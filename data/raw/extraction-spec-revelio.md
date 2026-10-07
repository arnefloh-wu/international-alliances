# Extraction specification: Revelio Labs (pilot)

Purpose: observe the workforce of the pilot IJVs and their parents.

## Companies

For each pilot JV and each parent: Revelio company id (`rcid`), name,
ultimate parent rcid, country, LinkedIn URL, industry, headcount series.
Export the full candidate set returned by name search for each JV, not
only the top match, so that the matching script can score alternatives.

## Positions

For every individual with at least one position at a matched JV rcid:
all positions in the individual's history (previous and subsequent
employers are needed to classify parent origin), with: user id
(anonymized), rcid, company name, start date, end date, title (raw and
mapped), Revelio role/function taxonomy fields (`job_category`,
`role_k150` or equivalent), seniority level, location (country, region),
and the salary and prestige scores if available.

Format: CSV (UTF-8), named `revelio-companies-<date>.csv` and
`revelio-positions-<date>.csv`. Parquet needs the R package arrow, which
is not installed in the cloud environment.

## Documentation to attach

The Revelio data dictionary version used, the seniority scale
definition, and the function taxonomy used, so that `data/codebook.md`
can record them.
