/*************************************************************************** 
 * Appendix Figure A31: Selection into Transfer Receipt Over Time
 * 
 * Description:
 * This script estimates the average conditional predictive effect of transfer
 * receipt on household rank outcomes, pooling across eight transfer programs 
 * (SNAP, Medicaid, SSI, WIC, TANF, LIHEAP, school meals, and housing assistance). 

 * For each year, we estimate the coefficient on an indicator 
 * for transfer receipt within the simulated-eligible population, controlling for 
 * program-specific cubic splines in current-income rank and including 
 * program-by-cohort-by-year fixed effects. 
 * 
 * All regressions are run on a stacked dataset, where each household-year appears
 * once per transfer program. Estimates are reported separately using raw sample 
 * weights and weights re-scaled by the relative size of each transfer program. 
 * 
 * Inputs:
 * - PSID data with transfer receipt ($dir/data/psid_base") 
 * - simulated eligibility (via `run_all_eligsims')
 * 
 * Outputs:
 * - PDF figures displaying year-by-year predictive effects:
 *     * selection_by_year1.pdf: Separate panels for consumption and lifetime income
 *     * selection_by_year2.pdf: Combined panel with both outcomes
 * Note that only selection_by_year2.pdf is included in the paper. Other figures are kept for reference.
 ***************************************************************************/
 
* Settings

	do code/settings.do
	
* Produce stacked dataset	
		
	foreach v in snap medicaid ssi wic tanf liheap schoolmeals ha {
		
		use "$dir/data/psid_base", clear
		
		run_all_eligsims
			
		rename housing_assistance ha
		rename housing_assistance_amt_hh ha_amt_hh
		rename eligsim_housing eligsim_ha
		
		keep `v' `v'_amt_hh rk_c_current_eq rk_lifetime_eq rk_current_eq id famid_orig wtfam year cohort_ind eligsim_`v' hhsize
		
		rename `v' receipt
		rename eligsim_`v' eligsim
		gen pname = "`v'"
		
		tempfile `v'
		save ``v'', replace
		
	}


	clear

	foreach v in snap medicaid ssi wic tanf liheap schoolmeals ha {
		
		append using ``v''
		
	}
	
	* Generate new weights
	
	gen wtadj = .
	
	foreach v in snap medicaid ssi wic tanf liheap schoolmeals ha {
		summ `v'_amt_hh [aw=wtfam]
		local totamt = r(sum) / 10e8
		replace wtadj = wtfam*hhsize*`totamt' if pname == "`v'"
	}
	
	encode pname, gen(p)
	
	* Create basis spline for rk_current_eq
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
	
* Run regressions

	mat res = J(12,9,.)
	local j = 0
	
	foreach wt in wtfam wtadj {
	foreach rk in rk_c_current_eq rk_lifetime_eq {
		
		local j = `j'+1
	
		reghdfe `rk' 1.receipt#i.year if eligsim==1 [pw=`wt'], cl(famid_orig) a(p#year p#c.bs_rk1 p#c.bs_rk3 p#c.bs_rk4 p#c.bs_rk5 p#c.bs_rk6 p#c.bs_rk7)
		
		forvalues t = 1/12 {
			local y =  2*(`t'-1) + 1997
			mat res[`t',1] = `y'
			mat res[`t',2*`j'] = _b[1.receipt#`y'.year]
			mat res[`t',1+2*`j'] = _se[1.receipt#`y'.year]
		}
			
	}	
	}
	
* Make figures

	svmat res
	keep res*
	drop if missing(res1)
	
	rename (res1-res9) (year b_c_unwt se_c_unwt b_li_unwt se_li_unwt b_c_wt se_c_wt b_li_wt se_li_wt)
	
	foreach v in c_unwt li_unwt c_wt li_wt {
		
		gen lo_`v' = b_`v' - 1.96*se_`v'
		gen hi_`v' = b_`v' + 1.96*se_`v'
		
	}
	
	tw line b_c_unwt year, lcolor(midblue) || line b_c_wt year, lcolor(red) || rarea lo_c_unwt hi_c_unwt year, lwidth(none) fcolor(midblue%30)  || rarea lo_c_wt hi_c_wt year, lwidth(none) fcolor(red%30)  ylabel(,nogrid labsize(medlarge)) xtitle("") graphregion(color(white)) legend(order(1 "Unweighted" 2 "Weighted") size(small)) name(gr_c, replace) title("Consumption") ytitle("Conditional Predictive Effect on Rank", size(medlarge)) xlabel(,labsize(medlarge))
	
		tw line b_li_unwt year, lcolor(midblue) || line b_li_wt year, lcolor(red) || rarea lo_li_unwt hi_li_unwt year, lwidth(none) fcolor(midblue%30)  || rarea lo_li_wt hi_li_wt year, lwidth(none) fcolor(red%30)  ylabel(,nogrid labsize(medlarge)) xtitle("") graphregion(color(white)) legend(order(1 "Unweighted" 2 "Weighted")) name(gr_li, replace) title("Lifetime Income") xlabel(,labsize(medlarge))
		
		grc1leg gr_c gr_li, ycommon graphregion(color(white))
		gr export "$dir/figures/selection_by_year1.pdf", replace
	 
	tw line b_c_unwt year, lcolor(midblue) || line b_li_unwt year, lcolor(red) || rarea lo_c_unwt hi_c_unwt year, lwidth(none) fcolor(midblue%30)  || rarea lo_li_unwt hi_li_unwt year, lwidth(none) fcolor(red%30)  ylabel(,nogrid) xtitle("") graphregion(color(white)) legend(order(1 "Consumption" 2 "Lifetime Income") rows(1))  ytitle("Conditional Predictive Effect on Rank", size(medlarge)) yscale(range(-20 -10 0)) ylabel(-20(10)0)

	gr export "$dir/figures/selection_by_year2.pdf", replace
	 