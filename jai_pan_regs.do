// Do regressions for the research not tables

clear all

use reg_data
merge 1:1 country year using shocks

drop _merge

qui include drop_vars.do

drop if year < 1990 | year > 2019

sysdir set PLUS ado
local inst_flag = 0

if `inst_flag' == 1 {

	ssc install ivreg2
	ssc install ranktest
	ssc install estout

	}

xtset countryid year

// gen news vars

gen news_s1f1 = l1.gRf1F - l1.gRf1S
gen news_f2s1 = l1.gRf1S - l2.gRf1F
gen news_f2f1 = l1.gRf1F - l2.gRf1F
gen news_s1s0 = gRf0S - l1.gRf1S

gen jai_pan_dev = jai_pan_midhi + jai_pan_midli + jai_pan_li
gen jai_pan_dev_mid = jai_pan_midhi + jai_pan_midli 
gen al_tab_noecd = 1 - al_tab_oecd

local cats "jai_pan_ind jai_pan_dev jai_pan_dev_mid jai_pan_midhi jai_pan_midli jai_pan_li"

// fall window regressions

foreach i in `cats' {

	qui: xtivreg2 netlend d.tot l1.netlend (news_f2f1 gRGDP = shock_f2f1 shock_t) if `i' == 1, fe ffirst cluster(countryid)
	
	mat ests = e(first)
	eststo, title(`i') addscalars(f_news ests[4,1] f_gRGDP ests[4,2])

}

esttab, mtitle scalars(f_news f_gRGDP N) se 
esttab, mtitle scalars(f_news f_gRGDP N)
eststo clear

// spring window regressions

foreach i in `cats' {

	qui: xtivreg2 netlend d.tot l1.netlend (news_s1s0 gRGDP = shock_s1s0 shock_t) if `i' == 1, fe ffirst cluster(countryid)
	
	mat ests = e(first)
	eststo, title(`i') addscalars(f_news ests[4,1] f_gRGDP ests[4,2])

}

esttab, mtitle scalars(f_news f_gRGDP N) se
esttab, mtitle scalars(f_news f_gRGDP N) 

eststo clear
