# Gate 5: Pre-analysis plan

Status: APPROVED
Approved by: Arne Floh, 2026-11-25, in chat ("approve all decision of gate 5"); line set by the agent on the PI's instruction. The plan is fixed as v1.0 by the annotated Git tag `pap-v1.0`, created on the PI's instruction once this file is on `main`
Stage: 5 Pre-analysis plan (`/research-workflow hypotheses`)
Agent: orchestrator with quant-analyst
Date produced: 2026-11-25, draft (parts A, B and C merged). File opened on 2026-11-24 to carry in the focal shock decision

## Decisions carried in before stage 5

### Focal shock (decided by the PI on 2026-11-24)

The PI adopted S13 as the focal shock and S06 as the fallback, in chat on
2026-11-24 ("Adopt S13, S06 fallback"), after `/shock-options rescore`.
Recorded in `docs/decisions.md` (Decided, 2026-11-24).

Amended on 2026-11-25: S06 is retired as the fallback; S13 is the only
confirmatory shock and is not replaced ("Decisions in chat during stage
5", item 17). The S06 column below is kept as the record of the rescore.

| | Focal: S13 | Fallback: S06 (retired 2026-11-25) |
|---|---|---|
| Shock | Brexit: end of the UK-EU transition period and of free movement | Staggered investment screening in OECD hosts |
| Onset | 2021 (referendum 2016; 2016 to 2020 as anticipation window, proposed) | Host adoption year, 2017 onward (proposed lower bound) |
| Exposure | IJVs whose host and parent countries form a UK-EU, EEA or Switzerland pair | IJVs with a non-allied parent (China, Hong Kong, Macao) in a screened sector of a screening host |
| Exposed in `core_main` | 28 pairs; 394 IJVs (97 strategic), 311 with a parent in Revelio | 39 IJVs (7 strategic), 35 with a parent in Revelio |
| After cell thresholds (IJVs with a parent in Revelio; pairs) | 136 (hires rule) to 231 (employee rule); 23 to 24 pairs | 23 (hires rule) to 32 (employee rule); 15 to 19 pairs |
| Controls | 3,409 never-treated IJVs in the UK and the EU, EEA and Switzerland without a UK-set link (1,273 at the hires rule) | Not-yet-treated hosts and allied-parent IJVs in the same hosts and sectors (1,011; 399 at threshold) |
| Rescored score (equal weights) | 4.20 | 3.20 |

Sources: `literature/shock-scan/rescoring.md` (sections 4, 6 and 9),
`literature/shock-scan/rescoring-counts-2026-11-24.csv`, produced by
`code/R/06_shock_exposure.R`. The shock was chosen on exposure counts,
design properties and literature evidence only; no staffing outcome was
tabulated by exposure status (`CLAUDE.md` rule 8).

Proposed design for S13 (from `rescoring.md`, section 9; open until this
gate): hiring flows per IJV x function x year, 2008 to 2025; treatment as
exposed IJV x post-2021 x the function's change in local embeddedness, with
coordination dependence as the moderator of the channel; IJV x year, IJV x
function and function x year fixed effects; an event study with 2013 to 2015
as the clean pre-period; GB-IE IJVs (31) as a within-shock contrast that
separates the regulatory channel from the mobility channel; clustering by
country pair with a wild cluster bootstrap.

Superseded in part on 2026-11-25: hiring flows run from 2010, not 2008
(pre-analysis plan rules, decision 4); the grain is IJV x domain x year
(contingency scores, decision 4); the change score is the REG domain
(decisions 5 and 6); and coordination dependence enters H4 as a
directional prediction, not as a moderator (PI, 2026-11-25; see
"Decisions in chat during stage 5").

Main threats to address in the plan: the mobility channel acts on the same
outcome; the onset coincides with COVID-19 and follows four years of
anticipation; survivor bias; a single common onset; a thin local
parent-origin cell; the framing of Brexit as a change in the political order
between states.

### Route to gate 5 (decided by the PI on 2026-11-24)

The PI accepted all seven recommendations of
`docs/coauthor-notes/pre-analysis-plan-inputs-decision-sheet-2026-11-24.qmd`
("Accept all"). Recorded in `docs/decisions.md` (Decided, 2026-11-24).

1. Stage 5 goes ahead without G3, as a dated departure from `docs/workflow.md`.
2. `/lit-synthesis` runs now on the corpus approved at G1, and is re-run when
   the manual exports arrive.
3. The static scores (`coord_dependence`, `local_embeddedness`) come from
   O\*NET task measures linked through Revelio's `onet_code`. Scores from raters
   outside the team are the robustness check. Author-set scores are not used.
4. The Brexit change score is a binary list of regulatory-facing occupations,
   written into this plan before the panel is built. The O\*NET law and
   government score is the robustness check.
5. The domain variable is the occupation group. The panel unit is IJV x
   occupation group x year, with the nine functions as a robustness check.
6. The cell rule is at least 5 employees, with at least 5 hires as a
   sensitivity check.
7. The S13 design above is accepted as proposed.

### Pre-analysis plan rules (decided by the PI on 2026-11-25)

The PI accepted all ten recommendations of
`docs/coauthor-notes/pre-analysis-plan-rules-decision-sheet-2026-11-24.qmd`
("Accept all"). Recorded in `docs/decisions.md` (Decided, 2026-11-25).
Decisions 9 and 10 concern the literature and go to the protocol and the G2
re-run. The rest are carried into this plan:

1. O\*NET data step: the WRDS pull of `onet_code` and the public O\*NET
   download go ahead. The licensed pull runs after the PI confirms it once
   more. If fewer than 70% of positions carry a code, `role_k50` is mapped to
   O\*NET by title.
2. Labor market entrants: three-year window. One and five years are the
   robustness checks.
3. IJVs inside a parent's Revelio family (831): a person audits a random 100
   on names, ownership and location only. If more than 20 are parent units,
   the flagged IJVs leave the main sample and return as robustness.
   Otherwise they stay, and dropping them is the robustness check.
4. Main sample: hiring flows from 2010 on. The robustness checks are the
   cell's unmapped-employer share as a control, and the full period. Stocks
   are descriptive only.
5. Primary estimator for share outcomes: Poisson on the category count with
   the log of the cell denominator as offset. The fractional logit and the
   linear model are robustness checks. A wild cluster bootstrap is added
   wherever a test rests on fewer than about 50 clusters.
6. Static models are clustered two-way by IJV and occupation group, with
   IJV-only errors reported and the permutation test over occupation groups
   kept as a check. Shock models keep the S13 clustering by country pair,
   with a wild cluster bootstrap.
7. The level part of H1 stays exploratory: `mintzberg1979structuring` as
   the source of `coord_role`, clustered errors, the limitation stated, and
   no permutation test over levels. It is reported in a separate exploratory
   section.
8. S13 linked entity: settled at stage 5 from the public Home Office
   guidance. If the guidance is unclear, the mobility-channel term is
   estimated both ways (minority-held IJVs coded as linked, then as not
   linked).

O\*NET data step, done on 2026-11-25 (`data/data-log.md`): 96.6% of the JV
positions carry a position-level occupation code (O\*NET-SOC 2019), so the
70% rule is met. The 3.1% of positions no longer in Revelio's position table
take the code of their role through the role lookup (PI, 2026-11-25), with
the route recorded as `onet_source` and their exclusion as a robustness check.

### Contingency scores (decided by the PI on 2026-11-25)

The PI accepted all ten recommendations of
`docs/coauthor-notes/score-construction-decision-sheet-2026-11-25.qmd`
("Accept all"). Recorded in `docs/decisions.md` (Decided, 2026-11-25).

1. `local_embeddedness` combines three O\*NET elements: law and government
   (knowledge), communicating with people outside the organization
   (activity), and dealing with external customers or the public (context).
   `coord_dependence` combines coordinating the work and activities of others
   (activity), coordinating or leading others (context), and working with a
   work group or team (context). The broad sets are the robustness check.
2. Importance and context ratings are used. Each element is standardized
   across the rated occupations without weights; the elements are averaged
   and the average is standardized again. The level scale is an appendix
   check.
3. The 103 occupation codes without full O\*NET ratings (corrected from 102
   on 2026-11-25; one code is rated on only one score) take the mean of
   their SOC broad group,
   or of their minor group if the broad group has none, and are flagged
   `score_imputed`. Dropping them is the robustness check. The military
   codes (major group 55), which O\*NET does not rate at all, take the mean
   of all rated occupations (PI, 2026-11-25).
4. The domain is the SOC minor group, scored as the unweighted mean of its
   rated occupations. There are 98 domains: 97 minor groups plus `REG`,
   because minor group 23-2 lies wholly inside `REG` (corrected on
   2026-11-25 from "98 minor groups"). `role_k50` and the nine functions are the
   robustness checks.
5. H4 uses the 16 narrow O\*NET-SOC codes listed in `docs/decisions.md`. The
   broad list and the continuous law-and-government score are the
   robustness checks.
6. The listed occupations form a domain of their own, taken out of their
   minor groups.
7. The domain's mean job zone is a control in a planned robustness check.
8. Outside raters: three raters rate the 50 `role_k50` groups. Their ratings
   are used only if ICC(2,k) is at least 0.70.
9. The audit is coded by a co-author or research assistant, and the PI
   checks ten cases.
10. Stage 5 starts now. Gate 5 waits for the G2 re-run.

The scores are written by `code/R/07_contingency_scores.R` from O\*NET alone.

### Decisions in chat during stage 5 (2026-11-25)

Recorded in `docs/decisions.md` (Decided, 2026-11-25).

1. H4 is tested as a directional prediction. After 2021, in exposed IJVs
   relative to unexposed ones, the local share of new hires rises more in the
   `REG` domain than in other domains (H4a). Because `REG` scores low on
   coordination dependence, the rise is carried by independent local hires
   (H4b). The continuous moderation (shock x law-and-government importance x
   coordination dependence) is a secondary analysis. PI: "use the directional
   prediction for H4".
2. The origin window for prior positions is three years, with one and five
   years as robustness. PI: "use three years for the origin window".
3. The mobility-channel term uses Rule C (part C, section 2) as its
   contrast: an EU parent is control-linked if it holds more than 50 percent
   of the voting rights or controls the board (equity above 50 percent as the
   proxy; 50/50 not linked without board-control evidence). Rule L, under
   which every JV party is linked, is reported for completeness. PI: "use
   Rule C as the mobility-channel contrast".
4. The mobility-channel term (level x exposed x post, with the Rule C
   contrast) is a confirmatory test on the IJV x level x year panel. It joins
   the confirmatory family for the multiple-testing correction, its inference
   relies on country-pair clustering with a wild cluster bootstrap, and the
   seniority-to-level mapping must be fixed before the panel is built. The
   static level part of H1 stays exploratory. Part A5 must state that the
   seniority tables of 2026-11-23 were seen before this test was fixed. PI:
   "Make it confirmatory".
5. Seniority-to-level mapping: executive = Revelio seniority 6 to 7,
   middle management = 4 to 5, professional = 3, operational = 1 to 2.
   Robustness: executive = 7, middle management = 5 to 6, professional = 3
   to 4, operational = 1 to 2; and the seven codes as one linear term. Labels
   from the Revelio data dictionary (methodology, "Seniority"), which
   resolves the `[DATA]` marker on the labels in part A. PI: "Yes, mapping
   (a)".
6. Part A5 is kept as worded (dimensions of the 2026-11-23 tabulations
   named, no values) and extended to the mobility-channel test (A5, item 3).
   PI: "Yes, keep it".
7. Static inference for H1 to H3: the permutation p-value over domains is
   decisive; two-way and IJV-only clustered errors are reported (amends
   pre-analysis plan rules, decision 6, after the simulation in part B). PI:
   "Yes, permutation".
8. H4 feasibility count and fallback rule (rule fixed before the count;
   PI: "Yes, count with rule"). `code/R/08_feasibility_reg_cells.R` counted
   structural quantities only (no origin, no hires, no before-after
   magnitudes; `data/interim/feasibility-reg-cells-2026-11-25.md`):

   | List | Period | Exposed IJVs | Exposed pairs | Control IJVs | Control pairs |
   |---|---|---|---|---|---|
   | narrow | 2013-2015 | 16 | 8 | 156 | 88 |
   | narrow | 2021 on | 50 | 18 | 363 | 154 |
   | narrow | both periods | 14 | 8 | 139 | 79 |
   | broad | 2013-2015 | 40 | 16 | 361 | 161 |
   | broad | 2021 on | 120 | 22 | 873 | 276 |
   | broad | both periods | 38 | 16 | 328 | 151 |

   With 8 exposed pairs (fewer than 10) for the narrow list and 16 for the
   broad list, the rule makes the broad regulatory list the confirmatory H4
   measure. Amendment to parts A and B: wherever H4a, H4b, the H4 event study
   or the H4 decision rules name `REG` or the narrow list, the confirmatory
   measure is the broad-list domain (`REG_B`: the 22 broad-list codes, carved
   out of their minor groups in the H4 models); the narrow list and the
   continuous law-and-government importance are robustness. The static
   domains of H1 to H3 keep the narrow `REG` domain. Rule C counts
   (ownership only): of 168 UK-hosted exposed IJVs with an EU, EEA or Swiss
   parent, 59 have a largest stake above 50 percent (control-linked), 17
   exactly 50 and 92 below 50; 226 exposed IJVs are EU-hosted with a UK
   parent, to which the UK rule does not apply. Controls: 3,409 IJVs in 528
   pairs; 912 have no foreign direct parent (owner-level IJVs; 104 of them
   are dropped from the controls, item 14).
9. Pre-trend rule for H4a: one pooled 2010 to 2012 lead, p-value from the
   cluster score bootstrap by dyad, fail if p < 0.10; the separate leads,
   the Wald test and the linear slope are reported only; `HonestDiD`
   sensitivity is a reported robustness check once installed. To be
   simulated before approval. PI: "Yes, pooled lead".
10. Mobility test, part (c): the Rule C gradient is a two-sided secondary
    result; the confirmatory mobility test is parts (a) and (b) with
    p = max(p_a, p_b). The earlier one-sided direction had been relayed by
    the orchestrator, not set by the PI. PI: "Two-sided".
11. The confirmatory mobility test is labeled C1, a competing-channel test,
    not H5; it stays confirmatory and in the Holm family. PI: "Yes, C1".
12. The six smaller proposed choices of part B are accepted: H2 on all of
    `core_main`; the new variable names, plus `reg_b` for the broad list;
    the lead-pooling display rule (fewer than 25 exposed regulatory cells in
    any of 2010 to 2012); the 5 percent small-effect reading; the Holm family
    of six (H1, H2, H3, H4a, H4b test (i), C1); and `dyad` as host plus the
    largest-equity foreign parent. Wherever part B marks these as
    "proposed", they are now decided. PI: "Accept all six".
13. Causal language for H4a needs the pooled pre-test to pass and the
    `HonestDiD` relative-magnitude bound (M-bar = 1) to exclude zero; the
    trend-adjusted estimate is reported beside H4a; the bound decides the
    wording, not the classification. `HonestDiD` installed with the PI's
    approval. PI: "Yes, add the bound".
14. S13 control group: the 912 controls without a foreign direct parent
    are owner-level IJVs (route `orbis_owner_level`), not domestic joint
    ventures. The 104 with a UK-set link through their ultimate owner are
    dropped from the control group; the other 808 stay. Owner-level IJVs
    take their `dyad` from the host and the country of the largest-equity
    foreign ultimate owner. Robustness: all owner-level IJVs dropped from the
    S13 models. Exposure stays on direct parent-host pairs. PI: "Yes, drop
    the 104".
15. Audit and rater procedures: a research assistant codes the audit (to
    be named); only `parent_own_unit` counts toward the 20-of-100 rule, and
    more than 20 `cannot_tell` cases are recoded by the PI first; two coding
    cues accepted; coded copy returned in the project Dropbox. Raters: O\*NET
    scores aggregated to `role_k50` weighted by taxonomy entries, compared by
    Spearman correlation; blanks filled before the ICC; no second round below
    0.70; ratings stored gitignored. The PI asks WRDS or Revelio about sharing
    the group labels; otherwise the O\*NET-only workbook is used. PI: answers
    of 2026-11-25.
16. Registration: no outside registry. After approval the plan is fixed by
    an annotated Git tag `pap-v1.0` on the `main` commit that carries the
    approved gate file, pushed to GitHub, with its hash recorded in
    `docs/decisions.md` and the gate 6 file; amendments get new tags, and no
    `pap-*` tag is moved or deleted. PI: "GitHub tag only".
17. S06 is retired as the fallback shock. S13 is the only confirmatory
    shock and is not replaced, whatever the panel build, the pre-trend
    test or the results show; a failed pre-trend test falls under the
    pre-trend rule and thin cells under the H4 fallback measures. S06 may
    return only as a separate analysis labeled exploratory. PI: "Yes,
    retire S06".
18. Resource-dependence check (robustness 19) defined: parent industry from
    Orbis NAICS 2017 (ultimate owner for holding parents); BLS OEWS
    industry-by-occupation matrix, NAICS 4-digit, one fixed vintage; a
    domain is core for a parent if its employment share in the parent's
    industry is at least twice its share across all industries; any parent
    for H1, the host-country parent for H3; the coordination reading holds
    if the score keeps its sign and at least half its size. The PI's
    acceptance is the go-ahead for the industry-code pull. PI: "Accept
    all".
19. Coverage of the resource-dependence check maximized (rule v2): own
    primary, core and secondary Orbis codes, then the ultimate owner's, then
    the Capital IQ industry tree through SIC to NAICS 2017 for Capital IQ
    parents; holdings include NACE 70.1; available-case `rd_core` primary for
    H1, complete-case beside it; OEWS match by 4-digit, combined, then
    3-digit industry. 76.0 percent of parents and 93.5 percent of IJVs (at
    least one parent) are covered. PI: "Pull Capital IQ too", "try to
    maximise the saample".
20. PI updates: the audit is coded by Arne Floh (PI), so the PI's ten-case
    check falls away (who checks instead is open); the licence for sharing
    the `role_k50` labels is confirmed, so the full rater workbook is used;
    three raters are recruited; the four must-read full texts are read,
    which unblocks the G2 re-run (none tests H3 or contingency fit in a
    two-parent unit: "None did"); the available-case `rd_core` is confirmed
    as primary for H1. PI: "Audit: Arne Floh, Licence confirmed, full
    texts read, H1 confirmed, 3 raters recruited."
21. Gate approval: the PI approves all decisions of gate 5. This confirms
    the two departures from the accepted gap-statement wording
    ("multinational subsidiaries" for `li2024origin`; the IJV-control works
    `barden2005influence` and `han2019management` in place of the unsourced
    "alliance-level performance"), accepts the nine proposed changes to
    `docs/research-brief.md` (gate 2 file, P1 to P9, applied the same day),
    and approves this plan. PI: "approve all decision of gate 5".

### Items this plan still has to settle

Listed in the Open section of `docs/decisions.md`:
- the audit of the 831 flagged IJVs, coded by the PI (before the panel is built);
- the ratings of the three recruited outside raters (before the panel is built);
- `[CITE]` markers for the O\*NET-based scores (targeted S10 search at the G2 re-run);
- the G2 re-run: done on 2026-11-25 (gap statement narrowed, research-brief
  changes accepted and applied).

## Part A: Hypotheses and measurement

Drafted on 2026-11-25 by a stage 5 agent from the files listed in "Inputs" below and merged by the orchestrator the same day. Independence: no file in `data/interim/staffing-tabulations-*` and no table
of staffing counts by function, occupation, level or exposure was opened. No
staffing pattern is used below to motivate a hypothesis or a direction.
Pooled counts are cited with file and section.

Inputs read: `CLAUDE.md`; `docs/theory-framework.md`; `docs/research-brief.md`;
`literature/synthesis/theory-outline.md` and `gap-statement.md`;
`literature/search/ebsco-novelty-check-2026-11-24.md`;
`literature/shock-scan/rescoring.md` (sections 1 to 4.1 and 9); this file;
`docs/decisions.md`; `data/codebook.md`; `reviews/gate-4-pilot.md` ("Staffing
tabulations" and "Data quality flags", for definitions and pooled rates
only); `data/interim/contingency-scores-v1-2026-11-25.md` and the domain
score table (O\*NET only); `code/R/functions/measures.R`;
`code/R/07_contingency_scores.R`.

### A1. Hypotheses

#### A1.0 Numbering: H1 to H4, no H5

The stage skill (`.claude/skills/research-workflow/SKILL.md`, line 57) and
three agent files (`quant-analyst.md`, `shock-evaluator.md`,
`literature-synthesizer.md`) still ask for "H1 to H5", which refers to the
original research idea. Since gate 4, decision 1 (`docs/decisions.md`,
2026-11-24) the working set is H1 to H4 of `docs/research-brief.md`, and
gate 5 fixes the final set. The plan therefore states four hypotheses and
no H5. The content of the original H5 (coordinating levels keep
cross-partner integration after political deterioration) is not carried:
cross-partner integration is no longer an outcome (gate 4, decision 1), the
static level claim is folded into H1 (brief, Appendix D), and its level part
is exploratory (pre-analysis plan rules, decision 7). The level x exposure x
post term of the S13 design is a control for the mobility channel, not a
test of the original H5, and is reported as such. Edits to the skill and
agent files are proposed in A6.

Rule for every hypothesis: the contingency is stated first, then the
staffing category and the direction, then the instantiation. Static
hypotheses (H1 to H3) are associational claims about differences across
domains within the same IJV-year. Causal language is reserved for H4 and
applies only if the event-study pre-trends are flat (`CLAUDE.md`, rule 4).

#### A1.1 H1 (organizational origin)

**Contingency-level statement.** The more an organizational domain depends
on coordination with the parents' activities and on parent-specific
knowledge (the task and coordination contingencies), the larger the share
of parent-origin hires, local and international together, among its hires
with an observed prior position, relative to independent hires.

Mechanism (domain-level assumption, gate 2 decision 6, `docs/decisions.md`
2026-11-24): a domain whose work is interdependent with the parents'
activities needs the parents' routines and parent-specific knowledge to
coordinate at acceptable cost (`lawrence1967organization`,
`thompson1967organizations`). A hire from a parent's group brings both,
whereas a market hire has to acquire them after entry
(`edstrom1977transfer`, `harzing2001bears`, `harzing2016bridging`). The step
is stated for the domain's requirement, not for the individual hire; no
microfoundation is added (`docs/theory-framework.md`).

**Instantiation, domain grain (confirmatory).** Domains are the 97 SOC
minor groups that remain after the carve-out plus the domain `REG`, 98
domains in all (`data/codebook.md`, "Contingency scores";
`data/interim/contingency-scores-v1-2026-11-25.md`). Within the same
IJV-year, the rate of parent-origin hires among hires with an observed
prior position increases with the domain's `coord_dependence` (narrow O\*NET
set: 4.A.4.b.1, 4.C.1.b.1.g, 4.C.1.b.1.e). Test coefficient: the
`coord_dependence` slope, predicted positive. Sample: IJVs with at least one
parent in Revelio (gate 4, decision 8a).

Measurement caveat to be stated with the result: O\*NET measures how much an
occupation coordinates the work of others in general, not dependence on the
IJV's parents. The gap between generic and parent-specific coordination is
a stated limitation, and the parent-specific part is carried by H3's
boundary test (gate 2, decisions 1 to 4, `docs/decisions.md` 2026-11-24).

**Instantiation, level grain (exploratory).** Within the same IJV-year, the
rate of parent-origin hires among observed-history hires is higher at
levels with `coord_role` = 1 than at levels with `coord_role` = 0, with
`coord_role` taken from `mintzberg1979structuring` (gate 2, decision 10;
pre-analysis plan rules, decision 7). Reported in a separate exploratory
section, with clustered errors, no permutation test over levels, and the
limitation stated. It is exploratory for two reasons: the source of
`coord_role` is a classification, not a measured contingency, and the
staffing tabulations of 2026-11-23 reported parent-origin shares by Revelio
seniority level before this plan was written (A5). The mapping of Revelio
seniority codes 1 to 7 to the four project levels is still open
`[DATA: Revelio's documented labels for seniority 1 to 7, and the mapping to executive, middle management, professional and operational]`.

#### A1.2 H2 (geographic origin)

**Contingency-level statement.** The more an organizational domain depends
on host-country institutions, labor markets, customers and regulators (the
environmental contingency), the larger the share of locally recruited
hires, parent-origin and independent together, among its hires whose prior
position has a recorded country, relative to international hires.

Mechanism: host-dependent work needs host-specific knowledge and acceptance
by local stakeholders (`meyer2014local`, `henisz2000institutional`), which
locally recruited staff hold. At the level of the unit, greater home-host
distance raises parent-country staffing (`gaur2007institutional`,
`gong2003subsidiary`); H2 is a claim about differences between domains
inside one IJV-year, which IJV x year fixed effects separate from that
unit-level pattern. H2 uses one dimension only and is kept because H3 is
defined on its outcome.

**Instantiation (confirmatory).** Within the same IJV-year, the rate of
local hires among geographically classified hires increases with the
domain's `local_embeddedness` (narrow O\*NET set: 2.C.8.b, 4.A.4.a.3,
4.C.1.b.1.f). Test coefficient: the `local_embeddedness` slope, predicted
positive. Sample: all of `core_main`, because the geographic axis does not
need a parent in Revelio.

#### A1.3 H3 (channel of localization; anchor)

**Contingency-level statement.** Among locally recruited hires, the share
with a prior position in a host-country unit of a parent's group increases
with the domain's coordination dependence. Localization runs through the
parents' host-country workforce where coordination dependence is high and
through the open host labor market where it is low. Boundary condition:
the relationship is weaker or absent in IJVs without a host-country parent.

Mechanism (wording accepted on 2026-11-25, pre-analysis plan rules,
decision 10): a domain that is locally embedded and also depends on
coordination with the parents needs hires who bring host-specific and
parent-specific knowledge. In an IJV with a host-country parent, the
parents' host-country workforce, above all the host-country parent's own,
is the largest and cheapest pool of such hires, though not the only one
(staff who combine intra-firm and local knowledge are also found among
former inpatriates and self-initiated expatriates in units with one parent;
`georgopoulos2024mediating`). Where coordination dependence is low, the second
kind of knowledge is not needed and the open market offers more candidates
at lower cost `[CITE: recruitment source choice, internal versus external labor markets]`.
The contribution therefore rests on the channel through a second
organizational source and on the within-IJV domain slope, not on the
knowledge-combination step (`ebsco-novelty-check-2026-11-24.md`, verdict a;
`gap-statement.md`, revision of 2026-11-25).

**Instantiation (confirmatory).** In IJVs with a host-country parent and
at least one parent in Revelio, within the same IJV-year, the rate of local
parent-origin hires among local hires increases with the domain's
`coord_dependence`. Test coefficient: the `coord_dependence` slope,
predicted positive. Boundary test: in the pooled sample of IJVs with at
least one parent in Revelio, the interaction of `coord_dependence` with an
indicator for having no host-country parent is negative. Local
parent-origin means the host-country units of any parent's group, with the
host-country parent's group alone as robustness (gate 4, decision 8b),
which keeps the boundary test from being zero by construction. The
boundary test rests on few clusters and gets a wild cluster bootstrap
(pre-analysis plan rules, decision 5). Pooled feasibility counts: 860 of
the 7,460 IJVs have no host-country parent, and 67 of them have five or
more local parent-origin hires over the whole window
(`reviews/gate-4-pilot.md`, "Staffing tabulations").
`[CITE: IJVs formed by two foreign parents]` stays open for the boundary
argument.

#### A1.4 H4 (dynamic form of H3)

**Contingency-level statement.** When a change in the environment raises
the local-embeddedness requirement of some domains and leaves their
coordination dependence unchanged, the share of locally recruited hires in
new hiring rises more in those domains than in others, in exposed IJVs
relative to unexposed IJVs, and the rise consists of local parent-origin
hires where coordination dependence is high and of independent local hires
where it is low.

Mechanism: the change alters one contingency, which creates misfit on the
geographic axis; the organization regains fit at the margin, in new
hiring, on that axis (`donaldson1987strategy`, `donaldson2001contingency`),
while the organizational axis stays where coordination dependence placed
it. The prediction concerns the direction of shifts in hiring shares, not a
single fitting configuration, because the parents' strategic choice limits
determinism (`child1972organizational`).
`[CITE: hiring flows as the adjustment margin of workforce composition]`.

**Instantiation for S13 (Brexit, end of the UK-EU transition period).**
Focal shock decided by the PI on 2026-11-24 (`docs/decisions.md`;
`reviews/gate-5-pre-analysis-plan.md`, "Focal shock"). From 1 January 2021,
UK and EU regulation, customs, product approval and tax administration
diverged `[CITE: UK-EU regulatory divergence after 31 December 2020]`. In an
IJV whose host and a parent form a UK-EU, EEA or Switzerland pair, the
regulatory-facing occupations (domain `REG`, 16 narrow O\*NET-SOC codes,
`docs/decisions.md` 2026-11-25) now need knowledge of the host jurisdiction
that staff from the other jurisdiction lack
`[CITE: jurisdiction-specific human capital in legal and compliance work]`.
Their coordination dependence on the parents is assumed unchanged, because
the parents' activities and the IJV's tasks are unchanged; this is an
assumption of the design (`theory-outline.md`, C1 step 3).

H4a (geographic part, confirmatory). In exposed IJVs relative to control
IJVs, the rate of local hires among geographically classified hires rises
from 2021 on more in `REG` than in the other domains. Test term: exposed x
post x `REG`, predicted positive; causal reading only if the event-study
coefficients for 2013 to 2015 are jointly flat, with 2016 to 2020 reported
as the anticipation window.

H4b (channel part, confirmatory as stated here). The `REG` domain's
`coord_dependence` is -0.47, below the median of the 98 domains (22 domains
score lower; computed from
`data/processed/contingency-scores-domain-v1-2026-11-25.csv`, O\*NET only).
The contingency-level H4 therefore predicts that the rise in local hiring
in `REG` consists mainly of independent local hires: the exposed x post x
`REG` term is positive for independent local hires (offset: geographically
classified hires) and not positive for local parent-origin hires among
local hires. The moderation form of H4b (the channel tilts toward
local parent-origin hires as coordination dependence rises) is not
identified at the primary grain, because `REG` is one domain with one
`coord_dependence` value. It is estimated in the continuous robustness
specification, where the change score is `law_gov_importance` and varies
across all domains: exposed x post x `law_gov_importance` x
`coord_dependence`, predicted positive for local parent-origin hires among
local hires. See A7, item 1, for the decision this requires.

Competing pattern (mobility channel, not a hypothesis). The same date ended
free movement between the UK and the EU (`shrestha2026end`), which raises
the cost of hiring from abroad in every domain. It predicts a fall in
international hiring in all domains, steeper at junior levels, and no
specific rise in `REG`. IJV x year fixed effects absorb its uniform part;
the level x exposed x post term and the GB-IE contrast address the rest
(A2.6).

#### A1.5 Wording changes against `docs/research-brief.md`

| # | Brief (2026-11-22) | This plan | Reason | Source |
|---|---|---|---|---|
| 1 | "function or hierarchical level" (H1); "function" (H2, H3) | "organizational domain", instantiated as SOC minor groups plus `REG`; the nine functions and `role_k50` are robustness grains | Domain variable is the occupation group | `docs/decisions.md` 2026-11-24 (route to gate 5, decision 5); 2026-11-25 (scores, decisions 4 and 6) |
| 2 | H1 covers levels on equal terms | Level part of H1 marked exploratory, `coord_role` from `mintzberg1979structuring` | No measured contingency for levels; seniority distributions seen | gate 2 decision 10; pre-analysis plan rules decision 7 |
| 3 | Scores "from the interview recoding (gate 3)" | Scores from O\*NET task measures, fixed before any panel | Qualitative study set aside; author scores excluded | `docs/decisions.md` 2026-11-23, 2026-11-24 (route decisions 3 and 4), 2026-11-25 |
| 4 | H1 mechanism (already revised at gate 2) | Kept as a domain-level assumption; instantiation adds that O\*NET measures generic, not parent-specific, coordination | Gate 2 limitation, H3 boundary carries the parent-specific part | gate 2 decisions 1 to 4 and 6 |
| 5 | H2 "share of locally recruited hires" | "among hires whose prior position has a recorded country" | Denominator made explicit; location not recorded excluded | this plan (A3), from the codebook categories |
| 6 | H3 "prior employment in a parent's group" | "a prior position in a host-country unit of a parent's group" (any parent; host-country parent's group as robustness) | Definition of local parent-origin decided | gate 4 decision 8b |
| 7 | H3 mechanism "Only a hire from a parent's host-country workforce brings both" | "the parents' host-country workforce, above all the host-country parent's own, is the largest and cheapest pool of such hires, though not the only one" | Novelty check: the knowledge-combination step has a one-parent analog | pre-analysis plan rules decision 10; `ebsco-novelty-check-2026-11-24.md`, verdict a |
| 8 | H4 at contingency level only; "No shock is named" | Adds "and leaves their coordination dependence unchanged" and "in exposed IJVs relative to unexposed IJVs"; instantiated for S13 as H4a and H4b | Shock fixed; the condition was implicit in the mechanism | `docs/decisions.md` 2026-11-24 (focal shock) |
| 9 | Measures "for the stock ... and for the hiring flow" | Hiring flows from 2010 for all tests; stocks descriptive | Early profiles are thinner and unmapped employers count as independent | pre-analysis plan rules decision 4 |
| 10 | Strategic subset as main sample for parent-origin hypotheses (Proposed Design) | `core_main` with at least one parent in Revelio; strategic subset as robustness | Gate 4 sample decisions | gate 4 decisions 6 and 8a |

### A2. Construct definitions and data sources

#### A2.1 Hire, prior position and origin window

| Construct | Definition | Source |
|---|---|---|
| Hire | A person's first dated position at the matched JV entity, for people with at least one 30 June at the JV; the hire year is that position's start year and its domain is that position's occupation | Revelio positions, matched dataset v3 (`data/codebook.md`, "Staffing tabulations") |
| Prior position | A position at another Revelio company (`rcid`) that started before the hire date and was ongoing or ended within `origin_window` years before it; an ongoing parent position counts (secondment) | Revelio career histories |
| `origin_window` | Three years, as in the tabulations; this plan proposes it as the primary rule for prior positions, with one and five years as robustness (A7, item 4) | `data/codebook.md`; pre-analysis plan rules, decision 2 (entrant window) |

#### A2.2 Staffing frame

Every hire is classified on two axes from the prior positions in the
window.

| | Prior position in a parent's group | Prior positions outside every parent's group |
|---|---|---|
| Prior position in the host country | Local parent-origin (`n_local_parent`) | Independent local (`n_local_indep`) |
| Prior position abroad | International parent-origin (`n_intl_parent`) | Independent international (`n_intl_indep`) |
| Country not recorded | Parent-origin, location not recorded (`n_parent_na`) | Independent, location not recorded (`n_indep_na`) |

Rules:

1. Parent-origin: any prior position in the window at an entity of a
   parent's Revelio family; the most recent such position gives the
   location and the parent. Independent: at least one prior position in the
   window and none in a parent family; the most recent gives the location.
   Prior employers not mapped to a Revelio company count as independent
   (14.2% of hires, `reviews/gate-4-pilot.md`, "Staffing tabulations",
   Q3); the cell's unmapped share is a robustness control (pre-analysis
   plan rules, decision 4).
2. Parent family: the Revelio entities matched to the direct parent and to
   its Orbis GUO (50 percent definition), extended to their whole Revelio
   family through `ultimate_parent_rcid`. GUOs that are states or
   government bodies do not define families. An entity in two parents'
   families goes to the parent with the larger equity share (216 IJVs have
   such entities, `reviews/gate-4-pilot.md`, "Data quality flags"). The
   JV's own matched entity is never a parent employer. Source: Orbis
   ownership and Revelio company mapping (`data/codebook.md`, "Sample frame
   from Orbis ownership").
3. Local parent-origin: a parent-origin hire whose most recent parent-family
   prior position is in the IJV's host country, at a unit of any parent's
   group (31,121 hires, gate 4 decision 8b). Robustness: the host-country
   parent's group only (23,190 hires). Both counts from
   `reviews/gate-4-pilot.md`, "Staffing tabulations".
4. Local and international: the country of the prior position (Revelio
   country names to ISO 2) against the IJV's host country. This is the
   location of the prior job, not nationality.
5. History not observed: no prior position in the window. It is split into
   labor market entrants (`n_entrant`: the JV is the first recorded job and
   the last education that ended by the year after joining ended at most
   three years before the hire year; one and five years as robustness,
   pre-analysis plan rules decision 2) and history unknown (`n_unknown`, all
   others). Entrants are split by place of education (host, abroad, not
   recorded). Entrants are a category of their own; counting them as
   independent local or international hires by place of education is a
   robustness check (gate 4, decision 8c). Source: Revelio education records
   of 2026-11-23 (`data/raw/revelio-education-full-2026-11-23/`).

Pooled shares for orientation (all from `reviews/gate-4-pilot.md`,
"Staffing tabulations"): 30.1% of hires have no observed history; after
entrants are separated, 17.6% of hires stay unknown (9.6% in 2020 to 2026).
Entrant counts: 467,895 (three-year window), 387,121 (one year), 502,142
(five years).

#### A2.3 Host-country parent

A parent whose direct shareholder country equals the IJV's host country
(`host_parent`); the Orbis GUO country is the robustness basis for
Orbis-sourced IJVs (gate 4, decisions 2 and 3). 6,600 of the 7,460 IJVs have
one and 860 do not; in 3,728 of the 6,600 the host-country parent itself has
a Revelio entity (`reviews/gate-4-pilot.md`, "Staffing tabulations", Q1).

#### A2.4 Domain and contingency scores

| Variable | Definition | Source |
|---|---|---|
| `domain` | SOC minor group of the position's O\*NET-SOC 2019 code, except the 16 narrow regulatory-facing codes, which form `REG`; 98 domains (97 minor groups plus `REG`; minor group 23-2 is entirely inside `REG`) | Revelio `onet_code` (position level, 96.6% of JV positions; lookup through `role_k17000_v3` for the 3.1% no longer in the position table, recorded as `onet_source`); `code/R/07_contingency_scores.R` |
| `local_embeddedness` | Mean of three standardized O\*NET elements (2.C.8.b importance; 4.A.4.a.3 importance; 4.C.1.b.1.f context), standardized again across rated occupations; domain value is the unweighted mean of its rated occupations | O\*NET 31.0 Database (CC BY 4.0), `data/codebook.md`, "Contingency scores" |
| `coord_dependence` | The same for 4.A.4.b.1 (importance), 4.C.1.b.1.g (context), 4.C.1.b.1.e (context) | as above |
| `*_broad`, `*_lv` | Broad element sets (robustness) and level scale (appendix check) | as above |
| `score_imputed` | Occupation not rated on all elements; scores from the SOC broad group, else minor group, else (military, major group 55) the overall mean | as above; PI decisions of 2026-11-25 |
| `REG` | Indicator for the regulatory-facing domain (16 codes, `docs/decisions.md` 2026-11-25); broad list and continuous `law_gov_importance` as robustness | as above |
| `job_zone` | Domain mean O\*NET job zone; skill-level control in a planned robustness check only | as above |
| `coord_role` | Level indicator for responsibility for coordination across the alliance, from `mintzberg1979structuring`; exploratory | gate 2, decision 10 |

The scores are fixed from O\*NET alone, before any panel exists
(`code/R/07_contingency_scores.R` reads no staffing data). Alpha 0.76 and
0.81 for the narrow sets, correlation 0.37 across occupations and 0.40
across domains (`data/interim/contingency-scores-v1-2026-11-25.md`).
O\*NET's content model is documented in
`nationalcenterforonetdevelopmentonet` and assessed in `handel2016onet`;
its development in `peterson1999occupational`; the data are the O\*NET 31.0
Database (`nationalcenterforonetdevelopment2026onet`, CC BY 4.0, credited to
USDOL/ETA). O\*NET measures of within-firm communication, customer contact and
interdependence have been used to explain how firms organize activities and
how occupations differ in interdependence (`oldenski2012export`;
`dierdorff2008its`; which elements they use is to be checked in the full
texts). US job information carries over to other countries with small to
moderate differences for generalized work activities
(`taylor2008transportability`), but task content within an occupation differs
markedly across countries, above all in poorer ones (`lewandowski2022technology`;
`caunedo2023technology`), so US ratings applied to IJVs mostly outside the US
are a stated limitation; no validation outside the US of the work-context
items used here was found (`literature/search/s10-onet-targeted-2026-11-25.md`).
Convergent-validity checks: outside raters on the 50 `role_k50` groups
(ICC(2,k) of at least 0.70 for use) and the function ordering of
`kim2003global` (gate 2, decision 4). Rival-account check: whether a
parent's industry matches the occupation group (`pfeffer1978external`,
`choi2004split`; gate 2, decision 3).

#### A2.5 Shock variables (S13)

| Variable | Definition | Source |
|---|---|---|
| `exposed` | 1 for a UK-hosted IJV with a parent (direct shareholder country) from the EU27, Iceland, Liechtenstein, Norway or Switzerland, or an IJV hosted in one of those countries with a UK parent; ultimate-owner country as robustness for Orbis-sourced IJVs | Orbis and Capital IQ ownership; `code/R/06_shock_exposure.R`; `rescoring.md`, 4.1 |
| Controls | Never-treated IJVs hosted in the UK or in the EU27, EEA or Switzerland without a UK-set parent-host link. IJVs hosted in third countries whose parents form a UK-set pair (19) are in neither group | `rescoring.md`, 4.1 |
| `post` | 1 from 2021 (end of the transition period on 31 December 2020) | `rescoring.md`, 4.1 and 8 |
| `antic` | 1 for 2016 to 2020 (referendum to end of transition), reported as the anticipation window; 2013 to 2015 is the clean pre-period | `docs/decisions.md`, 2026-11-24 (route to gate 5, decisions 6 and 7) |
| `event_time` | year minus 2021; missing for controls | as above |
| `pair` | Host-parent country pair, the unit of exposure and of clustering | `rescoring.md`, 4.1 and 9 |
| `gb_ie` | 1 for exposed IJVs on the pair {GB, IE} (31 IJVs). Irish and UK citizens keep Common Travel Area rights (`cabinetoffice2026common`), so these IJVs receive the regulatory change without the end of free movement for those citizens | `rescoring.md`, 4.1 |
| `linked` | Whether the IJV counts as linked to its parents for the UK intra-company (now Global Business Mobility) routes. The Immigration Rules define the sponsor group to include a business linked "by a joint venture on which the applicant is sponsored to work" (`homeoffice2020statement`), and the sponsor guidance lists an entity formed by a joint venture agreement as linked to a party to that agreement, with no ownership threshold (`homeoffice2026workers`; reading in `literature/zotero/verification-2026-11-24-s5-s6.md`). Primary coding: every UK-hosted exposed IJV is linked, minority-held ones included. Because the guidance version in force at the 2021 onset was not obtained and the EU member-state rules for EU-hosted IJVs were not checked, the mobility-channel term is also estimated with minority-held IJVs coded as not linked (pre-analysis plan rules, decision 8). The confirmatory H4 test does not depend on this coding | as cited |

Counts in `core_main` (`rescoring.md`, 4.1; `reviews/gate-5-pre-analysis-plan.md`,
"Focal shock"): 28 exposed pairs; 394 exposed IJVs, 311 with a parent in
Revelio, 230 with a parent in Revelio and a host-country parent; 136 (hires
rule) to 231 (employee rule) exposed IJVs with a parent in Revelio after
cell thresholds, in 23 to 24 pairs; 3,409 controls (2,510 with a parent in
Revelio; 1,273 at the hires rule).

#### A2.6 Mobility channel

The end of free movement acts on hires from abroad in every domain. Under
the primary `linked` coding the intra-company route stays open for
parent-to-IJV transfers into UK-hosted IJVs, so the channel should bear
mainly on independent international hires. Its measurement: the
international share of geographically classified hires
(`n_intl / n_geo`) and its two parts, in the IJV x level x year panel with
the level x exposed x post terms (salary floors make the restriction bite
more at junior levels, `homeoffice2020uks`), and the `gb_ie` contrast, in
which the mobility channel should be weaker while the `REG` effect of H4a
should be present. With 31 GB-IE IJVs the contrast is descriptive. A
caveat: `gb_ie` is defined on the pair, while Common Travel Area rights
attach to citizenship, and the frame observes the country of the prior
position, not nationality.

### A3. Outcomes per hypothesis

Unit: IJV i x domain d x year t (hiring flows), and IJV i x level l x year t
for the exploratory level part and the mobility-channel term. All counts
are hires in the cell-year. Variable names extend the draft panel columns
in `data/codebook.md` ("Draft panel columns for estimation"); new names are
marked (new).

Accounting identities per cell:

```
n_hires   = n_obs + n_not_obs
n_not_obs = n_entrant + n_unknown                                   (n_entrant, n_unknown new)
n_obs     = n_local_parent + n_intl_parent + n_parent_na
          + n_local_indep  + n_intl_indep  + n_indep_na             (n_parent_na, n_indep_na new)
n_parent  = n_local_parent + n_intl_parent + n_parent_na
n_indep   = n_local_indep  + n_intl_indep  + n_indep_na
n_local   = n_local_parent + n_local_indep
n_intl    = n_intl_parent  + n_intl_indep
n_geo     = n_local + n_intl  = n_obs - n_parent_na - n_indep_na    (new)
```

Primary estimator for every share outcome: Poisson on the numerator count
with log(denominator) as offset (pre-analysis plan rules, decision 5); the
fractional logit and the linear model on the share are robustness.

| Hyp. | Numerator | Denominator (offset) | Share | Test term, sign | Sample |
|---|---|---|---|---|---|
| H1 | `n_parent` | `n_obs` | `share_parent = n_parent / n_obs` | `coord_dependence`, + | at least one parent in Revelio |
| H1 level (expl.) | `n_parent` | `n_obs` | as above, level panel | `coord_role`, + | as H1 |
| H2 | `n_local` | `n_geo` | `share_local = n_local / n_geo` | `local_embeddedness`, + | `core_main` |
| H3 | `n_local_parent` | `n_local` | `share_parent_local = n_local_parent / n_local` | `coord_dependence`, + | host-country parent and at least one parent in Revelio |
| H3 boundary | `n_local_parent` | `n_local` | as above | `coord_dependence` x no host-country parent, minus | at least one parent in Revelio |
| H4a | `n_local` | `n_geo` | `share_local` | exposed x post x `REG`, + | S13 exposed and controls, at least one parent in Revelio |
| H4b | `n_local_indep` | `n_geo` | `n_local_indep / n_geo` | exposed x post x `REG`, + | as H4a |
| H4b | `n_local_parent` | `n_local` | `share_parent_local` | exposed x post x `REG`, not positive | as H4a |
| H4b moderation (robustness spec.) | `n_local_parent` | `n_local` | `share_parent_local` | exposed x post x `law_gov_importance` x `coord_dependence`, + | as H4a |
| Mobility (competing) | `n_intl`, `n_intl_indep`, `n_intl_parent` | `n_geo` | `n_intl / n_geo` and parts | level x exposed x post; `gb_ie` contrast | as H4a, level panel |

Both static scores enter every static model together, so each slope is net
of the other (the scores correlate 0.40 across domains). Domain fixed
effects cannot enter the static models, because the scores do not vary
within a domain; the H4 models carry IJV x year, IJV x domain and domain x
year effects as in the S13 design (`reviews/gate-5-pre-analysis-plan.md`).

**History not observed as an outcome.** `share_not_obs = n_not_obs /
n_hires`, with its parts `share_entrant = n_entrant / n_hires` and
`share_unknown = n_unknown / n_hires`. It is (1) reported per domain
descriptively; (2) estimated with the H1 to H4 right-hand sides as a
selection check: if missingness varies with the scores or with exposed x
post x `REG`, the share results are read with that in mind; and (3) the
basis of bounds that assign all unknown histories to each category in turn,
for example for H1 `n_parent / (n_obs + n_unknown)` (lower) and
`(n_parent + n_unknown) / (n_obs + n_unknown)` (upper). Entrants are not
used in the H1 bounds, because by definition they have no prior employer.

**What the denominators exclude, and why.**

1. Hires with history not observed (`n_not_obs`) are excluded from every
   share denominator. They have no prior employer, so they cannot be placed
   on the organizational axis, and treating them as independent would
   inflate independent hiring where profiles are thin (brief, risk table).
   Entrants enter the geographic denominators only in the robustness check
   that classifies them by place of education.
2. Hires whose prior position has no country (`n_parent_na`, `n_indep_na`)
   are excluded from the geographic denominator `n_geo` and kept in `n_obs`.
3. Hires that cannot be assigned to a domain (no usable `onet_code`; the
   values unknown, Retired and On Leave count as missing) are excluded;
   their count is reported.
4. Cells with a zero denominator drop out of that model. Because the
   Poisson estimator with IJV x year effects drops IJV-years in which the
   numerator is zero in every domain, the effective H3 sample is the set of
   IJV-years with at least one local parent-origin hire; its size is
   reported with the result.

### A4. Sample

1. Frame: `core_main` of frame v3 (7,460 IJVs, 2,172 strategic), the
   analysis sample since gate 4, decision 6; `core` (9,644) and the
   strategic subset are robustness samples. Usability threshold 20
   employees, with 10 and 30 as sensitivity checks.
2. Subsets: the organizational-origin hypotheses (H1, H3, H4) use IJVs with
   at least one parent in Revelio (5,882), with all parents in Revelio
   (2,321) as robustness (gate 4, decision 8a). H2 uses all of `core_main`.
   H3 uses IJVs with a host-country parent within that subset; its count is
   not in any file read here
   `[DATA: number of IJVs with a host-country parent and at least one parent in Revelio, counted at panel build]`.
   Robustness for H3: IJVs whose host-country parent itself has a Revelio
   entity (3,728 of the 6,600 IJVs with a host-country parent,
   `reviews/gate-4-pilot.md`, "Staffing tabulations", Q1). H4 uses the S13 exposed IJVs and
   controls (A2.5).
3. Period: hiring flows with hire years 2010 to 2025 (pre-analysis plan
   rules, decision 4). 2026 is left out because the Revelio data end in
   September 2026 (`rescoring.md`, section 3). The full period is a
   robustness check. Stocks are descriptive only.
4. Cell rule: an IJV x domain x year cell enters if it has at least 5
   employees on 30 June; at least 5 hires is the sensitivity check (route to
   gate 5, decision 6).
5. The 831 IJVs whose matched entity lies inside a parent's Revelio family
   (`reviews/gate-4-pilot.md`, "Data quality flags"): a person audits a
   random 100 on names, ownership and location only, with a script-drawn
   sample and fixed seed, before the panel is built. If more than 20 of the
   100 are parent units, the flagged IJVs leave the main sample and return
   as robustness; otherwise they stay and dropping them is the robustness
   check (pre-analysis plan rules, decision 3; score construction, decision
   9).
6. Imputed scores: positions in the occupation codes O\*NET does not rate
   keep their imputed scores in the main models and are dropped as a
   robustness check. The three military domains (55-1, 55-2, 55-3) carry
   the overall mean on every score and so add no score variation of their
   own. Positions coded through the role lookup (`onet_source` = lookup,
   156,484 positions) are dropped as a further robustness check
   (`docs/decisions.md`, 2026-11-25).
7. What the frame cannot contain, stated in the plan and in the paper: the
   frame holds only IJVs alive today with a multi-parent structure, so IJVs
   dissolved or bought out, including any that Brexit ended, are missing
   (survivor frame; `docs/decisions.md` 2026-10-08; for shocks shifting entry
   away from JVs see `lei2025playing`). The incorporation date stands in for
   formation (Capital IQ founding year, 1990 where missing), and 1,901 IJVs
   (25.5%) have a first position more than ten years before incorporation
   (`reviews/gate-4-pilot.md`, "Data quality flags"), so panels start
   mid-life. The current equity share stands in for the share at formation,
   and ownership changes are not observed. Seconded staff who keep the
   parent as employer of record are missing from the IJV in Revelio, which
   biases the parent-origin counts down, most where parent dependence is
   high and so against H1 and H3 (brief, risk table). The organizational
   axis is unobservable where no parent has a Revelio entity. Revelio covers
   only part of each IJV's staff, rising over time (median ratio to Orbis
   unconsolidated headcount 0.31 in 2015, 0.67 in 2024; `reviews/gate-4-pilot.md`,
   Q4); the ratio enters robustness checks only, from 2015 on (gate 4,
   decision 8d).

### A5. Independence and prior exposure

**Shock.** The focal shock was chosen from exposure counts, design
properties and literature evidence only. The rescoring counted exposed
pairs, IJVs, total hires and person-years, cells above threshold, onset
years and control group sizes; no hire was classified by origin and no
staffing category or share was computed by exposure status
(`docs/decisions.md`, Decided, 2026-11-24, focal shock row;
`literature/shock-scan/rescoring.md`, section 2). The staffing tabulations
of 2026-11-23 were never broken down by exposure group (`docs/decisions.md`,
2026-11-23).

**Scores.** `coord_dependence`, `local_embeddedness`, the domain grain and
the `REG` list were fixed from O\*NET alone and written by
`code/R/07_contingency_scores.R`, which reads no staffing data, before any
panel exists (`docs/decisions.md`, 2026-11-25). Author-set scores are not
used because the tabulations had been seen (route to gate 5, decision 3).

**Prior exposure.** The staffing tabulations of 2026-11-23 showed the PI
and the agents how the staffing categories are distributed over Revelio's
ten functions and seven seniority levels, and how local parent-origin hires
are distributed between IJVs with and without a host-country parent,
before the hypotheses were fixed (`docs/decisions.md`, Open, 2026-11-23;
`reviews/gate-4-pilot.md`, "Staffing tabulations", which reports local
parent-origin hires by function and parent-origin shares by seniority).

What this means for the confirmatory claim, stated plainly:

1. The directions of H1 to H4 were written in `docs/research-brief.md` on
   2026-11-22, the day before the tabulations ran, and are unchanged here
   except for the wording changes in A1.5, none of which reverses or adds a
   direction. To that extent the static predictions are not derived from
   the counts.
2. The measurement choices made after 2026-11-23 were made by people who
   had seen the tabulations: the choice of O\*NET as source, the narrow
   element sets, the occupation grain, the `REG` list, the any-parent
   definition of local parent-origin (chosen so that the H3 boundary test
   is not zero by construction, with the pooled split of 23,190 and 7,931
   hires known), the 2010 start and the cell rule. Each was argued from
   O\*NET properties, data quality or design, but none was made blind. The
   static tests are therefore confirmatory in direction and not blind in
   measurement.
3. The level part of H1 is the comparison that the seniority tables already
   showed, so it cannot be confirmatory and is reported as exploratory. The
   mobility-channel test (level x exposed x post, Rule C contrast), which
   the PI made confirmatory on 2026-11-25, also runs on the level panel. The
   seniority distributions were seen before it and the seniority-to-level
   mapping were fixed. Its direction comes from the S13 mechanism
   (`literature/shock-scan/rescoring.md`, section 9), not from the
   tabulations, which were never broken down by exposure; the mapping rests
   on Revelio's published labels, and a second mapping and a linear term are
   fixed as robustness.
4. Containment: (a) the primary grain (SOC minor groups and `REG`) was never
   tabulated against staffing categories, and Revelio's ten functions have
   no legal or compliance category (`rescoring.md`, section 9), so the
   staffing of the `REG` domain has not been seen; (b) every robustness
   variant named in this plan (broad sets, level scale, outside raters who
   have not seen the tabulations, `role_k50` and the nine functions, the
   host-country-parent-only definition, entrant windows, the 831 rule) is
   reported whatever its result; (c) the plan is fixed before the panel is
   built, and any later change is entered in `docs/decisions.md` with a
   date and reported as a departure; (d) the paper states the prior
   exposure in its method section.
5. The inferential weight of the paper rests on H4, whose outcome was
   never tabulated by exposure, and on the H3 boundary contrast. H1 and H2
   are reported as confirmatory tests with this caveat attached, in the
   spirit of the brief's risk table, which already proposes presenting them
   as patterns.

### A6. Proposed changes to earlier-stage files (proposals only; nothing edited)

1. `code/R/functions/measures.R`: `classify_origin()` returns the
   cross-partner categories of the original idea (`parent_a`, `parent_b`,
   `external_host`, `external_intl`, `no_history`), and `cell_measures()`
   computes `cross_parent_integration`, `parent_dominance` and
   `localization` on `n_emp`. Proposed: a classifier that returns the
   staffing-frame categories of A2.2 (`local_parent`, `intl_parent`,
   `parent_na`, `local_indep`, `intl_indep`, `indep_na`, `entrant` with place
   of education, `unknown`), with `origin_window`, the any-parent and
   host-country-parent-only rules and the parent label as arguments; a cell
   function that returns the counts and shares of A3 on hires; the
   cross-partner measures moved to a clearly labeled legacy section or
   removed (gate 4, decision 1); `within_ijv_dispersion()` keyed on
   `domain` instead of `function`.
2. `data/codebook.md`:
   (a) "Dependent variables": replace the cross-partner definitions with the
   counts, identities and shares of A3;
   (b) "Domain characteristics (from the qualitative memo, finalized at
   G5)": replace the 1-to-5 interview scores with a pointer to "Contingency
   scores" and add `coord_role` with its source;
   (c) "Identifiers": `function` becomes `domain` (SOC minor group or `REG`),
   the `level` mapping from Revelio seniority is added once decided, and
   parent A is defined by the current equity share, as in the matched
   dataset section (the Identifiers row still says "at formation" and
   "alphabetically");
   (d) "Shock": the S13 variables of A2.5 (as already proposed in the gate
   file);
   (e) "Draft panel columns": `fn` becomes `domain`; add `n_parent_na`,
   `n_indep_na`, `n_geo`, `n_entrant` (and its three places), `n_unknown`,
   `n_local_parent_hcp`, `share_entrant`, `share_unknown`, `onet_source`,
   `score_imputed`, `exposed`, `post`, `antic`, `pair`, `gb_ie`, `linked`;
   (f) "Revelio field assumptions": the Function row points to the domain
   built from `onet_code`.
3. `docs/research-brief.md`: the wording changes of A1.5, through the gate
   file at the G2 re-run as decided on 2026-11-25.
4. `.claude/skills/research-workflow/SKILL.md` (line 57),
   `.claude/agents/quant-analyst.md` (lines 18 and 36),
   `.claude/agents/shock-evaluator.md` (line 98) and
   `.claude/agents/literature-synthesizer.md` (lines 17 and 47): replace "H1
   to H5" and "H4, H5" by the working set H1 to H4, with a pointer to gate
   4, decision 1; and in the skill, scores "from O\*NET (decisions of
   2026-11-24 and 2026-11-25)" instead of "from the qualitative memo".
5. `docs/decisions.md`, Open: the item of 2026-11-23 still says the
   function scores are to be set from the interviews; propose noting that
   they come from O\*NET (2026-11-24, 2026-11-25) and that the plan records
   the prior exposure (A5). The G2 re-run item of 2026-11-24 still lists
   `[CITE: O*NET content model documentation]`, which
   `nationalcenterforonetdevelopmentonet` and `handel2016onet` in
   `references.bib` now cover.
6. `docs/decisions.md`, Decided 2026-11-25 (scores, decisions 1 to 4) and
   the gate file: "the SOC minor group (98)" and "102 unrated occupation
   codes" should read 98 domains (97 minor groups plus `REG`, because minor
   group 23-2 lies wholly in `REG`) and 103 codes, as the checks file
   reports (68 from the broad group, 18 from the minor group, 17 military).
7. `CLAUDE.md` (design paragraph, for the PI): the panel unit is IJV x
   occupation group x year, with functions as a robustness grain.
8. `code/R/tests/synthetic_panel.R`: simulate the domain grain and the new
   count columns, so that the estimation scripts are tested on the panel
   shape this plan defines.

### A7. Decisions this fragment needs from the PI

Status on 2026-11-25 (orchestrator): item 1 settled by the PI as option (a)
("use the directional prediction for H4"); item 2 settled by the
pre-analysis plan rules, decision 4 (flows from 2010, full period as
robustness); item 4 settled by the PI (three years). Items 3, 5 and 6 are
carried to "Decisions required from the PI".

1. H4b at the primary grain. With `REG` as one domain (score construction,
   decision 6), the moderation of the channel by `coord_dependence` that the
   S13 design names (route to gate 5, decision 7) is not identified.
   Options: (a) as drafted, the directional prediction for `REG` (rise
   carried by independent local hires, since `REG` scores low on
   coordination dependence) is confirmatory and the moderation form is
   tested only in the continuous `law_gov_importance` specification; (b)
   split `REG` by occupation-level `coord_dependence` (the 15 rated codes
   range widely), which departs from decision 6; (c) treat H4b as
   exploratory and keep only H4a confirmatory.
2. S13 window: the carried-in design says 2008 to 2025, the later sample
   rule says flows from 2010. This fragment uses 2010 to 2025 with the full
   period as robustness.
3. Mobility-channel term: the level x exposed x post term needs the level
   panel, which is exploratory for H1; confirm that it is estimated there
   as a competing-pattern check only.
4. `origin_window` for prior positions: still provisional since
   2026-11-23; this fragment proposes three years with one and five as
   robustness.
5. Seniority-to-level mapping for the exploratory level part.
6. Whether to keep A5's sentence that names the content of the seniority
   tables (by type, not by value) in the public plan.

## Part B: Estimation

Drafted on 2026-11-25 by the quant-analyst (method guide
`.claude/skills/statistical-analyst/SKILL.md`) and merged by the
orchestrator the same day. Choices the PI has made are cited to their
decision; choices the agent proposes are marked "proposed" and are not
binding until the PI accepts them. No model has been estimated on real
outcome data (`real_data_lock`; gate 6 is not approved). The simulated
recovery check is `data/synthetic/estimate-recovery-domain-synthetic-2026-11-25.md`
(code: `code/R/tests/check_recovery_domain.R`,
`code/R/functions/simulate_domain_panel.R`).

Label note: the confirmatory mobility-channel test is labeled C1, a
competing-channel test (PI, 2026-11-25), so that the theory's set stays H1 to
H4 and part A1.0's "no H5" holds; the quant-analyst's draft had proposed
"H5".

Disclosure required by the plan (skill, `preregistered`; `docs/decisions.md`,
Decided, 2026-11-25): the staffing tabulations of 2026-11-23 showed how the
staffing categories are distributed over Revelio's ten functions and seven
seniority levels before these hypotheses were fixed (part A5). They were not broken down by the
O\*NET domains, by the contingency scores or by shock exposure. The scores
were fixed from O\*NET alone (`code/R/07_contingency_scores.R`) so that no
author judgment informed by the tabulations enters the regressors (route to
gate 5, decision 3).

### 0. Common elements

#### 0.1 Panels

| Panel (proposed file name) | Unit | Use |
|---|---|---|
| `data/processed/panel-ijv-domain-year-v1.parquet` | IJV x domain x year | H1 (functions part), H2, H3, H4 (primary) |
| `data/processed/panel-ijv-level-year-v1.parquet` | IJV x level x year | H1 levels (exploratory); mobility channel of S13 |
| `data/processed/panel-ijv-function-year-v1.parquet` | IJV x function x year | grain robustness (nine functions) |

`domain` is the column name of the domain (never `function`, which breaks
`fixest` formulas; the function key in the robustness panel is `fn`). It takes
98 values: 97 SOC minor groups and `REG`, the 16 narrow regulatory-facing
O\*NET-SOC codes taken out of their minor groups (score construction,
decisions 4 to 6). Minor group 23-2 (legal support workers) lies wholly in
`REG` and so does not appear as a domain of its own. A position gets its domain from its `onet_code`
(`onet_source` = position, else lookup). `level` takes the values
`executive`, `middle_management`, `professional`, `operational`, mapped from
Revelio seniority 6-7, 4-5, 3 and 1-2 (PI, 2026-11-25).

#### 0.2 Sample (decided unless marked)

1. Frame: `core_main` (7,460 IJVs; gate 4, decision 6).
2. Hypotheses that use organizational origin (H1, H3, H4): IJVs with at least
   one parent that has a Revelio entity (5,882; gate 4, decision 8a). H2 uses
   all of `core_main` because local versus international origin does not need
   a parent entity (proposed; H2 is not an organizational-origin hypothesis).
3. The 831 IJVs flagged `flag_jv_in_parent_family`: if more than 20 of the 100
   audited are parent units, they leave the main sample; otherwise they stay
   (pre-analysis plan rules, decision 3). The audit result is recorded before
   any model is run.
4. Period: hiring flows with hire year 2010 to 2025 (pre-analysis plan
   rules, decision 4); the full period from formation is a robustness check
   (robustness 12). Stocks are descriptive only (same decision). The PI
   confirms the Revelio licence end date before stage 6 (gate 5a, decision 5).
5. Cell rule: a cell-year enters if it holds at least 5 employees on 30 June
   (`n_emp >= 5`, `const$min_cell_emp`; route to gate 5, decision 6). The
   Poisson models use cells with a positive denominator; cells with a zero
   denominator carry no information under the offset and their number is
   reported.

#### 0.3 Outcomes (hiring flow per cell-year)

Classification of each hire by the codebook rules (`data/codebook.md`,
"Staffing tabulations"), with the three-year origin window for prior
positions (`const$origin_window`; PI, 2026-11-25) and the three-year entrant
window (pre-analysis plan rules, decision 2):

| Variable | Definition |
|---|---|
| `n_hires` | hires in the cell-year |
| `n_obs` | hires with a prior position in the origin window |
| `n_local_parent`, `n_local_indep`, `n_intl_parent`, `n_intl_indep` | the four categories of the staffing frame among `n_obs`; local parent-origin is a prior position at a host-country unit of any parent's group (gate 4, decision 8b) |
| `n_local`, `n_intl`, `n_parent` | `n_local_parent + n_local_indep`; `n_intl_parent + n_intl_indep`; `n_local_parent + n_intl_parent` |
| `n_entrant`, `n_unknown` (proposed names) | history not observed, split into labor market entrants and unknown; `n_not_obs = n_entrant + n_unknown`; entrants are a category of their own (gate 4, decision 8c) |
| `n_emp` | employees in the cell on 30 June (cell rule only) |

Shares are defined only as estimands: share of parent-origin hires
`n_parent / n_obs` (H1), local share `n_local / n_obs` (H2, H4), parent-origin
share among local hires `n_local_parent / n_local` (H3). Entrants and unknown
histories are outside every denominator.

#### 0.4 Regressors

`local_embeddedness`, `coord_dependence`: domain scores from
`data/processed/contingency-scores-domain-v1-2026-11-25.csv` (unweighted mean
of the rated occupations of the domain; occupation scores standardized across
rated occupations, mean 0 and SD 1). Across the 98 domains the SDs are 0.77
and 0.73, the interquartile ranges 0.92 and 0.94, and the correlation 0.40.
REG ranks 6th of 98 on `local_embeddedness` and lies at the 22nd percentile
of `coord_dependence` (-0.47). A cell's score is its domain's score; it does
not change with the cell's occupational composition. `job_zone`,
`law_gov_importance`: domain means (robustness only).

S13 variables (proposed names; definitions from `literature/shock-scan/rescoring.md`, 4.1, and the S13 design):

| Variable | Definition |
|---|---|
| `exposed` | 1 if the IJV's host and one of its direct parents' countries form a {GB, X} pair with X in the EU27, Iceland, Liechtenstein, Norway or Switzerland (direct shareholder country; gate 4, decisions 2 and 3) |
| `shock` | `exposed` x 1[year >= 2021] (codebook: 1 from the first exposure year) |
| `antic` | `exposed` x 1[2016 <= year <= 2020] (anticipation window) |
| `event_time` | year - 2021 for exposed IJVs, missing otherwise |
| `reg` | 1 if `domain == "REG"` |
| `dyad` | cluster for the shock models: the host country paired with the country of the foreign direct parent with the largest equity share (proposed rule; for exposed IJVs one of the {GB, X} pairs). The codebook's identifier table defines `dyad` as the pair of parent HQ countries; gate 5 should revise it (see section 7) |

S13 sample: exposed IJVs and never-exposed control IJVs hosted in the UK, the
EU27, the EEA or Switzerland without a UK-set link (rescoring 4.1 and 9);
parent-parent pairs hosted in third countries (19 IJVs) are excluded and used
as a placebo. Expected size before outcomes: 24 exposed pairs and 231 exposed
IJVs with a parent in Revelio after the employee rule; 2,510 controls with a
parent in Revelio before the cell rule.

#### 0.5 Estimators, effect sizes and reporting (common to all blocks)

- Primary: `fepois(count ~ x + offset(log(denominator)) | fixed effects)`
  (pre-analysis plan rules, decision 5). The coefficient `b` is the change in
  the log expected share; consistency needs only the conditional mean to be
  correct, not a Poisson distribution, and clustered errors absorb
  overdispersion (`wooldridge1999distributionfree`; `santossilva2006log`; `santossilva2011further`; `correia2020fast`).
  No switch to negative binomial.
- Robustness estimators: fractional logit (`feglm`, `quasibinomial("logit")`,
  weights = denominator) (`papke1996econometric`, a cross-sectional estimator; the fixed-effects version is used as a robustness check only) and linear
  (`feols`, weighted by the denominator, unweighted reported).
- Effect size: `100 * (exp(b) - 1)` percent change in the share per one
  occupation-level SD, also per domain interquartile range; percentage points
  as the average marginal effect by prediction (fixed effects included,
  cells weighted by the denominator), set against the denominator-weighted
  mean share; 95 percent confidence intervals for all. No stars without
  intervals.
- Reported with every model: cells given and used, fixed-effect groups
  dropped for all-zero outcomes (`fepois`, `feglm` notes are never silenced),
  IJVs, clusters, and for the static models the within-IJV-year share of
  outcome variance (skill, variance check).
- Seeds: `set.seed(20261125)` for permutations and bootstraps.

### 1. Specification blocks

#### H1 (organizational origin, functions part: domains). Confirmatory

```
Hypothesis: H1. The more a domain depends on coordination with the parents'
  activities and on parent-specific knowledge, the larger its share of
  parent-origin hires (local and international) relative to independent hires.
Unit and sample: IJV x domain x year cells, hiring flows 2010-2025, n_emp >= 5,
  n_obs >= 1; IJVs of core_main with at least one parent in Revelio; 831 rule.
Outcome: n_parent with offset log(n_obs); estimand log E[n_parent / n_obs].
Regressor: coord_dependence (domain score; 98 values). local_embeddedness
  enters as a control so that each axis is read net of the other.
Model (primary): fepois(n_parent ~ coord_dependence + local_embeddedness
  + offset(log(n_obs)) | ijv_id^year)
Fixed effects: IJV x year. They absorb everything constant within the
  IJV-year: ownership shares, parent bargaining power and control rights, IJV
  size and age, host country and its labor market, industry, the shock, and
  the IJV-wide parent-origin rate (including coverage of parents in Revelio).
  Domain fixed effects cannot be added: the score varies only across domains.
Identifying variation: differences between domains inside one IJV-year.
Models: Poisson (decisive); fractional logit; linear, weighted (robustness).
Inference: permutation test over domains, decisive (PI, 2026-11-25,
  amending pre-analysis plan rules, decision 6): B = 999 reassignments of the
  score rows, both scores together, statistic the Poisson coefficient,
  one-sided p = (1 + #{b* >= b}) / (B + 1) (`young2019channeling`; `phipson2010permutation`). Clustered two-way by IJV
  and domain (t with G - 1 = 97 df) (`cameron2011robust`) and IJV-only errors are reported.
Test: coefficient on coord_dependence > 0, one-sided, Holm-adjusted across
  the confirmatory family (section 4).
Effect size: percent and percentage-point change in the parent-origin share
  per occupation SD and per domain IQR of coord_dependence, against the mean
  share in the estimation sample.
Checks: within-IJV-year variance share; cells and IJV-years dropped;
  history-not-observed outcome n_not_obs ~ scores (offset log(n_hires)) and
  bounds (all unknown histories as independent, then as parent-origin);
  domains with all scores imputed (the three military domains) dropped.
Competing accounts: parent bargaining power (absorbed); skill level
  (job_zone control, robustness 8); resource dependence: a domain hires from
  the parent because it is the parent's core business, not because of
  coordination (domain-level check, robustness 19, pfeffer1978external);
  secondments missed by Revelio, which bias against H1 (gate 4 pilot).
```

#### H1 (levels part). Exploratory, reported in a separate section

```
Hypothesis: as H1, for hierarchical levels (pre-analysis plan rules, decision 7).
Unit and sample: IJV x level x year, same sample rules as H1.
Outcome: n_parent with offset log(n_obs).
Regressor: coord_role (1 for executive and middle_management, 0 otherwise;
  source mintzberg1979structuring).
Model: fepois(n_parent ~ coord_role + offset(log(n_obs)) | ijv_id^year)
Fixed effects: IJV x year, as H1.
Identifying variation: the two senior levels against the two junior levels
  inside one IJV-year: a two-group contrast.
Inference: clustered by IJV. No permutation test (with four levels and a
  binary score the smallest attainable p is 1/3). No multiple-testing
  adjustment, no support classification.
Effect size: percent change in the parent-origin share, senior against junior.
Limitation stated in the text: coord_role cannot be separated from anything
  else that differs between senior and junior levels, above all the longer
  prior careers of senior hires, which raise the chance of any prior parent
  position. BoardEx senior-level counts (gate 4, decision 1) are a descriptive
  cross-check.
```

#### H2 (geographic origin). Confirmatory

```
Hypothesis: H2. The more a domain depends on host-country institutions, labor
  markets, customers and regulators, the larger its share of locally recruited
  hires (parent-origin and independent) relative to international hires.
Unit and sample: IJV x domain x year, hiring flows 2010-2025, n_emp >= 5,
  n_obs >= 1; all IJVs of core_main (proposed, 0.2); 831 rule.
Outcome: n_local with offset log(n_obs).
Regressor: local_embeddedness; coord_dependence as control.
Model (primary): fepois(n_local ~ local_embeddedness + coord_dependence
  + offset(log(n_obs)) | ijv_id^year)
Fixed effects and identifying variation: as H1. IJV x year effects separate
  the claim from the unit-level pattern that distance raises parent-country
  staffing (gaur2007institutional, gong2003subsidiary).
Models, inference: as H1.
Test: coefficient on local_embeddedness > 0, one-sided, Holm-adjusted.
Effect size: as H1, against the mean local share in the estimation sample.
Checks: as H1; entrants counted as local or international by place of
  education (robustness 10), since entrants bear on H2 only; H2 without the
  exposed IJV-years from 2016 on, so that the static slope is not mixed with
  the H4 response (robustness 15g).
Competing accounts: host labor supply by occupation (not absorbable with
  domain-level scores; the job_zone control and the role_k50 grain are the
  available checks); skill level (robustness 8).
```

#### H3 (channel of localization; anchor). Confirmatory

```
Hypothesis: H3. Among locally recruited hires, the share with prior employment
  in a parent's group increases with the domain's coordination dependence.
  Boundary: weaker or absent in IJVs without a host-country parent.
Unit and sample: IJV x domain x year, hiring flows 2010-2025, n_emp >= 5,
  n_local >= 1; IJVs with at least one parent in Revelio; 831 rule. IJVs
  without a host-country parent stay in the model for the boundary term.
Outcome: n_local_parent with offset log(n_local).
Regressors: cd_host = coord_dependence x host_parent and cd_nohost =
  coord_dependence x (1 - host_parent): separate slopes; local_embeddedness
  as control. host_parent is constant within the IJV and absorbed.
Model (primary): fepois(n_local_parent ~ cd_host + cd_nohost
  + local_embeddedness + offset(log(n_local)) | ijv_id^year)
Fixed effects and identifying variation: as H1; the slopes come from
  differences between domains inside the IJV-year, separately for IJVs with
  and without a host-country parent.
Models: Poisson (decisive); fractional logit; linear, weighted.
Inference: permutation over domains (decisive; PI, 2026-11-25); two-way
  IJV and domain and IJV-only errors reported. The boundary contrast rests on few IJVs without a
  host-country parent (67 with five or more local parent-origin hires in the
  tabulations); if fewer than 50 such IJVs contribute cells with a positive
  outcome, its p-value comes from a wild cluster (score) bootstrap by IJV
  (pre-analysis plan rules, decision 5).
Test (confirmatory): cd_host > 0, one-sided, Holm-adjusted.
Test (secondary, not in the family): cd_host - cd_nohost > 0, one-sided.
Effect size: percent and percentage-point change in the local parent-origin
  share among local hires per occupation SD and domain IQR of coord_dependence,
  against the mean share in the estimation sample.
Checks: host-country parent's group only as the definition of local
  parent-origin (gate 4, decision 8b, robustness 13c); bounds for unobserved
  histories; all-parents-in-Revelio sample.
Competing accounts: as H1; in addition, parents with a large host workforce
  supply local hires everywhere (absorbed by IJV x year as long as the
  supply does not differ by domain; the resource-dependence check covers the
  case where it does).
```

#### H4 (dynamic form of H3), stated at the contingency level

When an environmental change raises the local-embeddedness requirement of a
set of domains and leaves their coordination dependence unchanged, then, in
the IJVs exposed to the change and relative to unexposed IJVs: (H4a) the
local share of new hires rises more in the affected domains than in the other
domains of the same IJV-year (the geographic axis moves); (H4b) the rise
consists of local parent-origin hires where the affected domains' coordination
dependence is high and of independent local hires where it is low (the
organizational axis holds its contingency-fit position). Which contingency
changes: local embeddedness. Which domains: those whose work depends on the
changed part of the host environment. Direction: local share up in those
domains; composition of the increase set by their coordination dependence.

#### H4 instantiated for S13 (Brexit). H4a and H4b confirmatory (PI, 2026-11-25)

The end of the UK-EU transition period on 31 December 2020 separated UK and
EU regulation, customs, product approval, tax administration and employment
law. For an IJV whose host and parent countries straddle the new border, the
regulatory-facing domain (`REG`: legal, compliance, regulatory affairs,
customs brokerage, tax and labor relations occupations) now needs knowledge of
the host regime that staff from the other jurisdiction no longer hold: its
local-embeddedness requirement rises. Its coordination dependence on the
parents does not change. REG's coordination dependence is below the domain
average (-0.47; 22 of the 98 domains score lower), so H4b predicts that the
rise in REG is carried by independent local hires. REG is a single domain with
one `coord_dependence` value, so a shock x REG x `coord_dependence` moderation
is not identified at the primary grain; H4b is therefore stated as the
directional prediction for REG (PI decision of 2026-11-25), and the
moderation form is reported only as a secondary analysis.

```
Hypothesis: H4a (S13). From 2021, in exposed IJVs relative to control IJVs,
  the local share of new hires rises more in REG than in the IJV's other
  domains.
Unit and sample: IJV x domain x year, hiring flows 2010-2025, n_emp >= 5,
  n_obs >= 1; S13 sample (0.4): exposed and control IJVs with at least one
  parent in Revelio; 831 rule.
Outcome: n_local with offset log(n_obs).
Regressor: shock x reg (exposed x post-2021 x REG); antic x reg (exposed x
  2016-2020 x REG) enters as its own term so that the anticipation window
  does not enter the baseline; the baseline is 2010-2015.
Model (primary): fepois(n_local ~ shock:reg + antic:reg + offset(log(n_obs))
  | ijv_id^domain + domain^year + ijv_id^year)
Fixed effects: IJV x domain absorbs every time-invariant difference between
  the domains of one IJV (including REG's level of local hiring and exposed x
  REG); domain x year absorbs domain-specific shocks common to exposed and
  control IJVs (COVID-19 effects on occupations, occupation-wide labor market
  trends); IJV x year absorbs everything that moves the whole IJV in a year,
  including the shock main effect, the part of the mobility shock that is
  uniform across domains, sterling and demand.
Identifying variation: the change from 2010-2015 to 2021-2025 in the gap
  between REG and the other domains of the same IJV, exposed against control
  IJVs (a triple difference `olden2022triple`).
Models: Poisson (decisive); fractional logit; linear, weighted (robustness).
Inference: clustered by dyad (parent-host pair); the decisive p-value comes
  from a wild cluster bootstrap by dyad with the null imposed, implemented
  for the Poisson model as a cluster score bootstrap (restricted fit,
  Rademacher weights, B = 9,999; code/R/functions/simulate_domain_panel.R,
  score_boot()) (`cameron2008bootstrapbased`; `mackinnon2017wild`; `mackinnon2018wild`; `roodman2019fast`)
  (`kline2012score`); the test rests on about 24
  exposed pairs, below the 50-cluster line of decision 5. Dyad-clustered and
  IJV-clustered t tests are reported as checks. The number of exposed pairs
  that contribute REG cells in both periods is reported.
Test: coefficient on shock:reg > 0, one-sided, Holm-adjusted.
Effect size: 100 * (exp(b) - 1) percent change in the local share of REG
  hiring in exposed IJVs after 2021; percentage points at the exposed REG
  mean of 2010-2015.
Checks: event study and pre-trend rule (section 2); GB-IE contrast; mobility
  channel with the Rule C contrast (competing-pattern check below); placebos
  (robustness 15).
Competing accounts: (1) mobility channel: the end of free movement raises the
  cost of international hiring in every domain; the uniform part is absorbed
  by IJV x year; the part that varies with skill (salary thresholds bite in
  lower-paid roles) is checked with shock x job_zone and the level term
  below; REG lies above the average job zone (3.73), so a skill gradient of
  the mobility channel biases the REG estimate down, not up. (2) COVID-19 at
  the same onset: absorbed where common to exposed and control IJVs by domain
  x year. (3) Anticipation 2016-2020: separate term. (4) Survivor bias: IJVs
  dissolved because of Brexit are missing (robustness 15f).
```

```
Hypothesis: H4b (S13, confirmatory, directional; PI decision of 2026-11-25).
  Because REG scores low on coord_dependence, the post-2021 rise of the local
  share in REG in exposed IJVs is carried by independent local hires: the
  independent local component rises, and local parent-origin hires in REG do
  not rise more than elsewhere.
Unit and sample: as H4a, restricted to IJVs with a host-country parent (the
  channel needs a parent workforce in the host country).
Model (i), decisive: fepois(n_local_indep ~ shock:reg + antic:reg
  + offset(log(n_obs)) | ijv_id^domain + domain^year + ijv_id^year)
Model (ii), composition condition: fepois(n_local_parent ~ shock:reg
  + antic:reg + exposed:reg + offset(log(n_local)) | domain^year + ijv_id^year)
  IJV x domain effects are replaced by domain x year and IJV x year effects
  with exposed x REG as a regressor, because local parent-origin hires in REG
  cells are so rare that the model with IJV x domain effects separates (found
  in the simulation of 2026-11-25).
Fixed effects and identifying variation: as H4a for (i); for (ii) the
  comparison is the parent-origin share among local hires in REG against other
  domains, exposed against control, after against before.
Inference: as H4a (cluster score bootstrap by dyad with the null imposed).
Test: (i) coefficient on shock:reg > 0, one-sided, in the Holm family;
  (ii) the coefficient on shock:reg must not be positive with two-sided
  bootstrap p < 0.05.
Decision rule: support if (i) passes its Holm-adjusted test, (ii) holds, and
  H4a is at least partially supported; partial support if (i) passes
  unadjusted but not Holm-adjusted, or if (i) passes and the core checks of
  section 3 fail; no support if (i) fails; evidence against if (ii) shows a
  positive coefficient with two-sided p < 0.05 (parent-origin hires carry the
  rise), whatever (i) shows.
Effect size: percent change in the independent local share of REG hiring;
  percent change in the parent-origin share among local REG hires with its
  95 percent interval.
What the test can and cannot show: local parent-origin hires are a small part
  of local hires (gate 4 tabulations), so (i) is close to H4a by construction
  and adds little on its own; the information about the channel sits in (ii),
  whose interval will be wide (simulation, section 6a). A non-significant (ii)
  is not evidence that parent-origin hiring did not rise; the text reports the
  interval and says how large a rise it rules out.
```

```
Secondary (not confirmatory): moderation form of H4 (PI, 2026-11-25).
  fepois(n_local_parent ~ shock:law_gov_importance + shock:law_gov_importance:coord_dependence
  + antic:law_gov_importance + antic:law_gov_importance:coord_dependence
  + offset(log(n_local)) | ijv_id^domain + domain^year + ijv_id^year), all
  98 domains, law_gov_importance standardized across domains, host-parent
  IJVs; the same with n_local and offset log(n_obs) for the geographic axis.
  H4 at the contingency level predicts a positive three-way term for the
  parent-origin share. Clustered by dyad, score bootstrap; reported without a
  support label.
```

```
GB-IE contrast and REG effect by linked status are checks of H4a (below);
the mobility channel has its own confirmatory block (C1).
REG by linked status (check of H4a): the H4a model with shock:reg split into
  shock:reg:control_linked and shock:reg:(1 - control_linked). The regulatory
  channel predicts both positive and not different; a REG effect present only
  in one group points to the mobility channel.
GB-IE contrast: shock:reg split into shock:reg:ie and shock:reg:non_ie. GB-IE
  IJVs (31 before thresholds) see the regulatory change without the end of
  free movement for Irish nationals, so the regulatory channel predicts a
  positive REG coefficient in both groups. GB-IE is a single pair, hence a
  single cluster: its coefficient is reported with IJV-clustered intervals
  only and read descriptively.
```

#### C1 (S13 mobility channel; competing-channel test). Confirmatory (PI, 2026-11-25)

The same date ended free movement between the UK and the EU, EEA and
Switzerland. For an exposed IJV this raises the cost of hiring nationals of
the other jurisdiction in every domain and at every level, including staff
from a foreign parent's home units, who now need sponsorship under the
intra-company or skilled worker routes. The channel acts on the geographic
axis everywhere, not on the regulatory domain in particular; it is the
competing account H4a must be separated from and is tested in its own right.

```
Hypothesis: C1 (S13). From 2021, in exposed IJVs relative to control IJVs,
  (a) the local share of new hires rises; (b) international parent-origin
  hires from a foreign parent's home country fall as a share of hires.
  Secondary, two-sided (PI, 2026-11-25): (c) the fall in (b) differs between
  UK-hosted IJVs whose EU, EEA or Swiss parent is control-linked under Rule C
  and other UK-hosted exposed IJVs.
Unit and sample: IJV x level x year, hiring flows 2010-2025, cells with
  n_emp >= 5 and n_obs >= 1; S13 sample (0.4) with at least one parent in
  Revelio; 831 rule.
Outcomes: (a) n_local with offset log(n_obs); (b), (c) n_intl_parent_home
  (proposed name: international parent-origin hires whose prior position was
  in the home country of a foreign direct parent; for exposed IJVs this is the
  other jurisdiction) with offset log(n_obs).
Regressors: shock (exposed x post-2021); antic (exposed x 2016-2020);
  for (c) also shock:uk_host and shock:control_linked, where control_linked
  (Rule C, PI 2026-11-25) is 1 for a UK-hosted exposed IJV whose EU, EEA or
  Swiss parent holds more than 50 percent of the voting rights or controls the
  board (equity above 50 percent as the proxy where only equity data exist;
  50/50 coded 0 unless board control is documented), and 0 otherwise; uk_host
  is 1 for UK-hosted IJVs. Rule L (every JV party linked, Home Office guidance
  ICW2.8 to ICW2.14 and GBM2.11 onward; candidate source homeoffice2026workers)
  does not vary across IJVs and is reported for completeness only, as the
  model without the control_linked term.
Models (primary):
  (a) fepois(n_local ~ shock + antic + offset(log(n_obs)) | ijv_id^level + level^year)
  (b) fepois(n_intl_parent_home ~ shock + antic + offset(log(n_obs)) | ijv_id^level + level^year)
  (c) fepois(n_intl_parent_home ~ shock + shock:uk_host + shock:control_linked
      + antic + antic:uk_host + antic:control_linked + offset(log(n_obs))
      | ijv_id^level + level^year)
Fixed effects: IJV x level absorbs every time-invariant difference between
  the levels of one IJV; level x year absorbs level-specific trends and shocks
  common to exposed and control IJVs (COVID-19 effects by seniority, labor
  market cycles). IJV x year effects are not used, because they would absorb
  the IJV-wide shock that C1 predicts.
Identifying variation: (a), (b) the change from 2010-2015 to 2021-2025 in
  exposed against control IJVs (difference in differences, single common
  onset); (c) the same change in control-linked against other UK-hosted
  exposed IJVs.
Inference: clustered by dyad; decisive p-values from the cluster score
  bootstrap by dyad with the null imposed (wild cluster bootstrap counterpart
  for the Poisson model; pre-analysis plan rules, decisions 5 and 6); IJV
  clustering as a check. The number of control-linked exposed IJVs and of the
  pairs they come from is reported. The four-level limit on permutation tests
  concerns the static coord_role score and does not apply here.
Test: one-sided: (a) shock > 0; (b) shock < 0. C1 enters the confirmatory
  family as one member with the intersection-union p-value
  p_C1 = max(p_a, p_b), which needs no adjustment within C1. (c)
  shock:control_linked is tested two-sided and reported as a secondary
  result outside the confirmatory family (PI, 2026-11-25: route access
  predicts a weaker fall where control-linked, baseline dependence on parent
  transfers a stronger one).
Decision rule: support if p_C1 passes its Holm-adjusted threshold and the
  core checks hold (event-study pre-trend rule of section 2 applied to the
  level panel with treat = exposed; same signs in the fractional logit and
  linear models; level-specific shock coefficients in (a) positive at all
  four levels, sign only). Partial support if (a) and (b) pass at their
  unadjusted one-sided 0.05 but p_C1 does not pass Holm-adjusted, or if a core check fails. No support if (a) or (b) fails.
  Evidence against if (a) or (b) has the opposite sign with two-sided
  p < 0.05.
Effect size: percent change in the local share and in the international
  parent-origin share of hires after 2021; the difference between
  control-linked and other UK-hosted exposed IJVs in percent.
Checks: all international parent-origin hires in place of the home-country
  ones; UK-hosted IJVs and their controls only; Ireland excluded (GB-IE keeps
  free movement for Irish nationals, so C1 predicts no effect there: a
  placebo); level gradient i(level, shock) with IJV x year effects
  (salary thresholds bite more at professional and operational levels).
Level mapping (PI, 2026-11-25; labels from the Revelio data dictionary,
  methodology page, "Seniority"): executive = seniority 6-7, middle_management
  = 4-5, professional = 3, operational = 1-2. Robustness: (b) executive = 7,
  middle_management = 5-6, professional = 3-4, operational = 1-2; (c) the
  seven seniority codes as one linear term in the level-gradient check.
  Disclosure: the staffing tabulations by seniority (2026-11-23) were seen
  before this test and the mapping were fixed; they were not broken down by
  exposure.
Competing accounts: COVID-19 at the same onset (level x year effects absorb
  the part common to exposed and controls); sterling and UK demand after the
  referendum (IJV-wide; not separable in (a) and (b), which is why (c), a
  within-exposed contrast, carries the channel-specific part).
```

The direction of (c) was relayed to the quant-analyst by the orchestrator,
not set by the PI: the PI decided Rule C as the contrast and the test as
confirmatory, not its sign (correction, 2026-11-25). Section 7, point 4,
records that the intra-company route logic predicts the opposite sign; the
sign is put to the PI before approval.

### 2. Event study for H4a

Model:

```
fepois(n_local ~ i(year, treat_reg, ref = c(2013, 2014, 2015)) + offset(log(n_obs))
       | ijv_id^domain + domain^year + ijv_id^year)
treat_reg = exposed x reg; cluster: dyad
```

- Leads and lags: one coefficient per calendar year 2010 to 2025 except the
  reference. All exposed IJVs share the onset 2021, so event time equals
  calendar year minus 2021 for everyone (-11 to +4) and the ends need no
  binning for composition. Precision rule (proposed, applied before outcomes
  are seen from the cell counts alone): if any of the years 2010 to 2012 has
  fewer than 25 exposed REG cells with a positive denominator, those three
  years are pooled into one lead.
- Reference period: 2013 to 2015 pooled, the clean pre-period of the S13
  design. The year -1 (2020) is not the reference because it lies in the
  anticipation window and is the first COVID-19 year.
- Groups of coefficients: 2010 to 2012, pre-trend leads; 2016 to 2020,
  anticipation window (reported, not part of the pre-trend test); 2021 to
  2025, effects.
- Pre-trend test (PI, 2026-11-25): one pooled lead, the 2010 to 2012
  coefficient of treat_reg against the 2013 to 2015 reference, with its
  p-value from the cluster score bootstrap by dyad (one degree of freedom).
  Reported but not deciding: the separate 2010, 2011 and 2012 leads, the
  dyad-clustered Wald test of the three leads, and the slope of treat_reg x
  (year - 2015) on 2010 to 2015. The trend-adjusted estimate is reported
  beside H4a in every case.
- Power of the pre-test: report the linear pre-trend slope that the pooled
  test would detect with 80 percent power, and the bias in the H4a estimate
  that such an undetected trend would produce (`roth2022pretest`). Sensitivity
  of H4a to bounded violations of parallel trends: the relative-magnitude
  bound with M-bar = 1 decides causal language (PI, 2026-11-25); the bound
  over a grid of M-bar values and the smoothness bound are reported
  (`rambachan2023more`).
- Staggered adoption: not relevant for S13, which has one common onset; the
  two-way fixed-effects event study with never-exposed controls carries no
  forbidden comparisons, and `sunab` or `did::att_gt` would reproduce it.
  S13 is not replaced by another shock (S06 retired as fallback, PI,
  2026-11-25); a later exploratory S06 analysis would use `sunab` and
  `did::att_gt` with not-yet-treated controls and be reported apart
  (`sun2021estimating`; `callaway2021differenceindifferences`; `borusyak2024revisiting`).

Decision rule for the pre-trends (fixed before the data are seen):

1. Pass: score-bootstrap p-value of the pooled 2010 to 2012 lead >= 0.10.
   Causal language for H4a needs a second condition (PI, 2026-11-25): the
   `HonestDiD` sensitivity bound with relative magnitudes, M-bar = 1,
   computed from the event-study coefficients and their cluster score
   bootstrap covariance, excludes zero. If the pre-test passes but the bound
   includes zero, H4a is reported as a pattern consistent with the
   regulatory channel, without causal language; its support classification
   is unchanged. H4a may then be described with causal language, conditional on
   parallel trends in the REG-to-other gap between exposed and control IJVs,
   and the text names COVID-19 and the anticipation window as the remaining
   threats. A non-rejection is not proof of parallel trends: the leads are
   shown with their intervals and the detectable trend of the power check is
   stated.
2. Fail: that p-value < 0.10. No causal language for H4. The trend-adjusted
   estimate (H4a with treat_reg x linear trend estimated on 2010 to 2015 and
   extrapolated) is reported next to the main estimate, and H4 can be
   classified at most as partial support (section 3).
3. Anticipation: if the 2016 to 2020 coefficients are jointly positive
   (p < 0.10), the text says that adjustment began after the referendum; the
   main estimate (2021 to 2025 against 2010 to 2015) is unchanged by
   construction, and a supplementary estimate with 2016 to 2025 as the post
   period is reported.

### 3. Decision rules

Common to H1, H2, H3, H4a, H4b and C1: the decisive estimate is the Poisson
coefficient named in the block; the decisive p-value is one-sided in the
predicted direction and is Holm-adjusted across the six confirmatory family
members (section 4) at a family-wise alpha of 0.05. H4b adds its composition
condition and C1 its two components (intersection-union p-value), each with
its own decision rule in its block. Two-sided 95 percent intervals are reported for every estimate.

Core checks (the only results that can change a classification):

| Hypothesis | Decisive p-value | Core checks |
|---|---|---|
| H1 | permutation test over domains, one-sided (PI, 2026-11-25) | (a) two-way (IJV, domain) and IJV-only clustered errors reported, not decisive; (b) same sign in the fractional logit and the linear model; (c) same sign without positions with imputed scores; (d) same sign under the 5-hires cell rule |
| H2 | as H1 | as H1 |
| H3 (`cd_host`) | as H1 | as H1 |
| H4a (`shock:reg`) | cluster score bootstrap by dyad | (a) pre-trend rule passes (section 2); (b) same sign in the fractional logit and the linear model; (c) same sign with the broad REG list; (d) same sign under the 5-hires cell rule |
| H4b (`shock:reg` on `n_local_indep`) | cluster score bootstrap by dyad | as H4a, plus the composition condition (ii), which decides between support and evidence against as stated in the block |
| C1 (`shock` in (a) and (b); level panel) | cluster score bootstrap by dyad; p_C1 = max of the two one-sided p-values; (c) `shock:control_linked` two-sided, secondary | pre-trend rule on the level panel; same signs in the fractional logit and linear models; positive level-specific shock coefficients at all four levels (sign only) |

Static inference (see section 7, point 1): the simulation of 2026-11-25 shows
two-way clustered errors 20 to 43 percent too small and one-sided size 0.078
to 0.114 at nominal 0.05 when outcomes carry a domain-level component, while
the permutation test over domains holds its size. On 2026-11-25 the PI made
the permutation p-value the decisive p-value for H1 to H3 ("Yes,
permutation"); two-way and IJV-only errors are reported. Holm adjustment
applies to the permutation p-values.

Classification:

- Support: positive coefficient, Holm-adjusted p < 0.05, and every core check
  holds.
- Partial support: positive coefficient and Holm-adjusted p < 0.05 with at
  least one core check failing; or positive coefficient with unadjusted
  one-sided p < 0.05 and Holm-adjusted p >= 0.05; for H4, also when the
  pre-trend rule fails but the trend-adjusted estimate is positive with
  one-sided p < 0.05.
- No support: unadjusted one-sided p >= 0.05.
- Evidence against: negative coefficient with two-sided p < 0.05; reported as
  such, not as no support.
- Size: an effect is called small if the change in the share per domain IQR
  is below 5 percent of the mean share (proposed); this qualifies the reading,
  not the classification.

What robustness can and cannot change: robustness results cannot raise a
classification. Only the core checks can lower it, and only in the way stated.
Every other robustness result is reported in a table and discussed; a sign
reversal across a whole group of them (for example all three grain
alternatives) is named as a limitation in the text but does not reclassify.
Secondary tests (H3 boundary, moderation form of H4, mobility channel,
GB-IE contrast) are
reported with their own one- or two-sided p-values, are not adjusted, and
carry no support label. The levels part of H1 is exploratory.

### 4. Multiple testing

Policy (proposed): Holm's step-down procedure across the six confirmatory
family members (H1, H2, H3, H4a, H4b test (i), C1 with its intersection-union
p-value) at a family-wise error rate of 0.05 (`holm1979simple`) (`berger1982multiparameter`). The H4b composition condition
(ii) is a condition, not a test in the family; the two components of C1
enter through one p-value, the larger of the two, which controls the error
of the joint claim without a further adjustment. Reasons: (1) each of the six is a claim
the paper would make on its own, so the family-wise rate, not the false
discovery rate, is the relevant error; (2) Holm controls it under any
dependence among the tests, which matters because the tests share IJVs and
cells and are positively dependent; (3) it is uniformly more powerful than
Bonferroni, and with six members its cost is modest: the smallest p-value is
compared with 0.0083 (0.05/6), and the weakest members, likely H4 and C1,
are compared with up to 0.05 if the others reject first. H4a and H4b (i) are nearly
the same test (section 1), which Holm handles without penalty beyond one
step; treating them as one family member is the alternative if the PI
prefers it. Benjamini-Hochberg was not chosen because the
family is small and the aim is confirmation, not discovery. Secondary,
robustness and exploratory results are not adjusted and are labeled.

### 5. Robustness set (fixed order; each item tied to the decision that created it)

1. Fractional logit and linear models for every confirmatory test, with the
   samples of all three estimators side by side (pre-analysis plan rules,
   decision 5).
2. Wild cluster (score) bootstrap wherever a test rests on fewer than about 50
   clusters: H4a, H4b and the mobility term by dyad; the H3 boundary by IJV if
   fewer than 50 IJVs without a host-country parent contribute (pre-analysis
   plan rules, decision 5).
3. Inference checks: IJV-only clustering and the permutation test over
   domains for the static models (decision 6); IJV clustering for the shock
   models (S13 design); dyad defined by the combination of all foreign parent
   countries instead of the largest-equity parent (proposed).
4. Cell rules: at least 5 hires (route to gate 5, decision 6); 3 and 10
   employees (skill candidate list, item 4).
5. Grain: Revelio `role_k50` (50 groups) and the nine functions, with scores
   aggregated to that grain from the occupation scores (score construction,
   decision 4; route to gate 5, decision 5).
6. Scores: broad element sets (score construction, decision 1); level scale
   (`*_lv`) as an appendix check (decision 2); outside raters' scores for the
   50 `role_k50` groups if ICC(2,k) >= 0.70 (decision 8; route, decision 3);
   the function ordering of `kim2003global` as a convergent-validity check
   (gate 2, decisions 1 to 4).
7. Imputation and coding route: positions with `score_imputed` dropped
   (score construction, decision 3; includes the military domains); positions
   with `onet_source` = lookup dropped (PI, 2026-11-25).
8. Skill level: domain mean `job_zone` as an added regressor in H1 to H3, and
   `shock:job_zone` in H4a (score construction, decision 7).
9. H4 measure: REG built from the broad list (22 codes); continuous
   `law_gov_importance` in place of `reg`, without the REG carve-out
   (score construction, decision 5); the moderation form shock x
   `law_gov_importance` x `coord_dependence` as the secondary analysis of H4
   (PI, 2026-11-25; block in section 1).
10. Entrants: one- and five-year windows (pre-analysis plan rules, decision
    2); entrants counted as local or international independent hires by place
    of education (gate 4, decision 8c).
11. The 831 flagged IJVs: dropped if the audit keeps them, added back if it
    drops them (pre-analysis plan rules, decision 3).
12. Period and unmapped employers: full period from formation; the cell's
    share of prior employers not mapped to a Revelio company as a control
    (pre-analysis plan rules, decision 4).
13. Samples: (a) IJVs with all parents in Revelio (gate 4, decision 8a);
    (b) strategic subset and `core` (gate 4, decision 6); (c) local
    parent-origin from the host-country parent's group only (gate 4,
    decision 8b); (d) listed JVs dropped; ultimate owner's country for the
    host-parent label and for S13 exposure (gate 4, decisions 2 and 3;
    rescoring variant "Orbis, owner"); (e) usability threshold of 10 and 30
    employees (gate 4, decision 6).
14. Coverage: the Revelio-to-Orbis coverage ratio as a control, from 2015 on
    (gate 4, decision 8d).
15. S13 design checks (route to gate 5, decision 7; rescoring 4.1 and 9):
    (a) GB-IE contrast and Ireland excluded; (b) level x exposure x post
    mobility term; (c) mobility channel with the Rule C contrast
    (`control_linked`), Rule L reported for completeness (pre-analysis plan
    rules, decision 8; PI, 2026-11-25); (d) announcement onset 2016 as the post period;
    (e) placebos: shifted onset 2013 on 2010 to 2015 data, the placebo
    exposure of third-country parent-parent pairs, and each of the 97
    non-REG domains in place of REG, with the rank of the REG estimate in
    that distribution reported; (f) IJVs formed before 2016 only (survivor
    and entry check); (g) H2 without exposed IJV-years from 2016 on.
16. Unobserved histories: `n_not_obs` as its own outcome on the scores, and
    bounds (all unknown histories counted as independent, then as
    parent-origin) for H1 and H3 (gate 4 pilot; skill, Step 3).
17. Origin window for prior positions of one and five years next to three
    (PI, 2026-11-25).
18. Level mapping for the level panel (C1 and the levels part of H1; PI,
    2026-11-25): (b) executive = seniority 7, middle_management = 5-6,
    professional = 3-4, operational = 1-2; (c) the seven seniority codes as
    one linear term.
19. Resource dependence (gate 2, decisions 1 to 4; pfeffer1978external;
    defined by the PI on 2026-11-25, chat items 18 and 19). Parent industry
    (rule v2, `code/R/functions/parent_industry.R`): own Orbis primary NAICS
    2017 code (not for a holding), core code, secondary code; then the
    ultimate owner's codes in the same order; for Capital IQ parents the
    Capital IQ industry tree mapped to SIC and through the Census
    concordances to NAICS 2017 (modal 4-digit industry). Holding parents:
    NAICS 5511 or NACE 64.2 or 70.1; holding codes are never used. Matrix:
    BLS OEWS May 2021 national industry-specific estimates (the first
    release based only on 2018 SOC data), matched by 4-digit industry, then
    the OEWS combined industry, then the 3-digit industry. `rd_core` = 1 if the domain's
    employment share in the parent's industry is at least twice its share
    across all industries; `rd_ratio` = the log of that ratio (alternative
    specification). H1: `rd_core` = 1 if the domain is core for any parent
    with a code, with an indicator that some parent's code is missing
    (available case, primary); all parents coded (complete case) beside it.
    H3: the host-country parent's industry. `rd_core` and its interaction
    with the score enter the H1 and H3 models. Reading rule, fixed before
    the data are seen: the coordination reading holds if the score's
    coefficient keeps its sign and at least half its size; otherwise the
    paper reports that resource dependence accounts for part of the
    pattern. Outside the Holm family. US industry structures are a stated
    limitation, as for O\*NET.

Not carried forward: ownership-adjusted parent dominance (it belongs to the
cross-partner measures dropped at gate 4, decision 1); staggered estimators
for S13 (single onset; section 2).

### 6. Deviation policy

1. The plan is versioned at approval (v1.0, the commit hash of the approved
   gate file recorded in `docs/decisions.md`) and fixed by the annotated Git
   tag `pap-v1.0` on that commit, pushed to GitHub; there is no outside
   registry (PI, 2026-11-25). Amendments before gate 6 are tagged
   `pap-v1.1`, `pap-v1.2` and so on; a `pap-*` tag is never moved or deleted.
2. Before any model touches real outcome data (gate 6 open), changes are
   amendments: dated in `docs/decisions.md`, approved by the PI, recorded in
   the gate file with the reason. This includes a change of the H4 measure
   made from cell counts alone (section 7, point 2).
3. After real outcomes have been seen, every departure is a deviation, dated
   in `docs/decisions.md` with the label "Deviation from the pre-analysis plan
   (exploratory)" or, for a correction of a coding or data error that leaves
   the specification unchanged, "Correction". Each entry states what changed,
   why, and whether the result was known when the change was made.
4. Deviations never replace a planned result: the planned specification is
   reported as planned, and the deviating one is shown apart, labeled
   exploratory. Forced deviations (a model that cannot be estimated, a
   variable that cannot be built) are reported with the reason and the
   closest feasible specification.
5. `reviews/gate-7-results.md` lists every deviation and correction, and
   `code/quarto/analysis-report.qmd` has a section "Departures from the
   pre-analysis plan".

### 6a. Simulated recovery check (simulated data only)

Simulated data only (`data/synthetic/estimate-recovery-domain-synthetic-2026-11-25.md`,
written by `code/R/tests/check_recovery_domain.R` with
`code/R/functions/simulate_domain_panel.R`; no staffing data read). IJV x
domain x year cells with the 98 real O\*NET domain scores as fixed
regressors, outcomes drawn log-linear in the shares (so the planted value is
the Poisson estimand), a domain random effect common to all IJVs, and the S13
exposure structure of `rescoring.md` 4.1 (24 exposed pairs, 231 exposed IJVs).
The noise SDs and the REG prevalence are assumptions; power figures depend on
them.

1. Static, Poisson with offset (500 draws per world of 1,000 IJVs). The
   estimator recovers the planted values: mean estimates 0.143 (H1; the
   composite of the two parent-origin categories, planted 0.15 in IJVs with a
   host-country parent), 0.050 (H2, planted 0.05), 0.154 (H3 `cd_host`,
   planted 0.15); planted nulls average 0.000 to 0.008.
2. Two-way clustering by IJV and domain does not give standard errors close
   to the sampling SD: the SD of the estimates is 1.20 to 1.43 times the mean
   two-way SE, and under the null world the one-sided 5 percent test rejects
   in 9.6 percent (H1), 11.4 percent (H2) and 7.8 percent (H3) of draws;
   95 percent intervals cover 84 to 88 percent. IJV-only errors are far worse
   (SE ratio 1.5 to 4.3; one-sided rejection 13 to 35 percent under the null).
   The shortfall persists with equal domain sizes (SE ratio 1.13 to 1.34) and
   is not removed by a cluster score bootstrap by domain (one-sided rejection
   8.4 to 11.4 percent under the null).
3. The permutation test over domains holds its size (150 draws per world of
   600 IJVs, 99 permutations: one-sided rejection 7.3 percent for H1 and 2.7
   percent for H2 under the null, within the Monte Carlo tolerance of about
   10 percent at 150 draws) and has power 0.82 (H1) and 0.77 (H2) at the
   planted effects, against 0.90 and 0.87 for the over-rejecting two-way test
   on the same draws.
4. H4a (150 draws per cell). The cluster score bootstrap by pair holds its
   size (6.7 percent with REG cells in 30 percent of IJVs, 4.7 percent with
   10 percent). Power at a planted rise of 0.10, 0.20 and 0.30 in the log
   local share of REG hiring: 0.33, 0.75 and 0.97 when 30 percent of IJVs have
   a REG cell (about 52 exposed IJVs with REG cells in 15 pairs); 0.15, 0.37
   and 0.58 when 10 percent do (about 17 exposed IJVs in 9 pairs). Minimum
   detectable effect at 80 percent power: 0.21 and 0.35 on the log scale,
   that is a rise of 23 and 42 percent in the local share of REG hiring.
   Pair-clustered standard errors are 6 to 20 percent too small (the t test
   rejects 6.7 to 8.0 percent under the null), which is why the bootstrap is
   decisive.
5. Event-study pre-test: with no planted pre-trend, the pair-clustered joint
   Wald test of the 2010 to 2012 leads rejects at the 0.10 line in 21 to 34
   percent of draws (14 to 24 percent at 0.05). Under the pre-trend rule of
   section 2 as written, H4 would fail the rule in about a quarter of samples
   with parallel trends (section 7, point 3).
6. H4b (high-REG scenario only). Test (i) holds its size (7.3 percent) and has
   power 0.30, 0.69 and 0.94 at 0.10, 0.20 and 0.30, close to H4a. The
   composition condition (ii) rarely fires falsely (4 to 6 percent), but when
   the planted rise is carried by parent-origin hires (parent share among
   local REG hires multiplied by e) it detects this in only 23 percent of
   draws, so H4b would be classified as supported in 67 percent of draws in
   which it is false.
7. Not simulated: C1 (the level panel and the Rule C contrast were decided
   after the run was set up; they need a level-panel generator) and the level
   part of H1 (covered at the function grain by the run of 2026-11-23).
8. Run time 1,727 s on 14 workers, above the 15-minute target.

### 7. Points for the PI before approval

1. Static inference. The PI decided two-way clustering by IJV and domain as
   the primary inference for H1 to H3. In the simulation these errors are 20
   to 40 percent too small whenever outcomes carry a domain-level component,
   which is almost certain with occupations, and the one-sided test has a
   size of about 0.08 to 0.11 at nominal 0.05; the permutation test holds its
   size. Proposal: make the permutation p-value (B = 999) decisive for H1 to
   H3 and report the two-way and IJV-only errors. Under the plan as written,
   core check (a) already prevents a support label on the two-way test alone,
   but partial support could rest on it.
2. H4a power depends on how many exposed IJVs have a REG cell with at least
   five employees, which is unknown. With 52 such IJVs in 15 pairs the test
   detects a 23 percent rise in the local share of REG hiring with 80 percent
   power; with 17 IJVs in 9 pairs it needs a 42 percent rise. Proposal: before
   approval, the PI instructs a count of REG cells (employees and hires only,
   no origin categories) in exposed and control IJVs before and after 2021,
   a feasibility count, not an outcome. If fewer than about 10 exposed pairs
   contribute REG cells in both periods, the PI may switch the confirmatory
   H4 measure to the broad list or to `law_gov_importance` as an amendment
   before any outcome is seen.
3. Pre-trend rule. The pair-clustered Wald pre-test over-rejects (21 to 34
   percent at 0.10 with parallel trends planted). Proposal: compute the
   pre-test from the cluster score bootstrap on one pooled 2010 to 2012 lead
   (one degree of freedom), keeping the 0.10 line. Not yet simulated.
4. C1 sign of (c). The PI's direction is that the fall of international
   parent-origin hires is stronger where the EU parent is control-linked
   under Rule C. The route-access reading predicts the opposite: a
   control-linked IJV keeps the intra-company route, so its parent transfers
   should fall less. The PI's direction holds if control-linked IJVs drew more
   of their staff from the parent under free movement and the sponsored route
   replaces that flow only in part and at higher cost. A one-sided
   confirmatory test needs its sign fixed before approval; please confirm it.
   C1 was not simulated; its power rests on the number of control-linked
   exposed IJVs, which can be counted from the ownership data alone before
   approval.
5. H4b. Test (i) is nearly the same test as H4a, because local parent-origin
   hires are a small share of local hires; the channel information sits in
   the composition condition (ii), which has little power (23 percent against
   a tripling of the parent share among local REG hires). H4b will rarely
   discriminate between channels. The decision rule treats a significantly
   positive (ii) as evidence against. A non-significant (ii) is reported as
   an interval and not read as a null finding. The composition model has to
   drop IJV x domain effects (it separates with them).
6. Wild cluster bootstrap for Poisson. No installed package does this
   (`fwildclusterboot` is not installed and covers linear models only). The
   plan uses a cluster score bootstrap with the null imposed, written by the
   agent (`score_boot()`). It held size for H4a and H4b in the simulation but
   needs review and a methods source.
7. GB-IE is one country pair and therefore one cluster; its contrast cannot be
   tested at the pair level and is read descriptively.
8. `dyad`: the codebook's identifier table defines it as the pair of parent HQ
   countries, while the S13 design clusters by parent-host pair; the plan
   proposes the host plus the largest-equity foreign parent, and gate 5
   should revise the codebook entry. The number of control pairs is not yet
   counted, and the bootstrap depends on it.
9. Proposed choices needing the PI's yes or no: H2 on all of `core_main` (not
   only IJVs with a parent in Revelio); the variable names `exposed`,
   `antic`, `reg`, `control_linked`, `uk_host`, `n_entrant`, `n_unknown`,
   `n_intl_parent_home`; the precision rule for binning the leads; the 5
   percent "small effect" reading; the Holm family of six with H4a and H4b
   (i) counted separately.
10. The three military domains (55-1, 55-2, 55-3) carry identical imputed
    scores (overall means); they are dropped in core check (c).
11. 30 exposed IJVs were formed from 2021 and have no pre-period; they add
    nothing to the H4 and C1 contrasts, and robustness 15f keeps only IJVs
    formed before 2016.

### 8. Methods references (verified 2026-11-25)

Verified by the reference-manager on 2026-11-25 and added to
`literature/references.bib` (record: `literature/zotero/verification-2026-11-25-methods.md`;
Zotero import file `literature/zotero/import-2026-11-25-methods.ris`). The
markers in this part now carry the keys.

1. Poisson pseudo-maximum likelihood with fixed effects: `wooldridge1999distributionfree`;
   `santossilva2006log`; `santossilva2011further` (overdispersion and many
   zeros; added); `correia2020fast`.
2. Multiway clustering: `cameron2011robust`.
3. Wild cluster bootstrap and few treated clusters: `cameron2008bootstrapbased`;
   `mackinnon2017wild` (unequal cluster sizes); `mackinnon2018wild` (few treated
   clusters, which fits the roughly 24 exposed dyads; added); `roodman2019fast`
   (author order Roodman, Nielsen, MacKinnon and Webb).
4. Score bootstrap: `kline2012score`.
5. Randomization inference over the assignment of a regressor:
   `young2019channeling`; the (1 + #) / (B + 1) rule: `phipson2010permutation`
   (added).
6. Pre-trend tests and sensitivity: `roth2022pretest`; `rambachan2023more`.
7. Holm step-down: `holm1979simple` (no DOI; verified from zbMATH Open).
8. Fractional response: `papke1996econometric`. It is the cross-sectional
   quasi-likelihood estimator and does not cover a logit with
   high-dimensional fixed effects, which the plan uses as a robustness check
   only.
9. Triple difference: `olden2022triple` (Olden and Møen).
10. Staggered adoption (only for an exploratory S06 analysis; S06 retired as
    fallback on 2026-11-25): `sun2021estimating`;
    `callaway2021differenceindifferences`; `borusyak2024revisiting`.
11. Software: `berge2026fixest` (the citation the `fixest` CRAN page now asks
    for; arXiv preprint) and `berge2018efficient` (FENmlm, the predecessor;
    discussion paper, no DOI). Package versions are cited once `renv.lock`
    exists.
12. Intersection-union test for C1: `berger1982multiparameter`.
13. Small-sample bias of cluster-robust variance estimators with a
    cluster-level regressor (section 7, point 1): `bell2002bias` (no DOI;
    verified from the Statistics Canada catalogue record, to be rechecked
    against the PDF); `pustejovsky2018smallsample` (a corrigendum appeared in
    2023, DOI 10.1080/07350015.2023.2174123; check before relying on CR2 with
    Satterthwaite degrees of freedom).
14. ICC(2,k) for the outside raters: `shrout1979intraclass`;
    `mcgraw1996forming` (who call the same form ICC(A,k)).

Verified but not added (DOIs in the verification record): MacKinnon,
Nielsen and Webb (2021) on two-way clustering; Weidner and Zylkin (2021) on
incidental-parameter bias in fixed-effects Poisson models; Goodman-Bacon
(2021); the R packages `did` and `HonestDiD`.

## Part C: S13 mobility channel, linked-entity rule

Settles pre-analysis plan rules, decision 8. Drafted on 2026-11-25 by a
stage 5 agent from public Home Office texts and merged by the orchestrator.

Fragment for the pre-analysis plan (gate 5). Prepared 2026-11-25 from public Home Office texts. This is a reading of the official guidance for research coding. It is not legal advice, and section 4 lists the points a lawyer should confirm.

Scope: transfers into the United Kingdom of a worker employed by an EU parent (or its group) to a UK-hosted IJV, from 1 January 2021 onward. Before 2021, EU nationals needed no UK work permission, so the link rule matters for the design only from the onset year.

### 1. The rule in 2021 and after April 2022

#### 1.1 In force in 2021 (Intra-Company Transfer route, Appendix Intra-Company Routes)

**Worker-level requirement (Immigration Rules).** An applicant on the Intra-Company Transfer route had to be currently working for the "sponsor group" and, unless a high earner, had to have worked outside the UK for the sponsor group for a cumulative 12 months (Appendix Intra-Company Routes, IC 5.7 and IC 5.8). The Rules define "sponsor group" as the sponsor plus any business linked to it by common ownership or control, or by a joint venture on which the applicant is sponsored to work (Introduction, paragraph 6.2). The Rules themselves set no shareholding threshold and do not define "joint venture".

**Sponsor-level test (Home Office sponsor guidance).** The guidance lists the ways a UK sponsor may show a direct link by common ownership or control with the overseas entity the worker comes from (Sponsor an Intra-Company worker, version 04/21, ICW2.8). In paraphrase, the qualifying links are:

1. one entity controls the composition of the other's board;
2. one entity holds shares carrying more than half of the voting rights in the other;
3. both have a common parent that meets test 1 or 2, directly or through other entities;
4. the two entities are both parties to a joint venture agreement;
5. one entity is a party to a joint venture agreement and the other is the entity formed by that agreement;
6. and 7. the same two joint venture links where joint ventures are not legally permitted in the country of operation, or one entity may not enter them there;
8. and 9. trademark or shared-name agreements between law or accountancy firms;
10. for unincorporated associations, documentary evidence that one controls the other.

Where the link runs through an individual who owns shares in both entities, that individual must hold a majority shareholding in each (ICW2.9). The supporting documents in Appendix A of the sponsor guidance must be sent at licence application (ICW2.10).

**Joint venture conditions.** Where the link is a joint venture, the Home Office must be satisfied that the worker will work as part of the joint venture agreement (ICW2.11). The sponsor shows that the venture is in operation, for example with Companies House numbers and the owners of a newly formed company, public announcements, or a signed binding contract that sets out the investment or ownership arrangement (ICW2.12, a non-exhaustive list, ICW2.13). Informal cooperation agreements are not accepted, the venture must already be operating, and there must be a need for the worker in the UK as part of the agreement (ICW2.14).

**No stake threshold for the joint venture link.** None of the joint venture bullets in ICW2.8 to ICW2.14 sets a minimum equity share for the parent. The only numeric thresholds in the section are "more than half of the voting rights" (test 2) and the individual-shareholder majority rule (ICW2.9). The guidance does not define "joint venture agreement".

**Version in force on 1 January 2021.** The 04/21 version (valid from 6 April 2021) replaced version 12/20. Its change table lists no change to ICW2.8 to ICW2.14, which implies the same wording applied from January 2021. I could not retrieve the 12/20 PDF itself (not archived), so that inference is **[unverified against the 12/20 text]**. Part 1 of the sponsor guidance (version 10/21, valid from 11 October 2021, L5.6) points back to section ICW2 for the assessment of common ownership or control, so the test was unchanged through 2021 as far as Part 1 shows. I did not check whether a later 2021 version of the Intra-Company guidance (for example a 10/21 edition) changed ICW2. **[unverified]**

#### 1.2 From 11 April 2022 (Global Business Mobility: Senior or Specialist Worker)

The Senior or Specialist Worker route replaced the Intra-Company Transfer route. Version 04/22 of the sponsor guidance was published on 11 April 2022, according to the change note in version 06/22. The worker-level requirement in the Rules is unchanged in substance: the applicant must be currently working for the sponsor group and, unless a high earner, must have worked outside the UK for it for a cumulative 12 months (Appendix Global Business Mobility routes, SNR 5.7 and SNR 5.8, page updated 29 October 2026). The "sponsor group" for Senior or Specialist Worker still includes businesses linked by a joint venture on which the worker is sponsored to work (sponsor guidance glossary, current GBM guidance; caseworker guidance, section 14.1).

The sponsor-level list of links is carried over unchanged, including the four joint venture bullets, the individual-shareholder majority rule and the joint venture evidence and "already operating" conditions. In version 06/22 these are GBM2.11 (list), GBM2.12 (individual majority rule) and GBM2.13 to GBM2.16 (joint venture conditions). In version 04/26 they are GBM2.10 (route table), GBM2.12 (list), GBM2.13, and GBM2.15 to GBM2.18. The 06/22 change table records changes only to GBM2.20, GBM3.15 to GBM3.16 and housekeeping. I did not retrieve the 04/22 PDF itself, so identity of 04/22 and 06/22 on these paragraphs is an inference **[unverified against the 04/22 text]**.

**The one substantive change after 2021 does not concern this design.** For the new UK Expansion Worker route, joint venture links are expressly excluded and only the first four bullets (board control, voting majority, common parent, branch) apply (GBM2.14 in version 04/26). This does not affect Senior or Specialist Worker, which is the successor of the Intra-Company Transfer route.

The current caseworker guidance (version 15.0, 3 August 2026) mentions joint ventures only in the list of eligible linked businesses (section 14.1). It gives no definition of a joint venture and no shareholding threshold.

#### 1.3 Sources

| # | Title | Issuing body | Version or date | URL (as retrieved) | Paragraphs | Short quote (one per source) |
|---|---|---|---|---|---|---|
| S1 | Workers and Temporary Workers: Sponsor an Intra-Company worker | Home Office | Version 04/21, applies from 6 April 2021 (replaces 12/20) | Original PDF https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/975861/2021-04-01_Sponsor-an-Intra-Company_worker-04-21_v1.0.pdf, retrieved from the Internet Archive capture of https://web.archive.org/web/20210621090144/https://www.gov.uk/government/publications/workers-and-temporary-workers-sponsor-an-intra-company-worker | ICW2.8 to ICW2.14; ICW3.4 to ICW3.6; "Sponsor group" in About this guidance; change table | "both are party to a joint venture agreement" (ICW2.8) |
| S2 | Immigration Rules Appendix Intra-Company Routes | Home Office | gov.uk page updated 7 April 2021 | https://web.archive.org/web/20210417191819/https://www.gov.uk/guidance/immigration-rules/immigration-rules-appendix-intra-company-routes | IC 5.1(e), IC 5.7, IC 5.8 | "be currently working for the sponsor group" (IC 5.7) |
| S3 | Immigration Rules: Introduction | Home Office | gov.uk page updated 7 April 2021 | https://web.archive.org/web/20210417180335/https://www.gov.uk/guidance/immigration-rules/immigration-rules-introduction | 6.2, definition of "Sponsor group" | "a joint venture on which the applicant is sponsored to work" (6.2) |
| S4 | Workers and Temporary Workers: guidance for sponsors Part 1, apply for a licence (accessible version) | Home Office | Version 10/21, valid from 11 October 2021 | https://web.archive.org/web/20210719065812/https://www.gov.uk/government/publications/workers-and-temporary-workers-guidance-for-sponsors-part-1-apply-for-a-licence/workers-and-temporary-workers-guidance-for-sponsors-part-1-apply-for-a-licence-accessible-version (the archive served the 10/21 text; exact capture date not recorded) | L5.6 | none needed |
| S5 | Workers and Temporary Workers: sponsor a Global Business Mobility worker (accessible version) | Home Office | Version 06/22, valid from 24 June 2022 (replaces 04/22, published 11 April 2022) | https://web.archive.org/web/20221025184640/https://www.gov.uk/government/publications/sponsor-a-global-business-mobility-worker/workers-and-temporary-workers-sponsor-a-global-business-mobility-worker-accessible-version | GBM1.4, GBM2.11 to GBM2.16; change table | "we must be satisfied that the worker will be working as part of" (GBM2.13) |
| S6 | Workers and Temporary Workers: sponsor a Global Business Mobility worker (accessible) | Home Office | Version 04/26, valid from 8 April 2026 | https://www.gov.uk/government/publications/sponsor-a-global-business-mobility-worker/workers-and-temporary-workers-sponsor-a-global-business-mobility-worker-accessible | GBM1.4, GBM2.9 to GBM2.18; glossary "sponsor group" | "not accepted on this route" (GBM2.14, UK Expansion Worker only) |
| S7 | Immigration Rules Appendix Global Business Mobility routes | Home Office | gov.uk page updated 29 October 2026 | https://www.gov.uk/guidance/immigration-rules/immigration-rules-appendix-global-business-mobility-routes | SNR 5.1(e), SNR 5.7, SNR 5.8 | none needed |
| S8 | Global Business Mobility routes: caseworker guidance (accessible) | Home Office | Version 15.0, 3 August 2026 | https://www.gov.uk/government/publications/global-business-mobility-routes-caseworker-guidance/global-business-mobility-routes-caseworker-guidance-accessible | Section 14.1 | "linked to the sponsor by common ownership or control" (14.1) |

Retrieval notes. The National Archives web archive returned a human-verification page to automated requests, which I did not try to get around. The 2021 and 2022 versions were therefore taken from the Internet Archive (Wayback Machine) copies of the gov.uk pages and PDFs listed above. A version 04/24 PDF of the GBM guidance, retrieved by accident through a redirected 2022 asset link, has the same list and joint venture conditions. The 04/22 and 12/20 PDFs were not archived. No law-firm text was used as a source for any rule.

### 2. Coding rule for the plan

Unit: UK-hosted IJV i with EU parent p, by year. Inputs: p's direct equity share in i (s_ip) from Orbis and Capital IQ; voting-rights and board data where available; an indicator that i was formed by, or operates under, a joint venture agreement to which p is a party (in this study, the IJV sample definition: i is a separately incorporated entity co-owned by two or more parents, at least one of them EU-based).

**Rule L (legal eligibility, primary).** Code `linked_ip = 1` for every year from 2021 in which p is a party to the joint venture that formed i, whatever the size of s_ip. Basis: S1 ICW2.8 (bullets 4 and 5) for 2021 to 10 April 2022, and S5 GBM2.11 and S6 GBM2.12 for 11 April 2022 onward. The guidance sets no stake threshold for a joint venture link, so minority (s_ip < 50), equal (s_ip = 50) and majority (s_ip > 50) parents are all coded linked. Code `linked_ip = 0` only when p holds equity in i without being a party to the joint venture (for example a later portfolio investor that entered by share purchase with no joint venture agreement), or when the joint venture has ended.

**Rule C (control link, sensitivity).** Code `linked_ctrl_ip = 1` when p holds more than 50 percent of the voting rights in i, or controls the composition of i's board (S1 ICW2.8 bullets 1 and 2; S6 GBM2.12 bullets 1 and 2). Where only equity data exist, use s_ip > 50 as the proxy for voting control. Code the case s_ip = 50 as not control-linked unless board-control evidence exists, because the test requires more than half of the votes. Minority parents are not control-linked. Under Rule C, the link does not depend on the joint venture conditions (worker working as part of the JV, venture already operating, binding agreement), so it identifies the lower-friction path.

**Stake bands for reporting.** Report results for three bands of s_ip: below 50, exactly 50, above 50. Under Rule L all three are linked. Under Rule C only the band above 50 (and board-control cases) is linked.

**Group affiliates of the parent.** When the transferring worker's employer is a subsidiary of p rather than p itself, the link to i under Rule L is not clearly covered by the text (see section 4). Code such affiliates as linked only under the parent-level coding and flag them `affiliate_link_uncertain = 1`. Where Revelio does not let the study tell p apart from its affiliates, the parent-group level is the unit and this flag is reported as a limitation.

**Timing.** The rule is the same for 2021 and for the years after 11 April 2022, so no break in coding is needed at the route change. The pre-period (before 2021) needs no link coding for EU-national transfers, because those workers needed no UK work permission.

### 3. Clear enough to code one way?

On the narrow question asked, the guidance is clear: the stake does not decide eligibility. A parent that is a party to the joint venture agreement, or whose joint venture formed the UK entity, is linked whatever its share, and this held in 2021 and holds after April 2022. On the text, a minority-held IJV can sponsor its EU parent's staff on the intra-company route.

I still recommend that the plan estimate the mobility-channel term both ways (Rule L as primary, Rule C as the pre-specified alternative), for three reasons.

First, the guidance does not define "joint venture agreement". Orbis and Capital IQ report equity shares, not whether a binding JV agreement exists or whether a given parent is a party to it. Some minority holders in the sample may be investors rather than JV parties, and Rule L treats them as linked only if they are JV parties.

Second, the joint venture link carries conditions that the control link does not: the worker must work as part of the joint venture, the venture must already be operating, and the sponsor must document the agreement (ICW2.11 to ICW2.14; GBM2.13 to GBM2.16 in 06/22). Eligibility may be the same on paper while the cost and refusal risk of a transfer differ by stake, which is a plausible reason why the channel could work more strongly in majority-held IJVs. Rule C captures that low-friction path.

Third, if Rule L holds for all sample IJVs, linked status does not vary across IJVs, and the mobility-channel term cannot be identified from linked versus not linked under Rule L alone. Any cross-IJV variation in the channel then has to come from the stake (Rule C), from whether the IJV holds an intra-company or GBM sponsor licence, or from parent nationality. The plan should state this before estimation, so that the choice of contrast is not made after seeing the outcomes.

Suggested plan wording: "Under the Home Office sponsor guidance in force from 2021 (Sponsor an Intra-Company worker, version 04/21, ICW2.8 to ICW2.14) and after 11 April 2022 (Sponsor a Global Business Mobility worker, GBM2.11 to GBM2.16 in version 06/22), a UK entity formed by a joint venture agreement is linked to each parent that is a party to that agreement, whatever the parent's equity share. We code all EU parents that are joint venture parties as linked (primary). Because the joint venture link carries documentation and assignment conditions that a control link does not, we also estimate the mobility-channel term with a control-based coding, linked if the EU parent holds more than 50 percent of the voting rights or controls the board (sensitivity), and we report both."

### 4. Open points for a lawyer to confirm

1. Whether the 12/20 version of Sponsor an Intra-Company worker (in force 1 January to 5 April 2021) had the same wording as 04/21 at ICW2.8 to ICW2.14, and whether any later 2021 edition changed it. **[unverified]**
2. Whether the 04/22 version of the GBM guidance (11 April to 23 June 2022) had the same wording as 06/22 at GBM2.11 to GBM2.16. **[unverified]**
3. What the Home Office accepts as a "joint venture agreement" in practice. In particular, whether a minority equity holding together with a shareholders' agreement suffices, or whether a separate JV contract is expected, and whether a parent that bought into an existing UK company later counts as a party.
4. Whether employees of a parent's subsidiaries or sister companies (not the parent entity itself) count as part of the sponsor group of a UK JV. The common-parent bullet requires board or voting control, not a JV link, and the guidance does not say how JV links chain through a parent's group.
5. How the "worker will be working as part of the joint venture" condition is applied: whether any role in the UK JV entity qualifies, or only roles tied to the JV project named in the agreement.
6. Whether a 50/50 parent with contractual board-appointment rights is treated as controlling board composition (bullet 1), which would make it control-linked as well as JV-linked.
7. Whether refusal rates or caseworker practice differed in fact for JV-based links compared with control-based links in 2021 to 2023. This bears on whether Rule C is the right proxy for the low-friction channel.
8. Whether the UK JV needed its own sponsor licence on the intra-company or GBM route, or could rely on a parent's or a group licence. This affects which IJVs could use the channel in practice.
9. Which Statement of Changes to the Immigration Rules introduced Appendix Intra-Company Routes and Appendix Global Business Mobility, and their commencement dates. I did not retrieve the statements from legislation.gov.uk or gov.uk. **[unverified]**
10. Whether the Skilled Worker route, which needs no link but has a lower skill threshold, should count as a parallel mobility channel in the design. This is a design question rather than a legal one.

## Deliverables

| Deliverable | Path | Notes |
|---|---|---|
| Part A: hypotheses and measurement | this file | merged 2026-11-25 |
| Part B: estimation | this file | merged 2026-11-25 |
| Part C: S13 linked-entity rule | this file | merged 2026-11-25 |
| Contingency scores and domains | `data/processed/contingency-scores-*-v1-2026-11-25.csv`, `code/R/07_contingency_scores.R` | O\*NET only; checks in `data/interim/contingency-scores-v1-2026-11-25.md` |
| H4 feasibility count | `code/R/08_feasibility_reg_cells.R`, `data/interim/feasibility-reg-cells-2026-11-25.md` | structural counts only |
| Pre-trend simulation | `code/R/tests/check_pretrend_pooled.R`, `data/synthetic/pretrend-pooled-synthetic-2026-11-25.md` | simulated data only |
| Audit sample and worksheet (831 flagged IJVs) | `code/R/09_audit_parent_family_sample.R`, `data/interim/audit-parent-family-worksheet-2026-11-25.xlsx` (gitignored), `docs/coauthor-notes/audit-parent-family-guide-2026-11-25.qmd` | coding pending |
| Outside-rater instrument | `docs/coauthor-notes/rater-instrument-2026-11-25.qmd`, `code/R/10_rater_sheet.R`, `data/interim/rater-sheet-*.xlsx` (gitignored) | licence question and comparison rule open |
| Simulated recovery check at the domain grain | `data/synthetic/estimate-recovery-domain-synthetic-2026-11-25.md`, `code/R/tests/check_recovery_domain.R`, `code/R/functions/simulate_domain_panel.R` | simulated data only; 500 draws for the static tests, 150 for H4; the mobility test (C1) and the level part of H1 not simulated |

## Quality checks run

- Independence: neither drafting agent opened a staffing tabulation; the
  only staffing information used is pooled counts already quoted in
  `reviews/gate-4-pilot.md`, cited by section.
- Citation keys: all 24 keys in parts A and C exist in
  `literature/references.bib` (checked by the orchestrator, 2026-11-25).
  The Home Office sources of part C are cited by title, version and URL and
  are not yet in the bibliography.
- Style: no em dashes in the merged text.
- Consistency: the hypotheses agent listed ten inconsistencies between
  decided items; the domain count, the count of unrated codes, the S13
  window and the H4 moderator are corrected above; the rest are in
  part A6 (proposed edits).
- Part B: no placeholders, no em dashes; its methods references are
  verified keys in `literature/references.bib` (27 added on 2026-11-25;
  part B, section 8).
- Simulated recovery (simulated data only): the Poisson estimator recovers
  the planted effects for H1 to H3 (0.143, 0.050, 0.154 against 0.15, 0.05,
  0.15). Two-way (IJV, domain) errors are 20 to 43 percent too small, with
  one-sided size 0.078 to 0.114 at a nominal 0.05; IJV-only errors are
  worse. The permutation test over domains holds its size (0.073 and 0.027)
  with power 0.82 and 0.77. H4a: bootstrap size 0.067 and 0.047; the effect
  detectable with 80 percent power is a 23 percent rise in the local share
  of REG hiring if 30 percent of IJVs have a REG cell, and a 42 percent rise
  if 10 percent do. The pair-clustered pre-trend Wald test rejects in 21 to
  34 percent of draws at the 0.10 line with parallel trends.
- Pooled-lead pre-trend test (simulated data only, 200 draws per cell,
  `data/synthetic/pretrend-pooled-synthetic-2026-11-25.md`, scenario close to
  the broad-list count: about 39 exposed IJVs in 13 pairs, 126 control
  pairs): size 0.095 at the 0.10 line under parallel trends (0.080 to 0.150
  across cells). Power against a linear pre-trend is low: 0.105, 0.135 and
  0.19 for trends of 0.01, 0.02 and 0.03 per year, which put a bias of about
  0.10, 0.21 and 0.31 into H4a; H4a then rejects falsely in 30, 70 and 94
  percent of draws, as often among draws that pass the pre-test. H4a in this
  scenario: bootstrap size 0.060, detectable effect at 80 percent power 0.234
  on the log scale (a 26 percent rise); pair-clustered errors 10 to 27
  percent too small, so the bootstrap stays decisive.

## Known weaknesses and uncertainties

- Prior exposure: the staffing tabulations of 2026-11-23 were seen before
  the measures were fixed, so the static tests are confirmatory in
  direction but not blind in measurement (part A5).
- `coord_dependence` measures coordination inside the organization, not
  dependence on the IJV's parents (route to gate 5, decision 3).
- O\*NET rates US occupations; transfer to IJVs elsewhere is supported for
  generalized work activities (`taylor2008transportability`) but not tested
  for the work-context items, and task content varies across countries
  (`lewandowski2022technology`; `caunedo2023technology`).
- O\*NET's work-context domain is being revised: a report of August 2026
  proposes new codes for the three job-interaction elements (4.C.1.b.1.e, f
  and g) and deletes Contact With Others (4.C.1.a.4)
  (`literature/search/s10-onet-targeted-2026-11-25.md`). The plan is tied to
  the O\*NET 31.0 Database as downloaded on 2026-11-25 (hash in
  `data/data-log.md`), so later releases do not change the scores.
- H4 rests on few exposed country pairs (23 to 24 after thresholds), so
  its power is limited; part B reports it.
- Part C: the wording in force on 1 January 2021 and in April 2022 is
  inferred from change tables (`[unverified]`); the data do not show which
  parents are parties to a JV agreement.
- Static inference: the decided two-way clustering over-rejects in the
  simulation whenever outcomes carry a domain-level component; only the
  permutation test holds its size (part B, section 7, point 1).
- H4a power: with the broad list, 38 exposed IJVs in 16 pairs carry REG
  cells in both periods, close to the simulation's 30 percent scenario
  (about 52 IJVs in 15 pairs, detectable rise about 23 percent); the test
  remains modest in power. The mobility test rests on 59 control-linked
  UK-hosted IJVs.
- The pre-trend rule as written fails H4 in about a quarter of samples with
  parallel trends (point 3).
- H4b test (i) nearly duplicates H4a, and the composition condition has
  little power, so H4b rarely separates the channels (point 5).
- No package offers a wild cluster bootstrap for Poisson; the plan relies on
  the agent's score bootstrap, which held size but needs review (point 6).
- GB-IE is a single cluster, so its contrast is descriptive (point 7).
- Registration rests on a Git tag in a public repository, not on a registry
  entry: a tag can be moved or deleted and history rewritten, so a reviewer
  may give it less weight as evidence of timing (PI, 2026-11-25, chat item 16).
- Open `[CITE]` and `[DATA]` markers are listed in parts A and B.

## Decisions required from the PI

All settled; the gate was approved on 2026-11-25 (chat item 21).
Settled on 2026-11-25 (see "Decisions in chat during stage 5"):

1. Mobility-channel contrast: Rule C (item 3).
2. The mobility-channel test is confirmatory on the level panel (item 4).
3. Seniority-to-level mapping (item 5).
4. Part A5 kept and extended (item 6).
5. Permutation p-value decisive for H1 to H3 (item 7).
6. Feasibility count run; the broad list is the confirmatory H4 measure
   (item 8).
7. Pre-trend rule: the pooled-lead bootstrap test (item 9), simulated on
   2026-11-25 ("Quality checks run").
8. Part (c) of the mobility test two-sided and secondary (item 10).
9. Mobility test labeled C1 (item 11).
10. The six smaller choices of part B (item 12).

11. Causal language for H4a: pre-test and `HonestDiD` bound (item 13).
12. S13 control group: the 104 owner-linked IJVs dropped (item 14).

No decision from parts A to C is open. Open before approval (see "Items
this plan still has to settle"): the full texts and the G2 re-run, the audit
of the 831 flagged IJVs, the outside raters, and the `[CITE]` markers.

## Proposed changes to earlier stages

- `docs/workflow.md`, lines 53 to 54 ("Stage 5 needs G2, G3, G4 and G5a"): add that, by the PI's decision of 2026-11-24, stage 5 proceeds without G3 while the qualitative study is set aside, with a pointer to `docs/decisions.md`.
- `data/codebook.md`, section "Shock": the S13 exposure definition (pairs, onset, variants), proposed by `literature/shock-scan/rescoring.md`, section 12.
- `data/README.md` and the folder map: mention `data/raw/external/` for public source files.
- Part A6 lists the further edits the plan implies (`code/R/functions/measures.R`, `data/codebook.md` dependent-variable sections, `docs/research-brief.md` through the G2 re-run, the skill and agent files that still ask for H1 to H5, stale items in `docs/decisions.md`, the design paragraph of `CLAUDE.md` for the PI, `code/R/tests/synthetic_panel.R`).
- `literature/references.bib`: add the Home Office sponsor guidance versions cited in part C through `/references`.
- `literature/references.bib`: add the sources the plan cites for the shocks (ASPI 2020, Bauerle Danzman and Meunier 2023, Regulation (EU) 2019/452, the EC list) through `/references`.

## PI notes (filled in by the PI; applied by the orchestrator if status is APPROVED WITH CHANGES)

- 
