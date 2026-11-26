# Gate 6: Panel

Status: PENDING
Approved by:
Stage: 6 Panel construction (`/panel-build`)
Agent: data-engineer
Date produced: 2026-11-26

Specification: the pre-analysis plan `reviews/gate-5-pre-analysis-plan.md`, registered as `pap-v1.0` (annotated tag object 4503a65f919a86f2589bafedbc22b4ccbe5b8cb2 on commit 911d8364faa8e9ad306137721fcbc136ba65b6a9 of `main`; `docs/decisions.md`, 2026-11-25). The gate 5 file is unchanged since the tag (`git diff pap-v1.0 HEAD` on it is empty). No amendment was made.

Independence and `real_data_lock` (`CLAUDE.md` rules 4 and 8; plan A5): no model was estimated on the real panels, and no staffing outcome was tabulated by exposure, host-country parent, contingency score, domain, level or year. This file reports denominators, cells, IJVs, years, missingness and flag rates, and the pooled share of each origin class over all hires of 2010 to 2025. Where an S13 sample is sized, the counts use employees and hires (`n_hires >= 1`), never an origin class.

Decisions of 2026-11-26 applied: the audit found 2 parent units in 100 (`docs/decisions.md`), so the 831 IJVs flagged `flag_jv_in_parent_family` stay in the main sample and the flag is kept for robustness 11; the audit verdicts were drafted with an AI tool (Codex) and reviewed and adopted by the PI, which the methods section and this file disclose; the Revelio licence runs to at least 2028 and the data reach 2026-09, so hire years 2010 to 2025 stay; missing `jv_website` and `jv_lei` stored as `""` are treated as missing (neither enters a panel); the rater scores per `role_k50` group (both scales ICC(2,k) >= 0.70) are on the role_k50 panel.

## Deliverables

| Deliverable | Path | Notes |
|---|---|---|
| Build, step 1 | `code/R/02_build_panel.R` (rewritten) | hires, staffing frame for origin windows of 1, 3 and 5 years, entrants for education windows of 1, 3 and 5 years, employee stocks per grain; resumes at step 6 on a rerun (`rebuild` forces a full run); `synthetic` runs it on the simulated twin |
| Build, step 2 | `code/R/03_measures.R` (rewritten) | cell-year panels, IJV and S13 variables, scores per grain, resource dependence, coverage ratio, sample-construction log, structure report |
| Helpers | `code/R/functions/panel_build.R`, `panel_ijv.R`, `resource_dependence.R` (new); `measures.R` (rewritten, cross-partner measures kept as a labeled legacy section) | |
| Panels (licensed, gitignored) | `data/processed/panel-ijv-domain-year-v1.parquet`, `-domain-b-year-v1`, `-level-year-v1`, `-level-b-year-v1`, `-seniority-year-v1`, `-function-year-v1`, `-role50-year-v1`; `panel-ijv-attributes-v1.parquet`; `panel-ijv-year-v1.parquet` | keys `ijv_id` x grain x `year`; every variable in `data/codebook.md`, "Panels (stage 6, 2026-11-26)" |
| Sample-construction log (gitignored) | `data/processed/sample-construction-log.md` | counts at every step from `core_main` to each panel, with the rule that removed each group |
| Structure report (gitignored, aggregates) | `data/interim/panel-structure-v1-2026-11-26.md` | source of the tables below |
| Codebook | `data/codebook.md` | identifiers, outcomes, domain characteristics, S13 variables, controls and Revelio field assumptions revised (plan A6.2); new section "Panels (stage 6)" |
| Synthetic test | `code/R/tests/synthetic_panel_build.R` (generator), `code/R/tests/check_panel_build.R` (runner and checks); `data/synthetic/panel-build-synthetic-2026-11-26/`, `data/synthetic/panel-build-test-synthetic-2026-11-26.md` | 93 of 93 checks pass |
| Independent recomputation | `code/R/tests/check_panel_recompute.R`; `data/interim/panel-recompute-check-v1-2026-11-26.md` | agreement counts only |
| Schema check against stage 7 | `code/R/tests/check_panel_build.R real`; `data/interim/panel-schema-check-v1-2026-11-26.md` | reads column names and types only |
| Unit checks | `code/R/tests/test-functions.R` | five checks added (level mappings, `coord_role`, identities, invalid O\*NET values); all pass |
| Run order, data log | `README.md`, `data/README.md`, `data/data-log.md` | |

Run commands (repository root): `Rscript code/R/tests/check_panel_build.R`, then `Rscript code/R/02_build_panel.R`, `Rscript code/R/03_measures.R`, `Rscript code/R/tests/check_panel_build.R real`, `Rscript code/R/tests/check_panel_recompute.R`. On the PI's computer each step takes a few minutes.

## Structural counts

### IJVs (all in `core_main`)

| Group | IJVs |
|---|---|
| `core_main` (every panel) | 7,460 |
| with at least one hire in 2010 to 2025 | 7,448 |
| at least one parent in Revelio (H1, H3, H4, C1) | 5,882 |
| all parents in Revelio (robustness 13a) | 2,321 |
| host-country parent (direct basis) | 6,600 |
| host-country parent with its own Revelio entity (H3 robustness) | 3,728 |
| host-country parent and at least one parent in Revelio (`h3_sample`; resolves the `[DATA]` marker of plan A4.2) | 5,159 |
| strategic | 2,172 |
| `flag_jv_in_parent_family` (kept) | 831 |
| `flag_shared_family_entity` | 216 |
| `flag_listed` (Orbis status `Listed`; no Capital IQ-sourced IJV has an ISIN in the frame) | 534 |
| `flag_pre_formation_10y` / `flag_holding_vehicle` / `flag_size_mismatch` (manual matches exempt) | 1,901 / 98 / 1 |
| `usable_30` (robustness 13e) | 6,480 |
| owner-level route | 1,367 |
| formed before 2016 / from 2021 | 6,299 / 278 |
| `host_parent_guo` missing (Capital IQ-sourced, or a GUO unknown) | 1,434 |

### S13 groups (ownership data only)

| Group | Count |
|---|---|
| exposed IJVs / exposed pairs | 394 / 28 |
| exposed with a parent in Revelio / also with a host-country parent | 311 / 230 |
| frame controls (UK, EU27, EEA, CH hosts without a UK-set link) | 3,409 |
| of these without a foreign direct parent / with a UK-set link through the ultimate owner, dropped | 912 / 104 |
| controls kept / with a parent in Revelio / control dyads | 3,305 / 2,417 / 629 |
| third-country parent-parent pairs (neither group) | 19 |
| GB-IE exposed IJVs | 31 |
| UK-hosted exposed IJVs: EU, EEA or Swiss stake above 50 (`control_linked`) / exactly 50 / below 50 | 59 / 17 / 92 |
| exposed with Ireland excluded / on the ultimate owner's country (Orbis-sourced) | 365 / 419 |
| exposed formed from 2021 / owner-level exposed / owner-level controls | 30 / 5 / 838 |

`dyad` source: exposure pair 394 IJVs, largest-equity foreign direct parent 5,754, largest-equity foreign ultimate owner 1,312, none 0. The control dyads number 629 rather than the 528 pairs of the stage 5 count because the owner-level controls now take their ultimate owner's country (decision of 2026-11-25, item 14).

### Hires

| Step | Count |
|---|---|
| person-IJV pairs in the spell table | 3,831,791 |
| with a dated first position at the JV entity (hires) | 3,831,791 |
| hired before the formation year (left out; reading 6) | 106,201 |
| hired in 2026 (left out) | 59,809 |
| hires from the formation year to 2025 (all panels, full period) | 3,665,781 |
| hires of 2010 to 2025 (main period) | 3,022,586 |
| first position covers no 30 June (occupation from the role lookup; reading 4) | 77,755 |
| all hires coded through the role lookup (`onet_source` = lookup) | 183,200 |
| no usable O\*NET code (left out of the domain panels; 7,471 in 2010 to 2025) | 10,943 |
| in occupations with imputed scores | 356,529 |
| without a seniority | 0 |
| people hired by two or more IJVs (a hire at each) | 64,325 |
| history positions of hired people / without a start date (ignored) | 22,003,228 / 104,039 |

Pooled over the 3,022,586 hires of 2010 to 2025 (sanity check; three-year origin window): history not observed 25.9 percent (labor market entrants 11.3, unknown 14.7); local parent-origin 0.92, international parent-origin 0.37, parent-origin without location 0.02, independent local 52.4, independent international 19.5, independent without location 0.88 percent. The prior employer is unmapped for 18.7 percent of hires with an observed history; 5.4 percent of hires are lookup-coded; 0.25 percent have no domain; 9.7 percent are in occupations with imputed scores. Over all years (formation to 2025) the build gives 30,565 local parent-origin hires (22,781 from the host-country parent's group) and 465,825 entrants (385,359 and 499,975 with the one- and five-year windows), against 31,121, 23,190, 467,895, 387,121 and 502,142 in the tabulations of 2026-11-23, which also counted 2026 hires: the frame reproduces the counts the plan cites.

### Panels (main period 2010 to 2025 unless stated)

| Panel | Values of the grain | Cell-years, all years | Cell-years, main period | IJVs, main | Cells with >= 5 employees (IJVs) | Cells with >= 5 hires (IJVs) | >= 3 / >= 10 employees | >= 5 employees and `n_obs` >= 1 |
|---|---|---|---|---|---|---|---|---|
| domain | 98 | 2,474,677 | 1,840,799 | 7,451 | 490,926 (6,597) | 122,839 (4,312) | 748,336 / 269,362 | 326,465 |
| domain-b (H4) | 98 | 2,467,695 | 1,835,437 | 7,451 | 490,909 (6,604) | 123,486 (4,314) | 747,192 / 269,814 | 326,864 |
| level (a) | 4 | 528,560 | 355,427 | 7,451 | 213,010 (7,390) | 82,381 (6,011) | 264,576 / 146,609 | 161,532 |
| level (b) | 4 | 505,089 | 337,882 | 7,451 | 201,894 (7,383) | 79,381 (6,051) | 249,590 / 140,530 | 153,188 |
| seniority | 7 | 810,983 | 558,583 | 7,451 | 283,468 (7,197) | 99,936 (5,246) | 373,207 / 184,203 | 209,173 |
| function (`role_k10`) | 11 | 1,029,000 | 715,514 | 7,451 | 333,301 (7,162) | 111,973 (5,158) | 444,351 / 211,621 | 243,740 |
| role_k50 | 51 | 2,320,365 | 1,717,439 | 7,451 | 493,824 (6,634) | 122,050 (4,415) | 746,520 / 270,835 | 334,397 |

Years covered: every panel runs from the IJV's formation year to 2025; the main period has 16 years (2010 to 2025). The domain panels hold 3,015,115 hires of the main period, of which 2,531,766 fall in cells with at least 5 employees.

### Estimation samples (structure only; main period, at least 5 employees)

| Sample | Cells | IJVs | IJV-years | Other |
|---|---|---|---|---|
| H1: parent in Revelio, `n_obs` >= 1 | 266,350 | 5,081 | 45,659 | |
| H1 under the 5-hires rule (`n_hires` >= 5, `n_obs` >= 1) | 99,681 | 3,451 | 23,621 | |
| H2: `core_main`, `n_geo` >= 1 | 325,163 | 6,400 | 56,617 | |
| H3: parent in Revelio, `n_local` >= 1 (with and without a host-country parent) | 231,425 | 4,937 | 42,687 | |
| H4 (domain-b): S13 sample, parent in Revelio, `n_hires` >= 1 | 90,013 | 2,302 | 19,283 | 277 exposed IJVs in 26 pairs; 2,025 controls in 486 dyads |
| H4: exposed IJVs with `REG_B` cells (>= 5 employees, >= 1 hire) both in 2013 to 2015 and from 2021 | 346 | 31 | | 15 pairs (feasibility count of 2026-11-25: 32 IJVs, 15 pairs, employee rule only) |
| H4 lead-pooling display rule: exposed `REG_B` cells with >= 1 hire in 2010 / 2011 / 2012 | 50 | 22 | | 15 / 16 / 19, each below 25, so the three leads are shown pooled (B2) |
| C1 (level): S13 sample, parent in Revelio, `n_hires` >= 1 | 55,917 | 2,694 | 27,064 | 307 exposed IJVs in 26 pairs; 2,387 controls in 524 dyads; 46 control-linked |
| H1 levels: parent in Revelio, `n_obs` >= 1 | 129,850 | 5,785 | 59,498 | |

### Coverage and regressor completeness

- Coverage ratio (robustness 14): 27,689 of 76,823 IJV-years of 2015 to 2025 (3,821 IJVs) have an unconsolidated Orbis headcount; median ratio 0.54. It is set for 20.8 percent of the domain cells with at least 5 employees in the main period (cells before 2015 have none by rule).
- Resource dependence (robustness 19): 11,707 parents reach an OEWS industry (4-digit 7,917, combined 1,597, 3-digit 2,193), as in `data/data-log.md`; 6,931 IJVs have a matched code for at least one parent and 4,270 for every parent; `rd_core` is set for 85.9 percent and `rd_core_hcp` for 61.6 percent of the domain cells with at least 5 employees in the main period.
- Scores: complete for every domain cell; at each of the function and role_k50 grains one group without O\*NET-coded taxonomy entries (`Miscellaneous` at the function grain; 5,234 cell-years, 267 hires) has no score; rater scores cover the 50 rated `role_k50` groups.

## Quality checks run

- Synthetic build with seeded failures (`code/R/tests/check_panel_build.R`; 93 of 93 checks pass): repeated position ids in spells, JV positions and histories are removed and counted once; a person whose only JV position has no start date is not a hire, and one with an undated plus a dated position is hired at the dated one; history positions without a start date, or ending before they start, are ignored; an open-ended parent position counts as a prior position under every window, and an open-ended JV position stays in the stock through 2025; a person at two IJVs is a hire at each, and the first IJV is an independent prior employer for the second; a 2008 hire sits in a full-period row (`main_period` = 0), while 2026 hires and hires before the formation year are dropped and logged; a parent's own entity matched as the IJV is flagged, kept, and not treated as a parent employer, while the parent's other entities still give parent origin; an entity in two parents' families goes to the larger-equity parent; the 1-, 3- and 5-year windows, entrants, unmapped employers, prior positions without a country, home-country parent hires, invalid O\*NET values, lookup-coded positions, missing seniority and a first position without a 30 June each give the expected value; the S13 coding (exposure, the owner-level control with a UK owner, the third-country pair, GB-IE, Rule C bands, dyads), the listed flag, short NAICS codes in the OEWS match and the country code NA (Namibia) are checked; the A3 identities hold on every row of all seven panels, cell hires sum to the hires of each grain, and keys are unique.
- Independent recomputation on real data (`code/R/tests/check_panel_recompute.R`, 150 random IJVs, 79,469 hires, a plain loop written apart from the build helpers): every hire agrees on the categories of the 1-, 3- and 5-year windows and on the entrant flag.
- The pooled totals over all years reproduce the counts the plan cites from the 2026-11-23 tabulations (section "Hires"), and the IJV and S13 counts reproduce the plan's figures (831, 216, 5,882, 2,321, 6,600, 3,728, 394, 28, 311, 230, 3,409, 912, 104, 59, 17, 92, 31, 19).
- Stage 7 schema (`check_panel_build.R real`, column names and types only, no row read): the real domain and domain-b panels carry every column and type of the stage 5 simulated panel (`simulate_domain_panel()`) and every variable named in the plan's model formulas for H1 to H4; the level panel carries every variable of C1 and the level models. No column is named `function`. Nothing was estimated.
- Unit checks (`code/R/tests/test-functions.R`): all pass, the legacy checks included.
- Licensed data: no row, id, name or Revelio label in any tracked file; the codebook, data log, README and this file hold aggregate counts only.
- Process note: the first real run of step 1 stopped at step 6 because the agent converted the script's line endings while Rscript was still reading it; the step was rerun from scratch (`rebuild`), and the outputs above come from the complete rerun. The script header now warns against editing it during a run.

## Readings and forced deviations (each needs the PI's yes or an amendment)

None of these changes a hypothesis, a measure's definition, a threshold or a sample of `pap-v1.0`; each is the reading closest to the text where the plan is silent, ambiguous or cannot be built as written. Any change of a measure before gate 6 is an amendment (`pap-v1.1`).

1. **Panel files.** The plan's names (B0.1) are used: `panel-ijv-domain-year-v1.parquet` (primary), `panel-ijv-level-year-v1.parquet` and `panel-ijv-function-year-v1.parquet`. The stage brief and `data/README.md` had named the domain panel `panel-ijv-function-year.parquet`; that name now holds the function grain, as in the plan. Four files the plan implies but does not name are added: `panel-ijv-domain-b-year-v1` (the H4 grain: the confirmatory measure became the broad list on 2026-11-25, chat item 8, and "the 22 broad-list codes, carved out of their minor groups in the H4 models" changes the cells, so it cannot be a column of the narrow panel), `panel-ijv-level-b-year-v1` and `panel-ijv-seniority-year-v1` (robustness 18b and 18c change the cells), and `panel-ijv-role50-year-v1` (robustness 5 and 6), plus an IJV attributes table and an IJV-year table. In the domain-b panel `domain` holds `REG_B` and `reg` equals `reg_b`, so the stage 5 model helpers run on it unchanged; `reg_list` says which list a file uses.
2. **The nine functions do not exist.** Robustness 5 names "the nine functions", but no mapping from Revelio's `role_k10_v3` (ten categories plus `Miscellaneous`) to the nine project functions of the original codebook (`rd_engineering`, ..., `other`) was ever decided; writing one now would be an author judgment made after the staffing tabulations by function were seen. The function panel therefore uses Revelio's own `role_k10_v3` as `fn` (forced deviation). PI: accept `role_k10` as the function grain, or decide a nine-function map as an amendment before gate 6.
3. **Denominator of the geographic outcomes.** Part A3 sets `n_geo` (hires whose prior position has a country) as the denominator of `share_local` and of the H2, H4a, H4b (i) and mobility outcomes; part B writes `offset(log(n_obs))` for the same models, but B0.3 lists only the four located categories, under which `n_obs` equals `n_geo`. The panels carry both; `share_local` is built as `n_local / n_geo` (A3). Stage 7 needs the PI to confirm `n_geo` as the offset of the geographic models (the reading closest to A3, which defines the denominators explicitly).
4. **Occupation of first positions that cover no 30 June.** A hire's domain is the occupation of the first dated position at the JV. Where that position is not in the spell table it was never sent to the O\*NET pull, so it takes the code of its `role_k17000_v3` through the role lookup (`onet_source` = `lookup`). The decision of 2026-11-25 named the lookup for spell positions no longer in Revelio's position table; this extends it to a second group of positions without a position-level code. Both groups are dropped together in robustness 7.
5. **Invalid codes are missing, without a lookup fallback.** Positions in the O\*NET extract whose code is `unknown`, `Retired`, `On Leave` or empty have no domain (plan A3, item 3), whereas the stage 5 feasibility count (`08_feasibility_reg_cells.R`) had given them the lookup code.
6. **Hires before the formation year are left out.** The plan does not say; the codebook's cell-year rule ("only years from the JV's formation (incorporation) year onward") and the stage 5 counts were applied. These hires are not in any panel (count below), which matters because 25.5% of IJVs have a first position more than ten years before incorporation (A4.7).
7. **Origin window in days.** A prior position counts if it was ongoing or ended at most `origin_window` x 365 days before the hire date, as in the staffing tabulations; the plan text says "within `origin_window` years before it".
8. **History positions without a start date** cannot be shown to precede a hire and are ignored; positions ending before they start would be ignored too (none in the real data).
9. **Listed JVs.** Flagged where Orbis reports the status `Listed` (Orbis-sourced IJVs; `Delisted` is not flagged) and, for Capital IQ-sourced IJVs, which carry no listing status in the frame, where an ISIN is on record (a proxy; an ISIN can belong to a bond).
10. **Resource dependence (robustness 19).** `rd_ratio` for H1 is the largest log ratio over the parents with a matched code (the plan defines the ratio per parent, not how to combine parents); a domain with no employment in a parent's industry has no log ratio (missing). For H3 the host-country parent is the largest-equity host-country parent with a matched code. The regulatory domains' OEWS shares sum the SOC detailed codes of the list and subtract them from their minor groups; `11-9199` (regulatory affairs and compliance managers) is published only inside "managers, all other", so `REG` is over-counted in OEWS. Suppressed OEWS cells count as zero.
11. **Scores at the role_k50 and function grains** are the occupation scores averaged per group with taxonomy-entry weights, the rule decided for the rater comparison on 2026-11-25; the plan says only "aggregated to that grain from the occupation scores".
12. **Scores of the REG_B grain** are computed in `measures.R` (`domain_b_scores()`) with the rule of `07_contingency_scores.R` (unweighted mean of rated occupations), because `07` (a stage 5 output) writes the narrow grain only. They enter no H4 model, which uses IJV x domain effects; they serve the `job_zone` and moderation checks.
13. **dyad.** Exposed IJVs with several exposed pairs keep the pair of their largest-equity parent among them; IJVs with neither a foreign direct parent nor a foreign ultimate owner get `host-none`.
14. **`n_intl_parent_home`** counts an international parent-origin hire whose prior position lies in the home country of any of the IJV's foreign direct parents, not only of the parent the hire came from.
15. **Linked status.** `linked` (Rule L) is 1 for UK-hosted exposed IJVs and 0 elsewhere, because part C covers transfers into the UK only; `linked_alt` codes minority-held IJVs as not linked. `affiliate_link_uncertain` (part C, section 2) cannot be built: Revelio identifies the parent group, not which group entity employed a transferring worker, so the plan's fallback applies (the parent group is the unit, a stated limitation).
16. **Lookup and imputation variants.** The `_xi` and `_xl` counts drop the hires (and employees) of imputed or lookup-coded occupations from every category; the entrant, window and channel variants are not crossed with them.

## What could not be built, and why

1. **`core` as a robustness sample (robustness 13b).** The matched dataset, the spells and the panels cover `core_main` (7,460 IJVs). The 2,184 IJVs of `core` outside `core_main` (Capital IQ prior co-ownership and the Orbis small-library sample, mostly sequential acquisitions and start-ups by the audits of 2026-10-09) have no matched-dataset tables and no O\*NET codes. Building them needs `09_build_matched_dataset.R` run on `core` (local, from the stored positions and histories) and a WRDS pull of `onet_code` for their positions (`14_wrds_onet_code.R`); that pull needs the PI's approval. The strategic subset (2,172) is in the panels (`strategic`).
2. **Usability threshold of 10 employees (robustness 13e).** IJVs with 10 to 19 Revelio employees are not "usable" and so are in neither the matched dataset nor the history pulls; the panels can only tighten the threshold (`usable_30`). Lowering it needs new Revelio pulls (positions and histories of those IJVs' employees) that the PI would have to approve.
3. **`kim2003global` function ordering and the BoardEx cross-check** are comparisons made at stage 7 from existing tables, not panel columns.
4. **The nine project functions** (reading 2 above).

Nothing else in Part B, section 5, lacks a column: robustness 1 to 3 and 15 use the S13 and IJV variables; 4 the cell flags; 5 and 6 the function and role50 panels, the broad and level-scale scores and the rater scores; 7 the `_xi` and `_xl` counts and `score_imputed_domain`; 8 `job_zone`; 9 the domain-b panel, `law_gov_importance` and the narrow panel; 10 the entrant windows and places; 11 `flag_jv_in_parent_family`; 12 `main_period` and `share_unmapped`; 13a, c, d, e `all_parents_in_revelio`, `n_local_parent_hcp`, `flag_listed`, `host_parent_guo`, `exposed_guo` and `usable_30`; 14 `coverage_ratio`; 16 `n_not_obs`, `n_unknown`; 17 the `_ow1` and `_ow5` counts; 18 the level-b and seniority panels; 19 the `rd_*` variables.

## Known weaknesses and uncertainties

- Observability: 25.9 percent of the hires of 2010 to 2025 have no prior position in the window and leave every share denominator; 14.7 percent stay unknown after entrants are separated, and the prior employer is unmapped (so counted as independent) for 18.7 percent of hires with an observed history. Robustness 12 and 16 rest on `share_unmapped` and on `n_unknown`.
- Parent-origin is rare (pooled 1.3 percent of hires), so H3 and H4b (ii) rest on few events; the effective H3 sample (IJV-years with a local parent-origin hire) and the count of IJVs without a host-country parent that contribute to the boundary test are outcome counts and are left to stage 7.
- H4 rests on 31 exposed IJVs in 15 pairs with `REG_B` cells (at least 5 employees and one hire) in both the clean pre-period and from 2021, close to the feasibility count; the lead-pooling display rule applies (15, 16 and 19 exposed `REG_B` cells with a hire in 2010, 2011 and 2012).
- The 831 IJVs filed in a parent's Revelio family stay in; at the audit rate (2 in 100) about 17 of them may be a parent's own unit, which would move their parent-origin counts.
- Hires before the incorporation year (106,201) are outside the panels; with 1,901 IJVs whose first position predates incorporation by more than ten years, the panels start mid-life for many IJVs (plan A4.7).
- Revelio seniority is a model score; the level panels inherit its error. O\*NET occupation codes are Revelio's, and 5.4 percent of the main-period hires carry a code from the role lookup.
- The coverage ratio exists for 3,821 IJVs only (Orbis-sourced with unconsolidated headcounts, from 2015); Capital IQ-sourced IJVs carry no listing status, so robustness 13d drops listed Orbis-sourced IJVs only.
- The owner-basis variants (robustness 13d) are built for the host-country parent label (`host_parent_guo`) and for exposure (`exposed_guo`); the control group under the owner basis is not re-derived and is left to stage 7.
- Rater scores: agreement among the three raters was unusually high, and the O\*NET `coord_dependence` score correlates only 0.13 with the raters' parent-coordination scale (`docs/decisions.md`, 2026-11-26); both points bear on how H1, H3 and H4b are read, not on the build.
- OEWS: `REG` and `REG_B` are over-counted in the resource-dependence shares because `11-9199` is published only as "managers, all other" (reading 10).

## Decisions required from the PI

1. Readings 1 to 16 above: accept as built, or amend (`pap-v1.1`). The ones with the most weight: reading 2 (no nine-function map exists; the function grain is Revelio's `role_k10`), reading 3 (`n_geo`, not `n_obs`, as the offset of the geographic models in stage 7), reading 6 (hires before the formation year left out) and reading 4 (lookup codes for first positions that cover no 30 June).
2. Whether to build the two robustness samples that need new data: `core` (2,184 more IJVs; a WRDS pull of O\*NET codes for their positions) and the usability threshold of 10 employees (new Revelio position and history pulls). Neither pull has been made.
3. Whether a listing status for Capital IQ-sourced IJVs should be sought (none is flagged now), or robustness 13d stays on Orbis-sourced IJVs.
4. Gate 6: approve the panels for stage 7, approve with changes, or reject.

## Proposed changes to earlier stages

- `docs/decisions.md`: record the PI's answers on the readings above with the date; note that the `[DATA]` marker of plan A4.2 is resolved (5,159 IJVs with a host-country parent and at least one parent in Revelio).
- `.claude/agents/data-engineer.md` and `.claude/skills/panel-build/SKILL.md`: the stage 6 outputs are the plan's file names (B0.1) plus the domain-b, level-b, seniority and role50 panels, not `panel-ijv-function-year.parquet` and `panel-ijv-level-year.parquet` alone.
- `CLAUDE.md`, design paragraph (plan A6.7, still open): the panel unit is IJV x occupation group (domain) x year, with Revelio functions and `role_k50` as robustness grains.
- `code/R/04_estimate.R` and `code/R/functions/estimation.R` still model the function grain of the draft hypotheses; stage 7 should build on `code/R/functions/simulate_domain_panel.R`, whose helpers read the real panel's columns.
- `code/R/08_feasibility_reg_cells.R` gave lookup codes to positions whose position-level code is `unknown`, `Retired` or `On Leave`; the panels treat them as missing (reading 5). The feasibility count is not rerun; the difference is small (10,943 hires over all years have no usable code).

## PI notes (filled in by the PI; applied by the orchestrator if status is APPROVED WITH CHANGES)

-
