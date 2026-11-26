# panel_ijv.R
# IJV-level and IJV-year variables of the stage 6 panels (pre-analysis plan
# pap-v1.0, A2.3, A2.5, A4 and B0.2, B0.4; S13 control group as decided on
# 2026-11-25, chat item 14). Ownership and frame data only: no staffing count.
#
#   ijv_attributes()   sample subsets, host-country parent, quality flags, listed JVs, S13 exposure
#   add_year_vars()    post, anticipation window, shock, event time, main period
#   coverage_ijv_year() Revelio staff on 30 June over the unconsolidated Orbis headcount

#' @param ijv matched IJV table; par IJV-parent table; fam_info output of build_families();
#'   exposure rows of 06_shock_exposure.R; orbis frame rows (jv_bvdid, jv_listed, jv_isin, source).
ijv_attributes <- function(ijv, par, fam_info, exposure, orbis) {
  host_of <- setNames(ijv$jv_country, ijv$jv_bvdid)
  src_of <- setNames(ijv$source, ijv$jv_bvdid)
  p <- copy(par)
  p[, host := host_of[jv_bvdid]]
  p[, host_direct := parent_country == host]
  p[, guo_ok := src_of[jv_bvdid] == "orbis" & !is.na(guo_country) & guo_country != "CI" & grepl("^[A-Z]{2}$", guo_country)]
  p[, host_guo := fifelse(guo_ok, guo_country == host, NA)]
  a <- ijv[, .(ijv_id = jv_bvdid, host_country = jv_country, region, industry, formation_year, formation_year_missing,
               source, route, admitted_by, n_parents, match_tier, strategic = as.integer(strategic),
               flag_pre_formation_10y = as.integer(flag_pre_formation_10y), flag_holding_vehicle = as.integer(flag_holding_vehicle),
               ijv_n_emp = n_emp, jv_employees_orbis)]
  pv <- p[, .(n_parents_in_revelio = sum(parent_in_revelio %in% TRUE),
              parent_in_revelio = as.integer(any(parent_in_revelio %in% TRUE)),
              all_parents_in_revelio = as.integer(all(parent_in_revelio %in% TRUE)),
              host_parent = as.integer(any(host_direct %in% TRUE)),
              host_parent_in_revelio = as.integer(any(host_direct %in% TRUE & parent_in_revelio %in% TRUE)),
              host_parent_guo = if (all(!is.na(host_guo))) as.integer(any(host_guo)) else NA_integer_),
          by = .(ijv_id = jv_bvdid)]
  a <- merge(a, pv, by = "ijv_id", all.x = TRUE)
  a[, h3_sample := as.integer(host_parent == 1L & parent_in_revelio == 1L)]
  a[, flag_jv_in_parent_family := as.integer(ijv_id %chin% fam_info$jv_in_family)]
  a[, flag_shared_family_entity := as.integer(ijv_id %chin% fam_info$shared_ijv)]
  a[, flag_size_mismatch := as.integer(!is.na(jv_employees_orbis) & jv_employees_orbis >= 10L & ijv_n_emp > 20 * jv_employees_orbis)]
  a[, usable_30 := as.integer(ijv_n_emp >= 30L)]
  # Listed JVs (gate 4, decision 2): Orbis listing status "Listed" for Orbis-sourced IJVs;
  # for Capital IQ-sourced IJVs, which have no listing status in the frame, an ISIN on record.
  o <- unique(orbis[, .(jv_bvdid, jv_listed = pb_blank(jv_listed), jv_isin = pb_blank(jv_isin))], by = "jv_bvdid")
  a[o, on = .(ijv_id = jv_bvdid), `:=`(jv_listed = i.jv_listed, has_isin = !is.na(i.jv_isin))]
  a[, flag_listed := as.integer(fifelse(source == "orbis", jv_listed %chin% "Listed", has_isin %in% TRUE))]
  a[, listed_basis := fifelse(source == "orbis", "orbis_listing_status", "isin_on_record")]
  a[, c("jv_listed", "has_isin") := NULL]

  # ---- S13 (A2.5, B0.4; control group decision of 2026-11-25) ----
  ex <- exposure[shock == "S13"]
  main <- ex[grepl("^main", variant)]
  a[, exposed := as.integer(ijv_id %chin% main$jv_bvdid)]
  a[, s13_third_country := as.integer(ijv_id %chin% ex[grepl("third countries", variant), jv_bvdid])]
  a[, exposed_no_ie := as.integer(ijv_id %chin% ex[grepl("^Ireland excluded", variant), jv_bvdid])]
  a[, exposed_guo := fifelse(source == "orbis", as.integer(ijv_id %chin% ex[grepl("owner \\(GUO\\)", variant), jv_bvdid]), NA_integer_)]
  a[, uk_host := as.integer(host_country == "GB")]
  a[, gb_ie := as.integer(ijv_id %chin% main[pair == "GB-IE", jv_bvdid])]
  # Exposure pair: for an IJV with several exposed pairs, the pair of its largest-equity parent among them.
  pe <- p[jv_bvdid %chin% main$jv_bvdid & ((host == "GB" & parent_country %chin% SET13) | (host %chin% SET13 & parent_country == "GB"))]
  pe <- pe[order(jv_bvdid, -equity_share_current, parent_rank)]
  pe <- unique(pe, by = "jv_bvdid")[, .(ijv_id = jv_bvdid, pair_exposure = paste0("GB-", fifelse(host == "GB", parent_country, host)))]
  a[pe, on = "ijv_id", pair_exposure := i.pair_exposure]
  # Rule C (part C, section 2): UK-hosted exposed IJV whose largest EU, EEA or Swiss stake is above 50 percent.
  st <- p[host == "GB" & parent_country %chin% SET13, .(eu_stake_max = max(equity_share_current, na.rm = TRUE)), by = .(ijv_id = jv_bvdid)]
  a[st, on = "ijv_id", eu_stake_max := fifelse(is.finite(i.eu_stake_max), i.eu_stake_max, NA_real_)]
  a[exposed == 0L | uk_host == 0L, eu_stake_max := NA_real_]
  a[, control_linked := as.integer(exposed == 1L & uk_host == 1L & !is.na(eu_stake_max) & eu_stake_max > 50)]
  a[, eu_stake_band := fifelse(is.na(eu_stake_max), NA_character_, fifelse(eu_stake_max > 50, "above_50", fifelse(eu_stake_max == 50, "exactly_50", "below_50")))]
  a[, linked := as.integer(exposed == 1L & uk_host == 1L)]                 # Rule L: every UK-hosted exposed IJV
  a[, linked_alt := as.integer(exposed == 1L & uk_host == 1L & !is.na(eu_stake_max) & eu_stake_max >= 50)]   # minority-held coded not linked
  # Controls: hosted in the UK or the EU27, EEA or Switzerland, no UK-set parent-host link, not a
  # third-country parent-parent pair; the controls without a foreign direct parent (owner-level IJVs)
  # that have a UK-set link through their ultimate owner are dropped (PI, 2026-11-25).
  a[, s13_frame_control := as.integer((host_country %chin% SET13 | host_country == "GB") & exposed == 0L & s13_third_country == 0L)]
  nofor <- p[, .(no_foreign_direct = all(parent_country == host)), by = .(ijv_id = jv_bvdid)]
  a[nofor, on = "ijv_id", no_foreign_direct := as.integer(i.no_foreign_direct)]
  ol <- p[guo_ok == TRUE, .(guo_uk_link = any((host == "GB" & guo_country %chin% SET13) | (host %chin% SET13 & guo_country == "GB"))),
          by = .(ijv_id = jv_bvdid)]
  a[ol, on = "ijv_id", guo_uk_link := as.integer(i.guo_uk_link)]
  a[is.na(guo_uk_link), guo_uk_link := 0L]
  a[, s13_owner_link_dropped := as.integer(s13_frame_control == 1L & no_foreign_direct == 1L & guo_uk_link == 1L)]
  a[, s13_control := as.integer(s13_frame_control == 1L & s13_owner_link_dropped == 0L)]
  a[, s13_sample := as.integer(exposed == 1L | s13_control == 1L)]
  a[, owner_level := as.integer(route == "orbis_owner_level")]
  # dyad (B0.4; decision of 2026-11-25, item 6): exposed IJVs keep their exposure pair; others take the
  # host plus the country of the largest-equity foreign direct parent; IJVs without a foreign direct
  # parent take the country of the largest-equity foreign ultimate owner (chat item 14).
  fd <- p[parent_country != host][order(jv_bvdid, -equity_share_current, parent_rank)]
  fd1 <- unique(fd, by = "jv_bvdid")[, .(ijv_id = jv_bvdid, d1 = paste0(host, "-", parent_country))]
  fg <- p[guo_ok == TRUE & guo_country != host][order(jv_bvdid, -equity_share_current, parent_rank)]
  fg1 <- unique(fg, by = "jv_bvdid")[, .(ijv_id = jv_bvdid, d2 = paste0(host, "-", guo_country))]
  a[fd1, on = "ijv_id", d1 := i.d1]; a[fg1, on = "ijv_id", d2 := i.d2]
  a[, dyad := fcoalesce(pair_exposure, d1, d2, paste0(host_country, "-none"))]
  a[, dyad_source := fcase(!is.na(pair_exposure), "exposure_pair", !is.na(d1), "foreign_direct_parent",
                           !is.na(d2), "foreign_ultimate_owner", default = "none")]
  # dyad_all (robustness 3): host plus the set of all foreign direct parent countries.
  da <- fd[, .(da = paste0(host[1], "-", paste(sort(unique(parent_country)), collapse = "+"))), by = .(ijv_id = jv_bvdid)]
  a[da, on = "ijv_id", dyad_all := i.da]
  a[is.na(dyad_all), dyad_all := dyad]
  a[, c("d1", "d2") := NULL]
  a[, `:=`(formed_pre2016 = as.integer(formation_year < 2016L), formed_from2021 = as.integer(formation_year >= 2021L))]
  setkey(a, ijv_id)
  a[]
}

#' Year variables (A2.5, B0.4). post: from 2021; antic_yr: 2016 to 2020; shock and antic:
#' exposed times those; event_time: year - 2021 for exposed IJVs; post16 and shock16 for the
#' announcement-onset check (robustness 15d); main_period: hire years 2010 to 2025.
add_year_vars <- function(d) {
  d[, `:=`(post = as.integer(year >= 2021L), antic_yr = as.integer(year >= 2016L & year <= 2020L),
           post16 = as.integer(year >= 2016L), main_period = as.integer(year >= MAIN_START & year <= PANEL_END))]
  d[, `:=`(shock = exposed * post, antic = exposed * antic_yr, shock16 = exposed * post16,
           event_time = fifelse(exposed == 1L, year - 2021L, NA_integer_))]
  invisible(d)
}

#' Coverage ratio (gate 4, decision 8d; robustness 14): Revelio staff on 30 June over
#' the unconsolidated Orbis headcount (U1, U2) of the same closing year; one headcount
#' per IJV-year, twelve-month accounts first, then the latest closing date (rule of
#' 11_staffing_tabulations.R, T4b). Set from 2015 on only.
coverage_ijv_year <- function(hc, staff) {
  hc <- copy(hc)[, `:=`(year = as.integer(closdate_year), closdate = as.IDate(closdate))][empl > 0 & conscode %chin% c("U1", "U2")]
  hc[, full := nr_months %in% "12"]
  hc <- hc[order(jv_bvdid, year, -full, -as.numeric(closdate), -empl)]
  hc <- unique(hc, by = c("jv_bvdid", "year"))[, .(jv_bvdid, year, headcount_orbis_u = as.numeric(empl))]
  out <- merge(staff, hc, by = c("jv_bvdid", "year"), all.x = TRUE)
  out[, coverage_ratio := fifelse(year >= 2015L & !is.na(headcount_orbis_u), staff_revelio / headcount_orbis_u, NA_real_)]
  out[]
}
