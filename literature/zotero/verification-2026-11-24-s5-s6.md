# Verification, sections 5 and 6 of `missing-references.md`, 2026-11-24

Stage 2 (lit-synthesis), reference-manager (one of four parallel agents), 2026-11-24.
Scope: `literature/synthesis/missing-references.md`, section 5 (Geopolitics and the focal shock S13) and section 6
(Methods, S6). BibTeX for the new entries: `literature/zotero/verification-2026-11-24-s5-s6.bib`.
`literature/references.bib` and `reviews/gate-2-synthesis.md` were not edited. Nothing was committed.

Zotero sync pending (no credentials). The environment has no `ZOTERO_API_KEY` or `ZOTERO_GROUP_ID`, and the group API
returns 403 (orchestrator, 2026-11-24). No RIS file was written for this fragment; the agent that owns the merge can add
the one new entry to the shared import file.

Evidence sources used: Crossref REST API (generic User-Agent, no contact details); GOV.UK Content API
(`www.gov.uk/api/content/...`, publisher metadata for GOV.UK documents) and the PDFs it links; GOV.UK search API; EU
Publications Office SPARQL endpoint (CELEX metadata). EUR-Lex returned a bot challenge (HTTP 202, 2 KB page) for every
URL tried. The UK Government Web Archive refused the request (HTTP 405).

## Table

Statuses: verified and added; already in bib (first agent); PI decision; search request; unobtainable.

| Section | # | Work or claim | Status | Key(s) | Evidence record | Notes |
|---|---|---|---|---|---|---|
| 5 | 35 | UK-EU Trade and Cooperation Agreement (regulatory, customs, product-approval and tax divergence after 31 Dec 2020) | already in bib (first agent); remainder is a search request | `foreigncommonwealthdevelopmentoffice2021trade` | first agent | The TCA sets out the new relationship. It is not a source that names each diverging domain. For customs formalities, product approval (UKCA) and VAT administration from 1 January 2021, a specific official guidance source is still needed. Suggested search: `site:gov.uk "from 1 January 2021" (customs declarations OR UKCA OR "VAT") guidance`. Incidental check: TS No. 8/2021 is the legally revised text, renumbered to Articles 1 to 783 (GOV.UK page, first published 30 April 2021). Article numbers differ from the December 2020 text. The EU edition is CELEX 22021A0430(01) (Publications Office record, document date 2020-12-30). |
| 5 | 36 | Regulatory-facing occupations need jurisdiction-specific knowledge | search request | none | none | No work named. Suggested search: `("regulatory affairs" OR compliance OR customs OR "tax function" OR "legal function") AND ("jurisdiction-specific" OR "local knowledge" OR "host-country knowledge" OR "country-specific knowledge") AND (subsidiar* OR "foreign unit*" OR multinational*)`. The decision of 2026-11-24 already names the O\*NET law-and-government knowledge score as the robustness measure. Its documentation is the O\*NET entry in the bib (section 4). No lead found. |
| 5 | 37 | End of free movement and migration of EU and UK nationals | already in bib (first agent) | `shrestha2026end`; `ukvisasandimmigration2023uks` | first agent | Print year 2026 (Economics Letters 259, January 2026 issue). The shock-scan's "2025" was the online year. Possible correction for the bib owner: the GOV.UK Content API gives `public_updated_at` 2023-09-09T00:01:04+01:00 for the EU-citizens guidance, which is 9 September 2023 in UK time (8 September 23:01 UTC). The bib entry says "last updated 8 September 2023". GOV.UK displays UK time. |
| 5 | 38 | Brexit and firm organization or staffing | already in bib (first agent); remainder is a search request | `du2025how`; `moschieri2019organizational`; `tung2025hyperglobalization` | first agent | None of the three is a study of staffing inside firms (services exports; an organization-design essay; a mobility research agenda). The claim "Brexit and staffing" is still unsupported. Suggested search: `Brexit AND (staffing OR expatriat* OR "international assignment*" OR "workforce composition" OR hiring OR relocation) AND (firm* OR subsidiar* OR multinational*)`. Two unscreened leads (Do et al. 2025; Panitz & Glückler 2022); see "Leads". Online-first dates for Extra (Crossref): Du et al. 2025-01-03 (print issue March 2025); Moschieri & Blake 2019-03-19 (issue December 2019); Tung & Qin 2025-06-20 (print issue December 2025). |
| 5 | 39 | Common Travel Area (GB-IE contrast) | already in bib (first agent) | `cabinetoffice2026common` | first agent | GOV.UK body text states that British and Irish citizens can move freely and reside in either jurisdiction, with the right to work. This matches the claim. |
| 5 | 40 | Points-based system salary thresholds bite more at junior levels | already in bib (first agent) | `homeoffice2020uks`; `homeoffice2020statement` | first agent | What the texts say (read before the orchestrator's update arrived). CP 220, para 4: the general threshold is lowered to GBP 25,600, and the rate for new entrants is set 30 percent lower than for experienced workers. Para 6 and its table: GBP 20,480 is the floor with tradeable points. HC 813, IC 8.1 (printed p. 244): the ICT general salary requirement is GBP 41,500. That thresholds "bite more at junior levels" is an inference from these figures, not a statement in the documents. The new-entrant discount partly offsets it for labor-market entrants. |
| 5 | 41 | Mobility restrictions and staffing inside foreign units | already in bib (first agent) | `glennon2024how` | first agent | Print year 2024 (Management Science 70(2)). |
| 5 | 42 | Investment screening mechanisms (fallback S06): PRISM, Regulation (EU) 2019/452, EC list of screening mechanisms | already in bib (first agent) | `bauerledanzman2023mapping`; `europeanparliament2019regulation`; `europeancommission2026list` | first agent | Incidental: the Publications Office SPARQL record for CELEX 32019R0452 gives the same title and a document date of 2019-03-19. Crossref gives PRISM published-print 2023-03-14 and published-online 2023-04-18. The ordering is odd, but the year is unaffected. The PRISM dataset itself was not obtained (rescoring, section 8). |
| 5 | doc (S19) | ASPI 2020, The Chinese Communist Party's coercive diplomacy | already in bib (first agent) | `hanson2020chinese` | first agent | The ASPI report page was not retried. The first agent verified the work from the APO repository record and the PDF. |
| 5 | DATA (C2) | Home Office rule on whether a minority-held IJV counts as linked for the intra-company route | verified and added | `homeoffice2026workers` (new); text also in `homeoffice2020statement` | GOV.UK Content API record (Home Office, first published 2022-04-11, updated 2026-04-08) and PDF, version 04/26 | Answer in the section below. The version of the sponsor guidance in force at the 2021 onset was not obtained (UK Government Web Archive, HTTP 405). |
| 6 | 43 | Validity and coverage of profile-based workforce data: Grégoire et al. 2024 (CON-S6-09); Cubrich et al. 2021 (CON-S6-10) | PI decision | `gregoire2024mobilizing`; `cubrich2021examining` | Crossref DOI 10.5465/amj.2024.4002 (AMJ 67(2), 289-298, April 2024); Crossref DOI 10.1016/j.chb.2021.106742 (Computers in Human Behavior 120, 106742, July 2021) | Metadata verified. Both records are screened "unsure", and the .bib holds include and seed records only, so inclusion is the PI's call at gate 2 (item 6). Both are in Zotero since 2026-10-04 (9RI8EQ6K, V54G9EJS). In the fragment they are wrapped in `@comment`. Note: Grégoire et al. is an editorial on new data sources (Glassdoor in the abstract, per the screening sheet), not a coverage study of profile data outside the US. Cubrich et al. is a US hiring sample. Neither, from the metadata, covers non-US coverage, so the non-US part of the claim also remains a search request (string under # 44). |
| 6 | 44 | Missing employment histories and labor-market entrants in profile data | search request | none | none | Suggested search: `(LinkedIn OR "online professional profile*" OR "resume data" OR "résumé data" OR "Revelio") AND (coverage OR missing OR selection OR representativeness OR "sample bias") AND ("employment histor*" OR "career histor*" OR "work histor*")`. Add `AND (countr* OR international OR Europe*)` for the non-US part of # 43. One unscreened lead (Berry et al. 2024, US only); see "Leads". |
| 6 | 45 | Seconded staff who keep the parent as employer of record | search request | none | none | Suggested search: `(secondment OR seconded OR "employer of record" OR "dual employment" OR "legal employer") AND ("joint venture*" OR IJV OR subsidiar*) AND (staff* OR expatriat* OR assignee*)`. No lead found. The GOV.UK sponsor guidance (`homeoffice2026workers`) covers transfers into a UK joint venture but not employer-of-record status. |
| 6 | 46 | Labor-flow networks from profile data (method precedent): Park et al. 2019 (CON-S6-01) | PI decision | `park2019global` | Crossref DOI 10.1038/s41467-019-11380-w (Nature Communications 10(1), 3449; published online 2019-08-01, online-only journal) | Metadata verified. Screened "unsure", so the PI decides inclusion at gate 2. In Zotero since 2026-10-04 (GGZ839WS). Wrapped in `@comment` in the fragment. |

## Totals

| Status | Rows | Keys |
|---|---|---|
| verified and added (new) | 1 | 1 (`homeoffice2026workers`) |
| already in bib (first agent) | 8 (35, 37, 38, 39, 40, 41, 42, ASPI doc) | 14 |
| PI decision (verified, screened unsure) | 2 (43, 46) | 3 (`gregoire2024mobilizing`, `cubrich2021examining`, `park2019global`) |
| search request | 3 (36, 44, 45), plus open remainders in 35, 38 and 43; 3 unscreened leads listed below for 38, 43 and 44 | 0 |
| unobtainable | 0 works | 0 |
| Total rows | 14 (12 numbered entries, 1 extra document, 1 DATA item) | 18 |

Records that could not be opened, none of them needed for a verification: EUR-Lex (bot challenge for CELEX 32019R0452,
22021A0430(01) and the ELI URI). The Publications Office SPARQL record was used for a cross-check instead. Also not
opened: the UK Government Web Archive copy of the 2020-21 sponsor guidance (HTTP 405).

## Leads for the search requests (not added)

The PI allowed Consensus for finding works. This agent has no Consensus tool, so it searched OpenAlex
(`api.openalex.org/works?search=`, anonymous, 2026-11-24). Queries: "Brexit staffing multinational subsidiaries
expatriates"; "Brexit relocation firms employees EU nationals hiring"; "LinkedIn data representativeness coverage
employment histories"; "online professional network profiles coverage across countries labor statistics comparison";
"seconded employees joint venture parent company employment contract"; "secondment international joint venture
staff"; "Revelio Labs workforce data".

The three hits below have their metadata confirmed on Crossref. Their relevance is judged from the title only. They
were not screened, so they are not in the fragment. They go to the literature-searcher for screening and, if included,
back to the reference-manager.

| For # | Lead | Crossref record | Why it may fit |
|---|---|---|---|
| 38 | Do, H., Duong, K. T., Huynh, L. D. T., & Vu, N. T. (2025). The real effects of Brexit on labor demand: Evidence from firm-level data. Journal of International Economics, 157, 104129 | DOI 10.1016/j.jinteco.2025.104129 (print issue September 2025) | firm-level labor demand after Brexit |
| 38 | Panitz, R., & Glückler, J. (2022). Relocation decisions in uncertain times: Brexit and financial services. Economic Geography, 98(2), 119-144 | DOI 10.1080/00130095.2021.2009336 (print 2022-03-15, online 2022-03-18) | firm relocation decisions under Brexit |
| 43, 44 | Berry, A., Maloney, E., & Neumark, D. (2024). The missing link? Using LinkedIn data to measure race, ethnic, and gender differences in employment outcomes at individual companies. NBER Working Paper w32294 | DOI 10.3386/w32294 (report, March 2024) | checks LinkedIn-based workforce measures (US) |

The secondment and regulatory-knowledge queries returned nothing on point (entries 36 and 45). The Revelio query
returned no validity study.

## Linked-entity rule for the intra-company route (DATA item, C2)

What the official texts say:

1. Statement of Changes HC 813, 22 October 2020 (`homeoffice2020statement`). Part 1, para 6.2 (definitions), printed
   p. 24: "'Sponsor group', under Appendix Intra-Company routes, means the sponsor and any business or organisation that
   is linked to the sponsor by common ownership or control, or by a joint venture on which the applicant is sponsored to
   work." Appendix Intra-Company Routes, IC 5.7 (printed p. 242): an applicant on the Intra-Company Transfer route must
   "(a) be currently working for the sponsor group; and (b) unless they are applying as a high earner must have worked
   outside the UK for the sponsor group for 12 months."
2. Current Immigration Rules (GOV.UK, Introduction, para 6.2, updated 8 October 2026 for HC 584). The same definition
   applies to the Global Business Mobility routes and to Appendix Intra-Company routes. Appendix Global Business
   Mobility routes, SNR 5.7 (updated 3 August 2026, HC 259), carries the same requirement for the Senior or Specialist
   Worker. Neither the 2020 nor the current Rules define "joint venture" or "common ownership or control". Neither sets
   an ownership threshold or mentions minority holdings.
3. Home Office sponsor guidance, "Sponsor a Global Business Mobility worker", version 04/26, valid from 8 April 2026
   (`homeoffice2026workers`).
   - Section "Meaning of 'common ownership or control'" (pp. 18-19) lists among the qualifying links "one entity is
     related to the other entity in that one is a party to a joint venture agreement and the other entity is formed by
     that joint venture agreement". The list also includes "both are party to a joint venture agreement".
   - A majority-shareholding condition appears only where the link is an individual who owns shares in each entity.
     The other qualifying routes are board control or more than half of the voting rights.
   - Section "Joint venture agreements: Senior or Specialist Worker, Graduate Trainee" (pp. 19-20) adds two conditions:
     the Home Office must be satisfied that the worker will work as part of the joint venture agreement, and the joint
     venture must already be operating. Informal agreements of cooperation are not accepted. Evidence includes the
     Companies House number and owners of a newly formed company, and the binding contract with the investment or
     ownership agreement.
   - Joint venture links are not accepted on the UK Expansion Worker route.

Reading (the agent's, to be confirmed by the PI or an immigration lawyer): under the current guidance, an IJV formed by
a joint venture agreement is linked to a parent that is party to that agreement. The text sets no ownership threshold
for this link, so a minority stake does not by itself exclude it. The conditions are that the JV operates and that the
transferee works on it. The texts do not use the word "minority".

Two limits:

- The guidance version in force at the 2021 onset (sponsor guidance part 2, first published 9 December 2020) was not
  obtained. The Rules definition is identical in HC 813 and today, which suggests continuity, but a person should check
  the 2020-21 guidance text.
- These are UK rules for transfers into UK-hosted IJVs only. For EU-hosted IJVs with UK parents, the EU member-state
  rules apply, which this check did not cover.
