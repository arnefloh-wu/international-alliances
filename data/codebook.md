# Codebook

Updated by the data-engineer and quant-analyst agents. Every variable in
the processed panels is listed here with source, construction and unit.

## Identifiers

| Variable | Level | Source | Definition |
|---|---|---|---|
| `ijv_id` | IJV | Orbis BvD ID | JV legal entity |
| `rcid_ijv` | IJV | Revelio | matched company id |
| `parent_a_id`, `parent_b_id` | IJV | Orbis BvD ID (GUO) | parent A is the parent with the larger equity share at formation; ties broken alphabetically by country code |
| `dyad` | IJV | derived | ordered pair of parent HQ country codes |
| `function` | cell | Revelio `job_category` mapped | one of: rd_engineering, operations_manufacturing, supply_chain_procurement, finance, hr, sales_marketing, it, general_management, other |
| `level` | cell | Revelio seniority mapped | one of: executive, middle_management, professional, operational |
| `year` | cell | derived | calendar year; an individual is in a cell-year if the position overlaps 30 June of that year |

## Dependent variables (see `code/R/functions/measures.R`)

| Variable | Definition | Range |
|---|---|---|
| `n_emp` | employees observed in the cell-year | count |
| `n_from_a`, `n_from_b`, `n_external` | employees whose most recent prior employer (or any prior employer within `origin_window` years) was parent A, parent B, neither | count |
| `share_a`, `share_b` | `n_from_a / (n_from_a + n_from_b)`, likewise B; NA if no parent-origin employees | 0 to 1 |
| `cross_parent_integration` | `2 * (1 - (share_a^2 + share_b^2))`, so 0 = one parent only, 1 = equal representation | 0 to 1 |
| `parent_dominance` | `abs(share_a - share_b)` | 0 to 1 |
| `parent_dominance_adj` | `abs((share_a - share_b) - (equity_a - equity_b))`, deviation of staffing asymmetry from equity asymmetry | 0 to 2 |
| `localization` | `n_external / n_emp` | 0 to 1 |
| `localization_host` | external employees whose prior position was in the host country / `n_emp` | 0 to 1 |

## Domain characteristics (from the qualitative memo, finalized at G5)

Under structural contingency theory these scores summarize four contingency families (task, coordination, environmental, resource; see `docs/theory-framework.md`). Gate 3 decides whether two summary scores suffice or a third, `resource_dependence`, is added.

| Variable | Definition |
|---|---|
| `coord_dependence` | score 1 to 5 for the function's dependence on cross-partner coordination and knowledge exchange |
| `local_embeddedness` | score 1 to 5 for the function's dependence on host-country institutions, labor markets, customers, regulators |
| `coord_role` | for levels: 1 if the level carries alliance-wide coordination responsibility (executive, middle management), else 0 |

## Shock (finalized at G5)

| Variable | Definition |
|---|---|
| `shock` | 1 from the first year in which the dyad is exposed to the focal environmental change |
| `event_time` | year minus first exposure year; NA for never exposed |

## Controls

`ijv_age`, `ijv_size_log`, `equity_a`, `equity_b`, `equity_balance`
(= 1 - |equity_a - equity_b|), `n_parents`, `parent_a_size_log`,
`parent_b_size_log`, `parent_a_roa`, `parent_b_roa`, `industry`,
`host_country`, `dist_a_host`, `dist_b_host`, `inst_dist_a_host`,
`inst_dist_b_host`, `host_gdp_growth`, `host_wgi`.

## Sample frame from Orbis ownership (Stage 4 pilot, 2026-10-08)

Orbis Crossborder Investment is not on WRDS and SDC joint ventures is not
licensed (`docs/decisions.md`, 2026-10-08), so the frame comes from the
current ownership links in `bvd_orbis_large` and `bvd_orbis_medium`
(`ob_links_current`, relation type `SHH`, active). Script:
`code/R/wrds/02_wrds_pilot_extract.R`.

| Rule | Definition |
|---|---|
| IJV | active, non-dormant company with two or three direct shareholders, each holding 20 to 90 percent, together at least 50 percent, from at least two countries, and at least one foreign to the host country |
| Parent | direct shareholder with a BvD ID (not an aggregated or anonymous holder) whose shareholder type in the JV's first-level shareholder table (`ob_all_cur_shh_1st_level`) is Corporate, Bank, Insurance company or Financial company; an IJV with any other parent type (public authority, fund, nominee or trust, private equity, venture capital, hedge fund, individual or family, employees, foundation, unnamed, self ownership, missing) is excluded |
| Excluded industries | NACE section K (financial and insurance) and NACE 6420/6430 (holding companies, trusts) |
| Formation date | Orbis incorporation date (`dateinc`), 2005 to 2023; stands in for the JV formation date, which the ownership tables do not record |
| Equity share | current direct share (`dir_pct`) and its information date; stands in for the share at formation. `parent_a` is the parent with the larger current share |
| Parent group (Orbis) | GUO at the 50 percent definition (`guo_50`) where present, otherwise the direct parent; GUO names from `ob_w_company_id_table` (large and medium libraries) |
| Parent group (Revelio) | the Revelio entities matched to the direct parent and to its GUO, extended to their whole Revelio family: the Revelio `ultimate_parent_rcid` of each matched entity and every company under it. A prior position anywhere in this family counts as parent origin |
| Country | first two characters of the BvD ID (ISO 3166 alpha-2) |
| Intra-group exclusion (applied 2026-10-09) | the parents of an IJV must resolve to at least two distinct Orbis GUOs (50 percent definition, looked up in the large, medium and small libraries; a parent without a GUO record is its own GUO). JVs whose parents share one GUO are subsidiaries held through two group entities and are excluded (`excl_jv = intra_group`). The two pilots of 2026-10-08 predate the rule; their reports exclude intra-group JVs from the usable counts |
| Large-JV stratum (pilot 2) | eligible JVs not in pilot 1 with an Orbis headcount (`empl`, latest year) of at least 100 and at least two parents whose own or GUO name has an exact or normalized Revelio match |

Consequences: the frame contains only JVs alive with an unchanged
multi-parent structure today, so JVs that were dissolved or bought out
are missing (survivor bias), and ownership changes since formation are
not observed.

## Full-frame sample (2026-10-09)

Table `data/processed/sample-ijv-2026-10-09.csv`, one row per eligible IJV, from `code/R/wrds/03_wrds_full_sample.R`.

| Variable | Definition |
|---|---|
| `tier` | `auto` (accepted name, LEI, ISIN or native-name match with the pilot guards), `strong` (website route with a close name), `review` (other review-tier route), `shared_entity_dropped` (another JV took the same Revelio entity), `unmatched` |
| `usable` | at least 20 employees and 3 observed years from the formation year at the matched entity |
| `core` | usable, tier `auto` or `strong`, and no size mismatch |
| `flag_size_mismatch` | Orbis headcount of 10 or more and Revelio employees more than 20 times that headcount |
| `flag_pre_formation_10y` | the matched entity's first position starts more than 10 years before the JV's incorporation year; the incorporation date then probably does not mark the JV's formation |
| `flag_holding_vehicle` | JV name contains "holding" and Orbis headcount is 5 or fewer or missing; the match is to the operating company |
| `operating_parents` | parents that are operating firms: the parent or its GUO has at least 50 employees in Orbis, or the parent's or GUO's matched Revelio entity has at least 50 people |
| `strategic` | at least two operating-firm parents; separates JVs between operating companies from companies co-owned by founders' holding companies and investment vehicles |

Additional matching routes in the full run: the JV's previous and also-known-as names (Orbis `prevname`, `akaname`), and its native-script name (exact match after removing spaces and punctuation). GUOs that are states or government bodies do not define parent families. Each Revelio entity counts for one JV only.

## Frame v2 (2026-10-09)

Built by `code/R/wrds/05_wrds_frame_v2.R`; matched by `code/R/wrds/03_wrds_full_sample.R v2`; sample table `data/processed/sample-ijv-v2-2026-10-09.csv`.

| Variable | Definition |
|---|---|
| `source` | `orbis` (Orbis ownership links) or `ciq` (Capital IQ ownership relations); Capital IQ JVs with the same normalized name and country as an Orbis JV are dropped |
| `admitted_by` | `base` if the JV meets the base rules; otherwise the relaxations that admit it: `stake_10_20` (a parent holds 10 to 20 percent), `four_parents`, `formed_before_2005`, `not_active` (company status not active), `guo_country` (two-country rule met only at the GUO level; not yet run), and `ciq` for Capital IQ JVs |
| Capital IQ IJV | a company (public or private) with two to four owners that are public or private companies, each holding 10 to 90 percent through a current investment or current subsidiary relation, together at least 50 percent, owners in at least two countries and at least one foreign to the company; financial-sector companies excluded |
| Capital IQ groups | an owner's group is its majority parent (current subsidiary relation above 50 percent) or the owner itself; this one-level check misses deeper common ownership |
| `formation_year` (Capital IQ) | `yearfounded`; where missing, 1990 and `formation_year_missing = TRUE` |
| Industry pick | the Orbis industry table can hold several rows per company; the v1 frame and the v2 frame used for the 2026-10-09 run took one without a fixed order, which moves a few hundred JVs in or out of the financial-sector exclusion between runs. `05_wrds_frame_v2.R` now orders the rows; the next rebuild is deterministic |

Frame v3 (2026-10-09) adds three routes, selected with arguments to `05_wrds_frame_v2.R`:

| Route (`admitted_by`) | Definition |
|---|---|
| `guo_country` | direct parents sit in one country, but their GUOs sit in at least two countries and two groups, one foreign to the host. Ids are found first with the single `GUO 50` relation row per company, then the detail query runs for those ids |
| `small_library_sample` | Orbis small-company library, restricted to a 1-in-20 hash sample of companies (hash of the BvD id); counts scale by 20 |
| `ciq_prior` | Capital IQ company with two to four prior corporate owners (relation types prior investment and prior subsidiary) in at least two countries and no current corporate owner. Prior relations have no stakes or dates, so sequential owners cannot be told from joint owners; low confidence |

Sample table columns added in the v3 run: `route` (`orbis_base`, `orbis_relaxed`, `orbis_owner_level`, `orbis_small_sample`, `capital_iq_current`, `capital_iq_prior`, `external`) and `core_main` (`core` without `capital_iq_prior` and `orbis_small_sample`). Tier `manual` marks matches confirmed or set by a person (decisions in `data/raw/manual/manual-matches-*.csv`: columns `jv_bvdid`, `decision` accept, reject or replace, and `rcid_manual` or `linkedin_url`); manual matches rank above automatic ones and are not subject to the size-mismatch check. Frame v4 adds external deal lists (`06_ingest_external_jvs.R`, format in `docs/data-acquisition-guide.md`); their `source` is `ext_<name>`. Career histories are stored as parquet parts in `data/raw/revelio-histories-full-2026-10-09/`; the parts are the only record of users already pulled, and readers should de-duplicate on `position_id`.

Matching changes in the v2 run: name keys are searched in cached batches; when an Orbis JV and a Capital IQ JV of the same tier pick the same Revelio entity, the Orbis JV keeps it; positions at JV entities and career histories are shared with v1 and pulled incrementally.

### Manual decisions and agent triage (2026-10-09)

The sample table has `manual_by` for tier `manual` rows: `claude` for decisions in `manual-matches-claude-*.csv`, otherwise the initials in the file name. Where a person and the agent decided on the same IJV, the person's decision wins. `code/R/wrds/08_triage_manual_candidates.R` makes the agent decisions from the worklist rows that have a review-tier candidate, with these rules:

| Decision | Rule |
|---|---|
| `accept` | the first candidate's name equals the JV's name once legal forms, punctuation and spacing are removed; Revelio headcount not more than 20 times Orbis headcount where Orbis reports 10 or more |
| `replace` | the same test holds for exactly one of candidates 2 and 3 (`rcid_manual` set) |
| `reject` | the first candidate is a parent's own entity, or shares no content word with the JV's name and has a name similarity below 0.6; abbreviated names and non-Latin script are never rejected |
| blank | everything else, left for a person |

Names that differ only by a holding or group word, or by Danish A/S against ApS, are not treated as equal. Per-row log: `data/interim/manual-triage-claude-v3-2026-10-09.csv`.

## Matched dataset (2026-10-09)

Built by `code/R/wrds/09_build_matched_dataset.R` for the `core_main` IJVs, in `data/processed/` (licensed data, gitignored). The shared key is `jv_bvdid`; a manifest `dataset-manifest-<run>.md` lists the row counts.

| Table | Grain | Columns |
|---|---|---|
| `ijv-matched-<run>.csv` | one row per IJV | `jv_bvdid`, `jv_name`, `jv_country`, `region`, `industry`, `formation_year`, `formation_year_missing`, `source`, `route`, `admitted_by`, `exposure_group`, `n_parents`, `rcid_jv` (Revelio entity), `match_tier`, `match_method`, `match_score`, `manual_by`, `n_emp`, `n_years`, `function_cells_5`, `seniority_cells_5`, `jv_employees_orbis`, `operating_parents`, `strategic`, `flag_pre_formation_10y`, `flag_holding_vehicle`, `jv_website`, `jv_lei`, and for parents A and B: name, country, share, BvD id, `in_revelio` |
| `ijv-parents-<run>.csv` | one row per IJV-parent pair | `jv_bvdid`, `parent_rank`, `parent_label` (A larger equity share, B second, then 3, 4), `parent_bvdid`, `parent_name`, `parent_country`, `parent_entity_type`, `equity_share_current`, `parent_guo`, `guo_name`, `guo_country`, `parent_in_revelio`, `revelio_family_size` |
| `ijv-employee-spells-<run>.parquet` | one row per Revelio position at the matched JV entity | `jv_bvdid`, `rcid`, `user_id`, `position_id`, `start_date`, `end_date`, `ongoing`, `first_reference_year`, `last_reference_year`, `n_reference_dates`, `country`, `seniority`, `role_k17000_v3`, `function_role_k10`, `role_k50_v3` |

A position is a spell only if it covers at least one 30 June from the formation year (or its start, if later) to 2026; `n_reference_dates` counts them. Parent A is the parent with the larger current equity share, ties broken on country code. `formation_year` is the incorporation year (Orbis) or founding year (Capital IQ; 1990 where missing, flagged by `formation_year_missing`), so for many IJVs the first observed year is later than the venture's real start. Career histories of the spell users are in `data/raw/revelio-histories-full-2026-10-09/` and link on `user_id`. Function and seniority are Revelio's own codes; the mapping to the project's nine functions and levels is set at gate 5. Version 3 of the 2026-10-09 run: 7,460 IJVs, 17,015 parent rows, 4,973,926 spells for 3,760,920 people.

## Staffing tabulations (2026-11-23)

Feasibility counts from `code/R/wrds/11_staffing_tabulations.R` (PI instruction of 2026-11-23). Provisional definitions, not the Stage 6 measures; outputs in `data/interim/staffing-tabulations-<run>.md` and the folder of the same name.

| Term | Definition |
|---|---|
| Hire | a person's first dated position at the matched JV entity, for people in the employee-spell table; stays that cover no 30 June are not counted |
| Flow window | hires with a hire year from the formation year to 2026 |
| Stock | person-years, one per person, IJV and 30 June |
| Prior position | a position at another employer that started before the hire date and was ongoing or ended within `origin_window` years before it |
| Parent-origin | any prior position in the window at an entity of a parent's Revelio family; the most recent such position gives the location and the parent. An entity in two parents' families goes to the parent with the larger equity share (216 IJVs have such entities) |
| Independent | a prior position in the window, none of them in a parent family; the most recent one gives the location. Includes prior employers not mapped to a Revelio company |
| Local, international | the prior position is in the IJV's host country, or in another country (Revelio country names converted to ISO 2) |
| History not observed | no prior position in the window |
| Host-country parent | a parent whose direct shareholder country equals the host country (`type_direct`); the owner label uses the Orbis GUO country and is missing for Capital IQ parents |
| Labor market entrant | a hire with history not observed for whom the JV is the first recorded job and whose last education that ended by the year after joining ended at most `origin_window` (three) years before the hire year; split by place of that education (host country, abroad, not recorded) |
| History unknown | a hire with history not observed who is not an entrant |
| Unconsolidated headcount | Orbis `empl` from a record with consolidation code U1 or U2; one per IJV and closing year (twelve-month accounts first, then the latest closing date) |
| Coverage ratio | Revelio staff at 30 June of the closing year divided by the unconsolidated Orbis headcount, from the formation year on |

Two extracts from `code/R/wrds/12_wrds_headcount_education.R` (pulled 2026-11-23, licensed, local only) feed the last four rows.

| File | Grain | Columns |
|---|---|---|
| `data/raw/orbis-jv-headcounts-2026-11-23.parquet` | one row per Orbis key-financials record with a headcount, for the Orbis-sourced IJVs of `core_main` (44,493 rows, 4,860 IJVs) | `jv_bvdid`, `conscode` (U1, U2 unconsolidated; C1, C2 consolidated; LF limited financials), `filing_type`, `closdate`, `closdate_year`, `nr_months`, `empl`, `orbis_library` (large, medium) |
| `data/raw/revelio-education-full-2026-11-23/part-NNNN.parquet` | one row per education record of a hired person (7,613,952 rows, 3,302,616 people); one part per block of 5,000 user ids in ascending order, 753 parts | `user_id`, `education_number`, `startdate`, `enddate` (years, stored as 1 January), `degree`, `university_country`. University names and fields of study were not pulled |

## O\*NET codes (2026-11-25)

Two extracts from `code/R/wrds/14_wrds_onet_code.R` (pulled 2026-11-25, licensed, local only) and one public download link positions to O\*NET occupations for the contingency scores (pre-analysis plan rules, decision 1). Revelio's `onet_code` follows the O\*NET-SOC 2019 taxonomy (checked on the lookup: 2019 codes such as 15-1252.00 and 15-2051.00 are present, 2010 codes such as 15-1132.00 are not). The values `On Leave`, `Retired` and `unknown` in `onet_code` are not occupations and are treated as missing. Positions no longer in `revelio.individual_positions` (3.1%) take the code of their `role_k17000_v3` from the lookup (PI, 2026-11-25); the panel carries the route as `onet_source` (`position` or `lookup`).

| File | Grain | Columns |
|---|---|---|
| `data/raw/revelio-role-lookup-v3-2026-11-25.parquet` | one row per Revelio role (17,000 rows) | `role_k17000_v3` to `role_k10_v3` (the nine taxonomy levels), `onet_code`, `onet_title` |
| `data/raw/revelio-jv-positions-onet-2026-11-25/part-NNNN.parquet` | one row per JV position of `ijv-employee-spells-v3-2026-10-09.parquet` found in `revelio.individual_positions`; one part per block of 5,000 position ids in ascending order | `position_id`, `onet_code` |
| `data/raw/external/onet-db-31-0-2026-11-25/db_31_0_text.zip` | the O\*NET 31.0 database, text files, unchanged (O\*NET-SOC 2019 taxonomy) | as published by the O\*NET Resource Center; licence CC BY 4.0, credit "O\*NET 31.0 Database, U.S. Department of Labor, Employment and Training Administration (USDOL/ETA)" |

Synthetic twins: `data/synthetic/revelio-role-lookup-v3-synthetic-2026-11-25.parquet` and `revelio-jv-positions-onet-synthetic-2026-11-25.parquet` (`code/R/tests/synthetic_onet.R`, seed 20261125), on the positions of the synthetic spell table, with made-up codes in major group 99.

## Contingency scores (2026-11-25)

Written by `code/R/07_contingency_scores.R` from the O\*NET 31.0 Database and the list of O\*NET codes in Revelio's taxonomy, before any panel exists (PI decisions of 2026-11-25, `docs/coauthor-notes/score-construction-decision-sheet-2026-11-25.qmd`). No staffing data are read. Checks in `data/interim/contingency-scores-v1-2026-11-25.md`.

| File | Grain | Columns |
|---|---|---|
| `data/processed/contingency-scores-occupation-v1-2026-11-25.csv` | one row per O\*NET-SOC code in O\*NET 31.0 or in Revelio's taxonomy (1,016 rows) | `onet_code`, `onet_title`, `in_revelio`, `soc_minor` (NN-N), `soc_broad` (NN-NNN), `domain`, `regulatory_narrow`, `regulatory_broad`, `score_imputed`, `imputed_from` (rated, broad group, minor group, overall mean), the six scores, `law_gov_importance`, `job_zone` |
| `data/processed/contingency-scores-domain-v1-2026-11-25.csv` | one row per domain (98: 97 SOC minor groups and `REG`) | `domain`, the six scores, `law_gov_importance`, `job_zone`, `n_occupations`, `n_rated`, `n_in_revelio`, `all_imputed` |

| Variable | Definition |
|---|---|
| `local_embeddedness` | mean of three standardized O\*NET elements: law and government (2.C.8.b, knowledge, importance); communicating with people outside the organization (4.A.4.a.3, activity, importance); dealing with external customers or the public (4.C.1.b.1.f, context); standardized again across the rated occupations (mean 0, SD 1) |
| `coord_dependence` | the same for coordinating the work and activities of others (4.A.4.b.1, activity, importance), coordinating or leading others (4.C.1.b.1.g, context), and working with a work group or team (4.C.1.b.1.e, context) |
| `*_broad` | broad sets (robustness): local embeddedness adds 4.A.4.a.4 and 4.A.4.a.8; coordination dependence adds 4.A.4.a.2, 4.A.4.b.2 and 4.C.3.a.2.a |
| `*_lv` | level scale in place of importance for knowledge and activities (appendix check); context elements keep their context rating |
| `score_imputed` | the occupation is not rated by O\*NET on all elements; missing scores take the mean of the rated occupations in its SOC broad group, else its minor group, else all rated occupations (`imputed_from`); the last applies only to the military occupations (major group 55), which O\*NET does not rate (PI, 2026-11-25) |
| `domain` | SOC minor group, except the 16 occupations of the narrow H4 list, which form the domain `REG`. A domain's score is the unweighted mean of its rated occupations |
| `regulatory_narrow`, `regulatory_broad` | H4 lists of regulatory-facing occupations (codes in `docs/decisions.md`, 2026-11-25) |
| `law_gov_importance` | O\*NET importance of law-and-government knowledge (1 to 5), the continuous H4 robustness measure |
| `job_zone` | O\*NET job zone (1 to 5); at the domain level the unweighted mean, the skill-level control of the planned robustness check |

## Quality flags and synthetic data (2026-11-23)

Flags from `code/R/functions/quality_flags.R`, reported by `code/R/wrds/13_quality_flags.R [version|synthetic]` in `data/interim/quality-flags-<run>.md`. They are computed on read and stored nowhere: the raw and processed tables are not changed and no row is dropped. The flags of the sample table (`flag_pre_formation_10y`, `flag_holding_vehicle`, defined above) are counted alongside.

| Flag | Table | Definition |
|---|---|---|
| `flag_dup_position` | spells, histories | `position_id` already seen; counts the copies after the first |
| `flag_start_missing` | spells, histories | no start date |
| `flag_end_before_start` | spells, histories | end date earlier than start date |
| `flag_open_ended` | spells, histories | no end date (position still held); a case to handle, not an error |
| `flag_employer_unmapped` | histories | no Revelio company id (`rcid`) for the employer |
| `flag_country_missing` | spells, histories | no country; the value `NA` (Namibia) is not missing |
| `flag_stray_entity` | spells | `jv_bvdid` not in the IJV table |
| `flag_pre_formation` | spells | start year before the IJV's `formation_year` |
| `flag_multi_ijv_person` | spells | the person has spells at more than one sample IJV; a case to handle |
| `flag_short_panel` | IJV | fewer than `const$min_years` (three) reference years covered by the spells |
| `flag_no_spells` | IJV | no spell at all |
| `flag_size_mismatch` | IJV | codebook rule recomputed from the table: `jv_employees_orbis` of 10 or more and `n_emp` above 20 times it. Manual matches are exempt from the rule in the sample definition |
| `flag_jv_in_parent_family` | IJV | the matched JV entity (`rcid_jv`) belongs to the Revelio family of one of its parents. Expected where Revelio files the JV under a parent; a wrong match where the entity is the parent's own unit |
| `flag_shared_family_entity` | IJV | a Revelio entity belongs to the families of two parents of the IJV |
| `flag_multi_account_row` | headcounts | another record exists for the same IJV and closing year |
| `flag_consolidated` | headcounts | consolidation code C1 or C2 |
| `flag_not_12_months` | headcounts | accounting period other than twelve months |

Synthetic tables in `data/synthetic/` (tracked in Git), written by `code/R/tests/synthetic_matched.R` with a fixed seed: `ijv-matched`, `ijv-parents`, `parent-groups`, `ijv-employee-spells`, `revelio-histories` and `orbis-jv-headcounts`, each as `<table>-synthetic-2026-11-23.parquet` with the columns of the real table plus `synthetic = TRUE`. Every value is simulated; no real row is read. Ids start with `SYN`, `exposure_group` is empty, and names are placeholders. `function_cells_5` and `seniority_cells_5` are simplified there (categories with five or more people over all years). `seeded-failures-synthetic-2026-11-23.csv` lists the failures built into the tables and their numbers. The extractions and the synthetic data are logged in `data/data-log.md`.

## Draft panel columns for estimation (simulated, 2026-11-23)

The simulated panels of `code/R/tests/synthetic_panel.R` use these columns. They are a draft for the gate-5 measurement specification, not decided names; the real panels of `/panel-build` follow the plan. One row per IJV x function x year (`fn`) or IJV x level x year (`level`), counting hires in the year (flows).

| Variable | Definition |
|---|---|
| `fn` | function key; the column is not called `function`, which is a reserved word in R and breaks `fixest` formulas |
| `level` | hierarchical level key |
| `dyad` | parent-country pair, the unit to which shock exposure is assigned |
| `host_parent`, `parent_in_revelio` | IJV has a host-country parent; at least one parent has a Revelio entity |
| `first_shock_year`, `shock`, `event_time` | first exposure year of the pair; 1 from that year on; year minus first exposure year (missing if never exposed) |
| `coord_dependence`, `local_embeddedness`, `coord_role` | contingency scores per function (1 to 5) and per level (0 or 1); placeholders in the simulation, source open (`docs/decisions.md`) |
| `n_hires`, `n_obs`, `n_not_obs` | hires; hires with a prior position in the origin window; hires with history not observed |
| `n_local_parent`, `n_local_indep`, `n_intl_parent`, `n_intl_indep` | the four staffing categories among `n_obs`; `n_local`, `n_intl`, `n_parent` are their sums |
| `share_local`, `share_parent`, `share_parent_local`, `share_not_obs` | `n_local / n_obs`, `n_parent / n_obs`, `n_local_parent / n_local`, `n_not_obs / n_hires`; missing where the denominator is zero |

## Revelio field assumptions

Source: WRDS `revelio` library (data through 2026-09, checked 2026-10-08).

| Item | Assumption |
|---|---|
| Company | `rcid` from `company_mapping`; `ultimate_parent_rcid` defines the Revelio company group |
| Function | `role_k10_v3` from `individual_role_lookup_v3` (Sales and Marketing, Public Service and Education, Technician, Project and IT Specialist, Engineer, Finance, Service Worker, Healthcare Provider, Operations, Software Engineer), with `role_k50_v3` kept for remapping to the project's nine functions at gate 5 |
| Seniority | integer 1 to 7 in `individual_positions.seniority`; mapping to executive, middle management, professional, operational is set at gate 5 |
| Prior employer | most recent position at another `rcid` that started before the JV spell and was still held within `origin_window` years before it; an ongoing parent position counts as parent origin (secondment) |
| Overlapping positions | each position counts; an individual is in a cell-year if a position overlaps 30 June |
| Duplicates | positions are de-duplicated on `position_id` |
| Cell-years | only years from the JV's formation (incorporation) year onward; earlier spells at the matched entity are counted separately as `person_years_pre_formation` |

## Entity matching tiers (Stage 4 pilot)

| Tier | Rule |
|---|---|
| `auto` | name match (exact, normalized, or Jaro-Winkler >= 0.92 with score >= 0.97 or a single candidate); a JV candidate must be in the host country or have no Revelio country, and must not be a parent's or GUO's own Revelio entity |
| `auto_plus_strong` | adds review-tier candidates found through the JV's website (Revelio url equals an Orbis website domain, or Revelio name starts with the domain's first label) whose normalized name is close (Jaro-Winkler >= 0.85) |
| `auto_plus_review` | adds all review-tier candidates, including the two-token name stem; an upper bound until the PI has checked `data/interim/pilot-jv-review-tier.csv` |

Review-tier rules (`review_tier_candidates()` in `code/R/functions/matching.R`): host country only; no parent entity or member of a parent's Revelio family; no candidate whose name resembles one of the JV's own parents; a route that returns more than one company for a JV gives no pick.
| Country | Revelio country names converted to ISO 2 with the `countrycode` package |
