# Data log

One entry per extraction, newest at the bottom, kept by `/data-collector`
(`.claude/skills/data-collector/SKILL.md`). The file is tracked in Git and
holds aggregated counts only: no row of licensed data, no name, no id.

Created on 2026-11-23. The entries dated before that day are pointers to
extractions that ran before the log existed. Their counts are copied from
the run logs in `data/interim/` and from the manifest in `data/processed/`,
which stay the record; nothing was pulled again to write them.

Handling that applies to every collection event: Orbis, Capital IQ, Revelio
and BoardEx data are licensed to the institution, stay local under
`data/raw/`, `data/interim/` and `data/processed/`, and are gitignored. The
repository folder sits in Dropbox, so the extracts sync there; whether the
licences allow that is an open item in `docs/decisions.md` (2026-10-02). No
ethics approval is required on file (PI, 2026-11-23). No extraction is
counted by shock exposure group to decide what to pull; the two pilot draws
of 2026-10-08 were stratified by exposure group as a sampling design.

## Collection Event: 2026-10-08 (catalogue)
- Purpose: find out which Orbis and Revelio tables the WRDS subscription includes (stage 4)
- PI go-ahead: 2026-10-07 and 2026-10-08, `docs/decisions.md` (data access through WRDS; connection established)
- Source: WRDS information schema
- Script: `code/R/wrds/01_wrds_discover.R`
- Frame and sample: none; a catalogue of libraries, tables and columns
- Output: `data/interim/wrds-libraries.csv`, `data/interim/wrds-catalog.csv`
- Handling: catalogue of a licensed service, local only, gitignored
- Collector: PI's computer, data-engineer agent
- Notes: not licensed: Amadeus, Osiris, SDC joint ventures and M&A. No Orbis Crossborder Investment or Zephyr library on WRDS

## Collection Event: 2026-10-08 (pilot frame and two pilots)
- Purpose: IJV frame from Orbis ownership links and two 100-IJV pilots (stage 4, gate 4)
- PI go-ahead: 2026-10-08, `docs/decisions.md` (frame from the Orbis ownership tables; second pilot from the large-JV stratum)
- Source: WRDS `bvd_orbis_large`, `bvd_orbis_medium` (ownership links, shareholders, company tables); `revelio` (company mapping, positions)
- Script: `code/R/wrds/02_wrds_pilot_extract.R [main|large]`
- Frame and sample: base frame of 2026-10-08, before the intra-group rule: 188,348 JV-parent rows, 83,907 JVs, 12,074 eligible. Pilot 1: 100 IJVs from the whole frame. Pilot 2: 100 IJVs from the large-JV stratum
- Columns pulled: as listed in `data/raw/extraction-spec-orbis.md` and `extraction-spec-revelio.md`
- Output: `data/raw/orbis-pilot-2026-10-08.csv` (213 JV-parent rows, 100 JVs); `data/raw/revelio-companies-2026-10-08.csv`; `data/raw/revelio-positions-2026-10-08.csv` (75,201 rows, 12,302 users, 54 JV entities); `data/raw/orbis-pilot-large-2026-10-08.csv` (207 JV-parent rows, 100 JVs); `data/raw/revelio-companies-large-2026-10-08.csv` (20,274 rows); `data/raw/revelio-positions-large-2026-10-08.csv` (545,157 rows, 97,399 users, 68 JV entities)
- Flags: matching tiers and review tier, `data/codebook.md` ("Entity matching tiers")
- Handling: licensed, local only, gitignored
- Collector: PI's computer, data-engineer agent
- Notes: run log `data/interim/wrds-extract-log-2026-10-08.md`. The main-pilot files were rewritten within the day as the matching routes were extended; the counts are those of the last write. The frame holds surviving JVs only

## Collection Event: 2026-10-09 (frames v2 and v3)
- Purpose: enlarge the frame (relaxed Orbis rules, Capital IQ, owner-level country rule, small-library sample, Capital IQ prior co-ownership), gate 4
- PI go-ahead: 2026-10-09, `docs/decisions.md` (upper-bound sample and frame v2; "run all routes" for v3)
- Source: WRDS `bvd_orbis_large`, `bvd_orbis_medium`, `bvd_orbis_small` (1-in-20 sample), `ciq` ownership relations
- Script: `code/R/wrds/05_wrds_frame_v2.R [with_dom] [with_small] [with_prior]`; sizing in `04_wrds_route_sizing.R`
- Frame and sample: frame v2 32,945 JVs (Orbis 23,765, Capital IQ 9,180); frame v3 55,590 JVs (Orbis 34,959, Capital IQ 20,631)
- Output: `data/interim/wrds-ijv-frame-v2-2026-10-09.csv`, `data/interim/wrds-ijv-frame-v3-2026-10-09.csv`
- Flags: `source`, `route`, `admitted_by`, `formation_year_missing` (`data/codebook.md`, "Frame v2")
- Handling: licensed, local only, gitignored
- Collector: PI's computer, data-engineer agent
- Notes: run log `data/interim/wrds-frame-v2-log-2026-10-09.md`. Capital IQ prior co-ownership and the small-library sample are kept out of `core_main` after the audits

## Collection Event: 2026-10-09 (full-frame extraction, matching inputs and career histories)
- Purpose: Orbis records, Revelio candidates, positions at the matched JV entities and career histories for the full frame (stage 4; inputs of the matched dataset)
- PI go-ahead: 2026-10-09, `docs/decisions.md` (full-frame sample; frame v2; all routes; "go ahead with building the dataset = matching")
- Source: WRDS Orbis libraries, `ciq`, `revelio` (company mapping, individual positions, role lookup)
- Script: `code/R/wrds/03_wrds_full_sample.R [v1|v2|v3]`, `code/R/wrds/09_build_matched_dataset.R [version]`
- Frame and sample: frame v1 (21,838 JV-parent rows, 10,431 JVs), v2 (72,878 rows, 32,945 JVs), v3 (126,540 rows, 55,590 JVs). Career histories for the users of usable IJVs. Matched dataset for `core_main`
- Columns pulled: positions and histories: user id, position id, entity, dates, country, seniority, role codes; no names or profile links (`data/codebook.md`, "Matched dataset")
- Output: `data/raw/orbis-full-<run>.csv`; `data/raw/revelio-companies-full-<run>.csv.gz`; `data/raw/revelio-jv-positions-full-2026-10-09.parquet` (11,555,598 rows, 8,876,872 users, 21,426 entities); `data/raw/revelio-histories-full-2026-10-09/` (1,061 parts; 29,535,144 positions of 5,292,799 people, counted on 2026-11-23). Derived: `data/processed/sample-ijv-<run>.csv`, and for `core_main` of v3 `ijv-matched`, `ijv-parents`, `ijv-employee-spells` (7,460 IJVs, 17,015 parent rows, 4,973,926 spells of 3,760,920 people; `dataset-manifest-v3-2026-10-09.md`)
- Flags: see "Quality flags: 2026-11-23" below
- Handling: licensed, local only, gitignored. The history parts are the only record of the users already pulled; single parts are never deleted
- Collector: PI's computer, data-engineer agent
- Notes: run logs `data/interim/wrds-full-log-2026-10-09.md`, `-v2-`, `-v3-`. One JV entity with more than 50,000 users was skipped in the position pull. The frame cannot contain dissolved or bought-out JVs, and parents without a Revelio entity cannot be observed as prior employers

## Collection Event: 2026-10-10 (BoardEx)
- Purpose: BoardEx coverage of the main-sample IJVs and their parents (feasibility question Q5, gate 4)
- PI go-ahead: no dated row in `docs/decisions.md`; the check is reported in `reviews/gate-4-pilot.md` and was merged with pull request 21. To be confirmed by the PI
- Source: WRDS `boardex` (company profiles, director and executive employment profiles, four regional files)
- Script: `code/R/wrds/10_boardex_coverage.R [version]`
- Frame and sample: frame v3, `core_main` (7,460 IJVs) and their parents
- Output: `data/raw/boardex-company-profile-2026-10-10.parquet`, `data/raw/boardex-jv-roles-2026-10-10.parquet`, `data/raw/boardex-jv-people-roles-2026-10-10.parquet`; `data/interim/boardex-coverage-v3-2026-10-09.csv` and summary. 2,537 IJVs found with the country confirmed; 35,597 people and 55,539 roles recorded at matched JV entities
- Flags: JV match quality (name and country 2,537, name only 156)
- Handling: licensed, local only, gitignored. BoardEx records name senior people; none of these fields enters prose or the repository
- Collector: PI's computer, data-engineer agent
- Notes: summary `data/interim/boardex-coverage-summary-v3-2026-10-09.md`

## Collection Event: 2026-11-23 (annual headcounts and education)
- Purpose: feasibility questions Q4 (Revelio coverage against Orbis headcounts) and Q3 (labor market entrants among unobserved histories)
- PI go-ahead: 2026-11-23, "Yes, pull both" (`docs/decisions.md`)
- Source: WRDS Orbis key financials (large and medium libraries); `revelio` education records
- Script: `code/R/wrds/12_wrds_headcount_education.R [version] [orbis] [education]`
- Frame and sample: frame v3, `core_main`. Headcounts for the 6,032 Orbis-sourced IJVs; education for the 3,760,920 people in the spell table
- Columns pulled: headcounts: consolidation code, filing type, closing date, months, employees. Education: record number, start and end year, degree, university country. University names and fields of study were not pulled
- Output: `data/raw/orbis-jv-headcounts-2026-11-23.parquet` (44,493 records, 4,860 IJVs); `data/raw/revelio-education-full-2026-11-23/` (753 parts, 7,613,952 records, 3,302,616 people)
- Flags: headcounts: 12,873 records (28.9%) share an entity and year with another record, 13,075 (29.4%) are consolidated, 611 (1.4%) cover a year that is not twelve months
- Handling: licensed, local only, gitignored
- Collector: PI's computer, data-engineer agent (separate session)
- Notes: run log `data/interim/wrds-headcount-education-log-2026-11-23.md`. Capital IQ-sourced IJVs have no Orbis headcount

## Quality flags: 2026-11-23
- Purpose: first run of the flag code on the matched dataset v3 (`core_main`), the career histories and the annual headcounts. No new data were pulled
- Script: `code/R/wrds/13_quality_flags.R v3`, functions in `code/R/functions/quality_flags.R`; the same code caught all 18 seeded failures in the synthetic tables first
- Output: `data/interim/quality-flags-v3-2026-10-09.md` (counts, and shares by region, source, match tier and start year)
- Keys: no parent row without an IJV, no IJV without a parent row or a spell, no missing host or parent country, no spell user without a career history. No main-sample IJV is in Namibia
- IJVs (7,460): first position more than ten years before incorporation 1,901 (25.5%); holding vehicle 98 (1.3%); fewer than three observed years 0; size mismatch 1 (a manual match, exempt from the rule); matched entity inside a parent's Revelio family 831 (11.1%); an entity in two parents' families 216 (2.9%)
- Spells (4,973,926): repeated position 0; start date missing 0; end before start 0; open-ended 1,582,599 (31.8%); country missing 61,047 (1.2%); start before the formation year 105,383 (2.1%); person at more than one sample IJV 175,412 (3.5%)
- Career histories (29,535,144 positions): repeated position 0; start date missing 855,916 (2.9%); end before start 0; open-ended 6,260,628 (21.2%); employer not mapped to a Revelio company 4,207,125 (14.2%); country missing 386,435 (1.3%)
- Rates that differ strongly: the unmapped-employer share of history positions falls from 30.8% for positions that started before 2000 to 9.6% for 2020 to 2026. The matched entity lies inside a parent's family for 12.7% of automatic matches and for none of the strong-tier matches. Both are open items in `docs/decisions.md`
- No row was dropped and no file was changed

## Synthetic Data: 2026-11-23
- Files: `data/synthetic/<table>-synthetic-2026-11-23.parquet` for `ijv-matched` (200 rows), `ijv-parents` (439), `parent-groups` (1,023), `ijv-employee-spells` (8,906), `revelio-histories` (18,502), `orbis-jv-headcounts` (1,049); `seeded-failures-synthetic-2026-11-23.csv`; `quality-flags-synthetic-2026-11-23.md`
- Generator: `code/R/tests/synthetic_matched.R` (seed 20261123)
- Schema source: `data/codebook.md` ("Matched dataset", "Staffing tabulations"); names, order and types compared with the six real tables on disk by `13_quality_flags.R synthetic`, all match
- Simulated, not derived: every value is drawn from a distribution; no real row was read. Ids start with `SYN`, every row has `synthetic = TRUE`, and `exposure_group` is empty
- Failure modes seeded (number seeded = number flagged): entity in two parents' families (5 IJVs); a parent's own entity matched as the IJV (3); fewer than three observed years (6); Revelio staff above 20 times the Orbis headcount (4); host country code `NA`, Namibia (8); positions that start before the formation year (40); a person at two sample IJVs (12 people); in the spell table: missing start dates (15), end before start (7), country missing (150), repeated position id (10), open-ended positions (3,772); in the histories: employer not mapped (1,536), country missing (480), missing start dates (25), repeated position id (6), open-ended positions (4,003); two account rows for one entity and year (20 entity-years)
- Not simulated: the education records, the BoardEx extracts and the frame tables
