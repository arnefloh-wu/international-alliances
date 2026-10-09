# 05_wrds_frame_v2.R
# Expanded IJV frame (PI instruction 2026-10-09: take the upper bound and
# maximize the sample).
#
# Base of frame v2:
#   1. Orbis ownership links (large and medium libraries) with relaxed rules:
#      direct stakes of 10 to 90 percent, two to four parents, incorporation
#      in any year up to 2023, any company status.
#   2. Capital IQ ownership relations: a company with two to four corporate
#      owners (public or private companies) holding 10 to 90 percent, owners
#      in at least two countries, one of them foreign to the company. Capital
#      IQ JVs that duplicate an Orbis JV (same normalized name and country)
#      are dropped.
# Extra routes (frame v3), switched on by arguments:
#   with_dom    Orbis companies whose direct parents sit in one country but
#               whose global ultimate owners (GUOs) sit in at least two
#               countries and two groups (JVs formed through local
#               subsidiaries of foreign groups). A SQL prefilter on the GUO
#               lookup keeps the query small.
#   with_small  The Orbis small-company library, restricted to a 1-in-20 hash
#               sample of companies (SMALL_SAMPLE) because the library holds
#               about a billion ownership links; counts scale by 20.
#   with_prior  Capital IQ prior co-ownership: companies with two to four
#               prior corporate owners in at least two countries and no
#               current corporate owner (former JVs). Prior relations carry no
#               stakes or dates, so a company owned by two parents in
#               sequence cannot be told from a joint venture; these rows are
#               low-confidence and tagged `ciq_prior`.
# Rules kept from the base frame: corporate parents only, no financial-sector
# JVs or holding vehicles (NACE K, 6420, 6430), parents from at least two
# groups (distinct GUOs). Each JV records the relaxations that admitted it
# (`admitted_by`), so any of them can be switched off later.
# Output: data/interim/wrds-ijv-frame-v2-2026-10-09.csv, or ...-v3-... when an
# extra route is on, read by 03_wrds_full_sample.R with the same argument.
# Run on the PI's computer from the repository root:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/05_wrds_frame_v2.R [with_dom] [with_small] [with_prior]

source("code/R/00_setup.R")
source("code/R/functions/frame.R")
require_pkgs(c("DBI", "RPostgres", "R.utils"))
library(DBI)

RUN_DATE <- "2026-10-09"
ARGS <- commandArgs(trailingOnly = TRUE)
WITH_DOM <- "with_dom" %in% ARGS
WITH_SMALL <- "with_small" %in% ARGS
WITH_PRIOR <- "with_prior" %in% ARGS
OUT_TAG <- if (WITH_DOM || WITH_SMALL || WITH_PRIOR) "v3" else "v2"
SMALL_SAMPLE <- 20L
CORP <- "('Corporate', 'Bank', 'Insurance company', 'Financial company')"
f_out <- file.path(paths$interim, sprintf("wrds-ijv-frame-%s-%s.csv", OUT_TAG, RUN_DATE))
f_log <- file.path(paths$interim, sprintf("wrds-frame-v2-log-%s.md", RUN_DATE))
cache <- function(name) file.path(paths$interim, sprintf("frame-v2-%s-%s.csv.gz", name, RUN_DATE))
log_line <- function(...) {
  msg <- sprintf(...)
  message(format(Sys.time(), "%H:%M:%S"), " ", msg)
  cat("- ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " ", msg, "\n", file = f_log, append = TRUE, sep = "")
}
if (!file.exists(f_log)) cat("# Frame v2 build log, ", RUN_DATE, "\n\n", file = f_log, sep = "")
secs <- function(t0) as.numeric(Sys.time() - t0, units = "secs")
log_line("run start: %s", paste(c(OUT_TAG, ARGS), collapse = " "))

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
# `scope` = "dom": all direct parents in one country, GUO-level two-country
#   rule applied in SQL (prefilter) and again in R;
# `scope` = "small": the small library, intl rules, 1-in-SMALL_SAMPLE sample.
orbis_sql <- function(lib, s, scope) {
  samp <- if (scope == "small") sprintf("AND abs(hashtext(sub_bvdid)) %% %d = 0", SMALL_SAMPLE) else ""
  jv_ctes <- if (scope == "dom") sprintf("
jv_pre AS MATERIALIZED (
  SELECT sub_bvdid FROM shh GROUP BY sub_bvdid
  HAVING count(*) BETWEEN 2 AND 4 AND sum(dir_pct) >= 50 AND count(DISTINCT shh_ctry) = 1
),
g AS MATERIALIZED (
  SELECT DISTINCT ON (sub_bvdid) sub_bvdid AS shh_bvdid, guo_50 AS guo
  FROM %1$s.ob_links_current_%2$s
  WHERE guo_50 IS NOT NULL AND sub_bvdid IN (SELECT shh_bvdid FROM shh WHERE sub_bvdid IN (SELECT sub_bvdid FROM jv_pre))
  ORDER BY sub_bvdid
),
y AS MATERIALIZED (
  SELECT s.sub_bvdid FROM shh s JOIN jv_pre USING (sub_bvdid) LEFT JOIN g ON g.shh_bvdid = s.shh_bvdid
  GROUP BY s.sub_bvdid
  HAVING count(DISTINCT coalesce(left(g.guo, 2), s.shh_ctry)) >= 2
     AND count(DISTINCT coalesce(g.guo, s.shh_bvdid)) >= 2
     AND bool_or(coalesce(left(g.guo, 2), s.shh_ctry) <> s.sub_ctry)
),
jv AS MATERIALIZED (
  SELECT sub_bvdid, count(*) AS n_parents, sum(dir_pct) AS sum_pct, min(dir_pct) AS min_pct,
         count(DISTINCT shh_ctry) AS n_ctry, bool_or(shh_ctry <> sub_ctry) AS any_foreign
  FROM shh WHERE sub_bvdid IN (SELECT sub_bvdid FROM y) GROUP BY sub_bvdid
)", lib, s) else "
jv AS MATERIALIZED (
  SELECT sub_bvdid, count(*) AS n_parents, sum(dir_pct) AS sum_pct, min(dir_pct) AS min_pct,
         count(DISTINCT shh_ctry) AS n_ctry, bool_or(shh_ctry <> sub_ctry) AS any_foreign
  FROM shh GROUP BY sub_bvdid
  HAVING count(*) BETWEEN 2 AND 4 AND sum(dir_pct) >= 50 AND count(DISTINCT shh_ctry) >= 2
)"
  sprintf("
WITH shh AS MATERIALIZED (
  SELECT sub_bvdid, shh_bvdid, left(sub_bvdid, 2) AS sub_ctry, left(shh_bvdid, 2) AS shh_ctry,
         dir_pct_onlyfigures::numeric AS dir_pct, inf_date
  FROM %1$s.ob_links_current_%2$s
  WHERE type_of_relation = 'SHH' AND active_or_archived = 'active'
    AND shh_bvdid !~ '[*]' AND shh_bvdid ~ '^[A-Z]{2}' AND dir_pct_onlyfigures ~ '^[0-9.]+$'
    AND dir_pct_onlyfigures::numeric BETWEEN 10 AND 90 %5$s
),%4$s,
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
    lib, s, CORP, jv_ctes, samp)
}

scope_libs <- list(intl = list(c("bvd_orbis_large", "l"), c("bvd_orbis_medium", "m")))
if (WITH_DOM) scope_libs$dom <- list(c("bvd_orbis_large", "l"), c("bvd_orbis_medium", "m"))
if (WITH_SMALL) scope_libs$small <- list(c("bvd_orbis_small", "s"))
for (scope in names(scope_libs)) for (ls in scope_libs[[scope]]) {
  f <- cache(sprintf("orbis-%s-%s", scope, ls[2]))
  if (file.exists(f)) next
  t0 <- Sys.time()
  x <- q(orbis_sql(ls[1], ls[2], scope))
  fwrite(x, f)
  log_line("orbis %s %s: %d JV-parent rows, %d JVs in %.0fs", scope, ls[2], nrow(x), uniqueN(x$jv_bvdid), secs(t0))
}
read_scope <- function(scope) {
  x <- rbindlist(lapply(vapply(scope_libs[[scope]], `[`, "", 2), function(s)
    fread(cache(sprintf("orbis-%s-%s", scope, s)), colClasses = list(character = c("jv_bvdid", "parent_bvdid", "nace", "naics")))))
  x[, scope := scope]
}
ob <- rbindlist(lapply(names(scope_libs), read_scope), use.names = TRUE)
# A company in several scopes or libraries is kept once: intl first, then dom,
# then the small-library sample; within that, the larger library.
scope_rank <- c(intl = 1L, dom = 2L, small = 3L)
ob[, sr := scope_rank[scope]]
setorder(ob, jv_bvdid, sr, orbis_library)
ob <- ob[, .SD[sr == sr[1] & orbis_library == orbis_library[1]], by = jv_bvdid][, sr := NULL]

# GUO of every parent (large, medium, small libraries); looked up once and
# cached, parents without a record are stored with an empty GUO.
f_guo <- cache("parent-guo")
pg <- if (file.exists(f_guo)) fread(f_guo, colClasses = "character") else data.table(parent_bvdid = character(), parent_guo = character())
need <- setdiff(unique(ob$parent_bvdid), pg$parent_bvdid)
if (length(need)) {
  t0 <- Sys.time()
  new <- rbindlist(lapply(c("bvd_orbis_large.ob_links_current_l", "bvd_orbis_medium.ob_links_current_m",
                            "bvd_orbis_small.ob_links_current_s"), function(t)
    q_in(paste0("SELECT DISTINCT ON (sub_bvdid) sub_bvdid AS parent_bvdid, guo_50 AS parent_guo FROM ", t,
                " WHERE sub_bvdid IN (%s) AND guo_50 IS NOT NULL"), need)))
  new <- unique(new, by = "parent_bvdid")
  pg <- rbind(pg, new, data.table(parent_bvdid = setdiff(need, new$parent_bvdid), parent_guo = NA_character_))
  fwrite(pg, f_guo)
  log_line("parent GUOs: %d new parents looked up, found for %d, in %.0fs", length(need), nrow(new), secs(t0))
}
pg[parent_guo == "", parent_guo := NA_character_]
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
  scope %chin% c("intl", "small"), any_foreign,                # direct parents from two countries, one foreign
  scope == "dom", n_guo_ctry >= 2 & guo_foreign,               # GUO-level two-country rule
  default = FALSE)]
jvl[, intra_group := n_groups < 2]
jvl[, admitted_by := mapply(function(sc, mn, np, fy, ac) {
  r <- c(if (sc == "dom") "guo_country", if (sc == "small") "small_library_sample",
         if (mn < 20) "stake_10_20", if (np == 4) "four_parents",
         if (!is.na(fy) && fy < 2005) "formed_before_2005", if (!ac) "not_active")
  if (length(r)) paste(r, collapse = ";") else "base"
}, scope, min_pct, n_parents, formation_year, active)]
log_line("orbis frame: %d candidate JVs; %d intra-group; %d kept (%s)", nrow(jvl), jvl[intra_group == TRUE, .N], jvl[keep == TRUE, .N],
         paste(sprintf("%s=%d", jvl[keep == TRUE, .N, by = scope]$scope, jvl[keep == TRUE, .N, by = scope]$N), collapse = ", "))
jvl[keep == TRUE, parents_eff := ifelse(scope == "dom", guo_countries, parent_countries)]
jvl[keep == TRUE, exposure_group := exposure_group_of(jv_country, parents_eff)]
ob <- merge(ob, jvl[keep == TRUE, .(jv_bvdid, admitted_by, exposure_group)], by = "jv_bvdid")
ob[, `:=`(source = "orbis", excl_jv = "", region = region_of(jv_country), industry = industry_of(nace_section))]

# ---- 2. Capital IQ -------------------------------------------------------------
ciq_select <- "
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
LEFT JOIN ciq.ciqcompanytype pt ON pt.companytypeid = p.companytypeid"

ciq_pull <- function(f, ctes) {
  if (!file.exists(f)) {
    t0 <- Sys.time()
    ciq <- q(paste(ctes, ciq_select))
    # One-level group: each owner's majority parent (current subsidiary relation above 50 percent).
    op <- q_in("SELECT DISTINCT ON (r.childcompanyid) r.childcompanyid AS owner, r.parentcompanyid AS owner_parent, p.companyname AS owner_parent_name
                FROM ciq.companyrels r JOIN ciq.ciqcompany p ON p.companyid = r.parentcompanyid
                WHERE r.companyreltypeid = '5' AND r.percentownership > 50 AND r.childcompanyid IN (%s)
                ORDER BY r.childcompanyid, r.percentownership DESC", as.character(unique(ciq$owner)))
    ciq <- merge(ciq, op, by = "owner", all.x = TRUE)
    fwrite(ciq, f)
    log_line("ciq %s: %d JV-owner rows, %d JVs in %.0fs", basename(f), nrow(ciq), uniqueN(ciq$child), secs(t0))
  }
  fread(f)
}

ciq_current <- ciq_pull(cache("ciq"), "
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
)")

# Capital IQ simple industries mapped to the four broad pilot industries.
ciq_industry_of <- function(x) fcase(
  grepl("oil|gas|energy|metals|mining|utilit|paper|forest", x, ignore.case = TRUE), "extractive_utilities",
  grepl("software|IT services|telecom|communications|semiconductor|technology hardware|electronic|interactive|media", x, ignore.case = TRUE), "technology",
  grepl("chemical|material|machinery|equipment|automobile|aerospace|building products|household durables|textile|beverage|food products|tobacco|pharma|biotech|leisure products|containers|conglomerate", x, ignore.case = TRUE), "manufacturing",
  is.na(x) | x == "", "unknown",
  default = "services")
name_key <- function(country, name) paste(country, gsub("[^a-z0-9]", "", normalize_name(name)))

# Turns Capital IQ JV-owner rows into frame rows; `tag` ("ciq" or "ciq_prior")
# is the first entry of admitted_by; `okey` lists name keys of JVs already in
# the frame, which are dropped as duplicates.
ciq_rows <- function(ciq, tag, okey) {
  ciq[, group := fifelse(is.na(owner_parent), owner, owner_parent)]
  cj <- ciq[, .(jv_country = jv_country[1], n_groups = uniqueN(group), any_foreign = any(parent_country != jv_country[1], na.rm = TRUE),
                fin = grepl("bank|insurance|financ|capital market|reit", ciq_industry[1], ignore.case = TRUE),
                parent_countries = list(sort(unique(parent_country))), yearfounded = yearfounded[1],
                status = companystatustypeid[1], n_parents = .N, min_pct = suppressWarnings(min(pct, na.rm = TRUE))), by = child]
  cj[is.infinite(min_pct), min_pct := NA_real_]
  cj[, keep := n_groups >= 2 & any_foreign & !fin & !is.na(jv_country) & (is.na(yearfounded) | yearfounded <= 2023)]
  cn <- unique(ciq[, .(child, jv_name, jv_country)], by = "child")
  cn[, dup := name_key(jv_country, jv_name) %chin% okey]
  cj <- merge(cj, cn[, .(child, dup)], by = "child")
  log_line("%s: %d candidate JVs; %d intra-group; %d financial; %d duplicate an earlier JV; %d kept", tag,
           nrow(cj), cj[n_groups < 2, .N], cj[fin == TRUE, .N], cj[dup == TRUE, .N], cj[keep & !dup, .N])
  cj <- cj[keep & !dup]
  cj[, exposure_group := exposure_group_of(jv_country, parent_countries)]
  cj[, admitted_by := mapply(function(mn, np, fy, st) {
    r <- c(tag, if (isTRUE(mn < 20)) "stake_10_20", if (np == 4) "four_parents",
           if (!is.na(fy) && fy < 2005) "formed_before_2005", if (!st %in% c(1, 2, 20)) "not_active")
    paste(r, collapse = ";")
  }, min_pct, n_parents, yearfounded, status)]
  cq <- merge(ciq[child %in% cj$child], cj[, .(child, admitted_by, exposure_group, n_parents)], by = "child")
  cq <- cq[, .(jv_bvdid = paste0("CIQ", child), jv_name, jv_country, jv_city, formation_date = as.IDate(NA),
               formation_year = fifelse(is.na(yearfounded), 1990L, as.integer(yearfounded)),
               formation_year_missing = is.na(yearfounded), jv_status, jv_legal_form = NA_character_, jv_listed = NA_character_,
               jv_lei = NA_character_, jv_isin = NA_character_, jv_website = webpage, nace_section = NA_character_, nace = NA_character_,
               nace_desc = ciq_industry, naics = NA_character_, parent_bvdid = paste0("CIQ", owner), parent_name, parent_country,
               parent_entity_type, equity_share_current = as.numeric(pct), ownership_info_date = as.IDate(NA), n_parents,
               parents_total_share = NA_real_, orbis_library = "ciq", parent_guo = paste0("CIQ", group),
               guo_name_pre = fifelse(is.na(owner_parent), parent_name, owner_parent_name), parent_guo_found = !is.na(owner_parent),
               source = "ciq", excl_jv = "", admitted_by, exposure_group)]
  cq[, `:=`(region = region_of(jv_country), industry = ciq_industry_of(nace_desc))]
  cq
}

okey <- unique(name_key(ob$jv_country, ob$jv_name))
cq_cur <- ciq_rows(ciq_current, "ciq", okey)

cq_prior <- NULL
if (WITH_PRIOR) {
  ciq_prior <- ciq_pull(cache("ciq-prior"), "
WITH cur AS (
  SELECT DISTINCT r.childcompanyid AS child
  FROM ciq.companyrels r JOIN ciq.ciqcompany p ON p.companyid = r.parentcompanyid
  WHERE r.companyreltypeid IN ('1', '5') AND p.companytypeid IN (4, 5)
),
own0 AS (
  SELECT r.childcompanyid AS child, r.parentcompanyid AS owner, NULL::numeric AS pct
  FROM ciq.companyrels r JOIN ciq.ciqcompany p ON p.companyid = r.parentcompanyid
  WHERE r.companyreltypeid IN ('2', '6') AND p.companytypeid IN (4, 5)
  GROUP BY 1, 2
),
jv AS (
  SELECT o.child FROM own0 o
  JOIN ciq.ciqcompany p ON p.companyid = o.owner
  JOIN ciq.ciqcompany c ON c.companyid = o.child
  LEFT JOIN cur ON cur.child = o.child
  WHERE c.companytypeid IN (4, 5) AND cur.child IS NULL
  GROUP BY o.child
  HAVING count(DISTINCT o.owner) BETWEEN 2 AND 4 AND count(DISTINCT p.countryid) >= 2
)")
  cq_prior <- ciq_rows(ciq_prior, "ciq_prior", unique(c(okey, name_key(cq_cur$jv_country, cq_cur$jv_name))))
}

# ---- 3. Small-library note and combine -------------------------------------------
ob[, `:=`(formation_year_missing = FALSE, guo_name_pre = NA_character_)]
fr <- rbindlist(list(ob, cq_cur, cq_prior), use.names = TRUE, fill = TRUE)
fr[, c("min_pct", "n_ctry", "any_foreign", "scope", "guo_country") := NULL]
setorder(fr, jv_bvdid, -equity_share_current, parent_country)
fwrite(fr, f_out)
jv_tab <- unique(fr, by = "jv_bvdid")
log_line("frame %s written: %s; %d JVs (orbis %d, ciq %d); base-rule JVs %d", OUT_TAG, f_out, nrow(jv_tab),
         jv_tab[source == "orbis", .N], jv_tab[source == "ciq", .N], jv_tab[admitted_by == "base", .N])
print(jv_tab[, .N, by = .(source, admitted_by)][order(-N)][1:25])
