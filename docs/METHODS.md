# Methods

Full derivation, condensed from the thesis's empirical chapters. Equation structure below follows the thesis; see `code/stata/cleaned/` for the exact implementation and `code/stata/original/` for the historical version.

## 1. Data

BACH aggregates non-financial-corporation accounting statements by country, sector, company size, and year (ECCBSO). The thesis uses the **variable sample** (BACH sample code 0 — all enterprises present in year *n*), rather than either of BACH's "sliding sample" variants, for a larger, better-balanced panel. Variables: turnover, number of firms, total assets, tangible fixed assets, cost of goods sold, external supplies/services, staff costs, and other expenses — the latter group reported as % of turnover/total assets in the raw export and converted to euro levels in `01_editing.do`.

Company-size classes (BACH's own coding):

| Code | Class | Turnover |
|---|---|---|
| 1 | Small | < €10m |
| 2 | Medium | €10m ≤ turnover < €50m |
| 3 | Large | > €50m |
| 4 | Small-Medium (combined) | < €50m |

## 2. Markup and TFP

Markup is recovered via the production approach (Hall 1988; De Loecker & Warzynski 2012): firms minimize cost subject to a production technology `Q_it(V_it, K_it, Ω_it)`. The first-order condition with respect to the variable input yields output elasticity `θ^v_it`, and the markup follows as

```
μ_it = θ^v_it * (P^Q_it * Q_it) / (P^v_it * V_it)
```

i.e. markup is the output elasticity of the variable input divided by that input's revenue share.

**TFP (Ω_it)** is estimated via the Ackerberg-Caves-Frazer (2007) control-function method (Stata `acfest`, per Manjón & Mañez 2016): a Cobb-Douglas production function `y_it = β0 + β_k k_it + β_v v_it + ω_it + η_it` is estimated in two stages, using an intermediate-input proxy (tangible inventory) to solve the simultaneity problem between input choice and unobserved productivity, then a Markov process for the evolution of productivity between periods to separately identify the labour coefficient via a GMM moment condition on lagged inputs.

In code (`03_markup_hhi.do`): `acfest pi, state(cap) proxy(y) free(labour) i(size) t(year) nbs(19) overid`, where `pi`=log revenue, `cap`=log fixed cost (state variable), `y`=log tangible inventory (proxy), `labour`=log staff cost (free/variable input). Markup is then `(pi/var) * TFP / 100`, where `var` = log total variable cost.

## 3. HHI (Herfindahl-Hirschman Index)

Market share for firm/cell *s* at time *t*:

```
s_it = Sales_it / sum(Sales_it)      [summed over all firms in the same sector-year]
```

HHI is the sum of squared market shares within a sector-year group:

```
HHI_t = sum(s_it^2)
```

Range: ~0 (perfect competition) to 10,000 (monopoly). The pipeline computes both a *national* HHI (per-country, per sector-year, in `03_markup_hhi.do`) and a *Pan-EU* HHI (pooled across the included countries by sector-year, in `04_merge.do`, on a 0–1 rescaled basis). The **Pan-EU HHI is what enters the VAR.**

## 4. Panel VAR

Abrigo & Love (2016) `pvar`: a 3-variable system per concentration measure, estimated separately for each of the four firm-size clusters:

```
Z_its = Γ(L) Z_its + μ_is + ε_its
```

where `Z_its = {long-term interest rate, TFP, concentration measure}` (HHI or markup — used one at a time, not jointly), `Γ(L)` is the lag-operator coefficient matrix, `μ_is` absorbs country-specific effects (removed via first-differencing), and `ε_its` is the error term. Shocks are identified via Cholesky decomposition, ordered **interest rate → TFP → concentration measure**.

- **Lag selection**: `pvarsoc`, reporting MBIC/MAIC/MQIC over 1–4 lags with 1–4 lags as GMM instruments (Andrews & Lu 2000).
- **Main specification**: lag 1 (`05_var_lag1.do`, historically `VAR I-R.do`).
- **Robustness check**: lag 2 (`06_var_lag2_robustness.do`, historically `VAR I-R Second Lag.do`) — the thesis's own caveat is that this produces largely insignificant results, which is itself informative about how sensitive the model is to lag choice.
- **Diagnostics**: `pvargranger` (Granger causality), `pvarstable` (stability/invertibility of the VMA representation).
- **Results**: `pvarirf` — orthogonalized impulse-response functions and cumulative IRFs, 10-step horizon, 95% confidence intervals via Monte Carlo simulation (1,500 draws); `pvarfevd` (historically `fevd.do`) for forecast-error variance decomposition on the same estimated model.

Sample restriction: sector code 18 (the Pan-EU aggregate sector total) only, for the pooled VAR stage — country/sector-level detail is retained through the merge stage but the headline VAR results are estimated on the aggregate.

## References

Key methodological citations: Abrigo & Love (2016) for `pvar`; Manjón & Mañez (2016) for `acfest`; Yujun (2016) for `hhi`/`hhi5`; De Loecker & Warzynski (2012) for the markup formula; Ackerberg, Caves & Frazer (2015) for the TFP identification strategy; Andrews & Lu (2001) for GMM moment/lag selection. Full bibliography with page-level citations is in the original thesis text, which is not included in this repository.
