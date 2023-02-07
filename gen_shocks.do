// generate shock instrumental veriables for news and GDP growth regressors

clear all

//// generate pared down set of shock inputs

use $rootdir/data/processed/reg_data

xtset countryid year


gen other_ctry = country

keep other_ctry year fct_* gRGDP

qui include drop_vars.do

save $rootdir/data/processed/shock_inputs, replace

//// Generate shock dataset

clear all

use $rootdir/data/processed/EXIM if strlen(year) == 4

////// calculate export shares of gdp weights

gen ind = 1

replace ind = 0 if other_ctry == "World"

bysort country year (ind) : gen exp_tot = exp_fob[1]

drop ind

*gen exp_share = exp_fob / exp_tot if !mi
gen exp_share_t = exp_fob 
bysort country other_ctry (year) : gen exp_share_tm1 = exp_fob[_n-1]
bys country year: egen temp = total(exp_share_t)
replace exp_share_t = exp_share_t/temp // normalize to 1
drop temp
bys country year: egen temp = total(exp_share_tm1)
replace exp_share_tm1 = exp_share_tm1/temp // normalize to 1

////// generate shock weighted sums

destring year, replace
merge m:1 other_ctry year using $rootdir/data/processed/shock_inputs
drop if _merge ~= 3
drop _merge

merge m:1 country year using $rootdir/data/processed/reg_data, keepusing(exp_pcgdp)
drop if _merge ~= 3
drop _merge
 
bysort country year : egen shock_t = total(exp_share_t * gRGDP)
bysort country year : egen shock_f2t = total(exp_share_tm1 * news_f2t)
bysort country year : egen shock_s1t = total(exp_share_tm1 * news_s1t)
bysort country year : egen shock_f1t = total(exp_share_tm1 * news_f1t)
bysort country year : egen shock_s0t = total(exp_share_tm1 * news_s0t)
bysort country year : egen shock_s1f1 = total(exp_share_tm1 * news_s1f1)
bysort country year : egen shock_f2s1 = total(exp_share_tm1 * news_f2s1)
bysort country year : egen shock_f2f1 = total(exp_share_tm1 * news_f2f1)
bysort country year : egen shock_s1s0 = total(exp_share_tm1 * news_s1s0)
bysort country year : egen shock_f1 = total(exp_share_tm1 * news_f1)
bysort country year : egen shock_f2 = total(exp_share_tm1 * news_f2)
bysort country year : egen shock_s1 = total(exp_share_tm1 * news_s0)
bysort country year : egen shock_s0 = total(exp_share_tm1 * news_s1)

////// drop duplicate rows and gen indicator for incomplete export data over the period

*keep country year shock_t shock_s1f1 shock_f2s1 shock_f2f1 shock_s1s0 exp_pcgdp
keep country year shock_* exp_pcgdp
bysort country year:  gen dup = cond(_N==1,0,_n)

drop if dup > 1
drop dup

gen exp_empty = 0
replace exp_empty = 1 if exp_pcgdp == .

by country : egen avg_exp = mean(exp_pcgdp)
by country : egen emp_sum = total(exp_empty)
la var emp_sum "# of empty export data rows"

gen unfull_flag = 0
replace unfull_flag = 1 if emp_sum > 0 
la var unfull_flag "has empty export data rows"

////// save shocks

egen countryid = group(country)
sort countryid year
xtset countryid year

replace shock_t = avg_exp * shock_t
replace shock_f2t = l.avg_exp * shock_f2t
replace shock_s1t = l.avg_exp * shock_s1t
replace shock_f1t = l.avg_exp * shock_f1t
replace shock_s0t = l.avg_exp * shock_s0t
replace shock_s1f1 = l.avg_exp * shock_s1f1 
replace shock_f2s1 = l.avg_exp * shock_f2s1 
replace shock_f2f1 = l.avg_exp * shock_f2f1 
replace shock_s1s0 = l.avg_exp * shock_s1s0 
replace shock_f1 = l.avg_exp * shock_f1 
replace shock_f2 = l.avg_exp * shock_f2
replace shock_s0 = l.avg_exp * shock_s0
replace shock_s1 = l.avg_exp * shock_s1 

drop countryid

save $rootdir/data/processed/shocks, replace 
