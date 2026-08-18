clear
clear matrix
capture log close

cd "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\HHI\Aus"

log using "Thesis aus Market Concentration calculation log", replace 
*Import Data
clear
 use "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\HHI\Aus\Aggregated_aus_zero.dta"



sort year id
*Declare Data Set to be a Panel Data Set 
*egen sector_id= group (size sector)
xtset id year,yearly

sort id year
*export excel using "hhi",replace firstrow(variables)



*Calculate Total Sales in each sector/year
egen t_turnover = sum(turnover), by(sector year) 
label var t_turnover "Total Sum Turnover"

*Calculate Market Share 
gen m_s = turnover / t_turnover
label var m_s Market_Share

*Calculate Group Variable
egen grp = group ( year sector)
label var grp group_variable

*Calculate Herfindahl–Hirschman Index
hhi m_s, by(grp) 
label var hhi_m_s Herfindahl_Hirschman_Index

hhi5 m_s, by(grp) pre(hhi5) per
label var hhi5_m_s Herfindahl_Hirschman_Index_5

rename hhi_m_s hhi_m_s_aus_zero
rename hhi5_m_s hhi5_m_s_aus_zero

*keep year id size m_s turnover nb_firms p_id t_turnover hhi5_m_s share_markup
xtline hhi5_m_s, i(id) t(year)
xtline hhi_m_s, i(id) t(year)

gr export hhi5_aus_zero.pdf,replace
gr export hhi_aus_zero.pdf,replace

histogram hhi_m_s_aus_zero, kdensity kdenopts(lcolor(black) lwidth(thick) lpattern(solid) connect(direct))
gr export hhi_m_s_aus_zero.pdf,replace

histogram hhi_m_s, kdensity kdenopts(lcolor(black) lwidth(thick) lpattern(solid) connect(direct))
gr export hhi_m_s.pdf,replace



save hhi_index_aus_zero.dta, replace



use hhi_index_aus_zero,clear
merge 1:1 year sec size using "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\HHI\Aus\aus_markup_zero.dta" 
keep year size id markup_aus_zero TFP_aus_zero m_s hhi_m_s_aus_zero hhi5_m_s_aus_zero grp country_n sec nb_firms turnover

sort grp size
order year size id markup_aus_zero TFP_aus_zero m_s hhi_m_s_aus_zero hhi5_m_s_aus_zero
rename markup_aus_zero markup
rename TFP_aus_zero TFP
rename hhi_m_s_aus_zero hhi
rename hhi5_m_s_aus_zero hhi5
save aus_zero_markup_hhi,replace
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Merge\aus_zero_markup_hhi.dta", replace
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Interest\aus_zero_markup_hhi.dta", replace
