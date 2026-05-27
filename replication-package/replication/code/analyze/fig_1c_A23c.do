/***************************************************************************
 * Figure 1, Panel C: Self-Targeting in Transfer Programs, Between and Within Lifetime, Among Eligible
 * Figure A23, Panel C: Self-Targeting in Transfer Programs: Reclassifying Simulated Ineligible Recipients
 * 
 * Description:
 * This script estimates the effect of transfer receipt on two key outcomes:
 * consumption rank and lifetime income rank, conditional on current income 
 * and other observables. It runs separate regressions by program and pooled
 * across programs, using both cross-sectional and fixed effects models.
 * Estimates are exported to a CSV and used to generate a graph comparing 
 * raw and within-lifetime effects for each transfer program.
 *
 * Figure A23 is created by turning on the imputation option (global imputation = 1).
 * 
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * 
 * Outputs:
 * - CSV file with regression results (`"$dir/figures/participation_reg_within.csv"`)
 * - PDF figure comparing regression effects (`"$dir/figures/eligregs_between_within_lifetime.pdf"`)
 ***************************************************************************/

* Settings

qui do code/settings.do

	discard
	adopath + "$dir/code"
	adopath + "$dir/code/eligsim"

	do "$dir/code/stata-tex.do"
	set scheme simplescheme
	
	global imputation = 0

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
	
}

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

* write a .csv
cap file close fh
file open fh using  "$dir/figures/participation_reg_within.csv", write replace
file write fh "prog,spec,imputed_eligibility,regtype,b,se" _n

foreach eligvar in yes no {
  
  foreach prog in snap medicaid liheap schoolmeals ssi wic housing_assistance tanf  {
  	
	 if "`eligvar'" == "no" local eligsim = "eligsim_`prog'"
    if "`eligvar'" == "yes" local eligsim = "imp_elig_`prog'" 

      * pooled regression 
      qui reg rk_c_current_eq bs_rk* `prog' if `eligsim' == 1 [pw=wtfam], cl(famid_orig)

    local b = _b[`prog']
    local se = _se[`prog']
    file write fh "`prog',_eq,`eligvar',raw," (`b') "," (`se') _n

      * within-lifetime regression (fixed effect)
       qui reghdfe rk_c_current_eq bs_rk* `prog' if `eligsim' == 1 [pw=wtfam], cl(famid_orig) a(id)

        local b = _b[`prog']
        local se = _se[`prog']
        file write fh "`prog',_eq,`eligvar',fe," (`b') "," (`se') _n
   
  }
  
}

* Run self-targeting regression pooled across programs
	
	preserve

	rename (snap medicaid liheap wic tanf ssi ha schoolmeals) (r_snap r_medicaid r_liheap r_wic r_tanf r_ssi r_ha r_schoolmeals)
	keep r_* id year rk_current_eq rk_c_current_eq wtfam eligsim_* imp_elig_* famid_orig bs_rk*
	
	reshape long r_ eligsim_ imp_elig_, i(id year) j(transfer) string
	
	egen prog = group(transfer)

	foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf {
		local wtname = "wt_`prog'"
		local wtval = ${`wtname'}
		replace wtfam = wtfam * `wtval' if transfer == "`prog'"
	}
	
	foreach eligvar in yes no {
	
    if "`eligvar'" == "no" local eligsim = "eligsim_"
    if "`eligvar'" == "yes" local eligsim = "imp_elig_" 

	* Pooled
	qui reghdfe rk_c_current_eq i.prog#c.bs_rk* r_ if `eligsim'==1 [pw=wtfam], a(prog) cl(famid_orig) 
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,_eq,`eligvar',raw," (`b') "," (`se') _n
		
	 * Within-lifetime regression (fixed effect)
	qui reghdfe rk_c_current_eq i.prog#c.bs_rk* r_ if `eligsim'==1 & rk_current_eq<10  [pw=wtfam], a(prog#id) cl(famid_orig) 

	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,_eq,`eligvar',fe," (`b') "," (`se') _n
	
	}
  
cap file close fh

/*****************/
/* Two version */
/*****************/
* generate a graph that is all programs together

foreach eligvar in yes no {
	
local avgname {bf:Average}
local wicname WIC
local snapname SNAP
local schoolmealsname "School Meals"
local ssiname SSI
local tanfname TANF
local medicaidname Medicaid
local liheapname LIHEAP
local housing_assistancename Housing 
    
    import delimited using "$dir/figures/participation_reg_within.csv", clear
    gen high = b + 1.96 * se
    gen low = b - 1.96 * se

	keep if imputed_eligibility == "`eligvar'"
	
    gen raweffect_tmp = b if regtype == "raw"
    bys prog: egen raweffect = mean(raweffect)
    replace raweffect = 10 if prog == "avg" 

    gen order = 1 if regtype == "raw" 
    replace order = 2 if regtype == "fe" 
    drop if !inlist(regtype,"raw","fe") 
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


    gr twoway /// 
        (rcap high low n if regtype == "raw" & , color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
      (rcap high low n if regtype == "fe", msize(medium)  color($orange) horizontal  ///
      yscale(range(1 18)) yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
      (scatter n b if regtype == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
      xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
      (scatter n b if regtype == "fe", msize(medium) msymbol(T) color($orange) ylabel(`ylabel') legend(col(3) lab(3 "Between- & Within-Lifetime") lab(4 "Within-Lifetime") order(3 4) ) )

    gr export "$dir/figures/eligregs_between_within_lifetime_`eligvar'.pdf", replace


}
