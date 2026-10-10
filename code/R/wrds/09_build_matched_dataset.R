# 09_build_matched_dataset.R
# Builds the matched dataset: the IJVs of the recommended main sample (core_main)
# linked across Orbis, Capital IQ and Revelio, as three tables that share the
# key jv_bvdid. This is the end of the matching work (Stage 4 extension). It is
# NOT the Stage 6 panel: no function mapping, no seniority mapping, no
# parent-origin classification and no measures are built here, because those
# need the approved pre-analysis plan (gate 5).
#
# Tables (data/processed/, gitignored, licensed data):
#   ijv-matched-<run>.csv            one row per IJV: identifiers, host, industry,
#                                    formation year, parents A and B, match
#                                    quality, coverage and flags
#   ijv-parents-<run>.csv            one row per IJV-parent pair, all parents,
#                                    with ultimate owner and Revelio family size
#   ijv-employee-spells-<run>.parquet one row per Revelio position at the matched
#                                    JV entity from the formation year on, with
#                                    function, seniority, dates and the number of
#                                    30 June reference dates it covers
# Career histories (all positions of those employees, before and after the JV)
# stay in data/raw/revelio-histories-full-2026-10-09/ and link on user_id.
#
# Run from the repository root after 03_wrds_full_sample.R:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/09_build_matched_dataset.R [version]

source("code/R/00_setup.R")
require_pkgs("arrow")
RUN_DATE <- "2026-10-09"
VERSION <- if (length(commandArgs(trailingOnly = TRUE))) commandArgs(trailingOnly = TRUE)[1] else "v3"
RUN <- if (VERSION == "v1") RUN_DATE else paste0(VERSION, "-", RUN_DATE)
YEAR_MAX <- 2026L
f_sample <- file.path(paths$processed, sprintf("sample-ijv-%s.csv", RUN))
f_orbis  <- file.path(paths$raw, sprintf("orbis-full-%s.csv", RUN))
f_groups <- file.path(paths$interim, sprintf("full-parent-groups-%s.csv", RUN))
f_pos    <- file.path(paths$raw, sprintf("revelio-jv-positions-full-%s.parquet", RUN_DATE))
f_ijv    <- file.path(paths$processed, sprintf("ijv-matched-%s.csv", RUN))
f_par    <- file.path(paths$processed, sprintf("ijv-parents-%s.csv", RUN))
f_spell  <- file.path(paths$processed, sprintf("ijv-employee-spells-%s.parquet", RUN))
f_man    <- file.path(paths$processed, sprintf("dataset-manifest-%s.md", RUN))
check <- function(cond, msg) { cat(if (isTRUE(cond)) "OK   " else "FAIL ", msg, "\n"); if (!isTRUE(cond)) stop("check failed: ", msg, call. = FALSE) }

s <- fread(f_sample, colClasses = list(character = "jv_bvdid"))
main <- s[core_main == TRUE]

# ---- Parents ---------------------------------------------------------------
o <- fread(f_orbis, colClasses = list(character = c("jv_bvdid", "parent_bvdid", "parent_guo")))
o <- o[jv_bvdid %in% main$jv_bvdid]
# Parent A is the parent with the larger equity share; ties break on country code.
setorder(o, jv_bvdid, -equity_share_current, parent_country, na.last = TRUE)
o[, parent_rank := seq_len(.N), by = jv_bvdid]
o[, parent_label := fifelse(parent_rank == 1L, "A", fifelse(parent_rank == 2L, "B", as.character(parent_rank)))]
grp <- fread(f_groups, colClasses = list(character = "parent_bvdid"))
fam <- grp[, .(revelio_family_size = .N), by = parent_bvdid]
o <- merge(o, fam, by = "parent_bvdid", all.x = TRUE)
o[is.na(revelio_family_size), revelio_family_size := 0L]
o[, parent_in_revelio := revelio_family_size > 0L]
parents <- o[, .(jv_bvdid, parent_rank, parent_label, parent_bvdid, parent_name, parent_country, parent_entity_type,
                 equity_share_current, parent_guo, guo_name, guo_country = substr(parent_guo, 1, 2),
                 parent_in_revelio, revelio_family_size)]
setorder(parents, jv_bvdid, parent_rank)
fwrite(parents, f_par)

# ---- IJV table -------------------------------------------------------------
pa <- o[parent_rank == 1L, .(jv_bvdid, parent_a_name = parent_name, parent_a_country = parent_country, parent_a_share = equity_share_current,
                              parent_a_bvdid = parent_bvdid, parent_a_in_revelio = parent_in_revelio)]
pb <- o[parent_rank == 2L, .(jv_bvdid, parent_b_name = parent_name, parent_b_country = parent_country, parent_b_share = equity_share_current,
                              parent_b_bvdid = parent_bvdid, parent_b_in_revelio = parent_in_revelio)]
ijv <- main[, .(jv_bvdid, jv_name, jv_country, region, industry, formation_year, formation_year_missing, source, route, admitted_by,
                exposure_group, n_parents, rcid_jv = rcid, match_tier = tier, match_method = method, match_score = score, manual_by,
                n_emp, n_years, function_cells_5, seniority_cells_5, jv_employees_orbis = jv_employees, operating_parents, strategic,
                flag_pre_formation_10y, flag_holding_vehicle, jv_website, jv_lei)]
ijv <- merge(merge(ijv, pa, by = "jv_bvdid", all.x = TRUE), pb, by = "jv_bvdid", all.x = TRUE)
setorder(ijv, jv_bvdid)
fwrite(ijv, f_ijv)

# ---- Employee spells at the matched JV entities -------------------------------
pos <- as.data.table(arrow::read_parquet(f_pos))
pos <- unique(pos, by = "position_id")
pos <- merge(pos, ijv[, .(rcid = rcid_jv, jv_bvdid, formation_year)], by = "rcid")
pos[, end_eff := fifelse(is.na(end_date), as.IDate(Sys.Date()), as.IDate(end_date))]
pos[, start_date := as.IDate(start_date)]
ref_md <- const$reference_date                       # "06-30"
ref_of <- function(y) as.IDate(sprintf("%d-%s", y, ref_md))
# First and last 30 June covered by the position, bounded by the formation year and YEAR_MAX.
pos[, first_ref := pmax(formation_year, year(start_date) + (start_date > ref_of(year(start_date))))]
pos[, last_ref := pmin(YEAR_MAX, year(end_eff) - (end_eff < ref_of(year(end_eff))))]
pos[, n_reference_dates := pmax(0L, as.integer(last_ref - first_ref + 1L))]
spells <- pos[n_reference_dates >= 1L, .(jv_bvdid, rcid, user_id, position_id, start_date, end_date, ongoing = is.na(end_date),
                                         first_reference_year = first_ref, last_reference_year = last_ref, n_reference_dates,
                                         country, seniority, role_k17000_v3, function_role_k10 = job_category, role_k50_v3)]
setorder(spells, jv_bvdid, user_id, start_date)
arrow::write_parquet(spells, f_spell)

# ---- Checks ------------------------------------------------------------------
cat("\n")
check(nrow(ijv) == nrow(main), sprintf("IJV table has one row per main-sample IJV (%d)", nrow(ijv)))
check(!anyDuplicated(ijv$jv_bvdid) && !anyDuplicated(ijv$rcid_jv), "each IJV and each Revelio entity appears once")
check(all(parents$jv_bvdid %in% ijv$jv_bvdid) && uniqueN(parents$jv_bvdid) == nrow(ijv), "every IJV has parents and no stray parent rows")
np <- merge(parents[, .(rows = .N), by = jv_bvdid], ijv[, .(jv_bvdid, n_parents)], by = "jv_bvdid")
check(np[rows != n_parents, .N] == 0L, sprintf("parent rows per IJV equal the recorded number of parents (mismatches: %d)", np[rows != n_parents, .N]))
check(all(spells$jv_bvdid %in% ijv$jv_bvdid) && uniqueN(spells$jv_bvdid) == nrow(ijv), "every IJV has employee spells")
check(!anyDuplicated(spells$position_id), "no repeated position in the spell table")
# The spell table must reproduce the employee counts of the sample table.
cnt <- spells[, .(n_emp_spells = uniqueN(user_id), n_years_spells = uniqueN(unlist(Map(seq, first_reference_year, last_reference_year)))), by = jv_bvdid]
chk <- merge(ijv[, .(jv_bvdid, n_emp, n_years)], cnt, by = "jv_bvdid")
mism_emp <- chk[n_emp != n_emp_spells, .N]
mism_yrs <- chk[n_years != n_years_spells, .N]
check(mism_emp == 0L, sprintf("employee counts from spells equal the sample table for all IJVs (mismatches: %d)", mism_emp))
check(mism_yrs == 0L, sprintf("observed years from spells equal the sample table for all IJVs (mismatches: %d)", mism_yrs))

# ---- Manifest ----------------------------------------------------------------
writeLines(c(sprintf("# Matched dataset manifest (%s)", RUN), "",
  sprintf("Built %s by code/R/wrds/09_build_matched_dataset.R from the main sample (core_main) of %s.", format(Sys.time(), "%Y-%m-%d %H:%M"), basename(f_sample)), "",
  "| Table | File | Rows |", "|---|---|---|",
  sprintf("| IJVs | %s | %d |", basename(f_ijv), nrow(ijv)),
  sprintf("| IJV-parent pairs | %s | %d |", basename(f_par), nrow(parents)),
  sprintf("| Employee spells at the matched JV entities | %s | %d (%d people) |", basename(f_spell), nrow(spells), uniqueN(spells$user_id)), "",
  sprintf("Strategic IJVs: %d. Manual (person or agent reviewed) matches: %d. Career histories: data/raw/revelio-histories-full-2026-10-09/ (link on user_id).",
          ijv[strategic == TRUE, .N], ijv[match_tier == "manual", .N])), f_man)
message(sprintf("matched dataset written: %d IJVs, %d parent rows, %d spells for %d people", nrow(ijv), nrow(parents), nrow(spells), uniqueN(spells$user_id)))
