# Memo Methods: Employment-history data in management research (stream S6)

Stage 2 (lit-synthesis), literature-synthesizer, 2026-11-24.
Evidence basis: worked from abstracts / metadata only. No full texts.

Role in the paper: justify the archival measurement (staffing origin from
Revelio position histories; occupation-group cells; contingency scores from
O\*NET). Corpus: S6 has 6 includes and no seeds. Three S6 records screened
"unsure" are relevant (CON-S6-01 LinkedIn labor-flow network, CON-S6-09
data-source editorial, CON-S6-10 LinkedIn profile validity) but are not
cited; they are listed in `missing-references.md`. Stage 1 found no JIBS,
SMJ or Org Sci paper in the Consensus results that names Revelio Labs; that
finding may be a Consensus coverage limit (`literature/search/search-log.md`,
finding 1).

## What is established

1. Professional profile data can measure the composition of a firm's
   workforce at fine grain. 570 million LinkedIn profiles have been
   aggregated to firm x occupation x year cells for 466,626 US firms
   (`wang2026organizational`); resumes measure education, specialization and
   hierarchy (`babina2023firm`); profiles characterize firms' skill
   distributions (`liu2020predicting`).

2. Career histories measure flows between employers. Employee moves define a
   human capital flow network that predicts labor-market competition
   (`liu2020predicting`, 89,000 employees, 3,000+ firms). This is the closest
   corpus precedent for classifying hires by prior employer, which is how
   the project measures organizational origin.

3. Hierarchy can be measured from titles and manager counts. Managerial
   hierarchy from 42 million profiles (`marchetti2026are`), hierarchy
   steepness from job titles (`heiss2024structure`), and flattening after AI
   investment (`babina2023firm`).

4. Profile data can be linked to and checked against firm registers. XING
   profiles linked to the Mannheim Enterprise Panel (14 million employments,
   1.5 million employers) with plausibility checks (`breithaupt2025linked`).

## What is disputed

Not within the corpus. The validity questions the paper will face
(selective coverage by country, occupation, seniority and cohort; missing
prior positions; self-reported titles) are not addressed by any included
record's abstract. They are the subject of the unsure records CON-S6-09 and
CON-S6-10, which are not cited.

## What is measured and how

Composition shares by firm-occupation-year (`wang2026organizational`);
skill vectors and flow networks (`liu2020predicting`); hierarchy indices
(`marchetti2026are`, `heiss2024structure`); linkage plausibility checks
(`breithaupt2025linked`). All settings are US or Germany, all are at the
firm level, and none concerns foreign units, JVs or entity matching of a JV
to two parents.

## Task 4b: O\*NET or similar task descriptors in the corpus

No included record, in any stream, uses O\*NET or the Dictionary of
Occupational Titles, and none uses occupational task descriptors to measure
a task environment, a contingency, interdependence or external contact. The
occupation grain itself has a precedent (`wang2026organizational`), but
whether that dataset uses O\*NET-SOC coding is not stated in the abstract.
The Stage 2 OpenAlex searches (`literature/search/search-log.md`, Stage 2
addendum) surfaced one candidate on occupational offshorability built from
task descriptors (Blinder 2007, RePEc working paper, unscreened); the
literature that uses O\*NET work-context and work-activity measures for
face-to-face contact, on-site work, offshorability and teamwork is in
economics and industrial-organizational psychology and was never in the
search scope. What the paper needs is listed in `concept-bridge.md` and
`missing-references.md`.

## What is missing for this project

1. Any IB or management study that measures foreign-unit or IJV staffing from
   profile data (bounded: provisional corpus).
2. A validity source for Revelio or LinkedIn-type coverage across countries
   and seniority levels `[CITE: validity and coverage of profile-based
   workforce data outside the US]`; candidates are the unsure records
   CON-S6-09 and CON-S6-10.
3. A source on missing histories and labor-market entrants in profile data
   `[CITE: missing employment histories in profile data]`.
4. A source on secondees who keep the parent as employer of record
   `[CITE: secondment and employer-of-record]`.
5. A methodological source for O\*NET as an occupation-level measure of task
   content `[CITE: O*NET content model documentation]` and for its use
   outside the US `[CITE: cross-country transferability of O*NET task
   measures]`.

## Implication for our theory section

The methods literature enters in the measurement rationale, not in the
theory section. For the theory section the relevant point is that occupation
x firm x year composition is an established grain (`wang2026organizational`)
and that prior-employer flows are an established measure
(`liu2020predicting`), so the staffing frame is measurable in principle. The
use of O\*NET to score contingencies has no precedent in the corpus and must
be justified from sources outside it before the hypotheses are written with
O\*NET-based scores as their contingency measures.
