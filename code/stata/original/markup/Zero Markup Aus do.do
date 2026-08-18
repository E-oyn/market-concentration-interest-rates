			
//////////////////////////////*Markup\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\			
			
**Thesis Aggregated Data Calculations** 11.10.2020			
			
clear			
clear matrix			
capture log close			
			
cd "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Markup\aus"			
			
log using "Thesis aggregated aus Markup Calculation plus zero log", replace 			
*Import Data			
 use "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\Markup\Aus\Aggregated_Aus_zero.dta"			
rename l_fixed_cost cap			
rename l_external_cost ex			
rename l_staff_cost labour			
rename l_sgna ssal			
rename l_cogs m			
rename l_revenue pi			
rename l_ten_inventory y			
rename l_value_added val_ad			
rename l_total_var_cost var			
			
sort year id			
keep cap labour m ex year id y sec size val_ad var pi l_sales var ssal l_expenses sec country_n			
*gen t=year[_n]-78			
sort sec			
			
save loop_data_zero,replace 			
			
*drop r11_wm r12_wm r13_wm r14_wm r15_wm r16_wm r21_wm r22_wm r23_wm r24_wm r25_wm r26_wm r27_wm r31_wm r32_wm r33_wm r34_wm r35_wm r36_wm r37_wm r38_wm r39_wm r310_wm r41_wm r42_wm r51_wm r52_wm r53_wm r54_wm			
			
foreach r of num 1(1)18 {			
			
    keep if sec == `r'			
	save acfest_data_aus_zero_`r',replace		
	use loop_data_zero,clear		
}			
			
			
			
order sec size year pi cap y labour var			
			
*Dropping yearly losses because regression does not work with negative values			
			
xtset id year, yearly			
forvalues r =  1(1)18 {			
	use acfest_data_aus_zero_`r',replace		
	drop if pi < 0		
acfest pi, state(cap) proxy(y) free(labour) i(size) t(year) nbs(19) overid			
predict TFP_acfest,omega			
replace TFP_acfest = (TFP_acfest + 100)			
gen markup_acfest = (pi/var)*(TFP_acfest) / 100			
rename markup_acfest markup_aus_zero			
xtline markup_aus_zero, recast(line) tlabel(, labsize(medium) angle(vertical))			
gr export line_markup_aus_zero_`r'.pdf,replace			
			
histogram markup_aus_zero, kdensity kdenopts(lcolor(black) lwidth(thick) lpattern(solid) connect(direct))			
gr export histogram_markup_zero_`r'.pdf,replace			
			
histogram TFP_acfest, kdensity kdenopts(lcolor(black) lwidth(thick) lpattern(solid) connect(direct))			
gr export histogram_TFP_zero_`r'.pdf,replace			
			
rename TFP_acfest TFP_aus_zero			
by size:gen profit_rate = pi/l_sales			
by size: gen overhead = ssal / l_expenses			
by size: gen delta_profit = (profit_rate - l.profit_rate) / l.profit_rate *100			
by size: gen delta_overhead = (overhead - l.overhead) / l.overhead	*100		
by size: gen delta_markup = (markup_aus_zero - l.markup_aus_zero) / l.markup_aus_zero	*100		
			
save acfest_data_aus_zero_`r',replace			
}			
			
use acfest_data_aus_zero_1,clear			
			
forvalues r =  2/18{			
 append using acfest_data_aus_zero_`r'.dta			
 }			
 egen grp = group (year sec)			
label var grp group_variable			
sort grp			
save aus_markup_zero,replace			
save "C:\Users\Ege\Dropbox\WiSo 20-21\Data\Zero\HHI\Aus\aus_markup_zero.dta",replace
			
			
			
