# synthetic_onet.R
# Synthetic twins of the two O*NET extracts of code/R/wrds/14_wrds_onet_code.R:
#   revelio-role-lookup-v3   role taxonomy with onet_code and onet_title
#   revelio-jv-positions-onet  position_id and onet_code
# Positions are those of the synthetic spell table of synthetic_matched.R, so the
# panel code can be built and tested without WRDS. Every value is drawn from a
# distribution; no real row, role name or O*NET code is read. Codes use the
# made-up major group 99 and roles carry the prefix SYN.
# Seeded failures (each is counted at the end and must be caught by the checks
# in 14_wrds_onet_code.R, step "coverage"):
#   positions without onet_code; non-occupation codes ("On Leave", "Retired",
#   "unknown") that must be treated as missing; repeated position_id; spell
#   positions absent from the pull; a lookup role without onet_code; a role in
#   the spells that the lookup does not hold.
# Run: "C:/Program Files/R/R-4.6.1/bin/Rscript.exe" code/R/tests/synthetic_onet.R
source("code/R/00_setup.R")
require_pkgs("arrow")
set.seed(20261125)
GEN_DATE <- "2026-11-25"
f_sp <- file.path("data", "synthetic", "ijv-employee-spells-synthetic-2026-11-23.parquet")
sp <- as.data.table(arrow::read_parquet(f_sp, col_select = c("position_id", "role_k17000_v3")))

# Lookup: one row per synthetic role, made-up codes in major group 99.
roles <- sort(unique(na.omit(sp$role_k17000_v3)))
n_codes <- 60L
codes <- sprintf("99-%04d.%s", sample(1000:9999, n_codes), sample(c("00", "00", "00", "01", "02"), n_codes, replace = TRUE))
lk <- data.table(role_k17000_v3 = roles[-1],                       # seeded: first spell role missing from the lookup
                 role_k50_v3 = sprintf("SYN role group %02d", sample(1:50, length(roles) - 1L, replace = TRUE)),
                 onet_code = sample(codes, length(roles) - 1L, replace = TRUE))
lk[, onet_title := sprintf("SYN occupation %s", onet_code)]
lk[1, `:=`(onet_code = NA_character_, onet_title = NA_character_)]   # seeded: lookup role without code
lk[, synthetic := TRUE]

# Position-level codes: the code of the role, with seeded failures.
po <- merge(unique(sp, by = "position_id"), lk[, .(role_k17000_v3, onet_code)], by = "role_k17000_v3", all.x = TRUE)[, .(position_id, onet_code)]
i_miss <- sample(nrow(po), 120L); po[i_miss, onet_code := NA_character_]                     # seeded: no code
i_odd  <- sample(setdiff(seq_len(nrow(po)), i_miss), 30L)
po[i_odd, onet_code := sample(c("On Leave", "Retired", "unknown"), 30L, replace = TRUE)]       # seeded: non-occupation codes
dropped <- sample(po$position_id, 25L); po <- po[!position_id %in% dropped]                     # seeded: absent from the pull
po <- rbind(po, po[sample(.N, 8L)])                                                             # seeded: repeated position_id
po[, synthetic := TRUE]

dir.create(file.path("data", "synthetic"), showWarnings = FALSE)
arrow::write_parquet(lk, file.path("data", "synthetic", sprintf("revelio-role-lookup-v3-synthetic-%s.parquet", GEN_DATE)))
arrow::write_parquet(po, file.path("data", "synthetic", sprintf("revelio-jv-positions-onet-synthetic-%s.parquet", GEN_DATE)))

# Checks with the rules of 14_wrds_onet_code.R: a valid code matches NN-NNNN(.NN).
valid <- function(x) !is.na(x) & grepl("^[0-9]{2}-[0-9]{4}([.][0-9]{2})?$", x)
found <- c(
  no_code         = sum(is.na(po$onet_code)),
  non_occupation  = sum(!is.na(po$onet_code) & !valid(po$onet_code)),
  repeated_id     = sum(duplicated(po$position_id)),
  absent_from_pull = sum(!unique(sp$position_id) %in% po$position_id),
  lookup_no_code  = sum(is.na(lk$onet_code)),
  role_not_in_lookup = sum(!roles %in% lk$role_k17000_v3))
seeded <- c(no_code = 120L, non_occupation = 30L, repeated_id = 8L, absent_from_pull = 25L, lookup_no_code = 1L, role_not_in_lookup = 1L)
print(data.table(failure = names(seeded), seeded = seeded, found = found[names(seeded)]))
# Positions of the role missing from the lookup and of the lookup role without a code
# also have no code, and repeated rows may copy a seeded missing or odd code.
expected_no_code <- 120L + sum(unique(sp, by = "position_id")$role_k17000_v3 %in% c(roles[1], lk$role_k17000_v3[1]) &
                               unique(sp, by = "position_id")$position_id %in% po$position_id)
cat("positions without a code from the two lookup failures:", expected_no_code - 120L, "\n")
stopifnot(all(found[names(seeded) != "no_code"] == seeded[names(seeded) != "no_code"]),
          found[["no_code"]] >= 120L, found[["no_code"]] <= expected_no_code + 8L)
cat("synthetic O*NET extracts written:", nrow(lk), "lookup rows,", nrow(po), "position rows\n")
