/***************************************************************************
 * Appendix Table 9: Sensitivity of Self-Targeting on Consumption to Income Mismeasurement (CEX)
 *
 * Description:
 * The script creates a table that reports estimates of the predictive effect of transfer receipt on lifetime-income rank, conditional on current-income income rank. The script reports coefficients based on different levels of      
 * constrains on the Rank-Rank slope.
 * Inputs:
 * - CEX-based dataset: `"$dir/data/cex/raw/workfile.dta"`
 * 
 * Outputs:
 * - Appendix Table 9 (`"$dir/tables/output/constrained_reg_cex_final.tex"`)
***************************************************************************/		

* Settings

	do code/settings.do
	do "$dir/code/stata-tex.do"
	
* Load data 

	use "$dir/data/cex/raw/workfile.dta", clear
	
	egen anytransfer = rowmax(snap medicaid ssi housing_assistance tanf)
	egen eligsim_anytransfer = rowmax(eligsim_snap eligsim_medicaid eligsim_ssi eligsim_housing eligsim_tanf) 
	
	rename (eligsim_housing_assistance housing_assistance) (eligsim_ha ha)
	
* Unconstrained baseline

cd "$dir/tables/data"

* weights too big - rescale 
replace finlwt21 = finlwt21 / 1000

foreach prog in anytransfer snap medicaid ssi ha tanf  {		

	reg rk_cons rk_inc `prog' if eligsim_`prog'==1 [pw=finlwt21], cl(cuid)
  local rc_`prog' = _b[rk_inc]         
	store_est_tpl using constrained_reg_cex.csv, coef(rk_inc) name(`prog'_c_rr) all format(%6.2fc) 
	store_est_tpl using constrained_reg_cex.csv, coef(`prog') name(`prog'_c_unc) all format(%6.2fc) 
	
}

* Constrain coefficient 
* Start simple with just the coefficient restriction, can transform later


* preferred: from abowd factor 
* reliability ratio from abowd paper: 0.7 
local abowd_factor = 0.7

	foreach prog in snap medicaid ssi ha tanf anytransfer {		
    constraint 1 rk_inc = `= min(`rc_`prog''  / `abowd_factor', 1) '		
		cnsreg rk_cons `prog' rk_inc if eligsim_`prog'==1 [pw=finlwt21], cl(cuid) constraint(1)
		store_est_tpl using constrained_reg_cex.csv, coef(`prog') name(`prog'_c_preferred) all format(%6.2fc) 
		
	}

local i = 0

forvalues c = 0.5(0.1)1 {
	
	di "`i'"
	
	local i = `i'+1
	constraint 1 rk_inc = `c'

	foreach prog in snap medicaid ssi ha tanf anytransfer {		
		
		cnsreg rk_cons `prog' rk_inc if eligsim_`prog'==1 [pw=finlwt21], cl(cuid) constraint(1)
		store_est_tpl using constrained_reg_cex.csv, coef(`prog') name(`prog'_c_`i') all format(%6.2fc) 
		
	}
	
}


*** Save tables

	cd "$dir/tables/data"

	cat constrained_reg_cex.csv
	
	cd "$dir/code"

	table_from_tpl, t(../tables/template/constrained_reg_cex_template.tex) ///
					r(../tables/data/constrained_reg_cex.csv) ///
					o(../tables/output/constrained_reg_cex_final.tex) 
						
	cd "$dir"
	
	exit



