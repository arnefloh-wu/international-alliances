"""Independent second screening of EBSCO block S7-staffing, records 67 to 132
(file order), run 2026-11-24. Reuses the RIS parser and normalizers of
ingest_ebsco_ris.py (imported, not modified).

Usage:
    python -I screen_S7staffing_part2_second.py <file.ris> <screening.csv> <out.csv>

Writes the 12 columns of screening.csv. Bibliographic fields come from the
RIS only. Duplicate check against screening.csv: DOI first, then normalized
title + year; all matching ids are listed in notes.
"""

import csv
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ingest_ebsco_ris import (COLUMNS, parse_ris, to_row, read_sheet,  # noqa: E402
                              clean_doi, norm_title)

FIRST, LAST = 67, 132

# pos: (stream, decision, reason, extra note)
D = {
    67: ("S7", "exclude", "E_offtopic: selection interview in a contingency-style organization; no foreign unit", ""),
    68: ("S7", "exclude", "C_nonscholarly: magazine (Fast Company)", ""),
    69: ("S7", "exclude", "E_offtopic: neurodiversity and leadership (symposium)", ""),
    70: ("S7", "exclude", "E_offtopic: person-environment fit and employee retention (symposium)", ""),
    71: ("S4", "include", "incl (a,e): expatriates' host-country social knowledge as subsidiary control mechanism, contingency approach (proceedings)", "Block S7-staffing; stream S4 by content. Proceedings: later journal version not checked."),
    72: ("S7", "exclude", "E_offtopic: post-ERP IT support structure in domestic firms; no foreign unit", "Generic structural-contingency application; treated like OA-S7-61."),
    73: ("S7", "exclude", "C_nonscholarly: letter to the editor", ""),
    74: ("S7", "exclude", "C_nonscholarly: magazine profile (Fortune)", ""),
    75: ("S7", "exclude", "C_nonscholarly: magazine profile (Fortune International)", "Same item as record 74 in another edition (within-run duplicate)."),
    76: ("S7", "exclude", "E_offtopic: person-environment fit and knowledge sharing", ""),
    77: ("S7", "exclude", "E_offtopic: individual expatriate coping and adjustment", ""),
    78: ("S7", "exclude", "E_offtopic: psychometrics of trait competitiveness", ""),
    79: ("S7", "exclude", "E_offtopic: employee stress in BPO", ""),
    80: ("S7", "exclude", "E_offtopic: person-organization fit and commitment", ""),
    81: ("S7", "exclude", "E_offtopic: executive search model (trade item)", "EBSCO labels the outlet Academic Journal; item reads as a trade feature."),
    82: ("S7", "exclude", "E_offtopic: employees' evaluations of HRM systems", ""),
    83: ("S7", "exclude", "E_offtopic: LMX and subordinate performance", ""),
    84: ("S7", "exclude", "E_offtopic: individual relocation mobility readiness (review)", ""),
    85: ("S7", "exclude", "E_offtopic: person-environment fit in recruiting and job search (symposium)", ""),
    86: ("S7", "exclude", "scope: F_duplicate: proceedings version of a peer-reviewed article; insider versus outsider CEO hiring and background misfit", "Publication-type rule: WebSearch 2026-11-24 finds Keil, Lavie & Pavicevic, 'When do outside CEOs underperform?', Academy of Management Journal 2022, DOI 10.5465/amj.2018.1087 (unverified); in screening.csv as EB-S7-15 per the first agent's merge. Screen the AMJ version under the mechanism-support rule (hiring source: internal versus external), not this abstract."),
    87: ("S7", "unsure", "incl (e)?: nursing-home staffing patterns realigned to a reimbursement policy change, contingency theory (domestic; proceedings)", "Analogous to OA-S7-63 (structural adjustment to regulatory change, no foreign unit). Proceedings: one WebSearch on 2026-11-24 found no later journal version; Crossref and Google Scholar not checked."),
    88: ("S7", "exclude", "E_offtopic: hospital infections, nurse staffing and financial performance", ""),
    89: ("S7", "exclude", "E_offtopic: person-environment fit across the employment cycle (symposium)", ""),
    90: ("S7", "exclude", "E_offtopic: SHRM-knowledge strategy fit and firm performance (domestic)", ""),
    91: ("S7", "exclude", "E_offtopic: HPWS and faculty job satisfaction", ""),
    92: ("S7", "exclude", "D_language: article in French (working paper)", "Topic: socialization of new recruits and innovation in small firms; would be E_offtopic in any case."),
    93: ("S7", "exclude", "E_offtopic: HR information sharing and environmental strategy", ""),
    94: ("S7", "exclude", "E_offtopic: cross-cultural delegation style of managers (NGO), not unit structure or staffing", ""),
    95: ("S7", "exclude", "E_offtopic: barriers to IT projects in hotels", ""),
    96: ("S7", "unsure", "scope: make versus buy human capital (internal development versus external expert hiring) contingent on environmental dynamism", "Mechanism-support rule: hiring-source evidence only (H3 hiring-source step); domestic Italian firms, no foreign unit."),
    97: ("S7", "exclude", "C_nonscholarly: newspaper (Wall Street Journal)", ""),
    98: ("S7", "exclude", "E_offtopic: work and non-work role segmentation", ""),
    99: ("S7", "exclude", "E_offtopic: heterosexism in hiring decisions", ""),
    100: ("S7", "exclude", "E_offtopic: not-for-profit board governance", ""),
    101: ("S7", "exclude", "E_offtopic: managerial culture of expatriate and local managers; no staffing or structure", ""),
    102: ("S7", "exclude", "E_offtopic: ethics of recruitment interview frameworks across a multinational's country units; no staffing composition", ""),
    103: ("S7", "exclude", "E_offtopic: organizational attractiveness and labor productivity", ""),
    104: ("S7", "exclude", "E_offtopic: IT compensation decisions", ""),
    105: ("S7", "exclude", "E_offtopic: job satisfaction of expatriate managers", ""),
    106: ("S7", "exclude", "E_offtopic: speed of new product development projects", ""),
    107: ("S7", "exclude", "E_offtopic: UK youth training policy commentary", ""),
    108: ("S7", "exclude", "E_offtopic: work-ability assessment instrument", ""),
    109: ("S7", "exclude", "E_offtopic: job satisfaction and performance in a privatized firm", ""),
    110: ("S7", "exclude", "E_offtopic: creativity and logic of contradiction", ""),
    111: ("S7", "exclude", "E_offtopic: interpersonal conflict management of Chinese employees", ""),
    112: ("S7", "exclude", "E_offtopic: plant structure and mass customization capability (domestic manufacturing)", "Generic structural-contingency application; treated like OA-S7-57/61."),
    113: ("S7", "exclude", "E_offtopic: teaching exercise on leader selection", ""),
    114: ("S4", "include", "incl (a): monitoring through expatriates and incentive alignment reduce subsidiary autonomy and strategic initiatives", "Block S7-staffing; stream S4 by content (S1 also plausible)."),
    115: ("S7", "exclude", "E_offtopic: leadership style and firm success (Nigeria, Taiwan)", ""),
    116: ("S7", "exclude", "E_offtopic: leader influence and goal interdependence", ""),
    117: ("S7", "exclude", "E_offtopic: responsibility accounting measures for evaluating managers", ""),
    118: ("S7", "exclude", "E_offtopic: HR practices, age and sustainable careers", ""),
    119: ("S7", "exclude", "C_nonscholarly: magazine column (New Statesman)", ""),
    120: ("S7", "exclude", "E_offtopic: star employees and firm innovation", ""),
    121: ("S7", "exclude", "C_nonscholarly: trade publication (Campaign)", ""),
    122: ("S7", "exclude", "C_nonscholarly: magazine (HR Magazine)", ""),
    123: ("S7", "exclude", "C_nonscholarly: trade publication (Training Journal)", ""),
    124: ("S7", "unsure", "incl (e)?: critical biography of Joan Woodward, founder of structural contingency theory (proceedings)", "History of an S7 seed author (Woodward 1965); background use only. Proceedings: later version not checked."),
    125: ("S7", "exclude", "E_offtopic: ethics of nontraditional university presidents", ""),
    126: ("S7", "exclude", "E_offtopic: change in HPWS and firm performance (dynamic HR fit, not structure)", ""),
    127: ("S7", "exclude", "C_nonscholarly: trade publication (Third Sector)", ""),
    128: ("S7", "exclude", "C_nonscholarly: trade publication (Circulation Management)", ""),
    129: ("S7", "exclude", "C_nonscholarly: newspaper (Wall Street Journal)", ""),
    130: ("S7", "exclude", "C_nonscholarly: trade publication (Accountancy)", ""),
    131: ("S7", "exclude", "C_nonscholarly: magazine (InternetWeek)", ""),
    132: ("S7", "exclude", "C_nonscholarly: trade publication (BRW)", "Topic: Australian accounting firms hiring international graduates."),
}
CLOSE_TO_H3 = set()  # no record in 67-132 reports H3 or contingency fit in a two-parent unit


def fmt_authors(aus):
    """'Last, First' -> 'First Last'; sheet convention for 1, 2, 3+ authors."""
    names = []
    for a in aus:
        if "," in a:
            last, first = [p.strip() for p in a.split(",", 1)]
            names.append(f"{first} {last}".strip())
        else:
            names.append(a.strip())
    if not names:
        return "[no author in RIS]"
    if len(names) <= 2:
        return " and ".join(names)
    return names[0] + " et al."


def main(ris, sheet, out):
    recs = [to_row(r) for r in parse_ris(ris)]
    assert len(recs) == 132, len(recs)
    rows = [r for r in read_sheet(sheet)]
    by_doi, by_ty = {}, {}
    for r in rows:
        d = clean_doi(r.get("doi", ""))
        if d:
            by_doi.setdefault(d, []).append(r["id"])
        by_ty.setdefault((norm_title(r["title"]), (r["year"] or "").strip()), []).append(r["id"])
    outrows = []
    for pos in range(FIRST, LAST + 1):
        x = recs[pos - 1]
        stream, dec, reason, extra = D[pos]
        doi_m = by_doi.get(x["doi"], []) if x["doi"] else []
        ty_m = by_ty.get((norm_title(x["title"]), x["year"]), [])
        notes = []
        if doi_m:
            notes.append("duplicate of " + ", ".join(doi_m) + " (DOI).")
        extra_ty = [i for i in ty_m if i not in doi_m]
        if extra_ty:
            notes.append("duplicate of " + ", ".join(extra_ty) + " (title+year).")
        if notes:
            notes.append("EB-S7-* matches are the same EBSCO record from the first agent's merge of this file.")
        notes.append(f"Second screening 2026-11-24, independent of the first agent. EBSCO Business Source run 2026-11-24, block S7-staffing, file exports/ebsco-S7staffing-2026-11-24.ris record {pos}, AN {x['an']}. RIS type {x['ty']}; EBSCO publication type: {'; '.join(x['pubtype'])}.")
        if "<" in x["doi_raw"]:
            notes.append("DOI in the RIS contains markup and is malformed; kept as given, needs Crossref lookup.")
        elif x["doi"]:
            notes.append("DOI as given in the RIS; unverified.")
        else:
            notes.append("No DOI in the RIS.")
        if extra:
            notes.append(extra)
        if pos in CLOSE_TO_H3:
            notes.append("CLOSE-TO-H3")
        outrows.append({
            "id": f"EB-S7S-{pos:03d}",
            "doi": x["doi_raw"].strip(),
            "title": x["title"],
            "authors": fmt_authors(x["authors"]),
            "year": x["year"],
            "journal": x["journal"],
            "source_db": "EBSCO",
            "stream": stream,
            "title_abstract_decision": dec,
            "reason": reason,
            "full_text_decision": "pending" if dec in ("include", "unsure") else "",
            "notes": " ".join(notes),
        })
    with open(out, "w", encoding="utf-8", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=COLUMNS, lineterminator="\r\n")
        w.writeheader()
        w.writerows(outrows)
    from collections import Counter
    print(Counter(r["title_abstract_decision"] for r in outrows))
    print("with duplicate note:", sum("duplicate of" in r["notes"] for r in outrows))
    print("dup of non-EB-S7 rows:", [(r["id"], r["notes"].split(" (")[0]) for r in outrows
                                     if r["notes"].startswith("duplicate of")
                                     and not r["notes"].startswith("duplicate of EB-S7-")])


if __name__ == "__main__":
    main(*sys.argv[1:4])
