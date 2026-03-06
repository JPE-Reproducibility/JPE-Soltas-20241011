/***************************************************************************
 * Tabulations of Transfer Receipt and Simulated Eligibility by Resources
 * Table 2, Appendix Table A1 
 * 
 * Description:
 * This script loads harmonized PSID data and assigns individuals to 
 * quintiles of income, lifetime income, and consumption. It tabulates 
 * average household transfers received (e.g., SNAP) and simulated 
 * eligibility rates across these quintiles. It also computes participation 
 * rates conditional on eligibility. Results are saved in a structured text 
 * file for later inclusion in a LaTeX table.
 * 
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * 
 * Outputs:
 * - Formatted text file with tabulated means (`"$dir/tables/data/tabulations.txt"`)
 * - Final LaTeX table compiled from template
 ***************************************************************************/
 
* Load data

	do code/settings

	use "$dir/data/psid_base", clear

	* Use 20.001 to classify rk = 100 --> quintile = 4 (quintile variable takes values 0,1,2,3,4)
	gen quintile_consumption = floor(rk_c_current_eq/20.001)
	gen quintile_lifetimeincome = floor(rk_lifetime_eq/20.001)
	gen quintile_income = floor(rk_current_eq/20.001)
	
	* Run all eligibility simulators
	run_all_eligsims
	
	* Convert to percentages
	gen snap100 = snap*100
	gen eligsim_snap100 = eligsim_snap*100
	
	* Apply sample restriction
	* Note: needed here, not elsewhere, b/c not always 'controlling' for ranks
	keep if inrange(age,18,65)
	
* Tabulations
	
	* These tables can be previewed via code like:
	* table quintile_* , stat(mean snap_) nformat(%8.1f)
	
	cd "$dir/tables/data"

	* Amounts, receipt, and eligibility (w/o eligibility restriction)
	foreach v of varlist tot_amt_hh snap100 eligsim_snap100 {
		forvalues i = 0/4 {
			
			* Values by income quintile
			summ `v' [aw=wtfam] if quintile_income == `i'
			local val = r(mean)
			
			if "`v'" == "tot_amt_hh" {
				insert_into_file using tabulations.txt, key(`v'_`i'_avginc) value(`val') format(%12.0fc) 
			}
			if "`v'" != "tot_amt_hh" {
				insert_into_file using tabulations.txt, key(`v'_`i'_avginc) value(`val') format(%12.1f) 
			}
			
			* Values by consumption quintile
			summ `v' [aw=wtfam] if quintile_consumption == `i'
			local val = r(mean)
			
			if "`v'" == "tot_amt_hh" {
				insert_into_file using tabulations.txt, key(`v'_`i'_avgc) value(`val') format(%12.0fc) 
			}
			if "`v'" != "tot_amt_hh" {
				insert_into_file using tabulations.txt, key(`v'_`i'_avgc) value(`val') format(%12.1f) 
			}
			
			* Values by lifetime quintile
			summ `v' [aw=wtfam] if quintile_lifetime == `i'
			local val = r(mean)
			
			if "`v'" == "tot_amt_hh" {
				insert_into_file using tabulations.txt, key(`v'_`i'_avgli) value(`val') format(%12.0fc) 
			}
			if "`v'" != "tot_amt_hh" {
				insert_into_file using tabulations.txt, key(`v'_`i'_avgli) value(`val') format(%12.1f) 
			}
		
			* Values by consumption quintile and income quintile
			forvalues j = 0/4 {
				
				summ `v' [aw=wtfam] if quintile_income == `i' & quintile_consumption == `j'
				local val = r(mean)
				
				if "`v'" == "tot_amt_hh" {
					insert_into_file using tabulations.txt, key(`v'_`i'_`j') value(`val') format(%12.0fc) 
				}
				if "`v'" != "tot_amt_hh" {
					insert_into_file using tabulations.txt, key(`v'_`i'_`j') value(`val') format(%12.1f) 
				}
				
			}
			
			* Values by lifetime quintile and income quintile
			forvalues j = 0/4 {
				
				summ `v' [aw=wtfam] if quintile_income == `i' & quintile_lifetime == `j'
				local val = r(mean)
				
				if "`v'" == "tot_amt_hh" {
					insert_into_file using tabulations.txt, key(`v'_`i'_`j'l) value(`val') format(%12.0fc) 
				}
				if "`v'" != "tot_amt_hh" {
					insert_into_file using tabulations.txt, key(`v'_`i'_`j'l) value(`val') format(%12.1f) 
				}
				
			}
		}
	}
	
	* Receipt conditional on eligibility
	forvalues i = 0/4 {
		
		* Values by income quintile
		summ snap100 [aw=wtfam] if quintile_income == `i' & eligsim_snap == 1
		local val = r(mean)
		
		insert_into_file using tabulations.txt, key(snapifelig_`i'_avginc) value(`val') format(%12.1f) 
		
		* Values by consumption quintile
		summ snap100 [aw=wtfam] if quintile_consumption == `i' & eligsim_snap == 1
		local val = r(mean)
		
		insert_into_file using tabulations.txt, key(snapifelig_`i'_avgc) value(`val') format(%12.1f) 
		
		* Values by lifetime quintile
		summ snap100 [aw=wtfam] if quintile_lifetime == `i' & eligsim_snap == 1
		local val = r(mean)
		
		insert_into_file using tabulations.txt, key(snapifelig_`i'_avgli) value(`val') format(%12.1f) 
	
		* Values by consumption quintile and income quintile
		forvalues j = 0/4 {
			
			summ snap100 [aw=wtfam] if quintile_income == `i' & quintile_consumption == `j' & eligsim_snap == 1
			local val = r(mean)
			
			insert_into_file using tabulations.txt, key(snapifelig_`i'_`j') value(`val') format(%12.1f) 
			
		}
		
		* Values by lifetime income quintile and income quintile
		forvalues j = 0/4 {
			
			summ snap100 [aw=wtfam] if quintile_income == `i' & quintile_lifetime == `j' & eligsim_snap == 1
			local val = r(mean)
			
			insert_into_file using tabulations.txt, key(snapifelig_`i'_`j'l) value(`val') format(%12.1f) 
			
		}
	}

*** Save tables

	cat tabulations.txt
	
	cd "$dir/code"

	table_from_tpl, t(../tables/template/tabulations_template.tex) ///
					r(../tables/data/tabulations.txt) ///
					o(../tables/output/tabulations_final.tex) 
						
	cd "$dir"
	
	exit
