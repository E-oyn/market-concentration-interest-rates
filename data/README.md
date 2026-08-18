# Data

Raw data is **not included** in this repository. Two sources are used, both obtainable directly from the original providers. Neither source's redistribution terms have been confirmed for this repository, and BACH-derived intermediate/regression-ready datasets are likewise excluded — nothing beyond a schema description and the already-published result files in `outputs/` is checked in here.

## 1. BACH (firm accounting data)

- **Provider**: European Committee of Central Balance-Sheet Data Offices (ECCBSO), via the BACH/ERICA data portal — [https://www.bach.banque-france.fr/#/login](https://www.bach.banque-france.fr/#/login)
- **What it is**: sector/size-aggregated non-financial-corporation accounting data for European countries, "variable sample" (sample code 0).
- **Access**: BACH data is available to researchers; check current access terms directly with ECCBSO before requesting or using it for your own replication. This is the current access link, not necessarily the exact one used in 2021.
- **Expected filename in the cleaned pipeline**: a semicolon-delimited export with one header row, referenced in `code/stata/cleaned/01_editing.do`.

### Schema (illustrative — column name, description, example unit/value; not real data)

| Column | Description | Example |
|---|---|---|
| `country` | Country name/code as exported by BACH | `Austria` |
| `year` | Calendar year | `2015` |
| `sector` | BACH sector code (1–18, 18 = Pan-EU aggregate) | `8` |
| `size` | Size indicator (1a/1b/1/2, mapped to Small/Medium/Large/SME) | `1a` |
| `turnover` | Sales, € thousands | `45231.0` |
| `nb_firm` | Number of companies in the cell | `312` |
| `employees` | Number of employees | `4821` |
| `total_assets` | Total assets, € thousands | `128904.0` |
| `gross_value_added` | Value added, € thousands | `19203.0` |
| `a12_wm` | Tangible fixed assets, % of total assets | `0.41` |
| `i5_wm` | Cost of goods sold, % of turnover | `0.52` |
| `i7_wm` | Staff cost, % of turnover | `0.18` |
| `it3_wm` | Net profit/loss for the period, % of turnover | `0.06` |

(Full column list and BACH's own definitions: see the BACH Userguide Summary.)

## 2. ECB long-term interest rates

- **Provider**: European Central Bank — [long-term interest rate statistics methodology](https://data.ecb.europa.eu/methodology/long-term-interest-rate-statistics)
- **What it is**: monthly long-term (10yr) interest rates for convergence purposes, by country, freely downloadable.
- **Expected filename**: referenced as `interest data.csv` in `code/stata/original/Zero Interest Do.do` and `code/stata/cleaned/02_interest.do`.

### Schema

| Column | Description | Example |
|---|---|---|
| (unnamed) | Year-month | `2015Jun` |
| `Interest` | Long-term interest rate, % | `0.83` |
| `country_n` | Country code/abbreviation as used in the original project | `De` |

## Excluded country ("Hr")

Country-code note: The original project contains an ambiguous country entry in which the folder abbreviation and the Stata country label do not agree. The original thesis code is preserved unchanged. The cleaned workflow excludes this entry rather than assigning it to a country without sufficient evidence. This exclusion was introduced during the later cleanup and was not part of the original 2021 code.

Concretely: the original project's folder and file naming used the abbreviation "Hr" for one of the twelve countries in the source material, which normally reads as Croatia's ISO 3166 code. The original `Merge Do Zero.do` script's own `label define country_n ... 7 "Hungary" ...` line, however, labels that same numeric slot "Hungary." These two pieces of the same original codebase disagree with each other, and it has not been possible to resolve which country's data actually populates that slot without access to the raw BACH export's own country labels — so this repository does not guess. `code/stata/original/markup/Zero Markup Hr Do.do` and `code/stata/original/hhi/HHI Zero Hr Do.do` are preserved as-is under `code/stata/original/`.

## Reproducing without raw data access

If you don't have BACH access, `outputs/tables/` and `outputs/figures/` contain a subset of the actual results already produced from this pipeline (HHI impulse responses, stability diagnostics, and forecast-error variance decomposition), so you can inspect what the code produces without re-running it. See `outputs/tables/README.md` for which files are independently verified against the thesis text versus copied as-is from the original pipeline output.
