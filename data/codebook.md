# Codebook

Updated by the data-engineer and quant-analyst agents. Every variable in
the processed panels is listed here with source, construction and unit.

## Identifiers

| Variable | Level | Source | Definition |
|---|---|---|---|
| `ijv_id` | IJV | Orbis BvD ID or Capital IQ id (`jv_bvdid` of the matched dataset) | JV legal entity; key of every stage 6 panel |
| `rcid_ijv` (`rcid_jv` in the matched dataset) | IJV | Revelio | matched company id |
| `parent_a_id`, `parent_b_id` | IJV | Orbis BvD ID or Capital IQ id of the direct parent | parent A is the parent with the larger current equity share, ties broken on country code (as in the matched dataset; the current share stands in for the share at formation) |
| `dyad` | IJV | derived (stage 6) | clustering unit of the shock models: exposed IJVs keep their S13 exposure pair (`GB-X`); other IJVs take the host country plus the country of the foreign direct parent with the largest equity share (`host-parent`); IJVs without a foreign direct parent take the country of the largest-equity foreign ultimate owner (Orbis GUO); `host-none` if neither exists (pre-analysis plan B0.4; decisions of 2026-11-25, items 6 and 14) |
| `domain` | cell | Revelio `onet_code` mapped | SOC minor group of the position's O\*NET-SOC 2019 code (`NN-N`), with the 16 narrow regulatory-facing codes as `REG` (98 domains); in the H4 panel the 22 broad-list codes form `REG_B` instead. Never a column named `function` |
| `fn` | cell | Revelio `role_k10_v3` | Revelio's own function (grain robustness; see "Panels (stage 6)") |
| `role_k50` | cell | Revelio `role_k50_v3` | Revelio occupation group (grain robustness, rater scores) |
| `level` | cell | Revelio seniority mapped | mapping (a), primary: `executive` = 6-7, `middle_management` = 4-5, `professional` = 3, `operational` = 1-2; mapping (b) in the `level-b` panel: 7, 5-6, 3-4, 1-2 (PI, 2026-11-25) |
| `seniority` | cell | Revelio `seniority` | integer 1 to 7 (robustness 18c) |
| `year` | cell | derived | calendar year: the hire year for hiring flows; employees are counted if a position overlaps 30 June of that year |

## Dependent variables

The outcomes of the approved plan are hiring-flow counts per cell-year on the
staffing frame (pre-analysis plan pap-v1.0, A2.2 and A3). Their definitions are
in "Panels (stage 6)" below and in `code/R/functions/measures.R`. The
cross-partner measures of the original idea (`n_from_a`, `n_from_b`,
`share_a`, `share_b`, `cross_parent_integration`, `parent_dominance`,
`parent_dominance_adj`, `localization`) were dropped at gate 4, decision 1;
their functions are kept in `measures.R` as a labeled legacy section and enter
no panel.

## Domain characteristics

The scores of the domains come from O\*NET alone (section "Contingency
scores"); the interview scores of 1 to 5 planned at the start were replaced on
2026-11-24 and 2026-11-25 (`docs/decisions.md`). For levels, `coord_role` = 1
for `executive` and `middle_management` and 0 otherwise, with
`mintzberg1979structuring` as the source (gate 2, decision 10); it is used in
the exploratory level part of H1 only. Rater scores per `role_k50` group
(section "Rater scores") are a robustness check.

## Shock (S13, Brexit; pre-analysis plan A2.5, B0.4)

| Variable | Definition |
|---|---|
| `exposed` | 1 for a UK-hosted IJV with a direct parent from the EU27, Iceland, Liechtenstein, Norway or Switzerland, or an IJV hosted there with a UK direct parent (S13 main variant of `code/R/06_shock_exposure.R`) |
| `pair_exposure` | the exposed pair `GB-X`; for an IJV with several exposed pairs, the pair of its largest-equity parent among them (attributes table) |
| `s13_control` | IJV hosted in the UK or the EU27, EEA or Switzerland, not exposed, not a third-country parent-parent pair, and not one of the controls without a foreign direct parent that have a UK-set link through their ultimate owner (`s13_owner_link_dropped`; PI, 2026-11-25, item 14) |
| `s13_sample` | `exposed` or `s13_control` |
| `s13_third_country` | IJV hosted outside the set whose parents form a UK-set pair (placebo; in neither group) |
| `owner_level` | route `orbis_owner_level` (robustness: all dropped from the S13 models) |
| `exposed_no_ie`, `exposed_guo` | exposure with Ireland excluded; exposure on the ultimate owner's country (Orbis-sourced IJVs only, else missing) |
| `uk_host`, `gb_ie` | UK-hosted IJV; exposed IJV on the pair {GB, IE} |
| `eu_stake_max`, `eu_stake_band` | UK-hosted exposed IJVs: largest direct stake of an EU, EEA or Swiss parent; band `below_50`, `exactly_50`, `above_50` (attributes table) |
| `control_linked` | Rule C (part C, section 2): 1 for a UK-hosted exposed IJV whose largest EU, EEA or Swiss stake is above 50 percent (equity as the proxy for voting control; 50/50 coded 0), else 0 |
| `linked`, `linked_alt` | Rule L: 1 for every UK-hosted exposed IJV; alternative with minority-held IJVs (stake below 50) coded as not linked |
| `post`, `antic_yr`, `post16` | year from 2021; 2016 to 2020; from 2016 (announcement onset, robustness 15d) |
| `shock`, `antic`, `shock16` | `exposed` times `post`, `antic_yr`, `post16` |
| `event_time` | year minus 2021 for exposed IJVs; missing for others |
| `reg`, `reg_b`, `treat_reg`, `exp_post_reg`, `exp_antic_reg` | domain panels: indicator of the regulatory domain (`REG` in the domain panel, `REG_B` in the domain-b panel, where `reg` equals `reg_b`); `exposed` x `reg`; `exposed` x `post` x `reg`; `exposed` x `antic_yr` x `reg` |

## Controls

The approved plan uses fixed effects in place of IJV controls. The draft list of
the research idea (`ijv_age`, `ijv_size_log`, equity balance, parent size and
profitability, distances, host indicators) is not built at stage 6. Robustness
controls that are built: `coverage_ratio` (IJV-year, from 2015 on),
`share_unmapped` (cell), the domain `job_zone`, and the resource-dependence
variables `rd_core` and `rd_ratio`.

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

A position is a spell only if it covers at least one 30 June from the formation year (or its start, if later) to 2026; `n_reference_dates` counts them. Parent A is the parent with the larger current equity share, ties broken on country code. `formation_year` is the incorporation year (Orbis) or founding year (Capital IQ; 1990 where missing, flagged by `formation_year_missing`), so for many IJVs the first observed year is later than the venture's real start. Career histories of the spell users are in `data/raw/revelio-histories-full-2026-10-09/` and link on `user_id`. Function and seniority are Revelio's own codes; the mapping to the project's nine functions and levels is set at gate 5. Version 3 of the 2026-10-09 run: 7,460 IJVs, 17,015 parent rows, 4,973,926 spells for 3,760,920 people. Missing `jv_website` and `jv_lei` are stored as quoted empty strings (`""`), which `fread` keeps as text; treat them as missing (found at the audit preparation, 2026-11-26).

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

## Parent industry (2026-11-25)

For the resource-dependence check (robustness 19 of the pre-analysis plan;
definition in `docs/decisions.md`, 2026-11-25). Built by
`code/R/wrds/15_wrds_parent_industry.R` and `16_wrds_ciq_parent_industry.R` with
`code/R/functions/parent_industry.R`.

| File | Unit | Columns |
|---|---|---|
| `data/raw/orbis-parent-industry-2026-11-25.parquet` | one row per Orbis industry row (several per company possible), untouched | `bvdid`, `nace2_main_section`, `nacepcod2` (primary NACE Rev. 2), `naicspcod2017` (primary NAICS 2017), `orbis_lib` (`l`, `m`, `s`) |
| `data/raw/orbis-parent-industry-core-secondary-2026-11-25.parquet` | as above, with core and secondary codes | adds `naceccod2`, `nacescod2`, `naicsccod2017` (core, often 4 digits), `naicsscod2017` (secondary), `orbis_library` |
| `data/raw/ciq-parent-industry-tree-2026-11-25.parquet` | one row per Capital IQ company and industry node | `companyid`, `companyindustryid`, `subtypeid`, `primaryflag`, `chartypeid` |
| `data/raw/ciq-industry-subtype-2026-11-25.parquet`, `ciq-industry-to-sic-2026-11-25.parquet` | Capital IQ industry tree; Capital IQ industry to SIC | `subtypeid`, `subtypevalue`, `childlevel`, `leafflag`, `subparentid`; `subtypeid`, `siccode` |
| `data/raw/external/census-naics-concordances-2026-11-25/` | five Census concordances, unchanged | SIC 1987 to NAICS 2002; NAICS 2002 to 2007, 2007 to 2012, 2012 to 2017, 2022 to 2017 |
| `data/interim/parent-industry-v2-2026-11-25.csv` | one row per direct parent (15,672); rule v2 | `parent_bvdid`, `parent_guo`, `ciq_companyid`, `orbis_lib`, `naics_direct`, `nace_direct`, `holding` (NAICS 5511, NACE 64.2 or 70.1), `own_code`, `own_src`, `guo_code`, `guo_src`, `ciq_naics4`, `rd_naics` (code used, NAICS 2017), `rd_naics4`, `rd_naics_source` (`own primary`, `own core`, `own secondary`, `ultimate owner ...`, `capital iq`, `holding unresolved`, `missing`), `flag_multi_rows`, `flag_code_conflict`, `flag_not_in_orbis_industry`, `flag_naics_short`, `flag_naics_missing`, `flag_holding_unresolved`. `parent-industry-v1-2026-11-25.csv` (first run, primary codes only) has the earlier column set |
| `data/raw/external/oesm21in4.zip` | BLS OEWS May 2021 national industry-specific estimates, unchanged | per file: `NAICS`, `NAICS_TITLE`, `I_GROUP`, `OCC_CODE` (SOC 2018), `O_GROUP` (`total`, `major`, `minor`, `broad`, `detailed`), `TOT_EMP`, `PCT_TOTAL` and wage columns |

Pick rule: Orbis large before medium before small, then rows with a NAICS
code, then by NACE and NAICS code. Capital IQ parents (`parent_bvdid`
starting with `CIQ`) take their code from the Capital IQ industry tree
(rule v2 in `docs/decisions.md`).
Planned panel variables (pre-analysis plan, robustness 19): `rd_core` (1 if
the domain's employment share in the parent's industry is at least twice its
share across all industries) and `rd_ratio` (log of that ratio).

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

## Draft panel columns for estimation (simulated, 2026-11-23; superseded by "Panels (stage 6)")

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
| Parent group | the Revelio entities matched to the direct parent and to its Orbis GUO (50 percent definition), extended to every company under their `ultimate_parent_rcid` (`full-parent-groups-<run>.csv`); state GUOs define no family; an entity in two parents' families goes to the parent with the larger equity share; the IJV's own matched entity is removed from the family for that IJV |
| Occupation and domain | position-level `onet_code` (O\*NET-SOC 2019) from `revelio-jv-positions-onet-2026-11-25`; positions not in that extract (spell positions no longer in `individual_positions`, and first positions at the JV that cover no 30 June and so were never queried) take the code of their `role_k17000_v3` in the role lookup (`onet_source` = `lookup`); `unknown`, `Retired`, `On Leave` and empty values are missing, without a fallback; domain from `contingency-scores-occupation-v1-2026-11-25.csv` |
| Function | Revelio `role_k10_v3` (`job_category` of the JV position for hires, `function_role_k10` of the spell for employees); `unknown` is missing, `Miscellaneous` is kept as a value; the project's nine functions were never mapped (see `reviews/gate-6-panel.md`) |
| Seniority | integer 1 to 7 in `individual_positions.seniority` (a model score; labels entry, junior, associate, manager, director, executive, senior executive per the Revelio data dictionary), mapped to the four levels as under "Identifiers"; missing seniority means no level |
| Hire | a person's first dated position at the matched JV entity (`revelio-jv-positions-full-2026-10-09.parquet`), for people with at least one spell (one 30 June at the JV from the formation year on); ties on the start date broken by `position_id`; hire years from the formation year to 2025 |
| Prior employer | a position at another `rcid` (or an unmapped employer) that started before the hire date and was ongoing or ended at most `origin_window` x 365 days before it (3 years primary, 1 and 5 robustness); an ongoing parent position counts (secondment); positions without a start date or ending before they start are ignored; parent-origin if any prior position in the window is in a parent family, the most recent one giving the location and the parent; otherwise the most recent prior position gives the location |
| Location | country of the prior position (Revelio country names to ISO 2 with `countrycode`), against the IJV's host country; not nationality |
| Entrant | history not observed, no earlier position at another employer, and the last education that ended by the year after joining ended at most 1, 3 (primary) or 5 years before the hire year; the place of that education gives `local`, `intl` or `na` |
| Overlapping positions | employees: each position counts, a person is counted once per cell-year (a person in two domains in one year counts in both) |
| Duplicates | positions are de-duplicated on `position_id` in the spells, the JV positions and the histories |
| Cell-years | only years from the JV's formation (incorporation) year onward, to 2025 |
| Missing values | `ijv-matched-v3` stores missing `jv_website` and `jv_lei` as quoted empty strings, which `fread` does not read as missing; treat `""` as missing (`pb_blank()`); the panels use neither column |

## Entity matching tiers (Stage 4 pilot)

| Tier | Rule |
|---|---|
| `auto` | name match (exact, normalized, or Jaro-Winkler >= 0.92 with score >= 0.97 or a single candidate); a JV candidate must be in the host country or have no Revelio country, and must not be a parent's or GUO's own Revelio entity |
| `auto_plus_strong` | adds review-tier candidates found through the JV's website (Revelio url equals an Orbis website domain, or Revelio name starts with the domain's first label) whose normalized name is close (Jaro-Winkler >= 0.85) |
| `auto_plus_review` | adds all review-tier candidates, including the two-token name stem; an upper bound until the PI has checked `data/interim/pilot-jv-review-tier.csv` |

Review-tier rules (`review_tier_candidates()` in `code/R/functions/matching.R`): host country only; no parent entity or member of a parent's Revelio family; no candidate whose name resembles one of the JV's own parents; a route that returns more than one company for a JV gives no pick.
| Country | Revelio country names converted to ISO 2 with the `countrycode` package |

## Rater scores (`data/interim/rater-scores-2026-11-26.csv`)

Built by `code/R/11_rater_icc.R` from the three returned rater workbooks in `data/raw/rater-ratings/` (gitignored). One row per Revelio `role_k50` group (50 rows). Used only as a robustness and convergent-validity check of the O\*NET contingency scores (pre-analysis plan, robustness set item 6), never as the primary measure. Run log: `data/interim/rater-icc-log-2026-11-26.md`.

| Variable | Content | Unit |
|---|---|---|
| `group_id` | rater sheet id, G01 to G50 (order shuffled with a fixed seed in `10_rater_sheet.R`) | id |
| `group_label` | Revelio `role_k50_v3` label (licensed) | text |
| `coord_dependence_rater` | mean of the three raters on the scale "dependence on coordination with the parents"; written only because ICC(2,k) >= 0.70 | 1 to 5 |
| `local_embeddedness_rater` | mean of the three raters on the scale "dependence on the host country"; written only because ICC(2,k) >= 0.70 | 1 to 5 |

## Rater and O\*NET scores per group (`data/interim/rater-onet-groups-2026-11-26.csv`)

Built by `code/R/12_rater_onet_comparison.R`. The rows and columns of `rater-scores-2026-11-26.csv` plus, per `role_k50` group: `n_codes` (O\*NET codes in the group), `n_entries` (taxonomy entries, the weights), `share_imputed` (share of the weight on occupations with imputed scores), `coord_dependence_onet` and `local_embeddedness_onet` (weighted means of the occupation scores of `07_contingency_scores.R`, standardized units). Correlations in `data/interim/rater-onet-comparison-2026-11-26.md`.

## Panels (stage 6, 2026-11-26)

Built by `code/R/02_build_panel.R` (hire-level staffing frame and employee
stocks) and `code/R/03_measures.R` (cell-year panels) under the approved
pre-analysis plan pap-v1.0 (`reviews/gate-5-pre-analysis-plan.md`, A2 to A4,
B0, B5), helpers in `code/R/functions/panel_build.R`, `measures.R`,
`panel_ijv.R` and `resource_dependence.R`. Licensed, in `data/processed/`
(gitignored). Counts at every step: `data/processed/sample-construction-log.md`.

| File | Unit (key) | Use in the plan |
|---|---|---|
| `panel-ijv-domain-year-v1.parquet` | IJV x domain x year (`ijv_id`, `domain`, `year`); 98 domains, narrow `REG` carved out | H1, H2, H3; H4 with the narrow list (robustness) |
| `panel-ijv-domain-b-year-v1.parquet` | IJV x domain x year; domains with the 22 broad-list codes carved out as `REG_B` | H4a, H4b (confirmatory measure since the feasibility rule of 2026-11-25) |
| `panel-ijv-level-year-v1.parquet` | IJV x level x year (`level`, mapping a) | C1; levels part of H1 (exploratory) |
| `panel-ijv-level-b-year-v1.parquet` | IJV x level x year (`level`, mapping b) | robustness 18b |
| `panel-ijv-seniority-year-v1.parquet` | IJV x seniority (1 to 7) x year | robustness 18c (linear term) |
| `panel-ijv-function-year-v1.parquet` | IJV x `fn` x year (Revelio `role_k10_v3`) | grain robustness 5 (stands in for the nine functions; see the gate 6 file) |
| `panel-ijv-role50-year-v1.parquet` | IJV x `role_k50` x year | grain robustness 5; rater scores (robustness 6) |
| `panel-ijv-attributes-v1.parquet` | IJV (`ijv_id`) | every IJV-level variable below, incl. those not repeated in the panels |
| `panel-ijv-year-v1.parquet` | IJV x year | `staff_revelio`, `headcount_orbis_u`, `coverage_ratio` |

Rows: every cell-year with at least one employee on 30 June or at least one
hire, from the IJV's formation year to 2025. `main_period` = 1 marks hire years
2010 to 2025 (main sample); earlier rows serve the full-period check
(robustness 12). Hires without a value of the grain (no usable O\*NET code, no
seniority, no Revelio function or group) are left out of that panel only; their
numbers are in the log. Counts are integers; shares are missing where the
denominator is zero. Indicators are integers 0/1.

### Cell counts (hiring flows; unit: hires in the cell-year)

| Variable | Construction |
|---|---|
| `n_emp` | employees on 30 June of the year in the cell (unique people; cell rule only) |
| `n_emp_xi`, `n_emp_xl` | the same without positions in occupations with imputed scores, and without positions coded through the role lookup (domain panels) |
| `n_hires` | hires (first dated position at the JV entity) with hire year = `year` |
| `n_local_parent`, `n_intl_parent`, `n_parent_na` | parent-origin hires (a prior position in the three-year window in a parent's Revelio family): the most recent such position in the host country, abroad, without a country |
| `n_local_indep`, `n_intl_indep`, `n_indep_na` | independent hires (prior positions in the window, none in a parent family; unmapped employers included): the most recent prior position in the host country, abroad, without a country |
| `n_not_obs` | history not observed: no prior position in the window |
| `n_parent`, `n_indep`, `n_obs` | sums of the three parent-origin categories, of the three independent categories, and of all six |
| `n_local`, `n_intl`, `n_geo` | `n_local_parent + n_local_indep`; `n_intl_parent + n_intl_indep`; `n_local + n_intl` (= `n_obs - n_parent_na - n_indep_na`) |
| `n_entrant` | labor market entrants among `n_not_obs` (education window three years); `n_entrant_local`, `n_entrant_intl`, `n_entrant_na` by place of education |
| `n_entrant_e1`, `n_entrant_e5` | entrants with education windows of one and five years (robustness 10) |
| `n_unknown`, `n_unknown_e1`, `n_unknown_e5` | `n_not_obs` minus the entrants of the respective window |
| `n_local_parent_hcp` | local parent-origin hires whose parent is a host-country parent (direct shareholder country; robustness 13c) |
| `n_intl_parent_home` | international parent-origin hires whose prior position was in the home country of one of the IJV's foreign direct parents (C1 parts b and c) |
| `n_obs_unmapped` | hires with an observed history whose deciding prior employer is not mapped to a Revelio company (robustness 12) |
| `*_ow1`, `*_ow5` | `n_obs`, the six categories, `n_parent`, `n_indep`, `n_local`, `n_intl`, `n_geo`, `n_not_obs` and `n_unknown` with origin windows of one and five years (robustness 17) |
| `*_xi`, `*_xl` | `n_hires`, the six categories and their sums (`n_obs`, `n_parent`, `n_indep`, `n_local`, `n_intl`, `n_geo`, `n_not_obs`) without hires in occupations with imputed scores (`xi`) and without hires coded through the role lookup (`xl`) (robustness 7) |

Identities checked on every row (`check_identities()`): `n_hires = n_obs +
n_not_obs`; `n_not_obs = n_entrant + n_unknown`; `n_obs` = the six categories;
`n_geo = n_obs - n_parent_na - n_indep_na`; the same for the window variants.

### Shares (estimands only; plan A3)

| Variable | Definition |
|---|---|
| `share_parent` | `n_parent / n_obs` (H1) |
| `share_local` | `n_local / n_geo` (H2, H4a; A3 denominator) |
| `share_parent_local` | `n_local_parent / n_local` (H3, H4b ii) |
| `share_not_obs`, `share_entrant`, `share_unknown` | `n_not_obs`, `n_entrant`, `n_unknown` over `n_hires` |
| `share_unmapped` | `n_obs_unmapped / n_obs` |

### Cell rules

`cell_emp5` (`n_emp >= 5`, primary), `cell_emp3`, `cell_emp10` (robustness 4),
`cell_hires5` (`n_hires >= 5`, sensitivity rule).

### IJV variables (repeated on every panel row; the attributes table holds them all)

| Variable | Definition |
|---|---|
| `host_country`, `formation_year`, `source`, `route`, `n_parents`, `strategic` | from the matched dataset (`strategic` as 0/1) |
| `parent_in_revelio`, `all_parents_in_revelio` | at least one parent, every parent has a Revelio entity (gate 4, decision 8a) |
| `host_parent` | a direct parent from the host country (A2.3) |
| `host_parent_guo` | owner basis: a parent whose Orbis GUO country is the host country; Orbis-sourced IJVs with every GUO known, else missing |
| `host_parent_in_revelio` | the host-country parent itself has a Revelio entity (H3 robustness) |
| `h3_sample` | `host_parent` and `parent_in_revelio` (H3 sample) |
| `flag_jv_in_parent_family` | matched entity in a parent's Revelio family (831 IJVs; kept in the main sample, audit of 2026-11-26; dropping them is robustness 11) |
| `flag_listed` | listed JV (gate 4, decision 2): Orbis status `Listed` for Orbis-sourced IJVs; an ISIN on record for Capital IQ-sourced IJVs (`listed_basis` in the attributes table). The frame holds no ISIN for any Capital IQ-sourced IJV, so in the 2026-11-26 build only Orbis-sourced IJVs are flagged |
| `usable_30` | Revelio headcount of the matched entity at least 30 (robustness 13e) |
| S13 variables | as in "Shock" above; `dyad` and `dyad_all` (host plus all foreign direct parent countries, robustness 3) |
| `formed_pre2016`, `formed_from2021` | formation year before 2016 (robustness 15f); from 2021 |
| `coverage_ratio` | IJV-year: Revelio staff on 30 June over the unconsolidated Orbis headcount of the closing year (U1, U2; twelve-month accounts first, then the latest closing date), from 2015 on (robustness 14) |

Attributes table only: `region`, `industry`, `formation_year_missing`,
`admitted_by`, `match_tier`, `ijv_n_emp`, `jv_employees_orbis`,
`n_parents_in_revelio`, `flag_shared_family_entity`, `flag_pre_formation_10y`,
`flag_holding_vehicle`, `flag_size_mismatch`, `listed_basis`, `pair_exposure`,
`eu_stake_max`, `eu_stake_band`, `s13_frame_control`, `no_foreign_direct`,
`guo_uk_link`, `s13_owner_link_dropped`, `dyad_source`.

### Year variables

`post`, `antic_yr`, `post16`, `shock`, `antic`, `shock16`, `event_time` (see
"Shock"), `main_period`.

### Regressors by grain

| Panel | Variables | Source and construction |
|---|---|---|
| domain, domain-b | `local_embeddedness`, `coord_dependence`, `*_broad`, `*_lv`, `law_gov_importance`, `job_zone`; `score_imputed_domain` (no rated occupation in the domain) | domain panel: `contingency-scores-domain-v1-2026-11-25.csv`; domain-b panel: the same rule (unweighted mean of the domain's rated occupations) applied by `domain_b_scores()` to the occupation table with the broad list carved out. Standardized units (occupation SD) |
| domain, domain-b | `reg`, `reg_list` (`narrow`/`broad`), `reg_b` (domain-b), `treat_reg`, `exp_post_reg`, `exp_antic_reg`, `cd_host`, `cd_nohost` (`coord_dependence` x `host_parent`, x `1 - host_parent`) | derived |
| domain, domain-b | `rd_core`, `rd_ratio` | robustness 19, available case: 1 if the domain's employment share in the industry of any parent with an OEWS-matched code is at least twice its share across all industries; largest log ratio over those parents (missing where a parent industry has no employment in the domain). BLS OEWS May 2021; parent industry rule v2; OEWS match exact 4-digit, combined industry, 3-digit. The regulatory domain's share sums its SOC detailed codes, which are subtracted from their minor groups; suppressed cells count as zero |
| domain, domain-b | `rd_core_hcp`, `rd_ratio_hcp` | the same for the host-country parent (the largest-equity one among host-country parents with a matched code; H3) |
| domain, domain-b | `rd_code_missing`, `rd_all_coded`, `rd_any_coded` | some parent / every parent / at least one parent with a matched code (IJV level) |
| level, level-b, seniority | `coord_role` | 1 for `executive` and `middle_management` (`mintzberg1979structuring`); the seniority panel also carries `level` and `level_b` |
| function, role50 | the eight scores, `n_codes`, `share_imputed`, `cd_host`, `cd_nohost` | occupation scores averaged over the O\*NET codes of the group, weighted by the number of `role_k17000_v3` entries per code (rule of the rater comparison of 2026-11-25); a group or function without O\*NET-coded taxonomy entries (for example `Miscellaneous`) has no score |
| role50 | `coord_dependence_rater`, `local_embeddedness_rater` | rater means per `role_k50` group (`rater-scores-2026-11-26.csv`; 1 to 5; both scales passed ICC(2,k) >= 0.70) |

Interim files of `02_build_panel.R` (person level, gitignored):
`data/interim/panel-hires-v1.parquet` (one row per hire with its
classification), `panel-stock-<grain>-v1.parquet`, `panel-staff-ijv-year-v1.parquet`,
`panel-families-v1.rds`, `panel-build-log-v1.csv`.

### Synthetic twin (2026-11-26)

`code/R/tests/synthetic_panel_build.R` (seed 20261126) writes made-up input
tables with the columns of every real input to
`data/synthetic/panel-build-synthetic-2026-11-26/` (12 IJVs, about 560 JV
positions, 20 seeded people with known expected results in
`seeded-cases.csv`); `02_build_panel.R synthetic` and `03_measures.R synthetic`
write their outputs to its `build/` folder. `code/R/tests/check_panel_build.R`
runs all three and checks the seeded cases, the identities, the cell sums and
the schema against the stage 5 simulated panel
(`data/synthetic/panel-build-test-synthetic-2026-11-26.md`).
