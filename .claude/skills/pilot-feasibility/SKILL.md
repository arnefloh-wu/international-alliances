---
name: pilot-feasibility
description: "Stage 4 of the research workflow. Runs the 100-IJV Orbis-to-Revelio matching pilot via the data-engineer agent and produces the go/no-go feasibility report. Requires exports in data/raw/ or produces the extraction specification for the PI."
---

# /pilot-feasibility

This is the stage the research idea (section 12 and 13) says must come
before any hypothesis-driven work.

1. Check `data/raw/` for `orbis-pilot-*.csv` and `revelio-pilot-*`. If
   absent, launch the `data-engineer` agent to write
   `data/raw/extraction-spec-orbis.md` and
   `data/raw/extraction-spec-revelio.md` (fields, filters, sample
   frame: equity IJVs with two or more parents headquartered in
   different countries, formation 2005 or later, at least three years
   of operation, stratified across host regions and industries), then
   stop and tell the PI what to export and where to put it (local
   `data/raw/` or the Dropbox folder named in `data/README.md`).
2. With the exports present, launch the `data-engineer` agent for the
   matching pilot as described in its definition. The agent writes and
   runs `code/R/01_pilot_matching.R` if R is available locally;
   otherwise it writes the script and the PI runs it, then re-invokes
   this skill with the outputs in `data/interim/`.
3. Verify `code/quarto/pilot-feasibility-report.qmd` renders (or is
   ready to render) and that `reviews/gate-4-pilot.md` contains: match
   rate, employee coverage distribution, cell survival at thresholds 3,
   5 and 10, parent-origin reconstruction rate, projected usable IJVs,
   and the agent's go/no-go recommendation with the reasons.
4. Commit and summarize.
