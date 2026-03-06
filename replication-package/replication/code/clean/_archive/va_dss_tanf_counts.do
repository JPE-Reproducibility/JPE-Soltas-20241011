* This program uses the Virginia DSS customer files to compute average (per-year)
* counts of TANF/VIEW recieipt among individuals in the 1988-1995 birth cohorts,
* split by a number of demographic variables: age, gender, education, marital 
* status, race, ethnicity, and citizenship

* Import data

	forvalues y = 1988/1995 {
		
		use ~/virginia/intermediate/dsscustomer_`y'.dta
		merge 1:m uniqueid year using ~/virginia/intermediate/vec_view_quarter_`y'.dta, nogen keep(1 3)
		
		tempfile d_`y'
		save `d_`y'', replace
	}
	
	use `d_1988', clear
	
	forvalues y = 1989/1995 {
		append using `d_`y''
	}
		
* Clean variables
		
	gen tanf = max(has_tanfcase,has_viewcase)
	keep if tanf == 1

	gen age = year - birth_year
	
	bys uniqueid year: egen annual_earnings = sum(wages)
	gen earnings0 = annual_earnings == 0
	gen earnings0_1000 = annual_earnings > 0 & annual_earnings < 1000
	gen earnings1000_2500 = annual_earnings >= 1000 & annual_earnings < 2500
	gen earnings2500_5000 = annual_earnings >= 2500 & annual_earnings < 5000
	gen earnings5000_7500 = annual_earnings >= 5000 & annual_earnings < 7500
	gen earnings7500_10000 = annual_earnings >= 7500 & annual_earnings < 10000
	gen earnings10000_15000 = annual_earnings >= 10000 & annual_earnings < 15000
	gen earnings15000_20000 = annual_earnings >= 15000 & annual_earnings < 20000
	gen earnings20000_30000 = annual_earnings >= 20000 & annual_earnings < 30000
	gen earnings30000_40000 = annual_earnings >= 30000 & annual_earnings < 40000
	gen earnings40000_50000 = annual_earnings >= 40000 & annual_earnings < 50000
	gen earnings50000_up = annual_earnings >= 50000
	
	gen marst_single = marital_status == 0 | marital_status == 1 | marital_status == 93
	gen marst_married = marital_status == 2
	gen marst_separated = marital_status == 3 | marital_status == 7 | marital_status == 8
	gen marst_divorced = marital_status == 4
	gen marst_widowed = marital_status == 5
	
	gen race_hispanic = ethnicity == 1
	replace race_asian = 1 if race_pi == 1
	drop race_pi
	
	foreach v of varlist race_white race_black race_asian race_aian race_oth {
		replace `v' = 0 if race_hispanic == 1 & `v' == 1
	}
	
	drop if gender == 3
	gen female = gender == 1
	
	gen ed_lths = educ <= 12 if !missing(educ)
	gen ed_hsdeg = educ == 13 | educ == 14 | educ == 15
	gen ed_scoll = educ > 15 & educ < 19
	gen ed_ba = educ == 19
	gen ed_mtcoll = educ > 19 if !missing(educ)
	
	replace citizen = 0 if missing(citizen) & citizenshipstatuscode > 1 & !missing(citizenshipstatuscode)
	replace citizen = 1 if missing(citizen) & citizenshipstatuscode <= 1
	
* Collapse to totals by year
	
	collapse (firstnm) age female ed_* marst_* race_* earnings* citizen, by(uniqueid year)
	
	gen ct = 1

	collapse (sum) ct, by(year age female ed_* marst_* race_* earnings* citizen)
	
	foreach v of varlist year age female ed_* marst_* race_* earnings* citizen {
		drop if missing(`v')
	}

	save ~/virginia/intermediate/tanfview_counts_by_demog_1988_1995.dta, replace
