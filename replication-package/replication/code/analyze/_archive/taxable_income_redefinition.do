/***************************************************************************

xxx

***************************************************************************/		

* Settings

	do code/settings.do
	do "$dir/code/stata-tex.do"
	
	discard
    set scheme simplescheme 

* Load data 

	use "$dir/data/psid_base", clear	
		
	* Compute alternative income ranks	
		
		gen equivalence_scale = ((hhsize-nchild)+0.7*nchild)^0.7
		
		gen eq_income_real_tot = (faminct_real+hhsize*tot_amt_hh) / equivalence_scale
	gen eq_income_real_cash = (faminct_real+hhsize*cash_amt_hh) / equivalence_scale
		
		bys year (eq_income_real_tot): gen rk_current_eq_tot = sum(wtfam) if !missing(faminct_real) & !missing(lifetime_income) & !missing(consumption_real) & !missing(tot_amt_hh)
		bys year: gegen min_rk_current_eq = min(rk_current_eq_tot)
		bys year: gegen max_rk_current_eq = max(rk_current_eq_tot)
		replace rk_current_eq_tot = 100*(rk_current_eq_tot - min_rk_current_eq) / (max_rk_current_eq - min_rk_current_eq)
		
		drop max_rk_current_eq min_rk_current_eq
		
		bys year (eq_income_real_cash): gen rk_current_eq_cash = sum(wtfam) if !missing(faminct_real) & !missing(lifetime_income) & !missing(consumption_real) & !missing(cash_amt_hh)
		bys year: gegen min_rk_current_eq = min(rk_current_eq_cash)
		bys year: gegen max_rk_current_eq = max(rk_current_eq_cash)
		replace rk_current_eq_cash = 100*(rk_current_eq_cash - min_rk_current_eq) / (max_rk_current_eq - min_rk_current_eq)
		
	* Get basis splines
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis splines
		frencurv, gen(bs1_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
		frencurv, gen(bs2_rk) x(rk_current_eq_tot) p(3) refpts(`refpts') omit(0)
		frencurv, gen(bs3_rk) x(rk_current_eq_cash) p(3) refpts(`refpts') omit(0)

	* Run eligibility simulators and limit sample
		
		run_all_eligsims
		
		cap drop eligsim_anytransfer 
	egen eligsim_anytransfer = rowmax(eligsim_snap eligsim_medicaid eligsim_schoolmeals eligsim_liheap eligsim_ssi eligsim_wic eligsim_housing eligsim_tanf) 
	egen anytransfer = rowmax(snap medicaid liheap ssi wic schoolmeals housing_assistance tanf)
		
		keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

		ren *housing_assistance* *ha*

* Run analysis
		
* write a .csv
cap file close fh
file open fh using  "$dir/figures/taxable_income_redefinition.csv", write replace
file write fh "prog,spec,inc,b,se" _n

foreach prog in anytransfer snap schoolmeals medicaid liheap ssi wic ha tanf  {
	
	foreach spec in "_c" "_li" {
	
	if "`spec'" != "_c" {
        qui reg rk_lifetime_eq `prog' bs1_rk* if eligsim_`prog'==1 [pw=wtfam],  cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
		qui reg rk_c_current_eq `prog' bs1_rk* if eligsim_`prog'==1  [pw=wtfam],  cl(famid_orig) 
	  }
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`spec',1," (`b') "," (`se') _n
	
}
}

foreach prog in anytransfer snap schoolmeals medicaid liheap ssi wic ha tanf  {
	
	foreach spec in "_c" "_li" {
	
	if "`spec'" != "_c" {
        qui reg rk_lifetime_eq `prog' bs2_rk*  if eligsim_`prog'==1 [pw=wtfam],  cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
		qui reg rk_c_current_eq `prog' bs2_rk*  if eligsim_`prog'==1  [pw=wtfam],  cl(famid_orig) 
	  }
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`spec',2," (`b') "," (`se') _n
	
}
}

foreach prog in anytransfer snap schoolmeals medicaid liheap ssi wic ha tanf  {
	
	foreach spec in "_c" "_li" {
	
	if "`spec'" != "_c" {
        qui reg rk_lifetime_eq  bs3_rk* `prog' if eligsim_`prog'==1 [pw=wtfam],  cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
		qui reg rk_c_current_eq bs3_rk* `prog' if eligsim_`prog'==1  [pw=wtfam],  cl(famid_orig) 
	  }
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`spec',3," (`b') "," (`se') _n
	
}
}

cap file close fh

* make plot
	
	foreach spec in "_c" "_li" {
		
	    import delimited using  "$dir/figures/taxable_income_redefinition.csv", clear
		keep if spec == "`spec'"
		duplicates drop prog spec inc, force
		
		gen high = b + 1.96 * se
		gen low = b - 1.96 * se

		gen raweffect_tmp = b if inc == 3
		bys prog: egen raweffect = mean(raweffect)
		replace raweffect = 5 if prog == "anytransfer" 

		gen order = 1 if inc == 1
		replace order = 2 if inc == 2
		replace order = 3 if inc == 3
		gsort raweffect -order 

		gen n = _n
		
		local anytransfername {bf:Any}
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
				(rcap high low n if inc == 1, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-25(5)20) xscale(range(-25 5))) ///
				(rcap high low n if inc == 2, color( $orange ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-25(5)20) xscale(range(-25 5))) ///
				(rcap high low n if inc == 3, msize(medium)  color( $green ) horizontal ///
			  yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) )) /// 
			  (scatter n b if inc == 1, msymbol(O) msize(medium) color( $navy )  ///
			  xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
				(scatter n b if inc == 2, msize(medium)  msymbol(T) color( $orange ) ylabel(`ylabel')) ///
				(scatter n b if inc == 3, msize(medium)  msymbol(S) color( $green ) ///
			  legend(col(3) lab(4 "Baseline") lab(5 "+ All Transfers") lab(6 "+ Cash Transfers")  order(4 5 6) ))
			  
		}
		
		if spec != "_c" {

			gr twoway /// 
				(rcap high low n if inc == 1, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-25(5)20) xscale(range(-25 5))) ///
				(rcap high low n if inc == 2, color( $orange ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-25(5)20) xscale(range(-25 5))) ///
				(rcap high low n if inc == 3, msize(medium)  color( $green ) horizontal ///
			  yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) )) /// 
			  (scatter n b if inc == 1, msymbol(O) msize(medium) color( $navy )  ///
			  xtitle("Predictive Effect of Participation on Lifetime Income Rank") ytitle("") )  /// 
				(scatter n b if inc == 2, msize(medium)  msymbol(T) color( $orange ) ylabel(`ylabel')) ///
				(scatter n b if inc == 3, msize(medium)  msymbol(S) color( $green ) ///
			  legend(col(3) lab(4 "Baseline") lab(5 "+ All Transfers") lab(6 "+ Cash Transfers")  order(4 5 6) ))
			  
		}


		gr export "$dir/figures/taxable_income_redefinition`spec'.pdf", replace
		
	}
