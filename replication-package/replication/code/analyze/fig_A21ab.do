/***************************************************************************
 * Appendix Figure A21, Panel A and B: Adjustments to Eligibility Simulations (PSID), Selection on Consumption and Selection on Lifetime Income
 * 
 * Description:
 * This script tests robustness of estimated self-targeting effects by 
 * modifying transfer eligibility definitions. Specifically, it:
 *   (1) Imposes a 100% FPL income limit,
 *   (2) Imposes a $2,000 real asset test,
 *   (3) Re-estimates baseline regressions for comparison.
 *
 * It runs regressions of rank outcomes on transfer receipt separately 
 * by program and outcome (consumption rank and lifetime rank), pooling 
 * results in a final self-targeting regression as well.
 *
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * 
 * Outputs:
 * - CSV of regression coefficients for baseline and alt specs 
 *   (`"$dir/figures/participation_reg_robustness2.csv"`)
 * - Robustness figure with coefficient plots 
 *   (`"$dir/figures/eligregs_robustness2_c.pdf"` and 
 *    `"$dir/figures/eligregs_robustness2_li.pdf"`)
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

	qui run_all_eligsims
	qui get_dollar_shares

	rename eligsim_housing eligsim_ha
	rename housing_assistance ha

* write a .csv
cap file close fh
file open fh using  "$dir/figures/participation_reg_robustness2.csv", write replace
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
		
	* Income limit @ 100% FPL
		* All sample
		local inclimit = 100
		di "`prog'"
	
	if "`outcome'" == "_c" {
	qui reg rk_c_current_eq  bs_rk* `prog' if eligsim_`prog'==1  & inc_to_fpl<`inclimit'  [pw=wtfam],  cl(famid_orig) 
	}
	if "`outcome'" == "_li" {
	qui reg rk_lifetime_eq  bs_rk* `prog' if eligsim_`prog'==1  & inc_to_fpl<`inclimit'  [pw=wtfam],  cl(famid_orig) 
	}
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`outcome',inclimit," (`b') "," (`se') _n

	* Asset test @ $2000 CPI adjusted
	* All sample
		local assettest = 2000
		di "`prog'"
		
	if "`outcome'" == "_c" {
	qui reg rk_c_current_eq  bs_rk* `prog' if eligsim_`prog'==1 & wsav_real<`assettest' [pw=wtfam],  cl(famid_orig) 
	}
	if "`outcome'" == "_li" {
	qui reg rk_lifetime_eq  bs_rk* `prog' if eligsim_`prog'==1 & wsav_real<`assettest' [pw=wtfam],  cl(famid_orig) 
	}
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`outcome',assettest," (`b') "," (`se') _n
	
}
}


* Run self-targeting regression pooled across programs

foreach outcome in "_c" "_li" {
	
	preserve

	rename (snap medicaid liheap wic tanf ssi ha schoolmeals) (r_snap r_medicaid r_liheap r_wic r_tanf r_ssi r_ha r_schoolmeals)
	keep r_* id year rk_current_eq rk_c_current_eq rk_lifetime_eq wtfam eligsim_* famid_orig bs_rk* wsav_real inc_to_fpl
	
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
	file write fh "avg,`outcome',baseline," (`b') "," (`se') _n
		
	* Income limit @ 100% FPL
	
	if "`outcome'" == "_c" {
	qui reghdfe rk_c_current_eq i.prog#c.bs_rk* r_ if eligsim_==1 & inc_to_fpl<`inclimit'  [pw=wtfam], a(prog) cl(famid_orig) 
	}
	if "`outcome'" == "_li" {
	qui reghdfe rk_lifetime_eq i.prog#c.bs_rk* r_ if eligsim_==1  & inc_to_fpl<`inclimit' [pw=wtfam], a(prog) cl(famid_orig) 
	}
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,`outcome',inclimit," (`b') "," (`se') _n

	* Asset test @ $2000 CPI adjusted
		
	if "`outcome'" == "_c" {
	reghdfe rk_c_current_eq r_ if eligsim_==1 & wsav_real<`assettest' [pw=wtfam], a(prog i.prog#c.bs_rk1 i.prog#c.bs_rk3 i.prog#c.bs_rk4 i.prog#c.bs_rk5 i.prog#c.bs_rk6 i.prog#c.bs_rk7) cl(famid_orig) 
	}
	if "`outcome'" == "_li" {
	reghdfe rk_lifetime_eq r_ if eligsim_==1 & wsav_real<`assettest' [pw=wtfam], a(prog i.prog#c.bs_rk1 i.prog#c.bs_rk3 i.prog#c.bs_rk4 i.prog#c.bs_rk5 i.prog#c.bs_rk6 i.prog#c.bs_rk7) cl(famid_orig) 
	}
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,`outcome',assettest," (`b') "," (`se') _n
	
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
			
			    import delimited using  "$dir/figures/participation_reg_robustness2.csv", clear

		keep if outcome == "`outcome'"
		
    gen high = b + 1.96 * se
    gen low = b - 1.96 * se

    gen raweffect_tmp = b if spec == "baseline"
    bys prog: egen raweffect = mean(raweffect)
    replace raweffect = 5 if prog == "avg" 

    gen order = 1 if spec == "baseline" 
    replace order = 2 if spec == "inclimit" 
	replace order = 3 if spec == "assettest" 

    drop if !inlist(spec,"baseline","inclimit","assettest") 
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
		  (rcap high low n if spec == "inclimit", msize(medium)  color($orange) horizontal)  ///
		  (rcap high low n if spec == "assettest", msize(medium)  color($green) horizontal  ///
		  yscale(range(1 18)) yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
		  (scatter n b if spec == "baseline", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
		  xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
		  (scatter n b if spec == "inclimit", msize(medium) msymbol(T) color($orange)) ///
		   (scatter n b if spec == "assettest", msize(medium) msymbol(S) color($green) ///
		   ylabel(`ylabel') legend(col(3) lab(4 "Baseline") lab(5 "Income Limit (100% FPL)") lab(6 "Asset Limit ($2000)") order(4 5 6) ) )

		
		}
		
		if "`outcome'" == "_li" {

		gr twoway /// 
			(rcap high low n if spec == "baseline", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
		  (rcap high low n if spec == "inclimit", msize(medium)  color($orange) horizontal)  ///
		  (rcap high low n if spec == "assettest", msize(medium)  color($green) horizontal  ///
		  yscale(range(1 18)) yline(3.5(3)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
		  (scatter n b if spec == "baseline", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
		  xtitle("Predictive Effect of Participation on Lifetime Rank") ytitle("") )  /// 
		  (scatter n b if spec == "inclimit", msize(medium) msymbol(T) color($orange)) ///
		   (scatter n b if spec == "assettest", msize(medium) msymbol(S) color($green) ///
		   ylabel(`ylabel') legend(col(3) lab(4 "Baseline") lab(5 "Income Limit (100% FPL)") lab(6 "Asset Limit ($2000)") order(4 5 6) ) )
		
		}
		
				gr export "$dir/figures/eligregs_robustness2`outcome'.pdf", replace

	
		}

