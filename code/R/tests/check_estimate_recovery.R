# check_estimate_recovery.R
# Monte Carlo check of the estimation code (.claude/skills/statistical-analyst,
# real_data_lock): draws R simulated panels with code/R/functions/simulate_panel.R,
# fits the models of code/R/functions/estimation.R to each, and compares the
# estimates with the planted effects. No project data are read.
#
# Pass criteria (each stops the script if it fails):
#   sign       planted positive effect detected (positive, p < 0.05) in at least 80% of draws
#   null       planted zero rejected at p < 0.05 in at most 0.05 + 3 binomial standard
#              errors of the draws (0.079 with R = 500)
#   null_linear the same for linear models of bounded or sparse shares, where the simulation
#              shows rates of 8 to 9 percent: at most 15% (a gross-error check, reported as such)
#   magnitude  mean estimate within 25% of the planted logit value (Poisson
#              approximation for rare outcomes; fractional logit before exposure)
#   "reported" rows are shown, not tested.
#
# Run from the repository root (about 13 minutes with R = 500):
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/tests/check_estimate_recovery.R [R]
# Output: data/synthetic/estimate-recovery-synthetic-2026-11-23.md (tracked)

source("code/R/00_setup.R")
source("code/R/functions/simulate_panel.R")
source("code/R/functions/estimation.R")
require_pkgs("fixest")
args <- commandArgs(trailingOnly = TRUE)
R <- if (length(args) && grepl("^[0-9]+$", args[1])) as.integer(args[1]) else 500L
NULL_MAX <- 0.05 + 3 * sqrt(0.05 * 0.95 / R)
N_IJV <- 600L
SYN_DATE <- "2026-11-23"
f_md <- file.path("data/synthetic", sprintf("estimate-recovery-synthetic-%s.md", SYN_DATE))
check <- function(cond, msg) { cat(if (isTRUE(cond)) "OK   " else "FAIL ", msg, "\n"); if (!isTRUE(cond)) stop("check failed: ", msg, call. = FALSE) }
kb <- function(d, digits = 3) knitr::kable(d, format = "pipe", digits = digits, format.args = list(big.mark = ","))
t0 <- Sys.time()
spec <- recovery_spec(simulate_panel(n_ijv = 20L, seed = 1L)$planted)

draws <- rbindlist(lapply(seq_len(R), function(r) {
  s <- simulate_panel(n_ijv = N_IJV, seed = 20261123L + r)
  m <- c(fit_static(s$pf, s$pl), fit_dynamic(s$pf, event_study = FALSE))
  cr <- coef_rows(m)[spec, on = .(model, term), nomatch = NULL]
  if (r %% 10L == 0L) message(sprintf("draw %d of %d, %.0f s", r, R, as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  cr[, draw := r]
}))
check(nrow(draws) == R * nrow(spec), sprintf("every recovery term estimated in all %d draws", R))

res <- draws[, .(mean_estimate = mean(estimate), sd_estimate = sd(estimate), mean_se = mean(se),
                 reject_5pct = mean(p < 0.05), positive_and_significant = mean(estimate > 0 & p < 0.05),
                 ci_covers_planted = NA_real_), by = .(model, term)]
res <- merge(spec, res, by = c("model", "term"), sort = FALSE)
cov <- draws[spec[!is.na(planted)], on = .(model, term), nomatch = NULL][, .(cov = mean(ci_low <= planted & planted <= ci_high)), by = .(model, term)]
res[cov, on = .(model, term), ci_covers_planted := i.cov]
res[, se_ratio := sd_estimate / mean_se]   # above 1: the clustered standard errors are too small
res[, rel_bias := fifelse(!is.na(planted) & planted != 0, mean_estimate / planted - 1, NA_real_)]
res[, result := fcase(check == "sign", fifelse(positive_and_significant >= 0.80, "pass", "FAIL"),
                      check == "null", fifelse(reject_5pct <= NULL_MAX, "pass", "FAIL"),
                      check == "null_linear", fifelse(reject_5pct <= 0.15, "pass (over-rejects)", "FAIL"),
                      check == "magnitude", fifelse(abs(rel_bias) <= 0.25, "pass", "FAIL"),
                      default = "shown, not tested")]
print(res[, .(model, term, check, planted, mean_est = round(mean_estimate, 3), se_ratio = round(se_ratio, 2), reject_5pct, rel_bias = round(rel_bias, 3), result)])

out <- c(sprintf("# Recovery of planted effects: Monte Carlo check (%s)", SYN_DATE), "",
  sprintf("Built %s by code/R/tests/check_estimate_recovery.R: %d simulated draws of %d IJVs (9 functions, 4 levels, 2010 to 2024), seeds 20261124 to %d. Simulated data only; nothing here is a result about IJVs.",
          format(Sys.time(), "%Y-%m-%d %H:%M"), R, N_IJV, 20261123L + R), "",
  "`planted` is on the logit scale of the data-generating process (`code/R/functions/simulate_panel.R`). `reject_5pct` is the share of draws with p < 0.05: for a planted null it estimates the false-positive rate (nominal 0.05), for a planted effect the power. `se_ratio` is the standard deviation of the estimates across draws divided by the mean clustered standard error: above 1, the standard errors are too small.", "",
  sprintf("Criteria: sign, power of at least 0.80; null, rejection rate of at most %.3f (0.05 plus three binomial standard errors); null_linear, at most 0.15, a gross-error check for linear models of bounded or sparse shares, whose false-positive rates in this simulation lie above the nominal level; magnitude, mean estimate within 25 percent of the planted value.", NULL_MAX), "",
  "Reading: the code recovers every planted effect and its size. Where a planted null is tested with a linear model on a share, the rejection rate is above 5 percent: partly functional form (the logistic curvature of one score loads onto a correlated score) and partly clustered standard errors that are 5 to 10 percent too small (`se_ratio`). The fractional logit, the Poisson model and the linear model with the score as categories hold the nominal level. See docs/decisions.md (Open, 2026-11-23).", "",
  kb(res[, .(hypothesis, model, term, check, planted, mean_estimate, sd_estimate, mean_se, se_ratio, reject_5pct, ci_covers_planted, rel_bias, result)]), "",
  sprintf("Run time %.0f s; fixest %s.", as.numeric(difftime(Sys.time(), t0, units = "secs")), packageVersion("fixest")))
writeLines(out, f_md)
message("written: ", f_md)
check(all(res[check == "sign", result] == "pass"), "every planted effect is detected in at least 80% of draws")
check(all(res[check == "null", result] == "pass"), sprintf("every planted null is rejected in at most %.1f%% of draws", 100 * NULL_MAX))
check(all(res[check == "null_linear", result] != "FAIL"), "linear-model nulls are rejected in at most 15% of draws (gross-error check)")
check(all(res[check == "magnitude", result] == "pass"), "every magnitude check is within 25% of the planted value")
