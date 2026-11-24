# Gap statement

Stage 2 (lit-synthesis), literature-synthesizer, 2026-11-24.
Evidence basis: worked from abstracts / metadata only. Working document, not
manuscript prose. Built with the Gap x Importance x Method logic of the
academic-writing skill. Hypotheses are H1 to H4 of `docs/research-brief.md`.

## Scope of every "not found" claim in this file

Every statement below that a topic has not been studied is bounded to the
provisional corpus: 95 records (67 include, 28 seed) from six Consensus
stream queries (top 10 per query, free tier), eight approximate citation
chase queries and the seed list, all run on 2026-10-02
(`literature/search/search-log.md`; chase method and its limits in the
"Citation chase" section there), plus five OpenAlex queries run on
2026-11-24 (Stage 2 addendum in the same file). Backward chasing was not run
for any stream; forward chases were not run for eleven central works
(listed in `reviews/gate-1-literature-search.md`). Web of Science, EBSCO and
Google Scholar have not been run, and streams S7, S8 and S9 were never
searched. No such claim may enter the manuscript before those runs are
ingested and G2 is re-run.

## The three factors

**Gap.** Research on the staffing of foreign units classifies employees by
nationality (parent-country versus host-country nationals) and explains the
mix by control, knowledge transfer and distance (`gong2003subsidiary`,
`gaur2007institutional`, `harzing2001whos`, `harzing2016bridging`), while
research on IJVs shows that parental influence is differentiated by
activity but measures it as control, not as hiring sources (`choi2004split`,
`mjoen1997control`, `geringer1989control`, `mohedanosuanes2021control`). As
a result, the corpus contains no study that separates the geographic origin
of an IJV's staff from its organizational origin, so localization through a
parent's local workforce cannot be distinguished from localization through
the open labor market (bounded as above). The same corpus contains no study
of how a change in the environment shifts staffing across domains inside an
IJV; the closest evidence is unit-level (`tang2026strategic`,
`adarkwah2024geopolitical`).

**Importance.** First, the distinction decides what a local staffing share
means: an IJV that localizes through its host-country parent remains
dependent on that parent, whereas one that hires on the open market does
not, and whether localization reduces or re-routes parental dependence is
unresolved in the IJV literature (`inkpen1997knowledge`, `luo2001dual`).
Second, contingency reasoning in IB has been developed for units with one
parent (`ghoshal1989internal`, `nohria1997differentiated`); an IJV is a unit
with two parents and a market as staff sources, which is where an IB
contribution to contingency theory can be made (tension 2 below). Third,
geopolitical change is reshaping how multinationals organize
(`meyer2022mne`, `moura2026how`, `sinani2026caught`), and the reviews
call for analysis beyond the home-host dyad (`patsiaouras2026geopolitical`);
practical stakes (for example the number of IJVs exposed to Brexit or the
policy weight host governments give to local staffing) still need a sourced
figure `[CITE: sourced figure on the scale or policy relevance of IJV
staffing or of Brexit-exposed cross-border units]`.

**Method.** Employment histories observe the prior employer and its country
for every hire at every level, which removes the shared limitation directly
(both axes observed, not inferred from nationality), and the occupation
grain is established in profile-based research (`wang2026organizational`,
`liu2020predicting`). Within-IJV comparison across occupation groups with
IJV x year fixed effects holds the IJV-level bargaining outcome constant,
which survey designs with one informant per IJV cannot do
(`yan2001antecedents`, `han2019management`, `liu2014metaanalysis`). The
focal contingency change (S13) has a dated onset and a within-shock
contrast (GB-IE), which permits an event-study design once pre-trends are
checked (`literature/shock-scan/rescoring.md`, section 9).

## Gap type

Primary: **existing studies share a limitation at the level of the
construct and its measurement.** Staffing research measures origin by
nationality only, and IJV control research measures parental influence by
activity-level control surveys, typically cross-sectional with one
informant. The two literatures together cannot test whether localization
and dependence on the parents answer to different contingencies. The
fitting design is one that removes the limitation (multi-level archival
panel with prior-employer histories and within-IJV comparison), which is
the design adopted at gate 4.

Secondary, for H3 and H4 only: **the topic has not been studied** within
the bounds stated above (no study of the local parent-origin channel; no
study of within-IJV staffing reconfiguration after a contingency change).
The fitting design is a first empirical test; the claims must stay
associational for H1 to H3 and become causal for H4 only after pre-trends
are checked (`CLAUDE.md`, rule 4).

Rejected as the primary type: "competing theories". Contingency theory and
bargaining power or resource dependence do make different predictions, but
the design is built to separate them (IJV x year fixed effects), not to
adjudicate between them, and the domain-level variant of bargaining
(`choi2004split`) is not cleanly separated (see tension 3). Treating the gap
as a theory contest would oversell the design.

## The three tensions (`docs/theory-framework.md`)

### 1. Static theory versus dynamic claim

Classical contingency theory specifies fit, not the path to it, and is
read as deterministic. H4 is an adjustment claim: a change in one
contingency produces misfit, and the IJV regains fit by shifting new hiring
on the matching axis only. The adjustment argument needs
`[CITE: Donaldson 1987, SARFIT]` and `[CITE: Donaldson 2001]`, and the limit
on determinism needs `[CITE: Child 1972, strategic choice]`; none is in the
corpus. Corpus support is indirect: parents adjust control over the IJV life
cycle and those that adjust perform better (`lenguyen2009parent`); control
evolves with bargaining power (`yan1994bargaining`); dependence shifts as
partners acquire knowledge (`inkpen1997knowledge`); subsidiary charters
change (`birkinshaw1998multinational`), though by capability, not
environment. How the outline handles the tension: H4 predicts the
direction of change in hiring-flow shares, not a single fitting
configuration, and parents' strategic choice is the reason the prediction is
about shares at the margin (flows), where adjustment is cheapest
`[CITE: hiring flows as the adjustment margin of workforce composition]`.

### 2. Single organization versus two parents

Contingency theory was developed for single organizations, and its IB
applications keep one parent (`ghoshal1989internal`,
`nohria1994differentiated`, `brock2007global`). The interorganizational
element in T2 is a metaphor for the MNC (`ghoshal1990multinational`) or a
duality between host and parent (`kostova2002adoption`). The IJV literature
shows the two parents differ in control and its effects (`luo2001dual`,
`chen2009parent`, `barden2005influence`) and that the local partner holds
local and government-facing knowledge (`inkpen1997knowledge`,
`henisz2000institutional`). The IB-specific contribution is that a unit with
two parents and a market has two staffing axes, and the organizational axis
exists only because there is more than one possible organizational source.
H3 is the hypothesis that would not exist for a wholly owned subsidiary, and
its boundary condition (no host-country parent) is the within-design test
of that claim `[CITE: IJVs formed by two foreign parents]`. What the paper
adds beyond "applying the theory to a new setting" is therefore the
prediction that two contingencies sort hires on two separate axes, with the
local parent as the channel where both contingencies are high.

### 3. Staffing as an outcome of contingencies and of bargaining power

The IJV literature explains parental control by bargaining power and
resource contribution (`yan2001antecedents`, `yan1994bargaining`,
`liu2014metaanalysis`, `mjoen1997control`, `chen2009parent`,
`killing1983strategies`). Staffing is a control mechanism
(`schaan1983parent`, `harzing2001bears`), so observed parent-origin staffing
may reflect power rather than coordination needs. Separability in the
design: IJV x year fixed effects absorb IJV-level equity and bargaining
outcomes; domain score x equity share interactions test whether the
contingency slope depends on ownership; the host-country parent indicator
defines the H3 boundary. What is not separated: domain-level bargaining, in
which each parent staffs the activities it contributed (`choi2004split`,
`mohedanosuanes2021control`). This varies within the IJV and correlates
with coordination dependence. The outline therefore proposes an explicit
check (parent industry matched to occupation group) and names
domain-level bargaining as the rival account in the limitations if it
cannot be separated. Ownership asymmetry (equity) and parent dominance
(staffing concentration) are kept as separate variables; the codebook's
equity-adjusted dominance measure is obsolete with the cross-parent
outcomes, so the plan needs a new way to keep them apart `[DATA: equity
shares at hire date; current equity stands in for formation equity per
docs/decisions.md 2026-10-08]`.

Resource dependence theory (open item, `docs/decisions.md` 2026-11-22):
treated here as the rival account, not adopted. Evidence for both readings
is set out in `memo-t3-ijv-control-staffing.md`.

## Contributions as the synthesis phrases them

1. To contingency theory in IB: localization and dependence on the parents
   are separate dimensions of IJV staffing that answer to different
   contingencies (environmental and coordination), so an IJV's staffing
   configuration is differentiated across domains on two axes. This extends
   the differentiation logic of `lawrence1967organization` and its IB
   applications (`ghoshal1989internal`, `meyer2014local`) from units with
   one parent to a unit with two parents and a market.

2. To IJV staffing and control research: adding the organizational-origin
   dimension shows a channel of localization through the local parent's
   workforce where coordination dependence is high (H3), which bears on the
   unresolved question of whether localization reduces or re-routes an
   IJV's dependence on its parents (`inkpen1997knowledge`, `luo2001dual`),
   and moves the evidence on activity-level differentiation from control
   surveys (`choi2004split`, `mjoen1997control`) to observed hiring.

3. To research on geopolitics in IB and on contingency dynamics: a change
   in one contingency (regulatory divergence after Brexit) moves staffing
   on the matching axis only, that is, selective reconfiguration inside the
   unit rather than a uniform shift (H4). This complements firm- and
   unit-level evidence on investment, employment and exit
   (`adarkwah2024geopolitical`, `moura2026how`) and on divergent unit
   responses (`tang2026strategic`). Causal language is conditional on the
   event-study pre-trends.

## Weak points a JIBS reviewer will press

- The main theory is backed by one work in the corpus
  (`lawrence1967organization`); see `memo-t1-structural-contingency.md`.
- The contingency scores come from US occupational data and measure generic
  rather than parent-specific coordination (`concept-bridge.md`, section 3).
- The H3 cell is about 0.8 percent of hires (`reviews/gate-4-pilot.md`,
  staffing tabulations, cited from `docs/research-brief.md`), so the
  "not studied" gap may coincide with a rarely occurring phenomenon; the
  importance argument must not rest on H3 alone.
- Domain-level bargaining is the live rival (tension 3).
