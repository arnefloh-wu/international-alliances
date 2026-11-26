# Sample construction log: stage 6 panels

Produced by `code/R/02_build_panel.R` and `code/R/03_measures.R` (synthetic run, 2026-11-26), following `reviews/gate-5-pre-analysis-plan.md` (pap-v1.0). Counts at every step from the matched frame (`core_main`) to the final panels, with the rule that removed each group of rows. Structural counts only.

| Part | Step | n | Unit | Removed | Rule |
|---|---|---|---|---|---|
| 1 IJVs | matched frame (core_main of frame v3) | 12 | IJVs |  | ijv-matched table; one row per IJV |
| 1 IJVs | IJVs whose matched entity lies in a parent's Revelio family (flag_jv_in_parent_family; kept, audit of 2026-11-26) | 1 | IJVs |  | entity removed from the parent family for that IJV only |
| 1 IJVs | IJVs with an entity in two parents' families (flag_shared_family_entity) | 1 | IJVs |  | entity assigned to the parent with the larger equity share |
| 2 Spells | positions in the spell table | 567 | positions |  |  |
| 2 Spells | after removing repeated position_id | 564 | positions | 3 | copies after the first dropped |
| 2 Spells | filed under an IJV of the frame | 564 | positions | 0 | stray entities dropped |
| 2 Spells | with valid 30 June reference years | 564 | positions | 0 | positions without a reference year dropped |
| 2 Spells | IJVs with at least one spell | 12 | IJVs |  |  |
| 2 Spells | people with spells at two or more IJVs (each person-IJV pair counted at its IJV) | 1 | people |  |  |
| 3 Hires | positions at the matched JV entities (all, incl. stays without a 30 June) | 565 | positions | 1 | repeated position_id dropped |
| 3 Hires | person-IJV pairs in the spell table | 563 | pairs |  |  |
| 3 Hires | pairs without any position record at the JV entity | 0 | pairs |  | dropped |
| 3 Hires | pairs with a dated first position (hires) | 562 | hires | 1 | pairs whose positions at the JV all lack a start date dropped |
| 3 Hires | hire year from the formation year on | 561 | hires | 1 | hired before the formation (incorporation) year |
| 3 Hires | hire year up to 2025 | 560 | hires | 1 | hired in 2026 (Revelio data end 2026-09) |
| 3 Hires | of these, hire year 2010 to 2025 (main period) | 453 | hires |  | earlier hires kept for the full-period check (main_period = 0) |
| 3 Hires | hires whose first position covers no 30 June (not in the spell table; occupation from the role lookup) | 1 | hires |  |  |
| 3 Hires | people hired by two or more IJVs (a hire at each) | 1 | people |  |  |
| 3 Hires | hires coded through the role lookup (onet_source = lookup) | 2 | hires |  |  |
| 3 Hires | hires without a usable O*NET code (unknown, Retired, On Leave, missing): no domain | 1 | hires |  |  |
| 3 Hires | hires in occupations with imputed scores (score_imputed) | 7 | hires |  |  |
| 3 Hires | hires without a Revelio seniority: no level | 1 | hires |  |  |
| 4 Histories | history positions read | 1,197 | positions |  |  |
| 4 Histories | after removing repeated position_id | 1,195 | positions | 2 | copies after the first dropped |
| 4 Histories | positions of hired people | 1,192 | positions |  |  |
| 4 Histories | hired people without any history position | 0 | people |  |  |
| 4 Histories | with a start date | 1,190 | positions | 2 | positions without a start date cannot precede a hire; dropped |
| 4 Histories | end date not before start date | 1,189 | positions | 1 | positions ending before they start dropped |
| 4 Histories | open-ended positions (no end date; treated as held until today) | 215 | positions |  |  |
| 4 Histories | positions at employers not mapped to a Revelio company (count as independent) | 141 | positions |  |  |
| 4 Histories | positions without a country that converts to ISO 2 | 24 | positions |  |  |
| 5 Frame | hires classified (all years from formation to 2025) | 560 | hires |  |  |
| 6 Stock | spells without a usable O*NET code (not in the domain stocks) | 1 | positions |  |  |
| 6 Stock | spells without a seniority (not in the level stocks) | 1 | positions |  |  |
| 6 Stock | IJV x domain x year cells with at least one employee on 30 June | 1,281 | cells |  |  |
| 6 Stock | IJV x domain_b x year cells with at least one employee on 30 June | 1,257 | cells |  |  |
| 6 Stock | IJV x level x year cells with at least one employee on 30 June | 750 | cells |  |  |
| 6 Stock | IJV x level_b x year cells with at least one employee on 30 June | 686 | cells |  |  |
| 6 Stock | IJV x seniority x year cells with at least one employee on 30 June | 1,098 | cells |  |  |
| 6 Stock | IJV x fn x year cells with at least one employee on 30 June | 964 | cells |  |  |
| 6 Stock | IJV x role50 x year cells with at least one employee on 30 June | 849 | cells |  |  |
| 7 Regressors | role_k50 groups with rater scores (ICC(2,k) >= 0.70 on both scales) | 5 | groups |  |  |
| 7 Regressors | parents with an OEWS industry (4-digit, combined or 3-digit) | 20 | parents |  | 4-digit 8, combined 4, 3-digit 8 |
| 7 Regressors | IJVs with an OEWS-matched code for at least one parent / for every parent | 12 / 8 | IJVs |  |  |
| 8 Panel domain | hires with a value of the grain (all years / main period) | 559 / 452 | hires |  | hires without a value dropped from this panel: 1 (main period 1) |
| 8 Panel domain | cell-years, all years from formation to 2025 | 1,334 | cells |  |  |
| 8 Panel domain | cell-years in the main period 2010 to 2025 | 1,177 | cells |  | earlier years kept, main_period = 0 |
| 8 Panel domain | main-period cell-years with at least 5 employees on 30 June (cell rule) | 185 | cells |  |  |
| 8 Panel domain | main-period cell-years with at least 5 hires (sensitivity rule) | 0 | cells |  |  |
| 8 Panel domain | main-period cell-years with at least 5 employees and n_obs >= 1 | 71 | cells |  |  |
| 8 Panel domain_b | hires with a value of the grain (all years / main period) | 559 / 452 | hires |  | hires without a value dropped from this panel: 1 (main period 1) |
| 8 Panel domain_b | cell-years, all years from formation to 2025 | 1,308 | cells |  |  |
| 8 Panel domain_b | cell-years in the main period 2010 to 2025 | 1,154 | cells |  | earlier years kept, main_period = 0 |
| 8 Panel domain_b | main-period cell-years with at least 5 employees on 30 June (cell rule) | 188 | cells |  |  |
| 8 Panel domain_b | main-period cell-years with at least 5 hires (sensitivity rule) | 0 | cells |  |  |
| 8 Panel domain_b | main-period cell-years with at least 5 employees and n_obs >= 1 | 73 | cells |  |  |
| 8 Panel level | hires with a value of the grain (all years / main period) | 559 / 452 | hires |  | hires without a value dropped from this panel: 1 (main period 1) |
| 8 Panel level | cell-years, all years from formation to 2025 | 772 | cells |  |  |
| 8 Panel level | cell-years in the main period 2010 to 2025 | 664 | cells |  | earlier years kept, main_period = 0 |
| 8 Panel level | main-period cell-years with at least 5 employees on 30 June (cell rule) | 318 | cells |  |  |
| 8 Panel level | main-period cell-years with at least 5 hires (sensitivity rule) | 1 | cells |  |  |
| 8 Panel level | main-period cell-years with at least 5 employees and n_obs >= 1 | 143 | cells |  |  |
| 8 Panel level_b | hires with a value of the grain (all years / main period) | 559 / 452 | hires |  | hires without a value dropped from this panel: 1 (main period 1) |
| 8 Panel level_b | cell-years, all years from formation to 2025 | 707 | cells |  |  |
| 8 Panel level_b | cell-years in the main period 2010 to 2025 | 613 | cells |  | earlier years kept, main_period = 0 |
| 8 Panel level_b | main-period cell-years with at least 5 employees on 30 June (cell rule) | 304 | cells |  |  |
| 8 Panel level_b | main-period cell-years with at least 5 hires (sensitivity rule) | 2 | cells |  |  |
| 8 Panel level_b | main-period cell-years with at least 5 employees and n_obs >= 1 | 152 | cells |  |  |
| 8 Panel seniority | hires with a value of the grain (all years / main period) | 559 / 452 | hires |  | hires without a value dropped from this panel: 1 (main period 1) |
| 8 Panel seniority | cell-years, all years from formation to 2025 | 1,138 | cells |  |  |
| 8 Panel seniority | cell-years in the main period 2010 to 2025 | 1,000 | cells |  | earlier years kept, main_period = 0 |
| 8 Panel seniority | main-period cell-years with at least 5 employees on 30 June (cell rule) | 229 | cells |  |  |
| 8 Panel seniority | main-period cell-years with at least 5 hires (sensitivity rule) | 0 | cells |  |  |
| 8 Panel seniority | main-period cell-years with at least 5 employees and n_obs >= 1 | 84 | cells |  |  |
| 8 Panel fn | hires with a value of the grain (all years / main period) | 560 / 453 | hires |  | hires without a value dropped from this panel: 0 (main period 0) |
| 8 Panel fn | cell-years, all years from formation to 2025 | 998 | cells |  |  |
| 8 Panel fn | cell-years in the main period 2010 to 2025 | 869 | cells |  | earlier years kept, main_period = 0 |
| 8 Panel fn | main-period cell-years with at least 5 employees on 30 June (cell rule) | 247 | cells |  |  |
| 8 Panel fn | main-period cell-years with at least 5 hires (sensitivity rule) | 0 | cells |  |  |
| 8 Panel fn | main-period cell-years with at least 5 employees and n_obs >= 1 | 107 | cells |  |  |
| 8 Panel role50 | hires with a value of the grain (all years / main period) | 560 / 453 | hires |  | hires without a value dropped from this panel: 0 (main period 0) |
| 8 Panel role50 | cell-years, all years from formation to 2025 | 874 | cells |  |  |
| 8 Panel role50 | cell-years in the main period 2010 to 2025 | 754 | cells |  | earlier years kept, main_period = 0 |
| 8 Panel role50 | main-period cell-years with at least 5 employees on 30 June (cell rule) | 295 | cells |  |  |
| 8 Panel role50 | main-period cell-years with at least 5 hires (sensitivity rule) | 1 | cells |  |  |
| 8 Panel role50 | main-period cell-years with at least 5 employees and n_obs >= 1 | 119 | cells |  |  |

## IJV subsets and S13 groups

| core_main| with_hire_main| parent_in_revelio| all_parents_in_revelio| host_parent| host_parent_in_revelio| h3_sample| strategic| flag_jv_in_parent_family| flag_shared_family_entity| flag_listed| listed_orbis| listed_ciq_isin| flag_pre_formation_10y| flag_holding_vehicle| flag_size_mismatch| usable_30| owner_level| formed_pre2016| formed_from2021|
|---------:|--------------:|-----------------:|----------------------:|-----------:|----------------------:|---------:|---------:|------------------------:|-------------------------:|-----------:|------------:|---------------:|----------------------:|--------------------:|------------------:|---------:|-----------:|--------------:|---------------:|
|        12|             12|                12|                     11|           9|                      9|         9|        12|                        1|                         1|           2|            1|               1|                      0|                    0|                  0|        12|           2|             12|               0|

| exposed| exposed_pairs| exposed_parent_in_revelio| exposed_h3| frame_controls| controls_no_foreign_direct| owner_link_dropped| controls| controls_parent_in_revelio| control_dyads| third_country| gb_ie| uk_hosted_exposed| control_linked| stake_exactly_50| stake_below_50| exposed_no_ie| exposed_guo| exposed_formed_from2021| exposed_owner_level| controls_owner_level|
|-------:|-------------:|-------------------------:|----------:|--------------:|--------------------------:|------------------:|--------:|--------------------------:|-------------:|-------------:|-----:|-----------------:|--------------:|----------------:|--------------:|-------------:|-----------:|-----------------------:|-------------------:|--------------------:|
|       4|             3|                         4|          2|              4|                          2|                  1|        3|                          3|             3|             1|     1|                 3|              1|                1|              1|             3|           4|                       0|                   0|                    1|

## Panels

|panel              |grain     | rows_all_years| ijvs_all_years| rows_main| ijvs_main| values_main| years_main| cells_emp5| ijvs_emp5| cells_hires5| ijvs_hires5| cells_emp3| cells_emp10| cells_emp5_obs1| cells_emp5_geo1| cells_emp5_local1| hires_main| hires_emp5|
|:------------------|:---------|--------------:|--------------:|---------:|---------:|-----------:|----------:|----------:|---------:|------------:|-----------:|----------:|-----------:|---------------:|---------------:|-----------------:|----------:|----------:|
|ijv-domain-year    |domain    |          1,334|             12|     1,177|        12|           8|         16|        185|        12|            0|           0|        494|           5|              71|              69|                53|        452|        135|
|ijv-domain-b-year  |domain    |          1,308|             12|     1,154|        12|           8|         16|        188|        12|            0|           0|        487|           5|              73|              70|                52|        452|        142|
|ijv-level-year     |level     |            772|             12|       664|        12|           4|         16|        318|        12|            1|           1|        448|          56|             143|             141|               104|        452|        308|
|ijv-level-b-year   |level     |            707|             12|       613|        12|           4|         16|        304|        12|            2|           2|        419|          89|             152|             151|               109|        452|        328|
|ijv-seniority-year |seniority |          1,138|             12|     1,000|        12|           7|         16|        229|        12|            0|           0|        528|           5|              84|              84|                59|        452|        159|
|ijv-function-year  |fn        |            998|             12|       869|        12|           5|         16|        247|        12|            0|           0|        479|          29|             107|             104|                77|        453|        228|
|ijv-role50-year    |role_k50  |            874|             12|       754|        12|           5|         16|        295|        12|            1|           1|        505|          17|             119|             117|                87|        453|        240|

## Estimation samples (structure only)

|panel    |sample                                                                                    | cells| ijvs| ijv_years| exposed_ijvs| exposed_pairs| control_ijvs| control_dyads|note      | control_linked_ijvs|
|:--------|:-----------------------------------------------------------------------------------------|-----:|----:|---------:|------------:|-------------:|------------:|-------------:|:---------|-------------------:|
|domain   |H1: parent in Revelio, n_obs >= 1                                                         |    71|   11|        61|           NA|            NA|           NA|            NA|NA        |                  NA|
|domain   |H2: core_main, n_geo >= 1                                                                 |    69|   11|        61|           NA|            NA|           NA|            NA|NA        |                  NA|
|domain   |H3: parent in Revelio, n_local >= 1 (host-country parent or not)                          |    53|   11|        49|           NA|            NA|           NA|            NA|NA        |                  NA|
|domain   |H1, 5-hires rule: parent in Revelio, n_hires >= 5, n_obs >= 1                             |     0|    0|         0|           NA|            NA|           NA|            NA|NA        |                  NA|
|domain_b |H4: S13 sample, parent in Revelio, n_hires >= 1                                           |    52|    7|        45|            4|             3|            3|             3|NA        |                  NA|
|domain_b |H4: exposed REG_B cells in 2013-2015 and from 2021 (IJVs in both periods; pairs in extra) |     0|    0|         0|            0|             0|           NA|            NA|NA        |                  NA|
|domain_b |H4 lead-pooling rule: exposed REG_B cells with n_hires >= 1 in 2010 / 2011 / 2012         |     0|    0|         0|           NA|            NA|           NA|            NA|0 / 0 / 0 |                  NA|
|level    |C1: S13 sample, parent in Revelio, n_hires >= 1                                           |   109|    7|        77|            4|             3|            3|             3|NA        |                   1|
|level    |H1 levels: parent in Revelio, n_obs >= 1                                                  |   143|   12|       113|           NA|            NA|           NA|            NA|NA        |                  NA|
