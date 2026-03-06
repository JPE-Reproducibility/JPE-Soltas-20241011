/***************************************************************************
			SNAP - Supplemental Nutrition Assistance Program
			
Data sources:
- SNAP Policy Database (USDA ERS): https://www.ers.usda.gov/data-products/snap-policy-data-sets/
- Other eligibility criteria (standard deduction, excess shelter deduction): Hand-collected for eligsim; see notes

Input:
- data/eligsim/snap/immigrant_elig.csv
- data/eligsim/snap/SNAP_Policy_Database.xlsx
- data/eligsim/snap/snap_params.csv

Output:
- data/eligsim/snap_immigrant.dta
- data/eligsim/snap.dta
	
***************************************************************************/

* Settings

	do code/settings
	
	set more off
	

*** Compile immigrant exceptions file

	import delimited "$dir/data/eligsim/snap/immigrant_elig.csv", clear
	
	rename state_fips state
	keep state snap_imm_early snap_imm_late snap_imm_late2021
	
	save "$dir/data/eligsim/snap_immigrant.dta", replace

*** Compile SNAP Policy Database file

	import excel "$dir/data/eligsim/snap/SNAP_Policy_Database.xlsx", sheet("SNAPPolicyDatabase_ED2") firstrow clear
	
	local vlist "inc_limit asset_limit vehexclall vehexclamt vehexclone"
	
	rename state_fips state
	
	keep state yearmonth bbce* vehex*
	
	* Create year variable
	gen year = floor(yearmonth/100)
	
	* Recode income limit (both regular and under BBCE)
		
		replace bbce_inclmt = 130 if bbce_inclmt == -9
		rename bbce_inclmt inc_limit
					
	* Recode asset limit under BBCE
				
		* Notes: asset limit was $2000 for nonelderly household from 1980s up to 2014, then increased to $2250 in October 2014
		
		gen asset_limit = 2000
		replace asset_limit = 2250 if year >= 2014
		
		gen asset_limit_bbce = asset_limit
		replace asset_limit = bbce_a_amt*1000 if bbce_asset == 0
		replace asset_limit = 10e9 if bbce_asset == 1
		
	* Collapse to annual policy (assume maximum)
	
	collapse (max) inc_limit asset_limit vehex*, by(state year)
	
	* Impute 2017 year
		
		preserve
		
		keep state
		duplicates drop
		
		gen year = 2017
		
		tempfile exp
		save `exp', replace
		
		restore
		
		append using `exp'
		
		sort state year
		
		foreach v of varlist `vlist' {
			replace `v' = `v'[_n-1] if year >= 2016
		}
		
		
	* Save to tempfile
	
		tempfile snap_policy_database
		save `snap_policy_database', replace
		
	* Load other eligibility variables
	
		import delimited "$dir/data/eligsim/snap/snap_params.csv", encoding(ISO-8859-1) clear
		merge m:1 state year using `snap_policy_database', nogen
		
		fillin state year hhsize
		
		foreach v of varlist `vlist' {
			bys state year: egen `v'_ = max(`v')
			replace `v' = `v'_ if missing(`v')
			drop `v'_
		}
		
		drop if missing(hhsize)
		
	* Save to file	
		
	save "$dir/data/eligsim/snap", replace
