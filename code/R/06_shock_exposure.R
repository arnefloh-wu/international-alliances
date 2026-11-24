# 06_shock_exposure.R
# Stage 5a, Phase B (/shock-options rescore): exposure counts for the shocks
# shortlisted at gate 5a (2026-11-24): S13 Brexit, S06 investment screening in
# OECD hosts, S19 Chinese coercion episodes, and S09 US Entity List (kept only
# if the name match finds at least 30 exposed IJVs).
#
# Independence rule (CLAUDE.md rule 8, strict reading of 2026-11-24). This
# script counts structural and denominator quantities only: exposed country
# pairs and IJVs, total hires and person-years (never split by origin), the
# IJV-function-years and IJV-years that reach the cell threshold, onset years,
# available pre- and post-onset years, and control-group sizes. It never
# classifies a hire by origin, never computes a share, and never compares a
# quantity before against after onset beyond counting the years and cells that
# exist. It does not read data/interim/staffing-tabulations-*, the career
# histories or the frame's exposure_group column (dropped on read).
#
# Functions are Revelio's own role_k10 codes (job_category of the first
# position for hires, function_role_k10 of the spell for person-years). The
# project's function map is set at gate 5.
#
# Inputs (licensed, local only): data/processed/ijv-matched-, ijv-parents-,
# ijv-employee-spells-<RUN>; data/raw/orbis-full-<RUN>.csv (NACE, NAICS, Capital
# IQ industry); data/raw/revelio-jv-positions-full-2026-10-09.parquet (hire dates).
# External: data/raw/external/consolidated-screening-list-2026-11-24.csv
# (trade.gov, downloaded 2026-11-24; downloaded here if missing). The ASPI case
# list and the screening adoption years are transcribed below with their sources.
#
# Outputs:
#   data/interim/shock-exposure-ijv-2026-11-24.csv        row level (gitignored)
#   data/interim/shock-s09-entity-list-matches-2026-11-24.csv  row level (gitignored)
#   literature/shock-scan/rescoring-counts-2026-11-24.csv  aggregates only
#
# Run from the repository root:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/06_shock_exposure.R

source("code/R/00_setup.R")
require_pkgs(c("arrow", "stringdist"))
source("code/R/functions/frame.R")            # eu27
t0 <- Sys.time()
say <- function(...) message(format(Sys.time(), "%H:%M:%S"), " ", sprintf(...))

RUN         <- "v3-2026-10-09"
OUT_DATE    <- "2026-11-24"
PANEL_START <- 2008L     # first year counted (Revelio coverage; Phase A data inventory)
PANEL_END   <- 2025L     # last complete year (Revelio data run to 2026-09)
ONSET_MAX   <- 2023L     # gate 5a, decision 5
MIN_CELL    <- const$min_cell_emp   # 5, gate 4 cell rule
f_ijv   <- file.path(paths$processed, sprintf("ijv-matched-%s.csv", RUN))
f_par   <- file.path(paths$processed, sprintf("ijv-parents-%s.csv", RUN))
f_spell <- file.path(paths$processed, sprintf("ijv-employee-spells-%s.parquet", RUN))
f_orbis <- file.path(paths$raw, sprintf("orbis-full-%s.csv", RUN))
f_pos   <- file.path(paths$raw, "revelio-jv-positions-full-2026-10-09.parquet")
f_csl   <- file.path(paths$raw, "external", "consolidated-screening-list-2026-11-24.csv")
URL_CSL <- "https://data.trade.gov/downloadable_consolidated_screening_list/v1/consolidated.csv"
f_expo  <- file.path(paths$interim, sprintf("shock-exposure-ijv-%s.csv", OUT_DATE))
f_s09   <- file.path(paths$interim, sprintf("shock-s09-entity-list-matches-%s.csv", OUT_DATE))
f_out   <- file.path("literature", "shock-scan", sprintf("rescoring-counts-%s.csv", OUT_DATE))

# ---- 0. Inputs ---------------------------------------------------------------------
ijv <- fread(f_ijv, colClasses = list(character = "jv_bvdid"), na.strings = "")
ijv[, exposure_group := NULL]        # the frame's group is not the treatment definition
par <- fread(f_par, colClasses = list(character = c("jv_bvdid", "parent_bvdid", "parent_guo")), na.strings = "")
stopifnot(all(par$jv_bvdid %in% ijv$jv_bvdid))
par <- merge(par, ijv[, .(jv_bvdid, host = jv_country, source)], by = "jv_bvdid")
# Owner country: Orbis GUO country for Orbis-sourced IJVs; Capital IQ ids give "CI".
par[, guo_ok := source == "orbis" & !is.na(guo_country) & guo_country != "CI"]
jvp <- par[, .(par_rev = any(parent_in_revelio), host_parent = any(parent_country == host)), by = jv_bvdid]
ijv <- merge(ijv, jvp, by = "jv_bvdid")
say("core_main: %d IJVs, %d parent rows", nrow(ijv), nrow(par))

# Sector codes (NACE group for Orbis IJVs, NAICS as fallback, Capital IQ industry text).
of <- fread(f_orbis, select = c("jv_bvdid", "nace", "naics", "nace_desc", "source"), colClasses = "character")
of <- unique(of, by = "jv_bvdid")[jv_bvdid %in% ijv$jv_bvdid]
ijv <- merge(ijv, of[, .(jv_bvdid, nace, naics, ind_text = nace_desc)], by = "jv_bvdid", all.x = TRUE)

# ---- 1. Cells: hires and person-years per IJV x Revelio function x year ---------------
# Hire: first dated position at the matched JV entity, for people in the spell
# table (as in code/R/wrds/11_staffing_tabulations.R). No origin is attached.
spells <- as.data.table(arrow::read_parquet(f_spell, col_select = c("jv_bvdid", "user_id", "first_reference_year", "last_reference_year", "function_role_k10")))
pairs <- unique(spells[, .(jv_bvdid, user_id)])
pos <- as.data.table(arrow::read_parquet(f_pos, col_select = c("user_id", "position_id", "rcid", "start_date", "job_category")))
pos <- unique(pos, by = "position_id")
pos <- merge(pos, ijv[, .(rcid = as.numeric(rcid_jv), jv_bvdid)], by = "rcid")
pos <- pos[pairs, on = .(jv_bvdid, user_id), nomatch = NULL][!is.na(start_date)]
setorder(pos, jv_bvdid, user_id, start_date)
hire <- unique(pos, by = c("jv_bvdid", "user_id"))[, .(jv_bvdid, fn = job_category, year = year(start_date))]
rm(pos); invisible(gc())
hire <- merge(hire, ijv[, .(jv_bvdid, formation_year)], by = "jv_bvdid")[year >= pmax(formation_year, PANEL_START) & year <= PANEL_END]
cells_h <- hire[, .(n = .N), by = .(jv_bvdid, fn, year)]
say("hires in the counting window %d-%d: %d", PANEL_START, PANEL_END, nrow(hire))
rm(hire)
spells <- merge(spells, ijv[, .(jv_bvdid, formation_year)], by = "jv_bvdid")
cells_e <- rbindlist(lapply(PANEL_START:PANEL_END, function(y) {
  x <- unique(spells[first_reference_year <= y & last_reference_year >= y & y >= formation_year], by = c("jv_bvdid", "user_id"))
  x[, .(n = .N), by = .(jv_bvdid, fn = function_role_k10)][, year := y]
}))
rm(spells, pairs); invisible(gc())
say("cells: %d IJV-function-years with a hire, %d with an employee", nrow(cells_h), nrow(cells_e))
yr_h <- cells_h[, .(n = sum(n)), by = .(jv_bvdid, year)]   # IJV-years, all functions

# ---- 2. Shock definitions ------------------------------------------------------------
# Each builder returns one row per exposed IJV x exposed country pair with its
# onset year. An IJV's onset is the earliest onset among its pairs.

# S13 Brexit. Free movement ended on 31 Dec 2020 for EU, EEA and Swiss
# citizens (gov.uk, opened 2026-11-24); Irish citizens keep Common Travel Area
# rights. Main exposure: parent-host pairs (UK-hosted IJV with a parent from the
# set, or set-hosted IJV with a UK parent), because the H4 channel is a change
# in the host environment. Parent-parent pairs hosted in third countries are
# counted as a separate variant.
set13 <- c(eu27, "IS", "LI", "NO", "CH")
b13 <- function(ij, pa, set = set13, onset = 2021L, third = FALSE) {
  p <- pa[, .(jv_bvdid, pc = parent_country, host)]
  if (!third) {
    out <- rbind(p[host == "GB" & pc %chin% set, .(jv_bvdid, pair = paste0("GB-", pc))],
                 p[host %chin% set & pc == "GB", .(jv_bvdid, pair = paste0("GB-", host))])
  } else {
    w <- p[, .(gb = any(pc == "GB"), s = list(intersect(pc, set)), host = host[1]), by = jv_bvdid][gb & lengths(s) > 0 & host != "GB" & !host %chin% set]
    out <- w[, .(pair = paste0("GB-", unlist(s))), by = jv_bvdid]
  }
  unique(out)[, onset := onset][]
}
ctrl13 <- function(ij, pa, set = set13) {
  link <- unique(rbind(b13(ij, pa, set), b13(ij, pa, set, third = TRUE))$jv_bvdid)
  ij[(jv_country %chin% set | jv_country == "GB") & !jv_bvdid %chin% link, jv_bvdid]
}

# S19 Chinese coercion. Government-targeted cases in ASPI, Hanson, Currey and
# Beattie (2020), "The Chinese Communist Party's coercive diplomacy", Policy
# Brief 36/2020, Appendix Table 1 (100 cases, 27 countries plus the EU, 2010 to
# 2020), transcribed from the PDF opened on 2026-11-24
# (https://s3-ap-southeast-2.amazonaws.com/ad-aspi/2020-08/The%20CCPs%20coercive%20diplomacy_0.pdf;
# copy in data/raw/external/). econ = first case of trade, tourism or investment
# restrictions or a popular boycott; any = first case of any category. The EU
# entry (one threat, Sep 2016) is not assigned to member states.
aspi <- fread(text = "
country,iso,econ_year,econ_month,any_year,any_month,n_cases
Australia,AU,2016,9,2016,9,17
Botswana,BW,NA,NA,2017,7,1
Brazil,BR,NA,NA,2020,3,1
Canada,CA,2019,1,2014,8,10
Czech Republic,CZ,2019,10,2019,10,2
Denmark,DK,2019,12,2013,11,2
Eswatini,SZ,2020,2,2020,2,2
France,FR,2020,2,2020,2,1
Germany,DE,NA,NA,2019,8,4
India,IN,2019,8,2019,8,1
Japan,JP,2010,9,2010,9,6
Kenya,KE,2018,9,2018,9,1
Mongolia,MN,2016,11,2016,11,2
Netherlands,NL,2020,4,2020,4,2
New Zealand,NZ,2019,2,2019,2,3
Norway,NO,2010,10,2010,10,5
Palau,PW,2017,11,2017,11,1
Philippines,PH,2012,5,2012,5,4
Slovakia,SK,NA,NA,2016,10,1
South Africa,ZA,NA,NA,2018,2,1
South Korea,KR,2016,8,2016,7,4
Sweden,SE,2018,9,2018,9,7
Taiwan,TW,2016,5,2016,5,4
Turkey,TR,2016,2,2016,2,3
United Kingdom,GB,NA,NA,2012,5,4
United States,US,2019,6,2019,6,9
Vietnam,VN,2014,5,2014,5,1
", na.strings = "NA")
stopifnot(sum(aspi$n_cases) + 1L == 100L, nrow(aspi) == 27L)   # plus the EU case
b19 <- function(ij, pa, onset_col = "econ_year", china = "CN", broad = FALSE, drop = character()) {
  tg <- aspi[!is.na(get(onset_col)) & !iso %chin% drop, .(iso, onset = as.integer(get(onset_col)))]
  p <- pa[, .(jv_bvdid, pc = parent_country, host)]
  out <- merge(p[host %chin% china & !pc %chin% china], tg, by.x = "pc", by.y = "iso")[, .(jv_bvdid, pair = paste0("CN-", pc), onset)]
  if (broad) out <- rbind(out, merge(p[pc %chin% china & !host %chin% china], tg, by.x = "host", by.y = "iso")[, .(jv_bvdid, pair = paste0("CN-", host), onset)])
  unique(out)
}
ctrl19 <- function(ij, pa, china = "CN") {
  tgt <- pa[parent_country %chin% aspi$iso & host %chin% china, unique(jv_bvdid)]
  ij[jv_country %chin% china & !jv_bvdid %chin% tgt, jv_bvdid]
}

# S06 investment screening. Treatment: an IJV in an OECD host from the year the
# host adopted or tightened a cross-sectoral screening mechanism (first such
# year in 2017 to 2023; mechanisms that existed before 2017 are the baseline),
# with a non-allied foreign parent and in a screened sector.
# EU hosts: European Commission, "List of screening mechanisms notified by
# Member States", last update 9 Feb 2026 (circabc download, opened 2026-11-24,
# copy in data/raw/external/); year of entry into force where the list states
# it, otherwise year of the instrument. Other hosts: search snippets of
# 2026-11-24, all [unverified].
scr <- fread(text = "
iso,onset,status,source
AT,2020,verified,EC list: Investment Control Act (InvKG) in force 25 Jul 2020
BE,2023,verified,EC list: cooperation agreement law of 14 Feb 2023; in force 1 Jul 2023
BG,2024,verified,EC list: Investment Promotion Act ch. 6 in force 12 Mar 2024 (after window)
CZ,2021,verified,EC list: Act 34/2021 Coll. on screening of foreign investments
DK,2021,verified,EC list: Investment Screening Act (Act 842 of 10 May 2021)
DE,2017,verified,EC list: Foreign Trade and Payments Act as amended by Act of 20 Jul 2017; further 2018 to 2021
EE,2023,verified,EC list: Foreign Investment Reliability Assessment Act (RT I 10.02.2023)
IE,2025,verified,EC list: Screening of Third Country Transactions Act 2023 effective 6 Jan 2025 (after window)
GR,2025,verified,EC list: Law 5202/2025 (after window)
ES,2020,verified,EC list: Royal Decree-Law 8/2020 of 17 Mar 2020
FR,2019,verified,EC list: Order of 31 Dec 2019 on foreign investments
IT,2019,verified,EC list: Decree-Law 105 of 21 Sep 2019 (first listed amendment after 2017; golden power since DL 21/2012)
LU,2023,verified,EC list: Law of 14 Jul 2023; in force 1 Sep 2023
NL,2023,verified,EC list: Vifo Act; entry into force set by decree of 4 May 2023
PL,2020,verified,EC list: Act of 19 Jun 2020 (extension of the Act of 24 Jul 2015)
PT,NA,verified,EC list: Decree-Law 138/2014 only; no tightening listed for 2017 to 2023
SK,2022,verified,EC list: Act 497/2022 Coll. on the screening of foreign investments
FI,2020,verified,EC list: amendments 682/2020 of 2 Oct 2020 to Act 172/2012
SE,2023,verified,EC list: Act 2023:560 on the screening of foreign direct investments
HR,NA,verified,not in the EC list (no notified mechanism)
CY,NA,verified,not in the EC list (no notified mechanism)
US,2018,unverified,FIRRMA signed 13 Aug 2018 (Treasury fact sheet in search results)
GB,2022,unverified,National Security and Investment Act 2021 in force 4 Jan 2022 (gov.uk in search results)
AU,2020,unverified,temporary nil monetary threshold 2020; national security test from 1 Jan 2021 (search results)
CA,2020,unverified,policy statement of 18 Apr 2020 on enhanced scrutiny (search results)
NZ,2020,unverified,Overseas Investment (Urgent Measures) Amendment Act 2020 effective 16 Jun 2020 (search results)
JP,2020,unverified,FEFTA amendment effective 8 May 2020 (search results)
KR,2020,unverified,2020 amendment of the FIPA enforcement decree (search results; date not confirmed)
IL,2019,unverified,Security Cabinet decision B/372 of 30 Oct 2019 (search results)
NO,2019,unverified,Security Act ch. 10 in force 1 Jan 2019 (search results)
", na.strings = "NA", sep = ",", quote = "")
oecd38 <- c("AU","AT","BE","CA","CL","CO","CR","CZ","DK","EE","FI","FR","DE","GR","HU","IS","IE","IL","IT","JP","KR","LV","LT","LU","MX","NL","NZ","NO","PL","PT","SK","SI","ES","SE","CH","TR","GB","US")
undated06 <- setdiff(oecd38, scr$iso)    # [DATA]: no adoption year looked up
# Non-allied parents. Main: China incl. Hong Kong and Macao. Broad: the foreign
# adversaries of 15 CFR 791.4(a) (law.cornell.edu, opened 2026-11-24): China
# incl. Hong Kong and Macao, Cuba, Iran, North Korea, Russia, Venezuela.
na_main  <- c("CN", "HK", "MO")
na_broad <- c("CN", "HK", "MO", "CU", "IR", "KP", "RU", "VE")
# Screened sectors: Regulation (EU) 2019/452, Art. 4(1) (critical
# infrastructure incl. energy, transport, water, health, communications, media,
# data processing; critical technologies and dual-use items; critical inputs incl.
# energy and raw materials; sensitive information; media), as adopted
# (legislation.gov.uk, opened 2026-11-24). The NACE Rev. 2, NAICS and Capital IQ
# mapping below is the agent's and needs the PI's review.
nace_core   <- c("05","06","07","09","19","21","26","35","36","50","51","53","58","59","60","61","62","63","72","86",
                 "24.4","25.4","27.2","30.3","30.4","49.1","49.2","49.5","52.2")
nace_broad  <- c(nace_core, "20","27","28","30","49","52","71")
naics_core  <- c("211","2121","2122","213","324","3254","334","2211","2212","2213","481","482","483","486","4881","4882","4883",
                 "491","492","511","512","515","517","518","519","5415","5417","621","622","332992","332993","332994",
                 "33641","336992","335911","335912","33141","33142","33149")
naics_broad <- c(naics_core, "325","335","333","336","484","493","5413")
ciq_core    <- c("Oil, Gas and Consumable Fuels","Energy Equipment and Services","Metals and Mining","Electric Utilities","Gas Utilities",
                 "Multi-Utilities","Water Utilities","Independent Power and Renewable Electricity Producers","Aerospace and Defense",
                 "Semiconductors and Semiconductor Equipment","Electronic Equipment, Instruments and Components",
                 "Technology Hardware, Storage and Peripherals","Communications Equipment","Diversified Telecommunication Services",
                 "Wireless Telecommunication Services","Media","Interactive Media and Services","IT Services","Software","Pharmaceuticals",
                 "Biotechnology","Life Sciences Tools and Services","Health Care Providers and Services","Transportation Infrastructure",
                 "Air Freight and Logistics","Marine Transportation","Passenger Airlines","Airlines")
ciq_broad   <- c(ciq_core, "Chemicals","Electrical Equipment","Machinery","Health Care Equipment and Supplies","Ground Transportation","Road and Rail")
pref <- function(code, set) { code[is.na(code)] <- ""; Reduce(`|`, lapply(set, function(s) startsWith(code, s)), init = rep(FALSE, length(code))) }
ijv[, nace_div := substr(nace, 1, 2)]
ijv[, sector_known := (!is.na(nace) & nace != "") | (!is.na(naics) & naics != "") | (source == "ciq" & !is.na(ind_text) & ind_text != "")]
ijv[, screened_core := fifelse(source == "ciq", ind_text %chin% ciq_core,
                       fifelse(!is.na(nace) & nace != "", pref(nace, nace_core), pref(naics, naics_core)))]
ijv[, screened_broad := fifelse(source == "ciq", ind_text %chin% ciq_broad,
                        fifelse(!is.na(nace) & nace != "", pref(nace, nace_broad), pref(naics, naics_broad)))]
b06 <- function(ij, pa, na = na_main, sector = "screened_core") {
  hosts <- scr[!is.na(onset) & onset <= ONSET_MAX, .(host = iso, onset)]
  ok <- if (is.null(sector)) ij$jv_bvdid else ij[get(sector) == TRUE, jv_bvdid]
  p <- pa[jv_bvdid %chin% ok & parent_country %chin% na & parent_country != host, .(jv_bvdid, pc = parent_country, host)]
  unique(merge(p, hosts, by = "host")[, .(jv_bvdid, pair = paste0(host, "-", pc), onset)])
}
ctrl06 <- function(ij, pa, na = na_main, sector = "screened_core") {
  hosts <- scr[!is.na(onset) & onset <= ONSET_MAX, iso]
  nap <- pa[parent_country %chin% na & parent_country != host, unique(jv_bvdid)]
  ij[jv_country %chin% hosts & get(sector) == TRUE & !jv_bvdid %chin% nap, jv_bvdid]   # same hosts and sectors, allied parents only
}

# S09 US Entity List. Consolidated Screening List (trade.gov), Entity List
# rows; start_date is the listing date shown for each entry; where it is blank
# the year of the first Federal Register citation is used (volume + 1935).
if (!file.exists(f_csl)) { dir.create(dirname(f_csl), showWarnings = FALSE, recursive = TRUE); download.file(URL_CSL, f_csl, mode = "wb") }
csl <- fread(f_csl, colClasses = "character", encoding = "UTF-8")
el <- csl[startsWith(source, "Entity List")]
el[, el_id := .I]
el[, el_ctry := vapply(strsplit(addresses, ";\\s*"), function(v) {
  m <- regmatches(v, regexpr(",\\s*[A-Z]{2}\\s*$", v)); paste(unique(gsub("[^A-Z]", "", m)), collapse = "|") }, "")]
el[, fr_vol := suppressWarnings(as.integer(sub("^\\D*(\\d+)\\s*FR.*$", "\\1", federal_register_notice)))]
el[, list_year := fifelse(start_date != "", as.integer(substr(start_date, 1, 4)), fr_vol + 1935L)]
el_nm <- el[, .(name = c(name, unlist(strsplit(alt_names, ";\\s*")))), by = .(el_id, el_ctry, list_year)][name != ""]
el_nm[, norm := normalize_name(name)]
el_nm <- unique(el_nm[nchar(norm) >= 4], by = c("el_id", "norm"))
s09_match <- function(pa) {
  p <- rbind(pa[, .(jv_bvdid, side = "direct", pname = parent_name, pctry = parent_country)],
             pa[!is.na(guo_name), .(jv_bvdid, side = "owner", pname = guo_name, pctry = fifelse(guo_ok, guo_country, parent_country))])
  p[, norm := normalize_name(pname)]
  u <- unique(p[nchar(norm) >= 3, .(norm, pctry)])
  m <- rbindlist(lapply(split(u, u$pctry), function(d) {
    e <- el_nm[grepl(d$pctry[1], el_ctry, fixed = TRUE)]
    if (!nrow(e)) return(NULL)
    rbindlist(lapply(seq_len(nrow(d)), function(i) {
      a <- d$norm[i]; tk <- strsplit(a, " ")[[1]]; nt <- length(tk)
      eq  <- e$norm == a
      # name plus one alias token: the token repeats a name word, is the name's
      # initials (with or without a trailing c for corporation), or is a Russian
      # legal form that normalize_name() keeps
      extra <- sub(paste0("^", a, " "), "", e$norm)
      ini <- paste(substr(tk, 1, 1), collapse = "")
      ali <- startsWith(e$norm, paste0(a, " ")) & lengths(strsplit(e$norm, " ")) == nt + 1L &
             (extra %chin% tk | extra %chin% c(ini, paste0(ini, "c")) | extra %chin% c("oao", "pao", "ao", "ojsc"))
      grp <- startsWith(e$norm, paste0(a, " ")) & nt >= 2L & nchar(a) >= 10L                  # listed unit of the group
      k <- which(eq | ali | grp)
      if (!length(k)) return(NULL)
      data.table(norm = a, pctry = d$pctry[1], el_id = e$el_id[k], el_norm = e$norm[k], list_year = e$list_year[k],
                 rule = fifelse(eq[k] | ali[k], "strict", "group"))
    }))
  }))
  if (!nrow(m)) return(m)
  merge(p[, .(jv_bvdid, side, norm, pctry)], m, by = c("norm", "pctry"), allow.cartesian = TRUE)
}
b09 <- function(ij, pa, rules = "strict") {
  m <- s09_match(pa)[rule %chin% rules & !is.na(list_year)]
  if (!nrow(m)) return(data.table(jv_bvdid = character(), pair = character(), onset = integer()))
  m <- m[, .(onset = min(list_year), lc = pctry[1]), by = jv_bvdid]
  other <- pa[, .(jv_bvdid, oc = parent_country)]
  out <- merge(m, other, by = "jv_bvdid", allow.cartesian = TRUE)[oc != lc]
  unique(out[, .(jv_bvdid, pair = paste0(lc, "-", oc), onset)])
}

# ---- 3. Counting --------------------------------------------------------------------
ijv_y <- ijv[, .(jv_bvdid, formation_year, strategic, par_rev, host_parent)]
in_win <- function(cells, ex, lo, hi) {   # cells of the exposed IJVs inside [lo, hi] relative to their own onset
  x <- merge(cells, ex[, .(jv_bvdid, onset, formation_year)], by = "jv_bvdid")
  x[year >= pmax(PANEL_START, formation_year) & year >= onset + lo & year <= pmin(PANEL_END, onset + hi)]
}
dist_str <- function(v) { t <- table(v); paste(names(t), t, sep = ":", collapse = "; ") }
q_str <- function(v) if (!length(v)) "NA" else sprintf("%s [%s-%s]", median(v), min(v), max(v))
count_shock <- function(shock, variant, long, ctrl_ids, ref_year, note = "") {
  long <- long[onset <= ONSET_MAX]
  ex <- long[, .(onset = min(onset)), by = jv_bvdid]
  ex <- merge(ex, ijv_y, by = "jv_bvdid")
  pre_ok <- ex[formation_year < onset]
  thr <- function(cells) {           # IJVs with >= MIN_CELL in one function-year both before and from onset
    a <- in_win(cells[n >= MIN_CELL], pre_ok, -99L, -1L)[, unique(jv_bvdid)]
    b <- in_win(cells[n >= MIN_CELL], pre_ok, 0L, 99L)[, unique(jv_bvdid)]
    intersect(a, b)
  }
  th <- thr(cells_h); te <- thr(cells_e)
  pairs_of <- function(ids) uniqueN(long[jv_bvdid %chin% ids, pair])
  sub <- function(ids, col) ex[jv_bvdid %chin% ids & get(col) == TRUE, jv_bvdid]
  cpre_h  <- in_win(cells_h[n >= MIN_CELL], pre_ok, -99L, -1L); cpost_h <- in_win(cells_h[n >= MIN_CELL], pre_ok, 0L, 99L)
  cpre_e  <- in_win(cells_e[n >= MIN_CELL], pre_ok, -99L, -1L); cpost_e <- in_win(cells_e[n >= MIN_CELL], pre_ok, 0L, 99L)
  ypre    <- in_win(yr_h[n >= MIN_CELL][, fn := "all"], pre_ok, -99L, -1L); ypost <- in_win(yr_h[n >= MIN_CELL][, fn := "all"], pre_ok, 0L, 99L)
  pre_years  <- pre_ok[, pmax(0L, onset - pmax(PANEL_START, formation_year))]
  post_years <- pre_ok[, pmax(0L, PANEL_END - onset + 1L)]
  # controls: never-treated IJVs with >= MIN_CELL hires in a function-year before and from the reference year
  cc <- ijv_y[jv_bvdid %chin% ctrl_ids]
  ch <- cells_h[n >= MIN_CELL & jv_bvdid %chin% cc$jv_bvdid]
  ch <- merge(ch, cc[, .(jv_bvdid, formation_year)], by = "jv_bvdid")[year >= pmax(PANEL_START, formation_year)]
  c_thr <- intersect(ch[year < ref_year, unique(jv_bvdid)], ch[year >= ref_year, unique(jv_bvdid)])
  tot_h <- cells_h[jv_bvdid %chin% ex$jv_bvdid, sum(n)]
  tot_e <- cells_e[jv_bvdid %chin% ex$jv_bvdid, sum(n)]
  v <- list(
    exposed_pairs = uniqueN(long$pair), exposed_ijv = nrow(ex), exposed_ijv_strategic = ex[strategic == TRUE, .N],
    exposed_ijv_parent_in_revelio = ex[par_rev == TRUE, .N], exposed_ijv_host_parent = ex[host_parent == TRUE, .N],
    exposed_ijv_parent_in_revelio_host_parent = ex[par_rev & host_parent, .N],
    exposed_ijv_formed_before_onset = nrow(pre_ok), exposed_ijv_formed_from_onset = ex[formation_year >= onset, .N],
    thr_hires_ijv = length(th), thr_hires_ijv_strategic = length(sub(th, "strategic")),
    thr_hires_ijv_parent_in_revelio = length(sub(th, "par_rev")), thr_hires_ijv_host_parent = length(sub(th, "host_parent")),
    thr_hires_pairs = pairs_of(th), thr_hires_pairs_parent_in_revelio = pairs_of(sub(th, "par_rev")),
    thr_emp_ijv = length(te), thr_emp_ijv_parent_in_revelio = length(sub(te, "par_rev")), thr_emp_pairs = pairs_of(te),
    thr_emp_pairs_parent_in_revelio = pairs_of(sub(te, "par_rev")),
    cells_hires5_pre = nrow(cpre_h), cells_hires5_post = nrow(cpost_h), cells_emp5_pre = nrow(cpre_e), cells_emp5_post = nrow(cpost_e),
    cells_hires5_pre_parent_in_revelio = cpre_h[jv_bvdid %chin% ex[par_rev == TRUE, jv_bvdid], .N],
    cells_hires5_post_parent_in_revelio = cpost_h[jv_bvdid %chin% ex[par_rev == TRUE, jv_bvdid], .N],
    ijv_years_hires5_pre = nrow(ypre), ijv_years_hires5_post = nrow(ypost),
    total_hires_window = tot_h, total_person_years_window = tot_e,
    onset_years_ijv = dist_str(ex$onset), pre_years_median_range = q_str(pre_years), post_years_median_range = q_str(post_years),
    control_ijv = nrow(cc), control_ijv_parent_in_revelio = cc[par_rev == TRUE, .N], control_ijv_thr_hires = length(c_thr),
    control_ref_year = ref_year,
    hard_screen_parent_in_revelio = fifelse(pairs_of(sub(th, "par_rev")) >= 15L & length(sub(th, "par_rev")) >= 30L, "PASS", "FAIL"),
    hard_screen_parent_in_revelio_emp_rule = fifelse(pairs_of(sub(te, "par_rev")) >= 15L & length(sub(te, "par_rev")) >= 30L, "PASS", "FAIL"))
  data.table(shock = shock, variant = variant, measure = names(v), value = vapply(v, as.character, ""), note = note)
}

# ---- 4. Run ---------------------------------------------------------------------------
say("building exposure")
L <- list(); R <- list()
add <- function(shock, variant, long, ctrl, ref, note = "") {
  L[[paste(shock, variant)]] <<- long[onset <= ONSET_MAX][, `:=`(shock = shock, variant = variant)]
  R[[paste(shock, variant)]] <<- count_shock(shock, variant, long, ctrl, ref, note)
}
# Owner-country basis (robustness, Orbis-sourced IJVs only).
ijv_o <- ijv[source == "orbis"]
par_o <- par[source == "orbis"]
par_g <- copy(par_o)[guo_ok == TRUE, parent_country := guo_country]

add("S13", "main: EU27+EEA+CH, parent-host pairs, onset 2021", b13(ijv, par), ctrl13(ijv, par), 2021L)
add("S13", "Ireland excluded (Common Travel Area)", b13(ijv, par, setdiff(set13, "IE")), ctrl13(ijv, par, setdiff(set13, "IE")), 2021L)
add("S13", "announcement onset 2016", b13(ijv, par, onset = 2016L), ctrl13(ijv, par), 2016L)
add("S13", "parent-parent pairs hosted in third countries", b13(ijv, par, third = TRUE), ctrl13(ijv, par), 2021L, "not an H4 host-environment channel")
add("S13", "Orbis-sourced, direct country", b13(ijv_o, par_o), ctrl13(ijv_o, par_o), 2021L)
add("S13", "Orbis-sourced, owner (GUO) country", b13(ijv_o, par_g), ctrl13(ijv_o, par_g), 2021L)

ref19 <- 2016L
add("S19", "main: CN host, ASPI first economic measure", b19(ijv, par), ctrl19(ijv, par), ref19)
add("S19", "US excluded", b19(ijv, par, drop = "US"), ctrl19(ijv, par), ref19)
add("S19", "ASPI first case of any type", b19(ijv, par, "any_year"), ctrl19(ijv, par), ref19)
add("S19", "broad: plus target-hosted IJVs with a CN parent", b19(ijv, par, broad = TRUE), ctrl19(ijv, par), ref19)
add("S19", "HK counted as China side", b19(ijv, par, china = c("CN", "HK")), ctrl19(ijv, par, c("CN", "HK")), ref19)
add("S19", "Orbis-sourced, direct country", b19(ijv_o, par_o), ctrl19(ijv_o, par_o), ref19)
add("S19", "Orbis-sourced, owner (GUO) country", b19(ijv_o, par_g), ctrl19(ijv_o, par_g), ref19)

ref06 <- 2020L
add("S06", "main: CN/HK/MO parent, core screened sectors", b06(ijv, par), ctrl06(ijv, par), ref06)
add("S06", "broad sectors", b06(ijv, par, sector = "screened_broad"), ctrl06(ijv, par, sector = "screened_broad"), ref06)
add("S06", "broad non-allied list (15 CFR 791.4)", b06(ijv, par, na = na_broad), ctrl06(ijv, par, na = na_broad), ref06)
add("S06", "any sector (no sector filter)", b06(ijv, par, sector = NULL), ctrl06(ijv, par, sector = "screened_core"), ref06, "shows what the sector filter removes")
add("S06", "Orbis-sourced, direct country", b06(ijv_o, par_o), ctrl06(ijv_o, par_o), ref06)
add("S06", "Orbis-sourced, owner (GUO) country", b06(ijv_o, par_g), ctrl06(ijv_o, par_g), ref06)

m09 <- s09_match(par)
add("S09", "strict: parent or owner is a listed party", b09(ijv, par, "strict"), ijv[!jv_bvdid %chin% m09$jv_bvdid, jv_bvdid], 2019L)
add("S09", "group: plus listed units of the parent's group", b09(ijv, par, c("strict", "group")), ijv[!jv_bvdid %chin% m09$jv_bvdid, jv_bvdid], 2019L)

res <- rbindlist(R)

# Extrapolation base: exposure among the IJVs of the gate 4 manual worklist
# (priorities 1 and 2, not yet in core_main), from the host and parent
# countries recorded in the frame. No Revelio data exist for them, so only
# exposed IJVs and pairs are counted; rescoring.md scales these by the
# core_main ratio of thresholded to exposed IJVs (a stated assumption).
f_wl <- file.path(paths$interim, sprintf("manual-match-list-%s.csv", RUN))
if (file.exists(f_wl)) {
  wl <- fread(f_wl, colClasses = "character", select = c("priority", "jv_bvdid", "jv_country", "parents", "decision"), na.strings = "")
  wl <- unique(wl[priority %chin% c("1", "2") & !jv_bvdid %chin% ijv$jv_bvdid], by = "jv_bvdid")
  wp <- wl[, .(pstr = trimws(unlist(strsplit(parents, ";")))), by = .(jv_bvdid, host = jv_country)]
  wp[, parent_country := sub("^.*\\(([A-Z]{2})\\)\\s*$", "\\1", pstr)][!grepl("^[A-Z]{2}$", parent_country), parent_country := NA_character_]
  wp <- wp[!is.na(parent_country), .(jv_bvdid, host, parent_country)]
  of_w <- fread(f_orbis, select = c("jv_bvdid", "nace", "naics", "nace_desc", "source"), colClasses = "character")
  wi <- merge(wl[, .(jv_bvdid, jv_country)], unique(of_w, by = "jv_bvdid")[, .(jv_bvdid, nace, naics, ind_text = nace_desc, source)], by = "jv_bvdid", all.x = TRUE)
  wi[, screened_core := fifelse(source %chin% "ciq", ind_text %chin% ciq_core, fifelse(!is.na(nace) & nace != "", pref(nace, nace_core), pref(naics, naics_core)))]
  wi[is.na(screened_core), screened_core := FALSE]
  wcount <- function(shock, long) data.table(shock = shock, variant = "extrapolation base: manual worklist priorities 1-2",
    measure = c("worklist_ijv", "worklist_exposed_ijv", "worklist_exposed_pairs", "worklist_new_pairs_not_in_core_main"),
    value = as.character(c(nrow(wl), uniqueN(long[onset <= ONSET_MAX, jv_bvdid]), uniqueN(long[onset <= ONSET_MAX, pair]),
                           length(setdiff(unique(long[onset <= ONSET_MAX, pair]), L[[grep(paste0("^", shock, " main"), names(L))]]$pair)))), note = "frame countries only; not matched to Revelio")
  res <- rbind(res, wcount("S13", b13(wi, wp)), wcount("S19", b19(wi, wp)), wcount("S06", b06(wi, wp)))
}

# Context rows (structural, no outcome).
ctx <- data.table(shock = "context", variant = "frame", measure = c(
  "core_main_ijv", "core_main_parent_in_revelio", "oecd_hosted_ijv_with_cn_hk_mo_parent_any_onset", "s06_hosts_undated",
  "s06_candidate_ijv_sector_unknown", "entity_list_rows", "entity_list_rows_listed_2008_2023", "s09_name_matches_strict_ijv", "s09_name_matches_group_ijv"),
  value = as.character(c(nrow(ijv), ijv[par_rev == TRUE, .N],
    uniqueN(par[host %chin% oecd38 & parent_country %chin% na_main & parent_country != host, jv_bvdid]),
    paste(undated06, collapse = " "),
    ijv[jv_bvdid %chin% par[host %chin% oecd38 & parent_country %chin% na_main & parent_country != host, jv_bvdid] & !sector_known, .N],
    nrow(el), el[list_year >= 2008 & list_year <= 2023, .N],
    uniqueN(m09[rule == "strict", jv_bvdid]), uniqueN(m09$jv_bvdid))), note = "")
res <- rbind(res, ctx)

# ---- 5. Write -------------------------------------------------------------------------
expo <- rbindlist(L, use.names = TRUE)
fwrite(expo[, .(shock, variant, jv_bvdid, pair, onset)], f_expo)
if (nrow(m09)) fwrite(merge(m09, unique(par[, .(jv_bvdid, parent_name, guo_name)]), by = "jv_bvdid", allow.cartesian = TRUE), f_s09)
stopifnot(!any(grepl("^[A-Z]{2}[0-9A-Z*]{4,}$|^CIQ", res$value)))   # no ids in the aggregate file
fwrite(res, f_out)
say("wrote %s (%d rows), %s, %s", f_out, nrow(res), f_expo, f_s09)
say("run time: %.1f minutes", as.numeric(difftime(Sys.time(), t0, units = "mins")))
