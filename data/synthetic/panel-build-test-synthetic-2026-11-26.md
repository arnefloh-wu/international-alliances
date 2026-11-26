# Panel build check (synthetic), 2026-11-26

Written by `code/R/tests/check_panel_build.R`.
Simulated data only (`code/R/tests/synthetic_panel_build.R`, seed 20261126).

Result: 93 of 93 checks pass.

|group                              |check                                                                                        |result |detail                                                             |
|:----------------------------------|:--------------------------------------------------------------------------------------------|:------|:------------------------------------------------------------------|
|run                                |code/R/tests/synthetic_panel_build.R runs to the end                                         |PASS   |                                                                   |
|run                                |code/R/02_build_panel.R runs to the end                                                      |PASS   |                                                                   |
|run                                |code/R/03_measures.R runs to the end                                                         |PASS   |                                                                   |
|S01 repeated position ids          |n_hires_person = 1                                                                           |PASS   |got 1                                                              |
|S01 repeated position ids          |cat_w3 = local_parent                                                                        |PASS   |got local_parent                                                   |
|S02 undated only position          |n_hires_person = 0                                                                           |PASS   |got 0                                                              |
|S03 undated plus dated             |year = 2015                                                                                  |PASS   |got 2015                                                           |
|S04 history start missing          |cat_w3 = not_obs                                                                             |PASS   |got not_obs                                                        |
|S05 open-ended parent position     |cat_w1 = local_parent                                                                        |PASS   |got local_parent                                                   |
|S05 open-ended parent position     |cat_w3 = local_parent                                                                        |PASS   |got local_parent                                                   |
|S06 open-ended JV position         |in_stock_2025 = TRUE                                                                         |PASS   |got TRUE                                                           |
|S07 person at two IJVs             |year = 2012                                                                                  |PASS   |got 2012                                                           |
|S07 person at two IJVs             |year = 2017                                                                                  |PASS   |got 2017                                                           |
|S07 person at two IJVs             |cat_w3 = intl_indep                                                                          |PASS   |got intl_indep                                                     |
|S08 hire 2008                      |year = 2008                                                                                  |PASS   |got 2008                                                           |
|S08 hire 2026                      |n_hires_person = 0                                                                           |PASS   |got 0                                                              |
|S08 hire before formation          |n_hires_person = 0                                                                           |PASS   |got 0                                                              |
|S09 parent's own entity as IJV     |cat_w3 = local_parent                                                                        |PASS   |got local_parent                                                   |
|S10 origin windows                 |cat_w1 = not_obs                                                                             |PASS   |got not_obs                                                        |
|S10 origin windows                 |cat_w3 = local_indep                                                                         |PASS   |got local_indep                                                    |
|S10 origin windows                 |cat_w5 = intl_parent                                                                         |PASS   |got intl_parent                                                    |
|S11 entrant                        |entrant_e1 = FALSE                                                                           |PASS   |got FALSE                                                          |
|S11 entrant                        |entrant_e3 = TRUE                                                                            |PASS   |got TRUE                                                           |
|S11 entrant                        |entrant_place = local                                                                        |PASS   |got local                                                          |
|S12 unmapped employer              |cat_w3 = intl_indep                                                                          |PASS   |got intl_indep                                                     |
|S12 unmapped employer              |employer_mapped = FALSE                                                                      |PASS   |got FALSE                                                          |
|S13 country missing                |cat_w3 = parent_na                                                                           |PASS   |got parent_na                                                      |
|S14 shared family entity           |cat_w3 = local_parent                                                                        |PASS   |got local_parent                                                   |
|S14 shared family entity           |p_host = TRUE                                                                                |PASS   |got TRUE                                                           |
|S15 home-country parent hire       |cat_w3 = intl_parent                                                                         |PASS   |got intl_parent                                                    |
|S15 home-country parent hire       |home_country = TRUE                                                                          |PASS   |got TRUE                                                           |
|S16 invalid O*NET value            |domain = NA                                                                                  |PASS   |got NA                                                             |
|S16 invalid O*NET value            |level = middle_management                                                                    |PASS   |got middle_management                                              |
|S17 lookup-coded position          |onet_source = lookup                                                                         |PASS   |got lookup                                                         |
|S17 lookup-coded position          |domain_b = REG_B                                                                             |PASS   |got REG_B                                                          |
|S18 seniority missing              |level = NA                                                                                   |PASS   |got NA                                                             |
|S19 end before start               |cat_w3 = not_obs                                                                             |PASS   |got not_obs                                                        |
|S20 first position without 30 June |year = 2014                                                                                  |PASS   |got 2014                                                           |
|S20 first position without 30 June |hire_in_spells = FALSE                                                                       |PASS   |got FALSE                                                          |
|S20 first position without 30 June |onet_source = lookup                                                                         |PASS   |got lookup                                                         |
|S01 repeated position ids          |spell copies removed (log)                                                                   |PASS   |3 copies seeded: 2 for the seeded person's duplicated row, 1 extra |
|S01 repeated position ids          |history copies removed (log)                                                                 |PASS   |                                                                   |
|S02 undated only position          |pairs without a dated position dropped (log)                                                 |PASS   |                                                                   |
|S08 hires outside 2010 to 2025     |no panel year after 2025                                                                     |PASS   |                                                                   |
|S08 hires outside 2010 to 2025     |the 2008 hire is in a full-period row with main_period = 0                                   |PASS   |                                                                   |
|S08 hires outside 2010 to 2025     |hire before the formation year dropped (log)                                                 |PASS   |                                                                   |
|S08 hires outside 2010 to 2025     |2026 hire dropped (log)                                                                      |PASS   |                                                                   |
|S09 parent's own entity as IJV     |IJV flagged flag_jv_in_parent_family                                                         |PASS   |                                                                   |
|S09 parent's own entity as IJV     |IJV kept in the panels                                                                       |PASS   |                                                                   |
|S14 shared family entity           |IJV flagged flag_shared_family_entity                                                        |PASS   |                                                                   |
|S07 person at two IJVs             |two hires for the person                                                                     |PASS   |                                                                   |
|S16 invalid O*NET value            |hire counted in the level panel, not in the domain panel                                     |PASS   |                                                                   |
|S18 seniority missing              |level panel hires equal hires with a level                                                   |PASS   |                                                                   |
|S13 coding                         |exposed IJVs are 1, 2, 3, 12                                                                 |PASS   |                                                                   |
|S13 coding                         |owner-level control with a UK ultimate owner dropped (IJV 5), the other kept (IJV 6)         |PASS   |                                                                   |
|S13 coding                         |controls are IJVs 4, 6 and 10 (EU-hosted, no UK-set link)                                    |PASS   |                                                                   |
|S13 coding                         |third-country pair (IJV 7) in neither group                                                  |PASS   |                                                                   |
|S13 coding                         |gb_ie only for IJV 3                                                                         |PASS   |                                                                   |
|S13 coding                         |Rule C: IJV 1 (DE 60) control-linked; IJV 12 (FR 50) and IJV 3 (IE 40) not                   |PASS   |                                                                   |
|S13 coding                         |dyads: exposure pair, foreign direct parent, foreign ultimate owner                          |PASS   |                                                                   |
|Listed JVs                         |Orbis 'Listed' (IJV 1) and Capital IQ with ISIN (IJV 11) flagged; 'Delisted' (IJV 12) not    |PASS   |                                                                   |
|Namibia                            |host country code NA kept as a value                                                         |PASS   |                                                                   |
|identities                         |domain: A3 identities hold on every row                                                      |PASS   |                                                                   |
|sums                               |domain: cell hires sum to the hires with a value of the grain                                |PASS   |                                                                   |
|keys                               |domain: one row per IJV x domain x year                                                      |PASS   |                                                                   |
|identities                         |domain_b: A3 identities hold on every row                                                    |PASS   |                                                                   |
|sums                               |domain_b: cell hires sum to the hires with a value of the grain                              |PASS   |                                                                   |
|keys                               |domain_b: one row per IJV x domain x year                                                    |PASS   |                                                                   |
|identities                         |level: A3 identities hold on every row                                                       |PASS   |                                                                   |
|sums                               |level: cell hires sum to the hires with a value of the grain                                 |PASS   |                                                                   |
|keys                               |level: one row per IJV x level x year                                                        |PASS   |                                                                   |
|identities                         |level_b: A3 identities hold on every row                                                     |PASS   |                                                                   |
|sums                               |level_b: cell hires sum to the hires with a value of the grain                               |PASS   |                                                                   |
|keys                               |level_b: one row per IJV x level x year                                                      |PASS   |                                                                   |
|identities                         |seniority: A3 identities hold on every row                                                   |PASS   |                                                                   |
|sums                               |seniority: cell hires sum to the hires with a value of the grain                             |PASS   |                                                                   |
|keys                               |seniority: one row per IJV x seniority x year                                                |PASS   |                                                                   |
|identities                         |fn: A3 identities hold on every row                                                          |PASS   |                                                                   |
|sums                               |fn: cell hires sum to the hires with a value of the grain                                    |PASS   |                                                                   |
|keys                               |fn: one row per IJV x fn x year                                                              |PASS   |                                                                   |
|identities                         |role50: A3 identities hold on every row                                                      |PASS   |                                                                   |
|sums                               |role50: cell hires sum to the hires with a value of the grain                                |PASS   |                                                                   |
|keys                               |role50: one row per IJV x role_k50 x year                                                    |PASS   |                                                                   |
|grains                             |REG in the domain panel, REG_B in the domain-b panel                                         |PASS   |                                                                   |
|grains                             |regressors complete in the domain panels                                                     |PASS   |                                                                   |
|grains                             |resource dependence set for some cells                                                       |PASS   |                                                                   |
|grains                             |parents with a code reach an OEWS industry, short codes through the 3-digit match (20 of 24) |PASS   |                                                                   |
|grains                             |rater scores on the role_k50 panel                                                           |PASS   |                                                                   |
|schema                             |synthetic domain panel: every column of the stage 5 simulated panel is present               |PASS   |                                                                   |
|schema                             |synthetic domain panel: types compatible with the simulated panel                            |PASS   |                                                                   |
|schema                             |synthetic domain panel: every variable named in the plan's model formulas is present         |PASS   |                                                                   |
|schema                             |synthetic domain panel: no column named 'function'                                           |PASS   |                                                                   |
|schema                             |synthetic level panel: every variable of the C1 and level models is present                  |PASS   |                                                                   |
