# check_panel_recompute.R
# Independent recomputation of the staffing-frame classification of
# 02_build_panel.R for a random sample of IJVs (seed 20261126), written as a
# plain loop over hires without the vectorized helpers of panel_build.R. It
# compares the category of every sampled hire for the origin windows of one,
# three and five years and the three-year entrant flag, and reports agreement
# counts only (no category count, no breakdown by exposure, domain, level,
# score or year; real_data_lock).
#
# Run from the repository root after 02_build_panel.R (a few minutes):
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/tests/check_panel_recompute.R [n_ijv]
# Output: data/interim/panel-recompute-check-v1-2026-11-26.md (agreement counts)

source("code/R/00_setup.R")
require_pkgs(c("arrow", "countrycode"))
N_IJV <- if (length(commandArgs(TRUE))) as.integer(commandArgs(TRUE)[1]) else 150L
RUN <- "v3-2026-10-09"
set.seed(20261126)
ijv <- fread(file.path(paths$processed, sprintf("ijv-matched-%s.csv", RUN)), colClasses = list(character = "jv_bvdid"), na.strings = "",
             select = c("jv_bvdid", "jv_country", "rcid_jv"))
par <- fread(file.path(paths$processed, sprintf("ijv-parents-%s.csv", RUN)), colClasses = list(character = c("jv_bvdid", "parent_bvdid")),
             na.strings = "", select = c("jv_bvdid", "parent_bvdid", "parent_rank"))
grp <- fread(file.path(paths$interim, sprintf("full-parent-groups-%s.csv", RUN)), colClasses = list(character = "parent_bvdid"))
S <- sample(ijv$jv_bvdid, N_IJV)
H <- as.data.table(arrow::read_parquet(file.path(paths$interim, "panel-hires-v1.parquet"),
       col_select = c("jv_bvdid", "user_id", "hire_date", "year", "cat_w1", "cat_w3", "cat_w5", "entrant_e3")))[jv_bvdid %chin% S]
users <- unique(H$user_id)
hist <- rbindlist(lapply(list.files(file.path(paths$raw, "revelio-histories-full-2026-10-09"), "[.]parquet$", full.names = TRUE), function(f)
  as.data.table(arrow::read_parquet(f, col_select = c("user_id", "position_id", "rcid", "start_date", "end_date", "country")))[user_id %in% users]))
hist <- hist[!duplicated(position_id)]
cty <- unique(hist$country[!is.na(hist$country)])
iso <- setNames(suppressWarnings(countrycode::countrycode(cty, "country.name", "iso2c", warn = FALSE)), cty)
hist[, iso := unname(iso[country])]
byu <- split(hist, hist$user_id)
edu <- rbindlist(lapply(list.files(file.path(paths$raw, "revelio-education-full-2026-11-23"), "[.]parquet$", full.names = TRUE), function(f)
  as.data.table(arrow::read_parquet(f, col_select = c("user_id", "education_number", "enddate", "university_country")))[user_id %in% users]))
edu <- edu[!duplicated(edu[, .(user_id, education_number)])]
edu_by <- split(edu, edu$user_id)

fam_of <- function(j) {             # rcid -> parent rank, the larger-equity parent first; the JV's own entity removed
  p <- par[jv_bvdid == j][order(parent_rank)]
  out <- integer(); for (i in seq_len(nrow(p))) { r <- grp[parent_bvdid == p$parent_bvdid[i], rcid]; r <- setdiff(r, as.integer(names(out))); out <- c(out, setNames(rep(p$parent_rank[i], length(r)), r)) }
  out[setdiff(names(out), as.character(ijv[jv_bvdid == j, rcid_jv]))]
}
classify_one <- function(h, fam, rcid_jv, host, w) {
  x <- byu[[as.character(h$user_id)]]
  if (is.null(x)) return("not_obs")
  x <- x[!is.na(start_date) & (is.na(end_date) | end_date >= start_date) & (is.na(rcid) | rcid != rcid_jv) & start_date < h$hire_date]
  x <- x[is.na(end_date) | as.integer(h$hire_date) - as.integer(end_date) <= w * 365L]
  if (!nrow(x)) return("not_obs")
  x[, par := !is.na(rcid) & as.character(rcid) %in% names(fam)]
  if (any(x$par)) x <- x[par == TRUE]
  x <- x[order(-fifelse(is.na(end_date), 99999L, as.integer(end_date)), -as.integer(start_date), position_id)][1]
  geo <- if (is.na(x$iso)) "na" else if (x$iso == host) "local" else "intl"
  if (x$par) c(local = "local_parent", intl = "intl_parent", na = "parent_na")[[geo]] else c(local = "local_indep", intl = "intl_indep", na = "indep_na")[[geo]]
}
res <- rbindlist(lapply(S, function(j) {
  hj <- H[jv_bvdid == j]; if (!nrow(hj)) return(NULL)
  fam <- fam_of(j); rj <- ijv[jv_bvdid == j, rcid_jv]; host <- ijv[jv_bvdid == j, jv_country]
  rbindlist(lapply(seq_len(nrow(hj)), function(i) {
    h <- hj[i]
    c3 <- classify_one(h, fam, rj, host, 3L)
    x <- byu[[as.character(h$user_id)]]
    earlier <- !is.null(x) && nrow(x[!is.na(start_date) & (is.na(end_date) | end_date >= start_date) & (is.na(rcid) | rcid != rj) & start_date < h$hire_date]) > 0
    e <- edu_by[[as.character(h$user_id)]]
    gap <- if (is.null(e)) NA_integer_ else { ey <- year(e$enddate); ey <- ey[!is.na(ey) & ey <= h$year + 1L]; if (length(ey)) h$year - max(ey) else NA_integer_ }
    ent <- !earlier && !is.na(gap) && gap <= 3L
    data.table(ok1 = classify_one(h, fam, rj, host, 1L) == h$cat_w1, ok3 = c3 == h$cat_w3, ok5 = classify_one(h, fam, rj, host, 5L) == h$cat_w5,
               ok_ent = ent == h$entrant_e3)
  }))
}))
out <- c("# Independent recomputation of the staffing frame, 2026-11-26", "",
  sprintf("Script `code/R/tests/check_panel_recompute.R`; %d IJVs drawn with seed 20261126; %s hires. Agreement with `data/interim/panel-hires-v1.parquet` (counts only):",
          N_IJV, format(nrow(res), big.mark = ",")), "",
  sprintf("- origin window 1 year: %s of %s hires agree", format(sum(res$ok1), big.mark = ","), format(nrow(res), big.mark = ",")),
  sprintf("- origin window 3 years: %s of %s hires agree", format(sum(res$ok3), big.mark = ","), format(nrow(res), big.mark = ",")),
  sprintf("- origin window 5 years: %s of %s hires agree", format(sum(res$ok5), big.mark = ","), format(nrow(res), big.mark = ",")),
  sprintf("- entrant flag (three years): %s of %s hires agree", format(sum(res$ok_ent), big.mark = ","), format(nrow(res), big.mark = ",")))
writeLines(out, file.path(paths$interim, "panel-recompute-check-v1-2026-11-26.md"))
cat(out, sep = "\n")
