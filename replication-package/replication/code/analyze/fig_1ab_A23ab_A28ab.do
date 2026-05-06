/***************************************************************************
 * Figure 1, Panel A and B: Self-Targeting in Transfer Programs, Selection on Consumption and Selection on Lifetime 
 * Income
 * Figure A23, Panel A and B: Self-Targeting in Transfer Programs: Reclassifying Simulated Ineligible Recipients, Selection on Consumption and Selection 
 * on Lifetime Income
 * Figure A28, Panel A and B: What Explains Selection into Transfer Receipt? With Controls, Selection on Consumption 
 * and Selection on Lifetime Income
 *
 * Description:
 * This script loads regression results from earlier analysis and creates
 * coefficient plots by specification (Raw, If Eligible, Rich Controls,
 * Unused Observables) for each transfer program. It produces separate
 * figures for outcomes including log consumption and income rank, and 
 * pooled effects across all programs. The graphs are formatted for 
 * inclusion in the main paper and appendix.
 * 
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * 
 * Outputs:
 * - CSV file with regression results (`"$dir/figures/participation_reg.csv"`)
 * - Plots of predictive rank effects
 *
 * Note: in the paper, only the figures eligregs_appear_2_c_no3.pdf (Figure 1 Panel A), eligregs_appear_2_eq_no.pdf (Figure 1 Panel B), eligregs_appear_2_c_yes3.pdf   
 * (Figure 23 Panel A), eligregs_appear_2_eq_yes.pdf (Figure 23 Panel B), eligregs_appear_me__c_no.pdf, and eligregs_appear_me__eq_no.pdf are used. Other figures are 
 * kept for reference.
 ***************************************************************************/

* Settings

	qui do code/settings.do
	
	discard
	adopath + "$dir/code"
	adopath + "$dir/code/eligsim"

	do "$dir/code/stata-tex.do"
	set scheme simplescheme
	
* Load data 

	use "$dir/data/psid_base", clear
	
	* Create basis spline for rk_current_eq
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
		
	* log spending or income variables to address outliers 
	gen ln_faminc = ln(faminct_real+1)
	gen ln_famearn = ln(famearn_real+1)
	gen ln_housing_exp = ln(housing_exp+1)
	gen ln_utility_exp = ln(utility_exp+1)
	gen ln_earnings = ln(earnings_real+1 )
	gen ln_wsav = ln(wsav_real+1)
	gen ln_wcar = ln(wcar_real+1)

	qui run_all_eligsims
	qui get_dollar_shares
	ren *housing_assistance* *ha*

  keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

	* parameterize the eligiblity function for each variable 
	global allvars i.state i.year i.hhsize c.ln_faminc fpl i.age i.age_youngest i.nchild c.ln_famearn c.ln_utility_exp c.ln_earn c.wks_unemp i.why_unemp c.ln_wsav c.ln_wcar i.disabled 
	global medicaidvars i.state#i.year i.hhsize ln_faminc fpl i.age i.age_youngest i.nchild i.ssi
	global snapvars i.state i.year i.hhsize ln_faminc ln_famearn fpl hhsize#c.ln_faminc#c.fpl i.hhsize#c.ln_famearn#c.fpl i.hhsize#c.ln_housing_exp#c.fpl
	global liheapvars i.state i.year ln_faminc i.hhsize ln_utility_exp
	global ssivars ln_earnings ln_faminc ln_famearn i.hhsize i.nchild ln_wsav ln_wcar i.disabled i.year
	global wicvars ln_faminc fpl i.snap i.tanf i.medicaid
	global havars i.state i.hhsize i.year ln_faminc ln_wsav 
	global tanfvars i.state i.year i.hhsize ln_faminc i.anychild ln_wcar ln_wsav

/****************************************/
/* * get imputed eligibility variables  */
/****************************************/
foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf { 

    * generate an imputed eligibility variable 
    cap drop imp_elig_`prog'
	gen imp_elig_`prog' = eligsim_`prog'
	replace imp_elig_`prog' = 1 if `prog' == 1      

      * partial 
      local threshold_low = 10
      local threshold_high = 50 

      cap drop imp_part_`prog' 
      gen imp_part_`prog' = eligsim_`prog'
      replace imp_part_`prog' = 1 if rk_current_eq < `threshold_low'
      
      cap drop max_rk_current_eq 
      bys id (year): egen max_rk_current_eq = max(rk_current_eq)
      bys id (year): replace imp_part_`prog' = 0 if max_rk_current_eq > `threshold_high' & !mi(max_rk_current_eq) 

}

/***********/
/* regressions  */
/***********/

* write a .csv
cap file close fh
file open fh using  "$dir/figures/participation_reg.csv", write replace
file write fh "prog,spec,imputed_eligibility,regtype,b,se" _n

foreach eligvar in yes partial no {
	
  foreach spec in "_eq" "_c" {  

  foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf  {

    if "`eligvar'" == "no" local eligsim = "eligsim_`prog'"
    if "`eligvar'" == "yes" local eligsim = "imp_elig_`prog'" 
    if "`eligvar'" == "partial" local eligsim = "imp_part_`prog'" 
 
      
      * raw regression 
      if "`spec'" != "_c" {
        qui reg rk_lifetime`spec' bs_rk* `prog' [pw=wtfam], cl(famid_orig) 
      }
      if "`spec'" == "_c" {
        qui reg rk_c_current_eq bs_rk* `prog' [pw=wtfam], cl(famid_orig)   
      }
		
    local b = _b[`prog']
    local se = _se[`prog']
    file write fh "`prog',`spec',`eligvar',raw," (`b') "," (`se') _n

      * regression if eligible

      if "`spec'" != "_c" {
        qui reg rk_lifetime`spec' bs_rk* `prog' if `eligsim' == 1 [pw=wtfam], cl(famid_orig)        
      }
      if "`spec'" == "_c" {
        qui reg rk_c_current_eq bs_rk* `prog' if `eligsim' == 1 [pw=wtfam], cl(famid_orig)  
      }

        local b = _b[`prog']
        local se = _se[`prog']
        file write fh "`prog',`spec',`eligvar',ifelig," (`b') "," (`se') _n
      
      * regression on controls 
      if "`spec'" != "_c" {
        qui reg rk_lifetime`spec' bs_rk* `prog' $allvars if `eligsim' == 1 [pw=wtfam], cl(famid_orig)
        local r2_med = e(r2) 
      }
      if "`spec'" == "_c" {
        qui reg rk_c_current_eq bs_rk* `prog' $allvars if `eligsim' == 1 [pw=wtfam], cl(famid_orig)
        local r2_med = e(r2)         
      }
            
    local b = _b[`prog']
    local se = _se[`prog']
    file write fh "`prog',`spec',`eligvar',richcontrols," (`b') "," (`se') _n
	
      * regression on controls 
      if "`spec'" != "_c" {
        qui reg rk_lifetime`spec' bs_rk* `prog' $allvars white black hisp i.edcat i.married if `eligsim' == 1 [pw=wtfam], cl(famid_orig)
        local r2_med = e(r2) 
      }
      if "`spec'" == "_c" {
        qui reg rk_c_current_eq bs_rk* `prog' $allvars white black hisp i.edcat i.married  if `eligsim' == 1 [pw=wtfam], cl(famid_orig)
        local r2_med = e(r2)         
      }
            
    local b = _b[`prog']
    local se = _se[`prog']
    file write fh "`prog',`spec',`eligvar',unusedobservables," (`b') "," (`se') _n
      
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
	
  foreach spec in "_eq" "_c" {  
  	
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
        qui reghdfe rk_c_current_eq i.prog#c.bs_rk* r_ [pw=wtfam], a(prog) cl(famid_orig) 
      }
		
    local b = _b[r_]
    local se = _se[r_]
    file write fh "avg,`spec',`eligvar',raw," (`b') "," (`se') _n

      * regression if eligible

      if "`spec'" != "_c" {
        qui reghdfe rk_lifetime`spec' i.prog#c.bs_rk* r_ if `eligsim' == 1 [pw=wtfam], a(prog) cl(famid_orig) 
      }
      if "`spec'" == "_c" {
        qui reghdfe rk_c_current_eq i.prog#c.bs_rk* r_ if `eligsim' == 1 [pw=wtfam], a(prog) cl(famid_orig) 
      }

        local b = _b[r_]
        local se = _se[r_]
        file write fh "avg,`spec',`eligvar',ifelig," (`b') "," (`se') _n
		
		 * raw regression (average of 5)
      if "`spec'" != "_c" {
        qui reghdfe rk_lifetime`spec' i.prog#c.bs_rk* r_ if inlist(transfer,"snap","medicaid","ssi","ha","tanf") [pw=wtfam], a(prog) cl(famid_orig) 
      }
      if "`spec'" == "_c" {
        qui reghdfe rk_c_current_eq i.prog#c.bs_rk* r_ if inlist(transfer,"snap","medicaid","ssi","ha","tanf") [pw=wtfam], a(prog) cl(famid_orig) 
      }
		
    local b = _b[r_]
    local se = _se[r_]
    file write fh "avg_of_5,`spec',`eligvar',raw," (`b') "," (`se') _n

      * regression if eligible (average of 5)

      if "`spec'" != "_c" {
        qui reghdfe rk_lifetime`spec' i.prog#c.bs_rk* r_ if `eligsim' == 1 & inlist(transfer,"snap","medicaid","ssi","ha","tanf") [pw=wtfam], a(prog) cl(famid_orig) 
      }
      if "`spec'" == "_c" {
        qui reghdfe rk_c_current_eq i.prog#c.bs_rk* r_ if `eligsim' == 1 & inlist(transfer,"snap","medicaid","ssi","ha","tanf") [pw=wtfam], a(prog) cl(famid_orig) 
      }

        local b = _b[r_]
        local se = _se[r_]
        file write fh "avg_of_5,`spec',`eligvar',ifelig," (`b') "," (`se') _n
      
      * regression on controls 
      if "`spec'" != "_c" {
        qui reghdfe rk_lifetime`spec' i.prog#c.bs_rk* r_ i.prog#$allvars if `eligsim' == 1 [pw=wtfam], a(prog) cl(famid_orig) 
        local r2_med = e(r2) 
      }
      if "`spec'" == "_c" {
        qui reghdfe rk_c_current_eq i.prog#c.bs_rk* r_ i.prog#$allvars if `eligsim' == 1 [pw=wtfam], a(prog) cl(famid_orig) 
        local r2_med = e(r2)         
      }
            
    local b = _b[r_]
    local se = _se[r_]
    file write fh "avg,`spec',`eligvar',richcontrols," (`b') "," (`se') _n
	
      * regression on controls 
      if "`spec'" != "_c" {
		qui reghdfe rk_lifetime`spec' i.prog#c.bs_rk* r_ $allvars i.prog#i.white i.prog#i.black i.prog#i.hisp i.prog#i.edcat i.prog#i.married if `eligsim' == 1 [pw=wtfam], a(prog) cl(famid_orig) 
        local r2_med = e(r2) 
      }
      if "`spec'" == "_c" {
		qui reghdfe rk_c_current_eq i.prog#c.bs_rk* r_ i.prog#$allvars i.prog#i.white i.prog#i.black i.prog#i.hisp i.prog#i.edcat i.prog#i.married if `eligsim' == 1 [pw=wtfam], a(prog) cl(famid_orig) 
        local r2_med = e(r2)         
      }
            
    local b = _b[r_]
    local se = _se[r_]
    file write fh "avg,`spec',`eligvar',unusedobservables," (`b') "," (`se') _n
	
	restore
	
  }
}
	
cap file close fh

/****************/
/* Three version  */
/****************/

* generate a graph that is all programs together
local avgname {bf:Average}
local wicname WIC
local snapname SNAP
local schoolmealsname "School Meals"
local ssiname SSI
local tanfname TANF
local medicaidname Medicaid
local liheapname LIHEAP
local haname Housing

foreach imputed in "yes" "no" { 
  foreach spec in  "_eq" "_c" {
    
    import delimited using  "$dir/figures/participation_reg.csv", clear
    keep if spec == "`spec'" & imputed == "`imputed'"
	drop if prog == "avg_of_5"
    gen high = b + 1.96 * se
    gen low = b - 1.96 * se

    * sorting 
    gen raweffect_tmp = b if regtype == "raw"
    bys prog: egen raweffect = mean(raweffect_tmp)
    replace raweffect = 5 if prog == "avg" 


    gen order = 1 if regtype == "raw" 
    replace order = 2 if regtype == "ifelig" 
    replace order = 3 if regtype == "richcontrols"
    replace order = 4 if regtype == "unusedobservables"    

    gsort raweffect -order
    
    gen index = 1
    replace index = 0 if regtype == "unusedobservables" 
    gen n = sum(index)
    gen n_of_raw_tmp = n if regtype == "raw" 
    bys prog: egen n_of_raw = total(n_of_raw_tmp)
    replace n = n_of_raw if regtype == "unusedobservables"

    gsort raweffect -order
    
    gen index_me = 1
    replace index_me = 0 if regtype == "raw" 
    gen n_me = sum(index_me)
    gen n_of_uo_tmp = n_me if regtype == "unusedobservables" 
    bys prog: egen n_of_uo = total(n_of_uo_tmp)
    replace n_me = n_of_uo if regtype == "raw"

    gsort raweffect -order
    
    * rerank with and without unused observables 
    preserve
        drop if regtype == "unusedobservables"    
        local ylabel = ""
        foreach obs of numlist 2(3)`=_N-1' {
          local progtype = prog[`obs']
          local name ``progtype'name'
          local ylabel = `" `ylabel' `obs' "`name'" "'
        }
    restore

    preserve
        drop if regtype == "raw"        
        local ylabel_me = ""
        foreach obs of numlist 2(3)`=_N-1' {
          local progtype = prog[`obs']
          local name ``progtype'name'
          local ylabel_me = `" `ylabel' `obs' "`name'" "'
        }    
    restore
    
    global navy `" "51 122 183" "'
    global green `" "92 184 92" "'
    global ltblue `" "91 192 222" "'
    global red `" "217 83 79" "'
    global orange `" "240 173 78" "'
    
    if "`spec'" != "_c" {

    gr twoway /// 
        (rcap high low n if regtype == "raw", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
        (rcap high low n if regtype == "ifelig", msize(medium)  color($orange) horizontal ) ///
      (rcap high low n if regtype == "richcontrols", msize(medium)  color($ltblue) horizontal  ///
      yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Lifetime Rank") ytitle("") )  /// 
        (scatter n b if regtype == "ifelig", msize(medium)  msymbol(T) color($orange) ylabel(`ylabel') ) ///
      (scatter n b if regtype == "richcontrols", msize(medium) msymbol(S) color($ltblue) ylabel(`ylabel') legend(title("Conditional on:", size(medium)) ///
      col(3) lab(4 "Income") lab(5 "Income & Eligibility") lab(6 "Income, Eligibility, & Controls")  order(4 5 6 ) ) )

    gr export "$dir/figures/eligregs_combined`spec'_`imputed'_2prog.pdf", replace

    ****** appearing versions [for presentation] 
    gr twoway /// 
        (rcap high low n if regtype == "raw", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5)))  ///
        (rcap high low n if regtype == "ifelig", msize(medium)  color(none) horizontal ) ///
      (rcap high low n if regtype == "richcontrols", msize(medium)  color(none) horizontal  ///
      yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Lifetime Rank") ytitle("") )  /// 
        (scatter n b if regtype == "ifelig", msize(medium)  msymbol(T) color(none) ylabel(`ylabel') ) ///
      (scatter n b if regtype == "richcontrols", msize(medium) msymbol(S) color(none) ylabel(`ylabel') legend(title("Conditional on:", size(medium)) ///
      col(3) lab(4 "Income") lab(5 "Income & Eligibility") lab(6 "Income, Eligibility, & Controls")  order(4) ) )

    gr export "$dir/figures/eligregs_appear_1`spec'_`imputed'_2prog.pdf", replace

    gr twoway /// 
        (rcap high low n if regtype == "raw", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5)))  ///
        (rcap high low n if regtype == "ifelig", msize(medium)  color($orange) horizontal ) ///
      (rcap high low n if regtype == "richcontrols", msize(medium)  color(none) horizontal  ///
      yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Lifetime Rank") ytitle("") )  /// 
        (scatter n b if regtype == "ifelig", msize(medium)  msymbol(T) color($orange) ylabel(`ylabel') ) ///
      (scatter n b if regtype == "richcontrols", msize(medium) msymbol(S) color(none) ylabel(`ylabel') legend(title("Conditional on:", size(medium)) ///
      col(3) lab(4 "Income") lab(5 "Income & Eligibility") lab(6 "Income, Eligibility, & Controls")  order(4 5) ) )

    gr export "$dir/figures/eligregs_appear_2`spec'_`imputed'_2prog.pdf", replace

    gr twoway /// 
        (rcap high low n if regtype == "raw", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5)))  ///
        (rcap high low n if regtype == "ifelig", msize(medium)  color($orange) horizontal ) ///
      (rcap high low n if regtype == "richcontrols", msize(medium)  color($ltblue) horizontal  ///
      yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Lifetime Rank") ytitle("") )  /// 
        (scatter n b if regtype == "ifelig", msize(medium)  msymbol(T) color($orange) ylabel(`ylabel') ) ///
      (scatter n b if regtype == "richcontrols", msize(medium) msymbol(S) color($ltblue) ylabel(`ylabel') legend(title("Conditional on:", size(medium)) ///
      col(3) lab(4 "Income") lab(5 "Income & Eligibility") lab(6 "Income, Eligibility, & Controls")  order(4 5 6) ) )

    gr export "$dir/figures/eligregs_appear_3`spec'_`imputed'_2prog.pdf", replace


    gr twoway /// 
        (rcap high low n_me if regtype == "unusedobservables", color($green) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5)))  ///
        (rcap high low n_me if regtype == "ifelig", msize(medium)  color($orange) horizontal ) ///
      (rcap high low n_me if regtype == "richcontrols", msize(medium)  color($ltblue) horizontal  ///
      yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n_me b if regtype == "unusedobservables", msymbol(O) msize(medium) color($green) ylabel(`ylabel_me') ///
      xtitle("Predictive Effect of Participation on Lifetime Rank") ytitle("") )  /// 
        (scatter n_me b if regtype == "ifelig", msize(medium)  msymbol(T) color($orange) ylabel(`ylabel_me') ) ///
      (scatter n_me b if regtype == "richcontrols", msize(medium) msymbol(S) color($ltblue) ylabel(`ylabel_me') legend(title("Conditional on:", size(medium)) ///
          col(1) lab(4 "Income, Eligibility, Controls, & Unused Observables") lab(5 "Income & Eligibility") ///
          lab(6 "Income, Eligibility, & Controls")  order(5 6 4) ) )

    gr export "$dir/figures/eligregs_appear_me_`spec'_`imputed'.pdf", replace

      
    }

    if "`spec'" == "_c" {

    gr twoway /// 
        (rcap high low n if regtype == "raw", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
        (rcap high low n if regtype == "ifelig", msize(medium)  color($orange) horizontal ) ///
      (rcap high low n if regtype == "richcontrols", msize(medium)  color($ltblue) horizontal  ///
      yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
        (scatter n b if regtype == "ifelig", msize(medium)  msymbol(T) color($orange) ylabel(`ylabel') ) ///
      (scatter n b if regtype == "richcontrols", msize(medium) msymbol(S) color($ltblue) ylabel(`ylabel') legend(title("Conditional on:", size(medium)) ///
      col(3) lab(4 "Income") lab(5 "Income & Eligibility") lab(6 "Income, Eligibility, & Controls")  order(4 5 6 ) ) )

    gr export "$dir/figures/eligregs_combined`spec'_`imputed'_2prog.pdf", replace

    ****** appearing versions [for presentation] 
    gr twoway /// 
        (rcap high low n if regtype == "raw", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5)))  ///
        (rcap high low n if regtype == "ifelig", msize(medium)  color(none) horizontal ) ///
      (rcap high low n if regtype == "richcontrols", msize(medium)  color(none) horizontal  ///
      yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
        (scatter n b if regtype == "ifelig", msize(medium)  msymbol(T) color(none) ylabel(`ylabel') ) ///
      (scatter n b if regtype == "richcontrols", msize(medium) msymbol(S) color(none) ylabel(`ylabel') legend(title("Conditional on:", size(medium)) ///
      col(3) lab(4 "Income") lab(5 "Income & Eligibility") lab(6 "Income, Eligibility, & Controls")  order(4) ) )

    gr export "$dir/figures/eligregs_appear_1`spec'_`imputed'_2prog.pdf", replace

    gr twoway /// 
        (rcap high low n if regtype == "raw", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5)))  ///
        (rcap high low n if regtype == "ifelig", msize(medium)  color($orange) horizontal ) ///
      (rcap high low n if regtype == "richcontrols", msize(medium)  color(none) horizontal  ///
      yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
        (scatter n b if regtype == "ifelig", msize(medium)  msymbol(T) color($orange) ylabel(`ylabel') ) ///
      (scatter n b if regtype == "richcontrols", msize(medium) msymbol(S) color(none) ylabel(`ylabel') legend(title("Conditional on:", size(medium)) ///
      col(3) lab(4 "Income") lab(5 "Income & Eligibility") lab(6 "Income, Eligibility, & Controls")  order(4 5) ) )

    gr export "$dir/figures/eligregs_appear_2`spec'_`imputed'_2prog.pdf", replace

    gr twoway /// 
        (rcap high low n if regtype == "raw", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5)))  ///
        (rcap high low n if regtype == "ifelig", msize(medium)  color($orange) horizontal ) ///
      (rcap high low n if regtype == "richcontrols", msize(medium)  color($ltblue) horizontal  ///
      yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
        (scatter n b if regtype == "ifelig", msize(medium)  msymbol(T) color($orange) ylabel(`ylabel') ) ///
      (scatter n b if regtype == "richcontrols", msize(medium) msymbol(S) color($ltblue) ylabel(`ylabel') legend(title("Conditional on:", size(medium)) ///
      col(3) lab(4 "Income") lab(5 "Income & Eligibility") lab(6 "Income, Eligibility, & Controls")  order(4 5 6) ) )

    gr export "$dir/figures/eligregs_appear_3`spec'_`imputed'_2prog.pdf", replace


    gr twoway /// 
        (rcap high low n_me if regtype == "unusedobservables", color($green) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5)))  ///
        (rcap high low n_me if regtype == "ifelig", msize(medium)  color($orange) horizontal ) ///
      (rcap high low n_me if regtype == "richcontrols", msize(medium)  color($ltblue) horizontal  ///
      yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n_me b if regtype == "unusedobservables", msymbol(O) msize(medium) color($green) ylabel(`ylabel_me') ///
      xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
        (scatter n_me b if regtype == "ifelig", msize(medium)  msymbol(T) color($orange) ylabel(`ylabel_me') ) ///
      (scatter n_me b if regtype == "richcontrols", msize(medium) msymbol(S) color($ltblue) ylabel(`ylabel_me') legend(title("Conditional on:", size(medium)) ///
          col(1) lab(4 "Income, Eligibility, Controls, & Unused Observables") lab(5 "Income & Eligibility") ///
          lab(6 "Income, Eligibility, & Controls")  order(5 6 4) ) )

    gr export "$dir/figures/eligregs_appear_me_`spec'_`imputed'.pdf", replace

	}
  }
 }

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
local haname Housing 

foreach imputed in "yes" "partial" "no" { 
  foreach spec in  "_eq" "_c" {
    
    import delimited using  "$dir/figures/participation_reg.csv", clear
    keep if spec == "`spec'" & imputed == "`imputed'" 
	drop if prog == "avg_of_5"
    gen high = b + 1.96 * se
    gen low = b - 1.96 * se

    gen raweffect_tmp = b if regtype == "raw" 
    bys prog: egen raweffect = mean(raweffect_tmp)
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
        (rcap high low n if regtype == "ifelig", msize(medium)  color($orange) horizontal ) ///
      (rcap high low n if regtype == "richcontrols", msize(medium)  color($ltblue) horizontal  ///
      yscale(range(1 18)) yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Lifetime Rank") ytitle("") )  /// 
        (scatter n b if regtype == "ifelig", msize(medium)  msymbol(T) color($orange) ylabel(`ylabel') ) ///
      (scatter n b if regtype == "richcontrols", msize(medium) msymbol(S) color($ltblue) ylabel(`ylabel') legend(title("Conditional on:", size(medium)) ///
      col(3) lab(4 "Income Rank") lab(5 "Income Rank & Eligibility")  order(4 5) ) )

    gr export "$dir/figures/eligregs_appear_2`spec'_`imputed'.pdf", replace

    }

    if "`spec'" == "_c" {
		
	gr twoway /// 
        (rcap high low n if regtype == "raw", color(white) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5)))  ///
        (rcap high low n if regtype == "ifelig", msize(medium)  color(white) horizontal ) ///
      (rcap high low n if regtype == "richcontrols", msize(medium)  color(white) horizontal  ///
          yscale(range(1 18))   xscale(range(-20 5))    yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw", msymbol(O) msize(medium) color(white) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
        (scatter n b if regtype == "ifelig", msize(medium)  msymbol(T) color(white) ylabel(`ylabel') ) ///
      (scatter n b if regtype == "richcontrols", msize(medium) msymbol(S) color(white) ylabel(`ylabel') legend(title("Conditional on:", size(medium)) ///
      col(3) lab(4 "Income Rank") order(4 5) lab(5 "Income Rank & Eligibility")  ) )

    gr export "$dir/figures/eligregs_appear_2`spec'_`imputed'0.pdf", replace
		
    gr twoway /// 
        (rcap high low n if regtype == "raw" & n == 17.5, color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5)))  ///
        (rcap high low n if regtype == "ifelig", msize(medium)  color(white) horizontal ) ///
      (rcap high low n if regtype == "richcontrols", msize(medium)  color($ltblue) horizontal  ///
          yscale(range(1 18))   xscale(range(-20 5))    yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw" & n == 17.5, msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
        (scatter n b if regtype == "ifelig", msize(medium)  msymbol(T) color(white) ylabel(`ylabel') ) ///
      (scatter n b if regtype == "richcontrols", msize(medium) msymbol(S) color($ltblue) ylabel(`ylabel') legend(title("Conditional on:", size(medium)) ///
      col(3) lab(4 "Income Rank") order(4 5) lab(5 "Income Rank & Eligibility")  ) )

    gr export "$dir/figures/eligregs_appear_2`spec'_`imputed'1.pdf", replace
	
	
    gr twoway /// 
        (rcap high low n if regtype == "raw", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5)))  ///
        (rcap high low n if regtype == "ifelig", msize(medium)  color(white) horizontal ) ///
      (rcap high low n if regtype == "richcontrols", msize(medium)  color($ltblue) horizontal  ///
          yscale(range(1 18))   xscale(range(-20 5))    yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
        (scatter n b if regtype == "ifelig", msize(medium)  msymbol(T) color(white) ylabel(`ylabel') ) ///
      (scatter n b if regtype == "richcontrols", msize(medium) msymbol(S) color($ltblue) ylabel(`ylabel') legend(title("Conditional on:", size(medium)) ///
      col(3) lab(4 "Income Rank") order(4 5) lab(5 "Income Rank & Eligibility")  ) )

    gr export "$dir/figures/eligregs_appear_2`spec'_`imputed'2.pdf", replace
	

    gr twoway /// 
        (rcap high low n if regtype == "raw", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5)))  ///
        (rcap high low n if regtype == "ifelig", msize(medium)  color($orange) horizontal ) ///
      (rcap high low n if regtype == "richcontrols", msize(medium)  color($ltblue) horizontal  ///
          yscale(range(1 18))  xscale(range(-20 5)) xlabel(-20(5)5)   yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
        (scatter n b if regtype == "ifelig", msize(medium)  msymbol(T) color($orange) ylabel(`ylabel') ) ///
      (scatter n b if regtype == "richcontrols", msize(medium) msymbol(S) color($ltblue) ylabel(`ylabel') legend(title("Conditional on:", size(medium)) ///
      col(3) lab(4 "Income Rank") order(4 5) lab(5 "Income Rank & Eligibility")  ) )

    gr export "$dir/figures/eligregs_appear_2`spec'_`imputed'3.pdf", replace
	
    }
  }
} 
