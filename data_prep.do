clear all

// Generate forecasts and save as .dta

import excel "${rootdir}\WEOhistorical.xlsx", sheet("ngdp_rpch") firstrow

destring, replace

// All forecasts in a row predict the same date

gen gRf0F = F1990ngdp_rpch if year == 1990 // Fall nowcast
gen gRf0S = S1990ngdp_rpch if year == 1990 // Spring nowcast
replace gRf0F = F1991ngdp_rpch if year == 1991 // Fall nowcast
replace gRf0S = S1991ngdp_rpch if year == 1991 // Spring nowcast

gen gRf1F = F1990ngdp_rpch if year == 1991 // Fall 1-yr ahead forecast
gen gRf1S = S1990ngdp_rpch if year == 1991 // Spring 1-yr ahead forecast

gen gRf2F = . // Fall 2-yr ahead forecast
gen gRf2S = . // Spring 2-yr ahead forecast

local strtyr = 1992

local endyr = 2019

foreach y of num `strtyr'/`endyr' {
	local ly = `y'-1
	local lly = `y'-2
	replace gRf0F = F`y'ngdp_rpch if year == `y'
	replace gRf1F = F`ly'ngdp_rpch if year == `y'
	replace gRf2F = F`lly'ngdp_rpch if year == `y'
	replace gRf0S = S`y'ngdp_rpch if year == `y'
	replace gRf1S = S`ly'ngdp_rpch if year == `y'
	replace gRf2S = S`lly'ngdp_rpch if year == `y'
}

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
replace country = "Venezuela, RB" if country == "Venezuela"
replace country = "Yemen, Rep." if country == "Yemen"

keep country year gRf0F gRf0S gRf1F gRf1S

save WEOhistorical, replace

clear all


// import controls and save as .dta

import delimited WB_WDI_vars, varnames(1)

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

save WB_WDI_vars, replace

// save group indicators

clear all

import delimited match_groups, varnames(1)

ren ïcountry country

sort country

drop if country == country[_n-1]
drop year

save match_groups, replace

// Merge the data

clear all

use WEOhistorical

merge 1:1 country year using WB_WDI_vars

drop _merge

merge m:1 country using match_groups

drop _merge

// numericize country name

egen countryid = group(country), label lname(country)
drop timecode countrycode
drop if year > 2020
order countryid, first

save reg_data, replace
