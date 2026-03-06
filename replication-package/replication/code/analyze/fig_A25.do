/***************************************************************************
 * Appendix Figure A25: Self-Targeting on Consumption Among the Very Likely Eligible (CEX)
 *
 * Description:
 * This script creates a figure that displays estimates of the predictive effect of transfer receipt on consumption 
 * rank, conditional on current-income rank. The eligibility logit uses the following demographic variables: age (as a 
 * quadratic), sex, marital status, race/ethnicity (white, black, Hispanic, other), education (less than high school, 
 * high school, some college, BA, more than BA), household size, homeownership, disability, presence of a child in the 
 * household, income as a share of the federal poverty level, and rank-transformed current income, lifetime income,  * 
 * and consumption.
 *
 * Inputs:
 * - CEX-based dataset: "$dir/data/cex/raw/workfile.dta"
 *
 * Outputs:
 * - CSV of estimates: "$dir/figures/participation_reg_robustness_cex.csv"
 * - Figures:
 * - "$dir/figures/eligregs_robustness_cex.pdf" (Effect on Consumption Rank)
 *
***************************************************************************/		

* Settings

	do code/settings.do
	do "$dir/code/stata-tex.do"
	
	discard
    set scheme simplescheme 

* Load data 

	use "$dir/data/cex/raw/workfile.dta", clear
		
	* Create basis spline for rk_inc
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_inc) p(3) refpts(`refpts') omit(0)
		
	cap drop eligsim_any 
	egen eligsim_any = rowmax(eligsim_snap eligsim_medicaid eligsim_ssi eligsim_housing eligsim_tanf) 
	
* Predict eligibility from demographics

	keep if !missing(rk_inc) & !missing(rk_cons)

	* Generate eligibility
	ren *housing_assistance* *ha*
	
	* Predict
	gen inc_to_fpl = 100 * fincbtax / povlevcy
	summ inc_to_fpl, d
	gen ln_inc_to_fpl = inc_to_fpl
	replace ln_inc_to_fpl = 10 if inc_to_fpl<10
	replace inc_to_fpl = 1000 if inc_to_fpl>1000 & !missing(inc_to_fpl)
	replace ln_inc_to_fpl = ln(ln_inc_to_fpl)

	local demographics "c.age##c.age ln_inc_to_fpl i.race married disabled i.hhsize owns_home has_child rk_inc rk_cons i.year i.educ"
	
	foreach prog in snap medicaid ssi ha tanf  {
		logit eligsim_`prog' `demographics' [pw=finlwt21]
		predict pr_eligsim_`prog'
	}
	
* write a .csv
cap file close fh
file open fh using  "$dir/figures/participation_reg_robustness_cex.csv", write replace
file write fh "prog,spec,high_prelig,b,se" _n

foreach prog in snap medicaid ssi ha tanf  {
		
	* All sample
	qui reg rk_cons  bs_rk* `prog' if eligsim_`prog'==1 & !missing(pr_eligsim_`prog') [pw=finlwt21],  cl(cuid) 
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',_c,0," (`b') "," (`se') _n
		
	* High eligibility sample
		* All sample
		di "`prog'"
	qui reg rk_cons  bs_rk* `prog' if eligsim_`prog'==1 & pr_eligsim_`prog'>0.75 & !missing(pr_eligsim_`prog')  [pw=finlwt21],  cl(cuid) 
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',_c,1," (`b') "," (`se') _n
	
}

cap file close fh

* make plot
		
	import delimited using  "$dir/figures/participation_reg_robustness_cex.csv", clear
	keep if spec == "_c"
	
	gen high = b + 1.96 * se
	gen low = b - 1.96 * se

	gen raweffect_tmp = b if high_prelig == 0
	bys prog: egen raweffect = mean(raweffect)
	replace raweffect = 5 if prog == "any" 

	gen order = 1 if high_prelig == 0
	replace order = 2 if high_prelig == 1
	gsort raweffect -order 

	gen n = _n
	
	local snapname SNAP
	local ssiname SSI
	local tanfname TANF
	local medicaidname Medicaid
	local haname Housing

	local ylabel = "" 
	foreach obs of numlist 1(2)`=_N-1' {
	  local progtype = prog[`obs']
	  local pos = `obs'+0.5
	  local name ``progtype'name'
	  local ylabel = `" `ylabel' `pos' "`name'" "'
	}

	global navy `" "51 122 183" "'
	global green `" "92 184 92" "'
	global ltblue `" "91 192 222" "'
	global red `" "217 83 79" "'
	global orange `" "240 173 78" "'

	gr twoway /// 
		(rcap high low n if high_prelig == 1, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-25(5)0) xscale(range(-25 0))) ///
		(rcap high low n if high_prelig == 0, msize(medium)  color( $orange ) horizontal yscale(range(0.75 10.2)) ///
	  yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) )) /// 
	  (scatter n b if high_prelig == 1, msymbol(O) msize(medium) color( $navy ) ylabel(`ylabel') ///
	  xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
		(scatter n b if high_prelig == 0, msize(medium)  msymbol(T) color( $orange ) ylabel(`ylabel') ///
	  legend(col(2) lab(4 "Full Sample") lab(3 "Very Likely Eligible")  order(4 3 ) ))
	  
	gr export "$dir/figures/eligregs_robustness_cex.pdf", replace
	
