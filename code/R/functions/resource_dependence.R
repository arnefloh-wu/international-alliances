# resource_dependence.R
# Resource-dependence variables for robustness 19 of the pre-analysis plan
# pap-v1.0 (definition and coverage rule v2 in docs/decisions.md, 2026-11-25):
# a domain is core for a parent if its employment share in the parent's industry
# is at least twice its share across all industries (rd_core); rd_ratio is the
# log of that ratio. Matrix: BLS OEWS May 2021 national industry-specific
# estimates (data/raw/external/oesm21in4.zip, unchanged). Parent industry: the
# 4-digit NAICS 2017 code of rule v2 (data/interim/parent-industry-v2-*.csv).
#
#   read_oews()             the OEWS sector, 3-digit and 4-digit files as one long table
#   oews_domain_shares()    domain employment shares per OEWS industry and across all industries
#   match_oews_industry()   parent code to an OEWS industry: exact 4-digit, the
#                           combined industry whose title lists the code, 3-digit
#   rd_ijv_domain()         per IJV and domain: any-parent (H1) and host-country-parent (H3) versions
#
# No staffing data are read.

#' OEWS files as one long table (level, naics, title, occ_code, o_group, tot_emp).
#' A .csv path is read as an already long table (synthetic twin).
read_oews <- function(path) {
  if (grepl("[.]csv$", path))
    return(fread(path, colClasses = list(character = c("level", "naics", "title", "occ_code", "o_group"))))
  td <- file.path(tempdir(), "oews-panel"); dir.create(td, showWarnings = FALSE)
  utils::unzip(path, exdir = td)
  rd <- function(f, level) {
    x <- as.data.table(readxl::read_excel(file.path(td, "oesm21in4", f), sheet = 1, col_types = "text"))
    x[, .(level = level, naics = NAICS, title = NAICS_TITLE, occ_code = OCC_CODE, o_group = O_GROUP,
          tot_emp = suppressWarnings(as.numeric(gsub(",", "", TOT_EMP))))]   # "**" and "*" (suppressed) become NA
  }
  rbind(rd("nat4d_M2021_dl.xlsx", "4d"), rd("nat3d_M2021_dl.xlsx", "3d"), rd("natsector_M2021_dl.xlsx", "sector"))
}

#' Employment share of each domain per industry and across all industries.
#' Domains: SOC minor groups (OEWS minor rows, "11-1000" is domain "11-1"), with
#' the occupations of the regulatory list carved out as their own domain: their
#' SOC detailed codes (the first seven characters of the O*NET-SOC code) are
#' summed into reg_label and subtracted from their minor groups. Suppressed cells
#' are left out of the numerator; the denominator is the industry total. The
#' all-industries share sums the sector rows (all 20 sectors).
oews_domain_shares <- function(oews, occ, reg_col = "regulatory_narrow", reg_label = "REG") {
  regsoc <- unique(substr(occ[get(reg_col) %in% TRUE, onet_code], 1, 7))
  mn <- oews[o_group == "minor", .(level, naics, domain = substr(occ_code, 1, 4), emp = fcoalesce(as.numeric(tot_emp), 0))]
  dt <- oews[o_group == "detailed" & occ_code %chin% regsoc, .(level, naics, domain = substr(occ_code, 1, 4), emp = fcoalesce(as.numeric(tot_emp), 0))]
  carve <- dt[, .(r = sum(emp)), by = .(level, naics, domain)]
  mn[carve, on = .(level, naics, domain), emp := pmax(0, emp - i.r)]
  reg <- dt[, .(emp = sum(emp)), by = .(level, naics)][, domain := reg_label]
  tot <- oews[o_group == "total", .(level, naics, total = tot_emp)]
  sh <- merge(rbind(mn, reg, use.names = TRUE), tot, by = c("level", "naics"))
  tot_all <- tot[level == "sector", sum(total, na.rm = TRUE)]
  all <- sh[level == "sector", .(share_all = sum(emp) / tot_all), by = domain]
  ind <- sh[level != "sector", .(level, naics, domain, share = emp / total)]
  merge(ind, all, by = "domain", all.x = TRUE)
}

#' OEWS industry for 4-digit NAICS 2017 codes: exact 4-digit industry, else the
#' OEWS combined industry (code with "A") whose title lists the code, else the
#' 3-digit industry, else NA. Returns level, naics and match route.
match_oews_industry <- function(code4, oews) {
  code4 <- as.character(code4)
  ind4 <- unique(oews[level == "4d", .(naics, title)])
  exact <- ind4[!grepl("A", naics), .(c4 = substr(naics, 1, 4), naics)]
  comb <- ind4[grepl("A", naics)][, .(c4 = regmatches(title, gregexpr("[0-9]{4}", title))[[1]]), by = naics]
  ind3 <- unique(oews[level == "3d", .(c3 = substr(naics, 1, 3), naics)])
  out <- data.table(code4 = code4, level = NA_character_, naics = NA_character_, route = NA_character_)
  i <- match(code4, exact$c4); k <- !is.na(i) & !is.na(code4)
  out[k, `:=`(level = "4d", naics = exact$naics[i[k]], route = "4-digit")]
  i <- match(code4, comb$c4); k <- is.na(out$naics) & !is.na(i) & !is.na(code4)
  out[k, `:=`(level = "4d", naics = comb$naics[i[k]], route = "combined")]
  i <- match(substr(code4, 1, 3), ind3$c3); k <- is.na(out$naics) & !is.na(i) & !is.na(code4)
  out[k, `:=`(level = "3d", naics = ind3$naics[i[k]], route = "3-digit")]
  out[]
}

#' Resource-dependence variables per IJV and domain.
#' rd_core, rd_ratio (H1, available case): core for any parent with a matched code;
#'   the largest log ratio among those parents. rd_code_missing: some parent of the
#'   IJV has no matched code (IJV level). rd_all_coded: every parent has one.
#' Returns list(cell = IJV x domain table, ijv = IJV-level coverage indicators).
#' rd_core_hcp, rd_ratio_hcp (H3): the host-country parent with the larger equity
#'   share among the host-country parents that have a matched code.
rd_ijv_domain <- function(par, pind, shares, domains) {
  p <- merge(par[, .(jv_bvdid, parent_bvdid, parent_rank, host_direct)], pind[, .(parent_bvdid, level, naics)],
             by = "parent_bvdid", all.x = TRUE)
  cov <- p[, .(rd_code_missing = as.integer(any(is.na(naics))), rd_all_coded = as.integer(all(!is.na(naics))),
              rd_any_coded = as.integer(any(!is.na(naics)))), by = jv_bvdid]
  pm <- p[!is.na(naics)]
  x <- merge(pm, shares[domain %chin% domains], by = c("level", "naics"), allow.cartesian = TRUE)
  x[, ratio := share / share_all]
  x[, `:=`(core = as.integer(ratio >= 2), lr = fifelse(ratio > 0, log(ratio), NA_real_))]
  any_p <- x[, .(rd_core = max(core), rd_ratio = if (all(is.na(lr))) NA_real_ else max(lr, na.rm = TRUE)), by = .(jv_bvdid, domain)]
  hcp <- x[host_direct %in% TRUE][order(jv_bvdid, domain, parent_rank)]
  hcp <- unique(hcp, by = c("jv_bvdid", "domain"))[, .(jv_bvdid, domain, rd_core_hcp = core, rd_ratio_hcp = lr)]
  list(cell = merge(any_p, hcp, by = c("jv_bvdid", "domain"), all = TRUE), ijv = cov)
}
