---
name: write-section
description: "Stage 8 of the research workflow. Drafts or revises one manuscript section in Arne's academic voice via the academic-writer agent, with citation keys verified by the reference-manager agent. Usage: /write-section <abstract|introduction|theory|study1|method|results|discussion> [revise]."
---

# /write-section <section> [revise]

Prerequisites per section are in `.claude/agents/academic-writer.md`.
Refuse and name the missing gate if they are not met; the PI may
override with "run anyway", which is recorded in `docs/decisions.md`.

1. Launch the `academic-writer` agent with the section name, the mode
   (draft or revise), the paths of the sources it may use, and the PI's
   notes from the relevant gate files.
2. Launch the `reference-manager` agent on the new section file to
   verify keys and resolve `[CITE:]` markers.
3. Launch the `internal-reviewer` agent in section scope for a short
   style and calibration audit (skip for `revise` runs under 300 words
   of change).
4. Render `manuscript/manuscript.qmd` to Word if Quarto is available;
   otherwise note that rendering is pending.
5. Commit and summarize: word count, open `[CITE:]` and `[DATA:]`
   markers, and the calibration questions the writer flagged in
   `reviews/gate-8-<section>.md`.
