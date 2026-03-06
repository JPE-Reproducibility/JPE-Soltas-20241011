/***************************************************************************
 * Figure A15: Distributional Decompositions of Self-Targeting by Consumption Ventile
 * 
 * Description:
 * This script generates Figure A14, which shows heterogeneity in the 
 * relationship between transfer receipt and resource rank across the 
 * distribution of consumption and income. The figure includes:
 * 
 * - Panel A: Consumption (PSID)
 * - Panel B: Lifetime-income rank (PSID)
 * - Panel C: Consumption (CEX)
 * 
 * The dependent variable in each regression is a consumption or lifetime-
 * income ventile dummy (e.g., 1{rank ∈ [a,b)}), and the key independent 
 * variable is transfer receipt (SNAP or Medicaid), conditional on 
 * current-income rank (flexibly controlled using basis splines).
 * 
 * Inputs:
 * - PSID harmonized panel (`"$dir/data/psid_base.dta"`)
 * - CEX harmonized file (`"$dir/data/cex/raw/workfile.dta"`)
 * - Eligibility simulation results via `run_all_eligsims`
 * 
 * Outputs:
 * - Graphs `distribreg_gr1`, `distribreg_gr2`, and `distribreg_gr3`
 * - Composite figure exported to PDF at: `"$dir/figures/distrib_reg.pdf"`]
 ***************************************************************************/

*** PSID

* Load data

	do code/settings

	use "$dir/data/psid_base", clear
	
	run_all_eligsims
	
	* Limit sample to having ranks
	keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

	rename eligsim_housing eligsim_ha
	rename housing_assistance ha

* Create basis spline for rk_current_eq
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
		
* Run regressions	

	forvalues r = 5(5)100 {
		gen rkgrp_`r' = rk_c_current_eq >= `r'-5 & rk_c_current_eq < `r'
	}
	
	replace rkgrp_100 = 1 if rk_c_current_eq==100
	
	mat coefs = J(20,8,.)
	
	forvalues r = 5(5)100 {
		
		reg rkgrp_`r' snap bs_rk* if eligsim_snap==1 [pw=wtfam], cl(famid_orig)
		mat coefs[`r'/5,1] = _b[snap]
		mat coefs[`r'/5,2] = _se[snap]
		
		reg rkgrp_`r' medicaid bs_rk* if eligsim_medicaid==1 [pw=wtfam], cl(famid_orig)
		mat coefs[`r'/5,3] = _b[medicaid]
		mat coefs[`r'/5,4] = _se[medicaid]
		
		
	}
	
	drop rkgrp*
	
	forvalues r = 5(5)100 {
		gen rkgrp_`r' = rk_lifetime_eq >= `r'-5 & rk_lifetime_eq < `r'
	}
	
	replace rkgrp_100 = 1 if rk_lifetime_eq==100
		
	forvalues r = 5(5)100 {
		
		reg rkgrp_`r' snap bs_rk* if eligsim_snap==1 [pw=wtfam], cl(famid_orig)
		mat coefs[`r'/5,5] = _b[snap]
		mat coefs[`r'/5,6] = _se[snap]
		
		reg rkgrp_`r' medicaid bs_rk* if eligsim_medicaid==1 [pw=wtfam], cl(famid_orig)
		mat coefs[`r'/5,7] = _b[medicaid]
		mat coefs[`r'/5,8] = _se[medicaid]
		
	}
	
* Plot results

	clear
	svmat coefs
	
	gen x = 5*_n - 2.5
	rename (coefs1-coefs8) (b_snap_c se_snap_c b_medicaid_c se_medicaid_c b_snap_li se_snap_li b_medicaid_li se_medicaid_li)
	
	foreach y in c li {
	foreach p in snap medicaid {
		gen lo_`p'_`y' = b_`p'_`y' - 1.96*se_`p'_`y'
		gen hi_`p'_`y' = b_`p'_`y' + 1.96*se_`p'_`y'
	}
	}
	
	tw line b_snap_c b_medicaid_c x, lcolor(navy maroon) lpattern(solid dash) lwidth(medthick medthick) || rarea lo_snap_c hi_snap_c x, color(navy%30) lwidth(none) || rarea lo_medicaid_c hi_medicaid_c x, color(maroon%30) lwidth(none) || , graphregion(color(white) lcolor(white)) ylabel(,nogrid angle(horizontal)) yline(0, lcolor(gs9)) xtitle("Consumption Percentile") ytitle("Effect of Receipt on Probability") legend(region(lwidth(none)) col(1) order(1 "SNAP" 2 "Medicaid") size(medsmall) ring(0) position(1) bmargin(medsmall) ) name(distribreg_gr1, replace)  title("Panel A: Consumption (PSID)", color(black) size(medsmall))
		
	tw line b_snap_li b_medicaid_li x, lcolor(navy maroon) lpattern(solid dash)  lwidth(medthick medthick) || rarea lo_snap_li hi_snap_li x, color(navy%30) lwidth(none) || rarea lo_medicaid_li hi_medicaid_li x, color(maroon%30) lwidth(none) || , graphregion(color(white) lcolor(white)) ylabel(,nogrid angle(horizontal)) yline(0, lcolor(gs9)) xtitle("Lifetime Income Percentile") ytitle("Effect of Receipt on Probability") legend(region(lwidth(none)) col(1) order(1 "SNAP" 2 "Medicaid") size(medsmall) ring(0) position(1) bmargin(medsmall) ) name(distribreg_gr2, replace)  title("Panel B: Lifetime Income (PSID)", color(black) size(medsmall))
		
*** CEX

	use "$dir/data/cex/raw/workfile.dta", clear
	
	rename eligsim_housing eligsim_ha
	rename housing_assistance ha
	
* Create basis spline for rk_inc
	
	* Create list
	local refpts 0 10 25 50 100
	
	* Create basis spline
	frencurv, gen(bs_rk) x(rk_inc) p(3) refpts(`refpts') omit(0)

* Run regressions	

	forvalues r = 5(5)100 {
		gen rkgrp_`r' = rk_cons >= `r'-5 & rk_cons < `r'
	}
	
	replace rkgrp_100 = 1 if rk_cons==100
	
	mat coefs = J(20,4,.)
	
	forvalues r = 5(5)100 {
		
		reg rkgrp_`r' snap bs_rk* if eligsim_snap==1 [pw=finlwt21], cl(cuid)
		mat coefs[`r'/5,1] = _b[snap]
		mat coefs[`r'/5,2] = _se[snap]
		
		reg rkgrp_`r' medicaid bs_rk* if eligsim_medicaid==1 [pw=finlwt21], cl(cuid)
		mat coefs[`r'/5,3] = _b[medicaid]
		mat coefs[`r'/5,4] = _se[medicaid]
		
		
	}

* Plot results

	clear
	svmat coefs
	
	gen x = 5*_n - 2.5
	rename (coefs1-coefs4) (b_snap_c se_snap_c b_medicaid_c se_medicaid_c)
	
	foreach p in snap medicaid {
		gen lo_`p'_c = b_`p'_c - 1.96*se_`p'_c
		gen hi_`p'_c = b_`p'_c + 1.96*se_`p'_c
	}
	
	tw line b_snap_c b_medicaid_c x, lcolor(navy maroon) lpattern(solid dash) lwidth(medthick medthick) || rarea lo_snap_c hi_snap_c x, color(navy%30) lwidth(none) || rarea lo_medicaid_c hi_medicaid_c x, color(maroon%30) lwidth(none) || , graphregion(color(white) lcolor(white)) ylabel(,nogrid angle(horizontal)) yline(0, lcolor(gs9)) xtitle("Consumption Percentile") ytitle("Effect of Receipt on Probability ") legend(region(lwidth(none)) col(1) order(1 "SNAP" 2 "Medicaid") size(medsmall) ring(0) position(1) bmargin(medsmall) ) name(distribreg_gr3, replace) title("Panel C: Consumption (CEX)", color(black) size(medsmall))
	
	
	grc1leg distribreg_gr1 distribreg_gr2 distribreg_gr3, graphregion(color(white)) legend(distribreg_gr1) pos(4) ring(0)
	gr export "$dir/figures/distrib_reg.pdf", replace

	