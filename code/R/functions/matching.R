# matching.R
# Entity-name normalization and Orbis-to-Revelio matching helpers.

legal_suffixes <- c(
  "ltd", "limited", "llc", "inc", "incorporated", "corp", "corporation",
  "co", "company", "plc", "gmbh", "ag", "sa", "s a", "sas", "srl", "bv",
  "nv", "oy", "ab", "as", "kk", "co ltd", "pte", "pty", "spa", "sp z o o",
  "ooo", "zao", "pjsc", "jsc", "llp", "lp", "holding", "holdings", "group"
)

#' Normalize a company name for matching.
normalize_name <- function(x) {
  x <- stringi::stri_trans_general(x, "Any-Latin; Latin-ASCII")
  x <- tolower(x)
  x <- gsub("&", " and ", x, fixed = TRUE)
  x <- gsub("[[:punct:]]", " ", x)
  x <- gsub("\\s+", " ", trimws(x))
  pat <- paste0("\\b(", paste(legal_suffixes, collapse = "|"), ")\\b")
  x <- gsub(pat, " ", x)
  gsub("\\s+", " ", trimws(x))
}

#' Match Orbis entities to Revelio companies in three passes.
#' @param orbis data.table with orbis_id, orbis_name, orbis_country
#' @param revelio data.table with rcid, rev_name, rev_country
#' @param jw_threshold Jaro-Winkler similarity cut-off for the fuzzy pass
#' @return data.table of candidate matches with method and score; one row per
#'   orbis_id for exact and normalized passes, up to five rows for fuzzy.
match_entities <- function(orbis, revelio, jw_threshold = 0.92) {
  orbis   <- data.table::copy(orbis)[, norm := normalize_name(orbis_name)]
  revelio <- data.table::copy(revelio)[, norm := normalize_name(rev_name)]

  exact <- merge(orbis, revelio, by.x = "orbis_name", by.y = "rev_name",
                 allow.cartesian = TRUE)[, `:=`(method = "exact", score = 1)]
  rest  <- orbis[!orbis_id %in% exact$orbis_id]

  normd <- merge(rest, revelio, by = "norm", allow.cartesian = TRUE)[
    , `:=`(method = "normalized", score = 1)]
  rest  <- rest[!orbis_id %in% normd$orbis_id]

  fuzzy_list <- lapply(seq_len(nrow(rest)), function(i) {
    cand <- revelio[rev_country == rest$orbis_country[i] | is.na(rev_country)]
    if (nrow(cand) == 0) cand <- revelio
    s <- 1 - stringdist::stringdist(rest$norm[i], cand$norm, method = "jw", p = 0.1)
    keep <- order(s, decreasing = TRUE)[seq_len(min(5, length(s)))]
    keep <- keep[s[keep] >= jw_threshold]
    if (length(keep) == 0) return(NULL)
    cbind(rest[i], cand[keep, .(rcid, rev_name, rev_country)],
          method = "fuzzy", score = s[keep])
  })
  fuzzy <- data.table::rbindlist(fuzzy_list, fill = TRUE)

  out <- data.table::rbindlist(list(exact, normd, fuzzy), fill = TRUE)
  out[, same_country := orbis_country == rev_country]
  out[, n_candidates := .N, by = orbis_id]
  out[, needs_review := method == "fuzzy" | n_candidates > 1]
  out[]
}
