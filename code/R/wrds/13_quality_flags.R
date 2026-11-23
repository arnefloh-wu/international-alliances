# 13_quality_flags.R
# Data quality flags for the matched dataset (.claude/skills/data-collector,
# Step 4). The flag code is code/R/functions/quality_flags.R and is the same
# for both inputs:
#   synthetic   data/synthetic/ (from code/R/tests/synthetic_matched.R). Checks
#               that every seeded failure is caught and, where the real tables
#               are on disk, that the synthetic schema matches them column for
#               column.
#   [version]   the real matched dataset, default v3: IJV, parent and spell
#               tables, parent families, career histories, annual headcounts.
# Flags are counted and reported; no row is dropped and no input is changed.
# Nothing is broken down by shock exposure group: that column is dropped on read.
#
# Run from the repository root (no WRDS connection):
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/13_quality_flags.R synthetic
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/13_quality_flags.R v3     (about two minutes)
# Outputs (aggregated counts only):
#   data/synthetic/quality-flags-synthetic-2026-11-23.md   (simulated data, tracked)
#   data/interim/quality-flags-<run>.md                    (from licensed data, gitignored)

source("code/R/00_setup.R")
source("code/R/functions/quality_flags.R")
require_pkgs("arrow")
RUN_DATE <- "2026-10-09"
SYN_DATE <- "2026-11-23"
args <- commandArgs(trailingOnly = TRUE)
SYN <- "synthetic" %in% args
VERSION <- if (any(grepl("^v[0-9]+$", args))) args[grepl("^v[0-9]+$", args)][1] else "v3"
RUN <- if (VERSION == "v1") RUN_DATE else paste0(VERSION, "-", RUN_DATE)
t0 <- Sys.time()
say <- function(...) message(format(Sys.time(), "%H:%M:%S"), " ", sprintf(...))
check <- function(cond, msg) { cat(if (isTRUE(cond)) "OK   " else "FAIL ", msg, "\n"); if (!isTRUE(cond)) stop("check failed: ", msg, call. = FALSE) }
kb <- function(d) knitr::kable(d, format = "pipe", format.args = list(big.mark = ","))
f_syn <- function(name, ext = "parquet") file.path("data/synthetic", sprintf("%s-synthetic-%s.%s", name, SYN_DATE, ext))
real <- list(`ijv-matched` = file.path(paths$processed, sprintf("ijv-matched-%s.csv", RUN)),
             `ijv-parents` = file.path(paths$processed, sprintf("ijv-parents-%s.csv", RUN)),
             `parent-groups` = file.path(paths$interim, sprintf("full-parent-groups-%s.csv", RUN)),
             `ijv-employee-spells` = file.path(paths$processed, sprintf("ijv-employee-spells-%s.parquet", RUN)),
             `revelio-histories` = file.path(paths$raw, sprintf("revelio-histories-full-%s", RUN_DATE)),
             `orbis-jv-headcounts` = file.path(paths$raw, "orbis-jv-headcounts-2026-11-23.parquet"))
f_md <- if (SYN) f_syn("quality-flags", "md") else file.path(paths$interim, sprintf("quality-flags-%s.md", RUN))

# ---- Inputs ----------------------------------------------------------------------
# na.strings = "" keeps the country code "NA" (Namibia) as a value.
read_csv <- function(f, chr) fread(f, colClasses = list(character = chr), na.strings = "")
read_syn <- function(name) {
  d <- as.data.table(arrow::read_parquet(f_syn(name)))
  check(all(d$synthetic), sprintf("%s: every row is marked synthetic", name))
  d[, synthetic := NULL][]
}
if (SYN) {
  ijv <- read_syn("ijv-matched"); par <- read_syn("ijv-parents"); grp <- read_syn("parent-groups")
  spells <- read_syn("ijv-employee-spells"); head <- read_syn("orbis-jv-headcounts")
  hist_files <- f_syn("revelio-histories")
} else {
  ijv <- read_csv(real$`ijv-matched`, "jv_bvdid")
  par <- read_csv(real$`ijv-parents`, c("jv_bvdid", "parent_bvdid", "parent_guo"))
  grp <- read_csv(real$`parent-groups`, "parent_bvdid")
  spells <- as.data.table(arrow::read_parquet(real$`ijv-employee-spells`, col_select = c(
    "jv_bvdid", "rcid", "user_id", "position_id", "start_date", "end_date", "first_reference_year", "last_reference_year", "country")))
  head <- if (file.exists(real$`orbis-jv-headcounts`)) as.data.table(arrow::read_parquet(real$`orbis-jv-headcounts`)) else NULL
  hist_files <- list.files(real$`revelio-histories`, pattern = "[.]parquet$", full.names = TRUE)
}
ijv[, exposure_group := NULL]          # never used here: the shock is not chosen by outcomes
say("inputs (%s): %d IJVs, %d parent rows, %d family rows, %d spells, %d history file(s)",
    if (SYN) "synthetic" else RUN, nrow(ijv), nrow(par), nrow(grp), nrow(spells), length(hist_files))

# ---- Keys and id types --------------------------------------------------------------
check(!anyNA(ijv$jv_bvdid) && !anyDuplicated(ijv$jv_bvdid), "one row per IJV")
check(is.double(spells$user_id) && is.double(spells$position_id), "spell ids are plain numeric (not integer64)")
keys <- data.table(
  check = c("parent rows without an IJV", "IJVs without a parent row", "IJVs without a spell", "host country missing",
            "host country code NA (Namibia) kept as a value", "parent country missing"),
  n = c(par[!jv_bvdid %in% ijv$jv_bvdid, .N], ijv[!jv_bvdid %in% par$jv_bvdid, .N], ijv[!jv_bvdid %in% spells$jv_bvdid, .N],
        ijv[is.na(jv_country), .N], ijv[jv_country == "NA", .N], par[is.na(parent_country), .N]))

# ---- Flags --------------------------------------------------------------------------
ijv_f <- flag_ijvs(ijv, spells, par, grp)
sp_f <- flag_positions(spells, ijv)
sp_f <- merge(sp_f, ijv[, .(jv_bvdid, region, source)], by = "jv_bvdid", all.x = TRUE)
sp_f[, start_band := year_band(start_date)]
say("IJV and spell flags done")

# Career histories: one part at a time; repeated position ids are counted over all parts.
h_cols <- c("user_id", "position_id", "rcid", "start_date", "end_date", "country")
h_sum <- list(); h_band <- list(); h_pid <- list(); h_uid <- list()
for (i in seq_along(hist_files)) {
  h <- flag_positions(as.data.table(arrow::read_parquet(hist_files[i], col_select = tidyselect::all_of(h_cols))))
  if (i == 1L) check(is.double(h$user_id), "history ids are plain numeric (not integer64)")
  h[, flag_dup_position := NULL]
  fl <- grep("^flag_", names(h), value = TRUE)
  h_sum[[i]] <- h[, c(list(rows = .N), lapply(.SD, sum)), .SDcols = fl]
  h_band[[i]] <- h[, c(list(rows = .N), lapply(.SD, sum)), by = .(start_band = year_band(start_date)), .SDcols = c("flag_employer_unmapped", "flag_country_missing")]
  h_pid[[i]] <- h$position_id; h_uid[[i]] <- unique(h$user_id)
  if (i %% 200L == 0L) say("histories: part %d of %d", i, length(hist_files))
}
h_sum <- rbindlist(h_sum)[, lapply(.SD, sum)]
h_pid <- unlist(h_pid, use.names = FALSE); h_uid <- unique(unlist(h_uid, use.names = FALSE))
h_rows <- h_sum$rows
hist_sum <- data.table(table = "histories", flag = c("flag_dup_position", setdiff(names(h_sum), "rows")),
                       n = c(sum(duplicated(h_pid)), unlist(h_sum[, !"rows"])), rows = h_rows)[, share := n / rows]
h_band <- rbindlist(h_band)[, lapply(.SD, sum), by = start_band][order(start_band)]
h_band[, `:=`(flag_employer_unmapped = round(flag_employer_unmapped / rows, 4), flag_country_missing = round(flag_country_missing / rows, 4))]
sp_users <- unique(spells$user_id)
keys <- rbind(keys, data.table(check = c("spell users without a career history on file", "people with a career history on file"),
                               n = c(sum(!sp_users %in% h_uid), length(h_uid))))
rm(h_pid); invisible(gc())
say("history flags done: %d positions", h_rows)

hc_f <- if (!is.null(head)) flag_accounts(head) else NULL
summ <- rbind(flag_summary(ijv_f, "ijv"), flag_summary(sp_f, "spells"), hist_sum,
              if (!is.null(hc_f)) flag_summary(hc_f, "headcounts"))
summ[, share := round(share, 4)]
check(!any(grepl("exposure", unlist(lapply(list(ijv_f, sp_f, hc_f), names)))), "no table carries or is broken down by exposure group")

# ---- Synthetic input: are the seeded failures caught, and does the schema match? ------
verify <- NULL; schema <- NULL
if (SYN) {
  seeded <- fread(f_syn("seeded-failures", "csv"))
  seeded[, n_flagged := vapply(seq_len(.N), function(i) {
    if (flag[i] == "jv_country == 'NA'") return(as.numeric(ijv[jv_country == "NA", .N]))
    x <- summ[table == seeded$table[i] & flag == seeded$flag[i], n]; if (length(x)) x else NA_real_ }, numeric(1))]
  seeded[, caught := !is.na(n_flagged) & n_flagged == n_expected]
  verify <- seeded[, .(failure, table, flag, unit, n_expected, n_flagged, caught)]
  print(verify)
  check(all(verify$caught), sprintf("all %d seeded failures are caught, each in the seeded number", nrow(verify)))
  # The CSV pitfall behind the Namibia seed: a default read turns the code NA into a missing value.
  tmp <- tempfile(fileext = ".csv"); fwrite(ijv[, .(jv_bvdid, jv_country)], tmp)
  n_default <- fread(tmp)[, sum(is.na(jv_country))]; n_safe <- fread(tmp, na.strings = "")[, sum(jv_country == "NA", na.rm = TRUE)]
  check(n_safe == ijv[jv_country == "NA", .N], sprintf("CSV read with na.strings = \"\" keeps the %d Namibian IJVs (a default read loses %d)", n_safe, n_default))
  # Schema: names and types of the synthetic tables against the real ones, where those are on disk.
  type_of <- function(x) c(character = "string", integer = "int32", numeric = "double", logical = "bool", Date = "date32[day]", IDate = "date32[day]")[class(x)[1]]
  sch <- function(p) {
    if (grepl("[.]csv$", p)) { d <- fread(p, na.strings = ""); return(data.table(column = names(d), type = unname(vapply(d, type_of, "")))) }
    s <- arrow::open_dataset(p)$schema
    data.table(column = s$names, type = vapply(s$fields, function(f) f$type$ToString(), ""))
  }
  schema <- rbindlist(lapply(names(real), function(n) {
    if (!file.exists(real[[n]])) return(data.table(table = n, columns = NA_integer_, result = "real table not on disk, not compared"))
    a <- sch(f_syn(n))[column != "synthetic"]; b <- sch(real[[n]])
    b[, type := sub("^int64$", "int32", type)]     # CSV integers are read as int32 or int64 depending on size
    same <- identical(a$column, b$column) && identical(a$type, b$type)
    diff <- if (same) "" else paste(setdiff(paste(a$column, a$type), paste(b$column, b$type)), collapse = "; ")
    data.table(table = n, columns = nrow(b), result = if (same) "names, order and types match" else paste("MISMATCH:", diff))
  }))
  print(schema)
  check(!any(grepl("MISMATCH", schema$result)), "synthetic schema matches the real tables that are on disk")
}

# ---- Report --------------------------------------------------------------------------------
ijv_flags <- grep("^flag_", names(ijv_f), value = TRUE); sp_flags <- setdiff(grep("^flag_", names(sp_f), value = TRUE), "flag_stray_entity")
out <- c(
  sprintf("# Data quality flags (%s)", if (SYN) paste("synthetic", SYN_DATE) else RUN), "",
  sprintf("Built %s by code/R/wrds/13_quality_flags.R with the flag functions of code/R/functions/quality_flags.R.", format(Sys.time(), "%Y-%m-%d %H:%M")),
  if (SYN) "Input: simulated tables in data/synthetic/ (no licensed data)." else
    sprintf("Input: matched dataset %s, career histories and annual headcounts (licensed, aggregated counts only).", RUN),
  "Flags are columns computed on read; no row was dropped and no file was changed. Nothing is broken down by shock exposure group.", "",
  "## Keys and coverage", "", kb(keys), "",
  "## Flag counts", "", "`n` is the number of flagged rows, `rows` the size of the table, `share` their ratio.", "", kb(summ), "",
  "`flag_open_ended`, `flag_multi_ijv_person` and `flag_jv_in_parent_family` mark cases to handle, not errors. `flag_dup_position` counts the copies after the first.",
  "`flag_size_mismatch` is recomputed from `n_emp` and `jv_employees_orbis` in the IJV table; manual matches are exempt from that rule in the sample definition.", "",
  "## IJV flags by region", "", kb(flag_by(ijv_f, "region", ijv_flags)), "",
  "## IJV flags by source", "", kb(flag_by(ijv_f, "source", ijv_flags)), "",
  "## IJV flags by match tier", "", kb(flag_by(ijv_f, "match_tier", ijv_flags)), "",
  "## Spell flags by region", "", kb(flag_by(sp_f, "region", sp_flags)), "",
  "## Spell flags by source", "", kb(flag_by(sp_f, "source", sp_flags)), "",
  "## Spell flags by start year", "", kb(flag_by(sp_f, "start_band", sp_flags)), "",
  "## Career-history flags by start year", "", kb(h_band), "",
  if (SYN) c("## Seeded failures", "", kb(verify), "", "## Schema against the real tables", "", kb(schema), ""))
writeLines(out, f_md)
say("written: %s (%.0f s)", f_md, as.numeric(difftime(Sys.time(), t0, units = "secs")))
