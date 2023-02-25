// Do regressions for the research not tables

clear all

use $rootdir/data/processed/reg_data
merge 1:1 country year using $rootdir/data/processed/shocks

drop _merge

qui include drop_vars.do

drop if year < 1988 | year > 2019

sysdir set PLUS ado
local minhz = 0
local maxhz = 5

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


winsor2 netlend news_* gRGDP tot shock_*, replace c(1 99)

gen jai_pan_dev = jai_pan_midhi | jai_pan_midli | jai_pan_li
gen jai_pan_dev_mid = jai_pan_midhi | jai_pan_midli 
gen al_tab_noecd = 1 - al_tab_oecd
gen rvk_oecd = al_tab_oecd & country != "Malta" & country != "Iceland" & country != "Luxembourg"
gen rvk_oecd_ex_us = rvk_oecd & country != "United States"
gen rvk_dev_mid = rvk_midhi | rvk_midli


local cats "rvk_oecd rvk_oecd_ex_us jai_pan_dev_mid jai_pan_midhi jai_pan_midli jai_pan_li"
local cat_labels `" "OECD" "OECD, ex-US" "Dev., Mid.-Inc." "Dev., High Mid-Inc." "Dev., Low Mid-Inc." "Dev., Low-Inc.""'

*local cats "rvk_oecd rvk_oecd_ex_us rvk_dev_mid rvk_midhi rvk_midli rvk_li"
*local cat_labels `" "OECD" "OECD, ex-US" "Dev., Mid.-Inc." "Dev., High Mid-Inc." "Dev., Low Mid-Inc." "Dev., Low-Inc.""'


local endog_sets `" "gRGDP" "gRGDP news_1yrs_ago" "gRGDP news_diff_1yrs_ago" "gRGDP news_F1yrs_ago" "gRGDP news_diff_F1yrs_ago"  "gRGDP news_S1yrs_ago" "gRGDP news_diff_S1yrs_ago" "gRGDP news_F1yrs_ago news_F2yrs_ago" "gRGDP news_diff_F1yrs_ago news_diff_F2yrs_ago"  "gRGDP news_S1yrs_ago news_S2yrs_ago" "gRGDP news_diff_S1yrs_ago news_diff_S2yrs_ago" "gRGDP news_1yrs_ago news_2yrs_ago" "gRGDP news_diff_1yrs_ago news_diff_2yrs_ago" "gRGDP f.news_1yrs_ago" "gRGDP f.news_diff_1yrs_ago" "gRGDP f.news_1yrs_ago f2.news_2yrs_ago" "gRGDP f.news_diff_1yrs_ago f2.news_diff_2yrs_ago" "'

local iv_sets `" "shock_t" "shock_t shock_fct1" "shock_t d_shock_fct1" "shock_t shock_fctF1" "shock_t d_shock_fctF1"  "shock_t shock_fctS1" "shock_t d_shock_fctS1" "shock_t shock_fctF1 shock_fctF2" "shock_t d_shock_fctF1 d_shock_fctF2"  "shock_t shock_fctS1 shock_fctS2" "shock_t d_shock_fctS1 d_shock_fctS2"  "shock_t shock_fct1 shock_fct2" "shock_t d_shock_fct1 d_shock_fct2" "shock_t f.shock_fct1" "shock_t f.d_shock_fct1" "shock_t f.shock_fct1 f2.shock_fct2" "shock_t f.d_shock_fct1 f2.d_shock_fct2" "'

local num_sets : word count `endog_sets'

foreach n of num 1/`num_sets' {

	local endogs : word `n' of `endog_sets'
	local ivs : word `n' of `iv_sets'
	local num_endogs : word count `endogs'

	local filename_spec ENDS_`endogs'_IVS_`ivs'
	local filename_spec = subinstr("`filename_spec'","gRGDP","g",.)
	local filename_spec = subinstr("`filename_spec'","yrs_ago","",.)
	local filename_spec = subinstr("`filename_spec'","news","nws",.)
	local filename_spec = subinstr("`filename_spec'",".","",.)	
	local filename_spec = subinstr("`filename_spec'","shock_fct","shf",.)
	local filename_spec = subinstr("`filename_spec'","shock","sh",.)
	local filename_spec = subinstr("`filename_spec'",".","",.)
	local filename_spec = subinstr("`filename_spec'"," ","",.)
	di "`filename_spec'"

foreach i of local cats {

	
	* OLS
*	qui: xtreg netlend `endogs' d.tot l1.netlend if `i' == 1, fe cluster(countryid)
	qui: xtreg wb_wdi_primbal `endogs' d.tot l1.wb_wdi_primbal if `i' == 1, fe cluster(countryid)
	qui: est store ols_`i'
	qui: estadd ysumm
	qui: est save results/ols_`i'_`filename_spec', replace
	* Reduced form
*	qui: xtreg netlend `ivs' d.tot l1.netlend if `i' == 1, fe cluster(countryid)
	qui: xtreg wb_wdi_primbal `ivs' d.tot l1.wb_wdi_primbal if `i' == 1, fe cluster(countryid)
	qui: est store rf_`i'
	qui: estadd ysumm
	qui: test `ivs'
	qui: estadd scalar shock_F = r(F)
	qui: est save results/rf_`i'_`filename_spec', replace
	* First stages
	
	local fst_ests ""
	local fst_mtitles ""
	foreach m of num 1/`num_endogs' {
		
		local m_endog : word `m' of `endogs'	
		di "`m'"
		di "`m_endog'"
*		xtreg `m_endog' `ivs' d.tot l1.netlend if `i' == 1, fe cluster(countryid)
		xtreg `m_endog' `ivs' d.tot l1.wb_wdi_primbal if `i' == 1, fe cluster(countryid)
		di "fst_`m_endog'_`i'"
		di "`ivs'"
		di "`results/fs_`m_endog'_`i'_`filename_spec'"
		 di "hi.25"
		 est store fst_eg`m'_`i'
		 di "hi.5"
		estadd ysumm
		di "hi1"
		qui: test `ivs'
		qui: estadd scalar shock_F = r(F)
		qui: est save results/fs_`m_endog'_`i'_`filename_spec', replace
		local fst_ests "`fst_ests' fst_eg`m'_`i'"
		di "hi2"
		local fst_mtitles `"`fst_mtitles' "FS (`m_endog')" "'
		di "hi3"
	}
	di "hi3.5"
	* IV
*	qui: xi: xtivreg2 netlend (`endogs' = `ivs') d.tot l1.netlend if `i' == 1, fe ffirst cluster(countryid)
	qui: xi: xtivreg2 wb_wdi_primbal (`endogs' = `ivs') d.tot l1.wb_wdi_primbal if `i' == 1, fe ffirst cluster(countryid)
	qui: est store iv_`i'
	qui: estadd ysumm
	qui: estadd scalar shock_F = `e(widstat)' : iv_`i'
	qui: est save results/iv_`i'_`filename_spec', replace
	di "hi4"
* group table
di "`i'"
di "`fst_ests'"
di "$rootdir/tables/rxn_fn/by_cat/cat_`i'_`filename_spec'.tex"
di `"`fst_mtitles'"'

esttab ols_`i' ///
		rf_`i' ///
		iv_`i' ///
		`fst_ests' ///
		using $rootdir/tables/rxn_fn/by_cat/cat_`i'_`filename_spec'.tex, replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle("OLS" "RF" "IV" `"`fst_mtitles'"') depvars
		
di "hi5"
}
di "ho"

local olsregs ""
local rfregs ""
local ivregs ""

foreach i of local cats {
	local olsregs "`olsregs' ols_`i'"
	local rfregs "`rfregs' rf_`i'"
	local ivregs "`ivregs' iv_`i'"
}

di "`olsregs'"
di "`rfregs'"
di "`ivregs'"
di "$rootdir/tables/rxn_fn/by_regtype/ols_`filename_spec'.tex"
di `"`cat_labels'"'

* Tables by regression type
esttab `olsregs' ///
		using "$rootdir/tables/rxn_fn/by_regtype/ols_`filename_spec'.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N, fmt(2 0) ///
		labels("Mean Y" "Observations")) mtitle(`"`cat_labels'"') depvars
esttab `rfregs' ///
		using "$rootdir/tables/rxn_fn/by_regtype/rf__`filename_spec'.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`cat_labels'"') depvars
esttab `ivregs' ///
		using "$rootdir/tables/rxn_fn/by_regtype/iv__`filename_spec'.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`cat_labels'"') depvars
		
eststo clear

}

// tables by group
di "adderyo"
foreach i of local cats {

	foreach n of num 1/`num_sets' {

	local endogs : word `n' of `endog_sets'
	local ivs : word `n' of `iv_sets'

	local filename_spec ENDS_`endogs'_IVS_`ivs'
	local filename_spec = subinstr("`filename_spec'","gRGDP","g",.)
	local filename_spec = subinstr("`filename_spec'","yrs_ago","",.)
	local filename_spec = subinstr("`filename_spec'","news","nws",.)
	local filename_spec = subinstr("`filename_spec'",".","",.)	
	local filename_spec = subinstr("`filename_spec'","shock_fct","shf",.)
	local filename_spec = subinstr("`filename_spec'","shock","sh",.)
	local filename_spec = subinstr("`filename_spec'"," ","",.)
	di "`filename_spec'"
	
	est use results/ols_`i'_`filename_spec'
	est store ols_`n'
	est use results/rf_`i'_`filename_spec'
	est store rf_`n'
	est use results/iv_`i'_`filename_spec'
	est store iv_`n'
	
	}
	
	local olsregs ""
	local rfregs ""
	local ivregs ""

	foreach n of num 1/`num_sets' {
		local olsregs "`olsregs' ols_`n'"
		local rfregs "`rfregs' rf_`n'"
		local ivregs "`ivregs' iv_`n'"
	}
	
	esttab `olsregs' ///
		using "$rootdir/tables/rxn_fn/by_group/ols_`i'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N, fmt(2 0) ///
		labels("Mean Y" "Observations")) mtitle(`cat_labels') depvars
	esttab `rfregs' ///
		using "$rootdir/tables/rxn_fn/by_group/rf_`i'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`window_labels'"') depvars
	esttab `ivregs' ///
		using "$rootdir/tables/rxn_fn/by_group/iv_`i'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`window_labels'"') depvars
		
	eststo clear
}
