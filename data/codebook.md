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

Under structural contingency theory these scores summarize four contingency families (task, coordination, environmental, resource; see `docs/theory-framework.md`). Gate 3 decides whether two summary scores suffice or a third, `resource_dependence`, is added.

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

## Sample frame from Orbis ownership (Stage 4 pilot, 2026-10-08)

Orbis Crossborder Investment is not on WRDS and SDC joint ventures is not
licensed (`docs/decisions.md`, 2026-10-08), so the frame comes from the
current ownership links in `bvd_orbis_large` and `bvd_orbis_medium`
(`ob_links_current`, relation type `SHH`, active). Script:
`code/R/wrds/02_wrds_pilot_extract.R`.

| Rule | Definition |
|---|---|
| IJV | active, non-dormant company with two or three direct shareholders, each holding 20 to 90 percent, together at least 50 percent, from at least two countries, and at least one foreign to the host country |
| Parent | direct shareholder with a BvD ID (not an aggregated or anonymous holder) whose shareholder type in the JV's first-level shareholder table (`ob_all_cur_shh_1st_level`) is Corporate, Bank, Insurance company or Financial company; an IJV with any other parent type (public authority, fund, nominee or trust, private equity, venture capital, hedge fund, individual or family, employees, foundation, unnamed, self ownership, missing) is excluded |
| Excluded industries | NACE section K (financial and insurance) and NACE 6420/6430 (holding companies, trusts) |
| Formation date | Orbis incorporation date (`dateinc`), 2005 to 2023; stands in for the JV formation date, which the ownership tables do not record |
| Equity share | current direct share (`dir_pct`) and its information date; stands in for the share at formation. `parent_a` is the parent with the larger current share |
| Parent group (Orbis) | GUO at the 50 percent definition (`guo_50`) where present, otherwise the direct parent; GUO names from `ob_w_company_id_table` (large and medium libraries) |
| Parent group (Revelio) | the Revelio entities matched to the direct parent and to its GUO, extended to their whole Revelio family: the Revelio `ultimate_parent_rcid` of each matched entity and every company under it. A prior position anywhere in this family counts as parent origin |
| Country | first two characters of the BvD ID (ISO 3166 alpha-2) |

Consequences: the frame contains only JVs alive with an unchanged
multi-parent structure today, so JVs that were dissolved or bought out
are missing (survivor bias), and ownership changes since formation are
not observed.

## Revelio field assumptions

Source: WRDS `revelio` library (data through 2026-09, checked 2026-10-08).

| Item | Assumption |
|---|---|
| Company | `rcid` from `company_mapping`; `ultimate_parent_rcid` defines the Revelio company group |
| Function | `role_k10_v3` from `individual_role_lookup_v3` (Sales and Marketing, Public Service and Education, Technician, Project and IT Specialist, Engineer, Finance, Service Worker, Healthcare Provider, Operations, Software Engineer), with `role_k50_v3` kept for remapping to the project's nine functions at gate 5 |
| Seniority | integer 1 to 7 in `individual_positions.seniority`; mapping to executive, middle management, professional, operational is set at gate 5 |
| Prior employer | most recent position at another `rcid` that started before the JV spell and was still held within `origin_window` years before it; an ongoing parent position counts as parent origin (secondment) |
| Overlapping positions | each position counts; an individual is in a cell-year if a position overlaps 30 June |
| Duplicates | positions are de-duplicated on `position_id` |
| Cell-years | only years from the JV's formation (incorporation) year onward; earlier spells at the matched entity are counted separately as `person_years_pre_formation` |

## Entity matching tiers (Stage 4 pilot)

| Tier | Rule |
|---|---|
| `auto` | name match (exact, normalized, or Jaro-Winkler >= 0.92 with score >= 0.97 or a single candidate); a JV candidate must be in the host country or have no Revelio country, and must not be a parent's or GUO's own Revelio entity |
| `auto_plus_strong` | adds review-tier candidates found through the JV's website (Revelio url equals an Orbis website domain, or Revelio name starts with the domain's first label) whose normalized name is close (Jaro-Winkler >= 0.85) |
| `auto_plus_review` | adds all review-tier candidates, including the two-token name stem; an upper bound until the PI has checked `data/interim/pilot-jv-review-tier.csv` |

Review-tier rules (`review_tier_candidates()` in `code/R/functions/matching.R`): host country only; no parent entity or member of a parent's Revelio family; no candidate whose name resembles one of the JV's own parents; a route that returns more than one company for a JV gives no pick.
| Country | Revelio country names converted to ISO 2 with the `countrycode` package |
