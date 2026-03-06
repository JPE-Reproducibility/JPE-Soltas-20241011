/***************************************************************************
 * Self-Targeting in Transfer Programs
 * 
 * Description:
 * Prepares CPS data for imputing income into PSID and creates industry and 
 * occupation harmonization crosswalks. Estimates income as a function of 
 * demographics and job characteristics in CPS and predicts income for PSID 
 * heads/spouses. Outputs predicted income ranks for PSID households.
 * 
 * Inputs:
 * - PSID base file
 * - IPUMS CPS extract
 * - Harmonization crosswalks (ind/occ)
 * 
 * Outputs:
 * - Updated PSID file with predicted income ranks
 ***************************************************************************/


* Set working directory

	do code/settings

* Prep: reshape PSID data for merge

	use "$dir/data/psid_base", clear
	
	keep if head == 1 | spouse == 1
	
	keep id year income_nominal weeks hours hispanic black aian asian otherrace female married edcat age selfemp occconst indconst disabled
	
	gen psid = 1
	
	tempfile psid_export
	save `psid_export', replace
	
* Run IPUMS cleaner code
	
	do "$dir/code/clean/cps/00_cps_00091.do"
	
* Set sample universe

	* 18-65 yo
	keep if age>=18 & age<=65
	
	* Head or spouse
	keep if inlist(relate,101,201,202,203,1114,1115,1116,1117)
	
	* Nonnegative income
	replace inctot = 0 if inctot<0
	
* Clean CPS variables for PSID merge

	* Female
	gen female = sex == 2 if !missing(sex)
	
	* Married
	gen married = marst == 1 | marst == 2 if !missing(marst)
	
	* Race/ethnicity
	
	gen hispanic = 0
	replace hispanic = 1 if hispan != 0 & !missing(hispan)
	
	gen black = race == 200 & hispanic == 0
	gen aian = race == 300 & hispanic == 0
	gen asian = inlist(race,650,651) & hispanic == 0
	gen otherrace = !missing(race) & !inlist(race,100,200,300,650,651) & hispanic == 0
	
	* Disability
	gen disabled = 0 if !missing(disabwrk) 
	replace disabled = 1 if disabwrk == 2
	
	* Education
	gen edcat = .
	replace edcat = 1 if educ <= 71
	replace edcat = 2 if educ == 73
	replace edcat = 3 if educ > 73 & educ <= 92
	replace edcat = 4 if educ == 111
	replace edcat = 4 if educ > 111 & !missing(educ)
	
	* Self-employment
	gen selfemp = inlist(classwly,13,14) if !missing(classwly)
	
	rename occly occ
	rename indly ind
	gen indconst = ind90ly
	
	rename wkswork1 weeks
	rename uhrsworkly hours
	rename inctot income_nominal
	
* Produce industry code harmonization

	tempfile data
	save `data', replace
	
	replace year = 1970 if inlist(year,1979,1981)
	replace year = 2000 if inlist(year,2003,2005,2007)
	replace year = 2010 if inlist(year,2015,2017,2019)
	
	collapse (sum) asecwt, by(year indconst ind)
		
	* 1970 ind codes
	
	preserve
	
	keep if year == 1970
	
	expand 2, gen(dup)
	replace year = 1997 if dup == 0
	replace year = 1999 if dup == 1
	
	drop dup
	expand 2, gen(dup)
	replace year = 2001 if dup == 1
	
	collapse (sum) asecwt, by(indconst ind)
	drop asecwt
	
	save "$dir/data/crosswalks/ind1970_ind1990.dta", replace
	
	restore
		
	* 2000 ind codes
	
	preserve
	
	keep if year == 2000
	
	expand 2, gen(dup)
	replace year = 2003 if dup == 0
	replace year = 2005 if dup == 1
	
	forvalues t = 2007(2)2015 {
		
		drop dup
		expand 2, gen(dup)
		replace year = `t' if dup == 1
		
	}
	
	collapse (sum) asecwt, by(indconst ind)
	drop asecwt
	
	save "$dir/data/crosswalks/ind2000_ind1990.dta", replace
	
	restore	
	
	* 2010 ind codes
	
	preserve
	
	keep if year == 2010
	
	expand 2, gen(dup)
	replace year = 2017 if dup == 0
	replace year = 2019 if dup == 1
	
	collapse (sum) asecwt, by(indconst ind)
	drop asecwt
	
	save "$dir/data/crosswalks/ind2010_ind1990.dta", replace
	
	restore
		
* Harmonize occupation codes using David Dorn resources

	use `data', clear

	* 1990 occ codes (already correct)
	preserve
	keep if inlist(year,1997,1999,2001)
	gen occconst = occ
	tempfile dat_97_01
	save `dat_97_01', replace
	restore

	* 2000 occ codes
	preserve
	keep if inlist(year,2003,2005,2007,2009,2011)
	replace occ = occ/10
	merge m:1 occ using "$dir/data/crosswalks/occ2000_occ1990dd/occ2000_occ1990dd.dta" , nogen keep(1 3)
	rename occ1990dd occconst
	tempfile dat_03_15
	save `dat_03_15', replace
	restore
	
	* 2010 occ codes
	preserve
	keep if inlist(year,2013,2015,2017,2019)
	merge m:1 occ using "$dir/data/crosswalks/occ2010_occ1990dd/occ2010_occ1990dd.dta" , nogen keep(1 3)
	rename occ1990dd occconst
	tempfile dat_17_19
	save `dat_17_19', replace
	restore
	
	* Reassemble data
	
	use `dat_97_01', clear
	append using `dat_03_15'
	append using `dat_17_19'
	
	replace occconst = 0 if occ == 0
	replace occconst = 999 if !missing(occ) & missing(occconst)
	
* Append PSID

	gen psid = 0
	
	append using `psid_export'
	replace asecwt = 0 if psid == 1	
	
	local varlist "year weeks hours hispanic black aian asian otherrace female married edcat age selfemp occconst indconst disabled"
		
	ppmlhdfe income_nominal [pw=asecwt], a(`varlist', savefe) d
	local constant = _b[_cons]

	local i = 0
	
	foreach v of varlist __hdfe* {
		
		local i = `i'+1
		
		local thisvar : word `i' of `varlist'
		di "`thisvar'"

		gegen tmp = max(`v'), by(`thisvar')
		replace `v' = tmp
		drop tmp
		
	}
	
	egen income_nominal_pred = rowtotal(__hdfe*)
	replace income_nominal_pred = `constant' + income_nominal_pred
	
	keep if psid == 1
	keep id year income_nominal_pred
	
* Merge back into the PSID

	merge 1:1 id year using "$dir/data/psid_base", nogen keep(2 3)
	
	* Construct ranks
	
	egen income_pred_hh = sum(income_nominal_pred), by(famid year)
	gen income_pred_eq = income_pred_hh / (((hhsize-nchild)+0.7*nchild)^0.7)
	
	egen rk_pred_eq = rank(income_pred_eq) if !missing(faminct_real) & !missing(lifetime_income) & !missing(consumption_real), unique by(year)
	bys year: gegen max_rk_pred_eq = max(rk_pred_eq)
	replace rk_pred_eq = 100*(rk_pred_eq - 1) / (max_rk_pred_eq - 1)
	
	drop income_pred_hh income_pred_eq max_rk_pred_eq
	
	save "$dir/data/psid_base", replace
	