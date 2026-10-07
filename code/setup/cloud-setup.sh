#!/usr/bin/env bash
# Setup script for the Claude Code cloud environment (paste into the
# environment settings: cloud environment menu > Edit > Setup script).
# Installs R and the project's R packages. Ubuntu's apt repository supplies
# most packages; the rest come from CRAN, which works only if
# cloud.r-project.org is allowed under Network access.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -q
apt-get install -y -q --no-install-recommends \
  r-base-core r-base-dev \
  r-cran-data.table r-cran-stringdist r-cran-stringi r-cran-lubridate \
  r-cran-ggplot2 r-cran-knitr r-cran-rmarkdown r-cran-renv r-cran-jsonlite \
  r-cran-httr2 r-cran-rcpp r-cran-sandwich r-cran-formula r-cran-numderiv \
  r-cran-nlme r-cran-remotes
# CRAN-only packages (estimation, parquet, rendering). Skipped quietly if CRAN is blocked.
if curl -s -o /dev/null -m 10 https://cloud.r-project.org/; then
  Rscript -e 'install.packages(c("fixest","did","didimputation","modelsummary","arrow","quarto"), repos = "https://cloud.r-project.org", Ncpus = 4)'
else
  echo "CRAN not reachable: fixest, did, didimputation, modelsummary, arrow, quarto not installed."
fi
