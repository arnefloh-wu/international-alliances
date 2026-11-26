# 12_rater_onet_comparison.R
# Convergent-validity check of the O*NET contingency scores against the rater
# scores at the role_k50 grain (pre-analysis plan pap-v1.0, A2.4 and robustness
# set item 6; rater procedures of 2026-11-25 in docs/decisions.md: "O*NET scores
# aggregated to role_k50 weighted by taxonomy entries, compared by Spearman
# correlation"). The plan sets no threshold for the correlation; it is reported.
#
# Aggregation: for each role_k50 group, the mean of the occupation scores of
# 07_contingency_scores.R over the O*NET codes in the group, weighted by the
# number of role_k17000_v3 taxonomy entries per code within the group (the same
# weights that rank the occupations shown to the raters in 10_rater_sheet.R).
# Imputed occupation scores are kept, as in the main models.
#
# Planned comparisons: rater coord_dependence with O*NET coord_dependence, and
# rater local_embeddedness with O*NET local_embeddedness. The cross-scale
# correlations are printed as descriptive context only.
#
# Independence: inputs are the taxonomy, the O*NET occupation scores and the rater
# scores. No position, staffing or exposure file is read.
#
# Inputs:  data/raw/revelio-role-lookup-v3-2026-11-25.parquet           (taxonomy only)
#          data/processed/contingency-scores-occupation-v1-2026-11-25.csv
#          data/interim/rater-scores-2026-11-26.csv                     (11_rater_icc.R)
# Outputs: data/interim/rater-onet-groups-2026-11-26.csv                (50 groups, both score sets)
#          data/interim/rater-onet-comparison-2026-11-26.md             (correlations)
# Run:     "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/12_rater_onet_comparison.R

source("code/R/00_setup.R")
require_pkgs(c("arrow", "data.table"))
RUN      <- "2026-11-26"
f_lookup <- file.path(paths$raw, "revelio-role-lookup-v3-2026-11-25.parquet")
f_occ    <- file.path(paths$processed, "contingency-scores-occupation-v1-2026-11-25.csv")
f_rater  <- file.path(paths$interim, sprintf("rater-scores-%s.csv", RUN))
f_grp    <- file.path(paths$interim, sprintf("rater-onet-groups-%s.csv", RUN))
f_rep    <- file.path(paths$interim, sprintf("rater-onet-comparison-%s.md", RUN))
SC       <- c("coord_dependence", "local_embeddedness")
is_occ   <- function(x) !is.na(x) & grepl("^[0-9]{2}-[0-9]{4}[.][0-9]{2}$", x)

lk  <- data.table::as.data.table(arrow::read_parquet(f_lookup, col_select = c("role_k17000_v3", "role_k50_v3", "onet_code")))
occ <- data.table::fread(f_occ, select = c("onet_code", "score_imputed", SC))
rat <- data.table::fread(f_rater)
stopifnot(all(paste0(SC, "_rater") %in% names(rat)), nrow(rat) == 50L)

cnt <- lk[is_occ(onet_code), .(w = .N), by = .(role_k50_v3, onet_code)]
cnt <- merge(cnt, occ, by = "onet_code", all.x = TRUE)
n_noscore <- cnt[is.na(coord_dependence), sum(w)]
grp <- cnt[!is.na(coord_dependence), .(
  n_codes = .N, n_entries = sum(w), share_imputed = sum(w * score_imputed) / sum(w),
  coord_dependence_onet = sum(w * coord_dependence) / sum(w),
  local_embeddedness_onet = sum(w * local_embeddedness) / sum(w)), by = role_k50_v3]
grp <- merge(rat, grp, by.x = "group_label", by.y = "role_k50_v3", all.x = TRUE)
stopifnot(nrow(grp) == 50L, !anyNA(grp$coord_dependence_onet))
data.table::fwrite(grp, f_grp)

sp <- function(x, y) { t <- suppressWarnings(cor.test(x, y, method = "spearman", exact = FALSE)); c(rho = unname(t$estimate), p = t$p.value) }
tab <- data.table::rbindlist(lapply(SC, function(r) data.table::rbindlist(lapply(SC, function(o) {
  v <- sp(grp[[paste0(r, "_rater")]], grp[[paste0(o, "_onet")]])
  data.table::data.table(rater = r, onet = o, planned = r == o, rho = v[["rho"]], p = v[["p"]], n = nrow(grp))
}))))

out <- c(sprintf("# Rater scores and O*NET scores at role_k50, %s", RUN), "",
         "Script: code/R/12_rater_onet_comparison.R. O*NET occupation scores averaged per role_k50 group, weighted by taxonomy entries; imputed occupation scores kept.",
         sprintf("Groups: %d; O*NET codes per group: %d to %d; taxonomy entries without a score: %d; mean share of imputed weight: %.3f.",
                 nrow(grp), min(grp$n_codes), max(grp$n_codes), n_noscore, mean(grp$share_imputed)), "",
         "| Rater scale | O*NET score | Planned | Spearman rho | p | Groups |", "|---|---|---|---|---|---|",
         tab[, sprintf("| `%s` | `%s` | %s | %.3f | %.3g | %d |", rater, onet, ifelse(planned, "yes", "descriptive"), rho, p, n)], "",
         "The plan sets no threshold for these correlations. The rater scale for coordination asks about coordination with the parents only, whereas the O*NET elements measure coordination in general, so a lower correlation on that scale is expected by design (rater instrument, Part B).")
writeLines(out, f_rep)
cat(out, sep = "\n")
