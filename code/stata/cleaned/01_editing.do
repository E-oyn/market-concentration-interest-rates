/*==============================================================================
 01_editing.do
 Adapted from the original "Zero Editing Do.do" (BACH "variable sample",
 code 0 -- the sample actually used in the thesis, per section 5.1).

 Purpose: import the raw BACH export, clean it, label it, convert
 percentage-of-turnover variables into euro amounts, build the company/
 sector/size panel ID, and split the pooled panel into per-country files
 used by 02..onwards.

 INPUT (not included in this repo -- see data/README.md):
   data/raw/bach_export.csv   <- rename your BACH export to this

 OUTPUT:
   data/interim/editing/aggregated_all_zero.dta
   data/interim/markup/<country>/aggregated_<country>_zero.dta   (11 files)
   data/interim/hhi/<country>/aggregated_<country>_zero.dta      (11 files)
==============================================================================*/

do "00_setup.do"

cd "$root/data/interim/editing"
log using "01_editing", replace text

* --- Import raw BACH export ---
import delimited "$root/data/raw/bach_export.csv", delimiter(";") varnames(1)
encode country, generate(country_n)

* Exclude the unresolved country (original "Hr" folder / country_n==7,
* labeled "Hungary" in the source do-files -- see 00_setup.do header note).
drop if country_n == 7

save "$root/data/interim/editing/sliding_zero.dta", replace

* --- Drop coverage columns not used downstream ---
drop coverage_firms coverage_turnover coverage_employees country sample

* Some sector/year/size cells have too few companies to have data.
egen missings = rowmiss(_all)
sort missings
drop if missings > 2
drop missings

* --- Labeling ---
label variable year Year
label var sector "Sector Code"
label var size "Size Indicator"
label var turnover "Sales (thousands)"
label var nb_firm "Number of Companies"
label var employees "Number of Employees"
label var total_assets "Total Assets (thousands)"
label var gross_value_added "Value Added (thousands)"
label var a12_wm "Tangible Fixed Assets"
label var a1_wm "Fixed Assets"
label var a2_wm "Inventories"
label var a_wm "Total Balance Sheet"
label var i1_wm "Net Turnover"
label var i41_wm "Operating Income"
label var i5_wm "Cost of Goods Sold"
label var i6_wm "External Supplies and Services"
label var i7_wm "Staff Cost"
label var i8_wm "Other Expenses"
label var i81_wm "Selling, General and Administrative Expenses"
label var it1_wm "Revenue"
label var it2_wm "Expenses"
label var it3_wm "Net profit or loss for the period"

* --- Company size categories ---
label define size 1 "1a" 2 "1b" 3 "1" 4 "2"
foreach v of varlist size* {
    encode `v', gen(_`v') label(size)
    drop `v'
    rename _`v' `v'
}
tab1 size*
tab1 size*, nolabel
label drop size

sort year sector size
gen id_c = sector + string(size, "%02.0f")
order id_c
rename id_c id
label var id "Company sector ID and Size"
sort year id
order year id turnover nb_firms
encode id, gen(company)
drop id
rename company id
order id
sort country_n
destring, replace dpcomma

* BACH gives total assets, value added and turnover as absolute euro values
* (thousands); item variables are given as % of turnover/total assets, so
* they are converted here by multiplying back through.
foreach r in i41_wm i42_wm i5_wm i6_wm i7_wm i8_wm i81_wm it2_wm it3_wm {
    replace `r' = `r' * turnover
}
replace a12_wm = a12_wm * total_assets
replace a2_wm  = a2_wm  * total_assets
replace a1_wm  = a1_wm  * total_assets

egen total_var_cost_wm = rowtotal(i6_wm i7_wm i8_wm)
label var total_var_cost_wm "Total Variable Cost"

sort id year
egen panelid = group(id country_n), label
save "$root/data/interim/editing/sliding_zero.dta", replace

* it3_wm (net profit) is sometimes negative and can't be logged directly:
* isolate negatives, take abs value, log, re-sign, then reattach.
keep if it3_wm < 0
replace it3_wm = it3_wm * (-1)
gen l_revenue = ln(it3_wm)
replace l_revenue = l_revenue * (-1)
save "$root/data/interim/editing/revenue_negatives_zero.dta", replace

use "$root/data/interim/editing/sliding_zero.dta", clear
drop if it3_wm < 0
gen l_revenue = ln(it3_wm)
append using "$root/data/interim/editing/revenue_negatives_zero.dta"

gen l_sales = ln(turnover)
gen l_total_var_cost = ln(total_var_cost_wm)
gen l_value_added = ln(gross_value_added)
gen l_fixed_cost = ln(a12_wm)
gen l_operating_inc = ln(i41_wm)
gen l_financial_inc = ln(i42_wm)
gen l_sgna = ln(i81_wm)
gen l_cogs = ln(i5_wm)
gen l_staff_cost = ln(i7_wm)
gen l_external_cost = ln(i6_wm)
gen l_other_expenses = ln(i81_wm)
gen l_total_income = ln(it1_wm)
gen l_expenses = ln(it2_wm)
gen l_ten_inventory = ln(a2_wm)
gen l_inventory = ln(a1_wm)
gen l_overhead = l_other_expenses / (l_operating_inc + l_financial_inc)
egen nmcount = rownonmiss(l_revenue), strok
drop if nmcount == 0

label var l_sales "Log Turnover"
label var l_total_var_cost "Log Variable Cost"
label var l_fixed_cost "Log Fixed Cost"
label var l_cogs "Cost of Goods Sold"
label var l_operating_inc "Operating Income"
label var l_financial_inc "Financial Income"
label var l_sgna "Log Selling, General and Administrative Expenses"
label var l_staff_cost "Labour Input cost"
label var l_external_cost "External Supplies and Services"
label var l_other_expenses "Other Expenses"
label var l_revenue "Revenue"
label var l_ten_inventory "Tangible Inventory"
label var l_inventory "Inventories"
label var l_overhead "Overhead Ratio"

compress
order year panelid
sort year panel id
encode sector, generate(sec)

save "$root/data/interim/editing/aggregated_all_zero.dta", replace

* --- Split into per-country files (11 countries, "Hr" slot excluded) ---
* country_n numbering follows Stata's alphabetical `encode` of the raw
* country string; 1=Aus 2=Be 3=Cz 4=De 5=Es 6=Fr 8=It 9=Lu 10=Pl 11=Pt 12=Sk
* (7 was the excluded/unresolved country, dropped above).
local codes  1 2 3 4 5 6 8 9 10 11 12
local names  aus be cz de es fr it lu pl pt sk
local i = 1
foreach code of local codes {
    local cname : word `i' of `names'
    use "$root/data/interim/editing/aggregated_all_zero.dta", clear
    keep if country_n == `code'
    save "$root/data/interim/markup/`cname'/aggregated_`cname'_zero.dta", replace
    save "$root/data/interim/hhi/`cname'/aggregated_`cname'_zero.dta", replace
    local ++i
}

log close
