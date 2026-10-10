# 03_wrds_full_sample.R
# Full-frame sample (PI instruction 2026-10-09): extract every eligible IJV in
# the WRDS ownership frame, match the JVs, their parents and the parents'
# global ultimate owners (GUOs) to Revelio, measure workforce coverage at the
# matched JV entities, and pull the full position histories of the employees
# of usable JVs. This extends Stage 4; it does not build the Stage 6 panel.
#
# Input: the frame written by 02_wrds_pilot_extract.R (including step A2, the
# intra-group exclusion) and its exposure-group file.
# Run on the PI's computer from the repository root:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/03_wrds_full_sample.R [v1|v2]
# v1 (default): the base frame of 02_wrds_pilot_extract.R. v2: the expanded
# frame of 05_wrds_frame_v2.R (relaxed Orbis rules and Capital IQ). v3: v2 plus
# the extra WRDS routes (05 with_dom with_small with_prior). v4: v3 plus
# external deal lists (06_ingest_external_jvs.R). Outputs of
# v2 carry "v2-" in their names; positions at JV entities and career
# histories are shared between versions and pulled incrementally.
# Every stage writes its output once and is skipped while the file exists.
#
# Matching follows the pilot rules (01_pilot_matching.R, data/codebook.md)
# with three additions that the pilots showed to be worthwhile:
#   - previous and also-known-as names of the JV from Orbis,
#   - the JV's native-script name (exact match after removing spaces and
#     punctuation), which matters for Chinese, Arabic and Cyrillic names,
#   - a hash join on six-character name prefixes so that one scan of
#     revelio.company_mapping serves all name keys.

source("code/R/00_setup.R")
require_pkgs(c("DBI", "RPostgres", "countrycode", "arrow", "R.utils"))
library(DBI)

FRAME_DATE <- "2026-10-08"
RUN_DATE   <- "2026-10-09"
VERSION    <- if (length(commandArgs(trailingOnly = TRUE))) commandArgs(trailingOnly = TRUE)[1] else "v1"
stopifnot(VERSION %in% c("v1", "v2", "v3", "v4"))
RUN        <- if (VERSION == "v1") RUN_DATE else paste0(VERSION, "-", RUN_DATE)
MAX_USERS_PER_JV <- 50000L
RN_MAX     <- 20L          # name candidates kept per entity and name source
YEAR_MAX   <- 2026L

f_frame   <- if (VERSION == "v1") file.path(paths$interim, sprintf("wrds-ijv-frame-%s.csv", FRAME_DATE)) else
               file.path(paths$interim, sprintf("wrds-ijv-frame-%s-%s.csv", VERSION, RUN_DATE))
f_groups  <- file.path(paths$interim, sprintf("wrds-ijv-frame-groups-%s.csv", FRAME_DATE))
f_size    <- file.path(paths$interim, sprintf("wrds-ijv-frame-size-%s.csv", FRAME_DATE))
f_orbis   <- file.path(paths$raw, sprintf("orbis-full-%s.csv", RUN))
f_cand    <- file.path(paths$raw, sprintf("revelio-companies-full-%s.csv.gz", RUN))
f_jvpos   <- file.path(paths$raw, sprintf("revelio-jv-positions-full-%s.parquet", RUN_DATE))
d_hist    <- file.path(paths$raw, sprintf("revelio-histories-full-%s", RUN_DATE))
f_matches <- file.path(paths$interim, sprintf("full-matches-%s.csv.gz", RUN))
f_rcids   <- file.path(paths$interim, sprintf("full-jv-rcids-%s.csv", RUN))
f_review  <- file.path(paths$interim, sprintf("full-jv-review-tier-%s.csv", RUN))
f_pgroups <- file.path(paths$interim, sprintf("full-parent-groups-%s.csv", RUN))
f_sample  <- file.path(paths$processed, sprintf("sample-ijv-%s.csv", RUN))
f_constr  <- file.path(paths$processed, if (VERSION == "v1") "sample-construction-log.md" else sprintf("sample-construction-log-%s.md", VERSION))
f_psize   <- file.path(paths$interim, sprintf("full-parent-size-%s.csv", RUN))
f_prsize  <- file.path(paths$interim, sprintf("full-parent-revelio-size-%s.csv", RUN))
OPERATING_MIN_EMP <- 50L   # a parent counts as an operating firm if it or its GUO has at least this many employees
f_log     <- file.path(paths$interim, sprintf("wrds-full-log-%s.md", RUN))

log_line <- function(...) {
  msg <- sprintf(...)
  message(format(Sys.time(), "%H:%M:%S"), " ", msg)
  cat("- ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " ", msg, "\n", file = f_log, append = TRUE, sep = "")
}
if (!file.exists(f_log)) cat("# WRDS full-sample extraction log, ", RUN, "\n\n", file = f_log, sep = "")
secs <- function(t0) as.numeric(Sys.time() - t0, units = "secs")

con <- dbConnect(RPostgres::Postgres(), host = "wrds-pgdata.wharton.upenn.edu", port = 9737,
                 dbname = "wrds", sslmode = "require",
                 user = Sys.getenv("WRDS_USERNAME"), password = Sys.getenv("WRDS_PASSWORD"))
on.exit(dbDisconnect(con), add = TRUE)
q <- function(sql) as.data.table(dbGetQuery(con, sql))
esc <- function(x) gsub("'", "''", x)
sql_in <- function(x) paste(sprintf("'%s'", esc(x)), collapse = ", ")
q_in <- function(template, ids, chunk = 2000L) {
  ids <- unique(ids[!is.na(ids) & ids != ""])
  if (!length(ids)) return(data.table())
  rbindlist(lapply(split(ids, ceiling(seq_along(ids) / chunk)), function(x) q(sprintf(template, sql_in(x)))), fill = TRUE)
}
to_iso2 <- function(x) suppressWarnings(countrycode::countrycode(x, "country.name", "iso2c", warn = FALSE))
# Native-name key: lower case, spaces and punctuation (ASCII and common
# full-width forms) removed. The same character class is used in SQL.
NATIVE_CLASS <- "[[:space:][:punct:]（）［］【】，、。．·・－—]"
native_key <- function(x) gsub(NATIVE_CLASS, "", tolower(x))

# ---- F1. Orbis extract of all eligible JVs --------------------------------
if (!file.exists(f_orbis)) {
  frame <- fread(f_frame, colClasses = list(character = c("jv_bvdid", "parent_bvdid", "parent_guo", "nace", "naics")))
  stopifnot("parent_guo" %in% names(frame))   # step A2 of 02_wrds_pilot_extract.R must have run
  orb <- frame[is.na(excl_jv) | as.character(excl_jv) == ""]
  ids <- unique(orb$jv_bvdid)
  t0 <- Sys.time()
  nm <- rbindlist(lapply(c("bvd_orbis_large.ob_w_company_id_table_l", "bvd_orbis_medium.ob_w_company_id_table_m"), function(t)
    q_in(paste0("SELECT DISTINCT ON (bvdid) bvdid AS jv_bvdid, name_native AS jv_name_native, prevname AS jv_prevname, akaname AS jv_akaname
                 FROM ", t, " WHERE bvdid IN (%s) ORDER BY bvdid"), ids)))
  nm <- unique(nm, by = "jv_bvdid")
  guo_ids <- unique(orb[parent_guo != parent_bvdid, parent_guo])
  gn <- rbindlist(lapply(c("bvd_orbis_large.ob_w_company_id_table_l", "bvd_orbis_medium.ob_w_company_id_table_m",
                           "bvd_orbis_small.ob_w_company_id_table_s"), function(t)
    q_in(paste0("SELECT DISTINCT ON (bvdid) bvdid AS parent_guo, name_internat AS guo_name, contact_ctryiso AS guo_country_orbis
                 FROM ", t, " WHERE bvdid IN (%s) ORDER BY bvdid"), guo_ids)))
  gn <- unique(gn, by = "parent_guo")
  orb <- merge(orb, nm, by = "jv_bvdid", all.x = TRUE)
  orb <- merge(orb, gn, by = "parent_guo", all.x = TRUE)
  if ("guo_name_pre" %in% names(orb)) orb[is.na(guo_name) & !is.na(guo_name_pre), guo_name := guo_name_pre]
  orb[parent_guo == parent_bvdid, guo_name := parent_name]
  orb[, guo_country := substr(parent_guo, 1, 2)]
  if (!"exposure_group" %in% names(orb)) {
    grp <- fread(f_groups, colClasses = list(character = "jv_bvdid"))[, .(jv_bvdid, region, industry, exposure_group)]
    orb <- merge(orb, grp, by = "jv_bvdid", all.x = TRUE)
  }
  sz <- if (file.exists(f_size)) fread(f_size, colClasses = list(character = "jv_bvdid")) else data.table(jv_bvdid = character(), employees = numeric(), fin_year = integer())
  miss <- setdiff(orb[!grepl("^CIQ", jv_bvdid), unique(jv_bvdid)], sz$jv_bvdid)
  if (length(miss)) {
    add <- rbindlist(lapply(c("bvd_orbis_large.ob_key_financials_usd_l", "bvd_orbis_medium.ob_key_financials_usd_m"), function(t)
      q_in(paste0("SELECT DISTINCT ON (bvdid) bvdid AS jv_bvdid, closdate_year AS fin_year, empl AS employees FROM ", t,
                  " WHERE bvdid IN (%s) AND closdate_year IS NOT NULL AND empl IS NOT NULL ORDER BY bvdid, closdate DESC"), miss)))
    sz <- unique(rbind(sz, add[order(jv_bvdid, -fin_year)], fill = TRUE), by = "jv_bvdid")
  }
  orb <- merge(orb, sz[, .(jv_bvdid, jv_employees = employees, jv_fin_year = fin_year)], by = "jv_bvdid", all.x = TRUE)
  setorder(orb, jv_bvdid, -equity_share_current, parent_country)
  fwrite(orb, f_orbis)
  log_line("F1 orbis extract: %d JV-parent rows, %d JVs, %d distinct GUOs differing from the parent (%d named) in %.0fs",
           nrow(orb), uniqueN(orb$jv_bvdid), length(guo_ids), nrow(gn), secs(t0))
}
orb <- fread(f_orbis, colClasses = list(character = c("jv_bvdid", "parent_bvdid", "parent_guo", "nace", "naics")))
jv  <- unique(orb, by = "jv_bvdid")[, intersect(c("jv_bvdid", "jv_name", "jv_country", "jv_name_native", "jv_prevname", "jv_akaname",
                                                   "jv_lei", "jv_isin", "jv_website", "formation_year", "exposure_group", "region", "industry",
                                                   "jv_employees", "n_parents", "source", "admitted_by", "formation_year_missing"),
                                                 names(orb)), with = FALSE]

# ---- F2. Revelio candidates ------------------------------------------------
# Name keys for JVs (main, previous and alias names), parents and GUOs.
split_names <- function(x) {
  x <- unlist(strsplit(ifelse(is.na(x), "", x), "|", fixed = TRUE))
  trimws(x[nzchar(trimws(x))])
}
name_key <- function(x) gsub("[^a-z0-9]", "", normalize_name(x))

if (!file.exists(f_cand)) {
  ents <- rbindlist(list(
    jv[, .(orbis_id = jv_bvdid, entity = "jv", src = "name", oname = jv_name, iso2 = jv_country)],
    jv[, .(oname = split_names(jv_prevname)), by = .(orbis_id = jv_bvdid, iso2 = jv_country)][
      , `:=`(entity = "jv", src = paste0("prev", seq_len(.N))), by = orbis_id],
    jv[, .(oname = split_names(jv_akaname)), by = .(orbis_id = jv_bvdid, iso2 = jv_country)][
      , `:=`(entity = "jv", src = paste0("aka", seq_len(.N))), by = orbis_id],
    unique(orb[, .(orbis_id = parent_bvdid, entity = "parent", src = "name", oname = parent_name, iso2 = parent_country)], by = "orbis_id"),
    unique(orb[parent_guo != parent_bvdid & !is.na(guo_name),
               .(orbis_id = parent_guo, entity = "guo", src = "name", oname = guo_name, iso2 = guo_country)], by = "orbis_id")
  ), use.names = TRUE)
  ents[, key := name_key(oname)]
  ents <- unique(ents[nchar(key) >= 2], by = c("orbis_id", "entity", "src"))
  fwrite(ents, file.path(paths$interim, sprintf("full-name-keys-%s.csv", RUN)))

  cm_cols <- "cm.rcid, cm.company, cm.hq_country, cm.ultimate_parent_rcid, cm.lei, cm.isin, cm.url, cm.linkedin_url"
  vals <- function(d) paste(sprintf("('%s', %d, '%s', '%s', '%s')", d$key, nchar(d$key), esc(d$orbis_id), d$entity, d$src), collapse = ",\n")
  name_sql <- function(d, k) sprintf("
WITH v(key, n, orbis_id, entity, src) AS (VALUES %s),
cm AS (SELECT %s, regexp_replace(lower(cm.company), '[^a-z0-9]', '', 'g') AS norm FROM revelio.company_mapping cm),
hits AS (
  SELECT v.orbis_id, v.entity, v.src, cm.*,
         row_number() OVER (PARTITION BY v.orbis_id, v.entity, v.src ORDER BY length(cm.norm), cm.rcid) AS rn
  FROM cm JOIN v ON left(cm.norm, %d) = left(v.key, %d) AND left(cm.norm, v.n) = v.key
)
SELECT orbis_id, entity, src, rcid, company, hq_country, ultimate_parent_rcid, lei, isin, url, linkedin_url
FROM hits WHERE rn <= %d", vals(d), cm_cols, k, k, RN_MAX)
  t0 <- Sys.time()
  # Name keys are searched in batches; each batch is cached so that a dropped
  # connection resumes from the last finished batch.
  d_batches <- file.path(paths$interim, sprintf("full-name-batches-%s", RUN))
  dir.create(d_batches, showWarnings = FALSE)
  batch_run <- function(d, k, size, tag) {
    idx <- split(seq_len(nrow(d)), ceiling(seq_len(nrow(d)) / size))
    rbindlist(lapply(seq_along(idx), function(i) {
      f <- file.path(d_batches, sprintf("%s-%03d.csv.gz", tag, i))
      if (!file.exists(f)) {
        t1 <- Sys.time()
        fwrite(q(name_sql(d[idx[[i]]], k)), f)
        log_line("F2 name batch %s %d of %d done in %.0fs", tag, i, length(idx), secs(t1))
      }
      fread(f, colClasses = list(character = c("orbis_id", "entity", "src")))
    }), use.names = TRUE)
  }
  cand <- rbindlist(list(batch_run(ents[nchar(key) >= 6], 6L, 40000L, "long"),
                         batch_run(ents[nchar(key) < 6], 2L, 4000L, "short")), use.names = TRUE)
  log_line("F2 name candidates: %d rows for %d of %d entity keys in %.0fs", nrow(cand),
           uniqueN(cand[, paste(orbis_id, entity)]), uniqueN(ents[, paste(orbis_id, entity)]), secs(t0))

  # Native-script names of JVs (only where they differ from the Latin name).
  nat <- jv[!is.na(jv_name_native) & jv_name_native != jv_name & grepl("[^ -~]", jv_name_native),
            .(orbis_id = jv_bvdid, key = native_key(jv_name_native))][nchar(key) >= 2]
  if (nrow(nat)) {
    t0 <- Sys.time()
    natc <- q(sprintf("
WITH v(key, orbis_id) AS (VALUES %s)
SELECT v.orbis_id, 'jv'::text AS entity, 'native'::text AS src, %s
FROM revelio.company_mapping cm JOIN v ON regexp_replace(lower(cm.company), '%s', '', 'g') = v.key",
      paste(sprintf("('%s', '%s')", esc(nat$key), esc(nat$orbis_id)), collapse = ","), cm_cols, NATIVE_CLASS))
    log_line("F2 native-name candidates: %d rows for %d of %d JVs with a native name in %.0fs",
             nrow(natc), uniqueN(natc$orbis_id), nrow(nat), secs(t0))
    cand <- rbindlist(list(cand, natc), use.names = TRUE)
  }
  # LEI and ISIN of JVs.
  for (idc in c("lei", "isin")) {
    col <- paste0("jv_", idc)
    ids <- jv[!is.na(get(col)) & get(col) != "", .(id = get(col), orbis_id = jv_bvdid)]
    if (!nrow(ids)) next
    idr <- q(sprintf("SELECT v.orbis_id, 'jv'::text AS entity, '%s'::text AS src, %s
                      FROM revelio.company_mapping cm JOIN (VALUES %s) AS v(id, orbis_id) ON cm.%s = v.id",
                     idc, cm_cols, paste(sprintf("('%s', '%s')", esc(ids$id), esc(ids$orbis_id)), collapse = ","), idc))
    log_line("F2 %s candidates: %d rows for %d JVs", idc, nrow(idr), uniqueN(idr$orbis_id))
    cand <- rbindlist(list(cand, idr), use.names = TRUE)
  }
  # Review-tier routes for JVs, host country only: website domain, website
  # stem and first two name tokens.
  rev_ctry <- q("SELECT DISTINCT hq_country FROM revelio.company_mapping WHERE hq_country IS NOT NULL")
  rev_ctry[, iso2 := to_iso2(hq_country)]
  rev_ctry <- rev_ctry[!is.na(iso2)]
  ctry_vals <- paste(sprintf("('%s', '%s')", esc(rev_ctry$hq_country), rev_ctry$iso2), collapse = ",")
  doms <- jv[!is.na(jv_website) & jv_website != "", .(domain = web_domains(jv_website)), by = .(orbis_id = jv_bvdid, iso2 = jv_country)]
  rkeys <- unique(rbind(
    doms[, .(key = gsub("[^a-z0-9]", "", sub("[.].*$", "", domain)), orbis_id, iso2, src = "web_stem")],
    jv[, .(key = vapply(strsplit(normalize_name(gsub("[(][^)]*[)]", " ", jv_name)), " "),
                        function(t) paste(head(t, 2), collapse = ""), character(1)),
           orbis_id = jv_bvdid, iso2 = jv_country, src = "stem2")]))[nchar(key) >= 5]
  t0 <- Sys.time()
  routes <- q(sprintf("
WITH v(key, n, orbis_id, iso2, src) AS (VALUES %s),
c(hq_country, iso2) AS (VALUES %s),
cm AS (SELECT %s, c.iso2, regexp_replace(lower(cm.company), '[^a-z0-9]', '', 'g') AS norm
       FROM revelio.company_mapping cm JOIN c ON c.hq_country = cm.hq_country),
hits AS (
  SELECT v.orbis_id, 'jv'::text AS entity, v.src, cm.*,
         row_number() OVER (PARTITION BY v.orbis_id, v.src ORDER BY length(cm.norm), cm.rcid) AS rn
  FROM cm JOIN v ON left(cm.norm, 5) = left(v.key, 5) AND left(cm.norm, v.n) = v.key AND cm.iso2 = v.iso2
)
SELECT orbis_id, entity, src, rcid, company, hq_country, ultimate_parent_rcid, lei, isin, url, linkedin_url FROM hits WHERE rn <= 30",
    paste(sprintf("('%s', %d, '%s', '%s', '%s')", rkeys$key, nchar(rkeys$key), esc(rkeys$orbis_id), rkeys$iso2, rkeys$src), collapse = ",\n"),
    ctry_vals, cm_cols))
  domr <- if (nrow(doms)) q(sprintf("
WITH d(domain, orbis_id, iso2) AS (VALUES %s), c(hq_country, iso2) AS (VALUES %s)
SELECT d.orbis_id, 'jv'::text AS entity, 'domain'::text AS src, %s
FROM revelio.company_mapping cm JOIN c ON c.hq_country = cm.hq_country
JOIN d ON regexp_replace(lower(cm.url), '^(https?://)?(www[.])?', '') = d.domain AND d.iso2 = c.iso2",
    paste(sprintf("('%s', '%s', '%s')", esc(doms$domain), esc(doms$orbis_id), doms$iso2), collapse = ","), ctry_vals, cm_cols)) else data.table()
  log_line("F2 review routes: %d stem rows and %d domain rows for %d JVs in %.0fs",
           nrow(routes), nrow(domr), uniqueN(c(routes$orbis_id, domr$orbis_id)), secs(t0))
  cand <- rbindlist(list(cand, routes, domr), use.names = TRUE)
  cand[, country := to_iso2(hq_country)]
  setnames(cand, "company", "company_name")
  fwrite(cand, f_cand)
  log_line("F2 candidates written: %s (%d rows)", f_cand, nrow(cand))
}
cand <- fread(f_cand, colClasses = list(character = c("orbis_id", "src", "entity")))
ents <- fread(file.path(paths$interim, sprintf("full-name-keys-%s.csv", RUN)), colClasses = list(character = c("orbis_id", "src", "entity")))

# ---- F3. Matching -----------------------------------------------------------
STATE_RX <- "government|ministry|state[- ]owned assets|sasac|republic of|kingdom of|municipal people|people's government|state of |commonwealth of|federal government|emirate of|sultanate"
method_rank <- c(id_exact = 1L, exact = 2L, normalized = 3L, native_exact = 4L, fuzzy = 5L)
if (!file.exists(f_matches)) {
  t0 <- Sys.time()
  nm_c <- cand[src %chin% c("name", "native", "lei", "isin") | grepl("^(prev|aka)[0-9]+$", src)]
  nm_c <- merge(nm_c, ents[, .(orbis_id, entity, src, oname, iso2)], by = c("orbis_id", "entity", "src"), all.x = TRUE)
  nm_c[is.na(iso2) & entity == "jv", iso2 := jv$jv_country[match(orbis_id, jv$jv_bvdid)]]
  nm_c[, `:=`(o_norm = normalize_name(oname), r_norm = normalize_name(company_name))]
  nm_c[, jw := 1 - stringdist::stringdist(o_norm, r_norm, method = "jw", p = 0.1)]
  nm_c[, method := fcase(src %chin% c("lei", "isin"), "id_exact",
                         src == "native", "native_exact",
                         toupper(oname) == toupper(company_name), "exact",
                         o_norm == r_norm & nzchar(o_norm), "normalized",
                         jw >= const$jw_threshold, "fuzzy",
                         default = NA_character_)]
  m <- nm_c[!is.na(method)]
  m[, score := fifelse(method == "fuzzy", jw, 1)]
  m[, same_country := fifelse(is.na(country) | is.na(iso2), NA, country == iso2)]
  m <- m[order(method_rank[method], -score)][, .SD[1], by = .(orbis_id, entity, rcid)]
  m[, n_candidates := .N, by = .(orbis_id, entity)]
  m[, needs_review := method == "fuzzy" | n_candidates > 1]
  m[, accepted := !needs_review | score >= 0.97]
  fwrite(m[, .(orbis_id, entity, src, rcid, company_name, country, ultimate_parent_rcid, oname, iso2, method, score,
               same_country, n_candidates, needs_review, accepted)], f_matches)
  log_line("F3 scored matches: %d pairs, %d accepted, in %.0fs", nrow(m), m[accepted == TRUE, .N], secs(t0))
}
m <- fread(f_matches, colClasses = list(character = c("orbis_id", "entity", "src")))
acc <- m[accepted == TRUE][order(method_rank[method], -score)]

# Parent families: parent's and GUO's own entities, extended to the whole
# Revelio family (ultimate parent and every company under it).
best_pa <- acc[entity == "parent"][, .SD[1], by = orbis_id]
# GUOs that are states or government bodies (for example "Government of
# China" for Chinese state-owned parents) supply no workforce and would merge
# unrelated state-owned firms into one family; they are not used.
state_guo <- unique(orb[grepl(STATE_RX, guo_name, ignore.case = TRUE), parent_guo])
best_gu <- acc[entity == "guo" & !orbis_id %in% state_guo][, .SD[1], by = orbis_id]
parent_core <- unique(rbind(
  best_pa[, .(parent_bvdid = orbis_id, rcid)],
  merge(unique(orb[parent_guo != parent_bvdid, .(parent_bvdid, parent_guo)]), best_gu[, .(parent_guo = orbis_id, rcid)],
        by = "parent_guo")[, .(parent_bvdid, rcid)]))
if (!file.exists(f_pgroups)) {
  core_up <- merge(parent_core, unique(cand[, .(rcid, up = ultimate_parent_rcid)], by = "rcid"), by = "rcid", all.x = TRUE)
  core_up[is.na(up), up := rcid]
  t0 <- Sys.time()
  fam <- q_in("SELECT rcid, ultimate_parent_rcid AS up FROM revelio.company_mapping WHERE ultimate_parent_rcid IN (%s)",
              as.character(unique(core_up$up)), chunk = 5000L)
  pg <- merge(unique(core_up[, .(parent_bvdid, up)]), fam, by = "up", allow.cartesian = TRUE)[, .(parent_bvdid, rcid)]
  pg <- unique(rbind(pg, parent_core, core_up[, .(parent_bvdid, rcid = up)]))
  fwrite(pg, f_pgroups)
  log_line("F3 parent families: %d parent-rcid rows for %d parents in %.0fs", nrow(pg), uniqueN(pg$parent_bvdid), secs(t0))
}
pg <- fread(f_pgroups, colClasses = list(character = "parent_bvdid"))

# JV picks: automatic tier with the pilot guards, then the review tier.
jv_acc <- acc[entity == "jv"]
jv_acc[, reject := fcase(rcid %in% parent_core$rcid, "is_parent_entity",
                         same_country %in% FALSE, "other_country", default = "")]
best_jv <- jv_acc[reject == ""][order(method_rank[method], -(same_country %in% TRUE), -score)][, .SD[1], by = orbis_id]
review_jv <- review_tier_candidates(
  cand[entity == "jv" & !orbis_id %in% best_jv$orbis_id][, match_key := src],
  jv[, .(orbis_id = jv_bvdid, orbis_name = jv_name, orbis_country = jv_country)],
  pg$rcid, orb[, .(orbis_id = jv_bvdid, parent_name)])
fwrite(review_jv, f_review)
picks <- rbindlist(list(
  best_jv[, .(jv_bvdid = orbis_id, rcid, tier = "auto", method, score)],
  if (nrow(review_jv)) review_jv[, .(jv_bvdid = orbis_id, rcid, tier = fifelse(strong, "strong", "review"), method, score)]))
# Manual decisions (PI or research assistant), files
# data/raw/manual/manual-matches-*.csv with columns jv_bvdid and decision
# (accept, reject or replace), and for replace either rcid_manual or
# linkedin_url. accept confirms the existing candidate, reject removes the JV
# from the matched set, replace sets the Revelio entity. Later files and later
# rows win. Manual picks have tier "manual" and rank above automatic ones.
f_man <- list.files(file.path(paths$raw, "manual"), "^manual-matches-.*[.]csv$", full.names = TRUE)
if (length(f_man)) {
  man <- rbindlist(lapply(f_man, function(f) cbind(fread(f, colClasses = "character"), manual_file = basename(f))), fill = TRUE)
  # Provenance: the text between "manual-matches-" and the date, for example
  # "claude" or a person's initials. Files from the agent triage
  # (08_triage_manual_candidates.R, prefix "claude") are read first, so any
  # decision by a person on the same IJV overrides them.
  man[, manual_by := gsub("[.]csv$", "", gsub("^manual-matches-|-[0-9]{4}-[0-9]{2}-[0-9]{2}[.]csv$", "", manual_file))]
  man <- man[order(-startsWith(manual_file, "manual-matches-claude-"))]
  for (cc in c("decision", "rcid_manual", "linkedin_url")) if (!cc %in% names(man)) man[, (cc) := NA_character_]
  man[, decision := tolower(trimws(decision))]
  man <- man[jv_bvdid %in% jv$jv_bvdid & decision %chin% c("accept", "reject", "replace")]
  man <- man[, .SD[.N], by = jv_bvdid]
  # LinkedIn company pages to Revelio ids: Revelio stores http://linkedin.com/company/<slug>.
  need <- man[decision == "replace" & (is.na(rcid_manual) | rcid_manual == "") & !is.na(linkedin_url) & linkedin_url != ""]
  if (nrow(need)) {
    need[, slug := sub("^.*linkedin[.]com/(company|school)/([^/?#]+).*$", "\\2", linkedin_url, ignore.case = TRUE)]
    slugs <- unique(c(need$slug, tolower(need$slug)))
    li <- q_in("SELECT rcid, linkedin_url FROM revelio.company_mapping WHERE linkedin_url IN (%s)",
               paste0("http://linkedin.com/company/", slugs))
    li[, slug := tolower(sub("^.*/company/", "", linkedin_url))]
    li <- unique(li, by = "slug")
    man[need, on = "jv_bvdid", rcid_manual := as.character(li$rcid[match(tolower(i.slug), li$slug)])]
    log_line("F3 manual: resolved %d of %d LinkedIn pages to Revelio ids", man[jv_bvdid %in% need$jv_bvdid & !is.na(rcid_manual), .N], nrow(need))
  }
  rej <- man[decision == "reject", jv_bvdid]
  acc <- man[decision == "accept", jv_bvdid]
  rep <- man[decision == "replace" & !is.na(rcid_manual) & rcid_manual != ""][, .(jv_bvdid, rcid = as.integer(rcid_manual))]
  picks <- picks[!jv_bvdid %in% c(rej, rep$jv_bvdid)]
  picks[jv_bvdid %in% acc, `:=`(tier = "manual", method = "manual_accept")]
  if (nrow(rep)) picks <- rbind(picks, rep[, .(jv_bvdid, rcid, tier = "manual", method = "manual_replace", score = 1)], fill = TRUE)
  picks[tier == "manual", manual_by := man$manual_by[match(jv_bvdid, man$jv_bvdid)]]
  log_line("F3 manual decisions: %d accepted (matched a candidate: %d), %d rejected, %d replaced; by source: %s", length(acc), picks[method == "manual_accept", .N],
           length(rej), nrow(rep), paste(sprintf("%s=%d", names(table(man$manual_by)), as.integer(table(man$manual_by))), collapse = ", "))
}
fwrite(picks, f_rcids)
log_line("F3 JV picks: %d automatic, %d strong review, %d other review; %d JV candidates rejected by the guards",
         picks[tier == "auto", .N], picks[tier == "strong", .N], picks[tier == "review", .N], jv_acc[reject != "", uniqueN(orbis_id)])

# ---- F4. Positions at the matched JV entities -------------------------------
have <- if (file.exists(f_jvpos)) unique(as.data.table(arrow::read_parquet(f_jvpos, col_select = "rcid"))$rcid) else integer()
f_pulled <- file.path(paths$interim, sprintf("full-jv-rcids-pulled-%s.csv", RUN_DATE))
tried <- if (file.exists(f_pulled)) fread(f_pulled)$rcid else have
todo <- setdiff(unique(picks$rcid), tried)
if (length(todo)) {
  t0 <- Sys.time()
  sizes <- q_in("SELECT rcid, count(DISTINCT user_id) AS n_users FROM revelio.individual_positions WHERE rcid IN (%s) GROUP BY rcid",
                as.character(todo), chunk = 500L)
  big <- sizes[n_users > MAX_USERS_PER_JV, rcid]
  if (length(big)) log_line("F4 skipped %d JV entities above %d users: %s", length(big), MAX_USERS_PER_JV, paste(big, collapse = ","))
  pull <- setdiff(sizes[n_users > 0, rcid], big)
  jp <- q_in("SELECT p.user_id, p.position_id, p.rcid, p.startdate AS start_date, p.enddate AS end_date, p.country,
                     p.seniority, p.role_k17000_v3, r.role_k10_v3 AS job_category, r.role_k50_v3
              FROM revelio.individual_positions p
              LEFT JOIN revelio.individual_role_lookup_v3 r USING (role_k17000_v3)
              WHERE p.rcid IN (%s)", as.character(pull), chunk = 200L)
  if (file.exists(f_jvpos)) jp <- rbindlist(list(as.data.table(arrow::read_parquet(f_jvpos)), jp), use.names = TRUE, fill = TRUE)
  jp <- unique(jp, by = "position_id")
  arrow::write_parquet(jp, f_jvpos)
  fwrite(data.table(rcid = union(tried, todo)), f_pulled)
  log_line("F4 JV positions: %d new entities pulled; file now %d rows, %d users, %d entities in %.0fs",
           length(pull), nrow(jp), uniqueN(jp$user_id), uniqueN(jp$rcid), secs(t0))
}
jp <- as.data.table(arrow::read_parquet(f_jvpos))

# ---- F5. Coverage and the sample table ---------------------------------------
jp[, `:=`(s = as.IDate(start_date), e = fifelse(is.na(end_date), as.IDate(Sys.Date()), as.IDate(end_date)))]
cov_for <- function(pk) {
  x <- merge(jp, pk[, .(rcid, jv_bvdid)], by = "rcid", allow.cartesian = TRUE)
  x <- merge(x, jv[, .(jv_bvdid, formation_year)], by = "jv_bvdid")
  cy <- rbindlist(lapply(seq(min(jv$formation_year, na.rm = TRUE), YEAR_MAX), function(y) {
    ref <- as.IDate(sprintf("%d-%s", y, const$reference_date))
    x[s <= ref & e >= ref & formation_year <= y, .(year = y, jv_bvdid, user_id, job_category, seniority)]
  }))
  per <- cy[, .(n_emp = uniqueN(user_id), n_years = uniqueN(year)), by = jv_bvdid]
  fc <- cy[, .(n = uniqueN(user_id)), by = .(jv_bvdid, year, job_category)][n >= const$min_cell_emp, .(function_cells_5 = .N), by = jv_bvdid]
  sc <- cy[, .(n = uniqueN(user_id)), by = .(jv_bvdid, year, seniority)][n >= const$min_cell_emp, .(seniority_cells_5 = .N), by = jv_bvdid]
  per <- merge(merge(per, fc, by = "jv_bvdid", all.x = TRUE), sc, by = "jv_bvdid", all.x = TRUE)
  per[is.na(function_cells_5), function_cells_5 := 0L][is.na(seniority_cells_5), seniority_cells_5 := 0L]
  per[, usable := n_emp >= const$min_ijv_emp & n_years >= const$min_years]
  per
}
# One JV per Revelio entity: where several JVs picked the same entity, the
# best tier keeps it (automatic, then strong, then review); a tie within the
# best tier drops all of them as ambiguous.
tier_rank <- c(manual = 0L, auto = 1L, strong = 2L, review = 3L)
# Within a tier, an Orbis JV is preferred over a Capital IQ JV on the same
# entity: the two are almost surely the same company recorded twice.
picks[, src := if ("source" %in% names(jv)) jv$source[match(jv_bvdid, jv$jv_bvdid)] else "orbis"]
picks[, tr := tier_rank[tier] * 10L + (src != "orbis")]
picks[, best_tr := min(tr), by = rcid]
picks[, n_best := sum(tr == best_tr), by = rcid]
shared_drop <- picks[tr > best_tr | n_best > 1, jv_bvdid]
picks_u <- picks[!jv_bvdid %in% shared_drop][, c("tr", "best_tr", "n_best", "src") := NULL]
cov <- cov_for(picks_u)
sample <- merge(jv, picks_u, by = "jv_bvdid", all.x = TRUE)
sample <- merge(sample, cov, by = "jv_bvdid", all.x = TRUE)
pa_stat <- merge(unique(orb[, .(jv_bvdid, parent_bvdid)]), unique(pg[, .(parent_bvdid, has_family = TRUE)]), by = "parent_bvdid", all.x = TRUE)
pa_stat <- pa_stat[, .(parents_in_revelio = sum(has_family %in% TRUE)), by = jv_bvdid]
sample <- merge(sample, pa_stat, by = "jv_bvdid", all.x = TRUE)
sample[jv_bvdid %in% shared_drop & is.na(tier), tier := "shared_entity_dropped"]
sample[is.na(tier), tier := "unmatched"]
sample[is.na(usable), usable := FALSE]
# Quality flags (2026-10-09 QA of the full run).
first_start <- jp[, .(first_start = min(s, na.rm = TRUE)), by = rcid]
sample <- merge(sample, first_start, by = "rcid", all.x = TRUE)
sample[, flag_pre_formation_10y := !is.na(first_start) & year(first_start) < formation_year - 10]
sample[, flag_holding_vehicle := grepl("holding", jv_name, ignore.case = TRUE) & (is.na(jv_employees) | jv_employees <= 5)]
sample[, flag_size_mismatch := !is.na(jv_employees) & jv_employees >= 10 & !is.na(n_emp) & n_emp / jv_employees > 20]
sample[, core := usable & (tier == "manual" | (tier %chin% c("auto", "strong") & !flag_size_mismatch))]
# Route and main-sample flags. Random audits on 2026-10-09 showed that Capital
# IQ prior co-ownership is mostly companies acquired in sequence, and that the
# Orbis small-library sample is mostly investor-owned start-ups. Neither is
# counted in the main sample; `core` stays as the upper bound.
if (!"admitted_by" %in% names(sample)) sample[, admitted_by := "base"]
if (!"source" %in% names(sample)) sample[, source := "orbis"]
sample[, route := fcase(grepl("ciq_prior", admitted_by), "capital_iq_prior",
                        source == "ciq", "capital_iq_current",
                        grepl("^ext_", source), "external",
                        grepl("small_library_sample", admitted_by), "orbis_small_sample",
                        grepl("guo_country", admitted_by), "orbis_owner_level",
                        admitted_by == "base", "orbis_base",
                        default = "orbis_relaxed")]
sample[, core_main := core & !route %chin% c("capital_iq_prior", "orbis_small_sample")]
# Strategic IJV: at least two parents are operating firms (the parent or its
# GUO has at least OPERATING_MIN_EMP employees in Orbis, latest year, or the
# parent's or GUO's matched Revelio entity has at least that many people). This
# separates JVs between operating companies from companies co-owned by
# founders' holding companies and investment vehicles, which Orbis also types
# as "Corporate".
if (!file.exists(f_psize)) {
  ids <- unique(c(orb$parent_bvdid, orb$parent_guo))
  t0 <- Sys.time()
  ps <- rbindlist(lapply(c("bvd_orbis_large.ob_key_financials_usd_l", "bvd_orbis_medium.ob_key_financials_usd_m",
                           "bvd_orbis_small.ob_key_financials_usd_s"), function(t)
    q_in(paste0("SELECT DISTINCT ON (bvdid) bvdid, closdate_year AS fin_year, empl AS employees FROM ", t,
                " WHERE bvdid IN (%s) AND empl IS NOT NULL ORDER BY bvdid, closdate DESC"), ids)))
  ps <- ps[order(bvdid, -fin_year)][, .SD[1], by = bvdid]
  fwrite(ps, f_psize)
  log_line("F5 parent sizes: Orbis headcount for %d of %d parents and GUOs in %.0fs", nrow(ps), length(ids), secs(t0))
}
ps <- fread(f_psize, colClasses = list(character = "bvdid"))
op <- unique(orb[, .(jv_bvdid, parent_bvdid, parent_guo)])
op[, emp_parent := ps$employees[match(parent_bvdid, ps$bvdid)]]
op[, emp_guo := ps$employees[match(parent_guo, ps$bvdid)]]
if (!file.exists(f_prsize)) {
  t0 <- Sys.time()
  rs <- q_in("SELECT rcid, count(DISTINCT user_id) AS n_users FROM revelio.individual_positions WHERE rcid IN (%s) GROUP BY rcid",
             as.character(unique(parent_core$rcid)), chunk = 300L)
  fwrite(rs, f_prsize)
  log_line("F5 parent Revelio sizes: %d of %d matched parent entities in %.0fs", nrow(rs), uniqueN(parent_core$rcid), secs(t0))
}
rs <- fread(f_prsize)
rev_users <- merge(parent_core, rs, by = "rcid")[, .(rev_users = max(n_users)), by = parent_bvdid]
op[, rev_users := rev_users$rev_users[match(parent_bvdid, rev_users$parent_bvdid)]]
op[, operating := pmax(emp_parent, emp_guo, rev_users, na.rm = TRUE) >= OPERATING_MIN_EMP]
op <- op[, .(operating_parents = sum(operating %in% TRUE)), by = jv_bvdid]
sample <- merge(sample, op, by = "jv_bvdid", all.x = TRUE)
sample[is.na(operating_parents), operating_parents := 0L]
sample[, strategic := operating_parents >= 2]
fwrite(sample, f_sample)
log_line("F5 sample table: %s; usable IJVs: auto %d, strong %d, review %d; core %d; core strategic %d; main %d; main strategic %d", f_sample,
         sample[usable & tier == "auto", .N], sample[usable & tier == "strong", .N], sample[usable & tier == "review", .N],
         sample[core == TRUE, .N], sample[core & strategic, .N], sample[core_main == TRUE, .N], sample[core_main & strategic, .N])

# Sample-construction log with counts at every step.
n_any <- uniqueN(cand[entity == "jv", orbis_id])
matched_tiers <- c("manual", "auto", "strong", "review")
funnel <- data.table(
  step = c("Eligible IJVs in the frame (after the intra-group rule)",
           "JVs with any Revelio candidate (all routes)",
           "JVs with an automatic match", "JVs with a strong review match (website route, close name)",
           "JVs with another review-tier match", "JVs with a manual (verified) match",
           "JVs dropped because another JV took the same Revelio entity",
           "Matched JVs with workforce data after formation",
           "Usable IJVs, automatic", "Usable IJVs, automatic plus strong", "Usable IJVs, all tiers",
           "Core sample: usable, automatic plus strong, no size mismatch",
           "  of which flagged: Revelio history starts more than 10 years before incorporation",
           "  of which flagged: holding vehicle matched to an operating company",
           "Eligible IJVs with at least two operating-firm parents (strategic)",
           "Core sample, strategic IJVs only",
           "Main sample: core without Capital IQ prior co-ownership and the small-library sample",
           "Main sample, strategic IJVs only"),
  n = c(nrow(jv), n_any, picks[tier == "auto", .N], picks[tier == "strong", .N], picks[tier == "review", .N], picks[tier == "manual", .N],
        length(unique(shared_drop)),
        sample[!is.na(n_emp), .N], sample[usable & tier == "auto", .N], sample[usable & tier %chin% c("manual", "auto", "strong"), .N],
        sample[usable & tier %chin% matched_tiers, .N], sample[core == TRUE, .N],
        sample[core & flag_pre_formation_10y, .N], sample[core & flag_holding_vehicle, .N],
        sample[strategic == TRUE, .N], sample[core & strategic, .N], sample[core_main == TRUE, .N], sample[core_main & strategic, .N]))
by_grp <- sample[, .(eligible = .N, matched = sum(tier %chin% matched_tiers), core = sum(core), core_main = sum(core_main),
                     main_strategic = sum(core_main & strategic)), by = exposure_group][order(-eligible)]
by_reg <- sample[, .(eligible = .N, matched = sum(tier %chin% matched_tiers), core = sum(core), core_main = sum(core_main),
                     main_strategic = sum(core_main & strategic)), by = region][order(-eligible)]
by_route <- sample[, .(eligible = .N, matched = sum(tier %chin% matched_tiers), core = sum(core), core_main = sum(core_main),
                       main_strategic = sum(core_main & strategic)), by = route][order(-eligible)]
mtab <- function(d) paste(c(paste("|", paste(names(d), collapse = " | "), "|"), paste("|", paste(rep("---", ncol(d)), collapse = " | "), "|"),
                            apply(d, 1, function(r) paste("|", paste(trimws(r), collapse = " | "), "|"))), collapse = "\n")
writeLines(c(sprintf("# Sample construction log (full frame, %s)", RUN), "",
             "Produced by `code/R/wrds/03_wrds_full_sample.R`. Usable: at least 20 employees and 3 years observed from the formation year.",
             "Core: usable, automatic or strong match, and Revelio employees not more than 20 times the Orbis headcount where Orbis reports 10 or more.",
             sprintf("Strategic: at least two parents are operating firms (the parent or its GUO has at least %d employees in Orbis).", OPERATING_MIN_EMP), "",
             "Main: core, excluding Capital IQ prior co-ownership (mostly sequential acquisitions) and the Orbis small-library sample (mostly investor-owned start-ups), by random audit on 2026-10-09.", "",
             mtab(funnel), "", "## By route", "", mtab(by_route), "", "## By exposure group", "", mtab(by_grp), "", "## By host region", "", mtab(by_reg)), f_constr)
log_line("F5 construction log written: %s", f_constr)

# ---- F6. Full position histories of employees of usable JVs -----------------
# Needed for prior-employer (localization) measures. Users with a JV spell
# overlapping 30 June of a year from the formation year onward, in usable JVs
# of the automatic and strong tiers. Written as a parquet dataset in chunks.
f_hist_users <- file.path(paths$interim, sprintf("full-history-users-%s.csv", RUN_DATE))
use <- sample[core_main == TRUE, .(jv_bvdid, rcid)]
{
  x <- merge(jp, use, by = "rcid", allow.cartesian = TRUE)
  x <- merge(x, jv[, .(jv_bvdid, formation_year)], by = "jv_bvdid")
  users <- unique(x[e >= as.IDate(sprintf("%d-%s", formation_year, const$reference_date)), user_id])
  dir.create(d_hist, recursive = TRUE, showWarnings = FALSE)
  # Users already pulled: the saved parts are the only record. Ids are compared
  # as plain numbers, because fread reads large ids as integer64 and arrow as
  # double, and a mixed comparison silently matches nothing.
  done <- unique(unlist(lapply(list.files(d_hist, full.names = TRUE, pattern = "parquet$"),
                               function(f) as.numeric(arrow::read_parquet(f, col_select = "user_id")$user_id))))
  users <- setdiff(as.numeric(users), done)
  t0 <- Sys.time()
  chunks <- split(users, ceiling(seq_along(users) / 5000L))
  start_i <- max(0L, as.integer(gsub("[^0-9]", "", list.files(d_hist, pattern = "^part-[0-9]+[.]parquet$"))), na.rm = TRUE)
  for (i in seq_along(chunks)) {
    h <- q(sprintf("SELECT p.user_id, p.position_id, p.rcid, p.ultimate_parent_rcid, p.startdate AS start_date, p.enddate AS end_date,
                           p.country, p.seniority, p.role_k17000_v3, r.role_k10_v3 AS job_category
                    FROM revelio.individual_positions p
                    LEFT JOIN revelio.individual_role_lookup_v3 r USING (role_k17000_v3)
                    WHERE p.user_id IN (%s)", paste(sprintf("%.0f", chunks[[i]]), collapse = ",")))
    arrow::write_parquet(h, file.path(d_hist, sprintf("part-%04d.parquet", start_i + i)))
    if (i %% 10 == 0 || i == length(chunks)) log_line("F6 histories: chunk %d of %d, %.0fs", i, length(chunks), secs(t0))
  }
  log_line("F6 histories: %d new users pulled into %s", length(users), d_hist)
}
log_line("full-sample run complete")
