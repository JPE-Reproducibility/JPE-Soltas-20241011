
/***************************************************************************
								LIHEAP
								
Data sources:
- LIHEAP Clearinghouse (NCAT, HHS-ACF)
- LIHEAP Reports to the Congress
- Federal Register

Input:
- data/eligsim/liheap/liheap_eligibility_income_limit.csv
- data/eligsim/liheap/liheap_eligibility_smi.csv
- data/eligsim/liheap/liheap_eligibility_fpg.csv
- data/eligsim/liheap/liheap_eligibility_asset_limit.csv
- data/eligsim/liheap/catelig_liheap.csv

Output:
- data/eligsim/liheap/liheap.dta

***************************************************************************/
* Settings

	do code/settings
	
	set more off
	
*** Income test information

	** Load data

	* Income limits
	import delimited "$dir/data/eligsim/liheap/LIHEAP_eligibility_income_limit.csv", delimiter(comma) stripquote(yes) encoding(UTF-8) clear
	tempfile inclimit
	save `inclimit', replace
	
	* Income definition: State median income
	import delimited "$dir/data/eligsim/liheap/LIHEAP_eligibility_smi.csv", delimiter(comma) stripquote(yes) encoding(UTF-8) clear
	tempfile smi
	save `smi', replace
	
	* Income definition: HHS federal poverty guideline
	import delimited "$dir/data/eligsim/liheap/LIHEAP_eligibility_fpg.csv", delimiter(comma) stripquote(yes) encoding(UTF-8) clear
	tempfile fpg
	save `fpg', replace
	
	* Asset limits
	import delimited "$dir/data/eligsim/liheap/LIHEAP_eligibility_asset_limit.csv", delimiter(comma) stripquote(yes) encoding(UTF-8) clear
	tempfile assetlimit
	save `assetlimit', replace
	
	* Categorical eligibility
	import delimited "$dir/data/eligsim/liheap/catelig_liheap.csv", delimiter(comma) stripquote(yes) encoding(UTF-8) clear
	tempfile catelig
	save `catelig', replace
	
	** Combine data
	
	use `inclimit', clear
	merge 1:1 state year using `smi', nogen
	merge 1:1 state year using `assetlimit', nogen
	merge m:1 state using `catelig', nogen
	mmerge year using `fpg'
	
	drop source_* _m
	
	** Make income limits consistent in dollars

	local vlist "heating cooling winter_crisis summer_crisis weatherization"
	
	local smi_hhsize1 = 0.52
	local smi_hhsize2 = 0.68
	local smi_hhsize3 = 0.84
	local smi_hhsize5 = 1.16
	local smi_hhsize6 = 1.32
	local smi_hhsize_adj = 0.03
		
	foreach v of varlist `vlist' {
		
		gen smi_`v' = `v' < 100
		
		replace `v' = (`v'/100) * smi_4_person if smi_`v' == 1
		replace `v' = (`v'/100) * fpg_allother if smi_`v' == 0 & state != "AK" & state != "HI"
		replace `v' = (`v'/100) * fpg_alaska if smi_`v' == 0 & state == "AK"
		replace `v' = (`v'/100) * fpg_hawaii if smi_`v' == 0 & state == "HI"
		
		* Adjust for HH size (SMI-only)
		
		replace `v' = `smi_hhsize1'*`v' if hhsize == 1
		replace `v' = `smi_hhsize2'*`v' if hhsize == 2
		replace `v' = `smi_hhsize3'*`v' if hhsize == 3
		replace `v' = `smi_hhsize5'*`v' if hhsize == 5
		replace `v' = `smi_hhsize6'*`v' if hhsize == 6
		replace `v' = (`smi_hhsize6'+`smi_hhsize_adj'*(hhsize-6))*`v' if hhsize > 6 & !missing(hhsize)
		
		drop smi_`v'
		
	}
	
	
	** Impute asset limit of 5000 if missing
	
	replace asset_limit_amt = 5000 if missing(asset_limit_amt) & has_asset_limit == 1
	
	** Recode state abbreviations to FIPS codes
	
	statastates, abbrev(state)
	drop _merge state state_name
	rename state_fips state
		
	** Save to file	
		
	save "$dir/data/eligsim/liheap/liheap", replace
