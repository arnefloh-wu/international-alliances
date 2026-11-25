# Recovery check at the domain grain: Monte Carlo (2026-11-25)

**Simulated data only. Nothing in this file is a result about IJVs.** No staffing data were read (real_data_lock: gate 6 is not approved). The only project inputs are the O*NET domain scores of `data/processed/contingency-scores-domain-v1-2026-11-25.csv` (public source, no outcome) as fixed regressor values, and the S13 exposure counts of `literature/shock-scan/rescoring.md`, section 4.1 (counts only).

Built 2026-11-25 09:36 by `code/R/tests/check_recovery_domain.R` with `code/R/functions/simulate_domain_panel.R`; run time 1727 s on 14 workers; fixest 0.14.2.

## Design of the simulation

IJV x domain x year cells, 98 domains with their O*NET scores (`local_embeddedness`, `coord_dependence`; correlation 0.40 across domains), hiring flows 2010 to 2025, cell rule `n_emp >= 5`. Each IJV is active in about 10 domains drawn with synthetic prevalence weights; the REG domain is present in an IJV with probability `pi_reg`. Outcomes are drawn log-linear in the category shares, so the planted value is the estimand of the primary estimator (Poisson with the log of the denominator as offset); 0.15% of cells hit the cap of the local share at 0.98.
The noise that matters for inference is common across IJVs: a domain random effect (SD 0.10 on the log local share, 0.25 on the log parent-origin shares), domain x year noise (SD 0.04) and pair x domain x year noise (SD 0.08). IJV x domain effects (SD 0.10 and 0.30) and cell-year noise (SD 0.05) add within-IJV dependence. These SDs are assumptions: they cannot be calibrated without outcome data, and the power of the static tests depends on them almost entirely.

Static checks: 500 draws per world of 1000 IJVs (null world: every planted effect zero; effect world: H1 0.15 on both parent-origin categories, H2 0.05, H3 0.15 with a host-country parent and 0 without; planted null on `coord_dependence` in the H2 model in both worlds). Average cells per draw: H1 32,446, H2 74,181, H3 9,870. `target` is the planted value in the null world and the pseudo-true value in the effect world (the same model fitted to one draw of 10,000 IJVs with the common random effects set to zero); for H1 the target is below the planted 0.15 because IJVs without a host-country parent carry no slope on local parent-origin hires.

`reject_1s` is the share of draws with a one-sided p < 0.05 for a positive coefficient (the decision rule of the plan), `reject_2s` the two-sided share. For a planted null it estimates the size (nominal 0.05; Monte Carlo tolerance 0.079 at 500 draws), for a planted effect the power. `se_ratio` is the SD of the estimates across draws divided by the mean standard error: above 1, the standard errors are too small.

## 1. Static models: Poisson with offset; two-way (IJV, domain) against IJV-only clustering

|world  |model |term                      |role                        |vcov   | planted| target| mean_est| sd_est| mean_se| se_ratio| reject_1s| reject_2s| ci_covers_target| rel_bias|
|:------|:-----|:-------------------------|:---------------------------|:------|-------:|------:|--------:|------:|-------:|--------:|---------:|---------:|----------------:|--------:|
|effect |H1    |coord_dependence          |H1 test                     |ijv    |    0.15|  0.129|    0.143|  0.050|   0.022|    2.312|     0.984|     0.982|            0.572|    0.104|
|effect |H1    |coord_dependence          |H1 test                     |twoway |    0.15|  0.129|    0.143|  0.050|   0.037|    1.347|     0.948|     0.896|            0.864|    0.104|
|effect |H2    |coord_dependence          |planted null in both worlds |ijv    |    0.00| -0.001|   -0.001|  0.022|   0.005|    4.190|     0.334|     0.646|            0.360|   -0.109|
|effect |H2    |coord_dependence          |planted null in both worlds |twoway |    0.00| -0.001|   -0.001|  0.022|   0.015|    1.417|     0.136|     0.166|            0.820|   -0.109|
|effect |H2    |local_embeddedness        |H2 test                     |ijv    |    0.05|  0.050|    0.050|  0.021|   0.005|    4.283|     0.968|     0.970|            0.354|   -0.012|
|effect |H2    |local_embeddedness        |H2 test                     |twoway |    0.05|  0.050|    0.050|  0.021|   0.015|    1.432|     0.864|     0.824|            0.840|   -0.012|
|effect |H3    |boundary (host - no host) |H3 boundary                 |ijv    |    0.15|  0.139|    0.146|  0.111|   0.104|    1.064|     0.432|     0.330|            0.936|    0.051|
|effect |H3    |boundary (host - no host) |H3 boundary                 |twoway |    0.15|  0.139|    0.146|  0.111|   0.102|    1.089|     0.436|     0.330|            0.930|    0.051|
|effect |H3    |cd_host                   |H3 test                     |ijv    |    0.15|  0.129|    0.154|  0.069|   0.043|    1.610|     0.892|     0.852|            0.752|    0.200|
|effect |H3    |cd_host                   |H3 test                     |twoway |    0.15|  0.129|    0.154|  0.069|   0.055|    1.265|     0.840|     0.754|            0.844|    0.200|
|effect |H3    |cd_nohost                 |planted null in both worlds |ijv    |    0.00| -0.011|    0.008|  0.114|   0.097|    1.169|     0.100|     0.098|            0.892|   -1.751|
|effect |H3    |cd_nohost                 |planted null in both worlds |twoway |    0.00| -0.011|    0.008|  0.114|   0.102|    1.119|     0.100|     0.088|            0.910|   -1.751|
|null   |H1    |coord_dependence          |H1 test                     |ijv    |    0.00|  0.000|    0.000|  0.048|   0.022|    2.172|     0.222|     0.368|            0.632|       NA|
|null   |H1    |coord_dependence          |H1 test                     |twoway |    0.00|  0.000|    0.000|  0.048|   0.037|    1.291|     0.096|     0.128|            0.872|       NA|
|null   |H2    |coord_dependence          |planted null in both worlds |ijv    |    0.00|  0.000|    0.000|  0.020|   0.005|    3.872|     0.346|     0.614|            0.386|       NA|
|null   |H2    |coord_dependence          |planted null in both worlds |twoway |    0.00|  0.000|    0.000|  0.020|   0.016|    1.290|     0.098|     0.136|            0.864|       NA|
|null   |H2    |local_embeddedness        |H2 test                     |ijv    |    0.00|  0.000|    0.000|  0.020|   0.005|    4.097|     0.332|     0.628|            0.372|       NA|
|null   |H2    |local_embeddedness        |H2 test                     |twoway |    0.00|  0.000|    0.000|  0.020|   0.015|    1.377|     0.114|     0.156|            0.844|       NA|
|null   |H3    |boundary (host - no host) |H3 boundary                 |ijv    |    0.00|  0.000|    0.000|  0.109|   0.104|    1.048|     0.064|     0.076|            0.924|       NA|
|null   |H3    |boundary (host - no host) |H3 boundary                 |twoway |    0.00|  0.000|    0.000|  0.109|   0.102|    1.066|     0.068|     0.078|            0.922|       NA|
|null   |H3    |cd_host                   |H3 test                     |ijv    |    0.00|  0.000|   -0.002|  0.067|   0.044|    1.533|     0.130|     0.208|            0.792|       NA|
|null   |H3    |cd_host                   |H3 test                     |twoway |    0.00|  0.000|   -0.002|  0.067|   0.056|    1.202|     0.078|     0.122|            0.878|       NA|
|null   |H3    |cd_nohost                 |planted null in both worlds |ijv    |    0.00|  0.000|   -0.002|  0.117|   0.097|    1.205|     0.088|     0.132|            0.868|       NA|
|null   |H3    |cd_nohost                 |planted null in both worlds |twoway |    0.00|  0.000|   -0.002|  0.117|   0.102|    1.151|     0.076|     0.118|            0.882|       NA|

## 2. Permutation test over domains

150 draws per world of 600 IJVs, 99 permutations of the domain score rows each (smallest attainable p = 0.010). `reject_1s_perm`: one-sided permutation p <= 0.05; `reject_1s_twoway`: one-sided two-way clustered p < 0.05 on the same draws; `agree`: share of draws in which the two tests reach the same decision.

|world  |model |term               | draws| reject_1s_perm| reject_2s_perm| reject_1s_twoway| agree|
|:------|:-----|:------------------|-----:|--------------:|--------------:|----------------:|-----:|
|effect |H1    |coord_dependence   |   150|          0.820|          0.747|            0.900| 0.920|
|effect |H2    |local_embeddedness |   150|          0.773|          0.660|            0.873| 0.900|
|null   |H1    |coord_dependence   |   150|          0.073|          0.073|            0.120| 0.953|
|null   |H2    |local_embeddedness |   150|          0.027|          0.040|            0.120| 0.893|

## 2b. Cluster score bootstrap by domain, and a diagnostic with equal domain sizes

Section 1 shows two-way clustered standard errors that are too small. 500 draws per row: `unequal` uses the domain prevalence of sections 1 and 2 (log-normal weights, SD 1); `equal` gives every non-REG domain the same prevalence (null world only), to check whether unequal cluster sizes cause the shortfall. `boot_domain` is the cluster score bootstrap by domain with the null imposed (`score_boot()`, 499 Rademacher replications), one-way by domain.

|domain_sizes |world  |model |term               | draws| se_ratio_twoway| reject_1s_twoway| reject_2s_twoway| reject_1s_boot_domain| reject_2s_boot_domain|
|:------------|:------|:-----|:------------------|-----:|---------------:|----------------:|----------------:|---------------------:|---------------------:|
|equal        |null   |H1    |coord_dependence   |   500|           1.233|            0.096|            0.124|                 0.098|                 0.132|
|equal        |null   |H2    |coord_dependence   |   500|           1.250|            0.076|            0.132|                 0.078|                 0.122|
|equal        |null   |H2    |local_embeddedness |   500|           1.343|            0.124|            0.150|                 0.114|                 0.134|
|equal        |null   |H3    |cd_host            |   500|           1.128|            0.068|            0.080|                 0.084|                 0.102|
|unequal      |effect |H1    |coord_dependence   |   500|           1.318|            0.960|            0.928|                 0.974|                 0.930|
|unequal      |effect |H2    |coord_dependence   |   500|           1.409|            0.124|            0.172|                 0.110|                 0.152|
|unequal      |effect |H2    |local_embeddedness |   500|           1.398|            0.878|            0.836|                 0.872|                 0.820|
|unequal      |effect |H3    |cd_host            |   500|           1.256|            0.814|            0.744|                 0.822|                 0.766|
|unequal      |null   |H1    |coord_dependence   |   500|           1.351|            0.114|            0.154|                 0.108|                 0.138|
|unequal      |null   |H2    |coord_dependence   |   500|           1.408|            0.120|            0.154|                 0.104|                 0.138|
|unequal      |null   |H2    |local_embeddedness |   500|           1.393|            0.134|            0.174|                 0.108|                 0.144|
|unequal      |null   |H3    |cd_host            |   500|           1.221|            0.090|            0.126|                 0.088|                 0.116|

## 3. H4 for S13: exposed x post x REG

Exposure on parent-host pairs: 24 exposed pairs and 231 exposed IJVs (the counts after the employee rule for IJVs with a parent in Revelio, `rescoring.md` 4.1), with the relative sizes of the twelve largest pairs (GB-DE to GB-BE) and twelve small pairs; 1,200 control IJVs in 100 control pairs (the number of control pairs is an assumption). Onset 2021, anticipation window 2016 to 2020 entered as its own term, fixed effects IJV x domain, domain x year and IJV x year. A uniform mobility shock (0.10 on the log local share in every domain of exposed IJVs after 2021) is planted and absorbed by the IJV x year effects. `pi_reg` is the probability that an IJV has a REG cell with five or more employees: low 0.10, high 0.30; the real share is unknown because counting REG cells needs the staffing data. 150 draws per cell of the grid; 0 fits failed.
`reject_1s_boot_pair` is the one-sided cluster score bootstrap by pair with the null imposed (Rademacher weights, 499 replications), the decisive test of the plan; `reject_1s_t_pair` and `reject_1s_t_ijv` use the clustered t statistic. `pretest_reject_10` is the rejection rate of the joint Wald test of the 2010 to 2012 leads (pair-clustered; reference 2013 to 2015) at 0.10, the threshold of the plan's pre-trend rule; no pre-trend is planted, so it is the size of the pre-test. `mde_80` is the effect a one-sided 5 percent test detects with 80 percent power, (z_0.95 + z_0.80) times the SD of the null-world estimates, on the log scale of the local share of REG hires.

|scenario            |  h4| draws| exposed_ijv_reg| exposed_pairs_reg_post| reg_cells_exposed_pre| reg_cells_exposed_post| mean_est| sd_est| se_ratio_pair| se_ratio_ijv| ci_covers_planted| reject_1s_boot_pair| reject_1s_t_pair| reject_1s_t_ijv| reject_2s_boot_pair| pretest_reject_10| pretest_reject_05|
|:-------------------|---:|-----:|---------------:|----------------------:|---------------------:|----------------------:|--------:|------:|-------------:|------------:|-----------------:|-------------------:|----------------:|---------------:|-------------------:|-----------------:|-----------------:|
|high                | 0.0|   150|          51.873|                 15.460|               185.420|                170.473|    0.000|  0.083|         1.120|        1.083|             0.893|               0.067|            0.080|           0.067|               0.093|             0.213|             0.167|
|high                | 0.1|   150|          51.027|                 15.260|               182.773|                168.373|    0.101|  0.079|         1.113|        1.083|             0.907|               0.333|            0.433|           0.400|               0.247|             0.213|             0.153|
|high                | 0.2|   150|          51.353|                 15.160|               182.820|                168.327|    0.186|  0.081|         1.145|        1.110|             0.887|               0.747|            0.767|           0.800|               0.640|             0.260|             0.180|
|high                | 0.3|   150|          50.160|                 15.093|               180.747|                164.407|    0.270|  0.072|         1.064|        1.029|             0.900|               0.967|            0.987|           0.973|               0.933|             0.220|             0.140|
|high_parent_carried | 0.3|   150|          50.980|                 15.080|               182.700|                167.360|    0.264|  0.080|         1.198|        1.169|             0.840|               0.967|            0.980|           0.973|               0.920|             0.193|             0.153|
|low                 | 0.0|   150|          17.173|                  9.240|                62.213|                 57.113|   -0.004|  0.142|         1.112|        1.064|             0.880|               0.047|            0.067|           0.060|               0.067|             0.287|             0.227|
|low                 | 0.1|   150|          17.187|                  9.400|                61.053|                 55.773|    0.087|  0.128|         1.048|        1.020|             0.900|               0.153|            0.207|           0.173|               0.080|             0.273|             0.160|
|low                 | 0.2|   150|          16.920|                  9.093|                60.013|                 55.987|    0.187|  0.125|         1.073|        1.010|             0.920|               0.373|            0.493|           0.487|               0.193|             0.340|             0.240|
|low                 | 0.3|   150|          17.100|                  9.413|                60.553|                 55.547|    0.254|  0.130|         1.148|        1.084|             0.880|               0.580|            0.707|           0.720|               0.453|             0.227|             0.173|

|scenario | mde_80|
|:--------|------:|
|high     |  0.207|
|low      |  0.352|

## 3b. H4b for S13 (directional channel test; PI decision of 2026-11-25)

IJVs with a host-country parent; run in the high-REG scenarios only (run time). The composition model uses domain x year and IJV x year effects with exposed x REG as a regressor, because with IJV x domain effects it separates (local parent-origin hires in REG cells are rare). `indep`: `n_local_indep` with offset log(`n_obs`), shock x REG, one-sided cluster score bootstrap by pair (H4b decisive test). `parent_share`: `n_local_parent` with offset log(`n_local`), shock x REG, two-sided score bootstrap; a significantly positive coefficient means parent-origin hires carry the rise (composition check). `h4b_support`: decisive test rejects and the composition check does not. In `high_parent_carried` the planted REG rise in the local share (0.30) comes with a parent-origin share among local REG hires multiplied by e (planted 1.0 on the log scale), so H4b is false; `composition_violation_detected` is then the power of the composition check.

|scenario            |  h4| draws| mean_est_indep| reject_1s_boot_indep| mean_est_parent_share| parent_share_estimable| composition_violation_detected| h4b_support|
|:-------------------|---:|-----:|--------------:|--------------------:|---------------------:|----------------------:|------------------------------:|-----------:|
|high                | 0.0|   150|          0.002|                0.073|                -0.191|                      1|                          0.040|       0.073|
|high                | 0.1|   150|          0.098|                0.300|                 1.671|                      1|                          0.060|       0.280|
|high                | 0.2|   150|          0.186|                0.687|                 0.210|                      1|                          0.040|       0.667|
|high                | 0.3|   150|          0.269|                0.940|                 1.013|                      1|                          0.060|       0.887|
|high_parent_carried | 0.3|   150|          0.237|                0.867|                 1.723|                      1|                          0.227|       0.673|

