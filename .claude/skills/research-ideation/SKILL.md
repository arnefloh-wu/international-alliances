---
name: research-ideation
description: >
  Use this skill to generate, structure, and stress-test research ideas for
  the IJV staffing study. Triggers: "brainstorm research ideas", "find gaps
  in the literature", "generate hypotheses", "develop my theoretical
  framework", "revise the research idea", "restate the hypotheses", or any
  request to move from the revised staffing idea (geographic origin x
  organizational origin of IJV employees) to a concrete, defensible research
  question and Research Brief.
---

# Research Ideation & Literature Gap Analysis

Customized on 2026-11-22 from the seminar template `1A-research-ideation.md`
for the IJV staffing study (Floh, Mohr, Thanyi; target JIBS).

## What This Skill Does

Starting from the revised research idea in **Study preset** below, this skill
guides Claude through a structured ideation process: mapping the literature,
surfacing gaps, generating hypotheses, and framing the theoretical argument.
Output is a Research Brief saved as `docs/research-brief.md` and referenced
from `CLAUDE.md`, so every session starts from it.

Place in the workflow (`docs/workflow.md`): this skill is not a numbered
stage. It prepares the PI's answer to gate 4, decision 1 (what replaces the
cross-partner integration hypotheses) and the input to
`/research-workflow hypotheses` at stage 5. It never approves a gate, never
fixes the focal shock, and never edits `docs/theory-framework.md` or
`initial-research-idea.md`.

---

## Customize This Skill (completed)

The **core** block is identical in all ten skills: paste it into the other
nine unchanged. The **skill-specific** block and the **extensions** apply
only here. Each value names the project file it was taken from in the table
that follows the block.

```yaml
# ---------- CORE — identical in all ten skills ----------
field:                 international business
subfield:              international joint ventures: staffing, control and organizational design
target_venue:          Journal of International Business Studies
citation_style:        APA 7 in text; JIBS reference list (manuscript/csl/journal-of-international-business-studies.csl)
software:              R
replication_standard:  code-only package: scripts in code/R/ reproduce every table and figure from the licensed exports; Orbis, Revelio and BoardEx data are not shareable; pre-analysis plan fixed at gate 5

# ---------- SKILL-SPECIFIC — research-ideation ----------
lit_sources:           literature/references.bib (verified, cite from here); Zotero group library; Consensus connector (agent-run); Web of Science, EBSCO Business Source and Google Scholar through emitted search strings run by hand
theory_anchors:        structural contingency theory (main theory, binding); resource dependence theory (candidate complement, not yet in the hierarchy); differentiated network and integration-responsiveness as IB vocabulary only; no microfoundations
hypothesis_style:      contingency-level directional prediction: name the contingency that differs across functions or levels, or that the shock changes, then the expected staffing configuration; instantiated for a shock only after gate 5
design_constraints:    archival panel from Orbis and Capital IQ ownership matched to Revelio through WRDS, BoardEx for senior levels only; 7,460 IJVs in core_main (2,172 strategic); parent-origin staff about 2 to 4 percent of person-years; about half of person-years without a prior position on record; China (86) and Russia (40) exposure groups thin; survivor frame, incorporation date stands in for formation; no new primary data beyond the existing manager interviews

# ---------- EXTENSIONS (three-edit pattern, see the last section) ----------
staffing_frame:        geographic origin (host country | abroad) x organizational origin (either parent's group | neither), plus a fifth class "history not observed"; stocks and hiring flows kept apart
feasibility_gate:      Q1 to Q7 in "Feasibility questions" below; Q1 to Q4 and Q6 first
```

Where each value comes from, so it can be updated when the source changes:

| Value | Source in this repository |
|-------|---------------------------|
| `target_venue`, `citation_style`, `software` | `docs/decisions.md` (2026-10-02), `CLAUDE.md` rules 3 and 5 |
| `replication_standard` | `CLAUDE.md` rules 2 and 5, `docs/workflow.md` stage 5. Whether the code is deposited publicly (OSF or elsewhere) is not decided; ask the PI before a brief promises it. |
| `lit_sources` | `docs/decisions.md` (2026-10-02), `CLAUDE.md` tooling notes |
| `theory_anchors` | `docs/theory-framework.md`; resource dependence theory comes from the revised idea and is not in that file |
| `hypothesis_style` | `docs/theory-framework.md`, "Rules for agents" |
| `design_constraints` | `reviews/gate-4-pilot.md` and `docs/coauthor-notes/gate-4-options-2026-10-10.qmd`. Re-read both before quoting a number: the counts change when matching changes. |

### Where your values change the output

| Step | What changes |
|------|--------------|
| Step 1 — Map the Terrain | IB / IJV staffing: the constructs are staffing configuration, geographic localization, organizational dependence on the parents, the four contingency families, and the domain (function, hierarchical level) |
| Step 2 — Identify Gaps | `lit_sources`: evidence for a gap is a key in `literature/references.bib` or a `[CITE: ...]` marker, never a reference from memory |
| Step 3 — Generate Hypotheses | `hypothesis_style`: a signed prediction is not enough; each hypothesis names the contingency first. `staffing_frame`: each hypothesis says which of the four categories moves |
| Step 3 — Testability flag | `feasibility_gate`: each hypothesis lists the feasibility questions it rests on and their status |
| Step 4 — Theory Dialogue | `theory_anchors`: the anchor is fixed (structural contingency theory); the dialogue tests whether resource dependence theory earns a place beside it |
| Step 5 — Research Brief | JIBS plus `design_constraints`: archival panel on core_main, no new survey, no design that needs staff from both parents in one cell, no shock named as chosen |

---

## Study preset

These replace the questions the blank template asks. Ask the PI only what has
changed since 2026-11-22.

| Input | Value |
|-------|-------|
| `topic` | Staffing of international joint ventures on two dimensions, replacing the direct measurement of cross-partner integration (see below) |
| `discipline` | International business; IJV staffing and control |
| `method_pref` | Exploratory sequential mixed method: recoding of existing manager interviews, then an archival panel (IJV x function x year, IJV x level x year) in R |
| `outlet_target` | Journal of International Business Studies |
| `prior_work` | `literature/references.bib`, `literature/synthesis/` if it exists, `initial-research-idea.md` (superseded where it measures cross-partner integration), `reviews/gate-4-pilot.md`, `docs/coauthor-notes/gate-4-options-2026-10-10.qmd` |

Read `CLAUDE.md`, `docs/theory-framework.md` and the Open section of
`docs/decisions.md` before Step 1.

### The revised idea

The pilot showed that staff from both parents working side by side cannot be
measured at scale in Revelio. The study therefore moves to staffing
localization, but on two dimensions instead of one:

- **Geographic origin:** recruited from the IJV's host country or from abroad.
- **Organizational origin:** previously employed by either IJV parent
  (including the parent's group companies), or recruited independently.

| | Prior employment with an IJV parent | No prior employment with either parent |
|---|---|---|
| **Recruited locally** | Local parent-origin hires | Independent local hires |
| **Recruited internationally** | International parent-origin hires | Independent international hires |

Why two dimensions: an IJV can employ more local staff without depending less
on its parents (hiring from the local parent's workforce), and it can depend
less on its parents without localizing (hiring internationally from unrelated
organizations). The second dimension is also the reason to study IJVs and not
wholly owned subsidiaries: an IJV reconciles the resource contributions,
coordination requirements and possibly competing interests of several parents.

Working research question:

> How do international joint ventures combine parent-based and independent
> recruitment from local and international labor markets, and how do
> organizational contingencies and geopolitical changes shape these staffing
> choices across functions and hierarchical levels?

### Feasibility questions

The idea stands or falls with whether Revelio separates the four categories.
The "Known so far" column is a pointer, not a result: check the file again.

| Q | Question | Why it matters for the idea | Known so far (2026-11-22) |
|---|----------|-----------------------------|---------------------------|
| Q1 | Can employees who came from the local parent (and its group) be identified, and for how many IJVs, functions, levels and years? | Separates localization through the local parent from independent local recruitment | Parent-origin shares exist only as parent A and parent B, where A is the larger shareholder, not the local one (`reviews/gate-4-pilot.md`). Local versus foreign parent is not tabulated. |
| Q2 | Can independent international hires be identified and told apart from international parent-origin hires? | Separates geographic localization from organizational dependence | Pilots report "external international hire" at 11 to 13 percent of person-years; reliability of the parent exclusion not assessed |
| Q3 | For what share of employees is a previous employer and its country observed? Can confirmed independent hires be told apart from missing histories? | Missing histories counted as independent hires would bias the parent versus independent comparison | 47 to 49 percent of person-years have no prior position on record in the two pilots |
| Q4 | Does Orbis give annual, unconsolidated headcounts for the IJVs, for how many of the 7,460, and how do they compare with Revelio counts? | Measures Revelio's workforce coverage. Parent-origin staff must not be inferred as the Orbis minus Revelio residual: the residual also holds everyone Revelio misses for other reasons | Orbis headcounts were used to define the large-JV stratum; coverage across core_main not tabulated |
| Q5 | Do IJVs with parent-linked senior managers in BoardEx show different Revelio coverage? Can the full BoardEx-matched sample measure parent representation? | Tests whether parent-origin staff are systematically missing from Revelio; supplementary measure at senior levels | BoardEx check of 2026-10-10: 2,537 of 7,460 IJVs covered, 1,207 with a parent-linked senior person, 279 with senior people linked to both parents. The link to Revelio coverage is not examined. |
| Q6 | How many employee observations and IJVs fall into each category, by function, seniority and year, for stocks and for hiring flows? How many IJVs support longitudinal analysis? | Shows whether the richer classification still leaves a large and representative sample | Not run. `docs/decisions.md` (2026-10-09) holds the parent-origin classification back until gate 5, so a preliminary run needs the PI's instruction. |
| Q7 | Which geopolitical developments affect enough IJVs with enough observations before and after? | The shock is chosen on theoretical relevance, data availability and identification together | `literature/shock-scan/` and gate 5a (pending). Exposure counts in core_main: OECD screening 3,638, UK-EU 485, China coercion 86, Russia 40. |

Update of 2026-11-23: Q1 to Q6 were tabulated by
`code/R/wrds/11_staffing_tabulations.R`. The counts are in
`reviews/gate-4-pilot.md`, section "Staffing tabulations", and replace the
"Known so far" column for those rows. Q7 is still open.

Priority: Q1 to Q4 and Q6. This skill does not run data. When a hypothesis
depends on an open question, it says so and proposes the tabulation for the
data-engineer.

---

## Step-by-Step Protocol

### Step 1 — Map the Terrain
Start from the preset; do not ask the PI to describe the topic again. Produce:
- A **concept map** of the 4 to 6 core constructs: staffing configuration (the
  four categories), geographic localization, organizational dependence on the
  parents, the contingency families (task, coordination, environmental,
  resource), the domain (function, hierarchical level), and geopolitical
  change as a change in contingencies.
- The theoretical lenses by tier, as in `docs/theory-framework.md`, with
  resource dependence theory marked as a candidate.
- The standard empirical approaches in IJV staffing research (manager
  surveys, expatriate counts in top management, archival employment
  histories) and what each can and cannot observe of the two dimensions.

### Step 2 — Identify Gaps
For each gap type, generate 2 to 3 candidate gaps:

| Gap Type | Prompt to Apply |
|----------|-----------------|
| **Empirical** | "What has never been directly tested about who staffs an IJV?" |
| **Boundary condition** | "For which functions, levels, parent constellations or host countries does the localization effect not hold?" |
| **Mechanism** | "Why do IJVs recruit from a parent instead of the market? Is it unresolved?" |
| **Context** | "Which host regions, industries or periods are understudied?" |
| **Methodological** | "What does the reliance on surveys and top-management expatriate counts leave unobserved?" |

Present gaps as: *[Gap type]: [Specific gap statement]. Evidence: [1 to 2
citation keys from `literature/references.bib`, or `[CITE: what is needed]`].
Why IJV: [what would differ for a wholly owned subsidiary].*

A gap with no answer to "Why IJV" is a gap in the subsidiary staffing
literature, not in this paper. Keep it only as a secondary point.

### Step 3 — Generate Hypotheses
For the 2 to 3 most promising gaps, write hypotheses in this structure:

```
H[n]: In [functions / hierarchical levels] where [contingency] is [higher / lower],
      IJVs rely [more / less] on [staffing category or dimension],
      because [mechanism from contingency logic, or from resource dependence if adopted].

Dynamic form: when [contingency] [rises / falls] for [domains],
      the share of [staffing category] [rises / falls] more in those domains.
      (Stated at the contingency level. No shock is named before gate 5.)
```

Flag each hypothesis:
- **Novelty** (Low / Medium / High)
- **Testability**: which categories it needs, stock or hiring flow, unit of
  analysis, and the feasibility questions it rests on with their status
  (open / partly answered / answered). A hypothesis resting on an open
  question is marked **provisional**.
- **Risk**: how likely a null result is, and how likely the category is too
  sparse to estimate (parent-origin cells in particular)
- **IJV-specific**: would the prediction differ for a wholly owned subsidiary?
- **Separability**: how the contingency is told apart from ownership
  asymmetry and parent bargaining power

Do not write a hypothesis that needs staff from both parents in the same
function or level cell. Gate 4 showed this cannot be observed.

### Step 4 — Theory Development Dialogue
Prompt the PI: *"Which hypothesis resonates most? Let's build the theoretical
argument."* Then:
1. The anchor is structural contingency theory. Do not offer alternatives as
   the main theory.
2. Test resource dependence theory as a complement. Write the argument for
   the chosen hypothesis twice, once with contingency logic alone and once
   with resource dependence added, and state what the second version explains
   that the first cannot (the organizational-origin dimension: reliance on a
   parent for personnel, and the difference between the local and the foreign
   parent as providers) and what it costs (a second theory a JIBS reviewer
   will ask to see earn its place). The PI decides. If the PI adopts it,
   draft a dated entry for `docs/decisions.md`; do not edit
   `docs/theory-framework.md`.
3. Map the causal chain: contingency of the domain → staffing choice on each
   dimension → staffing configuration; contingency change → selective
   reconfiguration.
4. Surface competing explanations and how the design would rule them out. At
   minimum: parent bargaining power and ownership asymmetry; supply of
   qualified staff in the host labor market; IJV age (localization over the
   life cycle); host rules on foreign staff; and data artefacts (seconded
   staff filed under the parent, missing histories).
5. Address the three tensions listed in `docs/theory-framework.md`: the
   static reading of contingency theory, its single-organization origin, and
   the entanglement of contingencies with bargaining power.

### Step 5 — Draft the Research Brief

Write the brief to **`docs/research-brief.md`**. Then add one line to the
"What this project is" section of `CLAUDE.md` that points to it as the
current statement of the idea. Change nothing else in `CLAUDE.md`; its
description of the original idea stays until the PI revises it.

Append to the Open section of `docs/decisions.md` every point the brief
leaves to the PI (for example the adoption of resource dependence theory, or
a tabulation needed to answer a feasibility question). Do not commit unless
the PI asks; the repository rule is one commit per completed stage on the
branch the session designates.

Template:

```markdown
# Research Brief: [Working Title]

Date, version, and the gate status this brief assumes.

## Core Question
[One sentence: what does this study ask?]

## Staffing Frame
[The four categories, the "history not observed" class, stock versus flow,
and the unit of analysis.]

## Theoretical Contribution
[2–3 sentences: what does this add to contingency theory in IB? What is
specific to IJVs? What gap does it fill?]

## Hypotheses
H1: ...
H2: ...

## Feasibility Dependencies
| Hypothesis | Rests on | Status | If the answer is no |
|------------|----------|--------|---------------------|
| H1 | Q1, Q3 | open | ... |

## Proposed Design
- Sample: [core_main or the strategic subset, with counts and the date read]
- Method: [interview recoding; archival panel]
- Key measures: [category shares, stocks and flows; contingency scores]
- Identification strategy: [two-way fixed effects baseline; event study or
  difference-in-differences once the shock is chosen at gate 5]
- Shock: not chosen. [Candidates from `literature/shock-scan/`.]

## Anticipated Contribution
- To theory: ...
- To practice/policy: ...

## Risks & Mitigations
| Risk | Mitigation |
|------|------------|
| ... | ... |

## Decisions for the PI
1. ...

## Next Steps
1. ...
```

---

## Quality Checks (run before delivering)

- [ ] Hypotheses are falsifiable and directional, and each names the
      contingency before the predicted staffing configuration
- [ ] Every gap claim cites 1 to 2 keys that exist in
      `literature/references.bib` or carries a `[CITE: ...]` marker; no
      reference, statistic or count is given from memory
- [ ] The theoretical mechanism is distinct from the hypothesis itself
- [ ] At least one competing explanation is acknowledged, and parent
      bargaining power is among them
- [ ] The design fits `design_constraints`: archival, core_main or a stated
      subset, no cell that needs staff from both parents
- [ ] `staffing_frame`: every hypothesis and measure uses the four
      categories; "history not observed" is reported as its own class and
      never folded into independent hires; stock or flow is stated
- [ ] `feasibility_gate`: every hypothesis lists the questions it rests on
      and their status; those resting on an open question are marked
      provisional; the brief holds the dependency table
- [ ] Each hypothesis answers "would this differ for a wholly owned
      subsidiary?"
- [ ] Resource dependence theory appears as a candidate unless
      `docs/decisions.md` records its adoption
- [ ] No shock is named as chosen, and no pattern in staffing outcomes is
      used to argue for one
- [ ] Counts quoted from the gate files carry the file and the date read; no
      row-level licensed data appears in the brief
- [ ] No gate status was changed; `docs/theory-framework.md` and
      `initial-research-idea.md` were not edited

---

## Common Failure Modes to Avoid

- **Gap-by-assertion**: saying "no research exists on X" without evidence.
  Qualify with "limited work has examined" or cite the closest study.
- **Mechanism = restatement**: "coordination-dependent functions hire from
  the parent because they depend on the parent" is circular. Name the
  process: what the parent-origin hire carries that a market hire does not.
- **Overscoped brief**: the original idea had five hypotheses. Write only as
  many as the four categories and the feasibility answers can carry.
- **Localization relabelled**: a hypothesis about local versus foreign staff
  alone is the one-dimensional idea this study moved away from. Each
  hypothesis must use organizational origin or say why it does not.
- **Missing counted as independent**: an employee without an observed
  history is not a confirmed independent hire (Q3).
- **Residual inference**: parent-origin staff cannot be measured as Orbis
  headcount minus Revelio headcount (Q4).

---

## Extending the Template (Exercise 1A Part 2)

Adding a field takes three edits, and all three matter:

1. Add the key to the **skill-specific block**.
2. Add a row to **Where your values change the output**, naming the step it affects.
3. Add a line to **Quality Checks**, so the new behaviour is verified rather than assumed.

Two fields were added this way on 2026-11-22: `staffing_frame` and
`feasibility_gate`. Neither has been tested yet. Test each twice: once as
set, once replaced by an `<angle bracket>` placeholder. If the output is
identical, the skill is ignoring the field.

### Ideas worth adding next

- `adversarial_review: true`: before delivering the brief, argue against
  your own hypotheses as a JIBS reviewer would and record what survives
- `null_result_plan:` state up front what a null result would mean, so the
  design does not depend on a significant finding
- `replication_of:` name the study you are extending, and require the brief
  to state what is new
