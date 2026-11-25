# 09_audit_parent_family_sample.R
# Worksheet for the person audit of the IJVs whose matched Revelio entity lies
# inside a parent's Revelio family (PI decisions of 2026-11-25, docs/decisions.md:
# "Pre-analysis plan rules, decisions 2 to 4" and "Contingency scores, decisions
# 8 to 10"). A random sample of 100 of the flagged core_main IJVs is coded by a
# co-author or research assistant; the PI checks ten of them. Rule fixed before
# the audit: if more than 20 of the 100 are a parent's own unit matched as the
# IJV, the flagged IJVs leave the main sample and return as robustness;
# otherwise they stay and dropping them is the robustness check.
# Coding guide: docs/coauthor-notes/audit-parent-family-guide-2026-11-25.qmd.
#
# Flag: flag_jv_in_parent_family from flag_ijvs() in
# code/R/functions/quality_flags.R, called exactly as in
# code/R/wrds/13_quality_flags.R v3. flag_ijvs() needs the spell reference years
# for its other flags; only the entity flag is kept, and no staffing count, no
# n_emp and no Orbis headcount enters the worksheet.
#
# Draw: RNGkind("Mersenne-Twister", "Inversion", "Rejection") and
# set.seed(20261125); sample() of 100 from the flagged jv_bvdid vector sorted
# with method = "radix" (locale-independent). audit_id A001 to A100 follows the
# order of the draw. PI cases: set.seed(20261125) again and sample() of 10 from
# the 100 sampled jv_bvdid, sorted the same way.
#
# Inputs (licensed, local only): data/processed/ijv-matched-, ijv-parents- and
# ijv-employee-spells-v3-2026-10-09 (spells: jv_bvdid and reference years only);
# data/interim/full-parent-groups-v3-2026-10-09.csv;
# data/raw/revelio-companies-full-v3-2026-10-09.csv.gz (Revelio company names).
# Outputs (licensed row-level data, data/interim/ is gitignored):
#   data/interim/audit-parent-family-worksheet-2026-11-25.xlsx and .csv
# The worksheet is never overwritten once it exists (coding may be under way):
# a rerun rebuilds the draw in memory and checks it against the file on disk.
# Pass the argument "overwrite" to write it again.
# Run: "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/09_audit_parent_family_sample.R

source("code/R/00_setup.R")
source("code/R/functions/quality_flags.R")
require_pkgs(c("arrow", "openxlsx"))
RUN <- "v3-2026-10-09"
SEED <- 20261125L
N_AUDIT <- 100L; N_PI <- 10L; N_FLAGGED_EXPECTED <- 831L
OVERWRITE <- "overwrite" %in% commandArgs(trailingOnly = TRUE)
f_xlsx <- file.path(paths$interim, "audit-parent-family-worksheet-2026-11-25.xlsx")
f_csv <- sub("[.]xlsx$", ".csv", f_xlsx)
check <- function(cond, msg) { cat(if (isTRUE(cond)) "OK   " else "FAIL ", msg, "\n"); if (!isTRUE(cond)) stop("check failed: ", msg, call. = FALSE) }

# ---- Inputs (as in 13_quality_flags.R) ----------------------------------------------
# na.strings = "" keeps the country code "NA" (Namibia) as a value.
read_csv <- function(f, chr) fread(f, colClasses = list(character = chr), na.strings = "")
ijv <- read_csv(file.path(paths$processed, sprintf("ijv-matched-%s.csv", RUN)), "jv_bvdid")
par <- read_csv(file.path(paths$processed, sprintf("ijv-parents-%s.csv", RUN)), c("jv_bvdid", "parent_bvdid", "parent_guo"))
grp <- read_csv(file.path(paths$interim, sprintf("full-parent-groups-%s.csv", RUN)), "parent_bvdid")
spells <- as.data.table(arrow::read_parquet(file.path(paths$processed, sprintf("ijv-employee-spells-%s.parquet", RUN)),
                                            col_select = c("jv_bvdid", "first_reference_year", "last_reference_year")))
co <- read_csv(file.path(paths$raw, "revelio-companies-full-v3-2026-10-09.csv.gz"), "orbis_id")
ijv[, exposure_group := NULL]          # never used here: the shock is not chosen by outcomes

# ---- Flag (existing function, unchanged) ---------------------------------------------
ijv_f <- flag_ijvs(ijv, spells, par, grp)
rm(spells); invisible(gc())
flagged <- sort(ijv_f[flag_jv_in_parent_family == TRUE, jv_bvdid], method = "radix")
check(nrow(ijv) == 7460L, sprintf("core_main matched dataset has 7,460 IJVs (%d)", nrow(ijv)))
check(length(flagged) == N_FLAGGED_EXPECTED, sprintf("%d IJVs flagged flag_jv_in_parent_family (expected %d)", length(flagged), N_FLAGGED_EXPECTED))

# ---- Draw ----------------------------------------------------------------------------
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(SEED)
drawn <- sample(flagged, N_AUDIT)
set.seed(SEED)
pi_ids <- sample(sort(drawn, method = "radix"), N_PI)
check(!anyDuplicated(drawn) && length(drawn) == N_AUDIT, sprintf("%d distinct IJVs drawn", length(drawn)))
check(all(pi_ids %in% drawn) && length(unique(pi_ids)) == N_PI, sprintf("%d PI cases, all among the sampled IJVs", length(unique(pi_ids))))

# ---- Revelio entity and the parent family that contains it ----------------------------
# One name per Revelio company id (rows of the extract repeat a company per Orbis id and route).
cj <- unique(co[order(rcid, entity != "jv"), .(rcid = as.numeric(rcid), company_name, hq_country, url, linkedin_url,
                                               ultimate_parent_rcid = as.numeric(ultimate_parent_rcid))], by = "rcid")
# Entities matched by name to a parent (entity "parent", keyed on the parent's BvD id) or to its GUO.
pm <- unique(co[entity %chin% c("parent", "guo"), .(orbis_id, via = entity, rcid = as.numeric(rcid),
                                                    ultimate_parent_rcid = as.numeric(ultimate_parent_rcid))])
s <- ijv_f[match(drawn, jv_bvdid)]
s[, audit_id := sprintf("A%03d", seq_len(.N))]
s[, rcid_jv := as.numeric(rcid_jv)]
ji <- match(s$rcid_jv, cj$rcid)
s[, `:=`(revelio_jv_name = cj$company_name[ji], revelio_jv_hq_country = cj$hq_country[ji], revelio_jv_url = cj$url[ji],
         revelio_jv_linkedin = cj$linkedin_url[ji], family_head_rcid = cj$ultimate_parent_rcid[ji])]
s[, family_head_name := cj$company_name[match(family_head_rcid, cj$rcid)]]

# The same join as flag_ijvs(): parents whose Revelio family holds the matched entity.
fam <- merge(par[, .(jv_bvdid, parent_rank, parent_label, parent_bvdid, parent_guo, parent_name, parent_country,
                     equity_share_current, revelio_family_size)],
             grp[, .(parent_bvdid, rcid = as.numeric(rcid))], by = "parent_bvdid", allow.cartesian = TRUE)
own <- fam[s[, .(jv_bvdid, rcid = rcid_jv, family_head_rcid)], on = .(jv_bvdid, rcid), nomatch = NULL]
check(uniqueN(own$jv_bvdid) == N_AUDIT, "every sampled IJV has a parent whose family holds the matched entity")
# The parent's own Revelio entity in that family: the entity matched to the parent (or its GUO) that is the
# family head, else a direct-parent match before a GUO match, else the lowest rcid.
pick_parent_entity <- function(p, g, head) {
  x <- pm[((orbis_id == p & via == "parent") | (!is.na(g) & orbis_id == g & via == "guo")) & ultimate_parent_rcid == head]
  if (!nrow(x)) return(list(NA_real_, NA_character_, 0L))
  x <- x[order(rcid != head, via != "parent", rcid)]
  list(x$rcid[1], x$via[1], uniqueN(x$rcid))
}
own[, c("parent_rcid", "parent_rcid_via", "parent_n_entities_in_family") := rbindlist(Map(function(p, g, h)
  as.list(setNames(pick_parent_entity(p, g, h), c("a", "b", "c"))), parent_bvdid, parent_guo, family_head_rcid))]
own[, parent_rcid_name := cj$company_name[match(parent_rcid, cj$rcid)]]
own[, jv_entity_is_parent_match := mapply(function(p, g, r) any((pm$orbis_id == p & pm$via == "parent" | (!is.na(g) & pm$orbis_id == g & pm$via == "guo")) & pm$rcid == r),
                                          parent_bvdid, parent_guo, rcid)]
setorder(own, jv_bvdid, parent_rank)
j <- function(x) paste(ifelse(is.na(x), "", as.character(x)), collapse = "; ")
fp <- own[, .(family_parent_label = j(parent_label), family_parent_name = j(parent_name), family_parent_country = j(parent_country),
              family_parent_share = j(equity_share_current), family_parent_rcid = j(format(parent_rcid, scientific = FALSE, trim = TRUE)),
              family_parent_rcid_name = j(parent_rcid_name), family_parent_rcid_via = j(parent_rcid_via),
              family_parent_n_entities_matched = j(parent_n_entities_in_family), family_parent_revelio_family_size = j(revelio_family_size),
              jv_entity_matched_to_parent_name = any(jv_entity_is_parent_match)), by = jv_bvdid]
fp[, family_parent_rcid := gsub("\\bNA\\b", "", family_parent_rcid)]
s <- merge(s, fp, by = "jv_bvdid", all.x = TRUE, sort = FALSE)
setorder(s, audit_id)

# ---- Worksheet -------------------------------------------------------------------------
ws <- s[, .(audit_id, jv_bvdid, jv_name, jv_country, formation_year, source, route, match_tier, match_method, match_score,
            rcid_jv = format(rcid_jv, scientific = FALSE, trim = TRUE), revelio_jv_name, revelio_jv_hq_country, revelio_jv_url, revelio_jv_linkedin,
            family_head_rcid = format(family_head_rcid, scientific = FALSE, trim = TRUE), family_head_name,
            family_parent_label, family_parent_name, family_parent_country, family_parent_share,
            family_parent_rcid, family_parent_rcid_name, family_parent_rcid_via, family_parent_n_entities_matched,
            family_parent_revelio_family_size, jv_entity_matched_to_parent_name, entity_in_two_parent_families = flag_shared_family_entity,
            parent_a_name, parent_a_country, parent_a_share, parent_b_name, parent_b_country, parent_b_share,
            jv_website, jv_lei,
            pi_check_case = jv_bvdid %chin% pi_ids,
            verdict = NA_character_, evidence = NA_character_, source_urls = NA_character_, coder = NA_character_, date = NA_character_,
            pi_check = NA_character_)]
# Quoted empty strings in the source CSVs (website, LEI, Revelio URL) are missing values.
for (v in names(ws)[vapply(ws, is.character, logical(1))]) set(ws, which(ws[[v]] == ""), v, NA_character_)
banned <- c("n_emp", "n_years", "function_cells_5", "seniority_cells_5", "jv_employees_orbis", "operating_parents", "strategic", "exposure_group")
check(!any(names(ws) %in% banned) && !any(grepl("emp|cells|origin|hire|staff", names(ws))), "no staffing count, employee number or Orbis headcount in the worksheet")
check(sum(ws$pi_check_case) == N_PI, sprintf("%d rows marked pi_check_case", sum(ws$pi_check_case)))

# ---- Write, or check against the file on disk ---------------------------------------------
if (file.exists(f_csv) && !OVERWRITE) {
  old <- fread(f_csv, colClasses = list(character = c("jv_bvdid", "audit_id")), na.strings = "")
  same <- identical(old$audit_id, ws$audit_id) && identical(old$jv_bvdid, ws$jv_bvdid) &&
    identical(as.logical(old$pi_check_case), ws$pi_check_case)
  check(same, sprintf("worksheet on disk has the same draw (audit_id, jv_bvdid, pi_check_case); not overwritten: %s", f_xlsx))
} else {
  fwrite(ws, f_csv, na = "")
  verdicts <- c("ijv_filed_under_parent", "parent_own_unit", "other_wrong_match", "cannot_tell")
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "worksheet")
  openxlsx::addWorksheet(wb, "codes")
  openxlsx::writeData(wb, "codes", data.table(verdict = verdicts, meaning = c(
    "the Revelio entity is the IJV itself, filed by Revelio inside a parent's family (match correct)",
    "the Revelio entity is a parent's own company, subsidiary, branch or division, not the IJV (wrong match; counts for the 20-of-100 rule)",
    "the Revelio entity is neither the IJV nor a parent's own unit (another company, another JV of the parent)",
    "the evidence does not allow a verdict")))
  openxlsx::writeData(wb, "worksheet", ws, withFilter = TRUE)
  hs <- openxlsx::createStyle(textDecoration = "bold", fgFill = "#DDDDDD", wrapText = TRUE)
  cs <- openxlsx::createStyle(fgFill = "#FFF2CC")
  code_cols <- match(c("verdict", "evidence", "source_urls", "coder", "date", "pi_check"), names(ws))
  openxlsx::addStyle(wb, "worksheet", hs, rows = 1, cols = seq_along(ws), gridExpand = TRUE)
  openxlsx::addStyle(wb, "worksheet", cs, rows = 2:(nrow(ws) + 1), cols = code_cols, gridExpand = TRUE)
  openxlsx::dataValidation(wb, "worksheet", cols = code_cols[1], rows = 2:(nrow(ws) + 1), type = "list",
                           value = sprintf("'codes'!$A$2:$A$%d", length(verdicts) + 1))
  openxlsx::freezePane(wb, "worksheet", firstRow = TRUE, firstActiveCol = 4)
  openxlsx::setColWidths(wb, "worksheet", cols = seq_along(ws), widths = 18)
  openxlsx::setColWidths(wb, "worksheet", cols = match(c("evidence", "source_urls"), names(ws)), widths = 50)
  openxlsx::setColWidths(wb, "codes", cols = 1:2, widths = c(26, 110))
  openxlsx::saveWorkbook(wb, f_xlsx, overwrite = TRUE)
  cat("written:", f_xlsx, "and", f_csv, "\n")
}

# ---- Aggregate counts for data/data-log.md (no row-level data) ----------------------------
cat(sprintf("flagged %d of %d core_main IJVs; sampled %d; PI cases %d\n", length(flagged), nrow(ijv), nrow(ws), sum(ws$pi_check_case)))
cnt <- function(x) paste(sprintf("%s %d", names(table(x, useNA = "ifany")), table(x, useNA = "ifany")), collapse = ", ")
cat("sample by source:", cnt(ws$source), "\n")
cat("sample by match tier:", cnt(ws$match_tier), "\n")
cat("sample by match method:", cnt(ws$match_method), "\n")
cat("flagged by match tier:", cnt(ijv_f[jv_bvdid %chin% flagged, match_tier]), "\n")
cat("sample, parent whose family holds the entity:", cnt(ws$family_parent_label), "\n")
cat("sample, entity in two parents' families:", sum(ws$entity_in_two_parent_families), "\n")
cat("sample, matched entity is itself an entity matched to the parent's name:", sum(ws$jv_entity_matched_to_parent_name), "\n")
cat("missing: Revelio name of matched entity", sum(is.na(ws$revelio_jv_name)), "; family head name", sum(is.na(ws$family_head_name)),
    "; parent's own matched entity in the family (IJV-parent pairs)", sum(is.na(own$parent_rcid)),
    "; its name", sum(is.na(own$parent_rcid_name)),
    "; jv_website", sum(is.na(ws$jv_website)), "; jv_lei", sum(is.na(ws$jv_lei)), "\n")
