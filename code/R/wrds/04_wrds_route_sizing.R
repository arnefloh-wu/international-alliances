# 04_wrds_route_sizing.R
# Sizes the routes for enlarging the IJV sample (PI request 2026-10-09).
# Each count applies the frame rules of 02_wrds_pilot_extract.R (step A,
# without the intra-group step A2) with one rule relaxed, so the baseline
# should reproduce the 12,074 eligible JVs of 2026-10-08. Counts are written
# to data/interim/route-sizing-2026-10-09.csv.
# Run on the PI's computer from the repository root:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/04_wrds_route_sizing.R

source("code/R/00_setup.R")
require_pkgs(c("DBI", "RPostgres"))
library(DBI)
RUN_DATE <- "2026-10-09"
f_out <- file.path(paths$interim, sprintf("route-sizing-%s.csv", RUN_DATE))
con <- dbConnect(RPostgres::Postgres(), host = "wrds-pgdata.wharton.upenn.edu", port = 9737,
                 dbname = "wrds", sslmode = "require",
                 user = Sys.getenv("WRDS_USERNAME"), password = Sys.getenv("WRDS_PASSWORD"))
on.exit(dbDisconnect(con), add = TRUE)
q <- function(sql) { t0 <- Sys.time(); r <- as.data.table(dbGetQuery(con, sql))
  message(format(Sys.time(), "%H:%M:%S"), sprintf(" query done in %.0fs", as.numeric(Sys.time() - t0, units = "secs"))); r }
corp <- "('Corporate', 'Bank', 'Insurance company', 'Financial company')"

# ---- Orbis variants (large and medium libraries) ----------------------------
orbis_sql <- function(lib, s) sprintf("
WITH shh AS MATERIALIZED (
  SELECT sub_bvdid AS sub, shh_bvdid AS shh, left(sub_bvdid, 2) AS sc, left(shh_bvdid, 2) AS hc,
         dir_pct_onlyfigures::numeric AS pct
  FROM %1$s.ob_links_current_%2$s
  WHERE type_of_relation = 'SHH' AND active_or_archived = 'active'
    AND shh_bvdid !~ '[*]' AND shh_bvdid ~ '^[A-Z]{2}' AND dir_pct_onlyfigures ~ '^[0-9.]+$'
    AND dir_pct_onlyfigures::numeric BETWEEN 10 AND 90
),
agg AS MATERIALIZED (
  SELECT sub, count(*) AS n, min(pct) AS mn, bool_or(hc <> sc) AS f
  FROM shh GROUP BY sub
  HAVING count(*) BETWEEN 2 AND 4 AND sum(pct) >= 50 AND count(DISTINCT hc) >= 2
),
typ AS (
  SELECT DISTINCT ON (bvdid, _9006) bvdid, _9006 AS shh, _9015 AS t
  FROM %1$s.ob_all_cur_shh_1st_level_%2$s WHERE bvdid IN (SELECT sub FROM agg) ORDER BY bvdid, _9006
),
cp AS (
  SELECT s.sub, bool_and(coalesce(typ.t, '') IN %3$s) AS all_corp
  FROM shh s JOIN agg USING (sub) LEFT JOIN typ ON typ.bvdid = s.sub AND typ.shh = s.shh GROUP BY s.sub
),
id AS (
  SELECT DISTINCT ON (bvdid) bvdid, dateinc_year AS y,
         (historic_status_str ILIKE 'active%%' AND historic_status_str NOT ILIKE '%%dormant%%') AS active
  FROM %1$s.ob_w_company_id_table_%2$s WHERE bvdid IN (SELECT sub FROM agg) ORDER BY bvdid
),
ind AS (
  SELECT DISTINCT ON (bvdid) bvdid, left(nace2_main_section, 1) AS sec, nacepcod2
  FROM %1$s.ob_industry_classifications_%2$s WHERE bvdid IN (SELECT sub FROM agg) ORDER BY bvdid
),
x AS (
  SELECT a.*, cp.all_corp, id.y, id.active,
         NOT (coalesce(ind.sec, '') = 'K' OR coalesce(ind.nacepcod2, '') IN ('6420', '6430')) AS not_fin
  FROM agg a JOIN id ON id.bvdid = a.sub JOIN cp ON cp.sub = a.sub LEFT JOIN ind ON ind.bvdid = a.sub
)
SELECT
  count(*) FILTER (WHERE n <= 3 AND mn >= 20 AND f AND all_corp AND not_fin AND active AND y BETWEEN 2005 AND 2023) AS baseline,
  count(*) FILTER (WHERE n <= 3 AND mn >= 10 AND f AND all_corp AND not_fin AND active AND y BETWEEN 2005 AND 2023) AS min_stake_10,
  count(*) FILTER (WHERE n <= 4 AND mn >= 20 AND f AND all_corp AND not_fin AND active AND y BETWEEN 2005 AND 2023) AS up_to_4_parents,
  count(*) FILTER (WHERE n <= 3 AND mn >= 20 AND f AND all_corp AND not_fin AND active AND y BETWEEN 1990 AND 2023) AS formed_1990_on,
  count(*) FILTER (WHERE n <= 3 AND mn >= 20 AND f AND all_corp AND not_fin AND active AND y <= 2023) AS formed_any_year,
  count(*) FILTER (WHERE n <= 3 AND mn >= 20 AND f AND all_corp AND not_fin AND y BETWEEN 2005 AND 2023) AS any_status,
  count(*) FILTER (WHERE n <= 4 AND mn >= 10 AND f AND all_corp AND not_fin AND y <= 2023) AS all_relaxed
FROM x", lib, s, corp)

res <- list()
for (ls in list(c("bvd_orbis_large", "l"), c("bvd_orbis_medium", "m"))) {
  r <- q(orbis_sql(ls[1], ls[2]))
  res[[length(res) + 1]] <- melt(r[, library := ls[2]], id.vars = "library", variable.name = "variant", value.name = "jvs")
}

# Two-country rule at the GUO level: all direct parents in one country, but
# their GUOs (same-library ownership links) in at least two countries, one of
# them foreign to the host. Estimated on a 1-in-SAMPLE hash sample of
# companies and scaled up; a full count ran for over 30 minutes.
SAMPLE <- 20L
guo_sql <- function(lib, s) sprintf("
WITH shh AS MATERIALIZED (
  SELECT sub_bvdid AS sub, shh_bvdid AS shh, left(sub_bvdid, 2) AS sc, left(shh_bvdid, 2) AS hc,
         dir_pct_onlyfigures::numeric AS pct
  FROM %1$s.ob_links_current_%2$s
  WHERE type_of_relation = 'SHH' AND active_or_archived = 'active'
    AND shh_bvdid !~ '[*]' AND shh_bvdid ~ '^[A-Z]{2}' AND dir_pct_onlyfigures ~ '^[0-9.]+$'
    AND dir_pct_onlyfigures::numeric BETWEEN 10 AND 90
    AND abs(hashtext(sub_bvdid)) %% %3$d = 0
),
agg AS MATERIALIZED (
  SELECT sub FROM shh GROUP BY sub
  HAVING count(*) BETWEEN 2 AND 3 AND sum(pct) >= 50 AND min(pct) >= 20 AND count(DISTINCT hc) = 1
),
g AS (
  SELECT DISTINCT ON (sub_bvdid) sub_bvdid AS shh, left(guo_50, 2) AS gc
  FROM %1$s.ob_links_current_%2$s
  WHERE sub_bvdid IN (SELECT shh FROM shh WHERE sub IN (SELECT sub FROM agg)) AND guo_50 IS NOT NULL
),
y AS (
  SELECT s.sub, min(s.sc) AS sc, count(DISTINCT coalesce(g.gc, s.hc)) AS ngc, bool_or(coalesce(g.gc, s.hc) <> s.sc) AS foreign_guo
  FROM shh s JOIN agg USING (sub) LEFT JOIN g ON g.shh = s.shh GROUP BY s.sub
),
id AS (
  SELECT DISTINCT ON (bvdid) bvdid, dateinc_year AS yr,
         (historic_status_str ILIKE 'active%%' AND historic_status_str NOT ILIKE '%%dormant%%') AS active
  FROM %1$s.ob_w_company_id_table_%2$s WHERE bvdid IN (SELECT sub FROM y WHERE ngc >= 2 AND foreign_guo) ORDER BY bvdid
)
SELECT count(*) AS guo_country_rule_extra FROM y JOIN id ON id.bvdid = y.sub
WHERE ngc >= 2 AND foreign_guo AND active AND yr BETWEEN 2005 AND 2023", lib, s, SAMPLE)
for (ls in list(c("bvd_orbis_large", "l"), c("bvd_orbis_medium", "m"))) {
  r <- q(guo_sql(ls[1], ls[2]))
  res[[length(res) + 1]] <- data.table(library = ls[2], variant = "guo_country_rule_extra_before_type_checks_estimated",
                                       jvs = r$guo_country_rule_extra * SAMPLE)
}

# Small library, ownership screen only (before status, year, parent-type and
# industry checks), estimated on the same hash sample and scaled up.
small <- q(sprintf("
WITH shh AS (
  SELECT sub_bvdid AS sub, left(sub_bvdid, 2) AS sc, left(shh_bvdid, 2) AS hc, dir_pct_onlyfigures::numeric AS pct
  FROM bvd_orbis_small.ob_links_current_s
  WHERE type_of_relation = 'SHH' AND active_or_archived = 'active'
    AND shh_bvdid !~ '[*]' AND shh_bvdid ~ '^[A-Z]{2}' AND dir_pct_onlyfigures ~ '^[0-9.]+$'
    AND dir_pct_onlyfigures::numeric BETWEEN 10 AND 90
    AND abs(hashtext(sub_bvdid)) %% %d = 0
),
agg AS (SELECT sub FROM shh GROUP BY sub
        HAVING count(*) BETWEEN 2 AND 3 AND sum(pct) >= 50 AND min(pct) >= 20 AND count(DISTINCT hc) >= 2 AND bool_or(hc <> sc))
SELECT count(*) AS small_screen FROM agg", SAMPLE))
res[[length(res) + 1]] <- data.table(library = "s", variant = "ownership_screen_before_type_status_year_checks_estimated",
                                     jvs = small$small_screen * SAMPLE)

# ---- Capital IQ ---------------------------------------------------------------
# Current: investee with two or three corporate owners (current investment or
# subsidiary relation, 20 to 90 percent), owners in at least two countries.
# Prior: investee with at least two prior corporate owners in at least two
# countries (shares are rarely recorded for prior relations).
ctype <- q("SELECT companytypeid, companytypename FROM ciq.ciqcompanytype ORDER BY 1")
corp_ids <- ctype[grepl("Company", companytypename) & !grepl("Investment|Fund|Government", companytypename), companytypeid]
ciq <- q(sprintf("
WITH cur AS (
  SELECT r.childcompanyid AS child, r.parentcompanyid AS parent, r.percentownership AS pct
  FROM ciq.companyrels r JOIN ciq.ciqcompany p ON p.companyid = r.parentcompanyid
  WHERE r.companyreltypeid IN ('1', '5') AND r.percentownership BETWEEN 20 AND 90 AND p.companytypeid IN (%1$s)
),
cur_jv AS (
  SELECT c.child FROM cur c JOIN ciq.ciqcompany p ON p.companyid = c.parent
  GROUP BY c.child HAVING count(*) BETWEEN 2 AND 3 AND sum(c.pct) >= 50 AND count(DISTINCT p.countryid) >= 2
),
pri AS (
  SELECT r.childcompanyid AS child, r.parentcompanyid AS parent
  FROM ciq.companyrels r JOIN ciq.ciqcompany p ON p.companyid = r.parentcompanyid
  WHERE r.companyreltypeid IN ('2', '6') AND p.companytypeid IN (%1$s)
),
pri_jv AS (
  SELECT x.child FROM pri x JOIN ciq.ciqcompany p ON p.companyid = x.parent
  GROUP BY x.child HAVING count(DISTINCT x.parent) >= 2 AND count(DISTINCT p.countryid) >= 2
)
SELECT (SELECT count(*) FROM cur_jv) AS ciq_current_jvs,
       (SELECT count(*) FROM cur_jv j JOIN ciq.ciqcompany c ON c.companyid = j.child WHERE c.yearfounded BETWEEN 2005 AND 2023) AS ciq_current_jvs_founded_2005_2023,
       (SELECT count(*) FROM pri_jv) AS ciq_prior_coowned",
  paste(corp_ids, collapse = ",")))
res[[length(res) + 1]] <- melt(ciq[, library := "ciq"], id.vars = "library", variable.name = "variant", value.name = "jvs")

out <- rbindlist(res, use.names = TRUE)
fwrite(out, f_out)
message("route sizing written: ", f_out)
print(out)
