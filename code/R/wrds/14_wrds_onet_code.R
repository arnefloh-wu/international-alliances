# 14_wrds_onet_code.R
# WRDS pull of Revelio's O*NET codes for the O*NET data step of the pre-analysis
# plan (decision 1 of docs/coauthor-notes/pre-analysis-plan-rules-decision-sheet-2026-11-24.qmd;
# PI go-ahead for the pull in chat on 2026-11-25, recorded in docs/decisions.md).
#   lookup     revelio.individual_role_lookup_v3: the role taxonomy (k17000 to k10)
#              with onet_code and onet_title. One small table, pulled once.
#   positions  revelio.individual_positions: position_id and onet_code for the
#              positions in the spells extract (ijv-employee-spells-<RUN>.parquet).
#              One parquet part per fixed block of 5,000 position ids; finished
#              parts are skipped, so an interrupted run resumes where it stopped.
# Nothing else is pulled: no names, titles of people, salaries or free text.
# Nothing is tabulated here; coverage is reported by 14 itself only as pooled
# shares (no breakdown by occupation, function or exposure).
#
# Credentials: WRDS_USERNAME and WRDS_PASSWORD in ~/.Renviron.
# Run from the repository root after 09_build_matched_dataset.R:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/14_wrds_onet_code.R [version] [lookup] [positions] [coverage]
# With no step named, all three run. The positions pull takes one to two hours.
# Outputs (gitignored, licensed data):
#   data/raw/revelio-role-lookup-v3-2026-11-25.parquet
#   data/raw/revelio-jv-positions-onet-2026-11-25/part-NNNN.parquet
#   data/interim/wrds-onet-log-2026-11-25.md

source("code/R/00_setup.R")
require_pkgs(c("arrow", "DBI", "RPostgres"))
RUN_DATE <- "2026-10-09"
PULL_DATE <- "2026-11-25"
args <- commandArgs(trailingOnly = TRUE)
VERSION <- if (any(grepl("^v[0-9]+$", args))) args[grepl("^v[0-9]+$", args)][1] else "v3"
STEPS <- intersect(args, c("lookup", "positions", "coverage")); if (!length(STEPS)) STEPS <- c("lookup", "positions", "coverage")
RUN <- if (VERSION == "v1") RUN_DATE else paste0(VERSION, "-", RUN_DATE)
CHUNK <- 5000L
COVERAGE_THRESHOLD <- 0.70   # fixed before the pull (decision 1, 2026-11-25)
f_spell  <- file.path(paths$processed, sprintf("ijv-employee-spells-%s.parquet", RUN))
f_lookup <- file.path(paths$raw, sprintf("revelio-role-lookup-v3-%s.parquet", PULL_DATE))
d_pos    <- file.path(paths$raw, sprintf("revelio-jv-positions-onet-%s", PULL_DATE))
f_log    <- file.path(paths$interim, sprintf("wrds-onet-log-%s.md", PULL_DATE))
if (!file.exists(f_log)) cat("# WRDS pull log: Revelio O*NET codes, ", PULL_DATE, "\n\n", file = f_log, sep = "")
log_line <- function(...) {
  msg <- sprintf(...)
  message(format(Sys.time(), "%H:%M:%S"), " ", msg)
  cat("- ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " ", msg, "\n", file = f_log, append = TRUE, sep = "")
}
secs <- function(t0) as.numeric(Sys.time() - t0, units = "secs")

need_wrds <- any(c("lookup", "positions") %in% STEPS)
if (need_wrds) {
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
}

# ---- Role lookup with O*NET codes ---------------------------------------------------
if ("lookup" %in% STEPS) {
  if (file.exists(f_lookup)) {
    log_line("lookup: %s exists, not pulled again", basename(f_lookup))
  } else {
    t0 <- Sys.time()
    lk <- q("SELECT role_k17000_v3, role_k10000_v3, role_k5000_v3, role_k1500_v3, role_k1000_v3, role_k500_v3,
                    role_k150_v3, role_k50_v3, role_k10_v3, onet_code, onet_title
             FROM revelio.individual_role_lookup_v3")
    arrow::write_parquet(lk, f_lookup)
    log_line("lookup: %d rows, %d distinct role_k17000_v3, %d distinct onet_code, %d rows without onet_code, %.0fs",
             nrow(lk), uniqueN(lk$role_k17000_v3), uniqueN(lk$onet_code[!is.na(lk$onet_code)]),
             sum(is.na(lk$onet_code) | lk$onet_code == ""), secs(t0))
  }
}

# ---- Position-level O*NET codes ---------------------------------------------------
if ("positions" %in% STEPS) {
  dir.create(d_pos, recursive = TRUE, showWarnings = FALSE)
  # Position ids are compared and written as plain numbers (arrow reads them as double).
  ids <- sort(unique(as.numeric(arrow::read_parquet(f_spell, col_select = "position_id")$position_id)))
  blocks <- split(ids, ceiling(seq_along(ids) / CHUNK))
  part <- function(i) file.path(d_pos, sprintf("part-%04d.parquet", i))
  todo <- which(!file.exists(vapply(seq_along(blocks), part, character(1))))
  log_line("positions: %d position ids in %d blocks, %d blocks to pull", length(ids), length(blocks), length(todo))
  t0 <- Sys.time(); n_rows <- 0
  for (k in seq_along(todo)) {
    i <- todo[k]
    p <- q(sprintf("SELECT position_id, onet_code FROM revelio.individual_positions WHERE position_id IN (%s)",
                   paste(sprintf("%.0f", blocks[[i]]), collapse = ",")))
    if (!nrow(p)) p <- data.table(position_id = numeric(), onet_code = character())
    p[, position_id := as.numeric(position_id)]
    # Written under a temporary name first, so a part on disk is always complete.
    tmp <- paste0(part(i), ".tmp")
    arrow::write_parquet(p, tmp)
    file.rename(tmp, part(i))
    n_rows <- n_rows + nrow(p)
    if (k %% 25 == 0 || k == length(todo)) log_line("positions: block %d of %d done, %d rows, %.0fs", k, length(todo), n_rows, secs(t0))
  }
  log_line("positions: complete, %d parts in %s", length(list.files(d_pos, pattern = "^part-[0-9]+[.]parquet$")), d_pos)
}
if (need_wrds) DBI::dbDisconnect(con)

# ---- Pooled coverage checks (no breakdown by occupation, function or exposure) ------
if ("coverage" %in% STEPS) {
  check <- function(cond, msg) { log_line("%s %s", if (isTRUE(cond)) "OK  " else "FAIL", msg); invisible(isTRUE(cond)) }
  sp <- as.data.table(arrow::read_parquet(f_spell, col_select = c("position_id", "role_k17000_v3", "start_date")))
  sp[, position_id := as.numeric(position_id)]
  parts <- list.files(d_pos, pattern = "^part-[0-9]+[.]parquet$", full.names = TRUE)
  n_blocks <- ceiling(uniqueN(sp$position_id) / CHUNK)
  check(length(parts) == n_blocks, sprintf("all %d position blocks on disk (%d found)", n_blocks, length(parts)))
  po <- rbindlist(lapply(parts, function(f) as.data.table(arrow::read_parquet(f))))
  # Codes that are not O*NET-SOC occupations ("On Leave", "Retired", "unknown") count as missing.
  is_occ <- function(x) !is.na(x) & grepl("^[0-9]{2}-[0-9]{4}([.][0-9]{2})?$", x)
  log_line("position codes that are not occupations, set to missing: %s",
           paste(sprintf("%s %d", names(table(po$onet_code[!is.na(po$onet_code) & !is_occ(po$onet_code)])),
                         as.integer(table(po$onet_code[!is.na(po$onet_code) & !is_occ(po$onet_code)]))), collapse = ", "))
  po[!is_occ(onet_code), onet_code := NA_character_]
  check(!anyDuplicated(po$position_id), sprintf("no repeated position_id in the pull (%d rows)", nrow(po)))
  check(all(po$position_id %in% sp$position_id), "no position outside the spells extract")
  sp <- po[sp, on = "position_id"]
  n <- nrow(sp)
  log_line("positions in spells: %d; found in individual_positions: %d (%.1f%%); with onet_code: %d (%.1f%%)",
           n, sum(sp$position_id %in% po$position_id), 100 * mean(sp$position_id %in% po$position_id),
           sum(!is.na(sp$onet_code)), 100 * mean(!is.na(sp$onet_code)))
  log_line("occupation codes: %d distinct; codes with an .NN suffix other than .00: %d",
           uniqueN(po$onet_code[!is.na(po$onet_code)]),
           uniqueN(po$onet_code[grepl("[.][0-9]{2}$", po$onet_code) & !grepl("[.]00$", po$onet_code)]))
  if (file.exists(f_lookup)) {
    lk <- as.data.table(arrow::read_parquet(f_lookup, col_select = c("role_k17000_v3", "onet_code")))
    lk[!is_occ(onet_code), onet_code := NA_character_]
    check(!anyDuplicated(lk$role_k17000_v3), "lookup: one row per role_k17000_v3")
    sp <- merge(sp, unique(lk, by = "role_k17000_v3")[, .(role_k17000_v3, onet_lookup = onet_code)], by = "role_k17000_v3", all.x = TRUE)
    both <- sp[!is.na(onet_code) & !is.na(onet_lookup)]
    log_line("lookup route: %.1f%% of spells positions get an onet_code through role_k17000_v3; agreement with the position-level code where both exist: %.1f%% of %d",
             100 * mean(!is.na(sp$onet_lookup)), 100 * mean(both$onet_code == both$onet_lookup), nrow(both))
  }
  # Coverage over time: pooled share by start-year band (data quality, not an outcome).
  sp[, band := cut(year(start_date), c(-Inf, 1999, 2009, 2014, 2019, Inf),
                   labels = c("before 2000", "2000-2009", "2010-2014", "2015-2019", "2020 on"))]
  cov <- sp[, .(positions = .N, share_onet = round(mean(!is.na(onet_code)), 3)), by = band][order(band)]
  log_line("coverage by start-year band: %s", paste(sprintf("%s %d (%.1f%%)", cov$band, cov$positions, 100 * cov$share_onet), collapse = "; "))
  share <- mean(!is.na(sp$onet_code))
  log_line("decision rule (threshold %.0f%%, fixed before the pull): %s", 100 * COVERAGE_THRESHOLD,
           if (share >= COVERAGE_THRESHOLD) "met; the position-level onet_code is the primary link"
           else "not met; role_k50 is mapped to O*NET by title as the documented fallback")
}
