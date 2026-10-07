# 04_estimate.R
# Stage 7: baseline models. Specifications follow research idea section 10
# and the approved pre-analysis plan. Variable names follow data/codebook.md.
# Skeleton: the quant-analyst agent completes it once gate 6 is approved.

source("code/R/00_setup.R")
require_pkgs(c("arrow", "fixest", "modelsummary"))
pf <- as.data.table(read_parquet(file.path(paths$processed, "panel-ijv-function-year.parquet")))
pl <- as.data.table(read_parquet(file.path(paths$processed, "panel-ijv-level-year.parquet")))
pf <- pf[n_emp >= const$min_cell_emp]
pl <- pl[n_emp >= const$min_cell_emp]

ctrl <- c("ijv_age", "ijv_size_log", "equity_balance", "parent_a_size_log", "parent_b_size_log")

# H1, H2: cross-sectional differentiation across functions, within IJV-year.
m_h1 <- feols(cross_parent_integration ~ coord_dependence + local_embeddedness + .[ctrl] |
                ijv_id^year, data = pf, cluster = ~ijv_id)
m_h2 <- feols(localization ~ coord_dependence + local_embeddedness + .[ctrl] |
                ijv_id^year, data = pf, cluster = ~ijv_id)

# H3: hierarchy.
m_h3 <- feols(cross_parent_integration ~ i(level, ref = "operational") + .[ctrl] |
                ijv_id^year, data = pl, cluster = ~ijv_id)

# H4, H5: shock x domain characteristic, cell fixed effects absorb levels.
m_h4 <- feols(localization ~ shock:local_embeddedness + shock:coord_dependence + .[ctrl] |
                ijv_id^function + year, data = pf, cluster = ~ijv_id)
m_h5 <- feols(cross_parent_integration ~ shock:coord_role + .[ctrl] |
                ijv_id^level + year, data = pl, cluster = ~ijv_id)

models <- list("H1/H2 integration" = m_h1, "H2 localization" = m_h2,
               "H3 hierarchy" = m_h3, "H4 shock x function" = m_h4,
               "H5 shock x level" = m_h5)
modelsummary(models,
             output = file.path(paths$tables, "tab-baseline.docx"),
             estimate = "{estimate} [{conf.low}, {conf.high}]",
             statistic = NULL, gof_map = c("nobs", "r2.within"),
             notes = "OLS with fixed effects as indicated; 95% confidence intervals in brackets; standard errors clustered by IJV.")
modelsummary(models, output = file.path(paths$tables, "tab-baseline.tex"))
saveRDS(models, file.path(paths$interim, "models-baseline.rds"))
