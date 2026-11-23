# 12_wrds_headcount_education.R
# Two WRDS pulls for feasibility questions Q4 and Q3 of docs/research-brief.md
# (PI instruction of 2026-11-23, docs/decisions.md):
#   orbis      annual headcounts of the Orbis-sourced IJVs of the main sample,
#              every year and every consolidation code on file, from the Orbis
#              key-financials tables (large and medium libraries)
#   education  Revelio education records of the people hired by the main-sample
#              IJVs: dates, degree and university country only. University
#              names and fields of study are not pulled.
# Both extracts are cached: the Orbis file is pulled once, and the education
# pull writes one parquet part per fixed block of 5,000 user ids and skips the
# blocks already on disk, so an interrupted run resumes where it stopped.
# Nothing is tabulated here; see 11_staffing_tabulations.R (T3b and T4b).
#
# Credentials: WRDS_USERNAME and WRDS_PASSWORD in ~/.Renviron.
# Run from the repository root after 09_build_matched_dataset.R:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/12_wrds_headcount_education.R [version] [orbis] [education]
# With no step named, both run. The education pull takes about two hours.
# Outputs (gitignored, licensed data):
#   data/raw/orbis-jv-headcounts-2026-11-23.parquet
#   data/raw/revelio-education-full-2026-11-23/part-NNNN.parquet
#   data/interim/wrds-headcount-education-log-2026-11-23.md

source("code/R/00_setup.R")
require_pkgs(c("arrow", "DBI", "RPostgres"))
RUN_DATE <- "2026-10-09"
PULL_DATE <- "2026-11-23"
args <- commandArgs(trailingOnly = TRUE)
VERSION <- if (any(grepl("^v[0-9]+$", args))) args[grepl("^v[0-9]+$", args)][1] else "v3"
STEPS <- intersect(args, c("orbis", "education")); if (!length(STEPS)) STEPS <- c("orbis", "education")
RUN <- if (VERSION == "v1") RUN_DATE else paste0(VERSION, "-", RUN_DATE)
CHUNK_USERS <- 5000L
f_ijv   <- file.path(paths$processed, sprintf("ijv-matched-%s.csv", RUN))
f_spell <- file.path(paths$processed, sprintf("ijv-employee-spells-%s.parquet", RUN))
f_head  <- file.path(paths$raw, sprintf("orbis-jv-headcounts-%s.parquet", PULL_DATE))
d_edu   <- file.path(paths$raw, sprintf("revelio-education-full-%s", PULL_DATE))
f_log   <- file.path(paths$interim, sprintf("wrds-headcount-education-log-%s.md", PULL_DATE))
if (!file.exists(f_log)) cat("# WRDS pull log: Orbis annual headcounts and Revelio education, ", PULL_DATE, "\n\n", file = f_log, sep = "")
log_line <- function(...) {
  msg <- sprintf(...)
  message(format(Sys.time(), "%H:%M:%S"), " ", msg)
  cat("- ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " ", msg, "\n", file = f_log, append = TRUE, sep = "")
}
secs <- function(t0) as.numeric(Sys.time() - t0, units = "secs")

connect <- function() DBI::dbConnect(RPostgres::Postgres(), host = "wrds-pgdata.wharton.upenn.edu", port = 9737,
                                     dbname = "wrds", sslmode = "require",
                                     user = Sys.getenv("WRDS_USERNAME"), password = Sys.getenv("WRDS_PASSWORD"))
con <- connect()
# A query that fails (dropped connection on a long run) is retried on a fresh connection.
q <- function(sql, tries = 4L) {
  for (i in seq_len(tries)) {
    r <- tryCatch(as.data.table(DBI::dbGetQuery(con, sql)), error = function(e) e)
    if (!inherits(r, "error")) return(r)
    log_line("query failed (try %d of %d): %s", i, tries, substr(conditionMessage(r), 1, 120))
    Sys.sleep(20 * i)
    try(DBI::dbDisconnect(con), silent = TRUE)
    con <<- connect()
  }
  stop("query failed after ", tries, " tries", call. = FALSE)
}

# ---- Orbis annual headcounts ------------------------------------------------------
if ("orbis" %in% STEPS) {
  if (file.exists(f_head)) {
    log_line("orbis: %s exists, not pulled again", basename(f_head))
  } else {
    # na.strings = "" keeps the country code "NA" (Namibia) as a value.
    ijv <- fread(f_ijv, colClasses = list(character = "jv_bvdid"), na.strings = "", select = c("jv_bvdid", "source"))
    ids <- ijv[source == "orbis", unique(jv_bvdid)]
    t0 <- Sys.time()
    libs <- c(large = "bvd_orbis_large.ob_key_financials_usd_l", medium = "bvd_orbis_medium.ob_key_financials_usd_m")
    batches <- split(ids, ceiling(seq_along(ids) / 2000L))
    pull_lib <- function(l) {
      x <- rbindlist(lapply(batches, function(b) {
        id_list <- paste(sprintf("'%s'", gsub("'", "''", b)), collapse = ",")
        q(sprintf("SELECT bvdid AS jv_bvdid, conscode, filing_type, closdate, closdate_year, nr_months, empl
                   FROM %s WHERE bvdid IN (%s) AND empl IS NOT NULL", libs[[l]], id_list))
      }))
      x[, orbis_library := l]
    }
    hc <- unique(rbindlist(lapply(names(libs), pull_lib)))
    arrow::write_parquet(hc, f_head)
    log_line("orbis: %d headcount records for %d of %d Orbis-sourced IJVs in %.0fs; consolidation codes: %s",
             nrow(hc), uniqueN(hc$jv_bvdid), length(ids), secs(t0),
             paste(sprintf("%s %d", names(table(hc$conscode, useNA = "ifany")), as.integer(table(hc$conscode, useNA = "ifany"))), collapse = ", "))
  }
}

# ---- Revelio education records ------------------------------------------------------
if ("education" %in% STEPS) {
  dir.create(d_edu, recursive = TRUE, showWarnings = FALSE)
  # User ids are compared and written as plain numbers (arrow reads them as double).
  users <- sort(unique(as.numeric(arrow::read_parquet(f_spell, col_select = "user_id")$user_id)))
  blocks <- split(users, ceiling(seq_along(users) / CHUNK_USERS))
  part <- function(i) file.path(d_edu, sprintf("part-%04d.parquet", i))
  todo <- which(!file.exists(vapply(seq_along(blocks), part, character(1))))
  log_line("education: %d users in %d blocks, %d blocks to pull", length(users), length(blocks), length(todo))
  t0 <- Sys.time(); n_rows <- 0
  for (k in seq_along(todo)) {
    i <- todo[k]
    e <- q(sprintf("SELECT user_id, education_number, startdate, enddate, degree, university_country
                    FROM revelio.individual_user_education WHERE user_id IN (%s)",
                   paste(sprintf("%.0f", blocks[[i]]), collapse = ",")))
    if (!nrow(e)) e <- data.table(user_id = numeric(), education_number = numeric(), startdate = as.Date(character()),
                                  enddate = as.Date(character()), degree = character(), university_country = character())
    e[, user_id := as.numeric(user_id)]
    # Written under a temporary name first, so a part on disk is always complete.
    tmp <- paste0(part(i), ".tmp")
    arrow::write_parquet(e, tmp)
    file.rename(tmp, part(i))
    n_rows <- n_rows + nrow(e)
    if (k %% 25 == 0 || k == length(todo)) log_line("education: block %d of %d done, %d records, %.0fs", k, length(todo), n_rows, secs(t0))
  }
  log_line("education: complete, %d parts in %s", length(list.files(d_edu, pattern = "^part-[0-9]+[.]parquet$")), d_edu)
}
DBI::dbDisconnect(con)
