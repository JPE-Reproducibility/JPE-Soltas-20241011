/***************************************************************************
 * Appendix Figure A30: Self-Targeting by Minimum Years of Observation
 * 
 * Description:
 * This script assesses how many years of earnings data are required for stable 
 * estimates of selection into transfer receipt by comparing recipients and 
 * nonrecipients in terms of lifetime earnings rank, conditional on current 
 * earnings rank. It uses an internal validation approach, progressively 
 * restricting the sample to individuals with more years of observed earnings.
 * 
 * The analysis is conducted separately for lifetime earnings rank and 
 * consumption rank, using cubic basis splines of current earnings rank and 
 * conditioning on simulated program eligibility. Results are visualized for 
 * multiple transfer programs.
 * 
 * Inputs:
 * - PSID-based dataset: `"$dir/data/psid_base"`
 * - Simulated eligibility indicators: `run_all_eligsims`
 * 
 * Outputs:
 * - Figure: `"$dir/figures/lifetime_internal_validation_eq.pdf"`
 ***************************************************************************/

*** Settings
		
	do code/settings
	set more off
	
	discard
	set scheme s2color
		
*** Prepare data

	* Load datafile
	use "$dir/data/psid_base", clear
	
	run_all_eligsims
	
	keep if !missing(rk_current_eq) & !missing(rk_c_current_eq) & !missing(rk_lifetime_eq)
	
	* Create variable for number of observations per ID (with earnings info)
	gen ct_ = !missing(rk_current_eq) & !missing(rk_c_current_eq) & !missing(rk_lifetime_eq)
	egen ct = sum(ct_), by(id)
	drop ct_
	
	* Create basis spline for rk_current_eq / rk_current_hh
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rke) x(rk_current_eq) p(3) refpts(`refpts') omit(0)

	* Create locals
	mat res = J(88,6,0)
	local n = 1
	local pnum = 1
	
	preserve
	
******************************************************************************************
* Main loop: produce regression coefficients, splitting sample by number of observations per ID
******************************************************************************************

**** Lifetime income
	
	foreach p of varlist snap medicaid ssi tanf schoolmeals wic housing_assistance liheap {
		
		di "`p'"
		
		forvalues i = 1/11 {
			
			quietly reg rk_lifetime_eq `p' bs_rke* if ct >= `i' & eligsim_`p'==1 [pw=wtfam], cl(famid_orig)
			
			mat b = e(b)
			mat V = e(V)
			
			mat res[`n',1] = `pnum'
			mat res[`n',2] = `i'
			mat res[`n',3] = b[1,1]
			mat res[`n',4] = sqrt(V[1,1])
			
			local n = `n'+1
			
			
		}
		
		local pnum = `pnum'+1
		
	}
	
**** Consumption

	local n = 1
	local pnum = 1
	
	foreach p of varlist snap medicaid ssi tanf schoolmeals wic housing_assistance liheap {
		
		di "`p'"
		
		forvalues i = 1/11 {
			
			quietly reg rk_c_current_eq `p' bs_rke* if ct >= `i' & eligsim_`p'==1 [pw=wtfam], cl(famid_orig)
			
			mat b = e(b)
			mat V = e(V)
			
			mat res[`n',5] = b[1,1]
			mat res[`n',6] = sqrt(V[1,1])
			
			local n = `n'+1
			
			
		}
		
		local pnum = `pnum'+1
		
	}
	
*** Present results

	* Move results from temporary matrix to data

	clear 
	svmat res
	
	* Clean up results in data
	
	rename res1 pnum
	rename res2 years
	rename res3 est_li
	rename res4 stderr_li
	rename res5 est_c
	rename res6 stderr_c
	
	replace years = years*2
	
	xtset pnum years

	gen transfer = ""
	replace transfer = "SNAP" if pnum == 1
	replace transfer = "Medicaid" if pnum == 2
	replace transfer = "SSI" if pnum == 3
	replace transfer = "TANF" if pnum == 4
	replace transfer = "School Meals" if pnum == 5
	replace transfer = "WIC" if pnum == 6
	replace transfer = "Housing Assistance" if pnum == 7
	replace transfer = "LIHEAP" if pnum == 8
	
	local critval = 1.96
	gen lo_li = est_li - `critval'*stderr_li
	gen hi_li = est_li + `critval'*stderr_li
	gen lo_c = est_c - `critval'*stderr_c
	gen hi_c = est_c + `critval'*stderr_c
	
	* Make graph
	
	forvalues p = 1/8 {
		
		summ est_li if years == 22 & pnum == `p'
		local est_final_li = r(mean)
		
		summ est_c if years == 22 & pnum == `p'
		local est_final_c = r(mean)
		
		if `p' == 1 { 
			local pname = "SNAP" 
		} 
		if `p' == 2 { 
			local pname = "Medicaid" 
		} 
		if `p' == 3 { 
			local pname = "SSI"
		} 
		if `p' == 4 { 
			local pname = "TANF"
		} 
		if `p' == 5 { 
			local pname = "School Meals"
		} 
		if `p' == 6 { 
			local pname = "WIC"
		} 
		if `p' == 7 { 
			local pname = "Housing Assistance"
		} 
		if `p' == 8 { 
			local pname = "LIHEAP" 
		} 

		tw 	rarea lo_li hi_li years if pnum == `p', fcolor(navy%30) lwidth(none) || ///
			connected est_li years if pnum == `p', mcolor(navy) lcolor(navy) fcolor(navy) || ///
			rarea lo_c hi_c years if pnum == `p', fcolor(maroon%30) lwidth(none) || ///
			connected est_c years if pnum == `p', mcolor(maroon) lcolor(maroon) fcolor(maroon) ///
			ylabel(,nogrid) graphregion(lcolor(white) color(white)) ///
			ylab(,nogrid) ytitle("") xtitle("") yline(`est_final_li' `est_final_c', lpattern(dash) lcolor(navy maroon)) ///
			yline(0, lpattern(solid) lcolor(gs9)) name(graph_`p', replace) title("`pname'") ///
			legend(order(2 "Lifetime Income" 4 "Consumption") size(small) region(lwidth(none)))
	
	}
	
	grc1leg graph_1 graph_2 graph_3 graph_4 graph_5 graph_6 graph_7 graph_8, ///
		ycommon rows(2) name(combined, replace) graphregion(lcolor(white) color(white)) ///
		l1title("Conditional Difference in Percentile Rank", size(small)) ///
		b1title("Minimum Years of Observation", size(small)) ring(1)
	
	graph display combined, ysize(4) xsize(6)
	
	graph export "$dir/figures/lifetime_internal_validation_eq.pdf", as(pdf) replace
