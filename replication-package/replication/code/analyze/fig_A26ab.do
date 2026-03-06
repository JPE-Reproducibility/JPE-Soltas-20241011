/***************************************************************************
 * Appendix Figure A26, Panel A and B: Accounting for Months of Transfer Receipt, Selection on Consumption and 
 * Selection on Lifetime Income
 * 
 * Description:
 * This script examines how the *duration* of transfer receipt — measured 
 * as the share of months receiving benefits within the year — predicts
 * consumption rank and lifetime income rank. It compares:
 * (1) Baseline binary receipt,
 * (2) Continuous months-based measure,
 * (3) A binary 0 vs. 12 months comparison.
 * 
 * Regressions are run separately by program (SNAP, SSI, TANF) and for two 
 * rank outcomes: consumption rank and lifetime income rank. Results are 
 * exported to a CSV and used to generate the robustness figure.
 * 
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * 
 * Outputs:
 * - CSV file with regression results (`"$dir/figures/participation_reg_robustness6.csv"`)
 * - PDF figures by specification (`"$dir/figures/eligregs_robustness_6_c.pdf"`, etc.)
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
	
* Recode months of transfer

	foreach v in snap ssi tanf {
		replace `v'_months = `v'_months/12
	}

* Predict eligibility from demographics

	keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

	* Generate eligibility
	ren *housing_assistance* *ha*
	
	
* write a .csv
cap file close fh
file open fh using  "$dir/figures/participation_reg_robustness6.csv", write replace
file write fh "prog,spec,months,b,se" _n

foreach prog in snap ssi tanf  {
	
	foreach spec in "_c" "_li" {
	
	* All sample
	if "`spec'" != "_c" {
        qui reg rk_lifetime_eq bs_rk* `prog' if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
		qui reg rk_c_current_eq bs_rk* `prog' if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) 
	  }
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`spec',0," (`b') "," (`se') _n
		
	* Month measure comparisons
	if "`spec'" != "_c" {
		qui reg rk_lifetime_eq `prog'_months bs_rk* if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
	qui reg rk_c_current_eq `prog'_months bs_rk*  if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) 
	  }
	  
	  	
	local b = _b[`prog'_months]
	local se = _se[`prog'_months]
	file write fh "`prog',`spec',1," (`b') "," (`se') _n
	
	  
	 * Zero versus twelve months
	 if "`spec'" != "_c" {
		qui reg rk_lifetime_eq `prog'_months bs_rk* if eligsim_`prog'==1 & inlist(`prog'_months,0,1) [pw=wtfam], cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
	qui reg rk_c_current_eq `prog'_months bs_rk*  if eligsim_`prog'==1 & inlist(`prog'_months,0,1) [pw=wtfam], cl(famid_orig) 
	  }
	
	local b = _b[`prog'_months]
	local se = _se[`prog'_months]
	file write fh "`prog',`spec',2," (`b') "," (`se') _n
	
}
}

cap file close fh

* Make graph
local snapname SNAP
local ssiname SSI
local tanfname TANF
    
	
		foreach spec in "_c" "_li" {
			
			    import delimited using  "$dir/figures/participation_reg_robustness6.csv", clear

		keep if spec == "`spec'"
		
    gen high = b + 1.96 * se
    gen low = b - 1.96 * se

    gen raweffect_tmp = b if spec == "baseline"
    bys prog: egen raweffect = mean(raweffect)

    gen order = 1 if months == 0 
    replace order = 2 if months == 1 
	replace order = 3 if months == 2 

    gsort prog months 
    
    gen n = _n
    local ylabel = "" 
    foreach obs of numlist 2(3)`=_N' {
      local progtype = prog[`obs']
      local name ``progtype'name'
      local ylabel = `" `ylabel' `obs' "`name'" "'
    }
    
    global navy `" "51 122 183" "'
    global green `" "92 184 92" "'
    global ltblue `" "91 192 222" "'
    global red `" "217 83 79" "'
    global orange `" "240 173 78" "'

		if "`spec'" == "_c" {

		gr twoway /// 
			(rcap high low n if months == 0, color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
		  (rcap high low n if months == 1, msize(medium)  color($orange) horizontal)  ///
		  (rcap high low n if months == 2, msize(medium)  color($green) horizontal  ///
		  yscale(range(0.75 9.25)) yline(3.5(3)`=_N+0.5', lcolor(gray) lpattern(dash) ) ) /// 
		  (scatter n b if months == 0, msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
		  xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
		  (scatter n b if months == 1, msize(medium) msymbol(T) color($orange)) ///
		   (scatter n b if months == 2, msize(medium) msymbol(S) color($green) ///
		   ylabel(`ylabel') legend(col(3) lab(4 "Baseline") lab(5 "Receipt Share of Months") lab(6 "0 Versus 12 Months") order(4 5 6) ) )

		
		}
		
		if "`spec'" == "_li" {

		gr twoway /// 
			(rcap high low n if months == 0, color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
		  (rcap high low n if months == 1, msize(medium)  color($orange) horizontal)  ///
		  (rcap high low n if months == 2, msize(medium)  color($green) horizontal  ///
		  yscale(range(0.75 9.25)) yline(3.5(3)`=_N+0.5', lcolor(gray) lpattern(dash) ) ) /// 
		  (scatter n b if months == 0, msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
		  xtitle("Predictive Effect of Participation on Lifetime Rank") ytitle("") )  /// 
		  (scatter n b if months == 1, msize(medium) msymbol(T) color($orange)) ///
		   (scatter n b if months == 2, msize(medium) msymbol(S) color($green) ///
		   ylabel(`ylabel') legend(col(3) lab(4 "Baseline") lab(5 "Receipt Share of Months") lab(6 "0 Versus 12 Months") order(4 5 6) ) )
		
		}
		
				gr export "$dir/figures/eligregs_robustness_6`spec'.pdf", replace

	
		}
