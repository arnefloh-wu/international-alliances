# Reference verification, S10 O*NET markers, 2026-11-25

Agent: reference-manager. Input: the recommendations for markers 1 to 3 in `literature/search/s10-onet-targeted-2026-11-25.md` (Oldenski 2012 and Dierdorff & Ellington 2008 for marker 1, a data citation for the O\*NET 31.0 Database for marker 2, Taylor et al. 2008, Lewandowski et al. 2022 and Caunedo et al. 2023 for marker 3), as passed on by the orchestrator. The data citation follows the O\*NET entry in `data/data-log.md` (Collection Event 2026-11-25, source 3). Evidence types follow the PI decisions of 2026-10-04 (Crossref DOI record, publisher or journal page, library or repository catalogue record, ISBN record, PDF of the work). The S10 candidate table and OpenAlex were treated as leads only.

Sources queried: Crossref REST API (api.crossref.org/works/<doi>, generic User-Agent, no contact e-mail) for the five articles; for the database, three O\*NET Resource Center pages (https://www.onetcenter.org/database.html, https://www.onetcenter.org/db_releases.html, https://www.onetcenter.org/license_db.html) and the database page's "Cite this Page" function. No abstract and no publisher text were copied into the .bib.

Zotero: not synced. No API credentials are available to agents in this run, so the group library was neither searched nor updated. The six entries are in `literature/zotero/import-2026-11-25-s10.ris` for manual import. Whether any of them already exists in the group library was not checked; each RIS record asks the importer to search the library first. No Better BibTeX export was run. Nothing was committed.

Scope of verification: each check confirms that the work exists and that the bibliographic metadata are correct. It does not confirm what the work says or that it carries the claim it is meant to support. In particular, the S10 file asks for a full-text check of which O\*NET elements Oldenski (2012) and Dierdorff & Ellington (2008) use, and whether Taylor et al. (2008) report item-level results for 4.A.4.a.3 and 4.A.4.b.1. No full text was read in this run, so these content questions remain open.

## 1. Citation keys

Convention as in `verification-report-2026-11-24.md`, section 2: first-author surname (or corporate author) in lowercase ASCII, year, first title word not in the stop list, punctuation removed (as in the existing `harzing2001whos` and `puranam2014whats`). The six keys do not collide with the 182 existing keys or with each other. `references.bib` now holds 188 entries; the new entries were inserted in key order, one header comment line was added, and the file keeps its CRLF line endings.

| Key | Work | Type | Evidence | Verified record |
|---|---|---|---|---|
| `caunedo2023technology` | Caunedo, Keller & Shin 2023 | article | Crossref 10.1093/wber/lhad015 | Technology and the Task Content of Jobs across the Development Spectrum, The World Bank Economic Review 37(3) 479-493; print issue 2023-07-28, online 2023-07-03 |
| `dierdorff2008its` | Dierdorff & Ellington 2008 | article | Crossref 10.1037/0021-9010.93.4.883 | It's the nature of the work: Examining behavior-based sources of work-family conflict across occupations, Journal of Applied Psychology 93(4) 883-892, 2008 |
| `lewandowski2022technology` | Lewandowski, Park, Hardy, Du & Wu 2022 | article | Crossref 10.1093/wber/lhac005 | Technology, Skills, and Globalization: Explaining International Differences in Routine and Nonroutine Work Using Survey Data, The World Bank Economic Review 36(3) 687-708; print issue 2022-08-10, online 2022-06-20 |
| `nationalcenterforonetdevelopment2026onet` | National Center for O\*NET Development 2026 | misc (dataset) | Official record: O\*NET Resource Center database page, Database Releases Archive and database license page | O\*NET 31.0 Database, O\*NET Resource Center, U.S. Department of Labor, Employment and Training Administration; release dated August 2026; CC BY 4.0 |
| `oldenski2012export` | Oldenski 2012 | article | Crossref 10.1016/j.jinteco.2011.12.012 | Export Versus FDI and the Communication of Complex Information, Journal of International Economics 87(2) 312-322, July 2012 |
| `taylor2008transportability` | Taylor, Li, Shi & Borman 2008 | article | Crossref 10.1111/j.1744-6570.2008.00106.x | The transportability of job information across countries, Personnel Psychology 61(1) 69-111; print issue 2008-03, online 2008-02-06 |

What was checked for each Crossref item: the DOI resolves, and title, author names and order, journal, volume, issue, pages and print-issue date agree with the S10 lead. All five agree. For the database: the database page names the current release "O\*NET 31.0 Database"; the Releases Archive lists "O\*NET 31.0, August 2026, Current production database"; the license page gives CC BY 4.0 and the required credit (the O\*NET 31.0 Database and USDOL/ETA as the source, a link to the licence, an indication of changes) and states that the database is sponsored by USDOL/ETA and developed by the National Center for O\*NET Development. The "Cite this Page" function gives the author as National Center for O\*NET Development and the outlet as O\*NET Resource Center, with no date. The existing `nationalcenterforonetdevelopmentonet` (content model page) was the pattern for author, howpublished, url and urldate.

## 2. Discrepancies between the leads and the verified records

| Key | Lead | Verified record | Action |
|---|---|---|---|
| `lewandowski2022technology` | OpenAlex lists a wrong DOI (S10 file) | Crossref 10.1093/wber/lhac005 matches all fields | Crossref DOI used; the OpenAlex DOI was neither used nor checked. Print-issue year 2022 (online 2022-06-20, same year) |
| `caunedo2023technology`, `lewandowski2022technology` | Journal "World Bank Economic Review" | Crossref container title "The World Bank Economic Review" | Crossref form used, as for the IJHRM entries |
| `taylor2008transportability` | Title and names in normal case | Crossref title and author names in capitals; "Wen-Dong" written with a Unicode hyphen | Case normalized (title in sentence case, names in normal case), ASCII hyphen. No other change |
| `dierdorff2008its` | None | Crossref title ends with a period | Final period dropped |
| `nationalcenterforonetdevelopment2026onet` | S10: release date of 31.0 not shown on the database page (only "Site updated October 6, 2026") | The Releases Archive gives "August 2026" for 31.0 | Year 2026 used; the month is in the note and in the RIS date (2026/08). No day is given on any page, so none is recorded |

## 3. Fields not verified or left out

| Key | Field | Reason |
|---|---|---|
| `dierdorff2008its` | issue month, online date | Crossref gives the year only; the APA page was not opened |
| `oldenski2012export` | online-first date | Not in the Crossref record; the publisher page was not opened |
| `nationalcenterforonetdevelopment2026onet` | release day; DOI | The O\*NET pages give the month only; the database has no DOI. `urldate` (2026-11-25) is the access date of the pages and the download date recorded in `data/data-log.md` |
| `nationalcenterforonetdevelopment2026onet` | `version` field | Not added because the title already carries 31.0 and some styles would print it twice |

No work failed verification. All six are in `literature/references.bib` and in the RIS import file.

## 4. Files changed

`literature/references.bib` (six entries and one header comment line added), `literature/zotero/import-2026-11-25-s10.ris` (new), and this file (new). No other file was edited.
