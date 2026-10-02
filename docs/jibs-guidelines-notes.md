# JIBS submission notes

Working notes for the academic-writer and internal-reviewer agents. These
notes are a checklist to verify against the current JIBS author
guidelines on the Springer/Palgrave site before submission; they are not
a substitute for them. Items marked (verify) must be checked by the PI or
the reference-manager agent against the live guidelines.

## Structure JIBS reviewers expect

- Abstract: one paragraph, around 150 words (verify current limit), no
  citations, states phenomenon, approach, data, findings, contribution.
- Introduction that states the research question, the gap in IB theory,
  and the theoretical contribution explicitly. JIBS editors reject papers
  whose contribution is empirical only; the paper must change how IB
  scholars think about alliance integration.
- Theory and hypotheses section organized by mechanism.
- Method section with transparent sampling, matching and measurement.
  For archival employment data, reviewers will ask about coverage bias,
  the construction of parent-origin indicators, and cell-size thresholds.
- Results with effect sizes, confidence intervals, robustness and
  identification checks (pre-trends, placebo shocks, alternative
  estimators).
- Discussion with theoretical contributions, managerial and policy
  implications (the "so what" for IB practice), limitations paired with
  future research.
- Mixed-method papers: JIBS has published guidance on mixed methods and
  qualitative rigor; Phase 1 must show a transparent coding procedure
  and explain exactly how it informed Phase 2 measurement.

## Formatting (verify each)

- Reference style: JIBS house style, author-date, full journal names.
  Implemented by `manuscript/csl/journal-of-international-business-studies.csl`.
- Tables and figures at the end or in place per the guideline; each
  table self-contained with notes on estimator, fixed effects, clustering
  and significance conventions.
- Word count: check the current limit including references and tables.
- Spelling: consistent American or British. This project uses American.
- Anonymized submission for review: no author-identifying statements in
  the main file.

## Reviewer expectations specific to this design

- Why IJVs rather than alliances in general, and what is lost.
- Why prior affiliation rather than nationality measures integration.
- Revelio coverage: who is missing (operational staff, non-LinkedIn
  countries) and how that biases the hierarchy results.
- Endogeneity of the shock to the dyad and the IJV; pre-trends.
- Multiple comparisons across functions; pre-registration-style
  pre-analysis plan in `reviews/gate-5-pre-analysis-plan.md`.
