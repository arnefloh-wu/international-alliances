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
| 2026-10-02 | Theory hierarchy: structural contingency theory is the main theory (T1). The differentiated network (Nohria and Ghoshal) and integration-responsiveness are related IB frameworks that apply the same contingency logic (T2), not separate theories. IJV staffing and control, parent-origin and expatriate staffing, and relevant organizational-design work are supporting literatures that specify how integration is manifested and measured (T3). Geopolitics is the environmental context that creates changing contingencies (T4). Microfoundations are excluded unless the interviews show a needed individual-level mechanism. | PI, detailed answer on theoretical anchors. See `docs/theory-framework.md`. |
| 2026-10-02 | The focal shock is not fixed in advance. The workflow generates and compares several candidate geopolitical contingencies (for example sanctions, investment-screening reform, export controls, mobility restrictions, bilateral political deterioration) on five criteria: theoretical fit, measurement quality, identification potential, sample coverage and power, and substantive interest and novelty in current IB research. | PI, detailed answer on the focal shock. |
| 2026-10-02 | A shock fits the theory only if it alters the contingencies of different domains by different amounts (coordination requirements, local embeddedness, access to parent resources, mobility, regulatory exposure, political sensitivity), so that it implies differentiated reconfiguration. | PI. |
| 2026-10-02 | Shock selection uses exposure counts, design properties and literature evidence only. It must not use patterns in the integration outcomes, to avoid choosing the shock by its results. | Workflow rule added when implementing the PI's answer; PI to confirm. |
| 2026-10-02 | H4 and H5 in the research idea assume geopolitical deterioration. They are restated at the contingency level and then instantiated for the chosen shock in the pre-analysis plan. | Workflow rule added when implementing the PI's answer; PI to confirm. |
| 2026-10-02 | Protocol version 1.1 adds three streams: S7 structural contingency theory, S8 organizational design, S9 candidate geopolitical shocks. Streams S1 to S6 keep their numbers. | Follows from the theory hierarchy. |
| 2026-10-04 | Zotero group library "international-alliances" (group ID 6702272) is the project library; the API key has read and write access. The 114 Stage 1 records screened as include, seed or unsure were imported into the collection "Stage 1 - Consensus search 2026-10-02 (unverified)", with metadata from Crossref where a strict title, author and year match existed (93 items) and from the screening sheet otherwise (21 items, tagged `metadata-check`). All carry the tag `unverified`; none is in `literature/references.bib` until the reference-manager verifies it. Mapping in `literature/zotero/import-2026-10-04-consensus.csv`. | PI request; Stage 9 conventions. |
| 2026-10-04 | References use the print-issue year, as JIBS does, not the online-first date. Nine items were re-dated and their citation keys re-pinned (for example li2018diplomatic, harzing2016bridging); the online date is kept in the Zotero Extra field. | PI. |
| 2026-10-04 | The metadata corrections proposed in `literature/zotero/verification-report-2026-10-04.md` (sections 3, 4.1 and 4.3) are approved and applied in Zotero. Consensus links moved from the url field to Extra. One name form, "Le Nguyen, Huu", is used for that author. `references.bib` holds 86 verified entries. | PI; applied by the reference-manager. |
| 2026-10-04 | Meyer & Li 2022 seed is Meyer, K. E., & Li, C., Global Strategy Journal 12(3), 555-577, doi 10.1002/gsj.1436 (follows from the approved correction). | PI approval of corrections. |
| 2026-10-04 | Cite the original work, not reprints or reissues (for example the 1990 Doz, Prahalad & Hamel chapter, the 1981 Prahalad & Doz SMR article, the 1983 Praeger edition of Killing). A revised edition with changed content or authors counts as its own work and is cited as read (Birkinshaw & Pedersen 2009). | PI; the revised-edition reading is the orchestrator's, PI to confirm. |
| 2026-10-04 | Book reviews do not count as verification evidence. Citing references in other papers are leads only. Accepted evidence: DOI record on Crossref, publisher or journal page, library or repository catalogue record, ISBN record, or a PDF of the work. | PI (book reviews); orchestrator's reading for citing references, consistent with the reference-manager rules. |
| 2026-10-04 | Academy of Management Proceedings abstracts may be cited. | PI. |
| 2026-10-04 | Unverified works are searched for PDFs and catalogue records on the web; results in `literature/zotero/pdf-search-2026-10-04.md`. Downloaded PDFs go to `literature/fulltext/` and are not committed. | PI. |
| 2026-10-04 | Web-search results count as verification evidence when they come from an accepted source type (publisher, journal, library or repository record) and the URL is logged, even if the page could not be opened in this environment. Internet Archive / Open Library and ProQuest records count as catalogue records; RePEc counts as a repository record; Questia listings are supporting only. | PI, on the orchestrator's recommendation. |
| 2026-10-04 | Record corrections from the web search approved (missing co-authors added; the "van Oosten" record replaced by Cocito et al. 2004; Mohedano-Suanes & Safón 2021 re-dated; Andersson & Forsgren as a book chapter). nguyen2009foreign dropped (moved to the Zotero trash). | PI. |
| 2026-10-04 | Venaik, Midgley & Devinney 2004 is cited as a journal article: Management International Review 44, 15-48 (volume and pages from the EconBiz library catalogue; issue label "Special Issue 1" to confirm). The Gabler reprint chapter DOI is kept in Zotero Extra. | PI. |
| 2026-10-07 | Data access goes through the university's WRDS subscription, queried from R (RPostgres) or Python (wrds). The Claude cloud environment cannot connect to WRDS, because its proxy does not support database connections, so WRDS scripts run on the PI's computer and their outputs reach the agents through Dropbox. First step: `code/R/wrds/01_wrds_discover.R` lists the Orbis and Revelio tables the subscription includes. | PI (WRDS access); proxy limitation documented in the cloud environment. |

## Open

| Raised | Question | Needed by | Owner |
|---|---|---|---|
| 2026-10-02 | Which candidate shock to adopt. Approach is decided (see Decided); the choice follows the shock scan (gate 5a) and the re-scoring with pilot exposure counts (gate 5). The comparison weights default to equal and can be changed at gate 5a. | Gate 5a shortlist, gate 5 final | PI |
| 2026-10-02 | Whether two summary contingency scores (coordination dependence, local embeddedness) suffice or a third, dependence on parent resources, is needed. | Gate 3 | PI |
| 2026-10-02 | Seed works for the new streams S7 to S9 are listed from memory and need verification before any is cited. | Stage 1 increment | literature-searcher |
| 2026-10-02 | Interview corpus: location, number, language, consent and anonymization constraints. | Stage 3 | PI |
| 2026-10-02 | Section ownership among co-authors. | Stage 8 | PI |
| 2026-10-02 | Whether raw exports may be stored in this GitHub repository (licence terms) or must stay in Dropbox. Default is Dropbox and gitignore. | Stage 4 | PI |
| 2026-10-02 | Web of Science API access (institutional key) for agent-run searches. Without it, manual export. | Stage 1 | PI |
| 2026-10-02 | Protocol seed corrections found at Stage 1: Witt, Lewin, Li & Gaur 2023 is in the Journal of World Business (not JIBS); Meyer & Li 2022 appears to be a Global Strategy Journal paper with co-author unconfirmed; Schaan 1983 is a dissertation. See `reviews/gate-1-literature-search.md`. | Stage 1 | PI |
| 2026-10-02 | Consensus free tier (10 results per query, no DOIs, 3 searches left until 2026-11-01): upgrade the plan or have the PI run the remaining citation chases manually? | Stage 1 chase, G1 | PI |
| 2026-10-02 | Treatment of conference proceedings, working papers and dissertations in the search protocol. | G1 | PI |
| 2026-10-04 | Shock scan (gate 5a): confirm hard-screen readings (single-dyad shocks; onsets after the Revelio panel end), admissibility of Brexit and of non-geopolitical regulatory shocks, and who verifies the shortlisted data sources, since the egress policy blocked all documentation pages and the scan rests on search snippets. See `reviews/gate-5a-shock-scan.md`. | Gate 5a | PI |
| 2026-10-04 | References: pages still to confirm from the library for several originals (Reus & Ritchie 2004, Downes & Thomas 2000, Doz & Prahalad 1980, Doz, Prahalad & Hamel 1990, Prahalad & Doz 1981); Downes & Thomas 2000 still unverified. See sections 9 to 11 of the verification report. | Before writing | PI |
