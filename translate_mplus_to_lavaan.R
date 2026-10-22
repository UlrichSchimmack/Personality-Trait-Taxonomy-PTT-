# ================================================================
# FacetMAP | Translate BFF_ALL_FINAL_annotated.inp (Mplus) to lavaan
# ================================================================
# Writes the three companion files used by run_facetmap_lavaan.R:
#   facetmap_reference_model.lavaan  (lavaan model syntax)
#   facetmap_columns.txt             (470 NAMES, raw-file order)
#   facetmap_used_columns.txt        (210 USEVARIABLES, Mplus order)
# Run: Rscript translate_mplus_to_lavaan.R [path/to/input.inp]
# Without an argument, a local BFF_ALL_FINAL_annotated.inp is used,
# otherwise the file is read from the GitHub repository.
#
# Mplus rules implemented:
# - Variable names are case-insensitive (everything is upper-cased).
# - The first indicator of each factor (first BY statement) is fixed at 1
#   unless it carries * (free) or @ (fixed) itself.
# - x*v = free with start value v; x* = free; x@v = fixed at v.
# - a-b ranges are expanded in USEVARIABLES order; a modifier or label
#   after a range applies to every variable in the range.
# - (label) gives equality constraints across all parameters sharing it.
# - MODEL = NOCOV: no latent covariances except explicit WITH statements.
# - Duplicate WITH statements (A with B / B with A) define one parameter.

github_raw <- "https://raw.githubusercontent.com/UlrichSchimmack/Personality-Trait-Taxonomy-PTT-/HEAD/"
args <- commandArgs(trailingOnly = TRUE)
inp_file <- if (length(args) > 0) args[1] else if (file.exists("BFF_ALL_FINAL_annotated.inp")) {
  "BFF_ALL_FINAL_annotated.inp"
} else paste0(github_raw, "BFF_ALL_FINAL_annotated.inp")

lines <- toupper(readLines(inp_file, warn = FALSE))
lines <- sub("!.*$", "", lines)                     # strip comments
txt <- paste(lines, collapse = " ")

section <- function(start, end) {
  s <- regexpr(start, txt); e <- regexpr(end, substring(txt, s + attr(s, "match.length")))
  substring(txt, s + attr(s, "match.length"), s + attr(s, "match.length") + e - 2)
}
words <- function(x) { w <- strsplit(trimws(x), "\\s+")[[1]]; w[nzchar(w)] }

all_names  <- words(section("NAMES ARE", ";"))
used_names <- words(section("USEVARIABLES", ";"))
stopifnot(length(all_names) == 470L, length(used_names) == 210L,
          all(used_names %in% all_names))

model_txt <- section("MODEL:", "OUTPUT:")
stmts <- trimws(strsplit(model_txt, ";")[[1]])
stmts <- stmts[nzchar(stmts)]

# Normalize spacing: "a - b" -> "a-b", "x *.2" -> "x*.2", "x @1" -> "x@1"
norm <- function(s) {
  s <- gsub("\\s+", " ", s)
  s <- gsub("([A-Z0-9_]) - ([A-Z])", "\\1-\\2", s)
  s <- gsub(" ([*@])", "\\1", s)
  s
}

expand <- function(a, b) {
  if (is.na(b) || !nzchar(b)) return(a)
  i <- match(a, used_names); j <- match(b, used_names)
  if (is.na(i) || is.na(j) || j < i) stop("Cannot expand range ", a, "-", b)
  used_names[i:j]
}

# Parameter table: one row per loading / covariance
par <- data.frame(lhs = character(), op = character(), rhs = character(),
                  type = character(), value = numeric(), label = character(),
                  stringsAsFactors = FALSE)
seen_factor <- character()
tok_re <- "^([A-Z][A-Z0-9_]*)(-([A-Z][A-Z0-9_]*))?(([*@])(-?[0-9]*\\.?[0-9]*))?$"

for (s in stmts) {
  s <- norm(s)
  m <- regmatches(s, regexec("^([A-Z][A-Z0-9_]*) (BY|WITH) (.*)$", s))[[1]]
  if (!length(m)) stop("Unparsed statement: ", s)
  lhs <- m[2]; op <- if (m[3] == "BY") "=~" else "~~"
  toks <- words(m[4])
  label <- NA_character_
  lab <- grep("^\\(.*\\)$", toks)
  if (length(lab)) { label <- gsub("[()]", "", toks[lab]); toks <- toks[-lab] }
  for (tk in toks) {
    g <- regmatches(tk, regexec(tok_re, tk))[[1]]
    if (!length(g)) stop("Unparsed token '", tk, "' in: ", s)
    vars <- expand(g[2], g[4])
    mod <- g[6]; val <- suppressWarnings(as.numeric(g[7]))
    for (k in seq_along(vars)) {
      type <- if (mod == "@") "fixed" else if (mod == "*") "free" else "default"
      v <- val
      if (op == "=~" && !(lhs %in% seen_factor)) {
        seen_factor <- c(seen_factor, lhs)
        if (type == "default") { type <- "fixed"; v <- 1 }
      }
      if (type == "default") type <- "free"
      par[nrow(par) + 1, ] <- list(lhs, op, vars[k], type, v, label)
    }
  }
}

# Covariances: drop duplicate unordered pairs (keep first occurrence)
key <- ifelse(par$op == "~~", paste(pmin(par$lhs, par$rhs), pmax(par$lhs, par$rhs)),
              paste(par$lhs, par$rhs))
key <- paste(par$op, key)
if (anyDuplicated(key)) {
  message("Dropping duplicate parameters: ",
          paste(unique(key[duplicated(key)]), collapse = "; "))
  par <- par[!duplicated(key), ]
}

# Write lavaan syntax
term <- function(r) {
  pre <- if (r$type == "fixed") paste0(r$value, "*")
         else if (!is.na(r$label)) paste0(if (!is.na(r$value)) paste0("start(", r$value, ")*"), r$label, "*")
         else if (!is.na(r$value)) paste0("start(", r$value, ")*")
         else ""
  paste0(pre, r$rhs)
}
out <- c("# FacetMAP reference model: lavaan translation of BFF_ALL_FINAL_annotated.inp",
         "# Generated by translate_mplus_to_lavaan.R - edit the Mplus input and regenerate.",
         "# Fit with auto.fix.first = FALSE, auto.cov.lv.x = FALSE, auto.cov.y = FALSE.", "")
for (op in c("=~", "~~")) {
  sub_par <- par[par$op == op, ]
  for (l in unique(sub_par$lhs)) {
    rows <- sub_par[sub_par$lhs == l, ]
    terms <- vapply(seq_len(nrow(rows)), function(i) term(rows[i, ]), "")
    out <- c(out, paste0(l, " ", op, " ",
                         paste(strwrap(paste(terms, collapse = " + "), width = 100,
                                       exdent = nchar(l) + 4), collapse = "\n")))
  }
  out <- c(out, "")
}
writeLines(out, "facetmap_reference_model.lavaan")
writeLines(all_names, "facetmap_columns.txt")
writeLines(used_names, "facetmap_used_columns.txt")

cat("Loadings:", sum(par$op == "=~"), " (fixed:", sum(par$op == "=~" & par$type == "fixed"),
    ") | covariances:", sum(par$op == "~~"),
    " | equality labels:", length(unique(na.omit(par$label))), "\n")
cat("Wrote facetmap_reference_model.lavaan, facetmap_columns.txt, facetmap_used_columns.txt\n")
