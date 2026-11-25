# 15_wrds_parent_industry.R
# WRDS pull of Orbis industry codes for the IJV parents and their ultimate
# owners, for the resource-dependence check (robustness 19 of the pre-analysis
# plan; definition and PI go-ahead for the pull in chat on 2026-11-25, recorded in
# docs/decisions.md).
#   pull     ob_industry_classifications_{l,m,s}: bvdid, NACE section, primary
#            NACE Rev. 2 code, primary NAICS 2017 code, for every direct parent
#            in ijv-parents-<RUN>.csv and every ultimate owner (parent_guo).
#            All rows are kept untouched in data/raw/.
#   resolve  one row per parent with the NAICS code the check uses
#            (code/R/functions/parent_industry.R): the parent's own primary
#            NAICS code, or the ultimate owner's for a holding parent (NAICS 5511
#            or NACE 6420); flags for missing codes, unresolved holdings, several
#            rows and conflicting rows.
# Nothing else is pulled: no names, descriptions, financials or staffing data.
# Nothing is tabulated by exposure, function or occupation; the log reports
# pooled counts only.
#
# Credentials: WRDS_USERNAME and WRDS_PASSWORD in ~/.Renviron.
# Run from the repository root after 09_build_matched_dataset.R:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/15_wrds_parent_industry.R [pull] [resolve]
# With no step named, all three run (pull, secondary, resolve); resolve runs
# 16_wrds_ciq_parent_industry.R first if its files are missing. Tested on simulated data by
# code/R/tests/synthetic_parent_industry.R.
# Outputs (gitignored, licensed data):
#   data/raw/orbis-parent-industry-2026-11-25.parquet
#   data/raw/orbis-parent-industry-core-secondary-2026-11-25.parquet (step "secondary")
#   data/interim/parent-industry-v2-2026-11-25.csv (v1 from the first run kept)
#   data/interim/wrds-parent-industry-log-2026-11-25.md

source("code/R/00_setup.R")
require_pkgs(c("arrow", "DBI", "RPostgres"))
source("code/R/functions/parent_industry.R")
RUN <- "v3-2026-10-09"
PULL_DATE <- "2026-11-25"
args <- commandArgs(trailingOnly = TRUE)
STEPS <- intersect(args, c("pull", "resolve", "secondary")); if (!length(STEPS)) STEPS <- c("pull", "secondary", "resolve")
CHUNK <- 2000L
LIBS <- list(c("bvd_orbis_large", "l"), c("bvd_orbis_medium", "m"), c("bvd_orbis_small", "s"))
f_par <- file.path(paths$processed, sprintf("ijv-parents-%s.csv", RUN))
f_raw <- file.path(paths$raw, sprintf("orbis-parent-industry-%s.parquet", PULL_DATE))
f_raw2 <- file.path(paths$raw, sprintf("orbis-parent-industry-core-secondary-%s.parquet", PULL_DATE))
f_out <- file.path(paths$interim, sprintf("parent-industry-v2-%s.csv", PULL_DATE))   # v1 (primary codes only) was written by the first run
f_log <- file.path(paths$interim, sprintf("wrds-parent-industry-log-%s.md", PULL_DATE))
if (!file.exists(f_log)) cat("# WRDS pull log: Orbis industry codes of IJV parents, ", PULL_DATE, "\n\n", file = f_log, sep = "")
log_line <- function(...) {
  msg <- sprintf(...)
  message(format(Sys.time(), "%H:%M:%S"), " ", msg)
  cat("- ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " ", msg, "\n", file = f_log, append = TRUE, sep = "")
}
par <- fread(f_par, colClasses = list(character = c("jv_bvdid", "parent_bvdid", "parent_guo")), na.strings = "",
             select = c("jv_bvdid", "parent_bvdid", "parent_guo"))

# ---- Pull ---------------------------------------------------------------------------
if ("pull" %in% STEPS) {
  if (file.exists(f_raw)) {
    log_line("pull: %s exists, not pulled again", basename(f_raw))
  } else {
    ids <- sort(unique(c(par$parent_bvdid, par$parent_guo)))
    ids <- ids[!is.na(ids) & ids != ""]
    log_line("pull: %d ids (%d direct parents, %d ultimate owners) in blocks of %d, libraries %s",
             length(ids), uniqueN(par$parent_bvdid), uniqueN(na.omit(par$parent_guo)), CHUNK,
             paste(vapply(LIBS, `[`, "", 1), collapse = ", "))
    con <- DBI::dbConnect(RPostgres::Postgres(), host = "wrds-pgdata.wharton.upenn.edu", port = 9737,
                          dbname = "wrds", sslmode = "require",
                          user = Sys.getenv("WRDS_USERNAME"), password = Sys.getenv("WRDS_PASSWORD"))
    on.exit(DBI::dbDisconnect(con), add = TRUE)
    blocks <- split(ids, ceiling(seq_along(ids) / CHUNK))
    t0 <- Sys.time()
    out <- rbindlist(lapply(LIBS, function(L) {
      r <- rbindlist(lapply(blocks, function(b) as.data.table(DBI::dbGetQuery(con, sprintf(
        "SELECT bvdid, nace2_main_section, nacepcod2, naicspcod2017 FROM %s.ob_industry_classifications_%s WHERE bvdid IN (%s)",
        L[1], L[2], paste(sprintf("'%s'", gsub("'", "''", b)), collapse = ","))))), fill = TRUE)
      if (nrow(r)) r[, orbis_lib := L[2]]
      log_line("pull: %s: %d rows for %d ids", L[1], nrow(r), uniqueN(r$bvdid))
      r
    }), fill = TRUE)
    arrow::write_parquet(out, f_raw)
    log_line("pull: %d rows for %d of %d ids written to %s, %.0fs", nrow(out), uniqueN(out$bvdid), length(ids),
             basename(f_raw), as.numeric(Sys.time() - t0, units = "secs"))
  }
}

# ---- Core and secondary codes (step "secondary", run on its own) ----------------------
# Added on 2026-11-25 after the first pull, to maximize coverage (PI: "try to
# maximise the sample"): Orbis core codes (naicsccod2017, naceccod2) and
# secondary codes (naicsscod2017, nacescod2) for the same ids, from the three
# current libraries and, where readable, the three "_old" libraries.
if ("secondary" %in% STEPS && !file.exists(f_raw2)) {
  ids <- sort(unique(c(par$parent_bvdid, par$parent_guo)))
  ids <- ids[!is.na(ids) & ids != "" & !startsWith(ids, "CIQ")]
  con <- DBI::dbConnect(RPostgres::Postgres(), host = "wrds-pgdata.wharton.upenn.edu", port = 9737,
                        dbname = "wrds", sslmode = "require",
                        user = Sys.getenv("WRDS_USERNAME"), password = Sys.getenv("WRDS_PASSWORD"))
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  blocks <- split(ids, ceiling(seq_along(ids) / CHUNK))
  libs2 <- c(LIBS, list(c("bvd_orbis_large_old", "l"), c("bvd_orbis_medium_old", "m"), c("bvd_orbis_small_old", "s")))
  out <- rbindlist(lapply(libs2, function(L) {
    r <- tryCatch(rbindlist(lapply(blocks, function(b) as.data.table(DBI::dbGetQuery(con, sprintf(
      "SELECT bvdid, nace2_main_section, nacepcod2, naceccod2, nacescod2, naicspcod2017, naicsccod2017, naicsscod2017
       FROM %s.ob_industry_classifications_%s WHERE bvdid IN (%s)",
      L[1], L[2], paste(sprintf("'%s'", gsub("'", "''", b)), collapse = ","))))), fill = TRUE),
      error = function(e) { log_line("secondary: %s not readable: %s", L[1], substr(conditionMessage(e), 1, 100)); NULL })
    if (is.null(r) || !nrow(r)) return(NULL)
    r[, `:=`(orbis_lib = L[2], orbis_library = L[1])]
    log_line("secondary: %s: %d rows for %d ids", L[1], nrow(r), uniqueN(r$bvdid))
    r
  }), fill = TRUE)
  arrow::write_parquet(out, f_raw2)
  log_line("secondary: %d rows for %d of %d ids written to %s", nrow(out), uniqueN(out$bvdid), length(ids), basename(f_raw2))
}

# ---- Resolve and check (pooled counts only) -------------------------------------------
# Rule v2 (2026-11-25, PI: "try to maximise the sample"): own primary, core and
# secondary NAICS codes, then the ultimate owner's, then for Capital IQ parents the
# Capital IQ industry tree through SIC to NAICS 2017 (16_wrds_ciq_parent_industry.R
# and the Census concordances); see code/R/functions/parent_industry.R.
if ("resolve" %in% STEPS) {
  require_pkgs("readxl")
  check <- function(cond, msg) { log_line("%s %s", if (isTRUE(cond)) "OK  " else "FAIL", msg); invisible(isTRUE(cond)) }
  pct <- function(x) sprintf("%d (%.1f%%)", sum(x), 100 * mean(x))
  if (!file.exists(file.path(paths$raw, sprintf("ciq-parent-industry-tree-%s.parquet", PULL_DATE))))
    source("code/R/wrds/16_wrds_ciq_parent_industry.R")   # the Capital IQ codes, if not yet pulled
  cw <- read_concordances(file.path(paths$raw, "external", "census-naics-concordances-2026-11-25"))
  ind <- as.data.table(arrow::read_parquet(f_raw2))
  ciq <- ciq_parent_naics(arrow::read_parquet(file.path(paths$raw, sprintf("ciq-parent-industry-tree-%s.parquet", PULL_DATE))),
                          as.data.table(arrow::read_parquet(file.path(paths$raw, sprintf("ciq-industry-subtype-%s.parquet", PULL_DATE)))),
                          as.data.table(arrow::read_parquet(file.path(paths$raw, sprintf("ciq-industry-to-sic-%s.parquet", PULL_DATE)))), cw)
  pp <- unique(par[, .(parent_bvdid, parent_guo)])
  n_guo_conflict <- pp[, uniqueN(parent_guo), by = parent_bvdid][V1 > 1, .N]
  check(n_guo_conflict == 0, sprintf("one ultimate owner per parent (%d parents with more than one)", n_guo_conflict))
  if (n_guo_conflict > 0) pp <- unique(pp[order(parent_bvdid, parent_guo)], by = "parent_bvdid")
  r <- resolve_parent_industry(pp, pick_industry(ind), cw, ciq)
  check(nrow(r) == uniqueN(par$parent_bvdid) && !anyDuplicated(r$parent_bvdid), sprintf("one row per parent (%d)", nrow(r)))
  check(!any(startsWith(na.omit(r$rd_naics), "5511")), "no holding code used as rd_naics")
  check(all(nchar(na.omit(r$rd_naics4)) == 4L), "rd_naics4 has four digits where set")
  n <- nrow(r); is_ciq <- startsWith(r$parent_bvdid, "CIQ")
  log_line("v2: parents %d (Orbis %d, Capital IQ %d); holding parents (NAICS 5511, NACE 64.2 or 70.1): %s",
           n, sum(!is_ciq), sum(is_ciq), pct(r$holding))
  src <- r[, .N, by = rd_naics_source][order(-N)]
  log_line("v2: code source: %s", paste(sprintf("%s %d", src$rd_naics_source, src$N), collapse = "; "))
  log_line("v2: Capital IQ parents: primary industry %d, SIC reached %d, NAICS 2017 4-digit %d",
           sum(ciq$ciq_primary), sum(ciq$ciq_sic), sum(!is.na(ciq$ciq_naics4)))
  log_line("v2: parents with a usable code (rd_naics): %s; usable 4-digit (rd_naics4): %s; short codes: %d; distinct 4-digit industries: %d",
           pct(!r$flag_naics_missing), pct(!is.na(r$rd_naics4)), sum(r$flag_naics_short), uniqueN(na.omit(r$rd_naics4)))
  ij <- merge(par[, .(jv_bvdid, parent_bvdid)], r[, .(parent_bvdid, ok = !flag_naics_missing)], by = "parent_bvdid")[
    , .(all_ok = all(ok), any_ok = any(ok)), by = jv_bvdid]
  log_line("v2: IJVs %d; with a code for every parent: %s; for at least one parent: %s",
           nrow(ij), pct(ij$all_ok), pct(ij$any_ok))
  fwrite(r, f_out)
  log_line("v2: written %s", basename(f_out))
}
