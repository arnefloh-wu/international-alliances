# Literature search protocol

Project: Differentiated international integration in IJVs (JIBS).
Version: 1.0, 2026-10-02. Owner: literature-searcher agent, approved at G1.

## Aim

Identify the literature needed to (a) position the construct of
differentiated international integration against existing alliance- and
MNE-level integration concepts, (b) derive the mechanisms behind H1 to
H5, and (c) justify the measurement of integration through employees'
prior organizational affiliation.

## Streams and seed works

| Stream | Core question for this paper | Seed works (include regardless of hits) |
|---|---|---|
| S1 Differentiated network and MNE internal configuration | How do internal units of an internationally dispersed organization differ in integration, and why? | Nohria & Ghoshal 1997 (The Differentiated Network); Ghoshal & Nohria 1989 (SMJ); Bartlett & Ghoshal 1989; Birkinshaw & Hood 1998 (AMR); Kostova & Roth 2002 (AMJ) |
| S2 Integration-responsiveness and contingency in international organization | What determines the global-local balance of a function or unit? | Prahalad & Doz 1987; Doz & Prahalad 1991 (SMJ); Roth & Morrison 1990 (JIBS); Lawrence & Lorsch 1967; Venaik, Midgley & Devinney 2005 (JIBS) |
| S3 IJV control, staffing and organization | How are IJVs staffed and controlled by parents, and with what consequences? | Killing 1983; Geringer & Hebert 1989 (JIBS); Schaan 1983; Yan & Gray 1994 (AMJ); Mjoen & Tallman 1997 (Org Sci); Luo, Shenkar & Nyaw 2001 (JIBS) |
| S4 Expatriate and parent-origin staffing, knowledge transfer | What does staffing from a parent firm do inside a foreign unit? | Edstrom & Galbraith 1977 (ASQ); Harzing 2001 (JWB); Gong 2003 (AMJ); Gaur, Delios & Singh 2007 (JoM); Lyles & Salk 1996 (JIBS); Inkpen & Beamish 1997 (AMR) |
| S5 Geopolitics, political risk and the organization of international activity | How do geopolitical shocks reshape the organization of foreign operations and alliances? | Witt 2019 (JIBS); Witt, Lewin, Li & Gaur 2023 (JIBS); Meyer & Li 2022 (JIBS); Petricevic & Teece 2019 (JIBS); Henisz 2000 (JLEO); Li, Meyer, Zhang & Ding 2018 (JIBS) |
| S6 Employment-data methods in management research | How have LinkedIn-type employment histories (Revelio, Burning Glass) been used to measure organizational composition? | none; the search identifies recent JIBS, SMJ and Org Sci papers using Revelio Labs or LinkedIn-based employment histories |

Seed works are listed from memory at setup. The search agent confirms
each one (year, outlet, authors) before marking it `seed` in the
screening sheet, and no seed is cited until the reference-manager has
verified the entry.

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

## Screening

Two-stage: title/abstract, then full text for items marked include or
unsure. Every exclusion has a reason code: `A_level` (alliance-level
only), `B_formation` (formation/performance only), `C_nonscholarly`,
`D_language`, `E_offtopic`, `F_duplicate`.

## Citation chase

Backward and forward citation search on the five most-cited included
works per stream. Forward citations via Consensus or Google Scholar
"cited by", logged with date.

## Reporting

PRISMA-style counts in `literature/search/search-log.md`. All strings
and run dates in `literature/search/search-strings.md`.
