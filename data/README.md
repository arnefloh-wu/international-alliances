# data/

All content under `data/` except this file, `codebook.md`,
`interviews/README.md` and the extraction specifications is gitignored.
Exports live locally here or in the project Dropbox folder.

Dropbox path (PI fills in): `Dropbox/international-alliances/data/`
Mirror it to this folder before running any `/pilot-feasibility`,
`/panel-build` or `/estimate` stage, or set `IA_DATA_DIR` in `.Renviron`
to the Dropbox path; `code/R/00_setup.R` reads it.

## Expected files

| Path | Source | Produced by | Notes |
|---|---|---|---|
| `raw/orbis-pilot-<date>.csv` | Orbis Crossborder Investment | PI export, spec in `raw/extraction-spec-orbis.md` | approx. 100 IJVs for the pilot |
| `raw/orbis-full-<date>.csv` | Orbis Crossborder Investment | PI export | full IJV population after go decision |
| `raw/orbis-financials-<date>.csv` | Orbis / Compustat / Capital IQ | PI export | parent and JV controls |
| `raw/revelio-companies-<date>.csv` | Revelio Labs | PI export | company master with identifiers |
| `raw/revelio-positions-<date>.parquet` | Revelio Labs | PI export | individual position records |
| `raw/boardex-<date>.csv` | BoardEx | PI export, optional | senior executives |
| `raw/dyad-<measure>-<date>.csv` | country-dyad political relations / sanctions / screening | PI or agent download | see decision on the focal shock |
| `interviews/transcripts/<code>.txt` | existing interview study | PI | see `interviews/README.md` |
| `interim/pilot-matches.csv` | `01_pilot_matching.R` | agent | all candidate matches with method and score |
| `interim/pilot-match-review.csv` | `01_pilot_matching.R` | agent | ambiguous matches for PI review |
| `processed/panel-ijv-function-year.parquet` | `02_build_panel.R`, `03_measures.R` | agent | primary panel |
| `processed/panel-ijv-level-year.parquet` | same | agent | hierarchy panel |
| `processed/sample-construction-log.md` | same | agent | counts at every exclusion step |

## Licence reminder

Orbis, Revelio and BoardEx data are licensed to the institution. Do not
place raw or individual-level processed files in a public repository.
Aggregated cell-level panels may be shareable; check the licence before
changing `.gitignore`.
