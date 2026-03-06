/***************************************************************************
 * Table 1: Means-Tested Transfer Programs in the U.S.
 * 
 * Description:
 * This script loads harmonized PSID data, defines demographic and economic 
 * variables for household heads, and computes summary statistics by program 
 * participation (e.g., SNAP, Medicaid, Housing Assistance). It also produces 
 * means conditional on simulated eligibility and estimates average transfer 
 * amounts among recipients. Results are formatted for inclusion in a LaTeX table.
 * 
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * - Stata-TeX helper and settings scripts (`code/stata-tex.do`, `code/settings`)
 * 
 * Outputs:
 * - Formatted CSV file with summary statistics (`"$dir/tables/data/summstats_transfers.csv"`)
 * - Final LaTeX table compiled from template
 ***************************************************************************/

* Load data

	qui do code/settings.do

	use "$dir/data/psid_base", clear
	run_all_eligsims

	* Rename housing variable (shorten)
	rename housing_assistance ha
	rename housing_assistance_amt_hh ha_amt_hh
	rename eligsim_housing eligsim_ha
	
	* Recode race/education variables
	
		gen nonwhite_or_hispanic = 1-white if !missing(white)
		
		gen hsdeg = edcat>=2 if !missing(edcat)
		
		gen age_head = age if head == 1
		replace anychild = . if head != 1
		replace nonwhite_or_hispanic = . if head != 1
		replace hsdeg = . if head != 1
		replace employ = . if head != 1
		
	* Ensure common sample for rank variables
	replace rk_current_eq = . if missing(rk_lifetime_eq) | missing(rk_c_current_eq)
	replace rk_lifetime_eq = . if missing(rk_current_eq) | missing(rk_c_current_eq)
	replace rk_c_current_eq = . if missing(rk_lifetime_eq) | missing(rk_current_eq)
	
	* Define "any transfer"
	egen anytransfer = rowmax(snap medicaid ha tanf ssi wic liheap schoolmeals)
	egen eligsim_anytransfer = rowmax(eligsim_snap eligsim_medicaid eligsim_ha eligsim_tanf eligsim_ssi eligsim_wic eligsim_liheap eligsim_schoolmeals)
	
	* Rescale to percentages
	
	foreach v of varlist married anychild nonwhite_or_hispanic hsdeg employ {
		replace `v' = `v' * 100
	}
	
	* Restrict to ages 18-65 (necessary b/c no income controls here)
	keep if inrange(age,18,65)
	
* Summarize

	cd "$dir/tables/data"

	* Loop through variables to summarize
	foreach outcome of varlist age_head hhsize married anychild nonwhite_or_hispanic hsdeg employ faminct_real rk_current_eq rk_lifetime_eq rk_c_current_eq {
		
		* Loop through all programs
		foreach p of varlist anytransfer snap medicaid ha tanf ssi wic liheap schoolmeals {
		
			* Generate outcome means (using `reg' to get clustered SEs)
			reg `outcome' if `p'==1 [pw=wtfam], cl(famid_orig)
			
			if "`outcome'" != "faminct_real" {
				store_est_tpl using summstats_transfers.csv, coef(_cons) name(`outcome'_`p') all format(%8.1f)
			}
			if "`outcome'" == "faminct_real" {
				store_est_tpl using summstats_transfers.csv, coef(_cons) name(`outcome'_`p') all format(%8.0fc)
			}
					
		}
		
		* Generate outcome means (using `reg' to get clustered SEs)
		reg `outcome' [pw=wtfam], cl(famid_orig)
		
		if "`outcome'" != "faminct_real" {
			store_est_tpl using summstats_transfers.csv, coef(_cons) name(`outcome'_allpop) all format(%8.1f)
		}
		if "`outcome'" == "faminct_real" {
			store_est_tpl using summstats_transfers.csv, coef(_cons) name(`outcome'_allpop) all format(%8.0fc)
		}
		
	}
	
	* Construct receipt rate, take-up rate, and average benefits by program
	
	foreach p of varlist anytransfer snap medicaid ha tanf ssi wic liheap schoolmeals {
		
		preserve 
		
		* Rescale to percentage rate
		replace `p' = `p' * 100
		
		reg `p' [pw=wtfam], cl(famid)
		store_est_tpl using summstats_transfers.csv, coef(_cons) name(`p') all format(%8.1f)
		
		restore
				
	}
	
	foreach p of varlist anytransfer snap medicaid ha tanf ssi wic liheap schoolmeals {
		
		preserve 
		
		* Rescale to percentage rate
		replace `p' = `p' * 100
		
		reg `p' if eligsim_`p'==1 [pw=wtfam], cl(famid)
		store_est_tpl using summstats_transfers.csv, coef(_cons) name(takeup_`p') all format(%8.1f)
		
		restore
				
	}

	foreach p of varlist snap medicaid ha tanf ssi wic liheap schoolmeals {
		
		* Rescale out of per-person
		replace `p'_amt_hh = `p'_amt_hh * hhsize
		
		reg `p'_amt_hh if `p' == 1 [pw=wtfam], cl(famid)
		store_est_tpl using summstats_transfers.csv, coef(_cons) name(`p'_amt_hh) all format(%8.0fc)
				
	}


*** Create tables

	cap erase "../tables/output/summstats_transfers.tex"
	
	cd "$dir/code"

	table_from_tpl, t("../tables/template/summstats_transfers_template.tex") ///
					r("../tables/data/summstats_transfers.csv") ///
					o("../tables/output/summstats_transfers.tex") 
					
	cd "$dir"
