---
name: statistical-analyst
description: >
  Use this skill to specify, script, run and debug the statistical models of
  the IJV staffing study. Triggers: "run my analysis", "write the analysis
  script", "specify the model", "draft the estimation part of the
  pre-analysis plan", "debug this error", "fit a fixed-effects / fractional
  / Poisson / event-study / difference-in-differences model", or any request
  to move from the panel to statistical results. Before gate 6 it works on
  simulated panels only. The stage run itself is `/estimate`.
---

# Statistical Analysis: Model Specification, Scripting & Debugging

Customized on 2026-11-23 from the seminar template `3A-statistical-analyst.md`
for the IJV staffing study (Floh, Mohr, Thanyi; target JIBS).

## What This Skill Does

Takes the hypotheses and the panel and produces: a model specification for
each hypothesis, with the variation that identifies it; an analysis script
that runs from top to bottom; debugged output; and a record of every check
and every departure from the plan. It is the method guide of the
`quant-analyst` agent for two stage tasks that already exist: the estimation
part of the pre-analysis plan (stage 5, `/research-workflow hypotheses`) and
the estimation itself (stage 7, `/estimate`).

The template covers OLS, logistic, choice, mediation, moderation, SEM, HLM
and Bayesian models for survey and experimental data. This study has one
design: a panel of IJV by function (or level) by year cells, share and
count outcomes that are zero in most cells, contingency scores that vary
across functions, and a shock that varies across IJVs and years. The
mediation, SEM, choice and Bayesian branches are removed. Fixed-effects
panel models, fractional and count models, and event-study and
difference-in-differences estimators take their place.

Place in the workflow (`docs/workflow.md`): not a numbered stage and no
gate. It does not approve a gate, does not choose the shock, and does not
add a hypothesis.

---

## Customize This Skill (completed)

The **core** block is identical in all ten skills and was copied unchanged
from `.claude/skills/research-ideation/SKILL.md`. The **skill-specific**
block and the **extensions** apply only here.

```yaml
# ---------- CORE — identical in all ten skills ----------
field:                 international business
subfield:              international joint ventures: staffing, control and organizational design
target_venue:          Journal of International Business Studies
citation_style:        APA 7 in text; JIBS reference list (manuscript/csl/journal-of-international-business-studies.csl)
software:              R
replication_standard:  code-only package: scripts in code/R/ reproduce every table and figure from the licensed exports; Orbis, Revelio and BoardEx data are not shareable; pre-analysis plan fixed at gate 5

# ---------- SKILL-SPECIFIC — statistical-analyst ----------
model_family:          linear models with high-dimensional fixed effects (fixest::feols) as the baseline; fractional logit (feglm, quasibinomial) and Poisson (fepois) for share and count outcomes; event study and staggered difference-in-differences (fixest::i and sunab, did, didimputation) for the dynamic hypothesis. No mediation, SEM, choice or Bayesian model
inference:             frequentist; cluster-robust standard errors, 95 percent confidence intervals, and a permutation test over functions for function-level regressors
preregistered:         true (pre-analysis plan in reviews/gate-5-pre-analysis-plan.md, binding once gate 5 is approved; a public registration is not decided)
multilevel:            true (cells within IJVs, IJVs within parent-country pairs), handled by fixed effects and clustering, not by random-effects models
effect_size:           true (percentage points of the share per one-point difference in the contingency score, set against the outcome mean; average marginal effects for the nonlinear models; no standardized d, f-squared or eta-squared)

# ---------- EXTENSIONS (three-edit pattern, see the last section) ----------
cluster_se:            IJV as the baseline; parent-country pair as the check for the shock models; two-way IJV and function as a check for the static models. The pre-analysis plan fixes the choice
robustness_suite:      the list in "Robustness set" below; a candidate list until the pre-analysis plan fixes it at gate 5
real_data_lock:        no model is estimated on real outcome data before reviews/gate-6-panel.md is APPROVED. Until then scripts are developed on simulated panels with planted effects
```

Notes on four values:

- `preregistered: true` is a commitment. After gate 5 every departure from
  the plan is named, dated in `docs/decisions.md`, labeled exploratory, and
  reported apart from the planned tests. One fact has to be in the plan
  itself: the staffing tabulations of 2026-11-23 showed how the categories
  are distributed over functions and levels before the hypotheses were
  fixed (`docs/decisions.md`, Open).
- `multilevel`: the template asks for an intraclass correlation before a
  single-level regression. Its counterpart here is the share of the outcome
  variance that lies within the IJV-year across functions, because that is
  the only variation the static hypotheses use (Step 1).
- `real_data_lock` protects two rules of `CLAUDE.md`: the shock is not
  chosen by looking at the outcomes (rule 8), and causal language waits for
  the identified design (rule 4). Feasibility counts are not estimates and
  are not covered; they need the PI's instruction as before.
- The hypotheses are not decided. `docs/research-brief.md` proposes H1 to H4
  (a proposal until the PI decides gate 4); gate 5 fixes the final set, the
  measures, the mapping of functions and levels, and the shock. Everything
  below that names H1 to H4 is a draft for that plan.

Where each value comes from:

| Value | Source in this repository |
|-------|---------------------------|
| Core block | `.claude/skills/research-ideation/SKILL.md` |
| `model_family`, `robustness_suite` | `docs/decisions.md` (2026-10-02, analysis in R), `.claude/agents/quant-analyst.md`, `docs/research-brief.md` ("Proposed Design"), tooling notes in `CLAUDE.md` |
| `preregistered` | `docs/workflow.md` (stage 5), `.claude/skills/estimate/SKILL.md` |
| `cluster_se` | `.claude/agents/quant-analyst.md`; the function-level check is added here (see "Inference") |
| `real_data_lock` | `CLAUDE.md` rules 4 and 8, `docs/decisions.md` (2026-10-02, shock selection) |

### Where your values change the output

| Step | What changes |
|------|--------------|
| Before Step 1 | `software: R`: `fixest`, `did`, `didimputation`, `modelsummary` are checked; no Python or Stata block anywhere |
| Step 1 — Model Specification | `model_family` gives each hypothesis a linear baseline and a fractional or count model; `multilevel` forces the within-IJV-year variance check before any model; `cluster_se` sets the clustering and the permutation test |
| Step 2 — Analysis Script | `real_data_lock`: the script takes the argument `synthetic` and is developed on a simulated panel; it reads the real panel only after gate 6 |
| Step 3 — Static Hypotheses | replaces the template's mediation step: sparse share outcomes, fractional logit, Poisson |
| Step 4 — Contingency Interactions and the Shock | replaces the template's simple-slopes step: interaction of a shock with a function-level score, event study, pre-trends, staggered estimators |
| Step 5 — Robustness Set | replaces the template's Bayesian step: `robustness_suite` |
| Step 6 — Debugging | errors of `fixest`, `did` and `modelsummary` in place of `lme4`, `lavaan` and Stan |
| Quality Checks | `effect_size` adds percentage-point effects and marginal effects; `preregistered` adds the deviation audit |

---

## Inputs (preset; ask the PI only for what is specific to the run)

| Input | Value |
|-------|-------|
| `hypotheses` | After gate 5: `reviews/gate-5-pre-analysis-plan.md`. Before: H1 to H4 of `docs/research-brief.md`, treated as drafts |
| `data_path` | After gate 6: `data/processed/panel-ijv-function-year.parquet` and `panel-ijv-level-year.parquet`. Before: a simulated panel in `data/synthetic/` |
| `software` | R |
| `model_type` | Set per hypothesis in Step 1 |
| `key_vars` | Outcomes: counts and shares of the staffing categories per cell, as stocks and as hiring flows, among people with an observed history; "history not observed" as its own outcome. Contingency scores: `coord_dependence`, `local_embeddedness` (and `coord_role` for levels), set from the interviews at gate 3. Shock: `shock`, `event_time`, first exposure year. Moderator: host-country parent. Controls: see `data/codebook.md` |
| `codebook_path` | `data/codebook.md`. Its sections on dependent variables still describe the original cross-partner measures and are revised at gate 5; do not take variable names from them without checking the plan |

Read `CLAUDE.md` (rules 1, 4, 5 and 8), `docs/theory-framework.md`,
`docs/research-brief.md`, the Open section of `docs/decisions.md` and
`.claude/agents/quant-analyst.md` before Step 1.

---

## Step-by-Step Protocol

### Before Step 1 — Check the Software

R is at `"C:/Program Files/R/R-4.6.1/bin/Rscript.exe"` on the PI's computer
and not on the PATH. Check that `fixest`, `did`, `didimputation`,
`modelsummary` and `arrow` load (on 2026-11-23 they did). Two gaps were
found that day: `modelsummary` cannot write a `.docx` file from a script
without the R package `pandoc` or `flextable`, and neither is installed;
`.tex` and `.md` output works. If a package is missing, do not stop and do
not ask the PI to install it by hand: offer to install it into the user
library, wait for the PI's approval, and add it to the package list in
`README.md`.

Check the gates (`real_data_lock`). If `reviews/gate-6-panel.md` does not
carry `Status: APPROVED`, work on a simulated panel and say so in every
output.

### Step 1 — Model Specification

Write the specification for each hypothesis before any code, in this form.
It goes into the estimation part of the pre-analysis plan.

```
Hypothesis: H3. Among locally recruited hires, the share with prior
  employment in a parent's group increases with the function's coordination
  dependence.
Unit and sample: IJV x function x year cells with at least const$min_cell_emp
  local hires with an observed history; hiring flows; IJVs with a host-country
  parent (contrast: IJVs without one).
Outcome: n_local_parent / (n_local_parent + n_local_indep), 0 to 1, zero in
  most cells.
Regressor: coord_dependence (1 to 5, varies across functions only).
Fixed effects: IJV x year. They absorb everything that is constant within
  the IJV-year: ownership shares, parent bargaining power, IJV size and age,
  host country, the shock.
Identifying variation: differences between functions inside one IJV-year.
Models: linear (feols, weighted by the denominator); fractional logit
  (feglm, quasibinomial); Poisson on the count with the denominator as
  exposure.
Inference: clustered by IJV; permutation test over functions.
Test: coefficient on coord_dependence > 0; criterion as fixed in the plan.
Effect size: percentage points per one-point difference in the score,
  against the mean share; average marginal effect for the logit.
Checks: within-IJV-year variance share; cells dropped by each estimator;
  sensitivity to the cell threshold; bounds for unobserved histories.
Competing account addressed: parent bargaining power (absorbed by the fixed
  effects); host labor supply (function x host-country effects as a check).
```

Rules by model:

| Model | Specification rules |
|-------|---------------------|
| **Linear with fixed effects** (`feols`) | State the fixed effects and what they absorb. A regressor that does not vary within the fixed effect is dropped: say which. Weight share outcomes by their denominator and report the unweighted result. Report the within R-squared, not the overall one |
| **Fractional logit** (`feglm`, `quasibinomial`) | For shares. IJV-years in which the outcome is zero in every cell carry no information and are dropped: report how many, and that the estimate is for the IJV-years with at least one such hire. Report average marginal effects |
| **Poisson** (`fepois`) | For counts, with `offset(log(denominator))`. Same reporting of dropped groups. Robust to overdispersion with clustered errors; do not switch to negative binomial with many fixed effects |
| **Shock x score interaction** | Include the shock main effect or absorb it with IJV x year effects (Step 4). Function x year effects absorb function-wide trends |
| **Event study** | Leads and lags relative to the first exposure year, reference period -1, never-exposed cells as a second reference; bin the end points; joint test of the leads |
| **Staggered adoption** | Do not rely on the two-way fixed effects estimate alone when exposure starts in different years: add `sunab`, `did::att_gt` or `didimputation` |

**Variance check (the counterpart of the ICC).** Before any model, report
how much of the outcome variance the design can use:

```r
d[, m_iy := mean(share_local), by = .(ijv_id, year)]
d[, var(share_local - m_iy) / var(share_local)]     # share of variance within the IJV-year
```

**Inference.** Three points decide whether a reviewer believes the standard
errors.

1. Cells of one IJV are not independent: cluster by IJV.
2. The contingency scores take one value per function. However many IJVs
   the panel has, the regressor has nine distinct values (four for levels).
   Clustering by IJV does not account for this. Report a permutation test
   that reassigns the scores across functions and re-estimates the model,
   and two-way clustering by IJV and function as a check, noting that nine
   clusters are too few to rely on. If gate 3 delivers scores at a finer
   grain (role groups, or function by level), use it.
3. Exposure to a shock is assigned to parent-country pairs, not to IJVs.
   For the shock models report clustering by pair next to clustering by
   IJV, and name the number of exposed clusters. With few exposed clusters
   (the scan counts 86 exposed IJVs for one candidate and 40 for another)
   say plainly that the test has little power.

```r
perm_test <- function(fml, data, scores, var, B = 999, ...) {   # scores: one row per function, first column the key
  b0 <- coef(feols(fml, data = data, ...))[[var]]
  sc <- names(scores)[-1]
  b <- vapply(seq_len(B), function(i) {
    s <- copy(scores); idx <- sample(nrow(s)); for (v in sc) set(s, j = v, value = s[[v]][idx])
    coef(feols(fml, data = copy(data)[, (sc) := NULL][s, on = names(scores)[1]], ...))[[var]] }, numeric(1))
  c(estimate = b0, p_perm = (1 + sum(abs(b) >= abs(b0))) / (B + 1))
}
perm_test(share_local ~ local_embeddedness + coord_dependence | ijv_id^year, d, fs, "local_embeddedness", weights = ~n_obs, notes = FALSE)
```

With nine functions there are 362,880 assignments, so the smallest
attainable p-value is far below any threshold. With four levels there are
24, and tied scores make it worse: with a binary `coord_role` (two levels
with a coordination role, two without) eight assignments reproduce the
observed split or its mirror image, so the test cannot return less than 1/3
(found in the simulated run of 2026-11-23). The level test cannot confirm an
effect; say so, and report the smallest attainable p-value next to the
p-value (`perm_test()` in `code/R/functions/estimation.R` returns `p_min`).

**Linear or nonlinear for shares.** In the simulated run of 2026-11-23
(500 draws, `data/synthetic/estimate-recovery-synthetic-2026-11-23.md`) the
linear model with a linear slope in one score rejected a planted null on a
correlated score in 10 to 12 percent of draws at nominal 5: the logistic
curvature of the first score loads onto the second. Linear models of sparse
shares also had clustered standard errors 5 to 10 percent too small. The
fractional logit, the Poisson model, and the linear model with the other
score as categories held the nominal level. Until the plan decides, report
a nonlinear model next to every linear one and read a linear null rejection
with that in mind.

### Step 2 — Generate the Analysis Script

The baseline models live in `code/R/04_estimate.R` and the robustness set in
`code/R/05_robustness.R`; helpers go in `code/R/functions/`. Both files are
skeletons written for the original hypotheses and are completed after gate
6. Structure:

```r
# 04_estimate.R
# Stage 7: baseline models for H1 to H<n> of reviews/gate-5-pre-analysis-plan.md.
# Input:  data/processed/panel-ijv-function-year.parquet, panel-ijv-level-year.parquet
#         (argument "synthetic": the simulated panel in data/synthetic/)
# Output: manuscript/tables/tab-*.tex and .md, manuscript/figures/fig-*.png,
#         data/interim/models-baseline.rds
# Run:    "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/04_estimate.R [synthetic]
source("code/R/00_setup.R")
require_pkgs(c("arrow", "fixest", "modelsummary"))
set.seed(20261123)                       # permutation tests and bootstraps
SYN <- "synthetic" %in% commandArgs(trailingOnly = TRUE)
# --- 1. Load, sample, cell threshold; print rows, IJVs, cells ---
# --- 2. Descriptives and the variance check ---
# --- 3. One block per hypothesis: model, checks, effect size ---
# --- 4. Tables and figures, written by the script ---
# --- 5. saveRDS(models); sessionInfo() to the log ---
```

Rules for the script:

- **Simulate first** (`real_data_lock`). Before gate 6, write a generator
  `code/R/tests/synthetic_panel.R` that simulates the panel with the columns
  of the gate-5 measurement specification and with planted effects of known
  size, and saves it to `data/synthetic/`. The analysis script has to
  recover the planted effects within sampling error, and has to return a
  null where none was planted. Never simulate from the real outcome data.
- **Do not name a column `function`.** It is a reserved word in R:
  `ijv_id^function` in a formula does not parse. The panel should carry the
  function as `fn` (propose this for the codebook at gate 5).
- Variable names follow `data/codebook.md` as revised at gate 5.
- Every table and figure of the manuscript is written by the script to
  `manuscript/tables/` and `manuscript/figures/`; nothing is typed in. File
  names follow the existing scripts (`tab-<name>`, `fig-<name>`); a
  numbering rule is proposed in the research-organizer skill and waits for
  the PI.
- Table notes state the estimator, the fixed effects, the clustering, the
  sample and the cell threshold. Report estimates with confidence
  intervals, not stars alone:

```r
modelsummary(models, output = file.path(paths$tables, "tab-baseline.tex"),
             estimate = "{estimate} [{conf.low}, {conf.high}]", statistic = NULL, gof_map = c("nobs", "r2.within"),
             notes = "Linear models with IJV x year fixed effects; 95% confidence intervals in brackets; standard errors clustered by IJV.")
```

- Results are read in `code/quarto/analysis-report.qmd`, which states for
  each hypothesis the criterion of the plan and whether the estimate meets
  it, and in `reviews/gate-7-results.md`.

### Step 3 — Static Hypotheses: Sparse Share Outcomes

Most cells hold no parent-origin hire, so the three estimators use different
samples. Run all three and report the samples side by side.

```r
d3 <- p[n_local >= const$min_cell_emp]
m_lin  <- feols(share_parent_local ~ coord_dependence + coord_dependence:host_parent | ijv_id^year,
                data = d3, weights = ~n_local, cluster = ~ijv_id)
m_frac <- feglm(share_parent_local ~ coord_dependence + coord_dependence:host_parent | ijv_id^year,
                data = d3, family = quasibinomial("logit"), weights = ~n_local, cluster = ~ijv_id)
m_pois <- fepois(n_local_parent ~ coord_dependence + coord_dependence:host_parent + offset(log(n_local)) | ijv_id^year,
                 data = p[n_local > 0], cluster = ~ijv_id)
c(linear = nobs(m_lin), fractional = nobs(m_frac), poisson = nobs(m_pois))   # cells each model keeps
```

The main effect of `host_parent` is constant within the IJV and is absorbed;
only its interaction with the score is estimated. Average marginal effect
for the nonlinear models, by prediction:

```r
ame <- function(m, data, var, delta = 1) { d1 <- copy(data); d1[[var]] <- d1[[var]] + delta
  mean(predict(m, newdata = d1, type = "response") - predict(m, newdata = data, type = "response"), na.rm = TRUE) }
ame(m_frac, d3, "coord_dependence"); d3[, weighted.mean(share_parent_local, n_local)]   # effect and outcome mean
```

Unobserved histories. The shares are defined among people with an observed
history. Report (a) the share of "history not observed" as an outcome of its
own, regressed on the same scores, and (b) bounds: every unobserved hire
counted as independent, and every one counted as parent-origin. If the sign
of the coefficient changes between the bounds, say so.

### Step 4 — Contingency Interactions and the Shock

The dynamic hypothesis is an interaction of a shock that varies by IJV and
year with a score that varies by function.

```r
m_h4 <- feols(share_local ~ shock:local_embeddedness + shock:coord_dependence |
                ijv_id^fn + fn^year + ijv_id^year, data = d, weights = ~n_obs, cluster = ~ijv_id)
```

- **Absorb or include the shock main effect.** `ijv_id^fn` and `fn^year`
  do not absorb a shock that switches on within an IJV. With uncentered
  scores, leaving the main effect out loads it onto the interactions. In a
  simulation with a planted effect on one score and none on the other, the
  model without the main effect returned a clearly non-zero coefficient on
  the second score; with `shock` added, or with `ijv_id^year` effects, it
  returned zero. `ijv_id^year` is the stricter choice: the coefficient then
  comes only from how the functions of one IJV diverge after the shock.
- **Event study and pre-trends before any causal word** (`CLAUDE.md` rule 4):

```r
d[, et := pmax(pmin(event_time, 4L), -5L)]; d[is.na(event_time), et := -1000L]   # binned; never exposed = -1000
m_es <- feols(share_local ~ i(et, local_embeddedness, ref = c(-1, -1000)) | ijv_id^fn + fn^year + ijv_id^year,
              data = d, weights = ~n_obs, cluster = ~ijv_id)
wald(m_es, keep = "et::-[2-5]")                    # joint test of the leads
png(file.path(paths$figures, "fig-event-study.png"), width = 1600, height = 1000, res = 200); iplot(m_es); dev.off()
```

  A joint test that does not reject is not proof of parallel trends. Report
  the lead coefficients with their intervals and say how large a pre-trend
  the data could not rule out. The decision rule for reading the leads is
  written into the pre-analysis plan before the data are seen.
- **Staggered exposure.** Where the first exposure year differs across
  IJVs, add a heterogeneity-robust estimator. For an interaction with a
  score, estimate it within groups of functions (high and low on the score)
  and compare:

```r
d[, cohort := fifelse(is.na(first_shock_year), 10000L, first_shock_year)]         # never exposed: far-off cohort
m_sa <- feols(share_local ~ sunab(cohort, year) | ijv_id^fn + year,
              data = d[local_embeddedness >= 4], weights = ~n_obs, cluster = ~ijv_id)
summary(m_sa, agg = "att")
```

- Nothing in this step runs on real data to compare candidate shocks. The
  shock is chosen at gate 5 from exposure counts, design properties and the
  literature.

### Step 5 — Robustness Set

The candidate list (`robustness_suite`). The pre-analysis plan fixes the
list and the order; anything added later is exploratory.

1. Event study with leads and lags, pre-trend test.
2. Staggered estimators: `sunab`, `did::att_gt`, `didimputation`.
3. Fractional logit and Poisson next to the linear model.
4. Cell-size thresholds 3, 5 and 10 (`const$min_cell_emp` is 5).
5. Alternative function and level classifications from the qualitative memo.
6. Placebo shocks: shifted dates, unexposed pairs.
7. Stocks next to hiring flows; hiring flows from 2010 only.
8. Bounds for unobserved histories; labor market entrants in and out.
9. Origin window of two and five years next to three.
10. Samples: strategic IJVs; IJVs with all parents in Revelio; base-rule
    IJVs only; without IJVs whose matched entity lies in a parent's Revelio
    family; without matches flagged `flag_pre_formation_10y`.
11. Clustering by parent-country pair; permutation inference over functions.

Items 7 to 10 follow from the feasibility counts and the quality flags in
`reviews/gate-4-pilot.md`; several rest on open items in
`docs/decisions.md`. The former item on ownership-adjusted parent dominance
belongs to the original cross-partner measures and applies only if gate 5
keeps them.

### Step 6 — Debugging Protocol

When an error occurs, diagnose in this order:

1. **Print the error verbatim.** Do not paraphrase it.
2. **Check the data**: `str(d)`, the number of cells, IJVs and years, the
   share of zero outcomes, missing values in the model variables.
3. **Isolate the failing line** on the simulated panel, where the right
   answer is known.
4. **Check package versions**: `sessionInfo()`.
5. **Read the message literally.** `fixest` notes are information about the
   sample, not noise to suppress.

| Message or symptom | Likely cause | What to do |
|---|---|---|
| `unexpected '+'` or `unexpected symbol` in a formula | a column called `function` | rename the column to `fn` |
| `The variable '...' has been removed because of collinearity` | the regressor does not vary within a fixed effect (a function-level score with function effects, `host_parent` with IJV effects, `shock` with IJV x year effects) | expected in many models; state which term is absorbed and by what. Unexpected: check the fixed effects |
| `NOTE: n fixed-effects (m observations) removed because of only 0 outcomes or singletons` | `feglm` and `fepois` drop IJV-years whose outcome is zero in every cell | report n and m; compare the sample with the linear model; never silence the note |
| Interaction on an unaffected score is far from zero in the simulation | shock main effect neither included nor absorbed | add `shock` or `ijv_id^year` effects (Step 4) |
| Standard errors change sharply under two-way clustering by function | nine clusters | report the permutation test; do not pick the smaller error |
| `sunab` returns no coefficients or absurd ones | never-exposed units coded `NA` or 0 | code them as a cohort far outside the panel years (10000) |
| `did::att_gt`: `No pre-treatment periods` or id errors | units exposed in the first panel year; non-numeric id; never-treated not coded 0 | drop always-treated units and say so; numeric id; `gname = 0` for never treated |
| `Please install the pandoc package` from `modelsummary` | `.docx` output from a script | write `.tex` and `.md`; for Word output install `pandoc` or `flextable` with the PI's approval, or render through Quarto |
| Model runs for minutes | interacted fixed effects on a very large table | check that the panel is at cell level, not person level; `fixef.tol`, `nthreads` |
| Coefficient changes sign between stock and flow | stocks carry decades of earlier hiring and survivors | report both; flows are the outcome closest to a staffing decision |

---

## Quality Checks

- [ ] Every hypothesis of the plan has a written specification with unit, sample, outcome, fixed effects, identifying variation, test and effect size
- [ ] `multilevel`: the within-IJV-year variance share was reported before the static models
- [ ] `cluster_se`: standard errors are clustered by IJV; the permutation test over functions is reported for every function-level regressor; the shock models also report clustering by parent-country pair and the number of exposed clusters
- [ ] Cells and IJV-years dropped by the fractional and Poisson models are counted and reported next to the linear sample
- [ ] The shock main effect is included or absorbed in every interaction model
- [ ] Pre-trends were examined and reported before any causal wording; the reading rule was fixed in the plan
- [ ] `effect_size`: every headline estimate is given in percentage points against the outcome mean with a 95 percent interval; nonlinear models report average marginal effects; no table rests on stars alone
- [ ] Unobserved histories are reported as their own outcome and as bounds; they are never counted as independent hires
- [ ] `preregistered`: every departure from the plan is dated in `docs/decisions.md`, labeled exploratory, and reported apart from the planned tests
- [ ] `robustness_suite`: every item of the plan's list was run, or the reason it could not be run is stated
- [ ] `real_data_lock`: no model touched real outcome data before gate 6 was approved; the script recovered the planted effects on the simulated panel
- [ ] Scripts run from top to bottom from `code/R/00_setup.R` with `set.seed()`; every table and figure is written by a script to `manuscript/tables/` or `manuscript/figures/`; table notes state estimator, fixed effects, clustering, sample and threshold
- [ ] Nothing was estimated or tabulated to compare candidate shocks, no hypothesis was added, and no gate status was changed

---

## Common Failure Modes to Avoid

- **Counting IJVs as the sample size for a function-level effect.** Thousands of IJVs do not turn nine score values into thousands of observations.
- **Reading the two-way fixed effects coefficient as the effect** under staggered exposure, or after a pre-trend test with no power.
- **Dropping the zeros silently.** A fractional or Poisson model that keeps a third of the IJV-years answers a different question from the linear model.
- **Specification search after the fact.** The tabulations have already been seen; the plan is the protection, so follow it and label the rest.
- **Causal words for the static hypotheses.** They are associations across domains within the IJV (`CLAUDE.md` rule 4).
- **Explaining a surprise from memory.** One explanation, with a citation key that exists in `literature/references.bib`, or a `[CITE: ...]` marker.

---

## Extending the Template (Exercise 3A Part 2)

Adding a field takes three edits, and all three matter:

1. Add the key to the **skill-specific block**.
2. Add a row to **Where your values change the output**, naming the step it affects.
3. Add a line to **Quality Checks**, so the new behavior is verified, not assumed.

Three fields were added this way on 2026-11-23: `cluster_se` (Step 1,
"Inference"), `robustness_suite` (Step 5) and `real_data_lock` (Before Step
1 and Step 2). They have not been tested yet. Test each twice, once set and
once as a placeholder; if the output is the same, the skill is ignoring the
field.

Further candidates: `min_cell` (the cell threshold and its alternatives,
now read from `const$min_cell_emp`); `multiple_testing` (a correction
across the hypotheses, if the plan asks for one); `power_simulation`
(detectable effect for the sparsest cell, simulated from the cell counts
without using outcomes); `sensitivity_priors` does not apply (no Bayesian
model).
