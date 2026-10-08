# 02_wrds_pilot_extract.R
# Stage 4 (pilot feasibility), extraction step. Builds the IJV sample frame
# from the Orbis ownership tables on WRDS, draws the approx. 100-IJV pilot,
# and pulls the Revelio candidate companies and position histories that
# code/R/01_pilot_matching.R expects in data/raw/.
#
# Why ownership tables: Orbis Crossborder Investment (deal records) is not
# part of the WRDS subscription and SDC joint ventures is not licensed
# (docs/decisions.md, 2026-10-08). The frame therefore identifies IJVs from
# the current shareholder structure: an active company with two or three
# corporate shareholders from at least two countries, each holding 20 to 90
# percent directly, together at least 50 percent, and at least one of them
# foreign to the host country. Incorporation date stands in for the
# formation date; the current equity share stands in for the share at
# formation. Both substitutions are recorded in data/codebook.md.
#
# Run on the PI's computer from the repository root (the cloud environment
# cannot reach WRDS):
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/02_wrds_pilot_extract.R
# Credentials: WRDS_USERNAME and WRDS_PASSWORD in ~/.Renviron.
# Each stage writes its output once and is skipped on re-runs while the
# file exists, so an interrupted run resumes where it stopped.

source("code/R/00_setup.R")
require_pkgs(c("DBI", "RPostgres", "countrycode"))
library(DBI)

EXTRACT_DATE <- "2026-10-08"
PILOT_N      <- 100L
SEED         <- 20261008L
MAX_USERS_PER_JV <- 50000L   # a Revelio entity above this is almost surely a mismatch to a large firm
set.seed(SEED)

f_frame   <- file.path(paths$interim, sprintf("wrds-ijv-frame-%s.csv", EXTRACT_DATE))
f_orbis   <- file.path(paths$raw, sprintf("orbis-pilot-%s.csv", EXTRACT_DATE))
f_rev_co  <- file.path(paths$raw, sprintf("revelio-companies-%s.csv", EXTRACT_DATE))
f_rev_pos <- file.path(paths$raw, sprintf("revelio-positions-%s.csv", EXTRACT_DATE))
f_log     <- file.path(paths$interim, sprintf("wrds-extract-log-%s.md", EXTRACT_DATE))

log_line <- function(...) {
  msg <- sprintf(...)
  message(format(Sys.time(), "%H:%M:%S"), " ", msg)
  cat("- ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " ", msg, "\n", file = f_log, append = TRUE, sep = "")
}
if (!file.exists(f_log)) cat("# WRDS pilot extraction log, ", EXTRACT_DATE, "\n\n", file = f_log, sep = "")

con <- dbConnect(RPostgres::Postgres(), host = "wrds-pgdata.wharton.upenn.edu", port = 9737,
                 dbname = "wrds", sslmode = "require",
                 user = Sys.getenv("WRDS_USERNAME"), password = Sys.getenv("WRDS_PASSWORD"))
on.exit(dbDisconnect(con), add = TRUE)
q <- function(sql) as.data.table(dbGetQuery(con, sql))
sql_in <- function(x) paste(sprintf("'%s'", gsub("'", "''", x)), collapse = ", ")

# ---- A. IJV frame from the ownership links (large and medium libraries) ----
frame_sql <- function(lib, s) sprintf("
WITH shh AS MATERIALIZED (
  SELECT sub_bvdid, shh_bvdid, left(sub_bvdid, 2) AS sub_ctry, left(shh_bvdid, 2) AS shh_ctry,
         dir_pct_onlyfigures::numeric AS dir_pct, inf_date
  FROM %1$s.ob_links_current_%2$s
  WHERE type_of_relation = 'SHH' AND active_or_archived = 'active'
    AND shh_bvdid !~ '[*]' AND shh_bvdid ~ '^[A-Z]{2}'
    AND dir_pct_onlyfigures ~ '^[0-9.]+$'
    AND dir_pct_onlyfigures::numeric BETWEEN 10 AND 90
),
jv AS MATERIALIZED (
  SELECT sub_bvdid, count(*) AS n_parents, sum(dir_pct) AS sum_pct
  FROM shh GROUP BY sub_bvdid
  HAVING count(*) BETWEEN 2 AND 3 AND count(DISTINCT shh_ctry) >= 2 AND sum(dir_pct) >= 50
     AND min(dir_pct) >= 20 AND bool_or(shh_ctry <> sub_ctry)
),
jv_shh AS MATERIALIZED (
  SELECT s.* , jv.n_parents, jv.sum_pct FROM shh s JOIN jv USING (sub_bvdid)
),
id AS (
  SELECT DISTINCT ON (bvdid) bvdid, name_internat, contact_ctryiso, city_internat, dateinc, dateinc_year,
         historic_status_str, legalfrm, listed, lei_lei, sd_isin, website
  FROM %1$s.ob_w_company_id_table_%2$s
  WHERE bvdid IN (SELECT sub_bvdid FROM jv)
    AND dateinc_year BETWEEN 2005 AND 2023
    AND historic_status_str ILIKE 'active%%' AND historic_status_str NOT ILIKE '%%dormant%%'
  ORDER BY bvdid
),
ind AS (
  SELECT DISTINCT ON (bvdid) bvdid, left(nace2_main_section, 1) AS nace2_main_section, nacepcod2, nacepdes2, naicspcod2017
  FROM %1$s.ob_industry_classifications_%2$s
  WHERE bvdid IN (SELECT sub_bvdid FROM jv)
  ORDER BY bvdid
),
ent AS (
  SELECT DISTINCT ON (bvdid, _9006) bvdid, _9006 AS shh_bvdid, _9001 AS name, _9015 AS entity_type
  FROM %1$s.ob_all_cur_shh_1st_level_%2$s
  WHERE bvdid IN (SELECT sub_bvdid FROM jv)
  ORDER BY bvdid, _9006
)
SELECT s.sub_bvdid AS jv_bvdid, id.name_internat AS jv_name, id.contact_ctryiso AS jv_country,
       id.city_internat AS jv_city, id.dateinc AS formation_date, id.dateinc_year AS formation_year,
       id.historic_status_str AS jv_status, id.legalfrm AS jv_legal_form, id.listed AS jv_listed,
       id.lei_lei AS jv_lei, id.sd_isin AS jv_isin, id.website AS jv_website,
       ind.nace2_main_section AS nace_section, ind.nacepcod2 AS nace, ind.nacepdes2 AS nace_desc,
       ind.naicspcod2017 AS naics,
       s.shh_bvdid AS parent_bvdid, ent.name AS parent_name, s.shh_ctry AS parent_country,
       ent.entity_type AS parent_entity_type, s.dir_pct AS equity_share_current,
       s.inf_date AS ownership_info_date, s.n_parents, s.sum_pct AS parents_total_share,
       '%2$s' AS orbis_library
FROM jv_shh s
JOIN id ON id.bvdid = s.sub_bvdid
LEFT JOIN ind ON ind.bvdid = s.sub_bvdid
LEFT JOIN ent ON ent.bvdid = s.sub_bvdid AND ent.shh_bvdid = s.shh_bvdid
", lib, s)

if (!file.exists(f_frame)) {
  frame <- rbindlist(list(
    { t0 <- Sys.time(); x <- q(frame_sql("bvd_orbis_large", "l"));  log_line("frame large: %d rows in %.0fs", nrow(x), as.numeric(Sys.time() - t0, units = "secs")); x },
    { t0 <- Sys.time(); x <- q(frame_sql("bvd_orbis_medium", "m")); log_line("frame medium: %d rows in %.0fs", nrow(x), as.numeric(Sys.time() - t0, units = "secs")); x }
  ), use.names = TRUE)
  # A company present in both libraries is kept once, from the larger library.
  setorder(frame, jv_bvdid, parent_bvdid, orbis_library)
  frame <- frame[, .SD[orbis_library == orbis_library[1]], by = jv_bvdid]
  # Exclusions: financial-sector JVs and holding vehicles, parents that are
  # unnamed, and parents that are not corporate. Shareholder types (from the
  # JV's own first-level shareholder table) kept as corporate: Corporate,
  # Bank, Insurance company, Financial company. Excluded: public authority,
  # funds, nominees and trusts, private equity, venture capital, hedge funds,
  # individuals and families, employees, foundations, unnamed or aggregated
  # holders, self ownership, and missing types, since none supplies a
  # workforce that can staff a JV.
  corporate_types <- c("Corporate", "Bank", "Insurance company", "Financial company")
  frame[, excl := fcase(
    nace_section == "K", "financial_sector",
    nace %chin% c("6420", "6430"), "holding_or_trust",
    !parent_entity_type %chin% corporate_types, "non_corporate_parent",
    is.na(parent_name), "parent_unnamed",
    default = "")]
  jv_excl <- frame[, .(excl_jv = paste(unique(excl[excl != ""]), collapse = ";")), by = jv_bvdid]
  frame <- merge(frame[, -"excl"], jv_excl, by = "jv_bvdid")
  fwrite(frame, f_frame)
  log_line("frame written: %d JV-parent rows, %d JVs, %d after exclusions",
           nrow(frame), uniqueN(frame$jv_bvdid), uniqueN(frame[excl_jv == "", jv_bvdid]))
} else {
  frame <- fread(f_frame, colClasses = list(character = c("jv_bvdid", "parent_bvdid", "nace", "naics")))
  log_line("frame loaded from %s", f_frame)
}

# ---- B. Stratified pilot draw --------------------------------------------
eu27 <- c("AT","BE","BG","HR","CY","CZ","DK","EE","FI","FR","DE","GR","HU","IE","IT","LV","LT","LU","MT","NL","PL","PT","RO","SK","SI","ES","SE")
coerced_by_china <- c("AU","KR","JP","NO","LT","CA")               # ASPI coercion targets named in the Orbis spec
oecd_screening <- c("AU","AT","CA","CZ","DK","FI","FR","DE","HU","IT","JP","KR","LV","LT","NL","NZ","NO","PL","PT","ES","SE","GB","US","IE","BE","CH")
region_of <- function(iso) fcase(
  iso %chin% c("US","CA"), "north_america",
  iso %chin% c("MX","BR","AR","CL","CO","PE","UY","PY","BO","EC","VE","CR","PA","GT","DO","CU","HN","SV","NI"), "latin_america",
  iso %chin% c(setdiff(eu27, c("BG","HR","CZ","EE","HU","LV","LT","PL","RO","SK","SI")), "GB","CH","NO","IS","LI","MC"), "western_europe",
  iso %chin% c("BG","HR","CZ","EE","HU","LV","LT","PL","RO","SK","SI","RS","BA","ME","MK","AL","UA","BY","MD","RU","GE","AM","AZ","KZ","UZ","KG","TJ","TM"), "central_eastern_europe",
  iso %chin% c("CN","JP","KR","TW","HK","MO","MN","AU","NZ","PG","FJ"), "east_asia_pacific",
  iso %chin% c("IN","PK","BD","LK","NP","BT","MV","SG","MY","TH","ID","VN","PH","KH","LA","MM","BN","TL"), "south_southeast_asia",
  default = "middle_east_africa")
industry_of <- function(sec) fcase(
  sec %chin% c("B","D","E"), "extractive_utilities",
  sec == "C", "manufacturing",
  sec %chin% c("J"), "technology",
  is.na(sec) | sec == "", "unknown",
  default = "services")

jv_level <- frame[excl_jv == "", .(
  jv_name = jv_name[1], jv_country = jv_country[1], formation_year = formation_year[1],
  nace_section = nace_section[1], n_parents = n_parents[1], orbis_library = orbis_library[1],
  parent_countries = list(sort(unique(parent_country))),
  max_share = max(equity_share_current), min_share = min(equity_share_current)
), by = jv_bvdid]
jv_level[, `:=`(region = region_of(jv_country), industry = industry_of(nace_section))]
jv_level[, countries_all := mapply(function(p, h) unique(c(p, h)), parent_countries, jv_country, SIMPLIFY = FALSE)]
jv_level[, `:=`(
  exp_uk_eu = mapply(function(p, h) ("GB" %in% p & any(eu27 %in% c(p, h))) | (h == "GB" & any(eu27 %in% p)), parent_countries, jv_country),
  exp_china = mapply(function(p, h) ("CN" %in% c(p, h)) & any(coerced_by_china %in% setdiff(c(p, h), "CN")), parent_countries, jv_country),
  exp_russia = mapply(function(p, h) "RU" %in% c(p, h), parent_countries, jv_country),
  exp_oecd_screening = jv_country %chin% oecd_screening,
  exp_entity_list = NA   # requires the US Entity List name match; not available in this run
)]
jv_level[, exposure_group := fcase(exp_russia, "russia", exp_china, "china_coercion", exp_uk_eu, "uk_eu",
                                   exp_oecd_screening, "oecd_screening", default = "unexposed")]
log_line("frame JVs eligible: %d; exposure groups: %s", nrow(jv_level),
         paste(sprintf("%s=%d", names(table(jv_level$exposure_group)), table(jv_level$exposure_group)), collapse = ", "))
fwrite(jv_level[, .(jv_bvdid, jv_country, region, industry, exposure_group, n_parents, orbis_library)],
       file.path(paths$interim, sprintf("wrds-ijv-frame-groups-%s.csv", EXTRACT_DATE)))

if (!file.exists(f_orbis)) {
  targets <- c(uk_eu = 18L, china_coercion = 18L, russia = 8L, oecd_screening = 18L)
  draw <- rbindlist(lapply(names(targets), function(g) {
    pool <- jv_level[exposure_group == g]
    pool[sample.int(nrow(pool), min(targets[[g]], nrow(pool)))]
  }))
  # Unexposed remainder: spread across region x industry cells as evenly as the pool allows.
  n_rest <- PILOT_N - nrow(draw)
  pool <- jv_level[exposure_group == "unexposed"]
  pool[, cell := paste(region, industry)]
  pool <- pool[sample.int(nrow(pool))]                      # shuffle, then round-robin over cells
  pool[, rank_in_cell := seq_len(.N), by = cell]
  setorder(pool, rank_in_cell)
  draw <- rbind(draw, pool[seq_len(min(n_rest, nrow(pool)))][, -c("cell", "rank_in_cell")])
  draw[, pilot := TRUE]
  log_line("pilot draw: %d JVs (%s)", nrow(draw),
           paste(sprintf("%s=%d", names(table(draw$exposure_group)), table(draw$exposure_group)), collapse = ", "))

  pilot <- merge(frame, draw[, .(jv_bvdid, region, industry, exposure_group, exp_uk_eu, exp_china, exp_russia, exp_oecd_screening, exp_entity_list)], by = "jv_bvdid")

  # Parent GUO (50 percent definition) and latest financials for JVs and parents.
  ids <- unique(c(pilot$jv_bvdid, pilot$parent_bvdid))
  guo <- rbindlist(lapply(c("bvd_orbis_large.ob_links_current_l", "bvd_orbis_medium.ob_links_current_m"), function(t)
    q(sprintf("SELECT DISTINCT ON (sub_bvdid) sub_bvdid, guo_50, guo_25 FROM %s WHERE sub_bvdid IN (%s) AND guo_50 IS NOT NULL", t, sql_in(ids)))))
  guo <- unique(guo, by = "sub_bvdid")
  fin <- rbindlist(lapply(c("bvd_orbis_large.ob_key_financials_usd_l", "bvd_orbis_medium.ob_key_financials_usd_m"), function(t)
    q(sprintf("SELECT DISTINCT ON (bvdid) bvdid, closdate_year AS fin_year, empl AS employees, toas AS total_assets_usd, opre AS revenue_usd
               FROM %s WHERE bvdid IN (%s) AND closdate_year IS NOT NULL ORDER BY bvdid, closdate DESC", t, sql_in(ids)))))
  fin <- unique(fin, by = "bvdid")
  pilot <- merge(pilot, guo[, .(parent_bvdid = sub_bvdid, guo_bvdid = guo_50)], by = "parent_bvdid", all.x = TRUE)
  pilot[is.na(guo_bvdid), guo_bvdid := parent_bvdid]
  pilot[, guo_country := substr(guo_bvdid, 1, 2)]
  # GUO names, so that parents that are holding or investment vehicles can be
  # matched to Revelio through their ultimate owner (decision 2026-10-08).
  guo_ids <- unique(pilot[guo_bvdid != parent_bvdid, guo_bvdid])
  guo_nm <- if (length(guo_ids)) rbindlist(lapply(
    c("bvd_orbis_large.ob_w_company_id_table_l", "bvd_orbis_medium.ob_w_company_id_table_m"), function(t)
      q(sprintf("SELECT DISTINCT ON (bvdid) bvdid AS guo_bvdid, name_internat AS guo_name FROM %s WHERE bvdid IN (%s) ORDER BY bvdid",
                t, sql_in(guo_ids))))) else data.table(guo_bvdid = character(), guo_name = character())
  guo_nm <- unique(guo_nm, by = "guo_bvdid")
  pilot <- merge(pilot, guo_nm, by = "guo_bvdid", all.x = TRUE)
  pilot[guo_bvdid == parent_bvdid, guo_name := parent_name]
  log_line("GUO names found for %d of %d distinct GUOs that differ from the direct parent",
           uniqueN(pilot[guo_bvdid != parent_bvdid & !is.na(guo_name), guo_bvdid]), length(guo_ids))
  pilot <- merge(pilot, fin[, .(jv_bvdid = bvdid, jv_fin_year = fin_year, jv_employees = employees, jv_total_assets_usd = total_assets_usd)], by = "jv_bvdid", all.x = TRUE)
  pilot <- merge(pilot, fin[, .(parent_bvdid = bvdid, parent_fin_year = fin_year, parent_employees = employees, parent_total_assets_usd = total_assets_usd)], by = "parent_bvdid", all.x = TRUE)
  setcolorder(pilot, c("jv_bvdid", "jv_name", "jv_country", "jv_city", "formation_date", "formation_year", "jv_status",
                       "nace_section", "nace", "nace_desc", "naics", "jv_employees", "jv_total_assets_usd", "jv_fin_year",
                       "parent_bvdid", "parent_name", "parent_country", "equity_share_current", "guo_bvdid", "guo_name", "guo_country",
                       "parent_employees", "parent_total_assets_usd", "parent_fin_year", "n_parents", "parents_total_share",
                       "region", "industry", "exposure_group"))
  setorder(pilot, jv_bvdid, -equity_share_current, parent_country)
  fwrite(pilot, f_orbis)
  log_line("orbis pilot export written: %s (%d JV-parent rows, %d JVs)", f_orbis, nrow(pilot), uniqueN(pilot$jv_bvdid))
} else {
  pilot <- fread(f_orbis, colClasses = list(character = c("jv_bvdid", "parent_bvdid", "guo_bvdid", "nace", "naics")))
  log_line("orbis pilot export loaded from %s", f_orbis)
}

# ---- C. Revelio candidate companies --------------------------------------
# One scan of revelio.company_mapping: candidates whose normalized name starts
# with the normalized Orbis name (legal suffixes removed), plus exact LEI and
# ISIN matches. The full candidate set goes to data/raw/ so that
# 01_pilot_matching.R can score alternatives.
if (!file.exists(f_rev_co)) {
  ents <- unique(rbind(
    pilot[, .(orbis_id = jv_bvdid, orbis_name = jv_name, orbis_country = jv_country, entity = "jv", lei = jv_lei, isin = jv_isin)],
    pilot[, .(orbis_id = parent_bvdid, orbis_name = parent_name, orbis_country = parent_country, entity = "parent", lei = NA_character_, isin = NA_character_)],
    pilot[guo_bvdid != parent_bvdid & !is.na(guo_name),
          .(orbis_id = guo_bvdid, orbis_name = guo_name, orbis_country = guo_country, entity = "guo", lei = NA_character_, isin = NA_character_)]
  ))
  ents[, key := gsub("[^a-z0-9]", "", normalize_name(orbis_name))]
  ents[, n := nchar(key)]
  keys <- unique(ents[n >= 2, .(key, n, orbis_id, entity)])
  vals_name <- paste(sprintf("('%s', %d, '%s', '%s')", keys$key, keys$n, keys$orbis_id, keys$entity), collapse = ",\n")
  leis  <- unique(ents[!is.na(lei) & lei != "", .(lei, orbis_id, entity)])
  isins <- unique(ents[!is.na(isin) & isin != "", .(isin, orbis_id, entity)])
  cm_cols <- "cm.rcid, cm.company, cm.hq_country, cm.hq_city, cm.ultimate_parent_rcid, cm.ultimate_parent_company_name, cm.lei, cm.isin, cm.linkedin_url, cm.naics_code, cm.year_founded"
  # Name candidates in one scan: hash join on the first two characters of the
  # normalized name, then keep rows whose normalized name starts with the key.
  rev_sql <- sprintf("
WITH v(key, n, orbis_id, entity) AS (VALUES %s),
cm AS (
  SELECT %s, regexp_replace(lower(cm.company), '[^a-z0-9]', '', 'g') AS norm
  FROM revelio.company_mapping cm
),
by_name AS (
  SELECT v.orbis_id, v.entity, 'name_prefix'::text AS match_key, cm.*,
         row_number() OVER (PARTITION BY v.orbis_id ORDER BY length(cm.norm), cm.rcid) AS rn
  FROM cm JOIN v ON left(cm.norm, 2) = left(v.key, 2) AND left(cm.norm, v.n) = v.key
)
SELECT orbis_id, entity, match_key, rcid, company, hq_country, hq_city, ultimate_parent_rcid, ultimate_parent_company_name,
       lei, isin, linkedin_url, naics_code, year_founded
FROM by_name WHERE rn <= 50", vals_name, cm_cols)
  id_sql <- function(col, ids) sprintf("
SELECT v.orbis_id, v.entity, '%1$s'::text AS match_key, %2$s
FROM revelio.company_mapping cm JOIN (VALUES %3$s) AS v(%1$s, orbis_id, entity) ON cm.%1$s = v.%1$s",
    col, cm_cols, paste(sprintf("('%s','%s','%s')", ids[[col]], ids$orbis_id, ids$entity), collapse = ","))
  t0 <- Sys.time()
  cand <- rbindlist(list(q(rev_sql),
                         if (nrow(leis))  q(id_sql("lei", leis)),
                         if (nrow(isins)) q(id_sql("isin", isins))), use.names = TRUE)
  log_line("revelio candidates: %d rows for %d of %d entities in %.0fs", nrow(cand), uniqueN(cand$orbis_id), nrow(ents), as.numeric(Sys.time() - t0, units = "secs"))
  cand[, country := countrycode::countrycode(hq_country, "country.name", "iso2c", warn = FALSE)]
  setnames(cand, "company", "company_name")

  # Review-tier routes for JVs (decision 2026-10-08): website domain, website
  # stem, and the first two name tokens, each limited to the host country.
  # Rules for using them are in review_tier_candidates() (functions/matching.R).
  rev_ctry <- q("SELECT DISTINCT hq_country FROM revelio.company_mapping WHERE hq_country IS NOT NULL")
  rev_ctry[, iso2 := countrycode::countrycode(hq_country, "country.name", "iso2c", warn = FALSE)]
  rev_ctry <- rev_ctry[!is.na(iso2)]
  ctry_vals <- paste(sprintf("('%s', '%s')", gsub("'", "''", rev_ctry$hq_country), rev_ctry$iso2), collapse = ",")
  jvs <- unique(pilot[, .(orbis_id = jv_bvdid, orbis_name = jv_name, iso2 = jv_country, website = jv_website)], by = "orbis_id")
  doms <- jvs[!is.na(website), .(domain = web_domains(website)), by = .(orbis_id, iso2)]
  web_keys <- unique(doms[, .(key = gsub("[^a-z0-9]", "", sub("[.].*$", "", domain)), orbis_id, iso2, route = "web_stem")])
  stem2 <- jvs[, .(key = vapply(strsplit(normalize_name(gsub("[(][^)]*[)]", " ", orbis_name)), " "),
                                function(t) paste(head(t, 2), collapse = ""), character(1)), orbis_id, iso2, route = "stem2")]
  route_keys <- unique(rbind(web_keys, stem2)[nchar(key) >= 5])
  route_keys[, n := nchar(key)]
  route_sql <- sprintf("
WITH v(key, n, orbis_id, iso2, route) AS (VALUES %s),
c(hq_country, iso2) AS (VALUES %s),
cm AS (
  SELECT %s, c.iso2, regexp_replace(lower(cm.company), '[^a-z0-9]', '', 'g') AS norm
  FROM revelio.company_mapping cm JOIN c ON c.hq_country = cm.hq_country
),
hits AS (
  SELECT v.orbis_id, 'jv'::text AS entity, v.route AS match_key, cm.*,
         row_number() OVER (PARTITION BY v.orbis_id, v.route ORDER BY length(cm.norm), cm.rcid) AS rn
  FROM cm JOIN v ON left(cm.norm, 2) = left(v.key, 2) AND left(cm.norm, v.n) = v.key AND cm.iso2 = v.iso2
)
SELECT orbis_id, entity, match_key, rcid, company, hq_country, hq_city, ultimate_parent_rcid, ultimate_parent_company_name,
       lei, isin, linkedin_url, naics_code, year_founded
FROM hits WHERE rn <= 30",
    paste(sprintf("('%s', %d, '%s', '%s', '%s')", route_keys$key, route_keys$n, route_keys$orbis_id, route_keys$iso2, route_keys$route), collapse = ",\n"),
    ctry_vals, cm_cols)
  dom_sql <- sprintf("
WITH d(domain, orbis_id, iso2) AS (VALUES %s),
c(hq_country, iso2) AS (VALUES %s)
SELECT d.orbis_id, 'jv'::text AS entity, 'domain'::text AS match_key, %s
FROM revelio.company_mapping cm
JOIN c ON c.hq_country = cm.hq_country
JOIN d ON regexp_replace(lower(cm.url), '^(https?://)?(www[.])?', '') = d.domain AND d.iso2 = c.iso2",
    paste(sprintf("('%s', '%s', '%s')", gsub("'", "''", doms$domain), doms$orbis_id, doms$iso2), collapse = ","),
    ctry_vals, cm_cols)
  t0 <- Sys.time()
  routes <- rbindlist(list(q(route_sql), if (nrow(doms)) q(dom_sql)), use.names = TRUE)
  routes[, country := countrycode::countrycode(hq_country, "country.name", "iso2c", warn = FALSE)]
  setnames(routes, "company", "company_name")
  log_line("review-tier routes: %d candidate rows for %d JVs (domain %d, web_stem %d, stem2 %d) in %.0fs",
           nrow(routes), uniqueN(routes$orbis_id), sum(routes$match_key == "domain"),
           sum(routes$match_key == "web_stem"), sum(routes$match_key == "stem2"), as.numeric(Sys.time() - t0, units = "secs"))
  cand <- rbindlist(list(cand, routes), use.names = TRUE)
  # Companies in the parent groups (ultimate parent = a parent candidate) are
  # needed for the origin classification; pull them for candidates that pass a
  # first name-score screen so that the pool stays small.
  pa <- merge(cand[entity %in% c("parent", "guo")], unique(ents[entity %in% c("parent", "guo"), .(orbis_id, entity, orbis_name, orbis_country)]),
              by = c("orbis_id", "entity"))
  pa[, score := 1 - stringdist::stringdist(normalize_name(orbis_name), normalize_name(company_name), method = "jw", p = 0.1)]
  pa_rcids <- unique(pa[score >= const$jw_threshold, rcid])
  # The parent's Revelio family: go up to the Revelio ultimate parent of each
  # matched parent or GUO entity, then take every company under it.
  pa_up <- unique(na.omit(c(pa_rcids, cand[rcid %in% pa_rcids, ultimate_parent_rcid])))
  grp <- if (length(pa_up)) q(sprintf("
    SELECT NULL::text AS orbis_id, 'parent_group' AS entity, 'ultimate_parent' AS match_key, rcid, company AS company_name, hq_country, hq_city,
           ultimate_parent_rcid, ultimate_parent_company_name, lei, isin, linkedin_url, naics_code, year_founded
    FROM revelio.company_mapping WHERE ultimate_parent_rcid IN (%1$s) OR rcid IN (%1$s)",
    paste(pa_up, collapse = ","))) else data.table()
  if (nrow(grp)) grp[, country := countrycode::countrycode(hq_country, "country.name", "iso2c", warn = FALSE)]
  rev_co <- rbindlist(list(cand, grp), use.names = TRUE, fill = TRUE)
  fwrite(rev_co, f_rev_co)
  log_line("revelio companies written: %s (%d rows, %d parent-group members)", f_rev_co, nrow(rev_co), nrow(grp))
} else {
  rev_co <- fread(f_rev_co, colClasses = list(character = c("orbis_id")))
  log_line("revelio companies loaded from %s", f_rev_co)
}

# ---- D. Position histories for matched JV entities -----------------------
# A provisional match (same rules as 01_pilot_matching.R) decides which JV
# rcids to pull. All positions of every individual with a spell at a matched
# JV rcid are exported, so that prior employers can be classified.
if (!file.exists(f_rev_pos)) {
  jv_ent  <- unique(pilot[, .(orbis_id = jv_bvdid, orbis_name = jv_name, orbis_country = jv_country)])
  rev_ent <- unique(rev_co[entity == "jv", .(rcid, rev_name = company_name, rev_country = country)])
  jv_m <- match_entities(jv_ent, rev_ent, const$jw_threshold)
  jv_best <- jv_m[score >= const$jw_threshold][order(-same_country, -score)][, .SD[1:min(.N, 3)], by = orbis_id]
  log_line("provisional JV matches: %d of %d JVs have a candidate at or above %.2f", uniqueN(jv_best$orbis_id), nrow(jv_ent), const$jw_threshold)
  # Review-tier candidates for JVs without a name match, with the same parent
  # guard as 01_pilot_matching.R (parent candidates at or above the threshold
  # and their group members).
  pa_ent <- unique(rbind(pilot[, .(orbis_id = parent_bvdid, orbis_name = parent_name)],
                         pilot[!is.na(guo_name), .(orbis_id = guo_bvdid, orbis_name = guo_name)]))
  pa_c <- merge(rev_co[entity %in% c("parent", "guo"), .(orbis_id, rcid, company_name)], pa_ent, by = "orbis_id", allow.cartesian = TRUE)
  pa_c[, score := 1 - stringdist::stringdist(normalize_name(orbis_name), normalize_name(company_name), method = "jw", p = 0.1)]
  parent_rcids <- unique(c(pa_c[score >= const$jw_threshold, rcid], rev_co[entity == "parent_group", rcid]))
  rt <- review_tier_candidates(rev_co[entity == "jv" & !orbis_id %in% jv_best$orbis_id], jv_ent, parent_rcids)
  log_line("review-tier JV candidates: %d JVs (%s)", nrow(rt),
           if (nrow(rt)) paste(sprintf("%s=%d", names(table(rt$method)), table(rt$method)), collapse = ", ") else "none")
  jv_best <- rbindlist(list(jv_best, rt), use.names = TRUE, fill = TRUE)
  sizes <- q(sprintf("SELECT rcid, count(DISTINCT user_id) AS n_users FROM revelio.individual_positions WHERE rcid IN (%s) GROUP BY rcid",
                     paste(unique(jv_best$rcid), collapse = ",")))
  jv_best <- merge(jv_best, sizes, by = "rcid", all.x = TRUE)
  jv_best[is.na(n_users), n_users := 0L]
  fwrite(jv_best, file.path(paths$interim, sprintf("wrds-jv-provisional-matches-%s.csv", EXTRACT_DATE)))
  pull <- jv_best[n_users > 0 & n_users <= MAX_USERS_PER_JV]
  skipped <- jv_best[n_users > MAX_USERS_PER_JV]
  if (nrow(skipped)) log_line("skipped %d candidate rcids above %d users: %s", nrow(skipped), MAX_USERS_PER_JV, paste(skipped$rcid, collapse = ","))
  pos_list <- lapply(unique(pull$rcid), function(r) {
    t0 <- Sys.time()
    x <- q(sprintf("
      WITH u AS (SELECT DISTINCT user_id FROM revelio.individual_positions WHERE rcid = %s)
      SELECT p.user_id, p.position_id, p.rcid, p.ultimate_parent_rcid, cm.company AS company_name,
             p.country, p.region, p.startdate AS start_date, p.enddate AS end_date,
             p.seniority, p.role_k1500_v2, p.role_k17000_v3, r.role_k10_v3 AS job_category, r.role_k50_v3,
             p.salary, p.weight, %s AS pulled_for_rcid
      FROM revelio.individual_positions p
      JOIN u USING (user_id)
      LEFT JOIN revelio.individual_role_lookup_v3 r USING (role_k17000_v3)
      LEFT JOIN revelio.company_mapping cm ON cm.rcid = p.rcid", r, r))
    log_line("positions for rcid %s: %d rows, %d users, %.0fs", r, nrow(x), uniqueN(x$user_id), as.numeric(Sys.time() - t0, units = "secs"))
    x
  })
  rev_pos <- rbindlist(pos_list)
  rev_pos[, country := countrycode::countrycode(country, "country.name", "iso2c", warn = FALSE)]
  fwrite(rev_pos, f_rev_pos)
  log_line("revelio positions written: %s (%d rows, %d users, %d JV rcids)", f_rev_pos, nrow(rev_pos), uniqueN(rev_pos$user_id), uniqueN(pull$rcid))
} else {
  log_line("revelio positions already present: %s", f_rev_pos)
}
log_line("extraction complete; next: Rscript code/R/01_pilot_matching.R")
