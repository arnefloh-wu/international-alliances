# Recovery of planted effects: Monte Carlo check (2026-11-23)

Built 2026-11-23 15:50 by code/R/tests/check_estimate_recovery.R: 500 simulated draws of 600 IJVs (9 functions, 4 levels, 2010 to 2024), seeds 20261124 to 20261623. Simulated data only; nothing here is a result about IJVs.

`planted` is on the logit scale of the data-generating process (`code/R/functions/simulate_panel.R`). `reject_5pct` is the share of draws with p < 0.05: for a planted null it estimates the false-positive rate (nominal 0.05), for a planted effect the power. `se_ratio` is the standard deviation of the estimates across draws divided by the mean clustered standard error: above 1, the standard errors are too small.

Criteria: sign, power of at least 0.80; null, rejection rate of at most 0.079 (0.05 plus three binomial standard errors); null_linear, at most 0.15, a gross-error check for linear models of bounded or sparse shares, whose false-positive rates in this simulation lie above the nominal level; magnitude, mean estimate within 25 percent of the planted value.

Reading: the code recovers every planted effect and its size. Where a planted null is tested with a linear model on a share, the rejection rate is above 5 percent: partly functional form (the logistic curvature of one score loads onto a correlated score) and partly clustered standard errors that are 5 to 10 percent too small (`se_ratio`). The fractional logit, the Poisson model and the linear model with the score as categories hold the nominal level. See docs/decisions.md (Open, 2026-11-23).

|hypothesis             |model       |term                             |check       | planted| mean_estimate| sd_estimate| mean_se| se_ratio| reject_5pct| ci_covers_planted| rel_bias|result              |
|:----------------------|:-----------|:--------------------------------|:-----------|-------:|-------------:|-----------:|-------:|--------:|-----------:|-----------------:|--------:|:-------------------|
|H1                     |H1_pois     |coord_dependence                 |sign        |      NA|         0.296|       0.017|   0.017|    0.989|       1.000|                NA|       NA|pass                |
|H1 levels              |H1L_pois    |coord_role                       |magnitude   |    0.50|         0.474|       0.039|   0.036|    1.074|       1.000|             0.860|   -0.052|pass                |
|H2                     |H2_lin      |local_embeddedness               |sign        |      NA|         0.059|       0.002|   0.002|    1.100|       1.000|                NA|       NA|pass                |
|H2 (no cd effect)      |H2_lin_cat  |coord_dependence                 |null        |    0.00|         0.000|       0.002|   0.002|    1.006|       0.048|             0.952|       NA|pass                |
|H2 before exposure     |H2_frac_pre |local_embeddedness               |magnitude   |    0.25|         0.257|       0.007|   0.007|    1.024|       1.000|             0.816|    0.028|pass                |
|H3 without host parent |H3_lin      |coord_dependence                 |null_linear |    0.00|         0.000|       0.002|   0.002|    1.088|       0.088|             0.912|       NA|pass (over-rejects) |
|H3                     |H3_lin      |coord_dependence:host_parentTRUE |sign        |      NA|         0.014|       0.003|   0.003|    1.079|       0.996|                NA|       NA|pass                |
|H3 without host parent |H3_pois     |coord_dependence                 |null        |    0.00|         0.000|       0.030|   0.030|    1.002|       0.072|             0.928|       NA|pass                |
|H3                     |H3_pois     |coord_dependence:host_parentTRUE |magnitude   |    0.40|         0.379|       0.033|   0.033|    0.979|       1.000|             0.906|   -0.053|pass                |
|H3                     |H3_frac     |coord_dependence:host_parentTRUE |reported    |    0.40|         0.413|       0.080|   0.071|    1.122|       1.000|             0.900|    0.032|shown, not tested   |
|H4                     |H4_lin      |shock:local_embeddedness         |sign        |      NA|         0.048|       0.006|   0.006|    1.036|       1.000|                NA|       NA|pass                |
|H4 (no cd effect)      |H4_lin      |shock:coord_dependence           |null_linear |    0.00|        -0.002|       0.007|   0.006|    1.041|       0.086|             0.914|       NA|pass (over-rejects) |
|H4                     |H4_frac     |shock:local_embeddedness         |magnitude   |    0.30|         0.315|       0.031|   0.030|    1.017|       1.000|             0.902|    0.051|pass                |
|H4 (no cd effect)      |H4_frac     |shock:coord_dependence           |null        |    0.00|         0.001|       0.033|   0.032|    1.038|       0.070|             0.930|       NA|pass                |
|H4 channel             |H4C_lin     |shock:local_embeddedness         |null_linear |    0.00|         0.000|       0.005|   0.004|    1.096|       0.084|             0.916|       NA|pass (over-rejects) |
|H4 channel             |H4C_lin     |shock:coord_dependence           |null_linear |    0.00|         0.000|       0.005|   0.005|    1.003|       0.060|             0.940|       NA|pass (over-rejects) |
|history not observed   |NO_lin      |coord_dependence                 |null        |    0.00|         0.000|       0.001|   0.001|    0.994|       0.060|             0.940|       NA|pass                |
|history not observed   |NO_lin      |local_embeddedness               |null        |    0.00|         0.000|       0.001|   0.001|    1.014|       0.052|             0.948|       NA|pass                |

Run time 761 s; fixest 0.14.2.
