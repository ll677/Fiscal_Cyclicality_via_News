clear all

// Generate forecasts and save as .dta


// All forecasts in a row predict the same date
import excel "${rootdir}/data/input/WEOhistorical.xlsx", sheet("ngdp_rpch") firstrow

destring, replace

ren *ngdp_rpch *
ren S* fct*S
ren F* fct*F
egen row_group = group(year country)
reshape long fct, i(row_group) j(fct_tag) string

destring fct_tag, ignore("SF") gen(repyr)
gen fct_hz = year - repyr
tostring fct_hz, gen(fct_hz_tag)
keep if fct_hz >= -1 & fct_hz <= 5
replace fct_hz_tag = regexr(fct_tag,"[0-9][0-9][0-9][0-9]","") + subinstr(fct_hz_tag,"-","neg",.) + "yrs_ago"
keep country year row_group fct_hz_tag fct

reshape wide fct, i(row_group) j(fct_hz_tag) string
drop row_group

// Reconciling country names with WB WDI data for merge

replace country = "Congo, Dem. Rep." if country == "Congo, Democratic Republic of the"
replace country = "Congo, Rep." if country == "Congo, Republic of"
replace country = "Cote d'Ivoire" if country == "Côte d'Ivoire"
replace country = "Egypt, Arab Rep." if country == "Egypt"
replace country = "Hong Kong SAR, China" if country == "Hong Kong SAR"
replace country = "Iran, Islamic Rep." if country == "Iran"
replace country = "Korea, Dem. People's Rep." if country == "Korea, Dem. Peopleâs Rep."
replace country = "Korea, Rep." if country == "Korea"
replace country = "Lao PDR" if country == "Lao P.D.R."
replace country = "Macao SAR, China" if country == "Macao SAR"
replace country = "Micronesia, Fed. Sts." if country == "Micronesia"
replace country = "Montenegro" if country == "Montenegro, Rep. of"
replace country = "Russian Federation" if country == "Russia"
replace country = "Sao Tome and Principe" if country == "São Tomé and Príncipe"
replace country = "Syrian Arab Republic" if country == "Syria"
replace country = "Turkiye" if country == "Türkiye"
replace country = "Venezuela, RB" if country == "Venezuela"
replace country = "Yemen, Rep." if country == "Yemen"

order country year fct*

save ${rootdir}/data/processed/WEOhistorical, replace

clear all


// import controls and save as .dta

import delimited $rootdir/data/input/WB_WDI_vars, varnames(1)

drop if countryname == ""

foreach v of varlist * {
	replace `v' = "." if `v' == ".."
}

destring, replace

ren countryname country
*ren ïtime year
ren time year
ren netlendingnetborrowingofgdpgcnld netlend
ren netbartertermsoftradeindex200010 tot
ren gdpgrowthannualnygdpmktpkdzg gRGDP
ren exportsofgoodsandservicesofgdpne exp_pcgdp

replace country = "Korea, Dem. People's Rep." if country == "Korea, Dem. Peopleâs Rep."
replace country = "Turkiye" if country == "Türkiye"

save $rootdir/data/processed/WB_WDI_vars, replace

// save group indicators

clear all

import delimited $rootdir/data/match_groups, varnames(1) clear

cap ren ïcountry country

sort country

*drop if country == country[_n-1]
*drop year

save $rootdir/data/match_groups, replace

// Merge the data

clear all

use $rootdir/data/processed/WEOhistorical

merge 1:1 country year using $rootdir/data/processed/WB_WDI_vars

drop _merge

merge m:1 country using $rootdir/data/match_groups

drop _merge

merge 1:1 country year using $rootdir/data/processed/WB_WDI_expense_debt

drop _merge

// numericize country name

egen countryid = group(country), label lname(country)
drop timecode countrycode
drop if year > 2020
order countryid, first

save $rootdir/data/processed/reg_data, replace
