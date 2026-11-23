---
name: research-organizer
description: >
  Use this skill to check and maintain the project infrastructure of the IJV
  staffing study: folder structure, naming conventions, README.md and
  CLAUDE.md. Triggers: "organize my research project", "set up project
  folders", "check the project structure", "audit the repository", "create a
  README", "update the README", "structure my project files", or any request
  to keep the repository reproducible. The repository already exists, so the
  skill audits and completes it; it does not rebuild it.
---

# Research Project Organizer

Customized on 2026-11-23 from the seminar template `1B-research-organizer.md`
for the IJV staffing study (Floh, Mohr, Thanyi; target JIBS).

## What This Skill Does

The template turns a research brief into a new, scaffolded project. This
repository was scaffolded on 2026-10-02 by stage 0 of the workflow
(`/research-workflow setup`) and has been in use since, so the customized
skill does the same job in maintenance mode: it compares the repository with
the structure, the naming conventions, the README and the CLAUDE.md that the
project has committed to, creates what is missing, and reports what has
drifted. It never renames or moves an existing folder, because the scripts,
the stage skills and the agents use these paths.

Place in the workflow (`docs/workflow.md`): not a numbered stage and no gate.
It does not replace `/research-workflow setup`, does not write to another
stage's outputs, and never changes a gate status.

---

## Customize This Skill (completed)

The **core** block is identical in all ten skills and was copied unchanged
from `.claude/skills/research-ideation/SKILL.md`. The **skill-specific**
block and the **extensions** apply only here.

```yaml
# ---------- CORE — identical in all ten skills ----------
field:                 international business
subfield:              international joint ventures: staffing, control and organizational design
target_venue:          Journal of International Business Studies
citation_style:        APA 7 in text; JIBS reference list (manuscript/csl/journal-of-international-business-studies.csl)
software:              R
replication_standard:  code-only package: scripts in code/R/ reproduce every table and figure from the licensed exports; Orbis, Revelio and BoardEx data are not shareable; pre-analysis plan fixed at gate 5

# ---------- SKILL-SPECIFIC — research-organizer ----------
collab_platform:       GitHub (arnefloh-wu/international-alliances; work on branches, merged into main by pull request); licensed data stay local or in the project Dropbox folder; references in the Zotero group library
folder_convention:     named, as in the folder map of CLAUDE.md (docs/, literature/, data/, code/, manuscript/, reviews/); scripts inside code/R/ are numbered
irb_required:          false

# ---------- EXTENSIONS (three-edit pattern, see the last section) ----------
licensed_data:         Orbis, Capital IQ, Revelio and BoardEx exports and the interview transcripts live under data/raw, data/interim, data/processed and data/interviews, all gitignored; aggregated counts may appear in reviews/ and docs/, row-level data never
workflow_gates:        reviews/gate-<n>-<slug>.md, created from reviews/GATE-TEMPLATE.md by the stage agent; only the PI sets Status
```

`irb_required: false` is the PI's answer of 2026-11-23 (`docs/decisions.md`):
the manager interviews need no ethics approval on file for this study. The
consent terms of the interviews are a separate matter and still an open item
there (2026-10-02, interview corpus), so the consent check in Step 1 stays.

Where each value comes from:

| Value | Source in this repository |
|-------|---------------------------|
| Core block | `.claude/skills/research-ideation/SKILL.md`; if it changes there, change it here and in the other eight skills |
| `collab_platform` | `git remote -v`, the merge history, `data/README.md`, the tooling notes in `CLAUDE.md` |
| `folder_convention` | folder map in `CLAUDE.md`, `docs/workflow.md` |
| `licensed_data` | `CLAUDE.md` rule 2, `.gitignore`, `data/README.md` |
| `workflow_gates` | `reviews/README.md`, `docs/workflow.md` |

### Where your values change the output

| Step | What changes |
|------|--------------|
| Step 1 — Folder Structure | `folder_convention: named`: the existing tree is the standard, the numbered template tree is not created. `irb_required` decides whether `docs/ethics/` is scaffolded. `licensed_data`: the audit checks `.gitignore` and that no licensed file is tracked |
| Step 2 — Naming Conventions | `software: R`: scripts are `.R`, numbered in run order; data files carry a version and an ISO date |
| Step 3 — README | `collab_platform` and `replication_standard`: reproduction means cloning from GitHub, obtaining the licensed exports through WRDS with the reader's own subscription, and running the scripts; no data download is promised |
| Step 4 — CLAUDE.md | International business, JIBS and APA 7 are already in `CLAUDE.md`; the step checks that they still agree with the core block |
| Steps 1 and 4 | `workflow_gates`: every stage that has produced outputs has a gate file; the audit lists stages with outputs and no gate file, and never edits a Status line |

---

## Inputs (preset; ask the PI only for what has changed)

| Input | Value |
|-------|-------|
| `project_name` | `international-alliances` (repository and folder name; do not rename) |
| `research_brief` | `docs/research-brief.md` (proposal until the PI decides gate 4); the original idea is `initial-research-idea.md` |
| `team_size` | Three: Arne Floh (PI, lead author), Alexander Mohr, Can Thanyi, plus the agents in `.claude/agents/` |
| `target_journal` | Journal of International Business Studies |
| `data_type` | Mixed: existing manager interviews (qualitative) and an archival panel from Orbis, Capital IQ, Revelio and BoardEx |
| `irb_required` | `false` (PI, 2026-11-23). Ask again only if new primary data are planned |

Read `CLAUDE.md`, `README.md`, `docs/workflow.md` and `.gitignore` before
Step 1.

---

## Step-by-Step Protocol

### Step 1 — Audit the Folder Structure

The standard is the tree below. It is the template's canonical structure
mapped onto the folders this project already uses.

```
international-alliances/
├── CLAUDE.md                  ← read by Claude at the start of every session; binding rules
├── README.md                  ← how to run the workflow and the scripts
├── initial-research-idea.md   ← original idea; not edited
├── docs/
│   ├── research-brief.md      ← current statement of the idea (template: 00_admin/research-brief.md)
│   ├── decisions.md           ← decision log, with an Open section (template: decision-log.md)
│   ├── workflow.md            ← stages, agents, gates
│   ├── theory-framework.md    ← binding theory hierarchy
│   ├── jibs-guidelines-notes.md, data-acquisition-guide.md
│   ├── coauthor-notes/        ← notes for the co-authors (template: meeting-notes/)
│   └── ethics/                ← only if irb_required is true
├── literature/
│   ├── search/                ← protocol, strings, hit logs, screening sheet
│   ├── synthesis/             ← created by stage 2
│   ├── shock-scan/
│   ├── fulltext/              ← PDFs, <citationkey>.pdf, not committed
│   ├── zotero/
│   └── references.bib         ← single source of truth for references
├── data/
│   ├── README.md, codebook.md
│   ├── raw/                   ← untouched exports; NEVER modify files here
│   ├── interim/, processed/
│   └── interviews/            ← transcripts, consent notes, coding files
├── code/
│   ├── R/                     ← 00_setup.R and numbered scripts
│   │   ├── functions/, tests/
│   │   └── wrds/              ← numbered WRDS extraction and matching scripts
│   ├── quarto/                ← pilot and analysis reports
│   └── setup/
├── manuscript/
│   ├── manuscript.qmd, outline.md, _quarto.yml
│   ├── sections/, tables/, figures/, csl/
│   ├── submission/, revision/ ← created when gate 10 is reached
├── reviews/                   ← gate files and internal review reports
└── .claude/
    ├── skills/                ← stage skills and the customized course skills
    └── agents/
```

How to run the audit:

1. List what exists and compare it with the tree. Report three groups:
   present, missing, and present but not in the tree.
2. Create a missing folder only if it belongs to no stage or its stage has
   run. Leave `literature/synthesis/`, `manuscript/submission/` and
   `manuscript/revision/` to their stages and say so. Add a `.gitkeep` to a
   created folder that would otherwise be empty, and to existing empty
   folders that Git does not yet track.
3. Do not rename, move or delete anything. A folder or file that is not in
   the tree is reported with a suggestion, and the PI decides. Report build
   artefacts that sit outside their place (for example rendered reports in
   the repository root).
4. `irb_required: true`: create `docs/ethics/` with a README that lists what
   belongs there (approval letter, consent form, protocol), and check that
   the consent section of `data/interviews/README.md` is filled in before
   `/qual-recode` runs. `false`: no `docs/ethics/`, but the consent section
   is still checked, because the interviews are reused. Placeholder: ask.
5. `licensed_data`: run `git ls-files data/` and confirm that only the
   allowed files are tracked (`data/README.md`, `data/codebook.md`,
   `data/raw/README.md`, `data/raw/extraction-spec-*.md`,
   `data/interviews/README.md`, the `.gitkeep` files). Confirm that
   `.gitignore` still excludes `data/raw/*`, `data/interim/*`,
   `data/processed/*`, `data/interviews/*`, `.env` and `.Renviron`. A tracked
   licensed file is reported at once and not removed without the PI.
6. `workflow_gates`: for each stage in `docs/workflow.md`, check whether its
   output folder has content and whether its gate file exists. List the
   mismatches. Do not create a gate file for a stage (its agent does) and do
   not touch a Status line.

The repository is a Git repository with a GitHub remote, so no `git init`.
Report the tree and the findings back to the PI when done.

### Step 2 — Naming Conventions

These are the conventions the repository already follows, except where a
rule is marked as proposed. The audit lists files that break them; it does
not rename them.

**Scripts**
- `NN_descriptor.R`, numbered in run order, starting from `code/R/00_setup.R`,
  which every script sources. WRDS scripts are numbered separately in
  `code/R/wrds/`. Helpers go in `code/R/functions/`, checks in
  `code/R/tests/`.
- A new script takes the next free number and gets a row in the run-order
  table of `README.md`.

**Data**
- Raw files are never renamed or edited; their source is recorded in
  `data/README.md` and in the extraction logs in `data/interim/`.
- Derived files: `<descriptor>-<version>-<YYYY-MM-DD>.<ext>` in lower case
  with hyphens, for example `ijv-matched-v3-2026-10-09.csv`. The date is the
  run date fixed in the script, not the day of a rerun.
- Every variable of a processed table is listed in `data/codebook.md`.

**Output**
- Tables and figures for the manuscript are written by scripts to
  `manuscript/tables/` and `manuscript/figures/`, never typed in by hand.
  Both folders are still empty, so no naming rule exists yet. Proposed, for
  the PI to confirm before stage 7: `tbl<n>-<descriptor>.<ext>` and
  `fig<n>-<descriptor>.<ext>`, with the number in order of appearance.
- Reports: `code/quarto/<name>.qmd`; rendered files are not committed.

**Documents**
- Gate files `reviews/gate-<n>-<slug>.md`; internal reviews
  `reviews/review-<date>-<scope>.md`; co-author notes
  `docs/coauthor-notes/<topic>-<YYYY-MM-DD>.qmd`.
- Citation keys in the form `authorYearTitleword` (Better BibTeX); full texts
  `literature/fulltext/<citationkey>.pdf`.
- Dates are ISO (`YYYY-MM-DD`) everywhere, in file names and in prose logs.

### Step 3 — Check README.md

`README.md` exists and is the run guide. Do not regenerate it. Compare it
with the template's sections and add what is missing, leaving the run
instructions as they are:

| Template section | In this README |
|------------------|----------------|
| Overview | Present (title and first paragraph); check that it still matches `docs/research-brief.md` once the PI has decided gate 4 |
| Research Question | Add as a pointer to `docs/research-brief.md`, not as a copy |
| Repository Structure | Add a short table, or a pointer to the folder map in `CLAUDE.md`; one of the two, not both |
| Data | Add: sources (Orbis and Capital IQ ownership, Revelio, BoardEx through WRDS; existing manager interviews), access (licensed, institution subscription; not shareable), raw data location `data/raw/` with "do not modify" |
| How to Reproduce | Present ("Run it locally"). Check that the run-order table lists every script in `code/R/` and `code/R/wrds/`, and that the package list matches `code/R/00_setup.R` and the scripts' `require_pkgs()` calls |
| Key Contacts | Team names are present. Add a contact address only if the PI supplies one for this purpose |
| Status | Add one line that points to `/research-workflow status` and `reviews/`; do not copy gate states, which go stale |
| Citation | Add the placeholder |

`collab_platform` and `replication_standard` decide the wording of the
reproduction section: clone from GitHub; put WRDS credentials in
`~/.Renviron`; the reader needs their own subscription to the Orbis, Capital
IQ, Revelio and BoardEx libraries; the scripts rebuild every dataset, table
and figure; no data are distributed with the code.

### Step 4 — Check CLAUDE.md

`CLAUDE.md` exists, is checked into the repository and is binding. Never
regenerate or shorten it. Compare it with the template's headings and report
gaps to the PI as proposed lines; apply them only on the PI's instruction.

| Template heading | In this CLAUDE.md |
|------------------|-------------------|
| Research Question | "What this project is", with pointers to `initial-research-idea.md` and `docs/research-brief.md` |
| Theoretical Framework | Theory hierarchy paragraph and `docs/theory-framework.md` |
| Hypotheses | Not listed, and they should not be until gate 5; the pointer to the research brief is enough |
| Data | Design paragraph; counts stay in `reviews/gate-4-pilot.md` and are not copied |
| Style Conventions | Rule 3 (academic-writing skill, American spelling, APA 7, JIBS CSL). Check against the core block |
| Current Status | Not present. Propose a pointer to `reviews/` and `/research-workflow status`, not a status text |
| Files Claude Should Know About | Folder map and tooling notes. Check that every folder in the map exists and every skill in `.claude/skills/` that the PI calls by name is mentioned in `README.md` or `CLAUDE.md` |

Keep `CLAUDE.md` short: it points to files, it does not copy them.

---

## Quality Checks

- [ ] `data/raw/` exists and its README says the files are never modified
- [ ] README explains how to reproduce all results from scratch, and its run-order table lists every script
- [ ] CLAUDE.md points to the research brief and its folder map matches the folders on disk
- [ ] Naming conventions are internally consistent, and files that break them are listed, not renamed
- [ ] No existing folder or file was renamed, moved or deleted
- [ ] `irb_required: false`: no `docs/ethics/` folder was created, and the consent section of `data/interviews/README.md` was still checked
- [ ] `licensed_data`: `git ls-files data/` shows only the allowed files, and `.gitignore` still excludes the data folders, `.env` and `.Renviron`
- [ ] `workflow_gates`: stages with outputs and no gate file are listed; no Status line was changed and no gate file was created for a stage
- [ ] The core block is still identical to the one in `research-ideation`
- [ ] Changes to `CLAUDE.md` were proposed to the PI, not applied unasked; nothing was committed unless the PI asked

---

## Common Failure Modes to Avoid

- **Rebuilding instead of auditing**: creating `00_admin/` to `05_replication/` next to the existing tree. The numbered layout is the template's default, not this project's.
- **Helpful renaming**: moving a script or data file to fit a convention breaks the paths in the scripts and in `data/codebook.md`.
- **Copying status into README or CLAUDE.md**: gate states and sample counts change; point to `reviews/`.
- **Treating the audit as a gate**: this skill reports. Decisions go to the PI and into `docs/decisions.md`.

---

## Extending the Template (Exercise 1B Part 2)

Adding a field takes three edits, and all three matter:

1. Add the key to the **skill-specific block**.
2. Add a row to **Where your values change the output**, naming the step it affects.
3. Add a line to **Quality Checks**, so the new behavior is verified, not assumed.

Two fields were added this way on 2026-11-23: `licensed_data` (Step 1, item 5)
and `workflow_gates` (Step 1, item 6). They have not been tested yet. Test
each twice, once set and once as a placeholder; if the output is the same,
the skill is ignoring the field.

Further candidates: `license` (a LICENSE file for the code; none exists),
`data_embargo` (when, if ever, derived cell-level panels may be shared; see
the licence reminder in `data/README.md`), `renv_lock` (whether package
versions are pinned with renv; `renv` is listed as optional and no lockfile
exists).
