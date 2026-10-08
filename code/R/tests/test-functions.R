# Unit checks for measures.R and matching.R on synthetic data (no project data needed).
# Run from the repository root: Rscript code/R/tests/test-functions.R
suppressMessages(source("code/R/00_setup.R"))
ok <- function(cond, msg) cat(if (isTRUE(cond)) "PASS" else "FAIL", msg, "\n")
# classify_origin
ok(classify_origin(c("A1","X"), "A1", "B1") == "parent_a", "most recent employer parent A")
ok(classify_origin(c("X","B1"), "A1", "B1") == "parent_b", "parent B within window")
ok(classify_origin(c("X"), "A1", "B1", "AT", "AT") == "external_host", "external host-country hire")
ok(classify_origin(c("X"), "A1", "B1", "DE", "AT") == "external_intl", "external international hire")
ok(classify_origin(character(0), "A1", "B1") == "no_history", "no history")
# cell_measures
m <- cell_measures(n_a = 5, n_b = 5, n_ext_host = 8, n_ext_intl = 2, equity_a = .5, equity_b = .5)
ok(abs(m$cross_parent_integration - 1) < 1e-9, "balanced parents give CPI = 1")
ok(m$parent_dominance == 0 && m$parent_dominance_adj == 0, "balanced dominance 0")
ok(abs(m$localization - 0.5) < 1e-9 && abs(m$localization_host - 0.4) < 1e-9, "localization shares")
m2 <- cell_measures(10, 0, 0, 0, equity_a = .6, equity_b = .4)
ok(m2$cross_parent_integration == 0 && m2$parent_dominance == 1, "single parent gives CPI 0, dominance 1")
ok(abs(m2$parent_dominance_adj - 0.8) < 1e-9, "ownership-adjusted dominance")
m3 <- cell_measures(0, 0, 3, 1)
ok(is.na(m3$cross_parent_integration) && m3$localization == 1, "no parent-origin staff gives NA CPI")
# within_ijv_dispersion
d <- data.table(ijv_id = 1, year = 2020, cross_parent_integration = c(0, .5, 1))
r <- within_ijv_dispersion(d)
ok(r$n_cells == 3 && abs(r$disp_range - 1) < 1e-9, "dispersion across functions")
# normalize_name and match_entities
ok(normalize_name("Siemens AG") == "siemens", "legal suffix stripped")
ok(normalize_name("Société Générale S.A.") == "societe generale", "accents and S.A. stripped")
orb <- data.table(orbis_id = c("O1","O2","O3"), orbis_name = c("Siemens AG","Shanghai Volkswagen Automotive Co Ltd","Unknown Venture"), orbis_country = c("DE","CN","AT"))
rev <- data.table(rcid = c(1,2,3), rev_name = c("Siemens AG","SAIC Volkswagen Automotive","Siemens Healthineers"), rev_country = c("DE","CN","DE"))
mm <- match_entities(orb, rev, jw_threshold = 0.85)
print(mm[, .(orbis_id, orbis_name, rcid, method, score = round(score, 3), needs_review)])
ok(mm[orbis_id == "O1", method][1] == "exact", "exact match found")
ok(!"O3" %in% mm$orbis_id, "no spurious match for unknown venture")
# web_domains
ok(identical(web_domains("www.nova-pack.com|nova-pack.com|https://www.a.de/x"), c("nova-pack.com", "a.de")), "website domains parsed and de-duplicated")
# review_tier_candidates
cand <- data.table(orbis_id = c("J1","J1","J2","J2","J3","J4"),
                   rcid = c(10, 11, 20, 21, 30, 40),
                   company_name = c("Nova-Pack", "Nova Pack Holding", "Alpha One", "Alpha Two", "Parent Group", "Beta Ltd"),
                   country = c("DK", "SE", "IT", "IT", "ES", "GB"),
                   match_key = c("domain", "domain", "stem2", "stem2", "domain", "web_stem"))
jvt <- data.table(orbis_id = c("J1","J2","J3","J4"), orbis_name = c("Nova-Pack A/S", "Alpha Srl", "Gamma SL", "Beta Limited"),
                  orbis_country = c("DK", "IT", "ES", "GB"))
rt <- review_tier_candidates(cand, jvt, parent_rcids = 30, parent_names = data.table(orbis_id = "J4", parent_name = "BETA LTD"))
ok(rt[orbis_id == "J1", rcid] == 10, "host-country domain candidate kept, foreign one dropped")
ok(!"J2" %in% rt$orbis_id, "route with two look-alike companies gives no pick")
ok(!"J3" %in% rt$orbis_id, "parent entity rejected")
ok(!"J4" %in% rt$orbis_id, "candidate resembling the JV's own parent rejected")
ok(isTRUE(rt[orbis_id == "J1", strong]), "close-name domain match flagged strong")
