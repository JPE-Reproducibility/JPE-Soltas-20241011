/***************************************************************************

This code cleans the raw PSID data.

Calls:
- code/psid/J345111.do: PSID loading script from UMich
- code/psid/J308959.do: supplement PSID loading script from UMich
- code/psid/name_vars.do: renames PSID variables for interpretability

Input:
- data/psid_int.dta
- data/lifetime_income.dta

Output:
- data/psid_base.dta

***************************************************************************/

* Set working directory

	do code/settings.do
	set more off
	
* Pre-load PSID Child Development Supplement data
	
	use "$dir/data/psid_int.dta", clear
	
	* Merge in lifetime income estimates

	* Note: this capture will allow the code to run once to clean data, then can run ebayes_lifetime_earnings.do, then re-clean data

	merge m:1 famid_orig perid_orig using "$dir/data/lifetime_income", nogen keep(1 3)
	replace lifetime_income = . if missing(income_real)
	
	summ income_real [aw=wtfam] if !missing(lifetime_income)
	local m1 = r(mean)
	summ lifetime_income [aw=wtfam] if !missing(lifetime_income)
	local m2 = r(mean)
	
	replace lifetime_income = (`m1'/`m2') * lifetime_income if !missing(lifetime_income)
	
	* Compute income ranks
	
		set seed 54342
		set sortseed 983685
	
		* Current household
		
		bys year (faminct_real id): gen rk_current_hh = sum(wtfam) if !missing(faminct_real) & !missing(lifetime_income) & !missing(consumption_real)
		bys year: gegen min_rk_current_hh = min(rk_current_hh)
		bys year: gegen max_rk_current_hh = max(rk_current_hh)
		replace rk_current_hh = 100*(rk_current_hh - min_rk_current_hh) / (max_rk_current_hh - min_rk_current_hh)
		label variable rk_current_hh "Household rank, current income, not equivalized"
		
		* Lifetime household
		
		bys famid year: gegen lifetime_income_hh_ = sum(lifetime_income) if !missing(income_real)
		bys id: gegen lifetime_income_hh = mean(lifetime_income_hh_) [aw=wtfam]

		bys cohort_ind (lifetime_income_hh id year): gen rk_lifetime_hh = sum(wtfam) if !missing(lifetime_income) & !missing(consumption_real)
		bys cohort_ind: gegen min_rk_lifetime_hh = min(rk_lifetime_hh)
		bys cohort_ind: gegen max_rk_lifetime_hh = max(rk_lifetime_hh)
		replace rk_lifetime_hh = 100*(rk_lifetime_hh - min_rk_lifetime_hh) / (max_rk_lifetime_hh - min_rk_lifetime_hh)
		
		label variable rk_lifetime_hh "Household rank, lifetime income, not equivalized"
		label variable lifetime_income_hh "Lifetime income of people in current household, not equivalized"
		
		drop max_rk*
		
		* Current household, equivalized
		
		gen equivalence_scale = ((hhsize-nchild)+0.7*nchild)^0.7
		gen eq_income_real = faminct_real / equivalence_scale
		
		bys year (eq_income_real id): gen rk_current_eq = sum(wtfam) if !missing(faminct_real) & !missing(lifetime_income) & !missing(consumption_real)
		bys year: gegen min_rk_current_eq = min(rk_current_eq)
		bys year: gegen max_rk_current_eq = max(rk_current_eq)
		replace rk_current_eq = 100*(rk_current_eq - min_rk_current_eq) / (max_rk_current_eq - min_rk_current_eq)
		label variable rk_current_eq "Household rank, current income, equivalized"
		
		* Lifetime household, equivalized
				
		gen lifetime_income_eq_ = lifetime_income_hh_ / equivalence_scale
		bys id: gegen lifetime_income_eq = mean(lifetime_income_eq_) [aw=wtfam]
		drop equivalence_scale lifetime_income_hh_ lifetime_income_eq_
		
		bys cohort_ind (lifetime_income_eq id year): gen rk_lifetime_eq = sum(wtfam) if !missing(faminct_real) & !missing(lifetime_income) & !missing(consumption_real)
		bys cohort_ind: gegen min_rk_lifetime_eq = min(rk_lifetime_eq)
		bys cohort_ind: gegen max_rk_lifetime_eq = max(rk_lifetime_eq)
		replace rk_lifetime_eq = 100*(rk_lifetime_eq - min_rk_lifetime_eq) / (max_rk_lifetime_eq - min_rk_lifetime_eq)
		
		label variable rk_lifetime_eq "Household rank, lifetime income, equivalized"
		label variable lifetime_income_eq "Lifetime income of people in current household, equivalized"
		
		drop eq_income_real max_rk*
		
	* Compute consumption ranks
	
		* Current household
		
		bys year (consumption_real id): gen rk_c_current_hh = sum(wtfam) if !missing(faminct_real) & !missing(lifetime_income) & !missing(consumption_real)
		bys year: gegen min_rk_c_current_hh = min(rk_c_current_hh)
		bys year: gegen max_rk_c_current_hh = max(rk_c_current_hh)
		replace rk_c_current_hh = 100*(rk_c_current_hh - min_rk_c_current_hh) / (max_rk_c_current_hh - min_rk_c_current_hh)
				
		label variable rk_c_current_hh "Household rank, consumption, not equivalized"		
				
		* Current household, equivalized
		
		gen equivalence_scale = ((hhsize-nchild)+0.7*nchild)^0.7
		gen eq_cons_real = consumption_real / equivalence_scale
		label variable eq_cons_real "Real equivalized household consumption"
		
		bys year (eq_cons id): gen rk_c_current_eq = sum(wtfam) if !missing(faminct_real) & !missing(lifetime_income) & !missing(consumption_real)
		bys year: gegen min_rk_c_current_eq = min(rk_c_current_eq)
		bys year: gegen max_rk_c_current_eq = max(rk_c_current_eq)
		replace rk_c_current_eq = 100*(rk_c_current_eq - min_rk_c_current_eq) / (max_rk_c_current_eq - min_rk_c_current_eq)
		
		label variable rk_c_current_eq "Household rank, consumption, equivalized"	
		label variable equivalence_scale "Equivalence scale value"
		
		drop max_rk* min_rk*
		
	* Adjusted consumption level (for use in calibration)	
	
		preserve
		keep if year == 2019 & !missing(consumption_real)
		
		sort eq_cons_real id
		gen rk = 100*(_n-1)/(_N-1)
		gen at_rk = 0.1*(_n-1) if _n<1002
		
		lpoly eq_cons rk, bw(0.005) deg(2) gen(consumption_real_at_rk) at(at_rk) nograph n(1000)
		replace at_rk = at_rk*10
		
		keep at_rk consumption_real_at_rk
		rename consumption_real_at_rk consumption_adj
		drop if missing(at_rk)
		
		tempfile at_rk
		save `at_rk', replace
		restore
		
		gen at_rk = round(rk_c_current_hh*10)
		merge m:1 at_rk using `at_rk', nogen
		drop at_rk
		
* Drop needless variables	

	drop rent_amt* div_amt* int_amt* trust_amt* farminc* assetincbus* laborincbus* educ_m educ_f ///
		denied_* applied_* foodsec regiongrewup* grewuppoor* edyears wsav2_ ssi_spouse ui_imp* ///
		 annual_hrs_head annual_hrs_spouse assetinc_other transfer assetinc_other hhid ///
		 educ_exp childcare_exp computer_exp furniture_exp clothing_exp travel_exp rec_exp ///
		 mortgage_exp trans_exp veh_loan_exp veh_dp_exp faminct_oth faminct_hs food_exp ///
		 proptax_exp trans_cons faminc_real
	
* Set data for panel	

	xtset id t

* Save resulting dataset

	save "$dir/data/psid_base.dta", replace
	
	