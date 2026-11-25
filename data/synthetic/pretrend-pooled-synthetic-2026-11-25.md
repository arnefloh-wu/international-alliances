# H4a pooled-lead pre-trend test and H4a power, broad-list scenario: Monte Carlo (2026-11-25)

**Simulated data only. Nothing in this file is a result about IJVs.** No staffing data were read (real_data_lock: gate 6 is not approved). Inputs: the O*NET domain scores (public, outcome-free) as fixed regressors, and counts only: 24 exposed pairs and 231 exposed IJVs (`rescoring.md` 4.1); 16 exposed pairs and about 38 exposed IJVs with broad-list REG cells, 151 control pairs and 328 control IJVs with such cells (feasibility count of 2026-11-25, as summarized by the coordinator).

Built 2026-11-25 12:45 by `code/R/tests/check_pretrend_pooled.R` with `code/R/functions/simulate_domain_panel.R`; 200 draws per grid cell; 0 fits failed; run time 2261 s on 14 workers; fixest 0.14.2.

## Design

The generator of `check_recovery_domain.R` (domain random effects, domain x year and pair x domain x year noise, a uniform mobility shock absorbed by IJV x year effects), with 231 exposed IJVs in 24 pairs, 2,000 control IJVs in 400 control pairs (Zipf sizes; an assumption) and a REG cell in an IJV with probability 0.230, calibrated so that the counts of IJVs and pairs with REG cells come close to the feasibility count (columns `exposed_ijv_reg` to `control_pairs_reg`; the simulation has somewhat fewer pairs with REG cells, about 13 exposed and 128 control against 16 and 151, so it is slightly conservative). The simulated domain `REG` stands in for `REG_B`. `pretrend` is a linear differential trend of exposed REG cells in the log local share, per year, centered on 2014 and continuing after 2021 (a violation of parallel trends); `h4` is the planted H4a effect on the log local share of REG hiring after 2021.
Pre-trend rule (PI, 2026-11-25): event study with fixed effects IJV x domain, domain x year and IJV x year; one pooled lead for 2010 to 2012, reference 2013 to 2015, one term per year 2016 to 2025; the lead's two-sided p-value from the cluster score bootstrap by dyad with the null imposed (499 Rademacher replications); the rule fails if p < 0.10. `expected_lead` is the lead the trend implies (-3 x pretrend), `expected_h4_bias` the bias of the H4a estimate it implies (pretrend x 10.5, the distance between the mean post year 2023 and the mean baseline year 2012.5).

H4a: exposed x post x REG with the anticipation window as its own term, decisive one-sided cluster score bootstrap by dyad. `h4_reject_after_pass` is the rejection rate of H4a among draws that pass the pre-trend rule. Monte Carlo tolerance for a 0.10 rate at 200 draws: +/- 0.064.

| pretrend|  h4| draws| exposed_ijv_reg| exposed_pairs_reg_both| control_ijv_reg| control_pairs_reg| expected_lead| mean_lead| pretest_reject_10| expected_h4_bias| mean_h4| sd_h4| se_ratio_pair| h4_reject_1s_boot| h4_reject_after_pass|
|--------:|---:|-----:|---------------:|----------------------:|---------------:|-----------------:|-------------:|---------:|-----------------:|----------------:|-------:|-----:|-------------:|-----------------:|--------------------:|
|     0.00| 0.0|   200|          39.260|                 13.350|         338.445|           125.845|          0.00|    -0.011|             0.095|            0.000|  -0.013| 0.094|         1.130|             0.060|                0.066|
|     0.01| 0.0|   200|          39.355|                 13.440|         338.340|           126.500|         -0.03|    -0.023|             0.105|            0.105|   0.104| 0.089|         1.105|             0.300|                0.285|
|     0.02| 0.0|   200|          38.930|                 13.375|         339.225|           126.310|         -0.06|    -0.074|             0.135|            0.210|   0.198| 0.088|         1.115|             0.695|                0.694|
|     0.03| 0.0|   200|          39.210|                 13.375|         338.555|           126.175|         -0.09|    -0.092|             0.190|            0.315|   0.285| 0.084|         1.117|             0.935|                0.944|
|     0.00| 0.1|   200|          39.070|                 13.260|         338.485|           126.480|          0.00|     0.002|             0.100|            0.000|   0.092| 0.089|         1.133|             0.285|                0.267|
|     0.00| 0.2|   200|          39.520|                 13.370|         340.830|           126.830|          0.00|    -0.013|             0.080|            0.000|   0.182| 0.090|         1.161|             0.665|                0.647|
|     0.00| 0.3|   200|          39.010|                 13.325|         338.620|           125.835|          0.00|     0.010|             0.150|            0.000|   0.275| 0.094|         1.266|             0.930|                0.929|
|     0.00| 0.4|   200|          39.680|                 13.355|         338.820|           126.190|          0.00|    -0.004|             0.105|            0.000|   0.347| 0.090|         1.249|             0.990|                0.989|

Minimum detectable H4a effect (80 percent power, one-sided 5 percent; (z_0.95 + z_0.80) x SD of the null estimates): 0.234 on the log scale, a rise of 26 percent in the local share of REG hiring.

