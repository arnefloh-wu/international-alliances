# 00_setup.R
# Project setup: packages, paths, options. Every other script starts with
# source("code/R/00_setup.R"). Run from the repository root.
#
# Not executed in the cloud session that wrote it (no R installed there).
# First local run: renv::init() is optional; the package list is below.

pkgs <- c(
  "data.table", "arrow", "stringdist", "stringi", "lubridate",
  "fixest", "did", "modelsummary", "ggplot2", "knitr", "quarto"
)
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) {
  message("Installing: ", paste(missing, collapse = ", "))
  install.packages(missing)
}
invisible(lapply(pkgs, library, character.only = TRUE))

# Paths. IA_DATA_DIR may point to the Dropbox mirror; default is data/.
data_dir <- Sys.getenv("IA_DATA_DIR", unset = "data")
paths <- list(
  raw        = file.path(data_dir, "raw"),
  interim    = file.path(data_dir, "interim"),
  processed  = file.path(data_dir, "processed"),
  interviews = file.path(data_dir, "interviews"),
  tables     = "manuscript/tables",
  figures    = "manuscript/figures"
)
for (p in paths) dir.create(p, showWarnings = FALSE, recursive = TRUE)

# Analysis constants (mirrored in reviews/gate-5-pre-analysis-plan.md).
const <- list(
  min_cell_emp    = 5L,     # baseline cell-size threshold (robustness: 3, 10)
  min_ijv_emp     = 20L,    # minimum observable employees per IJV
  min_years       = 3L,     # minimum operating years
  origin_window   = 3L,     # years back in which a parent employer counts as origin
  reference_date  = "06-30",# cell membership: position overlaps 30 June
  jw_threshold    = 0.92    # Jaro-Winkler similarity for fuzzy matching
)

source("code/R/functions/measures.R")
source("code/R/functions/matching.R")
options(scipen = 999)
setDTthreads(0)
message("Setup complete. Data dir: ", data_dir)
