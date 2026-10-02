# Search strings

Status: drafted 2026-10-02 by workflow setup; not yet run. The
literature-searcher agent updates each block with the run date and the
number of records when a search is executed or an export is ingested.

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
Run: [date] | Records: WoS [ ] EBSCO [ ] GS [ ] Consensus [ ]

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
Run: [date] | Records: WoS [ ] EBSCO [ ] GS [ ] Consensus [ ]

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
Run: [date] | Records: WoS [ ] EBSCO [ ] GS [ ] Consensus [ ]

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
Run: [date] | Records: WoS [ ] EBSCO [ ] GS [ ] Consensus [ ]

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
Run: [date] | Records: WoS [ ] EBSCO [ ] GS [ ] Consensus [ ]

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
Run: [date] | Records: WoS [ ] EBSCO [ ] GS [ ] Consensus [ ]

## Export instructions for manual runs

- Web of Science: Export > RIS (Other File Formats), "Full Record",
  500 records per file; name `exports/wos-S<n>-<date>-<part>.ris`.
- EBSCO: Share > Export > RIS, all pages (use the folder); name
  `exports/ebsco-S<n>-<date>.ris`.
- Google Scholar: use Publish or Perish (Harzing) with the string as the
  "Keywords" query, max 200 results, export CSV; name
  `exports/gs-S<n>-<date>.csv`.
