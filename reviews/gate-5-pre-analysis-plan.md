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

### Items this plan has to settle for the shock

Listed in the Open section of `docs/decisions.md` (raised 2026-11-24): the
cell rule for the hard screen; the S13 design choices above; a sourced score
for the change in local embeddedness per function and the `role_k50` map of
regulatory-facing roles; the S06 definitions and the verification of nine
non-EU adoption years, if the fallback is needed.

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

- `data/codebook.md`, section "Shock": the S13 exposure definition (pairs, onset, variants), proposed by `literature/shock-scan/rescoring.md`, section 12.
- `data/README.md` and the folder map: mention `data/raw/external/` for public source files.
- `literature/references.bib`: add the sources the plan cites for the shocks (ASPI 2020, Bauerle Danzman and Meunier 2023, Regulation (EU) 2019/452, the EC list) through `/references`.

## PI notes (filled in by the PI; applied by the orchestrator if status is APPROVED WITH CHANGES)

- 
