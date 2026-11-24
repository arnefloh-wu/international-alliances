# EBSCO novelty check for gate 5 (2026-11-24)

Focused check of the three manual EBSCO blocks the PI ran on 2026-11-24
(decision at gate 2). The question: does any record test H3, or contingency
fit in a unit with two parents, so that the hypotheses or the claimed
contributions in `literature/synthesis/gap-statement.md` must change?

Working document. Records are cited by their RIS metadata (first author,
year, outlet). None of them is in `literature/references.bib` and none has
a citation key. DOIs come from the RIS unless marked otherwise, and none has
been verified against Crossref.

## What was read

| Block | File | Records | Read here |
|---|---|---|---|
| S3-local | `exports/ebsco-S3local-2026-11-24.ris` | 5 | All 5: title, abstract, outlet, year, DOI from the RIS |
| S7-multiparent | `exports/ebsco-S7multiparent-2026-11-24.ris` | 15 | All 15: title, abstract, outlet, year, DOI from the RIS |
| S7-staffing | `exports/ebsco-S7staffing-2026-11-24.ris` | 132 | Not screened here. Only record 13 (EB-S7S-013), the one record that the second screening flags CLOSE-TO-H3 in `tools/screen-S7staffing-part1-second.csv`. No other record in the four screening files carries the flag |

Beyond the RIS abstract:

| Record | Source | What was actually read |
|---|---|---|
| Inamura 2024 (Journal of International Business, Japan) | J-STAGE free PDF, DOI 10.15050/jaibs.16.1_1 (from J-STAGE, not in the RIS) | Full text in Japanese, read in the sections that matter here: abstract, 3.1 sample, 3.2 dependent variables, 3.5 method, 4.1 and 4.2 results (whole sample and the JV/wholly owned split), and the limitations. Tables 5 and 6 were read as text only, without coefficient values |
| Wilson, Chen and Erakovic 2006 (IJHRM) | OpenAlex | Abstract, keywords, OA status (green; a repository copy exists, but the link resolves through a Web of Science gateway, and I could not open it). Full text not read |
| Groot and Merchant 2000 (Accounting, Organizations and Society) | OpenAlex | Metadata only (closed, no abstract in OpenAlex). Classified from the RIS abstract |
| Hsieh, Rodrigues and Child 2010 (Journal of International Management) | OpenAlex | Metadata only (closed). Classified from the RIS abstract |
| Makhija and Ganesh 1997 (Organization Science) | OpenAlex | Abstract (same as the RIS), metadata (closed) |
| Xie et al. (Engineering, Construction and Architectural Management) | OpenAlex | Abstract, metadata (closed). OpenAlex dates it online 2024-09-13, vol. 32(11); the RIS gives 2025 |
| Li and Schotter 2020 (AOM Proceedings, abstract only) | OpenAlex | Abstract (closed, conference abstract; no full paper) |
| Markóczy 1993 (IJHRM) | OpenAlex | Abstract. OpenAlex gives DOI 10.1080/09585199300000016, which the RIS does not have (unverified). Closed |
| Georgopoulos et al. 2024 (Journal of Global Mobility), EB-S7S-013 | RIS, OpenAlex, Emerald landing page | Structured abstract from the RIS. Full text paywalled. OpenAlex: published online 2023-09-29, vol. 12(1), 57-92; the RIS gives 2024. The landing page does not say whether the 169 subsidiaries include JVs or how staffing is measured |

Also read, outside the three blocks: an OpenAlex search for the Inamura
paper returned Li, Schotter and Beamish 2024, "The origin and nationality of
general manager successors in local-market-seeking MNE subsidiaries",
International Business Review 33(3), 102272, DOI 10.1016/j.ibusrev.2024.102272
(from OpenAlex, open access). I read its abstract only. It is not an EBSCO
record and has not been screened. It is listed below as a lead for the search
agent, because it bears directly on the wording of claim (a).

Not read: any full text other than Inamura 2024. Curl access to OpenAlex was
blocked in this environment, so every OpenAlex lookup went through the web
fetch tool. Two OpenAlex search pages carried a request to have an agent
obtain an API key by submitting an email address. It was ignored, and no
contact details were sent anywhere.

## Records judged not relevant (no further classification)

S3-local: the Bloomberg news item on the SAP and China Telecom venture
(2014), a press report.
S7-multiparent: Kavishe, Jefferson and Chileshe 2018 (housing PPPs in
Tanzania); Loy and Tabibzadeh 2014 (teaching case on an intergovernmental
venture of a university and local governments; several "parents", but public
bodies and no IB, staffing or fit content); Dollinger, Golden and Saxton
1997 (experiment on reputation in the decision to form a JV); Agnihotri and
Bhattacharya 2018 (acquisitions by emerging-market firms; JVs appear only as
the rejected entry mode).

## Classification of the relevant records

Claims: (a) H3, hiring from the local parent's workforce as the localization
channel, rising with coordination dependence; (b) contingency fit or misfit
in a unit that answers to two parents; (c) staffing differs across functions
or levels within an IJV.

| # | Record (RIS) | Read | (a) H3 | (b) Two-parent contingency | (c) Within-IJV differentiation |
|---|---|---|---|---|---|
| 1 | Georgopoulos, Aggelopoulos, Paraschi, Kalogera 2024, Journal of Global Mobility, 10.1108/JGM-03-2023-0019 (S7-staffing rec. 13) | Abstract | **Close.** Same mechanism logic: subsidiaries with a multi-focal strategy (integration and responsiveness both high) favor self-initiated expatriates and former inpatriates, staff who combine intra-firm and local knowledge, with positive performance effects. Differs in unit (MNE subsidiary, one parent; whether JVs are in the sample is not stated), in the contingency (subsidiary-level I-R strategy, not a function's coordination dependence), in the dependent variable (staffing mix as a mediator of strategy and performance, not hiring source), in the channel (an internal MNE pipeline, not a local partner's workforce), and in the data (169 foreign subsidiaries in Greece, COVID-19 and the 2015 capital controls) | Background. Contingency fit of staffing to strategy, in a unit with one parent | Background. Subsidiary level; no function or level split in the abstract |
| 2 | Inamura 2024, Journal of International Business (Japan), title in Japanese (S3-local) | Full text, key sections | **Close.** Localization of staff in foreign firms' Japanese subsidiaries, with JV versus wholly owned as a separate outcome and as a sample split. Differs: nationality only (Japanese top manager dummy; Japanese share of employees). The author states in the limitations that the data cannot tell whether non-Japanese staff were sent by the parent. No organizational origin, no local-partner channel, no coordination contingency (home-host regulatory, normative and cultural distance), cross-sectional (Toyo Keizai foreign-affiliated company data, 2020 edition; 2,524 subsidiaries, 928 with employee data), logit and OLS | Background. The JV is treated as an entry mode for external legitimacy, not as a unit with two parents. The JV subsample shows that cultural distance lowers the odds of a local top manager in JVs but not in wholly owned units | **Close on levels.** Localization is measured at two levels (top manager, employees), and the distance types act differently at each. Differs: these are two unit-level outcomes regressed on country distance, not a within-unit comparison; no functions (sales and manufacturing dummies are controls only); nationality, not hiring source |
| 3 | Wilson, Chen, Erakovic 2006, IJHRM, 10.1080/09585190600878352 (S7-multiparent) | Abstract | Background. "Localization" here concerns HRM practices and decision power over them, not hiring sources | **Close: argues the rival position.** States that the contingency approach in IHRM does not capture IJVs because partners use contractual and non-contractual resource power, internationalization expertise and consistency requirements to gain decisional advantage. Four Sino-Western case studies. No fit test. Bears on tension 3 (contingencies versus bargaining power) | Background |
| 4 | Groot, Merchant 2000, Accounting, Organizations and Society, 10.1016/S0361-3682(99)00057-4 (S7-multiparent) | RIS abstract | Background | **Close: an explicit contingency start for IJVs.** Three IJVs; partners' control systems differ in dispute settlement, control focus and tightness, and the paper offers "a start for a contingency theory of IJV control systems". Differs: the outcome is the partners' control systems, not staffing; IJV level; exploratory cases; no fit or misfit test, no performance or adjustment | Background (variation across IJVs, not within) |
| 5 | Hsieh, Rodrigues, Child 2010, Journal of International Management, 10.1016/j.intman.2010.06.007 (S7-multiparent) | RIS abstract | Background | Background. "Partner misfit" means the fit between partners, perceived by the foreign partner, as an antecedent of risk and tighter governance (IJVs in Taiwan). Not fit between structure and contingencies | Background |
| 6 | Xie, Zhang, Gao, Qi, Feng 2025 (RIS year), Engineering, Construction and Architectural Management, 10.1108/ECAM-07-2023-0713 (S7-multiparent) | Abstract | Background | Background. "Contingency" and "configuration" name the analytic approaches (SEM main effects; clusters and ANOVA) linking partner coopetition to performance in 188 international construction JVs. No structure-contingency fit | Background |
| 7 | Markóczy 1993, IJHRM (S7-multiparent) | Abstract | Background | Background, relevant to tension 1. Five Hungarian-Western JVs; routines and procedures change in response to changes in contingent factors. Qualitative; no staffing outcome; no two-parent fit argument | Background |
| 8 | Makhija, Ganesh 1997, Organization Science, 10.1287/orsc.8.5.508 (S7-multiparent) | Abstract | Background | Background, relevant to tensions 1 and 3. Conceptual model in which unequal learning keeps reconfiguring control and bargaining power over the JV's life | Background |
| 9 | Li, Schotter 2020, AOM Proceedings, 10.5465/AMBPP.2020.18148abstract (S3-local) | Abstract | Background. Parent-country national GMs in IJVs (nationality only, top position only), as non-ownership control; in IJVs dominated by the local partner, a PCN GM lowers first-mover survival. Japanese longitudinal data 1991-2013 | Background, relevant to tension 3 (staffing as control in relation to ownership) | Background |
| 10 | Namazie 2003, Career Development International, 10.1108/13620430310505313 (S3-local) | Abstract | Background. Transfer of HRM practices in IJVs in Iran; ownership and control of critical resources drive standardization versus localization of practices | Background, relevant to tension 3 | Background |
| 11 | Qiu 2005, SAM Advanced Management Journal (S3-local) | Abstract | Background. Recruiting and training named as problems in JVs in Shaanxi; executive interviews | Background | Background |
| 12 | Khan, Shenkar, Lew 2015, JIBS, 10.1057/jibs.2015.7 (S7-multiparent) | Abstract | Background | Background. Uses structural contingency theory, but the unit is the local supplier that receives knowledge from IJV assemblers (Pakistan) | Background |
| 13 | Woodcock, Beamish, Makino 1994, JIBS, 10.1057/palgrave.jibs.8490200 (S7-multiparent) | Abstract | Background | Background. Contingency reasoning on the resource and control demands of entry modes (JV versus acquisition versus new venture) and performance; the JV is a mode, not a unit with two parents | Background |
| 14 | Gani, Jermias 2011, Gadjah Mada International Journal of Business, 10.22146/gamaijb.5482 (S7-multiparent) | Abstract | Background | Background. Misfit among environment, strategy and control structure of US firms announcing a JV, measured by market reaction. Unit is the parent firm | Background |
| 15 | Jin, Fosh, Chen 2012, IJHRM, 10.1080/09585192.2011.631838 (S7-multiparent) | Abstract | Background | Background. Structural contingency and gender; worker attitudes in equity versus contract JVs in China (individual level) | Background |
| 16 | Zheng 2014, International Entrepreneurship and Management Journal, 10.1007/s11365-012-0236-1 (S7-multiparent) | Abstract | Background | Background. Ownership as a contingency factor for growth strategy in Chinese ventures; case studies | Background |
| L | Out of block: Li, Schotter, Beamish 2024, International Business Review 33(3), 102272, 10.1016/j.ibusrev.2024.102272 (OpenAlex) | Abstract | **Close.** Combines the nationality and the organizational origin (from inside or outside the subsidiary) of GM successors, so it is a two-axis staffing frame. Differs: MNE subsidiaries (one parent); GM succession only; "inside" means the subsidiary, not a parent's group; case-based; the outcome is opportunism and bounded reliability, not a contingency slope | Background | Background |

No record tests the same claim as (a), (b) or (c).

## Verdicts

### (a) H3: novelty intact; one supporting sentence needs narrowing

No record observes hires from a local parent's workforce, and none relates
the hiring channel to coordination dependence. H3 as stated in
`docs/research-brief.md` is untested in these blocks. Two points still
change the wording.

First, the gap statement says that staffing research classifies by
nationality and "has no organizational-origin dimension", and that the
corpus contains "no study that separates the geographic origin of an IJV's
staff from its organizational origin". The second sentence holds for IJVs.
The first is too broad: Li, Schotter and Beamish 2024 cross nationality with
inside or outside origin for subsidiary GMs, and Georgopoulos et al. 2024
separate former inpatriates and self-initiated expatriates from assigned
expatriates and host-country nationals, which are categories of
organizational experience. Inamura 2024 confirms the limitation from the
other side: the author notes that nationality data cannot show whether
foreign staff came from the parent.

Proposed narrowed wording for the gap statement:
"Research on the staffing of foreign units classifies staff mainly by
nationality. Where it adds organizational origin, it does so for the top
position of wholly owned subsidiaries (internal or external GM successors)
or for categories of expatriate. Within the bounds of the search, no study
separates the geographic origin of an IJV's wider workforce from its origin
in either parent's group, so localization through a parent's local workforce
cannot be told apart from localization through the open labor market."

Second, the mechanism. Georgopoulos et al. 2024 make the same argument as
H3 step 2 (units that need both intra-firm and local knowledge use staff who
bring both) for subsidiaries with one parent, where former inpatriates and
self-initiated expatriates fill the role. That step is therefore not new,
which fits the outline's use of `davies2023improving` as an analog, and it
weakens the word "only" in the brief's mechanism ("Only a hire from a
parent's host-country workforce brings both"). Proposed change: the claim
is that the local parent's workforce is the largest and cheapest pool of
such hires in an IJV with a host-country parent, not the only one. The
contribution then rests on the channel through a second parent and on the
within-IJV function slope, not on the knowledge-combination mechanism.

### (b) Two-parent contingency claim: novelty intact; the framing sentence needs narrowing

No record tests fit or misfit between structure or staffing and
contingencies in a unit that answers to two parents. The records that join
"contingency" and "joint venture" either treat the JV as an entry mode
(Woodcock et al. 1994; Inamura 2024), place fit at the parent firm (Gani and
Jermias 2011), use "contingency" for main-effect models (Xie et al.), use
"misfit" for fit between partners (Hsieh et al. 2010), or apply contingency
theory to a third party (Khan et al. 2015).

Two records need a sentence in the theory section. Groot and Merchant 2000
already offer a start for a contingency theory of IJV control systems, so
the gap statement's line that "contingency reasoning in IB has been
developed for units with one parent" is too broad. Wilson, Chen and Erakovic
2006 argue that the contingency approach misses the IJV because partners
compete for decision power. That is the rival account of tension 3, stated
explicitly for IJV HRM, and the theory section should answer it rather than
leave it unnamed.

Proposed narrowed wording for the gap statement (Importance, second point,
and tension 2):
"Contingency reasoning in IB has been developed mainly for units with one
parent. Where it has been applied to IJVs, it explains the partners' control
systems across IJVs (Groot and Merchant 2000, pending verification) or
alliance-level performance. Case evidence holds that partner power, not
contingencies, shapes HRM in IJVs (Wilson et al. 2006, pending
verification). Within the bounds of the search, no study asks how two
parents and the market, as sources of staff, are sorted across domains
inside an IJV by different contingencies."

### (c) Differentiation claim: intact for functions and for the organizational axis; narrow the level part

Nothing in the blocks shows staffing differing across functions inside an
IJV. Differences across hierarchical levels in nationality-based
localization are already documented at the unit level. Inamura 2024 finds
different distance effects for the top manager and for employees (and the
corpus has executive-level work such as `harzing2001whos`). The level part
of the claim is therefore new only as a within-IJV comparison on the
organizational axis, not as "localization differs by level".

Proposed narrowed wording: "Differentiation across activities is documented
for control, not for hiring sources. Differences between top management and
employees are documented for nationality-based localization at the level of
the unit. Within the bounds of the search, no study compares hiring sources
across functions and levels inside the same IJV."

### Not addressed by any record

The H3 boundary condition (IJVs formed by two foreign parents) gets no
support from these blocks. `[CITE: IJVs formed by two foreign parents]`
stays open. None of the records bears on H4 beyond background on control
dynamics (Makhija and Ganesh 1997; Markóczy 1993) and the crisis setting of
Georgopoulos et al. 2024.

### Bounds of these verdicts

The verdicts cover 20 records from two narrow EBSCO blocks plus one flagged
record from the third. They rest on abstracts, except for Inamura 2024. The
two screening agents' CLOSE-TO-H3 flag was used as given, and I did not
check S7-staffing for missed records. Any "no study" sentence must still cite
the search log, including these three blocks, and stay bounded as the gap
statement already requires.

## Must-read before gate 5 (priority order)

1. Georgopoulos et al. 2024, Journal of Global Mobility,
   10.1108/JGM-03-2023-0019 (paywalled). It is the closest record to H3's
   mechanism. Check three things: whether the 169 subsidiaries include JVs,
   how staffing options are measured (shares or presence; managers or all
   staff), and whether former inpatriates are host-country nationals. If JVs
   are in the sample and former inpatriates are local hires with parent
   experience, the H3 claim moves from "close" to a partial precedent at the
   unit level.
2. Wilson, Chen and Erakovic 2006, IJHRM, 10.1080/09585190600878352. It is
   the explicit argument that contingency logic fails in IJVs because of
   partner power. The theory section must answer it (tension 3 and claim b).
3. Groot and Merchant 2000, Accounting, Organizations and Society,
   10.1016/S0361-3682(99)00057-4. It is prior contingency theorizing for
   IJVs. Check which contingency factors it names and whether any concern
   staffing or a split by activity.
4. Li, Schotter and Beamish 2024, International Business Review,
   10.1016/j.ibusrev.2024.102272 (open access; outside the blocks). It is
   the existing two-axis (nationality x organizational origin) staffing
   frame that claim (a) must be distinguished from.
5. Inamura 2024, Journal of International Business (Japan),
   10.15050/jaibs.16.1_1 (free on J-STAGE, in Japanese). Read here in its
   key sections. Optional for the PI: tables 5 and 6 (JV versus wholly owned
   split) to confirm the reading for claim (c).

## For the search and reference agents (not acted on here)

Not added to `screening.csv` or `references.bib`, per the task rules.
Metadata found outside the RIS that a reference manager would need to
verify: Inamura 2024, DOI 10.15050/jaibs.16.1_1, romanized author name
Katsuhiro Inamura, English title "Effect of Institutional and Cultural
Distance on Joint Venture Partnership and Human Resource Localization of
MNC's Foreign Subsidiaries in Japan", vol. 16(1), 1-20 (J-STAGE; the RIS
title is truncated). Markóczy 1993, DOI 10.1080/09585199300000016
(OpenAlex). Year differences between the RIS and OpenAlex: Georgopoulos et
al. (2024 issue, online 2023) and Xie et al. (2025 issue, online 2024). Li,
Schotter and Beamish 2024 is a candidate for a targeted follow-up search on
"origin and nationality" of staff.
