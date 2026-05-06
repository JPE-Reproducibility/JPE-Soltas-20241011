/***************************************************************************
 * Appendix Figure A8: Selection on Consumption into Transfer Receipt: Adjusted for Regional Price Parity
 * 
 * Description:
 * This script constructs a state-level price index for 1997–2019 using 
 * ACCRA COLI data (1990–2008) and BEA Regional Price Parities (1998–2023), 
 * merged by state and year. The resulting index is used to adjust household 
 * consumption in the PSID for regional purchasing power differences.
 * 
 * The adjusted consumption measure is then used to re-estimate the 
 * predictive effect of program participation on consumption rank, conditional 
 * on current income and eligibility. The script outputs a CSV with regression 
 * results and a figure formatted for inclusion in the appendix.
 * 
 * Inputs:
 * - BEA RPP data (`"$dir/data/SASUMMARY__ALL_AREAS_1998_2023.csv"`)
 * - Harmonized PSID base dataset (`"$dir/data/psid_base"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * 
 * Outputs:
 * - State-level RPP index (`"$dir/data/state_prices.dta"`)
 * - Regression result CSV (`"$dir/figures/participation_reg_robustness_rpp.csv"`)
 * - Appendix figure PDF (`"$dir/figures/participation_reg_robustness_rpp.pdf"`)
 *
 * Note: proprietary data used to create the figure is not included in the replication package. The output is expected to look different than the corresponding figure in the paper.
 ***************************************************************************/

* Settings

qui do code/settings.do

	discard
	adopath + "$dir/code"
	adopath + "$dir/code/eligsim"

	do "$dir/code/stata-tex.do"
	set scheme simplescheme
	
	global imputation = 1

* Load BEA data

	import delimited "$dir/data/SASUMMARY__ALL_AREAS_1998_2023.csv", clear 

* Prepare data for merge

	keep if linecode == 13
	keep geoname v*

	reshape long v, i(geoname) j(t)
	
	destring v, replace force
	
	gen year = 1998 + (t - 9)
	
	assert year >= 1998 & year <= 2023
	su year, meanonly
	assert r(min) == 1998
	assert r(max) == 2023
	
	drop t
	
	statastates, name(geoname)
	
* Fill in BEA data backwards for missings

	gsort geoname - year
	
	preserve
	
	keep if year == 1998
	replace year = 1997
	
	tempfile append1997
	save `append1997', replace
	
	restore
	
	append using `append1997'
	gsort geoname year
	
	keep v year state_fips
	rename (state_fips v) (state state_price_index)
	order state year state_price_index

* Save to file

	save "$dir/data/state_prices.dta", replace
	
* Add to working dataset

	use "$dir/data/psid_base", clear
	merge m:1 state year using "$dir/data/state_prices.dta", nogen keep(1 3)
	
* Adjust income and consumption for regional price variation	

	gen eqscale = (0.7*nchild + (hhsize-nchild))^0.7

	* Income
	
	gen eq_inc_rpp = 100 * faminct_real / (eqscale*state_price_index)
	
	bys year (eq_inc_rpp id): gen rk_current_rpp = sum(wtfam) if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)
	bys year: gegen min_rk_current_rpp = min(rk_current_rpp)
	bys year: gegen max_rk_current_rpp = max(rk_current_rpp)
	replace rk_current_rpp = 100*(rk_current_rpp - min_rk_current_rpp) / (max_rk_current_rpp - min_rk_current_rpp)
	
	* Consumption
	
	gen eq_cons_rpp = 100 * eq_cons_real / state_price_index
	
	bys year (eq_cons_rpp id): gen rk_c_current_rpp = sum(wtfam) if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)
	bys year: gegen min_rk_c_current_rpp = min(rk_c_current_rpp)
	bys year: gegen max_rk_c_current_rpp = max(rk_c_current_rpp)
	replace rk_c_current_rpp = 100*(rk_c_current_rpp - min_rk_c_current_rpp) / (max_rk_c_current_rpp - min_rk_c_current_rpp)
	
	drop max_rk* min_rk*
	
	* Create basis spline for rk_current_eq
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis splines
		frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
		frencurv, gen(rpp_rk) x(rk_current_rpp) p(3) refpts(`refpts') omit(0)
	
		run_all_eligsims

* Run regressions

	keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)
	ren *housing_assistance* *ha*
	
* write a .csv
cap file close fh
file open fh using  "$dir/figures/participation_reg_robustness_rpp.csv", write replace
file write fh "prog,spec,rpp,b,se" _n

foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf  {
	
	* Baseline
	 reg rk_c_current_eq  bs_rk* `prog' if eligsim_`prog'==1  & !missing(rk_c_current_rpp) [pw=wtfam],  cl(famid_orig) 
	  	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',_c,0," (`b') "," (`se') _n
		
	* Regional price parity
	 reg rk_c_current_rpp rpp_rk* `prog' if eligsim_`prog'==1  & !missing(rk_c_current_rpp) [pw=wtfam],  cl(famid_orig) 
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',_c,1," (`b') "," (`se') _n
	
}


* Run self-targeting regression pooled across programs
	
	preserve
	
	get_dollar_shares

	rename (snap medicaid liheap wic tanf ssi ha schoolmeals) (r_snap r_medicaid r_liheap r_wic r_tanf r_ssi r_ha r_schoolmeals)
	keep r_* id year rk_current_eq rk_c_current_rpp rk_c_current_eq rk_lifetime_eq wtfam eligsim_* famid_orig bs_rk* rpp_rk*
	
	reshape long r_ eligsim_, i(id year) j(transfer) string
	
	egen prog = group(transfer)

	foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf {
		
		local wtname = "wt_`prog'"
		local wtval = ${`wtname'}
		replace wtfam = wtfam * `wtval' if transfer == "`prog'"
		
		di "`prog' : `wtval'"
			
	}
	
	* All sample
	qui reghdfe rk_c_current_eq i.prog#c.bs_rk* r_ if eligsim_==1 & !missing(rk_c_current_rpp) [pw=wtfam], a(prog) cl(famid_orig) 
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,_c,0," (`b') "," (`se') _n
		
	* Regional price parity
	qui reghdfe rk_c_current_rpp i.prog#c.rpp_rk* r_ if eligsim_==1 & !missing(rk_c_current_rpp) [pw=wtfam], a(prog) cl(famid_orig) 
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,_c,1," (`b') "," (`se') _n

	restore
	
cap file close fh

* make plot
	
	import delimited using  "$dir/figures/participation_reg_robustness_rpp.csv", clear
	sort prog rpp b se
	duplicates drop prog rpp, force
	
	gen high = b + 1.96 * se
	gen low = b - 1.96 * se

	gen raweffect_tmp = b if rpp == 0
	bys prog: egen raweffect = mean(raweffect_tmp)
	replace raweffect = 5 if prog == "avg" 

	gen order = 1 if rpp == 0
	replace order = 2 if rpp == 1
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
	
	gr twoway /// 
			(rcap high low n if rpp == 1, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-20(5)5) xscale(range(-20 5))) ///
			(rcap high low n if rpp == 0, msize(medium)  color( $orange ) horizontal ///
		  yline(2.5(2)`=_N+3.5', lcolor(gray) lpattern(dash) )) /// 
		  (scatter n b if rpp == 1, msymbol(O) msize(medium) color( $navy ) ylabel(`ylabel') ///
		  xtitle("Predictive Effect of Participation on Consumption Rank") ytitle("") )  /// 
			(scatter n b if rpp == 0, msize(medium)  msymbol(T) color( $orange ) ylabel(`ylabel') ///
		  legend(col(2) lab(4 "Baseline") lab(3 "Regional Price Parity")  order(4 3 ) ))

	gr export "$dir/figures/participation_reg_robustness_rpp.pdf", replace

