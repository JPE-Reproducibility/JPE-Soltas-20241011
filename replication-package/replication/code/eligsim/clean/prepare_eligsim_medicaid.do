
/***************************************************************************
								Medicaid

Input:
- data/eligsim/snap/immigrant_elig.csv

Output:
- data/eligsim/medicaid_immigrant.dta
								
***************************************************************************/
	
	*** Compile immigrant exceptions file

	import delimited "$dir/data/eligsim/snap/immigrant_elig.csv", clear
	
	rename state_fips state
	keep state medicaid*
	
	save "$dir/data/eligsim/medicaid_immigrant.dta", replace
	
	** Compile income/asset tests
	
	** Note: compiled manually in medicaid.dta
