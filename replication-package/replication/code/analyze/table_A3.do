/***************************************************************************
 * Appendix Table A3: Dollars and Percentage Differences Between Recipients and Similar-Income Non-Recipients
 * 
 * Description:
 * This script estimates differences in economic outcomes by transfer
 * participation, controlling flexibly for income using spline controls. 
 * Outcomes include:
 *   - Log levels (via Poisson regression): interpretable as approximate %
 *     differences in per-capita outcomes.
 *   - Levels in per-capita dollars (via average marginal effects).
 * 
 * Separate estimates are generated for the PSID and CEX samples. Results 
 * are stored in a CSV file and formatted for inclusion in the appendix.
 * 
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base"`)
 * - Harmonized CEX data (`"$dir/data/cex/raw/workfile.dta"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * - Stata-TeX helper and settings scripts (`code/stata-tex.do`, `code/settings`)
 * 
 * Outputs:
 * - CSV file with regression results (`"$dir/tables/data/levels_outcomes.csv"`)
 * - Formatted LaTeX table (`"$dir/tables/output/levels_outcomes.tex"`)
 ***************************************************************************/

*** PSID analysis

* Load data

	do code/settings

	use "$dir/data/psid_base", clear
	
	run_all_eligsims
	
	rename housing_assistance ha
	rename eligsim_housing eligsim_ha
	
* Construct per-capita outcomes

	gen income_real_pc = faminct_real / hhsize
	gen consumption_real_pc = consumption_real / hhsize
	gen lifetime_income_real_pc = lifetime_income_hh / hhsize
	
	gen lincome_real_pc = ln(income_real_pc+1)
	
* Create basis spline for rk_current_eq

	qui summ income_real_pc if eligsim_snap==1 [aw=wtfam]
	
	local lev_2500 = ln(2500)
	local lev_5000 = ln(5000)
	local lev_10000 = ln(10000)
	local max = ln(r(max))
	
	* Create list
	local refpts 0 `lev_2500' `lev_5000' `lev_10000' `max'
	
	* Create basis spline
	frencurv, gen(bs_rk) x(lincome_real_pc) p(3) refpts(`refpts') omit(0)

* Run regressions	

	cd "$dir/tables/data"

	foreach outcome of varlist consumption_real_pc lifetime_income_real_pc {
		
		if "`outcome'" == "consumption_real_pc" {
		local oc = "cons"
		}
		if "`outcome'" == "lifetime_income_real_pc" {
		local oc = "lifetime"
		}
		
		foreach p of varlist snap medicaid ha tanf ssi schoolmeals wic liheap {
					
			poisson `outcome' `p' bs_rk* if eligsim_`p'==1 [pw=wtfam], cl(famid_orig) 
			store_est_tpl using levels_outcomes.csv, coef(`p') name(ldiff_`p'_`oc') all format(%8.3f)
						
			poisson `outcome' `p' bs_rk* if eligsim_`p'==1 [pw=wtfam], cl(famid_orig)
			margins, dydx(`p') post
			store_est_tpl using levels_outcomes.csv, coef(`p') name(diff_`p'_`oc') all format(%8.0fc)
			
		}
		
	}
	
*** CEX analysis

* Load data

	use "$dir/data/cex/raw/workfile.dta", clear
	
	rename housing_assistance ha
	rename eligsim_housing eligsim_ha
	
* Construct per-capita outcomes

	gen income_real_pc = 100 * fincbtax / (cpi*hhsize)
	gen consumption_real_pc = 100 * max(0,cons_a) / (cpi*hhsize)
	
	gen lincome_real_pc = ln(income_real_pc+1)
	
* Create basis spline for rk_current_eq

	qui summ income_real_pc if eligsim_snap==1 [aw=finlwt21]
	
	local lev_2500 = ln(2500)
	local lev_5000 = ln(5000)
	local lev_10000 = ln(10000)
	local max = ln(r(max))
	
	* Create list
	local refpts 0 `lev_2500' `lev_5000' `lev_10000' `max'
	
	* Create basis spline
	frencurv, gen(bs_rk) x(lincome_real_pc) p(3) refpts(`refpts') omit(0)

* Run regressions	

	cd "$dir/tables/data"
			
	foreach p of varlist snap medicaid ha tanf ssi {
				
		poisson consumption_real_pc `p' bs_rk* if eligsim_`p'==1 [pw=finlwt21], cl(cuid) 
		store_est_tpl using levels_outcomes.csv, coef(`p') name(ldiff_`p'_cex) all format(%8.3f)
					
		poisson consumption_real_pc `p' bs_rk* if eligsim_`p'==1 [pw=finlwt21], cl(cuid)
		margins, dydx(`p') post
		store_est_tpl using levels_outcomes.csv, coef(`p') name(diff_`p'_cex) all format(%8.0fc)
		
	}
	
*** Create tables

	cap erase "../tables/output/levels_outcomes.tex"
	
	cd "$dir/code"

	table_from_tpl, t("../tables/template/levels_outcomes_template.tex") ///
					r("../tables/data/levels_outcomes.csv") ///
					o("../tables/output/levels_outcomes.tex") 
					
	cd "$dir"
