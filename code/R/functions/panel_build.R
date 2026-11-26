# panel_build.R
# Helpers for the stage 6 panel build (code/R/02_build_panel.R and
# code/R/03_measures.R), following the approved pre-analysis plan pap-v1.0
# (reviews/gate-5-pre-analysis-plan.md, parts A2 to A4 and B0). The same
# functions run on the synthetic inputs of code/R/tests/synthetic_panel_build.R
# and, unchanged, on the real extracts. No function here estimates a model or
# tabulates a staffing category by exposure, domain, level, score or year.
#
#   panel_config()          file paths of the inputs and outputs (real or synthetic)
#   level_of()              Revelio seniority 1 to 7 to the four project levels
#   to_iso2()               Revelio country names to ISO 3166 alpha-2
#   attach_onet()           position-level O*NET code, else the role lookup
#   build_families()        parents' Revelio families per IJV, without the JV's own entity
#   build_hires()           first dated position at the JV entity per person and IJV
#   classify_hires()        staffing frame (A2.2) for the origin windows 1, 3 and 5 years
#   add_entrants()          labor market entrants (education windows 1, 3 and 5 years)
#   stock_counts()          employees on 30 June per IJV x grain x year
#   new_log(), log_step()   sample-construction log
# Needs data.table and the constants of code/R/00_setup.R.

pb_blank <- function(x) { x <- as.character(x); x[!is.na(x) & trimws(x) == ""] <- NA_character_; x }
is_occ <- function(x) !is.na(x) & grepl("^[0-9]{2}-[0-9]{4}[.][0-9]{2}$", x)
CATS <- c("local_parent", "intl_parent", "parent_na", "local_indep", "intl_indep", "indep_na", "not_obs")
PANEL_END <- 2025L          # last complete hiring year (Revelio data end 2026-09; plan A4.3)
MAIN_START <- 2010L         # main sample: hire years 2010 to 2025 (pre-analysis plan rules, decision 4)
ORIGIN_WINDOWS <- c(1L, 3L, 5L)     # origin window for prior positions; 3 primary (PI, 2026-11-25)
ENTRANT_WINDOWS <- c(1L, 3L, 5L)    # entrant window (education); 3 primary (decision 2)
SET13 <- c("AT","BE","BG","HR","CY","CZ","DK","EE","FI","FR","DE","GR","HU","IE","IT","LV","LT","LU","MT","NL",
           "PL","PT","RO","SK","SI","ES","SE","IS","LI","NO","CH")

#' Input and output paths. mode = "real" reads the licensed extracts under data/;
#' mode = "synthetic" reads the simulated twins of tests/synthetic_panel_build.R
#' and writes every output to data/synthetic/.
panel_config <- function(mode = c("real", "synthetic")) {
  mode <- match.arg(mode)
  if (mode == "real") {
    RUN <- "v3-2026-10-09"
    list(mode = mode, tag = "v1",
      ijv       = file.path(paths$processed, sprintf("ijv-matched-%s.csv", RUN)),
      parents   = file.path(paths$processed, sprintf("ijv-parents-%s.csv", RUN)),
      groups    = file.path(paths$interim, sprintf("full-parent-groups-%s.csv", RUN)),
      spells    = file.path(paths$processed, sprintf("ijv-employee-spells-%s.parquet", RUN)),
      jvpos     = file.path(paths$raw, "revelio-jv-positions-full-2026-10-09.parquet"),
      hist_dir  = file.path(paths$raw, "revelio-histories-full-2026-10-09"),
      onet_dir  = file.path(paths$raw, "revelio-jv-positions-onet-2026-11-25"),
      lookup    = file.path(paths$raw, "revelio-role-lookup-v3-2026-11-25.parquet"),
      edu_dir   = file.path(paths$raw, "revelio-education-full-2026-11-23"),
      occ       = file.path(paths$processed, "contingency-scores-occupation-v1-2026-11-25.csv"),
      dom       = file.path(paths$processed, "contingency-scores-domain-v1-2026-11-25.csv"),
      exposure  = file.path(paths$interim, "shock-exposure-ijv-2026-11-24.csv"),
      orbis     = file.path(paths$raw, sprintf("orbis-full-%s.csv", RUN)),
      headcount = file.path(paths$raw, "orbis-jv-headcounts-2026-11-23.parquet"),
      pind      = file.path(paths$interim, "parent-industry-v2-2026-11-25.csv"),
      oews      = file.path(paths$raw, "external", "oesm21in4.zip"),
      rater     = file.path(paths$interim, "rater-scores-2026-11-26.csv"),
      interim   = paths$interim,
      out       = paths$processed,
      log       = file.path(paths$processed, "sample-construction-log.md"),
      summary   = file.path(paths$interim, "panel-structure-v1-2026-11-26.md"),
      K         = 8L)
  } else {
    d <- file.path("data", "synthetic", "panel-build-synthetic-2026-11-26")
    list(mode = mode, tag = "synthetic-2026-11-26",
      ijv = file.path(d, "ijv-matched.csv"), parents = file.path(d, "ijv-parents.csv"),
      groups = file.path(d, "parent-groups.csv"), spells = file.path(d, "ijv-employee-spells.parquet"),
      jvpos = file.path(d, "revelio-jv-positions.parquet"), hist_dir = file.path(d, "revelio-histories"),
      onet_dir = file.path(d, "revelio-jv-positions-onet"), lookup = file.path(d, "revelio-role-lookup.parquet"),
      edu_dir = file.path(d, "revelio-education"), occ = file.path(d, "contingency-scores-occupation.csv"),
      dom = file.path(d, "contingency-scores-domain.csv"), exposure = file.path(d, "shock-exposure-ijv.csv"),
      orbis = file.path(d, "orbis-frame.csv"), headcount = file.path(d, "orbis-jv-headcounts.parquet"),
      pind = file.path(d, "parent-industry.csv"), oews = file.path(d, "oews-long.csv"),
      rater = file.path(d, "rater-scores.csv"),
      interim = file.path(d, "build"), out = file.path(d, "build"),
      log = file.path(d, "build", "sample-construction-log.md"),
      summary = file.path(d, "build", "panel-structure.md"), K = 2L)
  }
}

read_parts <- function(dir, cols = NULL) {
  f <- list.files(dir, pattern = "[.]parquet$", full.names = TRUE)
  if (!length(f)) stop("no parquet parts in ", dir, call. = FALSE)
  sel <- if (is.null(cols)) NULL else tidyselect::all_of(cols)
  rbindlist(lapply(f, function(x) as.data.table(arrow::read_parquet(x, col_select = sel))), use.names = TRUE)
}

#' Seniority-to-level mapping (PI, 2026-11-25; Revelio data dictionary labels).
#' map "a" (primary): executive 6-7, middle_management 4-5, professional 3, operational 1-2.
#' map "b" (robustness 18b): executive 7, middle_management 5-6, professional 3-4, operational 1-2.
level_of <- function(sen, map = c("a", "b")) {
  map <- match.arg(map); sen <- as.integer(sen)
  if (map == "a") fcase(sen %in% 6:7, "executive", sen %in% 4:5, "middle_management", sen == 3L, "professional",
                        sen %in% 1:2, "operational", default = NA_character_)
  else fcase(sen == 7L, "executive", sen %in% 5:6, "middle_management", sen %in% 3:4, "professional",
             sen %in% 1:2, "operational", default = NA_character_)
}
coord_role_of <- function(level) as.integer(level %chin% c("executive", "middle_management"))

#' Revelio country names to ISO 2 (location of the job, not nationality).
to_iso2 <- function(x) {
  u <- unique(x[!is.na(x)])
  m <- suppressWarnings(countrycode::countrycode(u, "country.name", "iso2c", warn = FALSE))
  m[match(x, u)]
}

#' O*NET code of a position: the position-level code if the position is in the
#' extract of 14_wrds_onet_code.R (values unknown, Retired, On Leave and empty are
#' missing, without a fallback); otherwise the code of its role_k17000_v3 in the
#' role lookup (PI, 2026-11-25), recorded as onet_source = "lookup".
attach_onet <- function(d, onet_pos, lookup) {
  i <- match(d$position_id, onet_pos$position_id)
  raw <- onet_pos$onet_code[i]
  src <- fifelse(is.na(i), "lookup", "position")
  lk <- lookup$onet_code[match(d$role_k17000_v3, lookup$role_k17000_v3)]
  raw[is.na(i)] <- lk[is.na(i)]
  set(d, j = "onet_code", value = fifelse(is_occ(raw), raw, NA_character_))
  set(d, j = "onet_source", value = src)
  invisible(d)
}

#' Occupation attributes used by the panel grains.
attach_occupation <- function(d, occ) {
  i <- match(d$onet_code, occ$onet_code)
  set(d, j = "domain", value = occ$domain[i])
  set(d, j = "domain_b", value = fifelse(occ$regulatory_broad[i] %in% TRUE, "REG_B", occ$soc_minor[i]))
  set(d, j = "score_imputed_occ", value = occ$score_imputed[i])
  invisible(d)
}

#' Parents' Revelio families per IJV (plan A2.2, rule 2). An entity in two parents'
#' families goes to the parent with the larger equity share (lower parent_rank);
#' the JV's own matched entity is never a parent employer.
build_families <- function(ijv, par, grp) {
  fam <- merge(par[, .(jv_bvdid, parent_bvdid, parent_rank, parent_country, host_direct)],
               unique(grp[, .(parent_bvdid, rcid = as.numeric(rcid))]), by = "parent_bvdid", allow.cartesian = TRUE)
  setorder(fam, jv_bvdid, rcid, parent_rank)
  shared <- fam[, .(n_par = uniqueN(parent_bvdid)), by = .(jv_bvdid, rcid)][n_par > 1L]
  fam <- unique(fam, by = c("jv_bvdid", "rcid"))
  own <- ijv[, .(jv_bvdid, rcid = as.numeric(rcid_jv))]
  in_fam <- fam[own, on = .(jv_bvdid, rcid), nomatch = NULL]
  n_before <- nrow(fam)
  fam <- fam[!own, on = .(jv_bvdid, rcid)]
  list(fam = fam[, .(jv_bvdid, rcid, p_rank = parent_rank, p_country = parent_country, p_host = host_direct)],
       jv_in_family = unique(in_fam$jv_bvdid), shared_ijv = unique(shared$jv_bvdid),
       n_shared_entities = nrow(shared), n_own_removed = n_before - nrow(fam))
}

#' Hires (plan A2.1): a person's first dated position at the matched JV entity, for
#' people in the spell table (at least one 30 June at the JV). Ties on the start
#' date are broken by position_id.
build_hires <- function(jvpos, spells, ijv) {
  pairs <- unique(spells[, .(jv_bvdid, user_id)])
  pos <- merge(jvpos, ijv[, .(rcid = as.numeric(rcid_jv), jv_bvdid)], by = "rcid")
  pos <- pos[pairs, on = .(jv_bvdid, user_id), nomatch = NULL]
  setorder(pos, jv_bvdid, user_id, start_date, position_id, na.last = TRUE)
  first <- unique(pos, by = c("jv_bvdid", "user_id"))
  no_pos <- pairs[!first, on = .(jv_bvdid, user_id)]
  list(hire = first[!is.na(start_date)], n_pairs = nrow(pairs), n_undated = first[is.na(start_date), .N],
       n_no_position = nrow(no_pos))
}

#' Staffing frame (plan A2.2) for each origin window w: prior positions are
#' positions at another employer (rcid other than the JV's entity, unmapped
#' employers included) that started before the hire date and were ongoing or
#' ended at most w * 365 days before it. Parent-origin if any prior position in
#' the window is in a parent's family (the most recent such position gives the
#' location and the parent); otherwise independent, with the location of the most
#' recent prior position. Positions without a start date or ending before they
#' start are dropped beforehand by the caller.
#' @return one row per hire (user_id, jv_bvdid) with has_earlier and, per window,
#'   cat_w<w>, plus for the primary window the parent's host status, the location
#'   country and whether the deciding employer is mapped.
classify_hires <- function(hire, hist, fam, windows = ORIGIN_WINDOWS, primary = 3L, K = 8L) {
  FAR <- as.IDate("2099-12-31")
  rbindlist(lapply(seq_len(K) - 1L, function(k) {
    pk <- hire[user_id %% K == k, .(user_id, jv_bvdid, rcid_jv, hire_date, host)]
    pr <- hist[user_id %% K == k][pk, on = "user_id", allow.cartesian = TRUE, nomatch = NULL]
    pr <- pr[(is.na(rcid) | rcid != rcid_jv) & start_date < hire_date]
    out <- pk[, .(user_id, jv_bvdid)]
    out[pr[, .(has_earlier = TRUE), by = .(user_id, jv_bvdid)], on = .(user_id, jv_bvdid), has_earlier := i.has_earlier]
    out[is.na(has_earlier), has_earlier := FALSE]
    pr[fam, on = .(jv_bvdid, rcid), `:=`(p_rank = i.p_rank, p_host = i.p_host)]
    pr[, is_par := !is.na(p_rank)]
    pr[, end_eff := fifelse(is.na(end_date), FAR, end_date)]
    pr[, gap := as.integer(hire_date) - as.integer(end_eff)]      # negative while the position is held
    setorder(pr, user_id, jv_bvdid, -is_par, -end_eff, -start_date, position_id)
    for (w in windows) {
      dec <- unique(pr[gap <= w * 365L], by = c("user_id", "jv_bvdid"))
      dec[, geo := fifelse(is.na(p_iso), "na", fifelse(p_iso == host, "local", "intl"))]
      dec[, cat := fcase(is_par & geo == "local", "local_parent", is_par & geo == "intl", "intl_parent",
                         is_par, "parent_na", geo == "local", "local_indep", geo == "intl", "intl_indep",
                         default = "indep_na")]
      cw <- paste0("cat_w", w)
      out[dec, on = .(user_id, jv_bvdid), (cw) := i.cat]
      out[is.na(get(cw)), (cw) := "not_obs"]
      if (w == primary) out[dec, on = .(user_id, jv_bvdid),
                            `:=`(p_host = i.p_host, p_iso = i.p_iso, employer_mapped = !is.na(i.rcid))]
    }
    out
  }))
}

#' Labor market entrants (plan A2.2, rule 5): history not observed, the JV is the
#' first recorded job (no earlier position at another employer) and the last
#' education that ended by the year after joining ended at most e years before the
#' hire year; split by place of that education (host, abroad, not recorded).
add_entrants <- function(H, edu, windows = ENTRANT_WINDOWS) {
  edu <- unique(edu, by = c("user_id", "education_number"))[user_id %in% H$user_id]
  edu[, end_year := year(enddate)]
  edu[, u_iso := to_iso2(university_country)]
  x <- edu[!is.na(end_year), .(user_id, end_year, u_iso, education_number)][
    H[, .(user_id, jv_bvdid, hire_year)], on = "user_id", allow.cartesian = TRUE, nomatch = NULL]
  x <- x[end_year <= hire_year + 1L]
  setorder(x, user_id, jv_bvdid, -end_year, -education_number)
  x <- unique(x, by = c("user_id", "jv_bvdid"))
  H[x, on = .(user_id, jv_bvdid), `:=`(edu_gap = hire_year - i.end_year, edu_iso = i.u_iso)]
  for (e in windows) {
    v <- paste0("entrant_e", e)
    H[, (v) := !has_earlier & !is.na(edu_gap) & edu_gap <= e]
  }
  H[, entrant_place := fifelse(!entrant_e3, NA_character_, fifelse(is.na(edu_iso), "na", fifelse(edu_iso == host, "local", "intl")))]
  invisible(H)
}

#' Employees on 30 June per IJV x key x year (unique people; a person with
#' positions in two keys counts in both). Years run from the formation year to
#' PANEL_END. Extra logical columns of sp (keep_<name>) give restricted counts
#' (n_emp_<name>). stock_counts_all() does several keys in one pass over the years
#' and returns a named list; stock_counts() is the one-key form.
stock_counts_all <- function(sp, keys, years, restrict = list()) {
  out <- setNames(lapply(keys, function(k) list()), keys)
  for (y in years) {
    x0 <- sp[first_reference_year <= y & last_reference_year >= y & formation_year <= y]
    if (!nrow(x0)) next
    for (key in keys) {
      x <- x0[!is.na(get(key))]
      if (!nrow(x)) next
      a <- unique(x, by = c("jv_bvdid", "user_id", key))[, .(n_emp = .N), by = c("jv_bvdid", key)]
      for (r in restrict[[key]]) {
        v <- paste0("n_emp_", sub("^keep_", "", r))
        ur <- unique(x[get(r) == TRUE], by = c("jv_bvdid", "user_id", key))
        a[ur[, .(n = .N), by = c("jv_bvdid", key)], on = c("jv_bvdid", key), (v) := i.n]
        set(a, which(is.na(a[[v]])), v, 0L)
      }
      out[[key]][[length(out[[key]]) + 1L]] <- a[, year := y]
    }
  }
  lapply(out, rbindlist)
}
stock_counts <- function(sp, key, years, restrict = character()) {
  stock_counts_all(sp, key, years, setNames(list(restrict), key))[[key]]
}

# ---- Sample-construction log --------------------------------------------------------
new_log <- function() { e <- new.env(); e$rows <- list(); e }
log_step <- function(L, part, step, n, unit, rule = "", removed = NA_real_) {
  fmt <- function(x) if (is.numeric(x)) format(x, big.mark = ",", scientific = FALSE, trim = TRUE) else as.character(x)
  L$rows[[length(L$rows) + 1L]] <- data.table(part = part, step = step, n = fmt(n), unit = unit,
                                              removed = if (is.na(removed)) "" else fmt(removed), rule = rule)
  message(sprintf("[%s] %s: %s %s%s", part, step, fmt(n), unit, if (!is.na(removed)) sprintf(" (removed %s)", fmt(removed)) else ""))
  invisible(NULL)
}
log_table <- function(L) rbindlist(L$rows)
