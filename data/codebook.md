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
| Intra-group exclusion (applied 2026-10-09) | the parents of an IJV must resolve to at least two distinct Orbis GUOs (50 percent definition, looked up in the large, medium and small libraries; a parent without a GUO record is its own GUO). JVs whose parents share one GUO are subsidiaries held through two group entities and are excluded (`excl_jv = intra_group`). The two pilots of 2026-10-08 predate the rule; their reports exclude intra-group JVs from the usable counts |
| Large-JV stratum (pilot 2) | eligible JVs not in pilot 1 with an Orbis headcount (`empl`, latest year) of at least 100 and at least two parents whose own or GUO name has an exact or normalized Revelio match |

Consequences: the frame contains only JVs alive with an unchanged
multi-parent structure today, so JVs that were dissolved or bought out
are missing (survivor bias), and ownership changes since formation are
not observed.

## Full-frame sample (2026-10-09)

Table `data/processed/sample-ijv-2026-10-09.csv`, one row per eligible IJV, from `code/R/wrds/03_wrds_full_sample.R`.

| Variable | Definition |
|---|---|
| `tier` | `auto` (accepted name, LEI, ISIN or native-name match with the pilot guards), `strong` (website route with a close name), `review` (other review-tier route), `shared_entity_dropped` (another JV took the same Revelio entity), `unmatched` |
| `usable` | at least 20 employees and 3 observed years from the formation year at the matched entity |
| `core` | usable, tier `auto` or `strong`, and no size mismatch |
| `flag_size_mismatch` | Orbis headcount of 10 or more and Revelio employees more than 20 times that headcount |
| `flag_pre_formation_10y` | the matched entity's first position starts more than 10 years before the JV's incorporation year; the incorporation date then probably does not mark the JV's formation |
| `flag_holding_vehicle` | JV name contains "holding" and Orbis headcount is 5 or fewer or missing; the match is to the operating company |
| `operating_parents` | parents that are operating firms: the parent or its GUO has at least 50 employees in Orbis, or the parent's or GUO's matched Revelio entity has at least 50 people |
| `strategic` | at least two operating-firm parents; separates JVs between operating companies from companies co-owned by founders' holding companies and investment vehicles |

Additional matching routes in the full run: the JV's previous and also-known-as names (Orbis `prevname`, `akaname`), and its native-script name (exact match after removing spaces and punctuation). GUOs that are states or government bodies do not define parent families. Each Revelio entity counts for one JV only.

## Frame v2 (2026-10-09)

Built by `code/R/wrds/05_wrds_frame_v2.R`; matched by `code/R/wrds/03_wrds_full_sample.R v2`; sample table `data/processed/sample-ijv-v2-2026-10-09.csv`.

| Variable | Definition |
|---|---|
| `source` | `orbis` (Orbis ownership links) or `ciq` (Capital IQ ownership relations); Capital IQ JVs with the same normalized name and country as an Orbis JV are dropped |
| `admitted_by` | `base` if the JV meets the base rules; otherwise the relaxations that admit it: `stake_10_20` (a parent holds 10 to 20 percent), `four_parents`, `formed_before_2005`, `not_active` (company status not active), `guo_country` (two-country rule met only at the GUO level; not yet run), and `ciq` for Capital IQ JVs |
| Capital IQ IJV | a company (public or private) with two to four owners that are public or private companies, each holding 10 to 90 percent through a current investment or current subsidiary relation, together at least 50 percent, owners in at least two countries and at least one foreign to the company; financial-sector companies excluded |
| Capital IQ groups | an owner's group is its majority parent (current subsidiary relation above 50 percent) or the owner itself; this one-level check misses deeper common ownership |
| `formation_year` (Capital IQ) | `yearfounded`; where missing, 1990 and `formation_year_missing = TRUE` |
| Industry pick | the Orbis industry table can hold several rows per company; the v1 frame and the v2 frame used for the 2026-10-09 run took one without a fixed order, which moves a few hundred JVs in or out of the financial-sector exclusion between runs. `05_wrds_frame_v2.R` now orders the rows; the next rebuild is deterministic |

Matching changes in the v2 run: name keys are searched in cached batches; when an Orbis JV and a Capital IQ JV of the same tier pick the same Revelio entity, the Orbis JV keeps it; positions at JV entities and career histories are shared with v1 and pulled incrementally.

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
