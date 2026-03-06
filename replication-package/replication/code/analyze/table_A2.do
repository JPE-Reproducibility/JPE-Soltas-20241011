/***************************************************************************
 * SNAP Receipt, Eligibility, and Take-Up Rates by Income and Consumption Quintile: Consumer Expenditure Survey
 * Appendix Table A2
 * 
 * Description:
 * This script loads harmonized CEX data, assigns individuals to quintiles
 * of income and consumption, and computes average household
 * transfers received (e.g., SNAP) and simulated eligibility rates across these
 * quintiles. It also calculates participation rates conditional on eligibility. 
 * The results are tabulated and saved in a structured text file for later inclusion 
 * in a LaTeX table.
 * 
 * Inputs:
 * - Harmonized CEX data (`"$dir/code/clean/cex/process_cex.do"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * 
 * Outputs:
 * - Formatted text file with tabulated means (`"$dir/tables/data/tabulations_cex.txt"`)
 * - Final LaTeX table compiled from template (`"$dir/tables/output/tabulations_cex_final.tex"`)
 * 
 ***************************************************************************/ 

*** Settings

	do "code/settings"

*** Process CEX

	use "$dir/data/cex/raw/workfile.dta", clear
	
	keep if !missing(rk_inc) | !missing(rk_cons)
	
*** Prepare variables for tabulation
	
	* Generate quintile bins
	gen quintile_consumption = floor(rk_cons/20.001)
	gen quintile_income = floor(rk_inc/20.001)

	* Format variables

	gen eligsim_snap100 = eligsim_snap*100
	gen snap100 = snap*100
	format snap100 eligsim_snap100 %8.1f

*** Preview of the tabulations	
	
	tab quintile_consumption quintile_income [aw=finl], summ(snap100) nofreq nost noo
	tab quintile_consumption quintile_income [aw=finl], summ(eligsim_snap100) nofreq nost noo
	tab quintile_consumption quintile_income if eligsim_snap==1 [aw=finl], summ(snap100) nofreq nost noo
	
cd "$dir/tables/data"

	foreach v of varlist snap100 eligsim_snap100 {
		forvalues i = 0/4 {
			
			summ `v' [aw=finl] if quintile_income == `i'
			local val = r(mean)
			
			insert_into_file using tabulations_cex.txt, key(`v'_`i'_avginc) value(`val') format(%12.1f) 
			
			summ `v' [aw=finl] if quintile_consumption == `i'
			local val = r(mean)
			
			insert_into_file using tabulations_cex.txt, key(`v'_`i'_avgc) value(`val') format(%12.1f) 
		
			forvalues j = 0/4 {
				
				summ `v' [aw=finl] if quintile_income == `i' & quintile_consumption == `j'
				local val = r(mean)
				
				insert_into_file using tabulations_cex.txt, key(`v'_`i'_`j') value(`val') format(%12.1f) 
			
				
			}
		}
	}
	
	forvalues i = 0/4 {
		
		summ snap100 [aw=finl] if quintile_income == `i' & eligsim_snap == 1
		local val = r(mean)
		
		insert_into_file using tabulations_cex.txt, key(snapifelig_`i'_avginc) value(`val') format(%12.1f) 
		
		summ snap100 [aw=finl] if quintile_consumption == `i' & eligsim_snap == 1
		local val = r(mean)
		
		insert_into_file using tabulations_cex.txt, key(snapifelig_`i'_avgc) value(`val') format(%12.1f) 
	
		forvalues j = 0/4 {
			
			summ snap100 [aw=finl] if quintile_income == `i' & quintile_consumption == `j' & eligsim_snap == 1
			local val = r(mean)
			
			insert_into_file using tabulations_cex.txt, key(snapifelig_`i'_`j') value(`val') format(%12.1f) 
			
		}
	}
	

*** Save tables

	cat tabulations_cex.txt
	
	cd "$dir/code"

	table_from_tpl, t(../tables/template/tabulations_cex_template.tex) ///
					r(../tables/data/tabulations_cex.txt) ///
					o(../tables/output/tabulations_cex_final.tex) 
						
	cd "$dir"
	
	exit

