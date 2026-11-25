# check_recovery_domain.R
# Monte Carlo check of the primary specifications of the estimation part of
# the pre-analysis plan (draft, stage 5) at the decided grain: IJV x domain x
# year, 98 domains (97 SOC minor groups and REG), hiring flows 2010 to 2025,
# cell rule n_emp >= 5. Generator and models: code/R/functions/simulate_domain_panel.R.
#
# real_data_lock (gate 6 not approved): no staffing data are read. The only
# project inputs are the O*NET domain scores (public source, outcome-free) and
# the S13 exposure counts of literature/shock-scan/rescoring.md (counts only).
#
# Checks:
#   1. Static H1, H2, H3 (Poisson, log denominator offset, IJV x year effects):
#      size under a planted null world, power and bias under a planted effect
#      world; standard errors clustered two-way by IJV and domain against
#      IJV-only clustering (se_ratio = SD of the estimates / mean SE).
#   2. Permutation test over domains (score rows reassigned across the 98
#      domains) for H1 and H2: size and power.
#   2b. Cluster score bootstrap by domain (null imposed) for H1, H2, H3, and a
#      null world with equal domain sizes as a diagnostic of the two-way errors.
#   3. H4a and H4b for S13: exposed x post x REG triple difference with IJV x domain,
#      domain x year and IJV x year effects; 24 exposed pairs and 231 exposed
#      IJVs; clustered by pair (t test and cluster score bootstrap with the null
#      imposed) and by IJV; size, power, minimum detectable effect; size of the
#      joint pre-trend test of the event study.
#
# Run from the repository root (about 16 minutes on 14 workers):
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/tests/check_recovery_domain.R [R_static R_perm B_perm R_h4 workers]
#   (run of 2026-11-25: 500 150 99 150 14)
# Output: data/synthetic/estimate-recovery-domain-synthetic-2026-11-25.md

source("code/R/00_setup.R")
source("code/R/functions/simulate_domain_panel.R")
require_pkgs(c("fixest", "parallel"))
args <- as.integer(commandArgs(trailingOnly = TRUE))
arg <- function(i, default) if (length(args) >= i && !is.na(args[i])) args[i] else default
R_STATIC <- arg(1, 500L); R_PERM <- arg(2, 200L); B_PERM <- arg(3, 99L); R_H4 <- arg(4, 300L); WORKERS <- arg(5, 12L)
N_IJV_STATIC <- 1000L; N_IJV_PERM <- 600L; B_BOOT <- 499L
PI_REG <- c(low = 0.10, high = 0.30); H4_EFF <- c(0, 0.10, 0.20, 0.30)
SYN_DATE <- "2026-11-25"
f_md <- file.path("data/synthetic", sprintf("estimate-recovery-domain-synthetic-%s.md", SYN_DATE))
kb <- function(d, digits = 3) knitr::kable(d, format = "pipe", digits = digits, format.args = list(big.mark = ","))
t0 <- Sys.time()
dom <- domain_scores_sim()

cl <- parallel::makeCluster(WORKERS)

parallel::clusterExport(cl, c("dom", "N_IJV_STATIC", "N_IJV_PERM", "B_PERM", "B_BOOT"))
invisible(parallel::clusterEvalQ(cl, {
  suppressMessages({ library(data.table); library(fixest) })
  setDTthreads(1); setFixest_nthreads(1)
  source("code/R/functions/simulate_domain_panel.R")
}))
elapsed <- function() round(as.numeric(difftime(Sys.time(), t0, units = "secs")))

# --- 1. Static models -------------------------------------------------------
jobs1 <- CJ(world = c("null", "effect"), r = seq_len(R_STATIC))
st <- rbindlist(parallel::parLapplyLB(cl, split(jobs1, seq_len(nrow(jobs1))), function(j) {
  seed <- 20261125L + j$r + if (j$world == "effect") 100000L else 0L
  p <- simulate_domain_panel(dom, n_ijv = N_IJV_STATIC, eff = planted_domain(j$world), seed = seed)
  s <- fit_static_domain(p)
  cbind(world = j$world, r = j$r, s$coefs, capped = attr(p, "capped_share"),
        n_h1 = s$nobs[["H1"]], n_h2 = s$nobs[["H2"]], n_h3 = s$nobs[["H3"]])
}))
message("static done, ", elapsed(), " s")

# pseudo-true values of the effect world: one large draw with the common random effects set to zero
nz0 <- noise_domain(); nz0[c("dom_L", "dom_LP", "dom_IP", "dy", "pdt")] <- 0
big <- simulate_domain_panel(dom, n_ijv = 10000L, eff = planted_domain("effect"), nz = nz0, seed = 99L)
pt_true <- fit_static_domain(big)$coefs[vcov == "twoway", .(model, term, pseudo_true = estimate)]
rm(big)
pe <- planted_domain("effect")
planted_tab <- data.table(model = c("H1", "H2", "H2", "H3", "H3", "H3"),
                          term = c("coord_dependence", "local_embeddedness", "coord_dependence", "cd_host", "cd_nohost", "boundary (host - no host)"),
                          planted_effect = c(pe$h1_ip, pe$h2_le, pe$cd_local, pe$h3_host, pe$h3_nohost, pe$h3_host - pe$h3_nohost),
                          role = c("H1 test", "H2 test", "planted null in both worlds", "H3 test", "planted null in both worlds", "H3 boundary"))
s1 <- st[, .(mean_est = mean(estimate), sd_est = sd(estimate), mean_se = mean(se), reject_1s = mean(p1 < 0.05), reject_2s = mean(p2 < 0.05)),
         by = .(world, model, term, vcov)]
s1 <- merge(s1, planted_tab, by = c("model", "term"), sort = FALSE)
s1 <- merge(s1, pt_true, by = c("model", "term"), all.x = TRUE, sort = FALSE)
s1[world == "null", `:=`(planted = 0, target = 0)]
s1[world == "effect", `:=`(planted = planted_effect, target = pseudo_true)]
s1[, se_ratio := sd_est / mean_se]
cov1 <- merge(st, unique(s1[, .(world, model, term, target)]), by = c("world", "model", "term"))[, .(ci_covers_target = mean(ci_low <= target & target <= ci_high)), by = .(world, model, term, vcov)]
s1 <- merge(s1, cov1, by = c("world", "model", "term", "vcov"), sort = FALSE)
s1[, rel_bias := fifelse(target != 0, mean_est / target - 1, NA_real_)]
setorder(s1, world, model, term, vcov)
print(s1[, .(world, model, term, vcov, planted, target = round(target, 3), mean_est = round(mean_est, 3), se_ratio = round(se_ratio, 2), reject_1s, reject_2s)])
samp1 <- st[vcov == "twoway" & term == "local_embeddedness", .(cells_H1 = mean(n_h1), cells_H2 = mean(n_h2), cells_H3 = mean(n_h3), capped_share = mean(capped))]

# --- 2. Permutation test over domains ----------------------------------------
jobs2 <- CJ(world = c("null", "effect"), r = seq_len(R_PERM))
pm <- rbindlist(parallel::parLapplyLB(cl, split(jobs2, seq_len(nrow(jobs2))), function(j) {
  seed <- 30261125L + j$r + if (j$world == "effect") 100000L else 0L
  p <- simulate_domain_panel(dom, n_ijv = N_IJV_PERM, eff = planted_domain(j$world), seed = seed)
  d1 <- p[n_obs > 0]
  s <- fit_static_domain(p)$coefs[vcov == "twoway" & term %in% c("coord_dependence", "local_embeddedness")]
  h1 <- perm_domain(n_parent ~ coord_dependence + local_embeddedness + offset(log(n_obs)) | ijv_id^year, d1, dom, "coord_dependence", B = B_PERM)
  h2 <- perm_domain(n_local ~ local_embeddedness + coord_dependence + offset(log(n_obs)) | ijv_id^year, d1, dom, "local_embeddedness", B = B_PERM)
  data.table(world = j$world, r = j$r, model = c("H1", "H2"), term = c("coord_dependence", "local_embeddedness"),
             p1_perm = c(h1[["p1_perm"]], h2[["p1_perm"]]), p2_perm = c(h1[["p2_perm"]], h2[["p2_perm"]]),
             p1_twoway = c(s[model == "H1" & term == "coord_dependence", p1], s[model == "H2" & term == "local_embeddedness", p1]))
}))
message("permutation done, ", elapsed(), " s")
s2 <- pm[, .(draws = .N, reject_1s_perm = mean(p1_perm <= 0.05), reject_2s_perm = mean(p2_perm <= 0.05),
             reject_1s_twoway = mean(p1_twoway < 0.05), agree = mean((p1_perm <= 0.05) == (p1_twoway < 0.05))), by = .(world, model, term)]
print(s2)

# --- 2b. Score bootstrap by domain; diagnostic with equal domain sizes ---------
# Section 1 shows two-way clustered errors that are too small. Two candidate causes are
# checked: unequal domain sizes (few effective clusters), by a null world with equal domain
# prevalence (prev_sd = 0); and the remedy, a cluster score bootstrap by domain with the
# null imposed (score_boot(), Rademacher weights).
jobs2b <- rbind(CJ(world = c("null", "effect"), prev_sd = 1, r = seq_len(R_STATIC)),
                CJ(world = "null", prev_sd = 0, r = seq_len(R_STATIC)))
sb <- rbindlist(parallel::parLapplyLB(cl, split(jobs2b, seq_len(nrow(jobs2b))), function(j) {
  seed <- 50261125L + j$r + (j$world == "effect") * 100000L + (j$prev_sd == 0) * 200000L
  p <- simulate_domain_panel(dom, n_ijv = N_IJV_STATIC, eff = planted_domain(j$world), prev_sd = j$prev_sd, seed = seed)
  s <- fit_static_domain(p)$coefs[vcov == "twoway"]
  d1 <- p[n_obs > 0]; d3 <- p[n_local > 0]
  b1 <- score_boot(d1, "n_parent", "coord_dependence", "local_embeddedness", "ijv_id^year", "n_obs", "domain", B = B_BOOT)
  b2 <- score_boot(d1, "n_local", "local_embeddedness", "coord_dependence", "ijv_id^year", "n_obs", "domain", B = B_BOOT)
  b2n <- score_boot(d1, "n_local", "coord_dependence", "local_embeddedness", "ijv_id^year", "n_obs", "domain", B = B_BOOT)
  b3 <- score_boot(d3, "n_local_parent", "cd_host", c("cd_nohost", "local_embeddedness"), "ijv_id^year", "n_local", "domain", B = B_BOOT)
  data.table(world = j$world, prev_sd = j$prev_sd, r = j$r,
             model = c("H1", "H2", "H2", "H3"), term = c("coord_dependence", "local_embeddedness", "coord_dependence", "cd_host"),
             estimate = c(s[model == "H1" & term == "coord_dependence", estimate], s[model == "H2" & term == "local_embeddedness", estimate],
                          s[model == "H2" & term == "coord_dependence", estimate], s[model == "H3" & term == "cd_host", estimate]),
             se_twoway = c(s[model == "H1" & term == "coord_dependence", se], s[model == "H2" & term == "local_embeddedness", se],
                           s[model == "H2" & term == "coord_dependence", se], s[model == "H3" & term == "cd_host", se]),
             p1_twoway = c(s[model == "H1" & term == "coord_dependence", p1], s[model == "H2" & term == "local_embeddedness", p1],
                           s[model == "H2" & term == "coord_dependence", p1], s[model == "H3" & term == "cd_host", p1]),
             p2_twoway = c(s[model == "H1" & term == "coord_dependence", p2], s[model == "H2" & term == "local_embeddedness", p2],
                           s[model == "H2" & term == "coord_dependence", p2], s[model == "H3" & term == "cd_host", p2]),
             p1_boot = c(b1[["p1_boot"]], b2[["p1_boot"]], b2n[["p1_boot"]], b3[["p1_boot"]]),
             p2_boot = c(b1[["p2_boot"]], b2[["p2_boot"]], b2n[["p2_boot"]], b3[["p2_boot"]]))
}))
message("domain score bootstrap done, ", elapsed(), " s")
s2b <- sb[, .(draws = .N, se_ratio_twoway = sd(estimate) / mean(se_twoway),
              reject_1s_twoway = mean(p1_twoway < 0.05), reject_2s_twoway = mean(p2_twoway < 0.05),
              reject_1s_boot_domain = mean(p1_boot < 0.05), reject_2s_boot_domain = mean(p2_boot < 0.05)),
          by = .(domain_sizes = fifelse(prev_sd == 0, "equal", "unequal"), world, model, term)]
setorder(s2b, domain_sizes, world, model, term)
print(s2b)

# --- 3. H4 for S13 -----------------------------------------------------------
pairs <- s13_pairs()
parallel::clusterExport(cl, "pairs")
jobs3 <- CJ(scenario = names(PI_REG), h4 = H4_EFF, r = seq_len(R_H4))
jobs3[, `:=`(pi_reg = PI_REG[scenario], h4_channel = 0)]
# H4b violated: the REG rise is carried by local parent-origin hires (parent share among local REG hires x e^1)
jobs3 <- rbind(jobs3, data.table(scenario = "high_parent_carried", h4 = 0.30, r = seq_len(R_H4), pi_reg = PI_REG[["high"]], h4_channel = 1.0))
h4 <- rbindlist(parallel::parLapplyLB(cl, split(jobs3, seq_len(nrow(jobs3))), function(j) {
  seed <- 40261125L + j$r + 1000L * match(j$h4, c(0, 0.10, 0.20, 0.30)) + 100000L * match(j$scenario, c("low", "high", "high_parent_carried"))
  p <- simulate_domain_panel(dom, pairs = pairs, eff = planted_domain("effect", h4 = j$h4, h4_channel = j$h4_channel), pi_reg = j$pi_reg, seed = seed)
  f <- tryCatch(fit_h4(p, B = B_BOOT, h4b = j$scenario != "low"), error = function(e) NULL)   # H4b in the high-REG scenarios only (run time)
  if (is.null(f)) return(data.table(scenario = j$scenario, h4 = j$h4, r = j$r, failed = TRUE))
  cbind(scenario = j$scenario, h4 = j$h4, r = j$r, failed = FALSE, f$coefs, f$reg_cells_exposed,
        pairs_post = f$pairs_with_exposed_reg, pretest_p = f$pretest_p)
}), fill = TRUE)
message("H4 done, ", elapsed(), " s")
h4ok <- h4[failed == FALSE]
h4b <- h4ok[term %in% c("H4b_indep", "H4b_parent_share")]
h4ok <- h4ok[term == "exp_post_reg"]
s3 <- h4ok[vcov == "pair", .(draws = .N, mean_est = mean(estimate), sd_est = sd(estimate), mean_se_pair = mean(se),
                             reject_1s_t_pair = mean(p1 < 0.05), reject_1s_boot_pair = mean(p1_boot < 0.05),
                             reject_2s_boot_pair = mean(p2_boot < 0.05), pretest_reject_10 = mean(pretest_p < 0.10, na.rm = TRUE),
                             pretest_reject_05 = mean(pretest_p < 0.05, na.rm = TRUE),
                             exposed_ijv_reg = mean(ijv), exposed_pairs_reg_post = mean(pairs_post),
                             reg_cells_exposed_pre = mean(pre), reg_cells_exposed_post = mean(post)), by = .(scenario, h4)]
s3i <- h4ok[vcov == "ijv", .(mean_se_ijv = mean(se), reject_1s_t_ijv = mean(p1 < 0.05)), by = .(scenario, h4)]
s3 <- merge(s3, s3i, by = c("scenario", "h4"), sort = FALSE)
s3[, `:=`(se_ratio_pair = sd_est / mean_se_pair, se_ratio_ijv = sd_est / mean_se_ijv)]
cov3 <- h4ok[vcov == "pair", .(ci_covers_planted = mean(ci_low <= h4 & h4 <= ci_high)), by = .(scenario, h4)]
s3 <- merge(s3, cov3, by = c("scenario", "h4"), sort = FALSE)
mde <- s3[h4 == 0, .(scenario, mde_80 = (qnorm(0.95) + qnorm(0.80)) * sd_est)]
setorder(s3, scenario, h4)
print(s3)
print(mde)
w4b <- dcast(h4b, scenario + h4 + r ~ term, value.var = c("estimate", "p1_boot", "p2_boot"))
s3b <- w4b[, .(draws = .N, mean_est_indep = mean(estimate_H4b_indep), reject_1s_boot_indep = mean(p1_boot_H4b_indep < 0.05),
               mean_est_parent_share = mean(estimate_H4b_parent_share, na.rm = TRUE),
               parent_share_estimable = mean(!is.na(p2_boot_H4b_parent_share)),
               composition_violation_detected = mean(estimate_H4b_parent_share > 0 & p2_boot_H4b_parent_share < 0.05, na.rm = TRUE),
               h4b_support = mean(p1_boot_H4b_indep < 0.05 & !(estimate_H4b_parent_share > 0 & p2_boot_H4b_parent_share < 0.05 & !is.na(p2_boot_H4b_parent_share)))),
           by = .(scenario, h4)]
setorder(s3b, scenario, h4)
print(s3b)
n_failed <- h4[failed == TRUE, .N]

# --- 4. Write the report -----------------------------------------------------
NULL_MAX <- function(R) 0.05 + 3 * sqrt(0.05 * 0.95 / R)
ns <- noise_domain()
out <- c(
  sprintf("# Recovery check at the domain grain: Monte Carlo (%s)", SYN_DATE), "",
  "**Simulated data only. Nothing in this file is a result about IJVs.** No staffing data were read (real_data_lock: gate 6 is not approved). The only project inputs are the O*NET domain scores of `data/processed/contingency-scores-domain-v1-2026-11-25.csv` (public source, no outcome) as fixed regressor values, and the S13 exposure counts of `literature/shock-scan/rescoring.md`, section 4.1 (counts only).", "",
  sprintf("Built %s by `code/R/tests/check_recovery_domain.R` with `code/R/functions/simulate_domain_panel.R`; run time %d s on %d workers; fixest %s.",
          format(Sys.time(), "%Y-%m-%d %H:%M"), elapsed(), WORKERS, packageVersion("fixest")), "",
  "## Design of the simulation", "",
  sprintf("IJV x domain x year cells, 98 domains with their O*NET scores (`local_embeddedness`, `coord_dependence`; correlation %.2f across domains), hiring flows 2010 to 2025, cell rule `n_emp >= 5`. Each IJV is active in about 10 domains drawn with synthetic prevalence weights; the REG domain is present in an IJV with probability `pi_reg`. Outcomes are drawn log-linear in the category shares, so the planted value is the estimand of the primary estimator (Poisson with the log of the denominator as offset); %.2f%% of cells hit the cap of the local share at 0.98.",
          dom[, cor(local_embeddedness, coord_dependence)], 100 * samp1$capped_share),
  sprintf("The noise that matters for inference is common across IJVs: a domain random effect (SD %.2f on the log local share, %.2f on the log parent-origin shares), domain x year noise (SD %.2f) and pair x domain x year noise (SD %.2f). IJV x domain effects (SD %.2f and %.2f) and cell-year noise (SD %.2f) add within-IJV dependence. These SDs are assumptions: they cannot be calibrated without outcome data, and the power of the static tests depends on them almost entirely.",
          ns$dom_L, ns$dom_LP, ns$dy, ns$pdt, ns$id, ns$id_par, ns$e), "",
  sprintf("Static checks: %d draws per world of %d IJVs (null world: every planted effect zero; effect world: H1 0.15 on both parent-origin categories, H2 0.05, H3 0.15 with a host-country parent and 0 without; planted null on `coord_dependence` in the H2 model in both worlds). Average cells per draw: H1 %s, H2 %s, H3 %s. `target` is the planted value in the null world and the pseudo-true value in the effect world (the same model fitted to one draw of 10,000 IJVs with the common random effects set to zero); for H1 the target is below the planted 0.15 because IJVs without a host-country parent carry no slope on local parent-origin hires.",
          R_STATIC, N_IJV_STATIC, format(round(samp1$cells_H1), big.mark = ","), format(round(samp1$cells_H2), big.mark = ","), format(round(samp1$cells_H3), big.mark = ",")), "",
  sprintf("`reject_1s` is the share of draws with a one-sided p < 0.05 for a positive coefficient (the decision rule of the plan), `reject_2s` the two-sided share. For a planted null it estimates the size (nominal 0.05; Monte Carlo tolerance %.3f at %d draws), for a planted effect the power. `se_ratio` is the SD of the estimates across draws divided by the mean standard error: above 1, the standard errors are too small.", NULL_MAX(R_STATIC), R_STATIC), "",
  "## 1. Static models: Poisson with offset; two-way (IJV, domain) against IJV-only clustering", "",
  kb(s1[, .(world, model, term, role, vcov, planted, target, mean_est, sd_est, mean_se, se_ratio, reject_1s, reject_2s, ci_covers_target, rel_bias)]), "",
  "## 2. Permutation test over domains", "",
  sprintf("%d draws per world of %d IJVs, %d permutations of the domain score rows each (smallest attainable p = %.3f). `reject_1s_perm`: one-sided permutation p <= 0.05; `reject_1s_twoway`: one-sided two-way clustered p < 0.05 on the same draws; `agree`: share of draws in which the two tests reach the same decision.",
          R_PERM, N_IJV_PERM, B_PERM, 1 / (B_PERM + 1)), "",
  kb(s2), "",
  "## 2b. Cluster score bootstrap by domain, and a diagnostic with equal domain sizes", "",
  sprintf("Section 1 shows two-way clustered standard errors that are too small. %d draws per row: `unequal` uses the domain prevalence of sections 1 and 2 (log-normal weights, SD 1); `equal` gives every non-REG domain the same prevalence (null world only), to check whether unequal cluster sizes cause the shortfall. `boot_domain` is the cluster score bootstrap by domain with the null imposed (`score_boot()`, %d Rademacher replications), one-way by domain.", R_STATIC, B_BOOT), "",
  kb(s2b), "",
  "## 3. H4 for S13: exposed x post x REG", "",
  sprintf("Exposure on parent-host pairs: 24 exposed pairs and 231 exposed IJVs (the counts after the employee rule for IJVs with a parent in Revelio, `rescoring.md` 4.1), with the relative sizes of the twelve largest pairs (GB-DE to GB-BE) and twelve small pairs; 1,200 control IJVs in 100 control pairs (the number of control pairs is an assumption). Onset 2021, anticipation window 2016 to 2020 entered as its own term, fixed effects IJV x domain, domain x year and IJV x year. A uniform mobility shock (0.10 on the log local share in every domain of exposed IJVs after 2021) is planted and absorbed by the IJV x year effects. `pi_reg` is the probability that an IJV has a REG cell with five or more employees: low %.2f, high %.2f; the real share is unknown because counting REG cells needs the staffing data. %d draws per cell of the grid; %d fits failed.",
          PI_REG[["low"]], PI_REG[["high"]], R_H4, n_failed),
  "`reject_1s_boot_pair` is the one-sided cluster score bootstrap by pair with the null imposed (Rademacher weights, 499 replications), the decisive test of the plan; `reject_1s_t_pair` and `reject_1s_t_ijv` use the clustered t statistic. `pretest_reject_10` is the rejection rate of the joint Wald test of the 2010 to 2012 leads (pair-clustered; reference 2013 to 2015) at 0.10, the threshold of the plan's pre-trend rule; no pre-trend is planted, so it is the size of the pre-test. `mde_80` is the effect a one-sided 5 percent test detects with 80 percent power, (z_0.95 + z_0.80) times the SD of the null-world estimates, on the log scale of the local share of REG hires.", "",
  kb(s3[, .(scenario, h4, draws, exposed_ijv_reg, exposed_pairs_reg_post, reg_cells_exposed_pre, reg_cells_exposed_post, mean_est, sd_est, se_ratio_pair, se_ratio_ijv,
            ci_covers_planted, reject_1s_boot_pair, reject_1s_t_pair, reject_1s_t_ijv, reject_2s_boot_pair, pretest_reject_10, pretest_reject_05)]), "",
  kb(mde), "",
  "## 3b. H4b for S13 (directional channel test; PI decision of 2026-11-25)", "",
  "IJVs with a host-country parent; run in the high-REG scenarios only (run time). The composition model uses domain x year and IJV x year effects with exposed x REG as a regressor, because with IJV x domain effects it separates (local parent-origin hires in REG cells are rare). `indep`: `n_local_indep` with offset log(`n_obs`), shock x REG, one-sided cluster score bootstrap by pair (H4b decisive test). `parent_share`: `n_local_parent` with offset log(`n_local`), shock x REG, two-sided score bootstrap; a significantly positive coefficient means parent-origin hires carry the rise (composition check). `h4b_support`: decisive test rejects and the composition check does not. In `high_parent_carried` the planted REG rise in the local share (0.30) comes with a parent-origin share among local REG hires multiplied by e (planted 1.0 on the log scale), so H4b is false; `composition_violation_detected` is then the power of the composition check.", "",
  kb(s3b), "")
writeLines(out, f_md)
message("written: ", f_md, " (", elapsed(), " s)")
parallel::stopCluster(cl)
