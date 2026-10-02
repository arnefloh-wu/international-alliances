---
name: references
description: "Stage 9 of the research workflow. Verifies the bibliography, syncs literature/references.bib with the Zotero group library, checks every citation key in the manuscript and synthesis, and resolves [CITE:] markers via the reference-manager agent."
---

# /references

Launch the `reference-manager` agent with the brief in its definition.

## Zotero setup (one-time, by the PI)

1. Create a Zotero group library for the project and note its numeric
   id (the number in the group URL).
2. Create a Zotero API key with read/write access to that group at
   zotero.org/settings/keys.
3. Put `ZOTERO_API_KEY=...` and `ZOTERO_GROUP_ID=...` in `.Renviron` or
   `.env` at the repository root. Both files are gitignored.
4. Install Better BibTeX in Zotero, set the citation key formula to
   `auth.lower + year + shorttitle(1,1).lower`, and set an automatic
   export of the group library to `literature/references.bib`.

## API calls the agent uses

- Read items: `GET https://api.zotero.org/groups/<id>/items?format=bibtex&limit=100&start=<n>`
  with header `Zotero-API-Key`.
- Create items: `POST https://api.zotero.org/groups/<id>/items` with a
  JSON array of item objects; obtain templates from
  `GET https://api.zotero.org/items/new?itemType=journalArticle`.
- Verify DOIs: `GET https://api.crossref.org/works/<doi>` with a
  descriptive `User-Agent` header including a contact e-mail from the
  environment, never hard-coded.

If the Zotero API is unreachable from the agent environment, the agent
writes `literature/zotero/import-<date>.ris` and the PI imports it
manually. The `.bib` remains the single source of truth either way.
