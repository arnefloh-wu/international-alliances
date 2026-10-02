# Differentiated International Integration in International Joint Ventures

Research repository for an empirical manuscript targeted at the *Journal of
International Business Studies* (JIBS). The project is run as an agent-based
research workflow: Claude Code agents and skills in `.claude/` carry out each
stage, and the principal investigator signs off at review gates before the
next stage starts.

Team: Arne Floh (principal investigator, lead author), Alexander Mohr,
Can Thanyi (co-authors).

## What this project is

Read `initial-research-idea.md` first. In one sentence: international
integration inside an IJV is not a single alliance-level attribute but an
internally differentiated configuration that varies across functions and
hierarchical levels and is selectively reconfigured by environmental change.

Design: exploratory sequential mixed-method study.
- Phase 1 (qualitative): systematic recoding of existing manager interviews
  to ground the construct and its operationalization.
- Phase 2 (quantitative, primary): longitudinal panel of IJVs at the
  IJV x function x year level (and IJV x hierarchical level x year),
  built from Orbis Crossborder Investment and Revelio Labs, with a
  two-way fixed effects interaction model as the baseline and an
  event-study / difference-in-differences design as the preferred
  identification strategy once the focal shock is fixed.

## How the workflow runs

`docs/workflow.md` is the authoritative description of stages, agents,
inputs, outputs and gates. The orchestrator skill is
`/research-workflow`. Stage skills can also be run individually
(`/lit-search`, `/lit-synthesis`, `/qual-recode`, `/pilot-feasibility`,
`/panel-build`, `/estimate`, `/write-section`, `/references`,
`/internal-review`).

Review gates are recorded in `reviews/`. A stage whose gate file does not
carry `Status: APPROVED` blocks every downstream stage. Agents never
approve a gate themselves.

## Non-negotiable rules for every agent

1. Never invent a reference, DOI, page number, statistic, interview quote
   or data point. Insert `[CITE: what is needed]` or `[DATA: what is
   needed]` and report it. Every reference in prose must exist in
   `literature/references.bib`, and every entry there must have been
   verified against Crossref or the source database.
2. Licensed data (Orbis, Revelio, BoardEx) and interview transcripts never
   leave `data/`, never enter prose verbatim beyond what the consent terms
   allow, and are never committed unless `.gitignore` is deliberately
   changed by the PI.
3. Manuscript prose follows the `academic-writing` skill (Arne's voice).
   American spelling, APA 7 in-text conventions, JIBS reference style via
   `manuscript/csl/journal-of-international-business-studies.csl`.
   No em dashes, no bullet points in body text, no AI-tell vocabulary.
4. Claims are calibrated to the design. The qualitative phase supports
   associational and conceptual claims only. Causal language is reserved
   for the identified quantitative design and only after pre-trends have
   been checked.
5. Analysis is in R. Scripts in `code/R/` must run top to bottom from
   `code/R/00_setup.R` with no manual steps. Every table and figure in the
   manuscript is produced by a script and saved to `manuscript/tables/` or
   `manuscript/figures/`; nothing is typed in by hand.
6. Decisions and their rationale go in `docs/decisions.md` with a date.
   Open questions go in the "Open" section there, not in agent memory.
7. Agents write to the folder that belongs to their stage (see
   `docs/workflow.md`) and do not edit another stage's outputs. Edits to
   earlier-stage outputs are proposed in the gate review file.
8. Commit after each completed stage with a message that names the stage
   and the gate it feeds. Work on the branch the session designates.

## Folder map

| Folder | Content | Owner stage |
|---|---|---|
| `docs/` | workflow, decision log, JIBS guidelines notes | all |
| `literature/search/` | search protocol, search strings, hit logs, screening sheets | lit-search |
| `literature/synthesis/` | synthesis memos, concept matrix, gap statement | lit-synthesis |
| `literature/references.bib` | single source of truth for references (Better BibTeX export from Zotero) | references |
| `data/raw/` | untouched exports (Orbis, Revelio, BoardEx, dyad data) | data engineer |
| `data/interviews/` | transcripts, consent notes, coding files | qualitative analyst |
| `data/interim/`, `data/processed/` | matched entities, panel | data engineer |
| `code/R/` | numbered scripts, `functions/` helpers | data engineer, quant analyst |
| `code/quarto/` | pilot feasibility report, analysis report | data engineer, quant analyst |
| `manuscript/` | Quarto manuscript, sections, tables, figures, CSL | academic writer |
| `reviews/` | gate files and internal review reports | reviewer, PI |

## Tooling notes

- Literature: the Consensus connector is available to agents. Web of
  Science, EBSCO and Google Scholar have no agent access in this
  environment; the lit-search skill therefore emits exact search strings
  and a screening sheet for manual runs, and ingests the exported hit
  lists.
- References: Zotero group library via the Zotero Web API
  (`ZOTERO_API_KEY`, `ZOTERO_GROUP_ID` in `.Renviron` or `.env`, never
  committed). Better BibTeX citation keys in the form `authorYearTitleword`.
- Writing: Quarto (`manuscript/manuscript.qmd`) renders to Word with the
  JIBS CSL. Final Word polishing and tracked changes use the `docx`
  skill.
- R packages: `fixest`, `did`, `didimputation`, `modelsummary`,
  `data.table`, `arrow`, `stringdist`, `targets` (optional), `renv`.
