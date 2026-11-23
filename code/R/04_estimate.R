# 04_estimate.R
# Stage 7: baseline models for the staffing hypotheses. Until gate 5 fixes
# the plan, the models are those of the draft H1 to H4 in
# docs/research-brief.md, specified in .claude/skills/statistical-analyst.
# Model code: code/R/functions/estimation.R.
#
#   synthetic   the simulated panels in data/synthetic/ (code/R/tests/synthetic_panel.R);
#               adds a comparison with the planted effects. Allowed at any time.
#   (none)      the real panels data/processed/panel-ijv-function-year.parquet and
#               panel-ijv-level-year.parquet. Stops unless reviews/gate-6-panel.md
#               carries "Status: APPROVED" (real_data_lock; CLAUDE.md rules 4 and 8).
#
# Run from the repository root:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/04_estimate.R synthetic   (about a minute)
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/04_estimate.R             (after gate 6)
# Outputs:
#   synthetic: data/synthetic/estimates-synthetic-2026-11-23.md, fig-event-study-synthetic-2026-11-23.png
#   real:      manuscript/tables/tab-static.tex/.md, tab-dynamic.tex/.md, manuscript/figures/fig-event-study.png,
#              data/interim/models-baseline.rds, data/interim/estimates-report.md

source("code/R/00_setup.R")
source("code/R/functions/estimation.R")
require_pkgs(c("arrow", "fixest", "modelsummary"))
set.seed(20261123)
SYN <- "synthetic" %in% commandArgs(trailingOnly = TRUE)
SYN_DATE <- "2026-11-23"
PERM_B <- 999L
t0 <- Sys.time()
say <- function(...) message(format(Sys.time(), "%H:%M:%S"), " ", sprintf(...))
check <- function(cond, msg) { cat(if (isTRUE(cond)) "OK   " else "FAIL ", msg, "\n"); if (!isTRUE(cond)) stop("check failed: ", msg, call. = FALSE) }
kb <- function(d, digits = 3) knitr::kable(d, format = "pipe", digits = digits, format.args = list(big.mark = ","))
# Pipe table of models side by side: estimate [95% CI], cells used, within R-squared (for the report).
wide_tab <- function(models) {
  cr <- coef_rows(models)
  cr[, cell := sprintf("%.3f [%.3f, %.3f]", estimate, ci_low, ci_high)]
  w <- dcast(cr, term ~ factor(model, levels = names(models)), value.var = "cell", fill = "")
  g <- as.data.table(sapply(models, function(m) c(format(nobs(m), big.mark = ","),
                                                   if (is.null(m$family)) sprintf("%.3f", r2(m, "wr2")) else "")))
  g <- cbind(term = c("cells used", "within R2"), g)
  kb(rbind(w, g))
}
f_syn <- function(name, ext) file.path("data/synthetic", sprintf("%s-synthetic-%s.%s", name, SYN_DATE, ext))

# ---- 0. Gate check and inputs ---------------------------------------------------------
if (SYN) {
  pf <- as.data.table(arrow::read_parquet(f_syn("panel-ijv-function-year", "parquet")))
  pl <- as.data.table(arrow::read_parquet(f_syn("panel-ijv-level-year", "parquet")))
  planted <- fread(f_syn("panel-planted-effects", "csv"))
  check(all(pf$synthetic) && all(pl$synthetic), "every panel row is marked synthetic")
  f_md <- f_syn("estimates", "md"); f_fig <- f_syn("fig-event-study", "png")
} else {
  f_gate <- "reviews/gate-6-panel.md"
  st <- if (file.exists(f_gate)) grep("^Status:", readLines(f_gate), value = TRUE)[1] else NA_character_
  if (is.na(st) || !grepl("^Status:\\s*APPROVED", st))
    stop("real_data_lock: ", f_gate, " is not APPROVED (", if (is.na(st)) "file missing" else st,
         "). Run with the argument 'synthetic', or wait for gate 6.", call. = FALSE)
  pf <- as.data.table(arrow::read_parquet(file.path(paths$processed, "panel-ijv-function-year.parquet")))
  pl <- as.data.table(arrow::read_parquet(file.path(paths$processed, "panel-ijv-level-year.parquet")))
  planted <- NULL
  f_md <- file.path(paths$interim, "estimates-report.md"); f_fig <- file.path(paths$figures, "fig-event-study.png")
}
check(!"function" %in% names(pf), "the function column is not called 'function' (reserved word)")
check(!anyDuplicated(pf, by = c("ijv_id", "fn", "year")), "one row per IJV, function and year")
scores_fn <- unique(pf[, .(fn, coord_dependence, local_embeddedness)])
scores_lv <- unique(pl[, .(level, coord_role)])
check(!anyDuplicated(scores_fn$fn) && !anyDuplicated(scores_lv$level), "one score per function and per level")
MIN <- const$min_cell_emp
say("panels: %d function cells, %d level cells, %d IJVs, years %d-%d; cell threshold %d",
    nrow(pf), nrow(pl), uniqueN(pf$ijv_id), min(pf$year), max(pf$year), MIN)

# ---- 1. Descriptives and the variance check -------------------------------------------
s <- model_samples(pf, MIN)
desc <- data.table(
  item = c("IJVs", "IJVs with a host-country parent", "IJVs with a parent in Revelio", "parent-country pairs", "exposed pairs",
           "exposed IJVs", "function cells", "hires", "history observed (share of hires)", "local (share of observed)",
           "parent-origin (share of observed, IJVs with a parent in Revelio)",
           "cells with a local parent-origin hire (share of cells with local hires, same IJVs)"),
  value = format(c(uniqueN(pf$ijv_id), pf[host_parent == TRUE, uniqueN(ijv_id)], pf[parent_in_revelio == TRUE, uniqueN(ijv_id)],
            uniqueN(pf$dyad), pf[!is.na(first_shock_year), uniqueN(dyad)], pf[!is.na(first_shock_year), uniqueN(ijv_id)],
            nrow(pf), sum(pf$n_hires), round(sum(pf$n_obs) / sum(pf$n_hires), 3), round(sum(pf$n_local) / sum(pf$n_obs), 3),
            round(pf[parent_in_revelio == TRUE, sum(n_parent) / sum(n_obs)], 4),
            round(s$local_par0[, mean(n_local_parent > 0)], 3)), big.mark = ",", scientific = FALSE, drop0trailing = TRUE, trim = TRUE))
vchk <- data.table(outcome = c("share_parent", "share_local", "share_parent_local", "share_not_obs"),
                   sample = c("n_obs >= min, parent in Revelio", "n_obs >= min", "n_local >= min, parent in Revelio", "n_hires >= min"),
                   within_ijv_year = c(within_share(s$obs_par, "share_parent"), within_share(s$obs, "share_local"),
                                       within_share(s$local_par, "share_parent_local"), within_share(s$hires, "share_not_obs")))

# ---- 2. Static models ------------------------------------------------------------------
ms <- fit_static(pf, pl, MIN)
say("static models done")

# ---- 3. Dynamic models -----------------------------------------------------------------
md <- fit_dynamic(pf, MIN)
say("dynamic models done")
lead_test <- wald(md$H4_es, keep = "et::-[2-5]", print = FALSE)
leads <- coef_rows(list(event_study = md$H4_es))[grepl("et::-", term)]
att <- rbindlist(lapply(c("H4_sa_high", "H4_sa_low"), function(n) {
  ct <- summary(md[[n]], agg = "att")$coeftable
  data.table(model = n, functions = if (n == "H4_sa_high") "local_embeddedness >= 4" else "local_embeddedness <= 2",
             att = ct["ATT", 1], se = ct["ATT", 2], p = ct["ATT", 4])
}))
png(f_fig, width = 1600, height = 1000, res = 200)
iplot(md$H4_es, main = sprintf("Local share x local embeddedness, by year relative to first exposure%s", if (SYN) " (simulated)" else ""),
      xlab = "Years relative to first exposure (binned at -5 and +4)")
dev.off()

# ---- 4. Inference checks ---------------------------------------------------------------
say("permutation tests (B = %d)", PERM_B)
perm <- rbind(
  cbind(model = "H2_lin", perm_test(share_local ~ local_embeddedness + coord_dependence | ijv_id^year, s$obs, scores_fn,
                                    "local_embeddedness", B = PERM_B, weights = ~n_obs)),
  cbind(model = "H3_lin", perm_test(share_parent_local ~ coord_dependence + coord_dependence:host_parent | ijv_id^year, s$local_par,
                                    scores_fn, "coord_dependence:host_parentTRUE", B = PERM_B, weights = ~n_local)),
  cbind(model = "H1L_lin", perm_test(share_parent ~ coord_role | ijv_id^year, pl[n_obs >= MIN & parent_in_revelio == TRUE],
                                     scores_lv, "coord_role", B = PERM_B, weights = ~n_obs)))
se_alt <- rbind(
  data.table(model = "H2_lin", term = "local_embeddedness", clustering = c("IJV", "IJV and function (9 clusters)"),
             se = c(se(ms$H2_lin)[["local_embeddedness"]], se(summary(ms$H2_lin, cluster = ~ijv_id + fn))[["local_embeddedness"]])),
  data.table(model = "H3_lin", term = "coord_dependence:host_parentTRUE", clustering = c("IJV", "IJV and function (9 clusters)"),
             se = c(se(ms$H3_lin)[["coord_dependence:host_parentTRUE"]],
                    se(summary(ms$H3_lin, cluster = ~ijv_id + fn))[["coord_dependence:host_parentTRUE"]])),
  data.table(model = "H4_lin", term = "shock:local_embeddedness",
             clustering = c("IJV", sprintf("parent-country pair (%d pairs, %d exposed)", uniqueN(pf$dyad), pf[!is.na(first_shock_year), uniqueN(dyad)])),
             se = c(se(md$H4_lin)[["shock:local_embeddedness"]], se(summary(md$H4_lin, cluster = ~dyad))[["shock:local_embeddedness"]])))

# ---- 5. Effect sizes -------------------------------------------------------------------
wmean <- function(d, y, w) d[!is.na(get(y)), weighted.mean(get(y), get(w))]
eff <- rbind(
  data.table(model = "H1_lin", term = "coord_dependence", outcome_mean = wmean(s$obs_par, "share_parent", "n_obs")),
  data.table(model = "H2_lin", term = "local_embeddedness", outcome_mean = wmean(s$obs, "share_local", "n_obs")),
  data.table(model = "H3_lin", term = "coord_dependence:host_parentTRUE", outcome_mean = wmean(s$local_par, "share_parent_local", "n_local")),
  data.table(model = "H4_lin", term = "shock:local_embeddedness", outcome_mean = wmean(s$obs, "share_local", "n_obs")))
allc <- coef_rows(c(ms, md[c("H4_lin", "H4_frac", "H4C_lin")]))
eff <- merge(eff, allc, by = c("model", "term"), sort = FALSE)
eff[, `:=`(pp_per_point = 100 * estimate, pp_ci = sprintf("[%.2f, %.2f]", 100 * ci_low, 100 * ci_high), mean_pct = 100 * outcome_mean)]
ames <- data.table(model = c("H2_frac", "H3_frac"), term = c("local_embeddedness", "coord_dependence (all rows)"),
                   ame_pp = 100 * c(ame(ms$H2_frac, s$obs, "local_embeddedness"), ame(ms$H3_frac, s$local_par, "coord_dependence")))

# ---- 6. Recovery of the planted effects (simulated data only) --------------------------
rec <- NULL
if (SYN) {
  rec <- merge(recovery_spec(planted), allc, by = c("model", "term"), all.x = TRUE, sort = FALSE)
  check(!anyNA(rec$estimate), "every term of the recovery table was estimated")
  rec[, result := fcase(check == "sign", fifelse(estimate > 0 & p < 0.05, "recovered", "MISSED"),
                        check %in% c("null", "null_linear"), fifelse(p >= 0.05, "null held", "FALSE POSITIVE"),
                        check == "magnitude", fifelse(ci_low <= planted & planted <= ci_high, "planted value in 95% CI", "planted value outside CI"),
                        default = "shown, not tested")]
  print(rec[, .(hypothesis, model, term, check, planted, estimate = round(estimate, 3), p = signif(p, 2), result)])
  # One draw: a null may be rejected by chance (5 percent each); the Monte Carlo check is the test.
  check(all(rec[check == "sign", result] == "recovered"), "every planted effect is recovered with the right sign")
}

# ---- 7. Tables and report --------------------------------------------------------------
note_static <- sprintf("Fixed effects IJV x year; standard errors clustered by IJV; 95%% confidence intervals in brackets; cells with at least %d hires in the denominator; linear models weighted by the denominator.%s", MIN, if (SYN) " SIMULATED DATA." else "")
note_dyn <- sprintf("Fixed effects IJV x function, function x year and IJV x year (the last absorbs the shock main effect); standard errors clustered by IJV; 95%% confidence intervals in brackets.%s", if (SYN) " SIMULATED DATA." else "")
ms_tab <- function(models, out, note) modelsummary(models, output = out, estimate = "{estimate} [{conf.low}, {conf.high}]",
                                                    statistic = NULL, gof_map = c("nobs", "r2.within"), notes = note)
tab_static <- c(wide_tab(ms), "", note_static)
tab_dyn <- c(wide_tab(md[c("H4_lin", "H4_frac", "H4C_lin")]), "", note_dyn)
if (!SYN) {
  ms_tab(ms, file.path(paths$tables, "tab-static.tex"), note_static); ms_tab(ms, file.path(paths$tables, "tab-static.md"), note_static)
  ms_tab(md[c("H4_lin", "H4_frac", "H4C_lin")], file.path(paths$tables, "tab-dynamic.tex"), note_dyn)
  ms_tab(md[c("H4_lin", "H4_frac", "H4C_lin")], file.path(paths$tables, "tab-dynamic.md"), note_dyn)
  saveRDS(c(ms, md), file.path(paths$interim, "models-baseline.rds"))
}

out <- c(
  sprintf("# Estimates%s", if (SYN) sprintf(" on simulated panels (%s)", SYN_DATE) else ""), "",
  sprintf("Built %s by code/R/04_estimate.R%s with the model functions of code/R/functions/estimation.R.",
          format(Sys.time(), "%Y-%m-%d %H:%M"), if (SYN) " synthetic" else ""),
  if (SYN) c("", "**Simulated data.** The panels come from code/R/tests/synthetic_panel.R with planted effects of known size. Nothing here is a result about IJVs; the run checks that the code recovers what was planted. The hypotheses are the drafts of docs/research-brief.md, and the functions, levels and contingency scores are placeholders: their source is open since the PI set the qualitative study aside (2026-11-23), and the mapping is a gate-5 decision.") else NULL,
  "", "## Panel", "", kb(desc), "",
  "## Variance check", "", "Share of the outcome variance that lies within the IJV-year, the only variation the static models use.", "", kb(vchk), "",
  "## Static models", "", tab_static, "",
  "## Cells used by each model", "", "The fractional and Poisson models drop IJV-years in which the outcome is zero in every cell.", "",
  kb(sample_rows(c(ms, md[c("H4_lin", "H4_frac", "H4C_lin")]))), "",
  "## Dynamic models", "", tab_dyn, "",
  "## Event study: leads", "", sprintf("Joint test that the leads (-5 to -2) are zero: F = %.2f, p = %.3f. Not rejecting is not proof of parallel trends; the lead estimates and their intervals show how large a pre-trend the data cannot rule out.", lead_test$stat, lead_test$p), "",
  kb(leads[, .(term, estimate, ci_low, ci_high, p)], 4), "",
  sprintf("Figure: %s", f_fig), "",
  "## Staggered exposure (Sun and Abraham), within groups of functions", "", kb(att, 4), "",
  "## Inference checks", "", "Permutation of the scores across functions (levels). `p_min` is the smallest p-value the test can return. Four levels give only 24 assignments, and with a binary score (two levels with a coordination role, two without) eight of them reproduce the observed split or its mirror image, so the level test cannot fall below 1/3.", "",
  kb(perm, 4), "", kb(se_alt, 4), "",
  "## Effect sizes", "", "Linear models: percentage points of the share per one-point difference in the score, against the mean share.", "",
  kb(eff[, .(model, term, mean_pct, pp_per_point, pp_ci, p)], 3), "",
  "Average marginal effects of the fractional logit (percentage points per point):", "", kb(ames, 3), "",
  if (SYN) c("The static H2 slope pools years before and after exposure. Where the shock steepens the slope (H4), the pooled estimate lies above the pre-exposure slope: compare `H2_frac` with `H2_frac_pre` in the static table.", "") else NULL,
  if (SYN) c("## Recovery of the planted effects", "",
             "`planted` is on the logit scale of the data-generating process. Linear models are checked for sign and significance only. Poisson coefficients approximate the logit value because parent-origin hires are rare. One draw: each planted null is rejected by chance with probability 0.05, so a single false positive here is expected now and then; `code/R/tests/check_estimate_recovery.R` repeats the draw and tests the rejection rates.", "",
             kb(rec[, .(hypothesis, model, term, check, planted, estimate, ci_low, ci_high, p, result)], 3), "") else NULL,
  "## Session", "", sprintf("R %s; fixest %s; modelsummary %s; run time %.0f s.", getRversion(), packageVersion("fixest"),
                            packageVersion("modelsummary"), as.numeric(difftime(Sys.time(), t0, units = "secs"))))
writeLines(out, f_md)
say("written: %s and %s", f_md, f_fig)
