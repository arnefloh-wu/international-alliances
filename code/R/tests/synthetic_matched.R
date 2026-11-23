# synthetic_matched.R
# Synthetic twin of the matched dataset (.claude/skills/data-collector, Step 3):
# IJVs, IJV-parent pairs, parent families, employee spells, career histories and
# annual Orbis headcounts, with the column names and types of the real tables
# (data/codebook.md, "Matched dataset" and "Staffing tabulations").
#
# Every value is drawn from a distribution. No real row is read, sampled,
# shuffled or perturbed, so the files carry no licensed data and may be
# committed. Ids are made up and start with SYN; every row has synthetic = TRUE.
# exposure_group is left empty: no shock exposure is simulated.
#
# The failure modes that the quality flags have to catch are seeded in known
# numbers and listed in seeded-failures-synthetic-<date>.csv. The flag code is
# code/R/functions/quality_flags.R; code/R/wrds/13_quality_flags.R synthetic
# checks that each seed is caught.
#
# Run from the repository root (a few seconds, no data needed):
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/tests/synthetic_matched.R
# Outputs: data/synthetic/<table>-synthetic-2026-11-23.parquet (tracked in Git)

source("code/R/00_setup.R")
require_pkgs("arrow")
set.seed(20261123)
SYN_DATE <- "2026-11-23"          # fixed: a rerun rewrites the same files
N_JV <- 200L
DATA_END <- as.IDate("2026-09-30")
d_syn <- "data/synthetic"         # in the repository, not under IA_DATA_DIR
dir.create(d_syn, showWarnings = FALSE)
f_syn <- function(name, ext = "parquet") file.path(d_syn, sprintf("%s-synthetic-%s.%s", name, SYN_DATE, ext))
jun30 <- function(y) as.IDate(ifelse(is.na(y), NA_character_, paste0(y, "-06-30")))
seeds <- list()
seed <- function(failure, table, flag, n, unit) seeds[[length(seeds) + 1L]] <<-
  data.table(failure = failure, table = table, flag = flag, n_expected = as.integer(n), unit = unit)

ctry <- data.table(iso2 = c("DE", "IN", "CN", "BR", "US", "FR", "JP", "NA"),
                   name = c("Germany", "India", "China", "Brazil", "United States", "France", "Japan", "Namibia"),
                   region = c("western_europe", "south_southeast_asia", "east_asia_pacific", "latin_america",
                              "north_america", "western_europe", "east_asia_pacific", "middle_east_africa"))
K10 <- c("Sales and Marketing", "Public Service and Education", "Technician", "Project and IT Specialist", "Engineer",
         "Finance", "Service Worker", "Healthcare Provider", "Operations", "Software Engineer")

# Rows of the IJV table that carry a seeded failure.
R_NAMIBIA <- 1:8; R_SHORT <- 9:14; R_PREFORM <- 15L; R_SIZE <- 16:19; R_OWN <- 20:22; R_SHARED <- 23:27
R_SEEDED <- 1:27

# ---- IJVs ----------------------------------------------------------------------
ijv <- data.table(jv_bvdid = sprintf("SYN%05d", seq_len(N_JV)), jv_name = sprintf("Synthetic Venture %05d", seq_len(N_JV)))
ijv[, jv_country := sample(ctry$iso2[1:7], N_JV, replace = TRUE)]
ijv[R_NAMIBIA, jv_country := "NA"]                                   # seed: host country code NA is Namibia
ijv[, region := ctry$region[match(jv_country, ctry$iso2)]]
ijv[, industry := sample(c("manufacturing", "services", "unknown"), N_JV, replace = TRUE, prob = c(.45, .45, .1))]
ijv[, source := sample(c("orbis", "ciq"), N_JV, replace = TRUE, prob = c(.8, .2))]
ijv[R_SEEDED, source := "orbis"]
ijv[, formation_year := sample(1995:2018, N_JV, replace = TRUE)]
ijv[, formation_year_missing := source == "ciq" & runif(N_JV) < 1 / 3]
ijv[formation_year_missing == TRUE, formation_year := 1990L]
ijv[R_SHORT, formation_year := 2025L]                                # seed: fewer than three observed years
ijv[, route := fifelse(source == "ciq", "capital_iq_current",
                       sample(c("orbis_base", "orbis_relaxed", "orbis_owner_level"), N_JV, replace = TRUE, prob = c(.3, .5, .2)))]
ijv[, admitted_by := sample(c("stake_10_20", "four_parents", "formed_before_2005", "not_active"), N_JV, replace = TRUE)]
ijv[route == "orbis_base", admitted_by := "base"]
ijv[route == "orbis_owner_level", admitted_by := "guo_country"]
ijv[route == "capital_iq_current", admitted_by := "ciq"]
ijv[, exposure_group := NA_character_]
ijv[, n_parents := sample(2:3, N_JV, replace = TRUE, prob = c(.8, .2))]
ijv[, rcid_jv := 900000L + seq_len(N_JV)]
ijv[, match_tier := sample(c("auto", "strong", "manual"), N_JV, replace = TRUE, prob = c(.86, .12, .02))]
ijv[, match_method := sample(c("id_exact", "normalized", "exact", "fuzzy", "native_exact"), N_JV, replace = TRUE)]
ijv[match_tier == "strong", match_method := sample(c("domain", "web_stem"), .N, replace = TRUE)]
ijv[match_tier == "manual", match_method := sample(c("manual_accept", "manual_replace"), .N, replace = TRUE)]
ijv[, match_score := round(runif(N_JV, .92, 1), 3)]
ijv[match_tier == "strong", match_score := round(runif(.N, .85, .97), 3)]
ijv[match_tier == "manual", match_score := NA_real_]
ijv[, manual_by := fifelse(match_tier == "manual", "claude", NA_character_)]

# ---- Parents and their Revelio families ------------------------------------------
par <- ijv[, .(parent_rank = seq_len(n_parents)), by = .(jv_bvdid, jv_country, source)]
par[, parent_label := c("A", "B", "3", "4")[parent_rank]]
par[, parent_bvdid := sprintf("SYNP%05d", .I)]
par[, parent_name := sprintf("Synthetic Parent %05d", .I)]
# Frame rule: parents from at least two countries, at least one foreign to the host.
par[, parent_country := {
  x <- sample(setdiff(ctry$iso2, jv_country[1]), .N)
  if (runif(1) < 0.7) x[sample.int(2L, 1L)] <- jv_country[1]
  x }, by = jv_bvdid]
par[, parent_entity_type := fifelse(source == "ciq", sample(c("Private Company", "Public Company"), .N, replace = TRUE),
                                    sample(c("Corporate", "Financial company", "Bank", "Insurance company"), .N, replace = TRUE, prob = c(.85, .07, .05, .03)))]
par[, equity_share_current := round(fifelse(parent_rank == 1L, runif(.N, 40, 45), fifelse(parent_rank == 2L, runif(.N, 25, 40), runif(.N, 10, 15))), 1)]
has_guo <- par$source == "orbis" & runif(nrow(par)) < 0.6
par[, parent_guo := fifelse(has_guo, sprintf("SYNG%05d", .I), parent_bvdid)]      # no GUO record: the parent is its own GUO
par[, guo_name := fifelse(has_guo, sprintf("Synthetic Group %05d", .I), parent_name)]
par[, guo_country := fifelse(has_guo & runif(.N) < 0.2, sample(ctry$iso2, .N, replace = TRUE), parent_country)]
par[source == "ciq", c("parent_guo", "guo_name", "guo_country") := NA_character_]  # Capital IQ parents carry no Orbis GUO
par[, parent_in_revelio := runif(.N) < 0.65]
par[jv_bvdid %in% ijv$jv_bvdid[c(R_OWN, R_SHARED)] & parent_rank <= 2L, parent_in_revelio := TRUE]
par[, k := fifelse(parent_in_revelio, sample(1:6, .N, replace = TRUE), 0L)]
grp <- par[, .(parent_bvdid = rep(parent_bvdid, k))]
grp[, rcid := 800000L + .I]
for (j in ijv$jv_bvdid[R_SHARED]) {                                  # seed: an entity in two parents' families
  p <- par[jv_bvdid == j & parent_rank <= 2L, parent_bvdid]
  grp <- rbind(grp, data.table(parent_bvdid = p[2], rcid = grp[parent_bvdid == p[1], rcid][1]))
}
for (j in ijv$jv_bvdid[R_OWN])                                       # seed: a parent's own entity matched as the IJV
  grp <- rbind(grp, data.table(parent_bvdid = par[jv_bvdid == j & parent_rank == 1L, parent_bvdid], rcid = ijv[jv_bvdid == j, rcid_jv]))
seed("an entity that belongs to two parents' families", "ijv", "flag_shared_family_entity", length(R_SHARED), "IJVs")
seed("a parent's own entity matched as the IJV (the JV entity sits in a parent family)", "ijv", "flag_jv_in_parent_family", length(R_OWN), "IJVs")
par[, revelio_family_size := grp[, .N, by = parent_bvdid][par, on = "parent_bvdid", N]]
par[, k := NULL]

# ---- Employee spells at the JV entities ------------------------------------------
n_people <- pmax(20L, rpois(N_JV, 40)); n_people[R_SIZE] <- 260L; n_people[R_PREFORM] <- 80L
sp <- ijv[rep(seq_len(N_JV), n_people), .(jv_bvdid, rcid = rcid_jv, formation_year, jv_country)]
sp[, user_id := 3e9 + .I]            # above 2^31, as the large Revelio ids are (stored as double)
sp[, position_id := 7e9 + .I]
lo <- as.integer(as.IDate(paste0(sp$formation_year, "-01-01"))); hi <- pmin(lo + 6000L, as.integer(jun30(2026)))
sp[, start_date := as.IDate(lo + floor(runif(.N) * (hi - lo + 1L)), origin = "1970-01-01")]
sp[, end_date := start_date + sample(200:4000, .N, replace = TRUE)]
sp[end_date > DATA_END | runif(.N) < 0.25, end_date := NA]
pre <- sp[, .I[jv_bvdid == ijv$jv_bvdid[R_PREFORM]]][1:40]            # seed: positions that start before the formation year
sp[pre, `:=`(start_date = as.IDate(lo[pre] - sample(4000:5400, 40L), origin = "1970-01-01"), end_date = as.IDate(NA))]   # 11 to 15 years earlier, still held
sp[, ongoing := is.na(end_date)]
sp[, first_reference_year := pmax(formation_year, year(start_date) + (start_date > jun30(year(start_date))))]
sp[, last_reference_year := fifelse(ongoing, 2026L, year(end_date) - as.integer(end_date < jun30(year(end_date))))]
sp[, n_reference_dates := as.integer(last_reference_year - first_reference_year + 1L)]
sp <- sp[n_reference_dates >= 1L]                                    # as in the real table: a spell covers a 30 June
seed("a position that starts before the formation year", "spells", "flag_pre_formation", 40L, "positions")
i_a <- sp[, .I[jv_bvdid %in% ijv$jv_bvdid[100:150]]]; i_b <- sp[, .I[jv_bvdid %in% ijv$jv_bvdid[151:200]]]
i_multi <- sample(i_a, 12L); sp[i_multi, user_id := sp$user_id[sample(i_b, 12L)]]   # seed: a person at two sample IJVs
seed("a person at two sample IJVs", "spells", "flag_multi_ijv_person", 24L, "positions (12 people)")
host_name <- ctry$name[match(sp$jv_country, ctry$iso2)]
sp[, country := fifelse(runif(.N) < 0.88, host_name, sample(ctry$name, .N, replace = TRUE))]
sp[, seniority := sample(1:7, .N, replace = TRUE, prob = c(.3, .25, .18, .12, .08, .05, .02))]
sp[, role_k17000_v3 := sprintf("syn role %04d", sample(2000L, .N, replace = TRUE))]
sp[, function_role_k10 := sample(K10, .N, replace = TRUE)]
sp[, role_k50_v3 := sprintf("syn k50 %02d", sample(50L, .N, replace = TRUE))]

# IJV columns that the real table derives from the spells.
yrs <- unique(sp[, .(jv_bvdid, a = first_reference_year, b = last_reference_year)])[, .(year = seq.int(a, b)), by = .(jv_bvdid, a, b)]
agg <- sp[, .(n_emp = uniqueN(user_id), first_start = min(year(start_date)),
              function_cells_5 = sum(table(function_role_k10) >= 5L), seniority_cells_5 = sum(table(seniority) >= 5L)), by = jv_bvdid]
agg <- merge(agg, yrs[, .(n_years = uniqueN(year)), by = jv_bvdid], by = "jv_bvdid")
ijv <- merge(ijv, agg, by = "jv_bvdid", sort = FALSE)
stopifnot(nrow(ijv) == N_JV, ijv[R_SHORT, all(n_years < const$min_years)], ijv[-R_SHORT, all(n_years >= const$min_years)])
seed("an IJV with fewer than three observed years", "ijv", "flag_short_panel", length(R_SHORT), "IJVs")
ijv[, jv_employees_orbis := fifelse(source == "orbis" & runif(N_JV) < 0.7, as.integer(round(n_emp * runif(N_JV, .8, 3))), NA_integer_)]
ijv[R_SIZE, jv_employees_orbis := 10L]                               # seed: Revelio staff above 20 times the Orbis headcount
stopifnot(ijv[R_SIZE, all(n_emp > 200L)])
seed("a Revelio headcount more than 20 times the Orbis headcount", "ijv", "flag_size_mismatch", length(R_SIZE), "IJVs")
ijv[, operating_parents := vapply(n_parents, function(n) sample(0:n, 1L), integer(1))]
ijv[, strategic := operating_parents >= 2L]
ijv[, flag_pre_formation_10y := first_start < formation_year - 10L]
ijv[, flag_holding_vehicle := FALSE]
ijv[, jv_website := sprintf("syn%05d.example", seq_len(N_JV))]
ijv[, jv_lei := fifelse(runif(N_JV) < 0.3, sprintf("SYNLEI%014d", seq_len(N_JV)), NA_character_)]
for (r in 1:2) {
  p <- par[parent_rank == r][ijv, on = "jv_bvdid"]
  set(ijv, j = sprintf("parent_%s_%s", c("a", "b")[r], c("name", "country", "share", "bvdid", "in_revelio")),
      value = p[, .(parent_name, parent_country, equity_share_current, parent_bvdid, parent_in_revelio)])
}
ijv[, first_start := NULL]
setcolorder(ijv, c("jv_bvdid", "jv_name", "jv_country", "region", "industry", "formation_year", "formation_year_missing", "source", "route",
                   "admitted_by", "exposure_group", "n_parents", "rcid_jv", "match_tier", "match_method", "match_score", "manual_by", "n_emp",
                   "n_years", "function_cells_5", "seniority_cells_5", "jv_employees_orbis", "operating_parents", "strategic",
                   "flag_pre_formation_10y", "flag_holding_vehicle", "jv_website", "jv_lei"))
seed("host country code NA (Namibia) kept as a value", "ijv", "jv_country == 'NA'", length(R_NAMIBIA), "IJVs")

# ---- Career histories of the spell users -----------------------------------------
hist_jv <- sp[, .(user_id, position_id, rcid = as.numeric(rcid), ultimate_parent_rcid = as.numeric(rcid), start_date, end_date,
                  country, seniority, role_k17000_v3, job_category = function_role_k10)]
setorder(sp, user_id, start_date)
users <- sp[, .SD[1], by = user_id, .SDcols = c("jv_bvdid", "start_date", "jv_country")]
setnames(users, "start_date", "hire_date")
users[, n_prior := fifelse(runif(.N) < 0.55, sample(1:3, .N, replace = TRUE), 0L)]   # the rest: history not observed
pr <- users[n_prior > 0L, .(j = seq_len(n_prior)), by = .(user_id, jv_bvdid, hire_date, jv_country)]
pr[, `:=`(gap = sample(0:1500, .N, replace = TRUE), dur = sample(300:2500, .N, replace = TRUE))]
pr[, end_date := hire_date - cumsum(gap) - shift(cumsum(dur), fill = 0L), by = user_id]
pr[, start_date := end_date - dur]
pr[j == 1L & runif(.N) < 0.05, end_date := NA]                        # a prior position still held (secondment)
famj <- merge(par[, .(jv_bvdid, parent_bvdid)], grp, by = "parent_bvdid")[!ijv[, .(jv_bvdid, rcid = rcid_jv)], on = .(jv_bvdid, rcid)]
pr[, rcid := as.numeric(sample(700001:703000, .N, replace = TRUE))]   # independent employers
pr[, is_par := jv_bvdid %in% famj$jv_bvdid & runif(.N) < 0.08]         # parent-origin hires
pr[is_par == TRUE, rcid := { r <- famj$rcid[famj$jv_bvdid == .BY$jv_bvdid]; as.numeric(r[sample.int(length(r), .N, replace = TRUE)]) }, by = jv_bvdid]
host_name <- ctry$name[match(pr$jv_country, ctry$iso2)]
pr[, country := fifelse(runif(.N) < 0.62, host_name, sample(ctry$name, .N, replace = TRUE))]
n_unmapped <- as.integer(round(0.16 * nrow(pr))); n_cna <- as.integer(round(0.05 * nrow(pr)))
i_h <- sample(pr[, .I[is_par == FALSE]], n_unmapped + n_cna + 25L + 6L)
i_unm <- i_h[seq_len(n_unmapped)]; i_cna <- i_h[n_unmapped + seq_len(n_cna)]
i_sna <- i_h[n_unmapped + n_cna + 1:25]; i_dup <- i_h[n_unmapped + n_cna + 25L + 1:6]
pr[i_unm, rcid := NA_real_]                                           # seed: employer not mapped to a Revelio company
pr[i_cna, country := NA_character_]                                   # seed: country missing
pr[i_sna, start_date := NA]                                           # seed: missing start dates
pr[, position_id := 8e9 + .I]
hist <- rbind(hist_jv, pr[, .(user_id, position_id, rcid, ultimate_parent_rcid = rcid, start_date, end_date, country,
                              seniority = sample(1:7, .N, replace = TRUE), role_k17000_v3 = sprintf("syn role %04d", sample(2000L, .N, replace = TRUE)),
                              job_category = sample(K10, .N, replace = TRUE))])
hist <- rbind(hist, hist[position_id %in% pr$position_id[i_dup]])     # seed: repeated position_id
seed("employer not mapped (rcid missing)", "histories", "flag_employer_unmapped", n_unmapped, "positions")
seed("country missing", "histories", "flag_country_missing", n_cna, "positions")
seed("missing start dates", "histories", "flag_start_missing", 25L, "positions")
seed("repeated position_id", "histories", "flag_dup_position", 6L, "positions")
seed("open-ended positions", "histories", "flag_open_ended", hist[, sum(is.na(end_date))], "positions")

# ---- Row-level failures in the spell table ------------------------------------------
clean <- setdiff(sp[, .I[!jv_bvdid %in% ijv$jv_bvdid[R_SEEDED]]], which(sp$user_id %in% sp$user_id[duplicated(sp$user_id)]))
i_s <- sample(clean, 15L + 7L + 150L + 10L)
sp[i_s[1:15], start_date := NA]                                       # seed: missing start dates
sp[i_s[16:22], `:=`(end_date = start_date - 30L, ongoing = FALSE)]    # seed: end before start
sp[i_s[23:172], country := NA_character_]                             # seed: country missing
sp <- rbind(sp, sp[i_s[173:182]])                                     # seed: repeated position_id
seed("missing start dates", "spells", "flag_start_missing", 15L, "positions")
seed("end date before start date", "spells", "flag_end_before_start", 7L, "positions")
seed("country missing", "spells", "flag_country_missing", 150L, "positions")
seed("repeated position_id", "spells", "flag_dup_position", 10L, "positions")
seed("open-ended positions", "spells", "flag_open_ended", sp[, sum(ongoing)], "positions")
sp[, c("formation_year", "jv_country") := NULL]
setcolorder(sp, c("jv_bvdid", "rcid", "user_id", "position_id", "start_date", "end_date", "ongoing", "first_reference_year",
                  "last_reference_year", "n_reference_dates", "country", "seniority", "role_k17000_v3", "function_role_k10", "role_k50_v3"))
sp[, `:=`(first_reference_year = as.numeric(first_reference_year), last_reference_year = as.numeric(last_reference_year))]

# ---- Annual Orbis headcounts ---------------------------------------------------------
hc <- ijv[source == "orbis" & !is.na(jv_employees_orbis) & formation_year <= 2024L,
          .(closdate_year = seq.int(max(2015L, formation_year), 2024L), base = jv_employees_orbis,
            conscode = sample(c("U1", "U2"), 1L, prob = c(.75, .25)), orbis_library = sample(c("large", "medium"), 1L)), by = jv_bvdid]
hc[, `:=`(filing_type = sample(c("Local registry filing", "Annual report"), .N, replace = TRUE, prob = c(.9, .1)),
          closdate = as.IDate(paste0(closdate_year, "-12-31")), nr_months = "12",
          empl = pmax(1, round(base * runif(.N, .85, 1.15))))]
i_two <- sample(nrow(hc), 20L)                                        # seed: two account rows for one entity and year
hc <- rbind(hc, copy(hc[i_two])[, `:=`(conscode = "C1", filing_type = "Annual report", empl = empl * 3)])
seed("two account rows for one entity and year", "headcounts", "flag_multi_account_row", 40L, "records (20 entity-years)")
hc <- hc[, .(jv_bvdid, conscode, filing_type, closdate, closdate_year = as.numeric(closdate_year), nr_months, empl, orbis_library)]

# ---- Write ----------------------------------------------------------------------------
out <- list(`ijv-matched` = ijv, `ijv-parents` = par[, .(jv_bvdid, parent_rank, parent_label, parent_bvdid, parent_name, parent_country,
                                                           parent_entity_type, equity_share_current, parent_guo, guo_name, guo_country,
                                                           parent_in_revelio, revelio_family_size)],
            `parent-groups` = grp, `ijv-employee-spells` = sp, `revelio-histories` = hist, `orbis-jv-headcounts` = hc)
for (n in names(out)) {
  d <- copy(out[[n]])
  for (v in names(d)) if (inherits(d[[v]], "IDate")) set(d, j = v, value = as.Date(d[[v]]))
  d[, synthetic := TRUE]
  arrow::write_parquet(d, f_syn(n))
  message(sprintf("%-22s %6d rows, %2d columns -> %s", n, nrow(d), ncol(d), f_syn(n)))
}
fwrite(rbindlist(seeds), f_syn("seeded-failures", "csv"))
message("seeded failures: ", length(seeds), " -> ", f_syn("seeded-failures", "csv"))
