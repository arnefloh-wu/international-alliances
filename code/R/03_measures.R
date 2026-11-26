# 03_measures.R
# Stage 6 (/panel-build), step 2 of 2: cell-year panels of the approved
# pre-analysis plan pap-v1.0 (reviews/gate-5-pre-analysis-plan.md, A2 to A4,
# B0.1 to B0.4, robustness set of B5) from the outputs of 02_build_panel.R.
#
# Panels (one row per IJV x grain x year with at least one employee on 30 June or
# one hire; years from the formation year to 2025; main_period marks 2010 to 2025):
#   panel-ijv-domain-year-v1.parquet     domain = SOC minor group, narrow REG carved out (H1 to H3; H4 narrow-list check)
#   panel-ijv-domain-b-year-v1.parquet   domain = SOC minor group, broad REG_B carved out (H4 confirmatory grain)
#   panel-ijv-level-year-v1.parquet      level, mapping (a) (C1; H1 levels, exploratory)
#   panel-ijv-level-b-year-v1.parquet    level, mapping (b) (robustness 18b)
#   panel-ijv-seniority-year-v1.parquet  Revelio seniority 1 to 7 (robustness 18c, linear term)
#   panel-ijv-function-year-v1.parquet   fn = Revelio role_k10 function (grain robustness 5; see gate 6 file)
#   panel-ijv-role50-year-v1.parquet     role_k50 = Revelio role_k50 group (grain robustness 5; rater scores, robustness 6)
#   panel-ijv-attributes-v1.parquet      one row per IJV: every IJV-level variable
#   panel-ijv-year-v1.parquet            one row per IJV-year: Revelio staff, Orbis headcount, coverage ratio
# Counts: the staffing frame of A2.2 and the identities of A3 (code/R/functions/measures.R).
#
# real_data_lock and independence (CLAUDE.md rules 4 and 8; plan A5): no model is
# estimated. The structure report written here holds denominators, cell counts,
# flag rates and the pooled share of each origin class over all hires of the main
# period; nothing is broken down by exposure, host-country parent, score, domain,
# level or year.
#
# Run from the repository root after 02_build_panel.R:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/03_measures.R            # real extracts
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/03_measures.R synthetic  # simulated twin
# Outputs (gitignored for real data): the panels above in data/processed/, the
# sample-construction log data/processed/sample-construction-log.md and the
# structure report data/interim/panel-structure-v1-2026-11-26.md.

source("code/R/00_setup.R")
require_pkgs(c("arrow", "countrycode", "readxl"))
source("code/R/functions/panel_build.R")
source("code/R/functions/panel_ijv.R")
source("code/R/functions/resource_dependence.R")
MODE <- if ("synthetic" %in% commandArgs(trailingOnly = TRUE)) "synthetic" else "real"
cfg <- panel_config(MODE)
dir.create(cfg$out, showWarnings = FALSE, recursive = TRUE)
t0 <- Sys.time()
say <- function(...) message(format(Sys.time(), "%H:%M:%S"), " ", sprintf(...))
f_in <- function(name) file.path(cfg$interim, sprintf("panel-%s-%s.parquet", name, cfg$tag))
f_panel <- function(name) file.path(cfg$out, if (MODE == "real") sprintf("panel-%s-v1.parquet", name) else sprintf("panel-%s-%s.parquet", name, cfg$tag))
L <- new_log()
prev <- fread(file.path(cfg$interim, sprintf("panel-build-log-%s.csv", cfg$tag)), colClasses = "character", na.strings = NULL)
L$rows <- split(prev, seq_len(nrow(prev)))

# ---- 1. IJV attributes ---------------------------------------------------------------------
ijv <- fread(cfg$ijv, colClasses = list(character = "jv_bvdid"), na.strings = "")
if ("exposure_group" %in% names(ijv)) ijv[, exposure_group := NULL]
par <- fread(cfg$parents, colClasses = list(character = c("jv_bvdid", "parent_bvdid", "parent_guo")), na.strings = "")
par[, host_direct := parent_country == ijv$jv_country[match(jv_bvdid, ijv$jv_bvdid)]]
fi <- readRDS(file.path(cfg$interim, sprintf("panel-families-%s.rds", cfg$tag)))
ex <- fread(cfg$exposure, na.strings = "", colClasses = list(character = "jv_bvdid"))
orb <- fread(cfg$orbis, select = c("jv_bvdid", "jv_listed", "jv_isin"), colClasses = "character", na.strings = "")
A <- ijv_attributes(ijv, par, fi, ex, orb)
stopifnot(nrow(A) == nrow(ijv))
staff <- as.data.table(arrow::read_parquet(f_in("staff-ijv-year")))
hc <- as.data.table(arrow::read_parquet(cfg$headcount))
IY <- coverage_ijv_year(hc, staff)
setnames(IY, "jv_bvdid", "ijv_id")
arrow::write_parquet(A, f_panel("ijv-attributes"))
arrow::write_parquet(IY, f_panel("ijv-year"))

# ---- 2. Regressor tables ---------------------------------------------------------------------
occ <- fread(cfg$occ)
dom <- fread(cfg$dom)[, c("domain", SCORE_COLS, "all_imputed"), with = FALSE]
domb <- domain_b_scores(occ)[, c("domain_b", SCORE_COLS, "all_imputed"), with = FALSE]
setnames(domb, "domain_b", "domain")
lookup <- as.data.table(arrow::read_parquet(cfg$lookup, col_select = c("role_k17000_v3", "role_k50_v3", "role_k10_v3", "onet_code")))
sc50 <- taxonomy_scores(lookup, occ, "role_k50_v3"); setnames(sc50, "role_k50_v3", "role_k50")
sc10 <- taxonomy_scores(lookup, occ, "role_k10_v3"); setnames(sc10, "role_k10_v3", "fn")
rat <- fread(cfg$rater)
sc50[rat, on = .(role_k50 = group_label), `:=`(coord_dependence_rater = i.coord_dependence_rater,
                                               local_embeddedness_rater = i.local_embeddedness_rater)]
log_step(L, "7 Regressors", "role_k50 groups with rater scores (ICC(2,k) >= 0.70 on both scales)", sc50[!is.na(coord_dependence_rater), .N], "groups")
# Resource dependence (robustness 19, rule v2).
oews <- read_oews(cfg$oews)
pind <- fread(cfg$pind, colClasses = list(character = "parent_bvdid"), na.strings = "")
pm <- match_oews_industry(fifelse(is.na(pind$rd_naics4), as.character(pind$rd_naics), as.character(pind$rd_naics4)), oews)   # short codes reach the 3-digit match
pind <- cbind(pind[, .(parent_bvdid)], pm[, .(level, naics, route)])
log_step(L, "7 Regressors", "parents with an OEWS industry (4-digit, combined or 3-digit)", pind[!is.na(naics), .N], "parents",
         sprintf("4-digit %d, combined %d, 3-digit %d", pind[route == "4-digit", .N], pind[route == "combined", .N], pind[route == "3-digit", .N]))
rd_n <- rd_ijv_domain(par, pind, oews_domain_shares(oews, occ, "regulatory_narrow", "REG"), dom$domain)
rd_b <- rd_ijv_domain(par, pind, oews_domain_shares(oews, occ, "regulatory_broad", "REG_B"), domb$domain)
log_step(L, "7 Regressors", "IJVs with an OEWS-matched code for at least one parent / for every parent",
         sprintf("%s / %s", format(rd_n$ijv[rd_any_coded == 1L, .N], big.mark = ","), format(rd_n$ijv[rd_all_coded == 1L, .N], big.mark = ",")), "IJVs")
rm(oews); invisible(gc())

# ---- 3. Panels ---------------------------------------------------------------------------------
H <- as.data.table(arrow::read_parquet(f_in("hires")))
hire_indicators(H)
A_panel <- A[, .(ijv_id, host_country, formation_year, source, route, strategic, n_parents, parent_in_revelio, all_parents_in_revelio,
                 host_parent, host_parent_in_revelio, host_parent_guo, h3_sample, flag_jv_in_parent_family, flag_listed, usable_30,
                 exposed, s13_sample, s13_control, s13_third_country, owner_level, exposed_no_ie, exposed_guo, uk_host, gb_ie,
                 control_linked, linked, linked_alt, dyad, dyad_all, formed_pre2016, formed_from2021)]
grains <- list(
  domain    = list(h = "domain",    col = "domain",    file = "ijv-domain-year",    scores = dom,  rd = rd_n, reg = "REG"),
  domain_b  = list(h = "domain_b",  col = "domain",    file = "ijv-domain-b-year",  scores = domb, rd = rd_b, reg = "REG_B"),
  level     = list(h = "level",     col = "level",     file = "ijv-level-year"),
  level_b   = list(h = "level_b",   col = "level",     file = "ijv-level-b-year"),
  seniority = list(h = "seniority", col = "seniority", file = "ijv-seniority-year"),
  fn        = list(h = "fn",        col = "fn",        file = "ijv-function-year",  scores = sc10),
  role50    = list(h = "role50",    col = "role_k50",  file = "ijv-role50-year",    scores = sc50))
struct <- list(); samp <- list()
# Structural size of the estimation samples (cells, IJVs, pairs; main period, cell rule). The S13
# breakdowns use employees and hires only (n_hires >= 1), never an origin class (independence rule).
est_samples <- function(g, m) {
  e <- m[cell_emp5 == 1L]
  row <- function(sample, d, extra = list()) c(list(panel = g, sample = sample, cells = nrow(d), ijvs = uniqueN(d$ijv_id),
                                                    ijv_years = uniqueN(d[, .(ijv_id, year)])), extra)
  if (g == "domain") return(rbindlist(list(
    row("H1: parent in Revelio, n_obs >= 1", e[parent_in_revelio == 1L & n_obs >= 1L]),
    row("H2: core_main, n_geo >= 1", e[n_geo >= 1L]),
    row("H3: parent in Revelio, n_local >= 1 (host-country parent or not)", e[parent_in_revelio == 1L & n_local >= 1L]),
    row("H1, 5-hires rule: parent in Revelio, n_hires >= 5, n_obs >= 1", m[cell_hires5 == 1L & parent_in_revelio == 1L & n_obs >= 1L])), fill = TRUE))
  s13 <- e[s13_sample == 1L & parent_in_revelio == 1L & n_hires >= 1L]
  pr <- function(d) list(exposed_ijvs = uniqueN(d[exposed == 1L, ijv_id]), exposed_pairs = uniqueN(d[exposed == 1L, dyad]),
                         control_ijvs = uniqueN(d[exposed == 0L, ijv_id]), control_dyads = uniqueN(d[exposed == 0L, dyad]))
  if (g == "domain_b") {
    rg <- s13[reg == 1L & exposed == 1L]
    both <- intersect(rg[year %in% 2013:2015, unique(ijv_id)], rg[year >= 2021L, unique(ijv_id)])
    return(rbindlist(list(
      row("H4: S13 sample, parent in Revelio, n_hires >= 1", s13, pr(s13)),
      row("H4: exposed REG_B cells in 2013-2015 and from 2021 (IJVs in both periods; pairs in extra)", rg[ijv_id %chin% both],
          list(exposed_ijvs = length(both), exposed_pairs = uniqueN(rg[ijv_id %chin% both, dyad]))),
      row("H4 lead-pooling rule: exposed REG_B cells with n_hires >= 1 in 2010 / 2011 / 2012", rg[year %in% 2010:2012],
          list(note = paste(vapply(2010:2012, function(y) rg[year == y, .N], 0L), collapse = " / ")))), fill = TRUE))
  }
  if (g == "level") return(rbindlist(list(
    row("C1: S13 sample, parent in Revelio, n_hires >= 1", s13, c(pr(s13), list(control_linked_ijvs = uniqueN(s13[control_linked == 1L, ijv_id])))),
    row("H1 levels: parent in Revelio, n_obs >= 1", e[parent_in_revelio == 1L & n_obs >= 1L])), fill = TRUE))
  NULL
}
for (g in names(grains)) {
  G <- grains[[g]]; say("panel: %s", g)
  na_all <- H[is.na(get(G$h)), .N]; na_main <- H[is.na(get(G$h)) & year >= MAIN_START, .N]
  log_step(L, paste0("8 Panel ", g), "hires with a value of the grain (all years / main period)",
           sprintf("%s / %s", format(nrow(H) - na_all, big.mark = ","), format(H[year >= MAIN_START, .N] - na_main, big.mark = ",")), "hires",
           sprintf("hires without a value dropped from this panel: %s (main period %s)", format(na_all, big.mark = ","), format(na_main, big.mark = ",")))
  cnt <- cell_counts(H, G$h)
  cnt <- cnt[!is.na(get(G$h))]
  st <- as.data.table(arrow::read_parquet(f_in(paste0("stock-", g))))
  setnames(st, c("n_emp_keep_xi", "n_emp_keep_xl"), c("n_emp_xi", "n_emp_xl"), skip_absent = TRUE)
  if (G$h != G$col) { setnames(cnt, G$h, G$col); setnames(st, G$h, G$col) }
  if (g == "seniority") { cnt[, seniority := as.integer(seniority)]; st[, seniority := as.integer(seniority)] }
  d <- merge(st, cnt, by = c("jv_bvdid", G$col, "year"), all = TRUE)
  rm(st, cnt); invisible(gc())
  for (v in setdiff(names(d), c("jv_bvdid", G$col, "year"))) set(d, which(is.na(d[[v]])), v, 0L)
  for (s in c("", "_ow1", "_ow5", "_xi", "_xl")) add_derived(d, s)
  stopifnot(all(d$n_not_obs == d$n_not_obs_chk))      # the not-observed indicator agrees with n_hires - n_obs
  setnames(d, c("n_not_obs_chk_xi", "n_not_obs_chk_xl"), c("n_not_obs_xi", "n_not_obs_xl"))
  d[, n_not_obs_chk := NULL]
  d[, `:=`(n_unknown = n_not_obs - n_entrant, n_unknown_e1 = n_not_obs - n_entrant_e1, n_unknown_e5 = n_not_obs - n_entrant_e5,
           n_unknown_ow1 = n_not_obs_ow1 - n_entrant, n_unknown_ow5 = n_not_obs_ow5 - n_entrant)]
  add_shares(d); check_identities(d)
  d[, `:=`(cell_emp3 = as.integer(n_emp >= 3L), cell_emp5 = as.integer(n_emp >= const$min_cell_emp),
           cell_emp10 = as.integer(n_emp >= 10L), cell_hires5 = as.integer(n_hires >= 5L))]
  setnames(d, "jv_bvdid", "ijv_id")
  d <- merge(d, A_panel, by = "ijv_id")
  d <- merge(d, IY[, .(ijv_id, year, coverage_ratio)], by = c("ijv_id", "year"), all.x = TRUE)
  add_year_vars(d)
  # Grain regressors.
  if (g %chin% c("domain", "domain_b")) {
    d <- merge(d, G$scores, by = "domain", all.x = TRUE)
    setnames(d, "all_imputed", "score_imputed_domain")
    d[, reg := as.integer(domain == G$reg)]
    d[, reg_list := if (g == "domain") "narrow" else "broad"]
    if (g == "domain_b") d[, reg_b := reg]
    d[, `:=`(treat_reg = exposed * reg, exp_post_reg = exposed * post * reg, exp_antic_reg = exposed * antic_yr * reg,
             cd_host = coord_dependence * host_parent, cd_nohost = coord_dependence * (1L - host_parent))]
    rdc <- copy(G$rd$cell); setnames(rdc, "jv_bvdid", "ijv_id")
    d <- merge(d, rdc, by = c("ijv_id", "domain"), all.x = TRUE)
    rdi <- copy(G$rd$ijv); setnames(rdi, "jv_bvdid", "ijv_id")
    d <- merge(d, rdi, by = "ijv_id", all.x = TRUE)
    d[is.na(rd_code_missing), `:=`(rd_code_missing = 1L, rd_all_coded = 0L, rd_any_coded = 0L)]
    stopifnot(!anyNA(d$local_embeddedness), !anyNA(d$coord_dependence))
  } else if (g %chin% c("level", "level_b")) {
    d[, coord_role := coord_role_of(level)]
  } else if (g == "seniority") {
    d[, `:=`(level = level_of(seniority, "a"), level_b = level_of(seniority, "b"))]
    d[, coord_role := coord_role_of(level)]
  } else {
    d <- merge(d, G$scores, by = G$col, all.x = TRUE)
    d[, cd_host := coord_dependence * host_parent]; d[, cd_nohost := coord_dependence * (1L - host_parent)]
  }
  stopifnot(!"function" %in% names(d), !anyDuplicated(d, by = c("ijv_id", G$col, "year")))
  setcolorder(d, c("ijv_id", G$col, "year"))
  setorderv(d, c("ijv_id", G$col, "year"))
  arrow::write_parquet(d, f_panel(G$file))
  m <- d[main_period == 1L]
  samp[[g]] <- est_samples(g, m)
  struct[[g]] <- data.table(panel = G$file, grain = G$col, rows_all_years = nrow(d), ijvs_all_years = uniqueN(d$ijv_id),
    rows_main = nrow(m), ijvs_main = uniqueN(m$ijv_id), values_main = uniqueN(m[[G$col]]), years_main = uniqueN(m$year),
    cells_emp5 = m[cell_emp5 == 1L, .N], ijvs_emp5 = m[cell_emp5 == 1L, uniqueN(ijv_id)],
    cells_hires5 = m[cell_hires5 == 1L, .N], ijvs_hires5 = m[cell_hires5 == 1L, uniqueN(ijv_id)],
    cells_emp3 = m[cell_emp3 == 1L, .N], cells_emp10 = m[cell_emp10 == 1L, .N],
    cells_emp5_obs1 = m[cell_emp5 == 1L & n_obs >= 1L, .N], cells_emp5_geo1 = m[cell_emp5 == 1L & n_geo >= 1L, .N],
    cells_emp5_local1 = m[cell_emp5 == 1L & n_local >= 1L, .N], hires_main = sum(m$n_hires), hires_emp5 = m[cell_emp5 == 1L, sum(n_hires)])
  log_step(L, paste0("8 Panel ", g), "cell-years, all years from formation to 2025", nrow(d), "cells")
  log_step(L, paste0("8 Panel ", g), sprintf("cell-years in the main period %d to %d", MAIN_START, PANEL_END), nrow(m), "cells", "earlier years kept, main_period = 0")
  log_step(L, paste0("8 Panel ", g), "main-period cell-years with at least 5 employees on 30 June (cell rule)", struct[[g]]$cells_emp5, "cells")
  log_step(L, paste0("8 Panel ", g), "main-period cell-years with at least 5 hires (sensitivity rule)", struct[[g]]$cells_hires5, "cells")
  log_step(L, paste0("8 Panel ", g), "main-period cell-years with at least 5 employees and n_obs >= 1", struct[[g]]$cells_emp5_obs1, "cells")
  rm(d, m); invisible(gc())
}
ST <- rbindlist(struct)
SM <- rbindlist(samp, fill = TRUE)

# ---- 4. Structure report (denominators, flags, pooled origin shares only) ----------------------
Hm <- H[year >= MAIN_START]
pooled <- Hm[, .N, by = cat_w3][, share := N / sum(N)][order(match(cat_w3, CATS))]
pooled_ent <- Hm[, .(hires = .N, not_obs = mean(cat_w3 == "not_obs"), entrant = mean(entrant_e3), unknown = mean(cat_w3 == "not_obs" & !entrant_e3),
                     obs_unmapped = sum(cat_w3 != "not_obs" & employer_mapped %in% FALSE) / sum(cat_w3 != "not_obs"),
                     lookup = mean(onet_source == "lookup"), no_domain = mean(is.na(domain)), no_level = mean(is.na(level)),
                     imputed = mean(score_imputed_occ %in% TRUE))]
ijv_counts <- A[, .(core_main = .N, with_hire_main = sum(ijv_id %chin% Hm$jv_bvdid), parent_in_revelio = sum(parent_in_revelio),
                    all_parents_in_revelio = sum(all_parents_in_revelio), host_parent = sum(host_parent),
                    host_parent_in_revelio = sum(host_parent_in_revelio), h3_sample = sum(h3_sample), strategic = sum(strategic),
                    flag_jv_in_parent_family = sum(flag_jv_in_parent_family), flag_shared_family_entity = sum(flag_shared_family_entity),
                    flag_listed = sum(flag_listed), listed_orbis = sum(flag_listed[source == "orbis"]), listed_ciq_isin = sum(flag_listed[source == "ciq"]),
                    flag_pre_formation_10y = sum(flag_pre_formation_10y), flag_holding_vehicle = sum(flag_holding_vehicle),
                    flag_size_mismatch = sum(flag_size_mismatch), usable_30 = sum(usable_30), owner_level = sum(owner_level),
                    formed_pre2016 = sum(formed_pre2016), formed_from2021 = sum(formed_from2021))]
s13 <- A[, .(exposed = sum(exposed), exposed_pairs = uniqueN(pair_exposure[exposed == 1L]),
             exposed_parent_in_revelio = sum(exposed & parent_in_revelio), exposed_h3 = sum(exposed & h3_sample),
             frame_controls = sum(s13_frame_control), controls_no_foreign_direct = sum(s13_frame_control & no_foreign_direct),
             owner_link_dropped = sum(s13_owner_link_dropped), controls = sum(s13_control),
             controls_parent_in_revelio = sum(s13_control & parent_in_revelio), control_dyads = uniqueN(dyad[s13_control == 1L]),
             third_country = sum(s13_third_country), gb_ie = sum(gb_ie), uk_hosted_exposed = sum(exposed & uk_host),
             control_linked = sum(control_linked), stake_exactly_50 = sum(eu_stake_band %chin% "exactly_50"),
             stake_below_50 = sum(eu_stake_band %chin% "below_50"), exposed_no_ie = sum(exposed_no_ie),
             exposed_guo = sum(exposed_guo, na.rm = TRUE), exposed_formed_from2021 = sum(exposed & formed_from2021),
             exposed_owner_level = sum(exposed & owner_level), controls_owner_level = sum(s13_control & owner_level))]
cov <- IY[year >= 2015L & year <= PANEL_END, .(ijv_years_2015_2025 = .N, with_ratio = sum(!is.na(coverage_ratio)),
                                               ijvs_with_ratio = uniqueN(ijv_id[!is.na(coverage_ratio)]),
                                               median_ratio = round(median(coverage_ratio, na.rm = TRUE), 2))]
kb <- function(x) knitr::kable(x, format = "pipe", format.args = list(big.mark = ","), digits = 4)
writeLines(c(sprintf("# Panel structure (%s), %s", MODE, format(Sys.Date())), "",
  "Written by `code/R/03_measures.R`. Structural counts only: denominators, cells, flags and the pooled share of each origin class over all hires of 2010 to 2025. Nothing is broken down by exposure, host-country parent, score, domain, level or year (real_data_lock; plan A5).", "",
  "## IJVs", "", kb(ijv_counts), "", "## S13 exposure and controls (ownership data only)", "", kb(s13), "",
  "## Panels (main period 2010 to 2025 unless stated)", "", kb(ST), "",
  "## Estimation samples: structure only (main period, at least 5 employees unless stated)", "", kb(SM), "",
  "## Hires of 2010 to 2025: pooled origin classes (primary window, three years)", "", kb(pooled), "",
  "## Hires of 2010 to 2025: pooled rates", "", kb(pooled_ent), "",
  "## Coverage ratio (IJV-years 2015 to 2025)", "", kb(cov)), cfg$summary)

# ---- 5. Sample-construction log ------------------------------------------------------------------
LT <- log_table(L)
writeLines(c("# Sample construction log: stage 6 panels", "",
  sprintf("Produced by `code/R/02_build_panel.R` and `code/R/03_measures.R` (%s run, %s), following `reviews/gate-5-pre-analysis-plan.md` (pap-v1.0). Counts at every step from the matched frame (`core_main`) to the final panels, with the rule that removed each group of rows. Structural counts only.", MODE, format(Sys.Date())), "",
  "| Part | Step | n | Unit | Removed | Rule |", "|---|---|---|---|---|---|",
  LT[, sprintf("| %s | %s | %s | %s | %s | %s |", part, step, n, unit, fifelse(is.na(removed), "", removed), rule)], "",
  "## IJV subsets and S13 groups", "", kb(ijv_counts), "", kb(s13), "", "## Panels", "", kb(ST), "",
  "## Estimation samples (structure only)", "", kb(SM)), cfg$log)
say("03_measures.R done (%s) in %.1f minutes", MODE, as.numeric(difftime(Sys.time(), t0, units = "mins")))
