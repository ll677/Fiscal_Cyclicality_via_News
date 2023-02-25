// cap drop categories, territories, and constituents of other countries

local drop_res = `" "Africa Eastern and Southern" "Africa Western and Central" "American Samoa" "Anguilla" " (a|A)rea" "Asia" "Bermuda" "Belgium-Luxembourg" "British Virgin Islands" "Caribbean" "(c|C)ategor(y|ies)" "Cayman Islands" "Channel Islands" "CIS" "(C|c)ountr" "Curacao" "Czechoslovakia" "demographic" "Eastern Germany" "Economies" "Europe" "Falkland" "Faroe Islands" "Fragile and conflict affected situations" "French Polynesia" "Gibraltar" "Global Partnership for Education" "Greenland" "Guam" "Holy See" "Hong Kong" "IBRD" "IDA & IBRD total" "IDA blend" "IDA only" "IDA total" "income" "Isle of Man" "Latin America" "Lending category not classified" "Macao" "mall states" "Mayotte" "Middle East" "Montserrat" "Netherlands Antilles" "New Caledonia" "North America" "North Africa" "Northern Mariana Islands" "Not classified" "not specified" "OECD"  "Pacific" "pdated" "(Dutch part)" "(French part)" "Sub-Saharan" "Tokelau" "Turks and Caicos Islands" "USSR" "Virgin Islands" "Western Hemisphere" "World" "xport" "Yemen Arab Rep" "Yugoslavia" "'

cap drop drop_ind
gen drop_ind = 0

foreach re of local drop_res {

replace drop_ind = drop_ind | regexm(country,"`re'")
cap replace drop_ind = drop_ind | regexm(other_ctry,"`re'")

}

local drop_terms = `" "Africa" "Yemen, People's Dem. Rep. of" "'

foreach term of local drop_terms {

replace drop_ind = drop_ind | (country == "`term'")
cap replace drop_ind = drop_ind | (other_ctry == "`term'")

}

drop if drop_ind
drop drop_ind

