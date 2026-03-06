/***************************************************************************
* Appendix Figure A4: Self-Targeting on Transfer Receipt in the Distant Future
* 
* Description:
* This script analyzes how the predictive effect of participation in various
* transfer programs on consumption ranking evolves over time. It estimates
* regression models to measure the initial impact and subsequent effects up
* to 20 years later for eight different government transfer programs (SNAP,
* Medicaid, Housing Assistance, TANF, SSI, School Meals, WIC, and LIHEAP).
* The analysis focuses on eligible households and controls for baseline
* income rank using spline functions.
* 
* Inputs:
* - PSID base dataset ("$dir/data/psid_base")
* - Eligibility simulation results (generated via run_all_eligsims)
* 
* Outputs:
* - Figure showing dynamic effects of program participation on consumption
*   rank over time ("$dir/figures/rank_decay.pdf")
***************************************************************************/

* Load data

	do code/settings
	local N = 100

	use "$dir/data/psid_base", clear
	
	run_all_eligsims
	
	rename eligsim_housing eligsim_ha
	rename housing_assistance ha
	
* Create basis spline for rk_current_eq
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
	
* Run regressions	

	xtset id year
		
	mat results = J(12,16,.)
	local i = -1

	foreach p in snap medicaid ha tanf ssi schoolmeals wic liheap  {
		
		local i = `i'+2
		
		forvalues t = 0(2)20 {	
			
			local j = 1+`t'/2
			
			if `t' == 0 {
				
				reg rk_c_current_eq `p' bs_rk* if eligsim_`p'==1 [pw=wtfam], cl(famid_orig)
						
				mat results[`j',`i'] = e(b)[1,1]
				mat results[`j',`i'+1] = sqrt(e(V)[1,1])
						
			}
			
			if `t' != 0 {
				
				reg rk_c_current_eq f`t'.`p' bs_rk* if `p'==0 & eligsim_`p'==1 [pw=wtfam], cl(famid_orig)

				mat results[`j',`i'] = e(b)[1,1]
				mat results[`j',`i'+1] = sqrt(e(V)[1,1])
				
			}
			
			
		}
	}

* Make graphs
		
	svmat results
	preserve
	keep results*

	gen t = _n
	replace t = (t-1)*2
	drop if missing(results1)

	forvalues x = 1(2)15 {
		
		local xplus1 = `x'+1
		
		gen lo`x' = results`x'-1.96*results`xplus1'
		gen hi`x' = results`x'+1.96*results`xplus1'
		
	}
	
	forvalues p = 1(2)15 {
				
		if `p' == 1 { 
			local pname = "SNAP" 
		} 
		if `p' == 3 { 
			local pname = "Medicaid" 
		} 
		if `p' == 5 { 
			local pname = "Housing Assistance"
		} 
		if `p' == 7 { 
			local pname = "TANF"
		} 
		if `p' == 9 { 
			local pname = "School Meals"
		} 
		if `p' == 11 { 
			local pname = "SSI"
		} 
		if `p' == 13 { 
			local pname = "WIC"
		} 
		if `p' == 15 { 
			local pname = "LIHEAP" 
		} 

		tw 	rarea lo`p' hi`p' t if t != 0, fcolor(navy%30) lwidth(none) || ///
			connected results`p' t if t != 0, mcolor(navy) lcolor(navy) msymbol(circle) fcolor(navy) || ///
			connected results`p' t if t == 0, mcolor(navy) lcolor(navy) msymbol(circle_hollow) ///
			ylabel(,nogrid) graphregion(lcolor(white) color(white)) yline(0, lcolor(gs9)) ///
			ylab(,nogrid) ytitle("") xtitle("") ///
			yline(0, lpattern(solid) lcolor(gs9)) name(graph_`p', replace) title("`pname'") legend(off)
	
	}
	
	gr combine graph_1 graph_3 graph_5 graph_7 graph_9 graph_11 graph_13 graph_15, ///
		ycommon rows(2) name(combined, replace) graphregion(lcolor(white) color(white)) ///
		l1title("Average Difference in Consumption Rank", size(small)) ///
		b1title("Years Later", size(small) ring(1))
	
	graph display combined, ysize(4) xsize(6)
	
	graph export "$dir/figures/rank_decay.pdf", as(pdf) replace
