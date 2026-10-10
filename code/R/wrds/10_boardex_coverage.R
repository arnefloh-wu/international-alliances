# 10_boardex_coverage.R
# Coverage check for BoardEx as a source of parent-origin staffing (gate 4,
# decision 1, option 2). Read-only. For the IJVs of the recommended main sample
# it answers: how many JVs and parents can be found in BoardEx, how many senior
# people BoardEx records at the JVs, and how many of them have a role at one or
# both parent families. It does not build any measure.
#
# Matching is by normalized name (code/R/functions/matching.R) with a country
# check against BoardEx's head-office country. Parent families are the matched
# parent and GUO entities plus every BoardEx organisation whose ultimate parent
# is one of them.
#
# Run from the repository root after 09_build_matched_dataset.R:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/10_boardex_coverage.R [version]
# Outputs (gitignored, licensed): data/interim/boardex-coverage-<run>.csv and
# boardex-coverage-summary-<run>.md; raw pulls are cached in data/raw/.

source("code/R/00_setup.R")
source("code/R/functions/matching.R")
require_pkgs(c("arrow", "countrycode"))
RUN_DATE <- "2026-10-09"
VERSION <- if (length(commandArgs(trailingOnly = TRUE))) commandArgs(trailingOnly = TRUE)[1] else "v3"
RUN <- if (VERSION == "v1") RUN_DATE else paste0(VERSION, "-", RUN_DATE)
REGIONS <- c("na", "eur", "uk", "row")
f_ijv  <- file.path(paths$processed, sprintf("ijv-matched-%s.csv", RUN))
f_par  <- file.path(paths$processed, sprintf("ijv-parents-%s.csv", RUN))
f_prof <- file.path(paths$raw, "boardex-company-profile-2026-10-10.parquet")
f_jvp  <- file.path(paths$raw, "boardex-jv-roles-2026-10-10.parquet")
f_ppl  <- file.path(paths$raw, "boardex-jv-people-roles-2026-10-10.parquet")
f_out  <- file.path(paths$interim, sprintf("boardex-coverage-%s.csv", RUN))
f_sum  <- file.path(paths$interim, sprintf("boardex-coverage-summary-%s.md", RUN))
t0 <- Sys.time()
say <- function(...) message(format(Sys.time(), "%H:%M:%S"), " ", sprintf(...))

con <- DBI::dbConnect(RPostgres::Postgres(), host = "wrds-pgdata.wharton.upenn.edu", port = 9737,
                      dbname = "wrds", sslmode = "require",
                      user = Sys.getenv("WRDS_USERNAME"), password = Sys.getenv("WRDS_PASSWORD"))
on.exit(DBI::dbDisconnect(con))
q_in <- function(ids) paste(sprintf("%.0f", as.numeric(ids)), collapse = ",")

# ---- 1. BoardEx organisations --------------------------------------------------
if (!file.exists(f_prof)) {
  prof <- rbindlist(lapply(REGIONS, function(r) {
    say("company profile %s", r)
    as.data.table(DBI::dbGetQuery(con, sprintf(
      "SELECT boardid, boardname, hocountryname, orgtype, ultimateparentcompanyid FROM boardex.%s_wrds_company_profile", r)))
  }))
  prof <- unique(prof, by = "boardid")
  prof[, boardid := as.numeric(boardid)]
  prof[, ultimateparentcompanyid := suppressWarnings(as.numeric(ultimateparentcompanyid))]
  arrow::write_parquet(prof, f_prof)
}
prof <- as.data.table(arrow::read_parquet(f_prof))
say("BoardEx organisations: %d", nrow(prof))
# Drop the bracketed history notes ("(De-listed 04/2004)", "(X prior to 06/2001)") before normalizing.
prof[, name_clean := trimws(gsub("[(][^)]*[)]", " ", boardname))]
prof[, norm := normalize_name(name_clean)]
prof[, iso := suppressWarnings(countrycode::countrycode(hocountryname, "country.name", "iso2c", warn = FALSE))]
prof <- prof[nchar(norm) >= 4]

# ---- 2. Match JVs and parents to BoardEx ---------------------------------------
ijv <- fread(f_ijv, colClasses = list(character = "jv_bvdid"))
par <- fread(f_par, colClasses = list(character = c("jv_bvdid", "parent_bvdid", "parent_guo")))
targets <- rbind(
  ijv[, .(kind = "jv", key_id = jv_bvdid, name = jv_name, country = jv_country)],
  par[, .(kind = "parent", key_id = parent_bvdid, name = parent_name, country = parent_country)],
  par[!is.na(guo_name) & guo_name != "", .(kind = "guo", key_id = parent_guo, name = guo_name, country = guo_country)])
targets <- unique(targets, by = c("kind", "key_id"))
targets[, norm := normalize_name(name)]
targets <- targets[nchar(norm) >= 4]
cand <- merge(targets, prof[, .(norm, boardid, bx_name = name_clean, bx_iso = iso, bx_country = hocountryname, orgtype)],
              by = "norm", allow.cartesian = TRUE)
cand[, same_country := !is.na(bx_iso) & bx_iso == country]
# Keep same-country candidates where any exist; otherwise accept only a single unambiguous candidate.
cand[, any_same := any(same_country), by = .(kind, key_id)]
cand[, n_c := uniqueN(boardid), by = .(kind, key_id)]
cand <- cand[(any_same & same_country) | (!any_same & n_c == 1L)]
cand[, quality := fifelse(same_country, "name_country", "name_only")]
say("targets matched: jv %d of %d, parents %d of %d, guo %d of %d",
    cand[kind == "jv", uniqueN(key_id)], targets[kind == "jv", .N],
    cand[kind == "parent", uniqueN(key_id)], targets[kind == "parent", .N],
    cand[kind == "guo", uniqueN(key_id)], targets[kind == "guo", .N])

# Parent families: matched parent and GUO entities plus their BoardEx subsidiaries.
fam_seed <- cand[kind %in% c("parent", "guo"), .(key_id, boardid)]
fam_sub <- merge(fam_seed, prof[!is.na(ultimateparentcompanyid), .(boardid_sub = boardid, ultimateparentcompanyid)],
                 by.x = "boardid", by.y = "ultimateparentcompanyid", allow.cartesian = TRUE)
fam <- unique(rbind(fam_seed[, .(key_id, member = boardid)], fam_sub[, .(key_id, member = boardid_sub)]))
say("parent-family members: %d for %d parent or GUO ids", nrow(fam), uniqueN(fam$key_id))

# ---- 3. Roles recorded at the matched JVs --------------------------------------
jv_ids <- unique(cand[kind == "jv", boardid])
role_cols <- "directorid, directorname, companyid, companyname, datestartrole, dateendrole, rolename, brdposition, rowtype"
pull_roles <- function(where_col, ids, batch = 20000L) {
  rbindlist(lapply(REGIONS, function(r) rbindlist(lapply(split(ids, ceiling(seq_along(ids) / batch)), function(b)
    as.data.table(DBI::dbGetQuery(con, sprintf("SELECT %s FROM boardex.%s_dir_profile_emp WHERE %s IN (%s)",
                                               role_cols, r, where_col, q_in(b))))))))
}
if (!file.exists(f_jvp)) {
  say("roles at %d JV entities", length(jv_ids))
  jr <- pull_roles("companyid", jv_ids)
  jr <- unique(jr)
  arrow::write_parquet(jr, f_jvp)
}
jr <- as.data.table(arrow::read_parquet(f_jvp))
jr[, `:=`(directorid = as.numeric(directorid), companyid = as.numeric(companyid))]
say("roles at JV entities: %d for %d people", nrow(jr), uniqueN(jr$directorid))

# ---- 4. All other roles of those people (to find parent-family roles) -----------
people <- unique(jr$directorid)
if (!file.exists(f_ppl)) {
  say("all roles of %d people", length(people))
  pr <- unique(pull_roles("directorid", people))
  arrow::write_parquet(pr, f_ppl)
}
pr <- as.data.table(arrow::read_parquet(f_ppl))
pr[, `:=`(directorid = as.numeric(directorid), companyid = as.numeric(companyid))]
say("all roles of JV people: %d", nrow(pr))

# ---- 5. Link people to the JVs and their parent families -----------------------
jv_map <- unique(cand[kind == "jv", .(jv_bvdid = key_id, jv_boardid = boardid, jv_match = quality)])
par_rows <- merge(par[, .(jv_bvdid, parent_label, parent_bvdid, parent_guo)], fam, by.x = "parent_bvdid", by.y = "key_id", allow.cartesian = TRUE)
guo_rows <- merge(par[, .(jv_bvdid, parent_label, parent_guo)], fam, by.x = "parent_guo", by.y = "key_id", allow.cartesian = TRUE)
fam_jv <- unique(rbind(par_rows[, .(jv_bvdid, parent_label, member)], guo_rows[, .(jv_bvdid, parent_label, member)]))
# BoardEx often files the JV under one parent as its ultimate owner; the JV's own entity is not a parent role.
fam_jv <- fam_jv[!jv_map, on = .(jv_bvdid, member = jv_boardid)]

jv_people <- merge(unique(jr[, .(directorid, jv_boardid = companyid, jv_start = as.Date(datestartrole))]), jv_map, by = "jv_boardid", allow.cartesian = TRUE)
# a person's role at a parent family of the same JV
pr_fam <- merge(pr[, .(directorid, member = companyid, p_start = as.Date(datestartrole), p_end = as.Date(dateendrole))],
                fam_jv, by = "member", allow.cartesian = TRUE)
lnk <- merge(jv_people, pr_fam, by = c("directorid", "jv_bvdid"), allow.cartesian = TRUE)
lnk <- lnk[, .(any_role = TRUE, before_jv = any(!is.na(p_start) & !is.na(jv_start) & p_start <= jv_start)), by = .(directorid, jv_bvdid, parent_label)]

person_flags <- dcast(lnk, directorid + jv_bvdid ~ parent_label, value.var = "any_role", fun.aggregate = function(x) TRUE, fill = FALSE)
for (l in c("A", "B")) if (!l %in% names(person_flags)) person_flags[, (l) := FALSE]
person_flags[, both := A & B]
per_jv_people <- unique(jv_people[, .(jv_bvdid, directorid)])
per_jv_people <- merge(per_jv_people, person_flags[, .(jv_bvdid, directorid, A, B, both)], by = c("jv_bvdid", "directorid"), all.x = TRUE)
for (c in c("A", "B", "both")) set(per_jv_people, which(is.na(per_jv_people[[c]])), c, FALSE)
before <- lnk[before_jv == TRUE, .(has_before = TRUE), by = .(jv_bvdid, directorid)]
per_jv_people <- merge(per_jv_people, before, by = c("jv_bvdid", "directorid"), all.x = TRUE)
per_jv_people[is.na(has_before), has_before := FALSE]

agg <- per_jv_people[, .(bx_people = .N, bx_people_parent_a = sum(A), bx_people_parent_b = sum(B), bx_people_both = sum(both),
                         bx_people_parent_any = sum(A | B), bx_people_parent_before_jv = sum(has_before)), by = jv_bvdid]
# One row per IJV: a JV can match several BoardEx entities (duplicate names); keep the best match quality.
jv_one <- jv_map[order(jv_bvdid, jv_match)][, .(jv_in_boardex = TRUE, jv_match = jv_match[1], jv_boardids = .N), by = jv_bvdid]
cov <- merge(ijv[, .(jv_bvdid, jv_name, jv_country, region, exposure_group, strategic, formation_year, n_emp, parent_a_name, parent_b_name)],
             jv_one, by = "jv_bvdid", all.x = TRUE)
cov <- merge(cov, agg, by = "jv_bvdid", all.x = TRUE)
pm <- function(l) par[parent_label == l, .(jv_bvdid, hit = parent_bvdid %in% cand[kind == "parent", key_id] | parent_guo %in% cand[kind == "guo", key_id])]
cov <- merge(cov, setnames(pm("A"), "hit", "parent_a_in_boardex"), by = "jv_bvdid", all.x = TRUE)
cov <- merge(cov, setnames(pm("B"), "hit", "parent_b_in_boardex"), by = "jv_bvdid", all.x = TRUE)
for (c in c("jv_in_boardex", "parent_a_in_boardex", "parent_b_in_boardex")) set(cov, which(is.na(cov[[c]])), c, FALSE)
for (c in grep("^bx_people", names(cov), value = TRUE)) set(cov, which(is.na(cov[[c]])), c, 0L)
setorder(cov, jv_bvdid)
stopifnot(nrow(cov) == nrow(ijv), !anyDuplicated(cov$jv_bvdid))
fwrite(cov, f_out)
# Audit file: the matched BoardEx entity for every JV, to spot-check name matches by hand.
aud <- merge(cand[kind == "jv", .(jv_bvdid = key_id, jv_name = name, jv_country = country, boardid, bx_name, bx_country, quality)],
             jr[, .(bx_people_at_entity = uniqueN(directorid)), by = .(boardid = companyid)], by = "boardid", all.x = TRUE)
fwrite(aud[order(jv_bvdid)], file.path(paths$interim, sprintf("boardex-jv-matches-%s.csv", RUN)))

# ---- 6. Summary ------------------------------------------------------------------
N <- nrow(cov)
pc <- function(x) sprintf("%d (%.1f%%)", sum(x), 100 * mean(x))
tab <- function(d) data.table(
  IJVs = nrow(d),
  `JV in BoardEx` = pc(d$jv_in_boardex),
  `3+ people at JV` = pc(d$bx_people >= 3L),
  `both parents in BoardEx` = pc(d$parent_a_in_boardex & d$parent_b_in_boardex),
  `1+ person with a parent-family role` = pc(d$bx_people_parent_any >= 1L),
  `1+ person tied to both parents` = pc(d$bx_people_both >= 1L),
  `1+ person with a parent role before the JV role` = pc(d$bx_people_parent_before_jv >= 1L))
cov[, link_ab := bx_people_parent_a >= 1L & bx_people_parent_b >= 1L]
tab_core <- function(d) data.table(
  IJVs = nrow(d),
  `JV in BoardEx, country confirmed` = pc(d$jv_match %in% "name_country"),
  `and 3+ people` = pc(d$jv_match %in% "name_country" & d$bx_people >= 3L),
  `and 1+ parent-linked person` = pc(d$jv_match %in% "name_country" & d$bx_people_parent_any >= 1L),
  `and people linked to A and to B` = pc(d$jv_match %in% "name_country" & d$link_ab),
  `and one person tied to both` = pc(d$jv_match %in% "name_country" & d$bx_people_both >= 1L))
md <- c(sprintf("# BoardEx coverage of the main sample (%s)", RUN), "",
        "## Headline: country-confirmed JV matches only", "",
        knitr::kable(rbind(cbind(sample = "all", tab_core(cov)), cbind(sample = "strategic", tab_core(cov[strategic == TRUE]))), format = "pipe"), "",
        sprintf("Among country-confirmed JVs with people: median share of BoardEx people with a parent-family role %.2f, mean %.2f.",
                cov[jv_match %in% "name_country" & bx_people > 0, median(bx_people_parent_any / bx_people)],
                cov[jv_match %in% "name_country" & bx_people > 0, mean(bx_people_parent_any / bx_people)]), "",
        sprintf("Built %s by code/R/wrds/10_boardex_coverage.R. Matching is by normalized name with a head-office-country check; a person counts as parent-linked if they hold or held any BoardEx role at the matched parent, its GUO or a BoardEx subsidiary of either.", format(Sys.time(), "%Y-%m-%d %H:%M")), "",
        "## All main-sample IJVs", "", knitr::kable(tab(cov), format = "pipe"), "",
        "## Strategic IJVs", "", knitr::kable(tab(cov[strategic == TRUE]), format = "pipe"), "",
        "## By exposure group", "", knitr::kable(cov[, tab(.SD), by = exposure_group], format = "pipe"), "",
        "## By region", "", knitr::kable(cov[, tab(.SD), by = region], format = "pipe"), "",
        sprintf("People recorded at matched JV entities: %d; roles: %d. JV match quality: %s.", uniqueN(jr$directorid), nrow(jr),
                paste(names(table(cov$jv_match)), table(cov$jv_match), collapse = ", ")))
writeLines(md, f_sum)
say("done in %.1f min; summary %s", as.numeric(Sys.time() - t0, units = "mins"), f_sum)
