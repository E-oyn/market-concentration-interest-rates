/*==============================================================================
 03_markup_hhi.do
 Consolidated from 11 near-identical per-country originals:
   "Zero Markup <Country> Do.do"  (TFP via acfest, markup construction)
   "HHI Zero <Country> Do.do"     (market share, HHI, HHI5, merge with markup)
 The originals were confirmed byte-for-byte structurally identical across
 countries (Austria and Belgium diffed directly; file sizes for the rest
 matched the same pattern) -- differing only by the country abbreviation
 substituted into variable/file names. Collapsed here into one parameterized
 loop instead of 22 duplicate files.

 Purpose, per country:
   1. TFP: Ackerberg-Caves-Frazer production function estimation (`acfest`),
      per sector (18 sectors), Cobb-Douglas with cap/labour as inputs and
      tangible inventory (y) as the proxy variable.
   2. Markup = (revenue / total variable cost) * TFP / 100.
   3. Market share = turnover / sector-year total turnover.
   4. HHI and HHI5 (Herfindahl-Hirschman Index, two implementations) on
      market share, grouped by (year x sector).
   5. Merge the markup and HHI outputs into one <country>_zero_markup_hhi.dta.

 INPUT:  data/interim/markup/<c>/aggregated_<c>_zero.dta
         data/interim/hhi/<c>/aggregated_<c>_zero.dta        (from 01_editing.do)
 OUTPUT: data/interim/merge/<c>_zero_markup_hhi.dta           (11 files)
         outputs/figures/<c>/*.pdf                            (per-sector TFP/markup plots)
==============================================================================*/

do "00_setup.do"

foreach c in aus be cz de es fr it lu pl pt sk {

    di as result "=== Country: `c' ==="

    * -------------------- Markup / TFP stage --------------------
    clear
    clear matrix
    capture log close
    cd "$root/data/interim/markup/`c'"
    log using "markup_`c'", replace text

    use "$root/data/interim/markup/`c'/aggregated_`c'_zero.dta", clear
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
    sort sec
    save loop_data_zero, replace

    forvalues r = 1(1)18 {
        use loop_data_zero, clear
        keep if sec == `r'
        save acfest_data_`c'_zero_`r', replace
    }

    order sec size year pi cap y labour var
    xtset id year, yearly

    * Dropping yearly losses because the regression does not work with
    * negative revenue values.
    forvalues r = 1(1)18 {
        use acfest_data_`c'_zero_`r', clear
        drop if pi < 0
        acfest pi, state(cap) proxy(y) free(labour) i(size) t(year) nbs(19) overid
        predict TFP_acfest, omega
        replace TFP_acfest = TFP_acfest + 100
        gen markup_acfest = (pi/var) * (TFP_acfest) / 100
        rename markup_acfest markup_`c'_zero
        xtline markup_`c'_zero, recast(line) tlabel(, labsize(medium) angle(vertical))
        graph export "$root/outputs/figures/`c'/line_markup_`c'_zero_`r'.pdf", replace

        histogram markup_`c'_zero, kdensity kdenopts(lcolor(black) lwidth(thick) lpattern(solid) connect(direct))
        graph export "$root/outputs/figures/`c'/histogram_markup_zero_`r'.pdf", replace

        histogram TFP_acfest, kdensity kdenopts(lcolor(black) lwidth(thick) lpattern(solid) connect(direct))
        graph export "$root/outputs/figures/`c'/histogram_TFP_zero_`r'.pdf", replace

        rename TFP_acfest TFP_`c'_zero
        by size: gen profit_rate = pi / l_sales
        by size: gen overhead = ssal / l_expenses
        by size: gen delta_profit = (profit_rate - l.profit_rate) / l.profit_rate * 100
        by size: gen delta_overhead = (overhead - l.overhead) / l.overhead * 100
        by size: gen delta_markup = (markup_`c'_zero - l.markup_`c'_zero) / l.markup_`c'_zero * 100

        save acfest_data_`c'_zero_`r', replace
    }

    use acfest_data_`c'_zero_1, clear
    forvalues r = 2/18 {
        append using acfest_data_`c'_zero_`r'.dta
    }
    egen grp = group(year sec)
    label var grp group_variable
    sort grp
    save "$root/data/interim/markup/`c'/`c'_markup_zero.dta", replace
    save "$root/data/interim/hhi/`c'/`c'_markup_zero.dta", replace
    log close

    * -------------------- HHI stage --------------------
    clear
    clear matrix
    capture log close
    cd "$root/data/interim/hhi/`c'"
    log using "hhi_`c'", replace text

    use "$root/data/interim/hhi/`c'/aggregated_`c'_zero.dta", clear
    sort year id
    xtset id year, yearly
    sort id year

    egen t_turnover = sum(turnover), by(sector year)
    label var t_turnover "Total Sum Turnover"

    gen m_s = turnover / t_turnover
    label var m_s Market_Share

    egen grp = group(year sector)
    label var grp group_variable

    hhi m_s, by(grp)
    label var hhi_m_s Herfindahl_Hirschman_Index

    hhi5 m_s, by(grp) pre(hhi5) per
    label var hhi5_m_s Herfindahl_Hirschman_Index_5

    rename hhi_m_s hhi_m_s_`c'_zero
    rename hhi5_m_s hhi5_m_s_`c'_zero

    xtline hhi5_m_s_`c'_zero, i(id) t(year)
    xtline hhi_m_s_`c'_zero, i(id) t(year)
    graph export "$root/outputs/figures/`c'/hhi5_`c'_zero.pdf", replace
    graph export "$root/outputs/figures/`c'/hhi_`c'_zero.pdf", replace

    histogram hhi_m_s_`c'_zero, kdensity kdenopts(lcolor(black) lwidth(thick) lpattern(solid) connect(direct))
    graph export "$root/outputs/figures/`c'/hhi_m_s_`c'_zero.pdf", replace

    save hhi_index_`c'_zero.dta, replace

    use hhi_index_`c'_zero.dta, clear
    merge 1:1 year sec size using "$root/data/interim/hhi/`c'/`c'_markup_zero.dta"

    keep year size id markup_`c'_zero TFP_`c'_zero m_s hhi_m_s_`c'_zero hhi5_m_s_`c'_zero grp country_n sec nb_firms turnover
    sort grp size
    order year size id markup_`c'_zero TFP_`c'_zero m_s hhi_m_s_`c'_zero hhi5_m_s_`c'_zero
    rename markup_`c'_zero markup
    rename TFP_`c'_zero TFP
    rename hhi_m_s_`c'_zero hhi
    rename hhi5_m_s_`c'_zero hhi5

    save "$root/data/interim/merge/`c'_zero_markup_hhi.dta", replace
    log close
}
