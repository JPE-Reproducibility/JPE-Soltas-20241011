/***************************************************************************
 * Appendix Figure A14: Self-Targeting by Number of Distinct Transfers Received
 * 
 * Description:
 * This script estimates the predictive effect of transfer receipt on consumption
 * rank and lifetime-income rank, conditional on current-income rank. It produces
 * the analysis in Figure A13 of the paper, distinguishing by the number of distinct 
 * transfers received.
 * 
 * Inputs:
 * - PSID data (`"$dir/data/psid_base"`)
 * - CEX data (`"$dir/data/cex/raw/workfile.dta"`)
 * 
 * Outputs:
 * - Figure A14 (`"$dir/figures/multiple_receipt.pdf"`)
 ***************************************************************************/


* Load data

	do code/settings.do
	use "$dir/data/psid_base", clear
	
	global navy `" "51 122 183" "'
	global orange `" "240 173 78" "' 
	
* Create basis spline for rk_current_eq
	
	* Create list
	local refpts 0 10 25 50 100
	
	* Create basis spline
	frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)

* Run regressions

	egen anyt = rowmax(snap medicaid ssi wic liheap schoolmeals tanf housing_assistance)
	egen numt = rowtotal(snap medicaid ssi wic liheap schoolmeals tanf housing_assistance)
	replace numt = 5 if inlist(numt,6,7,8)
	
	mat res = J(7,6,.)
	
	reg rk_c_current_eq anyt bs_rk* [pw=wtfam], cl(famid_orig)
	mat res[1,1] = _b[anyt]
	mat res[1,2] = _se[anyt]
	
	reg rk_lifetime_eq anyt bs_rk* [pw=wtfam], cl(famid_orig)
	mat res[1,3] = _b[anyt]
	mat res[1,4] = _se[anyt]
	
	reg rk_c_current_eq i.numt bs_rk* [pw=wtfam], cl(famid_orig)
	
	forvalues i = 1/5 {
		mat res[1+`i',1] = _b[`i'.numt]
		mat res[1+`i',2] = _se[`i'.numt]
	}
	
	reg rk_lifetime_eq i.numt bs_rk* [pw=wtfam], cl(famid_orig)
	
	forvalues i = 1/5 {
		mat res[1+`i',3] = _b[`i'.numt]
		mat res[1+`i',4] = _se[`i'.numt]
	}

*** Redo in the CEX

* Load data

	use "$dir/data/cex/raw/workfile.dta", clear
	
	global navy `" "51 122 183" "'
	
* Create basis spline for rk_current_eq
	
	* Create list
	local refpts 0 10 25 50 100
	
	* Create basis spline
	frencurv, gen(bs_rk) x(rk_inc) p(3) refpts(`refpts') omit(0)

* Run regressions

	egen anyt = rowmax(snap medicaid housing_assistance ssi tanf)
	egen numt = rowtotal(snap medicaid housing_assistance ssi tanf)
	
	reg rk_cons anyt bs_rk* [pw=finlwt21], cl(cuid)
	mat res[1,5] = _b[anyt]
	mat res[1,6] = _se[anyt]
	
	reg rk_cons i.numt bs_rk* [pw=finlwt21], cl(cuid)
	
	forvalues i = 1/5 {
		mat res[1+`i',5] = _b[`i'.numt]
		mat res[1+`i',6] = _se[`i'.numt]
	}


*** Make figure

	svmat res
	keep res*
	rename (res1-res6) (coef_c se_c coef_li se_li coef_cex se_cex)
	
	foreach x in c li cex {
		gen lo_`x' = coef_`x' - 1.96*se_`x'
		gen hi_`x' = coef_`x' + 1.96*se_`x'
	}
	
	gen lev = _n
	keep if !missing(coef_c)
	replace lev = lev - 1
	replace lev = -0.5 if lev == 0
	
	reshape long coef_ se_ lo_ hi_, i(lev) j(n) string
	
	replace lev = lev - 0.15 if n == "c"
	replace lev = lev + 0.15 if n == "li"
	
	tw 	scatter coef_ lev if lev < 0 & n == "c", msymbol(Oh) mcolor($navy) || ///
		scatter coef_ lev if lev >= 0 & n == "c", msymbol(circle) mcolor($navy) || ///
		scatter coef_ lev if lev < 0 & n == "cex", msymbol(Th) mcolor($orange) || ///
		scatter coef_ lev if lev >= 0 & n == "cex", msymbol(triangle) mcolor($orange) || ///
		scatter coef_ lev if lev < 0 & n == "li", msymbol(Sh) mcolor($green) || ///
		scatter coef_ lev if lev >= 0 & n == "li", msymbol(square) mcolor($green) || ///
		rcap lo hi lev if lev < 0 & n == "c", lcolor($navy) || ///
		rcap lo hi lev if lev >= 0 & n == "c", lcolor($navy) || ///
		rcap lo hi lev if lev < 0 & n == "cex", lcolor($orange) || ///
		rcap lo hi lev if lev >= 0 & n == "cex", lcolor($orange) || ///
		rcap lo hi lev if lev < 0 & n == "li", lcolor($green) || ///
		rcap lo hi lev if lev >= 0 & n == "li", lcolor($green) ///
		ylabel(,nogrid) ytitle("Predictive Effect of Receipt on Rank") ///
		xline(0.25,lcolor(gs9) lpattern(dash)) legend(order(2 "Cons. (PSID)" 4 "Cons. (CEX)" 6 "Lifetime Inc. (PSID)") cols(3) region(lwidth(none))) ///
		graphregion(color(white)) xlabel(-0.5 "Any" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5+") ///
		xtitle("Number of Transfers Received") plotregion(margin(10 10 3 3))
	
	gr display, ysize(4) xsize(5)
	gr export "$dir/figures/multiple_receipt.pdf", replace
