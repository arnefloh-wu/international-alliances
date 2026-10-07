# 00_setup.R
# Project setup: packages, paths, options. Every other script starts with
# source("code/R/00_setup.R"). Run from the repository root.
#
# Core packages are required; optional packages (arrow, fixest, did,
# modelsummary, quarto) are loaded when installed. renv::init() is optional.

# Core packages: needed by every script (matching, measures, panel build).
core_pkgs <- c("data.table", "stringdist", "stringi", "lubridate", "ggplot2", "knitr")
# Optional packages: needed for parquet files (arrow), estimation (fixest,
# did, modelsummary) and rendering (quarto). Scripts that need them check
# with require_pkgs() at the top.
optional_pkgs <- c("arrow", "fixest", "did", "modelsummary", "quarto")

try_install <- function(p) {
  tryCatch(install.packages(p, quiet = TRUE),
           error = function(e) NULL, warning = function(w) NULL)
}
missing_core <- core_pkgs[!vapply(core_pkgs, requireNamespace, logical(1), quietly = TRUE)]
for (p in missing_core) try_install(p)
still_missing <- core_pkgs[!vapply(core_pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(still_missing) > 0)
  stop("Core packages missing and not installable: ", paste(still_missing, collapse = ", "))
invisible(lapply(core_pkgs, library, character.only = TRUE))

available_optional <- optional_pkgs[vapply(optional_pkgs, requireNamespace, logical(1), quietly = TRUE)]
invisible(lapply(available_optional, library, character.only = TRUE))
if (length(setdiff(optional_pkgs, available_optional)) > 0)
  message("Optional packages not installed: ",
          paste(setdiff(optional_pkgs, available_optional), collapse = ", "),
          ". Estimation, parquet I/O or rendering steps that need them will stop with a message.")

#' Stop with a clear message if a script's required packages are missing.
require_pkgs <- function(pkgs) {
  miss <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(miss) > 0)
    stop("This step needs R packages that are not installed: ", paste(miss, collapse = ", "),
         ". Install them from CRAN (in the cloud environment, allow cloud.r-project.org).", call. = FALSE)
}

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
