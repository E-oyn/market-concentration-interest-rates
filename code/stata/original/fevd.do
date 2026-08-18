				
**Zero Changes in Interest Rate 			
				
clear				
clear matrix 				
capture log close 				
				
	cd "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\Variance Decomposition" 			
use "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\reg_data_zero.dta", clear	
drop if year == 2019			
order country_n year sec size hhi TFP interest				
sort country_n year size				
keep if sec == 18				
save var_sec_18,replace				
				
				
forvalues v = 1(1)4 {				
use var_sec_18.dta,clear				
keep if size == `v'				
xtset country_n year,yearly				
				
replace TFP = TFP /100				
				
gen size_dum = `v'		
				
	drop if country_n-_merge == .			
				
				
pvarsoc interest TFP hhi , pvaropts(instlags(1/4)fd)			
				
				
pvar interest TFP hhi,lags(1) level(95)  instlags(1/4) fd overid				
				
				
pvarfevd, mc(1500)  step(10) porder(interest TFP hhi)	save("vardec_`v'")	impulse(interest TFP hhi ) response(hhi)	
	
}				




forvalues v = 1(1)4 {

use vardec_`v',clear

gen dummy= `v' 


save vardec_`v'.dta,replace
}

clear

 append using "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\Variance Decomposition\vardec_1.dta" "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\Variance Decomposition\vardec_2.dta" "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\Variance Decomposition\vardec_3.dta" "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\Variance Decomposition\vardec_4.dta"
sort dummy impvar _step
save vardec_combined

keep _step resvar impvar fevd dummy


				
forvalues v = 1(1)4 {				
use var_sec_18.dta,clear				
keep if size == `v'				
xtset country_n year,yearly				
				
replace TFP = TFP /100				
				
gen size_dum = `v'		
				
	drop if country_n-_merge == .			
				
				
pvarsoc interest TFP markup , pvaropts(instlags(1/4)fd)			
				
				
pvar interest TFP markup,lags(1) level(95)  instlags(1/4) fd overid				
				
				
pvarfevd, mc(1500)  step(10) porder(interest TFP markup)	save("vardec_markup_`v'")	impulse(interest TFP markup) response(markup)	
	
}				




forvalues v = 1(1)4 {

use vardec_markup_`v',clear

gen dummy= `v' 


save vardec_markup_`v'.dta,replace
}

clear

 append using "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\Variance Decomposition\vardec_markup_1.dta" "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\Variance Decomposition\vardec_markup_2.dta" "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\Variance Decomposition\vardec_markup_3.dta" "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\Variance Decomposition\vardec_markup_4.dta"
sort dummy impvar _step

keep _step resvar impvar fevd dummy

save vardec_markup_combined
