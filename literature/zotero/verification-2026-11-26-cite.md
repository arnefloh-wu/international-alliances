# Reference verification, five [CITE] markers of the pre-analysis plan, 2026-11-26

Agent: reference-manager. Input: the five substantive markers in the approved pre-analysis plan `reviews/gate-5-pre-analysis-plan.md` (lines 460, 481, 501, 507, 512), with the surrounding paragraphs read to fix what each claim needs. The plan was not edited. Evidence types follow the PI decisions of 2026-10-04 (Crossref DOI record, publisher or journal page, library or repository catalogue record, ISBN record, PDF of the work); OpenAlex, search results and citing references were used as leads only. The Consensus connector was not exposed in this session; searches ran through WebSearch, WebFetch, OpenAlex and Crossref (query log in `literature/search/search-log.md`, entry of 2026-11-26). Earlier leads in `literature/search/targeted-followup-2026-11-24.md` (sections 4 and 5, requests 19, 20 and 22 of `literature/synthesis/missing-references.md`) were rechecked.

Two separate checks were made for every work: (a) bibliographic verification (the work exists and the metadata are right) and (b) a content check that the work carries the claim. Column "Content checked" says what was read. Abstracts were read from OpenAlex (publisher-deposited abstract), RePEc/IDEAS, the publisher, or the author's own listing; no abstract text was copied into the `.bib`.

## 1. Results by marker

### Marker 1, line 460: recruitment source choice, internal versus external labor markets

Claim in context (H3 mechanism): where coordination dependence is low, parent-specific knowledge is not needed and the open market offers more candidates at lower cost; where it is high, the parents' host-country workforce is the main pool.

| Key | Work | Verified | Content checked | Fit |
|---|---|---|---|---|
| `williamson1975understanding` (new) | Williamson, Wachter & Harris 1975, *Bell Journal of Economics* 6(1), 250-278 | Crossref 10.2307/3003224 (first page only); end page from RePEc RePEc:rje:bellje:v:6:y:1975:i:spring:p:250-278 | Abstract (OpenAlex; RePEc): where job-specific skills and task-specific knowledge build up on the job, inexperienced outside workers are not equivalent to incumbents, and internal labor markets economize on the resulting transaction costs | Seminal statement of when firms fill jobs internally rather than from the outside market. Supports the specificity half of the claim directly |
| `cestone2024exploiting` (new) | Cestone, Fumagalli, Kramarz & Pica 2024, *Review of Economic Studies* 91(5), 2676-2716 | Crossref 10.1093/restud/rdad094; print issue 2024-09-05, online 2023-09-21 | Abstract (OpenAlex): business-group affiliates rely more on the group's internal labour market for swift hiring, especially of technical managers and skilled blue-collar workers, and more so when affiliates are geographically close | Recent. Closest analogue found to an IJV hiring from its parents' host-country units: hiring from an affiliated organization's workforce, helped by local proximity |
| `bidwell2014within` (new) | Bidwell & Keller 2014, *Academy of Management Journal* 57(4), 1035-1055 | Crossref 10.5465/amj.2012.0119; print issue 2014-08, online first 2013-10-23 (OpenAlex) | Accepted manuscript (Wharton faculty page) read in full: job-level choice between internal mobility and hiring, built on transaction-cost reasoning; Hypothesis 1 (firm-specific skills favor internal mobility) is not supported ("Contrary to expectations, we find no effect for firm-specific skills", abstract) | Use only as a source for the job-level choice between internal and external sourcing, not as evidence that skill specificity drives it |

Not added: Lepak & Snell 1999, *Academy of Management Review* 24(1), 31-48, doi 10.2307/259035 (Crossref verified). The abstract names internal development and acquisition as employment modes but not the uniqueness criterion; the full text was not reachable, so the fit was not checked. Bidwell 2011 (*ASQ*, 10.1177/0001839211433562; screening row OA-S4-21) reports, as summarized in the Bidwell & Keller manuscript (p. 4), that hires earn substantially more than workers promoted into similar jobs. That cuts against the "at lower cost" part of the claim.

Recommendation: cite `williamson1975understanding` and `cestone2024exploiting`; add `bidwell2014within` only for the internal-versus-external framing. No source was found for "at lower cost"; the plan should either drop it or say "a larger pool" (proposal in section 3).

### Marker 2, line 481: IJVs formed by two foreign parents

Claim in context: boundary condition of H3, the parents' host-country workforce channel is weaker or absent in IJVs without a host-country parent.

| Key | Work | Verified | Content checked | Fit |
|---|---|---|---|---|
| `makino1998performance` (new) | Makino & Beamish 1998, *JIBS* 29(4), 797-818 | Crossref 10.1057/palgrave.jibs.8490054 (note: not ...8490053, which is Rugman & Verbeke) | Abstract (IDEAS/RePEc; Ivey abstract compilation): four JV forms by partner nationality and affiliation, including JVs between home-country firms and with third-country firms; the conventional foreign-local JV is only 30% of 737 Japanese JVs in Asia; the forms differ in incidence, performance and survival | Seminal typology that names JVs without a local partner as a distinct and frequent form |
| `konara2022institutional` (new) | Konara & Yang 2022, *European Business Review* 34(5), 706-728 | Crossref 10.1108/ebr-07-2021-0155; print issue 2022-08-09, online 2022-06-01 | Abstract (OpenAlex): host-country, home-country and third-country partners; foreign firms are less likely to take a home- or third-country partner when host institutions are weak or institutional distance is large | Recent. Shows that the choice of a non-host partner is systematic, which matters for the boundary test (selection into the no-host-parent group) |
| `konara2023cultural` (new) | Konara & Mohr 2023, *International Business Review* 32(4), 102109 | Crossref 10.1016/j.ibusrev.2023.102109; open-access PDF (University of Essex repository); print issue 2023-08, online 2023-02-16 | Full text, pp. 1-2: research has focused on IJVs with local partners, while IJVs with a host-country partner account for only a fraction of IJVs; firms often choose partners from third countries assumed to be familiar with the host | Supports that IJVs without a host-country parent are common and distinct. Co-authored by Alexander Mohr (project co-author) |

Recommendation: cite `makino1998performance` and `konara2022institutional`; `konara2023cultural` is optional (self-citation of a co-author). None of the three studies staffing in IJVs without a host-country parent; as on 2026-11-24, no such study was found.

### Marker 3, line 501: hiring flows as the adjustment margin of workforce composition

Claim in context (H4 mechanism): after a contingency change the organization regains fit at the margin, in new hiring.

| Key | Work | Verified | Content checked | Fit |
|---|---|---|---|---|
| `abowd1999entry` (new) | Abowd, Corbel & Kramarz 1999, *Review of Economics and Statistics* 81(2), 170-187 | Crossref 10.1162/003465399558139 (NBER working paper version 10.3386/w5551 not cited) | Abstract (OpenAlex): when an establishment changes employment, the adjustment is made mainly through entry (hiring) rates, not separation rates; much simultaneous hiring and separation within skill groups | Establishment data: firms adjust through hires rather than separations |
| `hershbein2018do` (new) | Hershbein & Kahn 2018, *American Economic Review* 108(7), 1737-1772 | Crossref 10.1257/aer.20161570; print issue 2018-07-01 | Abstract (OpenAlex): skill requirements in job postings rose more in metro areas hit hard by the Great Recession, which the authors read as restructuring toward more-skilled workers | A shock shows up as a shift in the composition of new hiring |

Recommendation: cite both. Neither concerns IJVs or contingency theory; together they support the labor-market premise that composition shifts run through hiring. `babina2023firm` (in the `.bib`, working paper) has "changes in workforce composition" in its title but was not rechecked for this claim. Haveman 1995 (*ASQ* 40(4), doi 10.2307/2393755) was looked at and not added; it is about tenure distributions driven by ecological entry and exit.

### Marker 4, line 507: UK-EU regulatory divergence after 31 December 2020

Claim in context: from 1 January 2021, UK and EU regulation, customs, product approval and tax administration diverged.

| Key | Work | Verified | Content checked | Fit |
|---|---|---|---|---|
| `ukinachangingeurope2022doing` (new) | UK in a Changing Europe 2022, *Doing Things Differently? Policy after Brexit*, report of 31 January 2022 | Publisher page (ukandeu.ac.uk/reports/doing-things-differently-policy-after-brexit/, date and PDF link) and the PDF (also UCL Discovery 10142948) | Full text, pp. 4 and 8: the TCA "introduced significant new hindrances to UK-EU trade, such as customs declarations, new VAT procedures, different regulatory regimes, and the elimination of the recognition of many UK professional qualifications" (Winters & Morita-Jaeger, p. 8). But the introduction (Reland, Menon & Rutter, p. 4) states that there "has been no `big bang' of immediate and major divergence from EU rules" | Supports separate customs, VAT and regulatory regimes from 2021; does not support immediate divergence in the content of rules |
| `foreigncommonwealthdevelopmentoffice2021trade` (reused) | Trade and Cooperation Agreement, Treaty Series No. 8 (2021) | Already verified 2026-11-24 (GOV.UK) | GOV.UK page rechecked: title and Treaty Series number; the page does not state the application date | Legal instrument of the post-transition relationship; optional |

No peer-reviewed source on regulatory divergence itself was found in the time available. Kren & Lawless 2024 (*European Economic Review* 161, 104634, doi 10.1016/j.euroecorev.2023.104634, Crossref verified, not added) estimates the trade effect of Brexit, not regulatory change. The UK in a Changing Europe "UK-EU regulatory divergence tracker" (first edition October 2021, Reland, Rutter & Menon; copies on committees.parliament.uk) records individual divergence cases and could be added if the PI wants case evidence for regulatory content; it was not verified on the publisher site.

Recommendation: cite `ukinachangingeurope2022doing` (with the TCA entry if the legal instrument is to be named), and reword "diverged" (section 3).

### Marker 5, line 512: jurisdiction-specific human capital in legal and compliance work

Claim in context: regulatory-facing occupations in exposed IJVs now need knowledge of the host jurisdiction that staff from the other jurisdiction lack.

| Key | Work | Verified | Content checked | Fit |
|---|---|---|---|---|
| `hadfield2009role` (new) | Hadfield 2009, "The role of international law firms and multijural human capital in the harmonization of legal regimes", in Breton, Des Ormeaux, Pistor & Salmon (eds.), *Multijuralism: Manifestations, Causes, and Consequences*, Ashgate | Catalogue: Open Library edition records (Farnham and Burlington, VT: Ashgate, 2009; LCCN 2009025232; ISBN 9780754679448; chapter in the table of contents). The 2017 Routledge reissue chapter (doi 10.4324/9781351152884-8, pp. 161-179) is on Crossref and kept in Zotero Extra only (rule of 2026-10-04: cite the original) | Author's abstract (SSRN 959422, as reposted on the International Law Reporter, 2009-10-20; SSRN itself returned HTTP 403): legal human capital is generated by lawyers for clients, and "extensive jurisdiction-specific monopolies over the provision of legal services" inhibit multi-jurisdictional law firms. Full text not read | Conceptual support that legal expertise and the right to practise are tied to jurisdictions. A book chapter, not a journal article |
| `ukinachangingeurope2022doing` (new, as above) | | | p. 8: end of recognition of many UK professional qualifications under the TCA | Concrete Brexit case of a qualification losing value across the new border |

Not found: a peer-reviewed journal article showing that legal or compliance human capital is jurisdiction-specific (searches on immigrant lawyers, country-specific human capital, transferability of skills, law firm internationalization). Morgan & Quack 2005 (*Organization Studies*, doi 10.1177/0170840605059156) note that law is often regarded as determined by national legal systems, but argue against strong institutional legacies, so they were not added. Hadfield 2011 (*JEBO* 79(1-2), 80-94) does not make the jurisdiction point in its abstract. The marker is therefore only partly met. Suggested manual search (Web of Science): `TS=("legal human capital" OR "jurisdiction-specific" OR "country-specific human capital" OR "transferability of human capital") AND TS=(lawyer* OR "legal profession" OR compliance OR regulat*)`.

## 2. New entries in `literature/references.bib`

Ten entries, inserted in key order (188 to 198 entries), CRLF kept, no abstracts, one header comment line added; pandoc parses the file into 198 items without duplicate keys. Keys follow the convention of `verification-report-2026-11-24.md`, section 2 (first title word not in {a, an, the, on, of, in, for, and, to, at, by, with}; corporate author written out in full, as in `ukvisasandimmigration2023uks`).

| Key | Evidence | Discrepancies and decisions |
|---|---|---|
| `abowd1999entry` | Crossref | Kramarz's first name "Francis" as in Crossref (OpenAlex shows "Françis") |
| `bidwell2014within` | Crossref | Online-first date only in OpenAlex; second author "JR" as published |
| `cestone2024exploiting` | Crossref | Print year 2024 (online 2023); journal title as in Crossref, without "The" |
| `hadfield2009role` | Open Library catalogue (LCCN) | Chapter title as in the catalogue table of contents and Crossref (the 2009 working paper title adds "Legal"); 2009 page range not confirmed, so no pages field |
| `hershbein2018do` | Crossref | OpenAlex gives 2016 (working paper year); print year 2018 used |
| `konara2022institutional` | Crossref | Second author "Yang, Yi" as in Crossref; OpenAlex and the screening sheet give "Yi Chang Yang". DOI lowercase as registered |
| `konara2023cultural` | Crossref and PDF | Article number 102109 in the pages field, as for other Elsevier entries |
| `makino1998performance` | Crossref | Screening row OA-S3-68 had the right DOI |
| `ukinachangingeurope2022doing` | Publisher page and PDF | Corporate author; date 31 January 2022 from the publisher page and the foreword |
| `williamson1975understanding` | Crossref and RePEc | Crossref gives the first page only; end page 278 from RePEc |

## 3. Proposals for the plan and the decision log (not edited)

1. Line 460: drop "at lower cost" or replace it with "a larger pool", since the one study found on the cost side (Bidwell 2011) finds external hires paid more; cite `williamson1975understanding` and `cestone2024exploiting`.
2. Line 481: cite `makino1998performance` and `konara2022institutional`; state that no study of staffing in such IJVs exists, which is part of the contribution.
3. Line 501: cite `abowd1999entry` and `hershbein2018do`.
4. Line 507: reword along the lines of "From 1 January 2021, the UK and the EU were separate customs, VAT and regulatory jurisdictions, and many UK professional qualifications were no longer recognized in the EU" and cite `ukinachangingeurope2022doing` (p. 8). The same report (p. 4) says there was no immediate large divergence in the content of rules, which bears on the timing of H4a: the treatment is the jurisdictional separation, not a measured divergence in rules.
5. Line 512: cite `hadfield2009role` and `ukinachangingeurope2022doing` (p. 8), and record in the Open section of `docs/decisions.md` that a journal source for jurisdiction-specific legal human capital is still wanted (search string above).
6. Lines 658 to 662: replace "which elements they use is to be checked" with the findings in `literature/search/onet-precedent-elements-2026-11-26.md` (Dierdorff & Ellington use 4.C.1.b.1.e, f and g as one interdependence score; Oldenski uses "working with the public" and "creative thinking" importance ratings).
7. Decision log: a row recording that the ten entries were added and created in Zotero (section 4), as for earlier reference steps.

## 4. Zotero

Credentials were read from `.env` by a script and never printed or logged. Before creating anything, all 371 items of the group library (including trashed ones) were downloaded and checked locally for each DOI, each citation key in Extra and each title (the API quick search does not search the DOI or Extra fields, which a test with a known item confirmed). No match was found. The ten items were created through the Zotero Web API v3 in one write request, each with `Citation Key: <key>` as the first line of Extra followed by the verification line (and the online-first date where there is one), and added to the collection AIT5UJUH, "verified-import-2026-11-26 (agent)". The collection now holds 94 items and the library 380.

| Key | Zotero item | Type |
|---|---|---|
| `abowd1999entry` | V4WN87S5 | journalArticle |
| `bidwell2014within` | EB6DDHKU | journalArticle |
| `cestone2024exploiting` | 8IKIIGWI | journalArticle |
| `hershbein2018do` | 638ISQMB | journalArticle |
| `konara2022institutional` | 6XDHP7VT | journalArticle |
| `konara2023cultural` | SKBIHNFI | journalArticle |
| `makino1998performance` | PUR6IGPJ | journalArticle |
| `williamson1975understanding` | EEP5BS3I | journalArticle |
| `hadfield2009role` | BZVA6HE3 | bookSection |
| `ukinachangingeurope2022doing` | JX99RCRF | report |

`literature/zotero/import-2026-11-26-cite.ris` holds the same ten records as a fallback copy; each record says that the item already exists and should not be imported. Nothing was committed.

## 5. Files changed

`literature/references.bib` (ten entries and one header comment line), `literature/zotero/import-2026-11-26-cite.ris` (new), this file (new), `literature/search/onet-precedent-elements-2026-11-26.md` (new) and `literature/search/search-log.md` (entry appended). No other file was edited.
