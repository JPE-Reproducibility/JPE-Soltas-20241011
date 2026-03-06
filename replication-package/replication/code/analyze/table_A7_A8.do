/***************************************************************************
 * Appendix Table 7: Sensitivity of Self-Targeting on Consumption to Income Mismeasurement (PSID)
 * Appendix Table 8: Sensitivity of Self-Targeting on Lifetime Income to Income Mismeasurement (PSID)
 *
 * Description:
 * The script creates a table that reports estimates of the predictive effect of transfer receipt on consumption rank, conditional on current-income/lifetime income rank. The script reports coefficients based on different levels of      
 * constrains on the Rank-Rank slope.
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base"`)
 * 
 * Outputs:
 * - Appendix Table 7 and 8 (`"$dir/tables/output/constrained_reg_final.tex"`)
***************************************************************************/		

* Settings

	do code/settings.do
	do "$dir/code/stata-tex.do"
	
* Load data 

	use "$dir/data/psid_base", clear
	
	run_all_eligsims
 
	rename (eligsim_housing_assistance housing_assistance) (eligsim_ha ha)
	
* Unconstrained baseline

cd "$dir/tables/data"

foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf  {		
	foreach spec in "_c" "_li" {

		if "`spec'" != "_c" {
			
			reg rk_lifetime_eq rk_current_eq `prog' if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig)
      local rl_`prog' = _b[rk_current_eq] 
			store_est_tpl using constrained_reg.csv, coef(rk_current_eq) name(`prog'_li_rr) all format(%6.2fc) 
			store_est_tpl using constrained_reg.csv, coef(`prog') name(`prog'_li_unc) all format(%6.2fc) 
			
		}
		if "`spec'" == "_c" {
			
			reg rk_c_current_eq rk_current_eq `prog' if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig)
      local rc_`prog' = _b[rk_current_eq]       
			store_est_tpl using constrained_reg.csv, coef(rk_current_eq) name(`prog'_c_rr) all format(%6.2fc) 
			store_est_tpl using constrained_reg.csv, coef(`prog') name(`prog'_c_unc) all format(%6.2fc) 
			
		}
		
	}
	
}

* constrained to preferred value

* reliability ratio from abowd paper: 0.7
local abowd_factor = 0.7

	foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf  {		
		
		foreach spec in "_c" "_li" {

			if "`spec'" != "_c" {
      
      	constraint 1 rk_current_eq = `=min(`rl_`prog''  / `abowd_factor',1) ' 
				
				cnsreg rk_lifetime_eq `prog' rk_current_eq if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) constraint(1)
				store_est_tpl using constrained_reg.csv, coef(`prog') name(`prog'_li_preferred) all format(%6.2fc) 
				
			}
			if "`spec'" == "_c" {
      	constraint 1 rk_current_eq = `=min(`rc_`prog''  / `abowd_factor', 1) ' 
				cnsreg rk_c_current_eq `prog' rk_current_eq if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) constraint(1)
				store_est_tpl using constrained_reg.csv, coef(`prog') name(`prog'_c_preferred) all format(%6.2fc) 
			}
			
		}
		
	}

* Constrain coefficient one by one 
* Start simple with just the coefficient restriction, can transform later

local i = 0

forvalues c = 0.5(0.1)1 {
	
	di "`i'"
	
	local i = `i'+1
	constraint 1 rk_current_eq = `c'

	foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf  {		
		
		foreach spec in "_c" "_li" {

			if "`spec'" != "_c" {
				
				cnsreg rk_lifetime_eq `prog' rk_current_eq if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) constraint(1)
				store_est_tpl using constrained_reg.csv, coef(`prog') name(`prog'_li_`i') all format(%6.2fc) 
				
			}
			if "`spec'" == "_c" {
			
				cnsreg rk_c_current_eq `prog' rk_current_eq if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) constraint(1)
				store_est_tpl using constrained_reg.csv, coef(`prog') name(`prog'_c_`i') all format(%6.2fc) 
			}
			
		}
		
	}
	
}










*** Save tables

	cd "$dir/tables/data"

	cat constrained_reg.csv
	
	cd "$dir/code"

	table_from_tpl, t(../tables/template/constrained_reg_template.tex) ///
					r(../tables/data/constrained_reg.csv) ///
					o(../tables/output/constrained_reg_final.tex) 
						
	cd "$dir"
	
	exit



