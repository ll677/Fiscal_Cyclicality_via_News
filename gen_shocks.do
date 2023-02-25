// generate shock instrumental veriables for news and GDP growth regressors

clear all

//// generate pared down set of shock inputs

use $rootdir/data/processed/reg_data
tempfile using
keep country year exp_pcgdp
ren exp_pcgdp exp_pcgdp_home
gen temp = exp_pcgdp_home if year >= 1988 & year <= 2019
bys country : egen avg_exp = mean(temp)
drop temp
save `using', replace

use $rootdir/data/processed/reg_data, clear

gen other_ctry = country
keep other_ctry year fct* gRGDP
save $rootdir/data/processed/shock_inputs, replace

//// Generate shock dataset

clear all

use $rootdir/data/processed/EXIM if strlen(year) == 4


////// generate shocks

destring year, replace
merge m:1 other_ctry year using $rootdir/data/processed/shock_inputs
drop if _merge ~= 3
drop _merge

merge m:1 country year using `using', keep(3) nogen

sort country other_ctry year
egen ctry_pair = group(other_ctry country)
xtset ctry_pair year

local minhz = 0
local maxhz = 5
//// Average shock levels and diffs

bys country year: egen total_wgt = total(exp_fob*(!missing(gRGDP)))
bys country year: egen shock_t = total(avg_exp*exp_fob*gRGDP/total_wgt/100)
drop total_wgt

foreach hz of num `minhz'/`maxhz' {
	sort ctry_pair year
	
	* Level shock
	gen l`hz'_exp_fob = l`hz'.exp_fob
	gen temp = (fctF`hz'yrs_ago + fctS`hz'yrs_ago)/2
	bys country year: egen total_wgt = total(l`hz'_exp_fob*(!missing(temp)))
	bys country year: egen shock_fct`hz' = total(temp*l`hz'_exp_fob*avg_exp/total_wgt/100)
	replace shock_fct`hz' = . if total_wgt == 0 | missing(avg_exp)
	drop temp total_wgt
	
	* S->F intrayear shock
	gen temp = fctF`hz'yrs_ago - fctS`hz'yrs_ago
	bys country year: egen total_wgt = total(l`hz'_exp_fob*(!missing(temp)))
	bys country year: egen d_shock_fctS2F`hz' = total(temp*l`hz'_exp_fob*avg_exp/total_wgt/100)
	replace d_shock_fctS2F`hz' = . if total_wgt == 0 | missing(avg_exp)
	drop total_wgt temp
	
	if `hz' < `maxhz' {
	
	* Difference shock
		local hzp1 = `hz' + 1
		di "hi"
		gen temp = (fctF`hz'yrs_ago + fctS`hz'yrs_ago - fctF`hzp1'yrs_ago- fctS`hzp1'yrs_ago)/2
		bys country year: egen total_wgt = total(l`hz'_exp_fob*(!missing(temp)))
		bys country year: egen d_shock_fct`hz' = total(temp*l`hz'_exp_fob*avg_exp/total_wgt/100)
		replace d_shock_fct`hz' = . if total_wgt == 0 | missing(avg_exp)
		drop temp total_wgt
		
	* F->S interyear shock
		gen temp = fctS`hz'yrs_ago - fctF`hzp1'yrs_ago
		bys country year: egen total_wgt = total(l`hz'_exp_fob*(!missing(temp)))
		bys country year: egen d_shock_fctF2S`hz' = total(temp*l`hz'_exp_fob*avg_exp/total_wgt/100)
		replace d_shock_fctF2S`hz' = . if total_wgt == 0 | missing(avg_exp)
		drop temp total_wgt
		
	}
	
}

//// Average shock levels and diffs by season

foreach szn in S F {
foreach hz of num `minhz'/`maxhz' {
	bys country year: egen total_wgt = total(l`hz'_exp_fob*(!missing(fct`szn'`hz'yrs_ago)))
	bys country year: egen shock_fct`szn'`hz' = total(fct`szn'`hz'yrs_ago*l`hz'_exp_fob*avg_exp/total_wgt/100)
	replace shock_fct`szn'`hz' = . if total_wgt == 0 | missing(avg_exp)
	
	if `hz' < `maxhz' {
	local hzp1 = `hz' + 1
	gen temp = (fct`szn'`hz'yrs_ago - fct`szn'`hzp1'yrs_ago)
	bys country year: egen d_shock_fct`szn'`hz' = total(temp*l`hz'_exp_fob*avg_exp/total_wgt/100)
	replace d_shock_fct`szn'`hz' = . if total_wgt == 0 | missing(avg_exp)
	drop temp
	}
	drop total_wgt
}
}

////// save shocks

keep country year *shock*
duplicates drop
sort country year

save $rootdir/data/processed/shocks, replace 
