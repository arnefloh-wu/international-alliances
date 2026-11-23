# Data quality flags (synthetic 2026-11-23)

Built 2026-11-23 14:34 by code/R/wrds/13_quality_flags.R with the flag functions of code/R/functions/quality_flags.R.
Input: simulated tables in data/synthetic/ (no licensed data).
Flags are columns computed on read; no row was dropped and no file was changed. Nothing is broken down by shock exposure group.

## Keys and coverage

|check                                          |     n|
|:----------------------------------------------|-----:|
|parent rows without an IJV                     |     0|
|IJVs without a parent row                      |     0|
|IJVs without a spell                           |     0|
|host country missing                           |     0|
|host country code NA (Namibia) kept as a value |     8|
|parent country missing                         |     0|
|spell users without a career history on file   |     0|
|people with a career history on file           | 8,884|

## Flag counts

`n` is the number of flagged rows, `rows` the size of the table, `share` their ratio.

|table      |flag                      |     n|   rows|  share|
|:----------|:-------------------------|-----:|------:|------:|
|ijv        |flag_pre_formation_10y    |     1|    200| 0.0050|
|ijv        |flag_holding_vehicle      |     0|    200| 0.0000|
|ijv        |flag_short_panel          |     6|    200| 0.0300|
|ijv        |flag_no_spells            |     0|    200| 0.0000|
|ijv        |flag_size_mismatch        |     4|    200| 0.0200|
|ijv        |flag_jv_in_parent_family  |     3|    200| 0.0150|
|ijv        |flag_shared_family_entity |     5|    200| 0.0250|
|spells     |flag_dup_position         |    10|  8,906| 0.0011|
|spells     |flag_start_missing        |    15|  8,906| 0.0017|
|spells     |flag_end_before_start     |     7|  8,906| 0.0008|
|spells     |flag_open_ended           | 3,772|  8,906| 0.4235|
|spells     |flag_employer_unmapped    |     0|  8,906| 0.0000|
|spells     |flag_country_missing      |   150|  8,906| 0.0168|
|spells     |flag_stray_entity         |     0|  8,906| 0.0000|
|spells     |flag_pre_formation        |    40|  8,906| 0.0045|
|spells     |flag_multi_ijv_person     |    24|  8,906| 0.0027|
|histories  |flag_dup_position         |     6| 18,502| 0.0003|
|histories  |flag_start_missing        |    25| 18,502| 0.0014|
|histories  |flag_end_before_start     |     0| 18,502| 0.0000|
|histories  |flag_open_ended           | 4,003| 18,502| 0.2164|
|histories  |flag_employer_unmapped    | 1,536| 18,502| 0.0830|
|histories  |flag_country_missing      |   480| 18,502| 0.0259|
|headcounts |flag_multi_account_row    |    40|  1,049| 0.0381|
|headcounts |flag_consolidated         |    20|  1,049| 0.0191|
|headcounts |flag_not_12_months        |     0|  1,049| 0.0000|

`flag_open_ended`, `flag_multi_ijv_person` and `flag_jv_in_parent_family` mark cases to handle, not errors. `flag_dup_position` counts the copies after the first.
`flag_size_mismatch` is recomputed from `n_emp` and `jv_employees_orbis` in the IJV table; manual matches are exempt from that rule in the sample definition.

## IJV flags by region

|region               | rows| flag_pre_formation_10y| flag_holding_vehicle| flag_short_panel| flag_no_spells| flag_size_mismatch| flag_jv_in_parent_family| flag_shared_family_entity|
|:--------------------|----:|----------------------:|--------------------:|----------------:|--------------:|------------------:|------------------------:|-------------------------:|
|east_asia_pacific    |   60|                 0.0000|                    0|           0.0333|              0|             0.0000|                   0.0167|                    0.0333|
|latin_america        |   22|                 0.0000|                    0|           0.0000|              0|             0.0000|                   0.0000|                    0.0000|
|middle_east_africa   |    8|                 0.0000|                    0|           0.0000|              0|             0.0000|                   0.0000|                    0.0000|
|north_america        |   31|                 0.0000|                    0|           0.0323|              0|             0.0323|                   0.0000|                    0.0000|
|south_southeast_asia |   27|                 0.0000|                    0|           0.0000|              0|             0.0370|                   0.0000|                    0.0000|
|western_europe       |   52|                 0.0192|                    0|           0.0577|              0|             0.0385|                   0.0385|                    0.0577|

## IJV flags by source

|source | rows| flag_pre_formation_10y| flag_holding_vehicle| flag_short_panel| flag_no_spells| flag_size_mismatch| flag_jv_in_parent_family| flag_shared_family_entity|
|:------|----:|----------------------:|--------------------:|----------------:|--------------:|------------------:|------------------------:|-------------------------:|
|ciq    |   32|                  0.000|                    0|           0.0000|              0|             0.0000|                   0.0000|                    0.0000|
|orbis  |  168|                  0.006|                    0|           0.0357|              0|             0.0238|                   0.0179|                    0.0298|

## IJV flags by match tier

|match_tier | rows| flag_pre_formation_10y| flag_holding_vehicle| flag_short_panel| flag_no_spells| flag_size_mismatch| flag_jv_in_parent_family| flag_shared_family_entity|
|:----------|----:|----------------------:|--------------------:|----------------:|--------------:|------------------:|------------------------:|-------------------------:|
|auto       |  175|                 0.0057|                    0|           0.0343|              0|             0.0171|                   0.0171|                    0.0229|
|manual     |    4|                 0.0000|                    0|           0.0000|              0|             0.0000|                   0.0000|                    0.0000|
|strong     |   21|                 0.0000|                    0|           0.0000|              0|             0.0476|                   0.0000|                    0.0476|

## Spell flags by region

|region               |  rows| flag_dup_position| flag_start_missing| flag_end_before_start| flag_open_ended| flag_employer_unmapped| flag_country_missing| flag_pre_formation| flag_multi_ijv_person|
|:--------------------|-----:|-----------------:|------------------:|---------------------:|---------------:|----------------------:|--------------------:|------------------:|---------------------:|
|east_asia_pacific    | 2,404|            0.0012|             0.0017|                0.0012|          0.4276|                      0|               0.0200|             0.0000|                0.0029|
|latin_america        |   879|            0.0000|             0.0011|                0.0000|          0.4050|                      0|               0.0239|             0.0000|                0.0057|
|middle_east_africa   |   304|            0.0000|             0.0000|                0.0000|          0.4013|                      0|               0.0000|             0.0000|                0.0000|
|north_america        | 1,441|            0.0028|             0.0007|                0.0007|          0.4011|                      0|               0.0194|             0.0000|                0.0021|
|south_southeast_asia | 1,278|            0.0008|             0.0031|                0.0016|          0.4538|                      0|               0.0149|             0.0000|                0.0023|
|western_europe       | 2,600|            0.0008|             0.0019|                0.0004|          0.4262|                      0|               0.0131|             0.0154|                0.0023|

## Spell flags by source

|source |  rows| flag_dup_position| flag_start_missing| flag_end_before_start| flag_open_ended| flag_employer_unmapped| flag_country_missing| flag_pre_formation| flag_multi_ijv_person|
|:------|-----:|-----------------:|------------------:|---------------------:|---------------:|----------------------:|--------------------:|------------------:|---------------------:|
|ciq    | 1,313|            0.0015|             0.0015|                0.0008|          0.3572|                      0|               0.0213|             0.0000|                0.0023|
|orbis  | 7,593|            0.0011|             0.0017|                0.0008|          0.4350|                      0|               0.0161|             0.0053|                0.0028|

## Spell flags by start year

|start_band  |  rows| flag_dup_position| flag_start_missing| flag_end_before_start| flag_open_ended| flag_employer_unmapped| flag_country_missing| flag_pre_formation| flag_multi_ijv_person|
|:-----------|-----:|-----------------:|------------------:|---------------------:|---------------:|----------------------:|--------------------:|------------------:|---------------------:|
|before 2000 |   552|            0.0036|                  0|                0.0000|          0.3351|                      0|               0.0163|             0.0725|                0.0018|
|2000-2009   | 2,308|            0.0004|                  0|                0.0013|          0.2591|                      0|               0.0182|             0.0000|                0.0026|
|2010-2014   | 1,735|            0.0000|                  0|                0.0006|          0.2478|                      0|               0.0196|             0.0000|                0.0012|
|2015-2019   | 1,991|            0.0020|                  0|                0.0010|          0.3712|                      0|               0.0151|             0.0000|                0.0020|
|2020-2026   | 2,305|            0.0013|                  0|                0.0004|          0.7874|                      0|               0.0152|             0.0000|                0.0048|
|NA          |    15|            0.0000|                  1|                0.0000|          0.3333|                      0|               0.0000|             0.0000|                0.0000|

## Career-history flags by start year

|start_band  |  rows| flag_employer_unmapped| flag_country_missing|
|:-----------|-----:|----------------------:|--------------------:|
|before 2000 | 3,685|                 0.1406|               0.0407|
|2000-2009   | 5,864|                 0.0940|               0.0268|
|2010-2014   | 3,340|                 0.0763|               0.0281|
|2015-2019   | 3,009|                 0.0568|               0.0196|
|2020-2026   | 2,579|                 0.0159|               0.0078|
|NA          |    25|                 0.0000|               0.0000|

## Seeded failures

|failure                                                                          |table      |flag                      |unit                      | n_expected| n_flagged|caught |
|:--------------------------------------------------------------------------------|:----------|:-------------------------|:-------------------------|----------:|---------:|:------|
|an entity that belongs to two parents' families                                  |ijv        |flag_shared_family_entity |IJVs                      |          5|         5|TRUE   |
|a parent's own entity matched as the IJV (the JV entity sits in a parent family) |ijv        |flag_jv_in_parent_family  |IJVs                      |          3|         3|TRUE   |
|a position that starts before the formation year                                 |spells     |flag_pre_formation        |positions                 |         40|        40|TRUE   |
|a person at two sample IJVs                                                      |spells     |flag_multi_ijv_person     |positions (12 people)     |         24|        24|TRUE   |
|an IJV with fewer than three observed years                                      |ijv        |flag_short_panel          |IJVs                      |          6|         6|TRUE   |
|a Revelio headcount more than 20 times the Orbis headcount                       |ijv        |flag_size_mismatch        |IJVs                      |          4|         4|TRUE   |
|host country code NA (Namibia) kept as a value                                   |ijv        |jv_country == 'NA'        |IJVs                      |          8|         8|TRUE   |
|employer not mapped (rcid missing)                                               |histories  |flag_employer_unmapped    |positions                 |      1,536|     1,536|TRUE   |
|country missing                                                                  |histories  |flag_country_missing      |positions                 |        480|       480|TRUE   |
|missing start dates                                                              |histories  |flag_start_missing        |positions                 |         25|        25|TRUE   |
|repeated position_id                                                             |histories  |flag_dup_position         |positions                 |          6|         6|TRUE   |
|open-ended positions                                                             |histories  |flag_open_ended           |positions                 |      4,003|     4,003|TRUE   |
|missing start dates                                                              |spells     |flag_start_missing        |positions                 |         15|        15|TRUE   |
|end date before start date                                                       |spells     |flag_end_before_start     |positions                 |          7|         7|TRUE   |
|country missing                                                                  |spells     |flag_country_missing      |positions                 |        150|       150|TRUE   |
|repeated position_id                                                             |spells     |flag_dup_position         |positions                 |         10|        10|TRUE   |
|open-ended positions                                                             |spells     |flag_open_ended           |positions                 |      3,772|     3,772|TRUE   |
|two account rows for one entity and year                                         |headcounts |flag_multi_account_row    |records (20 entity-years) |         40|        40|TRUE   |

## Schema against the real tables

|table               | columns|result                       |
|:-------------------|-------:|:----------------------------|
|ijv-matched         |      38|names, order and types match |
|ijv-parents         |      13|names, order and types match |
|parent-groups       |       2|names, order and types match |
|ijv-employee-spells |      15|names, order and types match |
|revelio-histories   |      10|names, order and types match |
|orbis-jv-headcounts |       8|names, order and types match |

