# ================================================================
# FacetMAP | Five-factor hierarchical SEM (lavaan)
# Free, open-source companion to BFF_ALL_FINAL.inp (Mplus)
# ================================================================
# Requirements: R and the CRAN package lavaan
# First use: install.packages("lavaan")
# Run: Rscript run_facetmap_lavaan.R   (or source() it in R)
# The data (facet_map.dat) are read from the GitHub repository by default.
# Optional override: Rscript run_facetmap_lavaan.R /path/to/data.dat
# Input format: whitespace-delimited headerless Mplus .dat (470 columns),
# or CSV with original column names. See facetmap_columns.txt.
# Companion files are used from this folder if present, else from GitHub.
# They are generated from BFF_ALL_FINAL_annotated.inp by
# translate_mplus_to_lavaan.R.

if (!requireNamespace("lavaan", quietly = TRUE)) {
  stop('Missing R package lavaan. Install with: install.packages("lavaan")')
}

github_raw <- "https://raw.githubusercontent.com/UlrichSchimmack/Personality-Trait-Taxonomy-PTT-/HEAD/"
local_or_github <- function(f) if (file.exists(f)) f else paste0(github_raw, f)

model_file <- local_or_github("facetmap_reference_model.lavaan")
vars_file <- local_or_github("facetmap_columns.txt")
used_file <- local_or_github("facetmap_used_columns.txt")
input_path <- if (length(commandArgs(trailingOnly = TRUE)) > 0) {
  commandArgs(trailingOnly = TRUE)[1]
} else paste0(github_raw, "facet_map.dat")

if (!grepl("^https?://", input_path) && !file.exists(input_path)) {
  stop("Raw data not found: ", input_path)
}
cat("Data:", input_path, "\n")

all_names <- scan(vars_file, what = character(), quiet = TRUE)
used_names <- scan(used_file, what = character(), quiet = TRUE)
stopifnot(length(all_names) == 470L, length(used_names) == 210L,
          !anyDuplicated(all_names), !anyDuplicated(used_names),
          all(used_names %in% all_names))

if (grepl("\\.csv$", input_path, ignore.case = TRUE)) {
  dat <- read.csv(input_path, check.names = FALSE)
  missing_columns <- setdiff(used_names, colnames(dat))
  if (length(missing_columns)) {
    stop("CSV is missing required columns: ", paste(missing_columns, collapse = ", "))
  }
} else {
  dat <- read.table(input_path, header = FALSE, na.strings = c("NA", "."),
                    stringsAsFactors = FALSE, fill = FALSE)
  if (ncol(dat) != length(all_names)) {
    stop("Expected 470 columns in Mplus raw .dat, found ", ncol(dat),
         ". Check encoding/delimiter and original variable order.")
  }
  colnames(dat) <- all_names
}

dat <- dat[, used_names, drop = FALSE]
for (v in used_names) {
  if (!is.numeric(dat[[v]])) {
    dat[[v]] <- suppressWarnings(as.numeric(dat[[v]]))
  }
}
if (anyNA(dat)) {
  warning("Missing values detected. Original Mplus input has no explicit MISSING declaration. ",
          "Current lavaan run uses listwise deletion; confirm with source data before comparisons.")
}

model <- paste(readLines(model_file, warn = FALSE), collapse = "\n")
cat("Fitting FacetMAP hierarchical model in lavaan...\n")
cat("Rows:", nrow(dat), " | observed variables:", ncol(dat), "\n")

# Mplus: ANALYSIS MODEL=NOCOV; ML estimator; fixed marker coefficients,
# fixed/equal HALO item loadings, and fixed RSET loadings.
# Suppress lavaan's automatic covariance additions; permit ONLY WITH statements
# that appear explicitly in the translated model.
fit <- lavaan::sem(
  model = model,
  data = dat,
  estimator = "ML",
  std.lv = FALSE,
  auto.fix.first = FALSE,
  auto.var = TRUE,
  auto.cov.lv.x = FALSE,
  auto.cov.y = FALSE,
  int.ov.free = TRUE,
  int.lv.free = FALSE,
  meanstructure = TRUE,
  fixed.x = FALSE,
  missing = "listwise",
  se = "standard",
  information = "observed"
)

# Mplus results for BFF_ALL_FINAL_annotated.inp (bff_all_final_annotated.out)
reference <- c(npar = 1016, chisq = 36590.140, df = 21349,
               cfi = 0.900, tli = 0.897, rmsea = 0.026, srmr = 0.047)
actual <- tryCatch(lavaan::fitMeasures(
  fit, c("npar", "chisq", "df", "cfi", "tli", "rmsea", "srmr")),
  error = function(e) { warning(conditionMessage(e)); NULL }
)
# lavaan's npar counts each equality-labelled loading separately; count
# free parameters net of equality constraints, as Mplus does.
p <- length(used_names)
npar_net <- p * (p + 3) / 2 - lavaan::fitMeasures(fit, "df")
if (!is.null(actual)) actual["npar"] <- npar_net
cat("\nReference Mplus vs lavaan:\n")
if (!is.null(actual)) print(rbind(Mplus_reference = reference, lavaan = actual))
cat("\nConverged:", lavaan::lavInspect(fit, "converged"), "\n")
if (lavaan::lavInspect(fit, "converged")) {
  cat("Free parameter difference (lavaan minus Mplus): ",
      npar_net - 1016L, "\n")
  standardized <- lavaan::standardizedSolution(fit)
  pe <- lavaan::parameterEstimates(fit, standardized = TRUE)
  write.csv(pe, "lavaan_parameter_estimates.csv", row.names = FALSE)
  write.csv(subset(standardized, op == "=~"),
            "lavaan_standardized_loadings.csv", row.names = FALSE)
  write.csv(subset(standardized, op == "~~" & lhs != rhs),
            "lavaan_residual_covariances.csv", row.names = FALSE)
  mi <- lavaan::modindices(fit)
  mi <- mi[order(-mi$mi), , drop = FALSE]
  write.csv(mi, "lavaan_modification_indices.csv", row.names = FALSE)
  cat("\nLargest ten modification indices:\n")
  print(head(mi, 10))
}
writeLines(capture.output(summary(fit, fit.measures = TRUE,
                                  standardized = TRUE)),
           "lavaan_summary.txt")
saveRDS(fit, "lavaan_fitted_model.rds")
cat("\nWrote lavaan_summary.txt, .rds, and (if converged) parameter CSV files.\n")
cat("IMPORTANT: Verify chi-square, df, and npar against Mplus before using the conversion scientifically.\n")
