# Market Concentration and Interest Rates — A Panel VAR Analysis

This repository contains the empirical work from my 2021 M.Sc. thesis on the relationship between long-term interest rates, productivity and market concentration. The analysis uses European BACH accounting data and Stata to construct productivity and competition measures and estimate panel VAR models across firm-size groups.

The repository keeps the original thesis code alongside a cleaned version of the workflow prepared later to make the structure, dependencies and execution order easier to follow. The original files are kept for reference and are not rewritten to look like newer code.

> Research code from a completed M.Sc. thesis (Economics and Institutions, Philipps-Universität Marburg, 2021), organized for public review. Not actively maintained as a production pipeline.

## Overview

**Research question:** does a decline in long-term interest rates *reduce* market concentration (traditional channel: cheaper credit → easier entry/competition) or *increase* it (the "strategic effect" — Liu, Mian & Sufi 2019 — cheap credit lets incumbents invest more aggressively and entrench)? A secondary test checks the "Superstar Firm" hypothesis (Autor et al. 2017): does higher total factor productivity itself drive concentration up for large firms?

**Answer, in one line:** across firm sizes, interest-rate and TFP shocks are associated with *decreases* in concentration — consistent with the traditional channel, not the strategic-effect or Superstar-Firm hypotheses.

**Data:** BACH firm-accounting data (11 EU countries, ~2000–2018) plus ECB long-term interest rates.
**Method:** TFP via Ackerberg-Caves-Frazer, HHI and markup as concentration measures, a 3-variable panel VAR per measure per firm-size cluster.

## Data

- **BACH** (Bank for the Accounts of Companies Harmonized) — sector/size-aggregated firm accounting data, published by the European Committee of Central Balance-Sheet Data Offices (ECCBSO), accessed via [BACH/ERICA](https://www.bach.banque-france.fr/#/login). Uses BACH's "variable sample" (code 0).
- **ECB long-term interest rates** — "Monthly Long-Term Interest Rates for Convergence Purposes" (10yr maturity), via the [ECB long-term interest rate statistics methodology page](https://data.ecb.europa.eu/methodology/long-term-interest-rate-statistics). These are current access links, not necessarily the exact 2021 URLs used at the time of the thesis.

Raw data is **not included** — see [`data/README.md`](data/README.md) for schema and access notes. This repo ships code and results, not the underlying firm-accounting microdata.

**Countries (11):** Austria, Belgium, Czechia, Germany, Spain, France, Italy, Luxembourg, Poland, Portugal, Slovakia. One entry from the original project (folder abbreviation "Hr") is excluded from the cleaned workflow — see [`data/README.md`](data/README.md) for why.

**Panel:** ~2000–2018, four firm-size clusters (Small / Medium / Large / Small-Medium combined), company × sector × year cells.

## Methodology

**1. Total factor productivity (TFP).** Estimated via the Ackerberg-Caves-Frazer (2007) control-function method, implemented with Stata's `acfest` (Manjón & Mañez 2016). A Cobb-Douglas production function is estimated in two stages: an intermediate-input proxy (tangible inventory) resolves the simultaneity between input choice and unobserved productivity, and a Markov process for productivity evolution separately identifies the labour coefficient via a GMM moment condition on lagged inputs.

**2. Markup.** Production-approach markup (Hall 1988; De Loecker & Warzynski 2012): the ratio of the output elasticity of the variable input to that input's revenue share, computed here as `markup = (revenue / total variable cost) × TFP`.

**3. Concentration (HHI).** Herfindahl-Hirschman Index — sum of squared market shares within a sector-year group, `HHI = Σ(share_i²)`, range 0 (perfect competition) to 10,000 (monopoly). Computed nationally per country, then pooled to a Pan-EU HHI by sector-year for the regression stage.

**4. Panel VAR.** A 3-variable panel VAR (Abrigo & Love 2016) is estimated separately for each concentration measure (HHI, markup) and each of the four firm-size clusters:

```
Z_its = Γ(L) Z_its + μ_is + ε_its      Z = {long-term interest rate, TFP, concentration measure}
```

Country-specific effects (`μ_is`) are removed by first-differencing. Shocks are identified via Cholesky decomposition, ordered **interest rate → TFP → concentration measure**. Results are read off as orthogonalized impulse-response functions (IRFs), cumulative IRFs, and forecast-error variance decomposition, over a 10-step horizon with 95% Monte Carlo confidence intervals (1,500 draws).

The thesis code also contains a market-share (`m_s`) specification alongside HHI and markup; its role in the final thesis results is less clear from the code alone, so it isn't presented here as one of the two main concentration measures.

Full derivation with equations: [`docs/METHODS.md`](docs/METHODS.md).

## Models used

| Stage | Model / method | Stata command | Reference |
|---|---|---|---|
| TFP estimation | Ackerberg-Caves-Frazer control-function production function | `acfest` | Manjón & Mañez (2016); Ackerberg et al. (2007) |
| Markup | Production-approach price/marginal-cost markup | (derived from `acfest` output) | De Loecker & Warzynski (2012) |
| Concentration | Herfindahl-Hirschman Index | `hhi`, `hhi5` | Yujun (2016) |
| Lag/moment selection | Moment and lag-order selection criteria | `pvarsoc` | Andrews & Lu (2000) |
| Estimation | Panel VAR via GMM | `pvar` | Abrigo & Love (2016), building on Holtz-Eakin, Newey & Rosen (1988) |
| Causality | Panel Granger causality (Wald) | `pvargranger` | Abrigo & Love (2016) |
| Stability | Eigenvalue stability of the VAR | `pvarstable` | Lütkepohl (2005) |
| Dynamics | Orthogonalized IRFs, cumulative IRFs | `pvarirf` | Abrigo & Love (2016) |
| Forecast-error variance decomposition | FEVD | `pvarfevd` | Abrigo & Love (2016) |

## Repository structure

```text
README.md
LICENSE
.gitignore

code/
    stata/
        original/      original 2021 thesis do-files, unmodified
            markup/     original country-level Markup do-files
            hhi/        original country-level HHI do-files
        cleaned/        later restructured version of the same workflow

data/
    README.md           data schema, access instructions, country-code note

outputs/
    figures/             HHI impulse-response and stability plots (original pipeline output)
    tables/              HHI forecast-error variance decomposition tables

docs/
    METHODS.md           full methodology writeup
```

## Original and cleaned Stata code

`code/stata/original/` contains the original thesis do-files as they were used during the project, including the original local file paths and repeated country/model blocks. This is the most direct evidence of the actual 2021 work: nothing has been rewritten, renamed, or cleaned up. It includes the data-preparation scripts (`Zero Editing Do.do`, `Zero Interest Do.do`, `Merge Do Zero.do`), the per-country Markup and HHI do-files, the main one-lag panel VAR (`VAR I-R.do`), the two-lag robustness specification (`VAR I-R Second Lag.do`), and the forecast-error variance decomposition script (`fevd.do`).

`code/stata/cleaned/` contains a later restructuring of the same workflow, split into a numbered sequence (`00_setup.do` through `06_var_lag2_robustness.do`, plus a shared `_var_core.do` and a `run_all.do` entry point) intended to make the sequence and file dependencies easier to follow. It should not be treated as the historical version of the code — see `code/stata/original/` for that. The cleaned pipeline currently does not include a cleaned equivalent of `fevd.do`; the original FEVD script is the authoritative version for now.

## Running the pipeline

The cleaned pipeline (`code/stata/cleaned/run_all.do`) expects raw BACH and ECB inputs described in [`data/README.md`](data/README.md) to be placed locally — they are not distributed in this repository. Without that data, `outputs/tables/` and `outputs/figures/` already contain a subset of the actual results the pipeline produces, so the output of the code can be inspected without re-running it.

## References

Abrigo, M. R. M., & Love, I. (2016). Estimation of panel vector autoregression in Stata. *The Stata Journal*, 16(3), 778–804.
Ackerberg, D., Caves, K., & Frazer, G. (2015 [2007 working paper]). Identification properties of recent production function estimators. *Econometrica*, 83(6), 2411–2451.
Andrews, D. W. K., & Lu, B. (2001). Consistent model and moment selection procedures for GMM estimation with application to dynamic panel data models. *Journal of Econometrics*, 101(1), 123–164.
Autor, D., Dorn, D., Katz, L. F., Patterson, C., & Van Reenen, J. (2020). The fall of the labor share and the rise of superstar firms. *The Quarterly Journal of Economics*, 135(2), 645–709.
De Loecker, J., & Warzynski, F. (2012). Markups and firm-level export status. *American Economic Review*, 102(6), 2437–2471.
Liu, E., Mian, A., & Sufi, A. (2022). Low interest rates, market power, and productivity growth. *Econometrica*, 90(1), 193–221.
Manjón, M., & Mañez, J. A. (2016). Production function estimation in Stata using the Ackerberg-Caves-Frazer method. *The Stata Journal*, 16(4), 900–916.

Full bibliography with page-level citations: thesis text (not included in this repository — see `docs/METHODS.md` for the condensed methodological derivation).
