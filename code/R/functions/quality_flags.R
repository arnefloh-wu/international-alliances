# quality_flags.R
# Data quality flags for the matched dataset and for new extractions
# (.claude/skills/data-collector, Step 4). Flags are columns: no function here
# drops a row. The same functions run on data/synthetic/ (where every seeded
# failure has to be caught) and, unchanged, on the real tables.
# Needs data.table and const$min_years from code/R/00_setup.R.

#' Position-level flags.
#' @param d one row per position: position_id, start_date, end_date; optional
#'   rcid, country, user_id, jv_bvdid.
#' @param ijv optional IJV table (jv_bvdid, formation_year). With it, positions
#'   are checked against the IJV they are filed under.
flag_positions <- function(d, ijv = NULL) {
  d <- copy(d)
  d[, flag_dup_position := duplicated(position_id)]                 # copies after the first
  d[, flag_start_missing := is.na(start_date)]
  d[, flag_end_before_start := !is.na(start_date) & !is.na(end_date) & end_date < start_date]
  d[, flag_open_ended := is.na(end_date)]                           # a state to handle, not an error
  if ("rcid" %in% names(d)) d[, flag_employer_unmapped := is.na(rcid)]
  if ("country" %in% names(d)) d[, flag_country_missing := is.na(country)]   # "NA" (Namibia) is a value
  if (!is.null(ijv) && "jv_bvdid" %in% names(d)) {
    i <- match(d$jv_bvdid, ijv$jv_bvdid)
    d[, flag_stray_entity := is.na(i)]
    d[, flag_pre_formation := !is.na(start_date) & !is.na(i) & year(start_date) < ijv$formation_year[i]]
    if ("user_id" %in% names(d)) {
      multi <- unique(d[, .(user_id, jv_bvdid)])[, .N, by = user_id][N > 1L, user_id]
      d[, flag_multi_ijv_person := user_id %in% multi]
    }
  }
  d[]
}

#' IJV-level flags.
#' @param ijv one row per IJV: jv_bvdid, rcid_jv, n_emp, jv_employees_orbis.
#' @param spells employee spells with first_reference_year, last_reference_year.
#' @param parents,groups optional IJV-parent table and parent-family table
#'   (parent_bvdid, rcid); with them the entity checks run.
flag_ijvs <- function(ijv, spells, parents = NULL, groups = NULL) {
  ijv <- copy(ijv)
  u <- unique(spells[!is.na(first_reference_year) & !is.na(last_reference_year) & last_reference_year >= first_reference_year,
                     .(jv_bvdid, a = as.integer(first_reference_year), b = as.integer(last_reference_year))])
  yrs <- u[, .(year = seq.int(a, b)), by = .(jv_bvdid, a, b)][, .(n_years_obs = uniqueN(year)), by = jv_bvdid]
  ijv[, n_years_obs := yrs$n_years_obs[match(jv_bvdid, yrs$jv_bvdid)]]
  ijv[is.na(n_years_obs), n_years_obs := 0L]
  ijv[, flag_short_panel := n_years_obs < const$min_years]
  ijv[, flag_no_spells := n_years_obs == 0L]
  # Codebook rule: Orbis headcount of 10 or more and Revelio staff above 20 times it.
  ijv[, flag_size_mismatch := !is.na(jv_employees_orbis) & jv_employees_orbis >= 10L & n_emp > 20 * jv_employees_orbis]
  if (!is.null(parents) && !is.null(groups)) {
    fam <- merge(parents[, .(jv_bvdid, parent_bvdid)], groups[, .(parent_bvdid, rcid = as.numeric(rcid))],
                 by = "parent_bvdid", allow.cartesian = TRUE)
    own <- fam[ijv[, .(jv_bvdid, rcid = as.numeric(rcid_jv))], on = .(jv_bvdid, rcid), nomatch = NULL]
    # The JV's entity sits in a parent's Revelio family: Revelio files the JV under that parent.
    # A case to handle (the JV's own entity is never a parent employer); a wrong match where
    # the entity is the parent's own.
    ijv[, flag_jv_in_parent_family := jv_bvdid %in% own$jv_bvdid]
    sh <- fam[, .(n_par = uniqueN(parent_bvdid)), by = .(jv_bvdid, rcid)][n_par > 1L]
    ijv[, flag_shared_family_entity := jv_bvdid %in% sh$jv_bvdid]   # an entity in two parents' families
  }
  ijv[]
}

#' Account-level flags for annual Orbis records (one row per filing).
flag_accounts <- function(h, id = "jv_bvdid", year = "closdate_year") {
  h <- copy(h)
  h[, n_rows_entity_year := .N, by = c(id, year)]
  h[, flag_multi_account_row := n_rows_entity_year > 1L]            # several filings for one entity and year
  h[, flag_consolidated := conscode %in% c("C1", "C2")]
  h[, flag_not_12_months := is.na(nr_months) | nr_months != "12"]
  h[, n_rows_entity_year := NULL]
  h[]
}

#' Count and share of every flag_ column of a table.
flag_summary <- function(d, table = NA_character_) {
  fc <- grep("^flag_", names(d), value = TRUE)
  out <- data.table(table = table, flag = fc,
                    n = vapply(fc, function(f) sum(d[[f]], na.rm = TRUE), numeric(1)), rows = nrow(d))
  out[, share := n / rows][]
}

#' Flag shares within the groups of one column (region, source, year band).
flag_by <- function(d, by, flags = grep("^flag_", names(d), value = TRUE)) {
  d[, c(list(rows = .N), lapply(.SD, function(x) round(mean(x, na.rm = TRUE), 4))), by = by, .SDcols = flags][order(get(by))]
}

#' Year band of a date, for coverage over time.
year_band <- function(x) {
  cut(year(x), c(-Inf, 1999, 2009, 2014, 2019, Inf),
      labels = c("before 2000", "2000-2009", "2010-2014", "2015-2019", "2020-2026"))
}
