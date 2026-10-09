# frame.R
# Region, industry and shock-exposure classification of IJVs. Same rules as
# step B of code/R/wrds/02_wrds_pilot_extract.R (which keeps its own copy so
# that the 2026-10-08 pilot draws stay reproducible).

eu27 <- c("AT","BE","BG","HR","CY","CZ","DK","EE","FI","FR","DE","GR","HU","IE","IT","LV","LT","LU","MT","NL","PL","PT","RO","SK","SI","ES","SE")
coerced_by_china <- c("AU","KR","JP","NO","LT","CA")   # ASPI coercion targets named in the Orbis spec
oecd_screening <- c("AU","AT","CA","CZ","DK","FI","FR","DE","HU","IT","JP","KR","LV","LT","NL","NZ","NO","PL","PT","ES","SE","GB","US","IE","BE","CH")

region_of <- function(iso) data.table::fcase(
  iso %chin% c("US","CA"), "north_america",
  iso %chin% c("MX","BR","AR","CL","CO","PE","UY","PY","BO","EC","VE","CR","PA","GT","DO","CU","HN","SV","NI"), "latin_america",
  iso %chin% c(setdiff(eu27, c("BG","HR","CZ","EE","HU","LV","LT","PL","RO","SK","SI")), "GB","CH","NO","IS","LI","MC"), "western_europe",
  iso %chin% c("BG","HR","CZ","EE","HU","LV","LT","PL","RO","SK","SI","RS","BA","ME","MK","AL","UA","BY","MD","RU","GE","AM","AZ","KZ","UZ","KG","TJ","TM"), "central_eastern_europe",
  iso %chin% c("CN","JP","KR","TW","HK","MO","MN","AU","NZ","PG","FJ"), "east_asia_pacific",
  iso %chin% c("IN","PK","BD","LK","NP","BT","MV","SG","MY","TH","ID","VN","PH","KH","LA","MM","BN","TL"), "south_southeast_asia",
  default = "middle_east_africa")

industry_of <- function(sec) data.table::fcase(
  sec %chin% c("B","D","E"), "extractive_utilities",
  sec == "C", "manufacturing",
  sec %chin% c("J"), "technology",
  is.na(sec) | sec == "", "unknown",
  default = "services")

#' Exposure group of a JV from its host country and its parents' countries.
#' @param host ISO2 host country (vector)
#' @param parents list of character vectors of parent countries
exposure_group_of <- function(host, parents) {
  uk_eu  <- mapply(function(p, h) ("GB" %in% p & any(eu27 %in% c(p, h))) | (h == "GB" & any(eu27 %in% p)), parents, host)
  china  <- mapply(function(p, h) ("CN" %in% c(p, h)) & any(coerced_by_china %in% setdiff(c(p, h), "CN")), parents, host)
  russia <- mapply(function(p, h) "RU" %in% c(p, h), parents, host)
  data.table::fcase(russia, "russia", china, "china_coercion", uk_eu, "uk_eu",
                    host %chin% oecd_screening, "oecd_screening", default = "unexposed")
}
