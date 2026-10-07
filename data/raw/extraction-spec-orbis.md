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
  services, technology). Oversample joint ventures exposed to the
  shortlisted shocks from the shock scan (gate 5a, pending), so that the
  re-scoring can count exposure:
  - UK-EU pairs: a UK parent with an EU parent, or a UK parent in an
    EU-hosted JV and vice versa (Brexit, end of free movement 2021).
  - Parents that appear on the US Entity List, and their partners
    (staggered designations).
  - JVs with a Chinese parent, or hosted in China, whose partner country
    was a target of Chinese economic coercion (for example Australia,
    South Korea, Japan, Norway, Lithuania, Canada).
  - JVs hosted in OECD countries that adopted or tightened investment
    screening after 2010.
  - Reserve: JVs with a Russian parent or hosted in Russia (Russia 2022
    sanctions). Revelio coverage of Russia is likely weak.
  A rough target for the 100: about 15 to 20 per shortlisted group and the
  rest as an unexposed comparison spread across regions and industries.

## Fields to export

JV: BvD ID, name, country, city, NACE/NAICS code, formation date, status,
employee count (latest), total assets (latest).
Parents (one row per parent): BvD ID, name, country, GUO BvD ID and
country, equity share at formation, equity share latest, listed flag.
Deal: deal ID, announcement date, completion date, deal value, deal
rationale text, source.

Export as CSV, UTF-8, one row per JV-parent pair, named
`orbis-pilot-<YYYY-MM-DD>.csv`.
