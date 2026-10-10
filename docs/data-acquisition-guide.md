# Data acquisition guide: sources outside this chat and outside WRDS

Written 2026-10-09 for the PI. It says where the sample is lost, which outside
sources can help, how to get each one, and exactly how to hand the files back
so the pipeline can ingest them. Sources marked "verified" were checked against
a vendor, library or WRDS page on 2026-10-09; anything else is marked
"unverified" and needs a check with your library or the vendor.

## 1. Read this first

Where the 55,590 joint ventures of frame v3 are lost (`code/R/wrds/03_wrds_full_sample.R v3`):

| Stage | IJVs | Share |
|---|---|---|
| No accepted Revelio entity | 33,117 | 59.6% |
| Matched, but no employee observed after formation | 2,883 | 5.2% |
| Matched, under 20 employees observed | 8,819 | 15.9% |
| Matched, 20 or more employees but under 3 years | 1 | 0.0% |
| Usable, but review tier only | 1,057 | 1.9% |
| Usable, size mismatch (dropped) | 70 | 0.1% |
| Core sample (upper bound) | 9,643 | 17.3% |

The table includes the agent-made manual decisions from section 5. The core row is one lower than the 9,644 used elsewhere because one manually accepted IJV carries a size-mismatch flag and is kept as core.

The recommended main sample removes two routes that audits showed are mostly not joint ventures (Capital IQ prior co-ownership and the small-library sample) and has 7,460 IJVs, of which 2,172 are strategic.

Three consequences.

1. **A bigger frame helps less than better matching.** Most of the frame never
   reaches Revelio. Outside deal lists add frame entries, and those entries
   face the same 58 percent loss. Deal lists add the most where their JVs are
   larger or better documented than Orbis ownership records, and where they
   reach back before 2005 or cover JVs that no longer exist.
2. **Manual matching has the best yield per case.** Many strategic IJVs (two
   operating-firm parents) have no accepted Revelio entity, and 1,584 usable
   IJVs wait on review of a candidate. Section 5 gives the worklist.
3. **Revelio coverage is the hard limit in East Asia.** Only 7.9 percent of
   East Asian IJVs reach the core, against 23.6 percent in Western Europe.
   More Chinese frame entries will not change that. No source that closes this
   gap has been verified, and it is not listed below.

## 2. Priority table

| # | Source | Adds | Access | Effort | Priority |
|---|---|---|---|---|---|
| 1 | Manual matching of the worklist (section 5) | up to 1,057 usable IJVs still held back by a review-tier match (the agent has already resolved part of the rows), plus part of the 1,847 larger strategic IJVs without a candidate | you or a research assistant, with LinkedIn | days of RA time | highest |
| 2 | SDC joint ventures and alliances | JVs since 1988 with participants, nations, status, equity stakes; dissolved JVs | enable on WRDS (schema exists) or LSEG Workspace | an email, then an export | high |
| 3 | Orbis M&A (formerly Zephyr), deal type joint venture | JV deals with participant and target BvD ids | Moody's / Bureau van Dijk subscription of your institution | export, 10 to 40 minutes per run | high |
| 4 | fDi Markets | greenfield JVs from 2003 that create a new physical operation | FT subscription | demo or institutional request | low to medium |
| 5 | GLEIF Level 2 relationship file | no JVs; better group detection, so fewer intra-group false positives in external lists | free download | one download | helper |
| 6 | Companies House PSC snapshot (UK) | UK companies with two corporate controllers | free download | large JSON parse | low (Orbis already covers UK) |
| 7 | EU merger decisions on JVs | full-function JVs notified in the EU, with parents and dates | public website | manual case list | low (JV names are rarely real entity names) |
| 8 | FactSet Revere | pairs of partner firms, not JV entities | not licensed on WRDS | request through WRDS | low |

## 3. Sources you can ask for inside WRDS (no download outside WRDS)

### SDC joint ventures (schema `tr_sdc_joint_ventures`)

- Status (verified): the schema and the table `sdc_joint_ventures` appear in the WRDS catalogue, and the account is refused access (`permission denied for schema tr_sdc_joint_ventures`). The view `sdc.sdc_joint_ventures` points at the same schema.
- Who to ask: the WRDS representatives at your institution. Every subscribing institution has at least two, usually librarians (library guides on WRDS access). WRDS support lists wrds@wharton.upenn.edu (address from a 2021 WRDS page; confirm before writing).
- What to ask for: "Enable the Thomson Reuters / LSEG SDC Joint Ventures and Alliances library on our WRDS subscription, or tell me whether our SDC Platinum licence covers it."
- Fields the table holds (verified in the WRDS catalogue): `master_deal_no`, `sequence_no`, `jv_name`, `jvstatus`, `jv_type`, `jvindustry`, `jvweb`, `jvpublic`, `jv_cusip`, `equity_stake`, `jv_owner_est`, `pnation` and `pupnation` (participant and ultimate-parent nations), `pup` (participant ultimate parent), `strategic_alliance_flag`, `date_expired`, `count_par`, `aa_hdate`, and about 100 more.
- Once access exists, tell me. I will pull it through WRDS, add it to the frame with the `source` and `admitted_by` columns, and run the matching.

## 4. Sources you fetch yourself

For every source: save the export in `data/raw/external/`, name it `<source>-<YYYY-MM-DD>.csv`, and keep it out of git (the folder is already ignored). The required columns are in section 6.

### 4.1 SDC Platinum through LSEG Workspace (use if WRDS enablement fails)

1. Access (verified in library guides): you need an LSEG Workspace account and the SDC Platinum add-on, which libraries usually request from LSEG separately; Purdue and McMaster both describe a library-side request step. Ask your library which they use. From January 2024 SDC data is delivered through LSEG Workspace (a library note).
2. Open the app (verified): in Workspace, type "SDC" in the top search bar and open SDC Platinum, or use the short code SDC in the APPLIB bookmark.
3. Choose the joint ventures and strategic alliances data (LSEG lists 219,000+ records in this module). Filter: record type joint venture, not licensing or marketing alliances; equity JVs only; any announcement date; any status (including terminated). Restrict to JVs with participants from at least two nations if the screen allows.
4. Export the fields listed in section 3. Prefer one row per participant. If the screen exports one row per deal with numbered participant columns, use `wide_to_long()` (section 6).
5. Export limits are not documented for this module (unverified). A library note reports 1,000 deals per 24 hours for the M&A screener and another reports no limit through the Workspace Excel add-in. Test with a small export first and ask your library which applies. The Excel add-in works fully only on Windows (St. Gallen library note).

### 4.2 Orbis M&A (formerly Zephyr)

1. Access: Orbis M&A is Moody's Analytics / Bureau van Dijk and is not part of the Orbis tables on WRDS (checked: no deal tables in any Orbis library you can read). It needs your institution's subscription. Your GitHub organisation is named `arnefloh-wu`, which suggests WU Vienna; I have not confirmed that. If it is WU, the WU library page (verified) says: campus access, remote access through the WU VPN, Zephyr content sits inside Orbis under Navigation, Report, News and Deals, M&A; there is a Zephyr Advanced Portal for combined criteria; settings cannot be saved, so keep your search strategy in a file; at most two exports can run at once, each takes about 10 to 40 minutes, and an interrupted export cannot be resumed.
2. Search: deal type joint venture. Status: completed (and, as a second run, announced and pending, to see how much they add). Dates: all available (the product describes European deals from 1997, North America from 2000 and other regions from 2003; sources differ on start dates, so check the date range in your account). Keep a screenshot of the filters, because the sample-construction log needs them.
3. Export one row per deal participant, with: deal number, deal type, deal status, announced date, completed date, target name, target BvD id, target country, acquiror/participant name, participant BvD id, participant country, stake acquired and final stake (field names differ by version; choose the equivalents).
4. Orbis M&A gives BvD ids. Put the target BvD id in `jv_bvdid`; the importer then drops JVs already in the frame, and I can look the target up in the Orbis tables on WRDS.

### 4.3 fDi Markets (Financial Times)

1. Access (verified): subscription product of FT Locations; the vendor page offers a demo request and says non-subscribers should contact the vendor. It states no academic price or access terms. Ask your library first, then FT.
2. Scope (verified): joint ventures are included only when they create a new physical operation; announcements are included before completion; the database starts in 2003.
3. The vendor page does not state a JV flag, the export formats or the row limits (all unverified). Before paying for access, ask: does each project record the partner companies, and is there a joint-venture marker?
4. If the answers are yes: export investing company, source country, destination country, announcement date, project name and any partner field; map them to section 6. I rate this low to medium because fDi projects are new sites, not always legal entities with their own headcount.

### 4.4 Free sources

- **GLEIF Level 2 (verified page).** Daily golden-copy files: Level 1 (who is who), Level 2 relationship records (direct and ultimate parents, the "who owns whom" file) and reporting exceptions, in the vendor's common data format (XML/CSV/JSON; the page does not name the download file type). Download page: https://www.gleif.org/en/lei-data/gleif-golden-copy/download-the-golden-copy. The file records consolidating parents, so it will not list most JV owners. Its use here is to decide whether two parents of an external-list JV belong to the same group. Check the data terms linked on the page before use.
- **Companies House PSC snapshot, UK (verified page).** Free, rebuilt every morning, JSON, one zip or 33 split zips: https://download.companieshouse.gov.uk/en_pscdata.html. The page points to the Companies House API field documentation (developer-specs.company-information.service.gov.uk) for field names and does not describe corporate controllers or ownership bands itself. Open Ownership reports ownership bands of 25 to 50, 50 to 75 and 75 to 100 percent and no tracing through intermediaries. A JV is a company with two corporate controllers in the 25 to 50 percent band. Orbis already draws on UK registry data, so I expect few additions; do this last.
- **EU merger decisions (partly verified).** The Commission publishes decisions on full-function joint ventures; example case documents are on ec.europa.eu/competition/mergers. The search site address (competition-cases.ec.europa.eu) was not verified. JV names in these decisions are often placeholders ("Volvo / Daimler / JV"), which makes matching to Revelio hard. Use it only for specific JVs you want to confirm.

### 4.5 Other leads (not verified here)

Dealogic, Mergermarket and Crunchbase deal records; national registers (for China, the registration type for Sino-foreign equity joint ventures); World Bank infrastructure project databases. None has been assessed. Ask before spending time on them: the loss table in section 1 says the constraint is Revelio coverage, not the number of JVs listed.

## 5. Manual matching worklist

The worklist `data/interim/manual-match-list-v3-2026-10-09.csv` (written by `code/R/wrds/07_manual_match_list.R v3`; it exists now) has 9,285 rows. In priority order: (1) 976 strategic IJVs with a review-tier candidate to confirm; (2) 1,847 strategic IJVs with at least 50 Orbis employees and no candidate; (3) 1,210 other IJVs with a review-tier candidate; (4) 5,252 smaller or unknown-size strategic IJVs with no candidate. Do priorities 1 and 2 first (2,823 rows); priority 4 is unlikely to pay back. Each row gives the JV, its parents, website, Orbis headcount and up to three Revelio candidates with LinkedIn pages. It opens in Excel.

Status (2026-10-09): the agent has triaged the 2,186 rows of priorities 1 and 3 with `code/R/wrds/08_triage_manual_candidates.R` (103 accepted, 109 replaced, 464 rejected, 1,510 left blank). Its decisions are in `data/raw/manual/manual-matches-claude-2026-10-09.csv`, are labelled `claude` in the sample table, and are overridden by any decision you save on the same IJV. Priorities 2 and 4 are untouched. Open the per-row log `data/interim/manual-triage-claude-v3-2026-10-09.csv` to spot-check the agent, then work the rows it left blank: priority 1 has 688 of them, priority 3 has 822.

For each row, fill in three columns:

| Column | What to enter |
|---|---|
| `decision` | `accept` (the first candidate is the JV), `reject` (the candidate is wrong and no entity exists or is findable), or `replace` (the JV is another Revelio entity) |
| `linkedin_url` | for `replace`: the LinkedIn company page of the JV, copied from the browser address bar, for example `https://www.linkedin.com/company/some-company` |
| `notes` | anything that helps review |

Rules for the person matching:

- The JV must be the legal entity of the venture, not a parent and not a parent's other subsidiary. Check the name, the host country and the website. If the only page found is the parent's, enter `reject`.
- Use LinkedIn company search with the JV name and city; the website domain listed in the file helps.
- Save the filled file as `data/raw/manual/manual-matches-<initials>-<YYYY-MM-DD>.csv` with at least the columns `jv_bvdid`, `decision`, `linkedin_url`. Later files and later rows override earlier ones.
- The next full run turns LinkedIn pages into Revelio company ids (Revelio stores `http://linkedin.com/company/<slug>`, checked), pulls the new entities' positions and counts verified JVs as tier `manual`, which ranks above automatic matches.

## 6. How to hand files back

Required columns, one row per JV-parent pair, UTF-8 CSV:

| Column | Required | Meaning |
|---|---|---|
| `ext_id` | yes | the source's own deal or company id, unique per JV |
| `jv_name` | yes | name of the venture |
| `jv_country` | yes | host country, ISO2 or the country name |
| `parent_name` | yes | one parent per row |
| `parent_country` | yes | that parent's home country |
| `parent_share` | no | equity share in percent |
| `formation_year` | no | year formed or announced |
| `jv_website`, `jv_lei`, `jv_bvdid` | no | help matching and de-duplication |
| `status`, `industry` | no | free text; banks, insurers and financial JVs are dropped |

Example:

```
ext_id,jv_name,jv_country,parent_name,parent_country,parent_share,formation_year
D-1001,Nova Pack Sp. z o.o.,PL,Alfa Packaging SA,FR,50,2011
D-1001,Nova Pack Sp. z o.o.,PL,Beta Verpackungen GmbH,DE,50,2011
```

If your export has one row per deal with numbered participant columns, reshape it first with `wide_to_long()` from `code/R/functions/external.R` (the docstring has an example).

Then either tell me the files are in place, or run:

```bash
"C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/06_ingest_external_jvs.R
"C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/03_wrds_full_sample.R v4
```

The first command checks the files, drops JVs already in the frame, intra-group arrangements (parents with the same first name word, because external lists carry no group data), financial JVs and one-country JVs, and writes a report of every drop to `data/interim/external-ingest-report-2026-10-09.csv`. The second matches the new JVs to Revelio and writes `data/processed/sample-ijv-v4-2026-10-09.csv`.

## 7. Licence and data handling

SDC, Orbis M&A and fDi Markets exports are licensed; `data/raw/` is gitignored and must stay that way (CLAUDE.md rule 2). Do not paste licensed rows into the chat. If a source's licence forbids storing exports in Dropbox, store them locally and set `IA_DATA_DIR` accordingly (`data/README.md`).
