# simulate_domain_panel.R
# Simulated IJV x domain x year panels at the grain decided on 2026-11-25
# (domain = SOC minor group, 97, plus the REG domain of the 16 narrow
# regulatory-facing occupations), with planted effects of known size, and the
# model functions of the estimation part of the pre-analysis plan (draft for
# reviews/gate-5-pre-analysis-plan.md). Used by code/R/tests/check_recovery_domain.R.
#
# real_data_lock: no staffing row is read. The only project file read is the
# domain score table data/processed/contingency-scores-domain-v1-2026-11-25.csv,
# which code/R/07_contingency_scores.R builds from the public O*NET 31.0
# database alone; its scores are fixed regressor values, not outcomes.
# Exposure counts for S13 come from literature/shock-scan/rescoring.md
# (section 4.1, counts only). Everything else is drawn from distributions
# chosen by the agent: domain prevalence, cell sizes, the IJV and domain
# heterogeneity and the planted effects are assumptions, not estimates.
#
# Data-generating process (hiring flows per cell and year; log-linear in the
# category shares, so that the planted value is the estimand of the primary
# estimator, Poisson with the log of the denominator as offset):
#   n_emp          cell employment on 30 June; a cell enters the sample if n_emp >= 5
#   n_hires        Poisson(0.2 * n_emp)
#   n_obs          Binomial(n_hires, p_obs(year)): prior position observed (entrants and unknown excluded)
#   n_local        Binomial(n_obs, min(0.98, exp(eta_L)))
#                  eta_L = log p0_i + h2_le le + cd_local cd + v_d + g_dt + w_id + e_idt + q_pdt
#                          + exposed post (mobility + h4_reg reg) + exposed antic h4_antic reg
#   n_local_parent Binomial(n_local, min(0.5, exp(eta_LP)))
#                  eta_LP = log 0.016 + u_i + cd (h3_host host_parent + h3_nohost (1 - host_parent)) + ...
#                           + h4_channel exposed post reg (H4b violated when > 0: parent-origin hires carry the rise)
#   n_intl_parent  Binomial(n_intl, min(0.5, exp(eta_IP))),  eta_IP = log 0.05 + u_i + h1_ip cd + ...
#   v_d   domain random effect, common to all IJVs (redrawn each draw): the reason the static
#         tests rest on 98 domains, not on thousands of IJVs
#   g_dt  domain x year noise; w_id IJV x domain effect; e_idt cell-year noise
#   q_pdt parent-host pair x domain x year noise on the local share: the reason the shock
#         model is clustered by pair
# Scores are the O*NET domain scores (standardized across rated occupations).
# The intercepts put the local share near 0.55, parent-origin hires near 3 percent
# of observed hires and local parent-origin hires near 1.6 percent of local hires,
# close to the aggregate levels in docs/research-brief.md; no domain pattern of the
# real data is used (none was read).

#' Domain score table (98 rows) with the REG indicator.
domain_scores_sim <- function(path = file.path("data", "processed", "contingency-scores-domain-v1-2026-11-25.csv")) {
  d <- fread(path)[, .(domain, local_embeddedness, coord_dependence, law_gov_importance, job_zone)]
  d[, reg := as.integer(domain == "REG")]
  stopifnot(nrow(d) == 98L, sum(d$reg) == 1L, !anyNA(d$local_embeddedness), !anyNA(d$coord_dependence))
  d[]
}

#' Planted effects (log scale of the category share). Zero is a planted null.
planted_domain <- function(world = c("effect", "null"), h4 = 0, h4_channel = 0) {
  world <- match.arg(world)
  e <- list(h2_le = 0.05, cd_local = 0, h1_ip = 0.15, h3_host = 0.15, h3_nohost = 0,
            mobility = 0.10, h4_reg = h4, h4_antic = 0, h4_channel = h4_channel)
  if (world == "null") e[c("h2_le", "h1_ip", "h3_host")] <- 0
  e
}

#' Noise standard deviations (log scale). Assumptions; see the header.
noise_domain <- function() list(
  dom_L = 0.10, dom_LP = 0.25, dom_IP = 0.25,   # domain random effects
  dy = 0.04,                                    # domain x year
  id = 0.10, id_par = 0.30,                     # IJV x domain
  e = 0.05,                                     # cell-year
  pdt = 0.08,                                   # pair x domain x year (local share)
  u = 0.50                                      # IJV propensity for parent-origin hires
)

#' Parent-host pairs for the S13 simulation. Exposed: 24 pairs and 231 IJVs, the counts after
#' the employee rule for IJVs with a parent in Revelio (rescoring.md, section 4.1). The twelve
#' largest pairs keep their relative sizes (GB-DE 68 ... GB-BE 13 of 394, scaled by 231/394);
#' the other twelve pairs share the remainder. Controls: a Zipf distribution of n_control IJVs
#' over n_control_pairs pairs (the number of control pairs is not counted in the scan: an assumption).
s13_pairs <- function(n_control = 1200L, n_control_pairs = 100L) {
  big <- c(DE = 68, IT = 44, NL = 37, FR = 37, ES = 34, IE = 31, LU = 24, DK = 20, NO = 19, CY = 15, CH = 13, BE = 13)
  nb <- round(big * 231 / 394)
  rest <- 231L - sum(nb)
  ns <- rep(rest %/% 12L, 12L); ns[seq_len(rest %% 12L)] <- ns[seq_len(rest %% 12L)] + 1L
  ex <- data.table(dyad = c(paste0("GB-", names(big)), sprintf("GB-X%02d", 1:12)), exposed = 1L, n = c(nb, ns))
  w <- 1 / seq_len(n_control_pairs); nc <- floor(n_control * w / sum(w)); nc <- pmax(nc, 1L)
  nc[1] <- nc[1] + (n_control - sum(nc))
  co <- data.table(dyad = sprintf("CTRL%03d", seq_len(n_control_pairs)), exposed = 0L, n = as.integer(nc))
  rbind(ex, co)[n > 0]
}

#' One simulated IJV x domain x year panel (cells with n_emp >= min_emp).
#' @param pairs  data.table(dyad, exposed, n); NULL gives n_ijv unexposed IJVs in 50 pairs
#' @param pi_reg probability that an IJV has a REG cell
simulate_domain_panel <- function(dom, n_ijv = 1000L, pairs = NULL, years = 2010:2025, eff = planted_domain(),
                                  nz = noise_domain(), pi_reg = 0.20, k_mean = 10, min_emp = 5L,
                                  onset = 2021L, antic = 2016:2020, prev_sd = 1, pretrend = 0, seed = 1L) {
  set.seed(seed)
  if (is.null(pairs)) pairs <- data.table(dyad = sprintf("P%02d", 1:50), exposed = 0L, n = as.integer(diff(round(seq(0, n_ijv, length.out = 51)))))
  jv <- pairs[rep(seq_len(.N), n), .(dyad, exposed)]
  jv[, ijv_id := sprintf("SYN%05d", .I)]
  N <- nrow(jv)
  jv[, `:=`(host_parent = as.integer(runif(N) < 0.85), p0 = runif(N, 0.40, 0.65),
            u = rnorm(N, -nz$u^2 / 2, nz$u), size = exp(rnorm(N, 0, 0.5)))]
  # domains per IJV: prevalence weights drawn once per panel (synthetic, not from real data)
  nonreg <- dom[reg == 0L, domain]
  prev <- exp(rnorm(length(nonreg), 0, prev_sd))   # prev_sd = 0: equal domain sizes (diagnostic)
  k <- pmin(length(nonreg), 3L + rpois(N, k_mean - 3))
  cells <- rbindlist(lapply(seq_len(N), function(i) data.table(ijv_id = jv$ijv_id[i], domain = sample(nonreg, k[i], prob = prev))))
  has_reg <- runif(N) < pi_reg
  cells <- rbind(cells, data.table(ijv_id = jv$ijv_id[has_reg], domain = "REG"))
  cells[jv, on = "ijv_id", `:=`(size = i.size, dyad = i.dyad)]
  cells[, e0 := exp(rnorm(.N, log(6), fifelse(domain == "REG", 0.6, 1.0))) * size]
  cells[, `:=`(w_L = rnorm(.N, 0, nz$id), w_LP = rnorm(.N, 0, nz$id_par), w_IP = rnorm(.N, 0, nz$id_par))]
  # random effects that are common across IJVs
  re_d <- data.table(domain = dom$domain, v_L = rnorm(98, 0, nz$dom_L), v_LP = rnorm(98, 0, nz$dom_LP), v_IP = rnorm(98, 0, nz$dom_IP))
  re_dt <- CJ(domain = dom$domain, year = years)[, g := rnorm(.N, 0, nz$dy)]
  re_pdt <- CJ(dyad = unique(jv$dyad), domain = dom$domain, year = years)[, q := rnorm(.N, 0, nz$pdt)]

  p <- CJ(cid = seq_len(nrow(cells)), year = years)
  p <- cbind(cells[p$cid], year = p$year)
  p[, n_emp := as.integer(round(e0 * exp(rnorm(.N, 0, 0.15))))]
  p <- p[n_emp >= min_emp]
  p[jv, on = "ijv_id", `:=`(exposed = i.exposed, host_parent = i.host_parent, p0 = i.p0, u = i.u)]
  p[dom, on = "domain", `:=`(local_embeddedness = i.local_embeddedness, coord_dependence = i.coord_dependence,
                              job_zone = i.job_zone, reg = i.reg)]
  p[re_d, on = "domain", `:=`(v_L = i.v_L, v_LP = i.v_LP, v_IP = i.v_IP)]
  p[re_dt, on = .(domain, year), g := i.g]
  p[re_pdt, on = .(dyad, domain, year), q := i.q]
  p[, `:=`(post = as.integer(year >= onset), antic_yr = as.integer(year %in% antic))]
  le <- p$local_embeddedness; cd <- p$coord_dependence
  p[, n_hires := rpois(.N, 0.2 * n_emp)]
  p[, n_obs := rbinom(.N, n_hires, pmin(0.85, 0.60 + 0.015 * (year - 2010)))]
  p[, eta_L := log(p0) + eff$h2_le * le + eff$cd_local * cd + v_L + g + w_L + rnorm(.N, 0, nz$e) + q +
              exposed * post * (eff$mobility + eff$h4_reg * reg) + exposed * antic_yr * eff$h4_antic * reg +
              pretrend * exposed * reg * (year - 2014)]   # pretrend: linear violation of parallel trends (default 0)
  p[, p_local := pmin(0.98, exp(eta_L))]
  p[, n_local := rbinom(.N, n_obs, p_local)]
  p[, n_intl := n_obs - n_local]
  p[, p_lp := pmin(0.5, exp(log(0.016) + u + cd * fifelse(host_parent == 1L, eff$h3_host, eff$h3_nohost) + v_LP + w_LP + rnorm(.N, 0, nz$e) +
                             eff$h4_channel * exposed * post * reg))]
  p[, p_ip := pmin(0.5, exp(log(0.05) + u + eff$h1_ip * cd + v_IP + w_IP + rnorm(.N, 0, nz$e)))]
  p[, n_local_parent := rbinom(.N, n_local, p_lp)]
  p[, n_intl_parent := rbinom(.N, n_intl, p_ip)]
  p[, `:=`(n_local_indep = n_local - n_local_parent, n_intl_indep = n_intl - n_intl_parent, n_parent = n_local_parent + n_intl_parent)]
  capped <- p[, mean(exp(eta_L) > 0.98)]
  p[, `:=`(exp_post_reg = exposed * post * reg, exp_antic_reg = exposed * antic_yr * reg, treat_reg = exposed * reg,
           cd_host = coord_dependence * host_parent, cd_nohost = coord_dependence * (1L - host_parent))]
  p[, c("e0", "size", "w_L", "w_LP", "w_IP", "v_L", "v_LP", "v_IP", "g", "q", "p0", "u", "eta_L", "p_local", "p_lp", "p_ip") := NULL]
  p[, synthetic := TRUE]
  setcolorder(p, c("ijv_id", "domain", "year", "dyad"))
  attr(p, "capped_share") <- capped
  p[]
}

# ---------------------------------------------------------------------------
# Models of the plan (primary estimator: fepois with log denominator offset)
# ---------------------------------------------------------------------------

#' One coefficient with IJV-only and two-way (IJV, domain) clustered inference.
#' p1: one-sided p-value for a positive coefficient, t distribution with G - 1 df.
coef_inf <- function(m, term, vcovs) rbindlist(lapply(names(vcovs), function(v) {
  s <- summary(m, vcov = vcovs[[v]])
  ct <- coeftable(s); b <- ct[term, 1]; se <- ct[term, 2]
  df <- tryCatch(fixest::degrees_freedom(s, "t"), error = function(e) Inf)
  data.table(term = term, vcov = v, estimate = b, se = se, df = df,
             p2 = 2 * pt(abs(b / se), df, lower.tail = FALSE), p1 = pt(b / se, df, lower.tail = FALSE),
             ci_low = b - qt(0.975, df) * se, ci_high = b + qt(0.975, df) * se)
}))

#' Static models H1, H2, H3 (domains within the IJV-year).
fit_static_domain <- function(p) {
  q <- function(x) suppressMessages(suppressWarnings(x))
  d1 <- p[n_obs > 0]; d3 <- p[n_local > 0]
  m <- list(
    H1 = q(fepois(n_parent ~ coord_dependence + local_embeddedness + offset(log(n_obs)) | ijv_id^year, d1)),
    H2 = q(fepois(n_local ~ local_embeddedness + coord_dependence + offset(log(n_obs)) | ijv_id^year, d1)),
    H3 = q(fepois(n_local_parent ~ cd_host + cd_nohost + local_embeddedness + offset(log(n_local)) | ijv_id^year, d3)))
  vc <- list(twoway = ~ijv_id + domain, ijv = ~ijv_id)
  out <- rbind(
    cbind(model = "H1", coef_inf(m$H1, "coord_dependence", vc)),
    cbind(model = "H2", coef_inf(m$H2, "local_embeddedness", vc)),
    cbind(model = "H2", coef_inf(m$H2, "coord_dependence", vc)),
    cbind(model = "H3", coef_inf(m$H3, "cd_host", vc)),
    cbind(model = "H3", coef_inf(m$H3, "cd_nohost", vc)))
  # H3 boundary: slope with a host-country parent minus slope without
  bd <- rbindlist(lapply(names(vc), function(v) {
    V <- vcov(m$H3, vcov = vc[[v]]); b <- coef(m$H3)
    est <- b[["cd_host"]] - b[["cd_nohost"]]; se <- sqrt(V["cd_host", "cd_host"] + V["cd_nohost", "cd_nohost"] - 2 * V["cd_host", "cd_nohost"])
    df <- tryCatch(fixest::degrees_freedom(summary(m$H3, vcov = vc[[v]]), "t"), error = function(e) Inf)
    data.table(model = "H3", term = "boundary (host - no host)", vcov = v, estimate = est, se = se, df = df,
               p2 = 2 * pt(abs(est / se), df, lower.tail = FALSE), p1 = pt(est / se, df, lower.tail = FALSE),
               ci_low = est - qt(0.975, df) * se, ci_high = est + qt(0.975, df) * se)
  }))
  list(models = m, coefs = rbind(out, bd), nobs = c(H1 = nobs(m$H1), H2 = nobs(m$H2), H3 = nobs(m$H3)))
}

#' Permutation test over domains: the score rows (local_embeddedness and coord_dependence
#' together) are reassigned across the 98 domains and the model is re-estimated.
#' One-sided p-value for a positive coefficient: (1 + #{b* >= b0}) / (B + 1).
perm_domain <- function(fml, data, dom, var, B = 99L) {
  sc <- c("local_embeddedness", "coord_dependence")
  fit <- function(d) suppressMessages(suppressWarnings(coef(fepois(fml, data = d))))[[var]]
  b0 <- fit(data)
  base <- copy(data)[, (sc) := NULL]
  bs <- vapply(seq_len(B), function(i) {
    s <- copy(dom[, c("domain", sc), with = FALSE]); ix <- sample(nrow(s))
    for (v in sc) set(s, j = v, value = dom[[v]][ix])
    fit(base[s, on = "domain", nomatch = NULL])
  }, numeric(1))
  c(estimate = b0, p1_perm = (1 + sum(bs >= b0)) / (B + 1), p2_perm = (1 + sum(abs(bs) >= abs(b0))) / (B + 1))
}

#' Cluster score bootstrap with the null imposed for one coefficient of a Poisson model with
#' high-dimensional fixed effects (the Poisson counterpart of the restricted wild cluster
#' bootstrap). Restricted fit without `term`; the term is residualized on the fixed effects and
#' the other regressors with weights mu0; the cluster sums of x_tilde (y - mu0) are sign-flipped
#' (Rademacher weights). Returns one- and two-sided p-values of the score statistic.
score_boot <- function(data, y, term, others, fe, offset, cluster, B = 499L) {
  rhs0 <- if (length(others)) paste(others, collapse = " + ") else "1"
  f0 <- as.formula(sprintf("%s ~ %s + offset(log(%s)) | %s", y, rhs0, offset, fe))
  m0 <- suppressMessages(suppressWarnings(fepois(f0, data = data)))
  keep <- obs(m0)
  d <- data[keep]; mu0 <- fitted(m0)
  fe_vars <- strsplit(gsub(" ", "", fe), "\\+")[[1]]
  fdf <- as.data.frame(lapply(fe_vars, function(f) { parts <- strsplit(f, "\\^")[[1]]; do.call(paste, c(d[, parts, with = FALSE], sep = "_")) }))
  X <- as.matrix(d[, c(term, others), with = FALSE])
  Xd <- fixest::demean(X, f = fdf, weights = mu0)
  xt <- if (length(others)) { o <- Xd[, -1, drop = FALSE]; Xd[, 1] - o %*% solve(crossprod(o * mu0, o), crossprod(o * mu0, Xd[, 1])) } else Xd[, 1]
  s <- as.numeric(xt) * (d[[y]] - mu0)
  S <- tapply(s, d[[cluster]], sum)
  S <- S[S != 0]
  T0 <- sum(S) / sqrt(sum(S^2))
  W <- matrix(sample(c(-1, 1), length(S) * B, replace = TRUE), nrow = B)
  Tb <- as.numeric(W %*% S) / sqrt(sum(S^2))
  c(T = T0, p1_boot = (1 + sum(Tb >= T0)) / (B + 1), p2_boot = (1 + sum(abs(Tb) >= abs(T0))) / (B + 1), clusters = length(S))
}

#' H4 for S13: exposed x post x REG on the local share (triple difference), anticipation window
#' entered separately, IJV x domain, domain x year and IJV x year fixed effects.
H4_FE <- "ijv_id^domain + domain^year + ijv_id^year"
fit_h4 <- function(p, B = 499L, event_study = TRUE, h4b = TRUE) {
  q <- function(x) suppressMessages(suppressWarnings(x))
  d <- p[n_obs > 0]
  m <- q(fepois(as.formula(paste("n_local ~ exp_post_reg + exp_antic_reg + offset(log(n_obs)) |", H4_FE)), d))
  out <- coef_inf(m, "exp_post_reg", list(pair = ~dyad, ijv = ~ijv_id))
  sb <- score_boot(d, "n_local", "exp_post_reg", "exp_antic_reg", H4_FE, "n_obs", "dyad", B = B)
  out[vcov == "pair", `:=`(p1_boot = sb[["p1_boot"]], p2_boot = sb[["p2_boot"]])]
  # H4b (directional, PI 2026-11-25), IJVs with a host-country parent: (i) independent local hires
  # (offset log n_obs) carry the rise, one-sided > 0; (ii) composition: local parent-origin share
  # among local hires (offset log n_local), two-sided, must not be significantly positive. The
  # composition model uses domain x year and IJV x year effects with exposed x REG as a regressor:
  # with IJV x domain effects it separates, because local parent-origin hires in REG cells are rare.
  if (h4b) {
  dh <- d[host_parent == 1L]
  mi <- q(fepois(as.formula(paste("n_local_indep ~ exp_post_reg + exp_antic_reg + offset(log(n_obs)) |", H4_FE)), dh))
  oi <- coef_inf(mi, "exp_post_reg", list(pair = ~dyad))
  bi <- score_boot(dh, "n_local_indep", "exp_post_reg", "exp_antic_reg", H4_FE, "n_obs", "dyad", B = B)
  oi[, `:=`(term = "H4b_indep", p1_boot = bi[["p1_boot"]], p2_boot = bi[["p2_boot"]])]
  dl <- dh[n_local > 0]
  ml <- tryCatch(q(fepois(n_local_parent ~ exp_post_reg + exp_antic_reg + treat_reg + offset(log(n_local)) | domain^year + ijv_id^year, dl)), error = function(e) NULL)
  if (!is.null(ml) && "exp_post_reg" %in% names(coef(ml))) {
    ol <- coef_inf(ml, "exp_post_reg", list(pair = ~dyad))
    bl <- tryCatch(score_boot(dl, "n_local_parent", "exp_post_reg", c("exp_antic_reg", "treat_reg"), "domain^year + ijv_id^year", "n_local", "dyad", B = B),
                   error = function(e) c(p1_boot = NA, p2_boot = NA))
    ol[, `:=`(term = "H4b_parent_share", p1_boot = bl[["p1_boot"]], p2_boot = bl[["p2_boot"]])]
  } else ol <- data.table(term = "H4b_parent_share", vcov = "pair", estimate = NA_real_)
  out <- rbind(out, oi, ol, fill = TRUE)
  }
  res <- list(coefs = out, nobs = nobs(m),
              reg_cells_exposed = d[reg == 1L & exposed == 1L, .(pre = sum(year <= 2015), antic = sum(antic_yr == 1L), post = sum(post == 1L), ijv = uniqueN(ijv_id), pairs = uniqueN(dyad))],
              pairs_with_exposed_reg = d[reg == 1L & exposed == 1L & post == 1L, uniqueN(dyad)])
  if (event_study) {
    es <- q(fepois(as.formula(paste("n_local ~ i(year, treat_reg, ref = 2013:2015) + offset(log(n_obs)) |", H4_FE)), d, vcov = ~dyad))
    w <- tryCatch(wald(es, keep = "^year::201[0-2]:", print = FALSE), error = function(e) NULL)
    res$pretest_p <- if (is.null(w)) NA_real_ else w$p
  }
  res
}
