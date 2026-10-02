---
name: panel-build
description: "Stage 6 of the research workflow. Constructs the IJV-function-year and IJV-level-year panels from the full Orbis and Revelio exports via the data-engineer agent, following the approved pre-analysis plan. Requires gate 5 approved."
---

# /panel-build

Prerequisite: `reviews/gate-5-pre-analysis-plan.md` is APPROVED and the
full exports are in `data/raw/`.

Launch the `data-engineer` agent for Stage 6 as in its definition. The
measurement specification in the gate file is binding; deviations are
recorded in `docs/decisions.md` and in the gate-6 file.

Check on return: both parquet panels exist, `data/codebook.md` documents
every variable with source, construction and unit, and
`data/processed/sample-construction-log.md` reconciles counts from the
raw export to the final panel. Commit (code and docs only; data stays
gitignored) and summarize the sample sizes at each level.
