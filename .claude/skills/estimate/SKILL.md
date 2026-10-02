---
name: estimate
description: "Stage 7 of the research workflow. Estimates the baseline two-way fixed effects interaction models and the robustness set (event study, staggered DiD, fractional response, thresholds, placebos) via the quant-analyst agent and renders the analysis report. Requires gate 6 approved."
---

# /estimate

Prerequisite: `reviews/gate-6-panel.md` is APPROVED.

Launch the `quant-analyst` agent for Stage 7 as in its definition. The
pre-analysis plan is binding; exploratory additions are labelled as such.

Check on return: every table in `manuscript/tables/` and figure in
`manuscript/figures/` is produced by `code/R/04_estimate.R` or
`code/R/05_robustness.R`; the analysis report states for each
hypothesis whether it is supported, partially supported or not
supported by the pre-registered criterion; pre-trend results are
reported before any causal language. Commit and summarize.
