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

gen news_s1f1 = l1.gRf1F - l1.gRf1S
gen news_f2s1 = l1.gRf1S - l2.gRf1F
gen news_f2f1 = l1.gRf1F - l2.gRf1F
la var news_f2f1 "Oct-Oct GDP News Shock (%)"
gen news_s1s0 = gRf0S - l1.gRf1S
la var news_s1s0 "Apr-Apr GDP News Shock (%)"
gen news_f1 = l1.gRf1F
gen news_f2 = l2.gRf1F
gen news_s0 = gRf0S
gen news_s1 = l1.gRf1S

gen al_tab_noecd = 1 - al_tab_oecd
gen jai_pan_dev_mid = jai_pan_midhi | jai_pan_midli 
gen all_used = jai_pan_ind | jai_pan_dev_mid
gen cat_all = 1

*local cats "jai_pan_ind jai_pan_ind_ex_us all_used jai_pan_dev_mid cat_all"
local cats all_used

// Label variables
la var netlend "Net Lending (% GDP)"
la var tot "Terms of Trade (%)"
la var gRGDP "GDP growth (%)"
la var shock_t "Export Shock (%)"
la var shock_f2f1 "Oct-Oct Export News Shock (%)"
la var shock_s1s0 "Apr-Apr Export News Shock (%)"

local summ_vars netlend gRGDP tot news_f2f1 news_s1s0 shock_t shock_f2f1 shock_s1s0

foreach c of local cats {
	
	cap mat drop summ_tbl
	
foreach v of local summ_vars {
	
	tabstat `v', s(mean sd min p1 p5 p10 q p90 p95 p99 max) save
	mat summ_tbl = nullmat(summ_tbl)\r(StatTotal)'
	

}

}
