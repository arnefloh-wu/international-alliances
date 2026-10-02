# Codebook

Updated by the data-engineer and quant-analyst agents. Every variable in
the processed panels is listed here with source, construction and unit.

## Identifiers

| Variable | Level | Source | Definition |
|---|---|---|---|
| `ijv_id` | IJV | Orbis BvD ID | JV legal entity |
| `rcid_ijv` | IJV | Revelio | matched company id |
| `parent_a_id`, `parent_b_id` | IJV | Orbis BvD ID (GUO) | parent A is the parent with the larger equity share at formation; ties broken alphabetically by country code |
| `dyad` | IJV | derived | ordered pair of parent HQ country codes |
| `function` | cell | Revelio `job_category` mapped | one of: rd_engineering, operations_manufacturing, supply_chain_procurement, finance, hr, sales_marketing, it, general_management, other |
| `level` | cell | Revelio seniority mapped | one of: executive, middle_management, professional, operational |
| `year` | cell | derived | calendar year; an individual is in a cell-year if the position overlaps 30 June of that year |

## Dependent variables (see `code/R/functions/measures.R`)

| Variable | Definition | Range |
|---|---|---|
| `n_emp` | employees observed in the cell-year | count |
| `n_from_a`, `n_from_b`, `n_external` | employees whose most recent prior employer (or any prior employer within `origin_window` years) was parent A, parent B, neither | count |
| `share_a`, `share_b` | `n_from_a / (n_from_a + n_from_b)`, likewise B; NA if no parent-origin employees | 0 to 1 |
| `cross_parent_integration` | `2 * (1 - (share_a^2 + share_b^2))`, so 0 = one parent only, 1 = equal representation | 0 to 1 |
| `parent_dominance` | `abs(share_a - share_b)` | 0 to 1 |
| `parent_dominance_adj` | `abs((share_a - share_b) - (equity_a - equity_b))`, deviation of staffing asymmetry from equity asymmetry | 0 to 2 |
| `localization` | `n_external / n_emp` | 0 to 1 |
| `localization_host` | external employees whose prior position was in the host country / `n_emp` | 0 to 1 |

## Domain characteristics (from the qualitative memo, finalized at G5)

| Variable | Definition |
|---|---|
| `coord_dependence` | score 1 to 5 for the function's dependence on cross-partner coordination and knowledge exchange |
| `local_embeddedness` | score 1 to 5 for the function's dependence on host-country institutions, labor markets, customers, regulators |
| `coord_role` | for levels: 1 if the level carries alliance-wide coordination responsibility (executive, middle management), else 0 |

## Shock (finalized at G5)

| Variable | Definition |
|---|---|
| `shock` | 1 from the first year in which the dyad is exposed to the focal environmental change |
| `event_time` | year minus first exposure year; NA for never exposed |

## Controls

`ijv_age`, `ijv_size_log`, `equity_a`, `equity_b`, `equity_balance`
(= 1 - |equity_a - equity_b|), `n_parents`, `parent_a_size_log`,
`parent_b_size_log`, `parent_a_roa`, `parent_b_roa`, `industry`,
`host_country`, `dist_a_host`, `dist_b_host`, `inst_dist_a_host`,
`inst_dist_b_host`, `host_gdp_growth`, `host_wgi`.

## Revelio field assumptions

(To be filled by the data-engineer agent from the data dictionary
version used: seniority scale, function taxonomy, prior-employer
definition, treatment of overlapping positions, coverage caveats.)
