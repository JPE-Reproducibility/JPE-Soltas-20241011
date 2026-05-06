/***************************************************************************
* Appendix Figure A7, Panel A and B: Selection into Transfer Receipt: Income Interacted with Household Structure, Selection on Consumption and Selection on Lifetime Income
*
* Description:
* This script conducts a robustness check on self-targeting estimates by 
* testing whether the relationship between program participation and 
* economic outcomes persists when controlling more flexibly for household 
* structure. It compares baseline specifications with models that interact 
* income rank and spline terms with detailed household structure indicators.
* 
* Regressions are run separately for eight transfer programs (SNAP, Medicaid, 
* LIHEAP, School Meals, SSI, WIC, Housing Assistance, and TANF) and for two 
* outcome measures: consumption rank and lifetime income rank. A pooled 
* estimate across programs is also included.
* 
* Inputs:
* - PSID base dataset ("$dir/data/psid_base")
* - Eligibility simulation results (generated via run_all_eligsims)
* 
* Outputs:
* - CSV file with regression results ("$dir/figures/participation_reg_robustness4.csv")
* - Appendix Figure A6 plots comparing baseline and household structure–
*   controlled specifications:
*   - For consumption rank: "$dir/figures/eligregs_robustness_4_c.pdf"
*   - For lifetime income rank: "$dir/figures/eligregs_robustness_4_li.pdf"
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
 
* Recode household structure

	gegen hh_structure = group(hhsize nchild married)

* Run regressions

	keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

	* Generate eligibility
	ren *housing_assistance* *ha*
	
* write a .csv
cap file close fh
file open fh using  "$dir/figures/participation_reg_robustness4.csv", write replace
file write fh "prog,spec,hh_structure,b,se" _n

foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf  {
	
	foreach spec in "_c" "_li" {
	
	* All sample
	if "`spec'" != "_c" {
        qui reg rk_lifetime_eq  bs_rk* `prog' if eligsim_`prog'==1 [pw=wtfam],  cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
		qui reg rk_c_current_eq  bs_rk* `prog' if eligsim_`prog'==1 [pw=wtfam],  cl(famid_orig) 
	  }
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`spec',0," (`b') "," (`se') _n
		
	* HH-structure interaction
		* All sample
		di "`prog'"
	if "`spec'" != "_c" {
		qui reg rk_lifetime_eq  i.hh_structure#c.bs_rk*  `prog' if eligsim_`prog'==1   [pw=wtfam],  cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
	qui reg rk_c_current_eq  i.hh_structure#c.bs_rk* `prog' if eligsim_`prog'==1  [pw=wtfam],  cl(famid_orig) 
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
	keep r_* id year rk_current_eq rk_c_current_eq rk_lifetime_eq wtfam eligsim_* famid_orig bs_rk* hh_structure
	
	reshape long r_ eligsim_, i(id year) j(transfer) string
	
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
		
	* HH-structure interaction
	
	if "`outcome'" == "_c" {
	qui reghdfe rk_c_current_eq r_ if eligsim_==1 [pw=wtfam], a(prog i.hh_structure#i.prog#c.bs_rk1 i.hh_structure#i.prog#c.bs_rk3 i.hh_structure#i.prog#c.bs_rk4 i.hh_structure#i.prog#c.bs_rk5 i.hh_structure#i.prog#c.bs_rk6 i.hh_structure#i.prog#c.bs_rk7) cl(famid_orig) 
	}
	if "`outcome'" == "_li" {
	qui reghdfe rk_lifetime_eq r_ if eligsim_==1 [pw=wtfam], a(prog i.hh_structure#i.prog#c.bs_rk1 i.hh_structure#i.prog#c.bs_rk3 i.prog#c.bs_rk4 i.hh_structure#i.prog#c.bs_rk5 i.hh_structure#i.prog#c.bs_rk6 i.hh_structure#i.prog#c.bs_rk7) cl(famid_orig) 
	}
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,`outcome',1," (`b') "," (`se') _n

	restore
	
}

cap file close fh

* make plot
	
	foreach spec in "_c" "_li" {
		
	    import delimited using  "$dir/figures/participation_reg_robustness4.csv", clear
		keep if spec == "`spec'"
		sort prog spec hh_structure b se
		duplicates drop prog spec hh_structure, force
		
		gen high = b + 1.96 * se
		gen low = b - 1.96 * se

		gen raweffect_tmp = b if hh_structure == 0
		bys prog: egen raweffect = mean(raweffect)
		replace raweffect = 5 if prog == "avg" 

		gen order = 1 if hh_structure == 0
		replace order = 2 if hh_structure == 1
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
				(rcap high low n if hh_structure == 1, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
				(rcap high low n if hh_structure == 0, msize(medium)  color( $orange ) horizontal ///
			  yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) )) /// 
			  (scatter n b if hh_structure == 1, msymbol(O) msize(medium) color( $navy ) ylabel(`ylabel') ///
			  xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
				(scatter n b if hh_structure == 0, msize(medium)  msymbol(T) color( $orange ) ylabel(`ylabel') ///
			  legend(col(2) lab(4 "Income Rank") lab(3 "Income Rank by Household Structure")  order(4 3 ) ))
			  
		}
		
		if spec == "_li" {

			gr twoway /// 
				(rcap high low n if hh_structure == 1, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
				(rcap high low n if hh_structure == 0, msize(medium)  color( $orange ) horizontal ///
			  yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) )) /// 
			  (scatter n b if hh_structure == 1, msymbol(O) msize(medium) color( $navy ) ylabel(`ylabel') ///
			  xtitle("Predictive Effect of Participation on Lifetime Rank") ytitle("") )  /// 
				(scatter n b if hh_structure == 0, msize(medium)  msymbol(T) color( $orange ) ylabel(`ylabel') ///
			  legend(col(2) lab(4 "Income Rank") lab(3 "Income Rank by Household Structure")  order(4 3 ) ))
			  
		}

		gr export "$dir/figures/eligregs_robustness_4`spec'.pdf", replace
		
	}
