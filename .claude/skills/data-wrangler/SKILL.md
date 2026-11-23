---
name: data-wrangler
description: >
  Use this skill to clean, type and document the extracted tables of the IJV
  staffing study. Triggers: "clean my data", "wrangle my dataset", "fix data
  issues", "generate a codebook", "update the codebook", "prepare data for
  analysis", "document my variables", "harmonize the tables", or any request
  to move from the raw extracts and the matched dataset to documented,
  analysis-ready base tables. Not for pulling data (`/data-collector`) and
  not for the function and level mapping, the staffing categories or the
  measures (`/panel-build`, after gate 5).
---

# Data Wrangling & Codebook Generation

Customized on 2026-11-23 from the seminar template `2C-data-wrangler.md` for
the IJV staffing study (Floh, Mohr, Thanyi; target JIBS).

## What This Skill Does

Takes the extracts in `data/raw/` and the matched tables in `data/processed/`
and produces: cleaned base tables with one naming and typing convention; an
updated `data/codebook.md`; a cleaning script that reruns from top to bottom;
and a cleaning-run entry in `data/data-log.md`. Every transformation is
logged with the rows it touched, so the pipeline can be audited.

The template was written for a survey: item renaming, reverse scoring,
composites, Cronbach's alpha, imputation. This study has no items and no
scales. The data are administrative records in six linked tables (IJVs,
parents, parent families, positions at the JV, career histories, annual
headcounts), and the cleaning problems are keys, id types, dates, country
codes, repeated records and unobserved histories. The survey branches are
removed and replaced by their archival counterparts.

Place in the workflow (`docs/workflow.md`): the skill belongs to the
`data-engineer` agent, is not a numbered stage and has no gate. It works
after `/data-collector` (which pulls, flags and logs) and before
`/panel-build` (stage 6, which maps functions and levels, classifies origin
and builds the measures once gate 5 is approved). It never approves a gate
and never fixes a definition that a gate decides.

---

## Customize This Skill (completed)

The **core** block is identical in all ten skills and was copied unchanged
from `.claude/skills/research-ideation/SKILL.md`. The **skill-specific**
block and the **extensions** apply only here.

```yaml
# ---------- CORE — identical in all ten skills ----------
field:                 international business
subfield:              international joint ventures: staffing, control and organizational design
target_venue:          Journal of International Business Studies
citation_style:        APA 7 in text; JIBS reference list (manuscript/csl/journal-of-international-business-studies.csl)
software:              R
replication_standard:  code-only package: scripts in code/R/ reproduce every table and figure from the licensed exports; Orbis, Revelio and BoardEx data are not shareable; pre-analysis plan fixed at gate 5

# ---------- SKILL-SPECIFIC — data-wrangler ----------
missing_threshold:     0.10 (share of rows per variable and table); also flagged: a missing share that differs by more than 0.10 between regions, sources or start-year bands. Structural missingness (end date of a position still held, Orbis headcount of a Capital IQ IJV) is reported, not flagged
missing_policy:        no deletion and no imputation. A missing value stays missing and is carried as a flag or as a category of its own (history not observed, employer not mapped, country not recorded). The one imputed value in the data, formation year 1990 for Capital IQ IJVs without a founding year, keeps its flag formation_year_missing
reliability_target:    n/a for Cronbach's alpha (no multi-item scales). In its place: exact agreement (1.00) between the pipeline and an independent recomputation on a random 300 IJVs for every count or derived variable
efa:                   false

# ---------- EXTENSIONS (three-edit pattern, see the last section) ----------
derived_vars_log:      true (every constructed variable gets its formula, its inputs and the script that builds it in data/codebook.md)
outlier_rule:          nothing is dropped, trimmed or winsorized here. Implausible sizes and dates are flagged (flag_size_mismatch, flag_pre_formation_10y, flag_pre_formation, range checks of Step 3f) and the PI decides in the sample definition
stage_scope:           before gate 5 only definition-free cleaning: keys, id types, names, dates, country codes, exact duplicates, flags, sample labels. Function and level mapping, origin classification, staffing categories, measures, controls and shock variables belong to /panel-build after gate 5
```

Notes on three values:

- `missing_policy` is a substantive decision. The reason is the research
  question itself: whether a hire is independent or parent-origin is read
  from the prior employer, so a missing history that is deleted or filled in
  moves people between the categories the hypotheses compare. About 30
  percent of hires have no prior position on record and about 14 percent of
  history positions have no mapped employer (`reviews/gate-4-pilot.md`;
  re-read before quoting). They are reported as their own classes.
- `reliability_target`: the reliability of the contingency scores of the
  functions (interview coding) is the business of `/qual-recode`, not of this
  skill. Match quality is audited by a person through the manual worklist.
- `stage_scope` follows `docs/decisions.md` (2026-10-09, 2026-11-23): the
  origin rule is provisional until gate 5, and the mapping of Revelio's
  role and seniority codes to the project's nine functions and four levels
  is set at gate 5.

Where each value comes from:

| Value | Source in this repository |
|-------|---------------------------|
| Core block | `.claude/skills/research-ideation/SKILL.md` |
| `missing_threshold` | template default; the group comparison follows Step 4 of `.claude/skills/data-collector/SKILL.md` |
| `missing_policy` | `docs/research-brief.md` (staffing frame: "history not observed" is its own class), `data/codebook.md` (`formation_year_missing`) |
| `reliability_target` | the check recorded under "Staffing tabulations" in `reviews/gate-4-pilot.md` |
| `outlier_rule` | flag definitions in `data/codebook.md`; sample definitions `core`, `core_main` |
| `stage_scope` | `docs/workflow.md` (stage 6), `docs/decisions.md`, `.claude/skills/panel-build/SKILL.md` |

### Where your values change the output

| Step | What changes |
|------|--------------|
| Before Step 1 | `software: R`: R 4.x with `data.table`, `arrow`, `countrycode`; no Python or Stata block anywhere |
| Step 1 — Diagnostic Scan | `missing_threshold`: variables above 0.10 missing, or with a group difference above 0.10, are listed for a decision by the PI |
| Step 2 — Sample Labels and Flags | `outlier_rule`: no row leaves a table; exclusions exist only as flags and sample labels, each counted |
| Step 3 — Cleaning Pipeline | `missing_policy`: step 3c has no imputation branch. `stage_scope`: step 3d (recoding) prepares the crosswalk files and stops; step 3e builds only definition-free variables |
| Step 4 — Codebook | `reliability_target`: no alpha table; a recomputation check instead. `efa: false`: no factor analysis. `derived_vars_log`: a table of derived variables with formula, inputs and script |
| Step 5 — Cleaning Log | `missing_policy`: the entry states that nothing was imputed and why |

---

## Inputs (preset; ask the PI only for what is specific to the run)

| Input | Value |
|-------|-------|
| `raw_data_path` | Ask: which table or extract. The tables on disk are listed in `data/data-log.md`; the matched dataset is `data/processed/ijv-matched-<run>.csv`, `ijv-parents-<run>.csv`, `ijv-employee-spells-<run>.parquet`, with the career histories in `data/raw/revelio-histories-full-2026-10-09/` |
| `codebook_draft` | `data/codebook.md`, the project's single codebook. Extend it; do not start a second one |
| `key_vars` | Identifiers (`jv_bvdid`, `parent_bvdid`, `rcid`, `user_id`, `position_id`), dates (`start_date`, `end_date`, `formation_year`), countries, `seniority`, the Revelio role codes, `equity_share_current`, `parent_in_revelio`. The outcome and treatment variables do not exist before gate 5 |
| `software` | R |
| `exclusion_flags` | The flag columns of the sample table (`usable`, `core`, `core_main`, `strategic`, `flag_pre_formation_10y`, `flag_holding_vehicle`) and the flags of `code/R/functions/quality_flags.R` |

Read `CLAUDE.md` (rules 1, 2, 5 and 7), `data/codebook.md`,
`data/data-log.md` and the latest `data/interim/quality-flags-<run>.md`
before Step 1. If no quality-flag report exists for the table, run
`/data-collector` Step 4 first.

---

## Step-by-Step Protocol

### Before Step 1 — Check the Software

R is installed at `"C:/Program Files/R/R-4.6.1/bin/Rscript.exe"` on the PI's
computer and is not on the PATH; in the cloud environment the setup script
`code/setup/cloud-setup.sh` installs it. Check that `data.table`, `arrow`
and `countrycode` load. If one is missing, do not stop and do not ask the PI
to install it by hand: offer to install it into the user library, wait for
the PI's approval, and add it to the package list in `README.md`.

Develop on `data/synthetic/` first (`code/R/tests/synthetic_matched.R`). The
synthetic tables have the schema of the real ones and carry every failure
the cleaning has to survive. A session that cannot see the licensed data
(the cloud environment) works on the synthetic tables only and says so.

### Step 1 — Diagnostic Scan

Before changing anything, describe every column of the table. Large tables
are read with the columns needed, not whole.

```r
source("code/R/00_setup.R"); source("code/R/functions/quality_flags.R"); require_pkgs("arrow")
scan_table <- function(d, name) {
  data.table(table = name, column = names(d),
             type = vapply(d, function(x) class(x)[1], ""),
             n_missing = vapply(d, function(x) sum(is.na(x)), numeric(1)),
             n_unique = vapply(d, uniqueN, numeric(1)),
             min = vapply(d, function(x) if (is.character(x) || is.logical(x) || all(is.na(x))) NA_character_ else as.character(min(x, na.rm = TRUE)), ""),
             max = vapply(d, function(x) if (is.character(x) || is.logical(x) || all(is.na(x))) NA_character_ else as.character(max(x, na.rm = TRUE)), "")
  )[, share_missing := round(n_missing / nrow(d), 4)][]
}
d <- as.data.table(arrow::read_parquet("data/synthetic/ijv-employee-spells-synthetic-2026-11-23.parquet"))
s <- scan_table(d, "spells")
s[share_missing > 0.10]                                   # missing_threshold
miss_by <- function(d, var, by) d[, .(rows = .N, share_missing = round(mean(is.na(get(var))), 4)), by = by][order(get(by))]
miss_by(d[, band := year_band(start_date)], "country", "band")   # group difference above 0.10?
```

Report to the PI before going on: rows and columns per table; key
uniqueness; every variable above the threshold with its reason (structural
or not); the group differences; values that look like codes for missing
(`unknown`, empty strings, year 1900 or 9999, the placeholder formation year
1990). Do not scan by shock exposure group; drop `exposure_group` on read
unless the stage is `/shock-options rescore`.

### Step 2 — Sample Labels and Flags, Not Deletions

The template deletes excluded respondents here. In this project no row
leaves a table. Exclusions are columns:

```r
ijv <- fread(f_ijv, colClasses = list(character = "jv_bvdid"), na.strings = "")   # "NA" is Namibia
ijv[, exposure_group := NULL]
ijv_f <- flag_ijvs(ijv, spells, par, grp)          # code/R/functions/quality_flags.R
sp_f  <- flag_positions(spells, ijv)
excl <- rbind(flag_summary(ijv_f, "ijv"), flag_summary(sp_f, "spells"))
excl[, pct := round(100 * share, 1)][]
```

Reuse the existing sample labels (`usable`, `core`, `core_main`,
`strategic`) and flag names; do not invent a second name for the same
thing. Report each criterion with its count and share, in the style of
`data/processed/sample-construction-log-<version>.md`. Which flags define an
analysis sample is the PI's decision at gate 4 and gate 5.

### Step 3 — Systematic Cleaning Pipeline

One script per run in `code/R/wrds/` with the next free number
(`NN_clean_<what>.R`), in the form of the existing scripts: header with
purpose, inputs, outputs and run command; `source("code/R/00_setup.R")`;
fixed `RUN_DATE`; a `check()` that stops on failure; output skipped if it
exists; an argument `synthetic` that runs the same code on
`data/synthetic/`. Apply the steps in this order and count the rows each one
touches.

**3a. One name per concept.** The tables come from different pulls and name
the same thing differently. The cleaned tables use the names on the right;
the map goes into the codebook.

| In the extracts | Cleaned name |
|---|---|
| `function_role_k10` (spells), `job_category` (positions, histories) | `role_k10` |
| `startdate`, `enddate` (education) | `start_date`, `end_date` |
| `rcid_jv` (IJV table), `rcid` of a position at the JV | `rcid_jv` stays in the IJV table; positions keep `rcid` |
| `closdate_year` | `year` |
| `jv_employees_orbis`, `empl` | unchanged; they are different things (latest headcount, annual headcount) |

```r
setnames(sp, "function_role_k10", "role_k10"); setnames(hist, "job_category", "role_k10")
```

**3b. Types.**

```r
num_id <- function(x) { stopifnot(!inherits(x, "integer64")); as.numeric(x) }   # ids: plain numeric in every table
for (v in c("user_id", "position_id", "rcid")) set(sp, j = v, value = num_id(sp[[v]]))
for (v in c("start_date", "end_date")) set(sp, j = v, value = as.IDate(sp[[v]]))
for (v in c("first_reference_year", "last_reference_year")) set(sp, j = v, value = as.integer(sp[[v]]))
# Revelio writes country names; the frame uses ISO 3166 alpha-2. Convert once, through a lookup.
cm <- data.table(country = unique(na.omit(sp$country)))
cm[, country_iso2 := countrycode::countrycode(country, "country.name", "iso2c", warn = FALSE)]
cm[is.na(country_iso2)]                              # names that did not convert: list them, do not guess
sp[cm, on = "country", country_iso2 := i.country_iso2]
```

Check after each conversion that no value was lost: the number of non-missing
values before and after, and the number of distinct ids. Namibia converts to
the string `NA`; test `is.na()` and `== "NA"` separately, and read and write
CSV files with `na.strings = ""`.

**3c. Missing values: nothing is deleted and nothing is imputed.** Each
missing value is given its meaning, as a flag or as a category:

| Missing | Meaning | Carried as |
|---|---|---|
| `end_date` | position still held at the data end (2026-09) | `ongoing`, `flag_open_ended` |
| `start_date` (histories) | undated position; it cannot be placed before or after a hire | `flag_start_missing`; excluded from "prior position" by rule, not by deletion |
| `rcid` (histories) | employer not mapped to a Revelio company | `flag_employer_unmapped` |
| `country` | location not recorded | `flag_country_missing` |
| no prior position at all | history not observed | its own class in every tabulation, never added to independent hires |
| `formation_year` (Capital IQ) | founding year unknown, set to 1990 | `formation_year_missing`; never used as a real year |
| `jv_employees_orbis`, annual `empl` | Orbis reports no headcount | missing; no coverage ratio for that IJV or year |
| `guo_country`, `parent_guo` (Capital IQ parents) | no Orbis owner record | missing; owner-level labels are not available for these parents |

A variable above `missing_threshold` that is not in this table goes to the
PI with the diagnostic of Step 1. The cleaning log records the decision and
the reason.

**3d. Recoding: prepare, do not decide.** There are no scales to reverse.
The recoding this project needs is the mapping of Revelio's `role_k50_v3`
and `seniority` codes to the project's nine functions and four levels, and
that mapping is set at gate 5 (`stage_scope`). Before gate 5 the skill only
writes the crosswalk files with every code that occurs and an empty target
column, `data/function-map.csv` and `data/level-map.csv` (the file names
that `code/R/02_build_panel.R` expects). They hold category labels and no
person-level data, but the labels are Revelio's taxonomy, so ask the PI
before the files are committed. The skill does not fill the target column
and does not use the staffing counts to suggest a mapping. After gate 5
`/panel-build` applies the files.

Recoding that needs no decision is done here: country names to ISO 2, text
booleans to logical, the Orbis consolidation code to `unconsolidated`
(U1, U2) and `consolidated` (C1, C2).

**3e. Derived variables, definition-free only.** Allowed before gate 5,
each with its formula in the codebook (`derived_vars_log`):

```r
sp[ijv, on = "jv_bvdid", jv_country := i.jv_country]; par[ijv, on = "jv_bvdid", jv_country := i.jv_country]
sp[, host_position := country_iso2 == jv_country]                       # position located in the host country
sp[, tenure_days := as.integer(fifelse(ongoing, as.IDate("2026-09-30"), end_date) - start_date)]
par[, host_parent_direct := parent_country == jv_country]               # direct shareholder in the host country
hc[, unconsolidated := conscode %in% c("U1", "U2")]
```

Not built here: hire date and origin class (provisional rule, feasibility
scripts only), the staffing categories, the nine functions and four levels,
cell counts and shares, controls, and anything that involves the shock. A
variable whose definition is an open item in `docs/decisions.md` is not
stored in a cleaned table.

**3f. Range and consistency checks.** Violations are counted and flagged,
not corrected (`outlier_rule`).

```r
rng <- function(d, v, lo, hi) d[!is.na(get(v)) & (get(v) < lo | get(v) > hi), .N]
checks <- data.table(
  check = c("seniority outside 1 to 7", "start year outside 1950 to 2026", "end before start",
            "equity share outside 0 to 100", "equity shares of an IJV sum above 100.5",
            "last reference year before first", "headcount below 0"),
  n = c(rng(sp, "seniority", 1, 7), sp[!is.na(start_date) & (year(start_date) < 1950 | year(start_date) > 2026), .N],
        sp[!is.na(start_date) & !is.na(end_date) & end_date < start_date, .N],
        rng(par, "equity_share_current", 0, 100), par[, .(s = sum(equity_share_current, na.rm = TRUE)), by = jv_bvdid][s > 100.5, .N],
        sp[last_reference_year < first_reference_year, .N], rng(hc, "empl", 0, Inf)))
```

**3g. Repeated records.** Exact copies of a position (`position_id` seen
before) are the one thing removed, with the count logged. The career-history
parts are de-duplicated on read; the parts themselves are never rewritten.

**Write.** Cleaned tables go to `data/processed/<table>-clean-<run>.parquet`
(licensed, gitignored), the synthetic run to
`data/synthetic/<table>-clean-synthetic-<date>.parquet`. Files in
`data/raw/` are never edited, and an existing processed file is not
overwritten: a changed rule gets a new run date or version. End the script
with the final row count of every table and its key count.

### Step 4 — Update the Codebook

The codebook is `data/codebook.md`. It is organized by table and by date of
construction, not as one variable list; keep that form. For each cleaned
table add or update a section:

```markdown
## Cleaned <table> (<YYYY-MM-DD>)

Built by `code/R/wrds/NN_clean_<what>.R [version|synthetic]` from <inputs>.
File `data/processed/<table>-clean-<run>.parquet`, one row per <grain>,
<N> rows, key <columns>.

| Variable | Type | Values or range | Source | Definition |
|---|---|---|---|---|
| `user_id` | numeric id | | Revelio | person |
| `country_iso2` | character | ISO 3166 alpha-2; `NA` is Namibia | derived | see below |

### Renamed
| Extract name | Cleaned name |

### Derived variables
| Variable | Formula | Inputs | Script |
|---|---|---|---|
| `host_position` | `country_iso2 == jv_country` | `country`, `jv_country` | `NN_clean_<what>.R` |

### Missing values
| Variable | Share missing | Meaning | Carried as |

### Flags and sample labels
| Flag | N | Share |

### Checks
Range checks and their counts; the recomputation check and its result.
```

In place of Cronbach's alpha (`reliability_target`): recompute every derived
variable and every count a second way, on a random 300 IJVs, with code that
does not call the pipeline's functions, and require exact agreement. Report
the number of IJVs, rows and variables compared and the number that differ.
A difference stops the run.

Sections of the codebook that describe measures (dependent variables, domain
characteristics, shock, controls) are fixed at gates 3 and 5. Do not rewrite
them here; if a cleaning result makes one of them wrong, propose the change
in the gate file. Definitions marked provisional stay marked.

### Step 5 — Write the Cleaning Log

Append to `data/data-log.md` (tracked; aggregated counts only):

```markdown
## Cleaning Run: {YYYY-MM-DD}
- Input: {paths} ({rows per table})
- Output: {paths} ({rows per table}, key {columns})
- Script: `code/R/wrds/NN_clean_<what>.R` ({run command})
- Frame and sample: {frame version; core_main or subset}

### Transformations Applied
1. Renamed {K} variables: {map}
2. Types: {ids, dates, years}; countries converted for {N} distinct names, {N} not converted: {list}
3. Exact duplicates removed: {N} positions
4. Missing values: none deleted, none imputed, because the prior employer decides the staffing category; {variable: share, carried as}
5. Derived: {variables}; formulas in data/codebook.md
6. Flags and sample labels: {flag: N (share)}
7. Range checks: {check: N}
8. Recomputation on {N} IJVs: {N} values compared, {N} differ

### Analyst Notes
{anything unusual; what was left to gate 5; what the PI has to decide}
```

Then: add the script to the run-order block and the table in `README.md`,
put anything the PI has to decide into the Open section of
`docs/decisions.md`, and put results that bear on a gate into that gate's
file as a proposal. Do not commit unless the PI asks.

---

## Quality Checks

- [ ] Raw files are untouched; cleaned tables are in `data/processed/` under a new name, and no earlier processed file was overwritten
- [ ] Every flag and sample label is logged with N and share; no row was removed except exact copies of a `position_id`, whose number is logged
- [ ] `missing_threshold`: every variable above 0.10 missing, or with a group difference above 0.10, is listed with a reason or sent to the PI
- [ ] `missing_policy`: nothing was deleted or imputed; "history not observed" is its own class; `formation_year_missing` travels with the 1990 placeholder; the log states why
- [ ] `reliability_target`: the recomputation on 300 IJVs agrees exactly, and the codebook has no alpha table
- [ ] Ids are plain numeric in every table, and a join between two tables was counted before and after
- [ ] Country names were converted through a lookup; unconverted names are listed; Namibia (`NA`) survived every read and write
- [ ] `derived_vars_log`: every derived variable has its formula, inputs and script in `data/codebook.md`
- [ ] `outlier_rule`: no value was trimmed, winsorized or corrected; range violations are counted
- [ ] `stage_scope`: no function or level was mapped, no origin class or staffing category was stored, and no variable with an open definition entered a cleaned table
- [ ] The cleaning script runs from top to bottom on `data/synthetic/` and on the real tables, and ends with the row and key counts
- [ ] Nothing was scanned or tabulated by shock exposure group, no gate status was changed, and `git ls-files data/` shows no licensed file

---

## Common Failure Modes to Avoid

- **Treating missing as zero or as "independent"**: a person without a recorded prior employer is not an independent hire.
- **Cleaning by deleting**: dropping undated positions or unmapped employers shrinks the denominator differently across years (the unmapped share falls from about 31 to 10 percent between positions that started before 2000 and after 2020).
- **Silent non-matches**: ids of mixed type, or `NA` read as missing, give an empty join and no error.
- **Deciding a gate through the back door**: a "temporary" function mapping or origin rule stored in a cleaned table becomes the definition. Leave the column out.
- **A second codebook**: a new file next to `data/codebook.md` splits the record.
- **Fixing the data to fit the check**: an implausible value is flagged and counted. The PI decides what it means.

---

## Extending the Template (Exercise 2C Part 2)

Adding a field takes three edits, and all three matter:

1. Add the key to the **skill-specific block**.
2. Add a row to **Where your values change the output**, naming the step it affects.
3. Add a line to **Quality Checks**, so the new behavior is verified, not assumed.

Three fields were added this way on 2026-11-23: `derived_vars_log` (Step 3e
and Step 4), `outlier_rule` (Step 2 and Step 3f) and `stage_scope` (Steps 3d
and 3e). They have not been tested yet. Test each twice, once set and once
as a placeholder; if the output is the same, the skill is ignoring the field.

Further candidates: `measurement_invariance` does not apply (no composites);
`id_policy` (which person and company identifiers may appear in a cleaned
table at all, if the licences or a data-sharing plan restrict them);
`time_grid` (the reference date of 30 June and the first and last panel
year, once gate 5 fixes them).
