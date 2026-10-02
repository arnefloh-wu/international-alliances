---
name: research-workflow
description: "Orchestrates the agent-based research workflow for the JIBS manuscript on differentiated international integration in IJVs. Use with \"status\", \"next\", \"setup\", \"hypotheses\", or a stage name. Checks review gates in reviews/ and launches the right agent for the next unblocked stage."
---

# /research-workflow

Usage: `/research-workflow status | next | setup | hypotheses | <stage>`

Stages: `lit-search`, `lit-synthesis`, `qual-recode`, `pilot-feasibility`,
`hypotheses`, `panel-build`, `estimate`, `write-section <section>`,
`references`, `internal-review`.

## Procedure

1. Read `docs/workflow.md` and `docs/decisions.md`. List `reviews/gate-*.md`
   and read each `Status:` line.
2. `status`: print a table of stages, gate status, deliverable paths, and
   open decisions from `docs/decisions.md`. Stop.
3. `next`: pick the lowest-numbered stage whose prerequisites in the
   workflow table are APPROVED (or have no gate) and whose own gate does
   not exist or is REJECTED. Stages 1, 3 and 4 have no prerequisites and
   may be launched together as parallel Agent calls. Tell the user which
   stage you are launching and why, then run step 5.
4. `<stage>`: check prerequisites. If a prerequisite gate is PENDING or
   missing, refuse, name the gate, and stop. The user can override with
   "run anyway"; record the override in `docs/decisions.md`.
5. Launch the stage's agent with the Agent tool
   (`subagent_type` = the agent name in `docs/workflow.md`). Pass the
   stage skill's instructions as the prompt, plus any PI notes from an
   `APPROVED WITH CHANGES` gate upstream.
6. When the agent reports back, verify the deliverables exist at the
   paths it names, verify the gate file exists with `Status: PENDING`,
   and commit with the message `stage <n> <name>: <one line>`.
7. Summarize to the PI in under 200 words: what was produced, the
   decisions the gate file asks for, and the next stage waiting on it.

## `setup`

Verify the folder scaffold in `CLAUDE.md`, that `.gitignore` excludes
`data/`, that `literature/references.bib` exists, and that the
`academic-writing` skill is available. Add missing PI answers to
`docs/decisions.md`.

## `hypotheses` (Stage 5)

Prerequisites: G2, G3, G4 approved, and the focal-shock decision in
`docs/decisions.md` moved from Open to Decided. If the shock is still
open, produce `reviews/shock-options.md` instead: for each candidate
shock (geopolitical deterioration measured by a validated dyad index or
discrete sanction events, investment-screening reform, mobility
restrictions), the exposed dyads in the pilot sample, timing precision,
cross-dyad variation, plausible exogeneity to IJV staffing, and the
hypotheses it can and cannot identify. End with a recommendation and
stop for the PI.

With the shock decided, draft `reviews/gate-5-pre-analysis-plan.md`:
final H1 to H5 wording, construct definitions, the function
classification scores for coordination dependence and local
embeddedness (from the qualitative memo), DV formulas (see
`code/R/functions/measures.R`), the shock variable, baseline and
robustness specifications (from the quant-analyst agent), cell
thresholds, clustering, sample restrictions, and the exact predictions
that would count as support, partial support or no support for each
hypothesis. Status PENDING.

## Gate approval

Never set a gate to APPROVED. When the PI says in chat that a gate is
approved, edit the gate file's status line, add `Approved by: <PI>,
<date>, in chat`, and continue.
