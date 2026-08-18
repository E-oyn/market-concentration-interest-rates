				
**Zero Changes in Interest Rate 			
				
clear				
clear matrix 				
capture log close 				
				
	cd "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR" 			
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
				
				
	drop if country_n-_merge == .			
				
				
pvarsoc interest TFP hhi , pvaropts(instlags(1/4)fd)			
matrix list r(stats)
matrix varsoc = r(stats)
putexcel set "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\HHI\Varsoc\varsoc_`v'.xlsx", sheet("M") replace
putexcel b1 = matrix(varsoc), colnames
putexcel a2 = matrix(varsoc), rownames
				
				
pvar interest TFP hhi,lags(1) level(95)  instlags(1/4) fd overid				
				
pvargranger				
pvarstable,graph				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\HHI\Graph I-R `v' Stability.png", as(png) replace				
				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP hhi) xlabel(0(1)10) scheme(s2color) impulse(TFP) response(hhi)				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\HHI\Graph I-R `v' IRF.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\HHI\Graph I-R `v' IRF.gph", replace				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP hhi) xlabel(0(1)10) scheme(s2color) cum impulse(TFP) response(hhi)			
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\HHI\Graph I-R`v' IRF Cum.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\HHI\Graph I-R`v' IRF Cum.gph", replace				
}				


				
**Zero Changes in Interest Rate 			
				
clear				
clear matrix 				
capture log close 				
				
	cd "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR" 			
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
				
				
				
	drop if country_n-_merge == .			
				
				
pvarsoc interest TFP hhi , pvaropts(instlags(1/4)fd)
matrix list r(stats)
matrix varsoc = r(stats)		
putexcel set "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\Interest\HHI\Varsoc\varsoc_`v'.xlsx", sheet("M") replace
putexcel b1 = matrix(varsoc), colnames
putexcel a2 = matrix(varsoc), rownames				
				
pvar interest TFP hhi,lags(1) level(95)  instlags(1/4) fd overid				
				
pvargranger				
pvarstable,graph				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\Interest\HHI\Graph I-R `v' Stability.png", as(png) replace				
				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP hhi) xlabel(0(1)10) scheme(s2color) impulse(interest) response(hhi)				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\Interest\HHI\Graph I-R `v' IRF.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\Interest\HHI\Graph I-R `v' IRF.gph", replace				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP hhi) xlabel(0(1)10) scheme(s2color) cum impulse(interest) response(hhi)				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\Interest\HHI\Graph I-R`v' IRF Cum.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\Interest\HHI\Graph I-R`v' IRF Cum.gph", replace				
}				


**Testing for m_s


clear				
clear matrix 				
capture log close 				
				
	cd "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR" 			
use "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\reg_data_zero.dta", clear				
drop if year == 2019				
order country_n year sec size m_s TFP interest				
sort country_n year size				
keep if sec == 18				
save var_sec_18,replace				
					
				
forvalues v = 1(1)4 {				
use var_sec_18.dta,clear				
keep if size == `v'				
xtset country_n year,yearly				
				
replace TFP = TFP /100				
				
				
				
	drop if country_n-_merge == .			
				
				
pvarsoc interest TFP m_s , pvaropts(instlags(1/4)fd)
matrix list r(stats)
matrix varsoc = r(stats)					
putexcel set "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\Interest\Market Share\Varsoc\varsoc_`v'.xlsx", sheet("M") replace
putexcel b1 = matrix(varsoc), colnames
putexcel a2 = matrix(varsoc), rownames					
				
pvar interest TFP m_s,lags(1) level(95)  instlags(1/4) fd overid				
				
pvargranger				
pvarstable,graph				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\Interest\Market Share\Graph I-R `v' Stability.png", as(png) replace				
				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP m_s) xlabel(0(1)10) scheme(s2color) impulse(interest) response(m_s)				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\Interest\Market Share\Graph I-R `v' IRF.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\Interest\Market Share\Graph I-R `v' IRF.gph", replace				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP m_s) xlabel(0(1)10) scheme(s2color) cum impulse(interest) response(m_s)				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\Interest\Market Share\Graph I-R`v' IRF Cum.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\Interest\Market Share\Graph I-R`v' IRF Cum.gph", replace				
}				
*Testing for Market Share TFP


				
**Zero Changes in Interest Rate 				
*TFP				
clear				
clear matrix 				
capture log close 				
				
	cd "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR" 			
use "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\reg_data_zero.dta", clear				
drop if year == 2019				
order country_n year sec size m_s TFP interest				
sort country_n year size				
keep if sec == 18				
save var_sec_18,replace				
				
				
forvalues v = 1(1)4 {				
use var_sec_18.dta,clear				
keep if size == `v'				
xtset country_n year,yearly				
				
replace TFP = TFP /100				
				
				
				
	drop if country_n-_merge == .			
				
				
pvarsoc interest TFP m_s , pvaropts(instlags(1/4)fd)				
matrix list r(stats)
matrix varsoc = r(stats)				
putexcel set "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\Market Share\Varsoc\varsoc_`v'.xlsx", sheet("M") replace
putexcel b1 = matrix(varsoc), colnames
putexcel a2 = matrix(varsoc), rownames					
				
pvar interest TFP m_s,lags(1) level(95)  instlags(1/4) fd overid				
				
pvargranger				
pvarstable,graph				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\Market Share\Graph I-R `v' Stability.png", as(png) replace				
				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP m_s) xlabel(0(1)10) scheme(s2color) impulse(TFP) response(m_s)				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\Market Share\Graph I-R `v' IRF.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\Market Share\Graph I-R `v' IRF.gph", replace				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP m_s) xlabel(0(1)10) scheme(s2color) cum impulse(TFP) response(m_s)				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\Market Share\Graph I-R`v' IRF Cum.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\Market Share\Graph I-R`v' IRF Cum.gph", replace				
}	



*Interest
clear				
clear matrix 				
capture log close 				
				
	cd "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR" 			
use "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\reg_data_zero.dta", clear				
drop if year == 2019				
order country_n year sec size m_s TFP interest				
sort country_n year size				
keep if sec == 18				
save var_sec_18,replace				
				
				
forvalues v = 1(1)4 {				
use var_sec_18.dta,clear				
keep if size == `v'				
xtset country_n year,yearly				
				
replace TFP = TFP /100				
				
				
				
	drop if country_n-_merge == .			
				
				
pvarsoc interest TFP m_s , pvaropts(instlags(1/4)fd)				
matrix list r(stats)
matrix varsoc = r(stats)				
putexcel set "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\Market Share\Varsoc\varsoc_`v'.xlsx", sheet("M") replace
putexcel b1 = matrix(varsoc), colnames
putexcel a2 = matrix(varsoc), rownames					
				
pvar interest TFP m_s,lags(1) level(95)  instlags(1/4) fd overid				
				
pvargranger				
pvarstable,graph				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\Market Share\Graph I-R `v' Stability.png", as(png) replace				
				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP m_s) xlabel(0(1)10) scheme(s2color) impulse(interest) response(m_s)				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\Market Share\Graph I-R `v' IRF.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\Market Share\Graph I-R `v' IRF.gph", replace				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP m_s) xlabel(0(1)10) scheme(s2color) cum impulse(interest) response(m_s)				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\Market Share\Graph I-R`v' IRF Cum.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFP\Market Share\Graph I-R`v' IRF Cum.gph", replace				
}				


			
				
**Testing for Markups
**TFP
clear				
clear matrix 				
capture log close 				
				
	cd "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR" 			
use "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\reg_data_zero.dta", clear				
drop if year == 2019				
order country_n year sec size markup TFP interest				
sort country_n year size				
keep if sec == 18				
save var_sec_18,replace				
				
				
forvalues v = 1(1)4 {				
use var_sec_18.dta,clear				
keep if size == `v'				
xtset country_n year,yearly				
				
replace TFP = TFP /100				
				
				
				
	drop if country_n-_merge == .			
				
				
pvarsoc interest TFP markup , pvaropts(instlags(1/4)fd)				
matrix list r(stats)
matrix varsoc = r(stats)				
putexcel set "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\Interest\Markup\Varsoc\varsoc_`v'.xlsx", sheet("M") replace
putexcel b1 = matrix(varsoc), colnames
putexcel a2 = matrix(varsoc), rownames					
				
pvar interest TFP markup,lags(1) level(95)  instlags(1/4) fd overid				
				
pvargranger				
pvarstable,graph				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\\Interest\Markup\Graph I-R `v' Stability.png", as(png) replace				
				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP markup) xlabel(0(1)10) scheme(s2color) impulse(interest) response(markup)				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\Interest\Markup\Graph I-R `v' IRF.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\\Interest\Markup\Graph I-R `v' IRF.gph", replace				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP markup) xlabel(0(1)10) scheme(s2color) cum impulse(interest) response(markup)				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\\Interest\Markup\Graph I-R`v' IRF Cum.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\\Interest\Markup\Graph I-R`v' IRF Cum.gph", replace				
}


				
**Zero Changes in Interest Rate 			
				
clear				
clear matrix 				
capture log close 				
				
	cd "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR" 			
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
				
				
				
	drop if country_n-_merge == .			
				
				
pvarsoc interest TFP hhi , pvaropts(instlags(1/4)fd)			
matrix list r(stats)
matrix varsoc = r(stats)				
putexcel set "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\IntTFP\Varsoc\varsoc_`v'.xlsx", sheet("M") replace
putexcel b1 = matrix(varsoc), colnames
putexcel a2 = matrix(varsoc), rownames					
				
pvar interest TFP hhi,lags(1) level(95)  instlags(1/4) fd overid				
				
pvargranger				
pvarstable,graph				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\IntTFP\Graph I-R `v' Stability.png", as(png) replace				
				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP hhi) xlabel(0(1)10) scheme(s2color) impulse(interest) response(TFP)				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\IntTFP\Graph I-R `v' IRF.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\IntTFP\Graph I-R `v' IRF.gph", replace				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP hhi) xlabel(0(1)10) scheme(s2color) cum impulse(interest) response(TFP)			
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\IntTFP\Graph I-R`v' IRF Cum.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\IntTFP\Graph I-R`v' IRF Cum.gph", replace				
}				

**Zero Changes in Interest Rate 			
				
clear				
clear matrix 				
capture log close 				
				
	cd "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR" 			
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
				
				
				
	drop if country_n-_merge == .			
				
				
pvarsoc TFP interest hhi , pvaropts(instlags(1/4)fd)			
matrix list r(stats)
matrix varsoc = r(stats)				
putexcel set "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFPInt\Varsoc\varsoc_`v'.xlsx", sheet("M") replace
putexcel b1 = matrix(varsoc), colnames
putexcel a2 = matrix(varsoc), rownames					
				
pvar interest TFP hhi,lags(1) level(95)  instlags(1/4) fd overid				
				
pvargranger				
pvarstable,graph				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFPInt\Graph I-R `v' Stability.png", as(png) replace				
				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(TFP interest hhi) xlabel(0(1)10) scheme(s2color) impulse(TFP) response(interest)				
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFPInt\Graph I-R `v' IRF.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFPInt\Graph I-R `v' IRF.gph", replace				
pvarirf, r(iter) level(95)  mc(1500)  step(10) byoption(yrescale ixtitle ixaxe) oirf porder(TFP interest hhi) xlabel(0(1)10) scheme(s2color) cum impulse(TFP) response(interest)			
graph export "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFPInt\Graph I-R`v' IRF Cum.pdf", as(pdf) replace				
graph save Graph "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\VAR\Graphs\I-R\TFPInt\Graph I-R`v' IRF Cum.gph", replace				
}			
