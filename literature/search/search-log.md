# Search log (PRISMA-style), Stage 1 literature search

Date: 2026-10-02. Agent: literature-searcher. Protocol: `protocol.md` v1.0. Strings: `search-strings.md`. Screening sheet: `screening.csv`. Seed checks: `seed-verification.md`.

## Status in one paragraph

Only Consensus has been run. Web of Science, EBSCO Business Source and Google Scholar have not been run: the agent has no access to them and `literature/search/exports/` is empty. No hits are reported for those three databases, and every count below therefore describes a Consensus-plus-seed-list corpus, not the full systematic search the protocol specifies. The screening decisions are provisional and must be redone for the records that arrive from the manual runs.

## Databases and searches

| Database | Access | Streams run | Date | Strings logged | Records |
|---|---|---|---|---|---|
| Consensus (stream searches) | agent, free tier, no filters, 10 results per query | S1 to S6, one query each | 2026-10-02 | yes, `search-strings.md` and top of each `hits-consensus-S<n>-2026-10-02.md` | 60 (10 per stream) |
| Consensus (citation chase) | agent | S1 (2 queries), S2, S3 (2), S4, S5, S6 | 2026-10-02 | yes, `search-strings.md`, "Consensus run log" | 80 raw results from 8 queries (see limits below) |
| Consensus (seed verification) | agent | S2, S4, S5 | 2026-10-02 | yes | 29 results, used only to verify seeds, not counted as hits |
| WebSearch (seed verification, one pilot citation check) | agent | all seeds | 2026-10-02 | queries listed in `seed-verification.md` | not counted as hits |
| Web of Science Core Collection | manual (PI) | none | not run | strings final | 0 (not run) |
| EBSCO Business Source | manual (PI) | none | not run | strings final | 0 (not run) |
| Google Scholar (Publish or Perish) | manual (PI) | none | not run | strings final | 0 (not run) |

Run mechanics. The Consensus rate limiter rejected several calls issued in parallel (S1 and S3 in the first batch, S4 and S5 in the second, one S2 chase). Rejected calls returned no records and are not counted; each was re-run singly and only the successful run is logged. Consensus returns no DOI field, so no record from Consensus carries a DOI unless a seed source showed one.

## PRISMA flow (title/abstract stage)

| Step | n | Notes |
|---|---|---|
| Records identified, Consensus stream searches | 60 | S1 10, S2 10, S3 10, S4 10, S5 10, S6 10 |
| Records identified, seed list (protocol) | 28 | 6 already retrieved by Consensus, 22 added only as seeds |
| Records identified, citation chase (Consensus) | 80 | 8 queries; approximate chase, see limits |
| Records identified, Web of Science / EBSCO / Google Scholar | 0 | not run |
| Total records identified | 168 | |
| Duplicates removed (F_duplicate) | 33 | 6 seed/Consensus overlaps merged into one row each (Ghoshal & Nohria 1989, Yan & Gray 1994, Mjoen & Tallman 1997, Luo et al. 2001, Schaan 1983, Harzing 2001) plus 27 chase results already in the sheet (rows flagged `F_duplicate` with the retained id in `notes`) |
| Unique records | 135 | rows in `screening.csv` that are not F_duplicate |
| Seeds, included without screening | 28 | `title_abstract_decision = seed` |
| Records screened on title/abstract | 107 | 54 Consensus (non-seed) + 53 chase |
| Excluded at title/abstract | 21 | reasons below |
| Marked unsure, to full text | 19 | |
| Marked include, to full text | 67 | |
| Provisionally included for synthesis (seeds plus includes) | 95 | pending full-text screening and PI approval at G1 |
| Records proceeding to full-text screening (seeds, includes, unsure) | 114 | full text not yet retrieved; `full_text_decision = pending` |

Exclusion reasons at title/abstract (excluding duplicates).

| Code | n | Records |
|---|---|---|
| A_level | 3 | CON-S1-07, CON-S2-02, CON-S2-03 |
| B_formation | 2 | CON-S5-02, CC-S3-18 |
| C_nonscholarly | 1 | CC-S1-04 (Sloan working paper precursor of a seed) |
| D_language | 0 | |
| E_offtopic | 15 | CON-S2-08, CON-S6-07, CON-S6-08 and 12 chase records (see sheet) |
| F_duplicate | 33 | counted above under duplicates, 27 of them as rows |

## Per-stream counts (unique records)

| Stream | Consensus hits | Seed-only | Chase unique (raw, dup) | Unique total | Seeds | Include | Unsure | Exclude |
|---|---|---|---|---|---|---|---|---|
| S1 | 10 | 4 | 16 (20, 4) | 30 | 5 | 15 | 5 | 5 |
| S2 | 10 | 5 | 7 (10, 3) | 22 | 5 | 9 | 4 | 4 |
| S3 | 10 | 2 | 11 (20, 9) | 23 | 6 | 15 | 1 | 1 |
| S4 | 10 | 5 | 7 (10, 3) | 22 | 6 | 15 | 1 | 0 |
| S5 | 10 | 6 | 8 (10, 2) | 24 | 6 | 7 | 5 | 6 |
| S6 | 10 | 0 | 4 (10, 6) | 14 | 0 | 6 | 3 | 5 |
| Total | 60 | 22 | 53 (80, 27) | 135 | 28 | 67 | 19 | 21 |

"Include" excludes seeds. The Consensus-hit column counts every Consensus record including the six that are also seeds.

## Seeds

28 seeds in the protocol. 26 confirmed, 2 corrected (Witt et al. 2023 is JWB, not JIBS; Meyer & Li 2022 is a GSJ paper and the co-author is unconfirmed), 0 unconfirmed. Details and caveats in `seed-verification.md`. Seeds are marked `seed` in the sheet and included regardless of hits, as the protocol requires. No seed was added to `literature/references.bib`.

## Citation chase

Method. The protocol asks for backward and forward chasing on the five most-cited included works per stream. Neither Consensus nor WebSearch returns reference lists or cited-by lists, and Crossref, OpenAlex, Wiley (WebFetch) and Google Scholar were not reachable (egress policy or no access). The chase was therefore run as an approximation: one Consensus query per group of central works, phrased as "building on X (year) and Y (year)", which returns semantically related papers. A returned paper counts as evidenced forward citation only where the returned abstract or text names the focal work (flagged in `notes` as "abstract or text names a focal work"); otherwise it is logged as a "semantic neighbour; citation link not verified". Backward chasing (reading reference lists) was not run for any stream. Central works were chosen as seeds plus the highest Consensus-returned citation counts among included hits; the PI may overrule the choice.

| Stream | Central works | Chased by Consensus query | Not chased |
|---|---|---|---|
| S1 | Nohria & Ghoshal 1997; Ghoshal & Nohria 1989; Bartlett & Ghoshal 1989; Birkinshaw & Hood 1998; Birkinshaw & Morrison 1995 | all five (2 queries) | none |
| S2 | Prahalad & Doz 1987; Doz & Prahalad 1991; Roth & Morrison 1990; Venaik et al. 2005; Meyer et al. 2014 (GSJ) | Prahalad & Doz 1987; Roth & Morrison 1990 (Doz & Prahalad 1991 appeared as a duplicate) | Venaik et al. 2005; Meyer et al. 2014 |
| S3 | Geringer & Hebert 1989; Killing 1983; Yan & Gray 1994; Mjoen & Tallman 1997; Choi & Beamish 2004 | all five (2 queries) | none |
| S4 | Edstrom & Galbraith 1977; Harzing 2001 (JWB); Gong 2003; Gaur et al. 2007; Belderbos & Heijltjes 2005 | first four (1 query) | Belderbos & Heijltjes 2005 |
| S5 | Witt 2019; Petricevic & Teece 2019; Meyer et al. 2023 (sanctions); Witt et al. 2023 (JWB); Adarkwah et al. 2024 | Witt 2019; Petricevic & Teece 2019 | Meyer et al. 2023; Witt et al. 2023; Adarkwah et al. 2024 |
| S6 | none seeded; Babina et al. 2023; Liu et al. 2020; Park et al. 2019; Heiss et al. 2024; Wang et al. 2026 | not per work; one topical re-query surfaced one new include (Marchetti et al. 2025, SMJ) | all five per-work chases |

Reason for the gaps: the Consensus free tier reported 3 searches left for the month after the eighth chase query (reset on 1 November 2026). I stopped there instead of spending the remainder, so those chases are "not run", not "run with no result". The PI can either upgrade the Consensus plan or run Google Scholar "Cited by" and the reference lists manually for the works marked "not chased"; Google Scholar via Publish or Perish supports a cited-by lookup per paper.

WebSearch pilot, not counted. A WebSearch "cited by" query for Geringer & Hebert (1989) returned a search summary asserting these citing articles, with links that were RePEc listing pages that do not themselves show the citation relation: Huang & Chiu (2020, J Int Management), Firth (1996, Accounting, Organizations and Society), Fey (1995, European Management Journal), Mjoen & Tallman (1997), Hamel (1991, SMJ), Fryxell, Dooley & Vryza (2002, JMS), Child & Yan (2003, JMS), Johnson et al. (1996, JIBS), Blodgett (1991, JIBS). These could not be verified from a source page and were not added to the screening sheet. They are listed here only as leads for the manual Google Scholar "Cited by" run on that paper.

Chase yield: 80 results, 27 duplicates, 29 includes, 10 unsure, 14 exclusions. All chase rows have `source_db = citation_chase`.

## Findings that bear on the search itself

1. S6 returned no JIBS, SMJ or Org Sci paper that uses Revelio Labs by name. The closest are LinkedIn-profile studies in Strategy Science (Wang et al. 2026), SMJ (Marchetti et al. 2025), Information Systems Research (Liu et al. 2020), Nature Communications (Park et al. 2019), plus AOM Proceedings and SSRN items. The protocol's S6 aim (recent JIBS, SMJ and Org Sci papers using Revelio) is not met by Consensus; the Web of Science "Revelio" string and a Google Scholar run are needed before concluding that the literature is thin.
2. Consensus mislabels Strategic Management Journal as "Southern Medical Journal" for at least five records (see `seed-verification.md`, flag 5). Journal-list screening by outlet name would silently drop SMJ papers if applied to raw Consensus metadata.
3. Consensus metadata gaps affect 15 unique rows (truncated titles, "Unknown Journal", year N/A, a publisher name in the author field). They are flagged in `notes` and need resolving before any full-text screening.
4. Stream S5 contains conference-proceedings items (AOM Proceedings) that are directly on topic (CON-S5-04, CON-S5-09, CON-S6-03). The protocol does not say whether proceedings are scholarly; they are included provisionally.

## Limits of this log

- No Web of Science, EBSCO or Google Scholar record exists. No claim about coverage, saturation or the "first 200 Google Scholar results" can be made.
- Consensus returned 10 results per query on the free tier, so each stream search is a top-10 sample of a semantic ranking, not an exhaustive list.
- Title/abstract decisions use Consensus abstracts as returned (some truncated or absent). Full text has not been retrieved for any record.
- Dates in `year` are as returned by Consensus unless a seed source corrected them.

## Stage 2 addendum: targeted searches by the literature-synthesizer (2026-11-24)

Authorized by the Stage 2 brief (at most about five targeted searches for
S7, S8 and the O\*NET question; hits are candidates for the search agent,
not cited until screened and verified). The Consensus connector was not
available in this session, so the searches were run against the OpenAlex
API through the agent's web-fetch tool. Results were read through the
tool's summary, not exported; nothing was added to `screening.csv` or
`references.bib`. Candidates are listed in
`literature/synthesis/missing-references.md`.

| # | Date | Database | Purpose | Query (exact URL parameters) | Records shown | Usable candidates |
|---|---|---|---|---|---|---|
| 1 | 2026-11-24 | OpenAlex API | S7 | `search=structural contingency theory fit misfit structural adjustment&sort=cited_by_count:desc&per-page=15` | 15 | none (citation-sorted full-text search returned off-topic records) |
| 2 | 2026-11-24 | OpenAlex API | O\*NET as task-environment measure | `search=O*NET task interdependence work context occupation measure organization&sort=cited_by_count:desc&per-page=15` | 15 | none (off-topic) |
| 3 | 2026-11-24 | OpenAlex API | function-level IR classification (task 4a) | `search=global integration of business functions local responsiveness value chain activity multinational&sort=cited_by_count:desc&per-page=15` | 14 of 15 (page truncated by the tool) | none directly; off-topic at citation sort |
| 4 | 2026-11-24 | OpenAlex API | O\*NET offshorability (local embeddedness proxy) | `filter=title_and_abstract.search:O*NET offshorability&per-page=15` | 11 of 15 (page truncated by the tool) | 1: Blinder 2007, "How Many U.S. Jobs Might Be Offshorable" (RePEc) |
| 5 | 2026-11-24 | OpenAlex API | function-level integration (task 4a) | `filter=title.search:integration business functions multinational&per-page=15` | 1 | 1: Kim, Park & Prescott 2003, JIBS, doi 10.1057/palgrave.jibs.8400035 |

Lesson for the search agent: OpenAlex full-text search sorted by citations
is unusable for these topics; title or title-and-abstract filters with
relevance ranking worked. S7 and S8 still need the manual Web of Science,
EBSCO and Google Scholar runs specified in `search-strings.md`.

Also on 2026-11-24, abstracts of the 82 corpus works with a DOI in
`literature/references.bib` were requested from OpenAlex (batched DOI
filters) to replace screening-only evidence in the concept matrix; this is
retrieval of known records, not a search, and added no records. Coverage
and the evidence code per record are in
`literature/synthesis/concept-matrix.csv` (`evidence_basis`).

## 2026-11-24 targeted follow-up

Stage 1 increment run by the literature-searcher on 2026-11-24 for the
search requests in `literature/synthesis/missing-references.md`, meaning claims
for which no work is named yet. Works already named there (Thompson 1967,
Galbraith, Donaldson, Child 1972, Pfeffer and Salancik 1978, Mintzberg, the
O\*NET content model, Kim, Park and Prescott 2003, Blinder 2007, Brexit and
screening documents) are being verified in parallel by the reference-manager
and were not searched for here. Kim, Park and Prescott 2003 and Blinder 2007
were screened at title and abstract level only, as the brief asked. Nothing
was added to `literature/references.bib` or Zotero. Earlier counts in this
log are unchanged. New strings for the manual runs are in `search-strings.md`,
section "2026-11-24 targeted follow-up". The memo for the gate 2 re-run is
`literature/search/targeted-followup-2026-11-24.md`.

### Sources and access

| Source | Access on 2026-11-24 | Used |
|---|---|---|
| Consensus connector | Not available. The PI, through the orchestrator, asked for `mcp__Consensus__search`, but no Consensus tool was exposed in this session's tool list, so no call could be made. | no |
| OpenAlex API (`api.openalex.org/works`) | Reachable by direct HTTPS request without an API key (shared free daily budget; about 26 requests used). Raw JSON responses kept in the agent's session scratch space, not in the repository. | 24 searches, 2 record retrievals by DOI |
| Crossref | Not queried. No DOI was checked against Crossref; DOIs in the sheet are exactly as OpenAlex returned them and are unverified. | no |
| WebSearch | Reachable | 2 searches |
| Web of Science, EBSCO, Google Scholar | No agent access | 0 (strings proposed) |

Query syntax. OpenAlex `filter=title_and_abstract.search:` (or `title.search:`
for Q04) with Boolean AND/OR and quoted phrases; default relevance order
("best matches first"); `per-page` as stated; no date or type filter. The
OpenAlex parse of each query (the normalized `url` echoed in the response's
`meta.x_query`) is given in the table, where `,` separates ANDed clauses and
`|` separates ORed terms. Only the first page was screened. "Total" is
OpenAlex's match count; "Screened" is the number of records returned and
screened; "Kept" is include plus unsure; "Dup" is duplicates (within this run
or against the existing sheet).

### Query log

| # | Date | Source | Request (missing-references entry) | Query as sent | OpenAlex parse (`meta.x_query.url`) | Total | Screened | Include | Unsure | Dup |
|---|---|---|---|---|---|---|---|---|---|---|
| Q01 | 2026-11-24 | OpenAlex | 10 contingency fit in IJVs | `filter=title_and_abstract.search:"joint venture" AND (contingency OR misfit) AND (structure OR control OR staffing OR design)&per-page=20` | `title_and_abstract.search:"joint venture",title_and_abstract.search:contingency\|misfit,title_and_abstract.search:control\|design\|staffing\|structure` | 121 | 20 | 8 | 1 | 1 |
| Q02 | 2026-11-24 | OpenAlex | 10 units with more than one parent | `filter=title_and_abstract.search:("multiple parents" OR "two parents" OR "dual parents" OR "parent firms" OR "multiple principals") AND ("joint venture" OR alliance OR subsidiary) AND (contingency OR fit OR misfit OR "organizational design" OR "structural")&per-page=15` | as sent | 94 | 15 | 0 | 3 | 3 |
| Q03 | 2026-11-24 | OpenAlex | 10 contingency constructs in IJVs | `filter=title_and_abstract.search:("joint venture" OR "international joint venture") AND ("information processing" OR "task interdependence" OR "differentiation and integration" OR "structural contingency" OR "contingency theory")&per-page=15` | as sent | 33 | 15 | 1 | 0 | 2 |
| Q04 | 2026-11-24 | OpenAlex | 10, 11 JV organization design | `filter=title.search:("joint venture" OR "joint ventures") AND ("organizational design" OR "organization design" OR "organizational structure" OR "structural fit" OR "organizational fit")&per-page=15` | `display_name.search:...` (title field) | 7 | 7 | 1 | 1 | 0 |
| Q05 | 2026-11-24 | OpenAlex | 18 local parent as staff supplier | `filter=title_and_abstract.search:("joint venture" OR "joint ventures") AND ("local partner" OR "local parent" OR "host partner" OR "local firm") AND (staffing OR personnel OR employees OR managers OR secondment OR seconded OR "human resource")&per-page=15` | as sent | 165 | 15 | 1 | 1 | 1 |
| Q06 | 2026-11-24 | OpenAlex | 18, 45 seconded and parent-assigned staff | `filter=title_and_abstract.search:("joint venture" OR "joint ventures") AND (seconded OR secondment OR "assigned managers" OR "parent-assigned" OR "transferred employees" OR "staff transfer" OR "personnel transfer" OR "parent company managers")&per-page=15` | as sent | 2478 | 15 | 1 | 2 | 3 |
| Q07 | 2026-11-24 | OpenAlex | 18 IJV HRM and recruitment by parents | `filter=title_and_abstract.search:"international joint venture" AND ("human resource management" OR HRM OR recruitment OR recruiting OR hiring) AND (parent OR partner)&per-page=15` | as sent | 28 | 15 | 5 | 7 | 0 |
| Q08 | 2026-11-24 | OpenAlex | 20 two foreign parents (phrases) | `filter=title_and_abstract.search:"third-country joint venture" OR "third country joint venture" OR "trinational joint venture" OR "tri-national joint venture" OR "foreign-foreign joint venture" OR "joint ventures between foreign" OR "two foreign partners" OR "two foreign parents" OR "foreign partners only"&per-page=20` | as sent | 39 | 20 | 0 | 0 | 0 |
| Q09 | 2026-11-24 | OpenAlex | 20 two foreign parents (grouped) | `filter=title_and_abstract.search:("third-country" OR "third country" OR trinational OR "tri-national" OR "two foreign") AND ("joint venture" OR "joint ventures")&per-page=15` | as sent | 48 | 15 | 0 | 3 | 1 |
| Q10 | 2026-11-24 | OpenAlex | 19, 22 internal versus market hiring in multi-unit firms | `filter=title_and_abstract.search:("external hiring" OR "external hires" OR "internal hiring" OR "internal labor market" OR "internal labour market" OR "internal mobility") AND (subsidiary OR subsidiaries OR multinational OR "joint venture" OR "business group" OR affiliate)&per-page=20` | as sent | 91 | 20 | 0 | 6 | 5 |
| Q11 | 2026-11-24 | OpenAlex | 19 cost of external versus internal hires | `filter=title_and_abstract.search:("external hires" OR "external hiring" OR "outside hires") AND ("internal mobility" OR "internal promotion" OR "internal candidates" OR "internal hires" OR "promoted workers") AND (pay OR cost OR costs OR performance)&per-page=12` | as sent | 63 | 12 | 0 | 4 | 1 |
| Q12 | 2026-11-24 | OpenAlex | 25, 26 O\*NET interdependence and work context | `filter=title_and_abstract.search:("O NET" OR ONET OR "Occupational Information Network") AND (interdependence OR teamwork OR "work context" OR coordination OR "task context")&per-page=15` (a first attempt with `"O*NET"` was rejected by the API, 0 records) | as sent | 87 | 15 | 0 | 3 | 0 |
| Q13 | 2026-11-24 | OpenAlex | 25, 30 O\*NET in firm-level research | `filter=title_and_abstract.search:("O NET" OR "Occupational Information Network") AND (firms OR "firm-level" OR "organizational structure" OR "organization design" OR "managerial" OR "top management" OR subsidiaries)&per-page=15` | as sent | 99 | 15 | 2 | 2 | 1 |
| Q14 | 2026-11-24 | OpenAlex | 28 O\*NET outside the US | `filter=title_and_abstract.search:("O NET" OR "Occupational Information Network") AND (European OR Europe OR "cross-country" OR transferability OR "outside the US" OR "other countries" OR PIAAC OR "country-specific")&per-page=15` | as sent | 174 | 15 | 0 | 7 | 1 |
| Q15 | 2026-11-24 | OpenAlex | 27 location-bound task measures | `filter=title_and_abstract.search:("face-to-face" OR offshorability OR offshorable OR "on-site" OR teleworkability OR "work from home") AND ("O NET" OR "Occupational Information Network") AND (occupations OR tasks)&per-page=15` | as sent | 41 | 15 | 0 | 4 | 4 |
| Q16 | 2026-11-24 | OpenAlex | 38 Brexit and MNE subsidiaries | `filter=title_and_abstract.search:Brexit AND (subsidiary OR subsidiaries OR multinational OR multinationals OR "foreign-owned" OR "foreign affiliates") AND (relocation OR staffing OR employment OR employees OR restructuring OR organizational OR reorganization)&per-page=20` | as sent | 82 | 20 | 2 | 2 | 0 |
| Q17 | 2026-11-24 | OpenAlex | 37 Brexit, free movement and employers | `filter=title_and_abstract.search:Brexit AND ("free movement" OR "EU migrants" OR "EU workers" OR "EU nationals" OR immigration) AND (firms OR employers OR recruitment OR hiring OR "labour shortages" OR "labor shortages")&per-page=20` | as sent | 213 | 20 | 1 | 5 | 1 |
| Q18 | 2026-11-24 | OpenAlex | 41 Brexit, expatriation and HRM | `filter=title_and_abstract.search:Brexit AND (expatriate OR expatriates OR "global mobility" OR "international assignments" OR "intra-company" OR "posted workers" OR "talent management" OR "human resource management" OR HRM)&per-page=15` | as sent | 71 | 15 | 1 | 0 | 0 |
| Q19 | 2026-11-24 | OpenAlex | 42 investment screening and foreign firms | `filter=title_and_abstract.search:("investment screening" OR "FDI screening" OR CFIUS OR "national security review" OR "foreign investment review") AND (affiliates OR subsidiaries OR "joint venture" OR "joint ventures" OR acquisitions OR "foreign firms" OR multinationals)&per-page=20` | as sent | 279 | 20 | 1 | 3 | 1 |
| Q20 | 2026-11-24 | OpenAlex | 42 empirical effects of screening | `filter=title_and_abstract.search:("investment screening" OR "FDI screening" OR CFIUS OR FIRRMA OR "screening mechanism") AND (effect OR effects OR impact OR "difference-in-differences") AND (firms OR affiliates OR subsidiaries OR employment OR innovation OR operations)&per-page=15` | as sent | 165 | 15 | 0 | 2 | 1 |
| Q21 | 2026-11-24 | OpenAlex | 9 contingency theory with staffing as outcome | `filter=title_and_abstract.search:("contingency theory" OR "contingency approach" OR "contingency perspective" OR "structural contingency") AND (staffing OR "workforce composition" OR "personnel composition" OR expatriates OR "parent-country nationals")&per-page=15` | as sent | 370 | 15 | 3 | 1 | 0 |
| Q22 | 2026-11-24 | OpenAlex | 26 occupation-level interdependence measures | `filter=title_and_abstract.search:("task interdependence" OR "work interdependence" OR "interdependence of work" OR "coordination requirements") AND (occupations OR occupational OR "job analysis" OR "O NET")&per-page=15` | as sent | 38 | 15 | 0 | 2 | 0 |
| Q23 | 2026-11-24 | OpenAlex | 35, 36, 38 Brexit regulatory divergence | `filter=title_and_abstract.search:Brexit AND ("regulatory divergence" OR "non-tariff" OR customs OR "regulatory compliance" OR "trade and cooperation agreement") AND (firms OR jobs OR occupations OR employment OR skills OR exporters)&per-page=15` | as sent | 157 | 15 | 2 | 5 | 1 |
| Q24 | 2026-11-24 | WebSearch | 38 Brexit and foreign subsidiaries | `Brexit effect on foreign subsidiaries staffing organization empirical study international business journal` | n/a | 10 links | 8 records | 1 | 2 | 1 |
| Q25 | 2026-11-24 | OpenAlex | 38 Brexit and subsidiaries (follow-up to Q24 leads) | `filter=title_and_abstract.search:Brexit AND (subsidiaries OR subsidiary) AND (software OR "regional" OR formation OR referendum)&per-page=10` | as sent | 24 | 10 | 3 | 1 | 2 |
| Q26 | 2026-11-24 | WebSearch | 20 two foreign parents | `"international joint ventures" partners from "third country" OR "same home country" ownership structure staffing Makino Beamish non-conventional` | n/a | 19 links | 0 (all company pages; nothing added) | 0 | 0 | 0 |

Record retrievals (not searches; no new records found by them):

| # | Date | Source | Purpose | Request | Records |
|---|---|---|---|---|---|
| R00 | 2026-11-24 | OpenAlex | Stage 2 candidate Kim, Park & Prescott 2003, retrieved for screening | `filter=doi:10.1057/palgrave.jibs.8400035` | 1 (screened as OA-S2-01) |
| R24a | 2026-11-24 | OpenAlex | metadata for the WebSearch Q24 hit "Brexit: human resourcing implications" | `filter=doi:10.1108/ER-11-2018-0310` (DOI from the WebSearch link) | 1 (screened as WS-S9-01) |
| R24b | 2026-11-24 | OpenAlex | malformed title filter for the Fuller postprint | `filter=title.search:Brexit foreign subsidiaries,author.id:null` | 0; superseded by Q25 |

Blinder 2007 (the other Stage 2 candidate) was retrieved by Q15 (rank 1) and screened as OA-S6-46.

### PRISMA flow, 2026-11-24 increment (title and abstract stage)

| Step | n | Notes |
|---|---|---|
| Records identified, OpenAlex searches (Q01 to Q23, Q25) | 374 | first page of each query |
| Records identified, OpenAlex retrieval of a Stage 2 candidate (R00) | 1 | Kim, Park & Prescott 2003 |
| Records identified, WebSearch (Q24, Q26) | 8 | Q24: 10 links, 8 distinct records; Q26: 19 links, none scholarly, none added |
| Records identified, Consensus | 0 | connector not available in the session |
| Records identified, Web of Science / EBSCO / Google Scholar | 0 | not run (no access); strings proposed |
| Total rows added to `screening.csv` | 383 | ids `OA-<stream>-NN` and `WS-S9-NN` |
| Duplicates (F_duplicate) | 30 | 26 within this increment; 4 against existing rows (CON-S3-05 twice, CON-S3-07, and CC-S3-04, the record the PI dropped on 2026-10-04); see `notes` |
| Unique new records screened | 353 | |
| Excluded at title/abstract | 252 | E_offtopic 183, C_nonscholarly 45, B_formation 18, D_language 5, A_level 1 |
| Unsure, to full text | 67 | 27 of them marked `scope:` (outside criteria (a) to (g)); see below |
| Include, to full text | 34 | |
| Kept for full-text screening (include plus unsure) | 101 | `full_text_decision = pending` |

Per stream (unique new records).

| Stream | Include | Unsure | Exclude | Total |
|---|---|---|---|---|
| S2 | 1 | 0 | 0 | 1 |
| S3 | 7 | 13 | 55 | 75 |
| S4 | 0 | 10 | 16 | 26 |
| S6 (task-data methods) | 2 | 18 | 49 | 69 |
| S7 | 12 | 5 | 42 | 59 |
| S8 | 1 | 1 | 5 | 7 |
| S9 | 11 | 20 | 85 | 116 |
| Total | 34 | 67 | 252 | 353 |

### Screening conventions used in this increment

- Reasons for include and unsure cite the protocol criterion, for example
  `incl (b)` or `incl (g)?`. A reason that starts with `scope:` marks a record
  that falls outside inclusion criteria (a) to (g) (single-firm HRM, business-group
  labor markets, labor-economics task data) but is the only evidence found for a
  named search request. These records are marked unsure, not include, and the
  PI decides at gate 2 whether the protocol needs an amendment, for example a
  task-data methods block or a recruitment-source block.
- O\*NET and task-data records are filed under S6 (Methods tier) because
  the protocol has no task-data stream; the notes say so.
- `full_text_decision` is `pending` for include and unsure rows and blank for
  exclusions, following the convention of the existing sheet.
- DOIs are recorded only as OpenAlex returned them (lower-case prefix as
  returned) and are unverified; no DOI was added from memory. WebSearch-only
  records carry no DOI.

### Limits

- OpenAlex relevance ranking with Boolean filters is not a substitute for the WoS, EBSCO and Google Scholar runs; only the first page (10 to 20 records) of each query was screened, and the totals show that several queries matched far more records (Q06 2478, Q21 370, Q19 279).
- Q08 (exact phrases for two-foreign-parent JVs) returned noise; Q09 found the relevant records. Q26 (WebSearch) returned only company pages.
- Abstracts were missing for some records (OpenAlex does not return abstracts for some publishers); those were screened on title and outlet and marked unsure where the title suggested relevance.
- No backward or forward citation chase was run in this increment.

## 2026-11-24 EBSCO run: S3-local, S7-multiparent, S7-staffing (protocol v1.2, priority 1)

Appended 2026-11-24 by the literature-searcher. Earlier sections and counts above are unchanged. This increment ingests the PI's EBSCO exports for the three blocks that protocol v1.2 ("Priorities of the manual runs", item 1) requires before gate 5. Only EBSCO was run for this increment. Memo for the PI: `literature/search/ebsco-run-2026-11-24.md`.

### Sources and access

- Database: EBSCO Business Source (the RIS `DB` field reads "Business Source Premier" for all 152 records), run manually by the PI on 2026-11-24 and exported as RIS.
- Strings: the EBSCO strings of `search-strings.md`, section "2026-11-24 targeted follow-up", reproduced verbatim below. The exports do not record the query or the limiters, so "as run" means "as defined in `search-strings.md`"; the agent did not see the EBSCO session.
- Limiters: the protocol specifies 1985 to present and Scholarly (Peer Reviewed) Journals. The exports contain 22 records typed Periodical, Newspaper or Trade Publication, 27 conference proceedings and one working paper, and S7-staffing contains 5 records from 1975 to 1982. The peer-reviewed limiter therefore appears not to have been applied to S3-local and S7-staffing (both contain periodicals), and is uncertain for S7-multiparent (one conference-proceedings teaching case); the date limiter appears not to have been applied to S7-staffing. These records were screened like the others; non-scholarly items are excluded as `C_nonscholarly`.
- Parsing and deduplication: `literature/search/tools/ingest_ebsco_ris.py` (Python standard library). Deduplication within the run and against all 545 existing rows of `screening.csv`, first on DOI (case-insensitive, `https://doi.org/` prefix removed), then on normalized title plus year. A fuzzy title check (ratio above 0.85) against the existing sheet found no further matches.
- Block check: each file was tested against an approximation of the three EBSCO strings on title, abstract and subject terms. S3-local 5 of 5 records match its string and none of the others; S7-multiparent 13 of 15 (the other two carry the matching term only in a subject heading); S7-staffing 88 of 132 match fully, and all 132 contain a contingency or misfit term in title or abstract. The remaining 44 lack the staffing terms of the string in title, abstract and keywords (three contain only inflected forms such as "hired" or "staff") and carry subject headings such as "Employees" or "Employee selection", which points to EBSCO's equivalent-subject expansion of `hiring` and `recruit*`. No file matches more than one block.

### Files

| Original file name (as exported by EBSCO) | Block | Renamed to | Records |
|---|---|---|---|
| `498c707e-b3e0-4b7d-ace1-130dc5448e55.ris` | S3-local | `exports/ebsco-S3local-2026-11-24.ris` | 5 |
| `9654abb4-f2f6-479b-8192-2dc9d5eae14b.ris` | S7-multiparent | `exports/ebsco-S7multiparent-2026-11-24.ris` | 15 |
| `7eb29be6-6da3-4e5b-8a79-40f20577fa1f.ris` | S7-staffing | `exports/ebsco-S7staffing-2026-11-24.ris` | 132 |

The files were renamed only; SHA-256 checksums before and after renaming are identical.

### Query log

| # | Date | Database | Block | String (exact, as defined in `search-strings.md`) | Fields and limiters specified | Records exported |
|---|---|---|---|---|---|---|
| E01 | 2026-11-24 | EBSCO Business Source | S3-local | `(TI("joint venture*" OR IJV) OR AB("joint venture*" OR IJV)) AND AB("local partner*" OR "local parent*" OR "host partner*" OR "domestic partner*") AND AB(staffing OR secondment OR seconded OR "personnel transfer*" OR "top management team*" OR "human resource*" OR recruit*)` | TI, AB as in string; 1985 to present; Scholarly (Peer Reviewed) Journals (not applied, see above) | 5 |
| E02 | 2026-11-24 | EBSCO Business Source | S7-multiparent | `(TI("joint venture*" OR "multiple parent*" OR "shared ownership" OR "multiple principal*") OR AB("joint venture*" OR "multiple parent*" OR "shared ownership" OR "multiple principal*")) AND AB("contingency theory" OR "structural contingency" OR "contingency approach" OR "organi?ational fit" OR misfit OR "information processing") AND (structure* OR design OR control OR staffing)` | TI, AB as in string, last group in default fields; 1985 to present; Scholarly (Peer Reviewed) Journals | 15 |
| E03 | 2026-11-24 | EBSCO Business Source | S7-staffing | `(TI("contingency theory" OR "structural contingency" OR "contingency approach" OR "contingency perspective" OR misfit) OR AB("contingency theory" OR "structural contingency" OR "contingency approach" OR "contingency perspective" OR misfit)) AND (staffing OR "workforce composition" OR expatriat* OR "host-country national*" OR recruit* OR hiring)` | TI, AB as in string, last group in default fields; 1985 to present (not applied); Scholarly (Peer Reviewed) Journals (not applied) | 132 |
| W01 | 2026-11-24 | WebSearch | publication-type check for EB-S3-04 | `Li Schotter "first mover" survival international joint ventures legitimacy general manager staffing Japanese` | n/a | no later journal version found; nothing added |
| W02 | 2026-11-24 | WebSearch | publication-type check for EB-S7-89 | `Orewa nursing homes Patient Driven Payment Model staffing intensity financial performance contingency theory` | n/a | points to a possible later journal article (https://jhmhp.amegroups.org/article/view/9047), metadata not verified; noted on EB-S7-89; nothing added |

W01 and W02 are checks under the publication-type rule of protocol v1.2, not searches; they added no records. Crossref and Google Scholar were not checked.

### Duplicates

| Block | Duplicates of existing rows (existing id, match) | Duplicates within the run |
|---|---|---|
| S3-local | 1: OA-S3-44 (DOI) | 0 |
| S7-multiparent | 6: OA-S7-03, OA-S7-16, OA-S7-37, OA-S7-45, OA-S7-48, OA-S7-50 (all DOI) | 0 |
| S7-staffing | 5: OA-S7-51, OA-S7-53, OA-S7-64 (DOI); OA-S7-54, OA-S7-63 (title and year; the RIS DOIs of these two carry stray `<n>` markup) | 2: records 40 and 75 repeat records 39 and 74 (two trade-press items) |
| Total | 12 | 2 |

Duplicates got no row in `screening.csv`. One further record, EB-S7-88 (AOM Proceedings 2020), was identified at screening as the conference version of the journal article EB-S7-15 (same authors, same question). It has a row and is excluded as `F_duplicate` under the publication-type rule.

### PRISMA flow, 2026-11-24 EBSCO increment (title and abstract stage)

| Step | n | Notes |
|---|---|---|
| Records identified, EBSCO S3-local (E01) | 5 | |
| Records identified, EBSCO S7-multiparent (E02) | 15 | |
| Records identified, EBSCO S7-staffing (E03) | 132 | |
| Records identified, total | 152 | |
| Duplicates removed before screening | 14 | 12 against existing rows, 2 within the run |
| Records screened (rows added to `screening.csv`) | 138 | ids EB-S3-01 to EB-S3-04, EB-S7-01 to EB-S7-134 |
| Excluded at title and abstract | 120 | E_offtopic 94, C_nonscholarly 21, D_language 2, B_formation 2, F_duplicate 1 |
| Unsure, to full text | 8 | 3 of them `scope:` (hiring-source support only) |
| Include, to full text | 10 | |
| Kept for full-text screening (include plus unsure) | 18 | `full_text_decision = pending` |

Per block (unique records screened).

| Block | Stream | Exported | Duplicates | Screened | Include | Unsure | Exclude | Exclusion reasons |
|---|---|---|---|---|---|---|---|---|
| S3-local | S3 | 5 | 1 | 4 | 2 | 0 | 2 | D_language 1, C_nonscholarly 1 |
| S7-multiparent | S7 | 15 | 6 | 9 | 4 | 1 | 4 | B_formation 2, E_offtopic 1, C_nonscholarly 1 |
| S7-staffing | S7 | 132 | 7 | 125 | 4 | 7 | 114 | E_offtopic 93, C_nonscholarly 19, D_language 1, F_duplicate 1 |
| Total | | 152 | 14 | 138 | 10 | 8 | 120 | |

### Screening conventions used in this increment

- Protocol v1.2. Stream follows the block name: S3-local hits are S3, both S7 blocks are S7. The block is named in `notes`.
- Reasons follow the sheet's codes and the conventions of the 2026-11-24 follow-up: `incl (x)` for include, `incl (x)?` for unsure, `scope:` for hiring-source records under the mechanism-support rule, and code plus a short phrase for exclusions.
- Generic uses of a contingency approach in micro HRM, leadership, marketing or health-services research were excluded as `E_offtopic`, as in the earlier increment (for example OA-S7-61, OA-S7-64). Records that test contingency fit with organizational structure as the fitted variable were kept as unsure under criterion (e).
- EB-S3-01 (in Japanese, English abstract) is excluded under exclusion criterion (d) although its abstract concerns localization of human resources and JV partnering in foreign subsidiaries in Japan; the note says so, and the PI may waive the language rule.
- Metadata (title, authors, year, outlet, DOI) are taken from the RIS only. DOIs are as given in the RIS and unverified. Titles are HTML-unescaped; the EBSCO title of EB-S3-01 is truncated in the export.

### Limits

- One database only. The S3-local string returned 5 records, far fewer than the OpenAlex S3 queries of the same day (75 unique S3 records); its recall is low because all three concept groups are restricted to the abstract and the local-partner group admits four phrases only. A null result from this block is weak evidence.
- The limiters were not applied as specified (see "Sources and access"), which adds non-scholarly noise but does not reduce recall.
- No citation chase and no Consensus search in this increment (excluded by the run brief).

### Second screening and publication-type check (added by the orchestrator, 2026-11-24)

Two further agents screened the S7-staffing export independently in halves (records 1 to 66 and 67 to 132), without access to the first decisions (minor exposure noted in their reports: the first decisions for records 1 to 6 and a few obvious trade items in 64 to 80 were briefly visible). Files: `tools/screen-S7staffing-part1-second.csv`, `tools/screen-S7staffing-part2-second.csv`, with their scripts. Agreement with the first screening on content: 66 of 66 (records 1 to 66; the two coded differences are duplicate handling) and 61 of 66 (records 67 to 132). Three of the five disagreements in 67 to 132 (EB-S7S-072, -102, -112) turn on whether criterion (e) admits domestic tests of contingency theory or only work on foreign units and IJVs; one (-071) is duplicate handling, one (-124, a biography of Joan Woodward) is background. The first decisions stand in `screening.csv` until the PI settles the scope of criterion (e). No record was flagged close to H3 except EB-S7-22 (Georgopoulos et al. 2024), which is already included.

| Check | Date | Source | Query | Result |
|---|---|---|---|---|
| W03 publication-type check | 2026-11-24 | WebSearch (second screener) | journal version of OA-S7-63 (Zinn et al., AOM Proceedings 2007) | Zinn, Feng, Mor, Intrator & Grabowski 2008, Health Care Management Review 33(2), 113-123, DOI 10.1097/01.HMR.0000304506.12556.52 (from search results; not verified on Crossref). OA-S7-63 recoded to `F_duplicate`; the journal article added as WS-S7-01 (unsure, criterion (e) scope) |

The novelty check of the three blocks is `ebsco-novelty-check-2026-11-24.md` (literature-synthesizer). It supersedes task 5 of `ebsco-run-2026-11-24.md` where the two differ.

## Protocol v1.3 recode (added by the orchestrator, 2026-11-25)

By the PI's decision of 2026-11-25 (pre-analysis plan rules sheet, decision 9; protocol v1.3), criterion (e) admits only work on foreign units, subsidiaries and IJVs. The three S7-staffing records on which the two screenings disagreed for this reason keep their first decisions. The language rule is waived for EB-S3-01 (Inamura 2024), recoded from exclude (D_language) to include under (a) and (b). Block counts after the recode: S3-local 3 include, 1 exclude; EBSCO run total 11 include, 8 unsure, 119 exclude.

## S10 targeted O\*NET search for the G2 re-run (2026-11-25)

Agent: literature-searcher. Protocol v1.3, stream S10, criterion (h). Basis: `docs/decisions.md`, Open row "G2 re-run"; `docs/coauthor-notes/score-construction-decision-sheet-2026-11-25.qmd`. Full query log, candidate tables and recommendations: `s10-onet-targeted-2026-11-25.md`.

Purpose: sources for three markers in the pre-analysis plan (`reviews/gate-5-pre-analysis-plan.md`, A2.4): (1) `[CITE: a study that uses O*NET task measures as contingency, interdependence or external-contact scores]`, (2) `[CITE: O*NET content model documentation]`, (3) `[CITE: cross-country transferability of O*NET task measures]`.

### Sources and access

| Source | Access | Queries | Notes |
|---|---|---|---|
| Consensus | not available | 0 | `mcp__Consensus__search` was not exposed in this session (as at stage 2, 2026-11-24); plan upgrade not pursued (2026-11-25) |
| WebSearch | agent | 16 (T01-T03, T05, T06, T09-T13, T15, T17, T18, T27-T29) | 10 results each |
| WebFetch | agent | 8 page checks (T04, T14, T16, T30-T34; 11 fetches, 2 of them failed) | measurement and documentation checks, not searches |
| OpenAlex API | agent | 9 searches (T07, T08, T19-T25) and 1 forward-citation query (T26) | substitute for Consensus; relevance ranked; top 8 to 15 screened per search, all 54 citing works for T26 |
| Crossref API | agent | DOI checks of all candidates | one title query returned HTTP 429 and was redone by DOI |
| Web of Science, EBSCO, Google Scholar | not run | 0 | no agent access |

### Results

| Marker | Candidates listed | Verified on Crossref | Recommended |
|---|---|---|---|
| 1 | 5 ranked, 6 more noted | all ranked | Oldenski 2012, JIE, 10.1016/j.jinteco.2011.12.012; Dierdorff & Ellington 2008, JAP, 10.1037/0021-9010.93.4.883 (O\*NET elements to be confirmed from full text) |
| 2 | 3 | 1 (NRC 2010); 2 are web documents without DOI | existing bib entries suffice for the content model; add a data citation for the O\*NET 31.0 Database (CC BY 4.0 attribution) |
| 3 | 5 ranked, 6 more noted | all ranked | Taylor, Li, Shi & Borman 2008, Personnel Psychology, 10.1111/j.1744-6570.2008.00106.x; Lewandowski et al. 2022, WBER, 10.1093/wber/lhac005 |

Not found: a study that uses O\*NET elements as contingency scores for staffing, integration or control in subsidiaries or IJVs, and a validation outside the US of the O\*NET work context items used by the plan. Both are weak evidence of absence (agent-run sources only). The O\*NET Resource Center report of August 2026 on the work context domain proposes new codes for the three job-interaction elements and the deletion of Contact With Others (details in the memo).

### Records

No rows were added to `screening.csv` and nothing was added to `references.bib` (run brief). The memo lists which candidates are already in the sheet (OA-S6-16, OA-S6-28, OA-S6-36, OA-S6-39, OA-S6-51, OA-S6-63) and which would be new S10 rows if the PI accepts them. No PRISMA counts above change.

## Reference step for five [CITE] markers and the O\*NET precedent check (2026-11-26)

Agent: reference-manager. Basis: the approved pre-analysis plan (`reviews/gate-5-pre-analysis-plan.md`), markers at lines 460, 481, 501, 507 and 512, and the open element check at lines 658 to 662. Results: `literature/zotero/verification-2026-11-26-cite.md` (markers) and `onet-precedent-elements-2026-11-26.md` (O\*NET elements). Not a protocol search; no rows were added to `screening.csv` and no PRISMA counts change.

### Sources and access

| Source | Access | Queries | Notes |
|---|---|---|---|
| Consensus | not available | 0 | `mcp__Consensus__search` not exposed in this session |
| WebSearch | agent | 16 (R01-R16) | 10 results each |
| OpenAlex API | agent | 13 searches (R17-R29) and about 20 DOI look-ups for abstracts | relevance ranked; top 3 to 8 screened per search |
| Crossref API | agent | 11 title queries (R30-R40) and DOI checks of every candidate | generic User-Agent, no contact e-mail |
| WebFetch | agent | 24 page checks (R41) | content and metadata checks, not searches; 9 failed (HTTP 403 or 404, redirects to login, empty PDF text) |
| Full texts | agent | 4 | Oldenski working paper (UNT web archive raw capture), Dierdorff & Ellington (Appalachian State Figshare copy of the version of record), Bidwell & Keller accepted manuscript (Wharton faculty page), Konara & Mohr (University of Essex repository, CC BY). Read as text from the session scratchpad or the tool cache; no PDF saved in the repository |
| Web of Science, EBSCO, Google Scholar | not run | 0 | no agent access |

### Query log

| id | Source | Marker or task | Query | Result used |
|---|---|---|---|---|
| R01 | WebSearch | O\*NET task | `Oldenski "Export versus FDI and the communication of complex information" pdf working paper` | Georgetown working paper (October 2011) in the UNT web archive |
| R02 | WebSearch | O\*NET task | `Dierdorff Ellington 2008 "It's the nature of the work" work-family conflict pdf interdependence "responsibility for others" O*NET` | none (abstract only) |
| R03 | WebSearch | O\*NET task | `"Dierdorff" "Ellington" "nature of the work" work-family conflict occupations filetype:pdf` | none; repository copy then found through OpenAlex and Unpaywall |
| R04 | WebSearch | 1 | `Bidwell Keller 2014 "Within or without? How firms combine internal and external labor markets to fill jobs" Academy of Management Journal` | accepted manuscript on the Wharton faculty page |
| R05 | WebSearch | 1 | `Lepak Snell 1999 "human resource architecture" human capital allocation uniqueness internal development external acquisition` | Lepak & Snell 1999 (abstract only; not added) |
| R06 | WebSearch | 2 | `Makino Beamish 1998 "Performance and survival of joint ventures with non-conventional ownership structures" JIBS Japanese partners host country` | Makino & Beamish 1998 |
| R07 | WebSearch | 1 | `"Lepak" "Snell" 1999 "The human resource architecture" pdf "human capital is generic" OR "low in uniqueness" acquisition "external labor market"` | none (no legitimate full text) |
| R08 | WebSearch | 2 | `international joint ventures "both partners are foreign" OR "two foreign partners" OR "foreign-foreign" joint ventures host country journal article performance` | Konara & Mohr 2023 |
| R09 | WebSearch | 4 | `Kren Lawless "How has Brexit changed EU-UK trade flows" European Economic Review abstract Trade and Cooperation Agreement non-tariff` | Kren & Lawless 2024 (not added: trade effects, not regulation) |
| R10 | WebSearch | 4 | `UK in a Changing Europe "UK-EU regulatory divergence tracker" first edition 2021` | UKICE tracker editions; UKICE policy report 2022 |
| R11 | WebSearch | 4 | `"Doing things differently? Policy after Brexit" UK in a Changing Europe report 2022` | UKICE report (publisher page found by URL check) |
| R12 | WebSearch | 4 | `ukandeu.ac.uk "UK-EU regulatory divergence tracker" "first edition" October 2021 Reland Rutter` | tracker first edition on committees.parliament.uk (not added) |
| R13 | WebSearch | 5 | `Chiswick Miller 2009 "The international transferability of immigrants' human capital" Economics of Education Review abstract occupation lawyers` | none (no occupation-level law result in the abstract) |
| R14 | WebSearch | 5 | `lawyers "jurisdiction-specific" human capital legal knowledge not transferable across countries journal article economics labor` | Hadfield 2009 chapter |
| R15 | WebSearch | 5 | `Hadfield "multijural" "legal human capital" international law firms harmonization working paper SSRN USC` | SSRN 959422 abstract (via repost) |
| R16 | WebSearch | 5 | `journal article lawyers human capital "country-specific" legal knowledge immigrant lawyers earnings penalty law occupation non-transferable` | none |
| R17 | OpenAlex | 1 | `Shenkar Zeira human resources management in international joint ventures directions for research` | none relevant |
| R18 | OpenAlex | 2 | `joint ventures two foreign partners no local partner host country third-country` | none relevant |
| R19 | OpenAlex | 3 | `workforce composition adjusts through hiring new hires rather than incumbents skill composition firm` | none relevant |
| R20 | OpenAlex | 3 | `demographic metabolism of organizations turnover tenure distributions` | Haveman 1995 (not added) |
| R21 | OpenAlex | 3 | `Abowd Corbel Kramarz entry and exit of workers and the growth of employment French establishments` | lead for Abowd et al. 1999 (confirmed on Crossref) |
| R22 | OpenAlex | 3 | `Hershbein Kahn do recessions accelerate routine-biased technological change vacancy postings` | lead for Hershbein & Kahn 2018 |
| R23 | OpenAlex | 3 | `Burgess Lane Stevens job flows worker flows and churning` | Burgess et al. 2000 (not added) |
| R24 | OpenAlex | 5 | `country-specific human capital lawyers immigrants transferability legal occupations` | none |
| R25 | OpenAlex | 5 | `international transferability of immigrants human capital occupation Chiswick Miller` | none |
| R26 | OpenAlex | 5 | `Brexit legal profession lawyers qualification recognition solicitors Ireland` (articles only) | none |
| R27 | OpenAlex | 5 | `foreign-trained lawyers licensing legal knowledge country-specific earnings` (articles only) | none |
| R28 | OpenAlex | 5 | `local knowledge of laws and regulations host country nationals subsidiary staffing legal` (articles only) | none |
| R29 | OpenAlex | 5 | `Morgan Quack institutional legacies and firm dynamics growth internationalization UK German law firms`; `Faulconbridge Muzio globalization law firms national legal jurisdiction professional` | Morgan & Quack 2005, Muzio & Faulconbridge 2013 (not added) |
| R30-R40 | Crossref | 1 to 5 | title queries: Bidwell & Keller; Lepak & Snell; Abowd et al.; Hershbein & Kahn; Burgess et al.; Kren & Lawless; Freeman et al. (Brexit trade); "Brexit regulatory divergence ... after transition period"; Hadfield multijural (3 variants); Hadfield 2011 | DOIs and print dates for all candidates |
| R41 | WebFetch | all | page checks: UNT archive, NC DOCKS and Figshare, Wharton PDF, Cornell eCommons, Springer, IDEAS (3), Ivey abstract compilation, ScienceDirect (2), UCL Discovery (2), UKICE publisher page, Taylor & Francis chapter page, SciSpace, SelectedWorks, International Law Reporter (2), SSRN, GOV.UK TCA page | see the verification file |

Leads rechecked from `targeted-followup-2026-11-24.md`: OA-S3-68 (Makino & Beamish 1998), OA-S3-75 (Konara & Yang 2022), OA-S4-13 (Cestone et al.), OA-S4-21 (Bidwell 2011), OA-S4-09 (Belenzon & Tsolmon 2015), OA-S4-22 (DeVaro et al. 2019).

### Results

| Marker | Keys | Status |
|---|---|---|
| 1, line 460 | `williamson1975understanding`, `cestone2024exploiting`, `bidwell2014within` (framing only) | met for the specificity argument; "at lower cost" not supported |
| 2, line 481 | `makino1998performance`, `konara2022institutional`, `konara2023cultural` (optional) | met for the existence and distinctness of such IJVs; no staffing study exists |
| 3, line 501 | `abowd1999entry`, `hershbein2018do` | met |
| 4, line 507 | `ukinachangingeurope2022doing`; `foreigncommonwealthdevelopmentoffice2021trade` (reused, optional) | met for separate customs, VAT and regulatory regimes; the source states that rule content did not diverge at once |
| 5, line 512 | `hadfield2009role`, `ukinachangingeurope2022doing` | partly met; no journal article found |
| O\*NET check | `dierdorff2008its`, `oldenski2012export` | Dierdorff & Ellington: 4.C.1.b.1.e, f and g as one interdependence score; Oldenski: importance of "working with the public" and "creative thinking" (working paper; published version not opened) |

Ten entries were added to `references.bib` and created in the Zotero group library (collection "verified-import-2026-11-26 (agent)"); fallback import file `literature/zotero/import-2026-11-26-cite.ris`.
