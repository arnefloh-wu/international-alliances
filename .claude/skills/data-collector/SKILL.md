---
name: data-collector
description: >
  Use this skill to plan, run and document a data extraction for the IJV
  staffing study. Triggers: "collect data for my study", "pull data from
  WRDS", "extract from Orbis / Revelio / BoardEx / Capital IQ", "add a data
  source", "download the shock or country-dyad data", "generate synthetic
  data", "build quality flags", "update the data log", or any request to
  acquire secondary data for the project. Not for building the panel
  (`/panel-build`) or the measures.
---

# Data Collection & Quality Assurance

Customized on 2026-11-23 from the seminar template `2B-data-collector.md` for
the IJV staffing study (Floh, Mohr, Thanyi; target JIBS).

## What This Skill Does

Guides one data extraction from the decision to pull to the documented
result: checking that the source is licensed and what it holds, writing a
cached and resumable R extraction script, generating a synthetic dataset
with the same schema so that the downstream code can be built and tested
before the real pull, attaching quality flags, and recording the event in a
data log. Outputs: untouched exports in `data/raw/`, a synthetic twin in
`data/synthetic/`, flags in the derived tables, and an entry in
`data/data-log.md`.

The template covers surveys, scraping and APIs. This study collects no new
primary data: everything is archival, and almost all of it comes from WRDS by
SQL. The survey and scraping branches are therefore removed, and the API
branch is rewritten for a database connection in R.

Place in the workflow (`docs/workflow.md`): the skill belongs to the
`data-engineer` agent and serves stages 4 and 6 and the shock data of stage
5. It does not build the panel or any measure, does not approve a gate, and
does not choose the focal shock.

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

# ---------- SKILL-SPECIFIC — data-collector ----------
collection_mode:       archival: SQL extraction from WRDS (Orbis, Capital IQ, Revelio, BoardEx); file downloads for external deal lists and country-dyad shock data; no survey, no scraping, no new primary data
platform:              n/a (no survey or panel platform); WRDS PostgreSQL through DBI and RPostgres
irb_protocol:          not required (PI, 2026-11-23, docs/decisions.md); licence terms and interview consent terms govern data handling
power_analysis:        false
longitudinal:          true

# ---------- EXTENSIONS (three-edit pattern, see the last section) ----------
sampling_frame:        the IJV frame rules in data/codebook.md (ownership bands, parent types, intra-group exclusion, routes); every extraction states which frame version and sample (core, core_main, strategic) it covers and what the frame cannot contain
pull_approval:         a new pull of licensed data needs the PI's go-ahead, recorded in docs/decisions.md with the date before the script runs
```

Notes on three values:

- `irb_protocol` records the PI's answer that no ethics approval is needed on
  file. It does not settle the consent terms of the manager interviews, which
  are an open item in `docs/decisions.md` (2026-10-02).
- `power_analysis: false` because the sample is every IJV that can be matched,
  not a recruited sample. What replaces it is a count of the cells a
  hypothesis needs (Step 1). A minimum detectable effect, if the PI wants
  one, belongs to the pre-analysis plan at gate 5.
- `longitudinal: true`: the unit is the IJV by function (or level) by year,
  built from positions with start and end dates.

Where each value comes from:

| Value | Source in this repository |
|-------|---------------------------|
| Core block | `.claude/skills/research-ideation/SKILL.md` |
| `collection_mode`, `platform` | `README.md` ("Run it locally"), `code/R/wrds/`, `docs/data-acquisition-guide.md` |
| `irb_protocol` | `docs/decisions.md`, 2026-11-23 |
| `longitudinal` | design paragraph in `CLAUDE.md`, `data/codebook.md` |
| `sampling_frame` | `data/codebook.md`, `data/processed/sample-construction-log-*.md` |
| `pull_approval` | practice in `docs/decisions.md` (every extraction so far ran on a PI instruction) |

### Where your values change the output

| Step | What changes |
|------|--------------|
| Step 1 — Strategy Selection | `collection_mode: archival`: no method comparison; the step checks the source inventory and the licence. `power_analysis: false`: no a priori N, a cell-support count instead. `sampling_frame`: the step states the frame version, the sample and its coverage limits. `pull_approval`: the step stops until the PI's go-ahead is in `docs/decisions.md` |
| Step 2 — Extraction | `platform`: an R script on WRDS PostgreSQL, credentials in `~/.Renviron`; Steps 2A (survey) and 2B (scraping) do not exist here |
| Step 3 — Synthetic Data | The schema comes from `data/interim/wrds-catalog.csv` and `data/codebook.md`; `longitudinal: true` makes the synthetic data a panel of entities, people and dated positions |
| Step 4 — Quality Flags | `longitudinal: true` adds key, date and coverage checks over years |
| Step 5 — Data log | `irb_protocol`: no consent text; the entry records licence and handling restrictions instead |

---

## Inputs (preset; ask the PI only for what is specific to the pull)

| Input | Value |
|-------|-------|
| `research_question` | `docs/research-brief.md` (proposal until the PI decides gate 4) |
| `data_type` | Archival |
| `target_population` | IJVs in the frame of `data/codebook.md`; analysis sample `core_main` (7,460 IJVs on 2026-10-09; re-read `data/processed/dataset-manifest-*.md` before quoting a count) |
| `key_variables` | Named per pull. Existing tables and their columns are in `data/codebook.md` |
| `sample_size` | Not set in advance; see `power_analysis` |
| `data_source` | Ask: which library and tables, for which entities or people, which columns, and which feasibility question or stage the pull serves |

Read `CLAUDE.md` (rules 1, 2, 5 and 7), `data/README.md`, `data/codebook.md`
and `README.md` ("Run it locally") before Step 1.

---

## Step-by-Step Protocol

### Step 1 — Source, Licence and Scope

1. Find the source in the inventory. Before promising a pull, check that the
   library is readable (`data/interim/wrds-libraries.csv`) and that the
   columns exist (`data/interim/wrds-catalog.csv`). Do not write SQL against
   a column that is not in the catalog.

| Source | Library | Gives | Status |
|--------|---------|-------|--------|
| Orbis ownership and financials | `bvd_orbis_large`, `bvd_orbis_medium`, `bvd_orbis_small` | IJV frame, parents, ultimate owners, headcounts | licensed, used |
| Capital IQ ownership | `ciq` | second frame | licensed, used |
| Revelio Labs | `revelio` | companies, positions, career histories, education | licensed, used |
| BoardEx | `boardex` | senior executives and directors | licensed, used for a coverage check |
| External deal lists, manual matches | files in `data/raw/external/`, `data/raw/manual/` | additional IJVs, match decisions | formats in `docs/data-acquisition-guide.md` |
| Country-dyad and shock data | downloads, `data/raw/dyad-<measure>-<date>.csv` | exposure to the focal change | after the shock decision (gates 5a and 5) |
| Manager interviews | `data/interviews/` | qualitative phase | existing; not collected by this skill |

   Sources that are not licensed (SDC joint ventures, Orbis M&A, fDi Markets)
   are listed in `reviews/gate-4-pilot.md`. For those, write what the PI has
   to request, following `docs/data-acquisition-guide.md`, and stop.
2. `sampling_frame`: state the frame version, the sample the pull covers
   (`core`, `core_main`, `strategic`, or a subset with its rule), and what
   the frame leaves out (dissolved and bought-out IJVs, Capital IQ entities
   without a BvD id, parents without a Revelio entity).
3. Cell support in place of a power analysis: say which cells the pull is
   meant to fill and how many IJVs, people or years it can reach at most.
   Never count by shock exposure group to decide what to pull.
4. Minimum columns. Pull identifiers, dates, countries and the variables the
   stage needs. No personal names, profile links or free text about people.
5. `pull_approval`: if the pull brings new licensed data and the PI's
   go-ahead is not in `docs/decisions.md`, ask, record the answer with the
   date, and only then go on.

### Step 2 — Write and Run the Extraction Script

One script per extraction, in `code/R/wrds/`, with the next free number. It
follows the existing scripts (`03_wrds_full_sample.R`,
`10_boardex_coverage.R`):

```r
# NN_wrds_<what>.R
# Purpose, feasibility question or stage served, inputs, outputs, how to run.
source("code/R/00_setup.R")
require_pkgs(c("arrow", "DBI", "RPostgres"))
RUN_DATE <- "YYYY-MM-DD"                      # fixed in the script; reruns reuse the files
f_out <- file.path(paths$raw, sprintf("<source>-<what>-%s.parquet", RUN_DATE))
f_log <- file.path(paths$interim, sprintf("wrds-<what>-log-%s.md", RUN_DATE))
log_line <- function(...) {
  msg <- sprintf(...); message(format(Sys.time(), "%H:%M:%S"), " ", msg)
  cat("- ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " ", msg, "\n", file = f_log, append = TRUE, sep = "")
}

if (!file.exists(f_out)) {                    # cached: a finished stage is skipped
  con <- DBI::dbConnect(RPostgres::Postgres(), host = "wrds-pgdata.wharton.upenn.edu", port = 9737,
                        dbname = "wrds", sslmode = "require",
                        user = Sys.getenv("WRDS_USERNAME"), password = Sys.getenv("WRDS_PASSWORD"))
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  ids <- unique(ids[!is.na(ids)])
  parts <- lapply(split(ids, ceiling(seq_along(ids) / 2000L)), function(x)
    data.table::as.data.table(DBI::dbGetQuery(con, sprintf(
      "SELECT <columns> FROM <library>.<table> WHERE <id> IN (%s)",
      paste(sprintf("'%s'", gsub("'", "''", x)), collapse = ", ")))))
  out <- data.table::rbindlist(parts, fill = TRUE)
  arrow::write_parquet(out, f_out)
  log_line("<what>: %d rows for %d ids", nrow(out), length(ids))
}
```

Rules that the earlier runs taught:

- Credentials come from `~/.Renviron` (`WRDS_USERNAME`, `WRDS_PASSWORD`).
  Never write them in a script, a log or the chat.
- WRDS is reachable from the PI's computer only, not from the cloud
  environment. If the session cannot connect, write the script and the
  run command and stop.
- Large pulls (one row per person or position) are written as numbered
  parquet parts in a folder under `data/raw/`, in chunks of about 5,000 ids.
  The parts are the only record of what is already pulled, so a rerun skips
  those ids and nobody deletes single parts.
- Read ids as character or plain numeric, never mixed: large Revelio ids come
  back as integer64 from `fread` and as double from arrow, and a mixed
  comparison matches nothing without an error.
- Read country codes with `na.strings = ""`. The code `NA` is Namibia.
- A table can hold several rows per entity and year (Orbis industry codes,
  consolidated and unconsolidated accounts). Look at the values that come
  back before defining a filter, and order the rows before taking one.
- Files in `data/raw/` are written once and never edited. A corrected pull
  gets a new date or version, not an overwrite.
- A pull that takes more than about two minutes runs in the background. Do
  not edit a script while it runs, and do not run two scripts that write the
  same files.
- Add the script to the run-order block and the table in `README.md`.

File downloads (external deal lists, country-dyad data): save the file
untouched under `data/raw/` with the source and the download date in the
name, and record the URL, the version or vintage, and the licence in the data
log. No scraping. If a source offers no download, describe what the PI has to
request.

### Step 3 — Generate Synthetic Data

Before a long or new pull, generate a synthetic dataset with the schema the
real pull will have, so that the flags and the downstream script can be
written and tested first. It also lets the code run in sessions that cannot
reach WRDS.

1. **Schema**: column names and types from `data/interim/wrds-catalog.csv`
   for a new table, from `data/codebook.md` for an existing one.
2. **Size**: about 200 IJVs with their parents, and the people and positions
   that go with them. Enough for every flag to fire, small enough to run in
   seconds.
3. **Simulated, never derived**: draw every value from a distribution. Do not
   sample, shuffle or perturb real rows; licensed data stay licensed after
   noise is added. Ids are made up and carry a prefix (`SYN`).
4. **Seed the failures that Step 4 has to catch**:
   repeated `position_id`; missing start dates; open-ended positions;
   employer not mapped (`rcid` missing); host country `NA` (Namibia); a
   position that starts before the formation year; a person at two sample
   IJVs; an entity that belongs to two parents' families; a parent's own
   entity matched as the IJV; a Revelio headcount more than 20 times the
   Orbis headcount; an IJV with fewer than three observed years; two account
   rows for one entity and year.
5. **Mark every row** with `synthetic = TRUE`.
6. **Save to `data/synthetic/`**, never to `data/raw/`, `data/interim/` or
   `data/processed/`. The generator is `code/R/tests/synthetic_<source>.R`
   with a fixed seed; the file is
   `data/synthetic/<source>-synthetic-<YYYY-MM-DD>.parquet`. `data/synthetic/`
   is not gitignored, which is intended: simulated data may be committed.

```r
# code/R/tests/synthetic_<source>.R
source("code/R/00_setup.R"); require_pkgs("arrow")
set.seed(20261123)
n_jv <- 200L
jv <- data.table(jv_bvdid = sprintf("SYN%05d", seq_len(n_jv)),
                 jv_country = sample(c("DE", "IN", "CN", "BR", "NA"), n_jv, replace = TRUE),
                 formation_year = sample(1995:2020, n_jv, replace = TRUE))
pos <- jv[, .(user_id = sample(1e6, 40L)), by = .(jv_bvdid, formation_year)]
pos[, position_id := .I]
pos[, start_date := as.IDate(sprintf("%d-01-01", formation_year)) + sample(-1500:6000, .N, replace = TRUE)]
pos[, end_date := start_date + sample(200:4000, .N, replace = TRUE)]
# --- seeded failures: one line each, listed in the data log ---
pos[sample(.N, 15L), start_date := NA]                      # missing start dates
pos[sample(.N, 60L), end_date := NA]                        # open-ended positions
pos <- rbind(pos, pos[sample(.N, 10L)])                     # repeated position_id
pos[, synthetic := TRUE]
dir.create("data/synthetic", showWarnings = FALSE)
arrow::write_parquet(pos, sprintf("data/synthetic/<source>-synthetic-%s.parquet", Sys.Date()))
```

7. Record the generation in `data/data-log.md` under **Synthetic Data**,
   apart from the real collection events.

### Step 4 — Build Data Quality Flags

Flags are columns. Raw files are never filtered, and a derived table keeps
every row with its flags, so each exclusion can be counted and reversed. Run
the flag code on `data/synthetic/` first and confirm that each seeded failure
is caught, then run it unchanged on the real pull.

Flags the project already uses (definitions in `data/codebook.md`); reuse the
names, do not reinvent them:

| Flag or field | Threat |
|---------------|--------|
| `tier`, `match_method`, `match_score`, `manual_by` | wrong entity match |
| `flag_size_mismatch` | Revelio entity far larger than the Orbis company |
| `flag_pre_formation_10y` | incorporation date does not mark the formation |
| `flag_holding_vehicle` | holding entity matched to the operating company |
| `formation_year_missing` | founding year imputed (Capital IQ) |
| `usable`, `core`, `core_main`, `strategic` | sample definitions built from the flags |
| `parent_in_revelio` | parent cannot be observed as a prior employer |

For a new pull, add at least one flag per threat named in Step 1, and for
this panel always check:

```r
check <- function(cond, msg) { cat(if (isTRUE(cond)) "OK   " else "FAIL ", msg, "\n"); if (!isTRUE(cond)) stop(msg, call. = FALSE) }
check(!anyDuplicated(d$position_id), "no repeated position")           # keys
check(all(d$jv_bvdid %in% ijv$jv_bvdid), "no stray entity")
d[, flag_start_missing := is.na(start_date)]                             # dates
d[, flag_end_before_start := !is.na(end_date) & end_date < start_date]
d[, flag_pre_formation := year(start_date) < formation_year]
d[, flag_employer_unmapped := is.na(rcid)]                               # completeness
d[, flag_country_missing := is.na(country)]
yrs <- d[, .(n_years = uniqueN(year)), by = jv_bvdid]                    # coverage over time
yrs[, flag_short_panel := n_years < const$min_years]
flag_cols <- grep("^flag_", names(d), value = TRUE)
print(d[, lapply(.SD, mean), .SDcols = flag_cols])                       # report every rate
```

Report the count and the share for every flag and the rows left at each
step, in the style of `data/processed/sample-construction-log-*.md`. There is
no fixed ceiling for an acceptable exclusion rate in archival matching; a
rate that differs strongly by host region, source or year is the warning
sign, and it is reported, not hidden. Do not tabulate flags or coverage by
shock exposure group unless the stage is `/shock-options rescore`.

### Step 5 — Update the Data Log

Append to `data/data-log.md` (tracked in Git; aggregated counts only, no row
of licensed data). On the first run create the file and add one pointer entry
per earlier extraction, taken from the logs in `data/interim/wrds-*-log-*.md`
and from `data/processed/dataset-manifest-*.md`; do not retype counts that
those files do not state.

```markdown
## Collection Event: {YYYY-MM-DD}
- Purpose: {feasibility question or stage}
- PI go-ahead: {date and wording, as in docs/decisions.md}
- Source: {WRDS library and tables, or URL and vintage}
- Script: {code/R/wrds/NN_...R} ({run command})
- Frame and sample: {frame version; core_main / strategic / subset rule}
- Columns pulled: {list}
- Output: {path under data/raw/} ({rows}, {entities or people})
- Flags: {flag: count (share)}, ...
- Handling: licensed, local only, gitignored; {any further restriction}
- Collector: {name or agent}
- Notes: {anything unusual, including what the pull could not deliver}

## Synthetic Data: {YYYY-MM-DD}
- File: data/synthetic/{file}
- Generator: code/R/tests/synthetic_{source}.R (seed {seed})
- Rows: {N}
- Schema source: {catalog table or codebook section}
- Failure modes seeded: {list}
```

Then: add the new files and variables to `data/codebook.md`, the script to
`README.md`, and anything the PI has to decide to the Open section of
`docs/decisions.md`. Results that bear on a gate go into that gate's file as
a proposal; the status line is the PI's. Do not commit unless the PI asks.

---

## Quality Checks

- [ ] Raw data is saved without modification to `data/raw/`, with the source and the run date in the file name
- [ ] Synthetic data is saved to `data/synthetic/`, carries `synthetic = TRUE`, and was simulated, not derived from real rows
- [ ] The synthetic schema matches the real table column for column
- [ ] Every seeded failure mode is caught by a flag before the real pull is flagged
- [ ] `data/data-log.md` has an entry for the event, with synthetic data logged apart from real collection events
- [ ] At least one flag per data quality threat named in Step 1; flag counts and shares are reported, and no row was dropped from a raw file
- [ ] `longitudinal`: keys are unique, dates are checked, and coverage over years is reported per IJV
- [ ] WRDS credentials are read from `~/.Renviron` and appear in no script, log or message
- [ ] `irb_protocol`: the log entry states the handling restriction; no personal names or profile links were pulled
- [ ] `sampling_frame`: the entry names the frame version and sample and says what the frame cannot contain
- [ ] `pull_approval`: the PI's go-ahead is in `docs/decisions.md` with a date earlier than the pull
- [ ] The script reruns top to bottom from `code/R/00_setup.R`, skips finished stages, and is listed in `README.md`
- [ ] Nothing was counted by shock exposure group, no gate status was changed, and no licensed file is tracked by Git (`git ls-files data/`)

---

## Common Failure Modes to Avoid

- **Guessing a column or a coding**: SQL written from memory of how Orbis or Revelio "usually" look. Read the catalog, then look at the values.
- **Silent non-matches**: mixed id types, or `NA` read as missing, give an empty join and no error. Check match counts after every merge.
- **Overwriting a raw file** to fix it. Write a new version.
- **Synthetic data made from real rows**. That is licensed data with noise.
- **Reading a residual as a measure**: staff missing from Revelio are not parent-origin staff (feasibility question Q4).
- **Pulling more than the question needs**, in columns or in people.

---

## Extending the Template (Exercise 2B Part 2)

Adding a field takes three edits, and all three matter:

1. Add the key to the **skill-specific block**.
2. Add a row to **Where your values change the output**, naming the step it affects.
3. Add a line to **Quality Checks**, so the new behavior is verified, not assumed.

Two fields were added this way on 2026-11-23: `sampling_frame` (Step 1, item
2, and the log entry) and `pull_approval` (Step 1, item 5). They have not
been tested yet. Test each twice, once set and once as a placeholder; if the
output is the same, the skill is ignoring the field.

Further candidates: `pilot_n` (a pilot draw before a full pull, as in the
100-IJV pilot of stage 4), `retention` (how long licensed extracts may be
kept after the project ends; the licences decide), `storage_sync` (whether
`data/` may sync to Dropbox; `README.md` asks the PI to check the licences).
