/***************************************************************************
 * Appendix Figure A29, Panel A and B: Selection into Transfers, with Predicted-Income Control, Consumption and 
 * Lifetime Income
 * 
 * Description:
 * This script estimates the relationship between transfer receipt and household 
 * rank in the consumption distribution, comparing raw models with models that 
 * control for predicted income. Predicted income is generated using a Poisson 
 * regression methods in the CPS microdata (see paper). The figure visualizes effects on 
 * both current and lifetime rank, with and without controls for predicted income.
 * 
 * Inputs:
 * - PSID-based dataset: `"$dir/data/psid_base"`
 * - Income prediction components from the Current Population Survey
 * 
 * Outputs:
 * - CSV of estimates: `"$dir/figures/control_income.csv"`
 * - Figures:
 *     - `"$dir/figures/rk_c_current_eq_pred_income.pdf"`
 *     - `"$dir/figures/rk_lifetime_eq_pred_income.pdf"`
 ***************************************************************************/

* Set working directory

	do code/settings
	do "$dir/code/stata-tex.do"
	
	discard
	set scheme simplescheme 

	*do "$dir/code/clean/cps/02_clean_cps_income_reg.do"
	
	use "$dir/data/psid_base", clear

	run_all_eligsims
	
* Run regressions

cap file close fh
file open fh using "$dir/figures/control_income.csv" , write replace 
file write fh "prog,outcome,spec,b,se" _n

* spline and regress 
local refpts 0 10 25 50 100
frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
frencurv, gen(pred_rk) x(rk_pred_eq) p(3) refpts(`refpts') omit(0)


foreach outcome in rk_c_current_eq rk_lifetime_eq { 
foreach p of varlist snap medicaid housing_assistance ssi schoolmeals wic liheap tanf {
		noisily di "`p'"
    noisily di "`outcome'" 
  qui  reg `outcome'  `p' bs_rk* if eligsim_`p'==1 [pw=wtfam],  cl(famid_orig)
  file write fh "`p',`outcome',raw," (_b[`p']) "," (_se[`p']) _n
  
  qui	reg `outcome' `p' bs_rk* pred_rk* if eligsim_`p'==1 [pw=wtfam], cl(famid_orig)
  file write fh "`p',`outcome',controls," (_b[`p']) "," (_se[`p']) _n
  		
}
}

* Run self-targeting regression pooled across programs


	rename (snap medicaid liheap wic tanf ssi ha schoolmeals) (r_snap r_medicaid r_liheap r_wic r_tanf r_ssi r_ha r_schoolmeals)
	keep r_* id year rk_current_eq rk_c_current_eq rk_lifetime_eq wtfam eligsim_* famid_orig bs_rk* pred_rk*
	
	reshape long r_ eligsim_, i(id year) j(transfer) string
	
	egen prog = group(transfer)
	
	foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf {
		
		local wtname = "wt_`prog'"
		local wtval = ${`wtname'}
		replace wtfam = wtfam * `wtval' if transfer == "`prog'"
		
		di "`prog' : `wtval'"
			
	}

foreach outcome in rk_c_current_eq rk_lifetime_eq {
	
	* Baseline
	if "`outcome'" == "rk_c_current_eq" {
	qui reghdfe rk_c_current_eq i.prog#c.bs_rk* r_ if eligsim_==1 [pw=wtfam], a(prog) cl(famid_orig) 
	}
	if "`outcome'" == "rk_lifetime_eq" {
	qui reghdfe rk_lifetime_eq i.prog#c.bs_rk* r_ if eligsim_==1 [pw=wtfam], a(prog) cl(famid_orig) 
	}
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,`outcome',raw," (`b') "," (`se') _n
		
	* With predicted income control
	
	if "`outcome'" == "rk_c_current_eq" {
	qui reghdfe rk_c_current_eq i.prog#c.bs_rk* i.prog#c.pred_rk* r_ if eligsim_==1 [pw=wtfam], a(prog) cl(famid_orig) 
	}
	if "`outcome'" == "rk_lifetime_eq" {
	qui reghdfe rk_lifetime_eq i.prog#c.bs_rk* i.prog#c.pred_rk*  r_ if eligsim_==1  [pw=wtfam], a(prog) cl(famid_orig) 
	}
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,`outcome',controls," (`b') "," (`se') _n

}

cap file close fh

******** put into a graph, combining all programs

foreach outcome in rk_c_current_eq rk_lifetime_eq {
    import delimited using "$dir/figures/control_income.csv", clear
    keep   if outcome == "`outcome'" 
    
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

    global navy `" "51 122 183" "'
    global green `" "92 184 92" "'
    global ltblue `" "91 192 222" "'
    global red `" "217 83 79" "'
    global orange `" "240 173 78" "'

    gen high = b + 1.96 * se
    gen low = b - 1.96 * se

    gen raweffect_tmp = b if spec == "raw"
    bys prog: egen raweffect = mean(raweffect)
    replace raweffect = 5 if prog == "avg" 

    gen order = 1 if spec == "raw" 
    replace order = 2 if mi(order) 
    gsort raweffect -order 

    gen n = _n
    local ylabel = "" 
    foreach obs of numlist 2(2)`=_N' {
      local progtype = prog[`obs']
      local name ``progtype'name'
      local ylabel = `" `ylabel' `=`obs'-.5' "`name'" "'
    }

    di `ylabel'
    list prog b n 


	if "`outcome'" == "rk_c_current_eq" {
		

		gr twoway /// 
			(rcap high low n if spec == "raw", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
		  (rcap high low n if spec == "controls", msize(medium)  color($orange) horizontal  ///
		  yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
		  (scatter n b if spec == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
		  xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
		  (scatter n b if spec == "controls", msize(medium) msymbol(T) color($orange) ylabel(`ylabel') ///
		  legend(col(3) lab(3 "Baseline") lab(4 "Predicted Income Controls")  order(3 4  ) ) )
		  
	}
	
	if "`outcome'" == "rk_lifetime_eq" {

		gr twoway /// 
			(rcap high low n if spec == "raw", color($navy) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
		  (rcap high low n if spec == "controls", msize(medium)  color($orange) horizontal  ///
		  yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) ) ) /// 
		  (scatter n b if spec == "raw", msymbol(O) msize(medium) color($navy) ylabel(`ylabel') ///
		  xtitle("Predictive Effect of Participation on Lifetime Rank") ytitle("") )  /// 
		  (scatter n b if spec == "controls", msize(medium) msymbol(T) color($orange) ylabel(`ylabel') ///
		  legend(col(3) lab(3 "Baseline") lab(4 "Predicted Income Controls")  order(3 4  ) ) )
	  
	}

    gr export "$dir/figures/`outcome'_pred_income.pdf", replace
}
