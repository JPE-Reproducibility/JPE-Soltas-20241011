/***************************************************************************
 * Appendix Table A6: Selection into Transfers, Adjusted for Misreporting of Transfer Receipt
 * 
 * Description:
 * This script estimates the effect of corrections for misreporting of transfer
 * receipt on selection into transfers by consumption rank and lifetime-income rank,
 * conditional on current-income rank. It replicates the analysis in the paper's Table A6, 
 * with Panel A presenting PSID results and Panel B presenting CEX results. 
 * Columns 1 and 2 reproduce baseline estimates, while Columns 3 and 4 use adjusted
 * measures for SNAP and Medicaid from Mittag (2019) and Davern et al. (2019), respectively.
 * All specifications control flexibly for current-income rank using cubic basis splines.
 * Standard errors are clustered by household.
 * 
 * Inputs:
 * - PSID data (`"$dir/data/psid_data"`)
 * - CEX data (`"$dir/data/cex_data"`)
 * - Coefficients from Mittag (2019) and Davern et al. (2019)
 * - Stata-TeX helper and settings scripts (`code/stata-tex.do`, `code/settings`)
 * 
 * Outputs:
 * - Table (`tables/output/mittag_final.tex`) 
 ***************************************************************************/ 


* Set working directory

	do code/settings.do
	do "$dir/code/stata-tex.do"
	use "$dir/data/psid_base", clear
	
	run_all_eligsims
	cap drop state_name state_postal

* Create basis spline for rk_current_eq
	
	* Create list
	local refpts 0 10 25 50 100
	
	* Create basis spline
	frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
	
* Keep in tempfile

	tempfile mittag
	save `mittag', replace
	
* Run and store regression results 

	cd "$dir/tables/data"

	reg rk_c_current_eq snap bs_rk* if eligsim_snap==1 [pw=wtfam], cl(famid_orig)
	store_est_tpl using mittag.csv, coef(snap) name(base_snap_cons) all format(%12.1f)
	
	reg rk_lifetime_eq snap bs_rk* if eligsim_snap==1  [pw=wtfam], cl(famid_orig)
	store_est_tpl using mittag.csv, coef(snap) name(base_snap_lifetime) all format(%12.1f)

	reg rk_c_current_eq medicaid bs_rk* if eligsim_medicaid==1  [pw=wtfam], cl(famid_orig)
	store_est_tpl using mittag.csv, coef(medicaid) name(base_medicaid_cons) all format(%12.1f)
	
	reg rk_lifetime_eq medicaid bs_rk* if eligsim_medicaid==1 [pw=wtfam], cl(famid_orig)
	store_est_tpl using mittag.csv, coef(medicaid) name(base_medicaid_lifetime) all format(%12.1f)

/***************************************************************************
SNAP - PSID
***************************************************************************/

* Prepare data for Mittag 2019 underreporting correction

	capture drop inc_to_fpl
	gen inc_to_fpl = faminct_nom / fpl

	gen inc_to_fpl_lt_50 = inc_to_fpl < 0.5
	gen inc_to_fpl_50_100 = inc_to_fpl >= 0.5 & inc_to_fpl < 1
	gen inc_to_fpl_100_150 = inc_to_fpl >= 1 & inc_to_fpl < 1.5
	gen inc_to_fpl_150_200 = inc_to_fpl >= 1.5 & inc_to_fpl < 2
	gen inc_to_fpl_200_gt = inc_to_fpl >= 2 if !missing(inc_to_fpl)

	gen inc_to_fpl_lt_50s = inc_to_fpl*inc_to_fpl_lt_50
	gen inc_to_fpl_50_100s = inc_to_fpl*inc_to_fpl_50_100
	gen inc_to_fpl_100_150s = inc_to_fpl*inc_to_fpl_100_150
	gen inc_to_fpl_150_200s = inc_to_fpl*inc_to_fpl_150_200
	gen inc_to_fpl_200_gts = inc_to_fpl*inc_to_fpl_200_gt

	gen age_18_29 = age >= 18 & age <= 29 
	gen age_30_39 = age >= 30 & age <= 39
	gen age_50_59 = age >= 50 & age <= 59
	gen age_60_69 = age >= 60 & age <= 69
	gen age_70_up = age >= 70 if !missing(age)

	gen unmarried_childless = (1-married)*(1-anychild)
	gen unmarried_haschild = (1-married)*anychild
	gen married_childless = married*(1-anychild)

	gen interv_nonenglish = .

	gen any_emp_hh = famearn_nom > 0 if !missing(famearn_nom)
	replace any_emp_hh = 1 if missing(any_emp_hh)

	gen single_hh = hhsize == 1

	gen unemploy = emp == 3

	bys famid year: egen num_emp_hh = sum(employ)
	replace num_emp_hh = min(num_emp_hh,hhsize)

	gen nilf = emp != 1 & emp != 2 & emp != 3

	gen lths = edcat < 2
	gen hs = edcat == 2
	gen coll = edcat > 3 & !missing(edcat)

	gen disabled_nowork = disabled*(1-employ)

	gen anywealth = wsav_nom > 0 if !missing(wsav_nom)
	replace anywealth = 1 if missing(anywealth)

	gen not_in_english = lang !=1 if !missing(lang)

	bys famid year: egen any_disabled = max(disabled)
	replace any_disabled = 0 if missing(any_disabled)
	replace disabled = 0 if missing(disabled)
	
	replace nonwhite = 0 if missing(nonwhite)

* Load coefficients

	preserve
	import delimited "$dir/data/mittag2009/par_vec_mod.csv", clear
	drop if missing(pname)
	mkmat cd2008, mat(coefs) rownames(pname)
	restore

* Create probit score
		
	local vlist "_cons snap snap_imp inc_to_fpl_50_100 inc_to_fpl_100_150 inc_to_fpl_150_200 inc_to_fpl_200_gt inc_to_fpl_lt_50s inc_to_fpl_50_100s inc_to_fpl_100_150s inc_to_fpl_150_200s inc_to_fpl_200_gts age_18_29 age_30_39 age_50_59 age_60_69 age_70_up anywealth hhsize nchild unmarried_childless unmarried_haschild married_childless not_in_english num_emp any_emp any_disabled single_hh unemploy nilf female nonwhite lths hs coll disabled disabled_nowork" 

	gen snap_mp = 0

	local i = 1

	foreach v in `vlist' {
		
		local coef = coefs[`i',1]
		
		di "`v' : `coef'"
		
		replace snap_mp = snap_mp + `v'*`coef'
		
		local i = `i'+1
		
	}

* Compute probability from score

	gen snap_pr = 1-normal(snap_mp)

* Run and store regression results		

	reg rk_c_current_eq snap_pr bs_rk* if eligsim_snap==1 [pw=wtfam], cl(famid_orig)
	store_est_tpl using mittag.csv, coef(snap_pr) name(mittag_snap_cons) all format(%12.1f)
	
	reg rk_lifetime_eq snap_pr bs_rk* if eligsim_snap==1 [pw=wtfam], cl(famid_orig)
	store_est_tpl using mittag.csv, coef(snap_pr) name(mittag_snap_lifetime) all format(%12.1f)

/***************************************************************************
Medicaid - PSID
***************************************************************************/

* Reload clean data

	use `mittag', clear

* Prepare data for Mittag 2019 underreporting correction

	gen age_lt_45 = (age >= 18 & age < 45) - 1/6
	gen age_gt_45 = (age >= 45 & !missing(age)) - 1/6
	
	replace state = 0 if missing(state)
	tab state if state != 0 & state != 99, gen(state_)
	
	foreach v of varlist state_* {
		replace `v' = -1/51 if `v' == 0
		replace `v' = 1-1/51 if `v' == 1
		replace `v' = 0 if state == 0 | state == 99
	}
	foreach v of varlist female white black aian asian { 
		replace `v' = 0 if missing(`v')
	}
	foreach v of varlist white black aian asian { 
		replace `v' = -1/4 if `v' == 0
		replace `v' = 1-1/4 if `v' == 1
	}
	foreach v of varlist head spouse {
		replace `v' = -1/5 if `v' == 0
		replace `v' = 1-1/5 if `v' == 1
	}
	
	gen healthins_othpub_only = healthins_othpub*(1-healthins_priv)*(1-medicaid) - 1/3
	gen healthins_priv_only = healthins_priv*(1-healthins_othpub)*(1-medicaid) - 1/3
	gen medicaid_only = medicaid*(1-healthins_priv)*(1-healthins_othpub) - 1/3
	
	gen inc_to_fpl0 = faminct_nom == 0
	gen inc_to_fpl_1_49 = 100*faminct_nom/fpl < 50
	gen inc_to_fpl_50_75 = 100*faminct_nom/fpl >= 49 & 100*faminct_nom/fpl < 75 
	gen inc_to_fpl_75_99 = 100*faminct_nom/fpl >= 75 & 100*faminct_nom/fpl < 100 
	gen inc_to_fpl_100_124 = 100*faminct_nom/fpl >= 100 & 100*faminct_nom/fpl < 125 
	gen inc_to_fpl_125_149 = 100*faminct_nom/fpl >= 125 & 100*faminct_nom/fpl < 150 
	gen inc_to_fpl_150_174 = 100*faminct_nom/fpl >= 150 & 100*faminct_nom/fpl < 175 
	gen inc_to_fpl_175_199 = 100*faminct_nom/fpl >= 175 & 100*faminct_nom/fpl < 200  
	gen inc_to_fpl_200 = 100*faminct_nom/fpl >= 200 & !missing(faminct_nom/fpl)
	
	foreach v of varlist inc_to_fpl* {
		replace `v' = -1/9 if `v' == 0
		replace `v' = 1-1/9 if `v' == 1
	}
	
* Load coefficients
	
	preserve
	import delimited "$dir/data/mittag2009/medicaid_models_davern_et_al.csv", clear
	drop if missing(pname)
	mkmat model1, mat(coefs1) rownames(pname)
	mkmat model2, mat(coefs2) rownames(pname)
	restore

* Create probit score
		
	local vlist "_cons age_lt_45 age_gt_45 healthins_othpub_only healthins_priv_only healthins_pubpriv healthins_none medicaid_only hispanic black aian asian white female head spouse inc_to_fpl0 inc_to_fpl_1_49 inc_to_fpl_50_75 inc_to_fpl_75_99 inc_to_fpl_100_124 inc_to_fpl_125_149 inc_to_fpl_150_174 inc_to_fpl_175_199 inc_to_fpl_200 state_1 state_2 state_3 state_4 state_5 state_6 state_7 state_8 state_9 state_10 state_11 state_12 state_13 state_14 state_15 state_16 state_17 state_18 state_19 state_20 state_21 state_22 state_23 state_24 state_25 state_26 state_27 state_28 state_29 state_30 state_31 state_32 state_33 state_34 state_35 state_36 state_37 state_38 state_39 state_40 state_41 state_42 state_43 state_44 state_45 state_46 state_47 state_48 state_49 state_50 state_51" 

	gen medicaid_fit = 0

	local i = 1

	foreach v in `vlist' {
		
		local coef1 = coefs1[`i',1]
		local coef2 = coefs2[`i',1]
			
		replace medicaid_fit = medicaid_fit + `v'*`coef1' if medicaid == 0
		replace medicaid_fit = medicaid_fit + `v'*`coef2' if medicaid == 1
		
		local i = `i'+1
		
	}

* Compute probability from score

	gen medicaid_pr = .
	replace medicaid_pr = invlogit(medicaid_fit)
	drop medicaid_fit
	
* Run and store regression results		

	cd "$dir/tables/data"
	
	reg rk_c_current_eq medicaid_pr bs_rk* if eligsim_medicaid==1 [pw=wtfam], cl(famid_orig)
	store_est_tpl using mittag.csv, coef(medicaid_pr) name(mittag_medicaid_cons) all format(%12.1f)
	
	reg rk_lifetime_eq medicaid_pr bs_rk* if eligsim_medicaid==1 [pw=wtfam], cl(famid_orig)
	store_est_tpl using mittag.csv, coef(medicaid_pr) name(mittag_medicaid_lifetime) all format(%12.1f)

/***************************************************************************
Load CEX
***************************************************************************/

* Set working directory

	cd ../../
	do code/settings.do
	do "$dir/code/stata-tex.do"
	use "$dir/data/cex/raw/workfile.dta", clear
	
* Create basis spline for rk_inc
	
	* Create list
	local refpts 0 10 25 50 100
	
	* Create basis spline
	frencurv, gen(bs_rk) x(rk_inc) p(3) refpts(`refpts') omit(0)
		
* Run and store regression results		

	cd "$dir/tables/data"

	reg rk_cons snap bs_rk* if eligsim_snap==1 [pw=finlwt21], cl(cuid)
	store_est_tpl using mittag.csv, coef(snap) name(base_snap_cons_cex) all format(%12.1f)
	
	reg rk_cons medicaid bs_rk* if eligsim_medicaid==1  [pw=finlwt21], cl(cuid)
	store_est_tpl using mittag.csv, coef(medicaid) name(base_medicaid_cons_cex) all format(%12.1f)
	
/***************************************************************************
SNAP - CEX
***************************************************************************/

* Prepare data for Mittag 2019 underreporting correction

	gen inc_to_fpl = fincbtxm / povlevcy
	gen inc_to_fpl_lt_50 = inc_to_fpl < 0.5
	gen inc_to_fpl_50_100 = inc_to_fpl >= 0.5 & inc_to_fpl < 1
	gen inc_to_fpl_100_150 = inc_to_fpl >= 1 & inc_to_fpl < 1.5
	gen inc_to_fpl_150_200 = inc_to_fpl >= 1.5 & inc_to_fpl < 2
	gen inc_to_fpl_200_gt = inc_to_fpl >= 2 if !missing(inc_to_fpl)

	gen inc_to_fpl_lt_50s = inc_to_fpl*inc_to_fpl_lt_50
	gen inc_to_fpl_50_100s = inc_to_fpl*inc_to_fpl_50_100
	gen inc_to_fpl_100_150s = inc_to_fpl*inc_to_fpl_100_150
	gen inc_to_fpl_150_200s = inc_to_fpl*inc_to_fpl_150_200
	gen inc_to_fpl_200_gts = inc_to_fpl*inc_to_fpl_200_gt

	gen age_18_29 = age >= 18 & age <= 29 
	gen age_30_39 = age >= 30 & age <= 39
	gen age_50_59 = age >= 50 & age <= 59
	gen age_60_69 = age >= 60 & age <= 69
	gen age_70_up = age >= 70 if !missing(age)

	gen unmarried_childless = (1-married)*(1-has_child)
	gen unmarried_haschild = (1-married)*has_child
	gen married_childless = married*(1-has_child)

	gen interv_nonenglish = .

	gen any_emp_hh = earnings_qx > 0 if !missing(earnings_qx)
	replace any_emp_hh = 1 if missing(any_emp_hh)

	gen single_hh = hhsize == 1

	bys hhid year: egen num_emp_hh = sum(employ)
	replace num_emp_hh = min(num_emp_hh,hhsize)

	gen lths = educ < 2
	gen hs = educ == 2
	gen coll = educ > 3 & !missing(educ)

	gen disabled_nowork = disabled*(1-employ)

	gen anywealth = wsav_nom > 0 if !missing(wsav_nom)
	replace anywealth = 1 if missing(anywealth)

	* Note: Language not consistently recorded in CEX
	gen not_in_english = 0

	gen any_disabled = max(child_disabled,disabled)
	replace any_disabled = 0 if missing(any_disabled)
	replace disabled = 0 if missing(disabled)
	
	gen nonwhite = race != 1
	gen white = race == 1
	gen black = race == 2
	gen asian = race == 4
	gen aian = 0
	
	gen snap_imp = 0
	rename n_children nchild
	 
	gen female = sex==2 if !missing(sex)
	
	gen healthins_othpub = (hhmcrcov >= 0 & !missing(hhmcrcov)) | (othmed == 1) | (othplan == 1)
	gen healthins_priv = !missing(hhipdlib)
	
	gen healthins_none = 1 - max(medicaid,healthins_priv,healthins_othpub)
	gen healthins_pubpriv = healthins_priv*max(medicaid,healthins_othpub)
	
* Keep in tempfile

	tempfile mittag
	save `mittag', replace

* Load coefficients

	preserve
	import delimited "$dir/data/mittag2009/par_vec_mod.csv", clear
	drop if missing(pname)
	mkmat cd2008, mat(coefs) rownames(pname)
	restore

* Create probit score
		
	local vlist "_cons snap snap_imp inc_to_fpl_50_100 inc_to_fpl_100_150 inc_to_fpl_150_200 inc_to_fpl_200_gt inc_to_fpl_lt_50s inc_to_fpl_50_100s inc_to_fpl_100_150s inc_to_fpl_150_200s inc_to_fpl_200_gts age_18_29 age_30_39 age_50_59 age_60_69 age_70_up anywealth hhsize nchild unmarried_childless unmarried_haschild married_childless not_in_english num_emp any_emp any_disabled single_hh unemploy nilf female nonwhite lths hs coll disabled disabled_nowork" 

	gen snap_mp = 0

	local i = 1

	foreach v in `vlist' {
		
		local coef = coefs[`i',1]
		
		di "`v' : `coef'"
		
		replace snap_mp = snap_mp + `v'*`coef'
		
		local i = `i'+1
		
	}

* Compute probability from score

	gen snap_pr = 1-normal(snap_mp)

* Run and store regression results		

	reg rk_cons snap_pr bs_rk* if eligsim_snap==1 [pw=finlwt21], cl(cuid)
	store_est_tpl using mittag.csv, coef(snap_pr) name(mittag_snap_cons_cex) all format(%12.1f)
	
/***************************************************************************
Medicaid - CEX
***************************************************************************/

* Reload clean data

	use `mittag', clear

* Prepare data for Mittag 2019 underreporting correction

	gen age_lt_45 = (age >= 18 & age < 45) - 1/6
	gen age_gt_45 = (age >= 45 & !missing(age)) - 1/6
	
	gen state_recode = 0 if missing(state)
	replace state_recode = 1 if state == 1
	replace state_recode = 2 if state == 2
	replace state_recode = 3 if state == 4
	replace state_recode = 4 if state == 5
	replace state_recode = 5 if state == 6
	replace state_recode = 6 if state == 8
	replace state_recode = 7 if state == 9
	replace state_recode = 8 if state == 10
	replace state_recode = 9 if state == 11
	replace state_recode = 10 if state == 12
	replace state_recode = 11 if state == 13
	replace state_recode = 12 if state == 15
	replace state_recode = 13 if state == 16
	replace state_recode = 14 if state == 17
	replace state_recode = 15 if state == 18
	replace state_recode = 16 if state == 19
	replace state_recode = 17 if state == 20
	replace state_recode = 18 if state == 21
	replace state_recode = 19 if state == 22
	replace state_recode = 20 if state == 23
	replace state_recode = 21 if state == 24
	replace state_recode = 22 if state == 25
	replace state_recode = 23 if state == 14
	replace state_recode = 24 if state == 26
	replace state_recode = 25 if state == 27
	replace state_recode = 26 if state == 28
	replace state_recode = 27 if state == 29
	replace state_recode = 28 if state == 30
	replace state_recode = 29 if state == 31
	replace state_recode = 30 if state == 32
	replace state_recode = 31 if state == 33
	replace state_recode = 32 if state == 34
	replace state_recode = 33 if state == 36
	replace state_recode = 34 if state == 37
	replace state_recode = 36 if state == 39
	replace state_recode = 37 if state == 40
	replace state_recode = 38 if state == 41
	replace state_recode = 39 if state == 42
	replace state_recode = 40 if state == 44
	replace state_recode = 41 if state == 45
	replace state_recode = 42 if state == 46
	replace state_recode = 43 if state == 47
	replace state_recode = 44 if state == 48
	replace state_recode = 45 if state == 49
	replace state_recode = 47 if state == 51
	replace state_recode = 48 if state == 53
	replace state_recode = 50 if state == 35

	forvalues t = 1/51 {
		gen state_`t' = state_recode == `t'
	}
	
	foreach v of varlist state_* {
		replace `v' = -1/51 if `v' == 0
		replace `v' = 1-1/51 if `v' == 1
		replace `v' = 0 if state == 0 | state == 99
	}
	foreach v of varlist female white black aian asian { 
		replace `v' = 0 if missing(`v')
	}
	foreach v of varlist white black aian asian { 
		replace `v' = -1/4 if `v' == 0
		replace `v' = 1-1/4 if `v' == 1
	}
	foreach v of varlist head spouse {
		replace `v' = -1/5 if `v' == 0
		replace `v' = 1-1/5 if `v' == 1
	}
	
	gen healthins_othpub_only = healthins_othpub*(1-healthins_priv)*(1-medicaid) - 1/3
	gen healthins_priv_only = healthins_priv*(1-healthins_othpub)*(1-medicaid) - 1/3
	gen medicaid_only = medicaid*(1-healthins_priv)*(1-healthins_othpub) - 1/3
	
	gen inc_to_fpl0 = inc_to_fpl == 0
	gen inc_to_fpl_1_49 = 100*inc_to_fpl < 50
	gen inc_to_fpl_50_75 = 100*inc_to_fpl >= 49 & 100*inc_to_fpl < 75 
	gen inc_to_fpl_75_99 = 100*inc_to_fpl >= 75 & 100*inc_to_fpl < 100 
	gen inc_to_fpl_100_124 = 100*inc_to_fpl >= 100 & 100*inc_to_fpl < 125 
	gen inc_to_fpl_125_149 = 100*inc_to_fpl >= 125 & 100*inc_to_fpl < 150 
	gen inc_to_fpl_150_174 = 100*inc_to_fpl >= 150 & 100*inc_to_fpl < 175 
	gen inc_to_fpl_175_199 = 100*inc_to_fpl >= 175 & 100*inc_to_fpl < 200  
	gen inc_to_fpl_200 = 100*inc_to_fpl >= 200 & !missing(inc_to_fpl)
	
	foreach v of varlist inc_to_fpl* {
		replace `v' = -1/9 if `v' == 0
		replace `v' = 1-1/9 if `v' == 1
	}
	
* Load coefficients
	
	preserve
	import delimited "$dir/data/mittag2009/medicaid_models_davern_et_al.csv", clear
	drop if missing(pname)
	mkmat model1, mat(coefs1) rownames(pname)
	mkmat model2, mat(coefs2) rownames(pname)
	restore

* Create probit score
		
	local vlist "_cons age_lt_45 age_gt_45 healthins_othpub_only healthins_priv_only healthins_pubpriv healthins_none medicaid_only hispanic black aian asian white female head spouse inc_to_fpl0 inc_to_fpl_1_49 inc_to_fpl_50_75 inc_to_fpl_75_99 inc_to_fpl_100_124 inc_to_fpl_125_149 inc_to_fpl_150_174 inc_to_fpl_175_199 inc_to_fpl_200 state_1 state_2 state_3 state_4 state_5 state_6 state_7 state_8 state_9 state_10 state_11 state_12 state_13 state_14 state_15 state_16 state_17 state_18 state_19 state_20 state_21 state_22 state_23 state_24 state_25 state_26 state_27 state_28 state_29 state_30 state_31 state_32 state_33 state_34 state_35 state_36 state_37 state_38 state_39 state_40 state_41 state_42 state_43 state_44 state_45 state_46 state_47 state_48 state_49 state_50 state_51" 

	gen medicaid_fit = 0

	local i = 1

	foreach v in `vlist' {
		
		local coef1 = coefs1[`i',1]
		local coef2 = coefs2[`i',1]
			
		replace medicaid_fit = medicaid_fit + `v'*`coef1' if medicaid == 0
		replace medicaid_fit = medicaid_fit + `v'*`coef2' if medicaid == 1
		
		local i = `i'+1
		
	}

* Compute probability from score

	gen medicaid_pr = .
	replace medicaid_pr = invlogit(medicaid_fit)
	drop medicaid_fit
	
* Run and store regression results		

	cd "$dir/tables/data"
	
	reg rk_cons medicaid_pr bs_rk* if eligsim_medicaid==1 [pw=finlwt21], cl(cuid)
	store_est_tpl using mittag.csv, coef(medicaid_pr) name(mittag_medicaid_cons_cex) all format(%12.1f)
	
*** Save tables

	cat mittag.csv
	
	cd "$dir/code"

	table_from_tpl, t(../tables/template/mittag_template.tex) ///
					r(../tables/data/mittag.csv) ///
					o(../tables/output/mittag_final.tex) 
						
	cd "$dir"
	
	exit

	