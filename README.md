# Differentiated International Integration in International Joint Ventures

Empirical manuscript project (target: *Journal of International Business
Studies*), run as an agent-based research workflow in Claude Code.

- Research idea: `initial-research-idea.md`
- Research question and current statement of the idea (working hypotheses
  since gate 4; the final set is fixed at gate 5): `docs/research-brief.md`
- Conventions for agents and the folder map: `CLAUDE.md`
- Workflow stages, agents and gates: `docs/workflow.md`
- Theory hierarchy and how each tier enters the paper: `docs/theory-framework.md`
- Decision log and open questions: `docs/decisions.md`

## Running the workflow

From a Claude Code session in this repository:

```
/research-workflow status          # where things stand
/research-workflow next            # launch the next unblocked stage
/lit-search                        # Stage 1: search strings, Consensus runs, screening
/lit-synthesis                     # Stage 2 (after gate 1)
/qual-recode                       # Stage 3 (needs transcripts in data/interviews/)
/pilot-feasibility                 # Stage 4: 100-IJV Orbis-Revelio pilot
/shock-options scan                # Stage 5a: compare candidate shocks (no prerequisites)
/shock-options rescore             # Stage 5: re-score with pilot exposure counts (after G5a, G4)
/research-workflow hypotheses      # Stage 5: final shock, hypotheses, pre-analysis plan
/panel-build                       # Stage 6 (after gate 5)
/estimate                          # Stage 7 (after gate 6)
/write-section introduction        # Stage 8, one section per run
/references                        # verify bibliography, sync Zotero
/internal-review full              # Stage 10
```

Stages 1, 3, 4 and 5a have no prerequisites and can start now. Stage 1 needs
nothing from you. Stage 3 needs the interview transcripts and the consent
notes in `data/interviews/`. Stage 4 needs the Orbis and Revelio pilot
exports described in `data/raw/extraction-spec-*.md`.

Four skills sit outside the stage pipeline and have no gate:
`/research-ideation` drafts or revises `docs/research-brief.md`,
`/research-organizer` checks the folder structure, the naming conventions,
this README and `CLAUDE.md`, `/data-collector` plans, runs and logs a
data extraction (log in `data/data-log.md`, simulated test data in
`data/synthetic/`), and `/data-wrangler` cleans and types the extracted
tables and keeps `data/codebook.md` (no function mapping and no measures
before gate 5; those belong to `/panel-build`). `/statistical-analyst` is
the method guide for the estimation part of the pre-analysis plan and for
`/estimate`; before gate 6 it works on simulated panels only.

## Local tooling

- R 4.x with the packages listed in `code/R/00_setup.R`. In the cloud environment, paste `code/setup/cloud-setup.sh` into the environment's Setup script so every session has R. Function checks: `Rscript code/R/tests/test-functions.R`.
- Quarto for rendering reports and the manuscript to Word.
- Zotero with Better BibTeX; API credentials in `.Renviron` (gitignored),
  see `.claude/skills/references/SKILL.md`.

## Run it locally (Windows, WRDS)

The WRDS scripts in `code/R/wrds/` and the matching script run on your own
computer, not in the Claude cloud environment, whose proxy blocks database
connections. All commands start from the repository root. They use plain
`Rscript`. If R's `bin` folder is not on your PATH, call it by its full path
instead, for example `"C:/Program Files/R/R-4.6.1/bin/Rscript.exe"`.

### One-time setup

1. Install R 4.6.1 (or another 4.x), Quarto and Git.
2. Install the R packages (the core ones are installed automatically by
   `code/R/00_setup.R`; the WRDS scripts stop with a message if one of these
   is missing):

   ```r
   install.packages(c("data.table", "stringdist", "stringi", "lubridate", "ggplot2", "knitr",
                      "DBI", "RPostgres", "countrycode", "arrow", "R.utils",
                      "fixest", "did", "didimputation", "HonestDiD", "modelsummary", "quarto", "renv"))
   ```

3. Put your WRDS login in `~/.Renviron` (your home folder, outside the
   repository, never committed):

   ```
   WRDS_USERNAME=your_wrds_username
   WRDS_PASSWORD=your_wrds_password
   ```

   Restart R after editing. On Windows, run `path.expand("~")` in R to see
   which folder `~` means; the file belongs there. Your WRDS account needs read access to the Orbis
   (`bvd_orbis_*`), Revelio (`revelio*`), Capital IQ (`ciq*`) and BoardEx
   (`boardex`) libraries.
4. Know where the data goes. `data/raw`, `data/interim`, `data/processed` and
   `data/interviews` are gitignored. If the repository sits in Dropbox, the
   licensed exports sync to Dropbox too. Check that your Orbis, Revelio and
   Capital IQ licences allow that, or exclude `data` from sync, or point
   `IA_DATA_DIR` at another folder in `~/.Renviron`.

### Run order

```
Rscript code/R/wrds/01_wrds_discover.R                 # once: lists the readable Orbis and Revelio tables
Rscript code/R/wrds/02_wrds_pilot_extract.R main       # base IJV frame, pilot draw, Revelio candidates and positions
Rscript code/R/01_pilot_matching.R main                # pilot matching and coverage (argument: main or large)
Rscript code/R/wrds/05_wrds_frame_v2.R with_dom with_small with_prior   # expanded frame v3 (no arguments: frame v2)
Rscript code/R/wrds/03_wrds_full_sample.R v3           # full-frame matching, sample table, career histories
Rscript code/R/wrds/07_manual_match_list.R v3          # worklist for manual matching
Rscript code/R/wrds/08_triage_manual_candidates.R      # optional: agent triage of worklist rows (then rerun step 03)
Rscript code/R/wrds/09_build_matched_dataset.R v3      # matched dataset: IJV, parent and employee-spell tables
Rscript code/R/wrds/10_boardex_coverage.R v3           # BoardEx coverage of the matched IJVs
Rscript code/R/wrds/12_wrds_headcount_education.R v3   # optional: annual Orbis headcounts and Revelio education records (about two hours)
Rscript code/R/wrds/11_staffing_tabulations.R v3       # feasibility counts for the staffing frame (no WRDS connection; uses step 12 if present)
Rscript code/R/tests/synthetic_matched.R               # simulated twin of the matched dataset in data/synthetic/ (no data needed)
Rscript code/R/wrds/13_quality_flags.R synthetic       # quality flags on the simulated tables: every seeded failure must be caught
Rscript code/R/wrds/13_quality_flags.R v3              # the same flags on the real matched dataset (no WRDS connection)
Rscript code/R/tests/synthetic_onet.R                  # simulated twin of the O*NET extracts (needs the synthetic spells)
Rscript code/R/wrds/14_wrds_onet_code.R v3             # Revelio O*NET codes for the JV positions and the role lookup (one to two hours)
Rscript code/R/tests/synthetic_parent_industry.R      # simulated twin of the parent industry pull and a test of the holding rule
Rscript code/R/wrds/15_wrds_parent_industry.R         # Orbis industry codes of the parents and owners; runs 16 if needed; resolves rule v2 (about two minutes)
Rscript code/R/wrds/16_wrds_ciq_parent_industry.R     # Capital IQ industry tree for the Capital IQ parents (called by 15 if missing)
Rscript code/R/07_contingency_scores.R                 # contingency scores and domains from O*NET alone (no staffing data)
Rscript code/R/08_feasibility_reg_cells.R              # stage 5 feasibility count for H4: REG cells by exposure group, structural counts only
Rscript code/R/09_audit_parent_family_sample.R         # audit worksheet: 100 of the IJVs filed in a parent's Revelio family (seed 20261125; never overwrites a coded sheet)
Rscript code/R/10_rater_sheet.R                        # workbooks for the outside raters: 50 role_k50 groups with O*NET titles (taxonomy only, no staffing data)
Rscript code/R/wrds/06_ingest_external_jvs.R           # optional: add external deal lists (frame v4)
Rscript code/R/wrds/03_wrds_full_sample.R v4           # optional: match the external additions
Rscript code/R/tests/test-functions.R                  # function checks, all should print PASS
```

| Script | Needs | Main outputs |
|---|---|---|
| `02_wrds_pilot_extract.R [main\|large]` | WRDS | `data/interim/wrds-ijv-frame-*.csv`, `data/raw/orbis-pilot-*.csv`, `revelio-*` exports |
| `01_pilot_matching.R [main\|large]` | step 02 | `data/interim/pilot-*` match logs, `pilot-summary.rds` |
| `05_wrds_frame_v2.R [with_dom] [with_small] [with_prior]` | WRDS | `data/interim/wrds-ijv-frame-v2-*.csv` or `-v3-*.csv` |
| `03_wrds_full_sample.R [v1\|v2\|v3\|v4]` | step 02 for v1, step 05 for v2 and v3, step 06 for v4 | `data/processed/sample-ijv-*.csv`, `sample-construction-log*.md`, career-history parts |
| `07_manual_match_list.R [version]` | step 03 | `data/interim/manual-match-list-*.csv` |
| `08_triage_manual_candidates.R` | step 07 | `data/raw/manual/manual-matches-claude-*.csv` (gitignored), `data/interim/manual-triage-claude-*.csv` |
| `09_build_matched_dataset.R [version]` | step 03 (and the history parts it downloads) | `data/processed/ijv-matched-*.csv`, `ijv-parents-*.csv`, `ijv-employee-spells-*.parquet`, `dataset-manifest-*.md` |
| `10_boardex_coverage.R [version]` | step 09, WRDS | `data/interim/boardex-coverage-*.csv`, `boardex-coverage-summary-*.md`, BoardEx pulls cached in `data/raw/` |
| `12_wrds_headcount_education.R [version] [orbis] [education]` | step 09, WRDS | `data/raw/orbis-jv-headcounts-*.parquet`, `data/raw/revelio-education-full-*/` (parquet parts), `data/interim/wrds-headcount-education-log-*.md` |
| `11_staffing_tabulations.R [version]` | steps 09 and 10; step 12 for the entrant and annual-headcount tables | `data/interim/staffing-tabulations-*.md` and the csv tables in the folder of the same name |
| `tests/synthetic_matched.R` | nothing | `data/synthetic/<table>-synthetic-*.parquet`, `seeded-failures-synthetic-*.csv` (simulated, tracked in Git) |
| `13_quality_flags.R [version\|synthetic]` | step 09 (steps 03 and 12 for histories and headcounts), or the synthetic tables | `data/interim/quality-flags-*.md`, or `data/synthetic/quality-flags-synthetic-*.md` |
| `tests/synthetic_onet.R` | `tests/synthetic_matched.R` | `data/synthetic/revelio-role-lookup-v3-synthetic-*.parquet`, `revelio-jv-positions-onet-synthetic-*.parquet` |
| `14_wrds_onet_code.R [version] [lookup] [positions] [coverage]` | step 09, WRDS | `data/raw/revelio-role-lookup-v3-*.parquet`, `data/raw/revelio-jv-positions-onet-*/` (parquet parts), `data/interim/wrds-onet-log-*.md` |
| `tests/synthetic_parent_industry.R` | none | `data/synthetic/orbis-parent-industry-synthetic-*.parquet`, `ijv-parents-guo-synthetic-*.parquet` |
| `15_wrds_parent_industry.R [pull] [secondary] [resolve]` | step 09, WRDS; step 16; `data/raw/external/census-naics-concordances-*/` | `data/raw/orbis-parent-industry-*.parquet`, `orbis-parent-industry-core-secondary-*.parquet`, `data/interim/parent-industry-v2-*.csv`, `data/interim/wrds-parent-industry-log-*.md` |
| `16_wrds_ciq_parent_industry.R` | step 09, WRDS | `data/raw/ciq-parent-industry-tree-*.parquet`, `ciq-industry-subtype-*.parquet`, `ciq-industry-to-sic-*.parquet` |
| `07_contingency_scores.R` | step 14 (lookup) and the O\*NET 31.0 download | `data/processed/contingency-scores-occupation-*.csv`, `contingency-scores-domain-*.csv`, `data/interim/contingency-scores-*.md` |
| `08_feasibility_reg_cells.R` | steps 07 and 14, `06_shock_exposure.R` | `data/interim/feasibility-reg-cells-*.md` (aggregate counts) |
| `09_audit_parent_family_sample.R [overwrite]` | steps 03 and 09 | `data/interim/audit-parent-family-worksheet-*.xlsx` and `.csv` (licensed, gitignored); coding guide `docs/coauthor-notes/audit-parent-family-guide-*.qmd` |
| `10_rater_sheet.R` | step 14 (lookup) | `data/interim/rater-sheet-*.xlsx`, `rater-sheet-onet-only-*.xlsx` (gitignored; Revelio group labels in the first) |
| `06_ingest_external_jvs.R` | frame v3 and files in `data/raw/external/` | `data/interim/wrds-ijv-frame-v4-*.csv` |
| `04_wrds_route_sizing.R` | WRDS | `data/interim/route-sizing-*.csv` (a one-off sizing exercise) |

The sample table has one row per IJV. The columns to start with are `tier`
(how it was matched), `usable`, `core` (upper bound), `core_main`
(recommended analysis sample), `strategic`, `route`, `source` and
`admitted_by`. Definitions are in `data/codebook.md`.

`code/R/02_build_panel.R` to `05_robustness.R` are the scripts of stages 6
and 7. They are run by `/panel-build` and `/estimate` after gates 5 and 6.
`04_estimate.R` already holds the models of the draft hypotheses (functions in
`code/R/functions/estimation.R`) and runs now only on simulated panels; without
the argument `synthetic` it stops until `reviews/gate-6-panel.md` is approved:

```
Rscript code/R/tests/synthetic_panel.R                 # simulated IJV x function x year and x level x year panels with planted effects
Rscript code/R/04_estimate.R synthetic                 # all models on the simulated panel, with a check against the planted effects
Rscript code/R/tests/check_estimate_recovery.R 500     # Monte Carlo: power, false-positive rates and bias over 500 draws (about 13 minutes)
```

`02_build_panel.R`, `03_measures.R` and `05_robustness.R` are still skeletons.

### How the scripts behave

- Every stage writes its result once and is skipped while that file exists, so
  an interrupted run resumes where it stopped. Delete a stage's output file to
  rebuild it.
- The scripts carry fixed run dates (2026-10-08 for the pilot draw, 2026-10-09
  for the full runs) in their file names. Re-running reuses those files. To
  start a fresh dated run, change the date constants at the top of the scripts.
- Slow steps, in rough numbers for frame v3: the Revelio name search about 15
  minutes, the career-history download about an hour for 2.5 million users.
  Career histories are stored as parquet parts in
  `data/raw/revelio-histories-full-2026-10-09/`; the parts are the record of
  which users are already downloaded, so never delete a few of them.
- Do not edit a script while it is running, and do not run two scripts that
  write the same files at once.
- If a WRDS query hangs (no output for a long time and no CPU use), stop the R
  process and rerun; finished stages are cached. A message `permission denied
  for schema ...` means the library is not part of your subscription.

### Reports

```
QUARTO_R="C:/Program Files/R/R-4.6.1/bin/x64/R.exe" quarto render code/quarto/pilot-feasibility-report.qmd -P pilot:main
```

Use `-P pilot:large` for the second pilot. In our runs Quarto wrote the output
into the repository root; move the `.html` and `.docx` files into
`code/quarto/`. They are not committed.

### Bringing in data from outside WRDS

Manual match decisions go in `data/raw/manual/` and external deal lists in
`data/raw/external/`. Formats, sources and access steps are in
`docs/data-acquisition-guide.md`.

## Data

- Sources: Orbis and Capital IQ ownership data, Revelio Labs workforce data
  and BoardEx, all through WRDS, and existing manager interviews.
- Access: licensed to the institution and not shareable. Nothing under
  `data/raw/`, `data/interim/`, `data/processed/` or `data/interviews/` is
  committed, and no data are distributed with the code. Reproducing the
  results needs your own WRDS subscription to these libraries; the scripts
  then rebuild every dataset, table and figure.
- Raw exports are in `data/raw/` and are never modified. Variables are
  defined in `data/codebook.md`.

## Status

Run `/research-workflow status`, or read the gate files in `reviews/`.

## Team

Arne Floh (PI), Alexander Mohr, Can Thanyi.

## Citation

To be added on publication.
