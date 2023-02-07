// Do regressions for the research not tables

clear all

local outdir "tables/contemp"

use $rootdir/data/processed/reg_data
merge 1:1 country year using $rootdir/data/processed/shocks

drop _merge

qui include drop_vars.do

drop if year < 1988 | year > 2019

sysdir set PLUS ado
local inst_flag = 0


xtset countryid year

winsor2 netlend gRGDP tot shock_t, replace c(1 99)

gen jai_pan_dev = jai_pan_midhi | jai_pan_midli | jai_pan_li
gen jai_pan_dev_mid = jai_pan_midhi | jai_pan_midli 
gen al_tab_noecd = 1 - al_tab_oecd
gen rvk_oecd = al_tab_oecd & country != "Malta" & country != "Iceland" & country != "Luxembourg"

local cats "jai_pan_dev_mid jai_pan_midhi jai_pan_midli jai_pan_li rvk_oecd"
local cat_labels `" "Dev., Mid.-Inc." "Dev., High Mid-Inc." "Dev., Low Mid-Inc." "Dev., Low-Inc." "OECD" "'

foreach i of local cats {

di "`w'"
di "`i'"
	
	* OLS
	qui: xtreg netlend  gRGDP d.tot l1.netlend if `i' == 1, fe cluster(countryid)
	qui: est store ols_`i'
	qui: estadd ysumm
	qui: est save results/ols_contemp_`i', replace
	
	* Reduced form
	qui: xtreg netlend shock_t d.tot l1.netlend if `i' == 1, fe cluster(countryid)
	qui: est store rf_`i'
	qui: estadd ysumm
	qui: test shock_t
	qui: estadd scalar shock_F = r(F)
	qui: est save results/rf_contemp_`i', replace
	
	* First stage, gRGDP
	qui: xtreg gRGDP shock_t d.tot l1.netlend if `i' == 1, fe cluster(countryid)
	qui: est store fst_`i'
	qui: estadd ysumm
	qui: test shock_t
	qui: estadd scalar shock_F = r(F)
	qui: est save results/fs_grgdp_contemp_`i', replace

	* IV
	qui: xi: xtivreg2 netlend (gRGDP = shock_t) d.tot l1.netlend if `i' == 1, fe ffirst cluster(countryid)
	qui: est store iv_`i'
	qui: estadd ysumm
	qui: estadd scalar shock_F = `e(widstat)' : iv_`i'
	qui: est save results/iv_contemp_`i', replace
	
* group table
esttab ols_`i' ///
		rf_`i' ///
		fst_`i' ///
		iv_`i' ///
		using `outdir'/by_cat/cat_`i'_contemp_regs.tex, replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle("OLS" "RF" "FS (GDP)" "FS (news)") depvars
		

}


local olsregs ""
local rfregs ""
local fstregs ""
local ivregs ""

foreach i of local cats {
	local olsregs "`olsregs' ols_`i'"
	local rfregs "`rfregs' rf_`i'"
	local fstregs "`fstregs' fst_`i'"
	local ivregs "`ivregs' iv_`i'"
}


* Tables by regression type
esttab `olsregs' ///
		using "`outdir'/by_regtype/ols_contemp_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N, fmt(2 0) ///
		labels("Mean Y" "Observations")) mtitle(`"`cat_labels'"') depvars
esttab `rfregs' ///
		using "`outdir'/by_regtype/rf_contemp_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`cat_labels'"') depvars
esttab `fstregs' ///
		using "`outdir'/by_regtype/fst_contemp_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`cat_labels'"') depvars
esttab `ivregs' ///
		using "`outdir'/by_regtype/iv_contemp_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`cat_labels'"') depvars
		
eststo clear

