---
name: qual-recode
description: "Stage 3 of the research workflow. Recodes the existing manager interviews for differentiated international integration via the qualitative-analyst agent, producing the codebook, coded matrix, measurement memo and propositions. Requires transcripts in data/interviews/."
---

# /qual-recode

Prerequisite: transcripts and `data/interviews/README.md` (consent
rules, respondent codes, language) exist. If not, write the README
template with the questions the PI must answer (location, number,
language, consent terms, what may be quoted) and stop.

Launch the `qualitative-analyst` agent with the brief in its definition.
If transcripts are in German or another language, instruct the agent to
code in the original language and to translate only the excerpts in the
measurement memo, marking them `[translated]`.

After it reports, check that no quote exceeds the 40-word working limit
and that no respondent is identifiable, then commit and summarize: the
function classification proposed for H1 and H2, the hierarchy pattern
for H3, and the triggers respondents name for H4 and H5.
