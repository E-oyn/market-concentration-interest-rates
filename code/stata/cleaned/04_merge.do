/*==============================================================================
 04_merge.do
 Adapted from the original "Merge Do Zero.do".

 Purpose: append the 11 per-country markup/HHI files into one pooled panel,
 recompute a Pan-EU (rather than national) HHI on pooled market share by
 (sector x year), merge in the interest-rate series, and save the final
 regression-ready dataset used by the VAR stage (05/06).

 INPUT:
   data/interim/merge/<country>_zero_markup_hhi.dta   (11 files, from 03)
   data/interim/interest/interest_rate.dta             (from 02)
 OUTPUT:
   data/final/data_final_zero.dta
   data/final/reg_data_zero.dta   (input to the VAR scripts)
==============================================================================*/

do "00_setup.do"

clear
clear matrix
capture log close

cd "$root/data/interim/merge"
use "$root/data/interim/merge/aus_zero_markup_hhi.dta", clear
sort TFP markup hhi

foreach y in be cz de es fr it lu pl pt sk {
    sort TFP markup hhi
    qui: merge m:m TFP markup hhi hhi5 using "$root/data/interim/merge/`y'_zero_markup_hhi.dta"
    drop _merge
}

keep year size id markup TFP m_s hhi hhi5 nb_firms country_n sec grp turnover

* National-level HHI/market-share kept for reference, renamed out of the way
* before recomputing a pooled Pan-EU version below.
rename hhi hhi_nat
rename hhi5 hhi5_nat
rename m_s m_s_nat
label var hhi_nat "National Level HHI"
label var hhi5_nat "National Level HHI"
label var m_s_nat "National Level Market Share"

* --- Pan-EU market share and HHI (pooled across the 11 countries) ---
egen t_turnover = sum(turnover), by(sec year)
label var t_turnover "Total Sum Turnover"

gen m_s = turnover / t_turnover
label var m_s "Market Share Pan EU"

sort id year
hhi5 m_s, by(sec year) pre(hhi5) per
rename hhi5_m_s hhi
label var hhi "HHI Pan EU"

* One-off missing-data report (requires network access to fetch the
* `missings` package the first time it's run).
cap ssc install missings
missings report, percent

* HHI enters the VAR on a 0-1 scale rather than the raw 0-10,000 scale
* used for the descriptive statistics in the thesis text (chapter 5.5).
replace hhi = hhi / 10000

tab sec, gen(sec_)
tab size, gen(size_)
save "$root/data/final/data_final_zero.dta", replace

* --- Merge in interest rates ---
use "$root/data/final/data_final_zero.dta", clear
merge m:m country_n year using "$root/data/interim/interest/interest_rate.dta"
save "$root/data/final/data_final_zero.dta", replace

order year country_n size hhi markup TFP interest
sort year id size country_n

* Country labels -- Hungary/Croatia ("Hr", original country_n==7) excluded,
* see 00_setup.do. Remaining 11 slots renumbered 1-11 in the order below;
* if you regenerate from 01_editing.do, confirm this still matches your
* `encode country_n1` ordering before trusting these labels.
label define country_n 1 "Austria" 2 "Belgium" 3 "Czechia" 4 "Germany" ///
    5 "Spain" 6 "France" 7 "Italy" 8 "Luxembourg" 9 "Poland" ///
    10 "Portugal" 11 "Slovakia", replace

save "$root/data/final/reg_data_zero.dta", replace

sort country_n year
order country_n year sec hhi m_s TFP interest
