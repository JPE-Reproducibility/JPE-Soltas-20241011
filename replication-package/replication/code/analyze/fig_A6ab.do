/***************************************************************************
 * Appendix Figure A6, Panel A and B: Self-Targeting in Transfer Programs (Non-Equivalized Households), Selection on Consumption and Selection on Lifetime Income
 * 
 * Description:
 * This script estimates the relationship between transfer receipt and 
 * income rank using constrained and unconstrained regressions. The 
 * constraint is applied to the coefficient on current income rank to 
 * assess sensitivity of lifetime rank effects. Results are exported to a 
 * CSV and formatted for inclusion in the appendix.
 * 
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * 
 * Outputs:
 * - CSV file with regression results (`"$dir/tables/data/constrained_reg.csv"`)
 * - Formatted LaTeX table (`"$dir/tables/output/constrained_reg_final.tex"`)
 * - Note that only eligregs_appear_2_c_no3hh.pdf (Panel A) and eligregs_appear_2_hh_nohh.pdf (Panel B) are shown in the paper. Other figures are kept for reference.
 ***************************************************************************/

	qui do code/settings.do
	
	discard
	adopath + "$dir/code"
	adopath + "$dir/code/eligsim"

	do "$dir/code/stata-tex.do"
	set scheme simplescheme
	
* Load data 

	use "$dir/data/psid_base", clear
	
	* Create basis spline for rk_current_hh
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_current_hh) p(3) refpts(`refpts') omit(0)
		
	* log spending or income variables to address outliers 
	gen ln_faminc = ln(faminct_real+1)
	gen ln_famearn = ln(famearn_real+1)
	gen ln_housing_exp = ln(housing_exp+1)
	gen ln_utility_exp = ln(utility_exp+1)
	gen ln_earnings = ln(earnings_real+1 )
	gen ln_wsav = ln(wsav_real+1)
	gen ln_wcar = ln(wcar_real+1)

	qui run_all_eligsims


  keep if !missing(rk_lifetime_hh) & !missing(rk_current_hh) & !missing(rk_c_current_hh)

	* parameterize the eligiblity function for each variable 
	global allvars i.state i.year i.hhsize c.ln_faminc fpl i.age i.age_youngest i.nchild c.ln_famearn c.ln_utility_exp c.ln_earn c.wks_unemp i.why_unemp c.ln_wsav c.ln_wcar i.disabled 
	global medicaidvars i.state#i.year i.hhsize ln_faminc fpl i.age i.age_youngest i.nchild i.ssi
	global snapvars i.state i.year i.hhsize ln_faminc ln_famearn fpl hhsize#c.ln_faminc#c.fpl i.hhsize#c.ln_famearn#c.fpl i.hhsize#c.ln_housing_exp#c.fpl
	global liheapvars i.state i.year ln_faminc i.hhsize ln_utility_exp
	global uivars i.wks_unemp i.why_unemp ln_earnings i.state i.year
	global ssivars ln_earnings ln_faminc ln_famearn i.hhsize i.nchild ln_wsav ln_wcar i.disabled i.year
	global wicvars ln_faminc fpl i.snap i.tanf i.medicaid
	global housing_assistancevars i.state i.hhsize i.year ln_faminc ln_wsav 
	global tanfvars i.state i.year i.hhsize ln_faminc i.anychild ln_wcar ln_wsav

  egen any = rowmax(snap medicaid liheap schoolmeals ssi wic housing_assistance tanf) 

/****************************************/
/* * get imputed eligibility variables  */
/****************************************/
foreach prog in snap medicaid liheap schoolmeals ssi wic housing_assistance tanf { 

    * generate an imputed eligibility variable 
    cap drop imp_elig_`prog'
    
    if "`prog'" != "any" {
      gen imp_elig_`prog' = eligsim_`prog'
      replace imp_elig_`prog' = 1 if `prog' == 1      
    }

      * partial 
      local threshold_low = 10
      local threshold_high = 50 

      cap drop imp_part_`prog' 
      gen imp_part_`prog' = eligsim_`prog'
      replace imp_part_`prog' = 1 if rk_current_hh < `threshold_low'
      
      cap drop max_rk_current_hh 
      bys id (year): egen max_rk_current_hh = max(rk_current_hh)
      bys id (year): replace imp_part_`prog' = 0 if max_rk_current_hh > `threshold_high' & !mi(max_rk_current_hh) 

}

* now apply this procedure to the any eligibiliy variables
cap drop eligsim_any 
egen eligsim_any = rowmax(eligsim_snap eligsim_medicaid eligsim_liheap eligsim_schoolmeals eligsim_ssi eligsim_wic eligsim_housing_assistance eligsim_tanf) 

cap drop imp_elig_any 
egen imp_elig_any = rowmax(imp_elig_snap imp_elig_medicaid imp_elig_liheap imp_elig_schoolmeals imp_elig_ssi imp_elig_wic imp_elig_housing_assistance imp_elig_tanf) 

cap drop imp_part_any 
egen imp_part_any = rowmax(imp_part_snap imp_part_medicaid imp_part_liheap imp_part_schoolmeals imp_part_ssi imp_part_wic imp_part_housing_assistance imp_part_tanf) 

/***********/
/* regressions  */
/***********/
* write a .csv
cap file close fh
file open fh using  "$dir/figures/participation_reg_hh.csv", write replace
file write fh "prog,spec,imputed_eligibility,regtype,b,se" _n

foreach eligvar in yes partial no {
  
  foreach prog in any snap medicaid liheap schoolmeals ssi wic housing_assistance tanf  {

    if "`eligvar'" == "no" local eligsim = "eligsim_`prog'"
    if "`eligvar'" == "yes" local eligsim = "imp_elig_`prog'" 
    if "`eligvar'" == "partial" local eligsim = "imp_part_`prog'" 
    
    foreach spec in "_hh" "_c" {
      
      * raw regression 
      if "`spec'" != "_c" {
        qui reg rk_lifetime`spec' bs_rk* `prog'  [pw=wtfam],  cl(famid_orig) 
      }
      if "`spec'" == "_c" {
        qui reg rk_c_current_hh bs_rk* `prog' [pw=wtfam], cl(famid_orig)   
      }
		
    local b = _b[`prog']
    local se = _se[`prog']
    file write fh "`prog',`spec',`eligvar',raw," (`b') "," (`se') _n

      * regression if eligible

      if "`spec'" != "_c" {
        qui reg rk_lifetime`spec' bs_rk* `prog' if `eligsim' == 1 [pw=wtfam],  cl(famid_orig)        
      }
      if "`spec'" == "_c" {
        qui reg rk_c_current_hh bs_rk* `prog' if `eligsim' == 1 [pw=wtfam],  cl(famid_orig)  
      }

        local b = _b[`prog']
        local se = _se[`prog']
        file write fh "`prog',`spec',`eligvar',ifelig," (`b') "," (`se') _n
      
    }
   
  }
}


* Pooled across programs

	* re-parameterize the eligiblity function for each variable 
	
	gen tanf_ = tanf
	gen snap_ = snap
	gen medicaid_ = medicaid
	gen ssi_ = ssi
	
	global medicaidvars i.state#i.year i.hhsize ln_faminc fpl i.age i.age_youngest i.nchild i.ssi_
	global wicvars ln_faminc fpl i.snap_ i.tanf_ i.medicaid_
	capture drop eligsim_ui]

* Loop through cases
foreach eligvar in yes partial no {
	
  foreach spec in "_hh" "_c" {  
  	
	preserve
	
	rename (snap medicaid liheap wic tanf ssi ha schoolmeals) (r_snap r_medicaid r_liheap r_wic r_tanf r_ssi r_ha r_schoolmeals)
	keep r_* id year rk_current_* rk_lifetime_* rk_c_current_* wtfam eligsim_* imp_elig_* imp_part_* famid_orig bs_rk* white black hisp edcat married state hhsize ln_faminc fpl age age_youngest nchild ln_famearn ln_utility_exp ln_earn wks_unemp why_unemp ln_wsav ln_wcar disabled
	
	reshape long r_ eligsim_ imp_elig_ imp_part_, i(id year) j(transfer) string
	
	egen prog = group(transfer)

	foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf {
		local wtname = "wt_`prog'"
		local wtval = ${`wtname'}
		replace wtfam = wtfam * `wtval' if transfer == "`prog'"
	}
	
	if "`eligvar'" == "no" local eligsim = "eligsim_"
    if "`eligvar'" == "yes" local eligsim = "imp_elig_" 
    if "`eligvar'" == "partial" local eligsim = "imp_part_" 
	
	
	 * raw regression 
      if "`spec'" != "_c" {
        qui reghdfe rk_lifetime`spec' i.prog#c.bs_rk* r_ [pw=wtfam], a(prog) cl(famid_orig) 
      }
      if "`spec'" == "_c" {
        qui reghdfe rk_c_current_hh i.prog#c.bs_rk* r_ [pw=wtfam], a(prog) cl(famid_orig) 
      }
		
    local b = _b[r_]
    local se = _se[r_]
    file write fh "avg,`spec',`eligvar',raw," (`b') "," (`se') _n

      * regression if eligible

      if "`spec'" != "_c" {
        qui reghdfe rk_lifetime`spec' i.prog#c.bs_rk* r_ if `eligsim' == 1 [pw=wtfam], a(prog) cl(famid_orig) 
      }
      if "`spec'" == "_c" {
        qui reghdfe rk_c_current_hh i.prog#c.bs_rk* r_ if `eligsim' == 1 [pw=wtfam], a(prog) cl(famid_orig) 
      }

        local b = _b[r_]
        local se = _se[r_]
        file write fh "avg,`spec',`eligvar',ifelig," (`b') "," (`se') _n
		
	restore
	
  }
}

cap file close fh


/*****************/
/* Two version */
/*****************/
* generate a graph that is all programs together
local avgname {bf:Average}
local wicname WIC
local snapname SNAP
local schoolmealsname "School Meals"
local ssiname SSI
local tanfname TANF
local medicaidname Medicaid
local liheapname LIHEAP
local housing_assistancename Housing 

foreach imputed in "yes" "partial" "no" { 
  foreach spec in  "_hh" "_c" {
    
    import delimited using  "$dir/figures/participation_reg_hh.csv", clear
    keep if spec == "`spec'" & imputed == "`imputed'" 
    gen high = b + 1.96 * se
    gen low = b - 1.96 * se
	
	drop if prog == "avg_of_5"
    gen raweffect_tmp = b if regtype == "raw"
    bys prog: egen raweffect = mean(raweffect)
    replace raweffect = 5 if prog == "avg" 

    gen order = 1 if regtype == "raw" 
    replace order = 2 if regtype == "ifelig" 
    drop if !inlist(regtype,"raw","ifelig") 
    gsort raweffect -order 
    
    gen n = _n
    local ylabel = "" 
    foreach obs of numlist 1.5(2)`=_N' {
      local progtype = prog[`obs']
      local name ``progtype'name'
      local ylabel = `" `ylabel' `obs' "`name'" "'
    }
    
    global navy `" "51 122 183" "'
    global green `" "92 184 92" "'
    global ltblue `" "91 192 222" "'
    global red `" "217 83 79" "'
    global orange `" "240 173 78" "'

    if "`spec'" != "_c" {

    gr twoway /// 
        (rcap high low n if regtype == "raw", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
        (rcap high low n if regtype == "ifelig", msize(medium)  color($orange) horizontal  ///
      yscale(range(1 18)) yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Lifetime Rank") ytitle("") )  /// 
        (scatter n b if regtype == "ifelig", msize(medium)  msymbol(T) color($orange) ylabel(`ylabel')  legend(title("Conditional on:", size(medium)) ///
      col(2) lab(3 "Income Rank") lab(4 "Income Rank & Eligibility")  order(3 4) ) )

    gr export "$dir/figures/eligregs_appear_2`spec'_`imputed'hh.pdf", replace

    }

    if "`spec'" == "_c" {
		

    gr twoway /// 
        (rcap high low n if regtype == "raw", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5)))  ///
        (rcap high low n if regtype == "ifelig", msize(medium)  color($orange) horizontal  ///
          yscale(range(1 18))  xscale(range(-20 5)) xlabel(-20(5)5)   yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
        (scatter n b if regtype == "ifelig", msize(medium)  msymbol(T) color($orange) ylabel(`ylabel') legend(title("Conditional on:", size(medium)) ///
      col(2) lab(3 "Income Rank") order(3 4) lab(4 "Income Rank & Eligibility")  ) )

    gr export "$dir/figures/eligregs_appear_2`spec'_`imputed'3hh.pdf", replace
	
    }
  }
} 
