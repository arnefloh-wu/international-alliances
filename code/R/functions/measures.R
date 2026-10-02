# measures.R
# Dependent variables for differentiated international integration.
# Definitions mirror data/codebook.md and research idea section 6.

#' Classify an employee's origin relative to the IJV parents.
#' @param prior_rcids list-column or character vector of prior employer rcids
#'   within the origin window, most recent first
#' @param parent_a_rcids, parent_b_rcids character vectors of rcids belonging
#'   to each parent group (parent plus its subsidiaries)
#' @param prior_country country of the most recent prior position
#' @param host_country IJV host country
#' @return one of "parent_a", "parent_b", "external_host", "external_intl",
#'   "no_history"
classify_origin <- function(prior_rcids, parent_a_rcids, parent_b_rcids,
                            prior_country = NA_character_,
                            host_country = NA_character_) {
  if (length(prior_rcids) == 0 || all(is.na(prior_rcids))) return("no_history")
  # Most recent prior employer decides; ties (same employer in both parent
  # groups, e.g. a shared subsidiary) are assigned to the larger-equity parent
  # upstream and flagged there.
  first <- prior_rcids[[1]]
  if (first %in% parent_a_rcids) return("parent_a")
  if (first %in% parent_b_rcids) return("parent_b")
  # Any-employer-within-window variant: if either parent appears at all.
  if (any(prior_rcids %in% parent_a_rcids)) return("parent_a")
  if (any(prior_rcids %in% parent_b_rcids)) return("parent_b")
  if (!is.na(prior_country) && !is.na(host_country) &&
      prior_country == host_country) return("external_host")
  "external_intl"
}

#' Cell-level integration measures from origin counts.
#' @param n_a,n_b,n_ext_host,n_ext_intl,n_nohist integer counts in the cell
#' @param equity_a,equity_b parent equity shares (0 to 1), optional
#' @return data.table with one row of measures
cell_measures <- function(n_a, n_b, n_ext_host, n_ext_intl, n_nohist = 0L,
                          equity_a = NA_real_, equity_b = NA_real_) {
  n_emp    <- n_a + n_b + n_ext_host + n_ext_intl + n_nohist
  n_parent <- n_a + n_b
  share_a  <- if (n_parent > 0) n_a / n_parent else NA_real_
  share_b  <- if (n_parent > 0) n_b / n_parent else NA_real_
  # 1 - (sA^2 + sB^2) ranges 0 to 0.5 for two categories; rescale by 2.
  cpi      <- if (n_parent > 0) 2 * (1 - (share_a^2 + share_b^2)) else NA_real_
  dom      <- if (n_parent > 0) abs(share_a - share_b) else NA_real_
  dom_adj  <- if (n_parent > 0 && !is.na(equity_a) && !is.na(equity_b))
                abs((share_a - share_b) - (equity_a - equity_b)) else NA_real_
  data.table::data.table(
    n_emp = n_emp, n_from_a = n_a, n_from_b = n_b,
    n_external = n_ext_host + n_ext_intl, n_no_history = n_nohist,
    share_a = share_a, share_b = share_b,
    cross_parent_integration = cpi,
    parent_dominance = dom,
    parent_dominance_adj = dom_adj,
    localization = if (n_emp > 0) (n_ext_host + n_ext_intl) / n_emp else NA_real_,
    localization_host = if (n_emp > 0) n_ext_host / n_emp else NA_real_,
    parent_share_of_cell = if (n_emp > 0) n_parent / n_emp else NA_real_
  )
}

#' Within-IJV differentiation (robustness, research idea 6.4).
#' @param dt cell-year data.table with ijv_id, year, function, and a measure
#' @param measure column name
within_ijv_dispersion <- function(dt, measure = "cross_parent_integration") {
  dt[!is.na(get(measure)),
     .(n_cells = .N,
       disp_sd = sd(get(measure)),
       disp_range = max(get(measure)) - min(get(measure))),
     by = .(ijv_id, year)]
}
