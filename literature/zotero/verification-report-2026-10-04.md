# Reference verification report, Stage 9, 2026-10-04

Agent: reference-manager. Library: Zotero group 6702272 ("international-alliances"), collection "Stage 1 - Consensus search 2026-10-02 (unverified)". Crossref REST API (api.crossref.org) queried with a descriptive User-Agent and no contact e-mail (none available in the environment). No WebSearch tool was available to this agent; publisher sites, library catalogues, OpenAlex, doi.org, Wikipedia and Google Books (quota 0) were blocked or unusable. Nothing was committed.

## 1. Counts

| Outcome | n |
|---|---|
| Items pulled from Zotero (JSON, 2 pages) | 114 |
| Verified, total | 101 |
| of which Crossref, DOI resolved (title, first author, year agree) | 93 |
| of which Crossref, strict bibliographic search, no DOI in Zotero | 5 |
| of which Crossref-registered book-review record stating author, publisher and year (books) | 3 |
| of which WebSearch | 0 (tool not available) |
| Failed verification (tagged `verification-failed`, in `references-unverified.bib`) | 13 (include 6, seed 3, unsure 4) |
| Verified but screened unsure (kept out of the .bib until gate 1) | 15 |
| Verified include/seed held out of the .bib pending a metadata correction or version decision | 4 |
| Entries written to `literature/references.bib` | 82 (include 58, seed 24) |

Check: 101 verified + 13 failed = 114. 86 verified include/seed = 82 in the .bib + 4 held.

Zotero changes made (PATCH with If-Unmodified-Since-Version, all 114 returned 204; re-pulled afterwards and checked that no title, creator, date, DOI or other metadata field changed):

- Verified items: tag `unverified` removed; tags `verified` and `verified:2026-10-04` added; `citationKey` field set; Extra gained `Citation Key: <key>` and `Verified: 2026-10-04 crossref <evidence>` (book-review cases read `crossref (book-review record) <evidence>`).
- Failed items: tag `verification-failed` added, `unverified` kept, Extra gained `Verification failed: 2026-10-04 <reason>`. No citation key pinned. No item deleted.

Method notes the PI should know about. (a) For the 93 DOI items the Zotero metadata had itself been filled from Crossref at import, so agreement on title, author and year is expected; the substantive check is that each DOI resolves to the same work and that the import matched the right work (compared against `literature/search/screening.csv`). (b) Three seed books were accepted on Crossref-registered book reviews whose registered title states authors, publisher, place, year (and, for Nohria and Ghoshal, the ISBN). This is not a WebSearch publisher or library record as the brief specified; if the PI does not accept it, revert those three to failed (`bartlett1989managing`, `lawrence1967organization`, `nohria1997differentiated`). (c) Two strict-search matches needed judgment and are flagged in section 4: `birkinshaw1998corporate` (Crossref stores the main title only, so similarity was computed on the main title) and `nguyen2009parent` (the depositor inverted given and family names; matched on the surname token). (d) `gong2003subsidiary`: the Crossref record (JSTOR deposit) has no author list; first author Gong was confirmed from the publisher-asserted reference to DOI 10.2307/30040664 in Gaur et al. 2022 (10.1057/s41267-021-00498-z).

## 2. Citation keys

Convention applied: first-author surname in lowercase ASCII (spaces, hyphens and diacritics removed) + year from the Zotero date + first title word not in {a, an, the, on, of, in, for, and, to, at, by, with}, punctuation removed. No collisions occurred, so no a/b suffixes were needed. Keys are pinned only for verified items. Keys for failed items appear in `references-unverified.bib` but are not pinned.

| Key | Zotero | Screen | Status | Source | In .bib | First author, year, title |
|---|---|---|---|---|---|---|
| `adarkwah2024geopolitical` | 9H87RCJN | include | verified | crossref | yes | Adarkwah 2024, Geopolitical volatility and subsidiary investments |
| `aliasghar2023adjustment` | P6NKC3ZX | unsure | verified | crossref | no | Aliasghar 2023, Adjustment strategies for firms affected by international sanctions |
| `andersson2018integration` | NZTX3AZ7 | unsure | FAILED |  | no | Andersson 2018, Integration in the Multinational Corporation : The problem of Subsidia... |
| `atanassova2026sociopolitical` | JRJ96A97 | unsure | verified | crossref | no | Atanassova 2026, Sociopolitical shocks and global value chains transformation: insights... |
| `babina2023firm` | 88QXZTG6 | include | verified | crossref | yes | Babina 2023, Firm Investments in Artificial Intelligence Technologies and Changes i... |
| `barden2005influence` | T5VD822M | include | verified | crossref | yes | Barden 2005, The influence of parent control structure on parent conflict in Vietna... |
| `bartlett1989managing` | AJCDXEJ2 | seed | verified | crossref-review | yes | Bartlett 1989, Managing Across Borders: The Transnational Solution |
| `beamish1993characteristics` | KKHXPMW6 | include | verified | crossref | yes | Beamish 1993, The Characteristics of Joint Ventures in the People's Republic of Chin... |
| `belderbos2005determinants` | KBGMTE85 | include | verified | crossref | yes | Belderbos 2005, The determinants of expatriate staffing by Japanese multinationals in ... |
| `birkinshaw1995configurations` | T69RD6M4 | include | verified | crossref | yes | Birkinshaw 1995, Configurations of Strategy and Structure in Subsidiaries of Multinatio... |
| `birkinshaw1996how` | NAUSJNEE | include | verified | crossref | yes | Birkinshaw 1996, How Multinational Subsidiary Mandates are Gained and Lost |
| `birkinshaw1998building` | 5J2TCKFR | include | verified | crossref | yes | Birkinshaw 1998, Building firm-specific advantages in multinational corporations: the r... |
| `birkinshaw1998corporate` | DM4CTNIE | include | verified | crossref | yes | Birkinshaw 1998, Corporate entrepreneurship in network organizations: How subsidiary in... |
| `birkinshaw1998multinational` | SSNE7QZC | seed | verified | crossref | yes | Birkinshaw 1998, Multinational Subsidiary Evolution: Capability and Charter Change in F... |
| `birkinshaw2005subsidiary` | 35EG9AVG | unsure | verified | crossref | no | Birkinshaw 2005, Subsidiary entrepreneurship, internal and external competitive forces,... |
| `birkinshaw2009strategy` | KSPCJSEW | include | verified | crossref | yes | Birkinshaw 2009, Strategy and Management In MNE Subsidiaries |
| `bouquet2008managing` | CHMN62P9 | unsure | verified | crossref | no | Bouquet 2008, Managing Power in the Multinational Corporation: How Low-Power Actors ... |
| `breithaupt2024linked` | JPMH5KM5 | include | verified | crossref | yes | Breithaupt 2024, Linked Employer–Employee Data from XING and the Mannheim Enterprise Pa... |
| `brock2007global` | JWIBN2WD | include | verified | crossref | yes | Brock 2007, Global integration and local responsiveness in multinational subsidiar... |
| `buckley2024internalization` | MWHU9GFA | include | verified | crossref | yes | Buckley 2024, An internalization perspective on subsidiaries’ reputation and its imp... |
| `chen2009parent` | RZVX8HJ3 | include | verified | crossref | yes | Chen 2009, Parent contribution and organizational control in international joint ... |
| `chen2020global` | T6GHCT2C | unsure | verified | crossref | no | Chen 2020, Global Integration or Local Responsiveness? Insights from the Case of ... |
| `chiao2013network` | WZ2W8PFG | include | verified | crossref | yes | Chiao 2013, Network effect and subsidiary autonomy in multinational corporations: ... |
| `choi2004split` | DW84ZTPV | include | verified | crossref | yes | Choi 2004, Split management control and international joint venture performance |
| `chung2010trap` | 4W4DC8XQ | unsure | verified | crossref | no | Chung 2010, The Trap of Continual Ownership Change in International Equity Joint V... |
| `chung2024exploring` | XP364SFX | include | verified | crossref | yes | Chung 2024, Exploring the configuration of international HRM strategies for global... |
| `collings2009global` | JNJRZRDG | unsure | verified | crossref | no | Collings 2009, Global staffing |
| `cubrich2021examining` | V54G9EJS | unsure | verified | crossref | no | Cubrich 2021, Examining the criterion-related validity evidence of LinkedIn profile ... |
| `davies2023improving` | 5P8G9E2D | include | verified | crossref | yes | Davies 2023, Improving subsidiary performance via inpatriate assignments: The role ... |
| `delios2000expatriate` | 4ID6739F | include | verified | crossref | yes | Delios 2000, Expatriate staffing in foreign subsidiaries of Japanese multinational ... |
| `downes2000knowledge` | UUDXK2UH | include | FAILED |  | no | Downes 2000, Knowledge Transfer through Expatriation: The U-Curve Approach to Overs... |
| `doz1980how` | CICN2KGP | unsure | FAILED |  | no | Doz 1980, How MNCs cope with host-government intervention |
| `doz1981global` | GF77XXJB | include | verified | crossref | yes | Doz 1981, Global Competitive Pressures and Host Country Demands Managing Tension... |
| `doz1984patterns` | F8AU9QG2 | include | verified | crossref | yes | Doz 1984, Patterns of Strategic Control Within Multinational Corporations |
| `doz1991managing` | E9NIE5FT | seed | verified | crossref | yes | Doz 1991, Managing DMNCs: A search for a new paradigm |
| `doz2017control` | 8V3G25M2 | include | verified | crossref | held | Doz 2017, Control, change, and flexibility: the dilemma of transnational collabo... |
| `edstrom1977transfer` | PSWKH2H5 | seed | verified | crossref | yes | Edstrom 1977, Transfer of Managers as a Coordination and Control Strategy in Multina... |
| `fang2009multinational` | PBT7ZJ6A | include | verified | crossref | yes | Fang 2009, Multinational Firm Knowledge, Use of Expatriates, and Foreign Subsidia... |
| `gaur2007institutional` | DZP5SF6I | seed | verified | crossref | yes | Gaur 2007, Institutional Environments, Staffing Strategies, and Subsidiary Perfor... |
| `gaur2022societal` | K369ZI68 | include | verified | crossref | yes | Gaur 2022, Societal trust, formal institutions, and foreign subsidiary staffing |
| `geringer1989control` | 8WT9UWV4 | seed | verified | crossref | yes | Geringer 1989, Control and Performance of International Joint Ventures |
| `ghoshal1988creation` | IMZMEXQ6 | include | verified | crossref | yes | Ghoshal 1988, Creation, Adoption and Diffusion of Innovations by Subsidiaries of Mul... |
| `ghoshal1989internal` | AJ4SZ3QT | seed | verified | crossref | yes | Ghoshal 1989, Internal differentiation within multinational corporations |
| `ghoshal1990multinational` | 4AIGS3ZI | include | verified | crossref | yes | Ghoshal 1990, The Multinational Corporation as an Interorganizational Network |
| `ghoshal1993horses` | 3APPWAA7 | include | FAILED |  | no | Ghoshal 1993, Horses for Courses: Organizational Forms for Multinational Corporation... |
| `gong2003subsidiary` | JFNH8JXV | seed | verified | crossref | yes | Gong 2003, Subsidiary Staffing in Multinational Enterprises: Agency, Resources, a... |
| `gregoire2024mobilizing` | 9RI8EQ6K | unsure | verified | crossref | no | Grégoire 2024, Mobilizing New Sources of Data: Opportunities and Recommendations |
| `gupta1994organizing` | AZ3AMHX2 | include | verified | crossref | yes | Gupta 1994, Organizing for knowledge flows within MNCs |
| `han2019management` | SEU9JU2A | include | verified | crossref | yes | Han 2019, Management Control in International Joint Ventures in the Infrastructu... |
| `harzing2001bears` | T6ISFZ6K | seed | verified | crossref | yes | Harzing 2001, Of bears, bumble-bees, and spiders: the role of expatriates in control... |
| `harzing2001whos` | 9CQ4TDZJ | include | verified | crossref | yes | Harzing 2001, Who's in Charge? An Empirical Study of Executive Staffing Practices in... |
| `harzing2015bridging` | QQ66GH9A | include | verified | crossref | yes | Harzing 2015, The Bridging Role of Expatriates and Inpatriates in Knowledge Transfer... |
| `heiss2024structure` | PA7CMRVE | include | verified | crossref | yes | Heiss 2024, Structure, Personality and Employee Turnover: How Hierarchies Repel an... |
| `henisz2000institutional` | Z68UC5ED | seed | verified | crossref | yes | Henisz 2000, The institutional environment for multinational investment |
| `inkpen1997knowledge` | II8Q3D2U | seed | verified | crossref | yes | Inkpen 1997, Knowledge, Bargaining Power, and the Instability of International Join... |
| `kawai2019expatriate` | E2RHTXDV | include | verified | crossref | yes | Kawai 2019, Expatriate utilization, subsidiary knowledge creation and performance:... |
| `killing1983strategies` | 7FMHGKUS | seed | FAILED |  | no | Killing 1983, Strategies for Joint Venture Success |
| `kim2022how` | KZIWKGGH | include | verified | crossref | yes | Kim 2022, How does successive inpatriation contribute to subsidiary capability b... |
| `kostova2002adoption` | UW2MQRIP | seed | verified | crossref | yes | Kostova 2002, ADOPTION OF AN ORGANIZATIONAL PRACTICE BY SUBSIDIARIES OF MULTINATIONA... |
| `lawrence1967organization` | 6MCT8UKD | seed | verified | crossref-review | yes | Lawrence 1967, Organization and Environment: Managing Differentiation and Integration |
| `lee2021cultures` | 9X7W8HE8 | include | verified | crossref | yes | Lee 2021, Cultures and Institutions: Dispositional and contextual explanations f... |
| `lei2025playing` | Z3W2ZJNV | include | verified | crossref | yes | Lei 2025, Playing Hardball: US Entity List Sanctions and Ownership Strategy of C... |
| `lenguyen2008governing` | 4BZN688X | include | verified | crossref | held | Le Nguyen 2008, Governing for Success: The Host Country Uncertainty and the Design of ... |
| `li2017diplomatic` | 2HPPVPN5 | seed | verified | crossref | yes | Li 2017, Diplomatic and corporate networks: Bridges to foreign locations |
| `liu2014metaanalysis` | 2H798AB3 | include | verified | crossref | yes | Liu 2014, A Meta-analysis of Factors Leading to Management Control in Internatio... |
| `liu2020predicting` | 8HWVU4DF | include | verified | crossref | yes | Liu 2020, Predicting Labor Market Competition: Leveraging Interfirm Network and ... |
| `luo2001dual` | 9IUEC3N7 | seed | verified | crossref | yes | Luo 2001, A Dual Parent Perspective on Control and Performance in International ... |
| `luo2021springboard` | XUFD6BUM | unsure | verified | crossref | no | Luo 2021, Springboard MNEs under de-globalization |
| `lyles1996knowledge` | SIC2SDFU | seed | verified | crossref | yes | Lyles 1996, Knowledge Acquisition from Foreign Parents in International Joint Vent... |
| `marchetti2025are` | HSI42DI8 | include | verified | crossref | yes | Marchetti 2025, Are less hierarchical firms organized around stronger cultures? Eviden... |
| `meyer2014local` | IU3K2H7T | include | verified | crossref | yes | Meyer 2014, Local Context and Global Strategy: Extending the Integration Responsiv... |
| `meyer2022mne` | MME5FVKE | seed | verified | crossref | held | Meyer 2022, The MNE and its subsidiaries at times of global disruptions: An intern... |
| `meyer2023international` | AD7HJGRA | include | verified | crossref | yes | Meyer 2023, International business under sanctions |
| `mjoen1997control` | XQPKWCQZ | seed | verified | crossref | yes | Mjoen 1997, Control and Performance in International Joint Ventures |
| `mohedanosuanescontrol` | F5UQTQEU | include | FAILED |  | no | Mohedano-Suanes n.d., Control and Performance in International Joint Ventures. A Model Based... |
| `moura2025how` | IH46K4SN | include | verified | crossref | yes | Moura 2025, How do multinational enterprises respond to geopolitics? A review and ... |
| `nguyen2009foreign` | 5VCMDEXP | include | FAILED |  | no | Nguyen 2009, Foreign Parent Firm Contributions, Experiences, and International Join... |
| `nguyen2009parent` | NWS3NVNJ | include | verified | crossref | held | Nguyen 2009, Parent Control Dynamics and International Joint Venture Performance |
| `nguyen2019control` | KS6Q5B24 | include | verified | crossref | yes | Nguyen 2019, Control, innovation and international joint venture performance: The m... |
| `nohria1994differentiated` | 25V6SJ84 | include | verified | crossref | yes | Nohria 1994, Differentiated fit and shared values: Alternatives for managing headqu... |
| `nohria1997differentiated` | IKZSRF37 | seed | verified | crossref-review | yes | Nohria 1997, The Differentiated Network: Organizing Multinational Corporations for ... |
| `oostenfunctions` | RQ6DD3F8 | unsure | FAILED |  | no | Oosten n.d., of Functions |
| `palmer1993organization` | KQUJBDGW | unsure | FAILED |  | no | Palmer 1993, Organization Theory and the Multinational Corporation |
| `park2009foreign` | K8NEN9IT | include | verified | crossref | yes | Park 2009, Foreign parent control mechanisms and international joint venture perf... |
| `park2019global` | GGZ839WS | unsure | verified | crossref | no | Park 2019, Global labor flow network reveals the hierarchical organization and dy... |
| `patel2019global` | 6S2I54CZ | include | verified | crossref | yes | Patel 2019, Global staffing and control in emerging multinational corporations and... |
| `patsiaouras2026geopolitical` | JMK8HP9M | include | verified | crossref | yes | Patsiaouras 2026, Geopolitical risk and international business: a multi-disciplinary rev... |
| `petricevic2019structural` | R4GVBQQX | seed | verified | crossref | yes | Petricevic 2019, The structural reshaping of globalization: Implications for strategic ... |
| `plabarber2021intermediate` | EB3BTJNS | include | verified | crossref | yes | Pla-Barber 2021, Intermediate units in multinational corporations: A resource dependenc... |
| `prahalad1987multinational` | A8TZXATM | seed | FAILED |  | no | Prahalad 1987, The Multinational Mission: Balancing Local Demands and Global Vision |
| `prahalad2017approach` | 49E3HS6U | unsure | verified | crossref | no | Prahalad 2017, An Approach to Strategic Control in MNCs |
| `pudelko2007countryoforigin` | 39IUDVZ6 | include | verified | crossref | yes | Pudelko 2007, Country‐of‐origin, localization, or dominance effect? An empirical inv... |
| `raziq2021multinational` | D7P5XWPU | include | verified | crossref | yes | Raziq 2021, Multinational Enterprise Organizational Structures and Subsidiary Role... |
| `reus2004interpartner` | RM2XMUC2 | include | FAILED |  | no | Reus 2004, Interpartner, Parent, and Environmental Factors Influencing the Operat... |
| `roth1990empirical` | HNSA8V6J | seed | verified | crossref | yes | Roth 1990, An Empirical Analysis of the Integration-Responsiveness Framework in G... |
| `roth1991global` | MER2WVJM | include | verified | crossref | yes | Roth 1991, Global Strategy Implementation at the Business Unit Level: Operational... |
| `schaan1983parent` | GQAP8MUB | seed | FAILED |  | no | Schaan 1983, Parent Control And Joint Venture Success: The Case Of Mexico |
| `schlegelmilch2022balancing` | KX46549B | unsure | verified | crossref | no | Schlegelmilch 2022, Balancing Global Synergies and Local Responsiveness |
| `sinani2026caught` | ENMFEJRS | include | verified | crossref | yes | Sinani 2026, Caught in the crossfire: Multinational enterprises in the era of geopo... |
| `singh2019subsidiary` | ZVF3SZ2T | include | verified | crossref | yes | Singh 2019, Subsidiary staffing, cultural friction, and subsidiary performance: Ev... |
| `surlemont1998typology` | PGN2FG2Q | include | verified | crossref | yes | Surlemont 1998, A Typology of Centres Within Multinational Corporations: An Empirical ... |
| `tang2026strategic` | EMNMXID5 | include | verified | crossref | yes | Tang 2026, Strategic Divergence and Localized Clustering: MNE Innovation Restruct... |
| `teece2022wideraperture` | ZK9N7IWP | unsure | verified | crossref | no | Teece 2022, A wider‐aperture lens for global strategic management: The multination... |
| `thompson2004empirical` | FAR2F3NV | include | verified | crossref | yes | Thompson 2004, An empirical study of executive nationality staffing practices in fore... |
| `venaik2005dual` | 3SV6W87U | seed | verified | crossref | yes | Venaik 2005, Dual paths to performance: the impact of global pressures on MNC subsi... |
| `verlag2004new` | VRT67DH3 | include | FAILED |  | no | Verlag 2004, A New Perspective on the Integration-Responsiveness Pressures Confront... |
| `wang2026organizational` | 4PI4P4WJ | include | verified | crossref | yes | Wang 2026, Organizational Diversity Database: An Open Data Set on Firm Racial and... |
| `westney2021mncs` | FBGVIHMZ | include | verified | crossref | yes | Westney 2021, MNCs and Cross-Border Strategic Management |
| `witt2019deglobalization` | WGF4M2CD | seed | verified | crossref | yes | Witt 2019, De-globalization: Theories, predictions, and opportunities for interna... |
| `witt2021deglobalization` | NHPERIWH | unsure | verified | crossref | no | Witt 2021, De-globalization and Decoupling: Game Changing Consequences? |
| `witt2023decoupling` | HR22T77W | seed | verified | crossref | yes | Witt 2023, Decoupling in international business: Evidence, drivers, impact, and i... |
| `yan1994bargaining` | UDSFVGB2 | seed | verified | crossref | yes | YAN 1994, BARGAINING POWER, MANAGEMENT CONTROL, AND PERFORMANCE IN UNITED STATES... |
| `yan2001antecedents` | P4JDQQP3 | include | verified | crossref | yes | Yan 2001, Antecedents and Effects of Parent Control in International Joint Ventu... |
| `yan2001negotiating` | 8KC37NG9 | include | verified | crossref | yes | Yan 2001, Negotiating control and achieving performance in international joint v... |

## 3. Items that failed verification

These are in `literature/references-unverified.bib` and must not be cited. "Leads" are details found in reference lists of other Crossref records; they are not verification and are given only to speed up a manual check.

| Key | Screen | Reason | Leads / proposed correction |
|---|---|---|---|
| `andersson2018integration` | unsure | Crossref chapter 10.4324/9781315196831-27 (2018, Routledge reissue) matches title/year but lists no authors; first author Andersson unconfirmed | Crossref chapter 10.4324/9781315196831-27 in Global Competition and Local Networks (Routledge 2018, McNaughton and Green) matches the title but has no authors; 2018 is a reissue date. |
| `downes2000knowledge` | include | no Crossref record (Journal of Managerial Issues not deposited); only citing-reference evidence found | Citing reference in 10.1057/palgrave.jibs.8400135: Downes, M. and Thomas, A.S. (2000), Journal of Managerial Issues 12: 131-149. Zotero lacks the co-author. |
| `doz1980how` | unsure | no Crossref record (Harvard Business Review not deposited); no publisher page reachable; outlet unknown in record | No lead found in Crossref reference lists. Zotero has no outlet and one author. Needs WebSearch. |
| `ghoshal1993horses` | include | no Crossref record (Sloan Management Review not deposited); no publisher/library page reachable in this session | Citing references (10.1002/tie.20035, 10.1002/hrm.1004, 10.1007/978-3-030-90665-8_4) give Ghoshal and Nohria 1993, Sloan Management Review 34(2), first page 23 (last page 35 or 36, sources differ). Zotero lists only Ghoshal. Needs a PDF or a WebSearch run. |
| `killing1983strategies` | seed | book (1983 Praeger edition): no publisher/library record reachable; Crossref has only the 2013 Routledge reissue 10.4324/9780203077757 and a title-only review | Crossref has the 2013 Routledge Library Editions reissue by Killing, 10.4324/9780203077757, and a title-only 1984 review. Either confirm the 1983 Praeger edition (WebSearch or PI copy) or cite the verified reissue with the original date. |
| `mohedanosuanescontrol` | include | no Crossref record, no year or outlet in record; nothing confirms the work | No year, outlet or lead found. Needs the source document. |
| `nguyen2009foreign` | include | no Crossref record for this title; outlet (International Management Review) not confirmable in this session | No lead found. Probably the same author as `nguyen2009parent` (Nguyen Huu Le, University of Vaasa); needs a PDF. |
| `oostenfunctions` | unsure | metadata unusable (truncated title "of Functions", no year, no outlet); no Crossref match | Metadata unusable. Drop unless the Consensus record can be identified. |
| `palmer1993organization` | unsure | record conflates a book review with the book: first author "Palmer" is the 1995 ASQ reviewer (10.2307/2393708); the edited volume is Ghoshal & Westney (Eds.) 1993, Palgrave Macmillan, 10.1007/978-1-349-22557-6 | Replace with the edited volume: Ghoshal, Sumantra and Westney, D. Eleanor (Eds.) 1993, Organization Theory and the Multinational Corporation, Palgrave Macmillan, 10.1007/978-1-349-22557-6 (Crossref book record). Key would become `ghoshal1993organization`. |
| `prahalad1987multinational` | seed | book: no publisher/library/ISBN record reachable in this session; Crossref review 10.1057/jibs.1988.26 carries title only | Crossref has only a title-only review (Roth 1988, JIBS, 10.1057/jibs.1988.26). Stage 1 seed-verification lists an ISBN (9780029250501) from WebSearch, but no URL was logged and this agent could not see a record. Needs a WebSearch run or the PI copy. |
| `reus2004interpartner` | include | no Crossref record (MIR 2004 not deposited); only citing-reference evidence found | Citing reference in 10.1002/smj.784: Reus TH 2004, Management International Review 44, first page 369. Co-authors not shown there. Needs a PDF or a WebSearch run. |
| `schaan1983parent` | seed | doctoral dissertation: no Crossref/DataCite record and no library catalogue reachable in this session; citing references disagree on the title | Three citing references name a University of Western Ontario doctoral dissertation, 1983, but disagree on the title ("Parent control and joint venture success: The case of Mexico" in 10.1016/s1075-4253(01)00049-7 and 10.1061/(asce)me.1943-5479.0000665, the latter adding "Digitized Theses (1252)"; "Joint Venture Control: The Case of Mexico" in 10.1177/1069031x9300100203). Needs the Western repository record. |
| `verlag2004new` | include | author recorded as "Verlag" (publisher name); Crossref shows the work as Venaik, Midgley & Devinney 2004, 10.1007/978-3-322-90999-2_3; correct authors, then re-verify | Work exists on Crossref as Venaik, Sunil; Midgley, David F.; Devinney, Timothy M. (2004), pp. 15-48, in "Management International Review" (Gabler Verlag volume edited by Brock and Birkinshaw), 10.1007/978-3-322-90999-2_3. "Verlag, G." is the publisher. Correct the creators (key becomes `venaik2004new`) and re-run; it would pass. |

## 4. Discrepancies found and proposed metadata corrections

No Zotero metadata was changed. Every correction below needs the PI's approval; once it is approved, the reference-manager can apply it by PATCH and regenerate the .bib.

### 4.1 Verified items held out of `references.bib`

| Key | Problem | Proposed correction |
|---|---|---|
| `meyer2022mne` (seed) | Zotero: Meyer, Klaus E. as sole author, no DOI, no volume or pages. Crossref 10.1002/gsj.1436 lists Meyer, Klaus E. and Li, Chengguang, Global Strategy Journal 12(3), 555-577. | Add co-author Li, Chengguang; DOI; 12(3) 555-577. This settles the Stage 1 flag "co-author unconfirmed": the protocol's "Meyer & Li 2022" is this GSJ paper, not a JIBS paper. PI to confirm it is the intended seed. |
| `nguyen2009parent` (include) | Outlet recorded as "International Journal of Biometrics" (Consensus artefact). Crossref 10.5539/ijbm.v4n4p29: International Journal of Business and Management 4(4). Author recorded as "Nguyen, L."; Crossref "Le, Nguyen Huu" (same depositor inverts "Larimo, Jorma" in 10.5539/ibr.v2n1p3); Springer records the same author as "Le Nguyen, Huu" (`lenguyen2008governing`). | Correct the outlet, volume and issue; add the DOI; adopt one name form for this author across items. If the form is "Le Nguyen, Huu", the key becomes `lenguyen2009parent`. |
| `lenguyen2008governing` (include) | bookTitle holds the series name "Contributions to Management Science". | bookTitle "Strategy and Governance of Networks"; series "Contributions to Management Science"; editors Hendrikse, George; Tuunanen, Mika; Windsperger, Josef; Cliquet, Gerard (Crossref 10.1007/978-3-7908-2058-4); publisher Physica-Verlag. |
| `doz2017control` (include) | 2017 reprint in a Routledge anthology; an earlier original exists (see section 5). | PI decides which version to cite; likely the 1990 chapter. |

### 4.2 Year: online-first date in Zotero versus print-issue year

JIBS references give the year of the issue. Zotero holds the online-first date for these items, so the in-text year and the key would change if the PI adopts the print year. The keys are currently pinned with the Zotero year; I can re-pin them in one pass once the convention is decided.

| Current key | Zotero date | Print issue (Crossref) | Key if corrected |
|---|---|---|---|
| `marchetti2025are` | 2025-10 | 2026, SMJ 47(2) 463-493 | `marchetti2026are` |
| `lee2021cultures` | 2021-04-22 | 2022, Organization Studies 43(4) 497-519 | `lee2022cultures` |
| `li2017diplomatic` | 2017-09-01 | 2018, JIBS 49(6) 659-683 (seed; Stage 1 also gives 2018) | `li2018diplomatic` |
| `breithaupt2024linked` | 2024-10-30 | 2025, Jahrbuecher 245(6) 689-703 | `breithaupt2025linked` |
| `moura2025how` | 2025-04-17 | 2026, IJMR 28(1) e12399 | `moura2026how` |
| `harzing2015bridging` | 2015-01-12 | 2016, HRM 55(4) 679-695 | `harzing2016bridging` |
| `fang2009multinational` | 2009-11-11 | 2010, JMS 47(1) 27-54 | `fang2010multinational` |
| `raziq2021multinational` | 2021-12-14 | 2023, GOM 48(3) 908-952 | `raziq2023multinational` |
| `luo2021springboard` | 2021-04-22 | 2022, JIBS 53(4) 767-780 (unsure, not in .bib) | `luo2022springboard` |

### 4.3 Other corrections (entries are in the .bib as Zotero holds them)

| Key | Discrepancy | Proposed correction |
|---|---|---|
| `brock2007global` | DOI stored with a trailing period, 10.1177/1038411107082278. Both the dotted and the undotted DOI are registered on Crossref with identical metadata. | Use 10.1177/1038411107082278 (resource at Wiley). |
| `park2009foreign` | Crossref holds two DOIs with identical metadata: 10.1504/ijsba.2009.515647 (in Zotero, non-standard pattern) and 10.1504/IJSBA.2009.025350 (standard Inderscience pattern). Pages hold only the start page, 113. | Switch to 10.1504/IJSBA.2009.025350; add the end page from the publisher. |
| `harzing2015bridging` | Third author split wrongly: lastName "Sebastian Reiche", firstName "B.". | Reiche, B. Sebastian. |
| `yan1994bargaining` | Title and surnames in capitals from the JSTOR deposit ("YAN, A.", "GRAY, B."); title ends with a period. | Title case; Yan, Aimin and Gray, Barbara (forms used by Crossref in 10.1016/s1075-4253(01)00049-7, the same authors' 2001 paper); drop the final period. |
| `kostova2002adoption` | Title in capitals with a final period (JSTOR deposit). | Title case, drop the period. |
| `birkinshaw1998corporate` | No DOI, volume or pages in Zotero. | Add 10.1016/s0263-2373(98)00012-7, 16(3), 355-364. |
| `gong2003subsidiary` | No DOI, volume or pages in Zotero. | Add 10.2307/30040664, 46(6), 728-739. |
| collings2009global (unsure) | Zotero: Collings, D. as sole author, no DOI. Crossref 10.1080/09585190902909798: Collings, David G. and Scullion, Hugh, IJHRM 20(6) 1249-1252 (special-issue introduction). | Add the co-author, DOI and pages. |
| `surlemont1998typology` | Chapter without editors. | Editors Birkinshaw, Julian and Hood, Neil (Crossref 10.1007/978-1-349-26467-4). |
| `birkinshaw2009strategy` | Chapter without editors. | Editor Rugman, Alan M. (Crossref 10.1093/oxfordhb/9780199234257.001.0001). |
| `westney2021mncs` | Chapter without editors. | Editors Duhaime, Irene M.; Hitt, Michael A.; Lyles, Marjorie A. (Crossref 10.1093/oso/9780190090883.001.0001 spells "Majorie"). |
| chen2020global (unsure) | bookTitle holds the series name "Understanding China". | bookTitle "China-India Relations", editor Kim, Young-Chan, series Understanding China. |
| schlegelmilch2022balancing (unsure) | bookTitle holds the series name "Management for Professionals". | bookTitle "Global Marketing Strategy", series Management for Professionals. |
| heiss2024structure, lei2025playing, tang2026strategic | Academy of Management Proceedings abstracts typed as journal articles; volume holds the year; no article number. | Add article numbers 14560, 17603, 21345 (Crossref), or retype as conference papers. PI to decide whether proceedings abstracts are citable for JIBS. |
| han2019management, moura2025how, wang2026organizational | No pages; Crossref gives article numbers 04018051, e12399, stsc.2025.0393. wang2026organizational and atanassova2026sociopolitical are online-first without a volume. | Add the article numbers; re-check the volumes before submission. |
| `babina2023firm` | NBER working paper with no report number. | Report number w31325, report type "NBER Working Paper". |
| all 101 items with a url field | The url field holds a consensus.app link with utm_source=claude_desktop. A Better BibTeX export would write it into the .bib, and the CSL may print it. | Clear the url fields or have BBT skip url on export. The .bib written here omits url. |
| teece2022wideraperture, pudelko2007countryoforigin, thompson2004empirical, nohria1994differentiated, harzing2015bridging | Titles and names contain U+2010 hyphens from the Wiley deposits. | Normalize to ASCII hyphens (cosmetic). |

### 4.4 Discrepancies in Stage 1 outputs (to be raised in the gate 1 file, not edited here)

- `barden2005influence`: `screening.csv` (CON-S3-07) gives "H. Steensma et al."; Crossref and Zotero give Barden, Steensma and Lyles. Zotero is correct.
- `li2017diplomatic` and `harzing2015bridging`: the screening sheet gives 2018 and 2016 (print years); Zotero gives 2017 and 2015 (online). See 4.2.
- The Consensus "Southern Medical Journal" collision noted by Stage 1 is resolved for every affected item: all carry Strategic Management Journal in Zotero, confirmed by Crossref.
- AOM DOIs: the Stage 1 log records 10.5465 DOIs for Birkinshaw and Hood 1998, Inkpen and Beamish 1997, and Yan and Gray 1994; Zotero holds the JSTOR 10.2307 DOIs. Crossref resolves each 10.5465 DOI to the 10.2307 record, so they are aliases and no change is needed.

## 5. check-version items

| Key | Screen | Finding | Version to cite |
|---|---|---|---|
| `surlemont1998typology` | include | No journal article with this title on Crossref. Chapter in Birkinshaw and Hood (Eds.), Multinational Corporate Evolution and Subsidiary Development, Palgrave Macmillan 1998, pp. 162-188. | The chapter as held (add editors). In the .bib. |
| `birkinshaw2009strategy` | include | No journal article. An earlier first-edition chapter exists: Birkinshaw, J. (2001), "Strategy and management in MNE subsidiaries", Oxford Handbook of International Business, pp. 380-401, 10.1093/0199241821.003.0014, sole author. The 2009 chapter (2nd ed., with Pedersen, pp. 367-388) is a revised version, not a reprint. | Cite the edition actually read. 2009 is in the .bib; switch only if the 2001 text is used. |
| `doz2017control` | include | Earlier original exists. The chapter appears in Bartlett, Doz and Hedlund (Eds.), Managing the Global Firm, London and New York: Routledge, 1990 (year and publisher stated in the Crossref-registered review by Forsgren 1992, Organization Studies 13(3) 477-480, 10.1177/017084069201300314). The 2013 Routledge Library Editions reissue is on Crossref: 10.4324/9780203077948-14, pp. 127-153. | 1990 original (pagination of the 1990 edition to be confirmed; the 2013 reissue gives 127-153). Held out of the .bib. |
| `prahalad2017approach` | unsure | 2017 Routledge anthology reprint (10.4324/9781315199689, no editors in Crossref). No original on Crossref. Citing references in Raziq et al. 2021 (10.1177/10596011211060952) and Birkinshaw et al. 2005 (10.1016/j.ibusrev.2004.04.010) give Prahalad and Doz (1981), Sloan Management Review 22(4), 5-13. | Probably the 1981 SMR article; this rests on citing references only and needs confirming before any use. Not in the .bib (unsure). |
| `lenguyen2008governing` | include | No journal article. Original chapter in Strategy and Governance of Networks (Physica-Verlag 2008). | The chapter, after the bookTitle correction (4.1). |
| `chen2020global` | unsure | No journal article. Original chapter in Kim (Ed.), China-India Relations (Springer 2020, series Understanding China). | The chapter, after the bookTitle correction. Not in the .bib (unsure). |

## 6. Verified items screened unsure (not in the .bib until the PI decides at gate 1)

- `aliasghar2023adjustment` (P6NKC3ZX): Aliasghar 2023, Adjustment strategies for firms affected by international sanctions
- `atanassova2026sociopolitical` (JRJ96A97): Atanassova 2026, Sociopolitical shocks and global value chains transformation: insights from manufacturing ...
- `birkinshaw2005subsidiary` (35EG9AVG): Birkinshaw 2005, Subsidiary entrepreneurship, internal and external competitive forces, and subsidiary perf...
- `bouquet2008managing` (CHMN62P9): Bouquet 2008, Managing Power in the Multinational Corporation: How Low-Power Actors Gain Influence
- `chen2020global` (T6GHCT2C): Chen 2020, Global Integration or Local Responsiveness? Insights from the Case of Chinese MNEs in Indi...
- `chung2010trap` (4W4DC8XQ): Chung 2010, The Trap of Continual Ownership Change in International Equity Joint Ventures
- `collings2009global` (JNJRZRDG): Collings 2009, Global staffing
- `cubrich2021examining` (V54G9EJS): Cubrich 2021, Examining the criterion-related validity evidence of LinkedIn profile elements in an appli...
- `gregoire2024mobilizing` (9RI8EQ6K): Grégoire 2024, Mobilizing New Sources of Data: Opportunities and Recommendations
- `luo2021springboard` (XUFD6BUM): Luo 2021, Springboard MNEs under de-globalization
- `park2019global` (GGZ839WS): Park 2019, Global labor flow network reveals the hierarchical organization and dynamics of geo-indust...
- `prahalad2017approach` (49E3HS6U): Prahalad 2017, An Approach to Strategic Control in MNCs
- `schlegelmilch2022balancing` (KX46549B): Schlegelmilch 2022, Balancing Global Synergies and Local Responsiveness
- `teece2022wideraperture` (ZK9N7IWP): Teece 2022, A wider‐aperture lens for global strategic management: The multinational enterprise in a b...
- `witt2021deglobalization` (NHPERIWH): Witt 2021, De-globalization and Decoupling: Game Changing Consequences?

## 7. Citation-key scan and citation hygiene

`manuscript/sections/*.qmd` (seven files) hold only the placeholder comment ("status: not drafted"), and `literature/synthesis/` is empty. No `[@key]`, bare key or `[CITE:]` marker was found, so there are no unknown keys; see `manuscript/missing-citations.md`. Without prose, the hygiene checks (alphabetical order inside parentheses, "&" versus "and", page numbers on direct quotes) have nothing to test. The .bib balance of recent and seminal work is 26 entries up to 1999, 34 from 2000 to 2020, and 22 from 2021 to 2026.

## 8. What the PI must do

1. Decide the year convention for online-first articles (4.2). If print year is adopted, approve re-pinning the 9 keys.
2. Approve or edit the corrections in 4.1 and 4.3. On approval, the reference-manager applies them by PATCH, re-verifies, and moves `meyer2022mne`, `nguyen2009parent` and `lenguyen2008governing` into the .bib.
3. Confirm that `meyer2022mne` (Meyer & Li 2022, GSJ) is the intended seed.
4. Choose versions for the check-version items: `doz2017control` versus the 1990 original; the 2009 versus 2001 Birkinshaw chapter; and, if `prahalad2017approach` moves out of unsure, the 1981 SMR original.
5. Accept or reject the use of Crossref-registered book reviews as verification for `bartlett1989managing`, `lawrence1967organization` and `nohria1997differentiated` (1b).
6. For the 13 failed items: supply PDFs, or have the reference-manager rerun in a session where WebSearch is available. Priorities are the three seeds (`prahalad1987multinational`, `killing1983strategies`, `schaan1983parent`) and the six includes (`ghoshal1993horses`, `reus2004interpartner`, `downes2000knowledge`, `nguyen2009foreign`, `mohedanosuanescontrol`, `verlag2004new`). For `verlag2004new` and `palmer1993organization`, approving the corrections in section 3 is enough to make them pass.
7. List the 13 failed items in the gate 1 file (`reviews/`). This agent does not write to `reviews/`.
8. In Zotero, set up the Better BibTeX automatic export to `literature/references.bib` (SKILL.md, step 4) only after the corrections are applied, and exclude the url field. Until then, the .bib written here is the reference-manager's export of the verified, approved subset. A BBT export of the whole group would also include unsure and failed items unless it is limited to items tagged `verified`.
9. Optionally log the date convention and the book-review verification rule in `docs/decisions.md`; this agent does not write there.

## 9. Corrections applied 2026-10-04

The PI approved the following on 2026-10-04 (relayed by the coordinator): the corrections in sections 4.1 and 4.3; the two section 3 corrections (`verlag2004new`, `palmer1993organization`), each followed by re-verification; and print-issue years for the 9 items in 4.2. The coordinator's message also settled the sub-choices: the name form "Le Nguyen, Huu" for this author; Consensus links moved out of `url`; article numbers only for the AOM abstracts; the standard DOI for Park; ASCII hyphens. Sections 1 to 8 above describe the state before these corrections; this section supersedes them where they differ.

How the changes were made. For each item: GET, then PATCH with If-Unmodified-Since-Version, sending only the changed fields. There were 106 PATCH calls (104 for corrections and url clearing, 2 to mark the re-verified items as verified), all returning 204, with no failures and no deletions. Every corrected item carries a line in Extra: `Corrected: 2026-10-04 (PI-approved, Stage 9): <what changed>`. Afterwards I re-pulled the library and checked every verified item: the key computed from the corrected metadata matches the pinned `citationKey` field and the single `Citation Key:` line in Extra, with no key collisions. I re-checked all corrected items with a DOI against Crossref: title, first author and year still agree, and the new print years are the Crossref published-print years.

### 9.1 Counts after corrections

| Outcome | n |
|---|---|
| Verified | 103 (Crossref 100, Crossref book-review record 3) |
| Failed | 11 (include 5, seed 3, unsure 3) |
| Verified, screened unsure (not in the .bib) | 16 |
| Verified include/seed held out | 1 (`doz2017control`) |
| Entries in `literature/references.bib` | 86 (include 61, seed 25) |
| Entries in `literature/references-unverified.bib` | 11 |
| Items with substantive metadata corrections | 38 |
| Items changed only by clearing the Consensus url | 66 |
| Citation keys changed | 12 (2 of them first pins after re-verification) |

### 9.2 Key changes

| Zotero | Old key | New key | Reason |
|---|---|---|---|
| JPMH5KM5 | `breithaupt2024linked` | `breithaupt2025linked` | print-issue year |
| PBT7ZJ6A | `fang2009multinational` | `fang2010multinational` | print-issue year |
| KQUJBDGW | `palmer1993organization` | `ghoshal1993organization` | section 3 correction; re-verified and pinned |
| QQ66GH9A | `harzing2015bridging` | `harzing2016bridging` | print-issue year |
| 9X7W8HE8 | `lee2021cultures` | `lee2022cultures` | print-issue year |
| NWS3NVNJ | `nguyen2009parent` | `lenguyen2009parent` | name form Le Nguyen, Huu |
| 2HPPVPN5 | `li2017diplomatic` | `li2018diplomatic` | print-issue year |
| XUFD6BUM | `luo2021springboard` | `luo2022springboard` | print-issue year |
| HSI42DI8 | `marchetti2025are` | `marchetti2026are` | print-issue year |
| IH46K4SN | `moura2025how` | `moura2026how` | print-issue year |
| D7P5XWPU | `raziq2021multinational` | `raziq2023multinational` | print-issue year |
| VRT67DH3 | `verlag2004new` | `venaik2004new` | section 3 correction; re-verified and pinned |

All changed keys are re-pinned in Zotero. No manuscript or synthesis text uses keys yet, so nothing downstream needed updating.

### 9.3 Changes per item

| Key | Zotero | Change applied |
|---|---|---|
| `babina2023firm` | 88QXZTG6 | 4.3 report number and type |
| `birkinshaw1998corporate` | DM4CTNIE | 4.3 DOI, vol/issue/pages |
| `birkinshaw2009strategy` | KSPCJSEW | 4.3 editor |
| `breithaupt2025linked` | JPMH5KM5 | 4.2 date 2024-10-30 -> 2025 (print issue); key breithaupt2024linked -> breithaupt2025linked |
| `brock2007global` | JWIBN2WD | 4.3 DOI without trailing period |
| `chen2020global` | T6GHCT2C | 4.3 bookTitle, series, editor |
| `collings2009global` | JNJRZRDG | 4.3 co-author, DOI, vol/issue/pages |
| `fang2010multinational` | PBT7ZJ6A | 4.2 date 2009-11-11 -> 2010 (print issue); U+2010 normalized in creator names; key fang2009multinational -> fang2010multinational |
| `ghoshal1993organization` | KQUJBDGW | section 3 replaced by edited volume (editors, publisher, DOI, ISBN) |
| `gong2003subsidiary` | JFNH8JXV | 4.3 DOI, vol/issue/pages |
| `han2019management` | SEU9JU2A | 4.3 article number (in pages) |
| `harzing2001whos` | 9CQ4TDZJ | U+2010 normalized in creator names |
| `harzing2016bridging` | QQ66GH9A | 4.3 third author name split; 4.2 date 2015-01-12 -> 2016 (print issue); U+2010 normalized in creator names; key harzing2015bridging -> harzing2016bridging |
| `heiss2024structure` | PA7CMRVE | 4.3 article number (in pages) |
| `kostova2002adoption` | UW2MQRIP | 4.3 title case, final period |
| `lee2022cultures` | 9X7W8HE8 | 4.2 date 2021-04-22 -> 2022 (print issue); key lee2021cultures -> lee2022cultures |
| `lei2025playing` | Z3W2ZJNV | 4.3 article number (in pages) |
| `lenguyen2008governing` | 4BZN688X | 4.1 bookTitle, series, editors |
| `lenguyen2009parent` | NWS3NVNJ | 4.1 outlet, vol/issue, DOI, author name form; key nguyen2009parent -> lenguyen2009parent |
| `li2018diplomatic` | 2HPPVPN5 | 4.2 date 2017-09-01 -> 2018 (print issue); key li2017diplomatic -> li2018diplomatic |
| `luo2022springboard` | XUFD6BUM | 4.2 date 2021-04-22 -> 2022 (print issue); key luo2021springboard -> luo2022springboard |
| `marchetti2026are` | HSI42DI8 | 4.2 date 2025-10 -> 2026 (print issue); key marchetti2025are -> marchetti2026are |
| `meyer2022mne` | MME5FVKE | 4.1 add co-author, DOI, vol/issue/pages |
| `moura2026how` | IH46K4SN | 4.3 article number (in pages); 4.2 date 2025-04-17 -> 2026 (print issue); key moura2025how -> moura2026how |
| `nguyen2009foreign` | 5VCMDEXP | Extra: likely name form noted |
| `nohria1994differentiated` | 25V6SJ84 | U+2010 normalized in title |
| `park2009foreign` | K8NEN9IT | 4.3 standard DOI (Crossref gives start page only; pages unchanged) |
| `pudelko2007countryoforigin` | 39IUDVZ6 | U+2010 normalized in title; U+2010 normalized in creator names |
| `raziq2023multinational` | D7P5XWPU | 4.2 date 2021-12-14 -> 2023 (print issue); key raziq2021multinational -> raziq2023multinational |
| `schlegelmilch2022balancing` | KX46549B | 4.3 bookTitle, series |
| `surlemont1998typology` | PGN2FG2Q | 4.3 editors |
| `tang2026strategic` | EMNMXID5 | 4.3 article number (in pages) |
| `teece2022wideraperture` | ZK9N7IWP | U+2010 normalized in title |
| `thompson2004empirical` | FAR2F3NV | U+2010 normalized in title |
| `venaik2004new` | VRT67DH3 | section 3 creators corrected (Venaik, Midgley & Devinney) |
| `wang2026organizational` | 4PI4P4WJ | 4.3 article number (in pages) |
| `westney2021mncs` | FBGVIHMZ | 4.3 editors |
| `yan1994bargaining` | UDSFVGB2 | 4.3 title case, author names, final period |
| `ghoshal1993organization`, `venaik2004new` | KQUJBDGW, VRT67DH3 | Re-verified after correction. Tags `unverified` and `verification-failed` removed, `verified` and `verified:2026-10-04` added; key pinned; `Verified:` line added to Extra (the earlier `Verification failed:` line is kept as history). |
| all items with a Consensus link (101) | | `url` cleared. In every case the link already stood in Extra as "Consensus URL: <link>" (inside the screening note), so no duplicate line was added. |

Details of the implementation:
- Article numbers went into `pages`, because the Zotero item schema served by the API has no article-number field. In the .bib they therefore appear as `pages`.
- Dates of the 9 re-dated items hold the print year only; the earlier online-first date is in Extra as `Online first: <date>`.
- `park2009foreign`: Crossref gives only the start page (113), so `pages` is unchanged.
- `lenguyen2008governing`: the editor Cliquet is entered as "Gérard", the form in the Crossref book record.
- `nguyen2009foreign` (failed) is unchanged except for an Extra line: `Likely name form: Le Nguyen, Huu (same author as NWS3NVNJ and 4BZN688X; not confirmed for this item)`.
- `ghoshal1993organization` stays screened unsure, so it is not in the .bib. `venaik2004new` is include and is now in the .bib.

### 9.4 Still open

1. Version to cite for `doz2017control` (held out of the .bib) and the other check-version items (section 5): `birkinshaw2009strategy` versus the 2001 first-edition chapter, and `prahalad2017approach` versus the 1981 SMR original.
2. Whether the Crossref book-review evidence is accepted for `bartlett1989managing`, `lawrence1967organization` and `nohria1997differentiated`. They remain verified and in the .bib, flagged here.
3. The 11 items that still fail (section 3, minus `verlag2004new` and `palmer1993organization`): seeds `prahalad1987multinational`, `killing1983strategies`, `schaan1983parent`; includes `ghoshal1993horses`, `reus2004interpartner`, `downes2000knowledge`, `nguyen2009foreign`, `mohedanosuanescontrol`; unsure `doz1980how`, `andersson2018integration`, `oostenfunctions`.
4. Whether AOM Proceedings abstracts (`heiss2024structure`, `lei2025playing`, `tang2026strategic`) are citable for JIBS. Article numbers were added; the item type was not changed.
5. Not part of the approval, proposed as follow-up: `venaik2004new` has no DOI, volume or pages. Crossref holds it as a chapter (pp. 15-48, 10.1007/978-3-322-90999-2_3) in a Gabler volume titled "Management International Review" (edited by Brock and Birkinshaw), while Zotero types it as a journal article. The PI should decide whether to cite it as an MIR special issue (volume and issue to confirm) or as the Gabler chapter.
6. `wang2026organizational` and `atanassova2026sociopolitical` are online-first without a volume; check again before submission.
7. List the 11 failed items in the gate 1 file (`reviews/`), and note the key changes there if gate 1 materials quote keys.
8. Turn on the Better BibTeX auto-export, limited to items tagged `verified` and screened include or seed, with `doz2017control` excluded until its version is decided.

## 10. Decisions applied 2026-10-04 (versions, book reviews, proceedings)

The PI made three further decisions on 2026-10-04, relayed by the coordinator: (1) cite original works, not reprints or reissues; (2) book reviews do not count as verification evidence, and neither do citing references; (3) Academy of Management Proceedings abstracts can be cited. Each change was applied by GET, then PATCH with If-Unmodified-Since-Version, sending only the fields named below. There were 8 PATCH calls, all returning 204, with no failures and no deletions. This section supersedes sections 1 to 9 where they differ.

### 10.1 Versions (decision 1)

| Key | Zotero | Action |
|---|---|---|
| `doz1990control` (was `doz2017control`) | 8V3G25M2 | Corrected to the 1990 original chapter in Bartlett, Christopher; Doz, Yves; Hedlund, Gunnar (Eds.), Managing the Global Firm, Routledge, 1990. Editor given names follow the Crossref record of the 2013 reissue. Changes: date 2017-10-23 to 1990; bookTitle "International Business" to "Managing the Global Firm"; editors added; the 2017 reprint DOI (10.4324/9781315199689-24), ISBN (9781315199689) and pages (349-375) cleared. Extra now holds `Reissue:` (2013 RLE chapter 10.4324/9780203077948-14, pp. 127-153) and `Reprint:` (the former 2017 data). Key re-pinned as doz1990control. Tags `verified` and `verified:2026-10-04` removed; `verification-failed` and `unverified` added. Reason: "1990 edition details need a catalogue record or PDF". Not in the .bib; listed in `references-unverified.bib`. |
| `prahalad2017approach` | 49E3HS6U | Item unchanged (screened unsure; still verified as the 2017 reprint record). Extra gained a `Version to cite:` line: Prahalad, C. K., & Doz, Y. L. (1981), An approach to strategic control in MNCs, Sloan Management Review, 22(4), 5-13. This rests on citing references only and is unverified. |
| `killing1983strategies` | 7FMHGKUS | Still failed. Extra gained a `Version to cite:` line: the 1983 Praeger edition, not the 2013 Routledge reissue (10.4324/9780203077757). |
| `birkinshaw2009strategy` | KSPCJSEW | No change. The 2009 chapter is a revised second-edition chapter with a new co-author (Pedersen), not a reprint of the 2001 first-edition chapter (Birkinshaw alone, 10.1093/0199241821.003.0014), so it counts as its own work. It stays verified on its DOI and stays in the .bib. |
| `surlemont1998typology`, `lenguyen2008governing`, `chen2020global` | | No change. No earlier version was found (section 5), so these chapters are the originals. |

### 10.2 Book reviews and citing references (decision 2)

Reverted to failed: `nohria1997differentiated` (IKZSRF37), `bartlett1989managing` (AJCDXEJ2), `lawrence1967organization` (6MCT8UKD). For each: tags `verified` and `verified:2026-10-04` removed; `verification-failed` and `unverified` added; Extra gained "Verification failed: 2026-10-04 book-review evidence not accepted; needs catalogue record or PDF". The pinned keys were kept (citationKey field and the `Citation Key:` line). All three were removed from `references.bib` and added to `references-unverified.bib`. The earlier `Verified:` lines stay in Extra as history, followed by the failure line.

Check for other book-review evidence: none. The only other book-type verification, `ghoshal1993organization`, rests on the Crossref book record itself (10.1007/978-1-349-22557-6), not on a review. `doz2017control` had been verified on its 2017 reprint DOI; now that it is the 1990 original, it is failed (10.1).

Check for citing-reference evidence: only `gong2003subsidiary` used one, for its first author. Re-checked against the Crossref DOI record 10.2307/30040664: the title ("Subsidiary staffing in multinational enterprises: Agency, resources, and performance"), journal (Academy of Management Journal), volume 46, issue 6, pages 728-739 and year 2003 all match the Zotero item. It therefore stays verified, on the DOI record alone. The record lists no authors, so first author Gong is not independently verified by Crossref; Extra gained a `Verification basis:` line saying so. No other verification relied on citing references: in section 3 they were used only as leads for failed items.

### 10.3 Proceedings (decision 3)

`heiss2024structure`, `lei2025playing` and `tang2026strategic` remain journal articles in Academy of Management Proceedings, with the article numbers added in section 9 (in `pages`). No further change. They stay in the .bib.

### 10.4 Counts after decisions

| Outcome | n |
|---|---|
| Verified | 99 (all Crossref; no book-review evidence remains) |
| Failed | 15 (include 6, seed 6, unsure 3) |
| Verified, screened unsure (not in the .bib) | 16 |
| Verified include/seed held out | 0 |
| Entries in `literature/references.bib` | 83 (include 61, seed 22) |
| Entries in `literature/references-unverified.bib` | 15 |
| Keys changed in this step | 1 (`doz2017control` to `doz1990control`) |
| Failed items with a pinned key | 4 (`doz1990control`, `nohria1997differentiated`, `bartlett1989managing`, `lawrence1967organization`) |

### 10.5 Still open

1. The 15 failed items: seeds `prahalad1987multinational`, `killing1983strategies`, `schaan1983parent`, `nohria1997differentiated`, `bartlett1989managing`, `lawrence1967organization`; includes `doz1990control`, `ghoshal1993horses`, `reus2004interpartner`, `downes2000knowledge`, `nguyen2009foreign`, `mohedanosuanescontrol`; unsure `doz1980how`, `andersson2018integration`, `oostenfunctions`. A separate agent is searching for PDFs and catalogue records (`literature/zotero/pdf-search-2026-10-04.md`, not touched here). Once evidence arrives, the reference-manager re-verifies these items and moves them into the .bib.
2. `gong2003subsidiary`: first author not independently verified (the DOI record lists no authors). A PDF of the article would close this.
3. `prahalad2017approach` (unsure): if the PI includes it at gate 1, verify the 1981 SMR original first.
4. `venaik2004new`: DOI, volume and pages still missing (section 9.4, item 5).
5. List the failed items in the gate 1 file (`reviews/`).

## 11. Web-search evidence applied 2026-10-04

Source of evidence: `literature/zotero/pdf-search-2026-10-04.md`, written by a separate web-search agent; this agent did not edit it. The PI ruled on 2026-10-04 (relayed by the coordinator) on four points. (1) A web-search result counts as evidence when it comes from an accepted source type and its URL is logged, even though the page was not opened. (2) Internet Archive / Open Library and ProQuest records count as catalogue records, and RePEc counts as a repository record; the Questia listing is supporting only. (3) The record corrections listed below are approved. (4) `nguyen2009foreign` is dropped. Originals are cited throughout; fields that only a reissue confirms are left empty and marked "Pages to confirm" in Extra. This section supersedes sections 1 to 10 where they differ.

How the changes were made. For each item: GET, then PATCH with If-Unmodified-Since-Version. The three type changes (Oosten item to report, Andersson to book chapter, Prahalad to journal article) were done by PUT of the full item built from the new type's template, with the same version check. That is 15 write calls plus 1 trash PATCH, all returning 204, with no failures. The only removal is `nguyen2009foreign`, moved to the trash by PATCH `{"deleted": 1}` (reversible), with the reason noted in Extra first. Each verified item's Extra gained `Verified: 2026-10-04 websearch <source type> <URL> (page not opened)` and a `Corrected: 2026-10-04 (PI decision on web-search evidence): ...` line. Afterwards I re-pulled the library and confirmed that every verified item's pinned key matches the key computed from its metadata, with no collisions.

### 11.1 Per item

| Key (new) | Old key | Zotero | Screen | Outcome | Change applied | Evidence (URL in Extra) |
|---|---|---|---|---|---|---|
| `doz1990control` | same | 8V3G25M2 | include | verified (in .bib) | verified as the 1990 original; pages to confirm | Internet Archive record of the 1990 Routledge book; Routledge RLE catalogue supporting |
| `nohria1997differentiated` | same | IKZSRF37 | seed | verified (in .bib) | re-verified on publisher catalogue (replaces book-review evidence) | Wiley (Jossey-Bass) product page |
| `bartlett1989managing` | same | AJCDXEJ2 | seed | verified (in .bib) | re-verified on publisher institution and catalogue records (replaces book-review evidence) | HBS faculty page (HBS Press); Internet Archive / Open Library supporting |
| `lawrence1967organization` | same | 6MCT8UKD | seed | verified (in .bib) | re-verified on library catalogue (replaces book-review evidence) | Strathmore University Library catalogue |
| `killing1983strategies` | same | 7FMHGKUS | seed | verified (in .bib) | verified as the 1983 Praeger edition | Internet Archive catalogue record (LCCN 83013923) |
| `prahalad1987multinational` | same | A8TZXATM | seed | verified (in .bib) | verified on library catalogue records | WorldCat OCLC 15660416; Open Library / Internet Archive supporting |
| `schaan1983parent` | same | GQAP8MUB | seed | verified (in .bib) | verified on the university repository record | Scholarship@Western, Digitized Theses 1252 |
| `ghoshal1993horses` | same | 3APPWAA7 | include | verified (in .bib) | co-author Nohria added; journal, 34(2), 23-35 added | MIT SMR article page; ProQuest supporting |
| `reus2004interpartner` | same | RM2XMUC2 | include | verified (in .bib) | co-author Ritchie added; volume 44, issue 4 added; pages left empty (conflict) | Erasmus University repository (Pure) |
| `mohedanosuanes2021control` | `mohedanosuanescontrol` | F5UQTQEU | include | verified (in .bib) | co-author Safón added; dated 2021; journal, 26(4), ISSN added; pages left empty | IJB article PDF (journal site) |
| `doz1980how` | same | CICN2KGP | unsure | verified | co-author Prahalad added; journal, 58(2), March 1980 added; pages left empty | HBR article page; OSTI supporting |
| `cocito2004subsidiaries` | `oostenfunctions` | RQ6DD3F8 | unsure | verified | replaced with Cocito, Gatta, Majocchi & Onetti (2004), Insubria WP qf04011 (type journalArticle -> report) | RePEc/IDEAS series record |
| `prahalad1981approach` | `prahalad2017approach` | 49E3HS6U | unsure | verified | replaced by the 1981 Sloan Management Review original (type bookSection -> journalArticle; 22(4), first page 5; reprint DOI, ISBN, book title, publisher cleared) | ProQuest record |
| `andersson2018integration` | same | NZTX3AZ7 | unsure | verified | co-author Forsgren added; made a book chapter (2018 Routledge reissue, eds McNaughton & Green, pp. 369-391, DOI) | Crossref chapter DOI + Routledge catalogue (authors) |
| `downes2000knowledge` | same | UUDXK2UH | include | still unverified | co-author Thomas added; Questia lead noted; stays unverified | Questia issue listing (supporting only) |
| `nguyen2009foreign` | same | 5VCMDEXP | include | dropped (trash) | moved to trash | nothing found |

Notes on the changes:
- **`andersson2018integration`:** the search file found no catalogue record for the 2002 Ashgate original (its pages, 343-365, come from citing references only). Following the PI's instruction, the 2018 Routledge chapter is kept and the reason is noted in Extra. It is verified on the Crossref chapter record (title, 2018, pp. 369-391) plus the Routledge catalogue for the authors, and stays out of the .bib (unsure). The search file graded this item "partly verified" and the PI's list did not name it explicitly; if the PI wants it left unverified, revert the tags only.
- **`prahalad1981approach`:** the item now describes the 1981 SMR original. `pages` holds the first page only ("5") and Extra says "last page to confirm". The former 2017 reprint data is kept in Extra as `Reprint:`. It stays out of the .bib (unsure).
- **`doz1990control`:** now verified and in the .bib, with no pages.
- **`mohedanosuanes2021control`:** pages left empty, because the search file does not mark 20-45 as confirmed (search summary only).
- **`downes2000knowledge`:** co-author Thomas, A. S. added (approved); volume, issue and pages not added. It stays unverified, with the Questia lead in Extra, and is now the only entry in `references-unverified.bib`.
- **`nguyen2009foreign`:** in the Zotero trash, and removed from `references-unverified.bib`. It can be restored from the trash.
- **Fields not changed** (not covered by the approval; proposed only):
  - `doz1980how`: title hyphen ("host-government" in the record, "host government" on the HBR page).
  - `schaan1983parent`: university written "Univ. of Western Ontario", and the title has odd capitals ("And", "Of").
  - `reus2004interpartner`: "Interpartner" versus "Inter-partner".
  - `andersson2018integration`: middle initial "R." (from Consensus, unconfirmed).
  - Place and ISBN for Killing and Prahalad & Doz 1987 are recorded in Extra only.

### 11.2 Counts after this step

| Outcome | n |
|---|---|
| Items in the active library | 113 (plus 1 in the trash) |
| Verified | 112 (Crossref 98, websearch 13, Crossref + websearch 1) |
| Still unverified | 1 (`downes2000knowledge`) |
| Dropped (trash) | 1 (`nguyen2009foreign`) |
| Verified, screened unsure (not in the .bib) | 19 |
| Entries in `literature/references.bib` | 93 (include 65, seed 28) |
| Entries in `literature/references-unverified.bib` | 1 |
| Keys newly pinned | 9 (`ghoshal1993horses`, `killing1983strategies`, `reus2004interpartner`, `doz1980how`, `schaan1983parent`, `prahalad1987multinational`, `mohedanosuanes2021control`, `cocito2004subsidiaries`, `andersson2018integration`) |
| Keys changed on items already pinned | 1 (`prahalad2017approach` to `prahalad1981approach`) |
| Keys changed on unpinned items | 2 (`mohedanosuanescontrol` to `mohedanosuanes2021control`, `oostenfunctions` to `cocito2004subsidiaries`) |

All 28 seed works are now verified and in the .bib.

### 11.3 Fields still to confirm (for the PI's library request)

| Key | In .bib | Field(s) to confirm | Best route |
|---|---|---|---|
| `doz1990control` | yes | pages of the 1990 Routledge edition (citing papers give 117-143; 2013 reissue 127-153) | library copy of Bartlett, Doz & Hedlund (Eds.) 1990 |
| `reus2004interpartner` | yes | pages (369-395 in citing references versus 1-25 in the repository record); title spelling Interpartner / Inter-partner | JSTOR, Management International Review 44(4) |
| `mohedanosuanes2021control` | yes | pages (20-45 per search summary) | open-access PDF https://ijb.cyut.edu.tw/var/file/10/1010/img/838/V26N4-2.pdf |
| `ghoshal1993horses` | yes | last page (35 per SMR page summary; citing sources give 35 or 36) | SMR page or ProQuest record |
| `gong2003subsidiary` | yes | first author (Crossref DOI record lists no authors) | AMJ article PDF or AOM page |
| `venaik2004new` | yes | DOI, volume and pages; whether to cite as the MIR special issue or as the Gabler chapter (10.1007/978-3-322-90999-2_3, pp. 15-48) | PI decision plus a check of the MIR issue |
| `doz1980how` | no (unsure) | pages (149-157 per search summaries) | HBR archive or library copy |
| `prahalad1981approach` | no (unsure) | last page (citing references give 5-13) | ProQuest full text or library copy |
| `andersson2018integration` | no (unsure) | only if the 2002 Ashgate original is wanted: catalogue record and pages (343-365 per citing references); middle initial of Andersson | library catalogue / copy of McNaughton & Green (Eds.) 2002 |
| `downes2000knowledge` | no (unverified) | verification itself; volume 12, issue 2, pages 131-149 per citing references | JSTOR record or first-page PDF |

The search agent also recommends a one-click check of each websearch URL, because the pages were seen only through search results (13 items; URLs in each item's Extra).

### 11.4 Still open

1. The page checks in 11.3, and the click-through of the websearch URLs.
2. `downes2000knowledge`: verify via JSTOR, or drop.
3. `venaik2004new`: choose the form to cite.
4. Gate 1: decide on the 19 verified unsure items, and list `downes2000knowledge` as unverified in the gate file (`reviews/`).
5. Better BibTeX auto-export: limit it to items tagged `verified` and screened include or seed.
