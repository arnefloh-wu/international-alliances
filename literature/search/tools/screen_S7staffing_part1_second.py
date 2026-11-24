"""Independent second screening of EBSCO block S7-staffing, records 1 to 66.

Written 2026-11-24 as a reliability check on the first screening (the first
agent's fragment is screen-S7staffing-part1.csv; this script does not read
it). Reuses the parser of ingest_ebsco_ris.py without modifying it.

Usage:
    python -I screen_S7staffing_part1_second.py <file.ris> <screening.csv> <out.csv>

Metadata (doi, title, authors, year, journal) come from the RIS only. The
duplicate check runs against screening.csv on DOI, then on normalized title
plus year, and within the file.
"""

import csv
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ingest_ebsco_ris as T  # noqa: E402

LO, HI = 1, 66

# position: (decision, reason, extra note)
# Stream is S7 for every record: protocol v1.2 assigns hits of a block the
# stream in the block name. Where another stream also fits, the note says so.
D = {
 1: ("exclude", "E_offtopic: person-organization misfit feedback and job seekers", ""),
 2: ("exclude", "E_offtopic: supply chain resilience case; no staffing or unit structure", ""),
 3: ("exclude", "E_offtopic: conceptual AI and hybrid-work framework", ""),
 4: ("exclude", "E_offtopic: review of person-environment misfit", ""),
 5: ("exclude", "C_nonscholarly: practitioner magazine (Rotman Management)", ""),
 6: ("unsure", "scope: inside versus outside CEO hiring; misfit of outside CEOs' backgrounds with the firm", "Hiring-source evidence at CEO level, domestic US firms; mechanism support for H3 hiring-source step only."),
 7: ("exclude", "E_offtopic: individual person-environment fit of public-to-private movers under workforce nationalization", ""),
 8: ("exclude", "E_offtopic: review of job crafting", ""),
 9: ("include", "incl (a) and (e): structural contingency theory applied to MNE subsidiary structures and expatriate outcomes", "Wholly owned hotel units; no second parent. Also fits S4."),
 10: ("exclude", "E_offtopic: contingency of firm-level selection-practice use; no structure, staffing composition or hiring source", "Borderline: tests environment x HR practice fit; not structural."),
 11: ("exclude", "E_offtopic: employee perceptions of HR practices in local and international firms", ""),
 12: ("exclude", "E_offtopic: careers of autistic employees", ""),
 13: ("include", "incl (a): staffing origin (assigned and self-initiated expatriates, former inpatriates, host-country nationals) by subsidiary I-R strategy, contingency perspective", "CLOSE-TO-H3: subsidiaries with both integration and responsiveness needs (multi-focal) favor former inpatriates and SIEs, i.e. staff with both parent and host knowledge; subsidiary level, wholly owned, no function split; crisis setting (COVID, capital controls) relates to H4. Also fits S4 and S2."),
 14: ("include", "incl (e): extends structural contingency theory to team structure-environment fit and person-team fit", "Laboratory teams; individual differences are the moderator, so cite only for the structural-fit part."),
 15: ("exclude", "E_offtopic: person-job versus person-organization fit as selection criteria", ""),
 16: ("exclude", "E_offtopic: person-job misfit driving job formalization; no contingency or foreign unit", "Proceedings abstract."),
 17: ("exclude", "E_offtopic: recruiter evaluation of former entrepreneurs", ""),
 18: ("exclude", "E_offtopic: workplace curiosity and conflict in intensive care units", ""),
 19: ("exclude", "E_offtopic: recruiter evaluation of entrepreneurship education", "Proceedings abstract."),
 20: ("exclude", "E_offtopic: psychometric validation of a life orientation scale", ""),
 21: ("exclude", "E_offtopic: university tuition pricing", ""),
 22: ("exclude", "E_offtopic: team task conflict and innovation", ""),
 23: ("exclude", "E_offtopic: enterprise risk management adoption", ""),
 24: ("exclude", "E_offtopic: ideological person-organization misfit and CEO activism", ""),
 25: ("include", "incl (a): international management strategy and expatriate staffing policies, contingency perspective", "Headquarters level, Taiwanese MNCs. Also fits S4."),
 26: ("exclude", "E_offtopic: talent-management practices in hotels during COVID; no structure or foreign unit", ""),
 27: ("exclude", "E_offtopic: universal, contingency or configurational HRM approaches in performing arts", ""),
 28: ("exclude", "E_offtopic: review of remote work and work-life balance", ""),
 29: ("exclude", "E_offtopic: symposium on human capital resource management", "Proceedings symposium abstract."),
 30: ("exclude", "E_offtopic: telecommuting technology and communication fit", ""),
 31: ("exclude", "E_offtopic: person-organization misfit and counterproductive behavior", ""),
 32: ("exclude", "E_offtopic: realistic job previews for salespeople", ""),
 33: ("exclude", "E_offtopic: symposium on person-environment (mis)fit adaptation", "Proceedings symposium abstract."),
 34: ("exclude", "E_offtopic: contingency test of recruitment interview decisions", ""),
 35: ("exclude", "E_offtopic: HR practice adoption and commitment in local and multinational firms", ""),
 36: ("exclude", "E_offtopic: hospital infections, nurse staffing and financial performance", ""),
 37: ("exclude", "C_nonscholarly: cartoons in a practitioner periodical", ""),
 38: ("exclude", "E_offtopic: governance of not-for-profit organizations", ""),
 39: ("exclude", "C_nonscholarly: news item (Bloomberg)", ""),
 40: ("exclude", "F_duplicate: repeats EB-S7S-039 in the same export (news item)", ""),
 41: ("exclude", "E_offtopic: review of ethnic discrimination in recruitment", ""),
 42: ("include", "incl (a): expatriate assignment use by international management strategy, strategic contingency approach", "Also fits S4."),
 43: ("exclude", "E_offtopic: corporate philanthropy and investor reactions", ""),
 44: ("exclude", "C_nonscholarly: newspaper item (Wall Street Journal)", ""),
 45: ("exclude", "E_offtopic: timing of early hiring in start-ups; not hiring source", "Proceedings abstract."),
 46: ("exclude", "E_offtopic: strategic HRM and person-environment fit propositions", "Proceedings paper; a later journal version was not checked because the record is off-topic."),
 47: ("exclude", "C_nonscholarly: trade magazine item on a consultancy report", "RIS type says Academic Journal; no author, item summarizes a vendor report."),
 48: ("exclude", "E_offtopic: Fiedler leadership contingency model", "1975, before the protocol date range."),
 49: ("exclude", "C_nonscholarly: practitioner magazine (TD: Talent Development)", ""),
 50: ("unsure", "scope: organizational context and insider versus outsider general manager selection (organizational familiarity), contingency perspective", "Hiring source as a function of environmental instability and strategy, business-unit heads, domestic; mechanism support for H3 hiring-source step only (and possibly H4 logic)."),
 51: ("exclude", "E_offtopic: supply chain resilience case; no staffing or unit structure", "Proceedings abstract; same author and topic as EB-S7S-002 (2026 journal article), possibly an earlier version; not verified."),
 52: ("exclude", "E_offtopic: motivational person-job fit in job choice", ""),
 53: ("exclude", "E_offtopic: employee-supervisor pacing fit", ""),
 54: ("exclude", "E_offtopic: innovation-oriented culture and product innovativeness", ""),
 55: ("exclude", "E_offtopic: rural hospital service mix and financial performance", "Proceedings abstract."),
 56: ("exclude", "E_offtopic: national and technology differences in recruitment practices", ""),
 57: ("exclude", "E_offtopic: public managers' telework during COVID", ""),
 58: ("exclude", "E_offtopic: individual socialization model", "1976, before the protocol date range."),
 59: ("exclude", "E_offtopic: salesperson turnover intention in two countries", ""),
 60: ("exclude", "E_offtopic: individual differences and empowerment of nurses", ""),
 61: ("exclude", "E_offtopic: person-environment misfit and social context", ""),
 62: ("exclude", "E_offtopic: conceptual contingency view of public-sector diversity management", ""),
 63: ("exclude", "E_offtopic: adoption of volunteer-management practices", ""),
 64: ("exclude", "F_duplicate: proceedings version of a later journal article (publication-type rule)", "Journal version found by WebSearch 2026-11-24: Zinn, Feng, Mor, Intrator & Grabowski (2008), Health Care Management Review 33(2) 113-123, DOI 10.1097/01.HMR.0000304506.12556.52 (from search results; not Crossref-verified). Same findings (administrative nurse staffing +5.5% and +4.0%). The journal version should be screened under (e): staffing composition adjusting to a regulatory change; likely include as structural-adjustment evidence. RIS DOI carries <n> markup, removed here."),
 65: ("exclude", "E_offtopic: person-team guanxi fit and justice", ""),
 66: ("exclude", "E_offtopic: gender discourse in digital-industry recruitment", ""),
}

COLUMNS = T.COLUMNS


def fmt_authors(aus):
    names = []
    for a in aus:
        a = a.replace("\xa0", " ").strip()
        if "," in a:
            last, first_ = [p.strip() for p in a.split(",", 1)]
            names.append(f"{first_} {last}".strip())
        else:
            names.append(a)
    if not names:
        return ""
    if len(names) == 1:
        return names[0]
    if len(names) == 2:
        return f"{names[0]} and {names[1]}"
    return f"{names[0]} et al."


def clean_doi(raw):
    d = re.sub(r"</?n>", "", raw or "")
    return T.clean_doi(d)


def main(ris, sheet, out):
    recs = [T.to_row(r) for r in T.parse_ris(ris)]
    if len(recs) != 132:
        print(f"warning: {len(recs)} records, expected 132", file=sys.stderr)
    by_doi, by_ty, _ = T.build_index(T.read_sheet(sheet))
    seen = {}
    rows = []
    for i in range(LO, HI + 1):
        r = recs[i - 1]
        dec, reason, note = D[i]
        doi = clean_doi(r["doi_raw"])
        title = r["title"].replace("\xa0", " ").strip()
        key = (T.norm_title(title), r["year"])
        notes = []
        ids = []
        if doi and doi in by_doi:
            ids = by_doi[doi]
        elif key in by_ty:
            ids = by_ty[key]
        if ids:
            notes.append("duplicate of " + "; ".join(ids))
        if key in seen:
            notes.append(f"repeats {seen[key]} within the export")
        else:
            seen[key] = f"EB-S7S-{i:03d}"
        notes.append(f"Second screening 2026-11-24, file exports/ebsco-S7staffing-2026-11-24.ris record {i}, AN {r['an']}")
        if note:
            notes.append(note)
        rows.append({
            "id": f"EB-S7S-{i:03d}",
            "doi": doi,
            "title": title,
            "authors": fmt_authors(r["authors"]),
            "year": r["year"],
            "journal": r["journal"],
            "source_db": "EBSCO",
            "stream": "S7",
            "title_abstract_decision": dec,
            "reason": reason,
            "full_text_decision": "pending" if dec in ("include", "unsure") else "",
            "notes": ". ".join(n.rstrip(".") for n in notes) + ".",
        })
    with open(out, "w", encoding="utf-8", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=COLUMNS, lineterminator="\r\n")
        w.writeheader()
        w.writerows(rows)
    from collections import Counter
    c = Counter(r["title_abstract_decision"] for r in rows)
    nd = sum(1 for r in rows if "duplicate of" in r["notes"])
    print(f"wrote {len(rows)} rows: {dict(c)}; duplicates of existing rows {nd}")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    main(*sys.argv[1:])
