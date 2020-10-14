clear all

global rootdir = "C:\Users\Louis\Dropbox\fiscal_cyclicality_growth\Final upload"

cd "${rootdir}"

sysdir set PLUS ado

ssc install ivreg2
ssc install ranktest
ssc install xtivreg2
ssc install estout

do data_prep.do
do exim_work.do
do gen_shocks.do
do jai_pan_regs.do
