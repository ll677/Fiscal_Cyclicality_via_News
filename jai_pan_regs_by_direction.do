clear all

use reg_data
merge 1:1 country year using shocks
drop _merge
qui include drop_vars.do
drop if year < 1990 | year > 2019

xtset countryid year

// define categories and select forecast variables

gen jai_pan_dev = jai_pan_midhi | jai_pan_midli | jai_pan_li
gen jai_pan_dev_mid = jai_pan_midhi | jai_pan_midli 
gen al_tab_noecd = 1 - al_tab_oecd

local cats "jai_pan_ind jai_pan_ind_ex_us jai_pan_dev jai_pan_dev_mid jai_pan_midhi jai_pan_midli jai_pan_li"
local cat_labels `" "Industrial" "Industrial (ex-US)" "Developing" "Dev., Mid.-Inc." "Dev., High-Mid."  "Dev., Low-Mid." "Low Income" "'
local window_labels `"  "fall, t-1" "fall, t-2" "spring t" "spring t-1"  "fall - fall" "spring - spring" "spring-fall" "fall-spring" "'

local windows f1 f2 s0 s1 f2f1 s1s0 s1f1 f2s1

// gen news vars

gen news_s1f1 = gRf1F - gRf1S
gen news_f2s1 = gRf1S - gRf2F 
gen news_f2f1 = gRf1F - gRf2F 
gen news_s1s0 = gRf0S - gRf1S
gen news_f1 = gRf1F
gen news_f2 = gRf2F
gen news_s0 = gRf0S
gen news_s1 = gRf1S


// winsorize

winsor2 netlend news_* gRGDP tot shock_*, replace c(1 99)

// Separate business cycle variables by direction

bys countryid : egen med_gRGDP = median(gRGDP)
gen hi_gRGDP = gRGDP * (gRGDP >= med_gRGDP)
gen lo_gRGDP = gRGDP * (gRGDP < med_gRGDP)
bys countryid : egen med_shock_t = median(shock_t)
gen hi_shock_t = shock_t * (shock_t >= med_shock_t)
gen lo_shock_t = shock_t * (shock_t < med_shock_t)

foreach w of local windows {

	bys countryid : egen med_news_`w' = median(news_`w')
	gen hi_news_`w' = news_`w' * (news_`w' >= med_news_`w')
	gen lo_news_`w' = news_`w' * (news_`w' < med_news_`w')
	
	bys countryid : egen med_shock_`w' = median(shock_`w')
	gen hi_shock_`w' = shock_`w' * (shock_`w' >= med_shock_`w')
	gen lo_shock_`w' = shock_`w' * (news_`w' < med_shock_`w')
	
	
}

foreach w of local windows {

foreach i of local cats {

di "`w'"
di "`i'"
	
	*local w f1
	*local i jai_pan_ind
	
	* OLS
	qui: xtreg netlend hi_news_`w' lo_news_`w' hi_gRGDP lo_gRGDP d.tot l1.netlend if `i' == 1, fe cluster(countryid)
	qui: est store ols_`i'
	qui: estadd ysumm
	qui: est save results/ols_bydir_`w'_`i', replace
	
	* Reduced form
	qui: xtreg netlend hi_news_`w' lo_news_`w' hi_gRGDP lo_gRGDP hi_shock_`w' lo_shock_`w' ///
	     hi_shock_t lo_shock_t d.tot l1.netlend if `i' == 1, fe cluster(countryid)
	qui: est store rf_`i'
	qui: estadd ysumm
	qui: test hi_shock_`w' lo_shock_`w' hi_shock_t lo_shock_t
	qui: estadd scalar shock_F = r(F)
	qui: est save results/rf_bydir_`w'_`i', replace
	
	* IV
	qui: xi: xtivreg2 netlend (hi_news_`w' lo_news_`w' hi_gRGDP lo_gRGDP = hi_shock_`w' ///
	         lo_shock_`w' hi_shock_t lo_shock_t) d.tot l1.netlend if `i' == 1, fe ffirst cluster(countryid)
	qui: est store iv_`i'
	qui: estadd ysumm
	qui: estadd scalar shock_F = `e(widstat)' : iv_`i'
	qui: est save results/iv_bydir_`w'_`i', replace
	
* group table
esttab ols_`i' ///
		rf_`i' ///
		iv_`i' ///
		using tables/by_cat/cat_bydir_`i'_`w'_regs.tex, replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle("OLS" "RF" "IV") depvars
		

}

di "hi"

local olsregs ""
local rfregs ""
local fstregs ""
local fstm1regs ""
local ivregs ""

foreach i of local cats {
	local olsregs "`olsregs' ols_`i'"
	local rfregs "`rfregs' rf_`i'"
	local ivregs "`ivregs' iv_`i'"
}


* Tables by regression type
esttab `olsregs' ///
		using "tables/by_regtype/ols_bydir_`w'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N, fmt(2 0) ///
		labels("Mean Y" "Observations")) mtitle(`"`cat_labels'"') depvars
esttab `rfregs' ///
		using "tables/by_regtype/rf_bydir_`w'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`cat_labels'"') depvars
esttab `ivregs' ///
		using "tables/by_regtype/iv_bydir_`w'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`cat_labels'"') depvars
		
eststo clear

}

// tables by group

foreach i of local cats {

	foreach w of local windows {
	
	est use results/ols_bydir_`w'_`i'
	est store ols_`w'
	est use results/rf_bydir_`w'_`i'
	est store rf_`w'
	est use results/iv_bydir_`w'_`i'
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
		local ivregs "`ivregs' iv_`w'"
	}
	
	esttab `olsregs' ///
		using "tables/by_group/ols_bydir_`i'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N, fmt(2 0) ///
		labels("Mean Y" "Observations")) mtitle(`cat_labels') depvars
	esttab `rfregs' ///
		using "tables/by_group/rf_bydir_`i'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`window_labels'"') depvars
	esttab `ivregs' ///
		using "tables/by_group/iv_bydir_`i'_regs.tex", replace booktabs b(3) se(3) ///
		star(* 0.10 ** 0.05 *** 0.01) nonotes stats(ymean N shock_F, fmt(2 0 3) ///
		labels("Mean Y" "Observations" "Exc. Inst. F-stat")) mtitle(`"`window_labels'"') depvars
		
	eststo clear
}
