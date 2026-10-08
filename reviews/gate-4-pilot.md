# Gate 4: Pilot feasibility and go/no-go

Status: PENDING
Approved by:
Stage: 4 Pilot feasibility
Agent: data-engineer (run by the orchestrator in the PI's local session, WRDS access)
Date produced: 2026-10-08 (pilot 1 and, at the PI's request, pilot 2 on large JVs)

## Deliverables

| Deliverable | Path | Notes |
|---|---|---|
| WRDS extraction script | `code/R/wrds/02_wrds_pilot_extract.R [main\|large]` | Builds the IJV frame from Orbis ownership links, draws a pilot (main: seed 20261008; large: seed 20261009), pulls Revelio candidates and position histories. Resumes from cached stages. |
| Matching and coverage script | `code/R/01_pilot_matching.R [main\|large]` | Name matching with guards, review tier, GUO-level parent families, coverage per matching tier. |
| Matching helpers and tests | `code/R/functions/matching.R`, `code/R/tests/test-functions.R` | `web_domains()` and `review_tier_candidates()`; 22 of 22 checks pass. |
| Pilot feasibility report | `code/quarto/pilot-feasibility-report.qmd`, rendered with `-P pilot:main` and `-P pilot:large` to `pilot-feasibility-report(.html/.docx)` and `pilot-feasibility-report-large(.html/.docx)` (renders not committed) | Every figure is computed from the files below. |
| Frame exports (gitignored) | `data/interim/wrds-ijv-frame-2026-10-08.csv`, `wrds-ijv-frame-groups-2026-10-08.csv`, `wrds-ijv-frame-size-2026-10-08.csv`, `wrds-large-screen-2026-10-08.csv` | Licensed data, local only. |
| Pilot exports (gitignored) | `data/raw/orbis-pilot-[large-]2026-10-08.csv`, `revelio-companies-[large-]2026-10-08.csv`, `revelio-positions-[large-]2026-10-08.csv` | Licensed data, local only. |
| Match logs for review (gitignored) | `data/interim/pilot-[large-]matches.csv`, `match-review.csv`, `jv-rejected-matches.csv`, `jv-review-tier.csv`, `parent-groups.csv`, `jv-rcids.csv`, `origin-<tier>.csv` | The review-tier files need the PI's check (24 rows in pilot 1, 21 in pilot 2). |
| Extraction log | `data/interim/wrds-extract-log-2026-10-08.md` | Timings and counts for every stage, tagged by pilot. |
| Codebook | `data/codebook.md` | Frame rules, Revelio field assumptions, parent families, matching tiers, proposed intra-group rule. |

## Frame

83,907 companies passed the ownership screen. 12,074 remained eligible after excluding JVs with a non-corporate parent (69,722) and financial-sector JVs (2,111). Both pilots oversample JVs exposed to the shortlisted shocks.

A JV whose parents share one Orbis global ultimate owner (GUO) is an intra-group arrangement, not an IJV. Examples are Balenciaga Logistica (Kering Italia and Kering Holland) and KPIT Technologies GmbH (two KPIT entities). The current frame rules do not exclude these. They are excluded from all usable counts below: 5 of 100 JVs in pilot 1 and 32 of 100 in pilot 2.

## Pilot 1: whole frame

33 of 100 JVs had any name candidate in Revelio, and 19 were accepted automatically. Of 213 parents, 92 matched directly, and 35 of 53 distinct GUOs matched. 33 JVs have two or more parents with a Revelio group.

| Tier | JVs matched | Usable IJVs (>= 20 employees, >= 3 years) | Staff from at least one parent | Staff from both parents |
|---|---|---|---|---|
| Automatic name matches | 19 | 7 | 3 | 1 |
| Plus strong website matches | 28 | 14 | 4 | 1 |
| Plus all review-tier matches | 43 | 19 | 4 | 1 |

Person-years by origin (strong tier): no prior position on record 47.0%, external host-country hire 36.0%, external international hire 12.7%, parent A 3.5%, parent B 0.9%. Cells with at least 5 employees: 625 function-year and 475 seniority-year cells. Usable IJVs by exposure group (automatic / strong / all review): UK-EU 1 / 3 / 3, OECD screening 1 / 4 / 7, China coercion 1 / 1 / 1, Russia 0 / 0 / 0, unexposed 4 / 6 / 8.

Projection to the 12,074-JV frame, weighted by exposure group: about 1,000 usable IJVs (automatic) to 2,100 (strong) to 3,100 (all review). IJVs with staff from both parents project to about 170, a figure that rests on one pilot JV (Chery Jaguar Land Rover).

## Pilot 2: large-JV stratum

The stratum holds eligible JVs not in pilot 1 with an Orbis headcount of at least 100 and at least two parents found in Revelio by name, directly or through their GUO: 608 of the 2,171 JVs with 100 or more employees. The median Orbis headcount of the drawn JVs is 342.

44 of 100 JVs had any name candidate, and 30 were accepted automatically. Of 205 parents, 161 matched, and 55 of 61 distinct GUOs matched. 97 of 100 JVs have two or more parents with a Revelio group.

| Tier | JVs matched | Usable IJVs | Staff from at least one parent | Staff from both parents |
|---|---|---|---|---|
| Automatic name matches | 30 | 19 | 8 | 0 |
| Plus strong website matches | 36 | 20 | 9 | 0 |
| Plus all review-tier matches | 51 | 25 | 14 | 0 |

Person-years by origin (strong tier): no prior position on record 49.4%, external host-country hire 37.0%, external international hire 11.2%, parent A 2.3%, parent B below 0.1%. Cells with at least 5 employees: 1,398 function-year and 1,113 seniority-year cells. Usable IJVs by exposure group (automatic / strong / all review): UK-EU 4 / 4 / 5, OECD screening 4 / 5 / 5, China coercion 0 / 0 / 1, Russia 0 / 0 / 1, unexposed 11 / 11 / 13.

Projection to the 608-JV stratum, weighted by exposure group: about 130 to 170 usable IJVs, and none with staff from both parents.

## Recommendation (agent's view; the PI decides)

Go for a localization-based design; no-go for cross-parent integration as a primary measure.

The second pilot settles the open question from pilot 1. Large JVs match far better: nearly all have both parents in Revelio, and in the strong tier usable IJVs per 100 drawn rise from 14 to 20. Yet not one of them shows employees from both parents, and parent-origin staff fall to 2.3% of person-years. The scarcity of parent-origin staff is therefore a property of the data, not of matching or JV size. A plausible reason is that seconded managers list the parent, not the JV, as their employer, so Revelio files them under the parent. That cannot be verified with these data. Cross-parent integration and parent dominance (research idea sections 6.1 and 6.2; H1, H3 and H5) cannot be measured at scale.

Localization can. Function and seniority cells survive at the baseline threshold of 5 in both pilots. The whole frame projects to roughly 1,000 to 3,100 usable IJVs, above the 300 to 800 target, while the large stratum alone projects to only 130 to 170. The full sample should therefore come from the whole frame, with the intra-group exclusion added. Hypotheses H2 and H4, and hierarchy contrasts in localization, are feasible. H1, H3 and H5 would need a restatement in localization terms, or a different source for parent staffing, such as BoardEx for senior executives.

## Quality checks run

- All scripts run top to bottom from `code/R/00_setup.R` with no manual steps. Re-running the extraction regenerates an identical pilot 1 draw, and pilot 1's summary is identical after the refactor that added pilot 2 (`all.equal` on the saved summary).
- Function checks: `Rscript code/R/tests/test-functions.R`, 22 of 22 pass.
- Every accepted JV match in both pilots was inspected by name, country, Orbis headcount and first Revelio start date. This led to the host-country and parent-entity guards (pilot 1) and to the intra-group finding (pilot 2).
- Cell-years before the JV's incorporation year are excluded and counted separately.
- Parent-origin absence was checked without the three-year origin window: for most usable JVs, no employee was ever at either parent family at any time.
- A first frame run lost 92% of parent names to a lookup gap. The fix took names and types from each JV's own shareholder table, which cut missing parent names to 4 of 188,348 rows.

## Known weaknesses and uncertainties

- Survivor bias: the frame contains only JVs active today with an unchanged multi-parent structure.
- Proxies: incorporation date stands in for formation date and the current equity share for the share at formation.
- The intra-group rule uses the Orbis GUO only. It misses groups recorded under two GUO identifiers (for example VNV Global and VNV Cyprus), and the frame still contains listed companies with two corporate blockholders (for example Kolon Industries) and private-equity-backed firms.
- Exposure groups and the two-country rule use the direct shareholder's country, not the GUO's.
- Pilot 1 has no North American JVs, and 41 of its 100 JVs have no NACE code.
- Revelio coverage of China-hosted JVs is weak, and Russia has almost no usable JV in either pilot.
- The review tier is unverified. The strong subset looks correct on inspection in pilot 1. The full tier contains clear errors in both pilots.
- About half of JV person-years have no prior position on record.
- All per-group counts are small.
- Revelio seniority (1 to 7) and the `role_k10_v3` taxonomy are not yet mapped to the project's levels and nine functions; that is set at gate 5.

## Decisions required from the PI

1. Design: accept go for localization with cross-parent integration dropped as a primary measure, reject, or ask for changes. If accepted, decide how H1, H3 and H5 are restated, or whether BoardEx is used for senior parent staffing.
2. Frame rules: approve the corporate parent types, the 20 to 90 percent share band, two or three parents, active status and incorporation 2005 to 2023. Add the proposed intra-group exclusion (two or more distinct GUOs required), and decide whether to exclude listed JVs.
3. Country basis: direct shareholder country (current) or GUO country for the two-country rule and the exposure groups.
4. Review tier: check `data/interim/pilot-jv-review-tier.csv` and `pilot-large-jv-review-tier.csv`, and decide whether the strong website tier counts as accepted.
5. Deal data: whether to ask the library about the SDC joint-ventures module, which would give formation dates and dissolved JVs.

## Proposed changes to earlier stages

- `data/raw/extraction-spec-orbis.md`: annotated as superseded for the pilot by the WRDS ownership route (done; the spec belongs to Stage 4).
- Gate 5a / `/shock-options rescore`: use the usable-IJV counts by exposure group for both pilots. China coercion and Russia have almost no usable IJVs. US Entity List exposure needs a name match against the list before it can be counted.
- Research idea, section 6, and the hypotheses: if the design decision is accepted, restate H1, H3 and H5 in localization terms or find a separate source for parent staffing.

## PI notes (filled in by the PI; applied by the orchestrator if status is APPROVED WITH CHANGES)

- 
