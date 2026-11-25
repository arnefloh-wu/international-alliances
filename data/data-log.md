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
- PI go-ahead: confirmed after the fact on 2026-11-24 (`docs/decisions.md`); the check is reported in `reviews/gate-4-pilot.md` and was merged with pull request 21
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

## Collection Event: 2026-11-24 (public shock-side sources for the rescore)
- Purpose: exposure counts for `/shock-options rescore` (gate 5a, decisions 2 and 7): Entity List listings for S09, the ASPI coercion case list for S19, and EU screening adoption dates for S06
- PI go-ahead: gate 5a approved with changes on 2026-11-24 (`docs/decisions.md`), which provides for the Entity List name match and the source retries
- Source: public downloads, no licence restriction known:
  - (1) trade.gov Consolidated Screening List CSV, https://data.trade.gov/downloadable_consolidated_screening_list/v1/consolidated.csv
  - (2) ASPI, "The CCP's coercive diplomacy" (2020), PDF from ASPI's S3 bucket
  - (3) European Commission, list of national FDI screening mechanisms (update of 9 Feb 2026), from circabc.europa.eu
- Script: `code/R/06_shock_exposure.R` reads (1) and downloads it again if it is missing. The ASPI cases and the screening adoption years are typed into the script with their sources
- Frame and sample: frame v3, `core_main` (direct shareholder countries; owner countries as robustness)
- Output: `data/raw/external/`:
  - `consolidated-screening-list-2026-11-24.csv` (26,339 rows, 3,427 of them Entity List; 19,083,418 bytes; sha256 639e12a2b8f02fa462944c4e726de98c432384ae2514cfb344ff4b99c58b4ae9)
  - `aspi-ccp-coercive-diplomacy-2020.pdf` (68 pages, 100 government cases in Table 1; 7,952,164 bytes)
  - `ec-list-screening-mechanisms-2026-02-09.pdf` (31 pages; 4,871,447 bytes)
- Derived: `data/interim/shock-exposure-ijv-2026-11-24.csv` and `shock-s09-entity-list-matches-2026-11-24.csv` (row level, gitignored); aggregates in `literature/shock-scan/rescoring-counts-2026-11-24.csv`
- Flags: the screening list holds current entries only, so parties that were removed are missing. Screening adoption years outside the EU are `[unverified]` (`literature/shock-scan/rescoring.md`)
- Handling: kept under `data/raw/` (gitignored) like the other raw files. No staffing outcome is read by exposure status
- Collector: PI's computer, shock-evaluator agent

## Collection Event: 2026-11-25 (O\*NET codes and the O\*NET database)
- Purpose: O\*NET data step of the pre-analysis plan (pre-analysis plan rules, decision 1): link JV positions to O\*NET occupations for the contingency scores `coord_dependence` and `local_embeddedness`
- PI go-ahead: 2026-11-25, "Yes, run the pull" (`docs/decisions.md`); the O\*NET download was accepted with decision 1 ("Accept all", 2026-11-25)
- Source: (1) WRDS `revelio.individual_role_lookup_v3`; (2) WRDS `revelio.individual_positions`; (3) O\*NET 31.0 Database, text files, https://www.onetcenter.org/dl_files/database/db_31_0_text.zip, licence CC BY 4.0 (credit: O\*NET 31.0 Database, U.S. Department of Labor, Employment and Training Administration)
- Script: `code/R/wrds/14_wrds_onet_code.R v3 [lookup] [positions] [coverage]` for (1) and (2); (3) downloaded by hand with curl and saved unchanged
- Frame and sample: frame v3, `core_main`; the 4,973,926 positions of `ijv-employee-spells-v3-2026-10-09.parquet`. Prior employers' positions in the career histories were not pulled; the scores attach to the JV positions only
- Columns pulled: lookup: the nine role taxonomy levels, `onet_code`, `onet_title`. Positions: `position_id`, `onet_code`. No names, titles of people, salaries or free text
- Output: `data/raw/revelio-role-lookup-v3-2026-11-25.parquet` (17,000 roles, 1,010 distinct codes); `data/raw/revelio-jv-positions-onet-2026-11-25/` (995 parts, 4,817,442 positions); `data/raw/external/onet-db-31-0-2026-11-25/db_31_0_text.zip` (13,183,034 bytes; sha256 6883548adf5fde64cf6f801b35d15519c9225f2732c3cab0e281c652d16b23a9)
- Checks: no repeated position id; no position outside the spells extract; one lookup row per role
- Coverage: 4,817,442 of the 4,973,926 spell positions (96.9%) are still in `individual_positions`; 4,805,804 (96.6%) carry an occupation code after the non-occupation values are set to missing (unknown 10,842, Retired 344, On Leave 141). By start year: before 2000 97.1%, 2000 to 2009 97.3%, 2010 to 2014 97.2%, 2015 to 2019 96.9%, 2020 on 95.9%. The 70% threshold of decision 1 is met, so the position-level code is the primary link and the title mapping of `role_k50` is not needed
- Taxonomy: O\*NET-SOC 2019 (2019 codes such as 15-1252.00 and 15-2051.00 are present in the lookup, 2010 codes such as 15-1132.00 are not); 1,005 distinct occupation codes among the positions, 149 of them with a suffix other than .00. O\*NET 31.0 uses the same taxonomy
- Lookup route: through `role_k17000_v3`, 99.8% of spell positions get a code, and it agrees with the position-level code for 100.0% of the 4,805,671 positions that have both
- Handling: licensed extracts local only, gitignored; the O\*NET file is public and kept under `data/raw/external/` (gitignored) like the other raw files. Coverage was counted pooled and by start year only, not by occupation, function or exposure
- Collector: PI's computer, orchestrator following the data-collector skill
- Notes: run log `data/interim/wrds-onet-log-2026-11-25.md`. The position pull took about ten minutes. 156,484 spell positions (3.1%) are no longer in `individual_positions`, probably because Revelio has revised its position table since the extract of 2026-10-09; they keep a code through the lookup route (open item in `docs/decisions.md`)

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

## Synthetic Data: 2026-11-23 (estimation panels)
- Files: `data/synthetic/panel-ijv-function-year-synthetic-2026-11-23.parquet` (81,000 cells: 600 IJVs x 9 functions x 15 years), `panel-ijv-level-year-synthetic-2026-11-23.parquet` (36,000 cells: 4 levels), `panel-scores-function-…csv`, `panel-scores-level-…csv`, `panel-planted-effects-…csv`; results of the simulated run in `estimates-synthetic-2026-11-23.md`, `fig-event-study-synthetic-2026-11-23.png` and `estimate-recovery-synthetic-2026-11-23.md`
- Generator: `code/R/tests/synthetic_panel.R` with `code/R/functions/simulate_panel.R` (seed 20261123; the Monte Carlo check uses seeds 20261124 onward)
- Schema source: draft for the gate-5 measurement specification (hiring flows per cell in the staffing categories of `docs/research-brief.md`); the function column is `fn`. Functions, levels and contingency scores are placeholders
- Simulated, not derived: every value is drawn from a distribution. Two aggregate levels were matched to `reviews/gate-4-pilot.md` so the cells are as sparse as in the real data (about four hires per cell and year; parent-origin hires about 3 percent of observed hires in IJVs with a parent in Revelio). No function-level, level-level or year pattern of the real data was used
- Planted effects (logit scale): local share +0.25 per point of local embeddedness; local parent-origin share +0.40 per point of coordination dependence in IJVs with a host-country parent and 0 without; international parent-origin share +0.30 per point; parent-origin share +0.50 at levels with a coordination role; shock +0.20 on the local share and +0.30 per point of embeddedness after exposure, staggered 2016 to 2020 over 12 of 40 parent-country pairs; planted nulls for coordination dependence on the local share, the shock on the channel, and the scores on unobserved histories

## Synthetic Data: 2026-11-25 (O\*NET extracts)
- Files: `data/synthetic/revelio-role-lookup-v3-synthetic-2026-11-25.parquet` (1,970 roles), `revelio-jv-positions-onet-synthetic-2026-11-25.parquet` (8,879 rows)
- Generator: `code/R/tests/synthetic_onet.R` (seed 20261125), on the positions of `ijv-employee-spells-synthetic-2026-11-23.parquet`
- Schema source: the two real extracts of 2026-11-25 (`data/codebook.md`, "O\*NET codes"); the synthetic lookup keeps `role_k17000_v3`, `role_k50_v3`, `onet_code` and `onet_title`
- Simulated, not derived: made-up codes in major group 99 and roles with the prefix SYN; no real row, role or code was read. Every row has `synthetic = TRUE`
- Failure modes seeded (all found by the generator's checks): positions without a code (120), non-occupation codes "On Leave", "Retired", "unknown" (30), repeated position id (8), spell positions absent from the pull (25), a lookup role without a code (1), a spell role missing from the lookup (1). The run showed that the coverage step of `14_wrds_onet_code.R` counted non-occupation codes as valid; it was corrected before the coverage on the real pull was recorded

## Derived data: 2026-11-25 (contingency scores from O\*NET)
- Purpose: the static contingency scores and the H4 domain, fixed before any panel exists (score construction sheet, PI decisions of 2026-11-25)
- Script: `code/R/07_contingency_scores.R` (no WRDS connection)
- Inputs: the O\*NET 31.0 Database (`data/raw/external/onet-db-31-0-2026-11-25/db_31_0_text.zip`, public, CC BY 4.0) and the O\*NET codes in Revelio's taxonomy (`data/raw/revelio-role-lookup-v3-2026-11-25.parquet`, codes only). No staffing data were read
- Output: `data/processed/contingency-scores-occupation-v1-2026-11-25.csv` (1,016 codes) and `contingency-scores-domain-v1-2026-11-25.csv` (98 domains); checks in `data/interim/contingency-scores-v1-2026-11-25.md`
- Checks: alpha 0.76 (`local_embeddedness`) and 0.81 (`coord_dependence`) on 910 and 911 rated occupations; the two scores correlate 0.37 (broad sets 0.51); correlation with job zone 0.39 and 0.21. Of the 1,007 codes in Revelio's taxonomy, 103 lack O\*NET ratings: 68 imputed from the broad group, 18 from the minor group, and 17 military codes (major group 55), which O\*NET does not rate at all, from the mean of all rated occupations (PI, 2026-11-25). 96 distinct domain values of `local_embeddedness`; the three military domains share the overall mean
- Handling: derived from public data; written under `data/processed/` (gitignored) and rebuilt by the script

## Derived data: 2026-11-25 (audit sample of IJVs filed in a parent's Revelio family)
- Purpose: worksheet for the person audit of the IJVs whose matched Revelio entity lies inside a parent's Revelio family (PI decisions of 2026-11-25, "Pre-analysis plan rules, decisions 2 to 4" and "Contingency scores, decisions 8 to 10"); coding guide `docs/coauthor-notes/audit-parent-family-guide-2026-11-25.qmd`
- Script: `code/R/09_audit_parent_family_sample.R` (no WRDS connection). The flag is `flag_jv_in_parent_family` from `flag_ijvs()` in `code/R/functions/quality_flags.R`, called as in `13_quality_flags.R v3`
- Inputs: matched dataset v3 (IJV and parent tables; spell table read for its reference years only, as `flag_ijvs()` requires), `data/interim/full-parent-groups-v3-2026-10-09.csv`, `data/raw/revelio-companies-full-v3-2026-10-09.csv.gz` (Revelio company names)
- Draw: Mersenne-Twister, Inversion, Rejection; `set.seed(20261125)`; `sample()` of 100 from the flagged `jv_bvdid` sorted with `method = "radix"`; the ten PI cases with the same seed from the 100 sampled ids, sorted the same way. A rerun reproduced the same draw
- Counts: 831 of 7,460 `core_main` IJVs flagged (auto tier 818, manual 13); 100 sampled (Orbis 68, Capital IQ 32; auto 98, manual 2); 10 PI cases. In the sample, the entity lies in the family of parent A for 71 IJVs, of parent B for 21, of A and B for 5, and of a third or fourth parent for 3; 8 entities lie in two parents' families
- Missing in the sample: the Revelio name of the family head for 9 IJVs (not in the company extract); website 7, LEI 68. The Revelio name of every matched entity and of the parent's matched entity is present
- Output: `data/interim/audit-parent-family-worksheet-2026-11-25.xlsx` and `.csv` (licensed row-level data, gitignored, verified with `git check-ignore`). No staffing counts, employee numbers or Orbis headcounts in the worksheet
- Handling: the script never overwrites an existing worksheet (argument `overwrite` to force); coded copies are saved next to it with the coder's initials
