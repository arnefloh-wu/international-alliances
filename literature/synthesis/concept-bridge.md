# Concept bridge: contingency families, T2 and T3 constructs, project measures, O\*NET route

Stage 2 (lit-synthesis), literature-synthesizer, 2026-11-24.
Evidence basis: worked from abstracts / metadata only.

Measures are taken from `docs/research-brief.md` (Staffing Frame, Proposed
Design) and the decision rows of 2026-11-24 in `docs/decisions.md` (route to
gate 5, decisions 3 to 5), with the draft column names of `data/codebook.md`
("Draft panel columns", 2026-11-23). The dependent-variable section of the
codebook (cross-parent integration, parent dominance) is obsolete since
gate 4 and is not used here. Hypotheses are H1 to H4 of the brief.

O\*NET element names below are candidates only. Every one is marked
"to verify against the O\*NET content model"; none is adopted as a measure
by this memo.

## 1. Main table

| Contingency family (T1) | T1 meaning | T2 constructs (IB applications) | T3 constructs (staffing, control, design) | Project measure (brief; decisions 2026-11-24) | O\*NET route (candidates, to verify against the O\*NET content model) | Corpus support for the O\*NET route |
|---|---|---|---|---|---|---|
| Task | Interdependence among activities, task uncertainty, knowledge intensity (`lawrence1967organization`; `[CITE: Thompson 1967]`) | Knowledge-flow intensity by subsidiary role (`gupta1994organizing`); pressure for global integration from technology and economies of scale (`venaik2004new`, `prahalad1987multinational`) | Task interdependence between partners raises behavior control (`han2019management`); knowledge specificity conditions the value of expatriates (`fang2010multinational`); function-specific knowledge transfer by expatriates (`harzing2016bridging`); activities matched to partners' firm-specific advantages (`choi2004split`) | Part of `coord_dependence` (H1, H3), static, occupation level, from O\*NET, fixed before outcomes are seen (decision 3) | Work-context items on working with a work group or team and on the impact of decisions on co-workers or company results; work-activity items on coordinating the work of others and on communicating with supervisors, peers or subordinates; possibly job-zone or knowledge-intensity measures (all to verify against the O\*NET content model) | None. No corpus record uses occupational task data to measure interdependence or knowledge intensity |
| Coordination | Need for joint decisions, allocation of decision rights, hierarchical responsibility for unit-wide coordination | Normative integration and centralization fitted to subsidiary context (`ghoshal1989internal`); HQ control tools balancing coordination and responsiveness (`doz1984patterns`); coordinative role of intermediate units (`plabarber2021intermediate`) | Transfers and expatriates as coordination and control (`edstrom1977transfer`, `harzing2001bears`, `delios2000expatriate`); activity-specific control (`mjoen1997control`, `geringer1989control`); top-position staffing (`harzing2001whos`, `belderbos2005determinants`); level differences in PCN presence (`singh2019subsidiary`) | `coord_dependence` (occupations, from O\*NET) and `coord_role` (levels; source still open, `docs/decisions.md` Open 2026-11-23); H1 levels, H3 | For occupations: as in the task row, plus coordination-related work activities (to verify). For levels: no O\*NET route, because O\*NET scores occupations, not Revelio seniority levels. Management occupations could be scored, but that conflates level and occupation | None. The corpus also lacks a theoretical source for `coord_role` (`memo-t3-organizational-design.md`) |
| Environmental | Dependence on host institutions, labor markets, customers, regulators; political sensitivity | Local responsiveness pressure from customers, government, competition (`venaik2004new`, `doz1981global`, `meyer2014local`); institutional duality (`kostova2002adoption`) | Institutional and cultural distance and subsidiary staffing (`gaur2007institutional`, `gong2003subsidiary`, `gaur2022societal`); host partner's government-facing advantage (`henisz2000institutional`); localization of HRM practices (`pudelko2007countryoforigin`) | `local_embeddedness` (H2, H3), static, occupation level, from O\*NET. H4 change score for S13: binary list of regulatory-facing occupations (legal, compliance, customs and trade, tax, regulatory affairs, employment law) on O\*NET-SOC codes or `role_k50`, written into the plan before the panel is built; O\*NET law and government knowledge score as robustness (decision 4). Working name in this memo: `reg_facing` (not decided) | Work-activity items on communicating with people outside the organization and on performing for or working directly with the public; work-context items on dealing with external customers and face-to-face contact; knowledge domains of law and government and of customer and personal service (all to verify against the O\*NET content model). Regulatory-facing list from SOC major or minor groups for legal occupations, compliance officers, tax examiners and preparers, customs brokers (SOC codes to verify) | None in the corpus. Outside it, task-based offshorability measures use face-to-face and on-site requirements (Blinder 2007, found in the Stage 2 search, unscreened; other leads in `missing-references.md`) |
| Resource | Dependence on parent technology, personnel, finance; access to parent resources | Resource configuration and internal power (`ghoshal1990multinational`); local resources as a contingency of HQ-subsidiary structure (`ghoshal1989internal`) | Resource contribution and bargaining power determine control (`yan2001antecedents`, `liu2014metaanalysis`, `mjoen1997control`, `chen2009parent`); dependence and instability (`inkpen1997knowledge`); partner expertise per activity (`mohedanosuanes2021control`, `choi2004split`) | No score (third score still open, `docs/decisions.md` Open 2026-10-02 and 2026-11-22). Used in the design as the rival account: IJV x year fixed effects; domain score x equity share interactions; host-country parent indicator `host_parent` (H3 boundary). Proposed here: parent industry matched to occupation group as a test of domain-level bargaining | No O\*NET route. Dependence on a specific parent is relational and IJV-specific; occupational task content cannot measure it | Not applicable |

## 2. Outcome side (for completeness)

| Hypothesis | Outcome (draft column names, codebook 2026-11-23) | T3 precedent in the corpus | What the precedent measures instead |
|---|---|---|---|
| H1 | `share_parent` (parent-origin among hires with observed history) | Expatriate ratios (`gaur2007institutional`, `gong2003subsidiary`, `fang2010multinational`); expatriates per function (`harzing2016bridging`) | Nationality, not prior employer |
| H2 | `share_local` | PCN versus HCN in top positions (`harzing2001whos`, `thompson2004empirical`) | Nationality at the top level only |
| H3 | `share_parent_local` (local parent-origin among local hires) | None | No study separates host-country hires by parent affiliation |
| H4 | `share_local` and `share_parent_local` in hiring flows, exposed x post x `reg_facing` | `tang2026strategic` (local inventor employment under political tension, unit level); `adarkwah2024geopolitical` (subsidiary employees) | Unit-level counts, no origin dimension |
| all | `share_not_obs` (history not observed), reported separately | `liu2020predicting`, `wang2026organizational` (profile-based composition) | No treatment of missing histories in the abstracts |

## 3. What the corpus has and lacks for the O\*NET route (task 4b)

Has: an occupation-year composition precedent (`wang2026organizational`)
and a prior-employer flow precedent (`liu2020predicting`). Nothing else.

Lacks, and needed before O\*NET-based scores can carry H1 to H4:

1. A source that O\*NET (or DOT) task descriptors measure the task
   environment of a job in a way that maps onto contingency constructs,
   such as interdependence or external dependence `[CITE: occupational task
   data as a task-environment or contingency measure]`.
2. A source that O\*NET work-context items capture interdependence or
   teamwork `[CITE: O*NET-based measures of interdependence or teamwork]`.
3. A source that O\*NET items capture external contact or location-bound
   work, for `local_embeddedness`; the offshorability literature is the
   closest lead `[CITE: task-based offshorability measures using O*NET
   face-to-face and on-site items]`.
4. The O\*NET content model documentation itself, for the element
   definitions `[CITE: O*NET content model]`.
5. A source on applying US-based O\*NET descriptors to jobs in other
   countries `[CITE: cross-country transferability of O*NET]`. This matters
   because most of the sample is outside the US (Western Europe holds 3,378
   of 7,460 IJVs, per `docs/research-brief.md`).

Construct caveats the PI should weigh (synthesizer's reading, not in the
corpus):

- O\*NET measures generic interdependence and generic coordination, not
  dependence on coordination with the parents. H1 and H3 are about the
  latter. An occupation can be highly interdependent with colleagues inside
  the IJV and still have no need for parent-specific knowledge. The O\*NET
  score is therefore a proxy for one component of `coord_dependence` (the
  task family), not for the parent-specific component that the brief's
  mechanism invokes.
- O\*NET external-contact items measure contact with outsiders, not with
  host-country outsiders. In an export-oriented IJV, external contact may be
  with foreign customers. The S13 binary list of regulatory-facing
  occupations is closer to host-specificity than the generic contact items.
- Both scores vary only across occupations, so they are constant within an
  occupation across IJVs. Industry- or IJV-specific contingency differences
  are absorbed into the error or into fixed effects.

## 4. Competitor classifications found under task 4a

Detailed in `memo-t2-ib-frameworks.md`, section "Task 4a". In short: the
corpus contains frameworks that order broad functions or value activities
by local responsiveness or by which partner should control them
(`venaik2004new`, `prahalad1987multinational`, `mohedanosuanes2021control`,
`choi2004split`) and function-level staffing evidence (`harzing2016bridging`),
but no published numeric score at function or occupation level that could
be fixed before outcomes are seen. Outside the corpus, Kim, Park and
Prescott 2003 (JIBS, global integration of business functions; found in the
Stage 2 OpenAlex search, not screened) is the strongest lead and is listed in
`missing-references.md`. Recommendation for the PI's decision: keep the
O\*NET route as primary at the occupation-group grain and use any verified
function-level IR ordering as a convergent-validity check on O\*NET scores
aggregated to the nine project functions, not as a replacement.
