"""Parse EBSCO RIS exports, check them against the search blocks, and
deduplicate within the run and against literature/search/screening.csv.

Python standard library only. Written for the incremental lit-search run
of 2026-11-24 (EBSCO blocks S3-local, S7-multiparent, S7-staffing).

Usage (from any directory; paths are absolute or relative to the cwd):

    python -I ingest_ebsco_ris.py parse  <screening.csv> <out.json> <file.ris> [<file.ris> ...]
    python -I ingest_ebsco_ris.py append <screening.csv> <decisions.csv>

`parse` writes one JSON object per record with the parsed fields, the
block-match flags, and the duplicate status (within run, or against an
existing screening id). Files whose name is `ebsco-<block>-<date>.ris`
take the block from the name; otherwise the block is inferred from the
match flags and reported.

`append` appends rows from a decisions CSV (same 12 columns as
screening.csv) to screening.csv, byte-for-byte preserving the existing
content and its CRLF line endings, and refuses ids that already exist.
"""

import csv
import html
import io
import json
import os
import re
import sys
import unicodedata

COLUMNS = ["id", "doi", "title", "authors", "year", "journal", "source_db",
           "stream", "title_abstract_decision", "reason",
           "full_text_decision", "notes"]

# --------------------------------------------------------------------------
# RIS parsing
# --------------------------------------------------------------------------

TAG_RE = re.compile(r"^([A-Z][A-Z0-9])  - ?(.*)$")


def parse_ris(path):
    """Return a list of dicts; repeated tags become lists."""
    with open(path, encoding="utf-8-sig", newline="") as fh:
        text = fh.read()
    records, cur, last = [], None, None
    for raw in text.splitlines():
        m = TAG_RE.match(raw)
        if m:
            tag, val = m.group(1), m.group(2).strip()
            if tag == "TY":
                cur, last = {"TY": [val]}, "TY"
                continue
            if tag == "ER":
                if cur is not None:
                    records.append(cur)
                cur, last = None, None
                continue
            if cur is None:
                continue
            cur.setdefault(tag, []).append(val)
            last = tag
        elif raw.strip() and cur is not None and last:
            # continuation line
            cur[last][-1] = (cur[last][-1] + " " + raw.strip()).strip()
    if cur is not None:
        records.append(cur)
    return records


def first(rec, tag, default=""):
    v = rec.get(tag)
    return html.unescape(v[0]) if v else default


def clean_doi(doi):
    doi = (doi or "").strip()
    doi = re.sub(r"^(https?://(dx\.)?doi\.org/|doi:\s*)", "", doi, flags=re.I)
    return doi.lower()


def norm_title(t):
    t = html.unescape(t or "")
    t = unicodedata.normalize("NFKD", t)
    t = "".join(c for c in t if not unicodedata.combining(c))
    t = t.lower().replace("&", " and ")
    t = re.sub(r"[^0-9a-z぀-ヿ一-鿿]+", " ", t)
    return re.sub(r"\s+", " ", t).strip()


def year_of(rec):
    y1 = first(rec, "Y1") or first(rec, "PY") or first(rec, "DA")
    m = re.search(r"(19|20)\d{2}", y1)
    return m.group(0) if m else ""


def to_row(rec):
    authors = [html.unescape(a) for a in rec.get("AU", [])]
    journal = first(rec, "JO") or first(rec, "T2") or first(rec, "JF")
    return {
        "an": first(rec, "AN"),
        "ty": first(rec, "TY"),
        "doi": clean_doi(first(rec, "DO")),
        "doi_raw": first(rec, "DO"),
        "title": first(rec, "TI"),
        "authors": authors,
        "year": year_of(rec),
        "journal": journal,
        "volume": first(rec, "VL"),
        "issue": first(rec, "IS"),
        "sp": first(rec, "SP"),
        "ep": first(rec, "EP"),
        "abstract": first(rec, "AB"),
        "keywords": [html.unescape(k) for k in rec.get("KW", [])],
        "pubtype": [html.unescape(n) for n in rec.get("N1", [])],
        "language": first(rec, "LA"),
        "db": first(rec, "DB"),
        "url": first(rec, "UR"),
    }

# --------------------------------------------------------------------------
# Block checks: approximations of the EBSCO strings of 2026-11-24
# (search-strings.md, "2026-11-24 targeted follow-up"). Unqualified terms
# in EBSCO search the default fields; here they are checked against title,
# abstract, subject terms and keywords. The check is a plausibility test of
# the block assignment, not a re-run of the search: EBSCO also applies
# stemming and searches fields that are not in the export.
# --------------------------------------------------------------------------


def rx(*terms):
    parts = []
    for t in terms:
        t = re.escape(t.lower()).replace(r"\*", r"\w*").replace(r"\?", r"\w?")
        parts.append(t)
    return re.compile(r"\b(" + "|".join(parts) + r")", re.I)


JV = rx("joint venture", "ijv")
LOCAL = rx("local partner", "local parent", "host partner", "domestic partner")
S3_STAFF = rx("staffing", "secondment", "seconded", "personnel transfer",
              "top management team", "human resource", "recruit")
CONT_S7S = rx("contingency theory", "structural contingency",
              "contingency approach", "contingency perspective", "misfit")
STAFF_S7S = rx("staffing", "workforce composition", "expatriat",
               "host-country national", "host country national", "recruit",
               "hiring")
JV_MP = rx("joint venture", "multiple parent", "shared ownership",
           "multiple principal")
CONT_MP = rx("contingency theory", "structural contingency",
             "contingency approach", "organizational fit",
             "organisational fit", "misfit", "information processing")
STRUCT = rx("structure", "design", "control", "staffing")


def block_flags(r):
    ti, ab = r["title"], r["abstract"]
    allf = " ".join([ti, ab] + r["keywords"])
    s3 = bool((JV.search(ti) or JV.search(ab)) and LOCAL.search(ab)
              and S3_STAFF.search(ab))
    s7m = bool((JV_MP.search(ti) or JV_MP.search(ab)) and CONT_MP.search(ab)
               and STRUCT.search(allf))
    s7s = bool((CONT_S7S.search(ti) or CONT_S7S.search(ab))
               and STAFF_S7S.search(allf))
    misfit_only = bool(s7s and not re.search(
        r"contingency (theory|approach|perspective)|structural contingency",
        ti + " " + ab, re.I))
    return {"S3local": s3, "S7multiparent": s7m, "S7staffing": s7s,
            "s7staffing_misfit_only": misfit_only}

# --------------------------------------------------------------------------
# Existing sheet
# --------------------------------------------------------------------------


def read_sheet(path):
    with open(path, encoding="utf-8", newline="") as fh:
        return list(csv.DictReader(fh))


def build_index(rows):
    by_doi, by_ty, by_t = {}, {}, {}
    for r in rows:
        d = clean_doi(r.get("doi", ""))
        if d:
            by_doi.setdefault(d, []).append(r["id"])
        nt = norm_title(r.get("title", ""))
        if nt:
            by_ty.setdefault((nt, (r.get("year") or "").strip()), []).append(r["id"])
            by_t.setdefault(nt, []).append(r["id"])
    return by_doi, by_ty, by_t


NAME_RE = re.compile(r"^ebsco-(S\w+?)-(\d{4}-\d{2}-\d{2})\.ris$", re.I)


def cmd_parse(sheet, out, files):
    rows = read_sheet(sheet)
    by_doi, by_ty, by_t = build_index(rows)
    seen_doi, seen_ty = {}, {}
    result = []
    for f in files:
        base = os.path.basename(f)
        m = NAME_RE.match(base)
        recs = [to_row(r) for r in parse_ris(f)]
        flags = [block_flags(r) for r in recs]
        tallies = {k: sum(fl[k] for fl in flags) for k in
                   ("S3local", "S7multiparent", "S7staffing",
                    "s7staffing_misfit_only")}
        block = m.group(1) if m else max(
            ("S3local", "S7multiparent", "S7staffing"),
            key=lambda k: tallies[k])
        print(f"{base}: {len(recs)} records; block={'name:' if m else 'inferred:'}{block}; "
              f"matches {tallies}")
        for i, (r, fl) in enumerate(zip(recs, flags), 1):
            r.update(file=base, block=block, pos=i, flags=fl)
            key_ty = (norm_title(r["title"]), r["year"])
            dup = None
            if r["doi"] and r["doi"] in by_doi:
                dup = ("existing", "doi", by_doi[r["doi"]])
            elif key_ty in by_ty:
                dup = ("existing", "title+year", by_ty[key_ty])
            elif r["doi"] and r["doi"] in seen_doi:
                dup = ("run", "doi", [seen_doi[r["doi"]]])
            elif key_ty in seen_ty:
                dup = ("run", "title+year", [seen_ty[key_ty]])
            # title-only matches are reported for inspection, not merged
            title_only = by_t.get(key_ty[0], []) if not dup else []
            r["dup"] = dup
            r["title_only_existing"] = title_only
            tag = f"{base}#{i}"
            if not dup:
                if r["doi"]:
                    seen_doi[r["doi"]] = tag
                seen_ty[key_ty] = tag
            result.append(r)
    with open(out, "w", encoding="utf-8") as fh:
        json.dump(result, fh, ensure_ascii=False, indent=1)
    n_dup_e = sum(1 for r in result if r["dup"] and r["dup"][0] == "existing")
    n_dup_r = sum(1 for r in result if r["dup"] and r["dup"][0] == "run")
    print(f"total {len(result)}; duplicates of existing rows {n_dup_e}; "
          f"duplicates within run {n_dup_r}; unique {len(result)-n_dup_e-n_dup_r}")


def cmd_append(sheet, decisions):
    with open(sheet, "rb") as fh:
        original = fh.read()
    if not original.endswith(b"\r\n"):
        sys.exit("screening.csv does not end with CRLF; refusing to append")
    existing_ids = {r["id"] for r in read_sheet(sheet)}
    with open(decisions, encoding="utf-8", newline="") as fh:
        new = list(csv.DictReader(fh))
    if not new:
        sys.exit("no decision rows")
    if list(new[0].keys()) != COLUMNS:
        sys.exit(f"decision columns differ: {list(new[0].keys())}")
    clash = [r["id"] for r in new if r["id"] in existing_ids]
    if clash or len({r['id'] for r in new}) != len(new):
        sys.exit(f"id clash or repeated id: {clash}")
    buf = io.StringIO(newline="")
    w = csv.writer(buf, lineterminator="\r\n", quoting=csv.QUOTE_MINIMAL)
    for r in new:
        w.writerow([r[c] for c in COLUMNS])
    with open(sheet, "ab") as fh:
        fh.write(buf.getvalue().encode("utf-8"))
    with open(sheet, "rb") as fh:
        after = fh.read()
    assert after.startswith(original), "existing bytes changed"
    added = after[len(original):]
    assert added.count(b"\n") == added.count(b"\r\n"), "non-CRLF line ending"
    print(f"appended {len(new)} rows; existing {len(original)} bytes unchanged")


if __name__ == "__main__":
    if len(sys.argv) >= 5 and sys.argv[1] == "parse":
        cmd_parse(sys.argv[2], sys.argv[3], sys.argv[4:])
    elif len(sys.argv) == 4 and sys.argv[1] == "append":
        cmd_append(sys.argv[2], sys.argv[3])
    else:
        sys.exit(__doc__)
