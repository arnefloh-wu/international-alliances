# measures.R
# Cell-level measures of the approved pre-analysis plan pap-v1.0
# (reviews/gate-5-pre-analysis-plan.md, A3 and B0.3): hiring flows per
# IJV x grain x year counted on the staffing frame of A2.2, the accounting
# identities of A3, the share estimands, and the regressor tables of each
# grain. Definitions mirror data/codebook.md ("Panels, stage 6").
#
# The cross-partner measures of the original research idea (parent A against
# parent B) were dropped at gate 4, decision 1. They are kept at the end of this
# file, labeled legacy, because code/R/tests/test-functions.R still checks them;
# no panel uses them.

# ---- Staffing frame: counts per cell ------------------------------------------------

#' Indicator columns on the classified hire table H (one row per hire), so that
#' every count of A3 is a sum over the hires of a cell. Needs the columns of
#' classify_hires() and add_entrants() in code/R/functions/panel_build.R.
hire_indicators <- function(H) {
  six <- c("local_parent", "intl_parent", "parent_na", "local_indep", "intl_indep", "indep_na")
  for (w in c(3L, 1L, 5L)) {
    sfx <- if (w == 3L) "" else paste0("_ow", w)
    cw <- paste0("cat_w", w)
    for (cc in c(six, "not_obs")) set(H, j = paste0("i_", cc, sfx), value = as.integer(H[[cw]] == cc))
  }
  H[, i_local_parent_hcp := as.integer(cat_w3 == "local_parent" & p_host %in% TRUE)]
  H[, i_intl_parent_home := as.integer(cat_w3 == "intl_parent" & home_country %in% TRUE)]
  H[, i_obs_unmapped := as.integer(cat_w3 != "not_obs" & employer_mapped %in% FALSE)]
  for (e in c(3L, 1L, 5L)) set(H, j = if (e == 3L) "i_entrant" else paste0("i_entrant_e", e), value = as.integer(H[[paste0("entrant_e", e)]]))
  for (pl in c("local", "intl", "na")) set(H, j = paste0("i_entrant_", pl), value = as.integer(H$entrant_place %chin% pl))
  # Restricted subsets for robustness 7: without occupations with imputed scores (xi)
  # and without positions coded through the role lookup (xl).
  H[, `:=`(i_keep_xi = as.integer(score_imputed_occ %in% FALSE), i_keep_xl = as.integer(onet_source == "position"))]
  invisible(H)
}

#' Hire counts per cell-year. key: the grain column(s) of H (domain, level, ...).
#' Returns n_hires, the seven categories (primary window) and their one- and
#' five-year variants (_ow1, _ow5), the extra numerators, the entrant counts and
#' the counts of the restricted subsets (_xi, _xl).
cell_counts <- function(H, key) {
  if (!"i_hires" %in% names(H)) H[, i_hires := 1L]
  ic <- setdiff(grep("^i_", names(H), value = TRUE), c("i_keep_xi", "i_keep_xl"))
  by <- c("jv_bvdid", key, "year")
  d <- H[, lapply(.SD, sum), by = by, .SDcols = ic]          # plain lapply(.SD, sum): data.table GForce
  setnames(d, ic, sub("^i_", "n_", ic))
  core <- c("hires", "local_parent", "intl_parent", "parent_na", "local_indep", "intl_indep", "indep_na")
  for (s in c("xi", "xl")) {
    k <- paste0("i_keep_", s)
    r <- H[get(k) == 1L, lapply(.SD, sum), by = by, .SDcols = paste0("i_", core)]
    setnames(r, paste0("i_", core), paste0("n_", core, "_", s))
    d <- merge(d, r, by = by, all.x = TRUE)
  }
  for (v in grep("_x[il]$", names(d), value = TRUE)) set(d, which(is.na(d[[v]])), v, 0L)
  d
}

#' Accounting identities of A3 (pap-v1.0) for a suffix ("" primary; "_ow1", "_ow5",
#' "_xi", "_xl" variants). Adds n_obs, n_parent, n_indep, n_local, n_intl, n_geo and,
#' where n_hires<sfx> exists, n_not_obs<sfx>.
add_derived <- function(d, sfx = "") {
  g <- function(x) d[[paste0(x, sfx)]]
  set(d, j = paste0("n_parent", sfx), value = g("n_local_parent") + g("n_intl_parent") + g("n_parent_na"))
  set(d, j = paste0("n_indep", sfx), value = g("n_local_indep") + g("n_intl_indep") + g("n_indep_na"))
  set(d, j = paste0("n_obs", sfx), value = g("n_parent") + g("n_indep"))
  set(d, j = paste0("n_local", sfx), value = g("n_local_parent") + g("n_local_indep"))
  set(d, j = paste0("n_intl", sfx), value = g("n_intl_parent") + g("n_intl_indep"))
  set(d, j = paste0("n_geo", sfx), value = g("n_local") + g("n_intl"))
  if (paste0("n_hires", sfx) %in% names(d)) set(d, j = paste0("n_not_obs_chk", sfx), value = g("n_hires") - g("n_obs"))
  invisible(d)
}

#' Shares of A3 (estimands only; NA where the denominator is zero).
add_shares <- function(d) {
  r <- function(a, b) fifelse(b > 0, a / b, NA_real_)
  d[, `:=`(share_parent = r(n_parent, n_obs), share_local = r(n_local, n_geo),
           share_parent_local = r(n_local_parent, n_local), share_not_obs = r(n_not_obs, n_hires),
           share_entrant = r(n_entrant, n_hires), share_unknown = r(n_unknown, n_hires),
           share_unmapped = r(n_obs_unmapped, n_obs))]
  invisible(d)
}

#' Check the identities of A3 on every row; stops on the first failure.
check_identities <- function(d) {
  stopifnot(
    all(d$n_hires == d$n_obs + d$n_not_obs),
    all(d$n_not_obs == d$n_entrant + d$n_unknown),
    all(d$n_obs == d$n_local_parent + d$n_intl_parent + d$n_parent_na + d$n_local_indep + d$n_intl_indep + d$n_indep_na),
    all(d$n_geo == d$n_obs - d$n_parent_na - d$n_indep_na),
    all(d$n_hires == d$n_obs_ow1 + d$n_not_obs_ow1), all(d$n_hires == d$n_obs_ow5 + d$n_not_obs_ow5),
    all(d$n_obs_ow1 <= d$n_obs & d$n_obs <= d$n_obs_ow5),
    all(d$n_entrant == d$n_entrant_local + d$n_entrant_intl + d$n_entrant_na),
    all(d$n_entrant_e1 <= d$n_entrant & d$n_entrant <= d$n_entrant_e5),
    all(d$n_local_parent_hcp <= d$n_local_parent), all(d$n_intl_parent_home <= d$n_intl_parent),
    all(d$n_hires_xi <= d$n_hires & d$n_hires_xl <= d$n_hires),
    all(d$n_unknown >= 0L & d$n_unknown_e1 >= 0L & d$n_unknown_e5 >= 0L))
  invisible(TRUE)
}

# ---- Regressor tables per grain ---------------------------------------------------------

SCORE_COLS <- c("local_embeddedness", "coord_dependence", "local_embeddedness_broad", "coord_dependence_broad",
                "local_embeddedness_lv", "coord_dependence_lv", "law_gov_importance", "job_zone")

#' Domain scores at the H4 grain with the broad regulatory list carved out (REG_B,
#' 22 codes; pap-v1.0, stage 5 decision 8), by the rule of 07_contingency_scores.R:
#' unweighted mean of the domain's rated occupations, imputed values only where
#' no occupation is rated.
domain_b_scores <- function(occ) {
  o <- copy(occ)[, domain_b := fifelse(regulatory_broad %in% TRUE, "REG_B", soc_minor)]
  o[, {
    r <- !score_imputed
    use <- if (any(r)) r else rep(TRUE, .N)
    c(lapply(.SD[use], mean, na.rm = TRUE), list(n_occupations = .N, n_rated = sum(r), all_imputed = !any(r)))
  }, by = domain_b, .SDcols = SCORE_COLS]
}

#' Scores at a Revelio taxonomy grain (role_k50_v3 or role_k10_v3): mean of the
#' occupation scores over the O*NET codes of the group, weighted by the number of
#' role_k17000_v3 entries per code in the group (the rule of the rater comparison
#' of 2026-11-25, code/R/12_rater_onet_comparison.R); imputed occupation scores kept.
taxonomy_scores <- function(lookup, occ, col) {
  cnt <- lookup[is_occ(onet_code), .(w = .N), by = c(col, "onet_code")]
  cnt <- merge(cnt, occ[, c("onet_code", "score_imputed", SCORE_COLS), with = FALSE], by = "onet_code")
  cnt[, c(lapply(.SD, function(x) sum(w * x, na.rm = TRUE) / sum(w[!is.na(x)])),
          list(n_codes = .N, share_imputed = sum(w * score_imputed) / sum(w))), by = col, .SDcols = SCORE_COLS]
}

# ---- Legacy: cross-partner measures (dropped at gate 4, decision 1; not used) --------------

#' Legacy. Classify an employee's origin relative to parents A and B.
classify_origin <- function(prior_rcids, parent_a_rcids, parent_b_rcids,
                            prior_country = NA_character_, host_country = NA_character_) {
  if (length(prior_rcids) == 0 || all(is.na(prior_rcids))) return("no_history")
  first <- prior_rcids[[1]]
  if (first %in% parent_a_rcids) return("parent_a")
  if (first %in% parent_b_rcids) return("parent_b")
  if (any(prior_rcids %in% parent_a_rcids)) return("parent_a")
  if (any(prior_rcids %in% parent_b_rcids)) return("parent_b")
  if (!is.na(prior_country) && !is.na(host_country) && prior_country == host_country) return("external_host")
  "external_intl"
}

#' Legacy. Cross-partner integration measures from origin counts.
cell_measures <- function(n_a, n_b, n_ext_host, n_ext_intl, n_nohist = 0L,
                          equity_a = NA_real_, equity_b = NA_real_) {
  n_emp    <- n_a + n_b + n_ext_host + n_ext_intl + n_nohist
  n_parent <- n_a + n_b
  share_a  <- if (n_parent > 0) n_a / n_parent else NA_real_
  share_b  <- if (n_parent > 0) n_b / n_parent else NA_real_
  cpi      <- if (n_parent > 0) 2 * (1 - (share_a^2 + share_b^2)) else NA_real_
  dom      <- if (n_parent > 0) abs(share_a - share_b) else NA_real_
  dom_adj  <- if (n_parent > 0 && !is.na(equity_a) && !is.na(equity_b))
                abs((share_a - share_b) - (equity_a - equity_b)) else NA_real_
  data.table::data.table(
    n_emp = n_emp, n_from_a = n_a, n_from_b = n_b,
    n_external = n_ext_host + n_ext_intl, n_no_history = n_nohist,
    share_a = share_a, share_b = share_b, cross_parent_integration = cpi,
    parent_dominance = dom, parent_dominance_adj = dom_adj,
    localization = if (n_emp > 0) (n_ext_host + n_ext_intl) / n_emp else NA_real_,
    localization_host = if (n_emp > 0) n_ext_host / n_emp else NA_real_,
    parent_share_of_cell = if (n_emp > 0) n_parent / n_emp else NA_real_)
}

#' Within-IJV dispersion of a cell measure across the cells of an IJV-year
#' (keyed on any grain column; never a column named "function").
within_ijv_dispersion <- function(dt, measure = "cross_parent_integration") {
  dt[!is.na(get(measure)),
     .(n_cells = .N, disp_sd = sd(get(measure)), disp_range = max(get(measure)) - min(get(measure))),
     by = .(ijv_id, year)]
}
