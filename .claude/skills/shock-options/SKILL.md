---
name: shock-options
description: "Stage 5a of the research workflow. Generates and compares candidate geopolitical shocks via the shock-evaluator agent on theoretical fit, measurement quality, identification potential, sample coverage and substantive novelty. Usage: /shock-options scan (desk phase, no prerequisites) or /shock-options rescore (after gate 5a and gate 4)."
---

# /shock-options scan | rescore

The PI decided not to fix the focal shock in advance
(`docs/decisions.md`). This skill produces the comparison the decision
needs.

## scan

No prerequisites. It can run in parallel with stages 1 to 4. Launch the
`shock-evaluator` agent for Phase A as in its definition. Tell it:
- the independence rule (no outcome patterns),
- to use WebSearch and WebFetch, not the Consensus connector, unless
  `docs/decisions.md` records that the plan was upgraded,
- to read `literature/synthesis/qual-measurement-memo.md` if it exists,
  for triggers respondents name.

On return, check that `literature/shock-scan/` holds `candidates.md`,
`literature-scan.md`, `data-inventory.md`, `scoring.csv` and
`recommendation.md`, that `reviews/gate-5a-shock-scan.md` exists with
Status PENDING, and that no outcome by exposure status was reported.
Commit and summarize: the shortlist, the rank sensitivity to weights,
the candidates that failed hard screens, and the decisions for the PI.

## rescore

Prerequisites: gate 5a APPROVED (the PI's shortlist and any new weights)
and gate 4 APPROVED. If either is missing, name it and stop. Launch the
`shock-evaluator` agent for Phase B. On return, check that
`code/R/06_shock_exposure.R` and `literature/shock-scan/rescoring.md`
exist, then summarize the final recommendation for the PI. Do not record
the shock as decided until the PI says so; then move the item from Open to
Decided in `docs/decisions.md` and carry it into
`reviews/gate-5-pre-analysis-plan.md`.
