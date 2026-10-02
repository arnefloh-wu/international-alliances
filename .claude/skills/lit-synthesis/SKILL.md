---
name: lit-synthesis
description: "Stage 2 of the research workflow. Synthesizes the screened literature into a concept matrix, per-stream memos, a verified gap statement and the theory-section outline via the literature-synthesizer agent. Requires gate 1 approved."
---

# /lit-synthesis

Prerequisite: `reviews/gate-1-literature-search.md` is APPROVED.

Launch the `literature-synthesizer` agent with the brief in its
definition. Add the PI's notes from gate 1 if the status is
`APPROVED WITH CHANGES`.

After it reports, launch the `reference-manager` agent on
`literature/synthesis/missing-references.md` so that every citation key
the outline needs is either verified in `literature/references.bib` or
listed as unobtainable in `reviews/gate-2-synthesis.md`.

Then commit and summarize for the PI: the gap type named, the three
contributions as the synthesis now phrases them, and the claims that
still lack support.
