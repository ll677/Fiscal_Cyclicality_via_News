// Do regressions for the research not tables

clear all

use reg_data
merge 1:1 country year using shocks

drop _merge

qui include drop_vars.do

drop if year < 1990 | year > 2019

sysdir set PLUS ado
local inst_flag = 0


xtset countryid year

// gen news vars

gen news_s1f1 = gRf1F - gRf1S
gen news_f2s1 = gRf1S - gRf2F 
gen news_f2f1 = gRf1F - gRf2F 
gen news_s1s0 = gRf0S - gRf1S
gen news_f1 = gRf1F
gen news_f2 = gRf2F
gen news_s0 = gRf0S
gen news_s1 = gRf1S

winsor2 netlend news_* gRGDP tot shock_*, replace c(1 99)

gen jai_pan_dev = jai_pan_midhi | jai_pan_midli | jai_pan_li
gen jai_pan_dev_mid = jai_pan_midhi | jai_pan_midli 
gen al_tab_noecd = 1 - al_tab_oecd
gen rvk_oecd = al_tab_oecd & country != "Malta" & country != "Iceland" & country != "Luxembourg"

local cats "jai_pan_dev_mid jai_pan_midhi jai_pan_midli jai_pan_li rvk_oecd"
local cat_labels `" "Dev., Mid.-Inc." "Dev., High Mid-Inc." "Dev., Low Mid-Inc." "Dev., Low-Inc." "OECD" "'
local window_labels `"  "fall, t-1" "fall, t-2" "spring t" "spring t-1"  "fall - fall" "spring - spring" "spring-fall" "fall-spring" "'

local windows f1 f2 s0 s1 f2f1 s1s0 s1f1 f2s1

foreach w of local windows {

foreach i of local cats {

di "`w'"
di "`i'"
	
	* OLS
	qui: xtreg netlend news_`w' gRGDP d.tot l1.netlend if `i' == 1, fe cluster(countryid)
	qui: est store ols_`i'
	qui: estadd ysumm
	qui: est save results/ols_`w'_`i', replace
	
	* Reduced form
	qui: xtreg netlend shock_`w' shock_t d.tot l1.netlend if `i' == 1, fe cluster(countryid)
	qui: est store rf_`i'
	qui: estadd ysumm
	qui: test shock_`w' shock_t
	qui: estadd scalar shock_F = r(F)
	qui: est save results/rf_`w'_`i', replace
	
	* First stage, gRGDP
	qui: xtreg gRGDP shock_`w' shock_t d.tot l1.netlend if `i' == 1, fe cluster(countryid)
	qui: est store fst_`i'
	qui: estadd ysumm
	qui: test shock_`w' shock_t
	qui: estadd scalar shock_F = r(F)
	qui: est save results/fs_grgdp_`w'_`i', replace

	* First stage, news
	qui: xtreg news_`w' shock_`w' shock_t d.tot l1.netlend if `i' == 1, fe cluster(countryid)
	qui: est store fstm1_`i'
	qui: estadd ysumm
	qui: test shock_`w' shock_t
	qui: estadd scalar shock_F = r(F)
	qui: est save results/fs_news_`w'_`i', replace

	* IV
	qui: xi: xtivreg2 netlend (news_`w' gRGDP = shock_`w' shock_t) d.tot l1.netlend if `i' == 1, fe ffirst cluster(countryid)
	qui: est store iv_`i'
	qui: estadd ysumm
	qui: estadd scalar shock_F = `e(widstat)' : iv_`i'
	qui: est save results/iv_`w'_`i', replace
	
* group table
esttab ols_`i' ///
		rf_`i' ///
		fst_`i' ///
		fstm1_`i' ///
		iv_`i' ///
		using tables/by_cat/cat_`i'_`w'_regs.tex, replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle("OLS" "RF" "FS (GDP)" "FS (news)") depvars
		

}


local olsregs ""
local rfregs ""
local fstregs ""
local fstm1regs ""
local ivregs ""

foreach i of local cats {
	local olsregs "`olsregs' ols_`i'"
	local rfregs "`rfregs' rf_`i'"
	local fstregs "`fstregs' fst_`i'"
	local fstm1regs "`fstm1regs' fstm1_`i'"
	local ivregs "`ivregs' iv_`i'"
}


* Tables by regression type
esttab `olsregs' ///
		using "tables/by_regtype/ols_`w'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N, fmt(2 0) ///
		labels("Mean Y" "Observations")) mtitle(`"`cat_labels'"') depvars
esttab `rfregs' ///
		using "tables/by_regtype/rf_`w'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`cat_labels'"') depvars
esttab `fstregs' ///
		using "tables/by_regtype/fst_`w'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`cat_labels'"') depvars
esttab `fstm1regs' ///
		using "tables/by_regtype/fstm1_`w'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`cat_labels'"') depvars
esttab `ivregs' ///
		using "tables/by_regtype/iv_`w'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`cat_labels'"') depvars
		
eststo clear

}

// tables by group

foreach i of local cats {

	foreach w of local windows {
	
	est use results/ols_`w'_`i'
	est store ols_`w'
	est use results/rf_`w'_`i'
	est store rf_`w'
	est use results/fs_grgdp_`w'_`i'
	est store fst_`w'
	est use results/fs_news_`w'_`i'
	est store fstm1_`w'
	est use results/iv_`w'_`i'
	est store iv_`w'
	
	}
	
	local olsregs ""
	local rfregs ""
	local fstregs ""
	local fstm1regs ""
	local ivregs ""

	foreach w of local windows {
		local olsregs "`olsregs' ols_`w'"
		local rfregs "`rfregs' rf_`w'"
		local fstregs "`fstregs' fst_`w'"
		local fstm1regs "`fstm1regs' fstm1_`w'"
		local ivregs "`ivregs' iv_`w'"
	}
	
	esttab `olsregs' ///
		using "tables/by_group/ols_`i'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N, fmt(2 0) ///
		labels("Mean Y" "Observations")) mtitle(`cat_labels') depvars
	esttab `rfregs' ///
		using "tables/by_group/rf_`i'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`window_labels'"') depvars
	esttab `fstregs' ///
		using "tables/by_group/fst_`i'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`window_labels'"') depvars
	esttab `fstm1regs' ///
		using "tables/by_group/fstm1_`i'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`window_labels'"') depvars
	esttab `ivregs' ///
		using "tables/by_group/iv_`i'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`window_labels'"') depvars
		
	eststo clear
}
