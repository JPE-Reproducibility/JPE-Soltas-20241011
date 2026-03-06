
/***************************************************************************
								SSI

Input:
- data/eligsim/snap/immigrant_elig.csv
- data/eligsim/ssi/ssi_state_supplement.csv
- data/eligsim/snap/snap_params.csv

Output:
- data/eligsim/ssi_immigrant.dta
- data/eligsim/ssi/ssi_state_supplement.dta
	
***************************************************************************/
* Settings

	do code/settings
	
	set more off
		
	* Compile immigrant exceptions file

	import delimited "$dir/data/eligsim/snap/immigrant_elig.csv", clear
	
	rename state_fips state
	keep state ssi*
	
	save "$dir/data/eligsim/ssi_immigrant.dta", replace
	
	* SSI
	import delimited "$dir/data/eligsim/ssi/ssi_state_supplement.csv", delimiter(comma) stripquote(yes) encoding(UTF-8) clear
	replace year = year-1
	
	rename statefip state_abbrev
	statastates, abbrev(state_abbrev)
	drop state_abbrev state_name
	rename state_fips state
	
	order state year supplement*
	
	save "$dir/data/eligsim/ssi/ssi_state_supplement.dta", replace
