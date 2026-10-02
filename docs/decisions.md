# Decision log

Dated record of design and workflow decisions. Newest at the bottom of
each section. Agents append; they do not rewrite history.

## Decided

| Date | Decision | Rationale / source |
|---|---|---|
| 2026-10-02 | Target journal: *Journal of International Business Studies* (JIBS). | PI, workflow setup. |
| 2026-10-02 | Manuscript scope: full mixed-method paper (qualitative Phase 1 and quantitative Phase 2 both reported). | PI. |
| 2026-10-02 | The 100-IJV pilot matching exercise has not been run. The pilot feasibility report is produced before hypotheses are finalized. | PI; research idea section 12. |
| 2026-10-02 | Co-authors: Alexander Mohr, Can Thanyi. Division of sections to be recorded here once agreed. | PI. |
| 2026-10-02 | Literature databases: EBSCO (Business Source), Google Scholar, Web of Science. Agent search where possible (Consensus connector); otherwise the search agent emits exact strings for manual runs and ingests exports. | PI. |
| 2026-10-02 | Theoretical streams for synthesis: differentiated network, integration-responsiveness, IJV staffing and control, expatriate and parent-origin staffing, geopolitics in IB. No prior library; search starts from scratch. | PI. |
| 2026-10-02 | Data exports (Orbis Crossborder Investment, Revelio, BoardEx, dyad data) are placed in `data/raw/` locally or in Dropbox; agents work from the exports, not from the licensed platforms. | PI. |
| 2026-10-02 | Analysis in R. Baseline: two-way fixed effects with shock x domain-characteristic interactions. Robustness: event study, staggered DiD estimators, fractional response models, cell-size thresholds. | PI; research idea section 10. |
| 2026-10-02 | References in Zotero (group library), exported with Better BibTeX to `literature/references.bib`. | PI. |
| 2026-10-02 | Manuscript authored in Quarto, rendered to Word with the JIBS CSL; final tracked-change editing via the docx skill. | PI. |
| 2026-10-02 | Review gates after literature synthesis, pilot feasibility, pre-analysis plan, and each major section draft. | PI. |
| 2026-10-02 | Workflow lives in this repository as Claude Code agents and skills. | PI. |
| 2026-10-02 | Spelling: American, applied throughout. JIBS accepts consistent usage; confirm against the current author guidelines before submission. | academic-writing skill default. |

## Open

| Raised | Question | Needed by | Owner |
|---|---|---|---|
| 2026-10-02 | Focal environmental shock (geopolitical deterioration vs. investment-screening reform vs. mobility restrictions) and its measure. | Stage 5 (after pilot) | PI |
| 2026-10-02 | Interview corpus: location, number, language, consent and anonymization constraints. | Stage 3 | PI |
| 2026-10-02 | Section ownership among co-authors. | Stage 8 | PI |
| 2026-10-02 | Whether raw exports may be stored in this GitHub repository (licence terms) or must stay in Dropbox. Default is Dropbox and gitignore. | Stage 4 | PI |
| 2026-10-02 | Web of Science API access (institutional key) for agent-run searches. Without it, manual export. | Stage 1 | PI |
