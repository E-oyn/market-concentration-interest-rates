/*==============================================================================
 _var_core.do  (helper -- not meant to be run directly; called by
                05_var_lag1.do and 06_var_lag2_robustness.do)

 Consolidated from the original "VAR I-R.do" / "VAR I-R Second Lag.do",
 which repeated the same pvar/pvarirf block six-to-seven times per firm
 size to extract different impulse<->response pairs from what was
 substantively the same three-variable model. Here each 3-variable panel
 VAR (interest, TFP, <concentration measure>) is estimated ONCE per
 (concentration measure x firm size), and pvarirf is then called multiple
 times against that single estimate for each impulse/response pair --
 same results, without re-running GMM/Monte Carlo redundantly.

 Call with: do "_var_core.do" <lags> <tag>
   <lags> : 1 (thesis main specification) or 2 (thesis's own robustness
            check, ch. 9: "using the second lag produces insignificant
            results for all firm sizes and variables")
   <tag>  : folder label under outputs/figures/var/, e.g. "lag1" / "lag2"

 Model: Cholesky-ordered panel VAR (Abrigo & Love 2016), first-differenced,
 1-4 lags as GMM instruments, 95% CI, Monte Carlo (1500 draws), 10-step
 horizon, sector 18 (Pan-EU aggregate sector) only, four firm-size clusters.

 INPUT:  data/final/reg_data_zero.dta   (from 04_merge.do)
 OUTPUT: outputs/tables/var/<tag>/varsoc_<cv>_<size>.xlsx
         outputs/figures/var/<tag>/<cv>/Graph_<size>_{Stability,IRF,IRF_Cum}.pdf
==============================================================================*/

args lagn tag

cap mkdir "$root/outputs/tables/var"
cap mkdir "$root/outputs/tables/var/`tag'"
cap mkdir "$root/outputs/figures/var"
cap mkdir "$root/outputs/figures/var/`tag'"

clear
clear matrix
capture log close
cd "$root/data/final"
use "$root/data/final/reg_data_zero.dta", clear
drop if year == 2019
order country_n year sec size hhi m_s markup TFP interest
sort country_n year size
keep if sec == 18
save "$root/data/interim/merge/var_sec_18.dta", replace

foreach cv in hhi m_s markup {

    cap mkdir "$root/outputs/figures/var/`tag'/`cv'"

    forvalues v = 1/4 {

        use "$root/data/interim/merge/var_sec_18.dta", clear
        keep if size == `v'
        xtset country_n year, yearly
        replace TFP = TFP / 100
        drop if country_n - _merge == .

        * --- Lag/moment selection ---
        pvarsoc interest TFP `cv', pvaropts(instlags(1/4) fd)
        matrix list r(stats)
        matrix varsoc = r(stats)
        putexcel set "$root/outputs/tables/var/`tag'/varsoc_`cv'_`v'.xlsx", sheet("M") replace
        putexcel b1 = matrix(varsoc), colnames
        putexcel a2 = matrix(varsoc), rownames

        * --- Estimate once ---
        pvar interest TFP `cv', lags(`lagn') level(95) instlags(1/4) fd overid
        pvargranger
        pvarstable, graph
        graph export "$root/outputs/figures/var/`tag'/`cv'/Graph_`v'_Stability.png", as(png) replace
        * --- IRF: interest -> cv ---
        pvarirf, r(iter) level(95) mc(1500) step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP `cv') xlabel(0(1)10) scheme(s2color) impulse(interest) response(`cv')
        graph export "$root/outputs/figures/var/`tag'/`cv'/Graph_`v'_IRF_interest.pdf", as(pdf) replace
        pvarirf, r(iter) level(95) mc(1500) step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP `cv') xlabel(0(1)10) scheme(s2color) cum impulse(interest) response(`cv')
        graph export "$root/outputs/figures/var/`tag'/`cv'/Graph_`v'_IRF_interest_Cum.pdf", as(pdf) replace

        * --- IRF: TFP -> cv ---
        pvarirf, r(iter) level(95) mc(1500) step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP `cv') xlabel(0(1)10) scheme(s2color) impulse(TFP) response(`cv')
        graph export "$root/outputs/figures/var/`tag'/`cv'/Graph_`v'_IRF_TFP.pdf", as(pdf) replace
        pvarirf, r(iter) level(95) mc(1500) step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP `cv') xlabel(0(1)10) scheme(s2color) cum impulse(TFP) response(`cv')
        graph export "$root/outputs/figures/var/`tag'/`cv'/Graph_`v'_IRF_TFP_Cum.pdf", as(pdf) replace

        * --- Reverse-causality check (hhi block only, matching the original) ---
        if "`cv'" == "hhi" {
            pvarirf, r(iter) level(95) mc(1500) step(10) byoption(yrescale ixtitle ixaxe) oirf porder(interest TFP `cv') xlabel(0(1)10) scheme(s2color) impulse(TFP) response(interest)
            graph export "$root/outputs/figures/var/`tag'/`cv'/Graph_`v'_IRF_TFPtoInterest.pdf", as(pdf) replace
        }
    }
}
