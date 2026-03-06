/***************************************************************************
 * Appendix Figure A24, Panel A and B: Self-Targeting Among the Very Likely Eligible (PSID), Selection on Consumption 
 * and Selection on Lifetime Income
 *
 * Description:
 * This script estimates the predictive effect of transfer receipt on household
 * rank in the consumption distribution and lifetime-income rank, conditional
 * on current-income rank. It compares estimates for the full sample of
 * simulated eligibles with a subsample of "very likely eligibles" (predicted
 * eligibility probability > 75% based on demographic observables). The script
 * generates a CSV file containing the regression estimates and produces figures
 * visualizing these effects with confidence intervals.
 *
 * Inputs:
 * - PSID-based dataset: `"$dir/data/psid_base"`
 *
 * Outputs:
 * - CSV of estimates: `"$dir/figures/participation_reg_robustness.csv"`
 * - Figures:
 * - `"$dir/figures/eligregs_robustness_c.pdf"` (Effect on Consumption Rank)
 * - `"$dir/figures/eligregs_robustness_li.pdf"` (Effect on Lifetime Income Rank)
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
	get_dollar_shares

* Recode demographics

	gen race_recode = .
	replace race_recode = 1 if white==1 & hispanic==0
	replace race_recode = 2 if black==1 & hispanic==0
	replace race_recode = 3 if hispanic>0 & !missing(hispanic)
	replace race_recode = 4 if missing(race_recode)
	
* Predict eligibility from demographics

	keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

	* Generate eligibility
	ren *housing_assistance* *ha*
	drop ui eligsim_ui
	
	* Predict
	summ inc_to_fpl, d
	gen ln_inc_to_fpl = inc_to_fpl
	replace ln_inc_to_fpl = 10 if inc_to_fpl<10
	replace inc_to_fpl = 1000 if inc_to_fpl>1000 & !missing(inc_to_fpl)
	replace ln_inc_to_fpl = ln(ln_inc_to_fpl)

	local demographics "c.age##c.age ln_inc_to_fpl i.race_recode married female disabled i.hhsize ownhome anychild rk_current_eq rk_lifetime_eq rk_c_current_eq i.year i.edcat"
	
	foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf  {
		logit eligsim_`prog' `demographics' [pw=wtfam]
		predict pr_eligsim_`prog'
	}
	
* write a .csv
cap file close fh
file open fh using  "$dir/figures/participation_reg_robustness.csv", write replace
file write fh "prog,spec,high_prelig,b,se" _n

foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf  {
	
	foreach spec in "_c" "_li" {
	
	* All sample
	if "`spec'" != "_c" {
        qui reg rk_lifetime_eq  bs_rk* `prog' if eligsim_`prog'==1 & !missing(pr_eligsim_`prog') [pw=wtfam],  cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
		qui reg rk_c_current_eq  bs_rk* `prog' if eligsim_`prog'==1 & !missing(pr_eligsim_`prog') [pw=wtfam],  cl(famid_orig) 
	  }
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`spec',0," (`b') "," (`se') _n
		
	* High eligibility sample
		di "`prog'"
	if "`spec'" != "_c" {
		qui reg rk_lifetime_eq  bs_rk* `prog' if eligsim_`prog'==1 & pr_eligsim_`prog'>0.75 & !missing(pr_eligsim_`prog')  [pw=wtfam],  cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
	qui reg rk_c_current_eq  bs_rk* `prog' if eligsim_`prog'==1 & pr_eligsim_`prog'>0.75 & !missing(pr_eligsim_`prog')  [pw=wtfam],  cl(famid_orig) 
	  }
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`spec',1," (`b') "," (`se') _n
	
}
}


* Run self-targeting regression pooled across programs

foreach outcome in "_c" "_li" {
	
	preserve

	rename (snap medicaid liheap wic tanf ssi ha schoolmeals) (r_snap r_medicaid r_liheap r_wic r_tanf r_ssi r_ha r_schoolmeals)
	keep r_* id year rk_current_eq rk_c_current_eq rk_lifetime_eq wtfam eligsim_* famid_orig bs_rk* pr_eligsim_*
	
	reshape long r_ eligsim_ pr_eligsim_, i(id year) j(transfer) string
	
	egen prog = group(transfer)

	foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf {
		
		local wtname = "wt_`prog'"
		local wtval = ${`wtname'}
		replace wtfam = wtfam * `wtval'
		
		di "`prog' : `wtval'"
			
	}
	
	* All sample
	if "`outcome'" == "_c" {
	qui reghdfe rk_c_current_eq i.prog#c.bs_rk* r_ if eligsim_==1 [pw=wtfam], a(prog) cl(famid_orig) 
	}
	if "`outcome'" == "_li" {
	qui reghdfe rk_lifetime_eq i.prog#c.bs_rk* r_ if eligsim_==1 [pw=wtfam], a(prog) cl(famid_orig) 
	}
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,`outcome',0," (`b') "," (`se') _n
	
	
	* High eligibility sample
		di "`prog'"
	if "`outcome'" != "_c" {
		qui reghdfe rk_lifetime_eq r_ if eligsim_==1 & pr_eligsim_>0.75 & !missing(pr_eligsim_`prog')  [pw=wtfam], a(prog i.prog#c.bs_rk1 i.prog#c.bs_rk3 i.prog#c.bs_rk4 i.prog#c.bs_rk5 i.prog#c.bs_rk6 i.prog#c.bs_rk7) cl(famid_orig) 
	  }
	  if "`outcome'" == "_c" {
	qui reghdfe rk_c_current_eq r_ if eligsim_==1 & pr_eligsim_>0.75 & !missing(pr_eligsim_)  [pw=wtfam], a(prog i.prog#c.bs_rk1 i.prog#c.bs_rk3 i.prog#c.bs_rk4 i.prog#c.bs_rk5 i.prog#c.bs_rk6 i.prog#c.bs_rk7) cl(famid_orig) 
	  }
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,`outcome',1," (`b') "," (`se') _n

	restore
	
}

cap file close fh

* make plot
	
	foreach spec in "_c" "_li" {
		
	    import delimited using  "$dir/figures/participation_reg_robustness.csv", clear
		keep if spec == "`spec'"
		
		gen high = b + 1.96 * se
		gen low = b - 1.96 * se

		gen raweffect_tmp = b if high_prelig == 0
		bys prog: egen raweffect = mean(raweffect)
		replace raweffect = 5 if prog == "avg" 

		gen order = 1 if high_prelig == 0
		replace order = 2 if high_prelig == 1
		gsort raweffect -order 

		gen n = _n
		
		local avgname {bf:Average}
		local wicname WIC
		local snapname SNAP
		local schoolmealsname "School Meals"
		local ssiname SSI
		local tanfname TANF
		local medicaidname Medicaid
		local liheapname LIHEAP
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
		
		if spec == "_c" {

			gr twoway /// 
				(rcap high low n if high_prelig == 1, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
				(rcap high low n if high_prelig == 0, msize(medium)  color( $orange ) horizontal ///
			  yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) )) /// 
			  (scatter n b if high_prelig == 1, msymbol(O) msize(medium) color( $navy ) ylabel(`ylabel') ///
			  xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
				(scatter n b if high_prelig == 0, msize(medium)  msymbol(T) color( $orange ) ylabel(`ylabel') ///
			  legend(col(2) lab(4 "Full Sample") lab(3 "Very Likely Eligible")  order(4 3 ) ))
			  
		}
		
		if spec == "_li" {

			gr twoway /// 
				(rcap high low n if high_prelig == 1, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
				(rcap high low n if high_prelig == 0, msize(medium)  color( $orange ) horizontal ///
			  yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) )) /// 
			  (scatter n b if high_prelig == 1, msymbol(O) msize(medium) color( $navy ) ylabel(`ylabel') ///
			  xtitle("Predictive Effect of Participation on Lifetime Rank") ytitle("") )  /// 
				(scatter n b if high_prelig == 0, msize(medium)  msymbol(T) color( $orange ) ylabel(`ylabel') ///
			  legend(col(2) lab(4 "Full Sample") lab(3 "Very Likely Eligible")  order(4 3 ) ))
			  
		}

		gr export "$dir/figures/eligregs_robustness`spec'.pdf", replace
		
	}
