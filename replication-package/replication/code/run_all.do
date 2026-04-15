/***************************************************************************
This code file will run all data cleaniing and analyses do files to replicate the figures and tables in the paper
****************************************************************************/

* Settings
cd "../"
do code/settings.do

	discard
	adopath + "$dir/code"
	adopath + "$dir/code/eligsim"
	adopath + "$dir/packages"
	do "$dir/code/stata-tex.do"
	set scheme simplescheme
	
	global imputation = 0

/***************************************************************************
******************************** Data cleaning******************************
****************************************************************************/

* Run CPS and PSID do files
do "$dir/code/clean/cps/01_cps_imputation.do"
do "$dir/code/clean/psid/01_psid_reshape.do"
do "$dir/code/clean/psid/02_ebayes_lifetime_earnings.do"
do "$dir/code/clean/psid/03_merge_psid_reshape_lifetime_earnings.do"
do "$dir/code/clean/cps/02_clean_cps_income_reg.do"

* Run CEX do files
do "$dir/code/clean/cex/01_load_cex.do"
do "$dir/code/clean/cex/02_process_cex.do"

* Run eligibility simulation do files
do "$dir/code/eligsim/clean/prepare_eligsim_housing_assistance.do"
do "$dir/code/eligsim/clean/prepare_eligsim_liheap.do"
do "$dir/code/eligsim/clean/prepare_eligsim_medicaid.do"
do "$dir/code/eligsim/clean/prepare_eligsim_snap.do"
do "$dir/code/eligsim/clean/prepare_eligsim_ssi.do"
do "$dir/code/eligsim/clean/prepare_eligsim_tanf.do"

* Run figures and table do files
local flist fig_1ab_A23ab_A28ab.do fig_1c_A23c.do fig_1d.do fig_2_A23d.do fig_A1.do fig_A2ab.do fig_A3.do fig_A4.do fig_A5.do fig_A6ab.do fig_A7ab.do fig_A8.do fig_A9ab.do fig_A10ab.do fig_A11a.do fig_A11b.do fig_A12ab.do fig_A13ab.do fig_A14.do fig_A15.do fig_A16ab.do fig_A17.do fig_A18.do fig_A19.do fig_A20.do fig_A21ab.do fig_A22.do fig_A24ab.do fig_A25.do fig_A26ab.do fig_A27ab.do fig_A29ab.do fig_A30.do fig_A31.do fig_A32.do table_1.do table_2_A1.do table_3_i.do table_3_ii_A17.do table_A2.do table_A3.do table_A4.do table_A5.do table_A6.do table_A7_A8.do table_A9.do table_A10_12.do table_A11_13.do table_A14.do 

di `"`flist'"' // show you the filelist
foreach fname of local flist {
  di as red "Executing file: `fname'"
  do "$dir/code/analyze/`fname'"
}
