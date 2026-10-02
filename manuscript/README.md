# manuscript/

- `manuscript.qmd`: assembles the sections; render with
  `quarto render manuscript/manuscript.qmd --to docx` from the repo root.
- `sections/`: one Quarto file per section, drafted by `/write-section`.
- `tables/`, `figures/`: produced only by scripts in `code/R/`.
- `csl/journal-of-international-business-studies.csl`: JIBS reference style
  from the Citation Style Language repository.
- `outline.md`: the section-level plan.
- `missing-citations.md`: created by the reference-manager agent.
- Final Word polishing with tracked changes uses the `docx` skill on the
  rendered `manuscript.docx`, which is gitignored; commit the `.qmd` sources.
