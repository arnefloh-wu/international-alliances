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
# CRAN-only packages (estimation and rendering). Tested in a cloud session on
# 2026-10-07:
# - Ubuntu's Rcpp (1.0.12) is too old to compile fastglm, which did needs, so a
#   current Rcpp is installed from CRAN first.
# - did is installed last with a single compile job; its dependencies fastglm
#   and DRDID took about 10 minutes and peaked at about 4 GB of memory.
# - arrow is left out (its source build stalled); export Revelio data as CSV.
# Each install has a time limit and reports failure without stopping the rest.
# Expect this block to add roughly 20 minutes to the start of a new session.
CRAN=https://cloud.r-project.org
install_cran() {  # $1 package, $2 timeout in seconds, $3 parallel jobs
  MAKEFLAGS="-j$3" timeout "$2" Rscript -e "install.packages('$1', repos = '$CRAN', Ncpus = $3); if (!requireNamespace('$1', quietly = TRUE)) quit(status = 1)" \
    || echo "install failed or timed out: $1"
}
if curl -s -o /dev/null -m 10 "$CRAN/"; then
  install_cran Rcpp 600 4
  for p in fixest didimputation modelsummary quarto; do
    install_cran "$p" 900 4
  done
  install_cran did 1800 1
else
  echo "CRAN not reachable: fixest, did, didimputation, modelsummary, quarto not installed."
fi
