*Effect of Monetary Policy on Competetion*	
*Thesis Do File*	
	
clear	
clear matrix	
capture log close	
	
cd "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Editing"	
	
log using "Data Editing",replace	
	
*Importing the data and dividing it in two according to the two samples (sliding samples)	
import delimited "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Editing\export_20210129191251746916", delimiter(";") varnames(1) 	
encode country, generate(country_n)	
	
save sliding_zero,replace	
*Editing data and names for the zero set	
	
use sliding_zero,clear	
drop coverage_firms coverage_turnover coverage_employees country sample	
	
*In some years in given sector, year and size there not enough companies to have the data.	
//I dropped these 	
	
egen missings=rowmiss(_all)	
sort missings
*Dropping if more than 2 rows are missing	
drop if missings>2	
drop missings

*Labeling the Data	
label variable year Year	
label var sector "Sector Code" 	
label var size "Size Indicator" 	
label var turnover "Sales (€ thousands)"	
label var nb_firm "Number of Companies"	
label var employees "Number of Employees" 	
label var total_assets "Total Assets (€ thousands)"	
label var gross_value_added "Value Added (€ thousands)"	
label var a12_wm "Tangible Fixed Assets"	
label var a1_wm "Fixed Assets"	
label var a2_wm "Inventories" 	
label var a_wm "Total Balance Sheet"	
label var i1_wm "Net Turnover" 	
label var i41_wm "Operating Income"	
*label var i42_wm "Financial Income"	
	
	
label var i5_wm "Cost of Goods Sold"	
	
label var i6_wm "External Supplies and Services"	
	
label var i7_wm "Staff Cost"	
	
label var i8_wm "Other Expenses"	
	
label var i81_wm "Selling, General and Administrative Expenses"	
	
label var it1_wm "Revenue" 	
label var it2_wm "Expenses" 	
label var it3_wm "Net profit or loss for the period"	
	
*Defining the company size variable	
	
label define size    1    "1a"    2    "1b" 3 "1" 4 "2"	
foreach v of varlist size* {	
    encode `v', gen(_`v') label(size)	
    drop `v'	
    rename _`v' `v'	
}	
tab1 size*	
tab1 size*, nolabel	
label drop size	
	
sort year sector size 	
gen id_c = sector+string(size,"%02.0f")	
order id_c
rename id_c id 	
label var id "Company sector ID and Size" 	
sort year id 	
order year id  turnover nb_firms	
encode id, gen(company)	
drop id 	
rename company id 	
order id 
sort country_n
destring, replace dpcomma

*In the dataset from iBach, total assets, value added and turnover are given as absolute values in € thousands 	
/// and items as their percentage. Therefore they have been replaced by its multiplacation. 	
	
foreach r in i41_wm i42_wm i5_wm i6_wm i7_wm  i8_wm i81_wm it2_wm it3_wm {	
 replace `r' = `r' * turnover	
 }	
	
	
	
	
replace a12_wm = a12_wm*total_assets	
replace a2_wm = a2_wm*total_assets	
replace a1_wm = a1_wm*total_assets	
	
*Generating Total variable cost. i81 is part of i8 that is why its not included.	
egen total_var_cost_wm = rowtotal(i6_wm i7_wm i8_wm)	
	
label var total_var_cost_wm "Total Variable Cost"  	
	
sort id year	
	
*Generate capital stock for previous year since capital in t-1 is used for production in t.	
egen panelid = group(id country_n), label	
	
	
save sliding_zero,replace	
	
	
*In some years it3_wm is negative therefore can not be logged. 	
//Therefore first I isolated negative numbers, take the absolute values and logged.	
//then merged it to the original dataset.	
	
keep if it3_wm < 0	
replace it3_wm =it3_wm *(-1) 	
gen l_revenue = ln(it3_wm)	
replace l_revenue = l_revenue*(-1)	
save revenue_negatives_zero,replace	
	
use sliding_zero,clear	
drop if it3_wm<0	
gen l_revenue=ln(it3_wm)	
append using "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Editing\revenue_negatives_zero.dta"	
	
	
gen l_sales =ln(turnover)	
gen l_total_var_cost = ln(total_var_cost)	
gen l_value_added = ln(gross_value_added)	
gen l_fixed_cost = ln(a12_wm)	
gen l_operating_inc = ln(i41_wm)	
gen l_financial_inc = ln(i42_wm)	
gen l_sgna=ln(i81_wm)	
gen l_cogs=ln(i5_wm)	
gen l_staff_cost=ln(i7_wm)	
gen l_external_cost=ln(i6_wm)	
gen l_other_expenses=ln(i81_wm)	
gen l_total_income=ln(it1_wm)	
gen l_expenses = ln(it2_wm)	
gen l_ten_inventory=ln(a2_wm)	
gen l_inventory=ln(a1_wm)	
gen l_overhead = l_other_expenses / (l_operating_inc + l_financial_inc)	
egen nmcount = rownonmiss(l_revenue),strok	
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
label var l_ten_inventory "Tengible Inventory"	
label var l_inventory "Inventories"	
label var l_overhead "Overhead Ratio"	
	
compress 	
	
	
order year panelid	
sort year panel id	
	
encode sector, generate(sec)	
	
save aggregated_all_zero.dta, replace	
	

	
	
	
	
use aggregated_all_zero,clear	
	
	
	
	
	
keep if country_n == 1	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Markup\Aus\Aggregated_Aus_zero.dta",replace	
use Aggregated_All_zero,clear	
	
keep if country_n == 2	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Markup\Be\Aggregated_Be_zero.dta",replace	
	
use Aggregated_All_zero,clear	
keep if country_n == 3	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Markup\Cz\Aggregated_Cz_zero.dta",replace	
use Aggregated_All_zero,clear	
keep if country_n == 4	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Markup\De\Aggregated_De_zero.dta",replace	
use Aggregated_All_zero	
keep if country_n == 5	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Markup\Es\Aggregated_Es_zero.dta",replace	
	
use Aggregated_All_zero,clear	
keep if country_n == 6	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Markup\Fr\Aggregated_Fr_zero.dta",replace	
	
use Aggregated_All_zero,clear	
keep if country_n == 7	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Markup\Hr\Aggregated_Hr_zero.dta",replace	
	
use Aggregated_All_zero,clear	
keep if country_n == 8	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Markup\It\Aggregated_It_zero.dta",replace	
use Aggregated_All_zero,clear	
keep if country_n == 9	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Markup\Lu\Aggregated_Lu_zero.dta",replace	
	
use Aggregated_All_zero,clear	
keep if country_n == 10	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Markup\Pl\Aggregated_Pl_zero.dta",replace	
	
use Aggregated_All_zero,clear	
keep if country_n == 11	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Markup\Pt\Aggregated_Pt_zero.dta",replace	
use Aggregated_All_zero	
keep if country_n == 12	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Markup\Sk\Aggregated_Sk_zero.dta",replace	

use aggregated_all_zero,clear	


keep if country_n == 1	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\hhi\Aus\Aggregated_Aus_zero.dta",replace	
use Aggregated_All_zero,clear	
	
keep if country_n == 2	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\hhi\Be\Aggregated_Be_zero.dta",replace	
	
use Aggregated_All_zero,clear	
keep if country_n == 3	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\hhi\Cz\Aggregated_Cz_zero.dta",replace	
use Aggregated_All_zero,clear	
keep if country_n == 4	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\hhi\De\Aggregated_De_zero.dta",replace	
use Aggregated_All_zero	
keep if country_n == 5	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\hhi\Es\Aggregated_Es_zero.dta",replace	
	
use Aggregated_All_zero,clear	
keep if country_n == 6	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\hhi\Fr\Aggregated_Fr_zero.dta",replace	
	
use Aggregated_All_zero,clear	
keep if country_n == 7	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\hhi\Hr\Aggregated_Hr_zero.dta",replace	
	
use Aggregated_All_zero,clear	
keep if country_n == 8	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\hhi\It\Aggregated_It_zero.dta",replace	
use Aggregated_All_zero,clear	
keep if country_n == 9	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\hhi\Lu\Aggregated_Lu_zero.dta",replace	
	
use Aggregated_All_zero,clear	
keep if country_n == 10	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\hhi\Pl\Aggregated_Pl_zero.dta",replace	
	
use Aggregated_All_zero,clear	
keep if country_n == 11	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\hhi\Pt\Aggregated_Pt_zero.dta",replace	
use Aggregated_All_zero	
keep if country_n == 12	
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\hhi\Sk\Aggregated_Sk_zero.dta",replace	
	
	
	
	
	
