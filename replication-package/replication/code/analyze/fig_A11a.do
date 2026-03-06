/***************************************************************************
 * Appendix Figure A11, Panel A: Robustness of Self-Targeting to Alternative Utility Functions, State Dependence in Health Status
 * 
 * Description:
 * This script estimates whether self-targeting patterns in transfer receipt 
 * are robust to state dependence in health. Specifically, it tests whether the 
 * predictive relationship between transfer participation and rank outcomes 
 * differs by health status.
 * 
 * The analysis splits households into three health groups based on 
 * self-reported health:
 * - Poor/Fair
 * - Good
 * - Very Good/Excellent
 * 
 * For each group, it estimates the effect of transfer receipt on two outcomes:
 * (1) Consumption rank conditional on current income
 * (2) Lifetime income rank
 * 
 * Regressions are run separately by program and pooled across programs, 
 * incorporating dollar share weights for the pooled results.
 * 
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base"`)
 * - Eligibility simulation results (via `run_all_eligsims`) 
 * 
 * Outputs:
 * - CSV file with regression results (`"$dir/figures/participation_reg_robustness9.csv"`)
 * - PDF figure (`"$dir/figures/eligregs_robustness_9.pdf"`)
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
	
	* Cut past consumption rank into terciles
	xtset id year
	gen health_grp = .
	replace health_grp = 0 if inlist(health,1,2)
	replace health_grp = 1 if inlist(health,3)
	replace health_grp = 2 if inlist(health,4,5)
	
* Run regressions

	keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

	* Generate eligibility
	ren *housing_assistance* *ha*
	
* write a .csv
cap file close fh
file open fh using  "$dir/figures/participation_reg_robustness9.csv", write replace
file write fh "prog,spec,grp,b,se" _n

foreach prog in snap schoolmeals medicaid liheap ssi wic ha tanf  {
	
	foreach spec in "_c" "_li" {
	forvalues g = 0/2 {
	
	if "`spec'" != "_c" {
        qui reg rk_lifetime_eq bs_rk* `prog' if eligsim_`prog'==1 & health_grp==`g' [pw=wtfam],  cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
		qui reg rk_c_current_eq bs_rk* `prog' if eligsim_`prog'==1 & health_grp==`g' [pw=wtfam],  cl(famid_orig)
	  }
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`spec',`g'," (`b') "," (`se') _n
	
}
	}
}


* Run self-targeting regression pooled across programs

foreach spec in "_c" "_li" {
	
	preserve

	rename (snap medicaid liheap wic tanf ssi ha schoolmeals) (r_snap r_medicaid r_liheap r_wic r_tanf r_ssi r_ha r_schoolmeals)
	keep r_* id year rk_current_eq rk_c_current_eq rk_lifetime_eq wtfam eligsim_* famid_orig bs_rk* health_grp
	
	reshape long r_ eligsim_, i(id year) j(transfer) string
	
	egen prog = group(transfer)

	foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf {
		
		local wtname = "wt_`prog'"
		local wtval = ${`wtname'}
		replace wtfam = wtfam * `wtval'
		
		di "`prog' : `wtval'"
			
	}
	
	forvalues g = 0/2 {
	
	if "`spec'" != "_c" {
        qui reghdfe rk_lifetime_eq r_ if eligsim_==1 & health_grp==`g' [pw=wtfam], a(prog i.prog#c.bs_rk1 i.prog#c.bs_rk3 i.prog#c.bs_rk4 i.prog#c.bs_rk5 i.prog#c.bs_rk6 i.prog#c.bs_rk7) cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
	  	 qui reghdfe rk_c_current_eq r_ if eligsim_==1 & health_grp==`g' [pw=wtfam], a(prog i.prog#c.bs_rk1 i.prog#c.bs_rk3 i.prog#c.bs_rk4 i.prog#c.bs_rk5 i.prog#c.bs_rk6 i.prog#c.bs_rk7) cl(famid_orig) 
	  }
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,`spec',`g'," (`b') "," (`se') _n
	
	}

	restore
	
}

cap file close fh

* make plot
	
	foreach spec in "_c" "_li" {
		
	    import delimited using  "$dir/figures/participation_reg_robustness9.csv", clear
		keep if spec == "`spec'"
		duplicates drop prog spec grp, force
		
		gen high = b + 1.96 * se
		gen low = b - 1.96 * se

		gen raweffect_tmp = b if grp == 0
		bys prog: egen raweffect = mean(raweffect)
		replace raweffect = 5 if prog == "avg" 

		gen order = 1 if grp == 2
		replace order = 2 if grp == 1
		replace order = 3 if grp == 0
		gsort raweffect -order 

		gen n = _n
		
		local avgname {bf:Average}
		local wicname WIC
		local snapname SNAP
		local ssiname SSI
		local schoolmealsname "School Meals"
		local tanfname TANF
		local medicaidname Medicaid
		local liheapname LIHEAP
		local haname Housing

		local ylabel = "" 
		foreach obs of numlist 1.5(3)`=_N-1' {
		  local yval = `obs'+0.5
		  local progtype = prog[`obs']
		  local name ``progtype'name'
		  local ylabel = `" `ylabel' `yval' "`name'" "'
		}

		
		global navy `" "51 122 183" "'
		global green `" "92 184 92" "'
		global ltblue `" "91 192 222" "'
		global red `" "217 83 79" "'
		global orange `" "240 173 78" "'
		
		if spec == "_c" {

			gr twoway /// 
				(rcap high low n if grp == 2, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
				(rcap high low n if grp == 1, color( $orange ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
				(rcap high low n if grp == 0, msize(medium)  color( $green ) horizontal ///
			  yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) )) /// 
			  (scatter n b if grp == 2, msymbol(O) msize(medium) color( $navy )  ///
			  xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
				(scatter n b if grp == 1, msize(medium)  msymbol(T) color( $orange ) ylabel(`ylabel')) ///
				(scatter n b if grp == 0, msize(medium)  msymbol(S) color( $green ) ///
			  legend(col(3) lab(4 "Poor or Fair") lab(5 "Good") lab(6 "Very Good or Excellent")  order(4 5 6) ))

		gr export "$dir/figures/eligregs_robustness_9.pdf", replace
		}
		
	}
