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
local outdir $rootdir/tables/main/rxn_fn

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


local cats "rvk_oecd rvk_oecd_ex_big jai_pan_dev_mid jai_pan_li"
local cat_labels `" "OECD" "OECD, Smaller Exporters" "Dev., Mid.-Inc." "Dev., Low-Inc.""'

*local cats "rvk_oecd rvk_oecd_ex_us rvk_dev_mid rvk_midhi rvk_midli rvk_li"
*local cat_labels `" "OECD" "OECD, ex-US" "Dev., Mid.-Inc." "Dev., High Mid-Inc." "Dev., Low Mid-Inc." "Dev., Low-Inc.""'
 
local endog_sets `" "gRGDP" "gRGDP news_1yrs_ago" "gRGDP news_diff_1yrs_ago" "gRGDP news_1yrs_ago news_2yrs_ago" "gRGDP news_diff_1yrs_ago news_diff_2yrs_ago" "gRGDP f_news_1yrs_ago" "gRGDP f_news_diff_1yrs_ago" "gRGDP f_news_1yrs_ago f2_news_2yrs_ago" "gRGDP f_news_diff_1yrs_ago f2_news_diff_2yrs_ago" "'

local iv_sets `" "shock_t" "shock_t shock_fct1" "shock_t d_shock_fct1" "shock_t shock_fct1 shock_fct2" "shock_t d_shock_fct1 d_shock_fct2" "shock_t f_shock_fct1" "shock_t f_d_shock_fct1" "shock_t f_shock_fct1 f2_shock_fct2" "shock_t f_d_shock_fct1 f2_d_shock_fct2" "'

local struct_order_str "gRGDP news_1yrs_ago news_2yrs_ago news_diff_1yrs_ago news_diff_2yrs_ago f_news_1yrs_ago f2_news_2yrs_ago f_news_diff_1yrs_ago f2_news_diff_2yrs_ago pctd_tot l_wb_wdi_debt l_`depvar'"

local fs_order_str "shock_t shock_fct1 shock_fct2 d_shock_fct1 d_shock_fct2 f_shock_fct1 f2_shock_fct2 f_d_shock_fct1 f2_d_shock_fct2 pctd_tot l_wb_wdi_debt l_`depvar'"


gen l_`depvar' = l.`depvar'
gen l_wb_wdi_debt = l.wb_wdi_debt
gen pctd_tot = 100*d.tot/l.tot
gen f_news_1yrs_ago = f.news_1yrs_ago 
gen f2_news_2yrs_ago = f2.news_2yrs_ago 
gen f_news_diff_1yrs_ago = f.news_diff_1yrs_ago 
gen f2_news_diff_2yrs_ago = f2.news_diff_2yrs_ago
gen f_shock_fct1 = f.shock_fct1
gen f2_shock_fct2 = f2.shock_fct2
gen f_d_shock_fct1 = f.d_shock_fct1
gen f2_d_shock_fct2 = f2.d_shock_fct2

gen f_news_S1yrs_ago = f.news_S1yrs_ago
gen f2_news_F2yrs_ago = f2.news_F2yrs_ago
gen f_shock_fctS1 = f.shock_fctS1
gen f2_shock_fctF2 = f2.shock_fctF2

la var l_`depvar' "Lagged primary balance (\% GDP)"
la var pctd_tot "\% Change in terms-of-trade index"
la var l_wb_wdi_debt "Lagged government debt (\% GDP)"

la var gRGDP "Real YoY GDP Growth (\%)"
la var news_1yrs_ago "\$ News_{i,t-1}(t)\$ (\%)"
la var news_2yrs_ago "\$ News_{i,t-2}(t)\$ (\%)"
la var news_diff_1yrs_ago "\$ \Delta News_{i,t-1}(t)\$ (\%)"
la var news_diff_2yrs_ago "\$ \Delta News_{i,t-2}(t)\$ (\%)"
la var news_S1yrs_ago "\$ News^s_{i,t-1}(t)\$ (\%)"
la var news_S2yrs_ago "\$ News^s_{i,t-2}(t)\$ (\%)"
la var news_diff_S1yrs_ago "\$ \Delta News^s_{i,t-1}(t)\$ (\%)"
la var news_diff_S2yrs_ago "\$ \Delta News^s_{i,t-2}(t)\$ (\%)"
la var news_F1yrs_ago "\$ News^f_{i,t-1}(t)\$ (\%)"
la var news_F2yrs_ago "\$ News^f_{i,t-2}(t)\$ (\%)"
la var news_diff_F1yrs_ago "\$ \Delta News^f_{i,t-1}(t)\$ (\%)"
la var news_diff_F2yrs_ago "\$ \Delta News^f_{i,t-2}(t)\$ (\%)"
la var f_news_1yrs_ago "\$ News_{i,t}(t+1)\$ (\%)"
la var f2_news_2yrs_ago "\$ News_{i,t}(t+2)\$ (\%)"
la var f_news_diff_1yrs_ago "\$ \Delta News_{i,t}(t+1)\$ (\%)"
la var f2_news_diff_2yrs_ago "\$ \Delta News_{i,t}(t+2)\$ (\%)"

la var shock_t "\$ Shock_{i,t}\$ (\%)"
la var shock_fct1 "\$ FctShock_{i,t-1}(t)\$ (\%)"
la var shock_fct2 "\$ FctShock_{i,t-2}(t)\$ (\%)"
la var d_shock_fct1 "\$ \Delta FctShock_{i,t-1}(t)\$ (\%)"
la var d_shock_fct2 "\$ \Delta FctShock_{i,t-2}(t)\$ (\%)"
la var shock_fctS1 "\$ FctShock^s_{i,t-1}(t)\$ (\%)"
la var shock_fctS2 "\$ FctShock^s_{i,t-2}(t)\$ (\%)"
la var d_shock_fctS1 "\$ \Delta FctShock^s_{i,t-1}(t)\$ (\%)"
la var d_shock_fctS2 "\$ \Delta FctShock^s_{i,t-2}(t)\$ (\%)"
la var shock_fctF1 "\$ FctShock^f_{i,t-1}(t)\$ (\%)"
la var shock_fctF2 "\$ FctShock^f_{i,t-2}(t)\$ (\%)"
la var d_shock_fctF1 "\$ \Delta FctShock^f_{i,t-1}(t)\$ (\%)"
la var d_shock_fctF2 "\$ \Delta FctShock^f_{i,t-2}(t)\$ (\%)"
la var f_shock_fct1 "\$ FctShock_{i,t}(t+1)\$ (\%)"
la var f2_shock_fct2 "\$ FctShock_{i,t}(t+2)\$ (\%)"
la var f_d_shock_fct1 "\$ \Delta FctShock_{i,t}(t+1)\$ (\%)"
la var f2_d_shock_fct2 "\$ \Delta FctShock_{i,t}(t+2)\$ (\%)"


local num_sets : word count `endog_sets'

gen l_billrate = l.imf_ifs_billrate
gen l_bondrate = l.imf_ifs_bondrate

winsor2 *`depvar' *news_* gRGDP *tot *shock_* l_wb_wdi_debt l_*rate if time_in_sample, replace c(1 99)


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
	qui: xtreg `depvar' `endogs' pctd_tot l_wb_wdi_debt l_`depvar' if `i' & time_in_sample, fe cluster(countryid)
	qui: est store ols_`i'
	qui: estadd ysumm
	qui: est save results/ols_`i'_`filename_spec', replace
	* Reduced form
	qui: xtreg `depvar' `ivs' pctd_tot l_wb_wdi_debt l_`depvar' if `i' & time_in_sample, fe cluster(countryid)
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
		qui: xtreg `m_endog' `ivs' pctd_tot l_wb_wdi_debt l_`depvar' if `i' & time_in_sample, fe cluster(countryid)
	    qui: est store fst_eg`m'_`i'
		qui: estadd ysumm
		qui: test `ivs'
		qui: estadd scalar shock_F = r(F)
		qui: est save results/fs_`m_endog'_`i'_`filename_spec', replace
		local fst_ests "`fst_ests' fst_eg`m'_`i'"
		local fst_mtitles `"`fst_mtitles' "FS (`m_endog')" "'
	}
	* IV
	qui: xi: xtivreg2 `depvar' (`endogs' = `ivs') pctd_tot l_wb_wdi_debt l_`depvar' if `i' & time_in_sample, fe ffirst cluster(countryid)
	qui: est store iv_`i'
	qui: estadd ysumm
	qui: estadd scalar shock_F = `e(widstat)' : iv_`i'
	qui: est save results/iv_`i'_`filename_spec', replace
* group table

esttab ols_`i' ///
		rf_`i' ///
		iv_`i' ///
		`fst_ests' ///
		using `outdir'/by_cat/cat_`i'_`filename_spec'.tex, replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle("OLS" "RF" "IV" `"`fst_mtitles'"') label substitute(\_ _)
		
}

local olsregs ""
local rfregs ""
local ivregs ""

foreach i of local cats {
	local olsregs "`olsregs' ols_`i'"
	local rfregs "`rfregs' rf_`i'"
	local ivregs "`ivregs' iv_`i'"
}

* Tables by regression type
esttab `olsregs' ///
		using "`outdir'/by_regtype/ols_`filename_spec'.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N, fmt(2 0) ///
		labels("Mean Y" "Observations")) mtitle(`"`cat_labels'"') depvars order(`struct_order_str') label substitute(\_ _)
esttab `rfregs' ///
		using "`outdir'/by_regtype/rf__`filename_spec'.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`cat_labels'"') depvars order(`struct_order_str') label substitute(\_ _)
esttab `ivregs' ///
		using "`outdir'/by_regtype/iv__`filename_spec'.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`cat_labels'"') depvars order(`struct_order_str') label substitute(\_ _)
		
eststo clear

}
// tables by group
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
		using "`outdir'/by_group/ols_`i'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N, fmt(2 0) ///
		labels("Mean Y" "Observations")) order(`struct_order_str') label substitute(\_ _) depvars
	esttab `rfregs' ///
		using "`outdir'/by_group/rf_`i'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) order(`struct_order_str') label substitute(\_ _) depvars
	esttab `ivregs' ///
		using "`outdir'/by_group/iv_`i'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) order(`struct_order_str') label substitute(\_ _) depvars
	eststo clear 
}
