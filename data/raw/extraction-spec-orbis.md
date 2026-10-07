# Extraction specification: Orbis Crossborder Investment (pilot)

Purpose: draw approximately 100 international equity joint ventures for
the matching pilot (research idea, section 12).

## Sample frame

- Deal type: joint venture (equity), completed.
- At least two parents (investors) with headquarters in different
  countries.
- Deal completion / JV formation date: 2005-01-01 or later, and at least
  three years before the latest Revelio observation year, so that a
  three-year operating window exists.
- JV entity identifiable: Orbis BvD ID of the JV company present.
- Stratification for the pilot (approx. 100): roughly equal across host
  regions (North America, Western Europe, Central and Eastern Europe,
  East Asia, South and Southeast Asia, Middle East and Africa, Latin
  America) and across broad industries (manufacturing, extractive,
  services, technology). Oversample dyads likely to be exposed to the
  candidate shocks (for example US-China, EU-Russia, EU-China,
  Japan-Korea, India-China) so that Stage 5 has something to assess.

## Fields to export

JV: BvD ID, name, country, city, NACE/NAICS code, formation date, status,
employee count (latest), total assets (latest).
Parents (one row per parent): BvD ID, name, country, GUO BvD ID and
country, equity share at formation, equity share latest, listed flag.
Deal: deal ID, announcement date, completion date, deal value, deal
rationale text, source.

Export as CSV, UTF-8, one row per JV-parent pair, named
`orbis-pilot-<YYYY-MM-DD>.csv`.
