use $rootdir/data/processed/EXIM if strlen(year) == 4, clear
destring year, replace
/*
ren country origin_country
ren other_ctry country
merge m:1 country using $rootdir/data/match_groups, nogen
gen jai_pan_dev = jai_pan_midhi | jai_pan_midli | jai_pan_li
gen jai_pan_dev_mid = jai_pan_midhi | jai_pan_midli 
gen al_tab_noecd = 1 - al_tab_oecd
gen rvk_oecd = al_tab_oecd & country != "Malta" & country != "Iceland" & country != "Luxembourg"
gen rvk_oecd_ex_us = rvk_oecd & country != "United States"
gen rvk_dev_mid = rvk_midhi | rvk_midli

gen in_sample = rvk_oecd | jai_pan_dev

keep if in_sample

keep origin_country year exp_fob
ren origin_country country
*/
merge m:1 country using $rootdir/data/match_groups, nogen

gen jai_pan_dev = jai_pan_midhi | jai_pan_midli | jai_pan_li
gen jai_pan_dev_mid = jai_pan_midhi | jai_pan_midli 
gen al_tab_noecd = 1 - al_tab_oecd
gen rvk_oecd = al_tab_oecd & country != "Malta" & country != "Iceland" & country != "Luxembourg"
gen rvk_oecd_ex_us = rvk_oecd & country != "United States"
gen rvk_dev_mid = rvk_midhi | rvk_midli
gen in_sample = rvk_oecd | jai_pan_dev
keep if in_sample
keep if year >= 1990 & year <= 2019

preserve
tempfile exps
collapse (sum) exp_fob, by(country year)
save `exps', replace
bys year: egen total_exp = total(exp_fob)
gen exp_share = 100*exp_fob/total_exp
collapse (mean) exp_share, by(country)
gen inv_order = -exp_share
sort inv_order
drop inv_order
la var country Country
la var exp_share "Average Share of Total Exports (Top 20)"
replace exp_share = round(exp_share,.01)
texsave using $rootdir/tables/exp_share if _n <= 20, varlabels replace frag

restore
drop country
ren other_ctry country
tempfile imps
collapse (sum) imp_fob, by(country year)
save `imps', replace
bys year: egen total_imp = total(imp_fob)
gen imp_share = 100*imp_fob/total_imp
collapse (mean) imp_share, by(country)
gen inv_order = -imp_share
sort inv_order
drop inv_order
la var country Country
la var imp_share "Average Share of Total Imports (Top 20)"
replace imp_share = round(imp_share,.01)
texsave using $rootdir/tables/imp_share if _n <= 20, varlabels replace frag

use `exps', clear
merge 1:1 country year using `imps'
gen trade_vol = imp_fob + exp_fob
bys year: egen total_vol = total(trade_vol)
gen vol_share = 100*trade_vol/total_vol
collapse (mean) vol_share, by(country)
gen inv_order = -vol_share
sort inv_order
drop inv_order
la var country Country
la var vol_share "Average Share of Total Trade Volume (Top 20)"
replace vol_share = round(vol_share,.01)
texsave using $rootdir/tables/vol_share if _n <= 20, varlabels replace frag
