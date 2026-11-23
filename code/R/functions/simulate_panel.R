# simulate_panel.R
# Simulated IJV x function x year and IJV x level x year panels with planted
# effects of known size (.claude/skills/statistical-analyst, Step 2,
# real_data_lock). Used by code/R/tests/synthetic_panel.R (writes the files)
# and code/R/tests/check_estimate_recovery.R (repeated draws).
#
# Everything is drawn from distributions; no real row is read. The column
# names are a draft for the gate-5 measurement specification: the function is
# `fn` (not `function`, a reserved word in R), and the nine functions, four
# levels and their contingency scores are placeholders. The scores were to
# come from the interview recoding (gate 3); the PI set the qualitative study
# aside on 2026-11-23, so their source is open (docs/decisions.md).
#
# Data-generating process (hiring flows per cell and year):
#   hires          Poisson, IJV-specific rate; no difference across functions
#   observed       Binomial(hires, p_obs): history observed, rising with the year
#   local          Binomial(observed, logit^-1(a_i + b_h2 le + b_cd cd + shock (b_main + b_h4 le + b_h4cd cd)))
#   local parent   Binomial(local, logit^-1(-3.4 + u_i + cd (b_h3 host + b_h3n no host) + b_ch shock le + b_role role))
#   intl parent    Binomial(international, logit^-1(-4.0 + u_i + b_h1 cd + b_role role))
#   Where no parent is in Revelio, parent-origin hires are recorded as
#   independent (they cannot be seen), as in the real data.
# Scores enter centered at 3 (cd = coord_dependence - 3, le = local_embeddedness - 3).
# The intercepts put parent-origin hires at about 3 percent of observed hires
# and the hires per cell near 4, close to the aggregate levels reported in
# reviews/gate-4-pilot.md; no function-level pattern of the real data is used.
# Exposure to the shock is assigned to parent-country pairs (`dyad`) with
# staggered first years; there is no anticipation (no planted pre-trend).

#' Planted effects on the logit scale. Zero means a planted null.
planted_effects <- function() list(
  h2_le        = 0.25,  # H2: local share rises with local embeddedness
  cd_local     = 0.00,  # null: coordination dependence does not move the local share
  h1_intl_cd   = 0.30,  # H1 (part): international parent-origin share rises with coordination dependence
  h3_host      = 0.40,  # H3: local parent-origin share rises with coordination dependence, IJVs with a host-country parent
  h3_nohost    = 0.00,  # H3 boundary: no slope without a host-country parent
  shock_main   = 0.20,  # shock raises the local share at average embeddedness (absorbed by IJV x year effects)
  h4_shock_le  = 0.30,  # H4: after the shock the local share rises more where embeddedness is high
  h4_shock_cd  = 0.00,  # null: no shock x coordination-dependence effect on the local share
  h4_channel   = 0.00,  # null: the parent-origin share among local hires does not move with the shock (H4 channel)
  notobs_cd    = 0.00,  # null: unobserved histories do not vary with the scores
  notobs_le    = 0.00,
  lvl_role     = 0.50   # H1 for levels: parent-origin share higher at levels with a coordination role
)

#' Function and level score tables (placeholders; source of the real scores open).
score_tables <- function() list(
  fn = data.table(fn = sprintf("fn%02d", 1:9),
                  coord_dependence   = c(5L, 4L, 4L, 3L, 3L, 2L, 2L, 1L, 3L),
                  local_embeddedness = c(1L, 2L, 3L, 3L, 4L, 5L, 4L, 2L, 5L)),
  level = data.table(level = c("lv1_executive", "lv2_middle", "lv3_professional", "lv4_operational"),
                     coord_role = c(1L, 1L, 0L, 0L))
)

#' Draw one pair of panels.
#' @return list(pf = function panel, pl = level panel, scores, planted, ijv)
simulate_panel <- function(n_ijv = 600L, years = 2010:2024, n_pair = 40L, n_exposed_pairs = 12L,
                           seed = 20261123L, eff = planted_effects()) {
  set.seed(seed)
  sc <- score_tables()
  pairs <- data.table(dyad = sprintf("SYNPAIR%02d", seq_len(n_pair)), first_shock_year = NA_integer_)
  ex <- sample(n_pair, n_exposed_pairs)
  pairs[ex, first_shock_year := sample(2016:2020, n_exposed_pairs, replace = TRUE)]
  jv <- data.table(ijv_id = sprintf("SYN%05d", seq_len(n_ijv)), dyad = sample(pairs$dyad, n_ijv, replace = TRUE),
                   host_parent = runif(n_ijv) < 0.80, parent_in_revelio = runif(n_ijv) < 0.75,
                   strategic = runif(n_ijv) < 0.30,
                   a = rnorm(n_ijv, 0.8, 0.5),          # local propensity
                   u = rnorm(n_ijv, 0, 0.5),            # parent-origin propensity
                   lam = exp(rnorm(n_ijv, log(4), 0.6)),# hires per cell and year
                   o = rnorm(n_ijv, 0, 0.3))            # observability of histories
  jv[pairs, on = "dyad", first_shock_year := i.first_shock_year]

  draw <- function(g) {
    g[, `:=`(cd_c = coord_dependence - 3, le_c = local_embeddedness - 3)]
    g[, shock := as.integer(!is.na(first_shock_year) & year >= first_shock_year)]
    g[, event_time := fifelse(is.na(first_shock_year), NA_integer_, year - first_shock_year)]
    g[, n_hires := rpois(.N, lam)]
    g[, n_obs := rbinom(.N, n_hires, plogis(-0.2 + 0.12 * (year - 2010) + o + eff$notobs_cd * cd_c + eff$notobs_le * le_c))]
    g[, n_local := rbinom(.N, n_obs, plogis(a + eff$h2_le * le_c + eff$cd_local * cd_c +
                                              shock * (eff$shock_main + eff$h4_shock_le * le_c + eff$h4_shock_cd * cd_c)))]
    g[, n_intl := n_obs - n_local]
    g[, n_lp := rbinom(.N, n_local, plogis(-3.4 + u + cd_c * fifelse(host_parent, eff$h3_host, eff$h3_nohost) +
                                             eff$h4_channel * shock * le_c + eff$lvl_role * coord_role))]
    g[, n_ip := rbinom(.N, n_intl, plogis(-4.0 + u + eff$h1_intl_cd * cd_c + eff$lvl_role * coord_role))]
    g[parent_in_revelio == FALSE, `:=`(n_lp = 0L, n_ip = 0L)]  # cannot be seen: recorded as independent
    g[, `:=`(n_local_parent = n_lp, n_local_indep = n_local - n_lp, n_intl_parent = n_ip, n_intl_indep = n_intl - n_ip)]
    g[, `:=`(n_not_obs = n_hires - n_obs, n_parent = n_lp + n_ip)]
    g[, share_local := fifelse(n_obs > 0, n_local / n_obs, NA_real_)]
    g[, share_parent := fifelse(n_obs > 0, n_parent / n_obs, NA_real_)]
    g[, share_parent_local := fifelse(n_local > 0, n_local_parent / n_local, NA_real_)]
    g[, share_not_obs := fifelse(n_hires > 0, n_not_obs / n_hires, NA_real_)]
    g[, c("a", "u", "lam", "o", "cd_c", "le_c", "n_lp", "n_ip") := NULL]
    g[, synthetic := TRUE][]
  }
  ids <- jv[, .(ijv_id, dyad, host_parent, parent_in_revelio, strategic, first_shock_year, a, u, lam, o)]
  pf <- CJ(ijv_id = jv$ijv_id, fn = sc$fn$fn, year = years)[ids, on = "ijv_id"][sc$fn, on = "fn"]
  pf[, coord_role := 0L]
  pf <- draw(pf)[, coord_role := NULL]
  pl <- CJ(ijv_id = jv$ijv_id, level = sc$level$level, year = years)[ids, on = "ijv_id"][sc$level, on = "level"]
  pl[, `:=`(coord_dependence = 3L, local_embeddedness = 3L)]   # centered at zero: no function scores at levels
  pl <- draw(pl)[, c("coord_dependence", "local_embeddedness") := NULL]
  setcolorder(pf, c("ijv_id", "fn", "year")); setcolorder(pl, c("ijv_id", "level", "year"))
  setorder(pf, ijv_id, fn, year); setorder(pl, ijv_id, level, year)
  list(pf = pf, pl = pl, scores = sc,
       planted = data.table(param = names(eff), value = unlist(eff)),
       ijv = jv[, .(ijv_id, dyad, host_parent, parent_in_revelio, strategic, first_shock_year)])
}
