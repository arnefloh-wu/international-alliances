# estimation.R
# Model functions for the staffing hypotheses (draft H1 to H4 of
# docs/research-brief.md; gate 5 fixes the final set). Used unchanged by
# code/R/04_estimate.R (one panel, simulated or real) and by
# code/R/tests/check_estimate_recovery.R (repeated simulated draws).
# Method rules: .claude/skills/statistical-analyst/SKILL.md.
# Needs data.table, fixest and const from code/R/00_setup.R.
#
# Panel columns (draft names): ijv_id, fn | level, year, dyad, host_parent,
# parent_in_revelio, first_shock_year, shock, event_time, coord_dependence,
# local_embeddedness | coord_role, n_hires, n_obs, n_not_obs, n_local,
# n_intl, n_local_parent, n_local_indep, n_intl_parent, n_intl_indep,
# n_parent, share_local, share_parent, share_parent_local, share_not_obs.

#' Share of the outcome variance within the IJV-year (the counterpart of the ICC).
within_share <- function(d, y, by = c("ijv_id", "year")) {
  x <- d[!is.na(get(y)), .(v = get(y), m = mean(get(y))), by = by]
  x[, var(v - m) / var(v)]
}

#' Samples of the static and dynamic models.
model_samples <- function(pf, min_cell = const$min_cell_emp) list(
  obs        = pf[n_obs >= min_cell],
  obs_par    = pf[n_obs >= min_cell & parent_in_revelio == TRUE],
  obs_par0   = pf[n_obs > 0 & parent_in_revelio == TRUE],
  local_par  = pf[n_local >= min_cell & parent_in_revelio == TRUE],
  local_par0 = pf[n_local > 0 & parent_in_revelio == TRUE],
  hires      = pf[n_hires >= min_cell]
)

#' Static models: variation across functions (levels) within the IJV-year.
fit_static <- function(pf, pl, min_cell = const$min_cell_emp) {
  s <- model_samples(pf, min_cell)
  lv <- pl[n_obs >= min_cell & parent_in_revelio == TRUE]; lv0 <- pl[n_obs > 0 & parent_in_revelio == TRUE]
  q <- function(expr) suppressMessages(expr)
  list(
    # H1: parent-origin share (local and international) among observed hires
    H1_lin  = q(feols(share_parent ~ coord_dependence + local_embeddedness | ijv_id^year, s$obs_par, weights = ~n_obs, cluster = ~ijv_id)),
    H1_pois = q(fepois(n_parent ~ coord_dependence + local_embeddedness + offset(log(n_obs)) | ijv_id^year, s$obs_par0, cluster = ~ijv_id)),
    H1L_lin = q(feols(share_parent ~ coord_role | ijv_id^year, lv, weights = ~n_obs, cluster = ~ijv_id)),
    H1L_pois = q(fepois(n_parent ~ coord_role + offset(log(n_obs)) | ijv_id^year, lv0, cluster = ~ijv_id)),
    # H2: local share among observed hires
    H2_lin  = q(feols(share_local ~ local_embeddedness + coord_dependence | ijv_id^year, s$obs, weights = ~n_obs, cluster = ~ijv_id)),
    # Same, with local embeddedness as categories: a linear slope in one score lets the curvature
    # of its effect load onto a correlated score (simulation: 10 to 12 percent false positives on
    # coordination dependence at nominal 5); categories remove that.
    H2_lin_cat = q(feols(share_local ~ i(local_embeddedness) + coord_dependence | ijv_id^year, s$obs, weights = ~n_obs, cluster = ~ijv_id)),
    H2_frac = q(feglm(share_local ~ local_embeddedness + coord_dependence | ijv_id^year, s$obs, family = quasibinomial("logit"),
                      weights = ~n_obs, cluster = ~ijv_id)),
    # H2 on cells before any exposure: the static slope is not mixed with the post-shock slope (H4)
    H2_frac_pre = q(feglm(share_local ~ local_embeddedness + coord_dependence | ijv_id^year, s$obs[shock == 0],
                          family = quasibinomial("logit"), weights = ~n_obs, cluster = ~ijv_id)),
    # H3: parent-origin share among local hires; slope by host-country parent
    H3_lin  = q(feols(share_parent_local ~ coord_dependence + coord_dependence:host_parent | ijv_id^year, s$local_par,
                      weights = ~n_local, cluster = ~ijv_id)),
    H3_frac = q(feglm(share_parent_local ~ coord_dependence + coord_dependence:host_parent | ijv_id^year, s$local_par,
                      family = quasibinomial("logit"), weights = ~n_local, cluster = ~ijv_id)),
    H3_pois = q(fepois(n_local_parent ~ coord_dependence + coord_dependence:host_parent + offset(log(n_local)) | ijv_id^year,
                       s$local_par0, cluster = ~ijv_id)),
    # History not observed, as its own outcome
    NO_lin  = q(feols(share_not_obs ~ coord_dependence + local_embeddedness | ijv_id^year, s$hires, weights = ~n_hires, cluster = ~ijv_id))
  )
}

#' Dynamic models: shock x score, the shock main effect absorbed by IJV x year effects.
fit_dynamic <- function(pf, min_cell = const$min_cell_emp, event_study = TRUE) {
  s <- model_samples(pf, min_cell)
  q <- function(expr) suppressMessages(expr)
  m <- list(
    H4_lin  = q(feols(share_local ~ shock:local_embeddedness + shock:coord_dependence | ijv_id^fn + fn^year + ijv_id^year,
                      s$obs, weights = ~n_obs, cluster = ~ijv_id)),
    H4_frac = q(feglm(share_local ~ shock:local_embeddedness + shock:coord_dependence | ijv_id^fn + fn^year + ijv_id^year,
                      s$obs, family = quasibinomial("logit"), weights = ~n_obs, cluster = ~ijv_id)),
    # Channel of H4: parent-origin share among local hires
    H4C_lin = q(feols(share_parent_local ~ shock:local_embeddedness + shock:coord_dependence | ijv_id^fn + fn^year + ijv_id^year,
                      s$local_par, weights = ~n_local, cluster = ~ijv_id))
  )
  if (event_study) {
    d <- copy(s$obs)
    d[, et := pmax(pmin(event_time, 4L), -5L)]; d[is.na(event_time), et := -1000L]
    m$H4_es <- q(feols(share_local ~ i(et, local_embeddedness, ref = c(-1, -1000)) | ijv_id^fn + fn^year + ijv_id^year,
                       d, weights = ~n_obs, cluster = ~ijv_id))
    d[, cohort := fifelse(is.na(first_shock_year), 10000L, first_shock_year)]
    m$H4_sa_high <- q(feols(share_local ~ sunab(cohort, year) | ijv_id^fn + year, d[local_embeddedness >= 4], weights = ~n_obs, cluster = ~ijv_id))
    m$H4_sa_low  <- q(feols(share_local ~ sunab(cohort, year) | ijv_id^fn + year, d[local_embeddedness <= 2], weights = ~n_obs, cluster = ~ijv_id))
  }
  m
}

#' Coefficient table of a list of models.
coef_rows <- function(models) rbindlist(lapply(names(models), function(n) {
  ct <- coeftable(models[[n]]); ci <- confint(models[[n]])
  data.table(model = n, term = rownames(ct), estimate = ct[, 1], se = ct[, 2], p = ct[, 4], ci_low = ci[, 1], ci_high = ci[, 2])
}))

#' Cells each model keeps, against the cells it was given.
sample_rows <- function(models) rbindlist(lapply(names(models), function(n) {
  m <- models[[n]]
  data.table(model = n, family = if (is.null(m$family)) "linear" else m$family$family,
             cells_given = m$nobs_origin, cells_used = m$nobs, ijv_years_or_groups_dropped = m$nobs_origin - m$nobs)
}))

#' What the planted effects imply for each model term (simulated data only).
#' check: "sign" = planted positive effect, must be positive and significant;
#'        "null" = planted zero, must not be significant;
#'        "null_linear" = planted zero in a linear model of a bounded or sparse share; the simulation
#'                        shows false-positive rates of 8 to 9 percent at nominal 5 (functional form and
#'                        slightly small clustered errors), so only gross errors are tested;
#'        "magnitude" = estimate should be near the planted logit value (rare outcome, Poisson);
#'        "reported" = shown, not tested (fractional logit with IJV x year effects).
recovery_spec <- function(planted) {
  pv <- setNames(planted$value, planted$param)
  data.table(
    model = c("H1_pois", "H1L_pois", "H2_lin", "H2_lin_cat", "H2_frac_pre", "H3_lin", "H3_lin", "H3_pois", "H3_pois", "H3_frac",
              "H4_lin", "H4_lin", "H4_frac", "H4_frac", "H4C_lin", "H4C_lin", "NO_lin", "NO_lin"),
    term = c("coord_dependence", "coord_role", "local_embeddedness", "coord_dependence", "local_embeddedness",
             "coord_dependence", "coord_dependence:host_parentTRUE", "coord_dependence", "coord_dependence:host_parentTRUE",
             "coord_dependence:host_parentTRUE", "shock:local_embeddedness", "shock:coord_dependence",
             "shock:local_embeddedness", "shock:coord_dependence",
             "shock:local_embeddedness", "shock:coord_dependence", "coord_dependence", "local_embeddedness"),
    planted = c(NA, pv[["lvl_role"]], NA, pv[["cd_local"]], pv[["h2_le"]], pv[["h3_nohost"]], NA, pv[["h3_nohost"]],
                pv[["h3_host"]], pv[["h3_host"]], NA, pv[["h4_shock_cd"]], pv[["h4_shock_le"]], pv[["h4_shock_cd"]],
                pv[["h4_channel"]], pv[["h4_channel"]],
                pv[["notobs_cd"]], pv[["notobs_le"]]),
    check = c("sign", "magnitude", "sign", "null", "magnitude", "null_linear", "sign", "null", "magnitude", "reported",
              "sign", "null_linear", "magnitude", "null", "null_linear", "null_linear", "null", "null"),
    hypothesis = c("H1", "H1 levels", "H2", "H2 (no cd effect)", "H2 before exposure", "H3 without host parent", "H3", "H3 without host parent",
                   "H3", "H3", "H4", "H4 (no cd effect)", "H4", "H4 (no cd effect)", "H4 channel", "H4 channel",
                   "history not observed", "history not observed"))
}

#' Permutation test: reassign the score rows across functions (levels) and re-estimate.
#' Exact enumeration when the number of permutations is at most B.
perm_test <- function(fml, data, scores, var, B = 999L, fun = feols, ...) {
  key <- names(scores)[1]; sc <- names(scores)[-1]
  fit <- function(d) suppressMessages(coef(fun(fml, data = d, ...)))[[var]]
  b0 <- fit(data)
  k <- nrow(scores)
  perms <- function(v) if (length(v) <= 1) list(v) else do.call(c, lapply(seq_along(v), function(i) lapply(perms(v[-i]), function(p) c(v[i], p))))
  idx <- if (factorial(k) <= B) perms(seq_len(k)) else replicate(B, sample(k), simplify = FALSE)
  base <- copy(data)[, (sc) := NULL]
  b <- vapply(idx, function(ix) { s <- copy(scores); for (v in sc) set(s, j = v, value = scores[[v]][ix]); fit(base[s, on = key]) }, numeric(1))
  exact <- factorial(k) <= B
  # p_min: the smallest p-value the test can return. With tied scores (a binary level score) many
  # permutations reproduce the observed assignment or its mirror image, so p_min can be large.
  data.table(term = var, estimate = b0, permutations = length(idx), exact = exact,
             p_perm = if (exact) mean(abs(b) >= abs(b0) - 1e-12) else (1 + sum(abs(b) >= abs(b0))) / (length(idx) + 1),
             p_min = if (exact) mean(abs(b) >= max(abs(b)) - 1e-12) else 1 / (length(idx) + 1))
}

#' Average marginal effect of a one-point change, by prediction.
ame <- function(m, data, var, delta = 1) {
  d1 <- copy(data); d1[[var]] <- d1[[var]] + delta
  mean(predict(m, newdata = d1, type = "response") - predict(m, newdata = data, type = "response"), na.rm = TRUE)
}
