# synthetic_panel_build.R
# Synthetic input for the stage 6 panel build (code/R/02_build_panel.R and
# code/R/03_measures.R run with the argument "synthetic"). Every table has the
# columns and types of the real extract it stands for (panel_config() in
# code/R/functions/panel_build.R), but every value is made up: no real row is
# read, sampled or perturbed. Ids start with SYN or are small integers; O*NET
# codes are real code labels with made-up scores; industries, OEWS rows and
# rater scores are invented. The files carry synthetic = TRUE and may be committed.
#
# Seeded failures and edge cases (people S01 to S20 below), each with the
# expected handling that code/R/tests/check_panel_build.R verifies:
#   repeated position ids (spells, JV positions, histories), missing start dates,
#   open-ended positions, a person at two IJVs, hires outside 2010 to 2025 and
#   before the formation year, a parent's own entity matched as the IJV, an entity
#   in two parents' families, origin windows of 1, 3 and 5 years, entrants,
#   unmapped employers, prior positions without a country, home-country parent
#   hires, invalid O*NET values, positions coded through the role lookup, missing
#   seniority, a history position ending before it starts, and a first position
#   at the JV that covers no 30 June.
#
# Run from the repository root (seconds, no data needed):
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/tests/synthetic_panel_build.R
# Output: data/synthetic/panel-build-synthetic-2026-11-26/ (tables, parts and
#   seeded-cases.csv with the expected results)

source("code/R/00_setup.R")
require_pkgs("arrow")
set.seed(20261126)
D <- file.path("data", "synthetic", "panel-build-synthetic-2026-11-26")
unlink(D, recursive = TRUE); dir.create(D, recursive = TRUE)
for (s in c("revelio-histories", "revelio-jv-positions-onet", "revelio-education")) dir.create(file.path(D, s))
DATA_END <- as.IDate("2026-09-30")
d8 <- function(x) as.IDate(x)

# ---- Occupations, roles and scores (made-up scores on real code labels) ----------------------
occ <- data.table(
  onet_code = c("15-1252.00", "11-1021.00", "23-1011.00", "13-2011.00", "13-2051.00", "41-3091.00", "17-2141.00", "43-4051.00", "55-1011.00"),
  onet_title = paste("Synthetic occupation", 1:9), in_revelio = TRUE)
occ[, `:=`(soc_minor = substr(onet_code, 1, 4), soc_broad = substr(onet_code, 1, 6))]
occ[, regulatory_narrow := onet_code == "23-1011.00"]
occ[, regulatory_broad := onet_code %chin% c("23-1011.00", "13-2011.00")]
occ[, domain := fifelse(regulatory_narrow, "REG", soc_minor)]
occ[, score_imputed := onet_code == "55-1011.00"]
occ[, imputed_from := fifelse(score_imputed, "overall mean", "rated")]
sc <- c("local_embeddedness", "coord_dependence", "local_embeddedness_broad", "coord_dependence_broad", "local_embeddedness_lv", "coord_dependence_lv")
for (v in sc) occ[, (v) := round(rnorm(.N), 3)]
occ[, `:=`(law_gov_importance = round(runif(.N, 1, 5), 2), job_zone = sample(2:5, .N, TRUE))]
occ[score_imputed == TRUE, (c(sc, "law_gov_importance", "job_zone")) := lapply(.SD, function(x) 0), .SDcols = c(sc, "law_gov_importance", "job_zone")]
setcolorder(occ, c("onet_code", "onet_title", "in_revelio", "soc_minor", "soc_broad", "domain", "regulatory_narrow", "regulatory_broad", "score_imputed", "imputed_from"))
fwrite(occ, file.path(D, "contingency-scores-occupation.csv"))
dom <- occ[, c(lapply(.SD, mean), list(n_occupations = .N, n_rated = sum(!score_imputed), n_in_revelio = .N, all_imputed = all(score_imputed))),
           by = domain, .SDcols = c(sc, "law_gov_importance", "job_zone")]
fwrite(dom, file.path(D, "contingency-scores-domain.csv"))
K10 <- c("Engineer", "Operations", "Finance", "Sales and Marketing", "Technician")
roles <- data.table(role_k17000_v3 = sprintf("syn role %02d", 1:9), onet_code = occ$onet_code,
                    role_k50_v3 = sprintf("syn group %s", c("a", "a", "b", "b", "c", "c", "d", "d", "e")),
                    role_k10_v3 = K10[c(1, 2, 3, 3, 3, 4, 1, 5, 2)])
lk <- rbind(roles, roles[1:3][, role_k17000_v3 := paste(role_k17000_v3, "alt")])   # extra entries: taxonomy weights
lk[, `:=`(role_k10000_v3 = role_k17000_v3, role_k5000_v3 = role_k17000_v3, role_k1500_v3 = role_k17000_v3, role_k1000_v3 = role_k17000_v3,
          role_k500_v3 = role_k50_v3, role_k150_v3 = role_k50_v3, onet_title = "Synthetic occupation", synthetic = TRUE)]
lk <- rbind(lk, data.table(role_k17000_v3 = "syn role unknown", onet_code = "unknown", role_k50_v3 = "syn group e", role_k10_v3 = "Operations",
                           role_k10000_v3 = "x", role_k5000_v3 = "x", role_k1500_v3 = "x", role_k1000_v3 = "x", role_k500_v3 = "x",
                           role_k150_v3 = "x", onet_title = "unknown", synthetic = TRUE))
setcolorder(lk, c("role_k17000_v3", "role_k10000_v3", "role_k5000_v3", "role_k1500_v3", "role_k1000_v3", "role_k500_v3", "role_k150_v3", "role_k50_v3", "role_k10_v3", "onet_code", "onet_title"))
arrow::write_parquet(lk, file.path(D, "revelio-role-lookup.parquet"))
fwrite(data.table(group_id = sprintf("G%02d", 1:5), group_label = sprintf("syn group %s", letters[1:5]),
                  coord_dependence_rater = round(runif(5, 1, 5), 2), local_embeddedness_rater = round(runif(5, 1, 5), 2), synthetic = TRUE),
       file.path(D, "rater-scores.csv"))

# ---- IJVs and parents --------------------------------------------------------------------------
ijv <- data.table(jv_bvdid = sprintf("SYN%05d", 1:12), jv_name = sprintf("Synthetic Venture %02d", 1:12),
                  jv_country = c("GB", "DE", "GB", "FR", "FR", "IT", "US", "CN", "NA", "DE", "IN", "GB"))
ijv[, `:=`(region = "synthetic", industry = "manufacturing", formation_year = 2005L, formation_year_missing = FALSE,
           source = c(rep("orbis", 10), "ciq", "orbis"), route = "orbis_base", admitted_by = "base", exposure_group = NA_character_,
           n_parents = 2L, rcid_jv = 900000L + 1:12, match_tier = "auto", match_method = "exact", match_score = 1, manual_by = NA_character_,
           n_emp = 60L, n_years = 15L, function_cells_5 = 3L, seniority_cells_5 = 3L, jv_employees_orbis = 50L, operating_parents = 2L,
           strategic = TRUE, flag_pre_formation_10y = FALSE, flag_holding_vehicle = FALSE, jv_website = "", jv_lei = "")]
ijv[11, `:=`(formation_year = 2012L, route = "capital_iq_current", admitted_by = "ciq")]
ijv[c(5, 6), `:=`(route = "orbis_owner_level", admitted_by = "guo_country")]
pp <- data.table(
  jv = rep(1:12, each = 2), rank = rep(1:2, 12),
  ctry = c("DE","US", "DE","GB", "JP","IE", "FR","US", "FR","FR", "IT","IT", "GB","DE", "CN","DE", "NA","ZA", "DE","US", "IN","JP", "GB","FR"),
  share = c(60,40, 50,50, 60,40, 50,50, 60,40, 50,50, 50,50, 51,49, 50,50, 70,30, 50,50, 50,50))
pp[, guo_ctry := ctry]
pp[jv == 5, guo_ctry := c("GB", "FR")]              # owner-level control with a UK owner: dropped from controls
pp[jv == 6, guo_ctry := "JP"]                       # owner-level control without a UK link: kept
par <- pp[, .(jv_bvdid = sprintf("SYN%05d", jv), parent_rank = rank, parent_label = c("A", "B")[rank],
              parent_bvdid = sprintf("SYNP%03d%d", jv, rank), parent_name = sprintf("Synthetic Parent %03d%d", jv, rank),
              parent_country = ctry, parent_entity_type = "Corporate", equity_share_current = share,
              parent_guo = sprintf("SYNG%03d%d", jv, rank), guo_name = "Synthetic Owner", guo_country = guo_ctry,
              parent_in_revelio = TRUE, revelio_family_size = 3L)]
par[jv_bvdid == "SYN00011", guo_country := "CI"]
par[jv_bvdid == "SYN00009" & parent_rank == 2L, parent_in_revelio := FALSE]
fwrite(par, file.path(D, "ijv-parents.csv"))
fwrite(ijv, file.path(D, "ijv-matched.csv"))
# Families: parent (jv j, rank r) owns rcids 10000 * j + 100 * r + 1:3.
fam_rcid <- function(j, r, k = 1L) 10000L * j + 100L * r + k
grp <- par[, .(rcid = fam_rcid(as.integer(substr(jv_bvdid, 4, 8)), parent_rank, 1:3)), by = .(parent_bvdid, jv_bvdid, parent_rank)]
grp <- rbind(grp[, .(parent_bvdid, rcid)],
             data.table(parent_bvdid = "SYNP0101", rcid = 900010L),            # S09: IJV 10's own entity is in parent A's family
             data.table(parent_bvdid = c("SYNP0041", "SYNP0042"), rcid = 77777L))   # S14: entity in both parents' families (IJV 4)
grp <- rbind(grp, data.table(parent_bvdid = "SYNP0101", rcid = 900010L))       # repeated family row
fwrite(grp, file.path(D, "parent-groups.csv"))

# ---- People and positions ----------------------------------------------------------------------
JV <- list(); HI <- list(); ED <- list(); NOEXTRACT <- integer(); UNKNOWN_CODE <- integer()
pid <- 100000
jun30 <- function(y) as.IDate(sprintf("%d-06-30", y))
jvpos <- function(u, j, start, end = NA, role = 1L, sen = 3L, country = NULL) {
  pid <<- pid + 1
  JV[[length(JV) + 1L]] <<- data.table(user_id = u, position_id = pid, rcid = 900000 + j, start_date = d8(start), end_date = d8(end),
                                        country = if (is.null(country)) ijv$jv_country[j] else country, seniority = sen,
                                        role_k17000_v3 = roles$role_k17000_v3[role], job_category = roles$role_k10_v3[role],
                                        role_k50_v3 = roles$role_k50_v3[role], jv = j)
  invisible(pid)
}
hpos <- function(u, rcid, start, end = NA, country = "Germany") {
  pid <<- pid + 1
  HI[[length(HI) + 1L]] <<- data.table(user_id = u, position_id = pid, rcid = rcid, start_date = d8(start), end_date = d8(end), country = country)
  invisible(pid)
}
edu <- function(u, end_year, country) ED[[length(ED) + 1L]] <<- data.table(user_id = u, education_number = length(ED) + 1,
  startdate = d8(sprintf("%d-01-01", end_year - 3)), enddate = d8(sprintf("%d-01-01", end_year)), degree = "Bachelor", university_country = country)
cname <- c(GB = "United Kingdom", DE = "Germany", FR = "France", IT = "Italy", US = "United States", CN = "China", "NA" = "Namibia",
           IN = "India", JP = "Japan", IE = "Ireland", ZA = "South Africa")
exp <- list()
expect <- function(case, user, jv, what, value) exp[[length(exp) + 1L]] <<- data.table(case = case, user_id = user, jv_bvdid = sprintf("SYN%05d", jv), what = what, value = as.character(value))

# S01 repeated position ids: the JV position appears twice in the spells and in the JV positions; a history row twice.
p <- jvpos(1, 4, "2012-03-01", "2019-12-31", role = 1); JV[[length(JV) + 1L]] <- JV[[length(JV)]]
q <- hpos(1, fam_rcid(4, 1), "2005-01-01", "2011-06-30", "France"); HI[[length(HI) + 1L]] <- HI[[length(HI)]]
expect("S01 repeated position ids", 1, 4, "n_hires_person", 1); expect("S01 repeated position ids", 1, 4, "cat_w3", "local_parent")
# S02 only JV position without a start date: not a hire.
jvpos(2, 4, NA, "2020-12-31", role = 2); expect("S02 undated only position", 2, 4, "n_hires_person", 0)
# S03 undated position plus a dated one: the dated one is the hire.
jvpos(3, 4, NA, "2014-12-31", role = 2); jvpos(3, 4, "2015-02-01", NA, role = 2)
expect("S03 undated plus dated", 3, 4, "year", 2015)
# S04 history position without a start date is ignored: no prior position.
jvpos(4, 1, "2016-04-01", "2022-01-31", role = 3); hpos(4, fam_rcid(1, 1), NA, "2015-12-31", "Germany")
expect("S04 history start missing", 4, 1, "cat_w3", "not_obs")
# S05 open-ended parent position (secondment), started 1999: local parent-origin with any window.
jvpos(5, 1, "2018-05-01", NA, role = 1); hpos(5, fam_rcid(1, 2, 2), "1999-01-01", NA, "United Kingdom")
expect("S05 open-ended parent position", 5, 1, "cat_w1", "local_parent"); expect("S05 open-ended parent position", 5, 1, "cat_w3", "local_parent")
# S06 open-ended JV position: in the stock through 2025 (checked on the stock: employee in 2025).
jvpos(6, 2, "2011-01-10", NA, role = 6); expect("S06 open-ended JV position", 6, 2, "in_stock_2025", TRUE)
# S07 a person at two IJVs: hire at IJV 4 (2012) and at IJV 8 (2017); the IJV 4 position is an
# independent prior position for the IJV 8 hire (France, host CN: international).
jvpos(7, 4, "2012-01-15", "2016-08-31", role = 7); jvpos(7, 8, "2017-03-01", "2023-12-31", role = 7)
hpos(7, 900004, "2012-01-15", "2016-08-31", "France")
expect("S07 person at two IJVs", 7, 4, "year", 2012); expect("S07 person at two IJVs", 7, 8, "year", 2017)
expect("S07 person at two IJVs", 7, 8, "cat_w3", "intl_indep")
# S08 hires outside 2010 to 2025: 2008 (kept, main_period 0), 2026 (dropped), before formation (IJV 11, formed 2012: dropped).
jvpos(81, 1, "2008-03-01", "2012-12-31", role = 6); expect("S08 hire 2008", 81, 1, "year", 2008)
jvpos(82, 1, "2026-02-01", NA, role = 6); expect("S08 hire 2026", 82, 1, "n_hires_person", 0)
jvpos(83, 11, "2010-05-01", "2016-12-31", role = 6); expect("S08 hire before formation", 83, 11, "n_hires_person", 0)
# S09 parent's own entity matched as the IJV (IJV 10): flagged and kept; a prior position at another
# entity of parent A's family is parent-origin.
jvpos(9, 10, "2014-09-01", "2021-03-31", role = 4); hpos(9, fam_rcid(10, 1, 3), "2010-01-01", "2014-08-31", "Germany")
expect("S09 parent's own entity as IJV", 9, 10, "cat_w3", "local_parent")
# S10 windows: parent position ended 4.25 years before the hire, independent position 1.5 years before.
jvpos(10, 2, "2020-06-01", "2024-06-30", role = 1)
hpos(10, fam_rcid(2, 2, 1), "2010-01-01", "2016-03-01", "United Kingdom"); hpos(10, 555001, "2016-04-01", "2018-12-01", "Germany")
expect("S10 origin windows", 10, 2, "cat_w1", "not_obs"); expect("S10 origin windows", 10, 2, "cat_w3", "local_indep")
expect("S10 origin windows", 10, 2, "cat_w5", "intl_parent")
# S11 entrant: no earlier position; education ended two years before the hire year, in the host country.
jvpos(11, 3, "2019-09-01", "2023-08-31", role = 8, sen = 1); edu(11, 2017, "United Kingdom")
expect("S11 entrant", 11, 3, "entrant_e1", FALSE); expect("S11 entrant", 11, 3, "entrant_e3", TRUE); expect("S11 entrant", 11, 3, "entrant_place", "local")
# S12 unmapped prior employer abroad: independent international, unmapped.
jvpos(12, 3, "2017-01-09", NA, role = 3); hpos(12, NA, "2012-01-01", "2016-10-31", "France")
expect("S12 unmapped employer", 12, 3, "cat_w3", "intl_indep"); expect("S12 unmapped employer", 12, 3, "employer_mapped", FALSE)
# S13 parent position without a country: parent-origin, location not recorded.
jvpos(13, 12, "2018-02-01", NA, role = 2); hpos(13, fam_rcid(12, 2, 1), "2013-01-01", "2017-12-31", NA)
expect("S13 country missing", 13, 12, "cat_w3", "parent_na")
# S14 entity in both parents' families (IJV 4, FR host, parent A French): goes to parent A, a host-country parent.
jvpos(14, 4, "2016-01-04", NA, role = 5); hpos(14, 77777, "2011-01-01", "2015-12-31", "France")
expect("S14 shared family entity", 14, 4, "cat_w3", "local_parent"); expect("S14 shared family entity", 14, 4, "p_host", TRUE)
# S15 international parent-origin hire from the home country of a foreign direct parent (IJV 1: GB host, DE parent).
jvpos(15, 1, "2021-03-01", NA, role = 1); hpos(15, fam_rcid(1, 1, 1), "2015-01-01", "2021-02-28", "Germany")
expect("S15 home-country parent hire", 15, 1, "cat_w3", "intl_parent"); expect("S15 home-country parent hire", 15, 1, "home_country", TRUE)
# S16 invalid O*NET value in the extract: no domain (out of the domain panels, in the level panels).
UNKNOWN_CODE <- jvpos(16, 2, "2015-05-01", "2020-05-01", role = 1, sen = 4)
expect("S16 invalid O*NET value", 16, 2, "domain", NA); expect("S16 invalid O*NET value", 16, 2, "level", "middle_management")
# S17 position not in the O*NET extract: code from the role lookup.
NOEXTRACT <- jvpos(17, 2, "2016-07-01", "2022-07-01", role = 3)
expect("S17 lookup-coded position", 17, 2, "onet_source", "lookup"); expect("S17 lookup-coded position", 17, 2, "domain_b", "REG_B")
# S18 missing seniority: no level.
jvpos(18, 1, "2013-01-01", "2019-01-01", role = 7, sen = NA); expect("S18 seniority missing", 18, 1, "level", NA)
# S19 history position ending before it starts is dropped (the person has no other prior position).
jvpos(19, 12, "2019-01-01", NA, role = 6); hpos(19, fam_rcid(12, 1, 1), "2017-06-01", "2016-01-01", "United Kingdom")
expect("S19 end before start", 19, 12, "cat_w3", "not_obs")
# S20 first JV position covers no 30 June (Jan to Mar 2014); a later position does: the hire is the first.
p20 <- jvpos(20, 3, "2014-01-06", "2014-03-28", role = 2); jvpos(20, 3, "2015-01-05", NA, role = 2)
expect("S20 first position without 30 June", 20, 3, "year", 2014); expect("S20 first position without 30 June", 20, 3, "hire_in_spells", FALSE)
expect("S20 first position without 30 June", 20, 3, "onet_source", "lookup")

# Bulk: 45 people per IJV with random careers (volume for the cell rule).
u <- 1000
for (j in 1:12) for (k in 1:45) {
  u <- u + 1
  sy <- sample(max(2006L, ijv$formation_year[j]):2024, 1)
  st <- as.IDate(sprintf("%d-%02d-%02d", sy, sample(1:12, 1), sample(1:28, 1)))
  en <- if (runif(1) < .25) NA else st + sample(400:3000, 1)
  if (!is.na(en) && en > DATA_END) en <- NA
  jvpos(u, j, st, en, role = sample(1:9, 1, prob = c(4, 2, 1, 1, 1, 3, 2, 2, .3)), sen = sample(1:7, 1, prob = c(5, 4, 3, 2, 1.5, .5, .3)))
  nh <- sample(0:3, 1, prob = c(.3, .35, .25, .1)); last_end <- st - sample(10:900, 1)
  for (h in seq_len(nh)) {
    type <- sample(c("parent", "indep", "unmapped"), 1, prob = c(.15, .65, .2))
    r <- switch(type, parent = fam_rcid(j, sample(1:2, 1), sample(1:3, 1)), indep = 500000 + sample(1:300, 1), unmapped = NA)
    hc <- if (runif(1) < .6) cname[ijv$jv_country[j]] else sample(cname, 1)
    if (runif(1) < .05) hc <- NA
    s0 <- last_end - sample(300:2500, 1)
    hpos(u, r, s0, last_end, unname(hc)); last_end <- s0 - sample(30:600, 1)
  }
  if (runif(1) < .7) edu(u, year(st) - sample(-1:8, 1), unname(if (runif(1) < .7) cname[ijv$jv_country[j]] else sample(cname, 1)))
}
J <- rbindlist(JV)

# ---- Spells: positions covering at least one 30 June from the formation year on ---------------------
J[, fy := ijv$formation_year[jv]]
ref <- J[!is.na(start_date), {
  y0 <- max(year(start_date), fy); y1 <- min(year(fifelse(is.na(end_date), DATA_END, end_date)), 2026L)
  ys <- if (y1 >= y0) seq(y0, y1) else integer()
  ys <- ys[jun30(ys) >= start_date & jun30(ys) <= fifelse(is.na(end_date), DATA_END, end_date)]
  list(first_reference_year = if (length(ys)) min(ys) else NA_integer_, last_reference_year = if (length(ys)) max(ys) else NA_integer_, n_ref = length(ys))
}, by = .(position_id)]
J[ref, on = "position_id", `:=`(first_reference_year = i.first_reference_year, last_reference_year = i.last_reference_year, n_reference_dates = i.n_ref)]
J[user_id == 2, `:=`(first_reference_year = 2015L, last_reference_year = 2020L, n_reference_dates = 6L)]   # S02: undated but in the spell table
J[user_id == 3 & is.na(start_date), `:=`(first_reference_year = 2010L, last_reference_year = 2014L, n_reference_dates = 5L)]
S <- J[!is.na(first_reference_year), .(jv_bvdid = sprintf("SYN%05d", jv), rcid = as.integer(rcid), user_id, position_id, start_date, end_date,
         ongoing = is.na(end_date), first_reference_year = as.numeric(first_reference_year), last_reference_year = as.numeric(last_reference_year),
         n_reference_dates = as.integer(n_reference_dates), country = cname[country], seniority = as.integer(seniority), role_k17000_v3,
         function_role_k10 = job_category, role_k50_v3, synthetic = TRUE)]
S <- rbind(S, S[user_id == 1])                                # S01: repeated spell row
arrow::write_parquet(S, file.path(D, "ijv-employee-spells.parquet"))
JP <- J[, .(user_id, position_id, rcid = as.numeric(rcid), start_date, end_date, country = cname[country], seniority = as.integer(seniority),
            role_k17000_v3, job_category, role_k50_v3, synthetic = TRUE)]
arrow::write_parquet(JP, file.path(D, "revelio-jv-positions.parquet"))
# O*NET extract: spell positions only, minus the lookup case (S17); S16 carries "unknown".
OX <- unique(S[, .(position_id, role_k17000_v3)], by = "position_id")[position_id != NOEXTRACT]
OX[, onet_code := roles$onet_code[match(role_k17000_v3, roles$role_k17000_v3)]]
OX[position_id == UNKNOWN_CODE, onet_code := "unknown"]
arrow::write_parquet(OX[, .(position_id, onet_code, synthetic = TRUE)], file.path(D, "revelio-jv-positions-onet", "part-0001.parquet"))
# Histories hold the whole career, the JV positions included (the build ignores positions at the JV entity).
HH <- rbind(rbindlist(HI), J[, .(user_id, position_id, rcid, start_date, end_date, country = cname[country])], use.names = TRUE)
HH[, `:=`(ultimate_parent_rcid = rcid, seniority = 3L, role_k17000_v3 = "syn role 01", job_category = "Engineer", synthetic = TRUE)]
setcolorder(HH, c("user_id", "position_id", "rcid", "ultimate_parent_rcid", "start_date", "end_date", "country", "seniority", "role_k17000_v3", "job_category"))
half <- HH$user_id %% 2 == 0
arrow::write_parquet(HH[half], file.path(D, "revelio-histories", "part-0001.parquet"))
arrow::write_parquet(HH[!half], file.path(D, "revelio-histories", "part-0002.parquet"))
arrow::write_parquet(rbindlist(ED)[, synthetic := TRUE], file.path(D, "revelio-education", "part-0001.parquet"))

# ---- Frame, exposure, headcounts, industry, OEWS --------------------------------------------------------
fwrite(data.table(jv_bvdid = ijv$jv_bvdid, jv_listed = c("Listed", rep("Unlisted", 9), "", "Delisted"),
                  jv_isin = c(rep("", 10), "SYNISIN0011", ""), source = ijv$source, synthetic = TRUE), file.path(D, "orbis-frame.csv"))
ex <- rbind(
  data.table(variant = "main: EU27+EEA+CH, parent-host pairs, onset 2021", jv_bvdid = sprintf("SYN%05d", c(1, 2, 3, 12)), pair = c("GB-DE", "GB-DE", "GB-IE", "GB-FR")),
  data.table(variant = "Ireland excluded (Common Travel Area)", jv_bvdid = sprintf("SYN%05d", c(1, 2, 12)), pair = c("GB-DE", "GB-DE", "GB-FR")),
  data.table(variant = "parent-parent pairs hosted in third countries", jv_bvdid = "SYN00007", pair = "GB-DE"),
  data.table(variant = "Orbis-sourced, owner (GUO) country", jv_bvdid = sprintf("SYN%05d", c(1, 2, 3, 12)), pair = c("GB-DE", "GB-DE", "GB-IE", "GB-FR")))
ex[, `:=`(shock = "S13", onset = 2021L)]
fwrite(ex[, .(shock, variant, jv_bvdid, pair, onset)], file.path(D, "shock-exposure-ijv.csv"))
hc <- CJ(jv_bvdid = ijv$jv_bvdid[1:6], closdate_year = 2014:2024)
hc[, `:=`(conscode = "U1", filing_type = "Annual report", closdate = as.IDate(sprintf("%d-12-31", closdate_year)), nr_months = "12",
          empl = sample(40:80, .N, TRUE), orbis_library = "large", synthetic = TRUE)]
hc <- rbind(hc, hc[1][, `:=`(conscode = "C1", empl = 500L)])
arrow::write_parquet(hc, file.path(D, "orbis-jv-headcounts.parquet"))
# Parent industry: 4-digit codes, a combined OEWS industry (3251), a 3-digit fallback (5413), a short
# three-digit code without a 4-digit form (541), and missing codes.
fwrite(data.table(parent_bvdid = par$parent_bvdid, rd_naics = rep(c(331110L, 541330L, 325110L, NA, 541L, 331120L), 4),
                  rd_naics4 = rep(c(3311L, 5413L, 3251L, NA, NA, 3311L), 4), synthetic = TRUE), file.path(D, "parent-industry.csv"))
mins <- c("11-1000", "13-2000", "15-1000", "17-2000", "23-1000", "41-3000", "43-4000")
ow <- rbindlist(list(
  data.table(level = "4d", naics = "331100", title = "Synthetic Industry A"), data.table(level = "4d", naics = "3250A1", title = "Synthetic Chemicals (3251, 3252 only)"),
  data.table(level = "3d", naics = "541000", title = "Synthetic Services"), data.table(level = "sector", naics = "31-33", title = "Synthetic sector 1"),
  data.table(level = "sector", naics = "54", title = "Synthetic sector 2")))
oews <- rbindlist(lapply(seq_len(nrow(ow)), function(i) {
  e <- round(runif(length(mins), 100, 5000)); tot <- sum(e) * 2
  rbind(data.table(ow[i], occ_code = "00-0000", o_group = "total", tot_emp = tot),
        data.table(ow[i], occ_code = mins, o_group = "minor", tot_emp = e),
        data.table(ow[i], occ_code = c("23-1011", "13-2011"), o_group = "detailed", tot_emp = round(e[c(5, 2)] * .5)))
}))
oews[level == "4d" & naics == "331100" & occ_code == "15-1000", tot_emp := NA]   # suppressed cell
fwrite(oews[, synthetic := TRUE], file.path(D, "oews-long.csv"))
fwrite(rbindlist(exp), file.path(D, "seeded-cases.csv"))
message(sprintf("synthetic panel-build input: %d IJVs, %d JV positions, %d spells, %d history positions, %d seeded expectations",
                nrow(ijv), nrow(JP), nrow(S), nrow(HH), length(exp)))
