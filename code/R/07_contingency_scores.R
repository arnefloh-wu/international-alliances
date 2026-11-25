# 07_contingency_scores.R
# Contingency scores from O*NET alone, as decided by the PI on 2026-11-25
# (docs/coauthor-notes/score-construction-decision-sheet-2026-11-25.qmd,
# docs/decisions.md). Written before any panel exists.
#
# Independence rule (CLAUDE.md rule 8): the only inputs are the public O*NET
# 31.0 Database and the list of O*NET codes in Revelio's role taxonomy (which
# codes exist, not how many positions hold them). No staffing count, by
# occupation, function or exposure, is read.
#
# Scores per O*NET occupation:
#   local_embeddedness  law and government (2.C.8.b, knowledge, IM); communicating
#                       with people outside the organization (4.A.4.a.3, activity,
#                       IM); dealing with external customers or the public
#                       (4.C.1.b.1.f, context, CX)
#   coord_dependence    coordinating the work and activities of others (4.A.4.b.1,
#                       activity, IM); coordinating or leading others (4.C.1.b.1.g,
#                       context, CX); working with a work group or team
#                       (4.C.1.b.1.e, context, CX)
#   *_broad             the broad five- and six-element sets (robustness)
#   *_lv                level scale (LV) in place of importance (appendix check)
# Each element is standardized across the occupations rated on all elements of
# its set, without weights; the elements are averaged and the average is
# standardized again. Occupations O*NET does not rate take the mean of the rated
# occupations in their SOC broad group (first five digits), else their minor
# group, flagged score_imputed.
#
# Domains: the SOC minor group (first three digits), scored as the unweighted mean
# of its rated occupations; the 16 regulatory-facing occupations of the H4 list
# form a domain of their own ("REG"), taken out of their minor groups. job_zone is
# the domain's mean O*NET job zone (robustness control).
#
# Inputs:  data/raw/external/onet-db-31-0-2026-11-25/db_31_0_text.zip (public, CC BY 4.0)
#          data/raw/revelio-role-lookup-v3-2026-11-25.parquet (O*NET codes only)
# Outputs: data/processed/contingency-scores-occupation-v1-2026-11-25.csv
#          data/processed/contingency-scores-domain-v1-2026-11-25.csv
#          data/interim/contingency-scores-v1-2026-11-25.md (checks)
# Run:     "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/07_contingency_scores.R

source("code/R/00_setup.R")
require_pkgs("arrow")
RUN <- "v1-2026-11-25"
f_zip    <- file.path(paths$raw, "external", "onet-db-31-0-2026-11-25", "db_31_0_text.zip")
f_lookup <- file.path(paths$raw, "revelio-role-lookup-v3-2026-11-25.parquet")
f_occ    <- file.path(paths$processed, sprintf("contingency-scores-occupation-%s.csv", RUN))
f_dom    <- file.path(paths$processed, sprintf("contingency-scores-domain-%s.csv", RUN))
f_rep    <- file.path(paths$interim, sprintf("contingency-scores-%s.md", RUN))

# ---- Definitions (fixed by the decision sheet) ------------------------------------
LE   <- c(law_gov = "2.C.8.b", comm_outside = "4.A.4.a.3", ext_customers = "4.C.1.b.1.f")
CD   <- c(coord_others = "4.A.4.b.1", lead_others = "4.C.1.b.1.g", team_work = "4.C.1.b.1.e")
LE_B <- c(LE, relationships = "4.A.4.a.4", public = "4.A.4.a.8")
CD_B <- c(CD, comm_internal = "4.A.4.a.2", build_teams = "4.A.4.b.2", impact_coworkers = "4.C.3.a.2.a")
REG_NARROW <- c("23-1011.00", "23-1012.00", "23-1022.00", "23-2011.00", "23-2093.00", "23-2099.00", "43-6012.00",
                "11-9199.01", "11-9199.02", "13-1041.00", "13-1041.01", "13-1041.07", "13-1041.08",
                "13-2081.00", "13-2082.00", "13-1075.00")
REG_BROAD  <- c(REG_NARROW, "13-2011.00", "13-1071.00", "13-1081.00", "13-1081.01", "13-1081.02", "13-1041.03")
is_occ <- function(x) !is.na(x) & grepl("^[0-9]{2}-[0-9]{4}[.][0-9]{2}$", x)

# ---- Read O*NET -------------------------------------------------------------------
tmp <- file.path(tempdir(), "onet31"); dir.create(tmp, showWarnings = FALSE)
need <- c("Occupation Data.txt", "Work Activities.txt", "Knowledge.txt", "Work Context.txt", "Job Zones.txt")
utils::unzip(f_zip, files = file.path("db_31_0_text", need), exdir = tmp, junkpaths = TRUE)
rd <- function(f) { x <- fread(file.path(tmp, f), sep = "\t", quote = ""); setnames(x, "O*NET-SOC Code", "onet_code"); x }
od <- rd("Occupation Data.txt")[, .(onet_code, onet_title = Title)]
ratings <- rbind(rd("Work Activities.txt"), rd("Knowledge.txt"), rd("Work Context.txt"), fill = TRUE)
ratings <- ratings[, .(onet_code, el = `Element ID`, scale = `Scale ID`, v = `Data Value`)]
jz <- rd("Job Zones.txt")[, .(onet_code, job_zone = `Job Zone`)]

# Context elements have no level scale: their CX rating is used in both variants.
pick <- function(els, im_scale) {
  ctx <- grepl("^4[.]C[.]", els)
  x <- rbind(ratings[el %in% els[!ctx] & scale == im_scale], ratings[el %in% els[ctx] & scale == "CX"])
  w <- dcast(x, onet_code ~ el, value.var = "v")
  setnames(w, unname(els), names(els), skip_absent = TRUE)
  w
}
composite <- function(els, im_scale = "IM") {
  w <- na.omit(pick(els, im_scale))
  m <- scale(as.matrix(w[, names(els), with = FALSE]))
  data.table(onet_code = w$onet_code, score = as.numeric(scale(rowMeans(m))), alpha = {
    k <- ncol(m); k / (k - 1) * (1 - sum(apply(m, 2, var)) / var(rowSums(m))) })
}
sc <- list(local_embeddedness = composite(LE), coord_dependence = composite(CD),
           local_embeddedness_broad = composite(LE_B), coord_dependence_broad = composite(CD_B),
           local_embeddedness_lv = composite(LE, "LV"), coord_dependence_lv = composite(CD, "LV"))
alphas <- vapply(sc, function(x) x$alpha[1], numeric(1))
occ <- Reduce(function(a, b) merge(a, b, by = "onet_code", all = TRUE),
              lapply(names(sc), function(n) setnames(copy(sc[[n]])[, .(onet_code, score)], "score", n)))
lawgov <- ratings[el == LE[["law_gov"]] & scale == "IM", .(onet_code, law_gov_importance = v)]

# ---- Occupation table: O*NET occupations plus every code in Revelio's taxonomy ------
lk_codes <- unique(as.data.table(arrow::read_parquet(f_lookup, col_select = "onet_code"))$onet_code)
lk_codes <- lk_codes[is_occ(lk_codes)]
base <- data.table(onet_code = sort(union(od$onet_code, lk_codes)))
base[, in_revelio := onet_code %in% lk_codes]
base <- Reduce(function(a, b) merge(a, b, by = "onet_code", all.x = TRUE), list(base, od, occ, lawgov, jz))
base[, job_zone := as.numeric(job_zone)]
base[, `:=`(soc_minor = substr(onet_code, 1, 4), soc_broad = substr(onet_code, 1, 6))]
score_cols <- names(sc)
base[, score_imputed := is.na(local_embeddedness) | is.na(coord_dependence)]
# Imputation: mean of rated occupations in the SOC broad group, else the minor group,
# else all rated occupations (the military codes, major group 55, which O*NET does not
# rate; PI decision of 2026-11-25).
for (v in c(score_cols, "law_gov_importance", "job_zone")) {
  rated <- base[score_imputed == FALSE]
  bg <- rated[, .(m = mean(get(v), na.rm = TRUE)), by = soc_broad]
  mg <- rated[, .(m = mean(get(v), na.rm = TRUE)), by = soc_minor]
  base[score_imputed == TRUE, (v) := fcoalesce(as.numeric(get(v)), bg$m[match(soc_broad, bg$soc_broad)], mg$m[match(soc_minor, mg$soc_minor)], mean(rated[[v]], na.rm = TRUE))]
}
rated_broad <- base[score_imputed == FALSE, unique(soc_broad)]; rated_minor <- base[score_imputed == FALSE, unique(soc_minor)]
base[, imputed_from := fcase(!score_imputed, "rated", soc_broad %in% rated_broad, "broad group",
                             soc_minor %in% rated_minor, "minor group", default = "overall mean")]
base[, `:=`(regulatory_narrow = onet_code %in% REG_NARROW, regulatory_broad = onet_code %in% REG_BROAD)]
base[, domain := fifelse(regulatory_narrow, "REG", soc_minor)]
setcolorder(base, c("onet_code", "onet_title", "in_revelio", "soc_minor", "soc_broad", "domain", "regulatory_narrow",
                    "regulatory_broad", "score_imputed", "imputed_from"))

# ---- Domain table: unweighted mean of rated occupations (imputed only if none rated) --
dom <- base[, {
  r <- !score_imputed
  use <- if (any(r)) r else rep(TRUE, .N)
  c(lapply(.SD[use], mean, na.rm = TRUE),
    list(n_occupations = .N, n_rated = sum(r), n_in_revelio = sum(in_revelio), all_imputed = !any(r)))
}, by = domain, .SDcols = c(score_cols, "law_gov_importance", "job_zone")]
setorder(dom, domain)

fwrite(base, f_occ); fwrite(dom, f_dom)

# ---- Checks (O*NET only) -----------------------------------------------------------
chk <- character()
add <- function(...) chk <<- c(chk, sprintf(...))
stopifnot(!anyDuplicated(base$onet_code), all(lk_codes %in% base$onet_code), all(REG_NARROW %in% base$onet_code),
          !anyNA(base$local_embeddedness), !anyNA(base$coord_dependence),
          all(substr(base$onet_code[base$imputed_from == "overall mean"], 1, 2) == "55"))
add("- O*NET occupations: %d; codes in Revelio's taxonomy: %d (all in the table)", nrow(od), length(lk_codes))
add("- Occupations rated on all elements: local_embeddedness %d, coord_dependence %d, broad sets %d and %d",
    nrow(sc$local_embeddedness), nrow(sc$coord_dependence), nrow(sc$local_embeddedness_broad), nrow(sc$coord_dependence_broad))
add("- Cronbach's alpha: %s", paste(sprintf("%s %.2f", names(alphas), alphas), collapse = "; "))
r <- base[score_imputed == FALSE]
add("- Correlation of the two scores across rated occupations: narrow %.2f, broad %.2f, level scale %.2f",
    cor(r$local_embeddedness, r$coord_dependence), cor(r$local_embeddedness_broad, r$coord_dependence_broad, use = "c"),
    cor(r$local_embeddedness_lv, r$coord_dependence_lv, use = "c"))
add("- Correlation with job zone: local_embeddedness %.2f, coord_dependence %.2f; narrow with broad: %.2f and %.2f; importance with level: %.2f and %.2f",
    cor(r$local_embeddedness, r$job_zone, use = "c"), cor(r$coord_dependence, r$job_zone, use = "c"),
    cor(r$local_embeddedness, r$local_embeddedness_broad, use = "c"), cor(r$coord_dependence, r$coord_dependence_broad, use = "c"),
    cor(r$local_embeddedness, r$local_embeddedness_lv, use = "c"), cor(r$coord_dependence, r$coord_dependence_lv, use = "c"))
add("- Codes in Revelio's taxonomy without O*NET ratings: %d; imputed from the broad group %d, from the minor group %d; from the overall mean (military, major group 55) %d",
    base[in_revelio & score_imputed, .N], base[in_revelio & imputed_from == "broad group", .N], base[in_revelio & imputed_from == "minor group", .N],
    base[in_revelio & imputed_from == "overall mean", .N])
add("- Domains: %d (%d SOC minor groups plus REG); with no rated occupation, scored from imputed values: %d (%s); distinct domain values of local_embeddedness: %d",
    nrow(dom), nrow(dom) - 1L, sum(dom$all_imputed), paste(dom[all_imputed == TRUE, domain], collapse = ", "),
    uniqueN(round(dom$local_embeddedness[!is.na(dom$local_embeddedness)], 6)))
add("- REG domain: %d occupations (%d rated); local_embeddedness %.2f, coord_dependence %.2f, law-and-government importance %.2f",
    dom[domain == "REG", n_occupations], dom[domain == "REG", n_rated], dom[domain == "REG", local_embeddedness],
    dom[domain == "REG", coord_dependence], dom[domain == "REG", law_gov_importance])
add("- Domain scores (SD across domains): local_embeddedness %.2f, coord_dependence %.2f; correlation across domains %.2f",
    sd(dom$local_embeddedness, na.rm = TRUE), sd(dom$coord_dependence, na.rm = TRUE), cor(dom$local_embeddedness, dom$coord_dependence, use = "c"))
writeLines(c(sprintf("# Contingency scores from O*NET, %s", RUN), "",
             "Built by `code/R/07_contingency_scores.R` from the O*NET 31.0 Database and the list of O*NET codes in Revelio's taxonomy. No staffing data were read.", "",
             chk), f_rep)
cat(chk, sep = "\n")
