# Gate 4: Pilot feasibility and go/no-go

Status: PENDING
Approved by:
Stage: 4 Pilot feasibility
Agent: data-engineer (run by the orchestrator in the PI's local session, WRDS access)
Date produced: 2026-10-08 (pilot 1 and, at the PI's request, pilot 2 on large JVs); updated 2026-10-09 with the full-frame runs (frames v1 to v3)

## Deliverables

| Deliverable | Path | Notes |
|---|---|---|
| WRDS extraction script | `code/R/wrds/02_wrds_pilot_extract.R [main\|large]` | Builds the IJV frame from Orbis ownership links, draws a pilot (main: seed 20261008; large: seed 20261009), pulls Revelio candidates and position histories. Resumes from cached stages. |
| Matching and coverage script | `code/R/01_pilot_matching.R [main\|large]` | Name matching with guards, review tier, GUO-level parent families, coverage per matching tier. |
| Matching and frame helpers, tests | `code/R/functions/matching.R`, `frame.R`, `external.R`, `code/R/tests/test-functions.R` | `web_domains()`, `review_tier_candidates()`, region/industry/exposure classification, `wide_to_long()`; 23 of 23 checks pass. |
| Pilot feasibility report | `code/quarto/pilot-feasibility-report.qmd`, rendered with `-P pilot:main` and `-P pilot:large` to `pilot-feasibility-report(.html/.docx)` and `pilot-feasibility-report-large(.html/.docx)` (renders not committed) | Every figure is computed from the files below. |
| Frame exports (gitignored) | `data/interim/wrds-ijv-frame-2026-10-08.csv`, `wrds-ijv-frame-groups-2026-10-08.csv`, `wrds-ijv-frame-size-2026-10-08.csv`, `wrds-large-screen-2026-10-08.csv` | Licensed data, local only. |
| Pilot exports (gitignored) | `data/raw/orbis-pilot-[large-]2026-10-08.csv`, `revelio-companies-[large-]2026-10-08.csv`, `revelio-positions-[large-]2026-10-08.csv` | Licensed data, local only. |
| Match logs for review (gitignored) | `data/interim/pilot-[large-]matches.csv`, `match-review.csv`, `jv-rejected-matches.csv`, `jv-review-tier.csv`, `parent-groups.csv`, `jv-rcids.csv`, `origin-<tier>.csv` | The review-tier files need the PI's check (24 rows in pilot 1, 21 in pilot 2). |
| Extraction log | `data/interim/wrds-extract-log-2026-10-08.md` | Timings and counts for every stage, tagged by pilot. |
| Full-frame sample script | `code/R/wrds/03_wrds_full_sample.R [v1\|v2\|v3\|v4]` | All eligible IJVs: Orbis extract, Revelio matching, manual decisions, positions at matched JVs, sample table with flags, career histories of employees of the main sample. Logs `data/interim/wrds-full-log-<version>-2026-10-09.md`. |
| Expanded frame script | `code/R/wrds/05_wrds_frame_v2.R [with_dom] [with_small] [with_prior]` | Frame v2 (relaxed Orbis rules plus Capital IQ) and v3 (plus the GUO-level rule, a 5% sample of the small library, Capital IQ prior co-ownership). |
| External-data importer | `code/R/wrds/06_ingest_external_jvs.R` | Reads deal lists from `data/raw/external/` and builds frame v4. Tested on a synthetic file. |
| Manual worklist | `code/R/wrds/07_manual_match_list.R [version]` | Builds `data/interim/manual-match-list-v3-2026-10-09.csv` (9,285 rows in four priorities). Decisions go in `data/raw/manual/` and are read by the full-sample script. |
| Route sizing script | `code/R/wrds/04_wrds_route_sizing.R` | Counts for each way of enlarging the frame; output `data/interim/route-sizing-2026-10-09.csv`. |
| Acquisition guide | `docs/data-acquisition-guide.md` | Where the sample is lost, outside sources ranked, access and export steps, file format for hand-back. |
| Full-frame outputs (gitignored) | `data/processed/sample-ijv-[v2-\|v3-]2026-10-09.csv`, `data/processed/sample-construction-log[-v2\|-v3].md`, `data/raw/orbis-full-[v2-\|v3-]2026-10-09.csv`, `data/raw/revelio-companies-full-[v2-\|v3-]2026-10-09.csv.gz`, `data/raw/revelio-jv-positions-full-2026-10-09.parquet`, `data/raw/revelio-histories-full-2026-10-09/` | Licensed data, local only. The history store holds 5,292,799 distinct users in 1,061 parts, audited with no duplicates. |
| Manual triage script | `code/R/wrds/08_triage_manual_candidates.R` | Agent triage of worklist rows with a review-tier candidate (priorities 1 and 3): accept, replace, reject or leave blank. Writes `data/raw/manual/manual-matches-claude-2026-10-09.csv` (gitignored; deleting it reverts all agent decisions) and the per-row log `data/interim/manual-triage-claude-v3-2026-10-09.csv`. |
| Matched dataset script | `code/R/wrds/09_build_matched_dataset.R [version]` | Builds the three matched tables (IJVs, IJV-parent pairs, employee spells) for the main sample and a manifest, with 8 consistency checks. Outputs `data/processed/ijv-matched-*`, `ijv-parents-*`, `ijv-employee-spells-*`, `dataset-manifest-*`. |
| Codebook | `data/codebook.md` | Frame rules (including the applied intra-group rule), Revelio field assumptions, parent families, matching tiers, frame v2 and v3 routes, sample table columns. |

## Frame

83,907 companies passed the ownership screen. 10,431 remain eligible after excluding JVs with a non-corporate parent (69,722), financial-sector JVs (2,111) and, since 2026-10-09, intra-group arrangements (1,643). Both pilots oversample JVs exposed to the shortlisted shocks. This section describes the base frame (v1); the expanded frames v2 and v3 are described in later sections.

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

Core IJVs by exposure group: OECD screening 719, unexposed 681, UK-EU 114, China coercion 9, Russia 7. Strategic core: unexposed 233, OECD screening 157, UK-EU 24, China coercion 6, Russia 1. In the first run, full career histories were pulled for the 660,211 employees of usable IJVs; the final history store is larger (see the frame v3 section).

Quality: in a random audit of 40 core IJVs, about 37 matched the right company, but only about half were joint ventures between operating companies. The rest were start-ups and small firms co-owned by founders' holding companies and investors, which Orbis also types as "Corporate". In a random audit of 30 strategic core IJVs, about 28 were joint ventures between operating companies matched to the right company (for example Maaden Barrick Copper, NEOM Green Hydrogen, Junghans Microtec, Ericsson-LG). 518 core IJVs show positions more than ten years before incorporation, so the incorporation date often does not mark the JV's formation. The strategic core is the defensible sample; the full core is the upper bound.

Usability threshold sensitivity (core / strategic core): at least 10 employees 1,904 / 506; at least 20 employees (baseline) 1,530 / 421; at least 30 employees 1,293 / 370. The minimum number of years matters little.

## Routes for enlarging the sample

The table below sets the pre-run estimates against what the runs found. Every route that can be run through WRDS has been run (frames v2 and v3). The routes still open need the PI or outside data.

| Route | Pre-run estimate (extra core IJVs) | Outcome |
|---|---|---|
| Orbis relaxations (incorporation before 2005, 10% stake, up to four parents, any status) | about 2,100 | Run in v2: 3,168 core IJVs from the relaxed rules (3,122 in v3 after de-duplication) |
| GUO-level two-country rule | not estimable (about 7,600 candidates) | Run in v3: 10,425 JVs, 1,350 core, 482 strategic |
| Capital IQ, current owners | unknown | Run in v2: 9,050 JVs not in Orbis, 1,395 core |
| Capital IQ, prior co-ownership | unknown | Run in v3: 11,581 JVs, 2,114 core, but mostly sequential acquisitions; excluded from the main sample |
| Orbis small-company library | low per JV | Run as a 5% sample: 769 JVs, 36 core, mostly investor-owned start-ups; the full library is not run |
| Lower the usability threshold to 10 employees | 374 (base frame) | Not applied; the sensitivity was computed on the base frame only |
| PI review of the review tier | up to 403 (base frame) | Open: 1,584 usable IJVs in frame v3 rest on review-tier matches |
| Manual matching of strategic JVs without a match | unknown | Open: worklist built (9,285 rows; do the first 2,823 first) |
| External sources (SDC, Orbis M&A, fDi Markets, registries) | unknown | Open: need licences or exports; steps in `docs/data-acquisition-guide.md` |

Pre-run sizing from `code/R/wrds/04_wrds_route_sizing.R` (`data/interim/route-sizing-2026-10-09.csv`) follows. The baseline reproduces the 12,074 JVs before the intra-group rule (12,072). Expected yields apply the full run's rates (core 14.7% and strategic core 4.0% of eligible JVs, 13.6% intra-group); they are rough.

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

## All routes run (frame v3, PI instruction 2026-10-09)

The PI asked for all routes to be run. Frame v3 adds the GUO-level two-country rule, a 1-in-20 sample of the Orbis small-company library and Capital IQ prior co-ownership (`data/processed/sample-construction-log-v3.md`).

| Route | Eligible | Core | Strategic core |
|---|---|---|---|
| Orbis, relaxed rules (v2) | 13,351 | 3,163 | 971 |
| Orbis, base rules | 10,414 | 1,502 | 418 |
| Capital IQ, current owners | 9,050 | 1,428 | 290 |
| Orbis, GUO-level two-country rule | 10,425 | 1,367 | 493 |
| Capital IQ, prior co-ownership | 11,581 | 2,148 | 568 |
| Orbis small library, 5% sample | 769 | 36 | 7 |
| **Total** | **55,590** | **9,644** | **2,747** |

The counts include the manual-matching decisions described below (before them the total was 9,504 core and 2,691 strategic).

Random audits of core IJVs by route:

- **Capital IQ prior co-ownership (25 audited):** mostly companies acquired in sequence, not joint ventures (Lucite International by Mitsubishi Chemical, Cardiff Software by Autonomy then Adobe, Omnipoint by Deutsche Telekom, Nadella by NTN-SNR and Timken). Hitachi Solutions Germany has two Hitachi entities as owners. About 5 of 25 look like real JVs (Sondel, SAE Institute Dubai). The high core rate (18%) reflects that established operating companies match Revelio easily, not that they are IJVs. Excluded from the main sample.
- **GUO-level rule (20 audited):** about 8 of 20 are real JVs between operating firms (Shell North China Petroleum, Yanchang and Shell, Recyfuel, Ace Hardware Philippines, Jj-Lapp); the rest are investor holding structures. The strategic flag separates them; the 482 strategic core IJVs are the reliable part.
- **Small library, 5% sample (12 audited):** nearly all investor-owned start-ups (Rushfiles, Balanco Accounting, Wunderfish). The full library would add about 720 core IJVs of this kind and is not run.

`core` (9,644) stays the upper bound. The recommended analysis sample is `core_main`: **7,460 IJVs, of which 2,172 are strategic**. Main sample by exposure group (strategic in brackets): OECD screening 3,638 (944), unexposed 3,211 (1,032), UK-EU 485 (136), China coercion 86 (54), Russia 40 (6). By region: Western Europe 3,378, South and Southeast Asia 1,468, East Asia and Pacific 860, Middle East and Africa 621, Central and Eastern Europe 527, Latin America 353, North America 253.

Where the 55,590 are lost: no accepted Revelio entity 59.6%, matched but under 20 employees 15.9%, matched with no employee after formation 5.2%, review tier only 1.9%, core 17.3%. The frame is not the binding constraint; matching and Revelio coverage are.

Career histories (all positions before and after the JV spell) were downloaded for the employees of the main sample and of the earlier v1 and v2 core samples: 5,292,799 distinct users in 1,061 parquet parts. Every employee in the matched dataset's spell table has a history.

Formation dates: of the 7,460 main-sample IJVs, 1,484 (19.9%) were incorporated before 1990 and 4,014 (54%) before 2005, and 199 Capital IQ JVs have no founding year (set to 1990 and flagged). For these the incorporation date does not mark the start of the joint venture, so panels begin mid-life, not at formation.

## Manual matching: agent triage (2026-10-09)

The manual worklist (`data/interim/manual-match-list-v3-2026-10-09.csv`, 9,285 rows in four priorities) was started with an agent triage of the rows that carry a review-tier candidate (priorities 1 and 3, 2,186 rows) by `code/R/wrds/08_triage_manual_candidates.R`. The rules are strict and deliberately leave most rows blank:

- **Accept** when the first candidate's name equals the JV's name once legal forms, punctuation and spacing are removed (and Revelio headcount is not more than 20 times Orbis headcount where Orbis reports 10 or more). **Replace** when the same holds for exactly one of candidates 2 and 3. A name that differs only by a holding or group word, or by Danish A/S against ApS, does not count as equal.
- **Reject** when the first candidate is a parent's own entity, or shares no content word with the JV's name and has a name similarity below 0.6. JVs with abbreviated names and non-Latin-script candidates are never rejected.

Result: 103 accepts, 109 replaces, 464 rejects and 1,510 rows left for a person (priority 1: 688 left; priority 3: 822 left). Priorities 2 (1,847 larger strategic IJVs without a candidate) and 4 (5,252) were not touched.

Effect on the sample: 212 positive decisions, of which 141 are usable IJVs. The recommended sample rose from 7,354 to 7,460 (strategic 2,127 to 2,172) and the upper bound from 9,504 to 9,644 (strategic 2,691 to 2,747).

Quality: a random audit of the first version (28 accepts, 28 replaces, 40 rejects) found 27, 27 and 38 correct, about 95 percent. The three kinds of error it found (Danish company form, a holding entity matched to the operating company, abbreviations such as NZ for New Zealand) are blocked in the final rules. The final rules were not audited again. The decisions are labelled `claude` in the sample table (`manual_by`), are not verified by a person, and are overridden by any decision a person makes on the same IJV. Deleting `data/raw/manual/manual-matches-claude-2026-10-09.csv` reverts all of them. The decisions per row are in `data/interim/manual-triage-claude-v3-2026-10-09.csv` for spot checks.

## Matched dataset (2026-10-09)

`code/R/wrds/09_build_matched_dataset.R` builds the matched dataset for the 7,460 main-sample IJVs as three tables with the shared key `jv_bvdid` in `data/processed/` (licensed data, local only):

| Table | Rows |
|---|---|
| `ijv-matched-v3-2026-10-09.csv`: one row per IJV (identifiers, host, industry, formation year, parents A and B, match tier and quality, coverage, flags) | 7,460 |
| `ijv-parents-v3-2026-10-09.csv`: one row per IJV-parent pair, with ultimate owner and Revelio family size | 17,015 |
| `ijv-employee-spells-v3-2026-10-09.parquet`: one row per Revelio position at the matched JV entity from the formation year on, with function, seniority, dates and the number of 30 June reference dates covered | 4,973,926 positions, 3,760,920 people |

Eight consistency checks pass, among them that the spell table reproduces the employee counts and the observed years of the sample table for all 7,460 IJVs. This dataset is not the Stage 6 panel: no function or seniority mapping, no parent-origin classification and no measures are built, because they need the approved pre-analysis plan (gate 5).

## Data sources for further enlargement

| Source | Status | What it adds |
|---|---|---|
| Orbis ownership links (WRDS) | licensed, used | Frames v1 to v3, including the GUO-level two-country rule (10,425 JVs). The small-company library was run on a 5% sample only. |
| Revelio (WRDS) | licensed, used | Workforce data; coverage of China-hosted JVs is the weakest link. |
| Capital IQ ownership relations (WRDS) | licensed, used | Second frame; 9,050 current-owner JVs not in Orbis. Prior co-ownership relations were run (11,581 JVs) and audited: mostly sequential acquisitions, so excluded from the main sample. |
| BoardEx (WRDS) | licensed, not used | Senior executives and directors with prior employers; a source for parent-origin staffing at the top, not for sample size. |
| FactSet entity data (WRDS) | licensed, small edition | 624,000 entities with LEIs only; little gain for matching. |
| SDC joint ventures and alliances (WRDS schema `tr_sdc_joint_ventures`) | not licensed | JV records with participants, announcement and status, from 1988 according to library guides; would give formation dates and dissolved JVs. Alliance databases each capture only part of announced alliances (Schilling 2009, as summarized in library sources). |
| FactSet Revere relationships (WRDS `factset_revere_*`) | not licensed | Relationship type "Partner - Joint Venture" exists in FactSet's type map. A relationship links two partner companies and does not identify the JV entity, so it adds no JV with a workforce of its own. Revelio carries `factset_entity_id` for 5.4 million companies, so the partners link to Revelio, but the JV entity would still have to be found, for example from Orbis co-ownership, which the frame already does. Low value for sample size (corrected 2026-10-09; the first version of this row overstated it). |
| Orbis M&A (formerly Zephyr) | not on WRDS; Moody's / BvD subscription | Deal records including the joint-venture deal type, no minimum deal value; formation dates and parents for JVs formed by deal. |
| fDi Markets (Financial Times) | not licensed | Greenfield projects from 2003, including JVs that create a new physical operation; announcement dates and partners. |
| PitchBook, Preqin (WRDS) | schemas visible, not licensed | Not assessed further. |

## Recommendation (agent's view; the PI decides)

Go for a localization-based design; no-go for cross-parent integration as a primary measure.

The second pilot settles the open question from pilot 1. Large JVs match far better: nearly all have both parents in Revelio, and in the strong tier usable IJVs per 100 drawn rise from 14 to 20. Yet not one of them shows employees from both parents, and parent-origin staff fall to 2.3% of person-years. The scarcity of parent-origin staff is therefore a property of the data, not of matching or JV size. A plausible reason is that seconded managers list the parent, not the JV, as their employer, so Revelio files them under the parent. That cannot be verified with these data. Cross-parent integration and parent dominance (research idea sections 6.1 and 6.2; H1, H3 and H5) cannot be measured at scale.

Localization can. Function and seniority cells survive at the baseline threshold of 5 in both pilots. The full runs bear this out: the base frame gives 1,530 core IJVs, frame v2 gives 6,139 and frame v3 gives 9,644, with 7,460 in the recommended main sample, all above the 300 to 800 target. The large stratum alone would give only 80 to 100. The sample therefore comes from the whole frame, with the intra-group exclusion applied. Hypotheses H2 and H4, and hierarchy contrasts in localization, are feasible. H1, H3 and H5 would need a restatement in localization terms, or a different source for parent staffing, such as BoardEx for senior executives.

## Quality checks run

- All scripts run top to bottom from `code/R/00_setup.R` with no manual steps. Re-running the extraction regenerates an identical pilot 1 draw, and pilot 1's summary is identical after the refactor that added pilot 2 (`all.equal` on the saved summary).
- Function checks: `Rscript code/R/tests/test-functions.R`, 23 of 23 pass.
- Regression after the last pipeline patch: the v1 and v2 reruns give 1,530 and 6,139 core IJVs and identical shared columns against the saved references; v1 gained two columns (`route`, `core_main`).
- The career-history store was audited after the full download (all parts scanned for repeated users): 1,061 parts, 5,292,799 distinct users, none duplicated. Two earlier duplicate downloads were removed and their cause fixed.
- Manual decisions (accept, reject, LinkedIn replace) and the external importer were tested on synthetic files and the test files removed.
- Every accepted JV match in both pilots was inspected by name, country, Orbis headcount and first Revelio start date. This led to the host-country and parent-entity guards (pilot 1) and to the intra-group finding (pilot 2).
- Cell-years before the JV's incorporation year are excluded and counted separately.
- Parent-origin absence was checked without the three-year origin window: for most usable JVs, no employee was ever at either parent family at any time.
- A first frame run lost 92% of parent names to a lookup gap. The fix took names and types from each JV's own shareholder table, which cut missing parent names to 4 of 188,348 rows.

## Known weaknesses and uncertainties

- Survivor bias: the frame contains only JVs active today with an unchanged multi-parent structure.
- Proxies: incorporation date stands in for formation date and the current equity share for the share at formation. In the main sample 19.9% of IJVs were incorporated before 1990 and 54% before 2005, so for many the observed ownership structure is much younger than the company.
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
4. Review tier: check `data/interim/pilot-jv-review-tier.csv` and `pilot-large-jv-review-tier.csv` for the pilots, and work through the manual worklist `data/interim/manual-match-list-v3-2026-10-09.csv` for the full frame (priorities 1 and 2 first). Decide whether the strong website tier counts as accepted.
5. Deal data: whether to ask the library about the SDC joint-ventures module, which would give formation dates and dissolved JVs.
6. Sample definition: the PI chose the upper bound on 2026-10-09. After the audits of frame v3 the data-engineer recommends `core_main` (7,460 IJVs, 2,172 strategic) as the analysis sample and `core` (9,644) as the upper bound for robustness checks; confirm or choose. The 212 agent-made manual matches are included in both; excluding them would give 7,354 and 9,504. Open: the usability threshold (20 employees by default).
7. Enlargement routes still open (all WRDS routes have been run): manual matching and review-tier checking (the worklist is built; the agent triaged 2,186 rows, and a person still has to check the agent's decisions and work the 1,510 rows left blank plus priorities 2 and 4), the SDC licence, an Orbis M&A export, and other outside lists through the importer. The agent's order of value for cost: manual matching and review-tier checking first, then SDC and Orbis M&A. It does not recommend running the full small-company library.

## Proposed changes to earlier stages

- `data/raw/extraction-spec-orbis.md`: annotated as superseded for the pilot by the WRDS ownership route (done; the spec belongs to Stage 4).
- Gate 5a / `/shock-options rescore`: use the usable-IJV counts by exposure group for both pilots. China coercion and Russia have almost no usable IJVs. US Entity List exposure needs a name match against the list before it can be counted.
- Research idea, section 6, and the hypotheses: if the design decision is accepted, restate H1, H3 and H5 in localization terms or find a separate source for parent staffing.

## PI notes (filled in by the PI; applied by the orchestrator if status is APPROVED WITH CHANGES)

- 
