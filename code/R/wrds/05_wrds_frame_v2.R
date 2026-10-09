# 05_wrds_frame_v2.R
# Expanded IJV frame (PI instruction 2026-10-09: take the upper bound and
# maximize the sample). Two sources:
#   1. Orbis ownership links (large and medium libraries) with relaxed rules:
#      direct stakes of 10 to 90 percent, two to four parents, incorporation
#      in any year up to 2023, any company status, and the two-country rule
#      applied at the GUO level as an alternative to the direct-parent level.
#   2. Capital IQ ownership relations: a company with two to four corporate
#      owners (public or private companies) holding 10 to 90 percent, owners
#      in at least two countries, one of them foreign to the company. Capital
#      IQ JVs that duplicate an Orbis JV (same normalized name and country)
#      are dropped.
# Rules kept from the base frame: corporate parents only, no financial-sector
# JVs or holding vehicles (NACE K, 6420, 6430), parents from at least two
# groups (distinct GUOs). Each JV records the relaxations that admitted it
# (`admitted_by`), so any of them can be switched off later.
# Output: data/interim/wrds-ijv-frame-v2-2026-10-09.csv in the format of the
# base frame, read by 03_wrds_full_sample.R with the argument "v2".
# Run on the PI's computer from the repository root:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/05_wrds_frame_v2.R

source("code/R/00_setup.R")
source("code/R/functions/frame.R")
require_pkgs(c("DBI", "RPostgres", "R.utils"))
library(DBI)

RUN_DATE <- "2026-10-09"
# The GUO-level two-country rule needs all domestically co-owned companies
# ("dom" scope); that query ran over 30 minutes on the large library alone, so
# it is off by default and added with the argument "with_dom".
SCOPES <- if ("with_dom" %in% commandArgs(trailingOnly = TRUE)) c("intl", "dom") else "intl"
CORP <- "('Corporate', 'Bank', 'Insurance company', 'Financial company')"
f_out <- file.path(paths$interim, sprintf("wrds-ijv-frame-v2-%s.csv", RUN_DATE))
f_log <- file.path(paths$interim, sprintf("wrds-frame-v2-log-%s.md", RUN_DATE))
cache <- function(name) file.path(paths$interim, sprintf("frame-v2-%s-%s.csv.gz", name, RUN_DATE))
log_line <- function(...) {
  msg <- sprintf(...)
  message(format(Sys.time(), "%H:%M:%S"), " ", msg)
  cat("- ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " ", msg, "\n", file = f_log, append = TRUE, sep = "")
}
if (!file.exists(f_log)) cat("# Frame v2 build log, ", RUN_DATE, "\n\n", file = f_log, sep = "")
secs <- function(t0) as.numeric(Sys.time() - t0, units = "secs")

con <- dbConnect(RPostgres::Postgres(), host = "wrds-pgdata.wharton.upenn.edu", port = 9737,
                 dbname = "wrds", sslmode = "require",
                 user = Sys.getenv("WRDS_USERNAME"), password = Sys.getenv("WRDS_PASSWORD"))
on.exit(dbDisconnect(con), add = TRUE)
q <- function(sql) as.data.table(dbGetQuery(con, sql))
esc <- function(x) gsub("'", "''", x)
sql_in <- function(x) paste(sprintf("'%s'", esc(x)), collapse = ", ")
q_in <- function(template, ids, chunk = 2000L) {
  ids <- unique(ids[!is.na(ids) & ids != ""])
  if (!length(ids)) return(data.table())
  rbindlist(lapply(split(ids, ceiling(seq_along(ids) / chunk)), function(x) q(sprintf(template, sql_in(x)))), fill = TRUE)
}

# ---- 1. Orbis, relaxed rules ----------------------------------------------
# `scope` = "intl": direct parents from at least two countries;
# `scope` = "dom": all direct parents in one country (candidates for the
# GUO-level two-country rule, decided in R after the GUO lookup).
orbis_sql <- function(lib, s, scope) sprintf("
WITH shh AS MATERIALIZED (
  SELECT sub_bvdid, shh_bvdid, left(sub_bvdid, 2) AS sub_ctry, left(shh_bvdid, 2) AS shh_ctry,
         dir_pct_onlyfigures::numeric AS dir_pct, inf_date
  FROM %1$s.ob_links_current_%2$s
  WHERE type_of_relation = 'SHH' AND active_or_archived = 'active'
    AND shh_bvdid !~ '[*]' AND shh_bvdid ~ '^[A-Z]{2}' AND dir_pct_onlyfigures ~ '^[0-9.]+$'
    AND dir_pct_onlyfigures::numeric BETWEEN 10 AND 90
),
jv AS MATERIALIZED (
  SELECT sub_bvdid, count(*) AS n_parents, sum(dir_pct) AS sum_pct, min(dir_pct) AS min_pct,
         count(DISTINCT shh_ctry) AS n_ctry, bool_or(shh_ctry <> sub_ctry) AS any_foreign
  FROM shh GROUP BY sub_bvdid
  HAVING count(*) BETWEEN 2 AND 4 AND sum(dir_pct) >= 50 AND %4$s
),
ent AS MATERIALIZED (
  SELECT DISTINCT ON (bvdid, _9006) bvdid, _9006 AS shh_bvdid, _9001 AS name, _9015 AS entity_type
  FROM %1$s.ob_all_cur_shh_1st_level_%2$s WHERE bvdid IN (SELECT sub_bvdid FROM jv) ORDER BY bvdid, _9006
),
corp AS MATERIALIZED (
  SELECT s.sub_bvdid FROM shh s JOIN jv USING (sub_bvdid)
  LEFT JOIN ent ON ent.bvdid = s.sub_bvdid AND ent.shh_bvdid = s.shh_bvdid
  GROUP BY s.sub_bvdid
  HAVING bool_and(coalesce(ent.entity_type, '') IN %3$s) AND bool_and(ent.name IS NOT NULL)
),
id AS (
  SELECT DISTINCT ON (bvdid) bvdid, name_internat, contact_ctryiso, city_internat, dateinc, dateinc_year,
         historic_status_str, legalfrm, listed, lei_lei, sd_isin, website
  FROM %1$s.ob_w_company_id_table_%2$s
  WHERE bvdid IN (SELECT sub_bvdid FROM corp) AND dateinc_year <= 2023 ORDER BY bvdid
),
ind AS (
  SELECT DISTINCT ON (bvdid) bvdid, left(nace2_main_section, 1) AS sec, nacepcod2, nacepdes2, naicspcod2017
  FROM %1$s.ob_industry_classifications_%2$s WHERE bvdid IN (SELECT sub_bvdid FROM corp)
  ORDER BY bvdid, nace2_main_section NULLS LAST, nacepcod2 NULLS LAST   -- deterministic pick among several industry rows
)
SELECT s.sub_bvdid AS jv_bvdid, id.name_internat AS jv_name, id.contact_ctryiso AS jv_country, id.city_internat AS jv_city,
       id.dateinc AS formation_date, id.dateinc_year AS formation_year, id.historic_status_str AS jv_status,
       id.legalfrm AS jv_legal_form, id.listed AS jv_listed, id.lei_lei AS jv_lei, id.sd_isin AS jv_isin, id.website AS jv_website,
       ind.sec AS nace_section, ind.nacepcod2 AS nace, ind.nacepdes2 AS nace_desc, ind.naicspcod2017 AS naics,
       s.shh_bvdid AS parent_bvdid, ent.name AS parent_name, s.shh_ctry AS parent_country, ent.entity_type AS parent_entity_type,
       s.dir_pct AS equity_share_current, s.inf_date AS ownership_info_date,
       jv.n_parents, jv.sum_pct AS parents_total_share, jv.min_pct, jv.n_ctry, jv.any_foreign, '%2$s' AS orbis_library
FROM shh s
JOIN jv USING (sub_bvdid)
JOIN corp USING (sub_bvdid)
JOIN id ON id.bvdid = s.sub_bvdid
LEFT JOIN ind ON ind.bvdid = s.sub_bvdid
LEFT JOIN ent ON ent.bvdid = s.sub_bvdid AND ent.shh_bvdid = s.shh_bvdid
WHERE NOT (coalesce(ind.sec, '') = 'K' OR coalesce(ind.nacepcod2, '') IN ('6420', '6430'))",
  lib, s, CORP, if (scope == "intl") "count(DISTINCT shh_ctry) >= 2" else "count(DISTINCT shh_ctry) = 1")

for (scope in SCOPES) for (ls in list(c("bvd_orbis_large", "l"), c("bvd_orbis_medium", "m"))) {
  f <- cache(sprintf("orbis-%s-%s", scope, ls[2]))
  if (file.exists(f)) next
  t0 <- Sys.time()
  x <- q(orbis_sql(ls[1], ls[2], scope))
  fwrite(x, f)
  log_line("orbis %s %s: %d JV-parent rows, %d JVs in %.0fs", scope, ls[2], nrow(x), uniqueN(x$jv_bvdid), secs(t0))
}
read_scope <- function(scope) {
  x <- rbindlist(lapply(c("l", "m"), function(s)
    fread(cache(sprintf("orbis-%s-%s", scope, s)), colClasses = list(character = c("jv_bvdid", "parent_bvdid", "nace", "naics")))))
  x[, scope := scope]
}
ob <- rbindlist(lapply(SCOPES, read_scope), use.names = TRUE)
# A company in both libraries is kept once, from the large library.
setorder(ob, jv_bvdid, orbis_library)
ob <- ob[, .SD[orbis_library == orbis_library[1]], by = jv_bvdid]

# GUO of every parent (large, medium, small libraries; cached).
f_guo <- cache("parent-guo")
if (!file.exists(f_guo)) {
  t0 <- Sys.time()
  pg <- rbindlist(lapply(c("bvd_orbis_large.ob_links_current_l", "bvd_orbis_medium.ob_links_current_m",
                           "bvd_orbis_small.ob_links_current_s"), function(t)
    q_in(paste0("SELECT DISTINCT ON (sub_bvdid) sub_bvdid AS parent_bvdid, guo_50 AS parent_guo FROM ", t,
                " WHERE sub_bvdid IN (%s) AND guo_50 IS NOT NULL"), unique(ob$parent_bvdid))))
  pg <- unique(pg, by = "parent_bvdid")
  fwrite(pg, f_guo)
  log_line("parent GUOs: found for %d of %d parents in %.0fs", nrow(pg), uniqueN(ob$parent_bvdid), secs(t0))
}
pg <- fread(f_guo, colClasses = "character")
ob <- merge(ob, pg, by = "parent_bvdid", all.x = TRUE)
ob[, parent_guo_found := !is.na(parent_guo)]
ob[is.na(parent_guo), parent_guo := parent_bvdid]
ob[, guo_country := substr(parent_guo, 1, 2)]

jvl <- ob[, .(scope = scope[1], n_parents = n_parents[1], min_pct = min_pct[1], any_foreign = any_foreign[1],
              jv_country = jv_country[1], formation_year = formation_year[1], jv_status = jv_status[1],
              n_groups = uniqueN(parent_guo), n_guo_ctry = uniqueN(guo_country),
              guo_foreign = any(guo_country != jv_country[1]),
              parent_countries = list(sort(unique(parent_country))), guo_countries = list(sort(unique(guo_country)))), by = jv_bvdid]
jvl[, active := grepl("^active", jv_status, ignore.case = TRUE) & !grepl("dormant", jv_status, ignore.case = TRUE)]
jvl[, keep := fcase(
  n_groups < 2, FALSE,                                         # intra-group
  scope == "intl", any_foreign,                                # direct parents from two countries, one foreign
  scope == "dom", n_guo_ctry >= 2 & guo_foreign,               # GUO-level two-country rule
  default = FALSE)]
jvl[, intra_group := n_groups < 2]
jvl[, admitted_by := mapply(function(sc, mn, np, fy, ac) {
  r <- c(if (sc == "dom") "guo_country", if (mn < 20) "stake_10_20", if (np == 4) "four_parents",
         if (!is.na(fy) && fy < 2005) "formed_before_2005", if (!ac) "not_active")
  if (length(r)) paste(r, collapse = ";") else "base"
}, scope, min_pct, n_parents, formation_year, active)]
log_line("orbis v2: %d candidate JVs; %d intra-group; %d kept (%s)", nrow(jvl), jvl[intra_group == TRUE, .N], jvl[keep == TRUE, .N],
         paste(sprintf("%s=%d", jvl[keep == TRUE, .N, by = scope]$scope, jvl[keep == TRUE, .N, by = scope]$N), collapse = ", "))
jvl[keep == TRUE, parents_eff := ifelse(scope == "dom", guo_countries, parent_countries)]
jvl[keep == TRUE, exposure_group := exposure_group_of(jv_country, parents_eff)]
ob <- merge(ob, jvl[keep == TRUE, .(jv_bvdid, admitted_by, exposure_group)], by = "jv_bvdid")
ob[, `:=`(source = "orbis", excl_jv = "", region = region_of(jv_country), industry = industry_of(nace_section))]

# ---- 2. Capital IQ -------------------------------------------------------------
f_ciq <- cache("ciq")
if (!file.exists(f_ciq)) {
  t0 <- Sys.time()
  ciq <- q("
WITH own0 AS (
  SELECT r.childcompanyid AS child, r.parentcompanyid AS owner, max(r.percentownership) AS pct
  FROM ciq.companyrels r JOIN ciq.ciqcompany p ON p.companyid = r.parentcompanyid
  WHERE r.companyreltypeid IN ('1', '5') AND r.percentownership BETWEEN 10 AND 90 AND p.companytypeid IN (4, 5)
  GROUP BY 1, 2
),
jv AS (
  SELECT o.child FROM own0 o
  JOIN ciq.ciqcompany p ON p.companyid = o.owner
  JOIN ciq.ciqcompany c ON c.companyid = o.child
  WHERE c.companytypeid IN (4, 5)
  GROUP BY o.child
  HAVING count(*) BETWEEN 2 AND 4 AND sum(o.pct) >= 50 AND count(DISTINCT p.countryid) >= 2
)
SELECT o.child, c.companyname AS jv_name, cg.isocountry2 AS jv_country, c.city AS jv_city, c.yearfounded, c.webpage,
       c.companystatustypeid, st.companystatustypename AS jv_status, si.simpleindustrydescription AS ciq_industry,
       o.owner, p.companyname AS parent_name, pgeo.isocountry2 AS parent_country, pt.companytypename AS parent_entity_type, o.pct
FROM own0 o JOIN jv USING (child)
JOIN ciq.ciqcompany c ON c.companyid = o.child
LEFT JOIN ciq.ciqcountrygeo cg ON cg.countryid = c.countryid
LEFT JOIN ciq.ciqcompanystatustype st ON st.companystatustypeid = c.companystatustypeid
LEFT JOIN ciq.ciqsimpleindustry si ON si.simpleindustryid = c.simpleindustryid
JOIN ciq.ciqcompany p ON p.companyid = o.owner
LEFT JOIN ciq.ciqcountrygeo pgeo ON pgeo.countryid = p.countryid
LEFT JOIN ciq.ciqcompanytype pt ON pt.companytypeid = p.companytypeid")
  # One-level group: each owner's majority parent (current subsidiary relation above 50 percent).
  op <- q_in("SELECT DISTINCT ON (r.childcompanyid) r.childcompanyid AS owner, r.parentcompanyid AS owner_parent, p.companyname AS owner_parent_name
              FROM ciq.companyrels r JOIN ciq.ciqcompany p ON p.companyid = r.parentcompanyid
              WHERE r.companyreltypeid = '5' AND r.percentownership > 50 AND r.childcompanyid IN (%s)
              ORDER BY r.childcompanyid, r.percentownership DESC", as.character(unique(ciq$owner)))
  ciq <- merge(ciq, op, by = "owner", all.x = TRUE)
  fwrite(ciq, f_ciq)
  log_line("ciq: %d JV-owner rows, %d JVs in %.0fs", nrow(ciq), uniqueN(ciq$child), secs(t0))
}
ciq <- fread(f_ciq)
ciq[, group := fifelse(is.na(owner_parent), owner, owner_parent)]
cj <- ciq[, .(jv_country = jv_country[1], n_groups = uniqueN(group), any_foreign = any(parent_country != jv_country[1], na.rm = TRUE),
              fin = grepl("bank|insurance|financ|capital market|reit", ciq_industry[1], ignore.case = TRUE),
              parent_countries = list(sort(unique(parent_country))), yearfounded = yearfounded[1],
              status = companystatustypeid[1], n_parents = .N, min_pct = min(pct)), by = child]
cj[, keep := n_groups >= 2 & any_foreign & !fin & !is.na(jv_country) & (is.na(yearfounded) | yearfounded <= 2023)]
# Drop Capital IQ JVs that duplicate an Orbis JV (normalized name and country).
okey <- unique(ob[, paste(jv_country, gsub("[^a-z0-9]", "", normalize_name(jv_name)))])
cn <- unique(ciq[, .(child, jv_name, jv_country)], by = "child")
cn[, dup_orbis := paste(jv_country, gsub("[^a-z0-9]", "", normalize_name(jv_name))) %chin% okey]
cj <- merge(cj, cn[, .(child, dup_orbis)], by = "child")
log_line("ciq: %d candidate JVs; %d intra-group; %d financial; %d duplicate an Orbis JV; %d kept",
         nrow(cj), cj[n_groups < 2, .N], cj[fin == TRUE, .N], cj[dup_orbis == TRUE, .N], cj[keep & !dup_orbis, .N])
cj <- cj[keep & !dup_orbis]
cj[, exposure_group := exposure_group_of(jv_country, parent_countries)]
cj[, admitted_by := mapply(function(mn, np, fy, st) {
  r <- c("ciq", if (mn < 20) "stake_10_20", if (np == 4) "four_parents",
         if (!is.na(fy) && fy < 2005) "formed_before_2005", if (!st %in% c(1, 2, 20)) "not_active")
  paste(r, collapse = ";")
}, min_pct, n_parents, yearfounded, status)]
cq <- merge(ciq[child %in% cj$child], cj[, .(child, admitted_by, exposure_group, n_parents)], by = "child")
cq <- cq[, .(jv_bvdid = paste0("CIQ", child), jv_name, jv_country, jv_city, formation_date = as.IDate(NA),
             formation_year = fifelse(is.na(yearfounded), 1990L, as.integer(yearfounded)),
             formation_year_missing = is.na(yearfounded), jv_status, jv_legal_form = NA_character_, jv_listed = NA_character_,
             jv_lei = NA_character_, jv_isin = NA_character_, jv_website = webpage, nace_section = NA_character_, nace = NA_character_,
             nace_desc = ciq_industry, naics = NA_character_, parent_bvdid = paste0("CIQ", owner), parent_name, parent_country,
             parent_entity_type, equity_share_current = pct, ownership_info_date = as.IDate(NA), n_parents,
             parents_total_share = NA_real_, orbis_library = "ciq", parent_guo = paste0("CIQ", group),
             guo_name_pre = fifelse(is.na(owner_parent), parent_name, owner_parent_name), parent_guo_found = !is.na(owner_parent),
             source = "ciq", excl_jv = "", admitted_by, exposure_group)]
# Capital IQ simple industries mapped to the four broad pilot industries.
ciq_industry_of <- function(x) fcase(
  grepl("oil|gas|energy|metals|mining|utilit|paper|forest", x, ignore.case = TRUE), "extractive_utilities",
  grepl("software|IT services|telecom|communications|semiconductor|technology hardware|electronic|interactive|media", x, ignore.case = TRUE), "technology",
  grepl("chemical|material|machinery|equipment|automobile|aerospace|building products|household durables|textile|beverage|food products|tobacco|pharma|biotech|leisure products|containers|conglomerate", x, ignore.case = TRUE), "manufacturing",
  is.na(x) | x == "", "unknown",
  default = "services")
cq[, `:=`(region = region_of(jv_country), industry = ciq_industry_of(nace_desc))]

# ---- 3. Combine ---------------------------------------------------------------------
ob[, `:=`(formation_year_missing = FALSE, guo_name_pre = NA_character_)]
v2 <- rbindlist(list(ob, cq), use.names = TRUE, fill = TRUE)
v2[, c("min_pct", "n_ctry", "any_foreign", "scope", "guo_country") := NULL]
setorder(v2, jv_bvdid, -equity_share_current, parent_country)
fwrite(v2, f_out)
jv_tab <- unique(v2, by = "jv_bvdid")
log_line("frame v2 written: %s; %d JVs (orbis %d, ciq %d); base-rule JVs %d", f_out, nrow(jv_tab),
         jv_tab[source == "orbis", .N], jv_tab[source == "ciq", .N], jv_tab[admitted_by == "base", .N])
print(jv_tab[, .N, by = .(source, admitted_by)][order(-N)][1:25])
