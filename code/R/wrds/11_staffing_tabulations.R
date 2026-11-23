# 11_staffing_tabulations.R
# Feasibility counts for the staffing frame of docs/research-brief.md
# (geographic origin x organizational origin of IJV hires), run before gate 5
# on the PI's instruction of 2026-11-23 (docs/decisions.md). Read-only on the
# matched dataset. It answers feasibility questions Q1 to Q6:
#   T1  host-country and foreign parents per IJV                         (Q1)
#   T2  hires and person-years in the four categories and with history
#       not observed, by function, seniority and year; IJV support       (Q1, Q2, Q6)
#   T3  what "history not observed" consists of                          (Q3)
#   T3b entrants and unknown histories, from Revelio education records    (Q3)
#   T4  Orbis headcount against the Revelio count, as a coverage ratio   (Q4)
#   T4b the same by year, on unconsolidated Orbis headcounts              (Q4)
# T3b and T4b use the extracts of 12_wrds_headcount_education.R and are
# skipped with a message if those are not on disk.
#   T5  Revelio coverage and parent-origin staff by BoardEx linkage      (Q5)
#
# It is NOT the Stage 6 panel. The origin rule is the pilot's (prior position
# held within const$origin_window years before joining the JV) and is
# provisional until gate 5. No measure is built, the project's nine functions
# and four levels are not mapped (Revelio's own codes are used), and nothing
# is broken down by shock exposure group: that column is dropped on read.
#
# Definitions
#   hire        a person's first dated position at the matched JV entity, for
#               people who appear in the employee-spell table (at least one
#               30 June at the JV from the formation year on). Short stays
#               that cover no 30 June are therefore not hires here.
#   flow        hires with a hire year from the formation year to 2026
#   stock       person-years: one per person, IJV and 30 June
#   prior       positions at another employer that started before the hire
#               date and were ongoing or ended within the origin window
#   parent      any prior position in the window at an entity of a parent's
#               Revelio family; the most recent such position gives the
#               location and the parent. Otherwise the most recent prior
#               position decides (independent), with its location.
#   local       prior position located in the IJV's host country
#   not observed  no prior position in the window
#
# Run from the repository root after 09_build_matched_dataset.R and
# 10_boardex_coverage.R:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/11_staffing_tabulations.R [version]
# Outputs (gitignored, aggregated counts from licensed data):
#   data/interim/staffing-tabulations-<run>.md and staffing-tabulations-<run>/*.csv

source("code/R/00_setup.R")
require_pkgs(c("arrow", "countrycode"))
RUN_DATE <- "2026-10-09"
VERSION <- if (length(commandArgs(trailingOnly = TRUE))) commandArgs(trailingOnly = TRUE)[1] else "v3"
RUN <- if (VERSION == "v1") RUN_DATE else paste0(VERSION, "-", RUN_DATE)
YEAR_MAX <- 2026L
K_CHUNKS <- 8L
f_ijv    <- file.path(paths$processed, sprintf("ijv-matched-%s.csv", RUN))
f_par    <- file.path(paths$processed, sprintf("ijv-parents-%s.csv", RUN))
f_spell  <- file.path(paths$processed, sprintf("ijv-employee-spells-%s.parquet", RUN))
f_groups <- file.path(paths$interim, sprintf("full-parent-groups-%s.csv", RUN))
f_orbis  <- file.path(paths$raw, sprintf("orbis-full-%s.csv", RUN))
f_pos    <- file.path(paths$raw, sprintf("revelio-jv-positions-full-%s.parquet", RUN_DATE))
d_hist   <- file.path(paths$raw, sprintf("revelio-histories-full-%s", RUN_DATE))
f_bx     <- file.path(paths$interim, sprintf("boardex-coverage-%s.csv", RUN))
# Extracts of 12_wrds_headcount_education.R; T3b and T4b run only if they are on disk.
f_head   <- file.path(paths$raw, "orbis-jv-headcounts-2026-11-23.parquet")
d_edu    <- file.path(paths$raw, "revelio-education-full-2026-11-23")
ENTRANT_WINDOW <- const$origin_window   # years between the end of education and the hire year
d_out    <- file.path(paths$interim, sprintf("staffing-tabulations-%s", RUN))
f_md     <- file.path(paths$interim, sprintf("staffing-tabulations-%s.md", RUN))
dir.create(d_out, showWarnings = FALSE)
t0 <- Sys.time()
say <- function(...) message(format(Sys.time(), "%H:%M:%S"), " ", sprintf(...))
check <- function(cond, msg) { cat(if (isTRUE(cond)) "OK   " else "FAIL ", msg, "\n"); if (!isTRUE(cond)) stop("check failed: ", msg, call. = FALSE) }
pct <- function(x, d = 1) sprintf(paste0("%.", d, "f"), 100 * x)
npc <- function(n, tot) sprintf("%s (%s%%)", format(n, big.mark = ","), pct(n / tot))
kb <- function(d) knitr::kable(d, format = "pipe", format.args = list(big.mark = ","))
tabs <- list()                       # every table written is collected here
keep <- function(name, d) { tabs[[name]] <<- d; fwrite(d, file.path(d_out, paste0(name, ".csv"))); d }

CATS <- c(local_parent = "Local parent-origin", intl_parent = "International parent-origin",
          parent_unk = "Parent-origin, location not recorded",
          local_indep = "Independent local", intl_indep = "Independent international",
          indep_unk = "Independent, location not recorded", not_obs = "History not observed")

# ---- 0. Inputs -----------------------------------------------------------------
# na.strings = "" keeps the country code "NA" (Namibia) as a value.
ijv <- fread(f_ijv, colClasses = list(character = "jv_bvdid"), na.strings = "")
ijv[, exposure_group := NULL]        # never used here: the shock is not chosen by outcomes
par <- fread(f_par, colClasses = list(character = c("jv_bvdid", "parent_bvdid", "parent_guo")), na.strings = "")
par <- merge(par, ijv[, .(jv_bvdid, jv_country, source)], by = "jv_bvdid")
N_IJV <- nrow(ijv)

# ---- T1. Host-country and foreign parents ----------------------------------------
# Direct label: country of the direct shareholder. Owner label: country of the
# Orbis GUO (50 percent definition). Capital IQ parents carry no owner country.
par[, host_direct := parent_country == jv_country]
par[, guo_ok := source == "orbis" & grepl("^[A-Z]{2}", parent_guo)]
par[, host_guo := fifelse(guo_ok, guo_country == jv_country, NA)]
jvp <- par[, .(n_host_direct = sum(host_direct, na.rm = TRUE), n_foreign_direct = sum(!host_direct, na.rm = TRUE),
               n_host_guo = sum(host_guo, na.rm = TRUE), n_foreign_guo = sum(!host_guo, na.rm = TRUE), guo_known = all(!is.na(host_guo)),
               n_par = .N, n_par_revelio = sum(parent_in_revelio),
               host_par_revelio = any(host_direct & parent_in_revelio, na.rm = TRUE),
               foreign_par_revelio = any(!host_direct & parent_in_revelio, na.rm = TRUE)), by = jv_bvdid]
lab <- function(nh, nf) fifelse(nh >= 1L & nf >= 1L, "host-country and foreign parent",
                        fifelse(nh == 0L, "foreign parents only", "host-country parents only"))
jvp[, type_direct := lab(n_host_direct, n_foreign_direct)]
jvp[, type_guo := fifelse(guo_known, lab(n_host_guo, n_foreign_guo), "owner country not available (Capital IQ)")]
jvp[, host_parent := n_host_direct >= 1L]
jvp[, all_par_revelio := n_par_revelio == n_par]
ijv <- merge(ijv, jvp, by = "jv_bvdid")
check(nrow(ijv) == N_IJV, "every IJV has a parent label")
t1 <- function(col) {
  a <- ijv[, .(core_main = .N, strategic = sum(strategic)), by = c(type = col)]
  a[, .(type, core_main = npc(core_main, N_IJV), strategic = npc(strategic, ijv[strategic == TRUE, .N]))][order(type)]
}
keep("t1_parent_type_direct", t1("type_direct"))
keep("t1_parent_type_owner", t1("type_guo"))
keep("t1_direct_by_owner_orbis", dcast(ijv[guo_known == TRUE], type_direct ~ type_guo, value.var = "jv_bvdid", fun.aggregate = length))
keep("t1_parents_in_revelio", data.table(
  group = c("all IJVs", "all parents in Revelio", "at least one parent in Revelio", "no parent in Revelio",
            "host-country parent (direct)", "its host-country parent in Revelio", "host-country and foreign parent both in Revelio"),
  IJVs = c(N_IJV, ijv[all_par_revelio == TRUE, .N], ijv[n_par_revelio >= 1L, .N], ijv[n_par_revelio == 0L, .N],
           ijv[host_parent == TRUE, .N], ijv[host_parent & host_par_revelio, .N], ijv[host_parent & host_par_revelio & foreign_par_revelio, .N])))

# Parent families in Revelio, per IJV. A Revelio entity in two parents' families
# of the same IJV is given to the parent with the larger equity share.
grp <- fread(f_groups, colClasses = list(character = "parent_bvdid"))
fam <- merge(par[, .(jv_bvdid, parent_bvdid, parent_rank, host_direct, host_guo)], grp, by = "parent_bvdid", allow.cartesian = TRUE)
fam[, rcid := as.numeric(rcid)]
setorder(fam, jv_bvdid, rcid, parent_rank)
shared <- fam[, .N, by = .(jv_bvdid, rcid)][N > 1L]
n_shared <- nrow(shared); n_shared_ijv <- uniqueN(shared$jv_bvdid); rm(shared)
fam <- unique(fam, by = c("jv_bvdid", "rcid"))[, .(jv_bvdid, rcid, p_rank = parent_rank, p_host_direct = host_direct, p_host_guo = host_guo)]
fam <- fam[!ijv[, .(jv_bvdid, rcid = as.numeric(rcid_jv))], on = .(jv_bvdid, rcid)]   # the JV's own entity is not a parent employer
rm(grp); say("parent-family entities per IJV: %d rows (%d shared between two parents)", nrow(fam), n_shared)

# ---- Hires: first dated position at the JV entity --------------------------------
spells <- as.data.table(arrow::read_parquet(f_spell, col_select = c("jv_bvdid", "user_id", "first_reference_year", "last_reference_year", "seniority", "function_role_k10")))
pairs <- unique(spells[, .(jv_bvdid, user_id)])
pos <- as.data.table(arrow::read_parquet(f_pos, col_select = c("user_id", "position_id", "rcid", "start_date", "seniority", "job_category")))
pos <- unique(pos, by = "position_id")
pos <- merge(pos, ijv[, .(rcid = as.numeric(rcid_jv), jv_bvdid, formation_year, jv_country)], by = "rcid")
pos <- pos[pairs, on = .(jv_bvdid, user_id), nomatch = NULL]
pos[, start_date := as.IDate(start_date)]
setorder(pos, jv_bvdid, user_id, start_date, na.last = TRUE)
hire <- unique(pos, by = c("jv_bvdid", "user_id"))
n_undated <- hire[is.na(start_date), .N]
hire <- hire[!is.na(start_date), .(jv_bvdid, user_id, rcid_jv = rcid, hire_date = start_date, hire_year = year(start_date),
                                   fn = job_category, sen = seniority, formation_year, jv_country)]
rm(pos); invisible(gc())
say("hires: %d person-IJV pairs with a dated first position (%d pairs without a start date dropped)", nrow(hire), n_undated)

# ---- Career histories --------------------------------------------------------------
files <- list.files(d_hist, pattern = "[.]parquet$", full.names = TRUE)
hist <- rbindlist(lapply(files, function(f) as.data.table(arrow::read_parquet(f, col_select = c("user_id", "position_id", "rcid", "start_date", "end_date", "country")))))
hist <- unique(hist, by = "position_id")
users <- unique(hire$user_id)
n_users_no_hist <- sum(!users %in% hist$user_id)
hist <- hist[user_id %in% users]
cm <- data.table(country = unique(hist$country))
cm[, p_iso := suppressWarnings(countrycode::countrycode(country, "country.name", "iso2c", warn = FALSE))]
hist[cm, on = "country", p_iso := i.p_iso]
n_hist <- nrow(hist)
diag_hist <- hist[, .(positions = .N, employer_not_mapped = mean(is.na(rcid)), start_missing = mean(is.na(start_date)),
                      end_missing = mean(is.na(end_date)), country_missing = mean(is.na(p_iso)))]
hist[, `:=`(start_date = as.IDate(start_date), end_date = as.IDate(end_date), country = NULL, position_id = NULL)]
hist <- hist[!is.na(start_date)]
say("history positions of hired people: %d (users without any history: %d)", n_hist, n_users_no_hist)

# ---- Origin of each hire -------------------------------------------------------------
WIN <- const$origin_window * 365L
FAR <- as.IDate("2099-12-31")
origin <- rbindlist(lapply(seq_len(K_CHUNKS) - 1L, function(k) {
  pk <- hire[user_id %% K_CHUNKS == k, .(user_id, jv_bvdid, rcid_jv, hire_date)]
  pr <- hist[user_id %% K_CHUNKS == k][pk, on = "user_id", allow.cartesian = TRUE, nomatch = NULL]
  pr <- pr[is.na(rcid) | rcid != rcid_jv]
  pr[fam, on = .(jv_bvdid, rcid), `:=`(p_rank = i.p_rank, p_host_direct = i.p_host_direct, p_host_guo = i.p_host_guo)]
  pr[, is_par := !is.na(p_rank)]
  # Diagnostics without the window: any earlier position, any parent-family position before or after joining.
  dg <- pr[, .(has_earlier = any(start_date < hire_date), parent_before_any = any(is_par & start_date < hire_date),
               parent_from_hire_on = any(is_par & start_date >= hire_date)), by = .(user_id, jv_bvdid)]
  pw <- pr[start_date < hire_date & (is.na(end_date) | end_date >= hire_date - WIN)]
  pw[, end_eff := fifelse(is.na(end_date), FAR, end_date)]
  setorder(pw, user_id, jv_bvdid, -is_par, -end_eff, -start_date)
  dec <- unique(pw, by = c("user_id", "jv_bvdid"))[, .(user_id, jv_bvdid, in_window = TRUE, is_par, p_rank, p_host_direct, p_host_guo,
                                                        p_iso, employer_mapped = !is.na(rcid))]
  merge(dg, dec, by = c("user_id", "jv_bvdid"), all.x = TRUE)
}))
rm(hist); invisible(gc())
H <- merge(hire, origin, by = c("user_id", "jv_bvdid"), all.x = TRUE)
for (c in c("has_earlier", "parent_before_any", "parent_from_hire_on", "in_window")) set(H, which(is.na(H[[c]])), c, FALSE)
H[, geo := fifelse(!in_window, NA_character_, fifelse(is.na(p_iso), "unk", fifelse(p_iso == jv_country, "local", "intl")))]
H[, cat := fifelse(!in_window, "not_obs",
           fifelse(is_par, fifelse(geo == "local", "local_parent", fifelse(geo == "intl", "intl_parent", "parent_unk")),
                           fifelse(geo == "local", "local_indep", fifelse(geo == "intl", "intl_indep", "indep_unk"))))]
H[, cat := factor(cat, levels = names(CATS))]
H[, flow := hire_year >= formation_year & hire_year <= YEAR_MAX]
H <- merge(H, ijv[, .(jv_bvdid, strategic, region, host_parent, all_par_revelio, n_par_revelio, host_par_revelio)], by = "jv_bvdid")
check(nrow(H) == nrow(hire) && !anyNA(H$cat), sprintf("every hire has one category (%d hires)", nrow(H)))
check(nrow(H) + n_undated == nrow(pairs), "hires plus undated pairs equal the person-IJV pairs of the spell table")

# ---- Education of the hired people: entrants among "history not observed" ---------------
# Revelio education dates are years. A hire is a labor market entrant if the JV
# is the first recorded job and the last education that ended by the year after
# joining ended at most ENTRANT_WINDOW years before the hire year. The year
# after joining is allowed because people start work in their final year of
# study. Everything else without an observed history stays unknown.
edu_parts <- list.files(d_edu, pattern = "^part-[0-9]+[.]parquet$", full.names = TRUE)
HAS_EDU <- length(edu_parts) > 0L && length(edu_parts) == ceiling(uniqueN(pairs$user_id) / 5000)
if (!HAS_EDU) message("Education extract missing or incomplete: T3b is skipped (run 12_wrds_headcount_education.R).")
if (HAS_EDU) {
  edu <- rbindlist(lapply(edu_parts, function(f) as.data.table(arrow::read_parquet(f))))
  n_edu_dup <- sum(duplicated(edu, by = c("user_id", "education_number")))
  edu <- unique(edu, by = c("user_id", "education_number"))[user_id %in% H$user_id]
  n_edu <- nrow(edu); n_edu_users <- uniqueN(edu$user_id)
  edu[, end_year := year(as.IDate(enddate))]
  um <- data.table(university_country = unique(edu$university_country))
  um[, u_iso := suppressWarnings(countrycode::countrycode(university_country, "country.name", "iso2c", warn = FALSE))]
  edu[um, on = "university_country", u_iso := i.u_iso]
  eu <- edu[, .(has_edu = TRUE, has_end = any(!is.na(end_year))), by = user_id]
  H[eu, on = "user_id", `:=`(has_edu = i.has_edu, has_end = i.has_end)]
  H[is.na(has_edu), `:=`(has_edu = FALSE, has_end = FALSE)]
  x <- edu[!is.na(end_year), .(user_id, end_year, u_iso, degree, education_number)][H[, .(user_id, jv_bvdid, hire_year)], on = "user_id", allow.cartesian = TRUE, nomatch = NULL]
  x <- x[end_year <= hire_year + 1L]
  setorder(x, user_id, jv_bvdid, -end_year, -education_number)
  x <- unique(x, by = c("user_id", "jv_bvdid"))
  H[x, on = .(user_id, jv_bvdid), `:=`(edu_gap = hire_year - i.end_year, edu_iso = i.u_iso, edu_degree = i.degree)]
  rm(x, eu, edu, um); invisible(gc())
  H[, nobs_class := fifelse(cat != "not_obs", NA_character_,
                    fifelse(has_earlier, "earlier_jobs",
                    fifelse(!is.na(edu_gap) & edu_gap <= ENTRANT_WINDOW, "entrant",
                    fifelse(!is.na(edu_gap), "edu_long_before",
                    fifelse(has_end, "edu_after_joining", fifelse(has_edu, "edu_no_end_date", "no_edu_record"))))))]
  H[, cat2 := fifelse(cat != "not_obs", as.character(cat),
              fifelse(nobs_class != "entrant", "unknown",
              fifelse(is.na(edu_iso), "entrant_unk", fifelse(edu_iso == jv_country, "entrant_local", "entrant_intl"))))]
  say("education: %d records for %d of %d hired people", n_edu, n_edu_users, uniqueN(H$user_id))
} else H[, cat2 := as.character(cat)]
CATS2 <- c(CATS[1:6], entrant_local = "Labor market entrant, educated in host country", entrant_intl = "Labor market entrant, educated abroad",
           entrant_unk = "Labor market entrant, place of education not recorded", unknown = "History unknown", not_obs = "History not observed")
H[, cat2 := factor(cat2, levels = names(CATS2))]
Fl <- H[flow == TRUE]
say("hires from the formation year on: %d of %d", nrow(Fl), nrow(H))

# ---- Stock: person-years at 30 June ---------------------------------------------------
spells[H, on = .(jv_bvdid, user_id), `:=`(cat = i.cat, cat2 = i.cat2)]
spells <- spells[!is.na(cat)]
yrs <- seq(min(spells$first_reference_year), YEAR_MAX)
st <- lapply(yrs, function(y) {
  x <- unique(spells[first_reference_year <= y & last_reference_year >= y], by = c("jv_bvdid", "user_id"))
  list(cell = x[, .(py = .N), by = .(cat, cat2, fn = function_role_k10, sen = seniority)][, year := y],
       jv = x[, .(py = .N), by = .(jv_bvdid, cat)][, year := y])
})
stock <- rbindlist(lapply(st, `[[`, "cell")); stock_jv <- rbindlist(lapply(st, `[[`, "jv")); rm(st, spells); invisible(gc())
PY <- sum(stock$py)

# ---- T2. The staffing categories -------------------------------------------------------
cat_table <- function(d) {
  a <- d[, .(hires = .N), keyby = cat]
  b <- d[, .N, by = .(jv_bvdid, cat)][, .(ijv_1 = .N, ijv_5 = sum(N >= 5L), ijv_20 = sum(N >= 20L)), keyby = cat]
  merge(a, b, all.x = TRUE)
}
ov <- merge(cat_table(Fl), stock[, .(person_years = sum(py)), keyby = cat], all.x = TRUE)
keep("t2_categories_overall", ov[, .(category = CATS[as.character(cat)], hires, hires_pct = pct(hires / sum(hires)),
                                    person_years, person_years_pct = pct(person_years / sum(person_years)),
                                    ijvs_with_1 = ijv_1, ijvs_with_5 = ijv_5, ijvs_with_20 = ijv_20)])
sub <- list(`all IJVs` = Fl, `host-country parent (direct)` = Fl[host_parent == TRUE], `no host-country parent` = Fl[host_parent == FALSE],
            `all parents in Revelio` = Fl[all_par_revelio == TRUE], `no parent in Revelio` = Fl[n_par_revelio == 0L], strategic = Fl[strategic == TRUE])
keep("t2_categories_by_subset", Reduce(function(a, b) merge(a, b, by = "category", sort = FALSE), lapply(names(sub), function(n) {
  x <- sub[[n]][, .N, keyby = cat]; x <- x[J(factor(names(CATS), levels = names(CATS)))]; x[is.na(N), N := 0L]
  setnames(data.table(category = c("IJVs", "hires", unname(CATS)),
                      v = c(format(uniqueN(sub[[n]]$jv_bvdid), big.mark = ","), format(sum(x$N), big.mark = ","), pct(x$N / sum(x$N)))), "v", n)
})))
wide <- function(d, by) { x <- dcast(d, as.formula(paste(by, "~ cat")), value.var = "N", fill = 0L, drop = FALSE); setnames(x, names(CATS), unname(CATS), skip_absent = TRUE); x }
keep("t2_hires_by_function", wide(Fl[, .N, by = .(fn, cat)], "fn"))
keep("t2_hires_by_seniority", wide(Fl[, .N, by = .(sen, cat)], "sen"))
keep("t2_hires_by_year", wide(Fl[, .N, by = .(hire_year, cat)], "hire_year"))
period <- function(y) cut(y, c(-Inf, 1999, 2004, 2009, 2014, 2019, Inf), labels = c("to 1999", "2000-2004", "2005-2009", "2010-2014", "2015-2019", "2020-2026"))
keep("t2_hires_by_period", wide(Fl[, .N, by = .(period = period(hire_year), cat)], "period"))
keep("t2_person_years_by_function", wide(stock[, .(N = sum(py)), by = .(fn, cat)], "fn"))
keep("t2_person_years_by_seniority", wide(stock[, .(N = sum(py)), by = .(sen, cat)], "sen"))
keep("t2_person_years_by_year", wide(stock[, .(N = sum(py)), by = .(year, cat)], "year"))
# Which parent, and where, among parent-origin hires.
po <- Fl[is_par == TRUE]
gl <- c(local = "prior position in host country", intl = "prior position abroad", unk = "location not recorded")
keep("t2_parent_origin_by_parent_direct", dcast(po[, .N, by = .(parent = fifelse(is.na(p_host_direct), "parent country missing", fifelse(p_host_direct, "host-country parent's group", "foreign parent's group")),
                                                               where = gl[geo])], parent ~ where, value.var = "N", fill = 0L))
keep("t2_parent_origin_by_parent_owner", dcast(po[, .N, by = .(parent = fifelse(is.na(p_host_guo), "owner country not available", fifelse(p_host_guo, "group owned in host country", "group owned abroad")),
                                                              where = gl[geo])], parent ~ where, value.var = "N", fill = 0L))
# IJV support for the local parent-origin cell (the cell H3 and H4 rest on).
jc <- dcast(Fl[, .N, by = .(jv_bvdid, cat)], jv_bvdid ~ cat, value.var = "N", fill = 0L, drop = FALSE)
jy <- Fl[cat == "local_parent", .(lp_years = uniqueN(hire_year)), by = jv_bvdid]
jc <- merge(merge(ijv[, .(jv_bvdid, strategic, host_parent)], jc, by = "jv_bvdid", all.x = TRUE), jy, by = "jv_bvdid", all.x = TRUE)
for (c in c(names(CATS), "lp_years")) set(jc, which(is.na(jc[[c]])), c, 0L)
jc[, hires_all := rowSums(.SD), .SDcols = names(CATS)]
fwrite(jc, file.path(d_out, "ijv_category_counts.csv"))    # one row per IJV, for spot checks; not printed in the summary
sup <- function(d) c(nrow(d), d[hires_all >= 1L, .N], d[local_parent >= 1L, .N], d[local_parent >= 5L, .N], d[local_parent >= 20L, .N],
                     d[lp_years >= 3L, .N], d[lp_years >= 5L, .N], d[local_parent >= 5L & local_indep >= 5L, .N],
                     d[local_parent + intl_parent + parent_unk >= 5L, .N], d[intl_indep >= 5L, .N])
keep("t2_ijv_support", data.table(
  criterion = c("IJVs", "with at least one hire in the flow window", "1+ local parent-origin hire", "5+ local parent-origin hires", "20+ local parent-origin hires",
                "local parent-origin hires in 3+ hire years", "local parent-origin hires in 5+ hire years",
                "5+ local parent-origin and 5+ independent local hires", "5+ parent-origin hires, any location", "5+ independent international hires"),
  all = sup(jc), `host-country parent` = sup(jc[host_parent == TRUE]), `no host-country parent` = sup(jc[host_parent == FALSE]), strategic = sup(jc[strategic == TRUE])))
cf <- dcast(Fl[, .N, by = .(jv_bvdid, fn, cat)], jv_bvdid + fn ~ cat, value.var = "N", fill = 0L, drop = FALSE)
cf[, local_all := local_parent + local_indep]
keep("t2_ijv_function_cells", cf[, .(`IJV-function cells with hires` = .N, `cells with 5+ local hires` = sum(local_all >= 5L),
                                     `of these, 1+ local parent-origin` = sum(local_all >= 5L & local_parent >= 1L),
                                     `of these, 5+ local parent-origin` = sum(local_all >= 5L & local_parent >= 5L),
                                     `IJVs with 2+ functions that have 5+ local and 1+ local parent-origin hires` =
                                       sum(.SD[local_all >= 5L & local_parent >= 1L, .N, by = jv_bvdid]$N >= 2L))])
keep("t2_diagnostics", data.table(
  item = c("hires (person-IJV pairs with a dated first position)", "hired before the formation year (not in the flow window)",
           "any parent-family position before joining, at any distance in time", "parent-family position starting on or after the hire date",
           "independent hires whose prior employer is not mapped to a Revelio company", "parent-family entities shared by two parents of one IJV",
           "IJVs with such shared entities (the parents sit in one Revelio family)"),
  n = c(nrow(H), H[flow == FALSE, .N], H[parent_before_any == TRUE, .N], H[parent_from_hire_on == TRUE, .N],
        H[in_window & !is_par & !employer_mapped, .N], n_shared, n_shared_ijv),
  share_of_hires = c("", pct(H[flow == FALSE, .N] / nrow(H)), pct(H[, mean(parent_before_any)]), pct(H[, mean(parent_from_hire_on)]),
                     pct(H[in_window & !is_par & !employer_mapped, .N] / nrow(H)), "", "")))

# ---- T3. What "history not observed" consists of ----------------------------------------
# Education end dates are not in the local extract, so entrants cannot be told
# apart directly. Two indirect views: whether any earlier position exists, and
# the seniority at which the person joined.
no <- Fl[cat == "not_obs"]
keep("t3_not_observed_split", data.table(
  class = c("no earlier position on record (the JV is the first recorded job)", "earlier positions, all ended more than three years before joining", "all hires with history not observed"),
  hires = c(no[has_earlier == FALSE, .N], no[has_earlier == TRUE, .N], nrow(no)),
  share_of_all_hires = pct(c(no[has_earlier == FALSE, .N], no[has_earlier == TRUE, .N], nrow(no)) / nrow(Fl))))
keep("t3_not_observed_by_seniority", Fl[, .(hires = .N, not_observed_pct = pct(mean(cat == "not_obs")),
                                           first_recorded_job_pct = pct(mean(cat == "not_obs" & !has_earlier))), keyby = .(seniority = sen)])
keep("t3_not_observed_by_period", Fl[, .(hires = .N, not_observed_pct = pct(mean(cat == "not_obs")),
                                        first_recorded_job_pct = pct(mean(cat == "not_obs" & !has_earlier))), keyby = .(period = period(hire_year))])
keep("t3_not_observed_by_region", Fl[, .(hires = .N, not_observed_pct = pct(mean(cat == "not_obs")),
                                        first_recorded_job_pct = pct(mean(cat == "not_obs" & !has_earlier))), keyby = region])
keep("t3_history_fields", diag_hist[, .(positions, employer_not_mapped_pct = pct(employer_not_mapped), start_missing_pct = pct(start_missing),
                                        end_missing_or_ongoing_pct = pct(end_missing), country_missing_pct = pct(country_missing))])

# ---- T3b. Entrants and unknown histories, from the education records ---------------------
if (HAS_EDU) {
  NC <- c(entrant = sprintf("labor market entrant: first recorded job, last education ended at most %d years before the hire year", ENTRANT_WINDOW),
          edu_long_before = sprintf("first recorded job, last education ended more than %d years before", ENTRANT_WINDOW),
          edu_after_joining = "first recorded job, education on record ends only after joining",
          edu_no_end_date = "first recorded job, education record without an end date",
          no_edu_record = "first recorded job, no education record",
          earlier_jobs = "earlier positions, all ended more than three years before joining")
  no <- Fl[cat == "not_obs"]
  a <- no[, .(hires = .N), by = nobs_class][match(names(NC), nobs_class)]
  keep("t3b_not_observed_split", a[, .(class = NC[nobs_class], hires, pct_of_not_observed = pct(hires / nrow(no)), pct_of_all_hires = pct(hires / nrow(Fl)))])
  keep("t3b_education_coverage", Fl[, .(hires = .N, with_education_record_pct = pct(mean(has_edu)), with_end_date_pct = pct(mean(has_end))),
                                    keyby = .(group = fifelse(cat != "not_obs", "history observed", fifelse(has_earlier, "not observed, earlier positions on record", "not observed, first recorded job")))])
  first_job <- no[has_earlier == FALSE]
  keep("t3b_entrant_window_sensitivity", rbindlist(lapply(c(1L, 2L, 3L, 5L, 10L), function(k) {
    n <- first_job[!is.na(edu_gap) & edu_gap <= k, .N]
    data.table(years_between_education_and_hire = k, entrants = n, pct_of_not_observed = pct(n / nrow(no)), pct_of_all_hires = pct(n / nrow(Fl)))
  })))
  spl <- function(by) Fl[, .(hires = .N, not_observed_pct = pct(mean(cat == "not_obs")), entrant_pct = pct(mean(nobs_class %in% "entrant")),
                             unknown_pct = pct(mean(cat == "not_obs" & !nobs_class %in% "entrant"))), keyby = by]
  keep("t3b_split_by_period", spl(Fl[, .(period = period(hire_year))]))
  keep("t3b_split_by_seniority", spl(Fl[, .(seniority = sen)]))
  keep("t3b_split_by_region", spl(Fl[, .(region)]))
  en <- Fl[nobs_class %in% "entrant"]
  keep("t3b_entrants_by_place_of_education", en[, .(entrants = .N), keyby = cat2][, .(place = CATS2[as.character(cat2)], entrants, pct = pct(entrants / sum(entrants)))])
  keep("t3b_entrants_by_degree", en[, .(entrants = .N), by = .(degree = fifelse(is.na(edu_degree), "not recorded", edu_degree))][order(-entrants)][, pct := pct(entrants / sum(entrants))])
  fwrite(dcast(Fl[, .N, by = .(jv_bvdid, cat2)], jv_bvdid ~ cat2, value.var = "N", fill = 0L), file.path(d_out, "ijv_category_counts_with_entrants.csv"))   # for spot checks
  c2 <- merge(Fl[, .(hires = .N), keyby = cat2], stock[, .(person_years = sum(py)), keyby = cat2], all.x = TRUE)
  keep("t3b_categories_with_entrants", c2[, .(category = CATS2[as.character(cat2)], hires, hires_pct = pct(hires / sum(hires)),
                                              person_years, person_years_pct = pct(person_years / sum(person_years)))])
}

# ---- T4. Orbis headcount against Revelio ------------------------------------------------
# The local extract holds one Orbis headcount per IJV: the latest year in the
# key-financials table, taken without a consolidation filter. It is compared
# with the Revelio count at 30 June of the same year. Annual headcounts need a
# new WRDS pull. Parent-origin staff are NOT inferred from the difference.
ob <- unique(fread(f_orbis, select = c("jv_bvdid", "jv_employees", "jv_fin_year"), colClasses = list(character = "jv_bvdid")), by = "jv_bvdid")
cv <- merge(ijv[, .(jv_bvdid, source, strategic, n_emp)], ob, by = "jv_bvdid", all.x = TRUE)
rj <- stock_jv[, .(revelio = sum(py)), by = .(jv_bvdid, year)]
cv <- merge(cv, rj, by.x = c("jv_bvdid", "jv_fin_year"), by.y = c("jv_bvdid", "year"), all.x = TRUE)
cv[, has_orbis := !is.na(jv_employees) & jv_employees > 0]
cv[has_orbis & is.na(revelio), revelio := 0L]
cv[has_orbis == TRUE, ratio := revelio / jv_employees]
qs <- function(x) { q <- quantile(x, c(.1, .25, .5, .75, .9), na.rm = TRUE); data.table(n = sum(!is.na(x)), p10 = q[1], p25 = q[2], median = q[3], p75 = q[4], p90 = q[5], mean = mean(x, na.rm = TRUE)) }
keep("t4_orbis_headcount_available", data.table(
  group = c("all IJVs", "Orbis-sourced IJVs", "Capital IQ-sourced IJVs", "strategic IJVs"),
  IJVs = c(N_IJV, cv[source == "orbis", .N], cv[source == "ciq", .N], cv[strategic == TRUE, .N]),
  with_orbis_headcount = c(cv[, sum(has_orbis)], cv[source == "orbis", sum(has_orbis)], cv[source == "ciq", sum(has_orbis)], cv[strategic == TRUE, sum(has_orbis)])))
keep("t4_orbis_headcount_year", cv[has_orbis == TRUE, .(IJVs = .N), keyby = .(year = fifelse(jv_fin_year < 2015, "before 2015", as.character(jv_fin_year)))])
keep("t4_coverage_ratio", rbind(cbind(group = "all with an Orbis headcount", cv[has_orbis == TRUE, qs(ratio)]),
                                cbind(group = "Orbis headcount of 50 or more", cv[has_orbis & jv_employees >= 50, qs(ratio)]),
                                cbind(group = "Orbis headcount under 50", cv[has_orbis & jv_employees < 50, qs(ratio)]))[, lapply(.SD, function(x) if (is.numeric(x)) round(x, 2) else x)])
keep("t4_coverage_bands", cv[has_orbis == TRUE, .(IJVs = .N), keyby = .(ratio = cut(ratio, c(-Inf, 0, .1, .25, .5, 1, 2, Inf),
                                                   labels = c("no Revelio staff that year", "up to 0.10", "0.10 to 0.25", "0.25 to 0.50", "0.50 to 1", "1 to 2", "above 2")))][, pct := pct(IJVs / sum(IJVs))])

# ---- T4b. Annual Orbis headcounts by consolidation code -------------------------------------
# Consolidation codes found in the extract: U1 and U2 (unconsolidated accounts,
# without and with a consolidated companion), C1 and C2 (consolidated, without
# and with an unconsolidated companion) and LF (limited financials, basis not
# stated). This reading follows the Orbis convention and fits the data: C2 and
# U2 occur in the same IJV-years, and the consolidated headcount is the larger
# one. Unconsolidated here means U1 or U2. Years are the closing years; the
# Revelio count is taken at 30 June of the same year, from the formation year on.
HAS_HEAD <- file.exists(f_head)
if (!HAS_HEAD) message("Orbis annual headcounts missing: T4b is skipped (run 12_wrds_headcount_education.R).")
if (HAS_HEAD) {
  hc_all <- as.data.table(arrow::read_parquet(f_head))[jv_bvdid %in% ijv$jv_bvdid]
  hc_all[, `:=`(year = as.integer(closdate_year), closdate = as.IDate(closdate),
                basis = fifelse(conscode %in% c("U1", "U2"), "unconsolidated", fifelse(conscode %in% c("C1", "C2"), "consolidated", "limited financials")))]
  hc <- hc_all[empl > 0]
  keep("t4b_orbis_records_by_code", hc[, .(records = .N, ijv_years = uniqueN(paste(jv_bvdid, year)), IJVs = uniqueN(jv_bvdid)), keyby = .(conscode, basis)])
  cu <- merge(hc[basis == "consolidated", .(cons = max(empl)), by = .(jv_bvdid, year)], hc[basis == "unconsolidated", .(uncons = max(empl)), by = .(jv_bvdid, year)], by = c("jv_bvdid", "year"))
  keep("t4b_consolidated_against_unconsolidated", cu[, .(ijv_years_with_both = .N, IJVs = uniqueN(jv_bvdid), median_consolidated_over_unconsolidated = round(median(cons / uncons), 2),
                                                         pct_equal = pct(mean(cons == uncons)), pct_consolidated_larger = pct(mean(cons > uncons)))])
  # One unconsolidated headcount per IJV-year: twelve-month accounts first, then the latest closing date.
  un <- hc[basis == "unconsolidated"][, full := nr_months %in% "12"]
  un <- un[order(jv_bvdid, year, -full, -as.numeric(closdate), -empl)]
  n_un_dup <- un[, .N, by = .(jv_bvdid, year)][N > 1L, .N]
  un <- unique(un, by = c("jv_bvdid", "year"))
  pa <- merge(un[, .(jv_bvdid, year, empl, conscode)], ijv[, .(jv_bvdid, formation_year, strategic)], by = "jv_bvdid")
  n_pre <- pa[year < formation_year, .N]
  pa <- merge(pa[year >= formation_year & year <= YEAR_MAX], rj, by = c("jv_bvdid", "year"), all.x = TRUE)
  pa[is.na(revelio), revelio := 0L]
  pa[, ratio := revelio / empl]
  check(!anyDuplicated(pa, by = c("jv_bvdid", "year")), sprintf("one unconsolidated headcount per IJV-year (%d IJV-years)", nrow(pa)))
  ny <- pa[, .(n = .N, n10 = sum(year >= 2010L)), by = jv_bvdid]
  n_orb <- ijv[source == "orbis", .N]
  keep("t4b_ijvs_by_years_available", data.table(
    criterion = c("Orbis-sourced IJVs", "headcount on any basis in at least one year", "unconsolidated headcount in 1+ years", "in 3+ years", "in 5+ years", "in 10+ years",
                  "in 5+ years from 2010 on", "in 10+ years from 2010 on", "consolidated or limited-financials headcount only"),
    IJVs = c(n_orb, uniqueN(hc$jv_bvdid), nrow(ny), ny[n >= 3L, .N], ny[n >= 5L, .N], ny[n >= 10L, .N], ny[n10 >= 5L, .N], ny[n10 >= 10L, .N],
             uniqueN(hc$jv_bvdid) - uniqueN(un$jv_bvdid)))[, pct_of_orbis_sourced := pct(IJVs / n_orb)])
  per4 <- function(y) cut(y, c(-Inf, 2009, 2014, 2019, Inf), labels = c("to 2009", "2010-2014", "2015-2019", "2020-2026"))
  size5 <- function(e) cut(e, c(0, 9, 49, 249, 999, Inf), labels = c("1 to 9", "10 to 49", "50 to 249", "250 to 999", "1,000 or more"))
  rq <- function(d, by) { x <- d[, c(.(ijv_years = .N, IJVs = uniqueN(jv_bvdid)), as.list(round(quantile(ratio, c(.1, .25, .5, .75, .9)), 2)),
                                     .(pct_between_0.5_and_2 = pct(mean(ratio >= .5 & ratio <= 2)))), keyby = by]
                          setnames(x, c("10%", "25%", "50%", "75%", "90%"), c("p10", "p25", "median", "p75", "p90")); x }
  keep("t4b_ratio_by_period", rq(pa, pa[, .(period = per4(year))]))
  keep("t4b_ratio_by_year", rq(pa, pa[, .(year)]))
  keep("t4b_ratio_by_size", rq(pa, pa[, .(orbis_headcount = size5(empl))]))
  im <- pa[, .(n = .N, med = median(ratio), lo = min(ratio), hi = max(ratio)), by = jv_bvdid][n >= 5L]
  keep("t4b_ijv_level_ratio", im[, c(.(IJVs_with_5_or_more_years = .N), as.list(round(quantile(med, c(.1, .25, .5, .75, .9)), 2)),
                                     .(pct_whose_ratio_stays_within_a_factor_of_2 = pct(mean(lo > 0 & hi / lo <= 2))))])
  setorder(pa, jv_bvdid, year)
  pa[, `:=`(d_orbis = log(empl) - shift(log(empl)), d_rev = log(revelio) - shift(log(revelio)), step = year - shift(year)), by = jv_bvdid]
  tr <- pa[step == 1L & is.finite(d_orbis) & is.finite(d_rev)]
  keep("t4b_tracking_of_changes", data.table(year_on_year_pairs = nrow(tr), IJVs = uniqueN(tr$jv_bvdid),
                                             correlation_of_log_changes = round(cor(tr$d_orbis, tr$d_rev), 2),
                                             rank_correlation = round(cor(tr$d_orbis, tr$d_rev, method = "spearman"), 2),
                                             pct_same_direction = pct(tr[d_orbis != 0 & d_rev != 0, mean(sign(d_orbis) == sign(d_rev))])))
  # Latest year per IJV under three rules, to tie T4b to T4.
  pick_latest <- function(d) unique(d[order(jv_bvdid, -as.numeric(closdate), conscode)], by = "jv_bvdid")
  lat <- function(d, rule) { x <- merge(pick_latest(d)[empl > 0, .(jv_bvdid, year, empl)], rj, by = c("jv_bvdid", "year"), all.x = TRUE)
                             x[is.na(revelio), revelio := 0L]
                             data.table(rule = rule, IJVs = nrow(x), median_ratio = round(median(x$revelio / x$empl), 2)) }
  keep("t4b_latest_year_by_rule", rbind(lat(hc_all, "latest record, any consolidation code (rule of the earlier pull)"),
                                        lat(hc_all[basis == "unconsolidated"], "latest unconsolidated record"),
                                        lat(hc_all[basis == "consolidated"], "latest consolidated record")))
  old <- merge(hc_all, cv[!is.na(jv_employees), .(jv_bvdid, jv_employees, jv_fin_year)], by = "jv_bvdid")
  n_old <- uniqueN(old$jv_bvdid); n_old_found <- old[, .(hit = any(empl == jv_employees & year == jv_fin_year)), by = jv_bvdid][hit == TRUE, .N]
}

# ---- T5. Revelio coverage and parent-origin staff by BoardEx linkage ---------------------
bx <- fread(f_bx, select = c("jv_bvdid", "jv_match", "bx_people", "bx_people_parent_any"), colClasses = list(character = "jv_bvdid"), na.strings = "")
jh <- H[, .(hires = .N, parent_hires = sum(is_par, na.rm = TRUE), parent_hires_senior = sum(is_par & sen >= 5L, na.rm = TRUE), hires_senior = sum(sen >= 5L)), by = jv_bvdid]
jp <- stock_jv[, .(py = sum(py), py_parent = sum(py[cat %in% c("local_parent", "intl_parent", "parent_unk")])), by = jv_bvdid]
b5 <- Reduce(function(a, b) merge(a, b, by = "jv_bvdid", all.x = TRUE), list(ijv[, .(jv_bvdid, n_par_revelio)], bx, jh, jp, cv[, .(jv_bvdid, ratio)]))
b5[, group := fifelse(!(jv_match %in% "name_country"), "not in BoardEx (country-confirmed)",
              fifelse(bx_people_parent_any >= 1L, "in BoardEx, 1+ parent-linked senior person", "in BoardEx, no parent-linked person"))]
keep("t5_boardex_comparison", b5[, .(IJVs = .N, median_hires = as.numeric(median(hires)), median_coverage_ratio = round(median(ratio, na.rm = TRUE), 2),
                                    ijvs_with_ratio = sum(!is.na(ratio)), parent_share_of_person_years_pct = pct(sum(py_parent) / sum(py), 2),
                                    median_parent_share_pct = pct(median(py_parent / py), 2),
                                    ijvs_with_parent_hire_pct = pct(mean(parent_hires >= 1L)),
                                    ijvs_with_senior_parent_hire_pct = pct(mean(parent_hires_senior >= 1L)),
                                    ijvs_with_a_parent_in_revelio_pct = pct(mean(n_par_revelio >= 1L))), keyby = group])
keep("t5_boardex_parent_linked_only", b5[group == "in BoardEx, 1+ parent-linked senior person" & n_par_revelio >= 1L,
                                         .(IJVs = .N, with_parent_hire_in_revelio = sum(parent_hires >= 1L), with_senior_parent_hire_in_revelio = sum(parent_hires_senior >= 1L),
                                           with_no_parent_hire_in_revelio = sum(parent_hires == 0L))])

# ---- Checks ----------------------------------------------------------------------------
cat("\n")
check(sum(ov$hires) == nrow(Fl), "category counts add up to the hires in the flow window")
check(sum(ov$person_years) == PY, "category person-years add up to the stock")
check(!any(vapply(tabs, function(d) any(grepl("exposure", names(d))), logical(1))), "no table is broken down by exposure group")
check(n_users_no_hist == 0L, sprintf("every hired person has a career history on file (missing: %d)", n_users_no_hist))
if (HAS_EDU) {
  check(Fl[cat == "not_obs", .N] == Fl[cat2 %in% c("entrant_local", "entrant_intl", "entrant_unk", "unknown"), .N], "entrants and unknown histories add up to history not observed")
  check(sum(tabs$t3b_categories_with_entrants$person_years) == PY, "person-years by extended category add up to the stock")
  cat(sprintf("Education: %d records for %d people; %d repeated (user, education number) rows dropped\n", n_edu, n_edu_users, n_edu_dup))
}
if (HAS_HEAD) cat(sprintf("Orbis: %d IJV-years had several unconsolidated records (one kept); %d unconsolidated IJV-years before the formation year are left out; the single headcount of the earlier pull is found in the new extract for %d of %d IJVs\n",
                          n_un_dup, n_pre, n_old_found, n_old))
cat(sprintf("Plausibility against the pilots (person-years): parent-origin %s%%, history not observed %s%% (pilots: 4.4 and about 2.3; 47.0 and 49.4)\n",
            pct(ov[cat %in% c("local_parent", "intl_parent", "parent_unk"), sum(person_years)] / PY), pct(ov[cat == "not_obs", person_years] / PY)))

# ---- Summary file ----------------------------------------------------------------------
sec <- function(title, name, note = NULL) c(sprintf("### %s", title), "", kb(tabs[[name]]), "", note, if (!is.null(note)) "")
md <- c(sprintf("# Staffing tabulations (%s)", RUN), "",
  sprintf("Built %s by code/R/wrds/11_staffing_tabulations.R from the matched dataset of %s (%s IJVs). Feasibility counts for the staffing frame of docs/research-brief.md, run before gate 5 on the PI's instruction of 2026-11-23. The origin rule is the pilot's and is provisional. Nothing here is broken down by shock exposure group.",
          format(Sys.time(), "%Y-%m-%d %H:%M"), RUN, format(N_IJV, big.mark = ",")), "",
  sprintf("Hires: %s person-IJV pairs with a dated first position at the JV entity, %s of them from the formation year on (the flow window). Stock: %s person-years at 30 June.",
          format(nrow(H), big.mark = ","), format(nrow(Fl), big.mark = ","), format(PY, big.mark = ",")), "",
  "## T1. Host-country and foreign parents (Q1)", "",
  sec("By country of the direct shareholder", "t1_parent_type_direct"),
  sec("By country of the Orbis ultimate owner", "t1_parent_type_owner"),
  sec("Direct label against owner label, Orbis-sourced IJVs", "t1_direct_by_owner_orbis"),
  sec("Parents with a Revelio entity", "t1_parents_in_revelio", "A parent without a Revelio entity cannot be observed as a prior employer, so hires from it fall into the independent categories or into history not observed."),
  "## T2. The staffing categories (Q1, Q2, Q6)", "",
  sec("All IJVs: hires (flow window) and person-years", "t2_categories_overall"),
  sec("Hires by subset of IJVs (percent of hires)", "t2_categories_by_subset"),
  sec("Parent-origin hires by parent and location, direct label", "t2_parent_origin_by_parent_direct"),
  sec("Parent-origin hires by parent and location, owner label", "t2_parent_origin_by_parent_owner"),
  sec("IJVs that support each cell", "t2_ijv_support"),
  sec("IJV-function cells", "t2_ijv_function_cells"),
  sec("Hires by function (Revelio role_k10_v3)", "t2_hires_by_function"),
  sec("Hires by seniority (Revelio 1 to 7)", "t2_hires_by_seniority"),
  sec("Hires by period", "t2_hires_by_period"),
  sec("Person-years by function", "t2_person_years_by_function"),
  sec("Person-years by seniority", "t2_person_years_by_seniority"),
  sec("Diagnostics", "t2_diagnostics"),
  "Hires and person-years by single year are in the csv files.", "",
  "## T3. History not observed (Q3)", "",
  sec("Split", "t3_not_observed_split", "Education end dates are not in the local extract; telling entrants from truncated profiles directly needs a pull of the Revelio education table."),
  sec("By seniority at hire", "t3_not_observed_by_seniority"),
  sec("By hire period", "t3_not_observed_by_period"),
  sec("By host region", "t3_not_observed_by_region"),
  sec("Completeness of the history fields", "t3_history_fields"),
  if (HAS_EDU) c("## T3b. Entrants and unknown histories, from Revelio education records (Q3)", "",
    sprintf("Rule: a hire is a labor market entrant if the JV is the first recorded job and the last education that ended by the year after joining ended at most %d years before the hire year. Education dates are years. All other hires without an observed history stay unknown.", ENTRANT_WINDOW), "",
    sec("Education records by group of hires", "t3b_education_coverage"),
    sec("History not observed, split", "t3b_not_observed_split"),
    sec("Entrants under other windows", "t3b_entrant_window_sensitivity"),
    sec("By hire period (percent of hires)", "t3b_split_by_period"),
    sec("By seniority at hire (percent of hires)", "t3b_split_by_seniority"),
    sec("By host region (percent of hires)", "t3b_split_by_region"),
    sec("Where entrants were educated", "t3b_entrants_by_place_of_education"),
    sec("Entrants by degree of the last education", "t3b_entrants_by_degree"),
    sec("The staffing categories with entrants separated", "t3b_categories_with_entrants")),
  "## T4. Orbis headcount against Revelio (Q4)", "",
  sec("IJVs with an Orbis headcount", "t4_orbis_headcount_available", "One headcount per IJV (latest year in the Orbis key-financials table, no consolidation filter). Capital IQ-sourced IJVs have none."),
  sec("Year of the Orbis headcount", "t4_orbis_headcount_year"),
  sec("Coverage ratio: Revelio staff at 30 June of that year divided by the Orbis headcount", "t4_coverage_ratio", "The main sample excludes IJVs whose Revelio employee total exceeds 20 times the Orbis headcount, which bounds the upper tail."),
  sec("Coverage ratio in bands", "t4_coverage_bands"),
  if (HAS_HEAD) c("## T4b. Annual Orbis headcounts by consolidation code (Q4)", "",
    "Unconsolidated means consolidation code U1 or U2. The Revelio count is taken at 30 June of the closing year, from the formation year on. Capital IQ-sourced IJVs have no Orbis record. Parent-origin staff are not inferred from the difference.", "",
    sec("Headcount records by consolidation code", "t4b_orbis_records_by_code"),
    sec("Consolidated against unconsolidated headcount in the same IJV-year", "t4b_consolidated_against_unconsolidated"),
    sec("IJVs by number of years with a headcount", "t4b_ijvs_by_years_available"),
    sec("Coverage ratio by period: Revelio staff divided by the unconsolidated Orbis headcount", "t4b_ratio_by_period"),
    sec("Coverage ratio by Orbis headcount", "t4b_ratio_by_size"),
    sec("IJV-level median ratio, IJVs with five or more years", "t4b_ijv_level_ratio"),
    sec("Do the two counts move together from year to year", "t4b_tracking_of_changes"),
    sec("Latest year per IJV under three rules", "t4b_latest_year_by_rule", "The first row repeats T4 with the new extract. Ratios by single year are in the csv files.")),
  "## T5. BoardEx linkage (Q5)", "",
  sec("Revelio coverage and parent-origin staff by BoardEx group", "t5_boardex_comparison", "Senior means Revelio seniority 5 to 7. The groups differ in size and in whether a parent is in Revelio at all, so the comparison is descriptive."),
  sec("IJVs with a parent-linked senior person in BoardEx and at least one parent in Revelio", "t5_boardex_parent_linked_only"))
writeLines(md, f_md)
say("done in %.1f min; summary %s; %d tables in %s", as.numeric(Sys.time() - t0, units = "mins"), f_md, length(tabs), d_out)
