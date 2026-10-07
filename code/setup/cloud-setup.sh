#!/usr/bin/env bash
# Setup script for the Claude Code cloud environment (paste into the
# environment settings: cloud environment menu > Edit > Setup script).
# Installs R and the project's R packages (arrow excluded, see below). Ubuntu's apt repository supplies
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
# CRAN-only packages (estimation and rendering), installed one at a time so a
# failure cannot block the others, each with a 15-minute limit. arrow is left
# out: its source build stalled the setup script on 2026-10-07. Export the
# Revelio data as CSV instead of parquet.
if curl -s -o /dev/null -m 10 https://cloud.r-project.org/; then
  for p in fixest did didimputation modelsummary quarto; do
    timeout 900 Rscript -e "install.packages('$p', repos = 'https://cloud.r-project.org', Ncpus = 4); if (!requireNamespace('$p', quietly = TRUE)) quit(status = 1)" \
      || echo "install failed or timed out: $p"
  done
else
  echo "CRAN not reachable: fixest, did, didimputation, modelsummary, quarto not installed."
fi
