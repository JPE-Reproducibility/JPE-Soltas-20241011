/***************************************************************************
 * Appendix Figure A17: Heterogeneous Self-Targeting on Consumption by Current Income Rank (CEX)
 * 
 * Description:
 * This script creates a figure that displays estimates of the predictive effect of transfer receipt on consumption rank, conditional on
 * current-income rank. Estimates in blue circles repeat our main estimates in Figure
 * 1. For estimates in yellow triangles or green squares, we split the sample at the tenth percentile of the distribution of
 * equivalized current household income. The data source is the Consumer Expenditure Survey. Confidence intervals are
 * at the 95-percent level and reflect clustered standard errors by household.
 * 
 * Inputs:
 * - CEX-based dataset: `"$dir/data/cex/raw/workfile.dta"`
 * - Eligibility simulation results (via `run_all_eligsims`)
 * 
 * Outputs:
 * - CSV of regression results (`"$dir/figures/robustness3_cex.csv"`)
 * - Figure ("$dir/figures/robustness3_cex.pdf"`)
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
		
	ren *housing_assistance* *ha*
	cap drop eligsim_anytransfer
	egen eligsim_anytransfer = rowmax(eligsim_snap eligsim_medicaid eligsim_ssi eligsim_ha eligsim_tanf) 
	egen anytransfer = rowmax(snap medicaid ssi ha tanf)

* Run regressions	
	
* write a .csv
cap file close fh
file open fh using  "$dir/figures/robustness3_cex.csv", write replace
file write fh "prog,spec,inc_range,b,se" _n


foreach prog in anytransfer snap medicaid ssi ha tanf  {
		
	* All sample
	qui reg rk_cons  bs_rk* `prog' if eligsim_`prog'==1  [pw=finlwt21],  cl(cuid) 
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',_c,0," (`b') "," (`se') _n
		
	* Income in bottom decile
		* All sample
		di "`prog'"
	qui reg rk_cons  bs_rk* `prog' if eligsim_`prog'==1 & rk_inc<10 [pw=finlwt21],  cl(cuid) 
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',_c,1," (`b') "," (`se') _n
	
	* Income not in bottom decile
		* All sample
		di "`prog'"
	qui reg rk_cons bs_rk* `prog' if eligsim_`prog'==1 & rk_inc>=10 [pw=finlwt21],  cl(cuid) 
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',_c,2," (`b') "," (`se') _n
	
	
}

cap file close fh

* make plot
		
	import delimited using  "$dir/figures/robustness3_cex.csv", clear
	keep if spec == "_c"
	
	gen high = b + 1.96 * se
	gen low = b - 1.96 * se

	gen raweffect_tmp = b if inc_range == 0
	bys prog: egen raweffect = mean(raweffect)
	replace raweffect = 5 if prog == "anytransfer" 

	gsort raweffect - inc_range 

	gen n = _n
	
	local anytransfername {bf:Any}
	local snapname SNAP
	local ssiname SSI
	local tanfname TANF
	local medicaidname Medicaid
	local haname Housing

	local ylabel = "" 
	foreach obs of numlist 1(3)`=_N-1' {
	  local progtype = prog[`obs']
	  local pos = `obs'+1
	  local name ``progtype'name'
	  local ylabel = `" `ylabel' `pos' "`name'" "'
	}

	global navy `" "51 122 183" "'
	global green `" "92 184 92" "'
	global ltblue `" "91 192 222" "'
	global red `" "217 83 79" "'
	global orange `" "240 173 78" "'

	gr twoway /// 
		(rcap high low n if inc_range == 0, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-25(5)0) xscale(range(-25 0))) ///
		(rcap high low n if inc_range == 1, color( $orange ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-25(5)0) xscale(range(-25 0))) ///
		(rcap high low n if inc_range == 2, msize(medium)  color( $green ) horizontal yscale(range(1 10.2)) ///
	  yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) )) /// 
	  (scatter n b if inc_range == 0, msymbol(O) msize(medium) color( $navy ) ylabel(`ylabel'))   ///
		(scatter n b if inc_range == 1, msize(medium)  msymbol(T) color( $orange ) ylabel(`ylabel')) ///
		(scatter n b if inc_range == 2, msize(medium)  msymbol(S) color( $green ) ylabel(`ylabel') ///
	  xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("")  legend(col(3) lab(4 "Full Sample") lab(5 "Bottom-Decile Income") lab(6 "Other Nine Deciles")  order(4 5 6) ))
	  
	gr export "$dir/figures/robustness3_cex.pdf", replace
	
