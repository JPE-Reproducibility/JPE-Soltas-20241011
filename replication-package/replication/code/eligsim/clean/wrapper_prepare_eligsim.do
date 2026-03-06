/***************************************************************************

This code file prepares datasets to run the following programs:
- eligsim_housing_assistance.ado
- eligsim_liheap.ado
- eligsim_medicaid.ado
- eligsim_schoolmeals.ado
- eligsim_snap.ado
- eligsim_ssi.ado
- eligsim_tanf.ado
- eligsim_ui.ado
- eligsim_wic.ado

***************************************************************************/

*** Set working directory

	do code/settings.do
	set more off
	
*** SNAP

	do "$dir/code/eligsim/clean/prepare_eligsim_snap.do"

*** Medicaid

	do "$dir/code/eligsim/clean/prepare_eligsim_medicaid.do"
	
*** SSI

*** WIC

*** LIHEAP

*** UI

*** Section 8

*** TANF
	
