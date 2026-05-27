/***************************************************************************
 * Appendix Figure A22: Adjustments to Eligibility Simulations (CEX)
 * 
 * Description:
 * This script creates a figure that displays estimates of the predictive effect of transfer benefit receipt on consumption rank, conditional
 * on current-income rank. For estimates represented by yellow triangles or green squares, we respectively impose an income limit (at 100% of the federal poverty level) 
 * or an asset limit (at $2,000 in liquid  assets, in 2020 dollars adjusted for the Consumer Price Index) on top of our eligibility simulations.
 *
 * Inputs:
 * - CEX data (`"$dir/data/cex/raw/workfile.dta"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * 
 * Outputs:
 * - CSV of regression coefficients for baseline and alt specs 
 *   (`"$dir/figures/robustness2_cex.csv"`)
 * - Robustness figure with coefficient plots 
 *   (`"$dir/figures/robustness2_cex.pdf"`)
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
	get_dollar_shares_cex
	
* Generate new eligsim variables

foreach prog in snap medicaid ssi ha tanf  {
	
	gen eligsim2_`prog' = eligsim_`prog'
	replace eligsim2_`prog' = 1 if fincbtax <= povlevcy
	
	gen eligsim3_`prog' = eligsim_`prog'
	replace eligsim3_`prog' = 0 if wsav_nom > 2000 & !missing(wsav_nom)
	
}

* Run regressions	
	
* write a .csv
cap file close fh
file open fh using  "$dir/figures/robustness2_cex.csv", write replace
file write fh "prog,spec,inc_range,b,se" _n

foreach prog in snap medicaid ssi ha tanf  {
		
	* All sample
	qui reg rk_cons  bs_rk* `prog' if eligsim_`prog'==1  [pw=finlwt21],  cl(cuid) 
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',_c,0," (`b') "," (`se') _n
		
	* Income limit
		di "`prog'"
	qui reg rk_cons  bs_rk* `prog' if eligsim2_`prog'==1  [pw=finlwt21],  cl(cuid) 
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',_c,1," (`b') "," (`se') _n
	
	* Asset limit
		di "`prog'"
	qui reg rk_cons bs_rk* `prog' if eligsim3_`prog'==1 [pw=finlwt21],  cl(cuid) 
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',_c,2," (`b') "," (`se') _n
	
	
}

*** Run self-targeting regression pooled across programs

	gegen id = group(perid cuid)

	rename (snap medicaid tanf ssi ha) (r_snap r_medicaid r_tanf r_ssi r_ha)
	keep r_* id year rk_inc rk_cons finlwt21 eligsim* cuid bs_rk* qtr
	
	reshape long r_ eligsim_ eligsim2_ eligsim3_, i(id year qtr) j(transfer) string
	
	egen prog = group(transfer)

	foreach prog in snap medicaid ssi ha tanf {
		
		local wtname = "wt_`prog'"
		local wtval = ${`wtname'}
		replace finlwt21 = finlwt21 * `wtval' if transfer == "`prog'"
		
		di "`prog' : `wtval'"
			
	}
		
	* All sample
	reghdfe rk_cons i.prog#c.bs_rk* r_ if eligsim_==1 [pw=finlwt21], a(prog) cl(cuid) 
	  
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,_c,0," (`b') "," (`se') _n
	
	* Income limit
	
	replace eligsim_ = 1 if r_ == 1 & eligsim_== 0
	
	reghdfe rk_cons i.prog#c.bs_rk* r_ if eligsim2_==1 [pw=finlwt21], a(prog) cl(cuid) 
	  
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,_c,1," (`b') "," (`se') _n
	
	* Asset limit
	
	replace eligsim_ = 1 if r_ == 1 & eligsim_== 0
	
	reghdfe rk_cons i.prog#c.bs_rk* r_ if eligsim3_==1 [pw=finlwt21], a(prog) cl(cuid) 
	  
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,_c,2," (`b') "," (`se') _n

cap file close fh

* make plot
		
	import delimited using  "$dir/figures/robustness2_cex.csv", clear
	keep if spec == "_c"
	
	gen high = b + 1.96 * se
	gen low = b - 1.96 * se

	gen raweffect_tmp = b if inc_range == 0
	bys prog: egen raweffect = mean(raweffect)
	replace raweffect = 5 if prog == "avg" 

	gsort raweffect - inc_range 

	gen n = _n
	
	local avgname {bf:Average}
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
	  xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("")  legend(col(3) lab(4 "Baseline") lab(5 "Income Limit (%100 FPL)") lab(6 "Asset Limit ($2000)")  order(4 5 6) ))
	  
	gr export "$dir/figures/robustness2_cex.pdf", replace
	
