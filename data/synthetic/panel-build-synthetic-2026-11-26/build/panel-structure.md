# Panel structure (synthetic), 2026-11-26

Written by `code/R/03_measures.R`. Structural counts only: denominators, cells, flags and the pooled share of each origin class over all hires of 2010 to 2025. Nothing is broken down by exposure, host-country parent, score, domain, level or year (real_data_lock; plan A5).

## IJVs

| core_main| with_hire_main| parent_in_revelio| all_parents_in_revelio| host_parent| host_parent_in_revelio| h3_sample| strategic| flag_jv_in_parent_family| flag_shared_family_entity| flag_listed| listed_orbis| listed_ciq_isin| flag_pre_formation_10y| flag_holding_vehicle| flag_size_mismatch| usable_30| owner_level| formed_pre2016| formed_from2021|
|---------:|--------------:|-----------------:|----------------------:|-----------:|----------------------:|---------:|---------:|------------------------:|-------------------------:|-----------:|------------:|---------------:|----------------------:|--------------------:|------------------:|---------:|-----------:|--------------:|---------------:|
|        12|             12|                12|                     11|           9|                      9|         9|        12|                        1|                         1|           2|            1|               1|                      0|                    0|                  0|        12|           2|             12|               0|

## S13 exposure and controls (ownership data only)

| exposed| exposed_pairs| exposed_parent_in_revelio| exposed_h3| frame_controls| controls_no_foreign_direct| owner_link_dropped| controls| controls_parent_in_revelio| control_dyads| third_country| gb_ie| uk_hosted_exposed| control_linked| stake_exactly_50| stake_below_50| exposed_no_ie| exposed_guo| exposed_formed_from2021| exposed_owner_level| controls_owner_level|
|-------:|-------------:|-------------------------:|----------:|--------------:|--------------------------:|------------------:|--------:|--------------------------:|-------------:|-------------:|-----:|-----------------:|--------------:|----------------:|--------------:|-------------:|-----------:|-----------------------:|-------------------:|--------------------:|
|       4|             3|                         4|          2|              4|                          2|                  1|        3|                          3|             3|             1|     1|                 3|              1|                1|              1|             3|           4|                       0|                   0|                    1|

## Panels (main period 2010 to 2025 unless stated)

|panel              |grain     | rows_all_years| ijvs_all_years| rows_main| ijvs_main| values_main| years_main| cells_emp5| ijvs_emp5| cells_hires5| ijvs_hires5| cells_emp3| cells_emp10| cells_emp5_obs1| cells_emp5_geo1| cells_emp5_local1| hires_main| hires_emp5|
|:------------------|:---------|--------------:|--------------:|---------:|---------:|-----------:|----------:|----------:|---------:|------------:|-----------:|----------:|-----------:|---------------:|---------------:|-----------------:|----------:|----------:|
|ijv-domain-year    |domain    |          1,334|             12|     1,177|        12|           8|         16|        185|        12|            0|           0|        494|           5|              71|              69|                53|        452|        135|
|ijv-domain-b-year  |domain    |          1,308|             12|     1,154|        12|           8|         16|        188|        12|            0|           0|        487|           5|              73|              70|                52|        452|        142|
|ijv-level-year     |level     |            772|             12|       664|        12|           4|         16|        318|        12|            1|           1|        448|          56|             143|             141|               104|        452|        308|
|ijv-level-b-year   |level     |            707|             12|       613|        12|           4|         16|        304|        12|            2|           2|        419|          89|             152|             151|               109|        452|        328|
|ijv-seniority-year |seniority |          1,138|             12|     1,000|        12|           7|         16|        229|        12|            0|           0|        528|           5|              84|              84|                59|        452|        159|
|ijv-function-year  |fn        |            998|             12|       869|        12|           5|         16|        247|        12|            0|           0|        479|          29|             107|             104|                77|        453|        228|
|ijv-role50-year    |role_k50  |            874|             12|       754|        12|           5|         16|        295|        12|            1|           1|        505|          17|             119|             117|                87|        453|        240|

## Estimation samples: structure only (main period, at least 5 employees unless stated)

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

## Hires of 2010 to 2025: pooled origin classes (primary window, three years)

|cat_w3       |   N|  share|
|:------------|---:|------:|
|local_parent |  31| 0.0684|
|intl_parent  |  20| 0.0442|
|parent_na    |   2| 0.0044|
|local_indep  | 157| 0.3466|
|intl_indep   |  81| 0.1788|
|indep_na     |  11| 0.0243|
|not_obs      | 151| 0.3333|

## Hires of 2010 to 2025: pooled rates

| hires| not_obs| entrant| unknown| obs_unmapped| lookup| no_domain| no_level| imputed|
|-----:|-------:|-------:|-------:|------------:|------:|---------:|--------:|-------:|
|   453|  0.3333|  0.1038|  0.2296|       0.2185| 0.0044|    0.0022|   0.0022|  0.0132|

## Coverage ratio (IJV-years 2015 to 2025)

| ijv_years_2015_2025| with_ratio| ijvs_with_ratio| median_ratio|
|-------------------:|----------:|---------------:|------------:|
|                 132|         60|               6|         0.32|
