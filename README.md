# Differentiated International Integration in International Joint Ventures

Empirical manuscript project (target: *Journal of International Business
Studies*), run as an agent-based research workflow in Claude Code.

- Research idea: `initial-research-idea.md`
- Conventions for agents: `CLAUDE.md`
- Workflow stages, agents and gates: `docs/workflow.md`
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
/research-workflow hypotheses      # Stage 5: shock options, pre-analysis plan
/panel-build                       # Stage 6 (after gate 5)
/estimate                          # Stage 7 (after gate 6)
/write-section introduction        # Stage 8, one section per run
/references                        # verify bibliography, sync Zotero
/internal-review full              # Stage 10
```

Stages 1, 3 and 4 have no prerequisites and can start now. Stage 1 needs
nothing from you. Stage 3 needs the interview transcripts and the consent
notes in `data/interviews/`. Stage 4 needs the Orbis and Revelio pilot
exports described in `data/raw/extraction-spec-*.md`.

## Local tooling

- R 4.x with the packages listed in `code/R/00_setup.R`.
- Quarto for rendering reports and the manuscript to Word.
- Zotero with Better BibTeX; API credentials in `.Renviron` (gitignored),
  see `.claude/skills/references/SKILL.md`.

## Team

Arne Floh (PI), Alexander Mohr, Can Thanyi.
