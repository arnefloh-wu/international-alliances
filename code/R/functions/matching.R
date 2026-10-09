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

#' Website domains from an Orbis website field ("a.com|www.b.de").
#' @return character vector of bare domains (no scheme, path or "www.")
web_domains <- function(website) {
  d <- tolower(trimws(unlist(strsplit(website, "|", fixed = TRUE))))
  d <- sub("^https?://", "", d)
  d <- sub("/.*$", "", d)
  d <- sub("^www[.]", "", d)
  unique(d[!is.na(d) & nzchar(d)])
}

#' Review-tier JV candidates (pilot rules decided 2026-10-08).
#' Routes from the WRDS extraction: "domain" (Revelio url equals an Orbis
#' website domain), "web_stem" (Revelio name starts with the first label of
#' an Orbis website domain) and "stem2" (Revelio name starts with the first
#' two tokens of the Orbis name, parentheses removed). Every route is limited
#' to the host country upstream. Rules: a candidate that is a parent entity or
#' a member of a parent group is dropped; a route that returns more than one
#' company for a JV is dropped (no automatic pick among look-alikes); among
#' the remaining routes, domain beats web_stem beats stem2. All results need
#' PI review.
#' @param cand candidate rows with orbis_id, rcid, company_name, country, match_key
#' @param jv data.table with orbis_id, orbis_name, orbis_country
#' @param parent_rcids rcids of parent entities and parent-group members
#' @param parent_names optional data.table with orbis_id (the JV) and parent_name;
#'   a candidate whose name resembles one of the JV's own parents (Jaro-Winkler
#'   >= 0.85 on normalized names, or one name contained in the other) is dropped,
#'   which catches parents that did not match in Revelio by name
#' @return one row per JV: orbis_id, orbis_name, orbis_country, rcid, rev_name,
#'   rev_country, method, score, same_country, needs_review
review_tier_candidates <- function(cand, jv, parent_rcids, parent_names = NULL) {
  routes <- c("domain", "web_stem", "stem2")
  x <- cand[match_key %in% routes,
            .(orbis_id, rcid, rev_name = company_name, rev_country = country, method = match_key)]
  x <- merge(unique(x), jv, by = "orbis_id")
  x <- x[!rcid %in% parent_rcids & rev_country == orbis_country]
  if (!is.null(parent_names) && nrow(x)) {
    pn <- merge(x[, .(orbis_id, rcid, rn = normalize_name(rev_name))],
                parent_names[, .(orbis_id, pn = normalize_name(parent_name))], by = "orbis_id", allow.cartesian = TRUE)
    pn[, resembles := (1 - stringdist::stringdist(rn, pn, method = "jw", p = 0.1)) >= 0.85 |
                      (nchar(pn) >= 4 & mapply(grepl, pn, rn, fixed = TRUE)) |
                      (nchar(rn) >= 4 & mapply(grepl, rn, pn, fixed = TRUE))]
    x <- x[!paste(orbis_id, rcid) %in% pn[resembles == TRUE, paste(orbis_id, rcid)]]
  }
  x[, n_rcid := uniqueN(rcid), by = .(orbis_id, method)]
  x <- x[n_rcid == 1]
  x[, prio := match(method, routes)]
  data.table::setorder(x, orbis_id, prio)
  x <- x[, .SD[1], by = orbis_id]
  if (nrow(x) == 0) return(data.table::data.table())
  x[, `:=`(score = 1 - stringdist::stringdist(normalize_name(orbis_name), normalize_name(rev_name),
                                              method = "jw", p = 0.1),
           same_country = TRUE, needs_review = TRUE)]
  # Strong: a website route (domain or web_stem) whose name is also close.
  x[, strong := method %in% c("domain", "web_stem") & score >= 0.85]
  x[, .(orbis_id, orbis_name, orbis_country, rcid, rev_name, rev_country, method, score,
        strong, same_country, needs_review)]
}
