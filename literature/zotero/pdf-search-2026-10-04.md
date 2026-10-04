# PDF and catalogue search for references that failed Crossref verification, 2026-10-04

Scope: the 16 works listed in the brief (the 11 open items from section 3 of `verification-report-2026-10-04.md` that are not already resolved, the three seed books accepted earlier on Crossref book-review evidence, and the originals of `doz2017control` and `prahalad2017approach`). Agent: web-search subagent. No file other than this one was edited. Zotero was not touched. Nothing was committed.

## Method and limits

The only tool that worked was WebSearch. Every other route was blocked by the network egress proxy:

- WebFetch returned `EGRESS_BLOCKED` for hbr.org, store.hbr.org, osti.gov, archive.org and ijb.cyut.edu.tw.
- `curl` through the proxy returned no connection (HTTP 000) for every catalogue and repository tried: worldcat.org, search.worldcat.org, catalog.loc.gov, lccn.loc.gov, openlibrary.org, archive.org, books.google.com, ir.lib.uwo.ca, uwo.scholaris.ca, sloanreview.mit.edu, proquest.com, jstor.org, ideas.repec.org, eco.uninsubria.it, pure.eur.nl, taylorfrancis.com, routledge.com, researchgate.net, semanticscholar.org, core.ac.uk, openalex.org, among others. Only api.crossref.org was reachable. The Google Books API returned 429.
- As a result, **no PDF could be downloaded** and `literature/fulltext/` was not created.

What "evidence" means in this file: a search result whose URL is on an accepted-type site (publisher, journal, library catalogue, institutional repository) and whose title and author match, plus the bibliographic details that the search tool reported for that page. The pages themselves were **not opened**. The search tool's summaries can mix in details from citing sources, so details that were reported only in a summary, and not in a result title or URL, are marked "per search summary". Every item marked verified below should get a one-click check by a human (open the URL, confirm the fields) before the Zotero record is changed. Crossref was queried directly for items 1 and 15.

The Consensus connector was used once (item 8) and only to identify which work the broken record refers to. It is not counted as evidence. Two Consensus searches remain this month.

Outcome categories:

- **verified**: an accepted-type source (per the PI's rules) shows the work with matching authors and title. Any fields that the source does not cover are listed.
- **partly verified**: the work and its core details are confirmed, but at least one field the manuscript needs (usually pages of the original edition) rests on supporting evidence only.
- **supporting only**: only citing references, booksellers, aggregators or user-uploaded pages were found.
- **nothing found**.

---

## 1. andersson2018integration

Queries:
- `"Integration in the Multinational Corporation" "Subsidiary Embeddedness" Andersson`
- `"Global Competition and Local Networks" McNaughton Green "Integration in the multinational corporation" Andersson Forsgren`
- `"Global Competition and Local Networks" Routledge table of contents chapter "Subsidiary Embeddedness"`
- `Global Competition and Local Networks McNaughton Green table of contents Andersson Forsgren subsidiary embeddedness` (restricted to routledge.com and taylorfrancis.com)
- `Andersson Forsgren 2002 "Integration in the multinational corporation: the problem of subsidiary embeddedness" Ashgate`
- `"9781315196831-27" OR "10.4324/9781315196831-27"`, a taylorfrancis chapter query, a DiVA query, and an Ashgate ISBN and catalogue query
- Crossref API: `works/10.4324/9781315196831-27` and `works/10.4324/9781315196831`

Evidence:
- Routledge product pages https://www.routledge.com/Global-Competition-and-Local-Networks/McNaughton-Green/p/book/9781138716797 and .../9781315196831, and Taylor & Francis https://www.taylorfrancis.com/books/mono/10.4324/9781315196831/global-competition-local-networks-rod-mcnaughton-milford-green. Per search summary of the Routledge/T&F pages: the table of contents lists "Integration in the multinational corporation: the problem of subsidiary embeddedness" by Ulf Andersson and Mats Forsgren, in the part "Contexts of Network Strategies". The book is edited by Rod B. McNaughton and Milford B. Green and was first published in 2002. (Publisher catalogue, accepted type.)
- Crossref (direct query): chapter 10.4324/9781315196831-27, "Integration in the Multinational Corporation: The Problem of Subsidiary Embeddedness", in *Global Competition and Local Networks*, Routledge, published 2018-02-06, pp. 369-391, no authors deposited. The book record 10.4324/9781315196831 lists McNaughton (as author) and Green (as editor).
- Citing references only (supporting): Andersson, U. & Forsgren, M. (2002), in R. McNaughton & M. Green (Eds), "Global Competition and Global Networks" [sic], Aldershot: Ashgate, 343-65.

Outcome: **partly verified**. The publisher catalogue confirms the authors (Andersson and Forsgren), the editors and the original 2002 date. Crossref confirms the 2018 Routledge Revivals reissue with its pagination. No catalogue record was found for the 2002 Ashgate edition, and its pagination (343-365) comes from citing references only.

Confirmed details (citable now, reissue): Andersson, U., & Forsgren, M. (2018). Integration in the multinational corporation: The problem of subsidiary embeddedness. In R. B. McNaughton & M. B. Green (Eds.), *Global competition and local networks* (pp. 369-391). Routledge. https://doi.org/10.4324/9781315196831-27 (originally published 2002, Ashgate).

PDF: none open.

Discrepancies with the current record: the second author (Forsgren) is missing. The item type is `article` but should be a book chapter (`incollection`) with editors, book title, publisher and pages. The key year depends on the version cited. If the 2002 original is cited, the Ashgate pages (343-365 per citing sources) need checking against a copy. The middle initial "R." for Andersson comes from Consensus and was not confirmed.

## 2. downes2000knowledge

Queries:
- `"Knowledge transfer through expatriation" "U-curve approach to overseas staffing" Downes Thomas Journal of Managerial Issues`
- `Downes Thomas 2000 "Knowledge transfer through expatriation" Journal of Managerial Issues vol 12 no 2` (restricted to jstor, proquest, questia and similar)
- `"Knowledge Transfer through Expatriation: The U-Curve Approach to Overseas Staffing" jstor`
- `Downes Thomas Knowledge Transfer through Expatriation U-Curve Approach Overseas Staffing` (restricted to jstor.org)
- `jstor stable "Knowledge Transfer through Expatriation" Downes "Journal of Managerial Issues"`
- `Journal of Managerial Issues Summer 2000 Vol 12 No 2 table of contents Downes Thomas expatriation`

Evidence:
- Questia issue page https://www.questia.com/library/p4318/journal-of-managerial-issues/i2894914/vol-12-no-2-summer ("Journal of Managerial Issues, Vol. 12, No. 2, Summer, 2000"). Per search summary, the article is listed in that issue. Questia was a commercial online library (now closed). This is an aggregator's issue listing, not the journal's own table of contents.
- ResearchGate page https://www.researchgate.net/publication/234021475_Knowledge_Transfer_through_Expatriation_The_U-Curve_Approach_to_Overseas_Staffing. Per search summary: JMI 12(2), 131-149, 2000. User-generated, so not accepted.
- JSTOR carries the *Journal of Managerial Issues* (https://www.jstor.org/journal/jmanaissues), but no JSTOR article page came up in the results.
- Citing references (not accepted): Downes, M. & Thomas, A. S. (2000), JMI 12, 131-149.

Outcome: **supporting only**. The Questia issue listing is the strongest lead. The PI may decide whether a digital-library issue listing counts as a library record.

Most likely details (unconfirmed): Downes, M., & Thomas, A. S. (2000). Knowledge transfer through expatriation: The U-curve approach to overseas staffing. *Journal of Managerial Issues, 12*(2), 131-149.

PDF: none open.

Discrepancies: the co-author Thomas, A. S. is missing, and so are the volume, issue and pages.

PI action: look up the JSTOR stable URL through the library (JMI is on JSTOR). A first-page PDF or the JSTOR record would verify the item.

## 3. doz1980how

Queries:
- `"How MNCs cope with host government intervention" Doz Harvard Business Review 1980`
- `How MNCs Cope with Host Government Intervention Doz Prahalad` (restricted to hbr.org, store.hbr.org, osti.gov, thecasecentre.org)
- `Doz Prahalad 1980 "How MNCs cope with host government intervention" "58" "149"`
- `osti.gov biblio 5424896 How MNCs cope with host-government intervention Harvard Bus. Rev. Doz Prahalad` (restricted to osti.gov)
- WebFetch of hbr.org, store.hbr.org and osti.gov: all blocked.

Evidence:
- HBR article page https://hbr.org/1980/03/how-mncs-cope-with-host-government-intervention. The URL dates it to March 1980. Per search summary: by Yves Doz and C. K. Prahalad, March 1980 issue. (Journal's own page, accepted.)
- HBR Store https://store.hbr.org/product/how-mncs-cope-with-host-government-intervention/80204 and HBSP https://hbsp.harvard.edu/product/80204-PDF-ENG: reprint product 80204 (publisher catalogue).
- OSTI record https://www.osti.gov/biblio/5424896, "How MNCs cope with host-government intervention (Journal Article)". Per search summary: Harvard Business Review, volume 58, issue 2, authors Y. L. Doz and C. K. Prahalad. (US DOE bibliographic database, a government library-catalogue type record.)
- The Case Centre https://www.thecasecentre.org/products/view?id=47678 (distributor listing, supporting only).

Outcome: **verified** for authors, title, outlet, year, month, volume and issue. The page range 149-157 appeared only in search summaries and was not tied to an accepted page, so treat it as unconfirmed.

Confirmed details: Doz, Y. L., & Prahalad, C. K. (1980). How MNCs cope with host government intervention. *Harvard Business Review, 58*(2), [pages: 149-157 per search summary, confirm]. HBR reprint 80204.

PDF: not open (HBR paywall). None attempted.

Discrepancies: the co-author Prahalad is missing, and so are the journal, volume, issue and pages. OSTI hyphenates "host-government", while the HBR page title does not. Use the HBR form.

## 4. ghoshal1993horses

Queries:
- `"Horses for courses" "organizational forms for multinational corporations" Ghoshal Nohria Sloan Management Review 1993`
- `Horses for Courses Organizational Forms for Multinational Corporations Ghoshal Nohria` (restricted to sloanreview.mit.edu, dspace.mit.edu, proquest.com, worldcat.org, ebsco.com)
- `Horses for courses Ghoshal Nohria 1993 Sloan Management Review 34 2 23 proquest`
- `Ghoshal Nohria Horses for Courses Sloan Management Review Winter 1993 pages 23-35` (restricted to SMR, ProQuest, HBS)
- `"Horses for courses" Ghoshal Nohria Sloan Management Review Vol. 34 Iss. 2 Winter 1993` (restricted to proquest.com)

Evidence:
- MIT SMR article page https://sloanreview.mit.edu/article/horses-for-courses-organizational-forms-for-multinational-corporations/. Per search summary: S. Ghoshal and N. Nohria, *Sloan Management Review* 34, no. 2 (Winter 1993): 23-35, posted January 15, 1993. (Journal's own page, accepted.)
- MIT SMR Store https://shop.sloanreview.mit.edu/store/horses-for-courses-organizational-forms-for-multinational-corporations (publisher catalogue).
- ProQuest record https://www.proquest.com/openview/3f2f60b0eddffc67939a02ca3852e9f8/1. Per search summary: Sloan Management Review, Vol. 34, Iss. 2 (Winter 1993), first page 23. (Source database.)
- HBS faculty page https://www.hbs.edu/faculty/Pages/item.aspx?num=2647 (author's institution, supporting).

Outcome: **verified**.

Confirmed details: Ghoshal, S., & Nohria, N. (1993). Horses for courses: Organizational forms for multinational corporations. *Sloan Management Review, 34*(2), 23-35.

PDF: not open (SMR paywall).

Discrepancies: Nohria is missing, and so are the journal, volume, issue and pages. The earlier report noted that citing sources disagree on the last page (35 or 36). The SMR page, per search summary, gives 35.

## 5. killing1983strategies

Queries:
- `Killing "Strategies for joint venture success" Praeger 1983 ISBN`
- `Strategies for joint venture success Killing 1983 New York Praeger catalog record` (restricted to archive.org, openlibrary.org, catalog.loc.gov, worldcat, books.google.com, hathitrust)
- `"83013923" Killing Strategies for joint venture success`
- `"Strategies for joint venture success" Killing 1983 Praeger hathitrust OR worldcat OR "library of congress"`
- `Strategies for joint venture success Killing` (restricted to worldcat; no relevant hit)

Evidence:
- Internet Archive record https://archive.org/details/strategiesforjoi0000kill_t8v6, "Strategies for joint venture success : Killing, J. Peter". Per search summary: New York, Praeger, 1983, 133 p., bibliography pp. 130-131, index, ISBN 0030639719, LCCN 83013923. Internet Archive is a digital library, and its record describes a scanned physical copy and carries the Library of Congress control number.
- Google Books https://books.google.com/books/about/Strategies_for_Joint_Venture_Success.html?id=tf4JAQAAMAAJ (supporting).
- AbeBooks listings for the Croom Helm/Routledge Kegan & Paul edition (ISBN 0709915381) and for the Routledge reissues (supporting only, bookseller).
- Publisher previews of the Routledge Library Editions reissue: https://api.pageplace.de/preview/DT0400.9781135133733_A23799465/preview-9781135133733_A23799465.pdf. The copyright page should state the original 1983 publication, but it was not opened.

Outcome: **verified** (library repository record), provided the PI accepts the Internet Archive record as a library record. If not, the LCCN 83013923 allows a quick check at https://lccn.loc.gov/83013923.

Confirmed details: Killing, J. P. (1983). *Strategies for joint venture success*. Praeger. (New York; 133 pp.; ISBN 0-03-063971-9; LCCN 83013923.)

PDF: the Internet Archive copy is controlled lending only, not open access.

Discrepancies: none in the core fields. Add the place and ISBN. A UK edition (Croom Helm, ISBN 0709915381) also exists. One search summary also mentioned ISBN 9780275910266 for a Praeger edition; that was not confirmed.

## 6. mohedanosuanescontrol

Queries:
- `Mohedano-Suanes "Control and Performance in International Joint Ventures" "Value Activities"`
- `International Journal of Business Vol 26 No 4 2021 Mohedano-Suanes Safón control performance international joint ventures` (restricted to ijb.cyut.edu.tw, producciocientifica.uv.es, roderic.uv.es, dialnet)
- `Mohedano-Suanes Safón International Journal of Business 26(4) 2021 pages value activities IJV control` (restricted to ijb.cyut.edu.tw)
- WebFetch of the PDF: blocked.

Evidence:
- Journal PDF https://ijb.cyut.edu.tw/var/file/10/1010/img/838/V26N4-2.pdf. The result title reads "INTERNATIONAL JOURNAL OF BUSINESS, 26(4), 2021 ISSN: 1083-4346", which is the running header of the article PDF. Per search summary: "Control and Performance in International Joint Ventures. A Model Based on Value Activities" by Antonia Mohedano-Suanes and Vicente Safón, pp. 20-45. (Open-access journal PDF of the work, accepted.)
- Journal volume page https://ijb.cyut.edu.tw/p/412-1010-5263.php?Lang=en (Volume 26 table of contents, journal's own).
- Author's university record https://producciocientifica.uv.es/investigadores/334678/publicaciones (Universitat de València research portal, supporting).

Outcome: **verified** for authors, title, journal, volume, issue and year. The page range 20-45 is per search summary only and needs checking against the PDF header.

Confirmed details: Mohedano-Suanes, A., & Safón, V. (2021). Control and performance in international joint ventures: A model based on value activities. *International Journal of Business, 26*(4), [20-45, confirm]. ISSN 1083-4346.

PDF: open access at the URL above. Download was blocked by the proxy, so there is no local copy.

Discrepancies: the record had no year, journal or co-author. The key should become `mohedanosuanes2021control`. Note the outlet: *International Journal of Business* (published from Chaoyang University of Technology, Taiwan) is a low-tier journal, which matters for the weight this work can carry in a JIBS paper.

## 7. nguyen2009foreign

Queries:
- `"Foreign Parent Firm Contributions, Experiences, and International Joint Venture" Nguyen International Management Review`
- `Nguyen Huu Le 2009 International Management Review foreign parent contributions experiences IJV control performance Vaasa`
- `"International Management Review" 2009 vol 5 Le Nguyen Huu "International Joint Venture Control and Performance"`
- `imrjournal.org Nguyen foreign parent firm contributions experiences international joint venture`
- `"Foreign Parent Firm Contributions" "International Joint Venture" Nguyen pdf`
- `"International Management Review" Vol. 5 No. 1 2009 Nguyen joint venture`
- `Le Nguyen Huu University of Vaasa publications "International Management Review" 2009`
- `"Huu Le Nguyen" OR "Nguyen, H. L." "International Management Review" joint venture control performance contributions`
- `americanscholarspress International Management Review 2009 Nguyen joint venture control performance pdf`
- `"parent firm contributions" "joint venture control and performance" 2009`

Evidence: none for this title. The searches found other 2009 papers by Huu Le Nguyen (University of Vaasa): "Foreign Parent Strategies, Control and International Joint Venture Performance" (*International Business Research*, 2009; PDF via Semantic Scholar https://pdfs.semanticscholar.org/a70e/2bc1b4a8bf2bf72676675b1d4abd6032b328.pdf) and "Do partners' differences affect international joint venture control and performance?" (*Journal of International Business Research* 8(2), 67-86, per search summary). Neither matches the recorded title.

Outcome: **nothing found**.

Discrepancies: the title, outlet and year all rest on the Consensus record alone. It may be a conflation of the 2009 papers named above.

PI action: drop the item, or ask the library for the *International Management Review* (American Scholars Press) 2009 issues. If the substantive point is needed, one of the other Nguyen papers above could be checked as a replacement, but only after its own verification.

## 8. oostenfunctions

Queries:
- `van Oosten Agilent Italian subsidiary role "of functions"`
- `"van Oosten" Agilent subsidiary Italy thesis functions headquarters subsidiary role change`
- `"Oosten" master thesis subsidiary role Agilent Technologies Italia "bundle of functions" OR "relocation of functions" OR "allocation of functions"`
- Consensus (identification only): `van Oosten Agilent Italian subsidiary role change functions`
- `"Subsidiaries within a High-Tech MNC" "Role of Functions" Cocito`
- `Cocito Agilent "reappraisal of the role of functions" Insubria working paper 2004 RePEc`
- `uninsubria.it Cocito Gatta Majocchi Onetti 2004 subsidiaries high-tech MNC pdf QF2004`
- `Cocito Gatta Majocchi Onetti "Subsidiaries within a high-tech MNC" "Economics and Quantitative Methods" qf04011 2004/11` (restricted to RePEc and uninsubria)

Identification: Consensus returns the "of Functions / J. van Oosten" record with an abstract that is word-for-word the abstract of "Subsidiaries within a High-Tech MNC. A reappraisal of the Role of Functions" (Cocito et al., 2004). The broken record even ends on the first author's affiliation footnote ("Manager, Turin Technology Center, Agilent Technology, Via Guglielmo Reiss Romoli, 274, 10148 Torino"). "J. van Oosten" does not appear anywhere in connection with this work. It is a Consensus parsing error.

Evidence:
- RePEc/IDEAS record https://ideas.repec.org/p/ins/quaeco/qf04011.html: "Subsidiaries within a High-Tech MNC. A reappraisal of the Role of Functions", Economics and Quantitative Methods qf04011, Department of Economics, University of Insubria. Per search summary: authors Marco Cocito (Agilent Technology, Turin Technology Center), Raffaele Gatta (CEO, Agilent Technology Italia), Antonio Majocchi and Alberto Onetti (Department of Economics, University of Insubria); 2004. The series metadata is deposited by the issuing department, so this works as the publisher's own catalogue record for the working-paper series. Series page: https://ideas.repec.org/s/ins/quaeco.html.

Outcome: **verified** (working-paper series record), provided the PI accepts a RePEc series record as the publisher's catalogue.

Confirmed details: Cocito, M., Gatta, R., Majocchi, A., & Onetti, A. (2004). *Subsidiaries within a high-tech MNC: A reappraisal of the role of functions* (Economics and Quantitative Methods Working Paper qf04011). Department of Economics, University of Insubria.

PDF: one search summary gave https://www.eco.uninsubria.it/RePEc/pdf/QF2004_21.pdf. This filename does not match the RePEc handle qf04011 (which would suggest QF2004_11), so the link is unconfirmed. Download was blocked.

Discrepancies: the author, title, year and outlet in the current record are all wrong. The key should become `cocito2004subsidiaries`. This is a non-peer-reviewed working paper. Substantively it is close to the project's construct (subsidiary role varies by function), so it may be worth keeping as a supporting citation once checked.

## 9. prahalad1987multinational

Queries:
- `"The Multinational Mission" Prahalad Doz Free Press 1987 ISBN 0029250501`
- `"The multinational mission" Prahalad Doz openlibrary OR "Library of Congress" LCCN 1987 Free Press Collier Macmillan 290 p.`
- `The Multinational Mission Balancing Local Demands and Global Vision Prahalad Doz 1987` (restricted to openlibrary, archive.org, simonandschuster, LoC, HathiTrust, WorldCat)

Evidence:
- WorldCat record https://search.worldcat.org/title/The-multinational-mission-:-balancing-local-demands-and-global-vision/oclc/15660416 (OCLC 15660416; library catalogue, accepted).
- Open Library https://openlibrary.org/books/OL2383205M/The_multinational_mission and Internet Archive https://archive.org/details/multinationalmis0000prah. Per search summary: Free Press, New York, and Collier Macmillan, London, 1987, 290 p., bibliography and index, ISBN 0029250501.
- Simon & Schuster page https://www.simonandschuster.com/books/The-Multinational-Mission/C-K-Prahalad/9780684871325 (publisher; a later printing with ISBN 9780684871325).
- Amazon and AbeBooks listings for ISBN 9780029250501 (bookseller, supporting only).

Outcome: **verified**.

Confirmed details: Prahalad, C. K., & Doz, Y. L. (1987). *The multinational mission: Balancing local demands and global vision*. Free Press. (New York: Free Press; London: Collier Macmillan; 290 pp.; ISBN 0-02-925050-1.)

PDF: none open.

Discrepancies: none. The ISBN 9780029250501 noted at Stage 1 is consistent with the catalogue and bookseller records.

## 10. reus2004interpartner

Queries:
- `"Interpartner, parent, and environmental factors influencing the operation of international joint ventures" Reus Ritchie Management International Review`
- `Inter-partner, parent, and environmental factors influencing the operation of international joint ventures: 15 years of research` (restricted to pure.eur.nl, repub.eur.nl, jstor.org, link.springer.com)
- `Reus Ritchie 2004 "Management International Review" 44 "369" international joint ventures 15 years of research jstor`
- `jstor Management International Review Vol. 44 No. 4 2004 "15 Years of Research" Reus` (restricted to jstor.org)
- `"Interpartner, Parent, and Environmental Factors Influencing the Operation of International Joint Ventures: 15 Years of Research"`
- `"Reus" "Ritchie" "Management International Review" 2004 "44(4)" "369-395"`
- `Reus Ritchie Interpartner parent environmental factors international joint ventures 15 years research` (restricted to jstor, econbiz, RePEc, ProQuest)

Evidence:
- Erasmus University Rotterdam research portal (Pure) https://pure.eur.nl/en/publications/inter-partner-parent-and-environmental-factors-influencing-the-op/, "Inter-partner, parent, and environmental factors influencing the operation of international joint ventures: 15 years of research". Per search summary: Taco Reus and W. J. Ritchie, 2004, *Management International Review*, volume 44, issue 4, **pages 1-25**. (University repository record, accepted.)
- Citing references (supporting only): Reus, T. H., & Ritchie, W. J. III (2004), MIR 44(4), **369-395**. The citing reference in 10.1002/smj.784 gives first page 369.
- MIR is on JSTOR for 1990-2017 (https://www.jstor.org/journal/mirmanaintrev), but no article page came up.

Outcome: **partly verified**. Authors, title, journal, year, volume and issue are confirmed by the repository record. The page range is in conflict. The Pure "1-25" looks like a repository default or manuscript pagination, and 369-395 is supported only by citing sources.

Confirmed details: Reus, T. H., & Ritchie, W. J., III. (2004). Interpartner, parent, and environmental factors influencing the operation of international joint ventures: 15 years of research. *Management International Review, 44*(4), [369-395 per citing sources; confirm].

PDF: none open.

Discrepancies: the co-author Ritchie is missing, and so are the volume, issue and pages. The title spelling differs: "Inter-partner" in Pure, "Interpartner" in the current record and in citing sources. Use the spelling printed in the journal once seen.

PI action: confirm the pages on JSTOR.

## 11. schaan1983parent

Queries:
- `Schaan 1983 dissertation University of Western Ontario "joint venture" Mexico Digitized Theses`
- `Parent Control And Joint Venture Success: The Case Of Mexico Schaan` (restricted to uwo.scholaris.ca, ir.lib.uwo.ca, Library and Archives Canada)
- `Schaan "Joint venture control: the case of Mexico" 1983 OR 1985 dissertation`
- `Schaan Jean-Louis 1983 PhD Western Ontario "Parent control and joint venture success" Digitized Theses 1252` (restricted to Western repositories)

Evidence:
- Scholarship@Western, Digitized Theses no. 1252: https://ir.lib.uwo.ca/digitizedtheses/1252/, "Parent Control And Joint Venture Success: The Case Of Mexico".
- Western University's Open Repository (current platform): https://uwo.scholaris.ca/items/bac4c38e-c1fb-40a4-a7a3-ec246affa01b. Per search summary: Schaan, Jean-louis Francois, 1983, University of Western Ontario. The abstract describes ten joint ventures in Mexico (five petrochemical, two hotel management, one each in aluminum, telecommunications, food products and construction). (University repository, accepted.)

Outcome: **verified**. The variant title "Joint venture control: The case of Mexico" (cited in 10.1177/1069031x9300100203) appears in no catalogue and is a citing error.

Confirmed details: Schaan, J.-L. (1983). *Parent control and joint venture success: The case of Mexico* [Doctoral dissertation, University of Western Ontario]. Digitized Theses 1252. https://ir.lib.uwo.ca/digitizedtheses/1252/

PDF: Western's digitized theses are normally open, with the full text attached to the repository item above, but this was not confirmed because download was blocked. URL recorded.

Discrepancies: none in the title. Add the repository number and URL. The full name in the record is "Jean-louis Francois Schaan".

## 12. nohria1997differentiated

Queries:
- `"The Differentiated Network" Nohria Ghoshal Jossey-Bass 1997 ISBN 0787903310 catalog`
- `The Differentiated Network Organizing Multinational Corporations for Value Creation Nohria Ghoshal` (restricted to wiley.com, hbs.edu, archive.org, openlibrary.org)
- `The Differentiated Network Nohria Ghoshal 1997 San Francisco Jossey-Bass` (restricted to WorldCat, HBS, Wiley)
- `wiley.com The Differentiated Network Organizing Multinational Corporations for Value Creation 9780787903312` (restricted to wiley.com)

Evidence:
- Wiley product page (Jossey-Bass is a Wiley imprint) https://www.wiley.com/en-us/The+Differentiated+Network%3A+Organizing+Multinational+Corporations+for+Value+Creation-p-9780787903312. Per search summary: Nitin Nohria and Sumantra Ghoshal, Jossey-Bass, February 1997, 272 pages, hardcover, ISBN 978-0-787-90331-2. (Publisher catalogue, accepted.)
- HBS faculty page https://www.hbs.edu/faculty/Pages/item.aspx?num=214. The result title shows a garbled subtitle ("Organizations Knowledge Flows in Multinational Corporations"), so do not use it for the title.
- Blackwell's and AbeBooks listings (bookseller, supporting only; Blackwell's gives 253 pages).

Outcome: **verified** (this replaces the Crossref book-review evidence accepted earlier).

Confirmed details: Nohria, N., & Ghoshal, S. (1997). *The differentiated network: Organizing multinational corporations for value creation*. Jossey-Bass. (San Francisco; ISBN 978-0-7879-0331-2.)

PDF: none.

Discrepancies: none with the record in `references.bib` as described. The page count differs between sources (272 at Wiley, 253 at Blackwell's) but is not needed for APA.

## 13. bartlett1989managing

Queries:
- `"Managing Across Borders" "The Transnational Solution" Bartlett Ghoshal 1989 Harvard Business School Press ISBN 0875842089`
- `Managing Across Borders The Transnational Solution Bartlett Ghoshal 1989 Harvard Business School Press` (restricted to hbs.edu, hbsp, archive.org, openlibrary.org, LoC, HOLLIS)
- `Managing across borders the transnational solution Bartlett Ghoshal` (restricted to WorldCat)
- `hbs.edu faculty item 32 Managing Across Borders The Transnational Solution Boston Harvard Business School Press 1989` (restricted to hbs.edu)

Evidence:
- HBS faculty page https://www.hbs.edu/faculty/Pages/item.aspx?num=32, "Managing Across Borders: The Transnational Solution - Book". Per search summary: C. A. Bartlett and S. Ghoshal, Harvard Business School Press, 1989. HBS Press is the publisher, and this is its parent institution's record.
- Internet Archive https://archive.org/details/managingacrossbo00chri ("Managing across borders : the transnational solution : Bartlett, Christopher A., 1943-") and Open Library https://openlibrary.org/books/OL2184040M/Managing_across_borders (library repository records).
- WorldCat https://www.worldcat.org/title/managing-across-borders-the-transnational-solution/oclc/23463959 and OCLC 44958601 (the latter is the 1998 2nd edition eBook). The edition behind OCLC 23463959 could not be seen.
- Bookseller listings for the UK edition (Hutchinson/Random House Business, ISBN 0091742552), supporting only.

Outcome: **verified** (replaces the Crossref book-review evidence).

Confirmed details: Bartlett, C. A., & Ghoshal, S. (1989). *Managing across borders: The transnational solution*. Harvard Business School Press. (Boston.)

PDF: none.

Discrepancies: none. The ISBN given in the query (0875842089) was not confirmed by any record. Do not add an ISBN unless one is read off a catalogue record.

## 14. lawrence1967organization

Queries:
- `Lawrence Lorsch 1967 "Organization and Environment: Managing Differentiation and Integration" Division of Research Graduate School of Business Administration Harvard University catalog`
- `Organization and Environment Managing Differentiation and Integration Lawrence Lorsch 1967` (restricted to hbs.edu, archive.org, openlibrary.org, HathiTrust, LoC)
- `hbs.edu Organization and Environment Lawrence Lorsch book Division of Research 1967` (restricted to hbs.edu and library.strathmore.edu)

Evidence:
- Strathmore University Library catalogue https://library.strathmore.edu/Record/21530, "Organization and environment : managing differentiation and integration". Per search summary: Paul R. Lawrence and Jay William Lorsch; Boston: Division of Research, Graduate School of Business Administration, Harvard University, 1967; xv, 279 p., illustrations. (University library catalogue, accepted.)
- HBS faculty page https://www.hbs.edu/faculty/Pages/item.aspx?num=7917. Per search summary: Harvard Business School, Division of Research, 1967, reissued as a Harvard Business School Classic in 1986.
- Open Library https://openlibrary.org/books/OL2548461M/Organization_and_environment (supporting).

Outcome: **verified** (replaces the Crossref book-review evidence).

Confirmed details: Lawrence, P. R., & Lorsch, J. W. (1967). *Organization and environment: Managing differentiation and integration*. Division of Research, Graduate School of Business Administration, Harvard University. (Boston; xv + 279 pp.)

PDF: none.

Discrepancies: none. The 1986 HBS Press reissue should not be mixed up with the 1967 original.

## 15. doz1990control (original of doz2017control)

Queries:
- `"Control, change, and flexibility: the dilemma of transnational collaboration" Doz Prahalad Hamel 1990 "Managing the Global Firm" Bartlett Doz Hedlund pages`
- `"Managing the global firm" Bartlett Doz Hedlund 1990 Routledge ISBN contents`
- `Managing the global firm 1990 Routledge London New York Bartlett Doz Hedlund catalog record ISBN 0415037115` (restricted to archive.org, openlibrary, LoC, WorldCat, HathiTrust, routledge.com)
- `Managing the global firm Bartlett Doz Hedlund 1990` (restricted to WorldCat; no hit)
- `archive.org managingglobalfi0000unse Managing the global firm 1990 London Routledge edited Bartlett Doz Hedlund`
- `Doz Prahalad Hamel "Control, change and flexibility" 1990 "pp. 117"`
- `"Managing the Global Firm" Doz Prahalad Hamel "117-143" OR "117–143" OR "117-44" OR "127-153"`
- `Yves Doz CV INSEAD "Control, Change and Flexibility" "Managing the Global Firm" 1990 pp.` (restricted to insead.edu)
- Crossref API: `works/10.4324/9780203077948`, `-13`, `-14`, `-15`

Evidence:
- Internet Archive https://archive.org/details/managingglobalfi0000unse, "Managing the global firm". Per search summary: London and New York, Routledge, 1990; editors Christopher A. Bartlett, Yves L. Doz, Gunnar Hedlund; 363 p., bibliography and index. (Library repository record.)
- Routledge catalogue page for the Routledge Library Editions reissue https://www.routledge.com/Managing-the-Global-Firm-RLE-International-Business/Bartlett-Doz-Hedlund/p/book/9780415751933. Per search summary, the table of contents in Part 2, "Management of Multinational Processes and Systems", lists "Control, Change and Flexibility: The Dilemma of Transnational Collaboration" by Yves Doz, C K Prahalad and Gary Hamel. The book is described as first published 1990. (Publisher catalogue.)
- Crossref (direct query): the 2013 RLE reissue 10.4324/9780203077948 (editors Bartlett, Doz, Hedlund; ISBN 9781135134921). Chapter 10.4324/9780203077948-14, "Control, change, and flexibility: the dilemma of transnational collaboration: Yves Doz, C. K. Prahalad, and Gary Hamel", pp. 127-153. The next chapter (Lorange & Probst) is at 154-173. The Taylor & Francis page is https://www.taylorfrancis.com/chapters/mono/10.4324/9780203077948-14/.
- The same chapter is also at 10.4324/9781315199689-24, in the 2017 Routledge anthology that holds `doz2017control` and `prahalad2017approach`.
- INSEAD CV of Yves Doz https://sites.insead.edu/facultyresearch/faculty/cv.cfm?cid=330 lists the chapter in Bartlett, Doz & Hedlund (Eds.), *Managing the Global Firm* (author's CV, supporting only; the summary did not give pages).
- Citing sources only: "Routledge, London, 1990, pp. 117-143".
- ISBN 0415037115 for the 1990 edition: bookseller listings only (Amazon.de).

Outcome: **partly verified**. The chapter title, authors, editors, book title, publisher and 1990 year are confirmed. The 1990 pagination is **not confirmed**. Citing sources give 117-143, while the 2013 reissue's Crossref record gives 127-153. The two ranges have the same length (27 pages), which is consistent with a 10-page front-matter offset in the e-book pagination, but that is an inference and not evidence.

Confirmed details: Doz, Y., Prahalad, C. K., & Hamel, G. (1990). Control, change, and flexibility: The dilemma of transnational collaboration. In C. A. Bartlett, Y. Doz, & G. Hedlund (Eds.), *Managing the global firm* (pp. [117-143, confirm]). Routledge.

PDF: none open.

PI action: check the 1990 pages from a library copy. Alternatively, cite the 2013 reissue with its DOI and pages 127-153, which are fully verifiable.

## 16. prahalad1981approach (original of prahalad2017approach)

Queries:
- `"An approach to strategic control in MNCs" Prahalad Doz Sloan Management Review 1981`
- `An Approach to Strategic Control in MNCs Prahalad Doz` (restricted to sloanreview.mit.edu, shop.sloanreview, proquest.com, sites.insead.edu)
- `sloanreview.mit.edu "approach to strategic control" multinational Prahalad Doz 1981 summer` (restricted to SMR; no article page found)
- `Prahalad Doz An Approach to Strategic Control in MNCs Sloan Management Review 22 4 Summer 1981 5` (restricted to proquest.com)

Evidence:
- ProQuest record https://www.proquest.com/scholarly-journals/approach-strategic-control-mncs/docview/1302987602/se-2 and open-view page https://www.proquest.com/openview/0adfa7d0277008c41ec35f5873bcbdd2/1.pdf. Per search summary: "An Approach to Strategic Control in MNCs", Prahalad, C K; Doz, Yves L, *Sloan Management Review*, Vol. 22, Iss. 4 (Summer 1981): 5. (Source database record, the same kind of evidence as for item 4.)
- No MIT SMR page for the 1981 article came up.
- Citing references (supporting only): pp. 5-13.

Outcome: **verified** for authors, title, journal, volume, issue, season, year and first page. The last page (13) rests on citing references only.

Confirmed details: Prahalad, C. K., & Doz, Y. L. (1981). An approach to strategic control in MNCs. *Sloan Management Review, 22*(4), 5-[13, confirm].

PDF: the ProQuest open-view link is a preview, not open full text.

Discrepancies with `prahalad2017approach`: the 2017 Routledge anthology reprint has no editors in Crossref. The 1981 SMR original is now confirmed and is the version to cite if the item moves out of unsure.

---

## Summary table

| Key | Outcome | Best evidence URL |
|---|---|---|
| andersson2018integration | partly verified (authors Andersson & Forsgren confirmed; 2018 reissue pp. 369-391 verified; 2002 Ashgate pages unconfirmed) | https://www.routledge.com/Global-Competition-and-Local-Networks/McNaughton-Green/p/book/9781315196831 and Crossref 10.4324/9781315196831-27 |
| downes2000knowledge | supporting only | https://www.questia.com/library/p4318/journal-of-managerial-issues/i2894914/vol-12-no-2-summer |
| doz1980how | verified (Doz & Prahalad, HBR 58(2), March 1980; pages unconfirmed) | https://hbr.org/1980/03/how-mncs-cope-with-host-government-intervention |
| ghoshal1993horses | verified (SMR 34(2), 23-35) | https://sloanreview.mit.edu/article/horses-for-courses-organizational-forms-for-multinational-corporations/ |
| killing1983strategies | verified (Praeger, New York, 1983; LCCN 83013923), if the Internet Archive record is accepted | https://archive.org/details/strategiesforjoi0000kill_t8v6 |
| mohedanosuanescontrol | verified (Mohedano-Suanes & Safón 2021, IJB 26(4); pages to confirm) | https://ijb.cyut.edu.tw/var/file/10/1010/img/838/V26N4-2.pdf |
| nguyen2009foreign | nothing found | none |
| oostenfunctions | identified and verified as Cocito, Gatta, Majocchi & Onetti (2004), Insubria WP qf04011 | https://ideas.repec.org/p/ins/quaeco/qf04011.html |
| prahalad1987multinational | verified | https://search.worldcat.org/title/The-multinational-mission-:-balancing-local-demands-and-global-vision/oclc/15660416 |
| reus2004interpartner | partly verified (Reus & Ritchie, MIR 44(4); pages conflict 1-25 vs 369-395) | https://pure.eur.nl/en/publications/inter-partner-parent-and-environmental-factors-influencing-the-op/ |
| schaan1983parent | verified ("Parent control and joint venture success: The case of Mexico") | https://ir.lib.uwo.ca/digitizedtheses/1252/ |
| nohria1997differentiated | verified | https://www.wiley.com/en-us/The+Differentiated+Network%3A+Organizing+Multinational+Corporations+for+Value+Creation-p-9780787903312 |
| bartlett1989managing | verified | https://www.hbs.edu/faculty/Pages/item.aspx?num=32 |
| lawrence1967organization | verified | https://library.strathmore.edu/Record/21530 |
| doz1990control | partly verified (1990 Routledge chapter confirmed; 1990 pages unconfirmed, 117-143 cited vs 127-153 in 2013 reissue) | https://archive.org/details/managingglobalfi0000unse and https://www.routledge.com/Managing-the-Global-Firm-RLE-International-Business/Bartlett-Doz-Hedlund/p/book/9780415751933 |
| prahalad1981approach | verified (SMR 22(4), first page 5; last page unconfirmed) | https://www.proquest.com/scholarly-journals/approach-strategic-control-mncs/docview/1302987602/se-2 |

No PDFs were downloaded, because every repository host was blocked by the proxy. Open full texts that exist and could be saved by hand: the Mohedano-Suanes & Safón article (IJB PDF above), the Schaan dissertation (Western repository), and probably the Cocito et al. working paper (Insubria; exact PDF URL unconfirmed).

## What the PI must decide or supply

1. Evidence-type rulings: whether the Internet Archive / Open Library records (Killing; supporting for Bartlett, Prahalad 1987, Managing the Global Firm), ProQuest records (Ghoshal & Nohria 1993, Prahalad & Doz 1981), the RePEc series record (Cocito et al. 2004) and the Questia issue listing (Downes & Thomas 2000) count as accepted evidence.
2. A click-through check of each "verified" URL, because the pages were seen only through search results, not opened.
3. Page ranges from a library copy or JSTOR: Reus & Ritchie 2004 (MIR, JSTOR), Downes & Thomas 2000 (JMI, JSTOR), Doz & Prahalad 1980 (HBR), Doz, Prahalad & Hamel 1990 (*Managing the Global Firm*, pp. 117-143?), Prahalad & Doz 1981 (last page), Andersson & Forsgren 2002 (Ashgate edition, pp. 343-365?), Mohedano-Suanes & Safón 2021 (open PDF).
4. Version choices: Andersson & Forsgren (2002 Ashgate original versus the verified 2018 Routledge reissue with DOI), and Doz et al. (1990 original versus the verified 2013 reissue).
5. `nguyen2009foreign`: drop it, or obtain the *International Management Review* 2009 issue through the library.
6. Record corrections for the reference-manager to propose at the gate (this agent changed nothing): add the missing co-authors (Forsgren; Thomas; Prahalad; Nohria; Safón; Ritchie), replace `oostenfunctions` with the Cocito et al. working paper, and change the item types for Andersson & Forsgren (book chapter).
