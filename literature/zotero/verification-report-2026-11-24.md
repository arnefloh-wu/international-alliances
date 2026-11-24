# Reference verification report, Stage 2 reference step, 2026-11-24

Agent: reference-manager, run inside `/lit-synthesis` (Stage 2). Input: `literature/synthesis/missing-references.md` (52 numbered entries, sections 1 to 8). Evidence types follow the PI decisions of 2026-10-04 (Crossref DOI record, publisher or journal page, library or repository catalogue record, ISBN record, PDF of the work; book reviews and citing references are not evidence).

Sources queried: Crossref REST API (api.crossref.org; descriptive User-Agent, no contact e-mail because none is set in the environment); Library of Congress catalogue (SRU interface lx2.loc.gov, MODS records); EconBiz catalogue API (ZBW); RePEc (ideas.repec.org); GOV.UK Content and Search APIs; EU Publications Office (Cellar notices) and legislation.gov.uk; the O\*NET Resource Center; Open Library (supporting only). WebSearch was used twice, to locate the Jensen and Meckling PDF and the EconBiz record for Egelhoff (1982); in both cases the accepted-type record itself was then opened.

Scope change during the run. The orchestrator split the work mid-run. This agent now owns sections 1 to 3 of `missing-references.md`, the key check, the gate 2 section, and all writes to `references.bib` and `reviews/gate-2-synthesis.md`. Three parallel reference-manager agents took section 4 (O\*NET route), sections 5 and 6 (S13 and S06 documentary sources, methods), and sections 7 and 8 (unsure and uncitable records). Their fragments are due as `literature/zotero/verification-2026-11-24-<section>.md` and `.bib`. Before the split, this agent had already verified and added 25 items from sections 4 and 5 to `references.bib` (11 from section 4, 14 from section 5; none from section 6). They stay in the `.bib`, are documented below, and are listed in the gate file so that the orchestrator can tell the parallel agents to skip them. Sections 6 to 8 were only reported on; nothing from them was added. When this report was written, no fragment from the parallel agents existed yet.

Zotero: not synced. Neither `.Renviron` nor `.env` exists at the repository root, and the user-level `~/.Renviron` holds no Zotero variables, so `ZOTERO_API_KEY` and `ZOTERO_GROUP_ID` were unavailable. The group endpoint answers HTTP 403 without a key. As the agent definition prescribes, an import file was written for manual import: `literature/zotero/import-2026-11-24.ris`. After the scope change it holds only the 19 entries from sections 1 to 3, because Zotero entry for sections 4 to 8 belongs to the parallel agents. The 25 section 4 and 5 items are in `references.bib` but not in this RIS file. No Zotero items were pulled, so any entries added in Zotero since 2026-10-04 are not in this run. Nothing was committed.

Scope of verification: each check confirms that the work exists and that the bibliographic metadata are correct. It does not confirm that the work supports the claim it is meant to carry. Where a lead came from the synthesizer's memory, the fit between work and claim still has to be checked by the synthesizer from the abstract or full text (section 6).

## 1. Counts

| Outcome | n |
|---|---|
| Numbered entries in `missing-references.md` | 52 |
| Entries with at least one verified work added | 30 |
| of which fully resolved (every named work verified) | 26 |
| of which partly resolved (named works verified; a search remainder stays open) | 4 (entries 11, 25, 28, 35) |
| Search requests (claim only, no work named) | 13 (entries 9, 10, 18 to 23, 26, 30, 36, 44, 45) |
| PI decisions (unsure G1 records, verified on 2026-10-04 but held out at G1) | 7 (entries 43, 46 to 51) |
| Unobtainable in this run | 1 (entry 52, `downes2000knowledge`) |
| No new reference (full-text retrieval of existing keys) | 1 (entry 34) |
| Works and documents verified and added to `references.bib` | 44 (sections 1 to 3: 19; section 4: 11; section 5: 14) |
| by primary evidence: Crossref DOI record (title, authors, year, volume, pages agree) | 25 |
| by primary evidence: Library of Congress catalogue record (LCCN logged) | 9 (8 books, plus the Jensen and Meckling chapter via its volume, with pages from the authors' PDF) |
| by primary evidence: repository record (RePEc, APO) plus PDF of the work | 2 (Blinder 2007; Hanson, Currey and Beattie 2020) |
| by primary evidence: official record (GOV.UK, EU Publications Office, European Commission, O\*NET Resource Center) | 8 |
| Works named in sections 1 to 6 that failed verification | 0 |
| Entries in `references.bib` after this run | 137 (93 before) |

Check: entries 30 + 13 + 7 + 1 + 1 = 52; works 25 + 9 + 2 + 8 = 44. Two Crossref items also have a second source: Donaldson (2001) has a LoC record, and Firpo, Fortin and Lemieux (2011) have an SSRN DOI with the IZA series number from RePEc. Section 2 gives the evidence per key.

Sections 1 to 3 (this agent's scope after the split) are entries 1 to 23: 14 fully resolved (1 to 8, 12 to 17), 1 partly resolved (11: Mintzberg verified, the alliance-governance source still a search request), 8 search requests (9, 10, 18 to 23), 0 unobtainable. These yield 19 new keys.

## 2. Citation keys

Convention as on 2026-10-04: first-author surname (for an institution, the full name) in lowercase ASCII with spaces, hyphens, punctuation and diacritics removed, plus year, plus the first title word not in {a, an, the, on, of, in, for, and, to, at, by, with}. No collisions with the 93 existing keys or among the new keys. The O\*NET page carries no date, so its key has no year.

| Key | Entry | Type | Evidence | First author, year, title |
|---|---|---|---|---|
| `autor2003skill` | 29 | article | Crossref 10.1162/003355303322552801 | Autor 2003, The skill content of recent technological change, QJE 118(4) 1279-1333 |
| `bauerledanzman2023mapping` | 42 | article | Crossref 10.1093/isq/sqad026 | Bauerle Danzman 2023, Mapping the characteristics of foreign investment screening mechanisms, ISQ 67(2) sqad026 |
| `blinder2007how` | 27 | working paper | RePEc RePEc:pri:cepsud:142; PDF (title page: CEPS Working Paper No. 142, March 2007) | Blinder 2007, How many U.S. jobs might be offshorable? |
| `burns1961management` | 8 | book | LoC LCCN 62052165 (Tavistock, London, 1961) | Burns 1961, The management of innovation |
| `cabinetoffice2026common` | 39 | guidance | GOV.UK content record (Cabinet Office, Home Office; first published 2019-02-22, updated 2026-01-01) | Cabinet Office 2026, Common Travel Area: rights of UK and Irish citizens |
| `child1972organizational` | 5 | article | Crossref 10.1177/003803857200600101 | Child 1972, Organizational structure, environment and performance, Sociology 6(1) 1-22 |
| `dierdorff2009milieu` | 25 | article | Crossref 10.1037/a0015456 | Dierdorff 2009, The milieu of managerial work, JAP 94(4) 972-988 |
| `donaldson1987strategy` | 3 | article | Crossref 10.1111/j.1467-6486.1987.tb00444.x | Donaldson 1987, Strategy and structural adjustment to regain fit and performance, JMS 24(1) 1-24 |
| `donaldson2001contingency` | 4 | book | Crossref 10.4135/9781452229249; LoC LCCN 00010586 | Donaldson 2001, The contingency theory of organizations (Sage, Thousand Oaks) |
| `drazin1985alternative` | 7 | article | Crossref 10.2307/2392695 (first page only); last page 539 from EconBiz record 10001013645 | Drazin 1985, Alternative forms of fit in contingency theory, ASQ 30(4) 514-539 |
| `du2025how` | 38 | article | Crossref 10.1057/s42214-024-00202-6 | Du 2025, How did the Brexit uncertainty impact services exports of UK firms?, JIBP 8(1) 80-104 |
| `egelhoff1982strategy` | 16 | article | Crossref 10.2307/2392321 (first page only); last page 458 from EconBiz record 10002110774 | Egelhoff 1982, Strategy and structure in multinational corporations, ASQ 27(3) 435-458 |
| `eisenhardt1985control` | 12 | article | Crossref 10.1287/mnsc.31.2.134 | Eisenhardt 1985, Control: organizational and economic approaches, MS 31(2) 134-149 |
| `europeancommission2026list` | 42 (S06 document) | official list | EC investment screening page (link opened 2026-11-24); PDF in `data/raw/external/`, page 1 read: "Last update: 9 February 2026" | European Commission 2026, List of screening mechanisms notified by Member States |
| `europeanparliament2019regulation` | 42 (S06 document) | regulation | EU Publications Office Cellar notice, CELEX 32019R0452: OJ L 79I, 21.3.2019, pp. 1-14; legislation.gov.uk record | European Parliament 2019, Regulation (EU) 2019/452 |
| `firpo2011occupational` | 27 | working paper | Crossref 10.2139/ssrn.1778886 (SSRN); RePEc RePEc:iza:izadps:dp5542 (IZA Discussion Paper 5542, 2011) | Firpo 2011, Occupational tasks and changes in the wage structure |
| `foreigncommonwealthdevelopmentoffice2021trade` | 35 | treaty | GOV.UK record: Treaty Series No. 8 (2021), CP 426, ISBN 978-1-5286-2546-3 | FCDO 2021, Trade and Cooperation Agreement (UK, EU, EAEC) |
| `galbraith1973designing` | 2 | book | LoC LCCN 72011887 (Addison-Wesley, Reading, MA) | Galbraith 1973, Designing complex organizations |
| `galbraith1974organization` | 2 | article | Crossref 10.1287/inte.4.3.28 | Galbraith 1974, Organization design: an information processing view, Interfaces 4(3) 28-36 |
| `glennon2024how` | 41 | article | Crossref 10.1287/mnsc.2023.4715 | Glennon 2024, How do restrictions on high-skilled immigration affect offshoring?, MS 70(2) 907-930 |
| `gulati2012two` | 13 | article | Crossref 10.5465/19416520.2012.691646 | Gulati 2012, The two facets of collaboration, AMA 6(1) 531-583 |
| `hanson2020chinese` | S19 document (requested in the brief) | report | PDF of the work in `data/raw/external/` (Policy Brief Report No. 36/2020, "First published August 2020"); APO record node 307991 (logged in `literature/shock-scan/rescoring.md`, section 8) | Hanson 2020, The Chinese Communist Party's coercive diplomacy |
| `hardy2018educational` | 28 | article | Crossref 10.1111/ecot.12145 | Hardy 2018, Educational upgrading, structural change and the task composition of jobs in Europe, EoT 26(2) 201-231 |
| `homeoffice2020statement` | 40 | parliamentary paper | GOV.UK record and PDF: HC 813, 22 October 2020, ISBN 978-1-5286-2186-1 | Home Office 2020, Statement of changes in Immigration Rules |
| `homeoffice2020uks` | 37, 40 | policy paper | GOV.UK record and PDF: CP 220, 19 February 2020, ISBN 978-1-5286-1775-8 | Home Office 2020, The UK's points-based immigration system: policy statement |
| `jensen1992specific` | 15 | chapter | LoC LCCN 92006048 (Contract Economics, Werin and Wijkander eds., Blackwell, 1992); chapter pages 251-274 from the authors' PDF | Jensen 1992, Specific and general knowledge, and organizational structure |
| `jensen2010measuring` | 27 | chapter | Crossref 10.7208/chicago/9780226001463.003.0009; editors from LoC LCCN 2010012103 | Jensen 2010, Measuring tradable services and the task content of offshorable services jobs, pp. 309-335 |
| `kim2003global` | 31 | article | Crossref 10.1057/palgrave.jibs.8400035 | Kim 2003, The global integration of business functions, JIBS 34(4) 327-344 |
| `malnight1996transition` | 33 | article | Crossref 10.1057/palgrave.jibs.8490125 | Malnight 1996, The transition from decentralized to network-based MNC structures, JIBS 27(1) 43-65 |
| `mintzberg1979structuring` | 11 | book | LoC LCCN 78012448 (Prentice-Hall, Englewood Cliffs) | Mintzberg 1979, The structuring of organizations |
| `moschieri2019organizational` | 38 | article | Crossref 10.1186/s41469-019-0047-8 | Moschieri 2019, The organizational implications of Brexit, JOD 8(1) article 6 |
| `nationalcenterforonetdevelopmentonet` | 24 | web page | O\*NET Resource Center page and its "Cite this page" record (undated; site of U.S. DOL/ETA) | National Center for O\*NET Development, n.d., The O\*NET content model |
| `ouchi1979conceptual` | 12 | article | Crossref 10.1287/mnsc.25.9.833 | Ouchi 1979, A conceptual framework for the design of organizational control mechanisms, MS 25(9) 833-848 |
| `peterson2001understanding` | 24 | article | Crossref 10.1111/j.1744-6570.2001.tb00100.x | Peterson 2001, Understanding work using the Occupational Information Network (O\*NET), PP 54(2) 451-492 |
| `pfeffer1978external` | 17 | book | LoC LCCN 77013907 (Harper & Row, New York) | Pfeffer 1978, The external control of organizations |
| `porter1986competition` | 32 | edited book | LoC LCCN 86018377 (Harvard Business School Press, Boston; "edited by Michael E. Porter") | Porter (Ed.) 1986, Competition in global industries |
| `puranam2014whats` | 14 | article | Crossref 10.5465/amr.2011.0436 | Puranam 2014, What's "new" about new forms of organizing?, AMR 39(2) 162-180 |
| `shrestha2026end` | 37 | article | Crossref 10.1016/j.econlet.2025.112759 | Shrestha 2026, The end of free movement and international migration, EL 259, 112759 |
| `stopford1972managing` | 16 | book | LoC LCCN 72076909 (Basic Books, New York) | Stopford 1972, Managing the multinational enterprise |
| `thompson1967organizations` | 1 | book | LoC LCCN 67011564 (McGraw-Hill, New York) | Thompson 1967, Organizations in action |
| `tung2025hyperglobalization` | 38 | article | Crossref 10.1057/s41267-025-00792-0 | Tung 2025, Hyperglobalization at a crossroads, JIBS 56(9) 1093-1101 |
| `ukvisasandimmigration2023uks` | 37 | guidance | GOV.UK content record (UKVI; first published 2020-10-19, updated 2023-09-08); body states that free movement between the UK and the EU ended on 31 December 2020 | UK Visas and Immigration 2023, The UK's points-based immigration system: information for EU citizens |
| `vandeven2013returning` | 6 | article | Crossref 10.5465/19416520.2013.774981 | Van de Ven 2013, Returning to the frontier of contingency theory, AMA 7(1) 393-440 |
| `woodward1965industrial` | 8 | book | LoC LCCN 65006145 (Oxford University Press, London) | Woodward 1965, Industrial organization: theory and practice |

## 3. Items that failed verification

None of the works or documents named in sections 1 to 6 failed. Entry 52 (`downes2000knowledge`, section 8) was not re-verified, as instructed (status report only). A read-only check of the EconBiz catalogue API found no record for it. It stays in `literature/references-unverified.bib`; a JSTOR record or a first-page PDF is still needed.

## 4. Discrepancies between the leads and the verified records

| Key | Lead in `missing-references.md` | Verified record | Action |
|---|---|---|---|
| `shrestha2026end` | Economics Letters 2025, authors not seen | Shrestha & Sant'Anna, vol. 259, article 112759, issue dated January 2026 | Print-issue year 2026 used (rule of 2026-10-04). Crossref has no online date; the copyright line reads 2025, so the online date is not stated in the record |
| `glennon2024how` | Management Science, year and volume to confirm | 2024, 70(2), 907-930 | Year set from the print issue |
| `moschieri2019organizational` | "The organizational implications of Brexit", outlet not seen | Moschieri & Blake, Journal of Organization Design 8(1), article 6, issue dated December 2019 | Added. Online first 2019-03-19 (in the RIS Extra line) |
| `tung2025hyperglobalization` | JIBS 2025, authors not seen | Tung & Qin, 56(9), 1093-1101, December 2025 | Added. Online first 2025-06-20 |
| `du2025how` | JIBP 2025, Brexit uncertainty and UK services exports | Du, Shepotylo & Yuan, 8(1), 80-104, March 2025 | Added. Online first 2025-01-03 |
| `blinder2007how` | RePEc working paper | RePEc page shows "Working Papers 60" in its citation line, but the handle (cepsud:142) and the PDF title page give CEPS Working Paper No. 142, March 2007 | No. 142 used, from the PDF. A 2009 World Economics version, 10(2), 41-78, exists; it is a later version and was not added |
| `jensen1992specific` | Jensen & Meckling 1992 | Crossref holds only the 1995 Journal of Applied Corporate Finance reprint and a 1996 Elsevier reprint | Original 1992 chapter cited (rule of 2026-10-04), from the catalogue record and the authors' PDF |
| `drazin1985alternative` | Drazin & Van de Ven 1985 | Crossref (JSTOR deposit) inverts the second author ("de Ven, Andrew H. Van") and gives only the first page | Author written as Van de Ven, Andrew H.; last page from EconBiz |
| `egelhoff1982strategy` | Egelhoff 1982 | Crossref title has a stray space ("Information- Processing"); first page only | Title normalized; last page from EconBiz |
| `kim2003global` | Kim, Park & Prescott 2003 | Crossref gives initials only (K; J-H; J E) | Initials kept; no given names added from memory. Online first 2003-05-15 |
| `autor2003skill` | Autor, Levy & Murnane 2003 | Crossref gives initials only | Initials kept |
| `bauerledanzman2023mapping` | ISQ 67(2), sqad026 | Crossref print date 2023-03-14 precedes the online date 2023-04-18 | Year 2023 either way; online date kept in Extra |
| `porter1986competition` | "Porter 1986, Competition in Global Industries" | An edited volume ("edited by Michael E. Porter") | Entered as an edited book with Porter as editor. If the synthesis needs Porter's own framework chapter, its pages need a separate record |
| `donaldson1987strategy` | JMS 1987 | Crossref "online" date 2007-05-05 is the Wiley back-file digitization, not an online-first date | Not recorded as online first |

## 5. Versions and originals

Originals were cited throughout: Thompson (1967, McGraw-Hill) rather than later reissues; Pfeffer and Salancik (1978, Harper & Row) rather than the 2003 reissue; Burns and Stalker (1961, Tavistock) rather than the 1966 printing that the Library of Congress also lists; Jensen and Meckling (1992) rather than the 1995 and 1996 reprints; Blinder (2007) as the working paper the lead names. Undated or updated official pages carry the date of the version read (GOV.UK "last updated" date) and the first-publication date in `howpublished`; the O\*NET page has no date (n.d.).

## 6. Content checks for the synthesizer (metadata verified, fit not verified)

The following were memory or desk-search leads. The works exist as recorded, but whether each carries the claim has to be confirmed from the abstract or full text before a `[CITE]` marker is replaced:

- `mintzberg1979structuring` for "senior levels carry coordination responsibility" (entry 11, `coord_role`).
- `dierdorff2009milieu` for "occupational task data as a task-environment measure in management research" (entries 25, 30).
- `blinder2007how`, `firpo2011occupational`, `jensen2010measuring` for O\*NET face-to-face and on-site items as location-bound work (entry 27). The Blinder PDF confirms that the offshorability index was built with O\*NET (the acknowledgements thank O\*NET staff, and O\*NET is named 26 times in the text); which items each paper uses was not checked.
- `hardy2018educational` for applying US O\*NET descriptors to European jobs (entry 28).
- `kim2003global` as a function-level classification of global integration (entry 31, task 4a). It was not screened at G1.
- `malnight1996transition` for function-by-function evolution of MNC integration (entry 33).
- `moschieri2019organizational`, `du2025how`, `tung2025hyperglobalization` for Brexit and firm organization or staffing (entry 38). `du2025how` is about services exports, so it may not carry a staffing claim.
- `foreigncommonwealthdevelopmentoffice2021trade` for "UK and EU regulation, customs, product approval and tax administration diverged after 31 December 2020" (entry 35). The treaty is the legal basis of the post-transition relationship, but the specific divergence claims were not checked against its text.
- `homeoffice2020uks` for C2 step 3. The policy statement sets the general salary threshold at £25,600 and a floor of £20,480 for tradeable points, and states that requirements for new entrants will be 30% lower than for experienced workers. The reduced new-entrant rate may weaken the outline's claim that thresholds "bite more at junior and lower-paid levels", and the synthesizer should frame that step accordingly. `homeoffice2020statement` (HC 813) is the statement of changes that inserted Appendix Skilled Worker and Appendix Intra-Company Routes. Its text is the place to look for the open `[DATA: linked-entity rule]` item, which this run did not resolve.
- `ukvisasandimmigration2023uks` states in its body that free movement between the UK and the EU ended on 31 December 2020 and that the points-based system started on 1 January 2021. This carries the factual part of C2 step 1. `shrestha2026end` is the scholarly source on migration flows, and its content was checked by title only.

## 7. Section 7 and 8 records (status only)

All records below were verified on Crossref or by web evidence on 2026-10-04 (`verification-report-2026-10-04.md`, sections 6 and 11) and held out of the `.bib` because they were screened unsure. Including them is a PI decision at G2.

| Entry | Screening id | Key | Verification status (2026-10-04) |
|---|---|---|---|
| 43 | CON-S6-09 | `gregoire2024mobilizing` | verified, Crossref 10.5465/amj.2024.4002 |
| 43 | CON-S6-10 | `cubrich2021examining` | verified, Crossref 10.1016/j.chb.2021.106742 |
| 46 | CON-S6-01 | `park2019global` | verified, Crossref 10.1038/s41467-019-11380-w |
| 47 | CC-S3-20 | `chung2010trap` | verified, Crossref 10.1287/orsc.1090.0489 |
| 48 | CON-S2-04 | `schlegelmilch2022balancing` | verified, Crossref 10.1007/978-3-030-90665-8_4 |
| 48 | CON-S2-07 | `chen2020global` | verified, Crossref 10.1007/978-3-030-44425-9_7 |
| 49 | CC-S2-10 | `doz1980how` | verified (web search, HBR article page; Doz & Prahalad, HBR 58(2), March 1980); pages unconfirmed |
| 50 | CC-S1-16 | `bouquet2008managing` | verified, Crossref 10.1177/0149206308316062 |
| 50 | CC-S1-17 | `birkinshaw2005subsidiary` | verified, Crossref 10.1016/j.ibusrev.2004.04.010 |
| 51 | CON-S5-03 | `atanassova2026sociopolitical` | verified, Crossref 10.1108/cpoib-12-2025-0289 |
| 51 | CON-S5-10 | `aliasghar2023adjustment` | verified, Crossref 10.1108/mbr-07-2022-0105 |
| 51 | CC-S5-05 | `luo2021springboard` | verified, Crossref 10.1057/s41267-021-00423-4 |
| 51 | CC-S5-08 | `witt2021deglobalization` | verified, Crossref 10.1017/mor.2021.9 |
| 51 | CC-S5-09 | `teece2022wideraperture` | verified, Crossref 10.1002/gsj.1462 |
| 52 | CON-S4-04 | `downes2000knowledge` | unverified; in `references-unverified.bib`; no EconBiz record (checked 2026-11-24, read-only) |

## 8. Citation-key scan

All 95 distinct key-shaped tokens in `literature/synthesis/*.md` and `concept-matrix.csv` were checked by script against `references.bib`. 93 are present. The two absent keys are `downes2000knowledge` (in `references-unverified.bib`) and `nguyen2009foreign` (dropped by the PI on 2026-10-04). Both appear only in "not citable" notes (`memo-t3-ijv-control-staffing.md` line 6, `missing-references.md` entry 52 and its note, and the matrix rows marked "Not used"). The synthesis has no Pandoc `[@key]` citations. None of the 44 new keys is cited in the synthesis yet; the marker-to-key list is in `reviews/gate-2-synthesis.md`. `manuscript/sections/` contains no `.qmd` file with citations, so `manuscript/missing-citations.md` was not changed. Citation hygiene (order inside parentheses, "&" versus "and", page numbers on quotes) applies to manuscript prose and was not checked on the working memos.

## 9. What the PI must do

1. Import `literature/zotero/import-2026-11-24.ris` (19 items, sections 1 to 3) into the group library (suggested collection "Stage 2 - missing references 2026-11-24 (verified)"). Each record carries a note that starts "Extra (move to the Extra field after import)". Move that text into Extra so that Better BibTeX pins the citation key ("Citation Key: ...") and the verification line is kept. The 25 items from sections 4 and 5 that are already in `references.bib` must enter Zotero through the parallel agents or the orchestrator, with the keys listed in section 2. Do not let the automatic Better BibTeX export overwrite `references.bib` until all 44 items are in Zotero; otherwise those 25 entries drop out of the `.bib`.
2. Alternatively, put `ZOTERO_API_KEY` and `ZOTERO_GROUP_ID` in `.Renviron` or `.env` at the repository root (both gitignored) and rerun `/references`. The agent then pushes the items, pulls any items added in Zotero since 2026-10-04, and pins the keys.
3. Set a contact e-mail for Crossref (for example `CROSSREF_MAILTO` in `.Renviron`) if the polite pool is wanted. This run used a generic User-Agent.
4. Decide at G2 on the unsure records in section 7, and on `downes2000knowledge` (JSTOR record, PDF, or drop).

## 10. Files

- `literature/references.bib`: 44 entries added in key order; header comment extended; the 93 existing entries are unchanged (diff: 489 insertions, 0 deletions). Parsed without error by Pandoc (137 entries).
- `literature/zotero/import-2026-11-24.ris`: the 19 new entries from sections 1 to 3, for manual Zotero import.
- `literature/fulltext/` (gitignored): `jensen1992specific.pdf` (authors' version), `blinder2007how.pdf`, `homeoffice2020uks.pdf`.
- Public files read in `data/raw/external/` (not modified): `ec-list-screening-mechanisms-2026-02-09.pdf`, `aspi-ccp-coercive-diplomacy-2020.pdf`.
