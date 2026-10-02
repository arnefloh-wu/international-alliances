# 05_robustness.R
# Stage 7: robustness set in the order fixed by the quant-analyst brief.
# Skeleton: completed once gate 6 is approved.

source("code/R/00_setup.R")
pf <- as.data.table(read_parquet(file.path(paths$processed, "panel-ijv-function-year.parquet")))
pf <- pf[n_emp >= const$min_cell_emp]
ctrl <- c("ijv_age", "ijv_size_log", "equity_balance")

# 1. Event study with leads and lags; never-exposed cells as reference.
pf[, event_time_c := fifelse(is.na(event_time), -1000, event_time)]
m_es <- feols(localization ~ i(event_time_c, local_embeddedness, ref = c(-1, -1000)) + .[ctrl] |
                ijv_id^function + year, data = pf, cluster = ~ijv_id)
png(file.path(paths$figures, "fig-event-study.png"), width = 1600, height = 1000, res = 200)
iplot(m_es, main = "Localization response by local embeddedness, event time", xlab = "Years relative to shock")
dev.off()

# 2. Staggered-treatment estimators.
m_sunab <- feols(localization ~ sunab(first_shock_year, year) + .[ctrl] |
                   ijv_id^function + year, data = pf, cluster = ~ijv_id)
# did::att_gt on the IJV level (cells aggregated) with not-yet-treated controls:
# cs <- att_gt(yname = "localization", tname = "year", idname = "cell_id",
#              gname = "first_shock_year", data = pf, control_group = "notyettreated")

# 3. Fractional response for share outcomes.
m_frac <- feglm(localization ~ shock:local_embeddedness + shock:coord_dependence + .[ctrl] |
                  ijv_id^function + year, data = pf, family = binomial("logit"), cluster = ~ijv_id)

# 4. Cell-size thresholds.
m_thr <- lapply(c(3, 10), function(k) {
  d <- as.data.table(read_parquet(file.path(paths$processed, "panel-ijv-function-year.parquet")))[n_emp >= k]
  feols(localization ~ shock:local_embeddedness + shock:coord_dependence + .[ctrl] |
          ijv_id^function + year, data = d, cluster = ~ijv_id)
})

# 5. Alternative function classification, 6. placebo shocks, 7. ownership-
#    adjusted dominance: added by the quant-analyst agent per the plan.

modelsummary(list("Event study" = m_es, "Sun-Abraham" = m_sunab, "Fractional logit" = m_frac,
                  "Threshold 3" = m_thr[[1]], "Threshold 10" = m_thr[[2]]),
             output = file.path(paths$tables, "tab-robustness.docx"),
             estimate = "{estimate} [{conf.low}, {conf.high}]", statistic = NULL)
