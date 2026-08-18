clear		
clear matrix 		
capture log close		
		
		
cd "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\interest"		
*Data Source in SDW: https://sdw.ecb.europa.eu/browse.do?node=9691124		
import delimited "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Interest\interest data.csv", varnames(1) 		
save interest_data.dta,replace		
		
*first create yealy variable 		
rename country_n country_n1		
encode country_n1, generate(country_n)		
		
		
		
 generate date = date(v1,"YM")		
format date %tdNN/CCYY 		
		
keep interest country_n date		
order date country_n interest		
		
label var interest "Interest Rate" 		
		
		
gen year = year(date)		
sort year		
save interest_data.dta,replace		
sort year country_n		
order year country_n interest		
		
		
foreach r of num 1(1)12 {		
use interest_data.dta,clear		
    keep if country_n == `r'		 
by year:asgen i_wm = interest, w(interest)		
collapse interest, by(year country_n)		
save interest_rate_`r'.dta,replace		
}		
use interest_rate_1,clear		
forvalues r =  2/12{		
 append using interest_rate_`r'.dta		
 }		
 		
 keep if year > 1997		
 drop if year > 2019		
 sort year country_n		
order year country_n interest		
		
tsset country_n year, yearly		
		
gen d_interest = d.interest		
		
save interest_rate.dta,replace		
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Merge\interest_rate.dta",replace		
