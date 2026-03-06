/***************************************************************************
* Appendix Figure A1: Absence of Self-Targeting in Contributory Programs
*
* Description:
* This file analyzes the relationship between participation in contributory
* transfer programs (UI, Worker's Compensation, Social Security) and our rank
* outcomes. It runs regressions for both consumption rank and
* lifetime income rank outcomes, and conducts separate analyses for the full
* sample and the non-employed subsample. The script produces coefficient plots
* comparing predictive effects across programs and specifications.
* 
* Inputs:
* - PSID base dataset ("$dir/data/psid_base")
* - Eligibility simulation results (generated via run_all_eligsims)
* 
* Outputs:
* - CSV file with regression results ("$dir/figures/participation_reg_ui_wc_ss.csv")
* - Coefficient plot comparing effects by program, outcome, and employment status:
*   "$dir/figures/participation_reg_ui_wc_ss.pdf"
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

* Run regressions

	keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)
	
* write a .csv
cap file close fh
file open fh using  "$dir/figures/participation_reg_ui_wc_ss.csv", write replace
file write fh "prog,spec,nonemployed,b,se" _n

foreach prog in ui wc ss  {
	
	foreach spec in "_c" "_li" {
	
	* All sample
	if "`spec'" != "_c" {
	qui reg rk_lifetime_eq  bs_rk* `prog' [pw=wtfam],  cl(famid_orig) 
	}
	if "`spec'" == "_c" {
	qui reg rk_c_current_eq  bs_rk* `prog' [pw=wtfam],  cl(famid_orig) 
	}
	  
	 local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`spec',0," (`b') "," (`se') _n
	  
	 * Nonemployed
	if "`spec'" != "_c" {
	qui reg rk_lifetime_eq  bs_rk* `prog' if employ==0 [pw=wtfam],  cl(famid_orig) 
	}
	if "`spec'" == "_c" {
	qui reg rk_c_current_eq  bs_rk* `prog' if employ==0 [pw=wtfam],  cl(famid_orig) 
	}
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`spec',1," (`b') "," (`se') _n
		
	
}
}

cap file close fh

* make plot
			
	import delimited using  "$dir/figures/participation_reg_ui_wc_ss.csv", clear
	
	gen high = b + 1.96 * se
	gen low = b - 1.96 * se

	gen raweffect_tmp = b if spec == "_c"
	bys prog: egen raweffect = mean(raweffect)

	gen order = 1 if spec == "_c" & nonemployed == 0
	replace order = 2 if spec == "_li" & nonemployed == 0
	replace order = 3 if spec == "_c" & nonemployed == 1
	replace order = 4 if spec == "_li" & nonemployed == 1
	gsort raweffect -order 

	gen n = _n
	
	local ssname "Social Security"
	local uiname "UI"
	local wcname "Worker's Comp" 

	local ylabel = "" 
	foreach obs of numlist 1(4)`=_N-1' {
	  local yval = `obs'+1.5
	  local progtype = prog[`obs']
	  local name ``progtype'name'
	  local ylabel = `" `ylabel' `yval' "`name'" "'
	}

	global navy `" "51 122 183" "'
	global green `" "92 184 92" "'
	global ltblue `" "91 192 222" "'
	global red `" "217 83 79" "'
	global orange `" "240 173 78" "'

	gr twoway /// 
		(rcap high low n if spec == "_c" & nonemployed == 0, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-15(5)10) xscale(range(-15 10)) yscale(range(0.5 12.125))) ///
		(rcap high low n if spec == "_li" & nonemployed == 0, msize(medium)  color( $orange ) horizontal) ///
		(rcap high low n if spec == "_c" & nonemployed == 1, msize(medium)  color( $green ) horizontal) ///
		(rcap high low n if spec == "_li"  & nonemployed == 1, msize(medium)  color( $ltblue ) horizontal ///
	  yline(4.5(4)`=_N+3.5', lcolor(gray) lpattern(dash) ))   /// 
	  (scatter n b if spec == "_c" & nonemployed == 0, msymbol(O) msize(medium) color( $navy ) ylabel(`ylabel'))  ///
	  (scatter n b if spec == "_li" & nonemployed == 0, msize(medium)  msymbol(T) color( $orange ) ylabel(`ylabel')) ///
	  (scatter n b if spec == "_c" & nonemployed == 1, msymbol(S) msize(medium) color( $green ) ylabel(`ylabel'))  ///
	  (scatter n b if spec == "_li" & nonemployed == 1, msize(medium)  msymbol(D) color( $ltblue ) ylabel(`ylabel') ///
	 xtitle("Predictive Effect of Participation on Rank") ytitle("")	 /// 
	  legend(col(2) lab(5 "Consumption") lab(6 "Lifetime Income") lab(7 "Cons., Non-Employed") lab(8 "Lifetime Inc., Non-Employed") order(5 6 7 8) ))

	gr export "$dir/figures/participation_reg_ui_wc_ss.pdf", replace
	
