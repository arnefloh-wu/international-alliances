# external.R
# Helpers for turning an external deal export into the long format read by
# code/R/wrds/06_ingest_external_jvs.R (one row per JV-parent pair).

#' Reshape a wide export (one row per JV, numbered participant columns) into
#' the long ingest format.
#'
#' @param x data.table with one row per JV.
#' @param jv_cols named character vector mapping ingest names to columns of x:
#'   ext_id, jv_name, jv_country (required); formation_year, jv_website, jv_lei,
#'   jv_bvdid, status, industry (optional).
#' @param parent_name_cols character vector of the columns holding parent names,
#'   in participant order.
#' @param parent_country_cols same, for parent countries (same length).
#' @param parent_share_cols same, for equity shares (optional; same length).
#' @return data.table in the ingest format.
#' @examples
#' w <- data.table::data.table(id = "D1", venture = "Nova Co", host = "PL",
#'   p1 = "Alfa SA", c1 = "FR", p2 = "Beta GmbH", c2 = "DE")
#' wide_to_long(w, c(ext_id = "id", jv_name = "venture", jv_country = "host"),
#'              c("p1", "p2"), c("c1", "c2"))
wide_to_long <- function(x, jv_cols, parent_name_cols, parent_country_cols, parent_share_cols = NULL) {
  stopifnot(data.table::is.data.table(x), length(parent_name_cols) == length(parent_country_cols),
            all(c("ext_id", "jv_name", "jv_country") %in% names(jv_cols)),
            is.null(parent_share_cols) || length(parent_share_cols) == length(parent_name_cols))
  base <- x[, unname(jv_cols), with = FALSE]
  data.table::setnames(base, names(jv_cols))
  out <- data.table::rbindlist(lapply(seq_along(parent_name_cols), function(k) {
    d <- data.table::copy(base)
    d[, parent_name := as.character(x[[parent_name_cols[k]]])]
    d[, parent_country := as.character(x[[parent_country_cols[k]]])]
    d[, parent_share := if (is.null(parent_share_cols)) NA_character_ else as.character(x[[parent_share_cols[k]]])]
    d
  }))
  out[!is.na(parent_name) & trimws(parent_name) != ""]
}
