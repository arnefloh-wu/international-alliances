# Gate 5a: Shock shortlist

Status: PENDING
Approved by:
Stage: 5a Shock scan (`/shock-options scan`, Phase A)
Agent: shock-evaluator
Date produced: 2026-10-04

## Deliverables

| Deliverable | Path | Notes |
|---|---|---|
| Long list and contingency map | `literature/shock-scan/candidates.md` | 30 candidates in 8 families (sanctions; investment screening; export controls; mobility; bilateral political deterioration; data rules; ownership caps and governance; tariffs). Exposure channels and dyad-counting rule defined. Uniform or unclear predictions marked. |
| Literature scan | `literature/shock-scan/literature-scan.md` | WebSearch only. Studied versus underexplored by family; closeness to our design. All references `[unverified]` with URL. |
| Data inventory | `literature/shock-scan/data-inventory.md` | Shock-side sources and outcome-side constraints. WebFetch blocked for every documentation host; entries record search snippets only, all `[unverified]`. |
| Scoring | `literature/shock-scan/scoring.csv` | Five criteria scored 1 to 5, equal-weight score, hard-screen result, notes. Failed candidates have `weighted_score = NA` and are not ranked. |
| Recommendation | `literature/shock-scan/recommendation.md` | Shortlist, fit memos, coverage-proxy reasoning, weight sensitivity, failed candidates, open questions. |

## Independence rule

The independence rule was followed. No integration outcome (cross-parent
integration, parent dominance, localization) was computed, inspected or
reported by exposure status. No Orbis or Revelio data exist in the
repository. The shortlist rests on exposure logic, design properties and
literature only.

## Shortlist proposed for the PI

| Rank (equal weights) | ID | Candidate | Weighted score | Note |
|---|---|---|---|---|
| 1 | S13 | Brexit: end of UK-EU free movement (1 Jan 2021; referendum 23 Jun 2016) | 4.40 | admissibility as "geopolitical" is a PI decision |
| 2 | S09 | US Entity List designations of IJV parent firms (staggered) | 4.00 | passes hard screen H3 only provisionally |
| 3 | S19 | Staggered Chinese coercion episodes against partner states (ASPI 2010 to 2020) | 3.80 | China outcome coverage uncertain |
| 4 | S06 | Staggered adoption of investment screening in OECD hosts | 3.60 | weak treatment of pre-existing IJVs |
| reserve | S02 | Russia 2022 sanctions and Russian countermeasures | 3.60 | outcome coverage in Russia likely thin since Nov 2016 |

Sample coverage was scored from proxies (dyads and hosts touched, plausible
IJV activity, Revelio coverage of hosts) and is provisional until
`/shock-options rescore`. No candidate reaches 5 on identification; the best
is 4.

## Weights used

Default equal weights (0.2 each on fit, measurement, identification,
coverage, interest). Sensitivity: fit-heavy (0.40/0.15/0.15/0.15/0.15),
feasibility-heavy (0.125/0.25/0.25/0.25/0.125), identification-heavy
(0.15/0.15/0.40/0.15/0.15). The top three (S13, S09, S19) are unchanged
under equal, fit-heavy and identification-heavy weights; under
feasibility-heavy weights S06 ties S19 for third. Full table in
`recommendation.md`, section 4.

## Hard screens (defaults, flagged as assumptions)

H1 dated onset at year resolution or finer. H2 measurable for the dyads in
the sample frame (exposure assignable from a documented source; the shock
must not itself remove the outcome data). H3 expected exposure of at least
about 15 dyads and about 30 IJVs after cell thresholds, read to require
post-onset IJV-function-years inside the panel window. These readings of H2
and H3 are the agent's interpretation and need the PI's confirmation.

## Candidates that failed hard screens (not ranked)

| ID | Candidate | Reason |
|---|---|---|
| S03 | Iran 2018 secondary sanctions | H3, few observable Iran-linked IJVs (provisional) |
| S04 | Russia-Turkey 2015 to 2017, incl. Turkish worker ban | H3, single dyad |
| S07 | India-China 2020 bundle (Press Note 3, Galwan, app bans, visas) | H3, one main dyad |
| S08 | US outbound investment rule (2 Jan 2025) | H3, single dyad, no post-period |
| S10 | US semiconductor rules (7 Oct 2022) | H3, one sector, mainly one host (provisional) |
| S11 | Japan-Korea 2019 export controls | H3, single dyad |
| S12 | China export controls 2023 to 2025 | H2 not dyadic; H3 no post-period |
| S15 | China Initiative (2018 to 2022) | H2 no IJV exposure rule; H3 single dyad |
| S17 | US 2025 mobility measures | H3, no post-period |
| S20 | Qatar blockade (2017 to 2021) | H3, four dyads |
| S21 | US-China bundle from 2018 | H3, single dyad (components scored separately) |
| S23 | Russia data-localization law (2015) | H2, its enforcement blocked LinkedIn in Russia (17 Nov 2016), removing outcome data |
| S25 | China auto ownership-cap removal (2018 to 2022) | H3, one sector, about eight partner countries (provisional) |
| S26 | India insurance FDI cap (2021) | H3, one host and sector, likely under 15 dyads (provisional) |
| S28 | State takeovers (Russia 2023; Nexperia 2025) | H3, a handful of firms |
| S29 | US Section 301 tariffs (2018 to 2019) | H3, single dyad; predictions uniform/unclear |
| S30 | US 2025 reciprocal tariffs | H3, no post-period; predictions uniform/unclear |

## Quality checks run

- All five Phase A deliverables exist in `literature/shock-scan/`.
- Every candidate has a family, country pair or host, date(s), instrument and
  source URL, or a `[DATA: ...]` marker where a date was not found.
- Every reference carries a URL and `[unverified]`; author lists are
  truncated where the snippet did not show them.
- Scores follow the anchors in the agent definition; equal-weight scores and
  alternative-weight ranks were computed by a scratch script (arithmetic
  only, no project data), and the ranks in `recommendation.md` match
  `scoring.csv`.
- Consensus connector not used (plan not upgraded per `docs/decisions.md`).
- S9 Google Scholar variants S9a to S9e run verbatim as WebSearch queries.
- No outcome by exposure status was computed or reported.

## Known weaknesses and uncertainties

- Verification: the egress proxy refused WebFetch for every documentation
  host tried (GSDB, TIES, GPR, OECD, UNCTAD, Harvard Dataverse, GDELT, BIS,
  Federal Reserve, Drexel). Dataset coverage, episode dates and literature
  details come from WebSearch snippets only.
- Data sources whose properties were seen in snippets (unverified): GSDB-R4
  (1950 to 2023, dyadic, on request), TIES v4 (1945 to 2005), UNGA ideal
  points (1946 to 2024, Dataverse), GDELT (1979 onward), ICEWS (ended
  11 Apr 2023) and POLECAT, Caldara-Iacoviello GPR (1985 onward, 44 country
  indexes, not dyadic), OECD FDIRRI (1997 to 2020 and a non-comparable new
  series), UNCTAD IPM (from 1992; reclassified back to 2012), PRISM (OECD 2007
  to 2021), BIS Entity List via Federal Register, DEMIG VISA (1973 to 2013),
  IMPIC (1980 to 2018), ASPI coercion cases (2010 to 2020), Global Trade
  Alert (from Nov 2008), Yale CELI and KSE lists.
- Not seen at all: EUSANCT coverage, Consolidated Screening List history,
  Tsinghua relations database structure, UK visa statistics by sector or
  nationality, a data-rule intensity index, Revelio country-level coverage
  rates.
- Coverage scores are proxies; S09's hard-screen pass is provisional.
- No interview-derived triggers: `literature/synthesis/qual-measurement-memo.md`
  does not exist yet. Revisit the long list after Stage 3.
- Revelio coverage of China- and Russia-hosted workforces is likely weak
  (LinkedIn blocked in Russia since 2016; main LinkedIn China platform closed
  2021), which affects S01, S02, S05, S19, S22, S27.
- Brexit tops the ranking but sits awkwardly with H4/H5 as written
  ("deterioration in political relations").

## Decisions required from the PI

1. Weights: keep equal weights or choose an alternative (top two are stable
   under all four schemes tried).
2. Shortlist: approve, amend or replace S13, S09, S19, S06 (with S02 in
   reserve) for pilot-based re-scoring.
3. Hard screens: confirm the defaults and the agent's readings of H2 and H3,
   and decide whether single-dyad shocks with many IJVs (US-China,
   India-China, Japan-Korea, Russia-Turkey) may enter via within-dyad
   designs.
4. Admissibility: is Brexit an admissible geopolitical contingency? Are
   non-geopolitical regulatory shocks (S26 India insurance cap, S27 China
   Foreign Investment Law) admissible fallbacks?
5. Panel window: confirm the Revelio licence end date (decides whether 2025
   onsets can have a post-period).
6. Pilot design (gate 4): oversample China-hosted IJVs to measure Revelio
   coverage there, and include known UK-EU IJVs and Entity-List-linked
   parents so rescore can count exposure for the shortlist.
7. Verification: who opens the documentation of the shortlisted sources
   (GSDB-R4, PRISM, ASPI case file, Federal Register Entity List rules, UK
   visa statistics) before gate 5, given the network block?
8. Combinations: fold S10 into S09 as an intensity layer; keep S18 as a
   continuous moderator for S19 rather than as a stand-alone shock?

## Proposed changes to earlier stages

- `literature/search/screening.csv` (lit-search stage): add the S9 records
  found here as `S9` rows for screening, in particular Sawant et al. 2026
  (JIBS), Tian, Xu & Yiu 2025 (JoM), Liu 2026 (JMS), Zhou, Li & Wang 2024
  (JIBS), Evenett & Pisani 2023 (JIBP), Andrews, Puhr & Knill 2026 (JIBP),
  Sinani et al. 2026 (IBR, already S5), Zhang 2024 (RIPE), Glennon
  (Management Science), Eichenauer & Wang 2024 (Kiel WP), Bauerle Danzman &
  Meunier 2023 (ISQ), Crosignani et al. 2024 (NY Fed), Makioka & Zhang 2024
  (JJIE), Bai et al. (AER). All `[unverified]`; URLs in `literature/shock-scan/literature-scan.md`.
- `literature/search/search-strings.md` (lit-search stage): record that the
  S9 Google Scholar variants were run as WebSearch queries on 2026-10-04 by
  the shock-evaluator (records not exported; WebSearch returns no hit list).
- `literature/search/protocol.md`, S9 data-source seeds: search snippets
  point to Bailey, Strezhnev & Voeten 2017 in the Journal of Conflict
  Resolution and Caldara & Iacoviello in the American Economic Review
  (aeaweb.org article page seen), consistent with the protocol; Felbermayr et
  al. GSDB papers appear on WIFO and WU Vienna pages. Still unverified.
- Gate 4 (pilot): see decision 6.

## PI notes (filled in by the PI; applied by the orchestrator if status is APPROVED WITH CHANGES)

- 
