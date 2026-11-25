# 10_rater_sheet.R
# Rating sheet for the three outside raters who score the 50 Revelio role_k50
# groups on coord_dependence and local_embeddedness (PI decision 8 of
# 2026-11-25, docs/decisions.md; robustness check of the O*NET scores of
# 07_contingency_scores.R). Instrument and rater instructions:
# docs/coauthor-notes/rater-instrument-2026-11-25.qmd.
#
# Independence rule (CLAUDE.md rule 8): the only input is Revelio's role
# taxonomy. Each group is described by up to five O*NET occupations linked to it,
# ranked by the number of role_k17000_v3 entries per onet_code within the group
# (a count of taxonomy entries, not of positions or people). No position, spell,
# staffing or score file is read, and no O*NET score is shown to the raters.
#
# Licence (CLAUDE.md rule 2): the group labels are Revelio taxonomy labels from a
# licensed product, so both workbooks are written to data/interim/ (gitignored).
# Whether the labels may be sent to outside raters is a question for the PI under
# the Revelio licence. The second workbook is the fallback: opaque group ids and
# O*NET titles only (O*NET is public, CC BY 4.0). Even there the composition of
# each group comes from the Revelio taxonomy.
#
# Group order: the 50 labels are sorted and then shuffled with a fixed seed, so
# that related groups are not adjacent and the ids carry no information.
#
# Inputs:  data/raw/revelio-role-lookup-v3-2026-11-25.parquet (taxonomy only)
#          docs/coauthor-notes/rater-instrument-2026-11-25.qmd (consistency check)
# Outputs: data/interim/rater-sheet-2026-11-25.xlsx            (with group labels)
#          data/interim/rater-sheet-onet-only-2026-11-25.xlsx  (opaque ids, O*NET titles)
# Run:     "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/10_rater_sheet.R

source("code/R/00_setup.R")
require_pkgs(c("arrow", "openxlsx"))
RUN      <- "2026-11-25"
SEED     <- 20261125L
N_TOP    <- 5L
f_lookup <- file.path(paths$raw, "revelio-role-lookup-v3-2026-11-25.parquet")
f_qmd    <- file.path("docs", "coauthor-notes", sprintf("rater-instrument-%s.qmd", RUN))
f_xlsx   <- file.path(paths$interim, sprintf("rater-sheet-%s.xlsx", RUN))
f_xlsx2  <- file.path(paths$interim, sprintf("rater-sheet-onet-only-%s.xlsx", RUN))
is_occ   <- function(x) !is.na(x) & grepl("^[0-9]{2}-[0-9]{4}[.][0-9]{2}$", x)

# ---- Definitions and anchors (keep identical to the instrument) ------------------
# Each text below must appear verbatim in the .qmd; the check at the end warns if not.
def <- c(
  coord_dependence = paste(
    "How much the work in this group depends on coordination with the joint venture's parent companies and their other units.",
    "High dependence means that the work is tightly linked to what the parents do, needs knowledge that is specific to a parent (its technology, products, systems, routines or internal contacts), and involves decisions that are taken jointly with a parent or need its approval.",
    "Low dependence means that the work can be done inside the joint venture with general professional knowledge, and decisions are taken locally.",
    "Only coordination with the parents and their units counts. Coordination inside the joint venture, for example within a team or with other departments, does not count."),
  local_embeddedness = paste(
    "How much the work in this group depends on the host country, the country in which the joint venture operates.",
    "High dependence means that the work relies on dealings with host-country authorities, regulators and other institutions, with local customers, suppliers or communities, and with the local labor market and its rules, and that it needs knowledge of local law, language, business practices and politics.",
    "Low dependence means that the work would be much the same in any country.")
)
anchors <- rbindlist(list(
  list("coord_dependence", 1L, "Very low. The work is done inside the joint venture with general professional knowledge. It needs no knowledge specific to a parent, and decisions are taken locally without parent input.",
       "Keeping a site clean and secure; running a staff canteen; handling routine local correspondence."),
  list("coord_dependence", 2L, "Low. Occasional contact with a parent, for example to apply a group-wide policy, but the work itself does not depend on it.", ""),
  list("coord_dependence", 3L, "Moderate. Regular but bounded coordination. The work uses a parent's systems or standards and reports to a parent from time to time. Some decisions need a parent's approval. Knowledge specific to a parent helps but can be learned on the job within a few months.",
       "Processing payroll in a parent's accounting system; selling a product line supplied by a parent within price ranges the parent sets."),
  list("coord_dependence", 4L, "High. Frequent coordination with a parent in day-to-day work; many decisions are agreed with a parent.", ""),
  list("coord_dependence", 5L, "Very high. The work cannot be done without continuous coordination with a parent. It is tightly linked to a parent's own activities, needs deep knowledge of a parent's technology, routines or internal networks, and major decisions are taken jointly with a parent.",
       "Adapting a component so that it fits a parent's product platform; transferring a parent's proprietary production process to the joint venture; planning output together with a parent that buys most of it."),
  list("local_embeddedness", 1L, "Very low. The work would be essentially the same in any country. It involves little contact with people or institutions outside the company in the host country and needs no knowledge of local law, institutions or language beyond the basics.",
       "Writing software to an international technical standard; analyzing samples under an international laboratory protocol; maintaining a design model in a global engineering tool."),
  list("local_embeddedness", 2L, "Low. Some local contacts or local rules, but the core of the work transfers across countries without change.", ""),
  list("local_embeddedness", 3L, "Moderate. The work regularly involves local customers, suppliers or authorities, or must follow some country-specific rules, but the core skills transfer across countries after some adaptation.",
       "Keeping the books under local accounting rules; buying supplies from local vendors; running a production line that must meet local safety rules."),
  list("local_embeddedness", 4L, "High. Frequent dealings with people or institutions outside the company in the host country; local knowledge is needed for most tasks.", ""),
  list("local_embeddedness", 5L, "Very high. The work depends on the host country. It involves constant dealings with local authorities, regulators, courts, unions, customers or communities and needs deep knowledge of local law, institutions, language and networks. Someone without that knowledge could not do it.",
       "Obtaining permits and licenses from local authorities; negotiating with local unions under local labor law; representing the company before local regulators or courts.")
))
setnames(anchors, c("scale", "score", "description", "example"))
confidence <- c("1" = "Low: I know little about this kind of work, or the group is too mixed to rate.",
                "2" = "Moderate.",
                "3" = "High: I know this kind of work well.")
general <- c(
  "Setting: think of an international joint venture in general, a separate company owned by two or more parent companies, at least one of them based in another country than the joint venture. Do not think of one particular company.",
  "Rate the typical work of each group. Rate the work itself, not the people who do it or the seniority of the job.",
  "Give both ratings for every group, as whole numbers from 1 to 5. Use the whole range of the scale. The two scales are separate: a group can be high on both, low on both, or high on one and low on the other.",
  "The occupations listed for a group are examples of what the group contains, the most common first.",
  "Confidence (optional): 1 to 3. Comment (optional): anything that helps us read your rating, for example that a group is too mixed or that a listed occupation does not fit.",
  "Work alone. Do not discuss the groups or your ratings with the other raters. Do not use numerical ratings from occupational databases; you may look up what an occupation does."
)

# ---- Groups from the taxonomy ----------------------------------------------------
lk <- as.data.table(arrow::read_parquet(f_lookup,
        col_select = c("role_k17000_v3", "role_k50_v3", "onet_code", "onet_title")))
n_all_k50 <- uniqueN(lk$role_k50_v3)
# Non-occupational placeholders (missing row, "unknown", "Miscellaneous" with the
# codes "On Leave" and "Retired") carry no O*NET-SOC code and drop out here.
dropped <- lk[!is_occ(onet_code), .N, by = .(role_k50_v3, onet_code)]
occ <- lk[is_occ(onet_code)]
groups <- sort(unique(occ$role_k50_v3))
stopifnot(length(groups) == 50L)
no_title <- occ[is.na(onet_title) | onet_title == "", uniqueN(onet_code)]
stopifnot(no_title == 0L)

cnt <- occ[, .(n_entries = .N), by = .(role_k50_v3, onet_code, onet_title)]
setorder(cnt, role_k50_v3, -n_entries, onet_code)
desc <- cnt[, .(top_onet_titles = {
                  top <- paste(head(onet_title, N_TOP), collapse = "; ")
                  more <- .N - min(.N, N_TOP)
                  if (more > 0) sprintf("%s (and %d further occupation%s)", top, more, if (more == 1) "" else "s") else top
                },
                n_onet = .N,
                top_share = sum(head(n_entries, N_TOP)) / sum(n_entries)),
            by = role_k50_v3]
multi <- cnt[, .(n_groups = uniqueN(role_k50_v3)), by = onet_code][n_groups > 1]

set.seed(SEED)
ord <- data.table(role_k50_v3 = sample(groups), group_id = sprintf("G%02d", seq_along(groups)))
sheet <- merge(ord, desc, by = "role_k50_v3")[order(group_id)]
sheet <- sheet[, .(group_id, group_label = role_k50_v3, top_onet_titles,
                   coord_dependence = NA_integer_, local_embeddedness = NA_integer_,
                   confidence = NA_integer_, comment = NA_character_)]

# ---- Workbooks -------------------------------------------------------------------
write_sheet <- function(x, file, with_label) {
  if (!with_label) x <- x[, !"group_label"]
  wb <- openxlsx::createWorkbook()
  hdr  <- openxlsx::createStyle(textDecoration = "bold", fgFill = "#D9E1F2", wrapText = TRUE, valign = "top", border = "Bottom")
  wrap <- openxlsx::createStyle(wrapText = TRUE, valign = "top")
  inp  <- openxlsx::createStyle(fgFill = "#FFF2CC", halign = "center", valign = "top")
  # Sheet 1: ratings
  openxlsx::addWorksheet(wb, "ratings")
  openxlsx::writeData(wb, "ratings", x, headerStyle = hdr)
  nr <- nrow(x) + 1L
  rating_cols <- match(c("coord_dependence", "local_embeddedness", "confidence"), names(x))
  title_col   <- match("top_onet_titles", names(x))
  comment_col <- match("comment", names(x))
  openxlsx::addStyle(wb, "ratings", wrap, rows = 2:nr, cols = seq_along(x), gridExpand = TRUE)
  openxlsx::addStyle(wb, "ratings", inp, rows = 2:nr, cols = rating_cols, gridExpand = TRUE)
  for (j in rating_cols[1:2])
    openxlsx::dataValidation(wb, "ratings", cols = j, rows = 2:nr, type = "whole", operator = "between", value = c(1, 5))
  openxlsx::dataValidation(wb, "ratings", cols = rating_cols[3], rows = 2:nr, type = "whole", operator = "between", value = c(1, 3))
  widths <- setNames(rep(12, length(x)), names(x))
  widths[c("group_id")] <- 9
  if (with_label) widths["group_label"] <- 28
  widths["top_onet_titles"] <- 70; widths["comment"] <- 40
  widths[c("coord_dependence", "local_embeddedness")] <- 14
  openxlsx::setColWidths(wb, "ratings", cols = seq_along(x), widths = unname(widths))
  openxlsx::freezePane(wb, "ratings", firstActiveRow = 2)
  # Sheet 2: definitions and anchors
  openxlsx::addWorksheet(wb, "definitions")
  rows <- rbind(
    data.table(part = "How to rate", score = "", text = general, example = ""),
    data.table(part = "coord_dependence: definition", score = "", text = def[["coord_dependence"]], example = ""),
    anchors[scale == "coord_dependence", .(part = "coord_dependence: anchors", score = as.character(score), text = description, example)],
    data.table(part = "local_embeddedness: definition", score = "", text = def[["local_embeddedness"]], example = ""),
    anchors[scale == "local_embeddedness", .(part = "local_embeddedness: anchors", score = as.character(score), text = description, example)],
    data.table(part = "confidence (optional)", score = names(confidence), text = unname(confidence), example = "")
  )
  openxlsx::writeData(wb, "definitions", rows, headerStyle = hdr)
  openxlsx::addStyle(wb, "definitions", wrap, rows = 2:(nrow(rows) + 1L), cols = 1:4, gridExpand = TRUE)
  openxlsx::setColWidths(wb, "definitions", cols = 1:4, widths = c(28, 7, 80, 55))
  openxlsx::saveWorkbook(wb, file, overwrite = TRUE)
}
write_sheet(sheet, f_xlsx,  with_label = TRUE)
write_sheet(sheet, f_xlsx2, with_label = FALSE)

# ---- Consistency with the instrument ---------------------------------------------
if (file.exists(f_qmd)) {
  qmd <- paste(readLines(f_qmd, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  txt <- c(unlist(strsplit(def, "(?<=[.]) ", perl = TRUE)), anchors$description, anchors$example[anchors$example != ""],
           unname(confidence), general)
  miss <- txt[!vapply(txt, grepl, logical(1), x = qmd, fixed = TRUE)]
  if (length(miss)) warning("Texts not found verbatim in ", f_qmd, ":\n", paste("-", miss, collapse = "\n"), call. = FALSE)
  else message("All definitions, anchors and instructions match the instrument.")
} else warning("Instrument not found: ", f_qmd, call. = FALSE)

# ---- Summary (taxonomy counts only) ----------------------------------------------
message(sprintf("role_k50_v3 values in the lookup: %d; rated groups: %d.", n_all_k50, length(groups)))
message("Rows dropped as non-occupational (no O*NET-SOC code): ", nrow(dropped),
        " value pairs, ", sum(dropped$N), " role_k17000_v3 entries.")
message(sprintf("O*NET codes per group: median %d, range %d to %d.", as.integer(median(desc$n_onet)),
                min(desc$n_onet), max(desc$n_onet)))
message(sprintf("Share of a group's taxonomy entries covered by its top %d occupations: median %.0f%%, range %.0f%% to %.0f%%.",
                N_TOP, 100 * median(desc$top_share), 100 * min(desc$top_share), 100 * max(desc$top_share)))
message(sprintf("O*NET codes linked to more than one group: %d of %d.", nrow(multi), uniqueN(cnt$onet_code)))
message("Written: ", f_xlsx, " and ", f_xlsx2, " (gitignored; licensed taxonomy labels in the first).")
