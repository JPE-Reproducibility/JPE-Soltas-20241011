/***************************************************************************
 * Appendix Table A10: Consumption and Consumer Durable Good Ownership 
 * Appendix Table A12: Sensitivity of Self-Targeting on Consumption to Income Mismeasurement (CEX)
 * 
 * Description:
 * This script analyzes the relationship between transfer receipt and well-measured
 * consumption (log levels of reported consumption) as well as consumer durable 
 * goods ownership. The focus is on simulated-eligible individuals, controlling
 * flexibly for current-income rank using cubic basis splines. The script produces
 * estimates of the predictive effect of transfer receipt on various consumption 
 * outcomes and durable goods ownership for each transfer program.
 * 
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base.dta"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * - Stata-TeX helper and settings scripts (`code/stata-tex.do`, `code/settings`)
 * 
 * Outputs:
 * - Table A10: "Well-Measured Consumption and Transfer Receipt" 
 *   (Estimates for consumption, conditional on transfer receipt and income rank)
 * - Table A12: "Durable-Goods Ownership and Transfer Receipt"
 *   (Estimates for durable-goods ownership, conditional on transfer receipt and income rank)
 * - CSV file with regression results (`"$dir/tables/data/wellmeasured_consumption_durables.csv"`) 
 ***************************************************************************/ 

* Set working directory

	do code/settings
	do "$dir/code/stata-tex.do"
	set more off
	
* Load data

	use "$dir/data/psid_base.dta", clear
	
	run_all_eligsims
	
	rename housing_assistance ha
	rename eligsim_housing eligsim_ha
	
* Create basis spline for rk_current_eq
		
	* Create list
	local refpts 0 10 25 50 100
	
	* Create basis spline
	frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
	
* Clean up consumption data	

	* Remove lease values for 1997
	replace veh_leaseval_exp = . if year == 1997

	rename oer oer_exp
	egen cons_wellmeasured = rowtotal(gasoline_exp utility_exp foodathome_exp veh_leaseval_exp oer_exp)
	
	foreach v in gasoline utility foodathome veh_leaseval oer {		
		gen l`v'_eq = ln(`v'_exp / equivalence_scale)		
	}
	
	drop veh_leaseval_exp equivalence_scale
	rename oer_exp oer
	
* "Well-measured" consumption regressions
	cd "$dir/tables/data"
  
	foreach transfer of varlist snap medicaid ha wic ssi schoolmeals tanf liheap {
		
		foreach outcome in gasoline utility foodathome veh_leaseval oer {
			
			reg l`outcome'_eq `transfer' bs_rk* if eligsim_`transfer'==1 [pw=wtfam], cl(famid_orig)
			store_est_tpl using wellmeasured_consumption_durables.csv, coef(`transfer') name(`outcome'_`transfer') all
			
		}		
	}

* Run through consumer durables regressions

	foreach transfer of varlist snap medicaid ha wic ssi schoolmeals tanf liheap {
		
		foreach outcome in ownhome owncar aircond computer smartphone {
			
			reg `outcome' `transfer' bs_rk* if eligsim_`transfer'==1 [pw=wtfam], cl(famid_orig)
			store_est_tpl using wellmeasured_consumption_durables.csv, coef(`transfer') name(`outcome'_`transfer') all
			
		}
		
		reghdfe rooms `transfer' bs_rk* if eligsim_`transfer'==1 [pw=wtfam], a(hhsize) cl(famid_orig)
		store_est_tpl using wellmeasured_consumption_durables.csv, coef(`transfer') name(rooms_`transfer') all
		
	}

*** Create tables

	cap erase "../tables/output/durable_good_ownership.tex"
	
	cd "$dir/code"

	table_from_tpl, t("../tables/template/durable_good_ownership_template.tex") ///
					r("../tables/data/wellmeasured_consumption_durables.csv") ///
					o("../tables/output/durable_good_ownership.tex") 

	cat "../tables/output/well_measured_c.tex"
	
	cd "$dir/code"

	table_from_tpl, t("../tables/template/well_measured_c_template.tex") ///
					r("../tables/data/wellmeasured_consumption_durables.csv") ///
					o("../tables/output/well_measured_c.tex") 
					
	cd "$dir"
