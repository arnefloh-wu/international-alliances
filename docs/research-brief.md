# Research Brief: Whom IJVs hire. Geographic and organizational origin of staff across functions and levels

Date: 2026-11-22. Version 0.1, produced by `/research-ideation`.
Feasibility counts added on 2026-11-23 (see "Feasibility Dependencies").
Status: draft for the PI and co-authors; nothing here is decided.

Assumes: gate 1 approved; gates 4 and 5a pending; gates 2, 3 and 5 not
reached. No literature synthesis (Stage 2) and no interview recoding
(Stage 3) exist yet. This brief revises the idea in
`initial-research-idea.md` where that document measures cross-partner
integration; it does not replace the theory hierarchy in
`docs/theory-framework.md`.

Reading note on evidence. Citation keys refer to `literature/references.bib`.
What each cited work shows is stated from the titles and from general
knowledge of these works, not from a full-text reading in this run, and has
to be confirmed at Stage 2. Works that are needed but not in the
bibliography carry a `[CITE: ...]` marker. No Consensus search was run,
because the search allowance is an open item in `docs/decisions.md`.

## Core Question

How do international joint ventures combine parent-based and independent
recruitment from local and international labor markets, and how do the
contingencies of functions and hierarchical levels, and changes in those
contingencies, shape the combination?

## Staffing Frame

Every employee who joins an IJV is classified on two dimensions from the
position held before the IJV spell (codebook rule: most recent position at
another employer within `origin_window` years).

| | Prior position in a parent's group | Prior position outside both parents' groups |
|---|---|---|
| **Prior position in the host country** | Local parent-origin hire | Independent local hire |
| **Prior position abroad** | International parent-origin hire | Independent international hire |

A fifth class, **history not observed**, holds employees with no prior
position on record. It is reported on its own and is never added to the
independent hires. Where the data allow it, the class is split into labor
market entrants (education ends shortly before the IJV spell) and unknown.

Measures are the shares of the four categories among employees with an
observed history, computed twice: for the **stock** (employees in the cell
on 30 June) and for the **hiring flow** (employees who joined the cell in
the year). The unit of analysis is the IJV x function x year, with a
parallel IJV x hierarchical level x year panel.

Two definitional points need a decision (see Decisions for the PI):

1. "Local parent-origin" as defined above means a parent-group employer
   located in the host country. This includes the foreign parent's own
   host-country subsidiary. The stricter reading in feasibility question Q1
   (the host-country parent's group only) needs the parents to be labeled
   local and foreign, which the matched dataset does not do: parent A is the
   larger shareholder.
2. Some IJVs have no host-country parent (both parents are foreign to the
   host). For them the local parent-origin cell is nearly empty by
   construction. This is used as a boundary condition, not treated as noise.

## Theoretical Contribution

Research on the staffing of foreign units separates parent-country from
host-country nationals and explains the mix by control, knowledge transfer
and institutional distance (`gong2003subsidiary`, `gaur2007institutional`,
`harzing2001whos`). In a wholly owned subsidiary the two dimensions used
here largely coincide: staff from the parent come from abroad, and local
staff come from the market. An IJV with a host-country parent breaks this
coincidence. It can localize by hiring from its local parent, which leaves
its dependence on the parents unchanged, or by hiring from the open labor
market, which reduces it.

The brief argues, with structural contingency theory
(`lawrence1967organization`), that the two dimensions answer to different
contingencies. Geographic origin follows a domain's dependence on the host
environment. Organizational origin follows its dependence on coordination
with the parents and on parent-specific knowledge. The staffing
configuration of an IJV is therefore differentiated across functions and
levels on two axes, and a change in one contingency moves staffing along one
axis without moving it along the other. The contribution to contingency
reasoning in international business is the interorganizational case: the
unit has two sources of integration, and localization and independence from
the parents are separate outcomes.

## Hypotheses

Contingency scores (`coord_dependence`, `local_embeddedness`) are assigned
to functions and levels before the staffing data are examined, from the
interview recoding (gate 3). All hypotheses are stated at the contingency
level. No shock is named.

**H1 (organizational origin).** The more a function or hierarchical level
depends on coordination with the parents' activities and on parent-specific
knowledge, the larger its share of parent-origin hires (local and
international together) relative to independent hires.
Mechanism: a parent-origin hire carries the parent's routines, its tacit
knowledge and personal ties into the parent organization, which lower the
cost of coordinating interdependent tasks. A market hire has to build all
three after entry.

**H2 (geographic origin).** The more a function depends on host-country
institutions, labor markets, customers and regulators, the larger its share
of locally recruited hires (parent-origin and independent together) relative
to international hires.
Mechanism: locally recruited staff hold host-specific knowledge and
relationships and are accepted by local stakeholders. H2 uses one dimension
only. It is kept because H3 is defined on its outcome.

**H3 (channel of localization; anchor hypothesis, chosen by the PI on
2026-11-22).** Among locally recruited hires, the share with prior
employment in a parent's group increases with the function's coordination
dependence. Localization runs through a parent's local workforce where
coordination dependence is high and through the open host labor market
where it is low.
Mechanism: a locally embedded function that also depends on coordination
with the parents needs two things from a hire, host-specific knowledge and
parent-specific knowledge. Only a hire from a parent's host-country
workforce brings both. Where coordination dependence is low, the second is
not needed and the wider market offers more candidates at lower cost.
Boundary condition: the relationship is weaker or absent in IJVs without a
host-country parent.

**H4 (dynamic form of H3).** When a change in the environment raises the
local-embeddedness requirement of a domain, the share of locally recruited
hires in new hiring rises more in that domain, and the rise consists of
parent-origin hires where coordination dependence is high and of independent
hires where it is low.
Mechanism: the change alters one contingency. Coordination dependence is
unchanged, so the organization regains fit on the geographic axis while
holding its position on the organizational axis.

| | Novelty | Testability | Risk | IJV-specific | Separability from bargaining power |
|---|---|---|---|---|---|
| H1 | Medium. Restates the original H1 and H3 as a hiring-source prediction | Pooled parent-origin share; stock and flow; function-year and level-year. Rests on Q3, Q5, Q6 (partly answered) | Parent-origin staff are 2 to 4 percent of person-years, and seconded staff are probably missed most where H1 expects the most. Bias runs against H1 | Partly. For a subsidiary this is the expatriate question with one parent | IJV x year fixed effects absorb ownership shares; the test uses variation across domains within the IJV |
| H2 | Low | Local versus international among observed histories; stock and flow. Rests on Q2, Q3, Q6 (partly answered) | Low risk of a null; low interest alone | No. Holds for subsidiaries too | As H1 |
| H3 | High | Local parent-origin against independent local hires; function-year; flow preferred. Rests on Q1, Q3, Q6 (open). **Provisional** | Sparsest cell of the frame. A null may reflect measurement, not theory | Yes. The cell exists at scale only where there is a host-country parent | As H1, plus the contrast with IJVs that have no host-country parent |
| H4 | High | As H3, hiring flows, before and after a contingency change. Rests on Q1, Q3, Q6, Q7 (open). **Provisional** | Highest. Needs a shock with enough exposed IJVs and a sparse cell | Yes | Shock x domain interaction with IJV x function and function x year effects |

## Feasibility Dependencies

Status as read on 2026-11-22 from `reviews/gate-4-pilot.md` (pilots of
2026-10-08, full frame of 2026-10-09) and
`docs/coauthor-notes/gate-4-options-2026-10-10.qmd`.

| Hypothesis | Rests on | Status | If the answer is no |
|------------|----------|--------|---------------------|
| H1 | Q3 (missing histories), Q5 (parent staff missing from Revelio), Q6 (cells per category) | Partly answered: parent A plus B is 4.4 percent of person-years in pilot 1 and about 2.3 percent in pilot 2; 47.0 and 49.4 percent have no prior position | Test H1 at senior levels on BoardEx (1,207 IJVs with a parent-linked senior person), as in option B of the co-author note |
| H2 | Q2, Q3, Q6 | Partly answered: external host-country hires 36.0 and 37.0 percent, external international hires 12.7 and 11.2 percent of person-years in the two pilots | Not expected |
| H3 | Q1 (parent-origin hires by location and by parent), Q3, Q6 | Open | Collapse to three categories (parent-origin pooled, independent local, independent international). H3 is dropped and the paper becomes option A of the co-author note with a geographic split of independent hires |
| H4 | Q1, Q3, Q6 for hiring flows, Q7 (shock) | Open | Keep H4 on the geographic axis only (the original H4), which loses the two-dimensional claim |

Update of 2026-11-23. The PI had the tabulations below run
(`code/R/wrds/11_staffing_tabulations.R`); the counts are in
`reviews/gate-4-pilot.md`, section "Staffing tabulations", and replace the
status column above for Q1 to Q6. In short: 6,600 of the 7,460 IJVs have a
host-country parent and 860 do not (Q1). Local parent-origin hires number
31,121 (0.8 percent of hires) in 1,852 IJVs, of which 828 have five or more
and 999 have them in three or more hire years; 23,190 of these hires come
from the host-country parent's group (Q1, Q6). Independent international
hires are 18.6 percent of hires (Q2). 30.1 percent of hires and 42.9 percent
of person-years have no observed history, falling to 16.9 percent of hires
in 2020 to 2026 (Q3). Revelio education records, pulled the same day,
identify 467,895 of the unobserved hires as labor market entrants (first
recorded job within three years of the end of education), about half of
them educated in the host country; 654,483 hires (17.6 percent of hires,
9.6 percent in 2020 to 2026) stay unknown (Q3). Annual unconsolidated Orbis
headcounts, also pulled, exist for 3,912 IJVs, almost only from 2015 on; the
median Revelio-to-Orbis ratio rises from 0.31 in 2015 to 0.67 in 2024 and
falls steeply with IJV size, so it serves as a control or sample
restriction and not as a count of missing staff (Q4). Of 1,144 IJVs with a
parent-linked senior person in BoardEx and a parent in Revelio, 482 show no
parent-origin hire in Revelio (Q5). Consequences for the hypotheses: H1, H3
and H4 can be estimated only where a parent has a Revelio entity (5,882 IJVs
with at least one, 2,321 with all); H3 has support in roughly 800 to 1,000
IJVs, and its contrast group without a host-country parent is small (67 IJVs
with five or more local parent-origin hires); hiring flows from about 2010
are better observed than stocks; and entrants need a place in the staffing
frame, since they have a place of education but no prior employer and so
bear on H2 only. H3 stays provisional on a narrower ground:
whether that support is enough once it is divided by function, and, for H4,
by exposure to a shock (Q7, not counted).

Tabulations proposed for the data-engineer, from the matched dataset
(`data/processed/ijv-employee-spells-*`, career histories):

1. Label each parent as host-country or foreign (direct shareholder country
   and GUO country, both) and count IJVs with and without a host-country
   parent in `core_main` and in the strategic subset. (Q1)
2. Count hires in each of the four categories and in "history not
   observed", for stocks and flows, by function (`role_k10_v3`), seniority
   and year; report the number of IJVs with at least one hire and with at
   least five hires per category. (Q1, Q2, Q6)
3. Split "history not observed" into labor market entrants and unknown,
   using education end dates if Revelio provides them for these users. (Q3)
4. Compare Orbis unconsolidated headcount with the Revelio count by IJV and
   year, as a coverage ratio. Do not compute parent-origin staff as the
   difference. (Q4)
5. Compare the Revelio coverage ratio and the parent-origin share between
   IJVs with and without a parent-linked senior person in BoardEx. (Q5)

Tabulations 1 to 3 need the parent-origin classification, which
`docs/decisions.md` (2026-10-09) holds back until gate 5. They need the PI's
instruction to run early. They are counts of the staffing categories, not
outcomes by shock exposure, so they do not touch the rule that the shock is
not chosen by its results, provided they are never broken down by exposure
group.

## Proposed Design

- Sample: `core_main`, 7,460 IJVs, of which 2,172 strategic (two
  operating-firm parents), as recorded on 2026-10-09 and read on 2026-11-22.
  H3 and H4 are tested on IJVs with a host-country parent; IJVs without one
  serve as the contrast. The strategic subset is the main sample for
  everything that uses parent origin, because the audit found that about
  half of the wider core are investor-owned firms, not joint ventures
  between operating companies.
- Method: exploratory sequential mixed method. Recoding of the existing
  manager interviews (Stage 3) yields the contingency scores and checks
  whether respondents describe the two hiring routes. Archival panel in R
  from Orbis and Capital IQ ownership matched to Revelio, with BoardEx for
  senior levels.
- Key measures: shares of the four categories among hires with an observed
  history, as stocks and as flows; the share of "history not observed" as a
  separate outcome and as the basis for bounds; `coord_dependence` and
  `local_embeddedness` per function and level; indicator for a host-country
  parent.
- Identification strategy: static hypotheses from variation across domains
  within the IJV-year (IJV x year fixed effects), with fractional response
  and count models because most cells hold no parent-origin hire. Dynamic
  hypothesis from a shock x domain-contingency interaction with IJV x
  function and function x year effects, as an event study or
  difference-in-differences once the shock is chosen at gate 5, after
  pre-trends are checked.
- Shock: not chosen. Candidates and their provisional scores are in
  `literature/shock-scan/recommendation.md` (gate 5a pending). H4 needs a
  candidate that raises local embeddedness in some domains and leaves
  coordination dependence unchanged.

## Anticipated Contribution

- To theory: localization and dependence on the parents are separate
  dimensions of IJV staffing that answer to different contingencies; the
  contingency logic of differentiation is extended to a unit with two
  parents.
- To practice and policy: partners and host governments that count local
  staff as a sign of an IJV's independence may misread it where the local
  staff come from the local parent.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Local parent-origin hires are too few to estimate H3 and H4 | Tabulation 2 before any hypothesis is fixed; flows pooled over years; count models; fallback in the dependency table |
| Seconded staff list the parent as employer and are missing from the IJV in Revelio | BoardEx comparison (Q5); state the direction of the bias (against H1); senior-level supplement on BoardEx |
| Missing histories are read as independent hires | Fifth class; bounds that assign all missing histories to each category in turn |
| Contingency scores vary over about nine functions only, so the static tests rest on few distinct values | Scores by function x industry from the interviews where they support it; randomization inference over function labels; present H1 and H2 as patterns and put the inferential weight on H3's within-function contrast (IJVs with and without a host-country parent) and on H4 |
| Parent bargaining power differs by function (each parent controls the activities it contributed to, `choi2004split`) | Interact domain scores with equity share; control for which parent's industry matches the function where observable; discuss as the rival account |
| Host labor supply, host rules on foreign staff, and Revelio coverage differ by country | Host x year effects; coverage ratio from tabulation 4 as a control and as a sample restriction |
| IJV age drives localization, and 54 percent of the sample were incorporated before 2005 | IJV x year effects for the static tests; age interactions; state that panels start mid-life |
| A second theory (resource dependence) dilutes the argument | See the theory record below; recommended treatment is as a rival account, not as a second anchor |

## Decisions for the PI

1. Resource dependence theory: adopt as a complement, or keep contingency
   theory alone and treat dependence on parent resources as the resource
   contingency already named in `docs/theory-framework.md`. Recommendation
   of this brief: the second.
2. The third contingency score (open since 2026-10-02): H1 and H3 use
   `coord_dependence` to cover both coordination need and dependence on
   parent knowledge. Decide at gate 3 whether these are one score or two.
3. Definition of local parent-origin: any parent-group employer in the host
   country (this brief), or the host-country parent's group only (Q1).
4. Whether tabulations 1 to 3 may run before gate 5.
5. Gate 4, decision 1: this brief corresponds to option A of the co-author
   note extended by the organizational-origin dimension, with option B's
   BoardEx analysis as a supplement to H1. The gate file is unchanged.
6. Number of hypotheses: four, with H2 as a baseline. Dropping H2 as a
   numbered hypothesis and reporting it as a descriptive pattern would leave
   three.

## Next Steps

1. PI and co-authors review this brief and settle decisions 1 to 4.
2. If decision 4 is yes: data-engineer runs tabulations 1 to 5; results go
   to `reviews/gate-4-pilot.md`.
3. `/lit-synthesis` (gate 1 is approved) with the staffing frame added to
   the concept matrix; resolve the `[CITE: ...]` markers through
   `/references`.
4. `/qual-recode`: code the interviews for the two hiring routes and for the
   contingency scores.
5. After gates 2 to 4 and 5a: `/shock-options rescore`, then
   `/research-workflow hypotheses` takes H1 to H4 into the pre-analysis plan.

---

## Appendix: ideation record (2026-11-22)

### A. Concept map

| Construct | Meaning here | Observed through |
|---|---|---|
| Staffing configuration | Shares of the four hire categories in a domain | Revelio position histories |
| Geographic localization | Local share on the geographic dimension | Country of the prior position |
| Organizational dependence on the parents | Parent-origin share on the organizational dimension | Prior employer in a parent's Revelio family |
| Domain contingencies | Task, coordination, environmental, resource (`docs/theory-framework.md`) | Scores from the interview recoding |
| Domain | Function; hierarchical level | `role_k10_v3`, seniority, remapped at gate 5 |
| Contingency change | Geopolitical or regulatory change that alters one contingency for some domains | Shock scan, gate 5 |

Lenses: structural contingency theory (T1, main). Differentiated network
and integration-responsiveness (T2, vocabulary). IJV control and staffing,
expatriate staffing, organizational design (T3). Geopolitics (T4, context).
Resource dependence theory: candidate, not in the hierarchy.

Empirical approaches in this literature and what they see of the two
dimensions: manager surveys of control (parent influence by activity, not
hiring sources); expatriate or nationality counts in top positions
(geographic origin at one level, organizational origin implied); archival
employment histories (both dimensions at all levels, with missing histories
and missing secondees).

### B. Gaps considered

Format: gap; evidence; why IJV. "Limited work" means none was found in the
verified bibliography, not that none exists.

Empirical
- Limited work observes the prior employers of an IJV's wider workforce;
  control is measured at the IJV or activity level. Evidence:
  `geringer1989control`, `liu2014metaanalysis`. Why IJV: two parents and the
  market are three possible sources.
- Staffing research classifies by nationality (parent-country, host-country)
  and has no organizational-origin dimension. Evidence:
  `gong2003subsidiary`, `gaur2007institutional`. Why IJV: with a
  host-country parent, local and parent-origin are no longer opposites.
  **Carried into H3.**
- Differentiation across activities is documented for control, not for
  hiring sources. Evidence: `choi2004split`, `mohedanosuanes2021control`.
  Why IJV: split control is an IJV phenomenon. **Carried into H1.**

Boundary condition
- The link between host environment and local staffing may not hold in
  functions tied to the parents. Evidence: `gaur2007institutional`,
  `belderbos2005determinants`. Why IJV: weak; also true of subsidiaries.
  Secondary.
- IJVs without a host-country parent cannot localize through a parent.
  Evidence: `[CITE: studies of IJVs formed by two foreign parents]`. Why
  IJV: specific. **Carried into H3 as the boundary condition.**
- Executive staffing studies concentrate on the top position. Evidence:
  `harzing2001whos`, `thompson2004empirical`. Why IJV: weak. Secondary;
  feeds the level part of H1.

Mechanism
- Why recruit from a parent instead of the market: control, knowledge
  transfer and bargaining are offered as accounts and are not separated at
  the domain level. Evidence: `edstrom1977transfer`, `harzing2001bears`,
  `yan1994bargaining`. Why IJV: bargaining between parents has no
  subsidiary equivalent. **Carried into H1 and the separability argument.**
- Whether localization lowers dependence on the parents or re-routes it
  through the local parent is unresolved. Evidence: `inkpen1997knowledge`,
  `luo2001dual`. Why IJV: specific. **Carried into H3 and H4.**

Context
- Evidence comes largely from Japanese multinationals' subsidiaries and
  from IJVs in China. Evidence: `delios2000expatriate`,
  `belderbos2005determinants`, `yan1994bargaining`,
  `beamish1993characteristics`. Why IJV: weak. The sample here is broad
  (Western Europe 3,378 of 7,460), which is a strength to state, not a gap
  to build on.
- Work on geopolitical tension addresses the multinational and its
  subsidiaries; limited work addresses staffing inside IJVs. Evidence:
  `meyer2022mne`, `witt2023decoupling`. Why IJV: an IJV between parents
  from two states is directly exposed to their relations. **Carried into
  H4.**

Methodological
- Surveys of control are cross-sectional and rely on one informant per IJV.
  Evidence: `geringer1989control`, `mjoen1997control`. Why IJV: weak.
- Employment-history data are established in management research but
  limited work applies them to IJVs. Evidence: `babina2023firm`,
  `marchetti2026are`. Why IJV: entity matching of JVs and both parents is
  the new step.
- Such data miss seconded staff and many prior positions. Evidence: own
  pilot, `reviews/gate-4-pilot.md`. This is a limitation to report, not a
  gap.

### C. Theory record for H3

Version 1, contingency logic alone. Functions in an IJV differ in two
requirements. Dependence on the host environment makes host-specific
knowledge and local acceptance valuable in a hire. Dependence on
coordination with the parents makes parent-specific knowledge and ties
valuable. The requirements are independent of each other, so a function can
be high on both. Fit then calls for hires who bring both, and those are
found in a parent's host-country workforce. Where only the first
requirement is high, the open local market fits at lower cost. Change in the
first requirement moves hiring between local and international sources and
leaves the parent-versus-market choice where coordination dependence put it
(H4). Regaining fit after a change follows
`[CITE: Donaldson 2001, The Contingency Theory of Organizations]`.

Version 2, with resource dependence added. Parents supply staff to protect
the resources they contributed and to keep the IJV dependent on them, and
the IJV's management seeks to reduce that dependence
(`[CITE: Pfeffer & Salancik 1978]`; in IJVs `yan1994bargaining`,
`chen2009parent`, `inkpen1997knowledge`). This adds two predictions that version 1 cannot
make: which parent staffs which function (the one that contributed the
critical resource), and a drift toward independent hires as the IJV ages
and its own capabilities grow.

Assessment. Neither added prediction is needed for H1 to H4, and both rest
on the weakest data: parent identity within the parent-origin group, and
IJV age in a sample whose panels start mid-life. Version 2 also turns
bargaining power from a rival account into part of the theory, which works
against the requirement in `docs/theory-framework.md` (tension 3) to keep
contingencies and parent power separable. Recommendation: keep version 1,
name dependence on parent resources as the resource contingency, and use
resource dependence and bargaining power as the rival account that the
within-IJV design addresses. The PI decides.

Causal chain. Domain contingencies (local embeddedness; coordination
dependence) → hiring choice on each dimension (local or international;
parent or market) → staffing configuration of the IJV. Change in one
contingency → adjustment on the matching dimension only.

Competing explanations and the design's answer.

| Explanation | What it predicts instead | Design answer |
|---|---|---|
| Parent bargaining power and ownership asymmetry | Parent-origin staffing follows equity and contributions, not domain contingencies | Within-IJV comparison across domains; interaction of domain scores with equity share |
| Host labor supply | Independent local hiring wherever the host market offers the skill | Host x year effects; function x host effects where cells allow |
| IJV age | More independent hiring in older IJVs in all domains | IJV x year effects; age interactions |
| Host rules on foreign staff | Local recruitment in all domains of the host | Host x year effects |
| Data artefact | Fewer observed parent-origin staff where secondment is common | BoardEx comparison; bounds; direction of bias stated |

Tensions from `docs/theory-framework.md`.
1. Static theory: H4 is the adjustment claim. Strategic choice by the
   parents limits determinism (`[CITE: Child 1972]`), which is why the
   hypotheses predict shares, not a single fitting configuration.
2. Single-organization origin: the organizational-origin dimension is the
   interorganizational element. A unit with two parents has two internal
   sources and a market, and H3 exists only because of that.
3. Contingencies and bargaining power: see the table above.

Definitional ambiguities flagged: the two readings of local parent-origin;
"recruited locally" is the country of the prior position, not nationality;
labor market entrants have no prior employer and are neither parent-origin
nor confirmed independent.

### D. Hypotheses considered and not carried forward

- Independence without localization: when access to a parent's staff is
  restricted in a domain with low local embeddedness, hiring shifts from
  international parent-origin to independent international hires. It is the
  mirror of H4 and is observable on the independent side (11 to 13 percent
  of person-years in the pilots). Left out to keep one dynamic hypothesis;
  a candidate if the chosen shock works through access to parent resources.
- A separate level hypothesis (the original H3). Folded into H1, because
  the level's responsibility for alliance-wide coordination is a
  coordination contingency.
- Any hypothesis on staff from both parents in one cell. Not observable
  (gate 4).

### E. Quality checks run

| Check | Result |
|---|---|
| Hypotheses falsifiable, directional, contingency named first | Pass |
| Gap evidence cites existing keys or `[CITE: ...]` | Pass. All 23 keys used exist in `literature/references.bib` (checked by script); four `[CITE: ...]` markers. What the works show is not yet verified against full text |
| Mechanism distinct from hypothesis | Pass |
| Competing explanation incl. bargaining power | Pass |
| Design fits the constraints | Pass |
| `staffing_frame` | Pass. H2 uses one dimension and says why |
| `feasibility_gate` | Pass. H3 and H4 marked provisional |
| Wholly owned subsidiary question answered per hypothesis | Pass |
| Resource dependence theory as candidate only | Pass |
| No shock named, no outcome pattern used | Pass |
| Counts carry file and date; no row-level licensed data | Pass |
| No gate status changed; framework and research idea not edited | Pass |
