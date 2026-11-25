# 16_wrds_ciq_parent_industry.R
# WRDS pull of Capital IQ industry codes for the IJV parents that come from
# Capital IQ (parent_bvdid starting with "CIQ"; no BvD id, so not in the Orbis
# tables of 15_wrds_parent_industry.R). Resource-dependence check, robustness 19
# of the pre-analysis plan; PI in chat on 2026-11-25: "Pull Capital IQ too".
#   tree     ciq_common.ciqcompanyindustrytree for the parents (all rows, with the
#            primary flag), joined to ciq_common.ciqsubtype for the industry name
#            and its place in the Capital IQ industry tree
#   maps     ciq_common.ciqsubtype (the whole industry tree) and
#            ciq_common.ciqindustrytosic (Capital IQ industry to SIC), both small
#            reference tables, pulled whole
# ciq.wrds_entity_info (sic, naics) is not used: it reads from the ciq_ratings
# schema, which the WRDS subscription does not cover (permission denied,
# 2026-11-25).
# Nothing else is pulled: no names, descriptions of people, financials or
# staffing data. The log reports pooled counts only.
#
# Credentials: WRDS_USERNAME and WRDS_PASSWORD in ~/.Renviron.
# Run: "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/16_wrds_ciq_parent_industry.R
# Outputs (gitignored, licensed data):
#   data/raw/ciq-parent-industry-tree-2026-11-25.parquet
#   data/raw/ciq-industry-subtype-2026-11-25.parquet
#   data/raw/ciq-industry-to-sic-2026-11-25.parquet
#   data/interim/wrds-parent-industry-log-2026-11-25.md (appended)

source("code/R/00_setup.R")
require_pkgs(c("arrow", "DBI", "RPostgres"))
RUN <- "v3-2026-10-09"
PULL_DATE <- "2026-11-25"
CHUNK <- 2000L
f_par  <- file.path(paths$processed, sprintf("ijv-parents-%s.csv", RUN))
f_tree <- file.path(paths$raw, sprintf("ciq-parent-industry-tree-%s.parquet", PULL_DATE))
f_sub  <- file.path(paths$raw, sprintf("ciq-industry-subtype-%s.parquet", PULL_DATE))
f_sic  <- file.path(paths$raw, sprintf("ciq-industry-to-sic-%s.parquet", PULL_DATE))
f_log  <- file.path(paths$interim, sprintf("wrds-parent-industry-log-%s.md", PULL_DATE))
log_line <- function(...) {
  msg <- sprintf(...)
  message(format(Sys.time(), "%H:%M:%S"), " ", msg)
  cat("- ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " ciq ", msg, "\n", file = f_log, append = TRUE, sep = "")
}

par <- fread(f_par, colClasses = list(character = "parent_bvdid"), na.strings = "", select = "parent_bvdid")
ids <- sort(unique(as.numeric(sub("^CIQ", "", par$parent_bvdid[startsWith(par$parent_bvdid, "CIQ")]))))
stopifnot(!anyNA(ids))
log_line("Capital IQ parents: %d company ids", length(ids))

con <- DBI::dbConnect(RPostgres::Postgres(), host = "wrds-pgdata.wharton.upenn.edu", port = 9737,
                      dbname = "wrds", sslmode = "require",
                      user = Sys.getenv("WRDS_USERNAME"), password = Sys.getenv("WRDS_PASSWORD"))
on.exit(DBI::dbDisconnect(con), add = TRUE)
q <- function(sql) as.data.table(DBI::dbGetQuery(con, sql))
by_ids <- function(tmpl) rbindlist(lapply(split(ids, ceiling(seq_along(ids) / CHUNK)), function(b)
  q(sprintf(tmpl, paste(sprintf("%.0f", b), collapse = ",")))), fill = TRUE)

if (!file.exists(f_tree)) {
  d <- by_ids("SELECT t.companyid, t.companyindustryid, t.subtypeid, t.primaryflag, t.chartypeid
               FROM ciq_common.ciqcompanyindustrytree t WHERE t.companyid IN (%s)")
  arrow::write_parquet(d, f_tree)
  log_line("tree: %d rows for %d of %d companies; rows with primaryflag = 1: %d (%d companies); chartypeid values: %s",
           nrow(d), uniqueN(d$companyid), length(ids), sum(d$primaryflag == 1, na.rm = TRUE),
           uniqueN(d[primaryflag == 1, companyid]), paste(sort(unique(d$chartypeid)), collapse = ", "))
}
if (!file.exists(f_sub)) {
  d <- q("SELECT subtypeid, subtypevalue, childlevel, leafflag, subparentid FROM ciq_common.ciqsubtype")
  arrow::write_parquet(d, f_sub)
  log_line("subtype tree: %d rows", nrow(d))
}
if (!file.exists(f_sic)) {
  d <- q("SELECT subtypeid, siccode FROM ciq_common.ciqindustrytosic")
  arrow::write_parquet(d, f_sic)
  log_line("industry to SIC: %d rows, %d Capital IQ industries, %d SIC codes", nrow(d), uniqueN(d$subtypeid), uniqueN(d$siccode))
}
