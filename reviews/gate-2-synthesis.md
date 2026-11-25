# Gate 2: Literature synthesis

Status: APPROVED WITH CHANGES
Approved by: Arne Floh, 2026-11-24, in chat ("Accept all" on the decision sheet, then "Yes, set it"); line set by the agent on the PI's instruction. Provisional: G2 is re-run when the manual database exports arrive
Stage: 2 Literature synthesis
Agent: literature-synthesizer
Date produced: 2026-11-24

Scope warning. This synthesis runs on the provisional Consensus-plus-seed
corpus approved at G1 (95 records: 67 include, 28 seed), worked from
abstracts and metadata only. Web of Science, EBSCO and Google Scholar are
still not run, and streams S7 (structural contingency theory, the main
theory) and S8 (organizational design) were never searched: the corpus
holds one S7 work (`lawrence1967organization`, an S2 seed) and no S8 work.
G2 must be re-run when the manual exports arrive (`docs/decisions.md`,
2026-10-04 and 2026-11-24).

Binding changes applied from the Stage 2 brief: hypotheses are H1 to H4 of
`docs/research-brief.md` (not H1 to H5 of the research idea); the matrix
column reads "staffing / integration construct and its measure"; S13 is the
focal shock with S06 as fallback; contingency scores come from O\*NET
(decisions of 2026-11-24); concept-bridge measures follow the brief and the
decisions of 2026-11-24, not the obsolete dependent-variable section of
`data/codebook.md`.

## Deliverables

| Deliverable | Path | Notes |
|---|---|---|
| Concept matrix | `literature/synthesis/concept-matrix.csv` | 95 rows, one per corpus record (93 citable; downes2000knowledge unverified; nguyen2009foreign dropped by the PI). Columns include evidence basis, theory, level, staffing / integration construct and measure, data, setting, finding on within-unit differentiation, contingency family, relevance to H1 to H4 (H/M/L/0), bearing on the rival account |
| Memo T1 | `literature/synthesis/memo-t1-structural-contingency.md` | States plainly that S7 was never searched |
| Memo T2 | `literature/synthesis/memo-t2-ib-frameworks.md` | S1, S2 as IB applications of contingency logic; contains task 4a (function-level classifications) |
| Memo T3 control and staffing | `literature/synthesis/memo-t3-ijv-control-staffing.md` | S3, S4; contains the evidence for both readings of resource dependence |
| Memo T3 organizational design | `literature/synthesis/memo-t3-organizational-design.md` | States plainly that S8 was never searched and has no seed in the corpus |
| Memo T4 | `literature/synthesis/memo-t4-geopolitics.md` | S5 (S9 not searched); coverage table for Brexit, investment screening, mobility restrictions |
| Memo methods | `literature/synthesis/memo-methods-employment-data.md` | S6; contains task 4b (O\*NET in the corpus: none) |
| Concept bridge | `literature/synthesis/concept-bridge.md` | Four families x T2 x T3 x project measures, with an O\*NET-route column; construct caveats |
| Gap statement | `literature/synthesis/gap-statement.md` | Gap x Importance x Method; gap type named; three tensions; bounded claims |
| Theory outline | `literature/synthesis/theory-outline.md` | Paragraph-level outline on T1; H1 to H4 with contingency, steps and references; H4 instantiated for S13 |
| Missing references | `literature/synthesis/missing-references.md` | 52 numbered entries plus microfoundations flag and full-text list |
| Search-log addendum | `literature/search/search-log.md`, "Stage 2 addendum" | Five OpenAlex queries (substitute for Consensus) and the abstract retrieval, as authorized by the brief |

Evidence codes in the matrix (`evidence_basis`): OA = abstract from OpenAlex,
retrieved 2026-11-24 and read through the fetch tool's paraphrase (54
records); CA = Consensus abstract snippet in the hits files of 2026-10-02
(17); SR = screening reason or title only (13); MS = metadata only, content
stated from the standard reading of a canonical work and marked "to verify"
(11).

## Quality checks run

- Every citation key in the memos, outline, gap statement and bridge was
  checked by script against `literature/references.bib`: 85 distinct keys
  cited, all present. One further key (downes2000knowledge) appears only in
  "not citable" notes. The concept matrix covers all 93 citable keys.
- Matrix rows reconcile with the screening sheet: 95 records, per stream S1
  20, S2 14, S3 21, S4 21, S5 13, S6 6, matching the G1 counts
  (seeds plus includes).
- No unsure record is cited; those the synthesis would use are listed in
  `missing-references.md`, section 7.
- No reference, page number, statistic or finding was added from memory as
  a citation. Leads from memory appear only in `missing-references.md` and
  are marked "memory, unverified". Statistics in the memos come from the
  abstracts (sample sizes, counts) and are attributed.
- Every "not studied" claim in `gap-statement.md` is bounded to the search
  log, the approximate citation chase and the outstanding manual runs.
- O\*NET element names appear only as candidates marked "to verify against
  the O\*NET content model".
- Theory hierarchy respected: T2 anchors no hypothesis; no microfoundations
  memo; individual-level mechanisms recorded under the microfoundations flag.
- Nothing read from `data/`. The only data figures used are aggregate counts
  quoted from `docs/research-brief.md`, `docs/decisions.md` and
  `literature/shock-scan/rescoring.md`.
- No file outside `literature/synthesis/`, the authorized search-log addendum
  and this gate file was edited. Nothing was committed.

## Known weaknesses and uncertainties

- The main theory rests on one work in the corpus. Thompson, Galbraith,
  Donaldson and Child carry outline steps as `[CITE: ...]` markers.
- No full text was read. 11 records are characterized from standard readings
  and 13 from screening reasons only; OpenAlex abstracts were paraphrased by
  the fetch tool, not copied verbatim. Claims about
  `lawrence1967organization`, `prahalad1987multinational`,
  `geringer1989control` and `bartlett1989managing` are the most exposed.
- The Consensus connector was not available in this session. The five
  substitute searches ran on OpenAlex; three of them (citation-sorted)
  returned only off-topic records. Two candidates resulted (Kim, Park and
  Prescott 2003; Blinder 2007), neither screened nor verified.
- H3 has almost no direct literature support: in the concept matrix only one
  record is coded H for H3 (`lawrence1967organization`, for the general
  logic), and the steps that make H3 specific (local parent as the supplier
  of host-embedded staff; market-hire cost; IJVs with two foreign parents)
  are all `[CITE: ...]`.
- The O\*NET route has no precedent in the corpus as a contingency measure,
  and O\*NET measures generic interdependence rather than dependence on
  coordination with the parents (`concept-bridge.md`, section 3).
- `coord_role` has neither a measure (open since 2026-11-23) nor a
  theoretical source in the corpus.
- The S4 finding that distance raises parent-country staffing
  (`gaur2007institutional`, `gong2003subsidiary`) cuts against a naive reading
  of H2; the outline argues it away at the within-IJV level, which a
  reviewer may not accept without evidence.
- Domain-level bargaining (`choi2004split`, `mohedanosuanes2021control`) is
  not absorbed by IJV x year fixed effects and is the live rival account.
- Brexit, the end of free movement and investment screening are covered only
  in general form (`meyer2022mne`, `petricevic2019structural`); every
  S13-specific step is `[CITE: ...]` or `[DATA: ...]`.

## Decisions required from the PI

1. Resource dependence theory: complement or rival. The evidence for both
   readings is in `memo-t3-ijv-control-staffing.md` ("Resource dependence").
   The synthesizer's reading: the corpus supports the rival treatment for
   the IJV-level component of bargaining (absorbed by IJV x year fixed
   effects) but leaves the domain-level component unresolved, so if
   resource dependence stays a rival account, the plan needs an explicit
   domain-level check (for example, parent industry matched to occupation
   group) and the source `[CITE: Pfeffer & Salancik 1978]`.
2. O\*NET route versus a function-level classification (task 4a). The corpus
   holds no published numeric function- or occupation-level score of local
   embeddedness or coordination need (`memo-t2-ib-frameworks.md`, "Task 4a").
   Kim, Park and Prescott 2003 (JIBS) is the strongest outside lead, not yet
   screened. Recommendation: keep O\*NET as the primary source at the
   occupation-group grain and use any verified function-level IR ordering as
   a convergent-validity check on O\*NET scores aggregated to the nine
   functions. Also decide whether the construct gap (generic versus
   parent-specific coordination) is acceptable or needs a second score.
3. S7 and S8 search gap. Run the manual Web of Science, EBSCO and Google
   Scholar strings for S7 and S8 (`literature/search/search-strings.md`)
   before stage 5 fixes the hypotheses, or accept that the theory section
   is outlined on `[CITE: ...]` markers for its T1 core until then. Also
   decide whether a targeted follow-up on entries 1 to 5, 10, 11, 17 to 20,
   24 to 28 and 35 to 38 of `missing-references.md` runs before the full
   manual runs.
4. Evidence basis: accept OpenAlex abstracts (paraphrased by the fetch tool)
   as the working evidence for this provisional G2, or require verbatim
   abstracts or full texts first.
5. Microfoundations flag (`missing-references.md`, section 9): keep the H1
   and H3 knowledge-carrier step as a domain-level assumption, or admit a
   narrowly scoped individual-level mechanism.
6. Unsure records: include any of `missing-references.md`, section 7
   (highest value: CC-S3-20, CON-S2-04, CC-S2-10, CON-S6-09, CON-S6-10).
7. Source for `coord_role`: the level hypotheses need a theoretical source
   (entry 11) and a measure; until then, should the level part of H1 be
   carried as exploratory?

## Proposed changes to earlier stages

- `literature/search/protocol.md` (Stage 0/1): add a stream for
  occupational task measures (O\*NET, DOT) as contingency or task-environment
  measures, and add the function-level IR question (task 4a) to S2; run S7
  and S8 as priority. Not edited by this agent.
- `literature/search/screening.csv` (Stage 1): add Kim, Park and Prescott
  2003 and Blinder 2007 as candidate records for screening. Not edited.
- `docs/decisions.md`: record that the Consensus connector was unavailable
  at Stage 2 and that five OpenAlex queries and an abstract retrieval were
  run instead; record the PI's answers to decisions 1 to 7 above. Not edited.
- `docs/theory-framework.md`: the contingency table still maps families to
  H1 to H5 of the research idea and assigns `coord_role` to "H3, H5"; it
  should point to H1 to H4 of the brief, name O\*NET as the source of the
  static scores (decision of 2026-11-24) and note that `coord_role` is open.
  Not edited.
- `docs/research-brief.md`: (a) the H1 mechanism names "personal ties",
  an individual-level step (microfoundations flag); (b) H2 should
  acknowledge that distance raises parent-country staffing at the unit level
  (`gaur2007institutional`, `gong2003subsidiary`) and state the within-IJV
  reading; (c) the "Reading note on evidence" can now point to this
  synthesis. Not edited.
- `data/codebook.md`: the dependent-variable section (cross-parent
  integration, parent dominance) is obsolete since gate 4 and its
  domain-characteristics section still says the scores come from the
  qualitative memo; both should be updated at stage 5 or 6. Not edited.

### G2 re-run, 2026-11-25: proposed changes to `docs/research-brief.md`

Drafted by the literature-synthesizer at the G2 re-run and merged by the
orchestrator on 2026-11-25. Basis: the narrowing of gap-statement claims (a),
(b) and (c) and the new H3 mechanism wording (PI, 2026-11-25, `docs/decisions.md`,
"Pre-analysis plan rules, decisions 9 and 10"), after the PI's reading of the
four must-read full texts, none of which tests H3 or contingency fit in a
two-parent unit ("PI updates before gate 5", item 4). The same narrowing is
applied in `literature/synthesis/gap-statement.md` and `theory-outline.md`
(revision notes of 2026-11-25). Two departures from the accepted wording need
the PI's confirmation (see P3): "wholly owned subsidiaries" became
"multinational subsidiaries", because the source the agent could read does not
state the ownership of the units in `li2024origin`; and "or alliance-level
performance", which had no source, was replaced by two works from the corpus
(`barden2005influence`, `han2019management`). Line numbers refer to the brief as
of 2026-11-25. `docs/research-brief.md` is not edited; the PI decides.

#### P1. H3 mechanism (section "Hypotheses", H3, lines 134 to 138)

Old:
"Mechanism: a locally embedded function that also depends on coordination
with the parents needs two things from a hire, host-specific knowledge and
parent-specific knowledge. Only a hire from a parent's host-country
workforce brings both. Where coordination dependence is low, the second is
not needed and the wider market offers more candidates at lower cost."

New:
"Mechanism: a locally embedded function that also depends on coordination
with the parents needs two things from a hire, host-specific knowledge and
parent-specific knowledge. In an IJV with a host-country parent, the
parents' host-country workforce, above all the host-country parent's own,
is the largest and cheapest pool of hires who bring both, though not the
only one: subsidiaries with one parent find such staff among former
inpatriates and self-initiated expatriates (`georgopoulos2024mediating`).
Where coordination dependence is low, the second is not needed and the
wider market offers more candidates at lower cost. The contribution of H3
therefore rests on the channel through a second organizational source and
on the within-IJV slope, not on the knowledge-combination step. (Revised at
the G2 re-run, 2026-11-25; `docs/decisions.md`.)"

Consistency: same wording as gate 5, A1.3, and A1.5 row 7.

#### P2. Hypothesis table, H3 row, column "Novelty" (line 155)

Old: "High"

New: "High for the channel and the within-IJV slope; the knowledge-combination step has a one-parent analog (`georgopoulos2024mediating`)"

#### P3. "Theoretical Contribution", first paragraph, first sentence (lines 74 to 77)

Old:
"Research on the staffing of foreign units separates parent-country from
host-country nationals and explains the mix by control, knowledge transfer
and institutional distance (`gong2003subsidiary`, `gaur2007institutional`,
`harzing2001whos`)."

New:
"Research on the staffing of foreign units mainly separates parent-country
from host-country nationals and explains the mix by control, knowledge
transfer and institutional distance (`gong2003subsidiary`,
`gaur2007institutional`, `harzing2001whos`). Where it adds organizational
origin, it does so for the top position of multinational subsidiaries, as
general manager successors from inside or outside the subsidiary
(`li2024origin`), or for categories of expatriate
(`georgopoulos2024mediating`), not for the wider workforce of an IJV."

Note: the novelty check proposed "wholly owned subsidiaries"; the abstract
of `li2024origin` does not state ownership, so "multinational subsidiaries"
is used. The PI, who read the full text, can restore "wholly owned" if the
paper's sample warrants it (same choice in `gap-statement.md`).

#### P4. "Theoretical Contribution", second paragraph, last sentence (lines 91 to 94)

Old:
"The contribution to contingency reasoning in international business is the
interorganizational case: the unit has two sources of integration, and
localization and independence from the parents are separate outcomes."

New:
"Contingency reasoning in international business has been developed mainly
for units with one parent and, where it has reached the IJV, for the
partners' control systems (`groot2000control`). The contribution is the
interorganizational case for staffing: the unit has two organizational
sources of staff and a market, and localization and independence from the
parents are separate outcomes."

#### P5. Appendix B, "Gaps considered", Empirical, second item (lines 350 to 354)

Old:
"- Staffing research classifies by nationality (parent-country, host-country)
  and has no organizational-origin dimension. Evidence:
  `gong2003subsidiary`, `gaur2007institutional`. Why IJV: with a
  host-country parent, local and parent-origin are no longer opposites.
  **Carried into H3.**"

New:
"- Staffing research classifies mainly by nationality (parent-country,
  host-country). Where it adds organizational origin, it does so for
  subsidiary general manager successors or for categories of expatriate,
  not for an IJV's wider workforce, and nationality data cannot show whether
  foreign staff came from a parent. Evidence: `gong2003subsidiary`,
  `gaur2007institutional`, `li2024origin`, `georgopoulos2024mediating`,
  `inamura2024effect`. Why IJV: with a host-country parent, local and
  parent-origin are no longer opposites. **Carried into H3.**"

(Appendix B is a list in a working brief, not manuscript prose; the list
format is kept.)

#### P6. Appendix B, "Gaps considered", Empirical, third item (lines 355 to 357)

Old:
"- Differentiation across activities is documented for control, not for
  hiring sources. Evidence: `choi2004split`, `mohedanosuanes2021control`.
  Why IJV: split control is an IJV phenomenon. **Carried into H1.**"

New:
"- Differentiation across activities is documented for control, not for
  hiring sources. Differences between top management and employees are
  documented for nationality-based localization at the level of the unit.
  Within the bounds of the search, no study compares hiring sources across
  functions and levels inside the same IJV. Evidence: `choi2004split`,
  `mohedanosuanes2021control`, `inamura2024effect`, `harzing2001whos`. Why
  IJV: split control is an IJV phenomenon. **Carried into H1.**"

#### P7. Appendix C, "Tensions from `docs/theory-framework.md`", items 2 and 3 (lines 458 to 461)

Old:
"2. Single-organization origin: the organizational-origin dimension is the
   interorganizational element. A unit with two parents has two internal
   sources and a market, and H3 exists only because of that.
3. Contingencies and bargaining power: see the table above."

New:
"2. Single-organization origin: the organizational-origin dimension is the
   interorganizational element. Contingency reasoning has reached the IJV
   for the partners' control systems (`groot2000control`), not for sources
   of staff. A unit with two parents has two internal sources and a market,
   and H3 exists only because of that.
3. Contingencies and bargaining power: see the table above. The
   power-based position has an explicit IJV precedent: case evidence holds
   that partner power, not contingencies, decides HRM localization in IJVs
   (`wilson2006dynamics`). The theory section answers it: power settles who
   decides at the level of the IJV, whereas the hypotheses concern
   differences between domains inside the same IJV-year."

#### P8. Appendix C, "Theory record for H3", version 1 (lines 412 to 413)

Old:
"Fit then calls for hires who bring both, and those are
found in a parent's host-country workforce."

New:
"Fit then calls for hires who bring both, and the largest and cheapest pool
of them, though not the only one, is a parent's host-country workforce."

Reason: the same "only" logic as the H3 mechanism (P1), stated implicitly.

#### P9. Appendix B, "Boundary condition", third item (lines 367 to 369), optional

Old:
"- Executive staffing studies concentrate on the top position. Evidence:
  `harzing2001whos`, `thompson2004empirical`. Why IJV: weak. Secondary;
  feeds the level part of H1."

New:
"- Executive staffing studies concentrate on the top position, including
  work that crosses nationality with inside or outside origin (`li2024origin`). Evidence: `harzing2001whos`,
  `thompson2004empirical`, `li2024origin`. Why IJV: weak. Secondary; feeds
  the level part of H1."

#### Checked and left unchanged in the brief

"Reading note on evidence" (lines 20 to 30) could add that five works bearing
on the novelty claims were read in full or in key sections at the G2 re-run;
optional. The H1 mechanism ("A parent-origin hire brings both", line 109)
concerns parent-origin hires in general, not the local channel, and was not
covered by the novelty check; left as is. The "IJV-specific" column of the
hypothesis table (H3: "The cell exists at scale only where there is a
host-country parent") is consistent with the narrowed wording.

## Reference verification (2026-11-24)

Agent: reference-manager (reference step of `/lit-synthesis`). Input:
`literature/synthesis/missing-references.md`. Log:
`literature/zotero/verification-report-2026-11-24.md`. Evidence types are
those of `docs/decisions.md`, 2026-10-04: Crossref DOI record, library or
repository catalogue record, official or publisher record, or a PDF of the
work. Each check confirms that a work exists and that its metadata are
correct. It does not confirm that the work carries the claim; where the lead
came from memory, the synthesizer still has to check the fit (verification
report, section 6).

Scope. Mid-run, the orchestrator split the work. This agent owns sections 1
to 3, the key check and this section, and is the only agent that writes to
`references.bib` and to this file. Parallel agents own section 4, sections 5
and 6, and sections 7 and 8; their fragments are due as
`literature/zotero/verification-2026-11-24-<section>.md` and `.bib`. Before
the split, this agent had already verified and added 25 items from sections
4 and 5. They stay in the `.bib` and are listed below so that the parallel
agents can skip them. No fragment from the parallel agents existed when this
section was written, so none is merged here; the orchestrator merges them.

Zotero was not synced. `ZOTERO_API_KEY` and `ZOTERO_GROUP_ID` are not in
the environment, and no `.Renviron` or `.env` exists at the repository root.
The 19 new items from sections 1 to 3 are in
`literature/zotero/import-2026-11-24.ris` for manual import. Do not run the
automatic Better BibTeX export over `references.bib` until all 44 new items
are in Zotero.

### Totals

| Status | Entries (of 52) | Of which sections 1 to 3 (entries 1 to 23) |
|---|---|---|
| Verified and added (all named works) | 26 | 14 |
| Verified and added, with a search remainder | 4 (11, 25, 28, 35) | 1 (11) |
| Search request (claim only, no work named) | 13 | 8 |
| PI decision (unsure G1 records) | 7 | 0 |
| Unobtainable | 1 (52) | 0 |
| No new reference (full-text retrieval of existing keys) | 1 (34) | 0 |

Works added to `references.bib`: 44. Sections 1 to 3 account for 19,
section 4 for 11 and section 5 for 14. The `.bib` now holds 137 entries
(93 before). No named work failed verification.

### Status per entry

| # | Work or claim | Status | Key(s) or reason |
|---|---|---|---|
| 1 | Thompson 1967 | verified and added (LoC catalogue) | `thompson1967organizations` |
| 2 | Galbraith 1973; Galbraith 1974 | verified and added (LoC; Crossref) | `galbraith1973designing`, `galbraith1974organization` |
| 3 | Donaldson 1987, SARFIT | verified and added (Crossref) | `donaldson1987strategy` |
| 4 | Donaldson 2001 | verified and added (Crossref, LoC) | `donaldson2001contingency` |
| 5 | Child 1972 | verified and added (Crossref) | `child1972organizational` |
| 6 | Van de Ven, Ganco & Hinings 2013 | verified and added (Crossref) | `vandeven2013returning` |
| 7 | Drazin & Van de Ven 1985 | verified and added (Crossref; last page from EconBiz) | `drazin1985alternative` |
| 8 | Burns & Stalker 1961; Woodward 1965 | verified and added (LoC) | `burns1961management`, `woodward1965industrial` |
| 9 | Contingency theory with staffing as the structural outcome | search request | no work named |
| 10 | Contingency study of a unit with more than one parent | search request | no work named |
| 11 | Senior levels carry coordination responsibility | verified and added (LoC), plus search remainder | `mintzberg1979structuring`; fit with the claim unchecked; alliance-governance source still to be searched |
| 12 | Ouchi 1979; Eisenhardt 1985 | verified and added (Crossref) | `ouchi1979conceptual`, `eisenhardt1985control` |
| 13 | Gulati, Wohlgezogen & Zhelyazkov 2012 | verified and added (Crossref) | `gulati2012two` |
| 14 | Puranam, Alexy & Reitzig 2014 | verified and added (Crossref) | `puranam2014whats` |
| 15 | Jensen & Meckling 1992 | verified and added (LoC record of the volume; pages from the authors' PDF); original chapter, not the 1995 reprint | `jensen1992specific` |
| 16 | Egelhoff 1982; Stopford & Wells 1972 | verified and added (Crossref plus EconBiz; LoC) | `egelhoff1982strategy`, `stopford1972managing` |
| 17 | Pfeffer & Salancik 1978 | verified and added (LoC); 1978 original | `pfeffer1978external` |
| 18 | Local parent supplies host-embedded staff | search request | no work named |
| 19 | Recruitment source choice | search request | no work named |
| 20 | IJVs formed by two foreign parents | search request | no work named |
| 21 | Host-specific human capital of local recruits | search request | no work named |
| 22 | Hiring flows as the adjustment margin | search request | no work named |
| 23 | Sourced figure on scale or policy relevance | search request | no work or statistic named |
| 24 | O\*NET content model; Peterson et al. 2001 | verified and added before the split (official page; Crossref) | `nationalcenterforonetdevelopmentonet`, `peterson2001understanding` |
| 25 | Occupational task data as a contingency measure | verified and added before the split (Crossref), plus search remainder | `dierdorff2009milieu`; fit unchecked |
| 26 | O\*NET measures of interdependence or teamwork | search request | no work named |
| 27 | O\*NET-based location-bound work measures | verified and added before the split (RePEc plus PDF; Crossref plus RePEc; Crossref) | `blinder2007how`, `firpo2011occupational`, `jensen2010measuring` |
| 28 | US O\*NET descriptors applied outside the US | verified and added before the split (Crossref), plus search remainder | `hardy2018educational` |
| 29 | Autor, Levy & Murnane 2003 | verified and added before the split (Crossref) | `autor2003skill` |
| 30 | Source for O\*NET measures as contingency scores | search request | same search as 25 to 27; no verified work yet shown to do this |
| 31 | Kim, Park & Prescott 2003 | verified and added before the split (Crossref); not screened at G1 | `kim2003global` |
| 32 | Porter 1986 | verified and added before the split (LoC); an edited volume | `porter1986competition` |
| 33 | Malnight 1996 | verified and added before the split (Crossref) | `malnight1996transition` |
| 34 | Function-level IR ordering | no new reference | full text of `venaik2004new` and `prahalad1987multinational` (section 10); entry 31 now in the `.bib` |
| 35 | UK-EU divergence after 31 December 2020 | verified and added before the split (GOV.UK treaty record), plus search remainder | `foreigncommonwealthdevelopmentoffice2021trade`; the specific divergence claims (product approval, tax administration) are not checked against the text |
| 36 | Jurisdiction-specific knowledge in regulatory work | search request | no work named |
| 37 | End of free movement and migration | verified and added before the split (Crossref; GOV.UK); year corrected to the 2026 print issue | `shrestha2026end`, `ukvisasandimmigration2023uks`, `homeoffice2020uks` |
| 38 | Brexit and firm organization or staffing | verified and added before the split (Crossref) | `moschieri2019organizational`, `du2025how`, `tung2025hyperglobalization`; fit unchecked |
| 39 | Common Travel Area | verified and added before the split (GOV.UK) | `cabinetoffice2026common` |
| 40 | Salary thresholds of the points-based system | verified and added before the split (GOV.UK records and PDFs) | `homeoffice2020uks`, `homeoffice2020statement` |
| 41 | Glennon, H-1B restrictions | verified and added before the split (Crossref; 2024, 70(2)) | `glennon2024how` |
| 42 | Bauerle Danzman & Meunier 2023; S06 documents | verified and added before the split (Crossref; EU Publications Office; EC page and PDF); ASPI 2020 (S19) from the PDF and the APO record | `bauerledanzman2023mapping`, `europeanparliament2019regulation`, `europeancommission2026list`, `hanson2020chinese` |
| 43 | Profile-data validity (CON-S6-09, CON-S6-10) | PI decision | `gregoire2024mobilizing`, `cubrich2021examining`: verified 2026-10-04, screened unsure |
| 44 | Missing employment histories in profile data | search request | no work named |
| 45 | Seconded staff with the parent as employer of record | search request | no work named |
| 46 | Labor-flow networks (CON-S6-01) | PI decision | `park2019global`: verified 2026-10-04, unsure |
| 47 | CC-S3-20 | PI decision | `chung2010trap`: verified 2026-10-04, unsure |
| 48 | CON-S2-04; CON-S2-07 | PI decision | `schlegelmilch2022balancing`, `chen2020global`: verified, unsure |
| 49 | CC-S2-10 | PI decision | `doz1980how`: verified (HBR page), pages unconfirmed, unsure |
| 50 | CC-S1-16; CC-S1-17 | PI decision | `bouquet2008managing`, `birkinshaw2005subsidiary`: verified, unsure |
| 51 | CON-S5-03, CON-S5-10, CC-S5-05, CC-S5-08, CC-S5-09 | PI decision | `atanassova2026sociopolitical`, `aliasghar2023adjustment`, `luo2021springboard`, `witt2021deglobalization`, `teece2022wideraperture`: verified, unsure |
| 52 | `downes2000knowledge` | unobtainable in this run (status only) | no Crossref deposit; no EconBiz record (read-only check); still needs a JSTOR record or PDF |

### Search requests (for the literature-searcher; no work invented)

Entries 9, 10, 18, 19, 20, 21, 22, 23, 26, 30, 36, 44 and 45. Search
remainders also stay open for entry 11 (an alliance-governance source on
level and coordination responsibility), entry 25 (management studies that
score task environments from O\*NET or DOT), entry 28 (O\*NET
transferability beyond Europe), and entry 35 (official guidance on customs,
product approval and tax administration after 31 December 2020). The memo
markers without a named work also remain: `[CITE: screening mitigation
agreements and personnel requirements]`, `[CITE: secondment and
employer-of-record]` and `[CITE: missing employment histories in profile
data]`.

### Items from sections 4 and 5 already added (orchestrator: tell the parallel agents to skip them)

Section 4 (11): `nationalcenterforonetdevelopmentonet`,
`peterson2001understanding`, `dierdorff2009milieu`, `blinder2007how`,
`firpo2011occupational`, `jensen2010measuring`, `hardy2018educational`,
`autor2003skill`, `kim2003global`, `porter1986competition`,
`malnight1996transition`. Section 5 (14):
`foreigncommonwealthdevelopmentoffice2021trade`, `shrestha2026end`,
`ukvisasandimmigration2023uks`, `du2025how`, `moschieri2019organizational`,
`tung2025hyperglobalization`, `cabinetoffice2026common`,
`homeoffice2020uks`, `homeoffice2020statement`, `glennon2024how`,
`bauerledanzman2023mapping`, `europeanparliament2019regulation`,
`europeancommission2026list`, `hanson2020chinese`. None of the 25 is in
Zotero or in the RIS file. Nothing was added from sections 6 to 8.

### `[CITE]` markers the new keys can replace (the synthesizer or PI applies them)

Direct replacements: the marker names the work, and the key is that work.

| File | Marker | Key |
|---|---|---|
| `theory-outline.md` (A1, A2, H1 steps 1 and 2); `concept-bridge.md` | `[CITE: Thompson 1967]` | `thompson1967organizations` |
| `memo-t1-structural-contingency.md` | `[CITE: Thompson 1967, pooled, sequential and reciprocal interdependence ...]` | `thompson1967organizations` |
| `theory-outline.md` (A1) | `[CITE: Galbraith 1973]` | `galbraith1973designing` |
| `theory-outline.md` (H1 step 2); `memo-t1-structural-contingency.md` | `[CITE: Galbraith 1973 or 1974]` | `galbraith1973designing` and/or `galbraith1974organization` |
| `memo-t3-organizational-design.md` | `[CITE: Galbraith 1974]` | `galbraith1974organization` |
| `theory-outline.md` (A1, H4 step 2, C1 step 4); `gap-statement.md` | `[CITE: Donaldson 2001]` | `donaldson2001contingency` |
| `theory-outline.md` (H4 step 2); `gap-statement.md` | `[CITE: Donaldson 1987, SARFIT]` | `donaldson1987strategy` |
| `memo-t1-structural-contingency.md` (twice) | `[CITE: Donaldson 1987, structural adjustment to regain fit (SARFIT); Donaldson 2001]`, `[CITE: Donaldson 1987; Donaldson 2001]` | `donaldson1987strategy`, `donaldson2001contingency` |
| `theory-outline.md` (H4 step 5); `gap-statement.md`; `memo-t1-structural-contingency.md` | `[CITE: Child 1972]`, `[CITE: Child 1972, strategic choice]` | `child1972organizational` |
| `theory-outline.md` (A2); `memo-t1-structural-contingency.md` (twice) | `[CITE: Van de Ven, Ganco & Hinings 2013]` | `vandeven2013returning` |
| `memo-t1-structural-contingency.md` | `[CITE: Drazin & Van de Ven 1985, forms of fit]` | `drazin1985alternative` |
| `theory-outline.md` (A5) | `[CITE: Ouchi 1979 or Eisenhardt 1985 on control types]` | `ouchi1979conceptual`, `eisenhardt1985control` |
| `memo-t3-organizational-design.md` | `[CITE: Ouchi 1979; Eisenhardt 1985]` | `ouchi1979conceptual`, `eisenhardt1985control` |
| `memo-t3-organizational-design.md` | `[CITE: Mintzberg 1979]` | `mintzberg1979structuring` |
| `memo-t3-organizational-design.md` | `[CITE: Gulati, Wohlgezogen & Zhelyazkov 2012]` | `gulati2012two` |
| `memo-t3-organizational-design.md` | `[CITE: Puranam, Alexy & Reitzig 2014]` | `puranam2014whats` |
| `memo-t3-organizational-design.md` | `[CITE: Jensen & Meckling 1992]` | `jensen1992specific` |
| `memo-t2-ib-frameworks.md` | `[CITE: Egelhoff 1982]` | `egelhoff1982strategy` |
| `memo-t2-ib-frameworks.md` | `[CITE: Stopford & Wells 1972]` | `stopford1972managing` |
| `theory-outline.md` (A6); `memo-t3-ijv-control-staffing.md` | `[CITE: Pfeffer & Salancik 1978]` | `pfeffer1978external` |
| `concept-bridge.md`; `memo-methods-employment-data.md` | `[CITE: O*NET content model]`, `[CITE: O*NET content model documentation]` | `nationalcenterforonetdevelopmentonet` (and `peterson2001understanding` for the design of O\*NET) |
| `theory-outline.md` (C3); `memo-t4-geopolitics.md` | `[CITE: Common Travel Area]` | `cabinetoffice2026common` |

Conditional replacements: the key is a candidate, and the synthesizer must
first confirm that the work carries the claim.

| File | Marker | Candidate key(s) | Condition |
|---|---|---|---|
| `theory-outline.md` (H1 step 5); `memo-t3-organizational-design.md` | `[CITE: hierarchical levels and coordination responsibility ...]` | `mintzberg1979structuring` | confirm from the book; the alliance-governance source is still open |
| `concept-bridge.md`; `memo-t1-structural-contingency.md` | `[CITE: occupational task data as a task-environment or contingency measure]` | `dierdorff2009milieu` | confirm it uses O\*NET work context as a context or role-requirement measure |
| `concept-bridge.md` | `[CITE: task-based offshorability measures using O*NET face-to-face and on-site items]` | `blinder2007how`, `firpo2011occupational`, `jensen2010measuring` | confirm which items each paper uses (Blinder's index is built with O\*NET, per the PDF) |
| `concept-bridge.md`; `memo-methods-employment-data.md` | `[CITE: cross-country transferability of O*NET ...]` | `hardy2018educational` | confirm from the abstract or full text |
| `memo-t2-ib-frameworks.md` | `[CITE: function-level IR measures]`, `[CITE: function-level IR ordering ... or Kim et al. 2003]` | `kim2003global` | not screened at G1; confirm the function ordering |
| `theory-outline.md` (C1 step 1); `memo-t4-geopolitics.md` (twice) | `[CITE: UK-EU regulatory divergence after 31 December 2020]`, `[CITE: ... after the end of the transition period]` | `foreigncommonwealthdevelopmentoffice2021trade` | the treaty is the legal basis; the specific divergence claims are unchecked |
| `theory-outline.md` (C2 step 1); `memo-t4-geopolitics.md` | `[CITE: end of UK-EU free movement and migration flows]` | `ukvisasandimmigration2023uks` (end of free movement on 31 December 2020, stated in its text); `shrestha2026end` (migration flows, checked by title only) | confirm Shrestha & Sant'Anna's content |
| `theory-outline.md` (C2 step 3) | `[CITE: UK points-based system salary thresholds]` | `homeoffice2020uks`; `homeoffice2020statement` | the policy statement sets the requirements for new entrants 30% lower, which weakens "bite more at junior levels"; reword or argue the step |
| `memo-t4-geopolitics.md` | `[CITE: Brexit and firm organization or staffing]` | `moschieri2019organizational`, `du2025how`, `tung2025hyperglobalization` | not screened; `du2025how` is about services exports |

### Key check

Every key-shaped token in `literature/synthesis/*.md` (and in
`concept-matrix.csv`) was checked by script against `references.bib`. Of 95
distinct keys, 93 are in the `.bib`. Two are not: `downes2000knowledge`
(unverified, in `references-unverified.bib`) and `nguyen2009foreign`
(dropped by the PI). Both appear only in "not citable" notes
(`memo-t3-ijv-control-staffing.md` line 6; `missing-references.md` entry 52
and the note after it; matrix rows marked "Not used"). No other synthesis
key is missing. The new keys are not cited in the memos yet.

### Outline claims that still lack support

H1 step 5 (levels: Mintzberg is a candidate whose fit is unchecked, and
`coord_role` still has no measure); H2 step 3 (host-specific human capital
of local recruits); H3 step 3 (local parent as supplier of host-embedded
staff), step 4 (recruitment source choice) and step 5 (IJVs with two
foreign parents); H4 step 3 (hiring flows as the adjustment margin); C1
step 1 in its specific form (product approval, tax administration), step 2
(jurisdiction-specific knowledge) and step 3 (an assumption with no
source); C2 step 2 (`[DATA]` on the linked-entity rule; HC 813, now
`homeoffice2020statement`, inserted Appendix Intra-Company Routes and is
where that rule would be found, which was not checked); C2 step 3 as
worded (see the new-entrant threshold above); the gap statement's
importance figure and the "two parents" novelty bound (tension 2); a
source for O\*NET scores as contingency measures (decision 3 of
2026-11-24; candidates only).

### Parallel verification results (merged by the orchestrator, 2026-11-24)

At the PI's request, sections 4 to 8 of `missing-references.md` went to three further reference-manager agents running in parallel. Their tables are in `literature/zotero/verification-2026-11-24-s4-onet.md`, `-s5-s6.md` and `-s7-s8.md`.

**Merged into `literature/references.bib`** (now 139 entries; it parses without errors and has no duplicate keys):
- `handel2016onet`, a peer-reviewed description of the O\*NET content model (Crossref);
- `homeoffice2026workers`, the Home Office guidance "Sponsor a Global Business Mobility worker", version 04/26 (GOV.UK record and PDF).

The date of `ukvisasandimmigration2023uks` was corrected to 9 September 2023 (UK time).

**Zotero.** None of the 46 new entries is in Zotero, because no Zotero API key is available in this environment. `literature/zotero/import-2026-11-24.ris` holds the 19 items from sections 1 to 3; the other 27 still need import. Do not run the Better BibTeX auto-export over `references.bib` until all are in Zotero.

**Section 4 (O\*NET):**
- Every named work is verified.
- PI decision: whether to add Peterson et al. (Eds.) 1999, *An occupational information system for the 21st century*, APA, doi 10.1037/10313-000, the original O\*NET development report. Entry 24 does not name it.
- Search requests: entries 25 (rest), 26, 28 (rest) and 30. Leads for entry 28, not verified: De Arcangelis and Mariani 2019; Borelli 2016.

**Sections 5 and 6 (Brexit, screening, methods):**
- Every named work is verified.
- PI decision: the three unsure methods records CON-S6-09, CON-S6-10 and CON-S6-01 (`gregoire2024mobilizing`, `cubrich2021examining`, `park2019global`). Their metadata was verified on Crossref, but they stay out of the bib until the PI includes them (decision 6).
- Search requests: entries 36, 44 and 45.
- Leads, not screened: Do et al. 2025 (JIE, Brexit and labor demand); Panitz and Glückler 2022 (Economic Geography, Brexit relocation); Berry, Maloney and Neumark 2024 (NBER w32294, LinkedIn data).

**Linked-entity rule (open item for S13, 2026-11-24):**
- HC 813, para 6.2, defines "sponsor group" to include a business linked to the sponsor by "a joint venture on which the applicant is sponsored to work". The current Rules keep that definition.
- Neither version defines a joint venture or sets an ownership threshold.
- The current sponsor guidance (v04/26, pp. 18 to 20) treats an entity formed by a joint venture agreement as linked to the parties.
- The agent's reading: a minority stake does not by itself exclude the link. This is to be confirmed by the PI or a lawyer, and the guidance version in force in 2021 still has to be checked.
- Implication for C2 step 2: the intra-company route probably stayed open for parent-to-IJV transfers, so the mobility channel acts mainly on hiring outside the parent group.

**Section 7, recommendations on the unsure records (PI decision 6):**
- Include (7): CC-S3-20 (Chung and Beamish 2010), CC-S2-10 (Doz and Prahalad 1980), CC-S2-05 (Prahalad and Doz 1981), CC-S1-16 (Bouquet and Birkinshaw 2008), CON-S5-03 (Atanassova and Makhmadshoev 2026, T4 context only), CON-S1-03 (Cocito et al. 2004, a working paper, under the G1 item 5 rule) and CON-S1-06 (Andersson and Forsgren 2002).
- Exclude (7): CON-S2-04, CON-S2-07, CC-S1-17, CON-S5-10, CC-S5-05, CC-S5-08 and CC-S5-09.
- This changes the synthesizer's list of highest-value records: CON-S2-04 is recommended for exclusion, because it covers the marketing function alone and gives no classification across functions.

**Section 8.** `downes2000knowledge` is still unverified. JSTOR stable 40604301 (an OpenAlex lead) did not load; a library check would settle it.

**Consensus.** None of the three agents had the connector, so none of the results rests on it.

### Targeted follow-up search (literature-searcher, 2026-11-24)

A Stage 1 increment, run in parallel for the search requests above. The memo is `literature/search/targeted-followup-2026-11-24.md`; the logs are `literature/search/search-log.md` and `search-strings.md`, both in sections dated 2026-11-24.

**What ran.** 24 OpenAlex queries and 2 web searches. Consensus was not exposed in that session either, and the manual Web of Science, EBSCO and Google Scholar runs are still outstanding.

**Screening.** `screening.csv` gained 383 rows (the 162 earlier rows are unchanged): 30 duplicates and 353 unique records, of which 34 are included, 67 unsure and 252 excluded. 27 of the unsure records carry the prefix `scope:`. They fall outside protocol criteria (a) to (g) (single-firm HRM, internal labor markets, labor-economics task data) and are kept only as the sole evidence found for a request. The PI decides whether the protocol is widened for them.

**Nothing relevant found for:**
- contingency fit of a unit with two parents at the level of functions or staffing (entry 10);
- the local parent as a supplier of staff (18, 45);
- staffing in IJVs with two foreign parents (20);
- O\*NET as an interdependence measure in management research (26);
- Brexit and the staffing of subsidiaries or IJVs (38);
- effects of screening on established affiliates (42).

**Closest candidates.**
- Contingency fit in IJV control: Lu and Hébert 2004; Pangarkar and Klein 2004; Luo and Tan 2003.
- Local parent: Björkman and Lu 2001; Yan 2003.
- Brexit and workforce composition: Castro-Pires et al. 2026.
- Task data: Kim, Park and Prescott 2003 (OA-S2-01, include); Costinot et al.; Oldenski 2012.

The DOIs of these candidates are as OpenAlex returned them and are unverified; nothing was added to the bib.

**New manual strings** (WoS, EBSCO and Google Scholar): S7-staffing, S7-multiparent, S7-adjust, S8-levels, S3-local, S3-foreign, S4-source, S6-task, S9f, S9g and S9b2. The proposed run order is the S7 blocks first. The old S9d block does not retrieve Brexit at all.

**Effect on the gap statement.** The bounded "not studied" claims for H3 and H4 now rest on a larger agent search, but still not on the manual database runs.

## PI notes (filled in by the PI; applied by the orchestrator if status is APPROVED WITH CHANGES)

Recorded by the agent on 2026-11-24 from the PI's answer "Accept all" to the decision sheet `docs/coauthor-notes/gate-2-decision-sheet-2026-11-24.qmd`. The decisions are logged in `docs/decisions.md` (2026-11-24). The Status line above is set by the PI or on the PI's instruction.

1. **Gate status:** approved with changes, as a provisional synthesis. G2 is re-run when the manual exports arrive.
2. **Searches:** the manual blocks S7-multiparent, S7-staffing and S3-local are run before gate 5 is approved. The other new blocks are run before stage 8.
3. **Resource dependence theory** is the rival account, not a complement. The pre-analysis plan adds a domain-level check, whether a parent's industry matches the occupation group, citing `pfeffer1978external`.
4. **O\*NET** stays the primary source of the static scores. A verified function-level ordering (`kim2003global`) serves as a check of convergent validity. The gap between generic and parent-specific coordination is stated as a limitation.
5. **Evidence basis:** OpenAlex abstracts are accepted for this provisional gate. Full texts of the most exposed works are retrieved before gate 5: `lawrence1967organization`, `prahalad1987multinational`, `geringer1989control`, `bartlett1989managing`, `choi2004split`, `kim2003global`, and the H3 candidates of the follow-up search.
6. **Microfoundations:** the step from a domain's need for parent-specific knowledge to the parent-origin hire is stated as a domain-level assumption. The H1 mechanism in the research brief is reworded.
7. **Records:** the reference agent's recommendations on the 14 unsure G1 records are accepted (include 7, exclude 7). The three methods records (CON-S6-09, CON-S6-10, CON-S6-01) and Peterson et al. 1999 are also included.
8. **Proceedings, working papers and dissertations** are admitted when no peer-reviewed version exists, flagged in the bib, and never as the sole support for a hypothesis.
9. **Search protocol version 1.2:** a task-data stream; the function-level question added to S2; records marked `scope:` admitted only as support for the hiring-source step of H3.
10. **`coord_role`:** the level part of H1 is carried as exploratory, with `mintzberg1979structuring` as the candidate source.
11. **Edits to earlier-stage files are authorized and applied:**
    - `docs/theory-framework.md`: pointers only; the hierarchy is unchanged;
    - `docs/research-brief.md`;
    - `literature/search/protocol.md`;
    - `docs/decisions.md`.

    The `data/codebook.md` update waits for stage 5 or 6.
