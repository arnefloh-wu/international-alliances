# 01_pilot_matching.R
# Stage 4: match approx. 100 pilot IJVs and their parents from Orbis to
# Revelio, compute coverage, and write the inputs for the pilot report.
# Not executed in the cloud session that wrote it; run locally.

source("code/R/00_setup.R")

# ---- 1. Load exports ------------------------------------------------------
orbis_file   <- tail(sort(list.files(paths$raw, "^orbis-pilot-.*\\.csv$", full.names = TRUE)), 1)
rev_co_file  <- tail(sort(list.files(paths$raw, "^revelio-companies-.*\\.csv$", full.names = TRUE)), 1)
rev_pos_file <- tail(sort(list.files(paths$raw, "^revelio-positions-.*\\.(parquet|csv)$", full.names = TRUE)), 1)
stopifnot(length(orbis_file) == 1, length(rev_co_file) == 1, length(rev_pos_file) == 1)

orbis <- fread(orbis_file)                       # one row per JV-parent pair
rev_co <- fread(rev_co_file)
rev_pos <- if (grepl("parquet$", rev_pos_file)) as.data.table(read_parquet(rev_pos_file)) else fread(rev_pos_file)

# Expected columns are documented in data/raw/extraction-spec-*.md. Rename here
# once the real export headers are known.
# orbis:   jv_bvdid, jv_name, jv_country, parent_bvdid, parent_name, parent_country,
#          guo_bvdid, guo_country, equity_share_formation, formation_date, nace
# rev_co:  rcid, company_name, country, ultimate_parent_rcid
# rev_pos: user_id, rcid, start_date, end_date, job_category, seniority, country

# ---- 2. Match JVs and parents --------------------------------------------
jv_ent <- unique(orbis[, .(orbis_id = jv_bvdid, orbis_name = jv_name, orbis_country = jv_country)])
pa_ent <- unique(orbis[, .(orbis_id = parent_bvdid, orbis_name = parent_name, orbis_country = parent_country)])
rev_ent <- rev_co[, .(rcid, rev_name = company_name, rev_country = country)]

jv_matches <- match_entities(jv_ent, rev_ent, const$jw_threshold)[, entity := "jv"]
pa_matches <- match_entities(pa_ent, rev_ent, const$jw_threshold)[, entity := "parent"]
matches <- rbindlist(list(jv_matches, pa_matches), fill = TRUE)
fwrite(matches, file.path(paths$interim, "pilot-matches.csv"))
fwrite(matches[needs_review == TRUE], file.path(paths$interim, "pilot-match-review.csv"))

# Parent groups: parent rcid plus all rcids whose ultimate parent is that rcid.
best <- matches[needs_review == FALSE | score >= 0.97][order(-score)][, .SD[1], by = .(orbis_id, entity)]
parent_groups <- merge(best[entity == "parent", .(parent_bvdid = orbis_id, rcid)],
                       rev_co[, .(rcid_member = rcid, ultimate_parent_rcid)],
                       by.x = "rcid", by.y = "ultimate_parent_rcid", all.x = TRUE)
parent_groups <- unique(rbind(parent_groups[, .(parent_bvdid, rcid = rcid_member)],
                              best[entity == "parent", .(parent_bvdid = orbis_id, rcid)]))

# ---- 3. Workforce coverage per matched JV ---------------------------------
jv_rcid <- best[entity == "jv", .(jv_bvdid = orbis_id, rcid)]
pos <- merge(rev_pos, jv_rcid, by = "rcid")
pos[, `:=`(start_date = as.IDate(start_date),
           end_date = fifelse(is.na(end_date), as.IDate(Sys.Date()), as.IDate(end_date)))]

years <- seq(min(year(pos$start_date), na.rm = TRUE), year(Sys.Date()))
ref <- as.IDate(paste0(years, "-", const$reference_date))
cell_years <- rbindlist(lapply(seq_along(years), function(i) {
  pos[start_date <= ref[i] & end_date >= ref[i],
      .(year = years[i], jv_bvdid, user_id, job_category, seniority, start_date)]
}))

# Prior employer within the origin window, from the full position history.
hist <- rev_pos[, .(user_id, rcid, start_date = as.IDate(start_date),
                    end_date = fifelse(is.na(end_date), as.IDate(Sys.Date()), as.IDate(end_date)),
                    country)]
setorder(hist, user_id, -end_date)
cell_years <- merge(cell_years, orbis[, .(jv_bvdid, parent_bvdid, parent_country, equity_share_formation)],
                    by = "jv_bvdid", allow.cartesian = TRUE)
# Parent A = larger equity share at formation.
setorder(cell_years, jv_bvdid, -equity_share_formation, parent_country)
cell_years[, parent_rank := rowid(jv_bvdid, year, user_id)]
# Simplified two-parent origin classification for the pilot; multi-parent JVs flagged.
origin <- cell_years[parent_rank <= 2][
  , .(parent_a = parent_bvdid[1], parent_b = parent_bvdid[2]), by = .(jv_bvdid, year, user_id)]
origin <- merge(origin, unique(cell_years[, .(jv_bvdid, year, user_id, job_category, seniority, start_date)]),
                by = c("jv_bvdid", "year", "user_id"))
origin[, origin := {
  pr <- hist[user_id == .BY$user_id & end_date <= start_date &
             end_date >= start_date - const$origin_window * 365, ]
  classify_origin(pr$rcid,
                  parent_groups[parent_bvdid == parent_a, rcid],
                  parent_groups[parent_bvdid == parent_b, rcid])
}, by = .(user_id, jv_bvdid, year, start_date, parent_a, parent_b)]
fwrite(origin, file.path(paths$interim, "pilot-origin.csv"))

# ---- 4. Coverage summaries ------------------------------------------------
cov_ijv <- origin[, .(n_emp = uniqueN(user_id),
                      n_years = uniqueN(year),
                      share_parent_origin = mean(origin %in% c("parent_a", "parent_b")),
                      share_no_history = mean(origin == "no_history")),
                  by = jv_bvdid]
cov_cell <- origin[, .(n_emp = uniqueN(user_id)), by = .(jv_bvdid, year, job_category)]
cell_survival <- rbindlist(lapply(c(3, 5, 10), function(k)
  cov_cell[, .(threshold = k, cells_total = .N, cells_surviving = sum(n_emp >= k),
               ijvs_with_3plus_cells = uniqueN(jv_bvdid[n_emp >= k]))]))

summary_tables <- list(
  match_rates   = matches[, .(n = uniqueN(orbis_id)), by = .(entity, method)],
  cov_ijv       = cov_ijv,
  cell_survival = cell_survival,
  thresholds    = cov_ijv[, .(ijvs_total = .N,
                               ijvs_ge_min_emp = sum(n_emp >= const$min_ijv_emp),
                               ijvs_ge_min_years = sum(n_years >= const$min_years))]
)
saveRDS(summary_tables, file.path(paths$interim, "pilot-summary.rds"))
message("Pilot matching complete. Render code/quarto/pilot-feasibility-report.qmd next.")
