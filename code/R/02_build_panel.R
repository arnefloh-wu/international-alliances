# 02_build_panel.R
# Stage 6: construct IJV-function-year and IJV-level-year panels from the
# full exports, following reviews/gate-5-pre-analysis-plan.md.
# Skeleton: the data-engineer agent completes it once G5 is approved and the
# full exports exist. Structure mirrors 01_pilot_matching.R, adding:
#   - full-population matching with PI-reviewed match decisions merged in
#   - function and seniority mapping tables (data/function-map.csv,
#     data/level-map.csv) documented in data/codebook.md
#   - sample-construction log with counts at each exclusion
#   - controls merge (Orbis financials, dyad data, host-country indicators)
#   - output: data/processed/panel-ijv-function-year.parquet,
#             data/processed/panel-ijv-level-year.parquet

source("code/R/00_setup.R")
stop("02_build_panel.R is a skeleton until gate 5 is approved; see docs/workflow.md")
