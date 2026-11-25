# parent_industry.R
# Parent industry for the resource-dependence check (robustness 19 of the
# pre-analysis plan; PI decisions of 2026-11-25 in docs/decisions.md, including
# "try to maximise the sample").
#   pick_industry()            one Orbis industry row per company
#   read_concordances()        Census NAICS concordances and the SIC chain
#   to_naics2017()             a code as NAICS 2017 (NAICS 2022 codes mapped back)
#   sic_to_naics4()            SIC 1987 codes to one NAICS 2017 4-digit industry
#   ciq_parent_naics()         Capital IQ industry tree to NAICS 2017 4-digit
#   resolve_parent_industry()  the code used for each parent, in this order:
#     1. own Orbis codes: primary NAICS (not for a holding), core NAICS,
#        secondary NAICS, skipping holding codes (NAICS 5511);
#     2. the ultimate owner's Orbis codes in the same order (owner not the
#        parent itself);
#     3. for Capital IQ parents (no BvD id): the Capital IQ industry tree,
#        mapped to SIC and on to NAICS 2017;
#     4. otherwise missing ("holding unresolved" for a holding parent).
#   A holding parent has primary NAICS 5511, or NACE group 64.2 (holding
#   companies) or 70.1 (head offices).
# Used by code/R/wrds/15_wrds_parent_industry.R; tested on simulated data by
# code/R/tests/synthetic_parent_industry.R.

blank_na <- function(x) { x <- as.character(x); x[!is.na(x) & trimws(x) == ""] <- NA_character_; x }
digits <- function(x) gsub("[^0-9]", "", blank_na(x))
is_holding_naics <- function(x) !is.na(x) & startsWith(digits(x), "5511")
is_holding_nace <- function(x) { d <- digits(x); !is.na(d) & (startsWith(d, "642") | startsWith(d, "701")) }

# Orbis can hold several industry rows per company and the same company in more
# than one library. The pick is deterministic: large before medium before small,
# then rows with a primary NAICS code, then by NACE and NAICS code.
pick_industry <- function(ind) {
  d <- copy(as.data.table(ind))
  for (v in intersect(names(d), c("nacepcod2", "naceccod2", "nacescod2", "naicspcod2017", "naicsccod2017", "naicsscod2017")))
    set(d, j = v, value = blank_na(d[[v]]))
  for (v in setdiff(c("naicsccod2017", "naicsscod2017"), names(d))) set(d, j = v, value = NA_character_)
  d[, lib_order := match(orbis_lib, c("l", "m", "s"))]
  multi <- d[, .(n_rows = .N,
                 n_naics = uniqueN(naicspcod2017[!is.na(naicspcod2017)]),
                 n_nace = uniqueN(nacepcod2[!is.na(nacepcod2)])), by = bvdid]
  d[, has_naics := !is.na(naicspcod2017)]
  setorderv(d, c("bvdid", "lib_order", "has_naics", "nacepcod2", "naicspcod2017"), c(1, 1, -1, 1, 1), na.last = TRUE)
  d <- unique(d, by = "bvdid")
  d <- merge(d[, .(bvdid, orbis_lib, nace = nacepcod2, naics = naicspcod2017,
                   naics_core = naicsccod2017, naics_sec = naicsscod2017)], multi, by = "bvdid")
  d[, flag_multi_rows := n_rows > 1L]
  d[, flag_code_conflict := n_naics > 1L | n_nace > 1L]
  d[, c("n_rows", "n_naics", "n_nace") := NULL]
  d[]
}

# ---- Concordances ----------------------------------------------------------------------
# Census files (https://www.census.gov/naics/?68967, concordances tab), unchanged in
# data/raw/external/census-naics-concordances-2026-11-25/. Each becomes a two-column
# table of codes (from, to) as character.
read_concordances <- function(dir) {
  rd <- function(f, skip, from_col, to_col) {
    x <- as.data.table(readxl::read_excel(file.path(dir, f), skip = skip, col_names = FALSE, col_types = "text", .name_repair = "minimal"))
    x <- data.table(from = digits(x[[from_col]]), to = digits(x[[to_col]]))
    unique(x[!is.na(from) & !is.na(to) & nchar(from) >= 2 & nchar(to) >= 2])
  }
  sic <- rd("1987_SIC_to_2002_NAICS.xls", 1, 1, 3)
  sic[, from := formatC(as.integer(from), width = 4, flag = "0")]
  list(sic_02 = sic,
       n02_07 = rd("2002_to_2007_NAICS.xls", 3, 1, 3),
       n07_12 = rd("2007_to_2012_NAICS.xls", 3, 1, 3),
       n12_17 = rd("2012_to_2017_NAICS.xlsx", 3, 1, 3),
       n22_17 = rd("2022_to_2017_NAICS.xlsx", 3, 1, 3))
}

# Modal NAICS 4-digit industry over a set of 6-digit targets; ties to the lowest code.
modal4 <- function(dt, key) {
  m <- unique(dt[, .(k = get(key), n4 = substr(to, 1, 4), src = from)])[, .N, by = .(k, n4)]
  setorder(m, k, -N, n4)
  setnames(unique(m, by = "k")[, .(k, n4)], "k", key)[]
}

# A code as NAICS 2017. Valid 2017 codes (and their 4-digit prefixes) pass; codes
# that exist only in NAICS 2022 are mapped to the modal 2017 4-digit industry.
to_naics2017 <- function(code, cw) {
  code <- digits(code)
  v17 <- unique(c(cw$n12_17$to, cw$n22_17$to))
  pre <- unique(unlist(lapply(2:5, function(k) substr(v17, 1, k))))   # valid 2017 prefixes of two to five digits
  ok <- !is.na(code) & ((nchar(code) == 6 & code %in% v17) | (nchar(code) %in% 2:5 & code %in% pre))
  out <- fifelse(ok, code, NA_character_)
  n22 <- cw$n22_17
  m <- modal4(n22[, .(from, to)][, from := from], "from")
  need <- !ok & !is.na(code)
  if (any(need)) {
    c6 <- code[need]
    hit6 <- m$n4[match(c6, m$from)]
    m4 <- modal4(n22[, .(from = substr(from, 1, 4), to)], "from")
    hit4 <- m4$n4[match(substr(c6, 1, 4), m4$from)]
    out[need] <- fifelse(!is.na(hit6), hit6, fifelse(nchar(c6) >= 4, hit4, NA_character_))
  }
  out
}

# SIC 1987 (4 digits) through NAICS 2002, 2007 and 2012 to NAICS 2017; returns the
# modal 2017 4-digit industry over all chain paths of the SIC codes given.
sic_chain <- function(cw) {
  ch <- merge(cw$sic_02[, .(sic = from, n02 = to)], cw$n02_07[, .(n02 = from, n07 = to)], by = "n02", allow.cartesian = TRUE)
  ch <- merge(ch, cw$n07_12[, .(n07 = from, n12 = to)], by = "n07", allow.cartesian = TRUE)
  ch <- merge(ch, cw$n12_17[, .(n12 = from, n17 = to)], by = "n12", allow.cartesian = TRUE)
  unique(ch[, .(sic, n17)])
}

# Capital IQ: deepest primary node(s) of each company's industry tree; walk up the
# tree to the nearest node with a SIC mapping; all SIC codes of those nodes; modal
# NAICS 2017 4-digit industry, each SIC code counted once per industry.
ciq_parent_naics <- function(tree, subtype, ind_sic, cw) {
  tr <- merge(as.data.table(tree)[primaryflag == 1], as.data.table(subtype)[, .(subtypeid, childlevel, subparentid)], by = "subtypeid")
  tr <- tr[tr[, .I[childlevel == max(childlevel)], by = companyid]$V1]
  up <- setNames(subtype$subparentid, subtype$subtypeid)
  mapped <- unique(ind_sic$subtypeid)
  node <- function(id) { k <- 0L; while (!is.na(id) && !(id %in% mapped) && k < 12L) { id <- unname(up[as.character(id)]); k <- k + 1L }
    if (!is.na(id) && id %in% mapped) id else NA_real_ }
  tr[, sic_node := vapply(subtypeid, node, numeric(1))]
  s <- merge(unique(tr[!is.na(sic_node), .(companyid, subtypeid = sic_node)]), ind_sic, by = "subtypeid", allow.cartesian = TRUE)
  s[, sic := formatC(as.integer(siccode), width = 4, flag = "0")]
  s <- unique(s[, .(companyid, sic)])
  chain <- sic_chain(cw)
  # Capital IQ also maps to SIC group codes (for example 0100, 0110) that the 1987
  # concordance does not list. Only for a company none of whose SIC codes match
  # exactly, a group code stands for all 1987 SIC codes of its group (two digits
  # for codes ending in 00, three digits otherwise).
  exact <- s[sic %in% chain$sic]
  rest <- s[!companyid %in% exact$companyid]
  if (nrow(rest)) {
    rest[, pre := fifelse(endsWith(sic, "00"), substr(sic, 1, 2), substr(sic, 1, 3))]
    known <- unique(chain$sic)
    rest <- rest[, .(sic = known[startsWith(known, pre)]), by = .(companyid, pre)][, .(companyid, sic)]
    exact <- rbind(exact, unique(rest))
  }
  ch <- merge(exact, chain, by = "sic", allow.cartesian = TRUE)
  m <- unique(ch[, .(companyid, sic, n4 = substr(n17, 1, 4))])[, .N, by = .(companyid, n4)]
  setorder(m, companyid, -N, n4)
  res <- unique(m, by = "companyid")[, .(companyid, ciq_naics4 = n4)]
  all <- data.table(companyid = unique(as.data.table(tree)$companyid))
  res <- merge(all, res, by = "companyid", all.x = TRUE)
  res[, ciq_primary := companyid %in% tr$companyid]
  res[, ciq_sic := companyid %in% s$companyid]
  res[]
}

# ---- Resolve ---------------------------------------------------------------------------
# parents: parent_bvdid, parent_guo. picked: pick_industry() output for parents and
# owners. cw: read_concordances(). ciq: ciq_parent_naics() output (or NULL).
resolve_parent_industry <- function(parents, picked, cw, ciq = NULL) {
  p <- unique(as.data.table(parents)[, .(parent_bvdid, parent_guo)])
  p[, parent_guo := blank_na(parent_guo)]
  stopifnot(!anyDuplicated(p$parent_bvdid))
  # candidate codes per company, in order, as NAICS 2017, holding codes dropped
  cand <- function(pk) {
    pk <- copy(pk)
    pk[, holding := is_holding_naics(naics) | (is.na(naics) & is_holding_nace(nace))]
    long <- rbind(pk[holding == FALSE, .(bvdid, ord = 1L, src = "primary", code = naics)],
                  pk[, .(bvdid, ord = 2L, src = "core", code = naics_core)],
                  pk[, .(bvdid, ord = 3L, src = "secondary", code = naics_sec)])
    long <- long[!is.na(code)]
    long[, code := to_naics2017(code, cw)]
    long <- long[!is.na(code) & !is_holding_naics(code)]
    setorder(long, bvdid, ord)
    list(best = unique(long, by = "bvdid")[, .(bvdid, code, src)], holding = pk[, .(bvdid, holding)])
  }
  cd <- cand(picked)
  own <- picked[, .(parent_bvdid = bvdid, orbis_lib, naics_direct = naics, nace_direct = nace, flag_multi_rows, flag_code_conflict)]
  p <- merge(p, own, by = "parent_bvdid", all.x = TRUE)
  p <- merge(p, cd$holding[, .(parent_bvdid = bvdid, holding)], by = "parent_bvdid", all.x = TRUE)
  p[is.na(holding), holding := FALSE]
  p[, flag_not_in_orbis_industry := is.na(orbis_lib)]
  p[is.na(flag_multi_rows), `:=`(flag_multi_rows = FALSE, flag_code_conflict = FALSE)]
  p <- merge(p, cd$best[, .(parent_bvdid = bvdid, own_code = code, own_src = src)], by = "parent_bvdid", all.x = TRUE)
  p <- merge(p, cd$best[, .(parent_guo = bvdid, guo_code = code, guo_src = src)], by = "parent_guo", all.x = TRUE)
  p[!is.na(parent_guo) & parent_guo == parent_bvdid, `:=`(guo_code = NA_character_, guo_src = NA_character_)]
  p[, ciq_companyid := fifelse(startsWith(parent_bvdid, "CIQ"), sub("^CIQ", "", parent_bvdid), NA_character_)]
  if (!is.null(ciq)) {
    p <- merge(p, ciq[, .(ciq_companyid = sprintf("%.0f", companyid), ciq_naics4)], by = "ciq_companyid", all.x = TRUE)
  } else p[, ciq_naics4 := NA_character_]
  p[, rd_naics_source := fifelse(!is.na(own_code), paste("own", own_src),
                          fifelse(!is.na(guo_code), paste("ultimate owner", guo_src),
                          fifelse(!is.na(ciq_naics4) & !is_holding_naics(ciq_naics4), "capital iq",
                          fifelse(holding, "holding unresolved", "missing"))))]
  p[, rd_naics := fifelse(!is.na(own_code), own_code, fifelse(!is.na(guo_code), guo_code,
                  fifelse(rd_naics_source == "capital iq", ciq_naics4, NA_character_)))]
  # Codes of two or three digits cannot give a NAICS 4-digit industry; flagged.
  p[, flag_naics_short := !is.na(rd_naics) & nchar(rd_naics) < 4L]
  p[, rd_naics4 := fifelse(!is.na(rd_naics) & nchar(rd_naics) >= 4L, substr(rd_naics, 1, 4), NA_character_)]
  p[, flag_naics_missing := is.na(rd_naics)]
  p[, flag_holding_unresolved := rd_naics_source == "holding unresolved"]
  keep <- c("parent_bvdid", "parent_guo", "ciq_companyid", "orbis_lib", "naics_direct", "nace_direct", "holding",
            "own_code", "own_src", "guo_code", "guo_src", "ciq_naics4", "rd_naics", "rd_naics4", "rd_naics_source",
            "flag_multi_rows", "flag_code_conflict", "flag_not_in_orbis_industry", "flag_naics_short",
            "flag_naics_missing", "flag_holding_unresolved")
  p <- p[, ..keep]
  setorder(p, parent_bvdid)
  p[]
}
