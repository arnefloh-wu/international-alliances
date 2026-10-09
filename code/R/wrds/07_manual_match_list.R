# 07_manual_match_list.R
# Builds the worklist for manual matching of IJVs to Revelio entities (PI or
# research assistant). The list holds, in priority order:
#   1. strategic IJVs (two operating-firm parents) with an unverified
#      review-tier candidate: confirm or reject it;
#   2. strategic IJVs without any accepted candidate and at least 50 Orbis
#      employees: find the Revelio entity;
#   3. other IJVs with a review-tier candidate that would be usable: confirm;
#   4. the remaining strategic IJVs without a candidate (smaller or unknown size).
# Each row shows the JV, its parents, Orbis headcount and up to three Revelio
# candidates with their LinkedIn pages, and leaves three columns to fill in.
# Output: data/interim/manual-match-list-<version>-2026-10-09.csv (UTF-8 with
# byte-order mark, so Excel opens it correctly).
# Run on the PI's computer from the repository root:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/07_manual_match_list.R [v1|v2|v3|v4]

source("code/R/00_setup.R")
require_pkgs(c("R.utils"))
RUN_DATE <- "2026-10-09"
VERSION <- if (length(commandArgs(trailingOnly = TRUE))) commandArgs(trailingOnly = TRUE)[1] else "v3"
RUN <- if (VERSION == "v1") RUN_DATE else paste0(VERSION, "-", RUN_DATE)
f_sample <- file.path(paths$processed, sprintf("sample-ijv-%s.csv", RUN))
f_cand <- file.path(paths$raw, sprintf("revelio-companies-full-%s.csv.gz", RUN))
f_orb <- file.path(paths$raw, sprintf("orbis-full-%s.csv", RUN))
f_out <- file.path(paths$interim, sprintf("manual-match-list-%s.csv", RUN))
stopifnot(file.exists(f_sample), file.exists(f_cand), file.exists(f_orb))

s <- fread(f_sample, colClasses = list(character = "jv_bvdid"))
cand <- fread(f_cand, colClasses = list(character = c("orbis_id", "src", "entity")))
o <- fread(f_orb, select = c("jv_bvdid", "parent_name", "parent_country", "equity_share_current"),
           colClasses = list(character = c("jv_bvdid")))
par <- o[order(-equity_share_current), .(parents = paste0(parent_name, " (", parent_country, ")", collapse = "; ")), by = jv_bvdid]

# Group 1 to 3.
s[, status := fcase(tier == "review", "review_candidate", tier %chin% c("unmatched", "shared_entity_dropped"), "no_candidate", default = "other")]
w <- s[(strategic == TRUE & status %in% c("review_candidate", "no_candidate")) |
         (tier == "review" & usable == TRUE)]
w[, priority := fcase(strategic & status == "review_candidate", 1L,
                      strategic & status == "no_candidate" & !is.na(jv_employees) & jv_employees >= 50, 2L,
                      status == "review_candidate", 3L,
                      default = 4L)]

# Up to three Revelio candidates per JV: the picked one first, then the best
# other host-country candidates by name similarity.
cj <- cand[entity == "jv" & orbis_id %in% w$jv_bvdid, .(jv_bvdid = orbis_id, rcid, company_name, country, url, linkedin_url)]
cj <- unique(cj, by = c("jv_bvdid", "rcid"))
cj <- merge(cj, w[, .(jv_bvdid, jv_name, jv_country, pick = rcid)], by = "jv_bvdid")
cj <- cj[country == jv_country | is.na(country)]
cj[, sim := 1 - stringdist::stringdist(normalize_name(jv_name), normalize_name(company_name), method = "jw", p = 0.1)]
cj[, is_pick := !is.na(pick) & rcid == pick]
setorder(cj, jv_bvdid, -is_pick, -sim)
cj <- cj[, head(.SD, 3), by = jv_bvdid]
cj[, k := seq_len(.N), by = jv_bvdid]
wide <- dcast(cj, jv_bvdid ~ k, value.var = c("rcid", "company_name", "linkedin_url"))
setnames(wide, c("jv_bvdid", paste0(rep(c("candidate_rcid_", "candidate_name_", "candidate_linkedin_"), each = 3), 1:3)))
w <- merge(w, wide, by = "jv_bvdid", all.x = TRUE)
w <- merge(w, par, by = "jv_bvdid", all.x = TRUE)
w[, `:=`(decision = "", rcid_manual = "", linkedin_url = "", notes = "")]
out <- w[order(priority, -operating_parents, -jv_employees),
         .(priority, jv_bvdid, jv_name, jv_country, formation_year, website = jv_website, orbis_employees = jv_employees, parents,
           status, n_employees_revelio_if_picked = n_emp, candidate_rcid_1, candidate_name_1, candidate_linkedin_1,
           candidate_rcid_2, candidate_name_2, candidate_linkedin_2, candidate_rcid_3, candidate_name_3, candidate_linkedin_3,
           decision, rcid_manual, linkedin_url, notes)]
con <- file(f_out, "wb"); writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), con); close(con)
fwrite(out, f_out, append = TRUE, col.names = TRUE, bom = FALSE)
message(sprintf("manual worklist written: %s; %d JVs (priority 1: %d, 2: %d, 3: %d, 4: %d)", f_out, nrow(out),
                out[priority == 1, .N], out[priority == 2, .N], out[priority == 3, .N], out[priority == 4, .N]))
