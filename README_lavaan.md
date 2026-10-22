# FacetMAP reference model in lavaan (R)

This folder contains a translation of the original **BFF_ALL_FINAL.inp** model to the **free, open-source** R package [lavaan](https://lavaan.ugent.be/). It allows researchers to examine and modify competing structural theories without purchasing Mplus.

## Files

- `facetmap_reference_model.lavaan` — SEM model specification in lavaan syntax.
- `run_facetmap_lavaan.R` — imports data, fits the SEM, prints fit statistics, and exports loadings, covariance parameters and modification indices.
- `facetmap_columns.txt` — original 470 raw-file variables, in order (including 8 DQ variables and all six items for 77 pools).
- `facetmap_used_columns.txt` — 210 analyzed item variables, in the original Mplus USEVARIABLES order.
- `BFF_ALL_FINAL.inp` — original Mplus model; retain alongside the translation for auditability.

**Raw data are not included** here. The data owner must approve public distribution before uploading respondent-level data. The R runner accepts the original whitespace-delimited `.dat` or a `.csv` with exact item column names.

## Run

1. Install [R](https://cran.r-project.org/) and run `install.packages("lavaan")` once.
2. Download all four companion files into one folder, along with the authorized raw data.
3. In R, set the working directory to that folder, and run:

```r
source("run_facetmap_lavaan.R")
```

Alternatively, from the terminal:

```bash
Rscript run_facetmap_lavaan.R "1 Final Raw data NO RK items FOR MPLUS 01.03.18.dat"
```

To use a named CSV, pass its path instead:

```bash
Rscript run_facetmap_lavaan.R data.csv
```

## Mplus-to-lavaan equivalence assumptions

| Source specification | Translation |
|---|---|
| `BY` (including secondary loadings) | `=~` |
| `WITH` | `~~` |
| `@1`, `@-1`, `@0` | `1*`, `-1*`, `0*` fixed parameter |
| `*0.2`, `*-0.2` | `start(0.2)*`, `start(-0.2)*` free parameter with initial value |
| `(H_F34)` on range | Same lavaan equality-constraint label on expanded range |
| `MODEL = NOCOV` | Disable lavaan automatic latent/exogenous and endogenous covariances |
| Mplus ML, continuous items, 210 estimated intercepts | lavaan ML with `meanstructure=TRUE`, continuous observed variables |

The translated model contains **210 observed item variables, 70 latent facets, 5 global factors, and 2 method factors**. All specified secondary loadings, local facet residual covariances, and item-level HALO/RSET loadings are retained. Mplus abbreviates latent variable names to eight characters in output; lavaan retains the full names.

### Reference results (original Mplus output)

| Statistic | Value |
|---|---:|
| N | 1,087 |
| Free parameters | 1,014 |
| Chi-square | 36,743.687 |
| df | 21,351 |
| CFI | .899 |
| TLI | .896 |
| RMSEA | .026 |
| SRMR | .046 |

**Critical validation status:** This is a *syntax-level translation*. The raw `.dat` file and an R installation were not available in the translation environment, so the translated lavaan model **has not been fitted or numerically compared** with the Mplus result. The script prints side-by-side values and the difference in the number of free parameters. Contributors should reconcile discrepancies before making substantive comparisons. In particular, numerical differences can arise from factor identification defaults, covariance defaults, how fixed means are handled, or differences in missing-data treatment and optimization.

**Model development:** The existing reference model was extensively refined against the original sample, so independent replication is needed to adjudicate rival structural theories.

**Intercepts:** The Mplus output includes estimated intercepts for all 210 items. The R runner uses `meanstructure=TRUE` to reproduce these; covariance-only estimation would produce a different free-parameter count.
