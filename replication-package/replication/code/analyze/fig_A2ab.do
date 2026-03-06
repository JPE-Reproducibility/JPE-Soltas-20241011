/***************************************************************************
 * Appendix Figure A2, Panel A and B: Raw Differences in Income, Consumption, and Lifetime Income by Transfer Benchmarks for Magnitude of Self-Targeting, Consumption and Lifetime Income
 * 
 * Description:
 * This script estimates the raw differences in economic rank outcomes 
 * between transfer recipients and eligible nonrecipients, providing a 
 * benchmark for the degree of self-targeting across programs. It compares:
 * (1) Current income rank,
 * (2) Lifetime income rank,
 * (3) Consumption rank conditional on current income.
 * 
 * Regressions are run separately by program and outcome, and also pooled 
 * across programs. Results are exported to a CSV and used to generate 
 * Appendix Figure A2.
 * 
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * 
 * Outputs:
 * - CSV file with regression results (`"$dir/figures/participation_reg_robustness11.csv"`)
 * - PDF figures by specification (`"$dir/figures/eligregs_robustness_11_c.pdf"`, etc.)
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
		
* Run regressions

	keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

	* Generate eligibility
	ren *housing_assistance* *ha*
	
* write a .csv
cap file close fh
file open fh using  "$dir/figures/participation_reg_robustness11.csv", write replace
file write fh "prog,spec,inc,b,se" _n

foreach prog in snap schoolmeals medicaid liheap ssi wic ha tanf  {
	
	foreach spec in "_c" "_li" {
	
	if "`spec'" != "_c" {
        qui reg rk_current_eq `prog' if eligsim_`prog'==1 [pw=wtfam],  cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
		qui reg rk_current_eq `prog' if eligsim_`prog'==1  [pw=wtfam],  cl(famid_orig) 
	  }
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`spec',1," (`b') "," (`se') _n
	
}
}

foreach prog in snap schoolmeals medicaid liheap ssi wic ha tanf  {
	
	foreach spec in "_c" "_li" {
	
	if "`spec'" != "_c" {
        qui reg rk_lifetime_eq `prog' if eligsim_`prog'==1 [pw=wtfam],  cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
		qui reg rk_c_current_eq `prog' if eligsim_`prog'==1  [pw=wtfam],  cl(famid_orig) 
	  }
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`spec',2," (`b') "," (`se') _n
	
}
}

foreach prog in snap schoolmeals medicaid liheap ssi wic ha tanf  {
	
	foreach spec in "_c" "_li" {
	
	if "`spec'" != "_c" {
        qui reg rk_lifetime_eq bs_rk* `prog' if eligsim_`prog'==1 [pw=wtfam],  cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
		qui reg rk_c_current_eq bs_rk* `prog' if eligsim_`prog'==1  [pw=wtfam],  cl(famid_orig) 
	  }
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`spec',3," (`b') "," (`se') _n
	
}
}


* Run self-targeting regression pooled across programs

foreach outcome in "_c" "_li" {
	
	preserve

	rename (snap medicaid liheap wic tanf ssi ha schoolmeals) (r_snap r_medicaid r_liheap r_wic r_tanf r_ssi r_ha r_schoolmeals)
	keep r_* id year rk_current_eq rk_c_current_eq rk_lifetime_eq wtfam eligsim_* famid_orig bs_rk*
	
	reshape long r_ eligsim_, i(id year) j(transfer) string
	
	egen prog = group(transfer)

	foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf {
		
		local wtname = "wt_`prog'"
		local wtval = ${`wtname'}
		replace wtfam = wtfam * `wtval'
		
		di "`prog' : `wtval'"
			
	}
	
	if "`outcome'" == "_c" {
	qui reghdfe rk_current_eq r_ if eligsim_==1 [pw=wtfam], a(prog) cl(famid_orig) 
	}
	if "`outcome'" == "_li" {
	qui reghdfe rk_current_eq r_ if eligsim_==1 [pw=wtfam], a(prog) cl(famid_orig) 
	}
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,`outcome',1," (`b') "," (`se') _n
	
	if "`outcome'" == "_c" {
	qui reghdfe rk_c_current_eq r_ if eligsim_==1 [pw=wtfam], a(prog) cl(famid_orig) 
	}
	if "`outcome'" == "_li" {
	qui reghdfe rk_lifetime_eq r_ if eligsim_==1 [pw=wtfam], a(prog) cl(famid_orig) 
	}
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,`outcome',2," (`b') "," (`se') _n
	
	if "`outcome'" == "_c" {
	reghdfe rk_c_current_eq r_ if eligsim_==1 [pw=wtfam], a(prog i.prog#c.bs_rk1 i.prog#c.bs_rk3 i.prog#c.bs_rk4 i.prog#c.bs_rk5 i.prog#c.bs_rk6 i.prog#c.bs_rk7) cl(famid_orig) 
	}
	if "`outcome'" == "_li" {
	reghdfe rk_lifetime_eq r_ if eligsim_==1 [pw=wtfam], a(prog i.prog#c.bs_rk1 i.prog#c.bs_rk3 i.prog#c.bs_rk4 i.prog#c.bs_rk5 i.prog#c.bs_rk6 i.prog#c.bs_rk7) cl(famid_orig) 
	}
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,`outcome',3," (`b') "," (`se') _n
	
	restore
	
}


cap file close fh

* make plot
	
	foreach spec in "_c" "_li" {
		
	    import delimited using  "$dir/figures/participation_reg_robustness11.csv", clear
		keep if spec == "`spec'"
		duplicates drop prog spec inc, force
		
		gen high = b + 1.96 * se
		gen low = b - 1.96 * se

		gen raweffect_tmp = b if inc == 3
		bys prog: egen raweffect = mean(raweffect)
		replace raweffect = 5 if prog == "avg" 

		gen order = 1 if inc == 1
		replace order = 2 if inc == 2
		replace order = 3 if inc == 3
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
				(rcap high low n if inc == 1, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
				(rcap high low n if inc == 2, color( $orange ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
				(rcap high low n if inc == 3, msize(medium)  color( $green ) horizontal ///
			  yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) )) /// 
			  (scatter n b if inc == 1, msymbol(O) msize(medium) color( $navy )  ///
			  xtitle("Difference in Ranks, Recipients Minus Eligible Nonrecipients") ytitle("") )  /// 
				(scatter n b if inc == 2, msize(medium)  msymbol(T) color( $orange ) ylabel(`ylabel')) ///
				(scatter n b if inc == 3, msize(medium)  msymbol(S) color( $green ) ///
			  legend(col(3) lab(4 "Income") lab(5 "Consumption") lab(6 "Consumption Given Income")  order(4 5 6) ))
			  
		}
		
		if spec != "_c" {

			gr twoway /// 
				(rcap high low n if inc == 1, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
				(rcap high low n if inc == 2, color( $orange ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
				(rcap high low n if inc == 3, msize(medium)  color( $green ) horizontal ///
			  yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) )) /// 
			  (scatter n b if inc == 1, msymbol(O) msize(medium) color( $navy )  ///
			  xtitle("Difference in Ranks, Recipients Minus Eligible Nonrecipients") ytitle("") )  /// 
				(scatter n b if inc == 2, msize(medium)  msymbol(T) color( $orange ) ylabel(`ylabel')) ///
				(scatter n b if inc == 3, msize(medium)  msymbol(S) color( $green ) ///
			  legend(col(3) lab(4 "Current Income") lab(5 "Lifetime Income") lab(6 "Lifetime Given Current")  order(4 5 6) ))
			  
		}


		gr export "$dir/figures/eligregs_robustness_11`spec'.pdf", replace
		
	}
