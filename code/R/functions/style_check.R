# style_check.R
# Sentence-length statistics and AI-tell scan for a manuscript section,
# per the academic-writing skill. Usage:
#   Rscript code/R/functions/style_check.R manuscript/sections/01-introduction.qmd

args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) stop("Give a .qmd or .md file")
txt <- readLines(args[1], warn = FALSE)
txt <- txt[!grepl("^(---|#|<!--|```|\\s*$)", txt)]
txt <- paste(txt, collapse = " ")
txt <- gsub("\\[@[^]]+\\]", "", txt)                 # drop citations
sents <- unlist(strsplit(txt, "(?<=[.!?])\\s+(?=[A-Z])", perl = TRUE))
wc <- vapply(strsplit(sents, "\\s+"), length, integer(1))
cat(sprintf("Sentences: %d  Words: %d  Mean: %.1f  Median: %.0f  SD: %.1f  >45 words: %d\n",
            length(wc), sum(wc), mean(wc), median(wc), sd(wc), sum(wc > 45)))
tells <- c("delve", "crucial", "pivotal", "paramount", "landscape", "realm",
           "tapestry", "intricate", "multifaceted", "nuanced", "leverage",
           "underscore", "shed light", "pave the way", "testament",
           "it is worth noting", "notably", "furthermore", "in conclusion",
           "groundbreaking", "novel", "comprehensive", "moreover", "—")
hits <- vapply(tells, function(t) sum(gregexpr(t, tolower(txt), fixed = TRUE)[[1]] > 0), integer(1))
hits <- hits[hits > 0]
if (length(hits)) { cat("Avoid-list hits:\n"); print(hits) } else cat("No avoid-list hits.\n")
cat("Connector counts: ",
    paste(sprintf("%s=%d", c("thus", "however", "we "),
                  vapply(c("thus", "however", "we "),
                         function(t) sum(gregexpr(t, tolower(txt), fixed = TRUE)[[1]] > 0), integer(1))),
          collapse = "  "), "\n")
