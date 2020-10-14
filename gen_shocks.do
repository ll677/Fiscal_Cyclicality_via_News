// generate shock instrumental veriables for news and GDP growth regressors

clear all

//// generate pared down set of shock inputs

use reg_data

xtset countryid year

gen news_s1f1 = l1.gRf1F - l1.gRf1S
gen news_f2s1 = l1.gRf1S - l2.gRf1F
gen news_f2f1 = l1.gRf1F - l2.gRf1F
gen news_s1s0 = gRf0S - l1.gRf1S

gen other_ctry = country

keep other_ctry year news_s1f1 news_f2s1 news_f2f1 news_s1s0 gRGDP

qui include drop_vars.do

save shock_inputs, replace

//// Generate shock dataset

clear all

use EXIM

////// calculate export shares of gdp weights

gen ind = 1

replace ind = 0 if other_ctry == "World"

bysort country year (ind) : gen exp_tot = exp_fob[1]

drop ind

gen exp_share = exp_fob / exp_tot
bysort country other_ctry (year) : gen l_exp_share = exp_share[_n-1]

////// generate shock weighted sums

merge m:1 other_ctry year using shock_inputs
drop if _merge ~= 3
drop _merge

merge m:1 country year using reg_data, keepusing(exp_pcgdp)
drop if _merge ~= 3
drop _merge
 
bysort country year : egen shock_t = sum(exp_share * gRGDP)
bysort country year : egen shock_s1f1 = sum(l_exp_share * news_s1f1)
bysort country year : egen shock_f2s1 = sum(l_exp_share * news_f2s1)
bysort country year : egen shock_f2f1 = sum(l_exp_share * news_f2f1)
bysort country year : egen shock_s1s0 = sum(l_exp_share * news_s1s0)

////// drop duplicate rows and gen indicator for incomplete export data over the period

keep country year shock_t shock_s1f1 shock_f2s1 shock_f2f1 shock_s1s0 exp_pcgdp
bysort country year:  gen dup = cond(_N==1,0,_n)

drop if dup > 1
drop dup

gen exp_empty = 0
replace exp_empty = 1 if exp_pcgdp == .

by country : egen avg_exp = mean(exp_pcgdp)
by country : egen emp_sum = sum(exp_empty)
la var emp_sum "# of empty export data rows"

gen unfull_flag = 0
replace unfull_flag = 1 if emp_sum > 0 
la var unfull_flag "has empty export data rows"

////// save shocks

replace shock_t = avg_exp * shock_t
replace shock_s1f1 = avg_exp * shock_s1f1 
replace shock_f2s1 = avg_exp * shock_f2s1 
replace shock_f2f1 = avg_exp * shock_f2f1 
replace shock_s1s0 = avg_exp * shock_s1s0 

save shocks, replace 
