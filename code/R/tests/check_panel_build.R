# check_panel_build.R
# Test of the stage 6 panel build on simulated data, and schema check of the
# panels against the stage 7 estimation helpers.
#
# Mode "synthetic" (default): writes the synthetic input
# (tests/synthetic_panel_build.R), runs 02_build_panel.R synthetic and
# 03_measures.R synthetic, and checks that every seeded failure is handled as
# expected (seeded-cases.csv plus frame-level checks), that the identities of
# A3 hold, that cell sums equal the hire counts, and that the domain panel
# carries every column and type of the stage 5 simulated panel
# (simulate_domain_panel()) and every variable named in the model formulas of
# code/R/functions/simulate_domain_panel.R and of the C1 block of the plan.
# Report: data/synthetic/panel-build-test-synthetic-2026-11-26.md.
#
# Mode "real": reads ONLY the parquet schemas (column names and types) of the
# real panels in data/processed/ (no row is read, nothing is estimated;
# real_data_lock) and runs the same schema comparison. Report (column names
# only): data/interim/panel-schema-check-v1-2026-11-26.md.
#
# Run from the repository root:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/tests/check_panel_build.R            # synthetic
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/tests/check_panel_build.R real       # schema of the real panels

source("code/R/00_setup.R")
require_pkgs(c("arrow", "fixest"))
source("code/R/functions/panel_build.R")
MODE <- if ("real" %in% commandArgs(trailingOnly = TRUE)) "real" else "synthetic"
res <- list()
ok <- function(group, check, cond, detail = "") {
  res[[length(res) + 1L]] <<- data.table(group = group, check = check, result = if (isTRUE(cond)) "PASS" else "FAIL", detail = detail)
  cat(if (isTRUE(cond)) "PASS" else "FAIL", group, "|", check, if (nzchar(detail)) paste0("(", detail, ")") else "", "\n")
}

# Columns and types the stage 7 helpers expect (stage 5 simulated domain panel), and the
# variables named in the model formulas of the plan (B1, C1).
expected_schema <- function() {
  source("code/R/functions/simulate_domain_panel.R")
  dom <- domain_scores_sim()
  p <- simulate_domain_panel(dom, n_ijv = 60L, seed = 1L)
  setdiff(names(p), "synthetic") |> (\(n) data.table(column = n, class = vapply(p[, ..n], function(x) class(x)[1], "")))()
}
FORMULA_VARS <- list(
  domain = c("ijv_id", "domain", "year", "dyad", "n_parent", "n_obs", "n_local", "n_geo", "n_local_parent", "n_local_indep", "n_intl",
             "coord_dependence", "local_embeddedness", "cd_host", "cd_nohost", "exp_post_reg", "exp_antic_reg", "treat_reg", "reg",
             "exposed", "post", "antic_yr", "shock", "antic", "host_parent", "law_gov_importance", "job_zone", "n_emp", "n_hires",
             "n_not_obs", "n_entrant", "n_unknown", "rd_core", "rd_ratio", "rd_code_missing", "rd_core_hcp", "score_imputed_domain",
             "control_linked", "gb_ie", "s13_sample", "parent_in_revelio", "h3_sample", "flag_jv_in_parent_family", "main_period", "cell_emp5", "cell_hires5"),
  level = c("ijv_id", "level", "year", "dyad", "n_local", "n_obs", "n_geo", "n_intl", "n_intl_parent", "n_intl_indep", "n_intl_parent_home",
            "n_parent", "coord_role", "shock", "antic", "uk_host", "control_linked", "exposed", "s13_sample", "event_time", "n_emp", "main_period"))
num_like <- function(cl) cl %chin% c("integer", "numeric", "double", "int32", "int64")
compare_schema <- function(have, label, want, vars) {
  miss <- setdiff(want$column, have$column)
  ok("schema", sprintf("%s: every column of the stage 5 simulated panel is present", label), !length(miss), paste(miss, collapse = ", "))
  m <- merge(want, have, by = "column", suffixes = c("_sim", "_panel"))
  bad <- m[!(class_sim == class_panel | (num_like(class_sim) & num_like(class_panel)))]
  ok("schema", sprintf("%s: types compatible with the simulated panel", label), !nrow(bad),
     paste(sprintf("%s %s/%s", bad$column, bad$class_sim, bad$class_panel), collapse = ", "))
  mv <- setdiff(vars, have$column)
  ok("schema", sprintf("%s: every variable named in the plan's model formulas is present", label), !length(mv), paste(mv, collapse = ", "))
  ok("schema", sprintf("%s: no column named 'function'", label), !"function" %in% have$column)
}
arrow_class <- function(t) fcase(t %in% c("int32", "int64"), "integer", t == "double", "numeric", t %in% c("string", "large_string"), "character",
                                 t == "bool", "logical", default = t)
schema_of <- function(f) { s <- arrow::open_dataset(f)$schema; data.table(column = s$names, class = arrow_class(vapply(s$fields, function(x) x$type$ToString(), ""))) }

if (MODE == "synthetic") {
  R <- file.path(R.home("bin"), "Rscript")
  for (s in c("code/R/tests/synthetic_panel_build.R", "code/R/02_build_panel.R", "code/R/03_measures.R")) {
    st <- system2(R, c(s, "synthetic"), stdout = FALSE, stderr = FALSE)
    ok("run", sprintf("%s runs to the end", s), st == 0L)
  }
  cfg <- panel_config("synthetic")
  B <- cfg$out
  rd <- function(n) as.data.table(arrow::read_parquet(file.path(B, sprintf("panel-%s-%s.parquet", n, cfg$tag))))
  H <- rd("hires"); A <- rd("ijv-attributes")
  P <- list(domain = rd("ijv-domain-year"), domain_b = rd("ijv-domain-b-year"), level = rd("ijv-level-year"), level_b = rd("ijv-level-b-year"),
            seniority = rd("ijv-seniority-year"), fn = rd("ijv-function-year"), role50 = rd("ijv-role50-year"))
  LG <- fread(file.path(B, sprintf("panel-build-log-%s.csv", cfg$tag)), colClasses = "character")
  lg <- function(pat) as.numeric(gsub(",", "", LG[grepl(pat, step, fixed = TRUE), removed][1]))

  # Seeded people.
  E <- fread(file.path("data/synthetic/panel-build-synthetic-2026-11-26", "seeded-cases.csv"), colClasses = "character")
  for (i in seq_len(nrow(E))) {
    e <- E[i]; h <- H[user_id == as.numeric(e$user_id) & jv_bvdid == e$jv_bvdid]
    if (e$what == "n_hires_person") { got <- as.character(nrow(h)) }
    else if (e$what == "in_stock_2025") {
      sp <- as.data.table(arrow::read_parquet(cfg$spells))[user_id == as.numeric(e$user_id)]
      sp <- unique(sp, by = "position_id")[, `:=`(formation_year = 2005L, k = "x")]
      got <- as.character(nrow(stock_counts(sp, "k", 2025L)) == 1L)
    } else got <- if (nrow(h) == 1L) as.character(h[[e$what]]) else sprintf("%d hire rows", nrow(h))
    want <- if (e$value == "") NA_character_ else e$value
    got[is.na(got)] <- NA_character_
    ok(e$case, sprintf("%s = %s", e$what, ifelse(is.na(want), "NA", want)), identical(got, want), sprintf("got %s", ifelse(is.na(got), "NA", got)))
  }
  # Frame-level checks of the seeded failures.
  ok("S01 repeated position ids", "spell copies removed (log)", lg("after removing repeated position_id") == 3, "3 copies seeded: 2 for the seeded person's duplicated row, 1 extra")
  ok("S01 repeated position ids", "history copies removed (log)", LG[part == "4 Histories" & grepl("repeated", step), removed] == "2")
  ok("S02 undated only position", "pairs without a dated position dropped (log)", lg("pairs with a dated first position") == 1)
  ok("S08 hires outside 2010 to 2025", "no panel year after 2025", all(vapply(P, function(d) max(d$year) <= PANEL_END, TRUE)))
  dom41 <- P$domain[ijv_id == "SYN00001" & year == 2008L]
  ok("S08 hires outside 2010 to 2025", "the 2008 hire is in a full-period row with main_period = 0", dom41[, sum(n_hires) >= 1L & all(main_period == 0L)])
  ok("S08 hires outside 2010 to 2025", "hire before the formation year dropped (log)", lg("hire year from the formation year on") == 1)
  ok("S08 hires outside 2010 to 2025", "2026 hire dropped (log)", lg("hire year up to 2025") == 1)
  ok("S09 parent's own entity as IJV", "IJV flagged flag_jv_in_parent_family", A[ijv_id == "SYN00010", flag_jv_in_parent_family] == 1L)
  ok("S09 parent's own entity as IJV", "IJV kept in the panels", "SYN00010" %chin% P$domain$ijv_id)
  ok("S14 shared family entity", "IJV flagged flag_shared_family_entity", A[ijv_id == "SYN00004", flag_shared_family_entity] == 1L)
  ok("S07 person at two IJVs", "two hires for the person", H[user_id == 7, .N] == 2L)
  ok("S16 invalid O*NET value", "hire counted in the level panel, not in the domain panel",
     P$level[ijv_id == "SYN00002" & year == 2015L & level == "middle_management", sum(n_hires)] >= 1L &&
       sum(P$domain$n_hires) == H[!is.na(domain), .N])
  ok("S18 seniority missing", "level panel hires equal hires with a level", sum(P$level$n_hires) == H[!is.na(level), .N])
  # S13 and other IJV-level codings.
  ok("S13 coding", "exposed IJVs are 1, 2, 3, 12", setequal(A[exposed == 1L, ijv_id], sprintf("SYN%05d", c(1, 2, 3, 12))))
  ok("S13 coding", "owner-level control with a UK ultimate owner dropped (IJV 5), the other kept (IJV 6)",
     A[ijv_id == "SYN00005", s13_owner_link_dropped == 1L & s13_control == 0L] && A[ijv_id == "SYN00006", s13_control == 1L])
  ok("S13 coding", "controls are IJVs 4, 6 and 10 (EU-hosted, no UK-set link)", setequal(A[s13_control == 1L, ijv_id], sprintf("SYN%05d", c(4, 6, 10))))
  ok("S13 coding", "third-country pair (IJV 7) in neither group", A[ijv_id == "SYN00007", s13_third_country == 1L & s13_sample == 0L])
  ok("S13 coding", "gb_ie only for IJV 3", setequal(A[gb_ie == 1L, ijv_id], "SYN00003"))
  ok("S13 coding", "Rule C: IJV 1 (DE 60) control-linked; IJV 12 (FR 50) and IJV 3 (IE 40) not",
     A[ijv_id == "SYN00001", control_linked] == 1L && A[ijv_id %chin% c("SYN00012", "SYN00003"), all(control_linked == 0L)] &&
       A[ijv_id == "SYN00012", eu_stake_band] == "exactly_50" && A[ijv_id == "SYN00003", eu_stake_band] == "below_50")
  ok("S13 coding", "dyads: exposure pair, foreign direct parent, foreign ultimate owner",
     A[ijv_id == "SYN00001", dyad] == "GB-DE" && A[ijv_id == "SYN00004", dyad] == "FR-US" && A[ijv_id == "SYN00006", dyad] == "IT-JP")
  ok("Listed JVs", "Orbis 'Listed' (IJV 1) and Capital IQ with ISIN (IJV 11) flagged; 'Delisted' (IJV 12) not",
     setequal(A[flag_listed == 1L, ijv_id], c("SYN00001", "SYN00011")))
  ok("Namibia", "host country code NA kept as a value", A[ijv_id == "SYN00009", host_country] == "NA")
  # Panels: identities, sums, keys.
  for (g in names(P)) {
    d <- P[[g]]; key <- names(d)[2]
    ok("identities", sprintf("%s: A3 identities hold on every row", g), isTRUE(tryCatch(check_identities(d), error = function(e) FALSE)))
    hk <- c(domain = "domain", domain_b = "domain_b", level = "level", level_b = "level_b", seniority = "seniority", fn = "fn", role50 = "role50")[[g]]
    ok("sums", sprintf("%s: cell hires sum to the hires with a value of the grain", g), sum(d$n_hires) == H[!is.na(get(hk)), .N])
    ok("keys", sprintf("%s: one row per IJV x %s x year", g, key), !anyDuplicated(d, by = c("ijv_id", key, "year")))
  }
  ok("grains", "REG in the domain panel, REG_B in the domain-b panel", "REG" %chin% P$domain$domain && "REG_B" %chin% P$domain_b$domain &&
       !"REG_B" %chin% P$domain$domain && !"REG" %chin% P$domain_b$domain)
  ok("grains", "regressors complete in the domain panels", !anyNA(P$domain$coord_dependence) && !anyNA(P$domain_b$local_embeddedness))
  ok("grains", "resource dependence set for some cells", any(!is.na(P$domain$rd_core)))
  LG3 <- readLines(file.path(B, "sample-construction-log.md"))
  ok("grains", "parents with a code reach an OEWS industry, short codes through the 3-digit match (20 of 24)",
     any(grepl("parents with an OEWS industry", LG3, fixed = TRUE) & grepl("| 20 | parents", LG3, fixed = TRUE)))
  ok("grains", "rater scores on the role_k50 panel", any(!is.na(P$role50$coord_dependence_rater)))
  have <- data.table(column = names(P$domain), class = vapply(P$domain, function(x) class(x)[1], ""))
  compare_schema(have, "synthetic domain panel", expected_schema(), FORMULA_VARS$domain)
  hl <- data.table(column = names(P$level), class = vapply(P$level, function(x) class(x)[1], ""))
  mv <- setdiff(FORMULA_VARS$level, hl$column)
  ok("schema", "synthetic level panel: every variable of the C1 and level models is present", !length(mv), paste(mv, collapse = ", "))
  out <- "data/synthetic/panel-build-test-synthetic-2026-11-26.md"
} else {
  f <- function(n) file.path(paths$processed, sprintf("panel-%s-v1.parquet", n))
  compare_schema(schema_of(f("ijv-domain-year")), "real domain panel", expected_schema(), FORMULA_VARS$domain)
  compare_schema(schema_of(f("ijv-domain-b-year")), "real domain-b panel", expected_schema(), FORMULA_VARS$domain)
  hl <- schema_of(f("ijv-level-year"))
  mv <- setdiff(FORMULA_VARS$level, hl$column)
  ok("schema", "real level panel: every variable of the C1 and level models is present", !length(mv), paste(mv, collapse = ", "))
  out <- file.path(paths$interim, "panel-schema-check-v1-2026-11-26.md")
}
RS <- rbindlist(res)
writeLines(c(sprintf("# Panel build check (%s), %s", MODE, format(Sys.Date())), "",
  "Written by `code/R/tests/check_panel_build.R`.", if (MODE == "real") "Only the parquet schemas of the real panels were read (column names and types); no row, no estimate." else
  "Simulated data only (`code/R/tests/synthetic_panel_build.R`, seed 20261126).", "",
  sprintf("Result: %d of %d checks pass.", RS[result == "PASS", .N], nrow(RS)), "",
  knitr::kable(RS, format = "pipe")), out)
message(sprintf("%d of %d checks pass; report %s", RS[result == "PASS", .N], nrow(RS), out))
