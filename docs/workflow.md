# Agent-based research workflow

This document is the authoritative description of the pipeline. The
orchestrator skill (`/research-workflow`) reads it, checks which gates are
approved in `reviews/`, and runs the next stage.

## Design principles

1. One agent per stage, with a narrow brief and a fixed output folder.
2. Every stage ends in a written deliverable the PI can read in under 30
   minutes, plus a gate file in `reviews/` that lists what the stage
   produced, what it is unsure about, and what the PI must decide.
3. Nothing downstream runs until the gate is approved. Approval is a
   human edit of the gate file (`Status: APPROVED`) or an explicit
   instruction in chat that the orchestrator records in the gate file
   with the date.
4. Deliverables are reproducible: searches have logged strings and dates,
   analyses are scripts, prose cites only verified references.
5. The feasibility risk named in the research idea (entity matching and
   workforce coverage) is tested before hypotheses are finalized. The
   pilot therefore precedes the panel, and the focal shock is chosen only
   after the pilot.

## Stages, agents, gates

| # | Stage | Agent | Skill | Inputs | Outputs | Gate |
|---|---|---|---|---|---|---|
| 0 | Project setup | orchestrator | `/research-workflow setup` | research idea, PI answers | `docs/decisions.md`, folder scaffold | none |
| 1 | Literature search | `literature-searcher` | `/lit-search` | search protocol | search strings, hit logs, screening sheet, Consensus results | G1 Literature search |
| 2 | Literature synthesis | `literature-synthesizer` | `/lit-synthesis` | screened hit list, full texts or abstracts | concept matrix, synthesis memos per stream, gap statement, theory-section outline | G2 Synthesis |
| 3 | Qualitative recoding | `qualitative-analyst` | `/qual-recode` | interview transcripts, consent notes | codebook, coded matrix, measurement memo, proposition memo | G3 Qualitative phase |
| 4 | Pilot feasibility | `data-engineer` | `/pilot-feasibility` | Orbis export (approx. 100 IJVs), Revelio export | match log, coverage tables, pilot feasibility report | G4 Pilot and go/no-go |
| 5 | Shock selection and hypotheses | orchestrator with `quant-analyst` | `/research-workflow hypotheses` | pilot report, synthesis, qualitative memo, PI decision on shock | final hypotheses, measurement specification, pre-analysis plan | G5 Pre-analysis plan |
| 6 | Panel construction | `data-engineer` | `/panel-build` | full exports, measurement spec | IJV-function-year and IJV-level-year panels, codebook | G6 Panel |
| 7 | Estimation | `quant-analyst` | `/estimate` | panel, pre-analysis plan | model scripts, tables, figures, analysis report | G7 Results |
| 8 | Writing | `academic-writer` | `/write-section <section>` | everything above | manuscript sections in `manuscript/sections/` | G8 per section, G9 full draft |
| 9 | References | `reference-manager` | `/references` | `.bib`, Zotero library | verified bibliography, missing-citation list | runs inside stages 2 and 8 |
| 10 | Internal review | `internal-reviewer` | `/internal-review` | full draft | JIBS-style review report, revision list | G10 Submission readiness |

Stages 1 to 3 can run in parallel. Stage 4 needs only the Orbis and
Revelio exports and can run in parallel with 1 to 3. Stage 5 needs G2,
G3 and G4. Everything after 5 is sequential.

## Gate files

Each gate is a Markdown file `reviews/gate-<n>-<slug>.md` created from
`reviews/GATE-TEMPLATE.md`. The agent fills in: deliverables with paths,
quality checks run, known weaknesses, decisions required from the PI, and
proposed changes to earlier stages. The PI sets the status line.

Status values: `PENDING`, `APPROVED`, `APPROVED WITH CHANGES` (changes
listed under the status line are applied by the orchestrator before the
next stage starts), `REJECTED` (stage reruns with the PI's notes).

## Standing conventions

- Dates in ISO format. Every search, export and model run is dated.
- File names: lowercase, hyphenated, numbered where order matters.
- Citation keys: Better BibTeX `authorYearFirstword` (for example
  `nohria1997differentiated`).
- Interview respondents are referred to by code (for example `IJV-07-M2`),
  never by name or employer.
- Variables in the panel follow the codebook in `data/codebook.md`.

## What the agents may not do

- Approve a gate.
- Change hypotheses after G5 without a dated entry in `docs/decisions.md`
  and a note in the manuscript's method section.
- Run a search and report hits without a logged string and date.
- Write a reference that is not in `literature/references.bib`.
- Report a model result that is not produced by a script in `code/R/`.
