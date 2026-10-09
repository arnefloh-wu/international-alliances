# 08_triage_manual_candidates.R
# Agent triage of the manual-matching worklist (priority 1 and, optionally, 3:
# IJVs with a review-tier candidate). It writes decisions in the format read by
# 03_wrds_full_sample.R from data/raw/manual/, in a file named
# manual-matches-claude-<date>.csv so that provenance is visible in the sample
# table (`manual_by`). The file can be deleted to revert every decision.
#
# The rules are deliberately strict. Only clear cases get a decision; all other
# rows stay blank for a person.
#   accept   the first candidate's name equals the JV's name once legal forms,
#            punctuation and spacing are removed, and Revelio headcount is not
#            more than 20 times the Orbis headcount (where Orbis reports 10 or more);
#   replace  the same test holds for exactly one of candidates 2 and 3;
#   reject   the first candidate is a parent's own entity (its name equals or
#            contains a parent's name and not the JV's), or its name shares no
#            content with the JV's name and the name similarity is below 0.6
#            (typical of a parent group's website shared with the JV); JVs
#            whose name is an abbreviation (three or more single letters) and
#            candidates written in non-Latin script are never rejected.
# Everything else, and any case with two matching candidates, is left blank.
#
# Run from the repository root:
#   "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/wrds/08_triage_manual_candidates.R [version]

source("code/R/00_setup.R")
RUN_DATE <- "2026-10-09"
VERSION <- if (length(commandArgs(trailingOnly = TRUE))) commandArgs(trailingOnly = TRUE)[1] else "v3"
RUN <- if (VERSION == "v1") RUN_DATE else paste0(VERSION, "-", RUN_DATE)
f_list <- file.path(paths$interim, sprintf("manual-match-list-%s.csv", RUN))
f_sample <- file.path(paths$processed, sprintf("sample-ijv-%s.csv", RUN))
f_out <- file.path(paths$raw, "manual", sprintf("manual-matches-claude-%s.csv", RUN_DATE))
f_audit <- file.path(paths$interim, sprintf("manual-triage-claude-%s.csv", RUN))
dir.create(dirname(f_out), showWarnings = FALSE, recursive = TRUE)

w <- fread(f_list, colClasses = list(character = c("jv_bvdid", "candidate_rcid_1", "candidate_rcid_2", "candidate_rcid_3")))
s <- fread(f_sample, select = c("jv_bvdid", "score", "method"), colClasses = list(character = "jv_bvdid"))
w <- merge(w[priority %in% c(1L, 3L)], s, by = "jv_bvdid", all.x = TRUE)

# Name key: normalized, legal forms (also spelled with spaces) and filler words
# removed, then letters and digits only.
stop_tokens <- c("and", "the", "of", "de", "la", "le", "el", "del", "du", "des", "co", "company", "corp", "corporation", "inc",
                 "incorporated", "llc", "ltd", "limited", "plc", "gmbh", "mbh", "ag", "sa", "sas", "sasu", "sarl", "srl", "spa", "bv",
                 "nv", "oy", "oyj", "ab", "asa", "as", "aps", "kg", "kk", "ltda", "pty", "pvt", "pte", "sdn", "bhd", "doo", "ooo",
                 "jsc", "pjsc", "llp", "lp", "aie", "sl", "slu", "sp", "zoo", "gp", "opc", "fzc", "fze", "fzco", "dmcc", "psc", "sae",
                 "bsc", "ohg", "gbr", "cv", "vof", "prior", "tbk", "bhd")
spaced_forms <- "\\b(l l c|s a s|s a r l|s r l|s p a|p s c|p j s c|o p c|n v|b v|s a|a s|a g|k g|s a e|d o o|s p z o o|p t y|p t e)\\b"
name_key <- function(x) {
  x <- ifelse(is.na(x), "", x)
  n <- normalize_name(x)
  n <- gsub(spaced_forms, " ", n)
  vapply(strsplit(n, " +"), function(t) paste(t[nzchar(t) & !t %chin% stop_tokens], collapse = ""), character(1))
}
is_latin <- function(x) !is.na(x) & !stringi::stri_detect_regex(x, "[\\p{Han}\\p{Hiragana}\\p{Katakana}\\p{Hangul}\\p{Arabic}\\p{Cyrillic}\\p{Greek}\\p{Hebrew}\\p{Thai}\\p{Devanagari}]")
n_single_letters <- function(x) vapply(strsplit(normalize_name(ifelse(is.na(x), "", x)), " +"), function(t) sum(nchar(t) == 1L), integer(1))
parent_keys <- function(p) {
  parts <- trimws(unlist(strsplit(ifelse(is.na(p), "", p), ";")))
  parts <- sub(" \\([A-Z]{2}\\)$", "", parts)
  k <- name_key(parts)
  k[nchar(k) >= 6]
}
shares_content <- function(a, b) nchar(a) >= 4 && nchar(b) >= 4 && (grepl(a, b, fixed = TRUE) || grepl(b, a, fixed = TRUE))
# Content words of a name (normalized, filler and legal forms removed, five letters or more).
content_tokens <- function(x) {
  n <- gsub(spaced_forms, " ", normalize_name(ifelse(is.na(x), "", x)))
  t <- unlist(strsplit(n, " +"))
  unique(t[nchar(t) >= 5 & !t %chin% stop_tokens])
}
shares_token <- function(a, b) length(intersect(content_tokens(a), content_tokens(b))) > 0
# Differences that the name key hides but that mean a different entity: a holding or
# group word on one side only, and Danish A/S against ApS.
holding_word <- function(x) grepl("\\b(holding|holdings|group|gruppe|groupe)\\b", tolower(x))
danish_form <- function(x) fcase(grepl("\\baps\\b", tolower(x)), "aps", grepl("\\ba/s\\b", tolower(x)), "as", default = "")
same_kind <- function(a, b) holding_word(a) == holding_word(b) && (danish_form(a) == "" || danish_form(b) == "" || danish_form(a) == danish_form(b))

w[, jvkey := name_key(jv_name)]
for (k in 1:3) w[, (paste0("key", k)) := name_key(get(paste0("candidate_name_", k)))]

decide <- function(i) {
  r <- w[i]
  jk <- r$jvkey
  keys <- c(r$key1, r$key2, r$key3)
  rc <- c(r$candidate_rcid_1, r$candidate_rcid_2, r$candidate_rcid_3)
  cnames <- c(r$candidate_name_1, r$candidate_name_2, r$candidate_name_3)
  eq <- which(nchar(jk) >= 6 & keys == jk & !is.na(rc) & rc != "" &
                vapply(cnames, function(cn) !is.na(cn) && same_kind(r$jv_name, cn), logical(1)))
  if (length(eq) > 1) return(list(decision = "", rcid = "", basis = "two candidates match the name; left for a person"))
  if (length(eq) == 1) {
    ratio <- if (!is.na(r$orbis_employees) && r$orbis_employees >= 10 && !is.na(r$n_employees_revelio_if_picked)) r$n_employees_revelio_if_picked / r$orbis_employees else NA_real_
    if (eq == 1) {
      if (!is.na(ratio) && ratio > 20) return(list(decision = "", rcid = "", basis = "name equal but Revelio headcount over 20 times Orbis; left for a person"))
      return(list(decision = "accept", rcid = "", basis = "candidate 1 name equals the JV name after removing legal forms"))
    }
    return(list(decision = "replace", rcid = rc[eq], basis = sprintf("candidate %d name equals the JV name after removing legal forms; candidate 1 does not", eq)))
  }
  c1 <- r$candidate_name_1
  if (is.na(c1) || c1 == "" || !is_latin(c1)) return(list(decision = "", rcid = "", basis = "no Latin-script candidate; left for a person"))
  pk <- parent_keys(r$parents)
  k1 <- keys[1]
  par_hit <- length(pk) > 0 && any(k1 == pk | vapply(pk, function(p) grepl(p, k1, fixed = TRUE) && !grepl(p, jk, fixed = TRUE), logical(1)))
  if (nchar(k1) >= 6 && par_hit) return(list(decision = "reject", rcid = "", basis = "candidate 1 is a parent's own entity"))
  if (!is.na(r$score) && r$score < 0.6 && !shares_content(jk, k1) && !shares_token(r$jv_name, c1) && n_single_letters(r$jv_name) < 3L)
    return(list(decision = "reject", rcid = "", basis = "candidate 1 shares no content with the JV name and similarity is below 0.6"))
  list(decision = "", rcid = "", basis = "not clear enough; left for a person")
}
res <- rbindlist(lapply(seq_len(nrow(w)), function(i) as.data.table(decide(i))))
w <- cbind(w[, .(jv_bvdid, priority, jv_name, jv_country, candidate_rcid_1, candidate_name_1, candidate_rcid_2, candidate_name_2,
                 candidate_rcid_3, candidate_name_3, parents)], res)
fwrite(w, f_audit)
out <- w[decision != "", .(jv_bvdid, decision, rcid_manual = rcid, linkedin_url = "", notes = paste0("claude: ", basis))]
fwrite(out, f_out)
message(sprintf("triage of %d rows: %d accept, %d replace, %d reject, %d left for a person", nrow(w),
                w[decision == "accept", .N], w[decision == "replace", .N], w[decision == "reject", .N], w[decision == "", .N]))
message("decisions written: ", f_out)
