# 01_wrds_discover.R
# Lists the WRDS libraries (schemas) and tables available to your account
# that look relevant for this project (Orbis / BvD, Revelio), with column
# names, and saves the catalogue to data/interim/wrds-catalog.csv.
#
# Run on your own computer, not in the Claude cloud environment: the cloud
# proxy does not support database connections. From the repository root:
#   Rscript code/R/wrds/01_wrds_discover.R
#
# Credentials: set WRDS_USERNAME in ~/.Renviron (never commit it). The
# password is read from ~/.pgpass if present, otherwise from WRDS_PASSWORD,
# otherwise you are prompted. WRDS may ask you to approve a Duo push.
# ~/.pgpass line format: wrds-pgdata.wharton.upenn.edu:9737:wrds:<user>:<password>

if (!requireNamespace("RPostgres", quietly = TRUE)) install.packages("RPostgres")
if (!requireNamespace("DBI", quietly = TRUE)) install.packages("DBI")
library(DBI)

user <- Sys.getenv("WRDS_USERNAME")
if (user == "") stop("Set WRDS_USERNAME in ~/.Renviron first.")
pw <- Sys.getenv("WRDS_PASSWORD")
args <- list(RPostgres::Postgres(), host = "wrds-pgdata.wharton.upenn.edu",
             port = 9737, dbname = "wrds", sslmode = "require", user = user)
if (pw != "") args$password <- pw
con <- do.call(dbConnect, args)
on.exit(dbDisconnect(con))

# Libraries the account can read.
libs <- dbGetQuery(con, "
  SELECT DISTINCT table_schema AS library
  FROM information_schema.tables
  WHERE table_schema NOT IN ('information_schema', 'pg_catalog')
  ORDER BY 1")
pattern <- "revelio|bvd|orbis|zephyr|crossborder|cbi"
relevant <- libs$library[grepl(pattern, libs$library, ignore.case = TRUE)]
cat("Libraries readable:", nrow(libs), "\nLooks relevant:", paste(relevant, collapse = ", "), "\n")
if (length(relevant) == 0)
  message("No library name matched '", pattern, "'. Check the full list in data/interim/wrds-libraries.csv.")

# Tables and columns in the relevant libraries (metadata only, no data rows).
cols <- if (length(relevant)) dbGetQuery(con, sprintf("
  SELECT table_schema AS library, table_name, column_name, data_type
  FROM information_schema.columns
  WHERE table_schema IN (%s)
  ORDER BY table_schema, table_name, ordinal_position",
  paste(sprintf("'%s'", relevant), collapse = ", "))) else data.frame()

dir.create("data/interim", showWarnings = FALSE, recursive = TRUE)
write.csv(libs, "data/interim/wrds-libraries.csv", row.names = FALSE)
write.csv(cols, "data/interim/wrds-catalog.csv", row.names = FALSE)
cat("Wrote data/interim/wrds-libraries.csv and data/interim/wrds-catalog.csv\n")
cat("These contain table and column names only. Copy them to the project",
    "Dropbox folder (or paste the summary) so the extraction script can be written.\n")
