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
*la var news_f2f1 "Oct.-Oct. change in forecasted output growth"
la var news_f2f1 "\\splitcell{Oct.-Oct. change in output}{growth forecast}"
gen news_s1s0 = gRf0S - gRf1S
*la var news_s1s0 "Apr.-Apr. change in forecasted output growth"
la var news_s1s0 "\\splitcell{Apr.-Apr. change in output}{growth forecast}"

gen news_f1 = gRf1F
*la var news_f1 "Oct. output growth forecast, 1 year prior"
la var news_f1 "\\splitcell{Oct. output growth forecast,}{1 year prior (\\%)}"
gen news_f2 = gRf2F
*la var news_f2 "Oct. output growth forecast, 2 years prior"
la var news_f2 "\\splitcell{Oct. output growth forecast,}{2 years prior (\\%)}"
gen news_s0 = gRf0S
*la var news_s0 "Apr. output growth forecast, same year"
la var news_s0 "\\splitcell{Apr. output growth forecast,}{same year (\\%)}"
gen news_s1 = gRf1S
*la var news_s1 "Apr. output growth forecast, 1 year prior"
la var news_s1 "\\splitcell{Apr. output growth forecast,}{1 year prior (\\%)}"

gen jai_pan_dev = jai_pan_midhi | jai_pan_midli | jai_pan_li
gen jai_pan_dev_mid = jai_pan_midhi | jai_pan_midli 
gen al_tab_noecd = 1 - al_tab_oecd
gen rvk_oecd = al_tab_oecd & country != "Malta" & country != "Iceland" & country != "Luxembourg"
gen all_used = rvk_oecd | jai_pan_dev

*local cats "jai_pan_ind jai_pan_ind_ex_us all_used jai_pan_dev_mid cat_all"
local cats rvk_oecd jai_pan_midhi jai_pan_midli jai_pan_li all_used

// Label variables
la var netlend "Net Lending (\\% GDP)"
la var tot "Terms of Trade (\\%)"
la var gRGDP "GDP growth (\\%)"
la var shock_t "Export Shock (\\%)"
*la var shock_f2f1 "Oct-Oct Export Forecast Shock (\\%)"
*la var shock_s1s0 "Apr-Apr Export Forecast Shock (\\%)"
*la var shock_f1 "Oct. Export Forecast Shock, 1 year prior"
*la var shock_f2 "Oct. Export Forecast Shock, 2 years prior"
*la var shock_s0 "Apr. Export Forecast Shock, same year"
*la var shock_s1 "Apr. Export Forecast Shock, 1 year prior"
la var shock_f2f1 "\\splitcell{Oct.-Oct. Export Forecast}{Shock (\\%)}"
la var shock_s1s0 "\\splitcell{Apr.-Apr. Export Forecast}{Shock (\\%)}"
la var shock_f1 "\\splitcell{Oct. Export Forecast Shock,}{1 year prior (\\%)}"
la var shock_f2 "\\splitcell{Oct. Export Forecast Shock,}{2 years prior (\\%)}"
la var shock_s0 "\\splitcell{Apr. Export Forecast Shock,}{same year (\\%)}"
la var shock_s1 "\\splitcell{Apr. Export Forecast Shock,}{1 year prior (\\%)}"

local summ_vars netlend gRGDP tot news_s0 news_s1 news_f1 news_f2 news_s1s0 news_f2f1 shock_t shock_s0 shock_s1 shock_f1 shock_f2 shock_s1s0 shock_f2f1

foreach c of local cats {
	
	cap mat drop summ_tbl
	
foreach v of local summ_vars {
	
	tabstat `v' if `c' == 1, s(mean sd n p1 q p99 ) save
	mat summ_tbl = nullmat(summ_tbl)\r(StatTotal)'

}

outtable using tables/summ_stats_`c', mat(summ_tbl) replace f(%9.2f %9.2f %9.0f %9.2f %9.2f %9.2f %9.2f %9.2f) label


}

