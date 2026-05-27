/***************************************************************************
* Figure 2: Estimates of Self-Targeting by Data Source (PSID Versus CEX)
* Appendix Figure A23, Panel D: Self-Targeting in Transfer Programs: Reclassifying Simulated, By Data Source
*
* Description:
* This script analyzes the relationship between participation in government 
* transfer programs and consumption rankings. It runs regressions for 
* different transfer programs (SNAP, Medicaid, Housing Assistance, SSI, TANF, 
* using both CEX data and compares results to PSID data.
* The script uses basis splines to control for income rank and produces 
* coefficient plots comparing results across datasets. It also performs 
* a sensitivity analysis by recoding simulated ineligible recipients as eligible.
* 
* Inputs:
* - CEX workfile data ("$dir/data/cex/raw/workfile.dta")
* - PSID results file ("$dir/figures/participation_reg.csv"). IMPT: Must run fig_1ab_A23ab_A28ab.do before running this code.
* 
* Outputs:
* - CSV file with CEX regression results ("$dir/figures/participation_reg_cex.csv")
* - Coefficient plots comparing CEX and PSID results:
*   - Main analysis: "$dir/figures/eligregs_psid_cex.pdf"
*   - With simulated ineligible recipients recoded: "$dir/figures/eligregs_psid_cex_simelig.pdf" (note that this analysis is not in the paper)
***************************************************************************/

* Settings

	do code/settings.do	
	set scheme simplescheme
	
*** Load data

	use "$dir/data/cex/raw/workfile.dta", clear
		
*** Run the regressions		

	* Create basis spline for rk_inc
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_inc) p(3) refpts(`refpts') omit(0)
		
	get_dollar_shares_cex
		
	* Run regression and save output to file
	
	preserve
	
	cap file close fh
	file open fh using "$dir/figures/participation_reg_cex.csv", write replace
	file write fh "prog,spec,imputed_eligibility,b,se" _n
		
	foreach p of varlist snap medicaid housing_assistance ssi tanf {
		
		reg rk_cons `p' bs_rk* if eligsim_`p' == 1 [pw=finlwt21], cl(cuid)
		
		local spec = "_c"
		local eligvar = "no"
		local b = _b[`p']
		local se = _se[`p']
		
		file write fh "`p',`spec',`eligvar',`b',`se'" _n
	
	}

****** Redo analysis, but recoding simulated ineligible recipients as eligible

	restore

	foreach p of varlist snap medicaid housing_assistance ssi tanf {
		
		preserve
		
		replace eligsim_`p' = 1 if `p' == 1 & eligsim_`p' == 0
				
		reg rk_cons `p' bs_rk* if eligsim_`p' == 1 [pw=finlwt21], cl(cuid)
		
		local spec = "_c"
		local eligvar = "yes"
		local b = _b[`p']
		local se = _se[`p']
		
		file write fh "`p',`spec',`eligvar',`b',`se'" _n
		
		restore
	
	}

*** Run self-targeting regression pooled across programs

	gegen id = group(perid cuid)

	rename housing_assistance ha
	rename (snap medicaid tanf ssi ha) (r_snap r_medicaid r_tanf r_ssi r_ha)
	keep r_* id year rk_inc rk_cons finlwt21 eligsim_* cuid bs_rk* qtr
	
	reshape long r_ eligsim_, i(id year qtr) j(transfer) string
	
	egen prog = group(transfer)

	foreach prog in snap medicaid ssi ha tanf {
		
		local wtname = "wt_`prog'"
		local wtval = ${`wtname'}
		replace finlwt21 = finlwt21 * `wtval' if transfer == "`prog'"
		
		di "`prog' : `wtval'"
			
	}
		
	* Simulated eligible sample
	reghdfe rk_cons i.prog#c.bs_rk* r_ if eligsim_==1 [pw=finlwt21], a(prog) cl(cuid) 
	  
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,_c,no," (`b') "," (`se') _n
	
	* Eligibility imputation version
	
	replace eligsim_ = 1 if r_ == 1 & eligsim_== 0
	
	reghdfe rk_cons i.prog#c.bs_rk* r_ if eligsim_==1 [pw=finlwt21], a(prog) cl(cuid) 
	  
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,_c,yes," (`b') "," (`se') _n
		
	file close fh
	
*** Compile the results

	* Set locals/globals
	
		local avgname  "{bf: Average}"
		local snapname SNAP
		local ssiname SSI
		local tanfname TANF
		local medicaidname Medicaid
		local haname Housing 
		
		global navy `" "51 122 183" "'
		global orange `" "240 173 78" "'
		
	* Load the CEX results
	
		import delimited using  "$dir/figures/participation_reg_cex.csv", clear
		
		keep if imputed == "no"
		replace prog = "ha" if prog == "housing_assistance"
		drop spec imputed
		gen data = "CEX"
	
		tempfile results_psid
		save `results_psid', replace
		
	* Append the PSID results
	
		import delimited using  "$dir/figures/participation_reg.csv", clear
		
		drop if prog == "avg"
		replace prog = "avg" if prog == "avg_of_5"
		keep if spec == "_c" & imputed == "no" & regtype == "ifelig"
		keep if inlist(prog,"avg","snap","medicaid","ha","ssi","tanf")

		drop spec imputed
		
		gen data = "PSID"
		
		* sorting 
		gen raweffect_tmp = b 
		bys prog: egen raweffect = mean(raweffect_tmp)
		replace raweffect = 5 if prog == "avg"
		
		gsort raweffect
		
		local ylabel = "" 
		foreach obs of numlist 1(1)`=_N' {
		  local progtype = prog[`obs']
		  local n = `obs'-0.9
		  local name ``progtype'name'
		  local ylabel = `" `ylabel' `n' "`name'" "'
		}
		
		gen n = _n - 1
	
	* Prepare for graphing
	
		append using `results_psid'

		gegen n2 = max(n), by(prog)
		drop n
		rename n2 n
		
		gsort data n
		replace n = n + 0.25 if data == "PSID"
		
		gen high = b + 1.96 * se
		gen low = b - 1.96 * se
		
*** Make graph

	set scheme simplescheme

	graph twoway (rcap high low n if data == "PSID", horizontal color($navy) msize(medium) xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
	(scatter n b if data == "PSID", msymbol(O) color($navy) ylabel(`ylabel' ) ytitle("") xtitle("Predictive Effect of Participation on Consumption Rank")) ///
	(rcap high low n if data == "CEX", horizontal color($orange) msize(medium) xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
	(scatter n b if data == "CEX", msymbol(D) color($orange) yline(0.6 1.6 2.6 3.6 4.6 5.6,lpattern(dash) lcolor(gray) ) yscale(range(-0.2 5.425)) legend(label(4 "CEX") label(2 "PSID") order(2 4) cols(2))) 

	gr export "$dir/figures/eligregs_psid_cex.pdf", replace

*** Compile the results, w/ sim inelig

	* Set locals/globals
	
		local avgname  "{bf: Average}"
		local snapname SNAP
		local ssiname SSI
		local tanfname TANF
		local medicaidname Medicaid
		local haname Housing 
		
		global navy `" "51 122 183" "'
		global orange `" "240 173 78" "'
		
	* Load the CEX results
	
		import delimited using "$dir/figures/participation_reg_cex.csv", clear
		
		keep if imputed == "yes"
		replace prog = "ha" if prog == "housing_assistance"
		drop spec imputed
		gen data = "CEX"
	
		tempfile results_psid
		save `results_psid', replace
		
	* Append the PSID results
		
		import delimited using "$dir/figures/participation_reg.csv", clear
		
		drop if prog == "avg"
		replace prog = "avg" if prog == "avg_of_5"
		keep if spec == "_c" & imputed == "yes" & regtype == "ifelig"
		keep if inlist(prog,"avg","snap","medicaid","ha","ssi","tanf")

		drop spec imputed
		
		gen data = "PSID"
		
		* sorting 
		gen raweffect_tmp = b
		bys prog: egen raweffect = mean(raweffect)
		replace raweffect = 10 if prog == "avg" 
		
		gsort raweffect
		
		local ylabel = "" 
		foreach obs of numlist 1(1)`=_N' {
		  local progtype = prog[`obs']
		  local n = `obs'-0.9
		  local name ``progtype'name'
		  local ylabel = `" `ylabel' `n' "`name'" "'
		}
		
		gen n = _n - 1
	
	* Prepare for graphing
	
		append using `results_psid'
		
		gegen n2 = max(n), by(prog)
		drop n
		rename n2 n
		
		gsort data n
		replace n = n + 0.25 if data == "PSID"		
		gen high = b + 1.96 * se
		gen low = b - 1.96 * se
		
	
*** Make graph

	set scheme simplescheme

	graph twoway (rcap high low n if data == "PSID", horizontal color($navy) msize(medium) xline(0,lcolor(gs9)) xlabel(-20(5)10) xscale(range(-20 10))) ///
	(scatter n b if data == "PSID", color($navy) ylabel(`ylabel' ) ytitle("") xtitle("Predictive Effect of Participation on Consumption Rank")) ///
	(rcap high low n if data == "CEX", horizontal color($orange) msize(medium) xline(0,lcolor(gs9)) xlabel(-20(5)10) xscale(range(-20 10))) ///
	(scatter n b if data == "CEX", color($orange) yline(0.6 1.6 2.6 3.6 4.6 5.6,lpattern(dash) lcolor(gray) ) yscale(range(-0.2 5.425)) legend(label(4 "CEX") label(2 "PSID") order(2 4)  cols(2))) 

	gr export "$dir/figures/eligregs_psid_cex_simelig.pdf", replace
