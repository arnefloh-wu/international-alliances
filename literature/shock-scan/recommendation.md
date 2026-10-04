# Shock scan: recommendation for gate 5a

Stage 5a, `/shock-options scan`. Agent: shock-evaluator. Date: 2026-10-04.
Inputs: `candidates.md`, `literature-scan.md`, `data-inventory.md`,
`scoring.csv` (this folder). Status: for PI review at
`reviews/gate-5a-shock-scan.md`; nothing here is decided.

Independence rule: no integration outcome was computed, inspected or reported
by exposure status. No Orbis or Revelio data exist yet. The ranking rests on
exposure logic, design properties and literature only.

## 1. Bottom line

Thirty candidates in eight families were screened. Thirteen pass the default
hard screens (one provisionally) and are ranked; seventeen fail. Four are
recommended for the shortlist and one is kept in reserve.

| Rank (equal weights) | ID | Candidate | Family | Fit | Meas. | Ident. | Cov. | Interest | Weighted |
|---|---|---|---|---|---|---|---|---|---|
| 1 | S13 | Brexit: end of UK-EU free movement (1 Jan 2021; referendum 23 Jun 2016) | mobility | 5 | 5 | 4 | 5* | 3 | 4.40 |
| 2 | S09 | US Entity List designations of IJV parent firms (staggered) | export controls | 5 | 4 | 4 | 2* | 5 | 4.00 |
| 3 | S19 | Staggered Chinese coercion episodes against partner states (2010 to 2020) | bilateral political | 5 | 3 | 4 | 3* | 4 | 3.80 |
| 4 (tie) | S06 | Staggered adoption of investment screening in OECD hosts | investment screening | 3 | 4 | 4 | 3* | 4 | 3.60 |
| reserve, 4 (tie) | S02 | Russia 2022 sanctions and Russian countermeasures | sanctions | 5 | 4 | 3 | 2* | 4 | 3.60 |

`*` Sample coverage is scored from proxies (dyads and hosts touched,
plausible IJV activity, Revelio coverage of the hosts) and is provisional
until `/shock-options rescore` counts exposed dyads, IJVs and
IJV-function-years in the pilot. S09 passes hard screen H3 only
provisionally.

Plain statement on identification: no candidate reaches 5 on identification
potential. The best score is 4 (S13, S09, S19, S06): discrete, dated onsets
with plausible exogeneity to IJV staffing and usable not-yet-treated or
never-treated controls, but each carries a specific threat (anticipation and
COVID-19 for S13, selection of designated firms for S09, selection of
targeted states and the post-2018 US-China overlap for S19, weak treatment of
pre-existing IJVs for S06). The two strongest designs on paper (S09, S19) are
also the two with the most uncertain coverage.

Why S02 is reserve, not shortlisted: it is theoretically rich but its
outcome data are likely thin (LinkedIn has been blocked in Russia since 17
Nov 2016) and exits and state takeovers remove treated IJVs from the panel.
It should come back only if the pilot shows usable Revelio coverage of
Russia-hosted IJVs.

## 2. How provisional coverage scores were reached

| ID | Dyads touched (count logic) | Hosts | Plausible IJV activity | Revelio host coverage (proxy) | Score |
|---|---|---|---|---|---|
| S13 | UK x 27 EU states, plus EEA-EFTA and Switzerland if treated alike [DATA]: up to about 31 PP/PH dyads | UK and every EU host | high: intra-European IJVs among large economies | high (LinkedIn widely used in UK and EU; no platform block) | 5 |
| S09 | parent-country pairs of IJVs with a listed parent group; mostly China x partners, plus other listed destinations | China and partners' hosts | unknown: depends on how many listed groups are IJV parents [DATA: match Federal Register names to Orbis parents] | mixed (China weak, partner hosts good) | 2 |
| S19 | China x up to 27 targeted states (ASPI) | mainly China | high for Japanese and Korean partners (e.g., Japanese and Korean auto JVs named in news coverage of 2012 and 2017), lower for others | weak in China (main LinkedIn platform closed 2021; about 53 million users reported) | 3 |
| S06 | OECD hosts adopting or tightening screening (about 38) x non-allied parent countries | OECD hosts | moderate: IJVs with Chinese or other screened parents in screened sectors | high in OECD hosts | 3 |
| S02 | Russia x 48 listed countries | Russia | high historically, then attrition | very weak after Nov 2016 | 2 |

The default hard-screen thresholds (15 dyads, 30 IJVs) are met on this logic
by S13, S19, S06 and S02 with margin; S09 depends on the parent match.

## 3. Fit memos

The hypotheses H1 to H5 are restated at the contingency level as in
`docs/theory-framework.md`: H1 coordination dependence raises cross-parent
integration (CPI); H2 local embeddedness raises localization (LOC) relative to
cross-parent staffing; H3 CPI is higher at levels responsible for alliance
coordination; H4 after a contingency change, domains whose environmental
contingency rises most become more localized; H5 after the change, levels
responsible for alliance-wide coordination maintain or increase CPI relative
to lower levels. The statements below say which contingency each shock
changes and where; they are not final hypotheses and are not manuscript
text.

### S13 Brexit: end of UK-EU free movement

Mechanism. The end of free movement raises the cost of moving personnel
between a UK parent and an EU parent (or into a UK- or EU-hosted IJV). The
Skilled Worker and Intra-Company routes impose salary floors and prior
employment rules, so the cost rises most for junior and mid-level moves and
least for senior transfers. Regulatory divergence after exit raises the
regulatory exposure of domains that must comply separately in each
jurisdiction (regulatory affairs, legal, customs and logistics, parts of
finance). Coordination needs at the top of the alliance do not fall.

Contingency-level predictions. H1 and H3 serve as the static baseline. H4
instantiated: domains with high regulatory exposure (regulatory, legal,
SCM-customs, finance) and operational levels localize more than other domains
in UK-EU IJVs after 2021, relative to non-UK EU IJVs. H5 instantiated:
executive and middle-management levels keep CPI (senior transfer routes stay
open) while CPI falls at professional and operational levels. The mobility
channel belongs to the resource family (personnel), which links this shock to
the gate-3 decision on a third contingency score.

Data. Legal dates (verified only by search snippets); treatment intensity
from UK sponsored-visa statistics if they exist by sector or nationality
[DATA]. Exposure by parent dyad (UK x EU/EEA/CH).

Identification. Two-stage event study (announcement 2016, implementation
2021) with stacked or staggered DiD; controls are EU-EU IJVs and UK-non-EU
IJVs (the latter difference out UK-wide shocks such as sterling and trade
frictions in a triple-difference: UK-EU dyad x post x domain contingency).
Pre-period 2008 to 2015.

Main risk. Not obviously "geopolitical" and not a deterioration of
political relations in the sense of H4/H5 as written, so the PI must decide
whether the shock family is admissible. Technical risks: anticipation over
2016 to 2020, COVID-19 coinciding with 2020 to 2021, and UK-wide economic
shocks that are not mobility-specific.

### S09 US Entity List designations of IJV parent firms

Mechanism. Designation of a parent group restricts its access to US-origin
technology and software and exposes the partner to licensing risk for any
transfer, including deemed exports to foreign nationals. The non-listed
partner has to ring-fence controlled technology and the personnel who handle
it. Compliance coordination rises at the top. Customer-facing,
administrative and non-technical operational domains are largely untouched.

Contingency-level predictions. H4 instantiated through the resource and
regulatory families: in technology-intensive domains (R&D, engineering, IT)
CPI falls and staffing shifts toward the parent that controls the technology
or toward outside hires (LOC up), relative to non-technical domains and to
not-yet-designated IJVs. H5 instantiated: executive levels maintain or raise
CPI for compliance and alliance governance while technical professional
levels separate. H1 interacts: domains with high knowledge-exchange
dependence face the sharpest conflict between coordination need and the new
constraint.

Data. Federal Register rules give day-dated additions; a historical list must
be assembled from the rules and fuzzy-matched to Orbis parent groups;
affiliate scope changed in 2020 and again in 2025 (Affiliates Rule stayed
until 9 Nov 2026).

Identification. Staggered DiD at the IJV level with not-yet-designated IJVs
of later-listed parents as controls (Callaway-Sant'Anna or imputation
estimators, as listed in `docs/decisions.md`), plus a within-IJV contrast
between technical and non-technical domains. Long pre-period for listings
after about 2015.

Main risk. Too few exposed IJVs once parents are matched and cells are
thresholded; designated parents are selected on technology and state ties,
so pre-trends must be checked; China-side staff are under-observed in
Revelio. If counts are low, folding in S10 (2022 semiconductor rules) as an
intensity layer adds exposure.

### S19 Staggered Chinese coercion episodes against partner states

Mechanism. When Beijing targets a partner state (consumer boycotts, informal
import bans, regulatory harassment, as in Japan 2012, Korea 2017, Australia
2020, Lithuania 2021), IJVs in China with a parent from that state face a
sharp rise in political sensitivity in customer-facing and government-facing
domains, a rise in the value of local legitimacy, safety-driven reductions of
foreign expatriates at operational levels, and higher crisis-coordination
needs at the top. Technical domains with high partner interdependence keep
their coordination need.

Contingency-level predictions. This is the closest instantiation of H4 and
H5 as written. H4: sales and marketing and government relations localize or
shift toward the Chinese parent after the episode, relative to technical
domains and to IJVs whose foreign parent is from a not-yet-targeted state.
H5: executive levels maintain or raise CPI. H1: R&D and engineering with high
coordination dependence keep CPI. Older qualitative evidence that Japanese
firms resisted localizing management in China because of political tension
warns that the level prediction may run the other way.

Data. ASPI case list (152 cases, 2010 to 2020) for onsets, GDELT or POLECAT
for intensity and validation; China-hosted IJVs from Orbis.

Identification. Staggered event study across targeted states with
not-yet-targeted partner states as controls; pre-period from 2008 for the
2012 and later episodes. The post-2018 US-China deterioration must be
absorbed (for example by excluding US-parent IJVs or by host-year effects
and partner-country trends).

Main risk. Revelio coverage of China-based staff (local and Chinese-parent
personnel especially); think-tank event coding; target selection is not
random (states that defy Beijing may differ in their firms' strategies).

### S06 Staggered adoption of investment screening in OECD hosts

Mechanism. Screening raises regulatory exposure for IJVs in screened sectors
whose foreign parent is from a non-allied state (mostly China) and, through
mitigation conditions, restricts that parent's access to technology, data
and board seats. The effect is concentrated in security-sensitive technical
domains and at board level.

Contingency-level predictions. H4 via regulatory exposure: sensitive
technical domains (R&D, IT, security-relevant operations) shift away from
the screened parent (PD toward the host-country parent, LOC up) relative to
non-sensitive domains, to unscreened sectors and to not-yet-screening hosts.
H5 is ambiguous here: board-level constraints may lower the screened
parent's senior presence, against H5.

Data. PRISM (OECD 2007 to 2021, on request), OECD FDIRRI screening
category, UNCTAD IPM dated measures; sector scope coding needed.

Identification. Staggered triple difference (host adoption x screened
sector x non-allied parent), following the design used for M&A flows by
Eichenauer and Wang (2024,
https://www.kielinstitut.de/publications/mild-deglobalization-foreign-investment-screening-and-cross-border-investment-17544
[unverified]); long pre-period.

Main risk. For IJVs formed before screening, the treatment may be weak
because screening acts mainly on new transactions; mitigation agreements are
not observed; host adoption responds to Chinese investment surges.

### Reserve: S02 Russia 2022

Strong, multi-family shock (resources, mobility, regulation, political
sensitivity) with dated instruments (Decree 81, Order 430-r, Decree 302).
Predictions are close to uniform localization with different magnitudes,
which weakens the differentiation test, and IJV attrition and outcome
coverage in Russia are serious problems. Keep in reserve pending the pilot.

## 4. Sensitivity to weights

Weights (fit, measurement, identification, coverage, interest):
equal 0.2 each; fit-heavy 0.40/0.15/0.15/0.15/0.15; feasibility-heavy
0.125/0.25/0.25/0.25/0.125; identification-heavy 0.15/0.15/0.40/0.15/0.15.
Ranks among the 13 candidates that pass the hard screens (ties share a rank).

| ID | Equal | Rank | Fit-heavy | Rank | Feasibility-heavy | Rank | Identification-heavy | Rank |
|---|---|---|---|---|---|---|---|---|
| S13 Brexit mobility | 4.40 | 1 | 4.55 | 1 | 4.50 | 1 | 4.30 | 1 |
| S09 Entity List | 4.00 | 2 | 4.25 | 2 | 3.75 | 2 | 4.00 | 2 |
| S19 China coercion | 3.80 | 3 | 4.10 | 3 | 3.63 | 3 | 3.85 | 3 |
| S06 Screening | 3.60 | 4 | 3.45 | 7 | 3.63 | 3 | 3.70 | 4 |
| S02 Russia 2022 | 3.60 | 4 | 3.95 | 4 | 3.38 | 7 | 3.45 | 5 |
| S01 Russia 2014 | 3.40 | 6 | 3.55 | 5 | 3.38 | 7 | 3.30 | 6 |
| S18 Alignment (continuous) | 3.40 | 6 | 3.30 | 8 | 3.50 | 5 | 3.05 | 9 |
| S22 China data regime | 3.40 | 6 | 3.55 | 5 | 3.25 | 9 | 3.30 | 6 |
| S24 Schrems II | 3.40 | 6 | 3.30 | 8 | 3.50 | 5 | 3.30 | 6 |
| S14 Proclamation 10052 | 3.20 | 10 | 3.15 | 11 | 3.25 | 9 | 2.90 | 10 |
| S16 Hong Kong NSL | 3.20 | 10 | 3.15 | 11 | 3.13 | 11 | 2.90 | 10 |
| S27 China FIL | 3.00 | 12 | 3.25 | 10 | 2.75 | 12 | 2.75 | 12 |
| S05 China blocking regime | 2.80 | 13 | 2.85 | 13 | 2.63 | 13 | 2.60 | 13 |

Do the top three change? Under equal, fit-heavy and identification-heavy
weights the top three are S13, S09, S19 in that order. Under
feasibility-heavy weights S13 and S09 stay first and second and S06 ties S19
for third (3.625 each). The fourth place moves between S06 and S02.

Further checks:

- If the PI rules Brexit inadmissible, the top three become S09, S19 and a
  tie between S02 and S06 (equal weights), S09, S19, S02 (fit-heavy), S09
  then S06 tied with S19 (feasibility-heavy), and S09, S19, S06
  (identification-heavy).
- S09 coverage is the least certain score. At coverage 1 its equal-weight
  score is 3.80 (tie with S19 for second); at 3 it is 4.20. It stays in the
  top three either way.
- If S19 coverage drops to 2 (China outcome data very thin), its score is
  3.60, tying S06 and S02 for third.

## 5. Candidates that failed the hard screens

Hard screens (defaults, flagged as assumptions): H1 dated onset at year
resolution or finer; H2 measurable for the dyads in the sample frame (exposure
can be assigned to IJVs from a documented source, and the shock does not
itself remove the outcome data); H3 expected exposure of at least about 15
dyads and about 30 IJVs after cell thresholds. H3 was read to include the
existence of post-onset IJV-function-years in the panel window, so onsets
after 2024 fail it. Indicative equal-weight scores are shown only to inform
the PI's screen decisions; failed candidates are not ranked.

| ID | Candidate | Screen failed and reason | Indicative score |
|---|---|---|---|
| S03 | Iran 2018 secondary sanctions | H3: few observable Iran-linked IJVs (provisional) | 3.0 |
| S04 | Russia-Turkey 2015 to 2017 incl. Turkish worker ban | H3: single dyad | 3.6 |
| S07 | India-China 2020 bundle | H3: one main dyad | 3.4 |
| S08 | US outbound investment rule 2025 | H3: single dyad, no post-period | 3.2 |
| S10 | US semiconductor rules Oct 2022 | H3: one sector, mainly one host (provisional) | 3.6 |
| S11 | Japan-Korea 2019 export controls | H3: single dyad | 3.4 |
| S12 | China export controls 2023 to 2025 | H2: not dyadic; H3: no post-period | 2.4 |
| S15 | China Initiative | H2: no IJV exposure rule; H3: single dyad | 2.6 |
| S17 | US 2025 mobility measures | H3: no post-period | 3.2 |
| S20 | Qatar blockade 2017 to 2021 | H3: four dyads | 3.8 |
| S21 | US-China bundle from 2018 | H3: single dyad (components scored separately) | 3.2 |
| S23 | Russia data-localization law 2015 | H2: the law's enforcement blocked LinkedIn in Russia, removing outcome data | 2.6 |
| S25 | China auto ownership-cap removal | H3: one sector, about eight partner countries (provisional) | 3.0 |
| S26 | India insurance FDI cap 2021 | H3: one host and sector, likely under 15 dyads (provisional) | 3.4 |
| S28 | State takeovers (Russia 2023, Nexperia 2025) | H3: a handful of firms | 3.0 |
| S29 | US Section 301 tariffs 2018 to 2019 | H3: single dyad; predictions uniform/unclear | 3.0 |
| S30 | US 2025 reciprocal tariffs | H3: no post-period; predictions uniform/unclear | 2.4 |

Candidates marked uniform or unclear on theoretical fit: S12, S15 (for
IJVs), S18 (direction depends on which contingency changes), S29, S30.

## 6. Open questions for the PI

1. Weights: keep equal weights or adopt one of the alternatives? The top two
   are stable across all four schemes tried.
2. Hard screens: accept the defaults? In particular, the 15-dyad threshold
   excludes every single-dyad episode (US-China, India-China, Japan-Korea,
   Russia-Turkey) however many IJVs it touches. Relaxing it would let
   within-dyad designs (sector or firm intensity) compete; the highest
   indicative scores among failures are Qatar (3.8), Russia-Turkey (3.6) and
   the 2022 semiconductor rules (3.6).
3. Admissibility of shock types: is Brexit an admissible "geopolitical
   contingency", given that H4 and H5 in the research idea speak of
   deteriorating political relations? Are non-geopolitical regulatory shocks
   (India insurance cap S26, China FIL S27) admissible as fallbacks?
4. Panel window: what is the end date of the Revelio licence? It decides
   whether 2025 onsets (S08, S17, S30, the Affiliates Rule) can ever have a
   post-period.
5. Resource contingency: S13 and S09 work mainly through mobility and
   access to parent resources. If gate 3 keeps two summary scores
   (coordination dependence, local embeddedness) and drops the resource
   score, their predictions must be re-expressed through those two scores.
6. China-hosted designs: S19 and S22 depend on Revelio coverage of
   China-based staff. Should the pilot (gate 4) oversample China-hosted IJVs
   to measure this directly?
7. Combinations: should S10 be folded into S09 as an intensity layer, and
   S18 kept as a continuous moderator for S19 rather than as a stand-alone
   shock?
8. Verification: the egress policy blocked all data-source documentation
   pages, so every dataset property and episode date here comes from search
   snippets. Who verifies the shortlisted candidates' sources before gate 5?
9. Interview triggers: the long list should be checked against triggers in
   the qualitative memo once Stage 3 is done.
