# 08_feasibility_reg_cells.R
# Stage 5 feasibility count for H4 (PI decision of 2026-11-25, docs/decisions.md),
# run after the fallback rule was recorded and before gate 5 is approved.
#
# Independence rule (CLAUDE.md rule 8; limits of the rescoring of 2026-11-24):
# this script counts structural quantities only. It counts whether an IJV has a
# REG cell (IJV x regulatory domain x year with at least const$min_cell_emp
# employees, positions overlapping 30 June) in the clean pre-period 2013 to 2015
# and from 2021 on, by exposure group; the exposed IJVs with a control-linked EU
# parent under Rule C (ownership data only); and the number of control pairs. It
# never reads an origin category, never counts hires, and never compares a
# quantity before against after onset beyond whether qualifying cells exist.
#
# Inputs (licensed, local only): data/processed/ijv-matched-, ijv-parents-,
# ijv-employee-spells-v3-2026-10-09; data/raw/revelio-jv-positions-onet-2026-11-25/;
# data/raw/revelio-role-lookup-v3-2026-11-25.parquet;
# data/processed/contingency-scores-occupation-v1-2026-11-25.csv;
# data/interim/shock-exposure-ijv-2026-11-24.csv (S13 main variant).
# Output:  data/interim/feasibility-reg-cells-2026-11-25.md (aggregate counts only)
# Run:     "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/08_feasibility_reg_cells.R

source("code/R/00_setup.R")
require_pkgs("arrow")
RUN <- "v3-2026-10-09"
PRE <- 2013:2015; POST <- 2021:2025
f_rep <- file.path(paths$interim, "feasibility-reg-cells-2026-11-25.md")
set13 <- c("AT","BE","BG","HR","CY","CZ","DK","EE","FI","FR","DE","GR","HU","IE","IT","LV","LT","LU","MT","NL",
           "PL","PT","RO","SK","SI","ES","SE","IS","LI","NO","CH")

ijv <- fread(file.path(paths$processed, sprintf("ijv-matched-%s.csv", RUN)), colClasses = list(character = "jv_bvdid"),
             na.strings = "", select = c("jv_bvdid", "jv_country"))
par <- fread(file.path(paths$processed, sprintf("ijv-parents-%s.csv", RUN)), colClasses = list(character = "jv_bvdid"),
             na.strings = "", select = c("jv_bvdid", "parent_country", "equity_share_current", "parent_in_revelio"))
par <- merge(par, ijv[, .(jv_bvdid, host = jv_country)], by = "jv_bvdid")
par_rev <- par[, .(par_rev = any(parent_in_revelio)), by = jv_bvdid]

# ---- Exposure (S13 main variant) and controls (as in 06_shock_exposure.R) ----------
ex <- fread(file.path(paths$interim, "shock-exposure-ijv-2026-11-24.csv"), na.strings = "")
ex <- ex[shock == "S13" & grepl("^main", variant), .(jv_bvdid, pair)]
third <- par[, .(gb = any(parent_country == "GB"), eu = any(parent_country %chin% set13), host = host[1]), by = jv_bvdid][
  gb & eu & host != "GB" & !host %chin% set13, jv_bvdid]
ctrl <- ijv[(jv_country %chin% set13 | jv_country == "GB") & !jv_bvdid %chin% c(ex$jv_bvdid, third), jv_bvdid]
# Control pair (proposed dyad): host plus the country of the largest-equity foreign parent.
cp <- par[jv_bvdid %chin% ctrl & parent_country != host][order(jv_bvdid, -equity_share_current)]
cp <- unique(cp, by = "jv_bvdid")[, .(jv_bvdid, pair = paste0(host, "-", parent_country))]
ctrl_nofor <- setdiff(ctrl, cp$jv_bvdid)          # controls without a foreign parent row

# ---- Positions to domains ---------------------------------------------------------
sp <- as.data.table(arrow::read_parquet(file.path(paths$processed, sprintf("ijv-employee-spells-%s.parquet", RUN)),
       col_select = c("jv_bvdid", "user_id", "position_id", "first_reference_year", "last_reference_year", "role_k17000_v3")))
sp <- sp[jv_bvdid %chin% c(ex$jv_bvdid, ctrl)]
sp[, position_id := as.numeric(position_id)]
po <- rbindlist(lapply(list.files(file.path(paths$raw, "revelio-jv-positions-onet-2026-11-25"), "^part-[0-9]+[.]parquet$", full.names = TRUE),
                       function(f) as.data.table(arrow::read_parquet(f))))
is_occ <- function(x) !is.na(x) & grepl("^[0-9]{2}-[0-9]{4}[.][0-9]{2}$", x)
po <- po[is_occ(onet_code)]
lk <- as.data.table(arrow::read_parquet(file.path(paths$raw, "revelio-role-lookup-v3-2026-11-25.parquet"), col_select = c("role_k17000_v3", "onet_code")))
lk <- lk[is_occ(onet_code)]
sp <- merge(sp, po, by = "position_id", all.x = TRUE)
sp[is.na(onet_code), onet_code := lk$onet_code[match(role_k17000_v3, lk$role_k17000_v3)]]
occ <- fread(file.path(paths$processed, "contingency-scores-occupation-v1-2026-11-25.csv"), select = c("onet_code", "regulatory_narrow", "regulatory_broad"))
sp <- merge(sp, occ, by = "onet_code", all.x = TRUE)
sp <- sp[regulatory_broad == TRUE]                 # only regulatory positions are needed

# ---- REG cells: IJV x year with >= min_cell_emp employees (30 June reference years) --
cells <- function(d, yrs) rbindlist(lapply(yrs, function(y)
  unique(d[first_reference_year <= y & last_reference_year >= y], by = c("jv_bvdid", "user_id"))[, .(n = .N), by = jv_bvdid][, year := y]))
qual <- function(d, yrs) unique(cells(d, yrs)[n >= const$min_cell_emp, jv_bvdid])
lists <- list(narrow = sp[regulatory_narrow == TRUE], broad = sp)
res <- rbindlist(lapply(names(lists), function(L) {
  d <- lists[[L]]; pre <- qual(d, PRE); post <- qual(d, POST); both <- intersect(pre, post)
  grp <- function(ids, who) {
    e <- ex[jv_bvdid %chin% ids]; cc <- cp[jv_bvdid %chin% ids]
    data.table(list = L, period = who,
      exposed_ijv = uniqueN(e$jv_bvdid), exposed_pairs = uniqueN(e$pair),
      exposed_ijv_par_rev = uniqueN(e[jv_bvdid %chin% par_rev[par_rev == TRUE, jv_bvdid], jv_bvdid]),
      exposed_pairs_par_rev = uniqueN(e[jv_bvdid %chin% par_rev[par_rev == TRUE, jv_bvdid], pair]),
      control_ijv = length(intersect(ids, ctrl)), control_pairs = uniqueN(cc$pair))
  }
  rbind(grp(pre, "2013-2015"), grp(post, "2021 on"), grp(both, "both periods"))
}))

# ---- Rule C: UK-hosted exposed IJVs by the largest EU parent stake (ownership only) --
uk <- par[jv_bvdid %chin% ex$jv_bvdid & host == "GB" & parent_country %chin% set13]
uk <- uk[, .(stake = max(equity_share_current, na.rm = TRUE)), by = jv_bvdid]
rc <- data.table(band = c("above 50 (control-linked under Rule C)", "exactly 50", "below 50", "stake missing"),
                 ijv = c(uk[stake > 50, .N], uk[stake == 50, .N], uk[stake < 50, .N], uk[!is.finite(stake), .N]))
eu_hosted <- uniqueN(ex[!jv_bvdid %chin% uk$jv_bvdid, jv_bvdid])

# ---- Rule ----------------------------------------------------------------------------
nb <- res[list == "narrow" & period == "both periods", exposed_pairs]
bb <- res[list == "broad" & period == "both periods", exposed_pairs]
verdict <- if (nb >= 10) "narrow list stays the confirmatory H4 measure" else if (bb >= 10)
  "narrow list below 10 pairs: the broad list becomes the confirmatory H4 measure" else
  "both lists below 10 pairs: the continuous law-and-government importance becomes the confirmatory H4 measure"

fmt <- function(d) c(paste("|", paste(names(d), collapse = " | "), "|"), paste("|", paste(rep("---", ncol(d)), collapse = " | "), "|"),
                     apply(d, 1, function(r) paste("|", paste(r, collapse = " | "), "|")))
writeLines(c("# H4 feasibility count: REG cells by exposure group, 2026-11-25", "",
  "Built by `code/R/08_feasibility_reg_cells.R` under the rescoring limits of 2026-11-24: structural counts only; no origin category, no hire count, no before-after comparison of magnitudes. A REG cell is an IJV-year with at least 5 employees (positions overlapping 30 June) in the regulatory occupations. Exposure: S13 main variant (parent-host pairs). Controls: IJVs in the UK and the EU, EEA and Switzerland without a UK-set link; control pair = host plus the largest-equity foreign parent.", "",
  sprintf("- Exposed IJVs (S13 main): %d in %d pairs. Controls: %d IJVs in %d pairs; %d controls have no foreign parent row and no pair.",
          uniqueN(ex$jv_bvdid), uniqueN(ex$pair), length(ctrl), uniqueN(cp$pair), length(ctrl_nofor)), "",
  "## IJVs and pairs with at least one REG cell", "", fmt(res), "",
  "## Rule C: UK-hosted exposed IJVs by the largest EU, EEA or Swiss parent stake", "", fmt(rc), "",
  sprintf("Exposed IJVs hosted in the EU, EEA or Switzerland with a UK parent (Rule C does not apply; UK immigration rules govern transfers into the UK only): %d.", eu_hosted), "",
  "## Fallback rule (fixed on 2026-11-25 before this count)", "",
  sprintf("Exposed pairs with REG cells in both periods: narrow list %d, broad list %d. Result: %s.", nb, bb, verdict)), f_rep)
cat(readLines(f_rep), sep = "\n")
