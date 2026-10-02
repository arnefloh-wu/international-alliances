---
name: internal-review
description: "Stage 10 of the research workflow. Produces a JIBS-style internal review of the full draft or a section via the internal-reviewer agent, with a prioritized revision list. Usage: /internal-review [full|<section>]."
---

# /internal-review [full|<section>]

Launch the `internal-reviewer` agent with the scope. For `full`,
render `manuscript/manuscript.qmd` first if Quarto is available so the
reviewer reads the assembled draft; otherwise concatenate the section
files in order.

After it reports, create or update `reviews/gate-10-submission.md`
with the simulated editorial decision and the revision list. Do not
start revisions automatically; the PI decides which items go to
`/write-section <section> revise`.
