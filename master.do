clear all

global rootdir = "C:\Users\l1lxl05\Desktop\Fiscal_Cyclicality_via_News"

cd "${rootdir}"

sysdir set PLUS ado

ssc install tabout, replace
ssc install ranktest, replace
ssc install ivreg2, replace
ssc install xtivreg2, replace
ssc install estout, replace
ssc install binscatter, replace
ssc install winsor2, replace
do data_prep.do
do exim_work.do
do gen_shocks.do
do summ_stats.do
do jai_pan_regs.do
