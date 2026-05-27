/***************************************************************************
 * Figure 1, Panel D: Self-Targeting in Transfer Programs, Marginal Utility (Baily-Chetty Calibration)
 * 
 * Description:
 * This script loads our PSID data, computes marginal utility 
 * from a calibrated utility function, and estimates self-targeting 
 * regressions by program participation and simulated eligibility. 
 * Outputs include regression coefficients and a formatted plot.
 * 
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * 
 * Outputs:
 * - CSV file with regression results (`"$dir/figures/participation_reg_mu.csv"`)
 * - Plot of marginal utility effects by eligibility status
 ***************************************************************************/

* Settings

	do code/settings.do	
	set scheme simplescheme
	
	use "$dir/data/psid_base", clear
	
	* Theoretical parameter values
	
	local ra = 3
	local ls = 0.3
	
	* Set sample to same as welfare analysis
	drop if year == 1997
	keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)
	keep if !mi(eq_cons)
    keep if !mi(lifetime_income_hh)
    drop if hhsize - nchild == 0
	drop if mi(snap) | mi(medicaid) | mi(liheap) | mi(housing_assistance)  | mi(tanf) |  mi(ssi)  | mi(schoolmeals) | mi(wic)  
	
	run_all_eligsims
	get_dollar_shares
	ren *, lower

* Set up environment as in theory model calibration

	keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

	cap gen equivalence_scale = ((hhsize-nchild)+0.7*nchild)^0.7
	gen faminct_eq = faminct_real / equivalence_scale
	
	ren *housing_assistance* *ha*
	
	* Censor consumption values below the 5th percentile
	sum eq_cons if eq_cons > 0, d    
    replace eq_cons = `r(p5)' if inrange(eq_cons,0,`r(p5)')

	* Obtain ghh utility preference parameter using - u_h = u_c w
	bys famid year: egen total_hours = total(hours)
	gen hours_eq = total_hours / (hhsize - nchild)
	replace hours_eq = max(hours_eq, 0)

	gen wage = faminct_eq / (hours_eq * 50)
	replace wage = 0 if hours_eq == 0 | mi(faminct_eq) 
	gen psi = wage  / hours_eq^(1/`ls')
	assert !mi(hours_eq) 
	assert !mi(psi) if hours_eq != 0
	replace psi = 0 if hours_eq == 0 
	
	drop if eq_cons - psi * hours_eq^(1+1/`ls') / (1+1/`ls') < 0  

	* Calculate marginal utility
	* Note: Uses GHH utility specification from paper
	gen double smmu = (eq_cons - psi * hours_eq^(1+1/`ls')/(1+1/`ls'))^(-`ra')
	
	 * censor marginal utility
	summ smmu [aw=wtfam], d
    replace smmu = r(p95) if smmu>r(p95) & !missing(smmu) 
		
	* rescale to money metric using average person in society
	sum smmu [aw=wtfam]
	gen double mean_smmu_overall = r(mean)
	
	* Calculate rounded rank
	gen rk_current_rd = floor(rk_current_eq)
    replace rk_current_rd = 1 if rk_current_rd == 0
		
* Run self-targeting regressions	
		
	* write a .csv
	cap file close fh
	file open fh using "$dir/figures/participation_reg_mu.csv", write replace
	file write fh "prog,eligsim,b,se" _n

	* Perform regressions for each program to estimate self-targeting on marginal utility
	foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf  {		
	
		* All sample
		qui reghdfe smmu `prog' [pw=wtfam], a(rk_current_rd) cl(famid_orig) 
		  
		local b = _b[`prog'] / mean_smmu_overall
		local se = _se[`prog'] / mean_smmu_overall
		file write fh "`prog',0," (`b') "," (`se') _n

		* Simulated eligible sample
		 reghdfe smmu `prog' if eligsim_`prog'==1 [pw=wtfam], a(rk_current_rd) cl(famid_orig) 
		  
		local b = _b[`prog'] / mean_smmu_overall
		local se = _se[`prog'] / mean_smmu_overall
		file write fh "`prog',1," (`b') "," (`se') _n
		
	}
	
* Run self-targeting regression pooled across programs

	rename (snap medicaid liheap wic tanf ssi ha schoolmeals) (r_snap r_medicaid r_liheap r_wic r_tanf r_ssi r_ha r_schoolmeals)
	keep r_* id year rk_current_eq rk_current_rd rk_c_current_eq wtfam smmu eligsim_* famid_orig mean_smmu_overall
	
	reshape long r_ eligsim_, i(id year) j(transfer) string
	
	egen prog = group(transfer)

	foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf {
		
		local wtname = "wt_`prog'"
		local wtval = ${`wtname'}
		replace wtfam = wtfam * `wtval' if transfer == "`prog'"
		
		di "`prog' : `wtval'"
			
	}
	
	* All sample
	qui reghdfe smmu  r_ [pw=wtfam], a(prog#rk_current_rd) cl(famid_orig) 
	  
	local b = _b[r_] / mean_smmu_overall
	local se = _se[r_] / mean_smmu_overall
	file write fh "avg,0," (`b') "," (`se') _n
		
	* Simulated eligible sample
	qui reghdfe smmu r_ if eligsim_==1 [pw=wtfam], a(prog#rk_current_rd) cl(famid_orig) 
	  
	local b = _b[r_] / mean_smmu_overall
	local se = _se[r_] / mean_smmu_overall
	file write fh "avg,1," (`b') "," (`se') _n
		
	* Ensure that the file is written correctly before closing
	cap file close fh

	* make plot
				
		import delimited using  "$dir/figures/participation_reg_mu.csv", clear
		
		gen high = b + 1.96 * se
		gen low = b - 1.96 * se

		gen raweffect_tmp = b if eligsim == 0
		bys prog: egen raweffect = mean(raweffect)
		replace raweffect = 99999 if prog == "avg" 

		gen order = 1 if eligsim == 0
		replace order = 2 if eligsim == 1
		gsort raweffect -order 
		

		* Censor bservations		
		replace b = 4 if b > 4
		replace b = -1 if b < -1
		replace lo = . if inlist(b,-1,4)
		replace hi = . if inlist(b,-1,4)

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

		gr twoway /// 
			(rcap high low n if eligsim == 0, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-1 "-1" 0 "0" 1 "1" 2 "2" 3 "3") xscale(range(-1 3)))		///
			(rcap high low n if eligsim == 1, msize(medium)  color( $orange ) horizontal ///
		  yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) )) /// 
		  (scatter n b if eligsim == 0, msymbol(O) msize(medium) color( $navy ) ylabel(`ylabel') ///
		  xtitle("Mean Difference in Marginal Utility (Calibrated)") ytitle("") )  /// 
			(scatter n b if eligsim == 1, msize(medium)  msymbol(T) color( $orange ) ylabel(`ylabel') ///
		  legend(col(2) lab(3 "Income Rank") lab(4 "Income Rank & Eligibility")  order(3 4 ) ))
		  
		gr export "$dir/figures/participation_reg_mu.pdf", replace
		
		