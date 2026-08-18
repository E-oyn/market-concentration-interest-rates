			
clear			
clear matrix			
capture log close			
			
cd "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Merge"			
 use "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Merge\aus_zero_markup_hhi.dta", clear			
sort TFP markup hhi			
			
foreach y in be cz de es fr hr it lu pl pt sk {			
	sort TFP markup hhi		 
	qui:merge m:m  TFP markup hhi hhi5 using `y'_zero_markup_hhi		
	drop _merge		
	}		
 			
keep year size id markup TFP m_s hhi hhi5 nb_firms country_n sec grp turnover			
*foreach y in markup TFP hhi {			
*drop if `y' < 0			
*}			
*Calculatin Pan EU HHI Index			
			
*gen country_n1 = country_n + 1010			
*replace id = id + country_n1			
rename hhi hhi_nat			
rename hhi5 hhi5_nat			
rename m_s m_s_nat			
			
label var hhi_nat "National Level HHI"			
label var hhi5_nat "National Level HHI"			
label var m_s_nat "National Level Market Share" 			
*Calculate Total Sales in each sector/year			
egen t_turnover = sum(turnover), by(sec year) 			
label var t_turnover "Total Sum Turnover"			
			
*Calculate Market Share 			
gen m_s =  turnover	/ t_turnover		
label var m_s "Market Share Pan EU"			
			
*Calculate Herfindahl–Hirschman Index			
sort id year			
*hhi m_s, by(grp) 			
*label var hhi "HHI Pan EU"			
			
hhi5 m_s, by(sec year) pre(hhi5) per			
rename hhi5_m_s hhi			
label var hhi "HHI Pan EU"			
			
			
			
ssc inst missings,replace			
missings report, percent			
			
*drop if missing(markup,TFP,hhi)			
replace hhi = hhi/10000			
tab sec, gen(sec_)			
tab size, gen(size_)			
save data_final_zero.dta,replace			
			
*Regression analysis			
			
use data_final_zero.dta,clear			
merge m:m country_n year using "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Interest\interest_rate.dta"			
save data_final_zero.dta,replace			
			
order year country_n size hhi markup TFP interest			
*rename sec_1 A			
*rename sec_2 B			
*rename sec_3 C			
*rename sec_4 D			
*rename sec_5 E			
*rename sec_6 F			
*rename sec_7 G			
*rename sec_8 H			
*rename sec_9 I			
*rename sec_10 J			
*rename sec_11 L			
*rename sec_12 Mc			
*rename sec_13 N			
*rename sec_14 P			
*rename sec_15 Q			
*rename sec_16 R			
*rename sec_17 S			
*rename sec_18 Zc			

			
			
sort year id size country_n			
			
			
*gen ln_interest = ln(interest) 			
			
label define country_n 1 "Austria" 2 "Belgium" 3 "Czechia" 4 "Germany" 5 "Spain" 6 "France" 7 "Hungary" 8 "Italy" 9 "Luxemburg" 10 "Poland" 11 "Portugal" 12 "Slovakia" ,replace			
			
			
			
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\reg_data_zero.dta",replace			
			
sort country_n year			
order country_n year sec hhi m_s TFP interest lag_interest ln_lag_interest			
