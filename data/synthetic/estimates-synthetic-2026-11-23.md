# Estimates on simulated panels (2026-11-23)

Built 2026-11-23 15:49 by code/R/04_estimate.R synthetic with the model functions of code/R/functions/estimation.R.

**Simulated data.** The panels come from code/R/tests/synthetic_panel.R with planted effects of known size. Nothing here is a result about IJVs; the run checks that the code recovers what was planted. The hypotheses are the drafts of docs/research-brief.md, and the functions, levels and contingency scores are placeholders: their source is open since the PI set the qualitative study aside (2026-11-23), and the mapping is a gate-5 decision.

## Panel

|item                                                                               |value   |
|:----------------------------------------------------------------------------------|:-------|
|IJVs                                                                               |600     |
|IJVs with a host-country parent                                                    |482     |
|IJVs with a parent in Revelio                                                      |471     |
|parent-country pairs                                                               |40      |
|exposed pairs                                                                      |12      |
|exposed IJVs                                                                       |192     |
|function cells                                                                     |81,000  |
|hires                                                                              |384,987 |
|history observed (share of hires)                                                  |0.638   |
|local (share of observed)                                                          |0.703   |
|parent-origin (share of observed, IJVs with a parent in Revelio)                   |0.0322  |
|cells with a local parent-origin hire (share of cells with local hires, same IJVs) |0.093   |

## Variance check

Share of the outcome variance that lies within the IJV-year, the only variation the static models use.

|outcome            |sample                            | within_ijv_year|
|:------------------|:---------------------------------|---------------:|
|share_parent       |n_obs >= min, parent in Revelio   |           0.662|
|share_local        |n_obs >= min                      |           0.576|
|share_parent_local |n_local >= min, parent in Revelio |           0.586|
|share_not_obs      |n_hires >= min                    |           0.489|

## Static models

|term                             |H1_lin                  |H1_pois               |H1L_lin              |H1L_pois             |H2_lin                 |H2_lin_cat            |H2_frac                |H2_frac_pre           |H3_lin                 |H3_frac                |H3_pois                |NO_lin                |
|:--------------------------------|:-----------------------|:---------------------|:--------------------|:--------------------|:----------------------|:---------------------|:----------------------|:---------------------|:----------------------|:----------------------|:----------------------|:---------------------|
|coord_dependence                 |0.008 [0.006, 0.009]    |0.284 [0.251, 0.318]  |                     |                     |-0.001 [-0.004, 0.001] |0.001 [-0.002, 0.004] |-0.002 [-0.015, 0.011] |0.002 [-0.013, 0.016] |-0.001 [-0.005, 0.003] |-0.028 [-0.138, 0.082] |-0.020 [-0.068, 0.029] |0.001 [-0.001, 0.003] |
|coord_dependence:host_parentTRUE |                        |                      |                     |                     |                       |                      |                       |                      |0.015 [0.010, 0.020]   |0.444 [0.313, 0.574]   |0.405 [0.348, 0.462]   |                      |
|coord_role                       |                        |                      |0.019 [0.014, 0.024] |0.459 [0.388, 0.530] |                       |                      |                       |                      |                       |                       |                       |                      |
|local_embeddedness               |-0.001 [-0.002, -0.000] |0.007 [-0.017, 0.030] |                     |                     |0.060 [0.057, 0.064]   |                      |0.321 [0.302, 0.341]   |0.260 [0.245, 0.274]  |                       |                       |                       |0.001 [-0.000, 0.003] |
|local_embeddedness::2            |                        |                      |                     |                     |                       |0.079 [0.065, 0.094]  |                       |                      |                       |                       |                       |                      |
|local_embeddedness::3            |                        |                      |                     |                     |                       |0.142 [0.128, 0.157]  |                       |                      |                       |                       |                       |                      |
|local_embeddedness::4            |                        |                      |                     |                     |                       |0.202 [0.185, 0.219]  |                       |                      |                       |                       |                       |                      |
|local_embeddedness::5            |                        |                      |                     |                     |                       |0.252 [0.234, 0.270]  |                       |                      |                       |                       |                       |                      |
|cells used                       |12,735                  |28,869                |4,785                |8,939                |16,563                 |16,563                |16,440                 |12,784                |6,090                  |3,655                  |23,527                 |33,721                |
|within R2                        |0.025                   |                      |0.022                |                     |0.206                  |0.207                 |                       |                      |0.033                  |                       |                       |0.000                 |

Fixed effects IJV x year; standard errors clustered by IJV; 95% confidence intervals in brackets; cells with at least 5 hires in the denominator; linear models weighted by the denominator. SIMULATED DATA.

## Cells used by each model

The fractional and Poisson models drop IJV-years in which the outcome is zero in every cell.

|model       |family        | cells_given| cells_used| ijv_years_or_groups_dropped|
|:-----------|:-------------|-----------:|----------:|---------------------------:|
|H1_lin      |linear        |      13,996|     12,735|                       1,261|
|H1_pois     |poisson       |      55,360|     28,869|                      26,491|
|H1L_lin     |linear        |       6,143|      4,785|                       1,358|
|H1L_pois    |poisson       |      24,571|      8,939|                      15,632|
|H2_lin      |linear        |      18,122|     16,563|                       1,559|
|H2_lin_cat  |linear        |      18,122|     16,563|                       1,559|
|H2_frac     |quasibinomial |      18,122|     16,440|                       1,682|
|H2_frac_pre |quasibinomial |      14,153|     12,784|                       1,369|
|H3_lin      |linear        |       7,228|      6,090|                       1,138|
|H3_frac     |quasibinomial |       7,228|      3,655|                       3,573|
|H3_pois     |poisson       |      49,478|     23,527|                      25,951|
|NO_lin      |linear        |      34,860|     33,721|                       1,139|
|H4_lin      |linear        |      18,122|     15,518|                       2,604|
|H4_frac     |quasibinomial |      18,122|     15,313|                       2,809|
|H4C_lin     |linear        |       7,228|      5,376|                       1,852|

## Dynamic models

|term                     |H4_lin                 |H4_frac                |H4C_lin                |
|:------------------------|:----------------------|:----------------------|:----------------------|
|shock:coord_dependence   |-0.002 [-0.013, 0.009] |-0.001 [-0.058, 0.056] |-0.002 [-0.017, 0.012] |
|shock:local_embeddedness |0.050 [0.038, 0.061]   |0.331 [0.270, 0.393]   |-0.000 [-0.011, 0.010] |
|cells used               |15,518                 |15,313                 |5,376                  |
|within R2                |0.009                  |                       |0.000                  |

Fixed effects IJV x function, function x year and IJV x year (the last absorbs the shock main effect); standard errors clustered by IJV; 95% confidence intervals in brackets. SIMULATED DATA.

## Event study: leads

Joint test that the leads (-5 to -2) are zero: F = 0.85, p = 0.495. Not rejecting is not proof of parallel trends; the lead estimates and their intervals show how large a pre-trend the data cannot rule out.

|term                      | estimate|  ci_low| ci_high|      p|
|:-------------------------|--------:|-------:|-------:|------:|
|et::-5:local_embeddedness |   0.0011| -0.0205|  0.0228| 0.9187|
|et::-4:local_embeddedness |   0.0091| -0.0192|  0.0373| 0.5290|
|et::-3:local_embeddedness |  -0.0028| -0.0271|  0.0215| 0.8189|
|et::-2:local_embeddedness |  -0.0143| -0.0381|  0.0095| 0.2376|

Figure: data/synthetic/fig-event-study-synthetic-2026-11-23.png

## Staggered exposure (Sun and Abraham), within groups of functions

|model      |functions               |     att|     se|      p|
|:----------|:-----------------------|-------:|------:|------:|
|H4_sa_high |local_embeddedness >= 4 |  0.1002| 0.0156| 0.0000|
|H4_sa_low  |local_embeddedness <= 2 | -0.0505| 0.0205| 0.0144|

## Inference checks

Permutation of the scores across functions (levels). `p_min` is the smallest p-value the test can return. Four levels give only 24 assignments, and with a binary score (two levels with a coordination role, two without) eight of them reproduce the observed split or its mirror image, so the level test cannot fall below 1/3.

|model   |term                             | estimate| permutations|exact | p_perm|  p_min|
|:-------|:--------------------------------|--------:|------------:|:-----|------:|------:|
|H2_lin  |local_embeddedness               |   0.0603|          999|FALSE | 0.0020| 0.0010|
|H3_lin  |coord_dependence:host_parentTRUE |   0.0149|          999|FALSE | 0.0010| 0.0010|
|H1L_lin |coord_role                       |   0.0187|           24|TRUE  | 0.3333| 0.3333|

|model  |term                             |clustering                                 |     se|
|:------|:--------------------------------|:------------------------------------------|------:|
|H2_lin |local_embeddedness               |IJV                                        | 0.0019|
|H2_lin |local_embeddedness               |IJV and function (9 clusters)              | 0.0022|
|H3_lin |coord_dependence:host_parentTRUE |IJV                                        | 0.0024|
|H3_lin |coord_dependence:host_parentTRUE |IJV and function (9 clusters)              | 0.0014|
|H4_lin |shock:local_embeddedness         |IJV                                        | 0.0058|
|H4_lin |shock:local_embeddedness         |parent-country pair (40 pairs, 12 exposed) | 0.0061|

## Effect sizes

Linear models: percentage points of the share per one-point difference in the score, against the mean share.

|model  |term                             | mean_pct| pp_per_point|pp_ci        |  p|
|:------|:--------------------------------|--------:|------------:|:------------|--:|
|H1_lin |coord_dependence                 |    3.190|        0.788|[0.65, 0.93] |  0|
|H2_lin |local_embeddedness               |   70.560|        6.031|[5.67, 6.40] |  0|
|H3_lin |coord_dependence:host_parentTRUE |    3.615|        1.491|[1.01, 1.97] |  0|
|H4_lin |shock:local_embeddedness         |   70.560|        4.989|[3.84, 6.14] |  0|

Average marginal effects of the fractional logit (percentage points per point):

|model   |term                        | ame_pp|
|:-------|:---------------------------|------:|
|H2_frac |local_embeddedness          |  5.661|
|H3_frac |coord_dependence (all rows) |  1.954|

The static H2 slope pools years before and after exposure. Where the shock steepens the slope (H4), the pooled estimate lies above the pre-exposure slope: compare `H2_frac` with `H2_frac_pre` in the static table.

## Recovery of the planted effects

`planted` is on the logit scale of the data-generating process. Linear models are checked for sign and significance only. Poisson coefficients approximate the logit value because parent-origin hires are rare. One draw: each planted null is rejected by chance with probability 0.05, so a single false positive here is expected now and then; `code/R/tests/check_estimate_recovery.R` repeats the draw and tests the rejection rates.

|hypothesis             |model       |term                             |check       | planted| estimate| ci_low| ci_high|     p|result                  |
|:----------------------|:-----------|:--------------------------------|:-----------|-------:|--------:|------:|-------:|-----:|:-----------------------|
|H1                     |H1_pois     |coord_dependence                 |sign        |      NA|    0.284|  0.251|   0.318| 0.000|recovered               |
|H1 levels              |H1L_pois    |coord_role                       |magnitude   |    0.50|    0.459|  0.388|   0.530| 0.000|planted value in 95% CI |
|H2                     |H2_lin      |local_embeddedness               |sign        |      NA|    0.060|  0.057|   0.064| 0.000|recovered               |
|H2 (no cd effect)      |H2_lin_cat  |coord_dependence                 |null        |    0.00|    0.001| -0.002|   0.004| 0.522|null held               |
|H2 before exposure     |H2_frac_pre |local_embeddedness               |magnitude   |    0.25|    0.260|  0.245|   0.274| 0.000|planted value in 95% CI |
|H3 without host parent |H3_lin      |coord_dependence                 |null_linear |    0.00|   -0.001| -0.005|   0.003| 0.610|null held               |
|H3                     |H3_lin      |coord_dependence:host_parentTRUE |sign        |      NA|    0.015|  0.010|   0.020| 0.000|recovered               |
|H3 without host parent |H3_pois     |coord_dependence                 |null        |    0.00|   -0.020| -0.068|   0.029| 0.428|null held               |
|H3                     |H3_pois     |coord_dependence:host_parentTRUE |magnitude   |    0.40|    0.405|  0.348|   0.462| 0.000|planted value in 95% CI |
|H3                     |H3_frac     |coord_dependence:host_parentTRUE |reported    |    0.40|    0.444|  0.313|   0.574| 0.000|shown, not tested       |
|H4                     |H4_lin      |shock:local_embeddedness         |sign        |      NA|    0.050|  0.038|   0.061| 0.000|recovered               |
|H4 (no cd effect)      |H4_lin      |shock:coord_dependence           |null_linear |    0.00|   -0.002| -0.013|   0.009| 0.769|null held               |
|H4                     |H4_frac     |shock:local_embeddedness         |magnitude   |    0.30|    0.331|  0.270|   0.393| 0.000|planted value in 95% CI |
|H4 (no cd effect)      |H4_frac     |shock:coord_dependence           |null        |    0.00|   -0.001| -0.058|   0.056| 0.963|null held               |
|H4 channel             |H4C_lin     |shock:local_embeddedness         |null_linear |    0.00|    0.000| -0.011|   0.010| 0.930|null held               |
|H4 channel             |H4C_lin     |shock:coord_dependence           |null_linear |    0.00|   -0.002| -0.017|   0.012| 0.748|null held               |
|history not observed   |NO_lin      |coord_dependence                 |null        |    0.00|    0.001| -0.001|   0.003| 0.341|null held               |
|history not observed   |NO_lin      |local_embeddedness               |null        |    0.00|    0.001|  0.000|   0.003| 0.064|null held               |

## Session

R 4.6.1; fixest 0.14.2; modelsummary 2.6.0; run time 24 s.
