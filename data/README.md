# Data

Raw data is **not included** in this repository. Two sources are used, both obtainable directly from the original providers; neither's redistribution terms have been confirmed for this repo, so nothing beyond a schema description is checked in here.

## 1. BACH (firm accounting data)

- **Provider**: European Committee of Central Balance-Sheet Data Offices (ECCBSO) — [https://www.bachesd.eu](https://www.bachesd.eu)
- **What it is**: sector/size-aggregated non-financial-corporation accounting data for European countries, "variable sample" (sample code 0).
- **Access**: BACH data is available to researchers; check current access terms directly with ECCBSO before requesting/using it for your own replication.
- **Expected filename in this pipeline**: `data/raw/bach_export.csv`, semicolon-delimited, one header row.

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

(Full column list and BACH's own definitions: see the BACH Userguide Summary, cited in the thesis.)

## 2. ECB long-term interest rates

- **Provider**: ECB Statistical Data Warehouse — [https://sdw.ecb.europa.eu/browse.do?node=9691124](https://sdw.ecb.europa.eu/browse.do?node=9691124)
- **What it is**: monthly long-term (10yr) interest rates for convergence purposes, by country, freely downloadable.
- **Expected filename**: `data/raw/interest_rate_data.csv`.

### Schema

| Column | Description | Example |
|---|---|---|
| `v1` | Year-month | `2015-06` |
| `country_n` | Country code/name as exported by SDW | `DE` |
| `interest` | Long-term interest rate, % | `0.83` |

## Excluded country ("Hr")

The original project's folder/file naming used the abbreviation **"Hr"** for one of the twelve countries in the source material — which normally reads as Croatia's ISO 3166 code. However, the original `Merge Do Zero.do` script's own `label define country_n ... 7 "Hungary" ...` line labels that same numeric slot **Hungary**. These two pieces of the same original codebase disagree with each other, and it was not possible to resolve which country's data actually populates that slot without access to the raw BACH export's own country labels.

Rather than guess, this cleaned repository **excludes that country entirely** (`01_editing.do` drops `country_n == 7` right after country encoding, before any of it can propagate downstream). If you have the original raw exports and can confirm which country it actually is:

1. Remove the `drop if country_n == 7` line in `01_editing.do`.
2. Add the correct country name to the loop in the same file and to `04_merge.do`'s `foreach y in ...` list.
3. Fix the `label define country_n` line in `04_merge.do` accordingly.
4. Re-run `run_all.do`.

## Reproducing without raw data access

If you don't have BACH access, `outputs/tables/` and `outputs/figures/` contain the actual results already produced from this pipeline, so you can inspect what the code produces without re-running it.
