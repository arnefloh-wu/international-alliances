# Shock scan, Phase B: pilot-based rescoring

Stage 5a, `/shock-options rescore`. Agent: shock-evaluator. Date: 2026-11-24.
Prerequisites: gate 4 and gate 5a, both APPROVED WITH CHANGES on 2026-11-24.
Inputs: `reviews/gate-5a-shock-scan.md` (PI notes), `docs/decisions.md`
(entries of 2026-11-24), `docs/coauthor-notes/gate-5a-decision-sheet-2026-11-24.qmd`,
H1 to H4 of `docs/research-brief.md`, `docs/theory-framework.md`, and the Phase A
files in this folder. Script: `code/R/06_shock_exposure.R`. Aggregate counts:
`rescoring-counts-2026-11-24.csv`. Rescored scores:
`scoring-rescored-2026-11-24.csv`.

Status: recommendation for the PI. Nothing here is decided. The final choice is
made at gate 5 and recorded by the orchestrator.

## 1. Bottom line

S13 (Brexit) is the only shortlisted shock that clears the hard screens with a
margin: 175 exposed IJVs in 25 country pairs keep five or more hires in some
function-year both before and after 2021 (136 IJVs in 23 pairs among IJVs with a
parent in Revelio). S06 (investment screening) passes only provisionally: it
clears the screen under the gate 4 employee cell rule (32 IJVs, 19 pairs) and
fails under a hires rule (23 IJVs, 15 pairs), and two thirds of its exposed IJVs
sit in hosts whose adoption years are still unverified. S19 (Chinese coercion)
fails on pairs (6 to 11, against 15) although it fits H4 best. S09 (US Entity
List) fails clearly (8 exposed IJVs) and is dropped as gate 5a decision 2
foresaw; S10 is therefore not folded in.

Recommendation: S13 as the focal shock, S06 as the fallback (Section 9). No
candidate scores 5 on identification. S13 reaches 4, the others 3.

| ID | Candidate | Scan score | Rescored (equal weights) | Hard screen |
|---|---|---|---|---|
| S13 | Brexit, end of UK-EU free movement | 4.40 | 4.20 | PASS |
| S06 | Investment screening in OECD hosts | 3.60 | 3.20 | PASS_PROVISIONAL |
| S19 | Chinese coercion episodes (ASPI) | 3.80 | not ranked (indicative 3.40) | FAIL |
| S09 | US Entity List designations | 4.00 | not ranked (indicative 2.80) | FAIL, dropped |

## 2. Independence rule

The independence rule (`CLAUDE.md` rule 8, strict reading of the instruction of
2026-11-24) was followed. By exposure status, `06_shock_exposure.R` counts only
the following: exposed country pairs and IJVs (all, strategic, with a parent in
Revelio, with a host-country parent), total hires and total person-years (never
split by origin), the IJV-function-years and IJV-years that reach the cell
threshold, onset years, the available pre- and post-onset years, and the size of
the control groups. No hire was classified by origin, no staffing category
(parent-origin, independent, local, international, entrants, history not
observed) was counted, no share was computed, and nothing was compared before
against after onset beyond counting the years and cells that exist. Total hires
are reported over the whole window, not split at onset. The script does not read
`data/interim/staffing-tabulations-*`, the career histories or the education
records, and it drops the frame's `exposure_group` column on read. The one
comparison with `exposure_group` (Section 4.1) is a reconciliation of group
membership and involves no outcome. The aggregate file holds no IJV names or ids;
a check in the script stops the run if an id-like value appears.

## 3. Counting rules

| Item | Rule | Source |
|---|---|---|
| Sample | `core_main`, 7,460 IJVs; 5,882 with at least one parent in Revelio | gate 4, decision 6 |
| Country basis | direct shareholder's country; Orbis GUO country as a robustness count on the 6,032 Orbis-sourced IJVs | gate 4, decisions 2 and 3 |
| Host-country parent | a parent whose direct shareholder country equals the host | gate 4 |
| Functions | Revelio's own role_k10 codes (`job_category` of the first position for hires, `function_role_k10` of the spell for person-years). The project's function map is set at gate 5 | instruction of 2026-11-24 |
| Hire | first dated position at the matched JV entity for people in the spell table, as in `code/R/wrds/11_staffing_tabulations.R`; no origin attached | |
| Counting window | 2008 to 2025, and not before the IJV's formation year. 2026 is left out because the Revelio data end in September 2026 | Phase A data inventory; Revelio check of 2026-10-08 |
| Cell rule | an IJV-function-year (or IJV-year) with at least 5 hires (hires rule) or at least 5 employees on 30 June (employee rule, the gate 4 baseline `min_cell_emp`) | gate 4 cell rule |
| IJV after thresholds | exposed, formed before its onset year, and with at least one qualifying function-year both before onset and from onset on | agent's reading of hard screen H3 |
| Onsets | up to 2023 | gate 5a, decision 5 |
| Hard screen | at least about 15 exposed pairs and about 30 exposed IJVs after thresholds, counted on IJVs with a parent in Revelio | gate 5a, decision 3 |

The hard-screen column in the counts file is computed for both cell rules. The
gate 4 cell rule is stated in employees, while H4 predicts hiring flows, so the
hires rule is the stricter and more relevant reading. Which one binds is an open
question for the PI (Section 11); it decides S06.

## 4. Shock definitions and counts

### 4.1 S13 Brexit: end of UK-EU free movement

Definition. Exposed: a UK-hosted IJV with a parent from the EU27, Iceland,
Liechtenstein, Norway or Switzerland, or an IJV hosted in one of those countries
with a UK parent. The pair is {GB, other country}. Onset 2021 (free movement
ended on 31 December 2020, verified on gov.uk, Section 8); the referendum of
2016 is the announcement variant. Parent-parent pairs hosted in third countries
are counted separately, because H4 works through a change in the host
environment and those IJVs see none. Ireland is a variant: Irish citizens keep
Common Travel Area rights, so GB-IE IJVs see the regulatory change without the
end of free movement for Irish nationals. Controls: never-treated IJVs hosted in
the UK or the set without a UK-set link.

Reconciliation. The frame's `uk_eu` group held 485 IJVs. 384 of them are
exposed here (main and third-country variants together, 413). The remaining 101
all entered the frame through the owner-level route; 98 of them have only
domestic direct parents (for example two UK direct shareholders of a UK-hosted
IJV), so they are not exposed on the direct-country basis that gate 4 fixed. 99
of the 101 return in the owner-country count (419 on the Orbis-sourced subset).

| Measure | Main (EU27+EEA+CH, onset 2021) | Ireland excluded | Onset 2016 | Third-country parent-parent | Orbis, direct | Orbis, owner |
|---|---|---|---|---|---|---|
| Exposed pairs | 28 | 27 | 28 | 12 | 26 | 28 |
| Exposed IJVs | 394 | 365 | 394 | 19 | 342 | 419 |
| strategic | 97 | 96 | 97 | 6 | 85 | 129 |
| parent in Revelio | 311 | 291 | 311 | 17 | 262 | 340 |
| host-country parent | 299 | 278 | 299 | 6 | 262 | 347 |
| parent in Revelio and host-country parent | 230 | 216 | 230 | 6 | 196 | 280 |
| formed before onset | 364 | 337 | 286 | 18 | 313 | 384 |
| IJVs after hires rule | 175 | 162 | 111 | 6 | 150 | 176 |
| of which parent in Revelio | 136 | 128 | 89 | 6 | 112 | 142 |
| of which host-country parent | 130 | 120 | 78 | 3 | 112 | 143 |
| pairs after hires rule (parent in Revelio) | 25 (23) | 24 (22) | 25 (22) | 5 (5) | 23 (21) | 25 (24) |
| IJVs after employee rule (parent in Revelio) | 288 (231) | 268 (218) | 195 (158) | 15 (14) | 249 (194) | 302 (250) |
| IJV-function-years, 5+ hires, pre / post | 2,654 / 2,052 | 2,594 / 1,908 | 1,082 / 2,998 | 182 / 70 | 2,212 / 1,845 | 2,818 / 2,251 |
| IJV-function-years, 5+ employees, pre / post | 7,964 / 6,059 | 7,778 / 5,723 | 3,557 / 9,029 | 620 / 315 | 6,281 / 5,170 | 7,981 / 6,459 |
| IJV-years, 5+ hires, pre / post | 1,763 / 1,093 | 1,692 / 1,004 | 782 / 1,665 | 100 / 35 | 1,455 / 960 | 1,739 / 1,166 |
| Total hires 2008-2025 | 122,328 | 118,490 | 122,328 | 6,707 | 107,130 | 139,594 |
| Total person-years 2008-2025 | 539,474 | 527,655 | 539,474 | 39,577 | 460,112 | 621,269 |
| Onset years (IJVs) | 2021: 394 | 2021: 365 | 2016: 394 | 2021: 19 | 2021: 342 | 2021: 419 |
| Pre-onset years, median [range] | 13 [1-13] | 13 [1-13] | 8 [1-8] | 13 [4-13] | 11 [1-13] | 12 [1-13] |
| Post-onset years | 5 (2021-2025) | 5 | 10 | 5 | 5 | 5 |
| Controls (parent in Revelio; at hires rule) | 3,409 (2,510; 1,273) | 3,367 (2,487; 1,260) | 3,409 (2,510; 875) | 3,409 | 3,128 | 3,051 |
| Hard screen, hires rule / employee rule | PASS / PASS | PASS / PASS | PASS / PASS | FAIL / FAIL | PASS / PASS | PASS / PASS |

Largest pairs (exposed IJVs, main): GB-DE 68, GB-IT 44, GB-NL 37, GB-FR 37,
GB-ES 34, GB-IE 31, GB-LU 24, GB-DK 20, GB-NO 19, GB-CY 15, GB-CH 13, GB-BE 13.

### 4.2 S06 Staggered investment screening in OECD hosts

Definition (gate 5a, decision 2). Exposed: an IJV in an OECD host from the year
the host adopted or tightened a cross-sectoral screening mechanism, with a
non-allied foreign parent, in a screened sector. The frame's `oecd_screening`
group is not used.

- Onset. The first year from 2017 to 2023 in which the host adopted a
  cross-sectoral mechanism or tightened an existing one; mechanisms in place
  before 2017 are the baseline. The year 2017 marks the start of the wave of
  reforms in the scan's sources; it is the agent's choice and the PI may move
  it. EU hosts are dated from the European Commission's "List of screening
  mechanisms notified by Member States" (last update 9 February 2026, opened on
  2026-11-24; year of entry into force where the list states it, otherwise year
  of the instrument). Other hosts rest on search snippets and are `[unverified]`.
  The table is in the script.
- Non-allied parent. Main: China, Hong Kong and Macao (direct shareholder
  country). Broad: the six foreign adversaries of 15 CFR 791.4(a) (China
  including Hong Kong and Macao, Cuba, Iran, North Korea, Russia, Venezuela),
  verified on law.cornell.edu on 2026-11-24.
- Screened sector. Regulation (EU) 2019/452, Article 4(1): critical
  infrastructure (energy, transport, water, health, communications, media, data
  processing or storage, and related facilities), critical technologies and
  dual-use items, critical inputs (energy, raw materials), sensitive information
  and media (as adopted, legislation.gov.uk, opened 2026-11-24). The mapping to
  NACE Rev. 2 groups (Orbis), NAICS (fallback) and Capital IQ industries is the
  agent's and is listed in the script; it needs the PI's review. Core NACE codes:
  05, 06, 07, 09, 19, 21, 26, 35, 36, 50, 51, 53, 58 to 63, 72, 86 and the groups
  24.4, 25.4, 27.2, 30.3, 30.4, 49.1, 49.2, 49.5, 52.2. The broad variant adds
  20, 27, 28, 30, 49, 52 and 71.
- Controls. IJVs in the same treated hosts and screened sectors whose parents
  are all from allied countries (the comparison group of a triple difference),
  plus hosts without an onset by 2023.

| Host | Onset | Status | Instrument |
|---|---|---|---|
| AT | 2020 | verified (EC list) | Investment Control Act, in force 25 Jul 2020 |
| BE | 2023 | verified | cooperation agreement law, in force 1 Jul 2023 |
| CZ | 2021 | verified | Act 34/2021 Coll. |
| DK | 2021 | verified | Investment Screening Act (Act 842 of 10 May 2021) |
| DE | 2017 | verified | Foreign Trade and Payments Act as amended on 20 Jul 2017; further changes 2018 to 2021 |
| EE | 2023 | verified | Foreign Investment Reliability Assessment Act (RT I 10.02.2023) |
| ES | 2020 | verified | Royal Decree-Law 8/2020 of 17 Mar 2020 |
| FI | 2020 | verified | amendments 682/2020 of 2 Oct 2020 to Act 172/2012 |
| FR | 2019 | verified | Order of 31 Dec 2019 on foreign investments |
| IT | 2019 | verified | Decree-Law 105 of 21 Sep 2019 (golden power since 2012) |
| LU | 2023 | verified | Law of 14 Jul 2023, in force 1 Sep 2023 |
| NL | 2023 | verified | Vifo Act, entry into force set by decree of 4 May 2023 |
| PL | 2020 | verified | Act of 19 Jun 2020 |
| SE | 2023 | verified | Act 2023:560 |
| SK | 2022 | verified | Act 497/2022 Coll. |
| PT | none in window | verified | only Decree-Law 138/2014 listed |
| IE, GR, BG | after 2023 | verified | in force 2025, 2025, 2024 |
| HR, CY | none | verified | not in the EC list |
| US | 2018 | [unverified] | FIRRMA, 13 Aug 2018 |
| GB | 2022 | [unverified] | National Security and Investment Act, in force 4 Jan 2022 |
| AU | 2020 | [unverified] | temporary nil monetary threshold 2020; national security test from 1 Jan 2021 |
| CA | 2020 | [unverified] | policy statement of 18 Apr 2020 |
| NZ | 2020 | [unverified] | Overseas Investment (Urgent Measures) Amendment Act, 16 Jun 2020 |
| JP | 2020 | [unverified] | FEFTA amendment effective 8 May 2020 |
| KR | 2020 | [unverified] | 2020 amendment of the FIPA enforcement decree (date not confirmed) |
| IL | 2019 | [unverified] | Security Cabinet decision B/372 of 30 Oct 2019 |
| NO | 2019 | [unverified] | Security Act chapter 10, in force 1 Jan 2019 |
| CH, TR, MX, CO, CL, CR, IS, HU, LV, LT, SI | not dated | [DATA: adoption year not looked up] | excluded from both groups; 5 candidate IJVs (TR 2, CH, MX, CO 1 each, any sector) |

| Measure | Main (CN/HK/MO, core sectors) | Broad sectors | Broad non-allied list | Any sector | Orbis, direct | Orbis, owner |
|---|---|---|---|---|---|---|
| Exposed pairs | 19 | 26 | 22 | 35 | 9 | 11 |
| Exposed IJVs | 39 | 61 | 43 | 148 | 13 | 22 |
| strategic | 7 | 11 | 9 | 24 | 2 | 4 |
| parent in Revelio | 35 | 53 | 37 | 122 | 11 | 19 |
| host-country parent | 28 | 44 | 30 | 106 | 8 | 17 |
| formed before onset | 39 | 58 | 43 | 133 | 13 | 22 |
| IJVs after hires rule (parent in Revelio) | 27 (23) | 33 (28) | 28 (24) | 66 (57) | 9 (7) | 13 (11) |
| pairs after hires rule (parent in Revelio) | 17 (15) | 19 (17) | 18 (16) | 27 (26) | 9 (7) | 10 (10) |
| IJVs after employee rule (parent in Revelio) | 36 (32) | 50 (44) | 39 (34) | 111 (93) | 12 (10) | 20 (17) |
| pairs after employee rule (parent in Revelio) | 19 (19) | 24 (23) | 22 (21) | 33 (31) | 9 (8) | 11 (11) |
| IJV-function-years, 5+ hires, pre / post | 549 / 308 | 610 / 369 | 582 / 310 | 1,214 / 799 | 56 / 45 | 198 / 102 |
| IJV-function-years, 5+ employees, pre / post | 1,269 / 1,080 | 1,695 / 1,500 | 1,431 / 1,130 | 3,350 / 2,911 | 224 / 297 | 541 / 525 |
| Total hires 2008-2025 | 24,888 | 27,621 | 25,570 | 53,236 | 1,887 | 6,174 |
| Onset years (IJVs) | 2017: 2, 2018: 7, 2019: 5, 2020: 16, 2021: 4, 2022: 2, 2023: 3 | 2017: 11, 2018: 10, 2019: 7, 2020: 22, 2021: 5, 2022: 2, 2023: 4 | as main plus 1 each in 2017 and 2018 and 2 in 2023 | 2017: 33, 2018: 16, 2019: 11, 2020: 60, 2021: 6, 2022: 14, 2023: 8 | | |
| Pre-onset years, median [range] | 11 [2-15] | 10.5 [1-15] | 11 [2-15] | 10 [1-15] | 9 [2-13] | 10 [2-15] |
| Post-onset years, median [range] | 6 [3-9] | 6 [3-9] | 6 [3-9] | 6 [3-9] | 6 [4-9] | 6 [3-9] |
| Controls (parent in Revelio; at hires rule) | 1,011 (823; 399) | 1,397 (1,129; 526) | 1,007 (821; 398) | 1,011 | 790 | 781 |
| Hard screen, hires rule / employee rule | FAIL / PASS | FAIL / PASS | FAIL / PASS | PASS / PASS | FAIL / FAIL | FAIL / FAIL |

Exposed IJVs by host (main): AU 8, US 7, CA 7, DK 4, GB 2, IL 2, IT 2, DE 2,
ES, FR, JP, LU, NL, SE 1 each. 26 of the 39 IJVs are in non-EU hosts whose
adoption years are `[unverified]`; the EU hosts alone give 13 IJVs in 10 pairs.
Of the 156 OECD-hosted IJVs with a Chinese, Hong Kong or Macao parent, 29 carry
no sector code and cannot be assigned. The sector filter removes most of
Germany's 33 such IJVs. The "any sector" column shows what the filter does; it
is not the treatment definition.

### 4.3 S19 Chinese coercion episodes

Definition. Exposed: a China-hosted IJV with a parent from a state targeted by
China, from the year of the first targeted case. Targets and dates come from
ASPI, Hanson, Currey and Beattie (2020), Appendix Table 1 (100 cases against
governments, 27 countries plus the EU, dated by month and year), transcribed
from the PDF on 2026-11-24 (Section 8). Main onset: first case of trade,
tourism or investment restrictions or a popular boycott. Variants: first case
of any type (adds threats, arbitrary detention and official-travel
restrictions), US excluded (the US-China trade conflict from 2018 overlaps and
ASPI excludes tit-for-tat trade-war measures), Hong Kong counted as part of the
China side, and a broad variant that adds IJVs hosted in a targeted state with a
Chinese parent. The EU case is not assigned to member states. Controls:
China-hosted IJVs with no parent from any ASPI target.

ASPI onsets used (first economic measure, year and month): Japan 2010-09,
Norway 2010-10, Philippines 2012-05, Vietnam 2014-05, Turkey 2016-02, Taiwan
2016-05, South Korea 2016-08, Australia 2016-09, Mongolia 2016-11, Palau
2017-11, Kenya 2018-09, Sweden 2018-09, Canada 2019-01, New Zealand 2019-02,
United States 2019-06, India 2019-08, Czech Republic 2019-10, Denmark 2019-12,
France 2020-02, Eswatini 2020-02, Netherlands 2020-04. Germany, the UK, Brazil,
Botswana, Slovakia and South Africa have threats or official-travel cases only
and enter only the "any type" variant (Germany 2019-08, UK 2012-05).

| Measure | Main | US excluded | Any type | Broad | HK as China | Orbis, direct | Orbis, owner |
|---|---|---|---|---|---|---|---|
| Exposed pairs | 10 | 9 | 12 | 15 | 11 | 9 | 12 |
| Exposed IJVs | 85 | 64 | 119 | 127 | 102 | 60 | 104 |
| strategic | 56 | 47 | 77 | 67 | 59 | 48 | 76 |
| parent in Revelio | 78 | 60 | 111 | 115 | 93 | 57 | 99 |
| host-country parent | 78 | 60 | 108 | 108 | 88 | 59 | 103 |
| IJVs after hires rule (parent in Revelio) | 21 (20) | 16 (15) | 34 (32) | 44 (40) | 27 (25) | 15 (15) | 21 (21) |
| pairs after hires rule (parent in Revelio) | 6 (6) | 5 (5) | 8 (8) | 12 (11) | 6 (6) | 6 (6) | 7 (7) |
| IJVs after employee rule (parent in Revelio) | 60 (55) | 43 (39) | 81 (75) | 92 (83) | 70 (64) | 43 (40) | 65 (62) |
| pairs after employee rule | 8 | 7 | 9 | 12 | 9 | 8 | 11 |
| IJV-function-years, 5+ hires, pre / post | 446 / 265 | 280 / 203 | 701 / 400 | 805 / 530 | 480 / 316 | 310 / 200 | 358 / 206 |
| Total hires 2008-2025 | 19,651 | 11,872 | 31,187 | 31,655 | 21,578 | 12,147 | 12,184 |
| Onset years (IJVs) | 2010: 34, 2016: 12, 2019: 25, 2020: 14 | 2010: 34, 2016: 12, 2019: 4, 2020: 14 | 2010: 34, 2012: 17, 2013: 2, 2014: 1, 2016: 12, 2019: 39, 2020: 14 | 2010: 35, 2014: 1, 2016: 26, 2018: 2, 2019: 47, 2020: 16 | 2010: 39, 2016: 16, 2019: 29, 2020: 18 | | |
| Pre-onset years, median [range] | 8 [1-12] | 2 [1-12] | 7 [1-12] | 8 [1-12] | 8 [1-12] | 2 [1-12] | 8 [1-12] |
| Controls (parent in Revelio; at hires rule) | 296 (224; 47) | 296 | 296 | 296 | 332 (254; 65) | 247 | 184 |
| Hard screen, hires rule / employee rule | FAIL / FAIL | FAIL / FAIL | FAIL / FAIL | FAIL / FAIL | FAIL / FAIL | FAIL / FAIL | FAIL / FAIL |

Exposed IJVs by pair (main): CN-JP 33, CN-US 21, CN-KR 10, CN-NL 8, CN-FR 7,
CN-TW 3, CN-DK 2, CN-CA 1, CN-IN 1, CN-NO 1. The pair count, not the IJV count,
is the binding constraint: only ten targeted states have China-hosted IJVs in
`core_main`.

### 4.4 S09 US Entity List

Source. Consolidated Screening List (trade.gov), downloaded on 2026-11-24:
26,339 rows, of which 3,427 Entity List entries (2,653 listed 2008 to 2023).
Each entry carries a `start_date` (listing date) and its Federal Register
citations; spot checks match the known listings (Huawei and affiliates
2019-05-21, SMIC 2020-12-18). Where `start_date` is blank (161 entries), the
year of the first Federal Register citation is used.

Match. Entry names and aliases, normalized with `normalize_name()`, against
the names of direct parents and their owners (GUO) in `core_main`, with the
country of the entry's address equal to the parent's country. Strict rule: the
names are equal, or the entry adds one alias token that repeats a name word,
gives the initials, or is a Russian legal form. Group rule: a listed entry is a
named unit of the parent's group (the parent's name of at least two words is
the start of the entry's name). Row-level matches with names are in
`data/interim/shock-s09-entity-list-matches-2026-11-24.csv` for a person to
check.

| Measure | Strict | Group |
|---|---|---|
| IJVs with a name match (any listing year) | 11 | 15 |
| Exposed IJVs (listing up to 2023) | 8 | 12 |
| parent in Revelio | 6 | 9 |
| Exposed pairs | 9 | 11 |
| IJVs after hires rule (parent in Revelio) | 3 (2) | 3 (2) |
| IJVs after employee rule (parent in Revelio) | 6 (5) | 9 (8) |
| Onset years | 2014: 2, 2020: 2, 2021: 1, 2022: 1, 2023: 2 | adds 2001: 1, 2014: 2, 2020: 1 |
| Hard screen | FAIL | FAIL |

S09 survives neither rule: it does not reach the 30 exposed IJVs that gate 5a
set as the condition for keeping it, even before thresholds. It is dropped, and
S10 (2022 semiconductor rules) is not folded in.

## 5. Extrapolation beyond `core_main`

`core_main` is the full matched frame, not a pilot draw, so these counts are
population counts for the analysis sample. The enlargement that gate 4
(decisions 4, 5 and 7) puts before stage 6 is the manual worklist (priorities 1
and 2) and, later, SDC. The script counts exposure among the 2,777 worklist IJVs
of priorities 1 and 2 that are not in `core_main`, from the host and parent
countries recorded in the frame (no Revelio data exist for them).

| Shock | Worklist IJVs exposed | Pairs | New pairs | Added IJVs after hires rule, if all were matched |
|---|---|---|---|---|
| S13 | 65 | 16 | 0 | about 29 |
| S06 | 10 | 10 | 3 | about 7 |
| S19 | 369 | 12 | 5 | about 91 |

Assumptions: every worklist IJV is matched and usable (an upper bound; the
match yield of the worklist is `[DATA: match rate of the manual worklist after
the research assistant's pass]`), and the ratio of thresholded to exposed IJVs
equals that of `core_main` (S13 175/394, S06 27/39, S19 21/85). Under these
assumptions S13 stays well above the screen, S06 could reach about 30 IJVs under
the hires rule, and S19 could reach many IJVs but at most 15 exposed pairs (10
plus 5), all of which would need a thresholded IJV to meet the pair screen.
Revelio coverage of China-hosted staff is weak (Phase A data inventory), so the
S19 ratio is likely lower for the worklist, which is dominated by China-hosted
IJVs. The owner-country basis adds S13 and S19 exposure (Sections 4.1, 4.3) but
is a robustness count only.

## 6. Rescored criteria

Measurement quality and substantive interest are left unchanged; H4 gives no
reason to move them. Two notes for the PI: the ASPI case file is now verified
and month-dated, which would justify raising S19's measurement score from 3 to 4
if the PI wishes; and S06's adoption years for non-EU hosts are unverified and
the sector mapping is the agent's, which argues against raising S06.

| ID | Fit (scan to now) | Measurement | Identification (scan to now) | Coverage (scan to now) | Interest | Equal weights (scan to now) | Hard screen |
|---|---|---|---|---|---|---|---|
| S13 | 5 to 4 | 5 | 4 to 4 | 5 to 5 | 3 | 4.40 to 4.20 | PASS |
| S06 | 3 to 3 | 4 | 4 to 3 | 3 to 2 | 4 | 3.60 to 3.20 | PASS_PROVISIONAL |
| S19 | 5 to 5 | 3 | 4 to 3 | 3 to 2 | 4 | 3.80 to 3.40 (indicative) | FAIL |
| S09 | 5 to 2 | 4 | 4 to 2 | 2 to 1 | 5 | 4.00 to 2.80 (indicative) | FAIL |

Reasons.

- S13 fit 4: alters the environmental (regulatory) contingency of some
  functions, which is the H4 channel, but also the mobility of staff in every
  function, which is not a change in local embeddedness. Coverage 5: 28 exposed
  pairs; 175 thresholded IJVs in 25 pairs (136 in 23 pairs with a parent in
  Revelio), hosted in the UK and across the EU, EEA and Switzerland.
  Identification 4: one dated
  onset, plausibly exogenous to IJV staffing, 3,409 never-treated controls
  (1,273 at threshold), 13 pre-years; not 5 because the onset coincides with
  COVID-19 and follows four years of anticipation, and all units are treated at
  once.
- S06 fit 3: raises the requirement for host-country personnel in
  security-sensitive functions, but mitigation also limits the non-allied
  parent's access, so coordination dependence changes as well, against the H4
  condition. Coverage 2: 39 exposed IJVs, 23 to 32 after thresholds, 15 to 19
  pairs. Identification 3: staggered onsets with not-yet-treated hosts and an
  allied-parent comparison group in the same hosts and sectors, but onsets are
  plausibly endogenous to Chinese investment, 16 of 39 fall in the COVID year
  2020, existing IJVs are only weakly treated, and two thirds of the exposure
  rests on unverified dates.
- S19 fit 5: raises the local-legitimacy requirement of customer- and
  government-facing functions while the technical functions' coordination with
  the foreign parent is unchanged, and 78 of 85 exposed IJVs have a host-country
  (Chinese) parent, so the H4 channel can be observed. Coverage 2 and
  identification 3: 6 to 11 thresholded pairs (too few clusters), 34 of 85 IJVs
  have the 2010 Japanese onset with two pre-years, only 47 controls reach the
  threshold, and the US pairs overlap the trade conflict.
- S09 fit 2: technology restrictions change the resource and coordination
  contingencies, not local embeddedness. Coverage 1 and identification 2: 3
  thresholded IJVs.

## 7. Weight sensitivity

Weights (fit, measurement, identification, coverage, interest): equal 0.2 each;
fit-heavy 0.40/0.15/0.15/0.15/0.15; feasibility-heavy
0.125/0.25/0.25/0.25/0.125; identification-heavy 0.15/0.15/0.40/0.15/0.15. The
PI chose equal weights (gate 5a, decision 1); the others are shown for
robustness. Only S13 and S06 are ranked; S19 and S09 are shown as indicative
scores because they fail the hard screen.

| ID | Equal | Fit-heavy | Feasibility-heavy | Identification-heavy |
|---|---|---|---|---|
| S13 | 4.20 (1) | 4.15 (1) | 4.38 (1) | 4.15 (1) |
| S06 | 3.20 (2) | 3.15 (2) | 3.13 (2) | 3.15 (2) |
| S19 (indicative) | 3.40 | 3.80 | 3.13 | 3.30 |
| S09 (indicative) | 2.80 | 2.60 | 2.63 | 2.60 |

The ranking of the two admissible candidates does not change under any scheme.
If S19 were admitted despite the screen, it would rank second under equal,
fit-heavy and identification-heavy weights and tie S06 under feasibility-heavy
weights; S13 stays first throughout.

Other sensitivities. (a) Cell rule: S13 passes under both; S06 passes only under
the employee rule; S19 and S09 fail under both. (b) Verified dates only: S06
falls to 13 exposed IJVs and fails. (c) Owner-country basis: S13 and S19 gain
exposure, S06 stays below the screen on the Orbis subset. (d) S13 without
Ireland: 162 thresholded IJVs in 24 pairs, still a pass.

## 8. Verification of the pages blocked on 2026-10-04

Retried on 2026-11-24 with WebFetch (decision 7 of gate 5a). Pages that opened
are marked verified for what they show; the rest stay `[unverified]` for a
person to check before gate 5.

| Source | Result | What it confirms |
|---|---|---|
| ASPI report page, aspi.org.au/report/chinese-communist-partys-coercive-diplomacy | still blocked (HTTP 403) | |
| APO record, https://apo.org.au/node/307991 | opened | title, authors (Hanson, Currey, Beattie), ICPC/ASPI, 1 Sep 2020, link to the PDF |
| ASPI PDF, https://s3-ap-southeast-2.amazonaws.com/ad-aspi/2020-08/The%20CCPs%20coercive%20diplomacy_0.pdf | opened (68 pages, text extracted) | Policy Brief 36/2020; Appendix Table 1 with 100 dated government cases in 27 countries plus the EU, which matches the scan's snippet; method and exclusions (US-China trade war and India-China border measures not counted) |
| ASPI Strategist article (aspistrategist.org.au) | opened | 152 cases, 2010 to 2020 |
| OECD investment security page and "Investment screening in times of COVID-19 and beyond" | still blocked (HTTP 403) | |
| PRISM record, collaborate.princeton.edu | opened | Bauerle Danzman and Meunier, International Studies Quarterly 67(2), sqad026, 2023; OECD countries 2007 to 2021; seven features; no data download on the page. The dataset itself was not obtained |
| European Commission investment screening page, policy.trade.ec.europa.eu | opened | Regulation 2019/452 fully applies since 11 Oct 2020; link to the list of national mechanisms |
| EC list of screening mechanisms (circabc, last update 9 Feb 2026) | opened (31 pages, read as images) | instruments and dates for 25 member states, used for the EU onsets in Section 4.2 |
| EUR-Lex text of Regulation 2019/452 | empty response | |
| legislation.gov.uk, Regulation 2019/452 Art. 4 as adopted | opened | the five Article 4(1) factor groups used for the screened sectors (quoted only in part by the fetch tool) |
| Federal Register document pages (federalregister.gov, ecfr.gov) | redirected to a bot check (unblock.federalregister.gov) | |
| Federal Register API, document 2020-18213 | opened | Huawei non-US affiliates rule: 85 FR 51596, published 20 Aug 2020, effective 17 Aug 2020 |
| BIS Entity List page, bis.gov/entity-list | responded, but the page exceeded the 10 MB fetch limit and was not read | |
| Consolidated Screening List page, trade.gov | opened | 13 lists incl. the Entity List; CSV, TSV and JSON downloads. The CSV (downloaded) carries `federal_register_notice` and `start_date` for Entity List entries; current entries only, so removed parties are missing |
| 15 CFR 791.4, law.cornell.edu | opened | the six foreign adversaries used for the broad non-allied list |
| UK immigration statistics, release for the year ending Sep 2025 (gov.uk) | opened | topics only; no table names on the page |
| UK immigration system statistics data tables (gov.uk) | opened | Occ_D01 and Occ_D02: entry clearance visa applications and grants by occupation, industry and nationality (SOC 2020 to the year ending June 2026; SOC 2010 to March 2024); CoS_D01 and CoS_D02 (certificates of sponsorship by industry and by nationality, discontinued Dec 2024). First years not stated: `[DATA: start year of Occ_D02]` |
| gov.uk guidance for EU citizens on the points-based system | opened | "Free movement between the UK and the European Union ended on 31 December 2020"; points-based system from 1 Jan 2021; addressed to EU, EEA and Swiss citizens; Irish citizens excepted |
| Non-EU screening dates (US, GB, AU, CA, NZ, JP, KR, IL, NO) | search snippets only | `[unverified]` |

Sources not on the shortlist (GSDB, TIES, GPR, GDELT, UNCTAD IPM, Harvard
Dataverse) were not retried.

## 9. Recommendation for the PI

### Focal shock: S13, Brexit and the end of UK-EU free movement

Fit memo against H4. Mechanism: the end of the transition period (31 December
2020) separated UK and EU regulation, customs, product approval and tax
administration. In a UK-hosted IJV with an EU parent, or an EU-hosted IJV with
a UK parent, functions that deal with host regulators, customs, compliance,
taxation and employment law now need host-specific knowledge that the other
jurisdiction's staff no longer have. That is a rise in the local-embeddedness
requirement of those functions. Their coordination dependence on the parents is
unchanged, because the parents' activities and the IJV's tasks are the same.
The same date also ended free movement, which raised the cost of hiring
EU nationals into UK IJVs and UK nationals into EU IJVs in every function, and
which may close the intra-company route for parent-to-IJV transfers where the
IJV is not group-linked to the parent (`[DATA: Home Office rule on whether a
minority-held joint venture counts as a linked entity for the Senior or
Specialist Worker route]`).

Predictions at the contingency level. H1 to H3 serve as the static baseline in
all IJVs. H4: after 2021, in exposed IJVs relative to controls, the local share
of new hires rises more in functions whose local-embeddedness requirement rose
(regulatory-facing functions) than in other functions; within the rise, local
parent-origin hires grow where coordination dependence is high and independent
local hires where it is low. The mobility channel predicts a rise of local
hiring in every function and a fall of international parent-origin hires
independent of embeddedness; this is the competing pattern the design has to
separate.

Data. Exposure from host and parent countries (`06_shock_exposure.R`);
optional intensity from UK entry-clearance grants by industry and nationality
(Occ_D02). Revelio's role_k10 has no legal or compliance category; the gate 5
function map would have to carve regulatory-facing roles out of role_k50
(`[DATA: role_k50 categories that identify legal, compliance, customs and tax
roles]`), and the change in local embeddedness per function needs a source fixed
before outcomes are seen (open item of 2026-11-23 in `docs/decisions.md`).

Identification design. Hiring flows per IJV x function x year, 2008 to 2025.
Treatment: exposed IJV x post-2021 x the function's change in local
embeddedness, with coordination dependence as the moderator of the channel.
Fixed effects: IJV x year (absorbs the uniform part of the mobility shock and
every IJV-wide change, including sterling and demand), IJV x function, and
function x year (absorbs function-specific COVID-19 effects common to exposed
IJVs and controls); host x year is collinear with IJV x year and is not needed.
An event study around 2021 with 2013 to 2015 as the clean pre-period and 2016
to 2020 reported as the anticipation window. Controls: never-treated IJVs in the
UK and the EU, EEA and Switzerland without a UK-set link (3,409; 1,273 at the
hires rule). Within-shock contrast: GB-IE IJVs (31) get the regulatory change
but keep free movement for Irish nationals, which separates the two channels.
Inference: clustering by country pair gives 25 clusters after thresholds, so a
wild cluster bootstrap is needed, with IJV clustering as a check.

Main threats. (1) The mobility channel acts on the same outcome; it is
differenced out only where it is uniform across functions within an IJV-year,
and salary floors make it bite more in junior and lower-paid roles, so a level x
exposure x post term is needed. (2) Onset concurrent with COVID-19 and preceded
by four years of anticipation (exits, restructuring, early relocation). (3)
Survivor bias: the frame holds only IJVs alive today, so IJVs dissolved because
of Brexit are missing. (4) All exposed units share one onset, so the design
rests on the never-treated comparison. (5) The H4 channel uses the local
parent-origin cell, which is about 0.8 percent of hires overall
(`reviews/gate-4-pilot.md`); whether it supports the function split in 136
thresholded IJVs cannot be checked without tabulating outcomes, which the
independence rule forbids until the shock is fixed. (6) Admissibility as a
geopolitical shock was settled by the PI (gate 5a, decision 4), but the paper
has to frame it as a change in the political order between states.

### Fallback: S06, staggered investment screening

Fit memo against H4. Mechanism: once a host screens acquisitions by non-allied
investors in sensitive sectors, IJVs with a Chinese parent face closer
regulatory scrutiny, and mitigation conditions often require host-country
personnel in security-relevant roles and limit the foreign parent's access to
data and technology. Security-sensitive functions (IT, R&D, engineering,
operations of critical assets) need more host-specific personnel. But the
non-allied parent's access is cut at the same time, so coordination dependence
on that parent also falls, which violates the H4 condition. Predictions: H4 in
its geographic part (the local share rises in sensitive functions); the channel
part is ambiguous, because the shift may go to the host-country parent's staff
or to the market for reasons of access rather than coordination. The pattern is
closer to the "independence without localization" hypothesis that the brief set
aside (Appendix D) than to H4.

Data. Host adoption years (EC list for EU hosts; non-EU hosts to be verified),
sector scope from Article 4 of Regulation 2019/452 mapped to NACE, parent
countries from Orbis. PRISM (Bauerle Danzman and Meunier 2023) would give coded
mechanism features for 2007 to 2021 if obtained.

Identification design. Staggered triple difference (host onset x non-allied
parent x screened sector) with heterogeneity-robust estimators
(Callaway-Sant'Anna or imputation), not-yet-treated hosts and allied-parent
IJVs in the same hosts and sectors as controls (1,011; 399 at threshold), and a
within-IJV contrast between sensitive and other functions.

Main threats. Screening acts on new transactions, so existing IJVs are treated
only weakly and mostly when ownership changes; mitigation agreements are not
observed; host adoption responds to Chinese investment waves; 16 of 39 onsets
fall in 2020; power is borderline (23 to 32 thresholded IJVs, 15 to 19 pairs);
and 26 of 39 exposed IJVs depend on unverified adoption years.

### Not recommended

S19 is the closest theoretical match to H4 but fails the pair screen under every
variant (at most 12 thresholded pairs). It could serve as a descriptive case
study, or enter a pooled design with S06 if the PI wanted one class of
"political sensitivity" shocks; neither is proposed here. S09 is dropped.

### Plain statement on identification

No candidate scores well enough to reach 5 on identification. S13 reaches 4
because its onset is discrete and plausibly exogenous to IJV staffing, but it is
a single common onset that coincides with COVID-19 and follows a long
anticipation period. S06 and S19 reach 3. Any causal reading of H4 will rest on
the within-IJV contrast across functions more than on the timing of the shock.

## 10. Items marked `[DATA]` or `[unverified]`

- `[unverified]` Adoption years of investment screening in the US, UK,
  Australia, Canada, New Zealand, Japan, Korea, Israel and Norway (search
  snippets only); 26 of S06's 39 exposed IJVs depend on them.
- `[DATA]` Adoption years for Switzerland, Turkey, Mexico, Colombia, Chile,
  Costa Rica, Iceland, Hungary, Latvia, Lithuania and Slovenia (not looked up;
  5 candidate IJVs).
- `[unverified]` The OECD screening pages and the ASPI report page (still
  blocked); the BIS Entity List page (too large to read); the Federal Register
  HTML pages (bot check). The content needed was obtained from the API, the PDF
  and the CSL instead.
- `[DATA]` First year of the UK tables Occ_D01 and Occ_D02.
- `[DATA]` Whether a minority-held IJV counts as linked for the UK intra-company
  route.
- `[DATA]` Revelio role_k50 categories that identify regulatory-facing roles.
- `[DATA]` Match rate of the manual worklist (for the extrapolation).
- The NACE, NAICS and Capital IQ mapping of screened sectors and the 2017 lower
  bound for S06 onsets are the agent's choices.
- The S09 name matches are automatic; a person can check the 15 matched IJVs in
  the interim file, but no plausible correction brings S09 near 30.
- References used here (ASPI 2020, Bauerle Danzman and Meunier 2023, Regulation
  2019/452, the EC list) are not in `literature/references.bib` and are
  `[unverified]` there until the reference-manager adds them.

## 11. Open questions for the PI

1. Which cell rule binds the hard screen for a hiring-flow hypothesis: 5
   employees (the gate 4 rule, under which S06 passes) or 5 hires (under which
   it fails)?
2. Focal shock: accept S13, with S06 as fallback?
3. S13 design: accept parent-host pairs as the exposure (third-country
   parent-parent pairs left out), 2021 as onset with 2016 to 2020 as an
   anticipation window, and GB-IE as a within-shock contrast?
4. S06, if kept as fallback: confirm the 2017 lower bound, the non-allied list
   (China, Hong Kong, Macao; 15 CFR 791.4 as the broad variant) and the sector
   mapping, and have a person verify the nine non-EU adoption years.
5. Should the measurement score of S19 rise from 3 to 4 now that the ASPI case
   file is verified? It does not change the outcome, because S19 fails the hard
   screen.
6. The contingency score for the change in local embeddedness per function
   (needed by H4 for any shock) still has no source; it has to be fixed before
   the staffing outcomes are examined.

## 12. Edits proposed for files outside this stage (not made)

- `docs/decisions.md`: record the rescoring result and the PI's choice at gate
  5; add open items 1, 3, 4 and 6 above; record that S09 was dropped (8 exposed
  IJVs) and S10 not folded in.
- `data/data-log.md`: one entry for the three external files in
  `data/raw/external/` (Consolidated Screening List CSV, ASPI PDF, EC list PDF).
- `data/README.md` (and the folder map, via `/research-organizer`): mention the
  new folder `data/raw/external/` for public source files.
- `reviews/gate-5-pre-analysis-plan.md`: the chosen shock's definition, onset,
  controls and the counts in this file once the PI decides.
- `data/codebook.md`, section "Shock": the exposure definition of the chosen
  shock (pair, onset, variants) once decided.
- `literature/references.bib`: add the ASPI report, Bauerle Danzman and Meunier
  (2023), Regulation (EU) 2019/452 and the EC list through `/references` if the
  pre-analysis plan cites them.
