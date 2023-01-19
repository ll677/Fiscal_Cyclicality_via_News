clear all

import delimited EXIM, varnames(1)

drop status
drop v9
drop v11
drop v13
drop v14

ren ïcountryname country
ren counterpartcountryname other_ctry
ren timeperiod year
ren countrycode ctry_id
ren counterpartcountrycode other_ctry_id
ren goodsvalueofexportsfreeonboardfo exp_fob
ren goodsvalueofimportscostinsurance imp
ren goodsvalueofimportsfreeonboardfo imp_fob
ren goodsvalueoftradebalanceusdollar netex

replace country = "Afghanistan" if country == "Afghanistan, Islamic Rep. of"
replace other_ctry = "Afghanistan" if other_ctry == "Afghanistan, Islamic Rep. of"
replace country = "Armenia" if country == "Armenia, Rep. of"
replace other_ctry = "Armenia" if other_ctry == "Armenia, Rep. of"
replace country = "Aruba" if country == "Aruba, Kingdom of the Netherlands"
replace other_ctry = "Aruba" if other_ctry == "Aruba, Kingdom of the Netherlands"
replace country = "Azerbaijan" if country == "Azerbaijan, Rep. of"
replace other_ctry = "Azerbaijan" if other_ctry == "Azerbaijan, Rep. of"
replace country = "Bahrain" if country == "Bahrain, Kingdom of"
replace other_ctry = "Bahrain" if other_ctry == "Bahrain, Kingdom of"
replace country = "Belarus" if country == "Belarus, Rep. of"
replace other_ctry = "Belarus" if other_ctry == "Belarus, Rep. of"
replace country = "Central African Republic" if country == "Central African Rep."
replace other_ctry = "Central African Republic" if other_ctry == "Central African Rep."
replace country = "Hong Kong SAR, China" if country == "China, P.R.: Hong Kong"
replace other_ctry = "Hong Kong SAR, China" if other_ctry == "China, P.R.: Hong Kong"
replace country = "Macao SAR, China" if country == "China, P.R.: Macao"
replace other_ctry = "Macao SAR, China" if other_ctry == "China, P.R.: Macao"
replace country = "China" if country == "China, P.R.: Mainland"
replace other_ctry = "China" if other_ctry == "China, P.R.: Mainland"
replace country = "Comoros" if country == "Comoros, Union of the"
replace other_ctry = "Comoros" if other_ctry == "Comoros, Union of the"
replace country = "Congo, Dem. Rep." if country == "Congo, Dem. Rep. of the"
replace other_ctry = "Congo, Dem. Rep." if other_ctry == "Congo, Dem. Rep. of the"
replace country = "Congo, Dem. Rep." if country == "Congo, Dem. Rep. of the"
replace other_ctry = "Congo, Dem. Rep." if other_ctry == "Congo, Dem. Rep. of the"
replace country = "Congo, Rep." if country == "Congo, Rep. of"
replace other_ctry = "Congo, Rep." if other_ctry == "Congo, Rep. of"
replace country = "Croatia" if country == "Croatia, Rep. of"
replace other_ctry = "Croatia" if other_ctry == "Croatia, Rep. of"
replace country = "Curacao" if country == "CuraÃ§ao, Kingdom of the Netherlands"
replace other_ctry = "Curacao" if other_ctry == "CuraÃ§ao, Kingdom of the Netherlands"
replace country = "Czech Republic" if country == "Czech Rep."
replace other_ctry = "Czech Republic" if other_ctry == "Czech Rep."
replace country = "Cote d'Ivoire" if country == "CÃ´te d'Ivoire"
replace other_ctry = "Cote d'Ivoire" if other_ctry == "CÃ´te d'Ivoire"
replace country = "Dominican Republic" if country == "Dominican Rep."
replace other_ctry = "Dominican Republic" if other_ctry == "Dominican Rep."
replace country = "Egypt, Arab Rep." if country == "Egypt, Arab Rep. of"
replace other_ctry = "Egypt, Arab Rep." if other_ctry == "Egypt, Arab Rep. of"
replace country = "Emerging Market and Developing Economies" if country == "Emerging and Developing Economies"
replace other_ctry = "Emerging Market and Developing Economies" if other_ctry == "Emerging and Developing Economies"
replace country = "Equatorial Guinea" if country == "Equatorial Guinea, Rep. of"
replace other_ctry = "Equatorial Guinea" if other_ctry == "Equatorial Guinea, Rep. of"
replace country = "Eritrea" if country == "Eritrea, The State of"
replace other_ctry = "Eritrea" if other_ctry == "Eritrea, The State of"
replace country = "Estonia" if country == "Estonia, Rep. of"
replace other_ctry = "Estonia" if other_ctry == "Estonia, Rep. of"
replace country = "Eswatini" if country == "Eswatini, Kingdom of"
replace other_ctry = "Eswatini" if other_ctry == "Eswatini, Kingdom of"
replace country = "Ethiopia" if country == "Ethiopia, The Federal Dem. Rep. of"
replace other_ctry = "Ethiopia" if other_ctry == "Ethiopia, The Federal Dem. Rep. of"
replace country = "Fiji" if country == "Fiji, Rep. of"
replace other_ctry = "Fiji" if other_ctry == "Fiji, Rep. of"
replace country = "Iran, Islamic Rep." if country == "Iran, Islamic Rep. of"
replace other_ctry = "Iran, Islamic Rep." if other_ctry == "Iran, Islamic Rep. of"
replace country = "Kazakhstan" if country == "Kazakhstan, Rep. of"
replace other_ctry = "Kazakhstan" if other_ctry == "Kazakhstan, Rep. of"
replace country = "Korea, Dem. People's Rep." if country == "Korea, Dem. People's Rep. of"
replace other_ctry = "Korea, Dem. People's Rep." if other_ctry == "Korea, Dem. People's Rep. of"
replace country = "Korea, Rep." if country == "Korea, Rep. of"
replace other_ctry = "Korea, Rep." if other_ctry == "Korea, Rep. of"
replace country = "Kyrgyz Republic" if country == "Kyrgyz Rep."
replace other_ctry = "Kyrgyz Republic" if other_ctry == "Kyrgyz Rep."
replace country = "Lao PDR" if country == "Lao People's Dem. Rep."
replace other_ctry = "Lao PDR" if other_ctry == "Lao People's Dem. Rep."
replace country = "Lesotho" if country == "Lesotho, Kingdom of"
replace other_ctry = "Lesotho" if other_ctry == "Lesotho, Kingdom of"
replace country = "Madagascar" if country == "Madagascar, Rep. of"
replace other_ctry = "Madagascar" if other_ctry == "Madagascar, Rep. of"
replace country = "Marshall Islands" if country == "Marshall Islands, Rep. of the"
replace other_ctry = "Marshall Islands" if other_ctry == "Marshall Islands, Rep. of the"
replace country = "Mauritania" if country == "Mauritania, Islamic Rep. of"
replace other_ctry = "Mauritania" if other_ctry == "Mauritania, Islamic Rep. of"
replace country = "Micronesia, Fed. Sts." if country == "Micronesia, Federated States of"
replace other_ctry = "Micronesia, Fed. Sts." if other_ctry == "Micronesia, Federated States of"
replace country = "Moldova" if country == "Moldova, Rep. of"
replace other_ctry = "Moldova" if other_ctry == "Moldova, Rep. of"
replace country = "Mozambique" if country == "Mozambique, Rep. of"
replace other_ctry = "Mozambique" if other_ctry == "Mozambique, Rep. of"
replace country = "Nauru" if country == "Nauru, Rep. of"
replace other_ctry = "Nauru" if other_ctry == "Nauru, Rep. of"
replace country = "Netherlands" if country == "Netherlands, The"
replace other_ctry = "Netherlands" if other_ctry == "Netherlands, The"
replace country = "North Macedonia" if country == "North Macedonia, Republic of"
replace other_ctry = "North Macedonia" if other_ctry == "North Macedonia, Republic of"
replace country = "Palau" if country == "Palau, Rep. of"
replace other_ctry = "Palau" if other_ctry == "Palau, Rep. of"
replace country = "Poland" if country == "Poland, Rep. of"
replace other_ctry = "Poland" if other_ctry == "Poland, Rep. of"
replace country = "San Marino" if country == "San Marino, Rep. of"
replace other_ctry = "San Marino" if other_ctry == "San Marino, Rep. of"
replace country = "Serbia" if country == "Serbia and Montenegro"
replace other_ctry = "Serbia" if other_ctry == "Serbia and Montenegro"
replace country = "Serbia" if country == "Serbia, Rep. of"
replace other_ctry = "Serbia" if other_ctry == "Serbia, Rep. of"
replace country = "Slovak Republic" if country == "Slovak Rep."
replace other_ctry = "Slovak Republic" if other_ctry == "Slovak Rep."
replace country = "Slovenia" if country == "Slovenia, Rep. of"
replace other_ctry = "Slovenia" if other_ctry == "Slovenia, Rep. of"
replace country = "Syrian Arab Republic" if country == "Syrian Arab Rep."
replace other_ctry = "Syrian Arab Republic" if other_ctry == "Syrian Arab Rep."
replace country = "Sao Tome and Principe" if country == "SÃ£o TomÃ© and PrÃ­ncipe, Dem. Rep. of"
replace other_ctry = "Sao Tome and Principe" if other_ctry == "SÃ£o TomÃ© and PrÃ­ncipe, Dem. Rep. of"
replace country = "Tajikistan" if country == "Tajikistan, Rep. of"
replace other_ctry = "Tajikistan" if other_ctry == "Tajikistan, Rep. of"
replace country = "Tanzania" if country == "Tanzania, United Rep. of"
replace other_ctry = "Tanzania" if other_ctry == "Tanzania, United Rep. of"
replace country = "Timor-Leste" if country == "Timor-Leste, Dem. Rep. of"
replace other_ctry = "Timor-Leste" if other_ctry == "Timor-Leste, Dem. Rep. of"
replace country = "Turkiye" if country == "TÃ¼rkiye, Rep of"
replace other_ctry = "Turkiye" if other_ctry == "TÃ¼rkiye, Rep of"
replace country = "Uzbekistan" if country == "Uzbekistan, Rep. of"
replace other_ctry = "Uzbekistan" if other_ctry == "Uzbekistan, Rep. of"
replace country = "Venezuela, RB" if country == "Venezuela, Rep. Bolivariana de"
replace other_ctry = "Venezuela, RB" if other_ctry == "Venezuela, Rep. Bolivariana de"
replace country = "Kosovo" if country == "Kosovo, Rep. of"
replace other_ctry = "Kosovo" if other_ctry == "Kosovo, Rep. of"
replace country = "Sint Maarten (Dutch part)" if country == "Sint Maarten, Kingdom of the Netherlands"
replace other_ctry = "Sint Maarten (Dutch part)" if other_ctry == "Sint Maarten, Kingdom of the Netherlands"
replace country = "South Sudan" if country == "South Sudan, Rep. of"
replace other_ctry = "South Sudan" if other_ctry == "South Sudan, Rep. of"
replace country = "Yemen, Rep." if country == "Yemen, Rep. of"
replace other_ctry = "Yemen, Rep." if other_ctry == "Yemen, Rep. of"
replace country = "Euro area" if country == "Euro Area"
replace other_ctry = "Euro area" if other_ctry == "Euro Area"

// Drop country groups, territories, and countries which lack WEO forecast data

drop if country == "Africa"
drop if country == "Anguilla"
drop if country == "Belgium-Luxembourg"
drop if country == "Czechoslovakia"
drop if country == "Emerging and Developing Asia"
drop if country == "Emerging and Developing Europe"
drop if country == "Export earnings: nonfuel"
drop if country == "Export earnings: fuel"
drop if country == "Falkland Islands (Malvinas)"
drop if country == "Holy See"
drop if country == "Middle East"
drop if country == "Middle East and Central Asia"
drop if country == "Montserrat"
drop if country == "Other Countries not included elsewhere"
drop if country == "South African Common Customs Area (SACCA)"
drop if country == "USSR"
drop if country == "Yugoslavia"
drop if country == "Western Hemisphere"

drop if other_ctry == "Africa"
drop if other_ctry == "Anguilla"
drop if other_ctry == "Belgium-Luxembourg"
drop if other_ctry == "Czechoslovakia"
drop if other_ctry == "Emerging and Developing Asia"
drop if other_ctry == "Emerging and Developing Europe"
drop if other_ctry == "Export earnings: nonfuel"
drop if other_ctry == "Export earnings: fuel"
drop if other_ctry == "Falkland Islands (Malvinas)"
drop if other_ctry == "Holy See"
drop if other_ctry == "Middle East"
drop if other_ctry == "Middle East and Central Asia"
drop if other_ctry == "Montserrat"
drop if other_ctry == "Other Countries not included elsewhere"
drop if other_ctry == "South African Common Customs Area (SACCA)"
drop if other_ctry == "USSR"
drop if other_ctry == "Yugoslavia"
drop if other_ctry == "Western Hemisphere"


save EXIM, replace
