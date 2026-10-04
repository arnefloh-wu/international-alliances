# Gate 1: Literature search

Status: PENDING
Approved by:
Stage: 1 Literature search
Agent: literature-searcher
Date produced: 2026-10-02

Scope warning. Only Consensus has been run. Web of Science, EBSCO Business Source and Google Scholar are NOT run (no agent access; `literature/search/exports/` is empty). Everything below describes a Consensus-plus-seed-list corpus. Approving this gate as it stands would approve an incomplete search; the manual runs listed below are needed before the search can be called complete.

## Deliverables

| Deliverable | Path | Notes |
|---|---|---|
| Search strings with run dates and Consensus queries | `literature/search/search-strings.md` | WoS, EBSCO, GS blocks marked "not yet run"; Consensus run log appended |
| Raw Consensus hits, S1 to S6 | `literature/search/hits-consensus-S1-2026-10-02.md` to `hits-consensus-S6-2026-10-02.md` | 10 records each; exact query at top; Consensus returns no DOI |
| Seed verification | `literature/search/seed-verification.md` | 26 confirmed, 2 corrected, 0 unconfirmed of 28 |
| Screening sheet | `literature/search/screening.csv` | 162 rows (135 unique, 27 rows flagged F_duplicate) |
| PRISMA-style log | `literature/search/search-log.md` | counts, chase method and limits |
| This gate file | `reviews/gate-1-literature-search.md` | |

## Counts (Consensus, seeds and citation chase only)

| Step | n |
|---|---|
| Consensus stream hits (6 queries) | 60 |
| Seed list | 28 (6 also retrieved by Consensus, 22 seed-only) |
| Citation-chase results (8 Consensus queries, approximate) | 80 |
| Web of Science, EBSCO, Google Scholar | 0 (not run) |
| Total identified | 168 |
| Duplicates removed | 33 |
| Unique records | 135 |
| Seeds included without screening | 28 |
| Screened on title/abstract | 107 |
| Excluded (A_level 3, B_formation 2, C_nonscholarly 1, D_language 0, E_offtopic 15) | 21 |
| Unsure, to full text | 19 |
| Include, to full text | 67 |
| Provisionally included for synthesis (seeds plus includes) | 95 |

Per stream (unique records: seeds / include / unsure / exclude): S1 30 (5/15/5/5), S2 22 (5/9/4/4), S3 23 (6/15/1/1), S4 22 (6/15/1/0), S5 24 (6/7/5/6), S6 14 (0/6/3/5).

## Manual runs required

The agent cannot reach Web of Science, EBSCO Business Source or Google Scholar. Please run the following and drop the exports into `literature/search/exports/`. The exact strings are in `literature/search/search-strings.md` (copy from the code blocks in each stream's section; do not retype). Then tell the orchestrator, which will have the literature-searcher ingest, deduplicate on DOI then normalized title, screen the new records and update the log.

| Database | Streams | Settings | Drop exports at |
|---|---|---|---|
| Web of Science Core Collection | S1, S2, S3, S4, S5, S6 (one string each) | field TS; years 1985 to present; Document type: Article, Review; Categories: Business, Management; Export > Other File Formats > RIS, Full Record, 500 records per file | `literature/search/exports/wos-S<n>-<date>-<part>.ris` (for example `wos-S3-2026-10-05-1.ris`) |
| EBSCO Business Source | S1, S2, S3, S4, S5, S6 (one string each) | fields TI, AB, SU as in the string; Scholarly (Peer Reviewed) Journals; 1985 to present; Share > Export > RIS, all pages (use the folder) | `literature/search/exports/ebsco-S<n>-<date>.ris` |
| Google Scholar via Publish or Perish | S1, S2, S3, S4, S5, S6; the strings list two variants per stream, run both | variant string as the "Keywords" query; max 200 results; no filters; export CSV | `literature/search/exports/gs-S<n>-<date>.csv`; where two variants are run for one stream, add a letter, `gs-S<n>-<date>-a.csv` and `-b.csv`, so files do not overwrite (this suffix is my addition to the naming rule in the strings file) |

Please also, where possible, run Google Scholar "Cited by" and read the reference lists for the central works that the Consensus chase did not cover (see `search-log.md`, citation-chase table): S2 Venaik et al. 2005 and Meyer et al. 2014 (GSJ); S4 Belderbos & Heijltjes 2005; S5 Meyer et al. 2023 (sanctions), Witt et al. 2023 (JWB), Adarkwah et al. 2024; S6 Babina et al. 2023, Liu et al. 2020, Park et al. 2019, Heiss et al. 2024, Wang et al. 2026. Backward chasing was not run for any stream because no accessible tool returns reference lists. Priority streams if time is short: S3 and S4 (the IJV core), then S1 and S2, then S5, then S6.

Web of Science API: if you can supply an institutional key, the strings can be run by the agent instead (open item in `docs/decisions.md`).

## Protocol amendment after the search (added by the orchestrator, 2026-10-02)

The PI's detailed answer on theoretical anchors (`docs/theory-framework.md`)
changed the search protocol to version 1.1 after the Consensus run. Streams
S1 to S6 are unchanged and keep their IDs. Three streams are new and have
strings but no results: S7 structural contingency theory (main theory),
S8 organizational design, and S9 candidate geopolitical shocks (five
families S9a to S9e). The Consensus free tier has too few searches left to
run them, so they are manual-run streams. The tier assigned to each stream
is in the protocol. The new seeds are from memory and unchecked.

Effect on this gate: the corpus is further from complete than the counts
above suggest, because the main theory (S7) has not been searched at all.
Do not approve this gate as complete before S7 and S8 exports are ingested.
Priority for the manual runs becomes: S7, S3 and S4, then S8, S1 and S2,
then S5 and S9, then S6.

## Reference verification results (added by the orchestrator, updated 2026-10-04)

The reference-manager verified the Stage 1 records imported into Zotero
(`literature/zotero/verification-report-2026-10-04.md`, sections 9 and 10).
After the PI's decisions (original works cited, book reviews not accepted),
99 of 114 are verified and 83 are in `literature/references.bib`. These 15
records are not verified and must not be cited until resolved:
andersson2018integration, bartlett1989managing, downes2000knowledge, doz1980how, doz1990control, ghoshal1993horses, killing1983strategies, lawrence1967organization, mohedanosuanescontrol, nguyen2009foreign, nohria1997differentiated, oostenfunctions, prahalad1987multinational, reus2004interpartner, schaan1983parent. Six of them are seeds: Nohria & Ghoshal 1997, Bartlett & Ghoshal
1989, Lawrence & Lorsch 1967, Prahalad & Doz 1987, Killing 1983 and Schaan
1983. A web search for PDFs and catalogue records is under way
(`literature/zotero/pdf-search-2026-10-04.md`). The report also corrects
three Stage 1 details: Barden, Steensma & Lyles 2005 (not "Steensma et
al."), Meyer & Li 2022 in Global Strategy Journal, and print years for
Li et al. 2018 and Harzing et al. 2016.

## Quality checks run

- Every Consensus query and run date is logged in `search-strings.md` and at the top of each hits file; hits were copied from the tool output without alteration, including its apparent metadata errors.
- No hit was invented. No DOI was taken from memory: Consensus returns none, and the DOIs in the sheet appear only where a WebSearch result showed them (publisher URL or summary) and are marked as not Crossref-verified.
- All 28 seeds were checked against a returned source; two corrections found (below).
- Deduplication on normalized title (no DOIs available from Consensus); 33 duplicates logged with the retained id in `notes`.
- Row counts in the log, this file and the sheet reconcile (162 rows, 135 unique, 27 F_duplicate rows).
- Nothing was added to `literature/references.bib`.

## Known weaknesses and uncertainties

- The search is incomplete: three of four databases not run, and the Consensus free tier returns a top-10 sample per query. No saturation or coverage claim is possible.
- Screening used Consensus abstracts only (some missing or truncated); no full text retrieved.
- The citation chase is an approximation. Consensus has no cited-by or reference-list function, so the chase returns semantic neighbours; only records whose returned text names a focal work are evidenced citations. Chases for 11 central works were not run (list above); the Consensus free tier reported 3 searches left this month after the eighth chase query, so I stopped.
- Consensus metadata errors: Strategic Management Journal is mislabeled "Southern Medical Journal" on at least five records; 15 unique rows have truncated titles, missing years or "Unknown Journal"; one record's author field holds a publisher name (CON-S2-05). Journal-name screening on raw Consensus data would drop SMJ papers.
- S6 returned no JIBS, SMJ or Org Sci paper that names Revelio. This may be a Consensus coverage limit or a real gap; the manual Web of Science and Google Scholar runs decide which.
- Three on-topic items are conference proceedings (AOM Proceedings) and one is an SSRN working paper; inclusion is provisional.

## Decisions required from the PI

1. Complete the manual runs above, or explicitly accept starting Stage 2 on the Consensus-plus-seed corpus (not recommended; G2 would then need a re-run when the exports arrive).
2. Protocol correction, Witt, Lewin, Li & Gaur 2023: the source shows Journal of World Business 58(1), not JIBS. Confirm the correction (the seed stays in the sheet either way).
3. Protocol correction, Meyer & Li 2022: the matching paper is "The MNE and its subsidiaries at times of global disruptions: An international relations perspective" in Global Strategy Journal, authored by Meyer and at least one other person; no source confirmed Li as co-author. Confirm this is the intended work (row SEED-19), or name a different paper.
4. Schaan 1983 is a doctoral dissertation (Western Ontario), not a journal article. Keep it as a seed (current treatment, row CON-S3-09), or drop it for citation purposes.
5. Conference proceedings and working papers: the protocol is silent. Current treatment: proceedings included provisionally (CON-S5-04, CON-S5-09, CON-S6-03), SSRN working paper included provisionally (CON-S6-05), a Sloan working-paper precursor of the Nohria & Ghoshal book excluded as C_nonscholarly (CC-S1-04). Confirm or change the rule.
6. Borderline includes to confirm: CON-S1-05 (subsidiary autonomy antecedents, no function or level split), CON-S2-09 (handbook chapter, MNC strategic management), CON-S4-06 (expatriate utilization with a performance outcome), CON-S2-05 (author field is a publisher name, authors unresolved).
7. Borderline excludes to confirm: CON-S2-02 (A_level; MNC-wide global integration review, outlet quality unclear but not a ground for exclusion), CON-S2-03 (A_level; firm-level CSR), CON-S1-07 (A_level; subsidiary performance and external networks), CON-S5-02 (B_formation; geopolitical risk and subsidiary performance only).
8. The 19 "unsure" records need a full-text call or a PI decision. Highest-impact ones: CON-S5-03 (GVC recalibration after sanctions), CON-S5-10 (sanctions adjustment commentary), CON-S6-01 (LinkedIn labor-flow network), CON-S6-09 and CON-S6-10 (data-source and LinkedIn-validity papers), CC-S3-20 (ownership-control restructuring in IJVs), CC-S5-05 (springboard MNEs under de-globalization), CC-S5-08 and CC-S5-09 (de-globalization context papers), CC-S1-16 and CC-S1-17 (subsidiary power and entrepreneurship), CON-S1-03, CON-S1-06, CON-S2-07 (metadata unresolved), CON-S2-04 (marketing-function chapter), CC-S1-08 (edited volume), CC-S2-05 and CC-S2-10 (outlet unknown), CC-S4-07 (special-issue editorial).
9. Whether to upgrade the Consensus plan (500 searches per month, 20 results per search) so the remaining chases and a second pass per stream can be run by the agent. The free tier resets on 1 November 2026.

## Proposed changes to earlier stages

- `literature/search/protocol.md` (Stage 0 output): correct the Witt, Lewin, Li & Gaur 2023 outlet (JWB) and resolve Meyer & Li 2022; add a rule for proceedings, working papers and dissertations; note that "Harzing 2001 (JWB)" is "Of bears, bumble-bees, and spiders", distinct from Harzing 2001 in Human Resource Management; replace the Gong 2003 and Li et al. 2018 shorthand with full titles (see `seed-verification.md`). The protocol was not edited by this agent.
- `docs/decisions.md`: the open items on Web of Science API access and the Consensus plan are relevant to this gate (rows added under "Open").

## PI notes (filled in by the PI; applied by the orchestrator if status is APPROVED WITH CHANGES)

-
