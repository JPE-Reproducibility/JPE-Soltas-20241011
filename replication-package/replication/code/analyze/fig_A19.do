/***************************************************************************
 * Appendix Figure A19: Variation in Eligible Populations Does Not Explain Across-Program Heterogeneity in Self-Targeting
 *
 * Description:
 * This script estimates variation in transfer take-up among eligible households, 
 * exploring whether differences in eligible populations can explain across-program 
 * heterogeneity in self-targeting. It calculates both within-person and pooled 
 * estimates for the model:
 * 
 * $D_{i,k} = \alpha_i + \beta_k \bar{R}_i + \gamma_k R_i + u_{i,k}$,
 * where k is a transfer program.
 * 
 * The figure compares point estimates of $\beta_k$ with and without household fixed 
 * effects, showing pooled estimates relative to WIC for comparison with within-person 
 * estimates. The dashed 45-degree line indicates equality between estimates.
 * 
 * Inputs:
 * - PSID data (`"$dir/data/psid_base"`)
 * - CEX data (`"$dir/data/cex/raw/workfile.dta"`)
 * 
 * Outputs:
 * - PDF figure (`"$dir/figures/explain_heterogeneity_support.pdf"`)
 ***************************************************************************/


* Settings

	do code/settings.do
	
	use "$dir/data/psid_base", clear
		
	* Create basis spline for rk_current_eq
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)

* Reshape data to person X program long file
	
	* Generate eligibility variables
	run_all_eligsims
	rename eligsim_housing_assistance eligsim_ha
	
	* Preparatory step - rename variables
	rename snap p_snap
	rename housing_assistance p_ha
	rename medicaid p_medicaid
	rename ssi p_ssi
	rename liheap p_liheap
	rename schoolmeals p_schoolmeals
	rename tanf p_tanf
	rename wic p_wic
	
	reshape long p_ eligsim_, i(id year) j(prog) string

* Clean up long file	
	
	drop if prog == "ui"
	encode prog, gen(prog_)
	gegen idyear = group(id year)
	replace p_ = 100*p_
	
* Run regressions with and without person-year FE

	* With person-year FE
	reghdfe p_ i.prog_#c.rk_c_current_eq if eligsim_ == 1 [pw=wtfam], a(idyear prog_ i.prog_#c.bs_rk1 i.prog_#c.bs_rk3 i.prog_#c.bs_rk4 i.prog_#c.bs_rk5 i.prog_#c.bs_rk6 i.prog_#c.bs_rk7) cl(famid_orig)
	
	mat b_ = e(b)'
	mat se_ = vecdiag(e(V))'
	
	* Without person-year FE
	reghdfe p_ i.prog_#c.rk_c_current_eq if eligsim_ == 1 [pw=wtfam], a(year prog_ i.prog_#c.bs_rk1 i.prog_#c.bs_rk3 i.prog_#c.bs_rk4 i.prog_#c.bs_rk5 i.prog_#c.bs_rk6 i.prog_#c.bs_rk7) cl(famid_orig)
	
	mat b2_ = e(b)'
	mat se2_ = vecdiag(e(V))'
	
* Format results into a figure

	mat results = b_ , b2_ , se_ , se2_
	clear
	
	svmat results
	keep if _n<=8
	
	gen lo1 = results1-1.96*sqrt(results3)
	gen lo2 = results2-1.96*sqrt(results4)
	gen hi1 = results1+1.96*sqrt(results3)
	gen hi2 = results2+1.96*sqrt(results4)
	
	gen progname = ""
	replace progname = "Housing" if _n == 1
	replace progname = "LIHEAP" if _n == 2
	replace progname = "Medicaid" if _n == 3
	replace progname = "School Meals" if _n == 4
	replace progname = "SNAP" if _n == 5
	replace progname = "SSI" if _n == 6
	replace progname = "TANF" if _n == 7
	replace progname = "WIC" if _n == 8
	
	gsort results1
	
	summ results2 if progname == "WIC"
	local adj = r(mean)
	foreach v of varlist lo2 hi2 results2 {
		replace `v' = `v' - `adj'
	}
	
	tw scatter results1 results2, color(navy) mlabel(progname) mlabp(5) mlabgap(3pt) || ///
		rcap lo1 hi1 results2, color(navy) || ///
		rcap lo2 hi2 results1, horizontal color(navy) || line results1 results1, color(gs9) lpattern(dash) ///
		aspect(1) graphregion(color(white)) ylabel(-0.2(0.2)1, nogrid angle(horizontal)) ///
		xscale(range(-0.2 1)) yscale(range(-0.2 1)) xlabel(-0.2(0.2)1) ///
		legend(off) xtitle("Pooled Estimates") ytitle("Within-Person Estimates")  ///
		xline(0, lcolor(gs3) lwidth(medthin)) yline(0, lcolor(gs3) lwidth(medthin))
		
	gr export "$dir/figures/explain_heterogeneity_support.pdf", replace
