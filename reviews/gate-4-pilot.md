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
| Full-frame sample script | `code/R/wrds/03_wrds_full_sample.R` | All eligible IJVs: Orbis extract, Revelio matching, positions at matched JVs, sample table with flags, career histories of employees of usable JVs. Log in `data/interim/wrds-full-log-2026-10-09.md`. |
| Full-frame outputs (gitignored) | `data/processed/sample-ijv-2026-10-09.csv`, `data/processed/sample-construction-log.md`, `data/raw/orbis-full-2026-10-09.csv`, `data/raw/revelio-companies-full-2026-10-09.csv.gz`, `data/raw/revelio-jv-positions-full-2026-10-09.parquet`, `data/raw/revelio-histories-full-2026-10-09/` | Licensed data, local only. |
| Route sizing script | `code/R/wrds/04_wrds_route_sizing.R` | Counts for each way of enlarging the frame; output `data/interim/route-sizing-2026-10-09.csv`. |
| Codebook | `data/codebook.md` | Frame rules, Revelio field assumptions, parent families, matching tiers, proposed intra-group rule. |

## Frame

83,907 companies passed the ownership screen. 10,431 remain eligible after excluding JVs with a non-corporate parent (69,722), financial-sector JVs (2,111) and, since 2026-10-09, intra-group arrangements (1,643). Both pilots oversample JVs exposed to the shortlisted shocks.

A JV whose parents share one Orbis global ultimate owner (GUO) is an intra-group arrangement, not an IJV. Examples are Balenciaga Logistica (Kering Italia and Kering Holland) and KPIT Technologies GmbH (two KPIT entities). The PI added this exclusion to the frame on 2026-10-09. Both pilots were drawn before that and contain such cases (5 of 100 in pilot 1, 32 of 100 in pilot 2). They are excluded from all usable counts below.

## Pilot 1: whole frame

33 of 100 JVs had any name candidate in Revelio, and 19 were accepted automatically. Of 213 parents, 92 matched directly, and 35 of 53 distinct GUOs matched. 33 JVs have two or more parents with a Revelio group.

| Tier | JVs matched | Usable IJVs (>= 20 employees, >= 3 years) | Staff from at least one parent | Staff from both parents |
|---|---|---|---|---|
| Automatic name matches | 19 | 7 | 3 | 1 |
| Plus strong website matches | 28 | 14 | 4 | 1 |
| Plus all review-tier matches | 43 | 19 | 4 | 1 |

Person-years by origin (strong tier): no prior position on record 47.0%, external host-country hire 36.0%, external international hire 12.7%, parent A 3.5%, parent B 0.9%. Cells with at least 5 employees: 625 function-year and 475 seniority-year cells. Usable IJVs by exposure group (automatic / strong / all review): UK-EU 1 / 3 / 3, OECD screening 1 / 4 / 7, China coercion 1 / 1 / 1, Russia 0 / 0 / 0, unexposed 4 / 6 / 8.

Projection to the 10,431-JV frame, weighted by exposure group: about 840 usable IJVs (automatic) to 1,830 (strong) to 2,740 (all review). IJVs with staff from both parents project to about 145, a figure that rests on one pilot JV (Chery Jaguar Land Rover).

## Pilot 2: large-JV stratum

The stratum holds eligible JVs not in pilot 1 with an Orbis headcount of at least 100 and at least two parents found in Revelio by name, directly or through their GUO: 608 of the 2,171 JVs with 100 or more employees when drawn, 370 after the intra-group rule. The median Orbis headcount of the drawn JVs is 342.

44 of 100 JVs had any name candidate, and 30 were accepted automatically. Of 205 parents, 161 matched, and 55 of 61 distinct GUOs matched. 97 of 100 JVs have two or more parents with a Revelio group.

| Tier | JVs matched | Usable IJVs | Staff from at least one parent | Staff from both parents |
|---|---|---|---|---|
| Automatic name matches | 30 | 19 | 8 | 0 |
| Plus strong website matches | 36 | 20 | 9 | 0 |
| Plus all review-tier matches | 51 | 25 | 14 | 0 |

Person-years by origin (strong tier): no prior position on record 49.4%, external host-country hire 37.0%, external international hire 11.2%, parent A 2.3%, parent B below 0.1%. Cells with at least 5 employees: 1,398 function-year and 1,113 seniority-year cells. Usable IJVs by exposure group (automatic / strong / all review): UK-EU 4 / 4 / 5, OECD screening 4 / 5 / 5, China coercion 0 / 0 / 1, Russia 0 / 0 / 1, unexposed 11 / 11 / 13.

Projection to the 370-JV stratum (after the intra-group rule), weighted by exposure group: about 80 to 100 usable IJVs, and none with staff from both parents.

## Full-frame sample (PI instruction, 2026-10-09)

All 10,431 eligible IJVs were extracted and matched (`code/R/wrds/03_wrds_full_sample.R`; log in `data/processed/sample-construction-log.md`). This extends Stage 4 and does not approve this gate.

| Step | IJVs |
|---|---|
| Eligible in the frame | 10,431 |
| Any Revelio candidate | 6,240 |
| Automatic match / strong review match / other review match | 2,593 / 475 / 1,081 |
| Usable, automatic plus strong | 1,548 |
| Core sample (usable, automatic or strong, no size mismatch) | 1,530 |
| Strategic core (at least two operating-firm parents) | 421 |

Core IJVs by exposure group: OECD screening 719, unexposed 681, UK-EU 114, China coercion 9, Russia 7. Strategic core: unexposed 233, OECD screening 157, UK-EU 24, China coercion 6, Russia 1. Full career histories were pulled for the 660,211 employees of usable IJVs.

Quality: in a random audit of 40 core IJVs, about 37 matched the right company, but only about half were joint ventures between operating companies. The rest were start-ups and small firms co-owned by founders' holding companies and investors, which Orbis also types as "Corporate". In a random audit of 30 strategic core IJVs, about 28 were joint ventures between operating companies matched to the right company (for example Maaden Barrick Copper, NEOM Green Hydrogen, Junghans Microtec, Ericsson-LG). 518 core IJVs show positions more than ten years before incorporation, so the incorporation date often does not mark the JV's formation. The strategic core is the defensible sample; the full core is the upper bound.

Usability threshold sensitivity (core / strategic core): at least 10 employees 1,904 / 506; at least 20 employees (baseline) 1,530 / 421; at least 30 employees 1,293 / 370. The minimum number of years matters little.

## Routes for enlarging the sample

Counts from `code/R/wrds/04_wrds_route_sizing.R` (`data/interim/route-sizing-2026-10-09.csv`). The baseline reproduces the 12,074 JVs before the intra-group rule (12,072). Expected yields apply the full run's rates (core 14.7% and strategic core 4.0% of eligible JVs, 13.6% intra-group); they are rough.

| Route | Extra JVs at the ownership screen | Expected extra core / strategic core | Cost and caveats |
|---|---|---|---|
| Include JVs incorporated 1990 to 2004 | 5,711 | about 720 / 200 | Low cost. Panels start in 2005 or with Revelio coverage, so observation begins after formation. |
| Include JVs incorporated in any year | 7,511 | about 950 / 260 | As above; formation dates matter less once the panel is left-truncated. |
| Lower the minimum parent stake from 20% to 10% | 4,463 | about 570 / 155 | Low cost. A 10% holder is closer to a minority investor than a JV partner; equity asymmetry must be controlled. |
| All Orbis relaxations together (stake 10%, up to 4 parents, any year, any status) | 16,699 | about 2,100 / 580 | Roughly doubles the sample to about 3,650 core and 1,000 strategic core IJVs. |
| Two-country rule at the GUO level (domestic subsidiaries of foreign groups) | about 7,600 before parent-type checks (estimated from a 1-in-20 sample) | not estimable yet | Medium cost. Recovers JVs formed through local subsidiaries, common in China and the Gulf. |
| Capital IQ ownership relations (company with 2 or 3 corporate owners of 20 to 90% in at least two countries) | 11,276 (3,040 founded 2005 to 2023) | unknown; overlap with Orbis not measured | Medium to high cost: a second frame and its own Revelio matching. Covers US JVs, which Orbis barely records (26 eligible). |
| Capital IQ prior co-ownership (two or more prior corporate owners in two countries) | 59,454 | unknown | Only route to dissolved and bought-out JVs (survivor bias). No stakes recorded; noisy. |
| Orbis small-company library | about 224,000 before status, year and parent-type checks (estimated) | low per JV | High cost, low Revelio coverage of small firms. Test with a 100-JV pilot before committing. |
| Up to four parents / inactive JVs | 86 / 329 | about 10 / 40 | Negligible. |
| Lower the usability threshold to 10 employees | none | 374 / 85 | Free; thinner cells. |
| PI review of the review tier | none | up to 403 / 93 | Clerical review of matches already found. |
| Targeted manual matching of strategic JVs without an accepted match | 1,664 strategic JVs (592 in East Asia, 373 in South and Southeast Asia, 356 in Western Europe) | unknown | Research-assistant search of Revelio and LinkedIn; highest value per case. |
| SDC joint-ventures module (library licence) | not sized | unknown | Formation dates and dissolved JVs; would replace the incorporation-date proxy. |

## Upper-bound sample from frame v2 (PI decision, 2026-10-09)

The PI chose the upper bound as the analysis sample and asked for the sample to be maximized. Frame v2 relaxes the Orbis rules and adds Capital IQ (`code/R/wrds/05_wrds_frame_v2.R`; log in `data/processed/sample-construction-log-v2.md`).

| Step | IJVs |
|---|---|
| Eligible in frame v2 (Orbis 23,765, Capital IQ 9,180) | 32,945 |
| Any Revelio candidate | 21,329 |
| Automatic / strong review / other review match | 9,988 / 1,474 / 3,068 |
| Usable, automatic plus strong | 6,192 |
| Core sample (upper bound) | 6,139 |
| Strategic core | 1,681 |

| Route | Eligible | Core | Strategic core |
|---|---|---|---|
| Orbis, base rules | 10,414 | 1,498 | 421 |
| Orbis, relaxed rules | 13,351 | 3,168 | 960 |
| Capital IQ | 9,180 | 1,473 | 300 |

Within the relaxed Orbis rules (a JV can carry several): incorporated before 2005, 2,258 core; a 10 to 20 percent parent, 1,667 core; four parents, 250 core; not active, 113 core. Core by exposure group: unexposed 2,842, OECD screening 2,802, UK-EU 388, China coercion 69, Russia 38. North America rises from 12 to 255 core IJVs through Capital IQ.

Quality (random audit of 25 Capital IQ and 25 relaxed-Orbis core IJVs): about 48 of 50 matched the right company. Incorporation before 2005 adds established IJVs (for example Timet Savoie, Osram China Lighting, Brose Sitech, Webmotors). The 10 to 20 percent stake rule mostly adds start-ups with investor shareholders, not IJVs. Capital IQ adds large IJVs that Orbis lacks (for example Sadara Chemical, Tata Teleservices Maharashtra, Saudi Steel Pipes, Sollers Ford), but also intra-group cases its one-level group check misses (Lotte Chemical) and listed companies with blockholders (Ambuja Cements, Octopus Energy). The `source`, `admitted_by` and `strategic` columns allow these subsets to be dropped in robustness checks.

## Data sources for further enlargement

| Source | Status | What it adds |
|---|---|---|
| Orbis ownership links (WRDS) | licensed, used | Frame v1 and v2. The GUO-level two-country rule is implemented but not yet run (about 7,600 extra candidates before checks, estimated). |
| Revelio (WRDS) | licensed, used | Workforce data; coverage of China-hosted JVs is the weakest link. |
| Capital IQ ownership relations (WRDS) | licensed, used | Second frame; 9,180 JVs not in Orbis. Prior co-ownership relations (59,454 companies) could add dissolved JVs but record no stakes. |
| BoardEx (WRDS) | licensed, not used | Senior executives and directors with prior employers; a source for parent-origin staffing at the top, not for sample size. |
| FactSet entity data (WRDS) | licensed, small edition | 624,000 entities with LEIs only; little gain for matching. |
| SDC joint ventures and alliances (WRDS schema `tr_sdc_joint_ventures`) | not licensed | JV records with participants, announcement and status, from 1988 according to library guides; would give formation dates and dissolved JVs. Alliance databases each capture only part of announced alliances (Schilling 2009, as summarized in library sources). |
| FactSet Revere relationships (WRDS `factset_revere_*`) | not licensed | Relationship type "Partner - Joint Venture" exists in FactSet's readable type map; Revelio carries `factset_entity_id` for 5.4 million companies, so FactSet JV partners link to workforce data without name matching. |
| Orbis M&A (formerly Zephyr) | not on WRDS; Moody's / BvD subscription | Deal records including the joint-venture deal type, no minimum deal value; formation dates and parents for JVs formed by deal. |
| fDi Markets (Financial Times) | not licensed | Greenfield projects from 2003, including JVs that create a new physical operation; announcement dates and partners. |
| PitchBook, Preqin (WRDS) | schemas visible, not licensed | Not assessed further. |

## Recommendation (agent's view; the PI decides)

Go for a localization-based design; no-go for cross-parent integration as a primary measure.

The second pilot settles the open question from pilot 1. Large JVs match far better: nearly all have both parents in Revelio, and in the strong tier usable IJVs per 100 drawn rise from 14 to 20. Yet not one of them shows employees from both parents, and parent-origin staff fall to 2.3% of person-years. The scarcity of parent-origin staff is therefore a property of the data, not of matching or JV size. A plausible reason is that seconded managers list the parent, not the JV, as their employer, so Revelio files them under the parent. That cannot be verified with these data. Cross-parent integration and parent dominance (research idea sections 6.1 and 6.2; H1, H3 and H5) cannot be measured at scale.

Localization can. Function and seniority cells survive at the baseline threshold of 5 in both pilots. The whole frame projects to roughly 840 to 2,740 usable IJVs, above the 300 to 800 target, while the large stratum alone projects to only 80 to 100. The full sample should therefore come from the whole frame, with the intra-group exclusion added. Hypotheses H2 and H4, and hierarchy contrasts in localization, are feasible. H1, H3 and H5 would need a restatement in localization terms, or a different source for parent staffing, such as BoardEx for senior executives.

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
2. Frame rules: approve the corporate parent types, the 20 to 90 percent share band, two or three parents, active status and incorporation 2005 to 2023, and decide whether to exclude listed JVs. The intra-group exclusion was added on 2026-10-09.
3. Country basis: direct shareholder country (current) or GUO country for the two-country rule and the exposure groups.
4. Review tier: check `data/interim/pilot-jv-review-tier.csv` and `pilot-large-jv-review-tier.csv`, and decide whether the strong website tier counts as accepted.
5. Deal data: whether to ask the library about the SDC joint-ventures module, which would give formation dates and dissolved JVs.
6. Sample definition: decided 2026-10-09, the upper bound (core sample of frame v2, 6,139 IJVs) with the strategic, source and admission flags for robustness checks. Open: the usability threshold (20 employees by default).
7. Enlargement routes: which of the routes listed above to run. The agent's order of value for cost: incorporation from 1990, the 10% stake threshold, PI review of the review tier, the GUO-level two-country rule, targeted manual matching of strategic JVs, then Capital IQ as a second frame.

## Proposed changes to earlier stages

- `data/raw/extraction-spec-orbis.md`: annotated as superseded for the pilot by the WRDS ownership route (done; the spec belongs to Stage 4).
- Gate 5a / `/shock-options rescore`: use the usable-IJV counts by exposure group for both pilots. China coercion and Russia have almost no usable IJVs. US Entity List exposure needs a name match against the list before it can be counted.
- Research idea, section 6, and the hypotheses: if the design decision is accepted, restate H1, H3 and H5 in localization terms or find a separate source for parent staffing.

## PI notes (filled in by the PI; applied by the orchestrator if status is APPROVED WITH CHANGES)

- 
