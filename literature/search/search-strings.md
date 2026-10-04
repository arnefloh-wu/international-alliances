# Search strings

Status: drafted 2026-10-02 by workflow setup. Consensus run on 2026-10-02
by the literature-searcher agent (one query per stream, no filters, free
tier, 10 records per query). Web of Science, EBSCO Business Source and
Google Scholar have NOT been run: no agent access, and
`literature/search/exports/` is empty. The literature-searcher agent
updates each block with the run date and the number of records when an
export is ingested.

Protocol v1.1 (2026-10-02) added streams S7, S8 and S9 (tiers in `docs/theory-framework.md`). They have not been run anywhere; Consensus quota is exhausted for the month except 3 searches, so they depend on the manual runs.

Syntax notes. Web of Science: `TS=` searches title, abstract, author
keywords and Keywords Plus; `NEAR/3` is proximity; `*` wildcard. EBSCO
Business Source: `TI`, `AB`, `SU` field codes, `N3` proximity, `*`
wildcard; limit to Scholarly (Peer Reviewed) Journals. Google Scholar:
no field codes beyond `intitle:`, no wildcard, OR must be upper-case;
strings are shortened accordingly and run in several variants.

## S1 Differentiated network, internal configuration of MNEs

Web of Science
```
TS=(("differentiated network" OR "differentiated fit" OR "internal differentiation" OR "subsidiary role*" OR "subsidiary autonomy" OR "headquarters-subsidiary" OR "headquarter* subsidiar*") AND (multinational* OR MNE OR MNC OR "international business"))
```
EBSCO
```
(TI("differentiated network" OR "internal differentiation" OR "subsidiary role*" OR "subsidiary autonomy" OR "headquarters-subsidiary") OR AB("differentiated network" OR "internal differentiation" OR "subsidiary role*" OR "subsidiary autonomy" OR "headquarters-subsidiary")) AND (multinational* OR MNE OR MNC)
```
Google Scholar (variants)
```
"differentiated network" multinational subsidiary integration
"subsidiary autonomy" OR "subsidiary role" integration multinational function
```
Consensus (natural-language query, no filters; saved in `hits-consensus-S1-2026-10-02.md`)
```
differentiated network of multinational corporation: how subsidiaries and internal units differ in integration, subsidiary roles and autonomy
```
Run: WoS not yet run (2026-10-02) | EBSCO not yet run (2026-10-02) | GS not yet run (2026-10-02) | Consensus run 2026-10-02 | Records: WoS not run, EBSCO not run, GS not run, Consensus 10

## S2 Integration-responsiveness and contingency

Web of Science
```
TS=(("integration-responsiveness" OR "integration responsiveness" OR "global integration" OR "local responsiveness" OR "global-local" OR "glocal*") AND (multinational* OR MNE OR MNC OR subsidiar* OR "joint venture*" OR alliance*) AND (function* OR "value chain" OR activit* OR "business function*" OR marketing OR "human resource*" OR R&D OR manufacturing))
```
EBSCO
```
(TI("global integration" OR "local responsiveness" OR "integration-responsiveness") OR AB("global integration" OR "local responsiveness" OR "integration-responsiveness")) AND (multinational* OR subsidiar* OR "joint venture*" OR alliance*) AND (function* OR "value chain" OR activit*)
```
Google Scholar
```
"integration-responsiveness" function OR activity multinational "value chain"
"global integration" "local responsiveness" functional level subsidiary
```
Consensus (natural-language query, no filters; saved in `hits-consensus-S2-2026-10-02.md`)
```
integration-responsiveness: global integration versus local responsiveness at the functional or activity level in multinationals and joint ventures
```
Run: WoS not yet run (2026-10-02) | EBSCO not yet run (2026-10-02) | GS not yet run (2026-10-02) | Consensus run 2026-10-02 | Records: WoS not run, EBSCO not run, GS not run, Consensus 10

## S3 IJV control, staffing and organization

Web of Science
```
TS=(("international joint venture*" OR IJV OR IJVs OR "cross-border joint venture*" OR "equity joint venture*") AND (control OR staffing OR "management control" OR "parent control" OR "parent dominance" OR "dominant parent" OR "shared management" OR "split control" OR "decision right*" OR "decision-making" OR "organi?ation* design" OR "management structure"))
```
EBSCO
```
(TI("international joint venture*" OR IJV OR "cross-border joint venture*") OR AB("international joint venture*" OR IJV OR "cross-border joint venture*")) AND (control OR staffing OR "parent control" OR "dominant parent" OR "shared management" OR "decision right*" OR "management structure")
```
Google Scholar
```
"international joint venture" control staffing "parent" dominant OR shared management
"international joint venture" "decision rights" OR "decision-making" structure function
```
Consensus (natural-language query, no filters; saved in `hits-consensus-S3-2026-10-02.md`)
```
international joint venture control, staffing and management structure: parent dominance, shared management and decision rights
```
Run: WoS not yet run (2026-10-02) | EBSCO not yet run (2026-10-02) | GS not yet run (2026-10-02) | Consensus run 2026-10-02 | Records: WoS not run, EBSCO not run, GS not run, Consensus 10

## S4 Expatriate and parent-origin staffing, knowledge transfer

Web of Science
```
TS=((expatriat* OR "parent-country national*" OR PCN OR "host-country national*" OR HCN OR "third-country national*" OR "staffing polic*" OR "international staffing" OR "subsidiary staffing" OR "inpatriat*") AND (multinational* OR MNE OR MNC OR subsidiar* OR "joint venture*") AND (control OR coordination OR "knowledge transfer" OR integration OR socializ* OR legitimac*))
```
EBSCO
```
(TI(expatriat* OR "parent-country national*" OR "host-country national*" OR "international staffing" OR "subsidiary staffing") OR AB(expatriat* OR "parent-country national*" OR "host-country national*" OR "international staffing" OR "subsidiary staffing")) AND (multinational* OR subsidiar* OR "joint venture*") AND (control OR coordination OR "knowledge transfer" OR integration)
```
Google Scholar
```
expatriate "subsidiary staffing" control coordination "knowledge transfer" multinational
"parent country nationals" "host country nationals" joint venture staffing
```
Consensus (natural-language query, no filters; saved in `hits-consensus-S4-2026-10-02.md`)
```
expatriate and parent-country national staffing of foreign subsidiaries and joint ventures: control, coordination and knowledge transfer
```
Run: WoS not yet run (2026-10-02) | EBSCO not yet run (2026-10-02) | GS not yet run (2026-10-02) | Consensus run 2026-10-02 | Records: WoS not run, EBSCO not run, GS not run, Consensus 10

## S5 Geopolitics, political risk and the organization of international activity

Web of Science
```
TS=((geopolitic* OR "political risk" OR "political relation*" OR "bilateral relation*" OR "political tension*" OR "political conflict*" OR sanction* OR "economic nationalism" OR "investment screening" OR "trade war" OR decoupling OR "de-globali?ation" OR deglobali?ation) AND (multinational* OR MNE OR MNC OR subsidiar* OR "joint venture*" OR alliance* OR "foreign direct investment" OR FDI) AND (organi?ation* OR staffing OR locali?ation OR restructur* OR reconfigur* OR "operating mode" OR coordination OR control))
```
EBSCO
```
(TI(geopolitic* OR "political risk" OR "political tension*" OR sanction* OR "investment screening" OR decoupling) OR AB(geopolitic* OR "political risk" OR "political tension*" OR sanction* OR "investment screening" OR decoupling)) AND (multinational* OR subsidiar* OR "joint venture*" OR alliance* OR FDI) AND (organi?ation* OR staffing OR locali?ation OR restructur* OR reconfigur*)
```
Google Scholar
```
geopolitical tension multinational subsidiary localization OR restructuring staffing
"political relations" OR sanctions "joint venture" staffing OR control reconfiguration
```
Consensus (natural-language query, no filters; saved in `hits-consensus-S5-2026-10-02.md`)
```
geopolitical tension, political risk and sanctions: how multinational enterprises reorganize, restructure or localize foreign subsidiaries, joint ventures and alliances
```
Run: WoS not yet run (2026-10-02) | EBSCO not yet run (2026-10-02) | GS not yet run (2026-10-02) | Consensus run 2026-10-02 | Records: WoS not run, EBSCO not run, GS not run, Consensus 10

## S6 Employment-history data in management research

Web of Science
```
TS=(("Revelio" OR "LinkedIn data" OR "LinkedIn profile*" OR "online resume*" OR "online résumé*" OR "employment histor*" OR "job histor*" OR "career histor*" OR "Burning Glass" OR "Lightcast") AND (firm* OR organization* OR organisation* OR subsidiar* OR "workforce composition" OR "human capital" OR "employee mobility"))
```
EBSCO
```
(TI("LinkedIn" OR "employment histor*" OR "career histor*" OR "online resume*" OR "Revelio") OR AB("LinkedIn" OR "employment histor*" OR "career histor*" OR "online resume*" OR "Revelio")) AND (firm* OR organization* OR "workforce composition" OR "employee mobility")
```
Google Scholar
```
"Revelio Labs" data firm workforce
"LinkedIn" "employment histories" measure workforce composition firm study
```
Consensus (natural-language query, no filters; saved in `hits-consensus-S6-2026-10-02.md`)
```
LinkedIn or Revelio Labs employment histories used to measure workforce composition and organizational structure of firms in management research
```
Run: WoS not yet run (2026-10-02) | EBSCO not yet run (2026-10-02) | GS not yet run (2026-10-02) | Consensus run 2026-10-02 | Records: WoS not run, EBSCO not run, GS not run, Consensus 10

## S7 Structural contingency theory (T1, added in protocol v1.1)

Status: drafted 2026-10-02, not run. Two variants: S7-core (theory itself) and S7-IB (contingency logic in international settings).

Web of Science, S7-core
```
TS=(("contingency theory" OR "structural contingency" OR "contingency approach" OR "contingency perspective" OR "organi?ational fit" OR "structural fit" OR "contingency fit" OR "structural adjustment" OR "task interdependence" OR "task uncertainty") AND (organi?ation* OR firm* OR structure*) AND (environment* OR "information processing" OR differentiation OR integration OR coordination OR fit OR misfit))
```
Web of Science, S7-IB
```
TS=(("contingency theory" OR "contingency perspective" OR "contingency approach" OR "structural contingency" OR "organi?ational fit") AND (multinational* OR MNE OR "international business" OR "joint venture*" OR alliance*))
```
EBSCO, S7-core
```
(TI("contingency theory" OR "structural contingency" OR "contingency approach" OR "organi?ational fit" OR "structural adjustment") OR AB("contingency theory" OR "structural contingency" OR "contingency approach" OR "organi?ational fit" OR "structural adjustment")) AND (organi?ation* OR firm*) AND (environment* OR "information processing" OR differentiation OR integration OR coordination OR misfit)
```
EBSCO, S7-IB
```
(TI("contingency theory" OR "contingency perspective" OR "structural contingency" OR "organi?ational fit") OR AB("contingency theory" OR "contingency perspective" OR "structural contingency" OR "organi?ational fit")) AND (multinational* OR "joint venture*" OR alliance* OR "international business")
```
Google Scholar (variants)
```
"structural contingency theory" fit misfit environment organizational structure adjustment
"contingency theory" multinational OR "joint venture" OR alliance structure function
```
Run: [not run] | Records: WoS [ ] EBSCO [ ] GS [ ]

## S8 Organizational design: differentiation across functions and levels, decision rights, control mechanisms (T3, added in v1.1)

Status: drafted 2026-10-02, not run.

Web of Science
```
TS=(("organi?ational design" OR "organi?ational structure" OR "decision right*" OR "decision authority" OR "control mechanism*" OR "formal control" OR "coordination mechanism*" OR "differentiation and integration" OR "functional differentiation") AND (function* OR "hierarchical level*" OR hierarch* OR "management level*") AND (alliance* OR "joint venture*" OR multinational* OR subsidiar* OR "interorgani?ational"))
```
EBSCO
```
(TI("organi?ational design" OR "decision right*" OR "control mechanism*" OR "coordination mechanism*" OR "differentiation and integration") OR AB("organi?ational design" OR "decision right*" OR "control mechanism*" OR "coordination mechanism*" OR "differentiation and integration")) AND (function* OR hierarch* OR "management level*") AND (alliance* OR "joint venture*" OR multinational* OR subsidiar*)
```
Google Scholar (variants)
```
"decision rights" OR "control mechanisms" alliance OR "joint venture" functions hierarchical levels organizational design
"coordination mechanisms" "strategic alliances" governance design functional differentiation
```
Run: [not run] | Records: WoS [ ] EBSCO [ ] GS [ ]

## S9 Candidate geopolitical shocks (T4, added in v1.1; feeds the shock scan)

Status: drafted 2026-10-02, not run. One string per shock family, S9a to S9e. The `shock-evaluator` agent may also use these as WebSearch queries. Records from S9 are used for two purposes: theory and evidence (T4 context) and the novelty assessment in the shock scan.

S9a Sanctions. Web of Science
```
TS=(("economic sanction*" OR "financial sanction*" OR "sanction* regime*" OR "secondary sanction*") AND (firm* OR multinational* OR MNE OR "joint venture*" OR subsidiar* OR alliance* OR "foreign direct investment") AND (organi?ation* OR staffing OR exit OR divest* OR locali?ation OR restructur* OR reconfigur* OR "human resource*" OR employee*))
```
S9a EBSCO
```
(TI("economic sanction*" OR "financial sanction*" OR "secondary sanction*") OR AB("economic sanction*" OR "financial sanction*" OR "secondary sanction*")) AND (firm* OR multinational* OR "joint venture*" OR subsidiar*) AND (organi?ation* OR staffing OR exit OR divest* OR restructur*)
```
S9a Google Scholar
```
sanctions multinational OR "joint venture" staffing OR exit OR restructuring OR localization
```
S9b Investment screening. Web of Science
```
TS=(("investment screening" OR "foreign investment screening" OR "FDI screening" OR "investment review" OR "national security review" OR CFIUS OR "foreign investment restriction*") AND (firm* OR multinational* OR "joint venture*" OR alliance* OR acquisition* OR "foreign direct investment"))
```
S9b EBSCO
```
(TI("investment screening" OR "FDI screening" OR "national security review" OR CFIUS OR "foreign investment restriction*") OR AB("investment screening" OR "FDI screening" OR "national security review" OR CFIUS OR "foreign investment restriction*")) AND (firm* OR multinational* OR "joint venture*" OR acquisition*)
```
S9b Google Scholar
```
"investment screening" OR "FDI screening" multinational "joint venture" OR alliance
```
S9c Export controls and technology restrictions. Web of Science
```
TS=(("export control*" OR "technology restriction*" OR "entity list" OR "technology transfer restriction*" OR "technological decoupling" OR "tech decoupling") AND (firm* OR multinational* OR "joint venture*" OR alliance* OR subsidiar* OR R&D))
```
S9c EBSCO
```
(TI("export control*" OR "technology restriction*" OR "entity list" OR "technological decoupling") OR AB("export control*" OR "technology restriction*" OR "entity list" OR "technological decoupling")) AND (firm* OR multinational* OR "joint venture*" OR subsidiar*)
```
S9c Google Scholar
```
"export controls" OR "entity list" multinational firms organization R&D "joint venture" OR subsidiary
```
S9d Mobility and visa restrictions. Web of Science
```
TS=(("visa restriction*" OR "travel restriction*" OR "travel ban*" OR "immigration polic*" OR "work permit*" OR "mobility restriction*" OR "talent mobility" OR "skilled migration polic*") AND (firm* OR multinational* OR expatriat* OR subsidiar* OR "joint venture*" OR "international assignment*"))
```
S9d EBSCO
```
(TI("visa restriction*" OR "travel restriction*" OR "travel ban*" OR "immigration polic*" OR "mobility restriction*") OR AB("visa restriction*" OR "travel restriction*" OR "travel ban*" OR "immigration polic*" OR "mobility restriction*")) AND (firm* OR multinational* OR expatriat* OR subsidiar*)
```
S9d Google Scholar
```
"visa restrictions" OR "travel restrictions" OR "mobility restrictions" expatriates multinational subsidiary staffing
```
S9e Bilateral political relations. Web of Science
```
TS=(("bilateral political relation*" OR "diplomatic relation*" OR "political tension*" OR "diplomatic conflict*" OR "territorial dispute*" OR "political animosity" OR "country-level animosity" OR "geopolitical distance" OR "political distance") AND (firm* OR multinational* OR "joint venture*" OR alliance* OR subsidiar* OR "foreign direct investment") AND (staffing OR organi?ation* OR ownership OR exit OR equity OR locali?ation OR performance))
```
S9e EBSCO
```
(TI("bilateral political relation*" OR "diplomatic relation*" OR "political tension*" OR "political animosity" OR "geopolitical distance" OR "political distance") OR AB("bilateral political relation*" OR "diplomatic relation*" OR "political tension*" OR "political animosity" OR "geopolitical distance" OR "political distance")) AND (firm* OR multinational* OR "joint venture*" OR subsidiar*) AND (staffing OR organi?ation* OR ownership OR exit OR locali?ation)
```
S9e Google Scholar
```
"political tension" OR "diplomatic relations" OR "political distance" "joint venture" OR subsidiary staffing OR ownership OR exit
```
Run: [not run] | Records: WoS [ ] EBSCO [ ] GS [ ]

## Export instructions for manual runs

- Web of Science: Export > RIS (Other File Formats), "Full Record",
  500 records per file; name `exports/wos-S<n>-<date>-<part>.ris`.
- EBSCO: Share > Export > RIS, all pages (use the folder); name
  `exports/ebsco-S<n>-<date>.ris`.
- Google Scholar: use Publish or Perish (Harzing) with the string as the
  "Keywords" query, max 200 results, export CSV; name
  `exports/gs-S<n>-<date>.csv`.

## Consensus run log, 2026-10-02

Tool: Consensus connector, free tier (10 results per search, no DOI field returned; the last call reported 3 searches left this month, reset on 1 November 2026). No filters were applied. The rate limiter rejected some parallel calls; rejected calls returned no records and were re-run singly. Only the successful run of each query is logged.

| Purpose | Stream | Query (exact) | Records |
|---|---|---|---|
| Stream search | S1 | see S1 block | 10 |
| Stream search | S2 | see S2 block | 10 |
| Stream search | S3 | see S3 block | 10 |
| Stream search | S4 | see S4 block | 10 |
| Stream search | S5 | see S5 block | 10 |
| Stream search | S6 | see S6 block | 10 |
| Seed verification | S4 | Knowledge acquisition from foreign parents in international joint ventures: an empirical examination in the Hungarian context | 9 |
| Seed verification | S2 | Managing DMNCs: a search for a new paradigm (Doz and Prahalad) | 10 |
| Seed verification | S5 | The MNE and its subsidiaries at times of global disruptions: an international relations perspective | 10 |
| Citation chase | S1 | building on Ghoshal and Nohria (1989) and Nohria and Ghoshal (1997) differentiated network: headquarters-subsidiary relationships differ by subsidiary context | 10 |
| Citation chase | S1 | building on Bartlett and Ghoshal (1989), Birkinshaw and Hood (1998) and Birkinshaw and Morrison (1995): subsidiary roles, charter change and differentiated subsidiary management in multinationals | 10 |
| Citation chase | S2 | building on Prahalad and Doz (1987) and Roth and Morrison (1990): integration-responsiveness pressures and strategy at business unit or functional level | 10 |
| Citation chase | S3 | studies building on Geringer and Hebert (1989) on the scope, extent and mechanisms of parent control in international joint ventures | 10 |
| Citation chase | S3 | building on Killing (1983), Yan and Gray (1994), Mjoen and Tallman (1997) and Choi and Beamish (2004): dominant, shared and split control of activities in international joint ventures | 10 |
| Citation chase | S4 | building on Edstrom and Galbraith (1977), Harzing (2001), Gong (2003) and Gaur, Delios and Singh (2007): staffing of subsidiaries with parent-country nationals and its effects | 10 |
| Citation chase | S5 | building on Witt (2019) deglobalization and Petricevic and Teece (2019) structural reshaping of globalization: effects on organization of multinational operations and joint ventures | 10 |
| Citation chase | S6 | management or international business study using Revelio Labs or LinkedIn-based employee profiles to measure firm workforce composition, hierarchy levels, or subsidiary employees | 10 |

Consensus does not return citing or cited-by lists. The chase queries therefore return semantically related papers, not verified citations; see `search-log.md` for how this limits the chase.

## Manual runs still required (strings above are final unless the PI edits them)

| Database | Streams | Status |
|---|---|---|
| Web of Science Core Collection | S1 to S6 | not yet run |
| Web of Science Core Collection | S7 (core, IB), S8, S9a to S9e (added in v1.1) | not yet run |
| EBSCO Business Source | S1 to S6 | not yet run |
| EBSCO Business Source | S7 (core, IB), S8, S9a to S9e | not yet run |
| Google Scholar (Publish or Perish, max 200 per string) | S1 to S6, both variants where two are listed | not yet run |
| Google Scholar (Publish or Perish, max 200 per string) | S7 to S9, variants as listed | not yet run |
