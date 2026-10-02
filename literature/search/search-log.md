# Search log (PRISMA-style), Stage 1 literature search

Date: 2026-10-02. Agent: literature-searcher. Protocol: `protocol.md` v1.0. Strings: `search-strings.md`. Screening sheet: `screening.csv`. Seed checks: `seed-verification.md`.

## Status in one paragraph

Only Consensus has been run. Web of Science, EBSCO Business Source and Google Scholar have not been run: the agent has no access to them and `literature/search/exports/` is empty. No hits are reported for those three databases, and every count below therefore describes a Consensus-plus-seed-list corpus, not the full systematic search the protocol specifies. The screening decisions are provisional and must be redone for the records that arrive from the manual runs.

## Databases and searches

| Database | Access | Streams run | Date | Strings logged | Records |
|---|---|---|---|---|---|
| Consensus (stream searches) | agent, free tier, no filters, 10 results per query | S1 to S6, one query each | 2026-10-02 | yes, `search-strings.md` and top of each `hits-consensus-S<n>-2026-10-02.md` | 60 (10 per stream) |
| Consensus (citation chase) | agent | S1 (2 queries), S2, S3 (2), S4, S5, S6 | 2026-10-02 | yes, `search-strings.md`, "Consensus run log" | 80 raw results from 8 queries (see limits below) |
| Consensus (seed verification) | agent | S2, S4, S5 | 2026-10-02 | yes | 29 results, used only to verify seeds, not counted as hits |
| WebSearch (seed verification, one pilot citation check) | agent | all seeds | 2026-10-02 | queries listed in `seed-verification.md` | not counted as hits |
| Web of Science Core Collection | manual (PI) | none | not run | strings final | 0 (not run) |
| EBSCO Business Source | manual (PI) | none | not run | strings final | 0 (not run) |
| Google Scholar (Publish or Perish) | manual (PI) | none | not run | strings final | 0 (not run) |

Run mechanics. The Consensus rate limiter rejected several calls issued in parallel (S1 and S3 in the first batch, S4 and S5 in the second, one S2 chase). Rejected calls returned no records and are not counted; each was re-run singly and only the successful run is logged. Consensus returns no DOI field, so no record from Consensus carries a DOI unless a seed source showed one.

## PRISMA flow (title/abstract stage)

| Step | n | Notes |
|---|---|---|
| Records identified, Consensus stream searches | 60 | S1 10, S2 10, S3 10, S4 10, S5 10, S6 10 |
| Records identified, seed list (protocol) | 28 | 6 already retrieved by Consensus, 22 added only as seeds |
| Records identified, citation chase (Consensus) | 80 | 8 queries; approximate chase, see limits |
| Records identified, Web of Science / EBSCO / Google Scholar | 0 | not run |
| Total records identified | 168 | |
| Duplicates removed (F_duplicate) | 33 | 6 seed/Consensus overlaps merged into one row each (Ghoshal & Nohria 1989, Yan & Gray 1994, Mjoen & Tallman 1997, Luo et al. 2001, Schaan 1983, Harzing 2001) plus 27 chase results already in the sheet (rows flagged `F_duplicate` with the retained id in `notes`) |
| Unique records | 135 | rows in `screening.csv` that are not F_duplicate |
| Seeds, included without screening | 28 | `title_abstract_decision = seed` |
| Records screened on title/abstract | 107 | 54 Consensus (non-seed) + 53 chase |
| Excluded at title/abstract | 21 | reasons below |
| Marked unsure, to full text | 19 | |
| Marked include, to full text | 67 | |
| Provisionally included for synthesis (seeds plus includes) | 95 | pending full-text screening and PI approval at G1 |
| Records proceeding to full-text screening (seeds, includes, unsure) | 114 | full text not yet retrieved; `full_text_decision = pending` |

Exclusion reasons at title/abstract (excluding duplicates).

| Code | n | Records |
|---|---|---|
| A_level | 3 | CON-S1-07, CON-S2-02, CON-S2-03 |
| B_formation | 2 | CON-S5-02, CC-S3-18 |
| C_nonscholarly | 1 | CC-S1-04 (Sloan working paper precursor of a seed) |
| D_language | 0 | |
| E_offtopic | 15 | CON-S2-08, CON-S6-07, CON-S6-08 and 12 chase records (see sheet) |
| F_duplicate | 33 | counted above under duplicates, 27 of them as rows |

## Per-stream counts (unique records)

| Stream | Consensus hits | Seed-only | Chase unique (raw, dup) | Unique total | Seeds | Include | Unsure | Exclude |
|---|---|---|---|---|---|---|---|---|
| S1 | 10 | 4 | 16 (20, 4) | 30 | 5 | 15 | 5 | 5 |
| S2 | 10 | 5 | 7 (10, 3) | 22 | 5 | 9 | 4 | 4 |
| S3 | 10 | 2 | 11 (20, 9) | 23 | 6 | 15 | 1 | 1 |
| S4 | 10 | 5 | 7 (10, 3) | 22 | 6 | 15 | 1 | 0 |
| S5 | 10 | 6 | 8 (10, 2) | 24 | 6 | 7 | 5 | 6 |
| S6 | 10 | 0 | 4 (10, 6) | 14 | 0 | 6 | 3 | 5 |
| Total | 60 | 22 | 53 (80, 27) | 135 | 28 | 67 | 19 | 21 |

"Include" excludes seeds. The Consensus-hit column counts every Consensus record including the six that are also seeds.

## Seeds

28 seeds in the protocol. 26 confirmed, 2 corrected (Witt et al. 2023 is JWB, not JIBS; Meyer & Li 2022 is a GSJ paper and the co-author is unconfirmed), 0 unconfirmed. Details and caveats in `seed-verification.md`. Seeds are marked `seed` in the sheet and included regardless of hits, as the protocol requires. No seed was added to `literature/references.bib`.

## Citation chase

Method. The protocol asks for backward and forward chasing on the five most-cited included works per stream. Neither Consensus nor WebSearch returns reference lists or cited-by lists, and Crossref, OpenAlex, Wiley (WebFetch) and Google Scholar were not reachable (egress policy or no access). The chase was therefore run as an approximation: one Consensus query per group of central works, phrased as "building on X (year) and Y (year)", which returns semantically related papers. A returned paper counts as evidenced forward citation only where the returned abstract or text names the focal work (flagged in `notes` as "abstract or text names a focal work"); otherwise it is logged as a "semantic neighbour; citation link not verified". Backward chasing (reading reference lists) was not run for any stream. Central works were chosen as seeds plus the highest Consensus-returned citation counts among included hits; the PI may overrule the choice.

| Stream | Central works | Chased by Consensus query | Not chased |
|---|---|---|---|
| S1 | Nohria & Ghoshal 1997; Ghoshal & Nohria 1989; Bartlett & Ghoshal 1989; Birkinshaw & Hood 1998; Birkinshaw & Morrison 1995 | all five (2 queries) | none |
| S2 | Prahalad & Doz 1987; Doz & Prahalad 1991; Roth & Morrison 1990; Venaik et al. 2005; Meyer et al. 2014 (GSJ) | Prahalad & Doz 1987; Roth & Morrison 1990 (Doz & Prahalad 1991 appeared as a duplicate) | Venaik et al. 2005; Meyer et al. 2014 |
| S3 | Geringer & Hebert 1989; Killing 1983; Yan & Gray 1994; Mjoen & Tallman 1997; Choi & Beamish 2004 | all five (2 queries) | none |
| S4 | Edstrom & Galbraith 1977; Harzing 2001 (JWB); Gong 2003; Gaur et al. 2007; Belderbos & Heijltjes 2005 | first four (1 query) | Belderbos & Heijltjes 2005 |
| S5 | Witt 2019; Petricevic & Teece 2019; Meyer et al. 2023 (sanctions); Witt et al. 2023 (JWB); Adarkwah et al. 2024 | Witt 2019; Petricevic & Teece 2019 | Meyer et al. 2023; Witt et al. 2023; Adarkwah et al. 2024 |
| S6 | none seeded; Babina et al. 2023; Liu et al. 2020; Park et al. 2019; Heiss et al. 2024; Wang et al. 2026 | not per work; one topical re-query surfaced one new include (Marchetti et al. 2025, SMJ) | all five per-work chases |

Reason for the gaps: the Consensus free tier reported 3 searches left for the month after the eighth chase query (reset on 1 November 2026). I stopped there instead of spending the remainder, so those chases are "not run", not "run with no result". The PI can either upgrade the Consensus plan or run Google Scholar "Cited by" and the reference lists manually for the works marked "not chased"; Google Scholar via Publish or Perish supports a cited-by lookup per paper.

WebSearch pilot, not counted. A WebSearch "cited by" query for Geringer & Hebert (1989) returned a search summary asserting these citing articles, with links that were RePEc listing pages that do not themselves show the citation relation: Huang & Chiu (2020, J Int Management), Firth (1996, Accounting, Organizations and Society), Fey (1995, European Management Journal), Mjoen & Tallman (1997), Hamel (1991, SMJ), Fryxell, Dooley & Vryza (2002, JMS), Child & Yan (2003, JMS), Johnson et al. (1996, JIBS), Blodgett (1991, JIBS). These could not be verified from a source page and were not added to the screening sheet. They are listed here only as leads for the manual Google Scholar "Cited by" run on that paper.

Chase yield: 80 results, 27 duplicates, 29 includes, 10 unsure, 14 exclusions. All chase rows have `source_db = citation_chase`.

## Findings that bear on the search itself

1. S6 returned no JIBS, SMJ or Org Sci paper that uses Revelio Labs by name. The closest are LinkedIn-profile studies in Strategy Science (Wang et al. 2026), SMJ (Marchetti et al. 2025), Information Systems Research (Liu et al. 2020), Nature Communications (Park et al. 2019), plus AOM Proceedings and SSRN items. The protocol's S6 aim (recent JIBS, SMJ and Org Sci papers using Revelio) is not met by Consensus; the Web of Science "Revelio" string and a Google Scholar run are needed before concluding that the literature is thin.
2. Consensus mislabels Strategic Management Journal as "Southern Medical Journal" for at least five records (see `seed-verification.md`, flag 5). Journal-list screening by outlet name would silently drop SMJ papers if applied to raw Consensus metadata.
3. Consensus metadata gaps affect 15 unique rows (truncated titles, "Unknown Journal", year N/A, a publisher name in the author field). They are flagged in `notes` and need resolving before any full-text screening.
4. Stream S5 contains conference-proceedings items (AOM Proceedings) that are directly on topic (CON-S5-04, CON-S5-09, CON-S6-03). The protocol does not say whether proceedings are scholarly; they are included provisionally.

## Limits of this log

- No Web of Science, EBSCO or Google Scholar record exists. No claim about coverage, saturation or the "first 200 Google Scholar results" can be made.
- Consensus returned 10 results per query on the free tier, so each stream search is a top-10 sample of a semantic ranking, not an exhaustive list.
- Title/abstract decisions use Consensus abstracts as returned (some truncated or absent). Full text has not been retrieved for any record.
- Dates in `year` are as returned by Consensus unless a seed source corrected them.
