# Market Concentration and Interest Rates — A Panel VAR Analysis

Stata pipeline and results from a Master's thesis (M.Sc. Economics and Institutions, Philipps-Universität Marburg, 2021) testing whether declining EU long-term interest rates have affected firm-level market concentration, using panel vector autoregression on BACH firm-accounting data across 11 European countries.

> Research code from a completed academic thesis, cleaned up for public reproducibility (fixed paths, deduplicated per-country scripts, documented dependencies). Not actively maintained as a production pipeline.

## Overview

**Research question:** does a decline in long-term interest rates *reduce* market concentration (traditional channel: cheaper credit → easier entry/competition) or *increase* it (the "strategic effect" — Liu, Mian & Sufi 2019 — cheap credit lets incumbents invest more aggressively and entrench)? A secondary test checks the "Superstar Firm" hypothesis (Autor et al. 2017): does higher total factor productivity itself drive concentration up for large firms?

**Answer, in one line:** across firm sizes, interest-rate and TFP shocks are associated with *decreases* in concentration — consistent with the traditional channel, not the strategic-effect or Superstar-Firm hypotheses.

**Data:** BACH firm-accounting data (11 EU countries, ~2000–2018) + ECB long-term interest rates.
**Method:** TFP via Ackerberg-Caves-Frazer, HHI + markup as concentration measures, 3-variable panel VAR per measure per firm-size cluster.

## Data

- **BACH** (Bank for the Accounts of Companies Harmonized) — sector/size-aggregated firm accounting data, published by the European Committee of Central Balance-Sheet Data Offices (ECCBSO). Uses BACH's "variable sample" (code 0).
- **ECB long-term interest rates** — Eurostat/ECB "Monthly Long-Term Interest Rates for Convergence Purposes" (10yr maturity), [ECB Statistical Data Warehouse](https://sdw.ecb.europa.eu/browse.do?node=9691124).

Raw data is **not included** — see [`data/README.md`](data/README.md) for schema and access instructions. This repo ships code and results, not the underlying firm-accounting microdata.

**Countries (11):** Austria, Belgium, Czechia, Germany, Spain, France, Italy, Luxembourg, Poland, Portugal, Slovakia. One country from the original project ("Hr") is excluded — see `data/README.md` for why.

**Panel:** ~2000–2018, four firm-size clusters (Small / Medium / Large / Small-Medium combined), company × sector × year cells.

## Methodology

**1. Total factor productivity (TFP).** Estimated via the Ackerberg-Caves-Frazer (2007) control-function method, implemented with Stata's `acfest` (Manjón & Mañez 2016). A Cobb-Douglas production function is estimated in two stages: an intermediate-input proxy (tangible inventory) resolves the simultaneity between input choice and unobserved productivity, and a Markov process for productivity evolution separately identifies the labour coefficient via a GMM moment condition on lagged inputs.

**2. Markup.** Production-approach markup (Hall 1988; De Loecker & Warzynski 2012): the ratio of the output elasticity of the variable input to that input's revenue share, computed here as `markup = (revenue / total variable cost) × TFP`.

**3. Concentration (HHI).** Herfindahl-Hirschman Index — sum of squared market shares within a sector-year group, `HHI = Σ(share_i²)`, range 0 (perfect competition) to 10,000 (monopoly). Computed nationally per country, then pooled to a **Pan-EU HHI** by sector-year (rescaled to 0–1) for the regression stage.

**4. Panel VAR.** A 3-variable panel VAR (Abrigo & Love 2016) is estimated separately for each concentration measure {HHI, market share, markup} × each of the four firm-size clusters:

```
Z_its = Γ(L) Z_its + μ_is + ε_its         Z = {long-term interest rate, TFP, concentration measure}
```

Country-specific effects (`μ_is`) are removed by first-differencing. Shocks are identified via Cholesky decomposition, ordered **interest rate → TFP → concentration measure**. Results are read off as orthogonalized impulse-response functions (IRFs), cumulative IRFs, and forecast-error variance decomposition, over a 10-year horizon with 95% Monte Carlo confidence intervals (1,500 draws).

Full derivation with equations: [`docs/METHODS.md`](docs/METHODS.md).

## Models used

| Stage | Model / method | Stata command | Reference |
|---|---|---|---|
| TFP estimation | Ackerberg-Caves-Frazer control-function production function | `acfest` | Manjón & Mañez (2016); Ackerberg et al. (2007) |
| Markup | Production-approach price/marginal-cost markup | (derived from `acfest` output) | De Loecker & Warzynski (2012) |
| Concentration | Herfindahl-Hirschman Index | `hhi`, `hhi5` | Yujun (2016) |
| Lag/moment selection | Moment and model selection criteria (MBIC/MAIC/MQIC) | `pvarsoc` | Andrews & Lu (2000) |
| Main model | Panel Vector Autoregression, first-differenced GMM, Cholesky-identified | `pvar` | Abrigo & Love (2016) |
| Diagnostics | Granger causality; VAR stability (eigenvalue/companion matrix) | `pvargranger`, `pvarstable` | — |
| Results | Orthogonalized IRF, cumulative IRF, forecast-error variance decomposition | `pvarirf` | — |

**Estimated 6 times** (3 concentration measures × main lag-1 spec + lag-2 robustness spec) **× 4 firm-size clusters** = 48 panel VAR models total across the two run scripts.

## Repository structure

```
original_stata/
  00_setup.do                  <- edit this one line to point at your local data folder
  01_editing.do                <- import & clean raw BACH export, split by country
  02_interest.do               <- import & prep ECB interest-rate series
  03_markup_hhi.do             <- TFP, markup, HHI per country (loop; was 22 duplicate files)
  04_merge.do                  <- pool countries, compute Pan-EU HHI, merge interest rates
  05_var_lag1.do               <- main panel VAR (lag 1)
  06_var_lag2_robustness.do    <- lag-2 robustness check (see thesis ch. 9)
  _var_core.do                 <- shared VAR estimation logic called by 05/06
  run_all.do                   <- runs the full pipeline end to end
docs/
  METHODS.md                   <- full methodology writeup with equations
data/
  README.md                    <- data schema, access instructions, excluded-country note
outputs/
  tables/                      <- variance decomposition tables, lag-selection (MMSC) tables
  figures/                     <- IRF / cumulative IRF / stability graphs
thesis/
  Oyan_2021_thesis.pdf         <- personal contact info & signature page redacted, see thesis/README.md
LICENSE
```

## How to run

1. Install Stata and the required community packages:
   ```stata
   ssc install acfest, replace
   ssc install hhi, replace
   ssc install hhi5, replace
   ssc install pvar, replace
   ssc install missings, replace
   ```
2. Obtain BACH and ECB interest-rate data yourself (see `data/README.md`) and place them as `data/raw/bach_export.csv` and `data/raw/interest_rate_data.csv`.
3. Open `original_stata/00_setup.do` and confirm the `global root` line points at your clone of this repo.
4. Run `original_stata/run_all.do`, or step through `01` → `06` individually.

## Results

Full set of tables and figures: [`outputs/tables/`](outputs/tables/) and [`outputs/figures/`](outputs/figures/).

**Headline pattern (Figures 7–12 of the thesis):** interest-rate and TFP shocks are associated with *decreases* in HHI and markup across firm sizes, strongest and most persistent for Small and Large enterprises; Medium enterprises behave differently (more of their markup variance is explained by interest rates specifically). No evidence for the Superstar-Firm hypothesis — TFP shocks do not raise concentration for large firms.

**Example — forecast-error variance decomposition of HHI** (share of 10-year-ahead forecast error explained by each variable; Table 2a of the thesis):

| Horizon (yrs) | Small: HHI (own) | Small: Interest | Small: TFP | Medium: HHI (own) | Medium: Interest | Medium: TFP |
|---|---|---|---|---|---|---|
| 1 | 0.99 | 0.00 | 0.01 | 0.93 | 0.05 | 0.02 |
| 2 | 0.82 | 0.16 | 0.03 | 0.82 | 0.04 | 0.15 |
| 5 | 0.59 | 0.31 | 0.10 | 0.67 | 0.05 | 0.28 |
| 10 | 0.55 | 0.33 | 0.12 | 0.63 | 0.06 | 0.31 |

Interpretation: for Small enterprises, interest-rate innovations explain a growing share of HHI variance (16% at year 2 → 33% at year 10), while for Medium enterprises TFP is the larger secondary driver (31% at year 10).

**Robustness:** the lag-2 specification (`06_var_lag2_robustness.do`) produces mostly insignificant results — the thesis's own documented limitation, included here rather than hidden.

## Known limitations

- Pooling 11 heterogeneous countries in one panel VAR creates a homogeneity problem, addressed only by over-parameterization.
- Results are sensitive to lag selection (lag-1 vs. lag-2 above).
- BACH is sector/size-aggregated data, not firm-level microdata — individual firm responses aren't visible.
- One country ("Hr" in the original files) is excluded pending resolution of a label inconsistency — see `data/README.md`.
- A declining long-term rate doesn't necessarily mean credit was actually abundant; credit rationing can coexist with low market rates.

## License

Code and documentation in this repository (`original_stata/`, `docs/`, this README, `data/README.md`) are released under the [MIT License](LICENSE).

The thesis PDF (`thesis/`) is an academic work — all rights remain with the author. It is included here in a redacted form (personal contact details and the signed declaration-of-authorship page removed; see `thesis/README.md`). BACH and ECB data are not redistributed in this repository; see `data/README.md` for access instructions and provider terms.

## Citation

Oyan, Ege. *The Market Concentration and Interest Rates — A Vector Autoregression Analysis.* Master's thesis, Philipps-Universität Marburg, 2021. Supervisor: Prof. Dr. Bernd Hayo.
