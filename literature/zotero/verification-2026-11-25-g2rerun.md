# Reference verification, G2 re-run, 2026-11-25

Agent: reference-manager, part of the G2 re-run (`docs/decisions.md`, Open row "G2 re-run", and Decided row of 2026-11-25 "Pre-analysis plan rules, decisions 9 and 10"). Input: the must-read list and the "For the search and reference agents" section of `literature/search/ebsco-novelty-check-2026-11-24.md`, the EBSCO rows of `literature/search/screening.csv`, and the RIS exports in `literature/search/exports/`. Evidence types follow the PI decisions of 2026-10-04 (Crossref DOI record, publisher or journal page, library or repository catalogue record, ISBN record, PDF of the work). OpenAlex and the RIS exports were treated as leads only.

Sources queried: Crossref REST API (api.crossref.org/works/<doi>, generic User-Agent, no contact e-mail); the doi.org registration-agency lookup (doi.org/ra/<doi>); the JaLC REST API (api.japanlinkcenter.org/dois/<doi>); the J-STAGE article page (bibliographic meta tags and the publication-history block). No abstract and no publisher text were copied into the .bib.

Zotero: not synced. No API credentials are available to agents in this run, so the group library was neither searched nor updated. The five entries are in `literature/zotero/import-2026-11-25-g2rerun.ris` for manual import. Whether any of them already exists in the group library was not checked; each RIS record asks the importer to search the library for the DOI first. No Better BibTeX export was run. Nothing was committed.

Scope of verification: each check confirms that the work exists and that the bibliographic metadata are correct. It does not confirm what the work says or that it carries the claim it is meant to support (see the content questions in the must-read list of the novelty check).

## 1. Citation keys

Convention as in `verification-report-2026-11-24.md`, section 2: first-author surname in lowercase ASCII, year, first title word not in the stop list. The five keys do not collide with the 150 existing keys or with each other. `references.bib` now holds 155 entries; the new entries were inserted in alphabetical order and the file keeps its CRLF line endings.

| Key | Work | Type | Evidence | Verified record |
|---|---|---|---|---|
| `georgopoulos2024mediating` | Georgopoulos, Aggelopoulos, Paraschi & Kalogera 2024 | article | Crossref 10.1108/JGM-03-2023-0019 | The mediating performance role of staffing options in MNE subsidiary strategies within rapidly deteriorating environments, Journal of Global Mobility 12(1) 57-92; print issue 2024-03-06, online 2023-09-29 |
| `groot2000control` | Groot & Merchant 2000 | article | Crossref 10.1016/S0361-3682(99)00057-4 | Control of international joint ventures, Accounting, Organizations and Society 25(6) 579-607, August 2000 |
| `inamura2024effect` | Inamura 2024 | article (in Japanese) | JaLC DOI record 10.15050/jaibs.16.1_1; J-STAGE article page (publisher: Japan Academy of International Business Studies) | Effect of institutional and cultural distance on joint venture partnership and human resource localization of MNC's foreign subsidiaries in Japan, Journal of International Business (国際ビジネス研究) 16(1) 1-20, 2024; available on J-STAGE 2024-11-28 |
| `li2024origin` | Li, Schotter & Beamish 2024 | article | Crossref 10.1016/j.ibusrev.2024.102272 | The origin and nationality of general manager successors in local-market-seeking MNE subsidiaries, International Business Review 33(3) article 102272, June 2024; open access (CC BY 4.0) |
| `wilson2006dynamics` | Wilson, Chen & Erakovic 2006 | article | Crossref 10.1080/09585190600878352 | Dynamics of decision power in the localization process: comparative case studies of China-Western IJVs, The International Journal of Human Resource Management 17(9) 1547-1571, September 2006 |

What was checked for each Crossref item: the DOI resolves, and title, author names and order, journal, volume, issue, pages and print-issue date agree with the RIS export (for Li et al., with the OpenAlex lead in the novelty check). For Inamura, the DOI is registered with JaLC, not Crossref (Crossref returns 404; doi.org/ra gives RA "JaLC"). The JaLC record and the J-STAGE page agree on the author (稲村 雄大; romanized INAMURA, Katsuhiro), the Japanese and English titles, the journal, ISSN 1883-5074 (print) and 2189-5694 (online), 16(1) 1-20, publication year 2024, and the DOI. J-STAGE also gives accepted 2024-03-18 and available on J-STAGE 2024-11-28.

## 2. Discrepancies between the leads and the verified records

| Key | Lead | Verified record | Action |
|---|---|---|---|
| `georgopoulos2024mediating` | RIS 2024; OpenAlex online 2023-09-29 (year difference flagged in the novelty check) | Crossref print issue 12(1) dated 2024-03-06, online 2023-09-29. The Crossref `issued` date is the online date, which is why OpenAlex shows 2023 | Print-issue year 2024 used (rule of 2026-10-04). Online date in the RIS Extra line ("Online first: 2023-09-29") and in the .bib note |
| `georgopoulos2024mediating` | Journal "Journal of Global Mobility" | Crossref container title "Journal of Global Mobility: The Home of Expatriate Management Research" | Short journal title used, as in the RIS |
| `groot2000control` | RIS: journal "Accounting, Organizations & Society", title with a final period | Crossref "Accounting, Organizations and Society", no period | Crossref form used. RIS and Crossref agree on 25(6) 579-607, August 2000 |
| `wilson2006dynamics` | RIS: "International Journal of Human Resource Management" | Crossref "The International Journal of Human Resource Management" | Crossref form used, as in the existing IJHRM entries in the .bib |
| `li2024origin` | Outside the EBSCO blocks (OpenAlex lead, novelty check row L) | Crossref gives the first author as "Li, Liang (Arthur)" | Entered as "Li, Liang"; the parenthetical name is kept in the RIS Extra line. Crossref has no online-first date, so none is recorded |
| `inamura2024effect` | RIS title truncated (novelty check); romanized metadata from J-STAGE | JaLC and J-STAGE give the full Japanese and English titles | The English title as registered by the publisher is used in the .bib (curly apostrophe written as a straight one), with `langid = {japanese}`; the Japanese original title is in the RIS Extra line. No transliteration was added |

## 3. Fields not verified or left out

| Key | Field | Reason |
|---|---|---|
| `li2024origin` | online-first date | Not in the Crossref record; the publisher page was not opened |
| `inamura2024effect` | issue month or print date | JaLC and J-STAGE give the year 2024 only (plus the J-STAGE release date) |
| `inamura2024effect` | romanized journal title | The journal's registered English title "Journal of International Business" is used; no romanization of 国際ビジネス研究 was added |

No work failed verification. All five are in `literature/references.bib` and in the RIS import file.

## 4. Files changed

`literature/references.bib` (five entries and three header comment lines added), `literature/zotero/import-2026-11-25-g2rerun.ris` (new), and this file (new). No other file was edited.
