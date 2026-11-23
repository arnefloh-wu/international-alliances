# synthetic_panel.R
# Writes one simulated draw of the IJV x function x year and IJV x level x
# year panels to data/synthetic/, with the planted effects and the score
# tables (generator: code/R/functions/simulate_panel.R). The analysis script
# code/R/04_estimate.R synthetic reads these files. Simulated, never derived
# from real rows; every row carries synthetic = TRUE.
#
# Run from the repository root (a few seconds, no data needed):
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/tests/synthetic_panel.R
# Outputs (tracked in Git):
#   data/synthetic/panel-ijv-function-year-synthetic-2026-11-23.parquet
#   data/synthetic/panel-ijv-level-year-synthetic-2026-11-23.parquet
#   data/synthetic/panel-scores-function-synthetic-2026-11-23.csv, panel-scores-level-synthetic-2026-11-23.csv
#   data/synthetic/panel-planted-effects-synthetic-2026-11-23.csv

source("code/R/00_setup.R")
source("code/R/functions/simulate_panel.R")
require_pkgs("arrow")
SYN_DATE <- "2026-11-23"
f_syn <- function(name, ext = "parquet") file.path("data/synthetic", sprintf("%s-synthetic-%s.%s", name, SYN_DATE, ext))
dir.create("data/synthetic", showWarnings = FALSE)

s <- simulate_panel(n_ijv = 600L, seed = 20261123L)
stopifnot(all(s$pf$synthetic), all(s$pl$synthetic), !"function" %in% names(s$pf))
arrow::write_parquet(s$pf, f_syn("panel-ijv-function-year"))
arrow::write_parquet(s$pl, f_syn("panel-ijv-level-year"))
fwrite(s$scores$fn, f_syn("panel-scores-function", "csv"))
fwrite(s$scores$level, f_syn("panel-scores-level", "csv"))
fwrite(s$planted, f_syn("panel-planted-effects", "csv"))
message(sprintf("function panel: %d cells, %d IJVs, %d years; level panel: %d cells; exposed pairs: %d of %d; exposed IJVs: %d",
                nrow(s$pf), uniqueN(s$pf$ijv_id), uniqueN(s$pf$year), nrow(s$pl),
                s$ijv[!is.na(first_shock_year), uniqueN(dyad)], uniqueN(s$ijv$dyad), s$ijv[!is.na(first_shock_year), .N]))
message(sprintf("hires %d; observed %.1f%%; local among observed %.1f%%; parent-origin among observed %.1f%%; cells with a local parent-origin hire among cells with local hires %.1f%%",
                sum(s$pf$n_hires), 100 * sum(s$pf$n_obs) / sum(s$pf$n_hires), 100 * sum(s$pf$n_local) / sum(s$pf$n_obs),
                100 * sum(s$pf$n_parent) / sum(s$pf$n_obs), 100 * s$pf[n_local > 0, mean(n_local_parent > 0)]))
