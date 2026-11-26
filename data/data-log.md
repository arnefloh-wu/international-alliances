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

## Collection Event: 2026-11-25 (Orbis industry codes of the IJV parents)
- Purpose: parent industry for the resource-dependence check (robustness 19 of the pre-analysis plan, gate 5)
- PI go-ahead: in chat on 2026-11-25, "Accept all" on the definition of the check, which named the pull (`docs/decisions.md`, Decided, "Resource-dependence check"); "Yes, run both"
- Source: WRDS, `bvd_orbis_large`, `bvd_orbis_medium`, `bvd_orbis_small`, tables `ob_industry_classifications_{l,m,s}`
- Script: `code/R/wrds/15_wrds_parent_industry.R` (`Rscript code/R/wrds/15_wrds_parent_industry.R`), rule in `code/R/functions/parent_industry.R`
- Frame and sample: matched dataset v3 (2026-10-09), all 15,672 direct parents of the 7,460 `core_main` IJVs and their 13,295 ultimate owners (22,434 distinct ids)
- Columns pulled: `bvdid`, `nace2_main_section`, `nacepcod2`, `naicspcod2017`; no names, descriptions or financials
- Output: `data/raw/orbis-parent-industry-2026-11-25.parquet` (45,873 rows for 14,240 of the 22,434 ids; all rows kept) and `data/interim/parent-industry-v1-2026-11-25.csv` (one row per parent); log `data/interim/wrds-parent-industry-log-2026-11-25.md`
- Flags (of 15,672 parents): absent from the industry table 3,802 (24.3%), of which 2,798 are Capital IQ parents with no BvD id; several industry rows 8,175 (52.2%); conflicting rows 5,098 (32.5%); holding parents 3,533 (22.5%), resolved through the ultimate owner 836 (5.3%), unresolved 2,697 (17.2%: owner without a code 1,444, own ultimate owner 918, owner also a holding 335); codes under four digits 26 (0.2%). Usable code (`rd_naics`) for 9,086 parents (58.0%); 7,460 IJVs, 3,123 (41.9%) with a code for every parent and 5,504 (73.8%) for at least one
- Handling: licensed, local only, gitignored. Pooled counts only; nothing tabulated by exposure, function or occupation
- Collector: orchestrator (Claude), on the PI's computer
- Notes: the first run's check that every code has six digits failed (Orbis stores 98 parents' codes at two to five digits); the rule now keeps codes of four or more digits and flags shorter ones (`flag_naics_short`). Capital IQ parents need another source; superseded the same day by rule v2 below

## Collection Event: 2026-11-25 (BLS OEWS industry-by-occupation estimates)
- Purpose: occupation-by-industry matrix for the resource-dependence check
- PI go-ahead: as above; the PI downloaded the file by hand because bls.gov refuses scripted downloads
- Source: U.S. Bureau of Labor Statistics, Occupational Employment and Wage Statistics, May 2021 national industry-specific estimates, https://www.bls.gov/oes/special-requests/oesm21in4.zip (linked from https://www.bls.gov/oes/tables.htm). Vintage: May 2021 is the first OEWS release based only on data collected under the 2018 SOC (https://www.bls.gov/oes/soc_2018.htm, read 2026-11-25); May 2019 and 2020 are hybrids. Public domain (U.S. government work)
- Output: `data/raw/external/oesm21in4.zip` (31,451,833 bytes, sha256 61d1eb0a77e8be523786d5bb2b1e32b41ea8c3cecf4f1ca990ab4080e7e2c04e), unchanged; it holds sector, 3-digit, 4-digit, 5- and 6-digit and ownership files (`nat4d_M2021_dl.xlsx`: 250 industry codes, of which 14 are OEWS combinations such as `3250A1`)
- Match (structural, no staffing data): of 9,060 parents with a 4-digit code, 5,590 (61.7%) match a published OEWS 4-digit industry as coded; with the 3-digit industry as fallback, 8,664 (95.6%); 396 (4.4%) match neither (government, codes under NAICS 2022, some agriculture). The 14 combined industries list their 4-digit members in the title and are not yet used
- Handling: public data, gitignored with the rest of `data/raw/`; reproducible from the URL and the hash

## Synthetic Data: 2026-11-25 (parent industry)
- Files: `data/synthetic/orbis-parent-industry-synthetic-2026-11-25.parquet`, `ijv-parents-guo-synthetic-2026-11-25.parquet` (300 parents)
- Generator: `code/R/tests/synthetic_parent_industry.R` (seed 20261125), which also tests `code/R/functions/parent_industry.R`
- Schema source: the columns of the real pull and of `ijv-parents-v3` (`parent_bvdid`, `parent_guo`)
- Simulated, not derived: made-up ids with the prefix SYN and codes from a short made-up list; every row has `synthetic = TRUE`
- Failure modes seeded (all caught): several industry rows with conflicting codes, one company in two libraries, parent without a NAICS code, parent absent from the industry table, holding parent with a usable ultimate owner, holding whose owner is a holding, holding that is its own owner, holding without an owner, holding by NACE 6420 only, four-digit and three-digit codes

## Collection Event: 2026-11-25 (Orbis core and secondary industry codes; rule v2)
- Purpose: maximize the coverage of the resource-dependence check (PI: "try to maximise the saample")
- PI go-ahead: covered by the industry-code go-ahead of 2026-11-25; scope widened in chat ("Pull Capital IQ too", "try to maximise the saample")
- Source: WRDS, `ob_industry_classifications_{l,m,s}` in the three current Orbis libraries; the `_old` libraries were tried and are not licensed (permission denied)
- Script: `code/R/wrds/15_wrds_parent_industry.R` step `secondary`
- Columns pulled: `bvdid`, `nace2_main_section`, `nacepcod2`, `naceccod2`, `nacescod2`, `naicspcod2017`, `naicsccod2017`, `naicsscod2017`
- Output: `data/raw/orbis-parent-industry-core-secondary-2026-11-25.parquet` (45,873 rows for 14,240 of 19,051 Orbis ids)
- Handling: licensed, local only, gitignored

## Collection Event: 2026-11-25 (Capital IQ industry tree of the Capital IQ parents)
- Purpose: industry for the 2,798 parents that come from Capital IQ and have no BvD id
- PI go-ahead: in chat on 2026-11-25, "Pull Capital IQ too"
- Source: WRDS, `ciq_common.ciqcompanyindustrytree`, `ciq_common.ciqsubtype` (whole industry tree), `ciq_common.ciqindustrytosic` (whole map); `ciq.wrds_entity_info` (direct NAICS) reads from `ciq_ratings`, which is not licensed (permission denied)
- Script: `code/R/wrds/16_wrds_ciq_parent_industry.R`
- Columns pulled: `companyid`, `companyindustryid`, `subtypeid`, `primaryflag`, `chartypeid`; `subtypeid`, `subtypevalue`, `childlevel`, `leafflag`, `subparentid`; `subtypeid`, `siccode`
- Output: `data/raw/ciq-parent-industry-tree-2026-11-25.parquet` (41,529 rows for 2,352 of 2,798 companies, all with a primary industry), `ciq-industry-subtype-2026-11-25.parquet` (17,981 rows), `ciq-industry-to-sic-2026-11-25.parquet` (1,760 rows, 786 Capital IQ industries)
- Handling: licensed, local only, gitignored

## Collection Event: 2026-11-25 (Census NAICS concordances)
- Purpose: SIC 1987 to NAICS 2017 for the Capital IQ parents, and NAICS 2022 to 2017 for Orbis codes coded under NAICS 2022
- PI go-ahead: in chat on 2026-11-25, "Yes, download" (five files named before download)
- Source: U.S. Census Bureau, https://www.census.gov/naics/?68967 (concordances tab), public domain
- Output: `data/raw/external/census-naics-concordances-2026-11-25/`, unchanged: `1987_SIC_to_2002_NAICS.xls` (406,016 bytes, sha256 fcb8ad7e4162a4d95c39ebe51c12e8ec20dfa6a31f2e81bf8fb1de08fbedc937), `2002_to_2007_NAICS.xls` (161,280; a4b00b2195e318420962ba52b77f3c3122e83d893a9f804e820c151847ec85b1), `2007_to_2012_NAICS.xls` (171,520; 302b8abcd78881f1ea5aa4c6c9104811bf8fa10d57b48d492939de5cacc8cfc5), `2012_to_2017_NAICS.xlsx` (58,543; 17f463f7e8385df1cc762fadf0dd5c25910aa27034ca96275a906608399188f5), `2022_to_2017_NAICS.xlsx` (61,577; 76ed2d5bc8cd3443dc86f0c3225b83e6d187f3fc47d4c5696c911a3234f1716f)

## Derived data: 2026-11-25 (parent industry, rule v2)
- Script: `code/R/wrds/15_wrds_parent_industry.R` step `resolve`, rule in `code/R/functions/parent_industry.R` (decision "coverage rule v2" in `docs/decisions.md`)
- Output: `data/interim/parent-industry-v2-2026-11-25.csv` (one row per parent; v1 of the first run kept)
- Code source (15,672 parents): own primary 8,248; own secondary 729; ultimate owner primary 781; ultimate owner secondary 37; Capital IQ tree 2,121; holding unresolved 2,154; missing 1,602. Capital IQ: primary industry 2,352, SIC reached 2,213, NAICS 2017 4-digit 2,125
- Coverage: 11,916 parents (76.0%) with a code, 11,876 with a 4-digit code, 40 short codes, 286 distinct 4-digit industries; 7,460 IJVs, 6,976 (93.5%) with a code for at least one parent, 4,442 (59.5%) for every parent. OEWS match: 4-digit 7,917, combined industry 1,597, 3-digit 2,193, none 209; 11,707 parents (74.7%) matched
- Checks: one row per parent; no holding code used; 4-digit codes where set. The simulated test caught a bug in the NAICS 2017 validity check for codes under six digits before the real run
- Handling: licensed, gitignored; pooled counts only

## Synthetic Data: 2026-11-25 (parent industry, rule v2)
- Generator: `code/R/tests/synthetic_parent_industry.R` (seed 20261125), rewritten for rule v2; files as in the entry above (240 Orbis parents plus 6 Capital IQ parents)
- Made up: ids with the prefix SYN, NAICS codes in sector 99, concordances and a small Capital IQ industry tree in the same code space; every row has `synthetic = TRUE`
- Failure modes and fallbacks seeded (all caught): conflicting rows, two libraries, parent absent (owner's code), holding with a core code, with a secondary code only, falling back to its owner, owner also a holding, own owner, NACE 64.20 with a dot, head office NACE 70.10, NAICS 2022 code, four- and three-digit codes, Capital IQ parents reached through an exact SIC code, a SIC group code and a parent node, and without a primary industry

## Synthetic Data: 2026-11-26 (stage 6 panel build)
- Files: `data/synthetic/panel-build-synthetic-2026-11-26/` (inputs: matched IJV, parent and family tables, spells, JV positions, history and education parts, O\*NET extract and role lookup, occupation and domain scores, exposure rows, Orbis frame and headcounts, parent industry, a long OEWS table, rater scores; `seeded-cases.csv` with the expected results) and its `build/` folder (outputs of `02_build_panel.R synthetic` and `03_measures.R synthetic`); test report `data/synthetic/panel-build-test-synthetic-2026-11-26.md`
- Generator: `code/R/tests/synthetic_panel_build.R` (seed 20261126); test: `code/R/tests/check_panel_build.R`
- Schema source: the columns of every real input named in `panel_config()` (`code/R/functions/panel_build.R`)
- Simulated, not derived: 12 made-up IJVs (ids with the prefix SYN), about 560 JV positions and 1,200 history positions; real O\*NET code labels with made-up scores; invented industries, OEWS rows and rater scores; every table carries `synthetic = TRUE`
- Failure modes and edge cases seeded (all handled, 92 of 92 checks pass): repeated position ids in spells, JV positions and histories; a person whose only JV position has no start date and one with an undated plus a dated position; history positions without a start date and one ending before it starts; open-ended JV and parent positions; a person at two IJVs; hires in 2008 (kept for the full period), 2026 (dropped) and before the formation year (dropped); a parent's own entity matched as the IJV; an entity in two parents' families; origin windows of 1, 3 and 5 years; an entrant; an unmapped employer; a prior position without a country; a home-country parent hire; an invalid O\*NET value; a lookup-coded position; missing seniority; a first JV position that covers no 30 June; S13 coding (exposed, controls, the owner-level control with a UK owner, third-country pair, GB-IE, Rule C bands, dyads); listed flags; the country code NA (Namibia)

## Derived data: 2026-11-26 (stage 6 panels)
- Purpose: the IJV x domain x year and IJV x level x year panels of the approved pre-analysis plan pap-v1.0 (stage 6, `/panel-build`); no new extraction, no WRDS connection
- Scripts: `code/R/02_build_panel.R` (hires, staffing frame, entrants, employee stocks), `code/R/03_measures.R` (cell-year panels), helpers in `code/R/functions/panel_build.R`, `measures.R`, `panel_ijv.R`, `resource_dependence.R`
- Inputs: matched dataset v3, career histories, JV positions, O\*NET extract and role lookup, education records, contingency scores, S13 exposure rows, Orbis frame and headcounts, parent industry (rule v2), BLS OEWS May 2021, rater scores
- Outputs (licensed, gitignored): `data/processed/panel-ijv-{domain,domain-b,level,level-b,seniority,function,role50}-year-v1.parquet`, `panel-ijv-attributes-v1.parquet`, `panel-ijv-year-v1.parquet`, `sample-construction-log.md`; person-level interim files `data/interim/panel-*-v1.*`; structure report `data/interim/panel-structure-v1-2026-11-26.md`
- Counts (structural): 7,460 IJVs; 3,831,791 person-IJV pairs; 3,665,781 hires from the formation year to 2025 (106,201 hired before the formation year and 59,809 in 2026 left out), 3,022,586 of them in 2010 to 2025; domain panel 2,474,677 cell-years (1,840,799 in 2010 to 2025, 490,926 with at least 5 employees, 122,839 with at least 5 hires); level panel 528,560 cell-years (355,427; 213,010; 82,381). Hires of 2010 to 2025: history not observed 25.9 percent (entrants 11.3, unknown 14.7); prior employer unmapped for 18.7 percent of hires with an observed history; occupation from the role lookup 5.4 percent; no usable occupation 0.25 percent. Parents matched to an OEWS industry: 11,707
- Checks: identities of A3 on every row of every panel; cell hires sum to the hires of the grain; one row per key; an independent recomputation for 150 random IJVs (79,469 hires) agrees for every hire on the categories of the 1-, 3- and 5-year windows and on the entrant flag; the synthetic build passes 93 of 93 checks; the schema of the real domain, domain-b and level panels matches the stage 7 helpers (column names only read)
- Handling: licensed, local only, gitignored; nothing tabulated by exposure, host-country parent, score, domain, level or year; no model estimated
