# synthetic_parent_industry.R
# Synthetic twin of the parent industry pulls (code/R/wrds/15_wrds_parent_industry.R
# and 16_wrds_ciq_parent_industry.R) and a test of the rule in
# code/R/functions/parent_industry.R (v2, 2026-11-25). Every value is drawn from a
# distribution or made up; no real row, company id, industry assignment or
# concordance row is read. Ids carry the prefix SYN; NAICS codes use the made-up
# sector 99 plus the holding codes the rule must recognize (NAICS 551112, NACE
# 64.20 and 70.10); the concordances are made up in the same code space.
# Seeded failures and fallbacks (each must be caught; the script stops if one is not):
#   several industry rows with conflicting codes; one company in two libraries;
#   parent absent from the industry table (owner takes over); holding parent
#   with a usable core code; holding parent with a usable secondary code only;
#   holding parent falling back to its owner; holding whose owner is a holding;
#   holding that is its own owner; holding by NACE 64.2 written with a dot;
#   head office (NACE 70.1); a NAICS 2022 code mapped to 2017; four- and
#   three-digit codes; Capital IQ parents reached through an exact SIC code,
#   through a SIC group code, through a parent node of the industry tree, and
#   one without a primary industry.
# Run: "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/tests/synthetic_parent_industry.R
source("code/R/00_setup.R")
require_pkgs("arrow")
source("code/R/functions/parent_industry.R")
set.seed(20261125)
GEN_DATE <- "2026-11-25"
check <- function(cond, msg) { cat(if (isTRUE(cond)) "OK   " else "FAIL ", msg, "\n"); if (!isTRUE(cond)) stop(msg, call. = FALSE) }

# ---- made-up concordances in sector 99 ----
n17 <- sprintf("99%04d", c(1110, 1120, 2110, 2120, 3110, 4110))
cw <- list(sic_02 = data.table(from = c("9901", "9902", "9911", "9912"), to = c("991110", "991120", "992110", "992120")),
           n02_07 = data.table(from = c("991110", "991120", "992110", "992120"), to = c("991110", "991120", "992110", "992120")),
           n07_12 = data.table(from = c("991110", "991120", "992110", "992120"), to = c("991110", "991120", "992110", "992120")),
           n12_17 = data.table(from = c(n17, "551112"), to = c(n17, "551112")),
           n22_17 = data.table(from = c("995110", n17), to = c("993110", n17)))   # 995110 exists only in 2022
check(identical(to_naics2017(c("995110", "991110", "9911", "123456"), cw), c("9931", "991110", "9911", NA)), "NAICS 2022 code mapped to 2017; valid codes pass; unknown code dropped")

# ---- parents and Orbis rows ----
n_par <- 240L
par <- data.table(parent_bvdid = sprintf("SYNP%05d", seq_len(n_par)),
                  parent_guo = sprintf("SYNG%05d", sample(1:100, n_par, replace = TRUE)))
ids <- unique(c(par$parent_bvdid, par$parent_guo))
ind <- data.table(bvdid = ids, orbis_lib = sample(c("l", "m", "s"), length(ids), replace = TRUE),
                  nace2_main_section = "C", nacepcod2 = "2910", naceccod2 = NA_character_, nacescod2 = NA_character_,
                  naicspcod2017 = sample(n17, length(ids), replace = TRUE), naicsccod2017 = NA_character_, naicsscod2017 = NA_character_)
used <- character()
take <- function(n, pool) { x <- sample(setdiff(pool, used), n); used <<- c(used, x); x }
P <- function() setdiff(par$parent_bvdid, par$parent_guo)
guo_ok <- function() par[parent_guo != parent_bvdid, parent_bvdid]

s_multi   <- take(6, P()); ind <- rbind(ind, ind[bvdid %in% s_multi][, `:=`(naicspcod2017 = "994110", nacepcod2 = "4690")])
s_twolib  <- take(4, P()); ind <- rbind(ind, ind[bvdid %in% s_twolib][, orbis_lib := fifelse(orbis_lib == "l", "s", "l")])
s_absent  <- take(5, intersect(P(), guo_ok())); ind <- ind[!bvdid %in% s_absent]
s_core    <- take(5, P()); ind[bvdid %in% s_core, `:=`(naicspcod2017 = "551112", naicsccod2017 = "9921")]
s_sec     <- take(5, P()); ind[bvdid %in% s_sec, `:=`(naicspcod2017 = "551112", naicsscod2017 = "992120")]
s_n22     <- take(4, P()); ind[bvdid %in% s_n22, naicspcod2017 := "995110"]
s_short4  <- take(3, P()); ind[bvdid %in% s_short4, naicspcod2017 := "9911"]
s_short3  <- take(3, P()); ind[bvdid %in% s_short3, naicspcod2017 := "991"]
s_hold_guo <- take(6, intersect(P(), guo_ok())); ind[bvdid %in% s_hold_guo, naicspcod2017 := "551112"]
gh_pool <- intersect(P(), guo_ok())
gh_pool <- gh_pool[!par$parent_guo[match(gh_pool, par$parent_bvdid)] %in% par$parent_guo[match(c(s_hold_guo, s_absent), par$parent_bvdid)]]
s_hold_gh <- take(4, gh_pool); gh <- unique(par[parent_bvdid %in% s_hold_gh, parent_guo])
ind[bvdid %in% c(s_hold_gh, gh), naicspcod2017 := "551112"]
s_self    <- take(3, P()); par[parent_bvdid %in% s_self, parent_guo := parent_bvdid]; ind[bvdid %in% s_self, naicspcod2017 := "551112"]
s_nacedot <- take(3, P()); par[parent_bvdid %in% s_nacedot, parent_guo := parent_bvdid]
ind[bvdid %in% s_nacedot, `:=`(naicspcod2017 = NA_character_, nacepcod2 = "64.20")]
s_headoff <- take(3, intersect(P(), guo_ok())); ind[bvdid %in% s_headoff, `:=`(naicspcod2017 = NA_character_, nacepcod2 = "7010")]

# ---- Capital IQ parents ----
ciq_ids <- 900001:900006
par <- rbind(par, data.table(parent_bvdid = paste0("CIQ", ciq_ids), parent_guo = NA_character_))
subtype <- data.table(subtypeid = c(1, 10, 11, 100, 101, 102), childlevel = c(1, 2, 2, 3, 3, 3), subparentid = c(NA, 1, 1, 10, 10, 11))
ind_sic <- data.table(subtypeid = c(100, 101, 11), siccode = c(9901, 9910, 9912))   # 101: group code 9910; 102 unmapped, parent 11 mapped
tree <- data.table(companyid = c(900001, 900001, 900001, 900002, 900002, 900002, 900003, 900003, 900003, 900004),
                   companyindustryid = 1:10, subtypeid = c(1, 10, 100, 1, 10, 101, 1, 11, 102, 100),
                   primaryflag = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 0), chartypeid = 3)
cq <- ciq_parent_naics(tree, subtype, ind_sic, cw)
check(cq[companyid == 900001, ciq_naics4] == "9911", "Capital IQ: exact SIC code reaches NAICS 2017")
check(cq[companyid == 900002, ciq_naics4] == "9921", "Capital IQ: SIC group code 9910 stands for SIC 9911 and 9912, both NAICS 9921")
check(cq[companyid == 900003, ciq_naics4] == "9921", "Capital IQ: unmapped node walks up to a mapped parent node")
check(is.na(cq[companyid == 900004, ciq_naics4]) && !cq[companyid == 900004, ciq_primary], "Capital IQ: no primary industry gives no code")

ind[, synthetic := TRUE]; par[, synthetic := TRUE]
dir.create(file.path("data", "synthetic"), showWarnings = FALSE)
f_ind <- file.path("data", "synthetic", sprintf("orbis-parent-industry-synthetic-%s.parquet", GEN_DATE))
f_par <- file.path("data", "synthetic", sprintf("ijv-parents-guo-synthetic-%s.parquet", GEN_DATE))
arrow::write_parquet(ind, f_ind); arrow::write_parquet(par, f_par)

# ---- resolve ----
pk <- pick_industry(ind)
r <- resolve_parent_industry(par[, .(parent_bvdid, parent_guo)], pk, cw, cq)
g <- function(ids, col) r[match(ids, parent_bvdid)][[col]]
check(!anyDuplicated(pk$bvdid), "pick: one row per company")
check(nrow(r) == nrow(par) && !anyDuplicated(r$parent_bvdid), "resolve: one row per parent")
check(all(g(s_multi, "flag_code_conflict")), "several conflicting rows: flagged")
check(all(g(s_twolib, "flag_multi_rows")) && !any(g(s_twolib, "flag_code_conflict")), "two libraries, same codes: multi rows, no conflict")
check(all(g(s_absent, "flag_not_in_orbis_industry")) && all(startsWith(g(s_absent, "rd_naics_source"), "ultimate owner")), "absent parent: owner's code")
check(all(g(s_core, "rd_naics_source") == "own core") && all(g(s_core, "rd_naics4") == "9921"), "holding with a core code: own core code")
check(all(g(s_sec, "rd_naics_source") == "own secondary") && all(g(s_sec, "rd_naics4") == "9921"), "holding with a secondary code only: own secondary code")
check(all(g(s_n22, "rd_naics4") == "9931"), "NAICS 2022 code mapped to 2017")
check(all(g(s_short4, "rd_naics4") == "9911") && !any(g(s_short4, "flag_naics_short")), "four-digit code: used")
check(all(g(s_short3, "flag_naics_short")) && all(is.na(g(s_short3, "rd_naics4"))), "three-digit code: flagged short")
check(all(g(s_hold_guo, "holding")) && all(startsWith(g(s_hold_guo, "rd_naics_source"), "ultimate owner")), "holding without own codes: owner's code")
check(all(g(s_hold_gh, "flag_holding_unresolved")), "holding whose owner is a holding: unresolved")
check(all(g(s_self, "flag_holding_unresolved")), "holding that is its own owner: unresolved")
check(all(g(s_nacedot, "holding")) && all(g(s_nacedot, "flag_holding_unresolved")), "NACE 64.20 with a dot: holding")
check(all(g(s_headoff, "holding")) && all(startsWith(g(s_headoff, "rd_naics_source"), "ultimate owner")), "head office NACE 70.10: holding, owner's code")
ciqp <- paste0("CIQ", ciq_ids)
check(all(g(ciqp[1:3], "rd_naics_source") == "capital iq") && identical(g(ciqp[1:3], "rd_naics4"), c("9911", "9921", "9921")), "Capital IQ parents: tree code used")
check(all(g(ciqp[4:6], "flag_naics_missing")), "Capital IQ parents without a primary industry or absent from the tree: missing")
check(!any(startsWith(na.omit(r$rd_naics), "5511")), "no holding code survives as rd_naics")
check(all(nchar(na.omit(r$rd_naics4)) == 4L), "rd_naics4 has four digits")
print(r[, .N, by = rd_naics_source][order(-N)])
cat("synthetic files:", f_ind, f_par, "\n")
