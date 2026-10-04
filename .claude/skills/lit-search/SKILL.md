---
name: lit-search
description: "Stage 1 of the research workflow. Runs the systematic literature search for the IJV integration manuscript via the literature-searcher agent, generates database search strings, and builds the screening sheet. Use when starting the literature work or when new database exports arrive in literature/search/exports/."
---

# /lit-search

Launch the `literature-searcher` agent with this brief.

## Brief

Protocol: `literature/search/protocol.md`. Streams and seed works are
listed there. Deliverables and their paths are in
`.claude/agents/literature-searcher.md`.

Order of work:
1. If `literature/search/search-strings.md` does not exist, write it
   first and stop after writing, so the PI can run Web of Science, EBSCO
   and Google Scholar in parallel with your Consensus searches. Say
   explicitly which databases need a manual run and where to drop the
   exports (`literature/search/exports/<db>-<stream>-<date>.<ris|bib|csv>`).
2. Run the Consensus searches, one per stream, no filters. Save hits.
3. If exports exist, parse, deduplicate, screen, and build
   `screening.csv` and `search-log.md`.
4. Citation chase on the five most central included works per stream.
5. Create `reviews/gate-1-literature-search.md` from the template with
   the PRISMA counts and the list of borderline screening decisions for
   the PI.

Incremental runs (protocol v1.1): streams S7 to S9 were added after the
first run. They have strings in `search-strings.md` but no Consensus
results, and the free tier has too few searches left to run them. Treat
them as manual-run streams, ingest their exports into the same screening
sheet, and append to the search log.

Parsing hints: RIS from Web of Science and EBSCO parse with a small
Python script (`python3`, standard library) or R `revtools`/`synthesisr`
locally; keep the script in `code/R/` or `literature/search/tools/`.
