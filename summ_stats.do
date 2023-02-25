// Do regressions for the research not tables

clear all

use $rootdir/data/processed/reg_data
merge 1:1 country year using $rootdir/data/processed/shocks

drop _merge

qui include drop_vars.do

gen time_in_sample = year >= 1990 & year <= 2019

sysdir set PLUS ado
local minhz = 0
local maxhz = 5
local depvar wb_wdi_primbal
local outdir $rootdir/figures

xtset countryid year

// gen news vars

foreach hz of num `maxhz'/`minhz' {
	gen news_`hz'yrs_ago = (fctF`hz'yrs_ago + fctS`hz'yrs_ago)/2
	gen news_S2F`hz'yrs_ago = fctF`hz'yrs_ago - fctS`hz'yrs_ago
	foreach szn in S F {
		gen news_`szn'`hz'yrs_ago = fct`szn'`hz'yrs_ago
	}

	if `hz' < `maxhz' {
		local hzp1 = `hz' + 1
		gen news_diff_`hz'yrs_ago = (news_`hz'yrs_ago - fctF`hzp1'yrs_ago/2- fctS`hzp1'yrs_ago/2)
		gen news_F2S`hz'yrs_ago = fctS`hz'yrs_ago - fctF`hzp1'yrs_ago
		foreach szn in S F {
			gen news_diff_`szn'`hz'yrs_ago = news_`szn'`hz'yrs_ago - news_`szn'`hzp1'yrs_ago
		}

	}
}

gen jai_pan_dev = jai_pan_midhi | jai_pan_midli | jai_pan_li
gen jai_pan_dev_mid = jai_pan_midhi | jai_pan_midli 
gen al_tab_noecd = 1 - al_tab_oecd
gen rvk_oecd = al_tab_oecd & country != "Malta" & country != "Iceland" & country != "Luxembourg" & country != "Turkiye"
gen rvk_oecd_ex_big = rvk_oecd & country != "United States" & country != "Germany" & country != "Japan" 
gen rvk_dev_mid = rvk_midhi | rvk_midli
gen full_samp = rvk_oecd | jai_pan_dev

local cats "full_samp rvk_oecd rvk_oecd_ex_big jai_pan_dev_mid jai_pan_li"


*local cats "rvk_oecd rvk_oecd_ex_us rvk_dev_mid rvk_midhi rvk_midli rvk_li"
*local cat_labels `" "OECD" "OECD, ex-US" "Dev., Mid.-Inc." "Dev., High Mid-Inc." "Dev., Low Mid-Inc." "Dev., Low-Inc.""'
 
local endog_sets `" "gRGDP" "gRGDP news_1yrs_ago" "gRGDP news_diff_1yrs_ago" "gRGDP news_1yrs_ago news_2yrs_ago" "gRGDP news_diff_1yrs_ago news_diff_2yrs_ago" "gRGDP f_news_1yrs_ago" "gRGDP f_news_diff_1yrs_ago" "gRGDP f_news_1yrs_ago f2_news_2yrs_ago" "gRGDP f_news_diff_1yrs_ago f2_news_diff_2yrs_ago" "'

local iv_sets `" "shock_t" "shock_t shock_fct1" "shock_t d_shock_fct1" "shock_t shock_fct1 shock_fct2" "shock_t d_shock_fct1 d_shock_fct2" "shock_t f_shock_fct1" "shock_t f_d_shock_fct1" "shock_t f_shock_fct1 f2_shock_fct2" "shock_t f_d_shock_fct1 f2_d_shock_fct2" "'

local struct_order_str "gRGDP news_1yrs_ago news_2yrs_ago news_diff_1yrs_ago news_diff_2yrs_ago f_news_1yrs_ago f2_news_2yrs_ago f_news_diff_1yrs_ago f2_news_diff_2yrs_ago pctd_tot l_`depvar'"

local fs_order_str "shock_t shock_fct1 shock_fct2 d_shock_fct1 d_shock_fct2 f_shock_fct1 f2_shock_fct2 f_d_shock_fct1 f2_d_shock_fct2 pctd_tot l_`depvar'"


gen l_`depvar' = l.`depvar'
gen pctd_tot = 100*d.tot/l.tot
gen f_news_1yrs_ago = f.news_1yrs_ago 
gen f2_news_2yrs_ago = f2.news_2yrs_ago 
gen f_news_diff_1yrs_ago = f.news_diff_1yrs_ago 
gen f2_news_diff_2yrs_ago = f2.news_diff_2yrs_ago
gen f_shock_fct1 = f.shock_fct1
gen f2_shock_fct2 = f2.shock_fct2
gen f_d_shock_fct1 = f.d_shock_fct1
gen f2_d_shock_fct2 = f2.d_shock_fct2

la var l_`depvar' "Lagged primary balance (\% GDP)"
la var pctd_tot "\% Change in terms-of-trade index"

la var gRGDP "Real YoY GDP Growth (\%)"
la var news_1yrs_ago "\$ News_{i,t-1}(t)\$ (\%)"
la var news_2yrs_ago "\$ News_{i,t-2}(t)\$ (\%)"
la var news_diff_1yrs_ago "\$ \Delta News_{i,t-1}(t)\$ (\%)"
la var news_diff_2yrs_ago "\$ \Delta News_{i,t-2}(t)\$ (\%)"

la var shock_t "\$ Shock_{i,t}\$ (\%)"
la var shock_fct1 "\$ FctShock_{i,t-1}(t)\$ (\%)"
la var shock_fct2 "\$ FctShock_{i,t-2}(t)\$ (\%)"
la var d_shock_fct1 "\$ \Delta FctShock_{i,t-1}(t)\$ (\%)"
la var d_shock_fct2 "\$ \Delta FctShock_{i,t-2}(t)\$ (\%)"

la var wb_wdi_primbal "Primary balance (\% GDP)"
la var tot "Net barter terms of trade index (2000 = 100)"

local summ_vars wb_wdi_primbal gRGDP pctd_tot news_1yrs_ago news_2yrs_ago news_diff_1yrs_ago news_diff_2yrs_ago shock_t shock_fct1 shock_fct2 d_shock_fct1 d_shock_fct2
foreach c of local cats {
	
	cap mat drop summ_tbl
	
foreach v of local summ_vars {
	
	tabstat `v' if `c' == 1, s(mean sd n p1 q p99 ) save
	mat summ_tbl = nullmat(summ_tbl)\r(StatTotal)'

}

outtable using tables/summ_stats_`c', mat(summ_tbl) replace f(%9.2f %9.2f %9.0f %9.2f %9.2f %9.2f %9.2f %9.2f) label asis


}

