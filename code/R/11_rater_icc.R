# 11_rater_icc.R
# Agreement of the three rater workbooks on the 50 Revelio role_k50 groups and the
# rater scores used as a robustness check of the O*NET contingency scores
# (pre-analysis plan pap-v1.0, robustness set item 6; PI decision 8 and the rater
# procedures of 2026-11-25 in docs/decisions.md).
#
# Rule (decided before the ratings arrived): per scale, ICC(2,k) for a two-way
# random-effects model, absolute agreement, average of k = 3 raters (Shrout &
# Fleiss, 1979; McGraw & Wong, 1996, ICC(A,k)). A scale is used only if its
# ICC(2,k) is at least 0.70; it is then the mean of the three raters per group.
# Blanks are filled by the raters before the ICC; there is no second round below
# 0.70. The confidence item and the comments are not used to weight or drop
# ratings.
#
# Independence: only the rater workbooks and the blank sheet are read. No
# position, staffing or score file is read here; the Spearman comparison with the
# O*NET scores at role_k50 is a separate step.
#
# Inputs:  data/raw/rater-ratings/rater-{A,B,C}-2026-11-26.xlsx   (returned workbooks)
#          data/interim/rater-sheet-2026-11-25.xlsx               (blank sheet, for checks)
# Outputs: data/interim/rater-scores-2026-11-26.csv               (group means per usable scale)
#          data/interim/rater-icc-log-2026-11-26.md               (checks, ICCs, decision)
# Run:     "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/11_rater_icc.R

source("code/R/00_setup.R")
require_pkgs(c("readxl", "irr", "data.table"))
RUN    <- "2026-11-26"
RATERS <- c("A", "B", "C")
SCALES <- c("coord_dependence", "local_embeddedness")
THRESH <- 0.70
f_blank <- file.path(paths$interim, "rater-sheet-2026-11-25.xlsx")
f_in    <- file.path(paths$raw, "rater-ratings", sprintf("rater-%s-%s.xlsx", RATERS, RUN))
f_out   <- file.path(paths$interim, sprintf("rater-scores-%s.csv", RUN))
f_log   <- file.path(paths$interim, sprintf("rater-icc-log-%s.md", RUN))

lines <- c(sprintf("# Rater ICC log, %s", RUN), "", sprintf("Script: code/R/11_rater_icc.R; irr %s", packageVersion("irr")), "")
say <- function(...) { s <- sprintf(...); message(s); lines <<- c(lines, s) }
stopifnot(all(file.exists(f_in)), file.exists(f_blank))

blank <- data.table::as.data.table(readxl::read_excel(f_blank, "ratings"))
rt <- lapply(seq_along(RATERS), function(i) {
  x <- data.table::as.data.table(readxl::read_excel(f_in[i], "ratings"))
  # checks: same groups, same order, same labels as the blank sheet; complete integer ratings 1 to 5
  stopifnot(identical(x$group_id, blank$group_id), identical(x$group_label, blank$group_label))
  for (s in SCALES) {
    v <- x[[s]]
    if (anyNA(v)) stop(sprintf("rater %s: %d blank cells in %s; ask the rater to fill them before the ICC", RATERS[i], sum(is.na(v)), s))
    if (any(!v %in% 1:5)) stop(sprintf("rater %s: values outside 1 to 5 or not whole numbers in %s", RATERS[i], s))
  }
  x[, rater := RATERS[i]]
  x
})
say("- Checks passed: 3 workbooks, 50 groups each, same ids, order and labels as the blank sheet; every rating a whole number from 1 to 5, no blanks.")

res <- data.table::rbindlist(lapply(SCALES, function(s) {
  m <- sapply(rt, function(x) x[[s]])                  # 50 x 3
  ic <- irr::icc(m, model = "twoway", type = "agreement", unit = "average")
  data.table::data.table(scale = s, icc2k = ic$value, ci_low = ic$lbound, ci_high = ic$ubound,
                         F = ic$Fvalue, p = ic$p.value, n_groups = nrow(m), k = ncol(m),
                         used = ic$value >= THRESH)
}))
say("")
say("| Scale | ICC(2,k) | 95%% CI | F | p | Groups | Raters | Used (>= %.2f) |", THRESH)
say("|---|---|---|---|---|---|---|---|")
for (i in seq_len(nrow(res))) with(res[i], say("| `%s` | %.3f | [%.3f, %.3f] | %.2f | %.3g | %d | %d | %s |",
                                             scale, icc2k, ci_low, ci_high, F, p, n_groups, k, if (used) "yes" else "no"))

out <- blank[, .(group_id, group_label)]
for (s in res[used == TRUE, scale]) out[, (paste0(s, "_rater")) := rowMeans(sapply(rt, function(x) x[[s]]))]
data.table::fwrite(out, f_out)
say("")
say("- Rater scores written for the usable scales: %s (%s).", if (any(res$used)) paste(res[used == TRUE, scale], collapse = ", ") else "none", f_out)
say("- Scales below %.2f are not used and no second round follows (decided 2026-11-25).", THRESH)
writeLines(lines, f_log)
print(res)
