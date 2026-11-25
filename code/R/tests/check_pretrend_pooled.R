# check_pretrend_pooled.R
# Monte Carlo check of the H4a pre-trend rule decided on 2026-11-25 (one
# pooled 2010-2012 lead against the 2013-2015 reference, p-value from the
# cluster score bootstrap by dyad with the null imposed, fail if p < 0.10)
# and of H4a size and power, in the broad-list scenario of the feasibility
# count of 2026-11-25: 16 exposed pairs with REG_B cells and about 38 exposed
# IJVs with REG_B cells; about 151 control pairs and 328 control IJVs with
# REG_B cells. Generator and models: code/R/functions/simulate_domain_panel.R
# (the domain "REG" stands in for REG_B; its scores do not enter the H4
# models, which absorb them with IJV x domain effects).
#
# real_data_lock (gate 6 not approved): simulated data only. Inputs: the O*NET
# domain scores (public, outcome-free) and counts from rescoring.md 4.1 and the
# coordinator's summary of the feasibility count (counts only); no staffing row
# is read.
#
# Grid: pretrend (linear differential trend of exposed REG cells on the log
# local share, per year, continuing after 2021) in {0, 0.01, 0.02, 0.03} with
# no H4 effect; and H4 effects {0.1, 0.2, 0.3, 0.4} with parallel trends.
#
# Run from the repository root (about 13 minutes on 14 workers; run of 2026-11-25: R = 200):
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/tests/check_pretrend_pooled.R [R workers]
# Output: data/synthetic/pretrend-pooled-synthetic-2026-11-25.md

source("code/R/00_setup.R")
source("code/R/functions/simulate_domain_panel.R")
require_pkgs(c("fixest", "parallel"))
args <- as.integer(commandArgs(trailingOnly = TRUE))
R <- if (length(args) >= 1 && !is.na(args[1])) args[1] else 250L
WORKERS <- if (length(args) >= 2 && !is.na(args[2])) args[2] else 14L
B_BOOT <- 499L
N_CONTROL <- 2000L; N_CONTROL_PAIRS <- 400L
# Calibrated without fitting (6 draws): about 40 exposed IJVs with REG cells in 13 pairs with cells in both
# periods, and about 333 control IJVs with REG cells in 128 pairs; the feasibility count has 38 in 16 and
# 328 in 151, so the simulation is slightly conservative on the number of clusters.
PI_REG <- 0.23
f_md <- file.path("data/synthetic", "pretrend-pooled-synthetic-2026-11-25.md")
kb <- function(d, digits = 3) knitr::kable(d, format = "pipe", digits = digits, format.args = list(big.mark = ","))
t0 <- Sys.time(); elapsed <- function() round(as.numeric(difftime(Sys.time(), t0, units = "secs")))
dom <- domain_scores_sim()
pairs <- s13_pairs(n_control = N_CONTROL, n_control_pairs = N_CONTROL_PAIRS)

#' Pooled-lead event study and H4a on one panel.
fit_pt <- function(p, B) {
  q <- function(x) suppressMessages(suppressWarnings(x))
  d <- p[n_obs > 0]
  d[, lead_reg := treat_reg * as.integer(year <= 2012)]
  yrs <- 2016:2025
  for (y in yrs) set(d, j = paste0("tr", y), value = d$treat_reg * as.integer(d$year == y))
  others <- paste0("tr", yrs)
  m_es <- q(fepois(as.formula(paste("n_local ~ lead_reg +", paste(others, collapse = " + "), "+ offset(log(n_obs)) |", H4_FE)), d))
  sb_lead <- score_boot(d, "n_local", "lead_reg", others, H4_FE, "n_obs", "dyad", B = B)
  m4 <- q(fepois(as.formula(paste("n_local ~ exp_post_reg + exp_antic_reg + offset(log(n_obs)) |", H4_FE)), d))
  sb4 <- score_boot(d, "n_local", "exp_post_reg", "exp_antic_reg", H4_FE, "n_obs", "dyad", B = B)
  data.table(lead_est = coef(m_es)[["lead_reg"]], lead_p2_boot = sb_lead[["p2_boot"]],
             h4_est = coef(m4)[["exp_post_reg"]], h4_se_pair = se(m4, vcov = ~dyad)[["exp_post_reg"]],
             h4_p1_boot = sb4[["p1_boot"]],
             exposed_ijv_reg = d[treat_reg == 1L, uniqueN(ijv_id)],
             exposed_pairs_reg_both = d[treat_reg == 1L, .(pre = any(year %in% 2013:2015), post = any(year >= 2021)), by = dyad][pre & post, .N],
             control_ijv_reg = d[reg == 1L & exposed == 0L, uniqueN(ijv_id)],
             control_pairs_reg = d[reg == 1L & exposed == 0L, uniqueN(dyad)])
}

cl <- parallel::makeCluster(WORKERS)
parallel::clusterExport(cl, c("dom", "pairs", "fit_pt", "B_BOOT", "PI_REG"))
invisible(parallel::clusterEvalQ(cl, {
  suppressMessages({ library(data.table); library(fixest) })
  setDTthreads(1); setFixest_nthreads(1)
  source("code/R/functions/simulate_domain_panel.R")
}))
grid <- rbind(data.table(pretrend = c(0, 0.01, 0.02, 0.03), h4 = 0),
              data.table(pretrend = 0, h4 = c(0.1, 0.2, 0.3, 0.4)))
grid[, cell := .I]
jobs <- grid[rep(seq_len(.N), each = R)][, r := rep(seq_len(R), nrow(grid))]
res <- rbindlist(parallel::parLapplyLB(cl, split(jobs, seq_len(nrow(jobs))), function(j) {
  p <- simulate_domain_panel(dom, pairs = pairs, eff = planted_domain("effect", h4 = j$h4), pi_reg = PI_REG,
                             pretrend = j$pretrend, seed = 60261125L + 10000L * j$cell + j$r)
  f <- tryCatch(fit_pt(p, B_BOOT), error = function(e) NULL)
  if (is.null(f)) return(data.table(cell = j$cell, pretrend = j$pretrend, h4 = j$h4, r = j$r, failed = TRUE))
  cbind(cell = j$cell, pretrend = j$pretrend, h4 = j$h4, r = j$r, failed = FALSE, f)
}), fill = TRUE)
parallel::stopCluster(cl)
message("draws done, ", elapsed(), " s")

ok <- res[failed == FALSE]
s <- ok[, .(draws = .N, exposed_ijv_reg = mean(exposed_ijv_reg), exposed_pairs_reg_both = mean(exposed_pairs_reg_both),
            control_ijv_reg = mean(control_ijv_reg), control_pairs_reg = mean(control_pairs_reg),
            expected_lead = unique(-3 * pretrend), mean_lead = mean(lead_est), pretest_reject_10 = mean(lead_p2_boot < 0.10),
            expected_h4_bias = unique(pretrend * 10.5), mean_h4 = mean(h4_est), sd_h4 = sd(h4_est), se_ratio_pair = sd(h4_est) / mean(h4_se_pair),
            h4_reject_1s_boot = mean(h4_p1_boot < 0.05),
            h4_reject_after_pass = mean(h4_p1_boot[lead_p2_boot >= 0.10] < 0.05)), by = .(pretrend, h4)]
setorder(s, h4, pretrend)
mde <- s[pretrend == 0 & h4 == 0, (qnorm(0.95) + qnorm(0.80)) * sd_h4]
print(s); message("MDE ", round(mde, 3))
n_failed <- res[failed == TRUE, .N]
mc_tol <- 3 * sqrt(0.1 * 0.9 / R)

out <- c("# H4a pooled-lead pre-trend test and H4a power, broad-list scenario: Monte Carlo (2026-11-25)", "",
  "**Simulated data only. Nothing in this file is a result about IJVs.** No staffing data were read (real_data_lock: gate 6 is not approved). Inputs: the O*NET domain scores (public, outcome-free) as fixed regressors, and counts only: 24 exposed pairs and 231 exposed IJVs (`rescoring.md` 4.1); 16 exposed pairs and about 38 exposed IJVs with broad-list REG cells, 151 control pairs and 328 control IJVs with such cells (feasibility count of 2026-11-25, as summarized by the coordinator).", "",
  sprintf("Built %s by `code/R/tests/check_pretrend_pooled.R` with `code/R/functions/simulate_domain_panel.R`; %d draws per grid cell; %d fits failed; run time %d s on %d workers; fixest %s.",
          format(Sys.time(), "%Y-%m-%d %H:%M"), R, n_failed, elapsed(), WORKERS, packageVersion("fixest")), "",
  "## Design", "",
  sprintf("The generator of `check_recovery_domain.R` (domain random effects, domain x year and pair x domain x year noise, a uniform mobility shock absorbed by IJV x year effects), with 231 exposed IJVs in 24 pairs, %s control IJVs in %d control pairs (Zipf sizes; an assumption) and a REG cell in an IJV with probability %.3f, calibrated so that the counts of IJVs and pairs with REG cells come close to the feasibility count (columns `exposed_ijv_reg` to `control_pairs_reg`; the simulation has somewhat fewer pairs with REG cells, about 13 exposed and 128 control against 16 and 151, so it is slightly conservative). The simulated domain `REG` stands in for `REG_B`. `pretrend` is a linear differential trend of exposed REG cells in the log local share, per year, centered on 2014 and continuing after 2021 (a violation of parallel trends); `h4` is the planted H4a effect on the log local share of REG hiring after 2021.",
          format(N_CONTROL, big.mark = ","), N_CONTROL_PAIRS, PI_REG),
  "Pre-trend rule (PI, 2026-11-25): event study with fixed effects IJV x domain, domain x year and IJV x year; one pooled lead for 2010 to 2012, reference 2013 to 2015, one term per year 2016 to 2025; the lead's two-sided p-value from the cluster score bootstrap by dyad with the null imposed (499 Rademacher replications); the rule fails if p < 0.10. `expected_lead` is the lead the trend implies (-3 x pretrend), `expected_h4_bias` the bias of the H4a estimate it implies (pretrend x 10.5, the distance between the mean post year 2023 and the mean baseline year 2012.5).", "",
  sprintf("H4a: exposed x post x REG with the anticipation window as its own term, decisive one-sided cluster score bootstrap by dyad. `h4_reject_after_pass` is the rejection rate of H4a among draws that pass the pre-trend rule. Monte Carlo tolerance for a 0.10 rate at %d draws: +/- %.3f.", R, mc_tol), "",
  kb(s), "",
  sprintf("Minimum detectable H4a effect (80 percent power, one-sided 5 percent; (z_0.95 + z_0.80) x SD of the null estimates): %.3f on the log scale, a rise of %.0f percent in the local share of REG hiring.", mde, 100 * (exp(mde) - 1)), "")
writeLines(out, f_md)
message("written: ", f_md, " (", elapsed(), " s)")
