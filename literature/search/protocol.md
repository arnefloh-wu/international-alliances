# Literature search protocol

Project: Differentiated international integration in IJVs (JIBS).
Version: 1.1, 2026-10-02 (v1.0 run the same day; v1.1 adds the theory hierarchy and streams S7 to S9). Owner: literature-searcher agent, approved at G1.

## Aim

Identify the literature needed to (a) establish structural contingency
theory as the main theory and show how it has been applied in
international business, (b) position the construct of differentiated
international integration against existing alliance- and MNE-level
integration concepts, (c) derive the mechanisms behind the hypotheses
from contingency logic, (d) justify the measurement of integration
through employees' prior organizational affiliation, and (e) identify
and compare candidate geopolitical shocks as sources of changing
contingencies. The hierarchy of tiers is defined in
`docs/theory-framework.md`.

## Streams, tiers and seed works

Streams S1 to S6 were searched on 2026-10-02 and keep their IDs. S7 to S9
are new in v1.1 and have not been searched.

| Stream | Tier | Core question for this paper | Seed works (include regardless of hits) |
|---|---|---|---|
| S7 Structural contingency theory | T1 main theory | How do task, environmental, resource and coordination contingencies shape organizational structure, how does a change in contingencies lead to structural adjustment, and how are multiple and misaligned contingencies handled? | Burns & Stalker 1961 (The Management of Innovation); Woodward 1965 (Industrial Organization); Lawrence & Lorsch 1967 (Organization and Environment); Thompson 1967 (Organizations in Action); Child 1972 (Sociology); Galbraith 1973 (Designing Complex Organizations); Drazin & Van de Ven 1985 (ASQ); Donaldson 1987 (JMS, structural adjustment to regain fit); Donaldson 2001 (The Contingency Theory of Organizations); Van de Ven, Ganco & Hinings 2013 (Academy of Management Annals) |
| S1 Differentiated network and MNE internal configuration | T2 related IB framework | How do internal units of an internationally dispersed organization differ in integration, and why? | Nohria & Ghoshal 1997 (The Differentiated Network); Ghoshal & Nohria 1989 (SMJ); Bartlett & Ghoshal 1989; Birkinshaw & Hood 1998 (AMR); Kostova & Roth 2002 (AMJ) |
| S2 Integration-responsiveness and contingency in international organization | T2 related IB framework | What determines the global-local balance of a function or unit? | Prahalad & Doz 1987; Doz & Prahalad 1991 (SMJ); Roth & Morrison 1990 (JIBS); Venaik, Midgley & Devinney 2005 (JIBS); additional in v1.1: Stopford & Wells 1972; Egelhoff 1982 (ASQ). Lawrence & Lorsch 1967 is a T1 seed and stays in the sheet under S2 and is also tracked under S7. |
| S3 IJV control, staffing and organization | T3 supporting literature | How are IJVs staffed and controlled by parents, and with what consequences? | Killing 1983; Geringer & Hebert 1989 (JIBS); Schaan 1983; Yan & Gray 1994 (AMJ); Mjoen & Tallman 1997 (Org Sci); Luo, Shenkar & Nyaw 2001 (JIBS) |
| S4 Expatriate and parent-origin staffing, knowledge transfer | T3 supporting literature | What does staffing from a parent firm do inside a foreign unit? | Edstrom & Galbraith 1977 (ASQ); Harzing 2001 (JWB); Gong 2003 (AMJ); Gaur, Delios & Singh 2007 (JoM); Lyles & Salk 1996 (JIBS); Inkpen & Beamish 1997 (AMR) |
| S8 Organizational design: differentiation across functions and levels, decision rights, control mechanisms | T3 supporting literature | How do organizations differentiate structure across functions and hierarchical levels, allocate decision rights, and choose control mechanisms, and how does this apply to alliances? | Galbraith 1974 (Interfaces); Mintzberg 1979 (The Structuring of Organizations); Ouchi 1979 (Management Science); Eisenhardt 1985 (Management Science); Jensen & Meckling 1992 (Journal of Applied Corporate Finance); Puranam, Alexy & Reitzig 2014 (AMR); Gulati, Wohlgezogen & Zhelyazkov 2012 (Academy of Management Annals) |
| S5 Geopolitics, political risk and the organization of international activity | T4 environmental context | How do geopolitical shocks reshape the organization of foreign operations and alliances? | Witt 2019 (JIBS); Witt, Lewin, Li & Gaur 2023 (JWB, corrected at Stage 1); Meyer & Li 2022 (GSJ, co-author unconfirmed); Petricevic & Teece 2019 (JIBS); Henisz 2000 (JLEO); Li, Meyer, Zhang & Ding 2018 (JIBS) |
| S9 Candidate geopolitical shocks | T4 environmental context, feeds Stage 5a | Which geopolitical developments (sanctions, investment screening, export controls, mobility restrictions, bilateral political deterioration) change the contingencies of different IJV domains, how have they been studied, and how are they measured? | none fixed; the `shock-evaluator` agent builds the list. Data-source papers to verify: Felbermayr et al. 2020 (Global Sanctions Data Base, European Economic Review); Bailey, Strezhnev & Voeten 2017 (Journal of Conflict Resolution, UN voting ideal points); Caldara & Iacoviello 2022 (American Economic Review, geopolitical risk index) |
| S6 Employment-data methods in management research | Methods | How have LinkedIn-type employment histories (Revelio, Burning Glass) been used to measure organizational composition? | none; the search identifies recent JIBS, SMJ and Org Sci papers using Revelio Labs or LinkedIn-based employment histories |

Seed works are listed from memory at setup. The search agent confirms
each one (year, outlet, authors) before marking it `seed` in the
screening sheet, and no seed is cited until the reference-manager has
verified the entry. Seeds added in v1.1 (S7, S8, S9 and the two additions
to S2) have not been checked at all.

## Databases

| Database | Access | Fields | Date range | Filters |
|---|---|---|---|---|
| Web of Science Core Collection | manual (PI) unless API key supplied | TS (topic) | 1985 to present | Document type: article, review; Categories: Business, Management |
| EBSCO Business Source | manual (PI) | TI, AB, SU | 1985 to present | Scholarly (peer reviewed) journals |
| Google Scholar | manual (PI); first 200 results per string | all | no limit | none; used for citation chase and grey literature |
| Consensus | agent | semantic | none | none unless stated |

Journal list for screening priority (not exclusion): JIBS, JWB, GSJ,
JMS, AMJ, AMR, SMJ, Org Sci, JoM, MIR, JIM, IBR, ASQ, Org Studies.

## Inclusion criteria (title and abstract stage)

Include if the paper (a) theorizes or measures integration, coordination,
control, autonomy, staffing or localization at the level of a unit,
function, team, hierarchical level or individual inside an MNE, IJV or
alliance; or (b) studies IJV organization, control or staffing; or (c)
studies how geopolitical or regulatory change alters the organization or
staffing of foreign operations or alliances; or (d) uses employment-
history data to measure organizational composition.

Exclude if the paper (a) treats the alliance or subsidiary only as a
whole with no internal differentiation and does not concern IJV control
or staffing; (b) is about alliance formation, partner selection or
performance outcomes only; (c) is a non-scholarly source; (d) is not in
English or German.

Amendments in v1.1:

- Include also if the paper (e) develops, tests or reviews structural
  contingency theory, contingency fit or misfit, or structural
  adjustment to environmental change; (f) concerns organizational design
  across functions or hierarchical levels, decision rights or control
  mechanisms; or (g) studies the effects of sanctions, investment
  screening, export controls, mobility or visa restrictions, or bilateral
  political deterioration on firms' organization, staffing or alliances
  (stream S9; also used for candidate-shock evidence).
- Do not include a paper only because it offers individual-level
  microfoundations (for example identity, trust or social-tie mechanisms)
  unless it also meets (a) to (g). Microfoundations are outside the
  framework unless the interviews call for them (`docs/theory-framework.md`).

## Screening

Two-stage: title/abstract, then full text for items marked include or
unsure. Every exclusion has a reason code: `A_level` (alliance-level
only), `B_formation` (formation/performance only), `C_nonscholarly`,
`D_language`, `E_offtopic`, `F_duplicate`.

## Citation chase

Backward and forward citation search on the five most-cited included
works per stream. The Consensus free tier cannot support this (no
cited-by lists, 3 searches left until 2026-11-01); Google Scholar
"cited by" run manually is the primary route. Forward citations via Consensus or Google Scholar
"cited by", logged with date.

## Reporting

PRISMA-style counts in `literature/search/search-log.md`. All strings
and run dates in `literature/search/search-strings.md`.
