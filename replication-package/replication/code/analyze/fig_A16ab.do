/***************************************************************************
 * Appendix Figure A16, Panel A and B: Heterogeneous Self-Targeting by Current Income Rank (PSID), Selection on Consumption and Selection on Lifetime Income
 * 
 * Description:
 * This script estimates regressions of rank outcomes on transfer program 
 * participation, allowing for flexible controls via basis splines of 
 * current income rank. It runs regressions separately for:
 *   (1) Full sample,
 *   (2) Bottom decile of rk_current_eq,
 *   (3) Above bottom decile.
 * 
 * Each specification is run separately by transfer program and outcome 
 * (current rank and lifetime rank). Results are exported to CSV and 
 * plotted for inclusion in robustness appendix.
 * 
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * 
 * Outputs:
 * - CSV of regression results (`"$dir/figures/participation_reg_robustness3.csv"`)
 * - Plots of coefficients with split @ 10th income percentile
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
	
	rename eligsim_housing eligsim_ha
	rename housing_assistance ha

* write a .csv
cap file close fh
file open fh using  "$dir/figures/participation_reg_robustness3.csv", write replace
file write fh "prog,outcome,spec,b,se" _n

foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf  {
	
	foreach outcome in "_c" "_li" {
		
	* All sample
	if "`outcome'" == "_c" {
	qui reg rk_c_current_eq  bs_rk* `prog' if eligsim_`prog'==1 [pw=wtfam],  cl(famid_orig) 
	}
	if "`outcome'" == "_li" {
	qui reg rk_lifetime_eq  bs_rk* `prog' if eligsim_`prog'==1 [pw=wtfam],  cl(famid_orig) 
	}
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`outcome',baseline," (`b') "," (`se') _n
		
	* Below 10th income percentile
		di "`prog'"
	
	if "`outcome'" == "_c" {
	qui reg rk_c_current_eq  bs_rk* `prog' if eligsim_`prog'==1  & rk_current_eq<10  [pw=wtfam],  cl(famid_orig) 
	}
	if "`outcome'" == "_li" {
	qui reg rk_lifetime_eq  bs_rk* `prog' if eligsim_`prog'==1  & rk_current_eq<10  [pw=wtfam],  cl(famid_orig) 
	}
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`outcome',lowinc," (`b') "," (`se') _n

	* Above 10th income percentile
		di "`prog'"
		
	if "`outcome'" == "_c" {
	qui reg rk_c_current_eq  bs_rk* `prog' if eligsim_`prog'==1 & rk_current_eq>10 [pw=wtfam],  cl(famid_orig) 
	}
	if "`outcome'" == "_li" {
	qui reg rk_lifetime_eq  bs_rk* `prog' if eligsim_`prog'==1 & rk_current_eq>10 [pw=wtfam],  cl(famid_orig) 
	}
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`outcome',highinc," (`b') "," (`se') _n
	
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
		replace wtfam = wtfam * `wtval' if transfer == "`prog'"
		
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
	file write fh "avg,`outcome',baseline," (`b') "," (`se') _n
		
	* Below 10th income percentile
	
	if "`outcome'" == "_c" {
	qui reghdfe rk_c_current_eq i.prog#c.bs_rk* r_ if eligsim_==1 & rk_current_eq<10  [pw=wtfam], a(prog) cl(famid_orig) 
	}
	if "`outcome'" == "_li" {
	qui reghdfe rk_lifetime_eq i.prog#c.bs_rk* r_ if eligsim_==1 & rk_current_eq<10  [pw=wtfam], a(prog) cl(famid_orig) 
	}
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,`outcome',lowinc," (`b') "," (`se') _n

	* Above 10th income percentile
	
	if "`outcome'" == "_c" {
	reghdfe rk_c_current_eq r_ if eligsim_==1 & rk_current_eq>10 [pw=wtfam], a(prog i.prog#c.bs_rk1 i.prog#c.bs_rk3 i.prog#c.bs_rk4 i.prog#c.bs_rk5 i.prog#c.bs_rk6 i.prog#c.bs_rk7) cl(famid_orig) 
	}
	if "`outcome'" == "_li" {
	reghdfe rk_lifetime_eq r_ if eligsim_==1 & rk_current_eq>10 [pw=wtfam], a(prog i.prog#c.bs_rk1 i.prog#c.bs_rk3 i.prog#c.bs_rk4 i.prog#c.bs_rk5 i.prog#c.bs_rk6 i.prog#c.bs_rk7) cl(famid_orig) 
	}
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,`outcome',highinc," (`b') "," (`se') _n
	
	restore
	
}

cap file close fh

* Make graph
local avgname {bf:Average}
local wicname WIC
local snapname SNAP
local schoolmealsname "School Meals"
local ssiname SSI
local tanfname TANF
local medicaidname Medicaid
local liheapname LIHEAP
local haname Housing 
    
		foreach outcome in "_c" "_li" {
			
			    import delimited using  "$dir/figures/participation_reg_robustness3.csv", clear

		keep if outcome == "`outcome'"
		
    gen high = b + 1.96 * se
    gen low = b - 1.96 * se

    gen raweffect_tmp = b if spec == "baseline"
    bys prog: egen raweffect = mean(raweffect)
    replace raweffect = 5 if prog == "avg" 

    gen order = 1 if spec == "baseline" 
    replace order = 2 if spec == "lowinc" 
	replace order = 3 if spec == "highinc" 

    drop if !inlist(spec,"baseline","lowinc","highinc") 
    gsort raweffect -order 
    
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

		if "`outcome'" == "_c" {

		gr twoway /// 
			(rcap high low n if spec == "baseline", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
		  (rcap high low n if spec == "lowinc", msize(medium)  color($orange) horizontal)  ///
		  (rcap high low n if spec == "highinc", msize(medium)  color($green) horizontal  ///
		  yscale(range(1 18)) yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
		  (scatter n b if spec == "baseline", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
		  xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
		  (scatter n b if spec == "lowinc", msize(medium) msymbol(T) color($orange)) ///
		   (scatter n b if spec == "highinc", msize(medium) msymbol(S) color($green) ///
		   ylabel(`ylabel') legend(col(3) lab(4 "Baseline") lab(5 "Bottom-Decile Income") lab(6 "Other Nine Deciles") order(4 5 6) ) )

		
		}
		
		if "`outcome'" == "_li" {

		gr twoway /// 
			(rcap high low n if spec == "baseline", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
		  (rcap high low n if spec == "lowinc", msize(medium)  color($orange) horizontal)  ///
		  (rcap high low n if spec == "highinc", msize(medium)  color($green) horizontal  ///
		  yscale(range(1 18)) yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
		  (scatter n b if spec == "baseline", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
		  xtitle("Predictive Effect of Participation on Lifetime Rank") ytitle("") )  /// 
		  (scatter n b if spec == "lowinc", msize(medium) msymbol(T) color($orange)) ///
		   (scatter n b if spec == "highinc", msize(medium) msymbol(S) color($green) ///
		   ylabel(`ylabel') legend(col(3) lab(4 "Baseline") lab(5 "Bottom-Decile Income") lab(6 "Other Nine Deciles") order(4 5 6) ) )
		
		}
		
				gr export "$dir/figures/eligregs_robustness3`outcome'.pdf", replace

	
		}

