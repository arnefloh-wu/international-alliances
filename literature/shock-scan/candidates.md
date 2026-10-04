# Candidate shocks: long list and contingency map

Stage 5a, `/shock-options scan`, Phase A. Agent: shock-evaluator. Date: 2026-10-04.
Status: draft for gate 5a (`reviews/gate-5a-shock-scan.md`), not approved.

## How this list was built

- Sources: WebSearch only. WebFetch was attempted for every data-source and
  policy page and was refused by the egress proxy for all hosts tried
  (globalsanctionsdatabase.com, matteoiacoviello.com, oecd.org,
  dataverse.harvard.edu, gdeltproject.org, investmentpolicy.unctad.org,
  bis.gov, lebow.drexel.edu, sanctions.web.unc.edu, federalreserve.gov,
  policyuncertainty.com). Every episode below therefore rests on search-result
  snippets and the URL that carried them. All are `[unverified]` until a
  person opens the source.
- The Consensus connector was not used (plan not upgraded; 3 free searches
  left until 2026-11-01, `docs/decisions.md`).
- Search block S9 (`literature/search/search-strings.md`): the five Google
  Scholar variants S9a to S9e were run verbatim as WebSearch queries on
  2026-10-04, plus about 60 targeted WebSearch queries for episodes, dates,
  data sources and literature. Web of Science and EBSCO strings were not run
  (no agent access).
- Interview-derived triggers: none. `literature/synthesis/qual-measurement-memo.md`
  does not exist yet (Stage 3 not run). This is a known gap; the long list must
  be re-checked against the triggers respondents name once the memo exists.
- Independence rule: no Orbis or Revelio data exist in the repository, and no
  integration outcome (cross-parent integration, parent dominance,
  localization) was computed, inspected or reported by exposure status.
  Choices below rest on exposure logic, design properties and literature only.
- Episodes that I could not date from a source are marked `[DATA: ...]`.
  Nothing was filled in from memory.

## Exposure channels and how dyads are counted

The research idea defines exposure through the parent-country dyad (H4, H5:
"deterioration in political relations between the parent firms' home
countries"). Shocks reach an IJV through four different channels, and the
hard screen counts dyads accordingly.

| Code | Channel | Treated unit | Dyads counted for hard screen H3 |
|---|---|---|---|
| PP | Parent-parent dyad | IJV whose two parents are headquartered in the two countries of a treated pair | country pairs of parents |
| PH | Parent-host dyad | IJV whose host country and one parent's home form a treated pair | host x parent-home pairs |
| H | Host-level | every IJV in a treated host (often interacted with sector or function) | all parent-country pairs with an IJV in the treated host |
| F | Parent-firm level | IJV whose parent firm (or group) is designated | parent-country pairs of the exposed IJVs |

Because many IJVs have one local parent, PP and PH often coincide (for
example a Sino-Japanese IJV hosted in China).

## Contingency families used in the map

The map uses the six domains named in the agent principle and links each to
the four families in `docs/theory-framework.md`.

| Code | Domain | Theory family | Index in research idea |
|---|---|---|---|
| Co | Coordination requirements between partners, decision rights, hierarchical coordination role | Task, Coordination | `coord_dependence`, `coord_role` (H1, H3, H5) |
| LE | Local embeddedness: dependence on host customers, labor markets, institutions | Environmental | `local_embeddedness` (H2, H4) |
| PR | Access to parent resources: technology, finance, personnel | Resource | candidate third score (gate 3) |
| Mo | Cross-border mobility of personnel | Resource (personnel) | candidate third score |
| Re | Regulatory exposure: compliance burden or legal constraint on a domain | Environmental | `local_embeddedness` |
| PS | Political sensitivity of a domain | Environmental | `local_embeddedness` |

Function codes (research idea section 7): RD (R&D/engineering), OPS
(operations/manufacturing), SCM (supply chain/procurement), FIN, HR, SM
(sales/marketing), IT, GM (general management); GR/LEG (government relations,
legal, regulatory affairs) where Revelio permits. Level codes: EX
(executive/senior), MM (middle management), PRO (professional), OP
(operational). Outcomes: CPI (cross-parent integration), PD (parent
dominance, with direction), LOC (localization). Signs: `+` rise, `-` fall,
`0` no expected change, `?` ambiguous.

## Long list

Each row gives the episode, country pair or host, date(s), instrument and the
URL where the dating was seen. All `[unverified]`.

### Family A. Sanctions and secondary sanctions

| ID | Episode | Pair / host, channel | Date(s) | Instrument | Source seen |
|---|---|---|---|---|---|
| S01 | Crimea-related Western sanctions on Russia and Russian countersanctions | Russia x EU, US, other sanctioning states; PP/PH | 2014; Russian import ban August 2014 [DATA: instrument-level dates from GSDB-R4] | sectoral financial, technology and trade sanctions; food import ban | Crozet & Hinz, https://www.economic-policy.org/wp-content/uploads/2018/09/996_Friendly-Fire.pdf; https://cepr.org/voxeu/columns/how-firms-adjust-economic-sanctions [unverified] |
| S02 | Full-scale sanctions on Russia and Russian countermeasures | Russia x 48 "unfriendly" states (EU27 plus 21 others per Order 430-r); PP/PH | 2022-02/03 onwards; Decree 81 of 1 Mar 2022 (government approval for transactions with unfriendly-country persons); Order 430-r of 7 Mar 2022; Decree 302 of 25 Apr 2023 (temporary administration; applied to Danone and Baltika/Carlsberg in Jul 2023) | sanctions, capital and exit controls, state temporary administration | http://government.ru/en/docs/44745/; https://www.whitecase.com/insight-alert/special-economic-measures-have-been-adopted; https://globaltradealert.org/state-act/76453-russia-government-places-foreign-stakes-in-danone-russia-and-baltika-under-temporary-government-control; https://www.cnn.com/2023/07/17/business/russia-danone-carlsberg-control [unverified] |
| S03 | US withdrawal from JCPOA and re-imposed (secondary) sanctions on Iran | Iran x partner states; PH | 8 May 2018 announcement; first wave August 2018 (PSA said it would comply "by August 6, 2018"); second wave November 2018 (Total: unwind "before 4 November 2018") | secondary sanctions | https://www.steptoe.com/en/news-publications/president-announces-withdrawal-from-jcpoa-and-reimposition-of-nuclear-based-sanctions-on-iran.html; https://www.timesofisrael.com/french-carmaker-psa-to-exit-iran-over-us-sanction-risk/; https://drillingcontractor.org/total-explains-position-related-south-pars-11-project-iran-following-us-withdrawal-joint-comprehensive-plan-action-47080 [unverified] |
| S04 | Russian sanctions on Turkey after the Su-24 downing | Russia x Turkey; PP/PH | decree 28 Nov 2015; ban on employing Turkish nationals from 1 Jan 2016 (incumbents at 31 Dec 2015 exempt); lifted by Decree No. 244 of 31 May 2017, employment restriction cancelled from 10 Jun 2017 | trade bans, work restrictions | https://www.hfw.com/insights/russia-imposes-sanctions-against-turkey-december-2015/; https://www.lexology.com/library/detail.aspx?g=b6eff206-0f16-4852-b039-9e38bdf1e3ba [unverified] |
| S05 | China's counter-sanctions and blocking regime | China x sanctioning states (mainly US); PH | Unreliable Entity List rules 19 Sep 2020; MOFCOM Blocking Rules Jan 2021; Anti-Foreign Sanctions Law 10 Jun 2021; State Council Decrees 834 and 835 of 7 and 13 Apr 2026; first blocking order 2 May 2026 | counter-sanctions, blocking statute | https://www.akingump.com/en/insights/alerts/the-new-prc-anti-foreign-sanctions-law; https://www.mofo.com/resources/insights/260420-china-issues-new-regulations-countering-foreign-states; https://www.jonesday.com/en/insights/2026/05/caught-in-the-crossfire-two-new-china-decrees-raise-the-stakes-on-sanctions-compliance [unverified] |

### Family B. Investment-screening reforms and national security reviews

| ID | Episode | Pair / host, channel | Date(s) | Instrument | Source seen |
|---|---|---|---|---|---|
| S06 | Staggered adoption and tightening of investment screening mechanisms in OECD hosts | OECD host x screened sector x non-allied parent (mainly China); H x sector x parent nationality | PRISM codes 2007 to 2021; examples: FIRRMA law 13 Aug 2018, final rules effective 13 Feb 2020; EU Regulation 2019/452 applies from 11 Oct 2020; UK NSIA fully in force 4 Jan 2022 (17 mandatory sectors) | screening, call-in, mitigation, prohibition | https://academic.oup.com/isq/article-abstract/67/2/sqad026/7128313; https://www.cooley.com/news/insight/2020/2020-02-13-cfius-update-final-regulations-implement-firrma; https://enterprise.gov.ie/en/publications/investment-screening-regulation.html; https://www.ashurst.com/en/insights/quickguide-uk-national-security-and-investment-control-regime/ [unverified] |
| S07 | India-China 2020 bundle | India x China (Press Note 3 also covers other land-border states); PP/PH | Press Note 3 of 17 Apr 2020; Galwan clash 15 Jun 2020; app ban announced end of June 2020; visa restrictions on Chinese nationals [DATA: date] | approval route for FDI, app bans, visa restrictions | https://www.lexology.com/library/detail.aspx?g=c6bd8252-99c9-419c-8d6d-a20b46185dcd; https://www.aljazeera.com/news/2020/06/india-bans-59-chinese-apps-border-dispute-200629180545547.html; https://www.orfonline.org/research/diplomacy-sanctions-and-military-might-india-s-post-galwan-strategies-in-managing-china [unverified] |
| S08 | US Outbound Investment Security Program | US x China; PP | final rules published 15 Nov 2024, effective 2 Jan 2025 | prohibition and notification of US-person investments incl. JVs in Chinese semiconductors, quantum, AI | https://www.hklaw.com/en/insights/publications/2025/01/outbound-investment-screening-rule-goes-into-effect [unverified] |

### Family C. Export controls and technology restrictions

| ID | Episode | Pair / host, channel | Date(s) | Instrument | Source seen |
|---|---|---|---|---|---|
| S09 | US Entity List designations of IJV parent firms | listed parent's country (mostly China) x partner countries; F | staggered, each addition dated in the Federal Register; e.g., Huawei and 68 affiliates May 2019; further Huawei affiliates 20 Aug 2020; recent rules 16 Jan, 28 Mar, 16 Sep 2025. Affiliates (50 percent) Rule effective 29 Sep 2025, stayed from 10 Nov 2025 to 9 Nov 2026 | licence requirements for listed entities | https://www.orrick.com/en/Insights/2019/08/Huawei-Entity-List-Action-Update; https://www.federalregister.gov/documents/2020/08/20/2020-18213/addition-of-huawei-non-us-affiliates-to-the-entity-list-the-removal-of-temporary-general-license-and; https://www.federalregister.gov/documents/2025/09/16/2025-17893/additions-and-revisions-to-the-entity-list; https://www.whitecase.com/insight-alert/bis-implements-affiliates-rule-50-rule-applicable-entity-list-and-military-end-user; https://www.cov.com/en/news-and-insights/insights/2025/10/suspended-for-one-year-us-department-of-commerce-expansion-of-end-user-controls-to-cover-affiliates-of-certain-listed-entities [unverified] |
| S10 | US advanced computing and semiconductor manufacturing rules, incl. US-persons restriction | US x China, semiconductors; PH x sector | 7 Oct 2022 (phased effect 7, 12, 21 Oct 2022); updated Oct 2023 | export controls, restrictions on US persons supporting advanced fabs in China | https://sanctionsnews.bakermckenzie.com/bis-issues-new-export-controls-targeting-chinas-advanced-computing-and-semiconductor-sectors/; https://www.federalregister.gov/documents/2023/10/25/2023-23055/implementation-of-additional-export-controls-certain-advanced-computing-items-supercomputer-and [unverified] |
| S11 | Japan's export controls on South Korea | Japan x Korea; PP/PH | announced 1 Jul 2019 (licence per shipment for hydrogen fluoride, fluorinated polyimide, photoresist); Korea removed from Japan's white list 28 Aug 2019; later reversal [DATA: date] | export licensing | https://www.usitc.gov/publications/332/working_papers/the_south_korea-japan_trade_dispute_in_context_semiconductor_manufacturing_chemicals_and_concentrated_supply_chains.pdf; https://cepr.org/voxeu/columns/impact-export-controls-international-trade-evidence-japan-korea-trade-dispute [unverified] |
| S12 | China's export controls on critical inputs | China x all destinations; not dyadic | dual-use regime revision late 2024 and rare-earth controls Oct 2025 as reported in a search summary [DATA: instruments and exact dates]; MOFCOM export restriction on Nexperia China announced 4 Oct 2025 | export licensing | https://www.justsecurity.org/121725/export-controls-trade-policy-new-terrain/; https://www.cnbc.com/2025/10/13/dutch-government-takes-control-of-chinese-owned-chipmaker-nexperia.html [unverified] |

### Family D. Mobility, visa and work-permit restrictions

| ID | Episode | Pair / host, channel | Date(s) | Instrument | Source seen |
|---|---|---|---|---|---|
| S13 | Brexit and the end of UK-EU free movement | UK x EU27 (and EEA/Swiss) [DATA: confirm EEA-EFTA and Swiss treatment]; PP/PH | referendum 23 Jun 2016; UK left the EU 31 Jan 2020; transition and free movement ended 31 Dec 2020; points-based system from 1 Jan 2021 (Skilled Worker and Intra-Company routes with salary floors) | end of free movement, work-visa requirement | https://commonslibrary.parliament.uk/research-briefings/cbp-10988/; https://www.aljazeera.com/news/2020/12/30/brexit-immigration-and-travel-what-you-should-know-in-500-words; https://freemovement.org.uk/the-intra-company-transfer-visa-could-be-getting-a-new-lease-of-life/; https://immigrationbarrister.co.uk/personal-immigration/long-term-work-visas/intra-company-transfer-visa/ [unverified] |
| S14 | US Proclamation 10052 | US host x all foreign parents; H | 22 Jun 2020 to 31 Dec 2020, extended to 31 Mar 2021; partial injunction | entry suspension for H-1B, H-2B, L-1, some J-1 | https://www.congress.gov/crs_external_products/IN/PDF/IN11435/IN11435.3.pdf; https://www.rnlawgroup.com/826-pp-10052-suspending-entry-of-h-1b-l-1-visa-holders-extended-through-march-31-2021/ [unverified] |
| S15 | US Department of Justice China Initiative | US x China, academic science; no firm exposure rule | Nov 2018 to Feb 2022 | investigations and prosecutions | https://www.pnas.org/doi/10.1073/pnas.2301436121; https://cep.lse.ac.uk/pubs/download/dp1936.pdf [unverified] |
| S16 | Hong Kong National Security Law | Hong Kong host; H | in force from 30 Jun/1 Jul 2020; AmCham survey May 2021: about 42 percent of respondents considering leaving | security law; expatriate departures | https://rajawali.hks.harvard.edu/wp-content/uploads/sites/2/2021/07/the_risks_for_international_business_under_the_hong_kong_national_security_law_7.7.21.pdf; https://www.finews.asia/people/34466-amcham-hong-kong-expats-may-leave-over-national-security-law [unverified] |
| S17 | US 2025 mobility measures | US host x listed nationalities / all foreign parents; H/PH | travel ban proclamation 4 Jun 2025 (19 countries), expanded 16 Dec 2025 to 39 countries effective 1 Jan 2026; H-1B fee of USD 100,000 for new petitions from 21 Sep 2025 (proclamation 19 Sep 2025; reported vacated by a court) | entry bans, visa fee | https://www.congress.gov/crs-product/IN12631; https://www.uscis.gov/newsroom/alerts/presidential-proclamation-on-restriction-on-entry-of-certain-nonimmigrant-workers; https://www.fragomen.com/insights/united-states-president-trump-extends-dollar100000-h-1b-fee-but-policy-currently-vacated-by-court-order.html [unverified] |

Note: S04 (Turkish worker ban) and S20 (expulsion of nationals) also carry a
mobility instrument.

### Family E. Bilateral political deterioration (diplomatic crises, alignment shifts)

| ID | Episode | Pair / host, channel | Date(s) | Instrument | Source seen |
|---|---|---|---|---|---|
| S18 | Continuous dyadic political alignment | all dyads; PP/PH | annual (UNGA ideal points, 1946 to 2024 in the July 2025 year-based release); daily/monthly (event data) | measure, not an episode | https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/LEJUQZ; https://www.jamelsaadaoui.com/united-nations-general-assembly-ideal-points/ [unverified] |
| S19 | Staggered Chinese coercion episodes against partner states | China x targeted states (ASPI: 27 countries plus the EU, 2010 to 2020); PP/PH | examples: anti-Japanese protests Aug to Sep 2012 after the Senkaku "nationalization" (peak 12 to 22 Sep 2012); THAAD retaliation against Korea 2017 (Lotte land swap late Feb 2017; Hyundai/Kia China sales -52 percent y/y in Mar 2017); Australia 2020 (barley tariffs May 2020, coal ban second half 2020); Lithuania (Taiwanese Representative Office Nov 2021, exports blocked Dec 2021); Canada 2018 to 2021 [DATA: dates]; full case list from ASPI | boycotts, informal import bans, regulatory harassment | https://www.aspi.org.au/report/chinese-communist-partys-coercive-diplomacy/; https://en.wikipedia.org/wiki/2012_anti-Japanese_demonstrations_in_China; https://www.cnn.com/2012/09/25/business/toyota-island-dispute; https://keia.org/the-peninsula/south-korean-losses-from-chinas-thaad-retaliation-continue-to-grow/; https://www.cnbc.com/2020/12/18/australia-china-trade-disputes-in-2020.html; https://www.csis.org/analysis/chinas-economic-coercion-lessons-lithuania [unverified] |
| S20 | Qatar blockade | Qatar x Saudi Arabia, UAE, Bahrain, Egypt; PP/PH | 5 Jun 2017 to Al-Ula Declaration 5 Jan 2021; Qatari nationals given 48 hours to leave Saudi Arabia, UAE and Bahrain, their nationals 14 days to leave Qatar | diplomatic rupture, blockade, expulsions | https://www.hsfkramer.com/insights/2017-06/qatari-diplomatic-ties-severed-%E2%80%93-implications-for-business; https://sanctionsnews.bakermckenzie.com/gcc-and-egypt-sign-the-al-ula-declaration-ending-the-qatar-boycott/ [unverified] |
| S21 | US-China bundled deterioration from 2018 | US x China; PP/PH | 2018 onward, many instruments (tariffs, Entity List, visas, China Initiative) | bundle | components scored as S05, S09, S10, S15, S22, S29 |

Considered and not listed separately: the Dalai Lama visit "punishments"
studied by Fuchs and Klann (heads-of-state meetings, 1991 to 2008,
https://dx.doi.org/10.2139/ssrn.1694602 [unverified]) fall mostly before
Revelio's 2008 start and are a subset of China coercion episodes (S19). A
Saudi-Canada 2018 dispute was not searched and is not listed.

### Family F. Data-localization and data-transfer rules

| ID | Episode | Pair / host, channel | Date(s) | Instrument | Source seen |
|---|---|---|---|---|---|
| S22 | China data regime | China host; H x data-intensive function | Cybersecurity Law 1 Jun 2017 (CII localization); PIPL 1 Nov 2021 (security assessment for transfers above thresholds); later relaxations [DATA: 2024 regulation date] | localization, transfer assessment | https://privacylaw.proskauer.com/2017/05/articles/cybersecurity/a-primer-on-chinas-new-cybersecurity-law-privacy-cross-border-transfer-requirements-and-data-localization/; https://www.china-briefing.com/news/cross-border-data-transfer-new-measures-offer-clarification-on-security-review/; https://www.faegredrinker.com/en/insights/publications/2024/4/china-releases-new-regulation-on-cross-border-data-transfers [unverified] |
| S23 | Russia personal-data localization law | Russia host; H | in force 1 Sep 2015; LinkedIn blocked by Roskomnadzor 17 Nov 2016 under this law | localization | https://techcrunch.com/2016/11/17/linkedin-is-now-officially-blocked-in-russia/; https://www.insideprivacy.com/cross-border-transfers/linkedin-blocked-in-russia-following-breach-of-data-localization-laws/ [unverified] |
| S24 | Schrems II | EU/EEA x US; PP/PH | CJEU judgment 16 Jul 2020 invalidating Privacy Shield; SCCs upheld in principle; successor framework [DATA: date of EU-US Data Privacy Framework adequacy decision] | data-transfer restriction | https://www.congress.gov/crs-product/R46724; https://www.jonesday.com/en/insights/2020/07/schrems-ii-confirms-validity [unverified] |

### Family G. Ownership caps, governance rules and forced divestment

| ID | Episode | Pair / host, channel | Date(s) | Instrument | Source seen |
|---|---|---|---|---|---|
| S25 | China auto JV foreign-ownership cap removal | China host, auto sector; H x sector | NEV and special vehicles 2018; commercial vehicles 2020; passenger cars from 1 Jan 2022 (50 percent cap dating from 1994) | ownership cap removal | https://www.autonews.com/china/china-scrap-foreign-ownership-caps-joint-ventures-2022/; https://carnewschina.com/2022/01/03/new-chinese-policy-allows-full-foreign-ownership-of-car-factories/ [unverified] |
| S26 | India insurance FDI cap | India host, insurance; H x sector | 26 to 49 percent in 2015; 49 to 74 percent approved 22 Mar 2021, with removal of the "Indian owned and controlled" requirement and of limits on foreign shareholders appointing the CEO or most directors; resident-Indian senior executives may be required above 49 percent | ownership cap, decision-right rules | https://www.cliffordchance.com/insights/resources/blogs/insurance-insights/2021/07/parliament-approves-fdi-hike-to-74-per-cent-for-insurance-companies-in-India.html; https://investmentpolicy.unctad.org/investment-policy-monitor/measures/3681/india-increased-fdi-ceiling-in-insurance-companies [unverified] |
| S27 | China Foreign Investment Law and JV governance conversion | China host, all Sino-foreign EJVs; H | in force 1 Jan 2020; existing EJVs must conform to the Company Law by 31 Dec 2024 (shareholders' meeting replaces board as highest authority) | governance rule | https://www.pillsburylaw.com/en/news-and-insights/china-new-foreign-investment-law-part-three-changes-to-corporate-governance.html; https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4707751 [unverified] |
| S28 | State takeover and forced divestment | Russia (Decree 302, Apr/Jul 2023); Netherlands (Nexperia, Goods Availability Act, reported 13 to 14 Oct 2025 [DATA: exact date of the ministerial order]) | 2023; 2025 | temporary administration, ministerial control | https://www.cnn.com/2023/07/17/business/russia-danone-carlsberg-control; https://www.cnbc.com/2025/10/13/dutch-government-takes-control-of-chinese-owned-chipmaker-nexperia.html [unverified] |

### Family H. Tariffs and trade wars

| ID | Episode | Pair / host, channel | Date(s) | Instrument | Source seen |
|---|---|---|---|---|---|
| S29 | US Section 301 tariffs on China and Chinese retaliation | US x China; PP/PH x product | 2018 to 2019 waves [DATA: wave dates from USTR notices]; tariffs on USD 362 billion of imports | tariffs | https://www.nber.org/system/files/working_papers/w26610/w26610.pdf; https://elischolar.library.yale.edu/cgi/viewcontent.cgi?article=2089&context=egcenter-discussion-paper-series [unverified] |
| S30 | US 2025 reciprocal tariffs | US x 57 partners with country-specific rates (10 percent baseline for most others); PH | Executive Order 14257, 2 Apr 2025; baseline from 5 Apr, country rates from 9 Apr 2025; most suspended for 90 days on 9/10 Apr except China [DATA: confirm suspension dates] | tariffs | https://en.wikipedia.org/wiki/Liberation_Day_tariffs; https://www.whitecase.com/insight-alert/president-trump-orders-10-global-tariff-and-higher-reciprocal-tariffs; https://www.wilmerhale.com/en/insights/client-alerts/20250411-president-trump-suspends-most-reciprocal-tariffs-for-90-days-while-significantly-increasing-tariffs-on-china [unverified] |

Not treated as a candidate: the COVID-19 pandemic (not geopolitical). It is a
confounder for every 2020 to 2021 onset (S07, S13, S14, S16, S24, S26) and the
design must absorb it.

## Contingency map

For each candidate: the domains it alters and in which direction, where the
change falls (functions, levels), and the implied direction for CPI, PD and
LOC in the most affected domains versus the rest. `UNIFORM/UNCLEAR` marks
candidates whose predictions do not differ across domains or cannot be signed.
These are contingency-level implications for comparing shocks, not
hypotheses.

| ID | Domains altered (direction) | Most affected functions / levels | Implied change in affected domains | Rest of IJV | Differentiated? |
|---|---|---|---|---|---|
| S01 | PR down (finance, sanctioned technology), Re up (compliance), PS up | RD and IT in sanctioned technologies, FIN, LEG/compliance; EX for compliance coordination | RD/FIN: CPI -, PD toward Russian parent, LOC +; EX: CPI 0 or + | SM, HR, OPS: 0 | yes |
| S02 | PR strongly down, Mo down, Re up (counter-sanctions, exit approval), PS up (stigma), LE up | all functions, strongest in RD, IT, FIN; all levels | LOC + nearly everywhere; Western-parent share falls at EX and PRO; PD toward Russian parent | few unaffected domains | partly: same direction everywhere, different magnitudes; close to uniform localization |
| S03 | PR down, Re up (secondary-sanction compliance), PS up | GM/EX of non-US parent, FIN, SCM | non-US parent withdraws personnel; LOC +; PD toward Iranian parent | OPS, SM: ? | yes, weakly |
| S04 | Mo down for new Turkish hires in Russia (incumbents exempt), PS up | OPS/OP levels and project roles staffed by Turkish nationals | Turkish-parent inflows stop at OP/PRO; LOC + at lower levels | EX incumbents retained: CPI 0 at top | yes (by level, through the incumbent exemption) |
| S05 | Re up (conflicting legal duties), PS up | LEG/compliance, SCM (supplier choice), EX liability | compliance and SCM: PD toward Chinese parent or LOC +; EX: CPI 0 | RD, OPS, HR: 0 | yes, narrow |
| S06 | Re up in screened sectors; PR down for screened parent's access to technology/data (mitigation); Co constraints on board/GM | RD, IT, security-sensitive OPS; EX/board | PD away from screened foreign parent; LOC + in sensitive functions | SM, HR: 0 | yes, but weak for IJVs formed before screening |
| S07 | Re up (approval route), PS up (app bans, boycotts), Mo down (visas for Chinese technicians), PR down | RD/OPS commissioning roles (PRO/OP), SM (brand visibility) | Chinese-parent technical inflows -, LOC + at PRO/OP; SM LOC +; EX CPI 0 | HR, FIN: 0 | yes |
| S08 | Re up for US parent; PR down (US capital and support) | GM, RD in covered sectors | US-parent share -, PD toward Chinese parent | other: 0 | yes, narrow |
| S09 | PR down (listed group's access to US-origin technology), Co: ring-fencing of controlled technology between parents, Re up (licensing), PS up | RD, ENG, IT (deemed-export exposure), compliance; EX coordinates compliance | RD/IT: CPI -, PD toward the parent holding controlled technology or LOC +; EX: CPI 0 or + | SM, HR, OPS non-technical: 0 | yes, clearly by function and level |
| S10 | Mo down for US persons, PR down (tools) | RD/ENG and EX roles held by US persons in advanced fabs | US-person staff exit; PD toward Chinese parent; LOC + | non-technical: 0 | yes, narrow |
| S11 | PR down (Japanese inputs), Re up | SCM/procurement, materials RD | SCM LOC +; RD localization of materials work | GM, SM: 0 | yes, one family |
| S12 | PR down (inputs) | SCM, OPS | ? | ? | UNIFORM/UNCLEAR |
| S13 | Mo down for UK-EU moves (bites below ICT and skilled-worker salary floors), Re up (regulatory divergence), Co need persists at top | OP/PRO levels; regulatory, legal, customs/SCM, FIN (passporting) | OP/PRO: CPI -, LOC +; regulatory/legal/SCM/FIN: LOC + (duplication by jurisdiction); EX/MM: CPI 0 (ICT route stays feasible) | RD with high partner interdependence: CPI 0 at senior levels | yes, by function and level |
| S14 | Mo down for foreign parents' transferees into US hosts | RD, IT, ENG at PRO (H-1B/L-1B); EX (L-1A) | PRO: LOC +, PD toward US parent; EX: CPI - (temporary) | SM, HR: 0 | yes, one family |
| S15 | Mo/PS for academic scientists | not assignable to IJVs | ? | ? | UNCLEAR for IJVs |
| S16 | PS up (legal, media, data), Mo down (expatriate departures), Re up | GR/LEG, regional GM/EX roles | GR/LEG: LOC + or PD toward Chinese parent; EX roles relocate out of HK (CPI in HK -) | OPS, FIN: 0 | yes, partly |
| S17 | Mo down | as S14 | as S14 | as S14 | yes, one family |
| S18 | PS rises with distance; other domains unspecified | depends on which contingency the deterioration changes | general H4/H5 direction: politically exposed domains LOC +, top CPI 0 | ? | UNCLEAR: measure does not say which contingency changed |
| S19 | PS up sharply (boycotts, regulatory harassment), LE up (local legitimacy), Mo down for foreign-parent expatriates (safety), Co up at top (crisis coordination) | SM, GR/LEG, customer-facing domains; OP levels with foreign expatriates; EX | SM/GR: LOC +, PD toward Chinese parent; OP: foreign-parent share -; EX: CPI 0 or + | RD with high partner interdependence: CPI 0 | yes, clearly by function and level |
| S20 | Mo forced (expulsion of nationals), PS up, SCM disrupted | all roles held by nationals of the other side, incl. EX signatories; SCM | PD toward Qatari parent; LOC + | domains without affected nationals: 0 | yes, moderately |
| S21 | PR, Mo, Re, PS | union of S09, S22, S29 and others | mixed | mixed | bundled, mechanisms not separable |
| S22 | Re up for data processing; Co down for data sharing with foreign parent | IT, data/analytics, HR (personal data), SM (CRM), some RD | LOC +, PD toward Chinese parent in those functions | OPS, FIN: 0; little level difference | yes, by function |
| S23 | Re up for IT | IT | LOC + | 0 | yes, but outcome unobservable (see scoring) |
| S24 | Re up for EU to US personal-data transfers; Co friction in HR/IT/SM | IT, HR, SM data roles in EU-US IJVs | LOC + in EU-hosted data roles | others: 0 | yes, one family |
| S25 | ownership constraint relaxed; PR dependence on local parent falls | RD, GM | PD toward foreign parent | GR, HR, SM: 0 | yes, but changes ownership directly (conflicts with separating ownership and dominance) |
| S26 | Co: decision rights over CEO and board move to foreign parent; residency rule for senior executives | EX/GM | EX: PD toward foreign parent by affiliation, LOC by nationality ? | distribution/SM, OPS: 0 | yes, by level |
| S27 | Co: highest authority moves from board to shareholders' meeting; unanimity rules removed | EX/board | EX: CPI - or PD toward majority parent | MM and below: 0 | yes, by level; not geopolitical |
| S28 | PR cut, state control of governance | EX | EX replaced by state appointees; LOC + | ? | yes, few cases |
| S29 | SCM/OPS cost shocks | SCM, OPS | ? | ? | UNIFORM/UNCLEAR |
| S30 | SCM/OPS cost shocks | SCM, OPS | ? | ? | UNIFORM/UNCLEAR |

## Gaps to revisit

1. Interview-derived triggers: add after Stage 3 (`qual-measurement-memo.md`).
2. All dates and instruments need a human check against primary sources,
   because WebFetch was blocked.
3. Exposed dyad and IJV counts are proxies until `/shock-options rescore`
   runs `code/R/06_shock_exposure.R` on the pilot sample.
