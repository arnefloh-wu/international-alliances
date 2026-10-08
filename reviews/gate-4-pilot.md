# Gate 4: Pilot feasibility and go/no-go

Status: PENDING
Approved by:
Stage: 4 Pilot feasibility
Agent: data-engineer (run by the orchestrator in the PI's local session, WRDS access)
Date produced: 2026-10-08

## Deliverables

| Deliverable | Path | Notes |
|---|---|---|
| WRDS extraction script | `code/R/wrds/02_wrds_pilot_extract.R` | Builds the IJV frame from Orbis ownership links, draws the pilot (seed 20261008), pulls Revelio candidates and position histories. Resumes from cached stages. |
| Matching and coverage script | `code/R/01_pilot_matching.R` | Name matching with guards, review tier, GUO-level parent groups, coverage per matching tier. |
| Matching helpers and tests | `code/R/functions/matching.R`, `code/R/tests/test-functions.R` | New `web_domains()` and `review_tier_candidates()`; 22 of 22 checks pass. |
| Pilot feasibility report | `code/quarto/pilot-feasibility-report.qmd` (renders to `.docx` and `.html`, not committed) | Every figure is computed from the files below. |
| Frame and pilot exports (gitignored) | `data/interim/wrds-ijv-frame-2026-10-08.csv`, `data/interim/wrds-ijv-frame-groups-2026-10-08.csv`, `data/raw/orbis-pilot-2026-10-08.csv`, `data/raw/revelio-companies-2026-10-08.csv`, `data/raw/revelio-positions-2026-10-08.csv` | Licensed data, local only. |
| Match logs for review (gitignored) | `data/interim/pilot-matches.csv`, `pilot-match-review.csv`, `pilot-jv-rejected-matches.csv`, `pilot-jv-review-tier.csv`, `pilot-parent-groups.csv`, `pilot-jv-rcids.csv` | `pilot-jv-review-tier.csv` needs the PI's check (24 rows). |
| Extraction log | `data/interim/wrds-extract-log-2026-10-08.md` | Timings and counts for every stage. |
| Codebook | `data/codebook.md` | Frame rules, Revelio field assumptions, parent families, matching tiers. |

## Key results

Frame: 83,907 companies passed the ownership screen. 12,074 remained eligible after excluding JVs with a non-corporate parent (69,722) and financial-sector JVs (2,111). The pilot drew 100.

Matching: 33 of 100 pilot JVs had any name candidate in Revelio, and 19 were accepted automatically. Of 213 parents, 92 matched directly, and 35 of 53 distinct ultimate owners (GUOs) matched. 33 JVs have two or more parents with a Revelio group, 45 have one, and 22 have none.

| Tier | JVs matched | JVs usable (>= 20 employees, >= 3 years) | Usable, staff from at least one parent | Usable, staff from both parents |
|---|---|---|---|---|
| Automatic name matches | 19 | 7 | 3 | 1 |
| Plus strong website matches | 28 | 14 | 4 | 1 |
| Plus all review-tier matches | 43 | 19 | 4 | 1 |

Person-years by origin, automatic plus strong tier: no prior position on record 47.0%, external host-country hire 36.0%, external international hire 12.7%, parent A 3.5%, parent B 0.9%.

Cells with at least 5 employees, automatic plus strong tier: 625 function-year cells and 475 seniority-year cells.

Usable JVs by exposure group (automatic / strong / all review): UK-EU 1 / 3 / 3, OECD screening 1 / 4 / 7, China coercion 1 / 1 / 1, Russia 0 / 0 / 0, unexposed 4 / 6 / 8. US Entity List exposure was not drawn.

Projection to the frame, weighted by exposure group: about 1,000 usable JVs (automatic) to 2,100 (strong) to 3,100 (all review). JVs with staff from both parents project to about 170, and that figure rests on a single pilot JV (Chery Jaguar Land Rover).

## Recommendation (agent's view; the PI decides)

Conditional go, with a design change. Workforce coverage is adequate for the localization measures. Usable JVs project to well above the 300 to 800 target, and function and seniority cells survive at the baseline threshold of 5. Parent-origin staffing, however, can be reconstructed for very few JVs. Only one usable pilot JV shows employees from both parents. Cross-parent integration and parent dominance (sections 6.1 and 6.2 of the research idea, and H1, H3 and H5) are therefore not measurable at scale on this frame. Localization (H2, H4) and hierarchy-based contrasts in localization are.

Two reasons make this a frame problem as much as a data problem. The ownership frame is dominated by small JVs (median Orbis headcount 43 among the 67 JVs that report one, and 19 of 100 with 100 or more employees), many of them project vehicles whose staff are hired locally. Where both parents were found in Revelio, parent-origin staff were still absent for most JVs, so better matching alone will not close the gap.

Before committing, the agent recommends a second 100-JV pilot drawn from a large-JV stratum (Orbis headcount of at least 100 and both parents' groups present in Revelio). The pipeline reruns in about five minutes. If that stratum yields enough JVs with staff from both parents, the original constructs can be kept for a large-JV subsample, with localization as the measure for the full sample.

## Quality checks run

- All scripts run top to bottom from `code/R/00_setup.R` with no manual steps. Re-running the extraction regenerates an identical pilot draw (checked against the saved ID list).
- Function checks: `Rscript code/R/tests/test-functions.R`, 22 of 22 pass, including five new checks for the review-tier rules.
- Every accepted JV match was inspected by name, country, Orbis headcount and first Revelio start date. This found JVs matched to their own parent (RTB House, Value Retail) and to same-name firms abroad (Kliver, Asva), which led to the host-country and parent-entity guards.
- Cell-years before the JV's incorporation year are excluded and counted separately, after one matched entity showed positions from 1982 for a JV incorporated in 2015.
- Parent-origin absence was checked without the three-year origin window: for most usable JVs, no employee was ever at either parent family at any time.
- The frame exclusion breakdown was checked after a first run in which a lookup gap removed 92% of parents. The fix (shareholder names and types from each JV's own shareholder table) cut missing parent names to 4 of 188,348 rows.

## Known weaknesses and uncertainties

- Survivor bias: the frame contains only JVs active today with an unchanged multi-parent structure. Dissolved and bought-out JVs are missing.
- Proxies: incorporation date stands in for formation date and the current equity share for the share at formation.
- Exposure groups and the two-country rule use the direct shareholder's country, not the GUO's. A JV whose two shareholders are registered in the same country but owned from different countries is excluded, and dyads may be misassigned.
- The pilot has no North American JVs, and 41 of 100 JVs have no NACE code (industry "unknown").
- Revelio coverage of China-hosted JVs is weak. Several large Chinese JVs (for example Samsung SDI Tianjin) have no separate Revelio entity.
- The review tier is unverified. The strong subset looks correct on inspection, with one doubtful case (Renovalia matched to the group entity). The full tier contains several clear errors.
- About 45% of JV person-years have no prior position on record, which caps parent-origin reconstruction whatever the matching quality.
- All per-group counts are small. The both-parent projection rests on one JV.
- Revelio seniority (1 to 7) and the `role_k10_v3` taxonomy are not yet mapped to the project's levels and nine functions. That mapping is set at gate 5.

## Decisions required from the PI

1. Go/no-go: accept the conditional go (localization as the primary measure, cross-parent integration for a large-JV subsample if feasible), reject, or ask for changes.
2. Second pilot: run a 100-JV pilot from the large-JV stratum before deciding, yes or no.
3. Frame rules: approve the corporate parent types, the 20 to 90 percent share band, two or three parents, active status, and incorporation 2005 to 2023.
4. Country basis: direct shareholder country (current) or GUO country for the two-country rule and the exposure groups.
5. Review tier: check the 24 rows in `data/interim/pilot-jv-review-tier.csv`, and decide whether the strong website tier counts as accepted.
6. Deal data: whether to ask the library about adding the SDC joint-ventures module, which would give formation dates and dissolved JVs.

## Proposed changes to earlier stages

- `data/raw/extraction-spec-orbis.md`: annotated as superseded for the pilot by the WRDS ownership route (already done in this stage, since the spec belongs to Stage 4).
- Gate 5a / `/shock-options rescore`: use the usable-JV counts by exposure group above. Russia has no usable pilot JV, and US Entity List exposure needs a name match against the list before it can be counted.
- Research idea, section 6: if the conditional go is accepted, the hypotheses on cross-partner integration (H1, H3, H5) need either the large-JV subsample or a restatement in terms of localization and staffing by level.

## PI notes (filled in by the PI; applied by the orchestrator if status is APPROVED WITH CHANGES)

- 
