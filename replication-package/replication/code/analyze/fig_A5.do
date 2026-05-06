/***************************************************************************
 * Appendix Figure A5: Bounds Analysis of Self-Targeting on Consumption
 * 
 * Description:
 * This script performs a bounds analysis on self-targeting in transfer 
 * receipt using consumption data. The goal is to investigate how the predictive 
 * relationship between participation in  transfer programs and consumption 
 * ranks changes when adjusting for the amount of transfer received (both 
 * positive and negative adjustments). The analysis estimates the effect of 
 * participation on consumption ranks under three different scenarios:
 * 1. Baseline consumption (without transfer adjustments).
 * 2. Consumption with transfer subtracted (first-dollar targeting)
 * 3. Consumption with transfer added (accounts for potential behav. responses)
 * 
 * Regressions are run for each program with the adjustments above, and 
 * coefficients are written to a CSV file.
 * 
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base"`)
 * - Eligibility simulation results (via `run_all_eligsims`) 
 * 
 * Outputs:
 * - CSV file with regression results (`"$dir/figures/participation_reg_robustness8.csv"`)
 * - PDF figure (`"$dir/figures/eligregs_robustness_8_c.pdf"`)
 ***************************************************************************/

* Settings

	do code/settings.do
	do "$dir/code/stata-tex.do"
	
	discard
    set scheme simplescheme 

* Load data 

	use "$dir/data/psid_base", clear
	
	rename tot_amt_hh anytransfer_amt_hh
	
	* Create basis spline for rk_current_eq
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
	
		run_all_eligsims
		
		cap drop eligsim_anytransfer
	egen eligsim_anytransfer = rowmax(eligsim_snap eligsim_medicaid eligsim_liheap eligsim_schoolmeals eligsim_ssi eligsim_wic eligsim_housing eligsim_tanf) 
	egen anytransfer = rowmax(snap medicaid liheap schoolmeals ssi wic housing_assistance tanf)

* Predict eligibility from demographics

	keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

	* Generate eligibility
	ren *housing_assistance* *ha*
	
* write a .csv
cap file close fh
file open fh using  "$dir/figures/participation_reg_robustness8.csv", write replace
file write fh "prog,spec,alt,b,se" _n

foreach prog in anytransfer snap medicaid wic liheap schoolmeals ha ssi tanf {
		
	* All sample
	
		qui reg rk_c_current_eq bs_rk* `prog' if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) 
		
		local b = _b[`prog']
		local se = _se[`prog']
		file write fh "`prog',_c,0," (`b') "," (`se') _n
			
	* Minus B
	
		capture gen equivalence_scale = ((hhsize-nchild)+0.7*nchild)^0.7
		gen `prog'_amt_hh_ = `prog'_amt_hh*hhsize
	
		* Lower consumption by transfer amount
		gen eq_cons_minust = (consumption_real - `prog'_amt_hh_) / equivalence_scale
	
		bys year (eq_cons_minust): gen rk_c_current_eq_minust = sum(wtfam) if !missing(faminct_real) & !missing(lifetime_income) & !missing(consumption_real)
		bys year: gegen min_rk_c_current_eq = min(rk_c_current_eq_minust)
		bys year: gegen max_rk_c_current_eq = max(rk_c_current_eq_minust)
		replace rk_c_current_eq_minust = 100*(rk_c_current_eq_minust - min_rk_c_current_eq) / (max_rk_c_current_eq - min_rk_c_current_eq)
		
		drop max_rk* min_rk* eq_cons_minust
	  
		* Run regression
			
		qui reg rk_c_current_eq_minust `prog' bs_rk* if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) 
		
		local b = _b[`prog']
		local se = _se[`prog']
		file write fh "`prog',_c,1," (`b') "," (`se') _n
		drop rk_c_current_eq_minust
	
	* Plus B
	
		* Raise consumption by transfer amount
		gen eq_cons_plust = (consumption_real + `prog'_amt_hh_) / equivalence_scale
	
		bys year (eq_cons_plust): gen rk_c_current_eq_plust = sum(wtfam) if !missing(faminct_real) & !missing(lifetime_income) & !missing(consumption_real)
		bys year: gegen min_rk_c_current_eq = min(rk_c_current_eq_plust)
		bys year: gegen max_rk_c_current_eq = max(rk_c_current_eq_plust)
		replace rk_c_current_eq_plust = 100*(rk_c_current_eq_plust - min_rk_c_current_eq) / (max_rk_c_current_eq - min_rk_c_current_eq)
		
		drop max_rk* min_rk* equivalence_scale eq_cons_plust
		
		* Run regression
		
		qui reg rk_c_current_eq_plust `prog' bs_rk* if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) 
		
		local b = _b[`prog']
		local se = _se[`prog']
		file write fh "`prog',_c,2," (`b') "," (`se') _n
		drop rk_c_current_eq_plust
		
}

cap file close fh

* make plot
		
	import delimited using  "$dir/figures/participation_reg_robustness8.csv", clear
	sort prog alt b se
	duplicates drop prog alt, force
	
	gen high = b + 1.96 * se
	gen low = b - 1.96 * se

	gen raweffect_tmp = b if alt == 0
	bys prog: egen raweffect = mean(raweffect)
	replace raweffect = 5 if prog == "anytransfer" 

	gen order = 1 if alt == 0
	replace order = 2 if alt == 1
	replace order = 3 if alt == 2
	gsort raweffect -order 

	gen n = _n
	
	local anytransfername {bf:Any}
	local wicname WIC
	local snapname SNAP
	local schoolmealsname "School Meals"
	local ssiname SSI
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

	gr twoway /// 
		(rcap high low n if alt == 0, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)15) xscale(range(-20 15))) ///
		(rcap high low n if alt == 1, msize(medium)  color( $orange ) horizontal) ///
			(rcap high low n if alt == 2, msize(medium)  color( $green ) horizontal ///
	  yline(3.5(3)`=_N+2', lcolor(gray) lpattern(dash) )) /// 
	  (scatter n b if alt == 0, msymbol(O) msize(medium) color( $navy ) ylabel(`ylabel') ///
	  xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
	   (scatter n b if alt == 1, msymbol(S) msize(medium) color( $orange ) ylabel(`ylabel')  )  /// 
		(scatter n b if alt == 2, msize(medium)  msymbol(D) color( $green ) ylabel(`ylabel') ///
	  legend(col(3) lab(4 "Baseline") lab(5 "Minus Transfer") lab(6 "Plus Transfer") order(4 5 6) ))

	gr export "$dir/figures/eligregs_robustness_8_c.pdf", replace

