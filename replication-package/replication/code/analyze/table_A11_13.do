/***************************************************************************
 * Appendix Table A11: Well-Measured Consumption and Transfer Receipt (CEX)
 * Appendix Table A13: Durable-Goods Ownership and Transfer Receipt (CEX)
 * 
 * Description:
 * This script creates a table that reports estimates of the predictive effect of transfer receipt on (log) levels of reported consumption/measures of household durable-goods ownership, conditional on current-income rank and being
 * simulated-eligible for the transfer.
 * 
 * Inputs:
 * - CEX-based dataset: `"$dir/data/cex/raw/workfile.dta"`
 * 
 * Outputs:
 * - Appendix Table A11 and A13 (`"$dir/tables/output/well_measured_cex.tex"`)
***************************************************************************/

* Set working directory

	do "$dir/code/settings"
	do "$dir/code/stata-tex.do"
	set more off
	
* Load data

	use "$dir/data/cex/raw/workfile.dta", clear
	
* Compute Rent/OER

	gen oer = .
	replace oer = 3 * equivrent if owns_home == 1 & !missing(equivrent)
	replace oer = rntxrpcq + rntxrppq if (!missing(rntxrpcq) | !missing(rntxrppq)) & missing(oer)
	replace oer = 100 * oer / (cpi * n_people)
		
* Create basis spline for rk_inc
		
	* Create list
	local refpts 0 10 25 50 100
	
	* Create basis spline
	frencurv, gen(bs_rk) x(rk_inc) p(3) refpts(`refpts') omit(0)
	
* "Well-measured" consumption regressions

	cd "$dir/tables/data"

	foreach transfer of varlist snap medicaid housing_assistance ssi tanf {
		
		foreach outcome in oer lease_cost_pred gasoline utility_exp food_at_home  {
			
			ppmlhdfe `outcome' `transfer' bs_rk* if eligsim_`transfer'==1 [pw=finl], cl(cuid)
			store_est_tpl using wellmeasured_consumption_durables_cex.csv, coef(`transfer') name(`outcome'_`transfer') all
			
		}
		
	}

* Run through consumer durables regressions

	foreach transfer of varlist snap medicaid housing_assistance ssi tanf {
		
		foreach outcome in owns_home owns_car central_ac computer {
			
			reg `outcome' `transfer' bs_rk* if eligsim_`transfer'==1 [pw=finl], cl(cuid)
			store_est_tpl using wellmeasured_consumption_durables_cex.csv, coef(`transfer') name(`outcome'_`transfer') all
			
		}
		
		reghdfe nrooms `transfer' bs_rk* if eligsim_`transfer'==1 [pw=finl], a(hhsize) cl(cuid)
		store_est_tpl using wellmeasured_consumption_durables_cex.csv, coef(`transfer') name(rooms_`transfer') all
		
	}

*** Create tables

	cap erase "../tables/output/durable_good_ownership_cex.tex"
	
	cd "$dir/code"

	table_from_tpl, t("../tables/template/durable_good_ownership_cex_template.tex") ///
					r("../tables/data/wellmeasured_consumption_durables_cex.csv") ///
					o("../tables/output/durable_good_ownership_cex.tex") 

	cat "../tables/output/well_measured_c.tex"
	
	cd "$dir/code"

	table_from_tpl, t("../tables/template/well_measured_cex_template.tex") ///
					r("../tables/data/wellmeasured_consumption_durables_cex.csv") ///
					o("../tables/output/well_measured_cex.tex") 
					
	cd "$dir"
