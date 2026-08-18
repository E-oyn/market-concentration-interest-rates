/*==============================================================================
 02_interest.do
 Adapted from the original "Zero Interest Do.do".

 Purpose: import the ECB long-term (10yr) interest rate series (Eurostat /
 ECB SDW, https://sdw.ecb.europa.eu/browse.do?node=9691124), collapse from
 monthly to yearly per country (turnover-independent, so no country is
 excluded here -- the merge stage in 04 restricts to the 11 countries used
 elsewhere), and build first-difference / log variables.

 INPUT (not included in this repo -- see data/README.md):
   data/raw/interest_rate_data.csv

 OUTPUT:
   data/interim/interest/interest_rate.dta
==============================================================================*/

do "00_setup.do"

cd "$root/data/interim/interest"
log using "02_interest", replace text

import delimited "$root/data/raw/interest_rate_data.csv", varnames(1)
save interest_data.dta, replace

rename country_n country_n1
encode country_n1, generate(country_n)

generate date = date(v1, "YM")
format date %tdNN/CCYY

keep interest country_n date
order date country_n interest
label var interest "Interest Rate"

gen year = year(date)
sort year
save interest_data.dta, replace
sort year country_n
order year country_n interest

* Turnover-weighted collapse to yearly, per country
foreach r of numlist 1(1)12 {
    use interest_data.dta, clear
    keep if country_n == `r'
    by year: asgen i_wm = interest, w(interest)
    collapse interest, by(year country_n)
    save interest_rate_`r'.dta, replace
}
use interest_rate_1, clear
forvalues r = 2/12 {
    append using interest_rate_`r'.dta
}

keep if year > 1997
drop if year > 2019
sort year country_n
order year country_n interest

tsset country_n year, yearly
gen d_interest = d.interest

save "$root/data/interim/interest/interest_rate.dta", replace

log close
