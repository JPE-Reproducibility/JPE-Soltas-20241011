/***************************************************************************
 * Appendix Figure A18: Relationship of Self-Targeting Estimates to Transfer Characteristics
 * 
 * Description:
 * This script constructs a series of program-level scatterplots that relate 
 * self-targeting estimates (from Equation 4) to transfer program characteristics. 
 * Each point represents a transfer program. The four panels compare the self-targeting
 * estimate to: (1) the mean consumption rank of recipients, (2) the mean current-income
 * rank of recipients, (3) the share of the population simulated to be eligible, and 
 * (4) the selectivity of simulated eligibility, measured as the coefficient on 
 * eligibility in a regression of consumption rank on eligibility and current-income 
 * spline controls.
 * 
 * The script computes means and regression coefficients for each program, then
 * generates a 2x2 panel of scatterplots labeled by program name. 
 * Confidence intervals are plotted for both axes where applicable.
 * 
 * Inputs:
 * - PSID-based dataset with eligibility and rank measures (`"$dir/data/psid_base"`)
 * - Eligibility simulation script (`run_all_eligsims`)
 * 
 * Outputs:
 * - Combined figure with four panels (`"$dir/figures/across_program_comparison.pdf"`)
 ***************************************************************************/


* Settings

	do code/settings.do
	
	use "$dir/data/psid_base", clear
		
	* Create basis spline for rk_current_eq
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
		
	* Generate eligibility variables
	run_all_eligsims
	
* Grab program variables

	local i = 0
	mat b = J(8,7,.)
	
	foreach p of varlist snap ssi wic liheap tanf housing_assistance medicaid schoolmeals {
		
		local i = `i'+1
		
		* Means
		
		summ rk_c_current_eq if eligsim_`p'==1 [aw=wtfam]
		mat b[`i',1] = r(mean)
		
		summ rk_current_eq if eligsim_`p'==1 [aw=wtfam]
		mat b[`i',2] = r(mean)
		
		summ eligsim_`p' [aw=wtfam]
		mat b[`i',3] = r(mean)
	
		* Regression coefficients
		
		reg rk_c_current_eq `p' bs_rk* if eligsim_`p'==1 [pw=wtfam], cl(famid_orig)
		mat b[`i',4] = _b[`p']
		mat b[`i',5] = _se[`p']
	
		reg rk_c_current_eq eligsim_`p' bs_rk* [pw=wtfam], cl(famid_orig)
		mat b[`i',6] = _b[eligsim_`p']
		mat b[`i',7] = _se[eligsim_`p']
		
	}

* Make figures

	clear
	svmat b
	
	rename (b1 b2 b3 b4 b5 b6 b7) (mean_rk_cons mean_rk_inc sh_eligsim coef_takeup se_takeup coef_eligsim se_eligsim)
	replace sh_eligsim = sh_eligsim*100
	
	gen progname = ""
	replace progname = "SNAP" if _n == 1
	replace progname = "SSI" if _n == 2
	replace progname = "WIC" if _n == 3
	replace progname = "LIHEAP" if _n == 4
	replace progname = "TANF" if _n == 5
	replace progname = "Housing" if _n == 6
	replace progname = "Medicaid" if _n == 7
	replace progname = "School Meals" if _n == 8
	
	foreach x in takeup eligsim {
		gen lo_`x' = coef_`x' - 1.96*se_`x'
		gen hi_`x' = coef_`x' + 1.96*se_`x'	
	}
	
	tw scatter coef_takeup mean_rk_cons, mlabel(progname) color(navy) || ///
		rcap lo_takeup hi_takeup mean_rk_cons, color(navy) || ///
		lfit coef_takeup mean_rk_cons, lcolor(gs9) lpattern(dash) legend(off) ///
		graphregion(color(white)) ylabel(,nogrid angle(horizontal)) ///
		xtitle("Mean Consumption Rank") ytitle("Self-Targeting Estimate") name(gr1, replace)
		
	tw scatter coef_takeup mean_rk_inc, mlabel(progname) color(navy) || ///
		rcap lo_takeup hi_takeup mean_rk_inc, color(navy) || ///
		lfit coef_takeup mean_rk_inc, lcolor(gs9) lpattern(dash) legend(off) ///
		graphregion(color(white)) ylabel(,nogrid angle(horizontal)) ///
		xtitle("Mean Current Income Rank") ytitle("Self-Targeting Estimate") name(gr2, replace)
	
	tw scatter coef_takeup sh_eligsim, mlabel(progname) color(navy) || ///
		rcap lo_takeup hi_takeup sh_eligsim, color(navy) || ///
		lfit coef_takeup sh_eligsim, lcolor(gs9) lpattern(dash) legend(off) ///
		graphregion(color(white)) ylabel(,nogrid angle(horizontal)) ///
		xtitle("Percent Eligible in Population") ytitle("Self-Targeting Estimate") name(gr3, replace)
		
	tw scatter coef_takeup coef_eligsim, mlabel(progname) color(navy) mlabp(2) mlabgap(4pt) || ///
		rcap lo_takeup hi_takeup coef_eligsim, color(navy) || ///
		rcap lo_eligsim hi_eligsim coef_takeup, color(navy) horizontal || ///
		lfit coef_takeup coef_eligsim, lcolor(gs9) lpattern(dash) legend(off) ///
		graphregion(color(white)) ylabel(,nogrid angle(horizontal)) ///
		xtitle("Eligibility Beta") ytitle("Self-Targeting Estimate") name(gr4, replace)
	
	gr combine gr1 gr2 gr3 gr4, rows(2) cols(2) graphregion(color(white))
	
	gr export "$dir/figures/across_program_comparison.pdf", replace
