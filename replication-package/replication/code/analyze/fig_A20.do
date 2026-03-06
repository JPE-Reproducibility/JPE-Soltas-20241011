/***************************************************************************
 * Appendix Figure A20: Relating Self-Targeting to Theories of Consumption Behavior
 *
 * Description:
 * This script creates a figure that displays estimates of the predictive effect of transfer receipt on consumption rank, conditional on
 * current-income rank, but augmented with additional controls noted in the legend. Blue
 * dots present our baseline estimates, yellow triangles include a control for the two-years-ahead consumption rank, green
 * squares further include controls for wealth, and teal diamonds also include fixed effects for the person's education,
 * occupation, and industry. The wealth controls are indicators for the household's decile of liquid savings, home equity,
 * value of household automobiles, and other wealth. Confidence intervals are at the 95-percent level and reflect clustered
 * standard errors by household.
 * 
 * Inputs:
 * - PSID data (`"$dir/data/psid_base"`)
 * 
 * Outputs:
 * - CSV (`"$dir/figures/precautionary.csv"`)
 * - PDF figure (`"$dir/figures/precautionary.pdf"`)
***************************************************************************/		

* Settings

	do code/settings.do
	do "$dir/code/stata-tex.do"
	
	discard
    set scheme simplescheme 

* Load data 

	use "$dir/data/psid_base", clear
		
	* Create basis spline for rk_current_eq
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
	
		run_all_eligsims
	
* Precautionary motive regressions

/*
	1. baseline
	2. one lead of future consumption
	3. liquid wealth bins
	4. control for occ/ind of husband and wife
*/

	keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

	* Generate eligibility
	ren *housing_assistance* *ha*
	
	egen wsav_bin = cut(wsav_real), group(10)
	egen whome_bin = cut(whome_real), group(10)
	egen wcar_bin = cut(wcar_real), group(10)
	egen woth_bin = cut(woth_real), group(10)
	
* write a .csv
cap file close fh
file open fh using  "$dir/figures/precautionary.csv", write replace
file write fh "prog,spec,b,se" _n

foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf {
	
	* All sample
	qui reg rk_c_current_eq bs_rk* `prog' if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) 
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',0," (`b') "," (`se') _n
	
	* Consumption lead
	xtset id year
	qui reg rk_c_current_eq f2.rk_c_current_eq bs_rk* `prog' if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) 
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',1," (`b') "," (`se') _n
		
	* Liquid wealth bins
	qui reg rk_c_current_eq `prog' bs_rk* f2.rk_c_current_eq i.w*_bin if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) 	  
	  	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',2," (`b') "," (`se') _n
	  
	 * Occupation/industry/education
	qui reghdfe rk_c_current_eq `prog' f2.rk_c_current_eq i.w*_bin if eligsim_`prog'==1 [pw=wtfam], a(edcat occconst indconst) cl(famid_orig) 
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',3," (`b') "," (`se') _n
	
}

cap file close fh

* Make graph
		local wicname WIC
		local snapname SNAP
		local schoolmealsname "School Meals"
		local ssiname SSI
		local tanfname TANF
		local medicaidname Medicaid
		local liheapname LIHEAP
		local haname Housing
		
	import delimited using  "$dir/figures/precautionary.csv", clear
		local ssiname SSI

    gen high = b + 1.96 * se
    gen low = b - 1.96 * se

    gen order = 1 if spec == 0 
    replace order = 2 if spec == 1 
	replace order = 3 if spec == 2 

	gen baseline = b if spec == 0
	gegen baseline_ = max(baseline), by(prog)
	
    gsort baseline_ spec 
    
    gen n = _n
    local ylabel = "" 
    foreach obs of numlist 2.5(4)`=_N+0.5' {
      local progtype = prog[`obs']
      local name "``progtype'name'"
      local ylabel = `" `ylabel' `obs' "`name'" "'
    }
    
    global navy `" "51 122 183" "'
    global green `" "92 184 92" "'
    global ltblue `" "91 192 222" "'
    global red `" "217 83 79" "'
    global orange `" "240 173 78" "'

		gr twoway  (rcap high low n if spec == 0, color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
		  (rcap high low n if spec == 1, msize(medium)  color($orange) horizontal) ///
		  (rcap high low n if spec == 2, msize(medium)  color($green) horizontal)  ///
		  (rcap high low n if spec == 3, msize(medium)  color($ltblue) horizontal  ///
		  yscale(range(0.75 9.25)) yline(4.5(4)`=_N+0.5', lcolor(gray) lpattern(dash) ) ) /// 
		  (scatter n b if spec == 0, msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
		  xtitle("Predictive Effect of Participation on Cons. Rank") ytitle("") )  /// 
		  (scatter n b if spec == 1, msize(medium) msymbol(T) color($orange)) ///
		   (scatter n b if spec == 2, msize(medium) msymbol(S) color($green)) ///
		   (scatter n b if spec == 3, msize(medium) msymbol(D) color($ltblue) ///
		   ylabel(`ylabel') legend(col(2) lab(5 "Baseline") lab(6 "Consumption in {it:y} + 2") lab(7 "Wealth Bins") lab(8 "Educ. +Occ.+ Ind.") order(5 6 7 8) ) name(tmp, replace))
		   
		   gr display tmp, xsize(4) ysize(6)

		
				gr export "$dir/figures/precautionary.pdf", replace

	