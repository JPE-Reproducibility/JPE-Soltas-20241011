/***************************************************************************

This code cleans the intermediate PSID by creating a balanced panel and merging in Bayes fixed effects

Calls:
- Install ebayes_chandra_et_al_2016.ado

Input:
- $dir/data/psid_int.dta

Output:
- $dir/data/lifetime_income.dta

***************************************************************************/

*** Load data
		
	do code/settings
	
	set more off
	
	use "$dir/data/psid_int.dta", clear
	
*** Initialize projection variable

	preserve
	
	gen projection = 1
	gcollapse (mean) projection [aw=wtfam], by(age)
	gen r = 0
	
	tempfile projections
	save `projections', replace
	
	drop r
	tempfile projection_latest
	save `projection_latest', replace
	restore
	
	local R = 3
	
forvalues r = 1/`R' {
	
*** Set up template for file

	use "$dir/data/psid_int.dta", clear

	replace income_real = income_real + 1 if !missing(income_real)
	
	* Estimate baseline FEs
	
	merge m:1 age using `projection_latest', keep(1 3) nogen

	ppmlhdfe income_real if head==1 | spouse==1 [pw=wtfam], a(i.id#c.projection year female#married#anychild edcat#age, savefe) tol(1e-7)
	
	mat b = e(b)
	local constant = b[1,1]
	
	rename __hdfe1__ reg_fe
		
	collapse (firstnm) female nonwhite reg_fe (sum) wtfam, by(id famid_orig perid_orig)
	gduplicates drop
	
	summ reg_fe [aw=wtfam]
	local mean_fe = r(mean)
	drop wtfam
	
	tempfile fe_boot
	save `fe_boot', replace
		
*** Bootstrap FEs

	keep reg_fe id famid_orig perid_orig
	rename reg_fe fe_eb

	local B = 100
	
	set seed 123456
	set sortseed 654321

	forvalues i = 1/`B' {
	
		di `i'
		
		quietly {
		
		use "$dir/data/psid_int.dta", clear
		merge m:1 age using `projection_latest', keep(1 3) nogen
		
		replace income_real = income_real + 1 if !missing(income_real)
		
		* Create Bayesian bootstrap weight
		
		gen gamma_tmp = rgamma(0.5,0.5)
		gegen gammavar = first(gamma_tmp), by(id)
		gegen gammasum = sum(gammavar)
		replace gammavar = gammavar / gammasum
		
		gen wtfam_b = wtfam * gammavar
		drop gamma_tmp gammasum gammavar
		
		* Run Poisson reg and save FE
					
		ppmlhdfe income_real if head==1 | spouse==1 [pw=wtfam_b], a(i.id#c.projection year female#married#anychild edcat#age, savefe) tol(1e-7)
				
		gen fe`i' = __hdfe1__
		
		keep id fe`i' famid_orig perid_orig
		
		gcollapse fe`i', by(id famid_orig perid_orig)
		
		merge 1:1 id using `fe_boot', nogen
		save `fe_boot', replace
		
		}
	
	}
	
*** Run Empirical Bayes
	
	use `fe_boot', clear
	
	egen sd_withinfe = rowsd(fe*)
	
	ebayes reg_fe sd_withinfe female nonwhite, gen(fe_eb)
	
*** Store in tempfile
	
	keep id fe_eb famid_orig perid_orig
	
	tempfile fe_eb
	save `fe_eb', replace
	
*** Update projection coefficients

	use "$dir/data/psid_int", clear
	merge m:1 id using `fe_eb', keep(1 3) nogen
	merge m:1 age using `projection_latest', keep(1 3) nogen
	
	replace income_real = income_real + 1 if !missing(income_real)
	
	gen tmp_fe_eb = fe_eb*projection
	
	ppmlhdfe income_real if head==1 | spouse==1 [pw=wtfam], a(i.age#c.tmp_fe_eb year female#married#anychild edcat#age, savefe) tol(1e-7) 
	
	replace projection = __hdfe1__
	
	gcollapse (mean) projection [aw=wtfam], by(age)
	
	gen r = `r'
	
	append using `projections'
	save `projections', replace
	
	keep if r == `r'
	keep age projection
	save `projection_latest', replace

}

*** Save projections

	use `projections', clear
	save "$dir/data/projections", replace
	
*** Create balanced panel

	* Create template for panel
	
		use "$dir/data/psid_int", clear
		keep id famid_orig perid_orig
		gduplicates drop
		
		local age_min = 18
		local age_max = 65
		local n_years = `age_max' - `age_min' + 1
		
		expand `n_years'
		
		gsort id
		gen age = 18
		replace age = age[_n-1]+1 if !missing(age[_n-1]) & id == id[_n-1]
		
		tempfile balanced_panel
		save `balanced_panel', replace
		
	* Re-load data
	
		use "$dir/data/psid_int", clear
		merge m:1 age using `projection_latest', nogen keep(3)
		
		ppmlhdfe income_real if head==1 | spouse==1 [pw=wtfam], a(i.id#c.projection year female#married#anychild edcat#age, savefe)
		
		drop __hdfe1__
	
		rename __hdfe2__ fe_year_
		rename __hdfe3__ fe_female_married_anychild_
		rename __hdfe4__ fe_edcat_age_
		
		keep id famid_orig perid_orig year female married anychild edcat age nonwhite income_real year fe_* 
				
		* Align age/year for panel
		
		keep if !missing(income_real)
		collapse (firstnm) female married anychild edcat nonwhite year fe_*, by(id age famid_orig perid_orig)
				
	* Merge data into balanced panel
	
		merge 1:1 id age using `balanced_panel', nogen keep(3)
		
		* Forward and backward imputations of missing values
		
		gsort + id + age 
		
		foreach v of varlist female married anychild edcat nonwhite {
			replace `v' = `v'[_n-1] if !missing(`v'[_n-1]) & id == id[_n-1]
		}
		
		gsort + id - age
		
		foreach v of varlist female married anychild edcat nonwhite {
			replace `v' = `v'[_n-1] if !missing(`v'[_n-1]) & id == id[_n-1]
		}
		
		
		bys female married anychild: gegen fe_female_married_anychild = max(fe_female_married_anychild_)
		bys edcat age: gegen fe_edcat_age = max(fe_edcat_age_)
		bys year: gegen fe_year = max(fe_year_)

		drop fe_female_married_anychild_ fe_edcat_age_ fe_year_
		
	* Merge in Empirical Bayes fixed effects
	
		merge m:1 id using `fe_eb', nogen keep(3)
		merge m:1 age using `projection_latest', nogen keep(3)
		
		/*summ fe_eb
		local m = r(mean)
		replace fe_eb = `m' if missing(fe_eb) */
		
*** Construct lifetime income ranks	
		
	gen lifetime_income = exp(`constant' + fe_eb*projection + fe_female_married_anychild + fe_edcat_age + fe_year)
	
	collapse (mean) lifetime_income fe_eb, by(id famid_orig perid_orig)
	
*** Save as file

	save "$dir/data/lifetime_income", replace
