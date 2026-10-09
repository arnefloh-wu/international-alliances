# 01_pilot_matching.R
# Stage 4: match approx. 100 pilot IJVs and their parents from Orbis to
# Revelio, compute coverage, and write the inputs for the pilot report.

source("code/R/00_setup.R")

# Pilot: "main" (default) or "large" (second pilot, gate 4). Inputs and
# outputs of the large pilot carry the tag "large-".
PILOT_ID <- if (length(commandArgs(trailingOnly = TRUE))) commandArgs(trailingOnly = TRUE)[1] else "main"
stopifnot(PILOT_ID %in% c("main", "large"))
TAG <- if (PILOT_ID == "main") "" else paste0(PILOT_ID, "-")
out <- function(name) file.path(paths$interim, paste0("pilot-", TAG, name))

# ---- 1. Load exports ------------------------------------------------------
orbis_file   <- tail(sort(list.files(paths$raw, paste0("^orbis-pilot-", TAG, "[0-9].*[.]csv$"), full.names = TRUE)), 1)
rev_co_file  <- tail(sort(list.files(paths$raw, paste0("^revelio-companies-", TAG, "[0-9].*[.]csv$"), full.names = TRUE)), 1)
rev_pos_file <- tail(sort(list.files(paths$raw, paste0("^revelio-positions-", TAG, "[0-9].*[.](parquet|csv)$"), full.names = TRUE)), 1)
stopifnot(length(orbis_file) == 1, length(rev_co_file) == 1, length(rev_pos_file) == 1)

orbis <- fread(orbis_file)                       # one row per JV-parent pair
rev_co <- fread(rev_co_file)
if (grepl("parquet$", rev_pos_file)) require_pkgs("arrow")
rev_pos <- if (grepl("parquet$", rev_pos_file)) as.data.table(arrow::read_parquet(rev_pos_file)) else fread(rev_pos_file)

# The WRDS extraction (code/R/wrds/02_wrds_pilot_extract.R) builds the frame
# from current Orbis ownership, so it carries the current equity share, not
# the share at formation (decision 2026-10-08). The current share is used in
# its place and the substitution is recorded in data/codebook.md. A person
# with spells at two candidate JV entities is pulled twice; keep each
# position once. The candidate file lists a company once per Orbis entity it
# was proposed for; the matcher needs each company once.
if (!"equity_share_formation" %in% names(orbis) && "equity_share_current" %in% names(orbis))
  orbis[, equity_share_formation := equity_share_current]
if ("position_id" %in% names(rev_pos)) rev_pos <- unique(rev_pos, by = "position_id")
rev_co_raw <- copy(rev_co)
rev_co <- unique(rev_co, by = "rcid")

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
# Global ultimate owners (GUO) of parents that are holding or investment
# vehicles: their Revelio entity and group count as the parent's group.
gu_ent <- if ("guo_name" %in% names(orbis))
  unique(orbis[guo_bvdid != parent_bvdid & !is.na(guo_name) & guo_name != "",
               .(orbis_id = guo_bvdid, orbis_name = guo_name, orbis_country = guo_country)]) else data.table()
gu_matches <- if (nrow(gu_ent)) match_entities(gu_ent, rev_ent, const$jw_threshold)[, entity := "guo"] else data.table()
matches <- rbindlist(list(jv_matches, pa_matches, gu_matches), fill = TRUE)
fwrite(matches, out("matches.csv"))
fwrite(matches[needs_review == TRUE], out("match-review.csv"))

# Parent groups: the parent's own Revelio entity and its GUO's entity
# (parent_core), extended to their whole Revelio family: the Revelio ultimate
# parent of each core entity and every company under it.
accepted <- matches[needs_review == FALSE | score >= 0.97]
best_pa <- accepted[entity == "parent"][order(-score)][, .SD[1], by = orbis_id]
best_gu <- accepted[entity == "guo"][order(-score)][, .SD[1], by = orbis_id]
parent_core <- unique(rbind(
  best_pa[, .(parent_bvdid = orbis_id, rcid)],
  if (nrow(best_gu)) merge(unique(orbis[, .(parent_bvdid, guo_bvdid)]), best_gu[, .(guo_bvdid = orbis_id, rcid)],
                           by = "guo_bvdid")[, .(parent_bvdid, rcid)]))
core_up <- merge(parent_core, rev_co[, .(rcid, up = ultimate_parent_rcid)], by = "rcid", all.x = TRUE)
core_up[is.na(up), up := rcid]
parent_groups <- merge(unique(core_up[, .(parent_bvdid, up)]),
                       rev_co[!is.na(ultimate_parent_rcid), .(up = ultimate_parent_rcid, rcid)],
                       by = "up", allow.cartesian = TRUE)[, .(parent_bvdid, rcid)]
parent_groups <- unique(rbind(parent_groups, parent_core, core_up[, .(parent_bvdid, rcid = up)]))
parent_groups <- parent_groups[!is.na(rcid)]
fwrite(parent_groups, out("parent-groups.csv"))

# JV matches: the JV is a host-country legal entity, so a candidate in another
# country is rejected (a missing Revelio country is accepted), and a candidate
# that is a parent's or a GUO's own entity is rejected, because the JV would
# then inherit the parent's workforce. Membership in a parent's Revelio group
# is not a reason to reject: Revelio often files a JV under one parent.
# Rejections are kept for gate 4.
jv_cand <- accepted[entity == "jv"]
jv_cand[, reject := fcase(rcid %in% parent_core$rcid, "is_parent_entity",
                          same_country %in% FALSE, "other_country",
                          default = "")]
fwrite(jv_cand[reject != ""], out("jv-rejected-matches.csv"))
best_jv <- jv_cand[reject == ""][order(-(same_country %in% TRUE), -score)][, .SD[1], by = orbis_id]
best <- rbindlist(list(best_jv[, -"reject"], best_pa), use.names = TRUE)

# Review tier: website-domain, website-stem and two-token routes for JVs
# without an automatic match (rules in review_tier_candidates()). These go to
# the PI review file and enter only the upper-bound coverage figures.
jv_tab <- unique(orbis[, .(orbis_id = jv_bvdid, orbis_name = jv_name, orbis_country = jv_country)], by = "orbis_id")
review_jv <- if ("match_key" %in% names(rev_co_raw))
  review_tier_candidates(rev_co_raw[entity == "jv" & !orbis_id %in% best_jv$orbis_id], jv_tab, parent_groups$rcid,
                         orbis[, .(orbis_id = jv_bvdid, parent_name)]) else data.table()
fwrite(review_jv, out("jv-review-tier.csv"))

# ---- 3. Workforce coverage per matched JV ---------------------------------
# Run once per matching tier: "auto" uses the automatic name matches only;
# "auto_plus_strong" adds review-tier candidates from a website route with a
# close name (likely correct); "auto_plus_review" adds all review-tier
# candidates and is an upper bound until the PI has checked them.
formation <- unique(orbis[, .(jv_bvdid, formation_year)], by = "jv_bvdid")
host <- unique(orbis[, .(jv_bvdid, jv_country)], by = "jv_bvdid")
hist <- rev_pos[, .(user_id, rcid, start_date = as.IDate(start_date),
                    end_date = fifelse(is.na(end_date), as.IDate(Sys.Date()), as.IDate(end_date)),
                    country)]
setorder(hist, user_id, -end_date)

coverage <- function(jv_rcid, tier) {
  pos <- merge(rev_pos, jv_rcid, by = "rcid")
  pos[, `:=`(start_date = as.IDate(start_date),
             end_date = fifelse(is.na(end_date), as.IDate(Sys.Date()), as.IDate(end_date)))]
  years <- seq(min(year(pos$start_date), na.rm = TRUE), year(Sys.Date()))
  ref <- as.IDate(paste0(years, "-", const$reference_date))
  cell_years <- rbindlist(lapply(seq_along(years), function(i) {
    pos[start_date <= ref[i] & end_date >= ref[i],
        .(year = years[i], jv_bvdid, user_id, job_category, seniority, start_date)]
  }))
  # Only years from the JV's formation (incorporation) year onward count;
  # earlier spells at the matched entity belong to a predecessor or a mismatch.
  cell_years <- merge(cell_years, formation, by = "jv_bvdid")
  pre_formation <- cell_years[year < formation_year, .(person_years_pre_formation = .N), by = jv_bvdid]
  cell_years <- cell_years[year >= formation_year][, formation_year := NULL]

  cell_years <- merge(cell_years, orbis[, .(jv_bvdid, parent_bvdid, parent_country, equity_share_formation)],
                      by = "jv_bvdid", allow.cartesian = TRUE)
  # Parent A = larger equity share (current share in the WRDS frame).
  setorder(cell_years, jv_bvdid, -equity_share_formation, parent_country)
  cell_years[, parent_rank := rowid(jv_bvdid, year, user_id)]
  # Two-parent origin classification for the pilot; 3-parent JVs use the two largest.
  origin <- cell_years[parent_rank <= 2][
    , .(parent_a = parent_bvdid[1], parent_b = parent_bvdid[2]), by = .(jv_bvdid, year, user_id)]
  origin <- merge(origin, unique(cell_years[, .(jv_bvdid, year, user_id, job_category, seniority, start_date)]),
                  by = c("jv_bvdid", "year", "user_id"))
  # Classify each JV spell once. A prior position counts if it started before
  # the JV spell and was still held within origin_window years before it; an
  # ongoing parent position (secondment) therefore counts as parent origin.
  spells <- unique(origin[, .(user_id, jv_bvdid, jv_start = start_date, parent_a, parent_b)])
  spells <- merge(spells, host, by = "jv_bvdid", all.x = TRUE)
  prior <- hist[!rcid %in% jv_rcid$rcid,
                .(user_id, p_rcid = rcid, p_start = start_date, p_end = end_date, p_country = country)]
  pr <- merge(spells, prior, by = "user_id", allow.cartesian = TRUE)
  pr <- pr[p_start < jv_start & p_end >= jv_start - const$origin_window * 365L]
  setorder(pr, user_id, jv_bvdid, jv_start, -p_end)
  cls <- pr[, {
    ga <- parent_groups$rcid[parent_groups$parent_bvdid == parent_a[1]]
    gb <- parent_groups$rcid[parent_groups$parent_bvdid == parent_b[1]]
    .(origin = classify_origin(p_rcid, ga, gb, p_country[1], jv_country[1]))
  }, by = .(user_id, jv_bvdid, jv_start)]
  spells <- merge(spells, cls, by = c("user_id", "jv_bvdid", "jv_start"), all.x = TRUE)
  spells[is.na(origin), origin := "no_history"]
  origin <- merge(origin, spells[, .(user_id, jv_bvdid, start_date = jv_start, origin)],
                  by = c("user_id", "jv_bvdid", "start_date"), all.x = TRUE)
  origin <- merge(origin, orbis[, .(n_parents = uniqueN(parent_bvdid)), by = jv_bvdid], by = "jv_bvdid")
  fwrite(origin, out(sprintf("origin-%s.csv", tier)))

  # ---- 4. Coverage summaries ----------------------------------------------
  cov_ijv <- origin[, .(n_emp = uniqueN(user_id),
                        n_years = uniqueN(year),
                        share_parent_origin = mean(origin %in% c("parent_a", "parent_b")),
                        share_no_history = mean(origin == "no_history")),
                    by = jv_bvdid]
  survival <- function(cells, dim) rbindlist(lapply(c(3, 5, 10), function(k)
    cells[, .(dimension = dim, threshold = k, cells_total = .N, cells_surviving = sum(n_emp >= k),
              ijvs_with_surviving_cell = uniqueN(jv_bvdid[n_emp >= k]))]))
  cell_survival <- rbind(
    survival(origin[, .(n_emp = uniqueN(user_id)), by = .(jv_bvdid, year, job_category)], "function"),
    survival(origin[, .(n_emp = uniqueN(user_id)), by = .(jv_bvdid, year, seniority)], "seniority"))
  list(
    tier          = tier,
    pre_formation = pre_formation,
    origin_shares = origin[, .N, by = origin][, share := N / sum(N)][order(-N)],
    cov_ijv       = cov_ijv,
    cell_survival = cell_survival,
    thresholds    = data.table(
      jvs_matched      = uniqueN(jv_rcid$jv_bvdid),
      jvs_with_data    = nrow(cov_ijv),
      jvs_ge_min_emp   = cov_ijv[n_emp >= const$min_ijv_emp, .N],
      jvs_ge_min_years = cov_ijv[n_years >= const$min_years, .N],
      jvs_usable       = cov_ijv[n_emp >= const$min_ijv_emp & n_years >= const$min_years, .N])
  )
}

auto_rcid <- best_jv[, .(jv_bvdid = orbis_id, rcid)]
tiers <- list(auto = auto_rcid,
              auto_plus_strong = rbind(auto_rcid, if (nrow(review_jv)) review_jv[strong == TRUE, .(jv_bvdid = orbis_id, rcid)]),
              auto_plus_review = rbind(auto_rcid, if (nrow(review_jv)) review_jv[, .(jv_bvdid = orbis_id, rcid)]))
fwrite(rbindlist(tiers, idcol = "tier"), out("jv-rcids.csv"))
by_tier <- lapply(names(tiers), function(t) coverage(tiers[[t]], t))
names(by_tier) <- names(tiers)

# Frame size for projections (eligible JVs in the WRDS ownership frame).
frame_file <- tail(sort(list.files(paths$interim, "^wrds-ijv-frame-[0-9].*[.]csv$", full.names = TRUE)), 1)
frame_eligible <- if (length(frame_file)) {
  fr <- fread(frame_file, select = c("jv_bvdid", "excl_jv"), colClasses = "character")
  uniqueN(fr[is.na(excl_jv) | excl_jv == "", jv_bvdid])
} else NA_integer_

summary_tables <- list(
  match_rates    = best[, .(n = uniqueN(orbis_id)), by = .(entity, method)],
  match_totals   = data.table(entity = c("jv", "parent", "guo"),
                              in_pilot = c(uniqueN(orbis$jv_bvdid), uniqueN(orbis$parent_bvdid), nrow(gu_ent)),
                              any_candidate = c(uniqueN(matches[entity == "jv", orbis_id]),
                                                uniqueN(matches[entity == "parent", orbis_id]),
                                                uniqueN(matches[entity == "guo", orbis_id])),
                              accepted = c(uniqueN(best_jv$orbis_id), uniqueN(best_pa$orbis_id), uniqueN(best_gu$orbis_id)),
                              review_tier = c(nrow(review_jv), NA_integer_, NA_integer_)),
  parents_in_group = unique(orbis[, .(jv_bvdid, parent_bvdid)])[
    , .(has_group = parent_bvdid %in% parent_groups$parent_bvdid), by = .(jv_bvdid, parent_bvdid)][
    , .(parents = .N, parents_with_group = sum(has_group)), by = jv_bvdid],
  review_routes  = if (nrow(review_jv)) review_jv[, .N, by = .(method, strong)] else data.table(),
  jv_rejected    = jv_cand[reject != "", .(n_candidates = .N, n_jvs = uniqueN(orbis_id)), by = reject],
  frame_eligible = frame_eligible,
  pilot_n        = uniqueN(orbis$jv_bvdid),
  by_tier        = by_tier,
  # Fields used by the report for the automatic tier.
  cov_ijv        = by_tier$auto$cov_ijv,
  cell_survival  = by_tier$auto$cell_survival,
  thresholds     = by_tier$auto$thresholds
)
saveRDS(summary_tables, out("summary.rds"))
message("Pilot matching complete. Render code/quarto/pilot-feasibility-report.qmd next.")
