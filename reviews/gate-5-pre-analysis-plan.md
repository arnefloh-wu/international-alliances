# Gate 5: Pre-analysis plan

Status: PENDING
Approved by:
Stage: 5 Pre-analysis plan (`/research-workflow hypotheses`)
Agent: orchestrator with quant-analyst
Date produced: not yet produced (file opened on 2026-11-24 to carry in the focal shock decision; stage 5 fills the remaining sections)

## Decisions carried in before stage 5

### Focal shock (decided by the PI on 2026-11-24)

The PI adopted S13 as the focal shock and S06 as the fallback, in chat on
2026-11-24 ("Adopt S13, S06 fallback"), after `/shock-options rescore`.
Recorded in `docs/decisions.md` (Decided, 2026-11-24).

| | Focal: S13 | Fallback: S06 |
|---|---|---|
| Shock | Brexit: end of the UK-EU transition period and of free movement | Staggered investment screening in OECD hosts |
| Onset | 2021 (referendum 2016; 2016 to 2020 as anticipation window, proposed) | Host adoption year, 2017 onward (proposed lower bound) |
| Exposure | IJVs whose host and parent countries form a UK-EU, EEA or Switzerland pair | IJVs with a non-allied parent (China, Hong Kong, Macao) in a screened sector of a screening host |
| Exposed in `core_main` | 28 pairs; 394 IJVs (97 strategic), 311 with a parent in Revelio | 39 IJVs (7 strategic), 35 with a parent in Revelio |
| After cell thresholds (IJVs with a parent in Revelio; pairs) | 136 (hires rule) to 231 (employee rule); 23 to 24 pairs | 23 (hires rule) to 32 (employee rule); 15 to 19 pairs |
| Controls | 3,409 never-treated IJVs in the UK and the EU, EEA and Switzerland without a UK-set link (1,273 at the hires rule) | Not-yet-treated hosts and allied-parent IJVs in the same hosts and sectors (1,011; 399 at threshold) |
| Rescored score (equal weights) | 4.20 | 3.20 |

Sources: `literature/shock-scan/rescoring.md` (sections 4, 6 and 9),
`literature/shock-scan/rescoring-counts-2026-11-24.csv`, produced by
`code/R/06_shock_exposure.R`. The shock was chosen on exposure counts,
design properties and literature evidence only; no staffing outcome was
tabulated by exposure status (`CLAUDE.md` rule 8).

Proposed design for S13 (from `rescoring.md`, section 9; open until this
gate): hiring flows per IJV x function x year, 2008 to 2025; treatment as
exposed IJV x post-2021 x the function's change in local embeddedness, with
coordination dependence as the moderator of the channel; IJV x year, IJV x
function and function x year fixed effects; an event study with 2013 to 2015
as the clean pre-period; GB-IE IJVs (31) as a within-shock contrast that
separates the regulatory channel from the mobility channel; clustering by
country pair with a wild cluster bootstrap.

Main threats to address in the plan: the mobility channel acts on the same
outcome; the onset coincides with COVID-19 and follows four years of
anticipation; survivor bias; a single common onset; a thin local
parent-origin cell; the framing of Brexit as a change in the political order
between states.

### Route to gate 5 (decided by the PI on 2026-11-24)

The PI accepted all seven recommendations of
`docs/coauthor-notes/pre-analysis-plan-inputs-decision-sheet-2026-11-24.qmd`
("Accept all"). Recorded in `docs/decisions.md` (Decided, 2026-11-24).

1. Stage 5 goes ahead without G3, as a dated departure from `docs/workflow.md`.
2. `/lit-synthesis` runs now on the corpus approved at G1, and is re-run when
   the manual exports arrive.
3. The static scores (`coord_dependence`, `local_embeddedness`) come from
   O\*NET task measures linked through Revelio's `onet_code`. Scores from raters
   outside the team are the robustness check. Author-set scores are not used.
4. The Brexit change score is a binary list of regulatory-facing occupations,
   written into this plan before the panel is built. The O\*NET law and
   government score is the robustness check.
5. The domain variable is the occupation group. The panel unit is IJV x
   occupation group x year, with the nine functions as a robustness check.
6. The cell rule is at least 5 employees, with at least 5 hires as a
   sensitivity check.
7. The S13 design above is accepted as proposed.

### Pre-analysis plan rules (decided by the PI on 2026-11-25)

The PI accepted all ten recommendations of
`docs/coauthor-notes/pre-analysis-plan-rules-decision-sheet-2026-11-24.qmd`
("Accept all"). Recorded in `docs/decisions.md` (Decided, 2026-11-25).
Decisions 9 and 10 concern the literature and go to the protocol and the G2
re-run. The rest are carried into this plan:

1. O\*NET data step: the WRDS pull of `onet_code` and the public O\*NET
   download go ahead. The licensed pull runs after the PI confirms it once
   more. If fewer than 70% of positions carry a code, `role_k50` is mapped to
   O\*NET by title.
2. Labor market entrants: three-year window. One and five years are the
   robustness checks.
3. IJVs inside a parent's Revelio family (831): a person audits a random 100
   on names, ownership and location only. If more than 20 are parent units,
   the flagged IJVs leave the main sample and return as robustness.
   Otherwise they stay, and dropping them is the robustness check.
4. Main sample: hiring flows from 2010 on. The robustness checks are the
   cell's unmapped-employer share as a control, and the full period. Stocks
   are descriptive only.
5. Primary estimator for share outcomes: Poisson on the category count with
   the log of the cell denominator as offset. The fractional logit and the
   linear model are robustness checks. A wild cluster bootstrap is added
   wherever a test rests on fewer than about 50 clusters.
6. Static models are clustered two-way by IJV and occupation group, with
   IJV-only errors reported and the permutation test over occupation groups
   kept as a check. Shock models keep the S13 clustering by country pair,
   with a wild cluster bootstrap.
7. The level part of H1 stays exploratory: `mintzberg1979structuring` as
   the source of `coord_role`, clustered errors, the limitation stated, and
   no permutation test over levels. It is reported in a separate exploratory
   section.
8. S13 linked entity: settled at stage 5 from the public Home Office
   guidance. If the guidance is unclear, the mobility-channel term is
   estimated both ways (minority-held IJVs coded as linked, then as not
   linked).

O\*NET data step, done on 2026-11-25 (`data/data-log.md`): 96.6% of the JV
positions carry a position-level occupation code (O\*NET-SOC 2019), so the
70% rule is met. The 3.1% of positions no longer in Revelio's position table
take the code of their role through the role lookup (PI, 2026-11-25), with
the route recorded as `onet_source` and their exclusion as a robustness check.

### Items this plan still has to settle

Listed in the Open section of `docs/decisions.md`:
- the audit of the 831 flagged IJVs (before the panel is built);
- the UK intra-company route for minority-held IJVs (decision 8, at stage 5);
- the S06 definitions, if the fallback is needed;
- `[CITE: methods reference for the consistency of Poisson with high-dimensional fixed effects]`;
- the full texts and the G2 re-run, before this gate is approved.

## Deliverables

| Deliverable | Path | Notes |
|---|---|---|
| | | To be filled at stage 5 |

## Quality checks run

- To be filled at stage 5

## Known weaknesses and uncertainties

- To be filled at stage 5

## Decisions required from the PI

1. To be filled at stage 5

## Proposed changes to earlier stages

- `docs/workflow.md`, lines 53 to 54 ("Stage 5 needs G2, G3, G4 and G5a"): add that, by the PI's decision of 2026-11-24, stage 5 proceeds without G3 while the qualitative study is set aside, with a pointer to `docs/decisions.md`.
- `data/codebook.md`, section "Shock": the S13 exposure definition (pairs, onset, variants), proposed by `literature/shock-scan/rescoring.md`, section 12.
- `data/README.md` and the folder map: mention `data/raw/external/` for public source files.
- `literature/references.bib`: add the sources the plan cites for the shocks (ASPI 2020, Bauerle Danzman and Meunier 2023, Regulation (EU) 2019/452, the EC list) through `/references`.

## PI notes (filled in by the PI; applied by the orchestrator if status is APPROVED WITH CHANGES)

- 
