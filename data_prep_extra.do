clear all

import excel using $rootdir/data/input/IMF_IFS.xlsx, sheet("International Financial Statis") cellrange(A2) firstrow clear

local keep_vars "year country"

ren A year
destring year, replace
ren B country

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

include drop_vars.do

foreach v of varlist _all {

local keep_ind = 0
di "`v'"
local v_lab : variable label `v'
local keep_ind = `keep_ind' | ("`v_lab'" == "Fiscal, Budgetary Central Government, Cash surplus/deficit [CSD_CA], 2001 Manual")
local keep_ind = `keep_ind' | ("`v_lab'" == "Fiscal, General Government, Assets and Liabilities, Debt (at Market Value), Clas")
local keep_ind = `keep_ind' | ("`v_lab'" == "Fiscal, General Government, Memo Item: Expenditure, 2001 Manual, Domestic Curren")
local keep_ind = `keep_ind' | ("`v_lab'" == "Prices, Consumer Price Index, All items, Percentage change, Corresponding period")

if `keep_ind' == 1 {
local keep_vars "`keep_vars' `v'"
}

}

keep `keep_vars'


foreach v of varlist _all {


local v_lab : variable label `v'
if ("`v_lab'" == "Fiscal, Budgetary Central Government, Cash surplus/deficit [CSD_CA], 2001 Manual") {
ren `v' imf_ifs_surp
}

if ("`v_lab'" == "Fiscal, General Government, Assets and Liabilities, Debt (at Market Value), Clas") {
ren `v' imf_ifs_debt
}

if ("`v_lab'" == "Fiscal, Budgetary Central Government, Memo Item: Expenditure, 2001 Manual, Cash, ") {
ren `v' imf_ifs_exp
}
if ("`v_lab'" == "Prices, Consumer Price Index, All items, Percentage change, Corresponding period") {
ren `v' imf_ifs_infl
}

}

save $rootdir/data/processed/imf_ifs, replace



import delimited using $rootdir/data/input/WB_WDI_expense_debt, varnames(1) clear

drop countrycode
ren countryname country
drop if missing(country)
drop timecode
ren time year

replace country = "Korea, Dem. People's Rep." if country == "Korea, Dem. Peopleâs Rep."
replace country = "Turkiye" if country == "Türkiye"

include drop_vars.do

ren expenseofgdpgcxpntotlgdzs wb_wdi_expense
ren centralgovernmentdebttotalofgdpg wb_wdi_debt

replace wb_wdi_debt = "" if wb_wdi_debt == ".."
replace wb_wdi_expense = "" if wb_wdi_expense == ".."
destring wb_wdi_expense wb_wdi_debt, replace

save $rootdir/data/processed/WB_WDI_expense_debt, replace
