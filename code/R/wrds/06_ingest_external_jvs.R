# 06_ingest_external_jvs.R
# Adds joint ventures from outside WRDS (SDC, Orbis M&A, fDi Markets, registry
# extracts, hand-built lists) to the frame. Builds frame v4 = frame v3 plus the
# external JVs, read by 03_wrds_full_sample.R with the argument "v4".
#
# Input: one or more CSV files in data/raw/external/, UTF-8, one row per
# JV-parent pair (long format). The file name starts with the source, for
# example sdc-2026-10-12.csv or orbismna-2026-10-12.csv; the source is the text
# before the first hyphen. Columns:
#
#   ext_id          required  the source's own deal or company id (unique per JV)
#   jv_name         required  name of the joint venture entity
#   jv_country      required  host country, ISO 3166 alpha-2 (a country name is
#                             also accepted and converted)
#   parent_name     required  name of one parent (one row per parent)
#   parent_country  required  that parent's home country (ISO2 or name)
#   parent_share    optional  parent's equity share in percent (0 to 100)
#   formation_year  optional  year the JV was formed or announced
#   jv_website      optional  helps matching to Revelio
#   jv_lei          optional  helps matching to Revelio
#   jv_bvdid        optional  Orbis BvD id; used only to drop duplicates of JVs
#                             already in the frame
#   status          optional  free text (active, dissolved, pending, ...)
#   industry        optional  free text; JVs in banking, insurance and finance
#                             are dropped
#
# Rules: two to four parents from at least two countries, at least one parent
# foreign to the host, parents with different first name tokens (a cheap
# check for intra-group arrangements such as "Kering Italia" and "Kering
# Holland", because external lists carry no group information), no financial
# JVs, and no duplicate of a JV already in the frame (same normalized name and
# country, or the same BvD id).
# Run on the PI's computer from the repository root:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/06_ingest_external_jvs.R

source("code/R/00_setup.R")
source("code/R/functions/frame.R")
require_pkgs(c("countrycode"))

RUN_DATE <- "2026-10-09"
f_v3 <- file.path(paths$interim, sprintf("wrds-ijv-frame-v3-%s.csv", RUN_DATE))
f_v4 <- file.path(paths$interim, sprintf("wrds-ijv-frame-v4-%s.csv", RUN_DATE))
f_rep <- file.path(paths$interim, sprintf("external-ingest-report-%s.csv", RUN_DATE))
ext_dir <- file.path(paths$raw, "external")
files <- list.files(ext_dir, "[.]csv$", full.names = TRUE)
if (!file.exists(f_v3)) stop("Frame v3 not found: run code/R/wrds/05_wrds_frame_v2.R with_dom with_small with_prior first.")
if (!length(files)) stop("No files in ", ext_dir, ". See docs/data-acquisition-guide.md for the format.")

required <- c("ext_id", "jv_name", "jv_country", "parent_name", "parent_country")
iso2 <- function(x) {
  x <- trimws(as.character(x))
  out <- ifelse(nchar(x) == 2L, toupper(x), suppressWarnings(countrycode::countrycode(x, "country.name", "iso2c", warn = FALSE)))
  out
}
name_key <- function(country, name) paste(country, gsub("[^a-z0-9]", "", normalize_name(name)))

base <- fread(f_v3, colClasses = list(character = c("jv_bvdid", "parent_bvdid", "parent_guo", "nace", "naics")))
base_jv <- unique(base, by = "jv_bvdid")
base_keys <- unique(name_key(base_jv$jv_country, base_jv$jv_name))
base_ids <- base_jv$jv_bvdid

report <- list()
rows <- list()
for (f in files) {
  src <- tolower(sub("-.*$", "", sub("[.]csv$", "", basename(f))))
  x <- fread(f, colClasses = "character", encoding = "UTF-8")
  miss <- setdiff(required, names(x))
  if (length(miss)) stop(basename(f), ": missing required columns: ", paste(miss, collapse = ", "))
  for (cc in c("parent_share", "formation_year", "jv_website", "jv_lei", "jv_bvdid", "status", "industry")) if (!cc %in% names(x)) x[, (cc) := NA_character_]
  n0 <- uniqueN(x$ext_id)
  x[, `:=`(jv_country = iso2(jv_country), parent_country = iso2(parent_country),
           parent_share = suppressWarnings(as.numeric(gsub(",", ".", parent_share))),
           formation_year = suppressWarnings(as.integer(formation_year)))]
  x <- x[!is.na(ext_id) & ext_id != "" & !is.na(jv_name) & jv_name != "" & !is.na(parent_name) & parent_name != "" &
           !is.na(jv_country) & !is.na(parent_country)]
  n_valid <- uniqueN(x$ext_id)
  x[, pkey := name_key(parent_country, parent_name)]
  x <- unique(x, by = c("ext_id", "pkey"))
  x[, first_tok := vapply(strsplit(normalize_name(parent_name), " "), function(t) if (length(t)) t[1] else "", character(1))]
  agg <- x[, .(n_parents = .N, n_pc = uniqueN(parent_country), foreign = any(parent_country != jv_country[1]),
               same_group = uniqueN(first_tok) == 1L & nchar(first_tok[1]) >= 4L,
               fin = any(grepl("bank|insur|financ|capital market|reit|asset manage", industry, ignore.case = TRUE), na.rm = TRUE),
               dup = name_key(jv_country[1], jv_name[1]) %chin% base_keys | (!is.na(jv_bvdid[1]) & jv_bvdid[1] %chin% base_ids)),
           by = ext_id]
  agg[, ok := n_parents >= 2 & n_parents <= 4 & n_pc >= 2 & foreign & !same_group & !fin & !dup]
  report[[length(report) + 1]] <- data.table(source = src, file = basename(f), jvs_in_file = n0, valid_rows_jvs = n_valid,
    fewer_than_2_parents = agg[n_parents < 2, .N], more_than_4_parents = agg[n_parents > 4, .N], one_country = agg[n_parents >= 2 & n_pc < 2, .N],
    none_foreign = agg[n_pc >= 2 & !foreign, .N], same_group = agg[same_group == TRUE, .N], financial = agg[fin == TRUE, .N],
    duplicates = agg[dup == TRUE, .N], accepted = agg[ok == TRUE, .N])
  x <- x[ext_id %in% agg[ok == TRUE, ext_id]]
  x[, source := src]
  rows[[length(rows) + 1]] <- x
}
rep <- rbindlist(report)
fwrite(rep, f_rep)
print(rep)
ext <- rbindlist(rows, fill = TRUE)
if (!nrow(ext)) stop("No external JV passed the rules; see ", f_rep)

ext[, jv_bvdid_new := paste0("EXT", toupper(source), "_", ext_id)]
ext[, parent_bvdid := paste0("EXT", toupper(gsub("[^A-Za-z0-9]", "", substr(normalize_name(parent_name), 1, 40))), parent_country)]
pc <- ext[, .(parent_countries = list(sort(unique(parent_country))), n_parents = .N), by = jv_bvdid_new]
ext <- merge(ext, pc, by = "jv_bvdid_new")
ext[, exposure_group := exposure_group_of(jv_country, parent_countries)]
fr <- ext[, .(jv_bvdid = jv_bvdid_new, jv_name, jv_country, jv_city = NA_character_, formation_date = as.IDate(NA),
              formation_year = fifelse(is.na(formation_year), 1990L, formation_year), formation_year_missing = is.na(formation_year),
              jv_status = status, jv_legal_form = NA_character_, jv_listed = NA_character_, jv_lei = jv_lei, jv_isin = NA_character_,
              jv_website = jv_website, nace_section = NA_character_, nace = NA_character_, nace_desc = industry, naics = NA_character_,
              parent_bvdid, parent_name, parent_country, parent_entity_type = "Corporate", equity_share_current = parent_share,
              ownership_info_date = as.IDate(NA), n_parents, parents_total_share = NA_real_, orbis_library = "ext",
              parent_guo = parent_bvdid, guo_name_pre = parent_name, parent_guo_found = FALSE,
              source = paste0("ext_", source), excl_jv = "", admitted_by = paste0("ext_", source), exposure_group)]
fr[, `:=`(region = region_of(jv_country), industry = "unknown")]
v4 <- rbindlist(list(base, fr), use.names = TRUE, fill = TRUE)
setorder(v4, jv_bvdid, -equity_share_current, parent_country)
fwrite(v4, f_v4)
message(sprintf("frame v4 written: %s; %d external JVs added to %d frame JVs", f_v4, uniqueN(fr$jv_bvdid), uniqueN(base$jv_bvdid)))
