# Differentiated International Integration in International Joint Ventures

Empirical manuscript project (target: *Journal of International Business
Studies*), run as an agent-based research workflow in Claude Code.

- Research idea: `initial-research-idea.md`
- Conventions for agents: `CLAUDE.md`
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
                      "fixest", "did", "didimputation", "modelsummary", "quarto", "renv"))
   ```

3. Put your WRDS login in `~/.Renviron` (your home folder, outside the
   repository, never committed):

   ```
   WRDS_USERNAME=your_wrds_username
   WRDS_PASSWORD=your_wrds_password
   ```

   Restart R after editing. On Windows, run `path.expand("~")` in R to see
   which folder `~` means; the file belongs there. Your WRDS account needs read access to the Orbis
   (`bvd_orbis_*`), Revelio (`revelio*`) and Capital IQ (`ciq*`) libraries.
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
| `06_ingest_external_jvs.R` | frame v3 and files in `data/raw/external/` | `data/interim/wrds-ijv-frame-v4-*.csv` |
| `04_wrds_route_sizing.R` | WRDS | `data/interim/route-sizing-*.csv` (a one-off sizing exercise) |

The sample table has one row per IJV. The columns to start with are `tier`
(how it was matched), `usable`, `core` (upper bound), `core_main`
(recommended analysis sample), `strategic`, `route`, `source` and
`admitted_by`. Definitions are in `data/codebook.md`.

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

## Team

Arne Floh (PI), Alexander Mohr, Can Thanyi.
