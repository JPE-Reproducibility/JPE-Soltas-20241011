/***************************************************************************

This code cleans the raw PSID data.

Calls:
- code/psid/J345111.do: PSID loading script from UMich
- code/psid/J308959.do: supplement PSID loading script from UMich
- code/psid/name_vars.do: renames PSID variables for interpretability

Input:
- data/psid/J345111_codebook.html
- data/psid/J345111.txt
- data/psid/J308959_codebook.html
- data/psid/J308959.txt
- data/psid/fed_pov_guidelines.dta
- data/crosswalks/occ1970_occ1990dd/occ1970_occ1990dd.dta
- data/crosswalks/occ2000_occ1990dd/occ2000_occ1990dd.dta
- data/crosswalks/occ2010_occ1990dd/occ2010_occ1990dd.dta
- data/crosswalks/ind1970_ind1990.dta
- data/crosswalks/ind2000_ind1990.dta
- data/cps/cps_imputation.dta

Output:
- data/psid_int.dta"

***************************************************************************/

* Set working directory

	do code/settings.do
	set more off
	
* Pre-load PSID Child Development Supplement data
	
	run "$dir/code/clean/psid/00_J308959.do"
	
	rename ER30001 famid_orig
	rename ER30002 perid_orig
		
	rename ER33401 famid1997
	rename Q1A26A limitathletics1997
	rename Q1A26B limitschattend1997
	rename Q1A26C limitschwork1997
	
	rename ER33601 famid2001
	rename Q21A9A limitathletics2001
	rename Q21A9B limitschattend2001
	rename Q21A9C limitschwork2001
	
	rename ER33901 famid2005
	rename Q31A9A limitathletics2005
	rename Q31A9B limitschattend2005
	rename Q31A9C limitschwork2005
	
	rename ER34201 famid2013
	rename P14A17 limitathletics2013
	rename P14A18 limitschattend2013
	rename P14A19 limitschwork2013
	
	rename ER34701 famid2019
	rename P19A17 limitathletics2019
	rename P19A18 limitschattend2019
	rename P19A19 limitschwork2019
	
	keep famid* limits* perid_orig
	
	gen id = famid_orig*1000 + perid_orig
	
	reshape long famid limitathletics limitschattend limitschwork, i(id) j(year)
	
	gen child_disabled = 0
	replace child_disabled = 1 if limitathletics == 1 | limitschattend == 1 | limitschwork == 1
	
	collapse (max) child_disabled, by(famid_orig famid year)
	
	tempfile cds_data
	save `cds_data', replace

* Run PSID base code to import data

	run "$dir/code/clean/psid/00_J345111.do"

* Rename PSID variables for reshape

	run "$dir/code/clean/psid/00_name_vars.do"

* Create new unique identifier
	
	gen id = _n
	label variable id "Person identifier (new)"
	label variable perid_orig "Person identifier (original)"

* Reshape into long panel	
	
	reshape long num famid rel age snap snap_amt_hh snap_unit tanf_head tanf_amt_head tanf_unit_head tanf_spouse tanf_amt_spouse ///
			tanf_unit_spouse race_s_ race_h_ hispanic_spouse hispanic_head ///
			transfer earnings_s_ earnings_h_ houseval othwelf_head othwelf_amt_head othwelf_amt_spouse  ///
			hhsize marital wtfam wtind wcar wsav wsav2_ whome woth split hhid ph1 ph2 ed wic nchild equivrent equivrent_unit rent_unit othwelf_spouse ///
			med1 med2 med3 med4 med5 med6 med7 state ssi_hh ssi_amt_head ssi_unit_head ssi_spouse ssi_amt_spouse ssi_unit_spouse ///
			ui_head ui_amt_head ui_unit_head ui_spouse ui_amt_spouse ui_unit_spouse faminc disabled_head disabled_spouse ///
			housing_exp utility_exp fpl emp liheap liheap_amt_hh liheap_unit rent rent_subsidy_part rent_subsidy_full ///
			why_unemploy_head why_unemploy_spouse annual_hrs_head annual_hrs_spouse wks_unemp_head wks_unemp_spouse ///
			food_exp trans_exp educ_exp childcare_exp health_exp computer_exp clothing_exp travel_exp rec_exp ///
			othwelf_imp_spouse othwelf_imp_head othwelf_unit_head othwelf_unit_spouse educ_f_head educ_m_head educ_f_spouse ///
			educ_m_spouse mortgage_exp proptax_exp whome_imp woth_imp earnings_h_imp earnings_s_imp snap_imp ///
			ui_imp_head ui_imp_spouse ssi_imp_head ssi_imp_spouse tanf_imp_head tanf_imp_spouse oer lang ///
			rent_h_amt rent_h_unit div_h_amt div_h_unit int_h_amt int_h_unit trust_h_amt trust_h_unit ///
			rent_s_amt rent_s_unit div_s_amt div_s_unit int_s_amt int_s_unit trust_s_amt trust_s_unit limitathletics limitschattend limitschwork ///
			applied_tanf applied_ssi applied_wic applied_snap applied_medicaid applied_ha applied_liheap applied_ui ///
			appstatus_tanf appstatus_ssi appstatus_wic appstatus_snap appstatus_medicaid appstatus_ha appstatus_liheap appstatus_ui ///
			vehadd_exp foodathome_exp gasoline_exp othtrans_exp taxi_exp bustrain_exp parking_exp veh_rep_exp veh_ins_exp ///
			veh1_manuf veh1_make veh1_model veh1_type veh1_howacq veh1_yearacq veh1_price veh1_leaseamt veh1_leasefreq ///
			veh2_manuf veh2_make veh2_model veh2_type veh2_howacq veh2_yearacq veh2_price veh2_leaseamt veh2_leasefreq ///
			veh3_manuf veh3_make veh3_model veh3_type veh3_howacq veh3_yearacq veh3_price veh3_leaseamt veh3_leasefreq ///
			ownhome rooms aircond computer_h smartphone_h computer_s smartphone_s furniture_exp hval100_ hval200_ hval400_ hval75_ hval25_ ///
			selfemp_h selfemp_s ind_h occ_h ind_s occ_s weeks_h hours_h weeks_s hours_s schoolbfast schoollunch schoolmeals ///
			farminc assetincbus_h assetincbus_s assetinc_other laborincbus_h laborincbus_s veh_loan_exp veh_dp_exp faminct_hs faminct_oth ///
			naturalized_h naturalized_s immstat_h immstat_s regiongrewup_h regiongrewup_s yrus_h yrus_s ///
			snap_m1_ tanf_h_m1_ tanf_s_m1_ ssi_h_m1_ ssi_s_m1_ snap_m2_ tanf_h_m2_ tanf_s_m2_ ssi_h_m2_ ssi_s_m2_ ///
			snap_m3_ tanf_h_m3_ tanf_s_m3_ ssi_h_m3_ ssi_s_m3_ snap_m4_ tanf_h_m4_ tanf_s_m4_ ssi_h_m4_ ssi_s_m4_ ///
			snap_m5_ tanf_h_m5_ tanf_s_m5_ ssi_h_m5_ ssi_s_m5_ snap_m6_ tanf_h_m6_ tanf_s_m6_ ssi_h_m6_ ssi_s_m6_ ///
			snap_m7_ tanf_h_m7_ tanf_s_m7_ ssi_h_m7_ ssi_s_m7_ snap_m8_ tanf_h_m8_ tanf_s_m8_ ssi_h_m8_ ssi_s_m8_ ///
			snap_m9_ tanf_h_m9_ tanf_s_m9_ ssi_h_m9_ ssi_s_m9_ snap_m10_ tanf_h_m10_ tanf_s_m10_ ssi_h_m10_ ssi_s_m10_ ///
			snap_m11_ tanf_h_m11_ tanf_s_m11_ ssi_h_m11_ ssi_s_m11_ snap_m12_ tanf_h_m12_ tanf_s_m12_ ssi_h_m12_ ssi_s_m12_ ///
			health_h health_s grewuppoor_h grewuppoor_s ///
			ss_amt_h_ ss_amt_s_ wc_rec_h_ wc_rec_s_ wc_amt_h_ wc_amt_s_ wc_freq_h_ wc_freq_s_ js_month_h js_year_h js_month_s js_year_s je_year_h je_year_s ///
			foodsecy fsecmon1_ fsecmon2_ fsecmon3_ fsecmon4_ fsecmon5_ fsecmon6_ fsecmon7_ fsecmon8_ fsecmon9_ fsecmon10_ fsecmon11_ fsecmon12_, i(id) j(year)
	
* Drop unused variables

	drop 	ER30000 ER33401 ER33402 ER33502 ER33601 ER33602 ER33701 ER33702 ER32006 wtind split ///
			ER33801 ER33802 ER33901 ER33902 ER34001 ER34002 ER34101 ER34102 ER34201 ER34202 ER34301 ///
			ER34302 ER34501 ER34502 ER32049 ER72001 ER34701 ER34702 num* limitathletics limitschattend limitschwork
			
* Merge in Child Development Supplement

	merge m:1 famid_orig famid year using `cds_data', nogen keep(1 3)
	
* Recode age

	replace age = . if age == 999
	replace age = 99 if age > 99 & !missing(age)
	
	label variable age "Age"
	
* Clean earnings data

	gen cpi = .
	replace cpi = 62.01610 if year == 1997
	replace cpi = 64.35663 if year == 1999
	replace cpi = 68.39703 if year == 2001
	replace cpi = 71.08526 if year == 2003
	replace cpi = 75.43795 if year == 2005
	replace cpi = 80.10388 if year == 2007
	replace cpi = 82.89340 if year == 2009
	replace cpi = 86.89517 if year == 2011
	replace cpi = 89.99694 if year == 2013
	replace cpi = 91.56159 if year == 2015
	replace cpi = 94.70392 if year == 2017
	replace cpi = 98.76702 if year == 2019
	
	label variable cpi "Consumer Price Index (100 = 2020 annual avg)"
	label variable year "Survey year"
		
* Recode head/spouse variables

	gen head = 0
	replace head = 1 if rel == 10
	
	gen spouse = 0
	replace spouse = 1 if rel == 20 | rel == 22
	
	label variable head "Head of household"
	label variable spouse "Spouse of household"
	label variable rel "Relationship to head"
	label variable lang "Language"
	
* Recode head/spouse status in case of more than one head/spouse in a HH

	bys famid year: gegen numheads = sum(head)
	bys famid year: gegen numspouses = sum(spouse)
	
	* Rule: If HH has more than one head, recode so that oldest person is the only head
	
	gsort famid year - head - age - id
	
	gen tmp_fix_head = 1
	replace tmp_fix_head = tmp_fix_head[_n-1]+1 if famid == famid[_n-1] & year == year[_n-1] & head == 1
	bys famid year: gegen tmp_fix_head_min = min(tmp_fix_head)

	replace head = 0 if tmp_fix_head > tmp_fix_head_min & numheads > 1
	
	* Rule: If HH has more than one spouse, recode so that oldest person is the only spouse
	
	gsort famid year - spouse - age - id
	
	gen tmp_fix_spouse = 1
	replace tmp_fix_spouse = tmp_fix_spouse[_n-1]+1 if famid == famid[_n-1] & year == year[_n-1] & spouse == 1
	bys famid year: gegen tmp_fix_spouse_min = min(tmp_fix_spouse)
	
	replace spouse = 0 if tmp_fix_spouse > tmp_fix_spouse_min & numspouses > 1
	
	drop tmp_fix_* numheads numspouses
		
* Create time identifiers to xtset			

	gen t = .
	replace t = 0 if year == 1997
	replace t = 1 if year == 1999
	replace t = 2 if year == 2001
	replace t = 3 if year == 2003
	replace t = 4 if year == 2005
	replace t = 5 if year == 2007
	replace t = 6 if year == 2009
	replace t = 7 if year == 2011
	replace t = 8 if year == 2013
	replace t = 9 if year == 2015
	replace t = 10 if year == 2017
	replace t = 11 if year == 2019
	
	label variable t "Survey wave (time period)"

* Marital status indicator
	
	gen married = marital == 1 if !missing(marital) | !inlist(marital,8,9)
	drop marital
	
	label variable married "Marital status (binary)"

* Recode household size (topcode @ 7)
	
	replace hhsize = 7 if hhsize > 7 & !missing(hhsize)
	
	label variable hhsize "Household size (1-6, 7+)"
	
* Merge in federal poverty guidelines
	
	merge m:1 year hhsize using "$dir/data/psid/fed_pov_guidelines.dta", nogen keep(1 3)
	
	drop fpl
	gen fpl = .
	replace fpl = fpg_us48 if !inlist(state,2,15)
	replace fpl = fpg_ak if state == 2
	replace fpl = fpg_hi if state == 15
	drop fpg_*
	
	label variable fpl "Federal Poverty Guideline"
	label variable state "State of residence"

* Recode years of education	
		
	replace ed = . if ed == 98 | ed == 99

* Recode racial identification (note: some people change their self-reported race during their lives --> use modal report)
	
	gen race = .
	replace race = race_h_ if head == 1 & spouse == 0
	replace race = race_s_ if head == 0 & spouse == 1
	drop race_h_ race_s_
	
	gen hispanic = .
	replace hispanic = hispanic_head if head == 1 & spouse == 0
	replace hispanic = hispanic_spouse if head == 0 & spouse == 0
	drop hispanic_head hispanic_spouse
	
	replace hispanic = 1 if race == 5
	replace hispanic = 0 if missing(hispanic)
	
	gen nonwhite = race != 1
	
	gen white = race == 1 & hispanic != 1 
	gen black = race == 2 & hispanic != 1 
	gen aian = race == 3 & hispanic != 1
	gen asian = race == 4 & hispanic != 1
	gen otherrace = inlist(race,6,7,8,9)
	
	foreach v of varlist nonwhite white black aian asian otherrace {
		
		egen `v'_ = mode(`v'), by(id)
		rename (`v' `v'_) (`v'_ `v')
		drop `v'_
			
	}
	
	label variable race "Racial category"
	label variable hispanic "Hispanic (binary)"
	label variable nonwhite "Hispanic or nonwhite (binary)"
	label variable white "Non-Hispanic white (binary)"
	label variable black "Non-Hispanic black (binary)"
	label variable aian "Non-Hispanic native (binary)"
	label variable asian "Non-Hispanic Asian (binary)"
	label variable otherrace "Other race/ethnicity (binary)"
	
* Recode sex

	replace sex = . if sex == 9
	gen female = sex - 1
	drop sex
	
	label variable female "Female (binary)"
	
* Recode household weights

	gen one = (head | spouse) & (age >= 18 & age <= 65)
	
	bys famid year: egen num_obs = sum(one)
	replace wtfam = wtfam / num_obs
	drop one num_obs
	
	label variable wtfam "Adjusted family sample weights"
	label variable famid "Family identifier (current)"
	label variable famid_orig "Family identifier (original)"
	
* Recode any children indicator

	gen anychild = nchild > 0 if !missing(nchild)
	
	label variable anychild "Household has children (binary)"
	label variable nchild "Number of children in household"
	
* Recode disability status

	gen disabled = .
	replace disabled = disabled_head if head == 1 & spouse == 0
	replace disabled = disabled_spouse if head == 0 & spouse == 1
	drop disabled_head disabled_spouse
	
	replace disabled = . if disabled == 8 | disabled == 9
	replace disabled = 1 if disabled == 3 | emp == 5
	replace disabled = 0 if disabled == 5 | disabled == 7
	
	bys id: egen child_disabled_ = max(child_disabled)
	replace child_disabled = anychild * child_disabled_
	drop child_disabled_
	
	label variable disabled "Disabled (binary)"
	label variable child_disabled "Has disabled child (binary)"
	
* Recode health status

	gen health = .
	replace health = health_h if head == 1 & spouse == 0
	replace health = health_s if head == 0 & spouse == 1
	drop health_h health_s
	
	replace health = . if inlist(health,0,8,9)
	
	label variable health "Health status (categorical)"
		
* Recode immigration variables

	gen immsamp = (inrange(famid,10001,10444) & year==1997) | (inrange(famid,10001,10071) & year==1999) | inrange(ER33501,10001,10071)
	drop ER33501

	foreach v in yrus immstat naturalized regiongrewup {
		gen `v' = . 
		replace `v' = `v'_h if head == 1 & spouse == 0
		replace `v' = `v'_s if head == 0 & spouse == 0
	}
	drop yrus_* immstat_* naturalized_* regiongrewup_*
	
	gen foreign_ = .
	replace foreign_ = 0 if immsamp == 0
	replace foreign_ = 1 if immsamp == 1
	gegen foreign = max(foreign_), by(id)
	drop foreign_ immsamp
	
	replace yrus = . if yrus > 2019
	replace yrus = . if yrus == 0
	gegen yr_us = max(yrus), by(id)
	drop yrus
	
	gen citizen = 1-foreign
	replace citizen = 1 if naturalized == 1
	
	gen qualified_imm = citizen
	replace qualified_imm = 1 if inlist(immstat,1,9,10)
	
	label variable foreign "Born outside USA (binary)"
	label variable citizen "USA citizen (binary)"
	label variable naturalized "Naturalized USA citzen"
	label variable qualified_imm "Qualified immigrant under PRWORA"
	label variable immstat "Immigration status"
	label variable yr_us "Year arrived in USA"
	
* Recode employment status

	gen employ = inlist(emp,1,2) if !missing(emp) & !inlist(emp,8,9)
	label variable employ "Employed (binary)"
	drop emp
	
* Recode unemployment variables

	foreach v in why_unemploy wks_unemp {
		gen `v' = . 
		replace `v' = `v'_head if head == 1 & spouse == 0
		replace `v' = `v'_spouse if head == 0 & spouse == 0
	}
	drop why_unemploy_head why_unemploy_spouse wks_unemp_head wks_unemp_spouse
	
	label variable why_unemploy "Reason for unemployment"
	label variable wks_unemp "Weeks of unemployment"
	
* Merge in David Dorn harmonized occupation codes	

	* 1970 occ codes

	preserve
	keep if inlist(year,1997,1999,2001)
	
	rename occ_h occ
	merge m:1 occ using "$dir/data/crosswalks/occ1970_occ1990dd/occ1970_occ1990dd.dta", nogen keep(1 3)
	rename (occ occ1990dd) (occ_h occconst_h)
	
	rename occ_s occ
	merge m:1 occ using "$dir/data/crosswalks/occ1970_occ1990dd/occ1970_occ1990dd.dta", nogen keep(1 3)
	rename (occ occ1990dd) (occ_s occconst_s)
	
	tempfile dat_97_01
	save `dat_97_01', replace
	restore
	
	* 2000 occ codes
	
	preserve
	keep if inlist(year,2003,2005,2007,2009,2011,2013,2015)
	
	rename occ_h occ
	merge m:1 occ using "$dir/data/crosswalks/occ2000_occ1990dd/occ2000_occ1990dd.dta", nogen keep(1 3)
	rename (occ occ1990dd) (occ_h occconst_h)
	
	rename occ_s occ
	merge m:1 occ using "$dir/data/crosswalks/occ2000_occ1990dd/occ2000_occ1990dd.dta", nogen keep(1 3)
	rename (occ occ1990dd) (occ_s occconst_s)
	
	tempfile dat_03_15
	save `dat_03_15', replace
	restore
	
	* 2010 occ codes
	
	preserve
	keep if inlist(year,2017,2019)
	
	rename occ_h occ
	merge m:1 occ using "$dir/data/crosswalks/occ2010_occ1990dd/occ2010_occ1990dd.dta", nogen keep(1 3)
	rename (occ occ1990dd) (occ_h occconst_h)
	
	rename occ_s occ
	merge m:1 occ using "$dir/data/crosswalks/occ2010_occ1990dd/occ2010_occ1990dd.dta", nogen keep(1 3)
	rename (occ occ1990dd) (occ_s occconst_s)
	
	tempfile dat_17_19
	save `dat_17_19', replace
	restore
	
	* Reassemble data
	
	use `dat_97_01', clear
	append using `dat_03_15'
	append using `dat_17_19'
	
	replace occconst_h = 0 if occ_h == 0
	replace occconst_s = 0 if occ_s == 0
	
	replace occconst_h = 999 if !missing(occ_h) & missing(occconst_h)
	replace occconst_s = 999 if !missing(occ_s) & missing(occconst_s)
	
	drop occ_h occ_s
	
	label variable occconst_h "Occupation of head (harmonized)"
	label variable occconst_s "Occupation of spouse (harmonized)"
	
* Harmonize industry codes
	
	* 1970 ind codes
	
	preserve
	keep if inlist(year,1997,1999,2001)
	
	rename ind_h ind
	merge m:1 ind using "$dir/data/crosswalks/ind1970_ind1990.dta", nogen keep(1 3)
	rename (ind indconst) (ind_h indconst_h)
	
	rename ind_s ind
	merge m:1 ind using "$dir/data/crosswalks/ind1970_ind1990.dta", nogen keep(1 3)
	rename (ind indconst) (ind_s indconst_s)
	
	tempfile dat_97_01
	save `dat_97_01', replace
	restore
	
	* 2000 ind codes
	
	preserve
	keep if inlist(year,2003,2005,2007,2009,2011,2013,2015)
	
	rename ind_h ind
	replace ind = ind*10
	merge m:1 ind using "$dir/data/crosswalks/ind2000_ind1990.dta", nogen keep(1 3)
	rename (ind indconst) (ind_h indconst_h)
	
	rename ind_s ind
	replace ind = ind*10
	merge m:1 ind using "$dir/data/crosswalks/ind2000_ind1990.dta", nogen keep(1 3)
	rename (ind indconst) (ind_s indconst_s)
	
	replace ind_h = ind_h/10
	replace ind_s = ind_s/10
	
	tempfile dat_03_15
	save `dat_03_15', replace
	restore
		
	* 2010 ind codes
	
	preserve
	keep if year == 2017 | year == 2019
	
	rename ind_h ind
	merge m:1 ind using "$dir/data/crosswalks/ind2010_ind1990.dta", nogen keep(1 3)
	rename (ind indconst) (ind_h indconst_h)
	
	rename ind_s ind
	merge m:1 ind using "$dir/data/crosswalks/ind2010_ind1990.dta", nogen keep(1 3)
	rename (ind indconst) (ind_s indconst_s)
	
	tempfile dat_17_19
	save `dat_17_19', replace
	restore
	
	* Reassemble data
	
	use `dat_97_01', clear
	append using `dat_03_15'
	append using `dat_17_19'
	
	replace indconst_h = 0 if ind_h == 0
	replace indconst_s = 0 if ind_s == 0
	
	replace indconst_h = 999 if !missing(ind_h) & missing(indconst_h)
	replace indconst_s = 999 if !missing(ind_s) & missing(indconst_s)
	replace ind_h = 999 if ind_h == 9999
	replace ind_s = 999 if ind_s == 9999
	
	drop ind_s ind_h
	
	label variable indconst_h "Industry of head (harmonized)"
	label variable indconst_s "Industry of spouse (harmonized)"
	
* Recode employment variables

	gen weeks = weeks_h*head + weeks_s*spouse
	gen hours = hours_h*head + hours_s*spouse
	drop hours_h hours_s weeks_h weeks_s

	gen indconst = indconst_h*head + indconst_s*spouse
	gen occconst = occconst_h*head + occconst_s*spouse
	gen selfemp = selfemp_h*head + selfemp_s*spouse
	drop selfemp_h selfemp_s
	
	replace selfemp = 0 if inlist(selfemp,1,2,4,8,9)
	replace selfemp = 1 if inlist(selfemp,3)
	
	replace weeks = round(weeks)
	
	label variable indconst "Industry (harmonized)"
	label variable occconst "Occupation (harmonized)"
	label variable selfemp "Self-employed (binary)"
	label variable weeks "Weeks of work per year"
	label variable hours "Usual weekly hours of work"
	
* Recode education

	gen edcat = 0 
	replace edcat = 1 if ed >= 8
	replace edcat = 2 if ed >= 12
	replace edcat = 3 if ed >= 13
	replace edcat = 4 if ed == 16
	replace edcat = 5 if ed == 17
	
	rename ed edyears
	
	label variable edcat "Education level (categorical)"

* Create demographic group variables
* Identify cohort by minimum age

	gegen min_age = min(age), by(id)
	
	* Fix these in case of replicability issues in cohort assignment
	set seed 42
	set sortseed 8593
	
	gen cohort_ = year - age if age != 0 & age == min_age
	bys id: gegen cohort_ind = firstnm(cohort_)
	drop cohort_
	
	label variable cohort_ind "Birth year cohort"
	
* Recode health insurance indicators
	
	gen medicaid = 0
	gen healthins_priv = 0
	gen healthins_othpub = 0
	
	replace medicaid = 1 if med1 == 1 & year == 1997
	
	foreach v of varlist med1 med2 med3 med4 med5 med6 med7 {
		
		replace medicaid = 1 if `v' == 5 & year != 1997
		replace healthins_priv = 1 if (`v' == 1 | `v' == 2 | `v' == 4)
		replace healthins_othpub = 1 if `v' >= 3 & `v' <= 10
		
		drop `v'
		
	}

	foreach v of varlist medicaid healthins_priv healthins_othpub {
		
		bys famid year: gegen `v'_ = max(`v')
		replace `v' = `v'_
		drop `v'_
		
	}
	
	gen healthins_none = 1 - max(medicaid,healthins_priv,healthins_othpub)
	gen healthins_pubpriv = healthins_priv*max(medicaid,healthins_othpub)
	
	label variable medicaid "Receives Medicaid"
	label variable healthins_priv "Health insurance status, private"
	label variable healthins_othpub "Health insurance status, other public"
	label variable healthins_pubpriv "Health insurance status, public & private"
	label variable healthins_none "Health insurance status, uninsured"

* Recode TANF participation indicators

	replace tanf_head = . if tanf_head > 5
	replace tanf_head = 0 if tanf_head == 5
	
	replace tanf_spouse = . if tanf_spouse > 5
	replace tanf_spouse = 0 if tanf_spouse == 5
	
	gen tanf = .
	replace tanf = tanf_head if head == 1 & spouse == 0
	replace tanf = tanf_spouse if head == 0 & spouse == 1
	drop tanf_head tanf_spouse
	
	* Measure transfer receipt at household level
	gegen tanf_ = max(tanf) if !missing(tanf), by(famid year)
	drop tanf
	rename tanf_ tanf
	
	label variable tanf "TANF recipient (binary)"
	
* Recode TANF dollar amounts

	foreach v in head spouse {
	
		replace tanf_amt_`v' = . if tanf_amt_`v' >= 999997 | tanf_amt_`v' == 99998 | tanf_imp_`v' == 1
		
		* 52.1429 weeks in a year
		replace tanf_amt_`v' = 52.1429 * tanf_amt_`v' if tanf_unit_`v' == 3
		replace tanf_amt_`v' = (52.1429/2) * tanf_amt_`v' if tanf_unit_`v' == 4
		
		* 12 months in a year
		replace tanf_amt_`v' = 12 * tanf_amt_`v' if tanf_unit_`v' == 5
		
		replace tanf_amt_`v' = . if tanf_unit_`v' == 7 | tanf_unit_`v' == 8 | tanf_unit_`v' == 9
		
		drop tanf_unit_`v'
	
	}
	
	egen tanf_amt_hh = rowtotal(tanf_amt_head tanf_amt_spouse)
	replace tanf_amt_hh = 100 * tanf_amt_hh / (cpi*hhsize) if head == 1 | spouse == 1

	gegen tanf_amt_hh_ = max(tanf_amt_hh) if !missing(tanf_amt_hh), by(famid year)
	replace tanf_amt_hh = tanf_amt_hh_
	
	* Winsorize payments at 99th percentile (within > 0)
	* Note PSID instructions: "Beware of outliers. Analysts are urged to exclude or otherwise allow for cases in which the value is above the top 99 percentile point."
	quietly summ tanf_amt_hh if tanf_amt_hh > 0 [aw=wtfam], d
	replace tanf_amt_hh = r(p99) if tanf_amt_hh > r(p99) & !missing(tanf_amt_hh)
	
	drop tanf_amt_head tanf_amt_spouse tanf_imp_head tanf_imp_spouse tanf_amt_hh_
	
	label variable tanf_amt_hh "Per capita real annual value of TANF"
	
* Recode LIHEAP dollar amounts

	replace liheap_amt_hh = . if liheap_amt_hh >= 9998
	replace liheap_amt_hh = 12 * liheap_amt_hh if liheap_unit == 5
	
	replace liheap_amt_hh = 100 * liheap_amt_hh / (cpi*hhsize)
	replace liheap_amt_hh = . if head == 0 & spouse == 0
	
	gegen liheap_amt_hh_ = max(liheap_amt_hh) if !missing(liheap_amt_hh), by(famid year)
	replace liheap_amt_hh = liheap_amt_hh_
	
	drop liheap_unit liheap_amt_hh_
	
	label variable liheap_amt_hh "Per capita real annual value of LIHEAP"
	
* Recode WIC participation indicator

	replace wic = . if wic > 5
	replace wic = 0 if wic == 5
	
	* Measure transfer receipt at household level
	gegen wic_ = max(wic) if !missing(wic), by(famid year)
	drop wic
	rename wic_ wic
	
	label variable wic "WIC recipient (binary)"
	
* Recode LIHEAP participation indicator

	replace liheap = . if liheap > 5
	replace liheap = 0 if liheap == 5
	
	* Measure transfer receipt at household level
	gegen liheap_ = max(liheap) if !missing(liheap), by(famid year)
	drop liheap
	rename liheap_ liheap
	
	label variable liheap "LIHEAP recipient (binary)"
	
* Recode SNAP participation indicator
	
	replace snap = . if snap > 5
	replace snap = 0 if snap == 5
	
	* Measure transfer receipt at household level
	gegen snap_ = max(snap) if !missing(snap), by(famid year)
	drop snap
	rename snap_ snap
	
	label variable snap "SNAP recipient (binary)"
	
* Recode SNAP dollar amounts
	
	replace snap_amt_hh = . if snap_amt_hh >= 99998
	replace snap_amt_hh = . if snap_imp == 1
	
	replace snap_amt_hh = 52.1429 * snap_amt_hh if snap_unit == 3
	replace snap_amt_hh = (52.1429/2) * snap_amt_hh if snap_unit == 4
	replace snap_amt_hh = 12 * snap_amt_hh if snap_unit == 5
	replace snap_amt_hh = . if snap_unit == 7 | snap_unit == 8 | snap_unit == 9

	replace snap_amt_hh = 100 * snap_amt_hh / (cpi*hhsize)
	
	* Winsorize payments at 99th percentile (within > 0)
	quietly summ snap_amt_hh if snap_amt_hh > 0 [aw=wtfam], d
	replace snap_amt_hh = r(p99) if snap_amt_hh > r(p99) & !missing(snap_amt_hh)
	
	drop snap_unit
	
	gegen snap_amt_hh_ = max(snap_amt_hh), by(famid year)
	replace snap_amt_hh = snap_amt_hh_
	drop snap_amt_hh_
	
	label variable snap_amt_hh "Per capita real annual value of SNAP"
	label variable snap_imp "SNAP receipt imputation flag"
	
* Recode SSI participation indicators

	replace ssi_hh = . if ssi_hh > 5
	replace ssi_hh = 1 if ssi_hh > 1 & !missing(ssi_hh)
		
	* Measure transfer receipt at household level
	gegen ssi = max(ssi_hh) if !missing(ssi_hh), by(famid year)
	drop ssi_hh
	
	label variable ssi "SSI recipient (binary)"
	
* Recode SSI dollar amounts

	foreach v in head spouse {

		replace ssi_amt_`v' = . if ssi_amt_`v' >= 999998 | ssi_imp_`v' == 1
		
		replace ssi_amt_`v' = 52.1429 * ssi_amt_`v' if ssi_unit_`v' == 3
		replace ssi_amt_`v' = (52.1429/2) * ssi_amt_`v' if ssi_unit_`v' == 4
		replace ssi_amt_`v' = 12 * ssi_amt_`v' if ssi_unit_`v' == 5
		replace ssi_amt_`v' = . if ssi_unit_`v' == 7 | ssi_unit_`v' == 8 | ssi_unit_`v' == 9
		
		drop ssi_unit_`v'
		
		replace ssi_amt_`v' = 100 * ssi_amt_`v' / cpi
			
	}
	
	egen ssi_amt_hh = rowtotal(ssi_amt_head ssi_amt_spouse) 
	replace ssi_amt_hh = ssi_amt_hh / hhsize
	
	gegen ssi_amt_hh_ = max(ssi_amt_hh), by(famid year)
	replace ssi_amt_hh = ssi_amt_hh_
	drop ssi_amt_hh_
	
	* Winsorize payments at 99th percentile (within > 0)
	quietly summ ssi_amt_hh if ssi_amt_hh > 0 [aw=wtfam], d
	replace ssi_amt_hh = r(p99) if ssi_amt_hh > r(p99) & !missing(ssi_amt_hh)
	
	drop ssi_amt_head ssi_amt_spouse ssi_imp_head ssi_imp_spouse
	
	label variable ssi_amt_hh "Per capita real annual value of SSI"
	
* Recode public housing indicator

	gen pubhousing = 0
	replace pubhousing = 1 if ph1 == 1 | ph2 == 1
	drop ph1 ph2
	
	gegen pubhousing_ = max(pubhousing) if !missing(pubhousing), by(famid year)
	drop pubhousing
	rename pubhousing_ pubhousing
	
	label variable pubhousing "Public housing recipient (binary)"

* Recode UI into indicator
	
	replace ui_head = 0 if ui_head == 5
	replace ui_head = . if ui_head > 5
	
	replace ui_spouse = 0 if ui_spouse == 5
	replace ui_spouse = . if ui_spouse > 5
	
	gen ui = .
	replace ui = ui_head if head == 1 & spouse == 0
	replace ui = ui_spouse if head == 0 & spouse == 1
	drop ui_head ui_spouse
	
	* Measure transfer receipt at household level
	gegen ui_ = max(ui) if !missing(ui), by(famid year)
	drop ui
	rename ui_ ui
	
	label variable ui "Unemployment insurance recipient (binary)"
	
* Recode UI dollar amounts

	foreach v in head spouse {

		replace ui_amt_`v' = . if ui_amt_`v' >= 99998
		
		replace ui_amt_`v' = 52.1429 * ui_amt_`v' if ui_unit_`v' == 3
		replace ui_amt_`v' = (52.1429/2) * ui_amt_`v' if ui_unit_`v' == 4
		replace ui_amt_`v' = 12 * ui_amt_`v' if ui_unit_`v' == 5
		replace ui_amt_`v' = . if ui_unit_`v' == 7 | ui_unit_`v' == 8 | ui_unit_`v' == 9
		
		replace ui_amt_`v' = 100 * ui_amt_`v' / cpi 
			
		drop ui_unit_`v'
	
	}
	
	egen ui_amt_hh = rowtotal(ui_amt_head ui_amt_spouse) 
	replace ui_amt_hh = ui_amt_hh / hhsize
	
	gegen ui_amt_hh_ = max(ui_amt_hh) if !missing(ui_amt_hh), by(famid year)
	drop ui_amt_hh
	rename ui_amt_hh_ ui_amt_hh
	
	* Winsorize UI payments at 99th percentile (within > 0)
	quietly summ ui_amt_hh if ui_amt_hh > 0 [aw=wtfam], d
	replace ui_amt_hh = r(p99) if ui_amt_hh > r(p99) & !missing(ui_amt_hh)
	
	drop ui_amt_head ui_amt_spouse
	
	label variable ui_amt_hh "Per capita real annual value of SSI"
	
* Recode worker's compensation

	replace wc_rec_h_ = 0 if inlist(wc_rec_h_,5)
	replace wc_rec_s_ = 0 if inlist(wc_rec_s_,5)
	
	replace wc_rec_h_ = . if inlist(wc_rec_h_,8,9)
	replace wc_rec_s_ = . if inlist(wc_rec_s_,8,9)
	
	gen wc = wc_rec_h_*head + wc_rec_s_*spouse if head == 1 | spouse == 1
	drop wc_rec_h_ wc_rec_s_
	
	* Measure transfer receipt at household level
	gegen wc_ = max(wc) if !missing(wc), by(famid year)
	drop wc
	rename wc_ wc
	
	foreach v in h s {
		
		replace wc_amt_`v' = 52.1429 * wc_amt_`v' if wc_freq_`v' == 3
		replace wc_amt_`v' = (52.1429/2) * wc_amt_`v' if wc_freq_`v' == 4
		replace wc_amt_`v' = 12 * wc_amt_`v' if wc_freq_`v' == 5
		replace wc_amt_`v' = . if wc_freq_`v' == 7 | wc_freq_`v' == 8 | wc_freq_`v' == 9
		
		replace wc_amt_`v' = 100 * wc_amt_`v' / cpi 
		
		drop wc_freq_`v'
		
	}
	
	egen wc_amt_hh = rowtotal(wc_amt_h_ wc_amt_s_) 
	replace wc_amt_hh = wc_amt_hh / hhsize
	
	gegen wc_amt_hh_ = max(wc_amt_hh) if !missing(wc_amt_hh), by(famid year)
	drop wc_amt_hh
	rename wc_amt_hh_ wc_amt_hh
	
	* Winsorize transfer payments at 99th percentile (within > 0)
	quietly summ wc_amt_hh if wc_amt_hh > 0 [aw=wtfam], d
	replace wc_amt_hh = r(p99) if wc_amt_hh > r(p99) & !missing(wc_amt_hh)
	
	drop wc_amt_h_ wc_amt_s_
	
	label variable wc "Worker's Comp recipient (binary)"
	label variable wc_amt_hh "Per capita real annual value of Worker's Comp'"
	
* Recode Social Security

	foreach v in h s {
		replace ss_amt_`v' = 100 * ss_amt_`v' / cpi
	}
	
	egen ss_amt_hh = rowtotal(ss_amt_h_ ss_amt_s_) 
	replace ss_amt_hh = ss_amt_hh / hhsize
	
	gegen ss_amt_hh_ = max(ss_amt_hh) if !missing(ss_amt_hh), by(famid year)
	drop ss_amt_hh
	rename ss_amt_hh_ ss_amt_hh
	
	quietly summ ss_amt_hh if ss_amt_hh > 0 [aw=wtfam], d
	replace ss_amt_hh = r(p99) if ss_amt_hh > r(p99) & !missing(ss_amt_hh)
	
	drop ss_amt_h_ ss_amt_s_
	
	gen ss = ss_amt_hh > 0 if !missing(ss_amt_hh)
	
	label variable ss "Social Security recipient (binary)"
	label variable ss_amt_hh "Per capita real annual value of Social Security"
	
* Recode school meals

	replace schoolbfast = 0 if schoolbfast==5
	replace schoolbfast = . if inlist(schoolbfast,8,9)
	
	replace schoollunch = 0 if schoollunch==5
	replace schoollunch = . if inlist(schoollunch,8,9)
	
	replace schoolmeals = max(schoollunch,schoolbfast) if missing(schoolmeals)
	replace schoolmeals = 1 if inlist(schoolmeals,2,3)
	replace schoolmeals = 0 if schoolmeals == 5
	replace schoolmeals = . if inlist(schoolmeals,8,9)
	drop schoolbfast schoollunch
	
	label variable schoolmeals "Receives school breakfast or lunch (binary)"
	
* Recode rent subsidy / housing assistance indicators

	gen rent_subsidy = (rent_subsidy_part==1) | (rent_subsidy_full==1)
	gegen rent_subsidy_ = max(rent_subsidy) if !missing(rent_subsidy), by(famid year)
	drop rent_subsidy
	rename rent_subsidy_ rent_subsidy
	
	gen housing_assistance = max(rent_subsidy,pubhousing)
	drop rent_subsidy_part rent_subsidy_full
	
	gegen housing_assistance_ = max(housing_assistance) if !missing(housing_assistance), by(famid year)
	drop housing_assistance
	rename housing_assistance_ housing_assistance
	
	label variable rent_subsidy "Receives rent subsidies (binary)"
	label variable housing_assistance "Receives public housing or rent subsidy (binary)"
	
* Recode food security (monthly and annual)

	rename foodsecy foodsec
	rename fsecmon#_ fsecmon#
	
	forvalues m = 1/12 {
		replace fsecmon`m' = . if fsecmon`m' == 9
		label variable fsecmon`m' "Food security (month `m')"
	}
		
* Recode other welfare variables

	* Measure transfer receipt at household level
	gen othwelf = .
	replace othwelf = othwelf_head if head == 1 & spouse == 0
	replace othwelf = othwelf_spouse if head == 0 & spouse == 1
	gegen othwelf_ = max(othwelf) if !missing(othwelf), by(famid year)
	drop othwelf
	rename othwelf_ othwelf
	
	foreach v in head spouse {
	
		replace othwelf_amt_`v' = . if othwelf_imp_`v' == 1
		
		replace othwelf_amt_`v' = 52.1429 * othwelf_amt_`v' if othwelf_unit_`v' == 3
		replace othwelf_amt_`v' = (52.1429/2) * othwelf_amt_`v' if othwelf_unit_`v' == 4
		replace othwelf_amt_`v' = 12 * othwelf_amt_`v' if othwelf_unit_`v' == 5
		replace othwelf_amt_`v' = . if othwelf_unit_`v' == 7 | othwelf_unit_`v' == 8 | othwelf_unit_`v' == 9
	
	}
		
	egen othwelf_amt_hh = rowtotal(othwelf_amt_head othwelf_amt_spouse) 
	replace othwelf_amt_hh = 100*othwelf_amt_hh / cpi if head == 1 | spouse == 1
	
	* Winsorize UI payments at 99th percentile (within > 0)
	quietly summ othwelf_amt_hh if othwelf_amt_hh > 0 [aw=wtfam], d
	replace othwelf_amt_hh = r(p99) if othwelf_amt_hh > r(p99) & !missing(othwelf_amt_hh)
	
	drop othwelf_head othwelf_amt_head othwelf_amt_spouse othwelf_spouse othwelf_imp_spouse othwelf_imp_head othwelf_unit_head othwelf_unit_spouse
	
	label variable othwelf "Receives other transfers"
	label variable othwelf_amt_hh "Per capital real annual value of other transfers"
	
* Recode monthly transfers

	rename (snap_m*_ tanf_s_m*_ tanf_h_m*_ ssi_s_m*_ ssi_h_m*_) (snap_m* tanf_s_m* tanf_h_m* ssi_s_m* ssi_h_m*)
	
	foreach v of varlist snap_m* tanf_s_m* tanf_h_m* ssi_s_m* ssi_h_m* {
		replace `v' = . if !inlist(`v',0,1)
	}
	
	forvalues t = 1/12 {
		
		gen tanf_m`t' = max(tanf_h_m`t',tanf_s_m`t')
		gen ssi_m`t' = max(ssi_h_m`t',ssi_s_m`t')
		
		label variable snap_m`t' "Receives SNAP (month `t')"
		label variable tanf_m`t' "Receives TANF (month `t')"
		label variable ssi_m`t' "Receives SSI (month `t')"
		
	}
	
	drop tanf_h_m* tanf_s_m* ssi_h_m* ssi_s_m*
	
	foreach x in snap ssi tanf {
		gegen `x'_months = rowtotal(`x'_m*)
	}
	
	label variable snap_months "Months of SNAP received"
	label variable ssi_months "Months of SSI received"
	label variable tanf_months "Months of TANF received"
	
* Recode transfer program application variables	

	foreach v of varlist applied_* {
		replace `v' = . if `v' == 8 | `v' == 9
	}
	
	foreach p in tanf ssi wic liheap medicaid snap ha ui {
		gen denied_`p' = appstatus_`p' == 5 if inlist(appstatus_`p',1,5)
	}
	
	drop appstatus_*
	
* Drop wealth levels if imputed

	replace whome = . if whome_imp == 1
	replace woth = . if woth_imp == 1
	
	drop whome_imp woth_imp
	
* Parent variables

	replace grewuppoor_h = . if grewuppoor_h == 9
	replace grewuppoor_s = . if grewuppoor_s == 9
	
	gen grewuppoor = grewuppoor_h*head + grewuppoor_s*spouse if head==1 | spouse==1
	drop grewuppoor_h grewuppoor_s
	
	replace grewup = . if grewup == 0
	
	replace educ_m_head = . if inlist(educ_m_head,0,99)
	replace educ_f_head = . if inlist(educ_f_head,0,99)
	replace educ_f_spouse = . if inlist(educ_f_spouse,0,99)
	replace educ_m_spouse = . if inlist(educ_m_spouse,0,99)
	replace educ_f_head = . if educ_f_head == 12
	
	foreach v in educ_m educ_f {
		gen `v' = . 
		replace `v' = `v'_head if head == 1 & spouse == 0
		replace `v' = `v'_spouse if head == 0 & spouse == 0
	}
	drop educ_m_head educ_m_spouse educ_f_head educ_f_spouse
	
* Check for continuous employment within couple

	gegen employ_head = max(employ*head), by(famid year)
	gegen has_spouse = max(spouse), by(famid year)
	gegen employ_spouse = max(employ*spouse), by(famid year)

	gen cts_employment = .
		
		* If employed head and spouse at current positions for 2+ years
		replace cts_employment = (js_year_h <= year - 2) & (js_year_s <= year - 2) if (js_year_h > 0 & js_year_h <= year & js_year_s > 0 & js_year_s <= year & employ_head == 1 & employ_spouse == 1)
		
		* If no spouse and head employed for 2+ years
		replace cts_employment = (js_year_h <= year - 2) if (js_year_h > 0 & js_year_h <= year & employ_head == 1 & has_spouse == 0)
		
		* If no spouse and head not employed for 2+ years
		replace cts_employment = (je_year_h <= year - 2) if (je_year_h > 0 & je_year_h <= year & employ_head == 0 & has_spouse == 0)
		
		* If employed head and nonemployed spouse at current position for 2+ years
		replace cts_employment = (js_year_h <= year - 2) & (je_year_s <= year - 2) if (js_year_h > 0 & js_year_h <= year & je_year_s > 0 & je_year_s <= year & employ_head == 1 & employ_spouse == 0 & has_spouse == 1)
		
		* If nonemployed head and employed spouse at current position for 2+ years
		replace cts_employment = (js_year_s <= year - 2) & (je_year_h <= year - 2) if (js_year_s > 0 & js_year_s <= year & je_year_h > 0 & je_year_h <= year & employ_spouse == 1 & employ_head == 0 & has_spouse == 1)
		
		* If nonemployed head and nonemployed spouse for 2+ years
		replace cts_employment = (je_year_h <= year - 2) & (je_year_s <= year - 2) if (je_year_h > 0 & js_year_h <= year & je_year_s > 0 & je_year_s <= year & employ_head == 0 & employ_spouse == 0 & has_spouse == 1)
		
		drop employ_head employ_spouse has_spouse je_* js_*
		
		label variable cts_employment "Continuously employed for 2+ years"

* Recode consumer durables

	gen smartphone = .
	replace smartphone = 1 if smartphone_h == 1 | smartphone_s == 1
	replace smartphone = 0 if smartphone_h == 5 & (smartphone_s == 5 | smartphone_s == 0)
	drop smartphone_h smartphone_s
	label variable smartphone "Owns a smartphone"
	
	gen computer = .
	replace computer = 1 if computer_h == 1 | computer_s == 1
	replace computer = 0 if computer_h == 5 & (computer_s == 5 | computer_s == 0)
	drop computer_h computer_s
	label variable computer "Owns a computer"
	
	replace aircond = 0 if aircond == 5
	replace aircond = . if aircond == 8 | aircond == 9
	label variable aircond "Home is air-conditioned"
	
	replace ownhome = 0 if ownhome == 5 | ownhome == 8
	replace ownhome = . if ownhome == 9
	label variable ownhome "Owns home"
	
	replace rooms = . if rooms == 98 | rooms == 99
	label variable rooms "Number of rooms in home"
	
	gen owncar = .
	replace owncar = 0 if inlist(veh1_howacq,0,2) | inlist(veh2_howacq,0,2) | inlist(veh3_howacq,0,2)
	replace owncar = 1 if inlist(veh1_howacq,1,3,7) | inlist(veh2_howacq,1,3,7) | inlist(veh3_howacq,1,3,7)
	label variable owncar "Owns a vehicle"
	
* Impute house value if missing	
	
	replace houseval = . if houseval == 9999999 | houseval == 9999998
	replace houseval = 50000 if missing(houseval) & hval25_ == 1 & hval75_ == 5
	replace houseval = 87500 if missing(houseval) & hval75_ == 1 & hval100_ == 5
	replace houseval = 150000 if missing(houseval) & hval100_ == 1 & hval200_ == 5
	replace houseval = 300000 if missing(houseval) & hval200_ == 1 & hval400_ == 5
	replace houseval = 300000 if missing(houseval) & hval200_ == 1 & hval400_ == 5
	
	summ houseval [aw=wtfam] if houseval > 400000
	replace houseval = round(r(mean)) if missing(houseval) &  hval400_ == 1
	
	summ houseval [aw=wtfam]
	replace houseval = round(r(mean)) if missing(houseval) & ownhome==1
	
	drop hval*_
	
	label variable houseval "Value of house (owned or rented)"
	
* Annualize rent expenditure

foreach v in rent equivrent {

	replace `v' = 52.1429 * `v' if `v'_unit == 3
	replace `v' = (52.1429/2) * `v' if `v'_unit == 4
	replace `v' = 12 * `v' if `v'_unit == 5
	replace `v' = . if `v'_unit == 7 | `v'_unit == 8 | `v'_unit == 9
		
	drop `v'_unit
	
}

label variable rent "Annualized rent expenditure" 	
	
* Impute missing owner's equivalent rent from house values	
	
	replace oer = . if oer < 0
		
	reg oer houseval c.houseval#c.houseval if ownhome==1 [pw=wtfam]
	predict oer_pred, xb
	replace oer = oer_pred if missing(oer) & ownhome==1
	drop oer_pred
	
	replace oer = rent if rent != 0 & !missing(rent)
			
	replace oer = equivrent if (missing(oer) | oer == 0) & equivrent != 0 & !missing(equivrent)
	drop equivrent
	
	* Replace outlier estimates of OER with housing expenditure
	local thresh = 500000
	replace oer = mortgage_exp + proptax_exp if !missing(oer) & oer > `thresh'
	
	label variable oer "Annualized owner's equivalent rent expenditure" 	

* Impute equivalent lease cost for vehicles

	preserve
	
	* Reshape into vehicle-level dataset
	keep veh*_manuf veh*_make veh*_model veh*_type veh*_howacq veh*_yearacq veh*_price veh*_leaseamt veh*_leasefreq id year wtfam
	reshape long veh@_manuf veh@_make veh@_model veh@_type veh@_howacq veh@_yearacq veh@_price veh@_leaseamt veh@_leasefreq, i(id year wtfam) j(vehnum)
	
	* Address nonresponses / misreponse
	
	replace veh_price = . if veh_price == 0 | veh_price >= 999998
	replace veh_leaseamt = . if veh_leaseamt == 0 | veh_leaseamt>=999998
	
	replace veh_model = . if veh_model >= 9997 | veh_model == 0
	
	gen veh_ageatacq = veh_yearacq - veh_model
	replace veh_ageatacq = . if veh_ageatacq<-1
	replace veh_ageatacq = 0 if veh_ageatacq==-1
	
	* Adjust for frequency of lease payments
	replace veh_leaseamt = 52*veh_leaseamt if veh_leasefreq == 3
	replace veh_leaseamt = 26*veh_leaseamt if veh_leasefreq == 4
	replace veh_leaseamt = 12*veh_leaseamt if veh_leasefreq == 5
	replace veh_leaseamt = . if veh_leasefreq == 7 | veh_leasefreq == 8 | veh_leasefreq == 9
	
	* Trim outliers
	
	summ veh_price [aw=wtfam], d
	replace veh_price = max(r(p1),veh_price) if !missing(veh_price)
	replace veh_price = min(r(p99),veh_price) if !missing(veh_price)
	
	summ veh_leaseamt [aw=wtfam], d
	replace veh_leaseamt = max(r(p1),veh_leaseamt) if !missing(veh_leaseamt)
	replace veh_leaseamt = min(r(p99),veh_leaseamt) if !missing(veh_leaseamt)
	
	* Predict price at purchase and lease amounts
	
	ppmlhdfe veh_price if veh_howacq==1 [pw=wtfam], a(year vehnum veh_ageatacq#veh_manuf veh_manuf#veh_make veh_manuf#veh_type veh_type#veh_make) d
	predict veh_price_pred, mu
	
	ppmlhdfe veh_leaseamt if veh_howacq==2 [pw=wtfam], a(year vehnum veh_ageatacq#veh_manuf veh_manuf#veh_make veh_manuf#veh_type veh_type#veh_make) d
	predict veh_leaseamt_pred, mu

	* Collapse to cells
	gcollapse (rawsum) wtfam (mean) veh_price_pred veh_leaseamt_pred veh_leaseamt [aw=wtfam], by(year vehnum veh_manuf veh_make veh_type veh_ageatacq)
	
	* Run lease-conversion regression
	reg veh_leaseamt_pred veh_price_pred c.veh_price_pred#c.veh_price_pred [aw=wtfam]
	predict veh_leaseamt_pred_
	
	gen veh_leaseval = veh_leaseamt 
	replace veh_leaseval = veh_leaseamt_pred_ if missing(veh_leaseval)
	
	* Save lease value dataset
	keep year vehnum veh_manuf veh_make veh_type veh_ageatacq veh_leaseval
	gen t = _n
	
	reshape wide veh@_manuf veh@_make veh@_type veh@_ageatacq veh@_leaseval, i(t) j(vehnum)
	drop t
	drop if missing(veh1_leaseval) & missing(veh2_leaseval) & missing(veh3_leaseval)
	
	tempfile veh_leaseval
	save `veh_leaseval', replace
	
	forvalues i = 1/3 {
	
	use `veh_leaseval', clear
	keep veh`i'_manuf veh`i'_make veh`i'_type veh`i'_ageatacq veh`i'_leaseval year
	drop if missing(veh`i'_manuf)
	tempfile veh`i'_leaseval
	save `veh`i'_leaseval', replace
	
	}
	
	restore
	
	* Merge into data
	
	forvalues i = 1/3 {
		
		gen veh`i'_ageatacq = veh`i'_yearacq - veh`i'_model
		replace veh`i'_ageatacq = . if veh`i'_ageatacq<-1
		replace veh`i'_ageatacq = 0 if veh`i'_ageatacq==-1
		
		merge m:1 veh`i'_manuf veh`i'_make veh`i'_type veh`i'_ageatacq year using `veh`i'_leaseval', nogen keep(1 3)
		
	}
	
* Recode sources of capital income

	foreach p in rent div int trust {
	foreach v in h s {

		replace `p'_`v'_amt = . if `p'_`v'_amt >= 999998
		
		replace `p'_`v'_amt = 52.1429 * `p'_`v'_amt if `p'_`v'_unit == 3
		replace `p'_`v'_amt = (52.1429/2) * `p'_`v'_amt if `p'_`v'_unit == 4
		replace `p'_`v'_amt = 12 * `p'_`v'_amt if `p'_`v'_unit == 5
		replace `p'_`v'_amt = . if `p'_`v'_unit == 7 | `p'_`v'_unit == 8 | `p'_`v'_unit == 9
		
		drop `p'_`v'_unit
			
	}
	
	gen `p'_amt = 100*(`p'_h_amt*head + `p'_s_amt*spouse) / cpi if head == 1 | spouse == 1
	egen `p'_amt_hh = rowtotal(`p'_h_amt `p'_s_amt) if head == 1 | spouse == 1
	replace `p'_amt_hh = 100 * `p'_amt_hh / cpi
	
	drop `p'_h_amt `p'_s_amt
	
	}
		
* Recode other sources of income
	
	* Farm income
	rename farminc farminc_hh
	replace farminc_hh = 100 * farminc_hh / cpi if head == 1 | spouse == 1
	replace farminc_hh = . if head == 0 & spouse == 0
	label variable farminc_hh "Per capita real annualized value of farm income"
	
	* Apportion farm income equally across adults in HH
	gen farminc = farminc_hh / (hhsize-nchild)
	
	* Asset component of business income
	
	foreach v of varlist assetincbus_h assetincbus_s {
		replace `v' = . if `v' == 9999999 | `v' == -999999
		replace `v' = 100 * `v' / cpi
	}
	
	gen assetincbus = assetincbus_h*head + assetincbus_s*spouse if head == 1 | spouse == 1
	replace assetincbus = . if  head == 0 & spouse == 0
	egen assetincbus_hh = rowtotal(assetincbus_h assetincbus_s) if head == 1 | spouse == 1
	
	gen laborincbus = laborincbus_h*head + laborincbus_s*spouse if head == 1 | spouse == 1
	replace laborincbus = . if  head == 0 & spouse == 0
	egen laborincbus_hh = rowtotal(laborincbus_h laborincbus_s) if head == 1 | spouse == 1
	
	replace laborincbus = 100 * laborincbus / cpi
	replace laborincbus_hh = 100 * laborincbus_hh / cpi

* Recode expenditure variables

	replace gasoline_exp = . if gasoline_exp == 99998 | gasoline_exp == 99999
	
	foreach v of varlist 	food_exp oer rent housing_exp utility_exp trans_exp educ_exp furniture_exp ///
							childcare_exp health_exp computer_exp clothing_exp travel_exp rec_exp mortgage_exp proptax_exp ///
							veh_ins_exp veh_rep_exp parking_exp bustrain_exp taxi_exp othtrans_exp gasoline_exp vehadd_exp veh*_leaseval {
								
		replace `v' = 0 if `v' < 0
		replace `v' = 100*`v' / cpi
		replace `v' = . if head != 1 & spouse != 1
		
	}		
	egen trans_cons = rowtotal(veh_ins_exp veh_rep_exp parking_exp bustrain_exp taxi_exp othtrans_exp gasoline_exp vehadd_exp veh1_leaseval veh2_leaseval veh3_leaseval)
	replace trans_cons = trans_exp if missing(trans_cons)
	replace trans_cons = . if missing(trans_exp)
	drop veh_ins_exp veh_rep_exp parking_exp bustrain_exp taxi_exp othtrans_exp vehadd_exp
	
	egen consumption_real = rowtotal(food_exp oer utility_exp furniture_exp trans_cons educ_exp childcare_exp health_exp computer_exp clothing_exp travel_exp rec_exp)
	replace consumption_real = . if missing(food_exp) & missing(oer) & missing(utility_exp) & missing(trans_cons) & missing(educ_exp) & missing(childcare_exp) & missing(health_exp) & missing(computer_exp) & missing(clothing_exp) & missing(travel_exp) & missing(rec_exp) & missing(furniture_exp)
	
	gen consumption_nom = consumption_real * cpi / 100
	
	egen veh_leaseval_exp = rowtotal(veh1_leaseval veh2_leaseval veh3_leaseval)
	drop veh1_* veh2_* veh3_*
	
	label variable gasoline_exp "Real household gasoline expenditure"
	label variable utility_exp "Real household utilty expenditure"
	label variable foodathome_exp "Real household expenditure on food at home"
	label variable housing_exp "Real household expenditure on housing"
	label variable consumption_real "Household consumption (real)"
	label variable consumption_nom "Household consumption (nominal)"
	label variable veh_leaseval_exp "Lease cost equivalent of vehicles"
	label variable health_exp "Real household health expenditure"
	
* Recode wealth	variables
	
	foreach v of varlist wcar wsav whome woth {
		
		replace `v' = . if `v' == 999999998 | `v' == 999999999
		
		replace `v' = 0 if `v' < 0
		replace `v' = . if head != 1 & spouse != 1
		
		gen `v'_real = 100*`v' / cpi 
		rename `v' `v'_nom
		
	}
	
	label variable wcar_nom "Wealth in vehicles (nominal)"
	label variable wcar_real "Wealth in vehicles (real)"
	label variable wsav_nom "Wealth in savings (nominal)"
	label variable wsav_real "Wealth in savings (real)"
	label variable whome_nom "Wealth in home (nominal)"
	label variable whome_real "Wealth in home (real)"
	label variable woth_nom "Wealth in other (non-home non-car) assets (nominal)"
	label variable woth_real "Wealth in other (non-home non-car) assets (real)"
	
* Recode years of birth to ages

	gen age_eldest = year - yob_eldest if !missing(yob_eldest) & year >= yob_eldest
	gen age_youngest = year - yob_youngest if !missing(yob_youngest) & year >= yob_youngest
	gen age_2ndyoungest = year - yob_2ndyoungest if !missing(yob_2ndyoungest) & year >= yob_2ndyoungest
	gen age_3rdyoungest = year - yob_3rdyoungest if !missing(yob_3rdyoungest) & year >= yob_3rdyoungest
	gen age_4thyoungest = year - yob_4thyoungest if !missing(yob_4thyoungest) & year >= yob_4thyoungest
	
	drop yob_*
	
	label variable age_eldest "Age of eldest child"
	label variable age_youngest "Age of youngest child"
	
* Code WIC amount (this should be moved to another file, temporary here XXX)	

	gen wic_num_recipients = 0
	replace wic_num_recipients = wic * ((age_youngest<=1) + (age_eldest<=4) + (age_youngest<=4) + (age_2ndyoungest<=4) + (age_3rdyoungest<=4) + (age_4thyoungest<=4))
	drop age_2ndyoungest age_3rdyoungest age_4thyoungest

	* Note: Use monthly national average WIC benefits from https://fns-prod.azureedge.net/sites/default/files/resource-files/wisummary-1.pdf
	
	gen wic_amt_hh = .
	replace wic_amt_hh = 100*12*31.68*wic_num_recipients / (cpi*hhsize) if year == 1997
	replace wic_amt_hh = 100*12*32.50*wic_num_recipients / (cpi*hhsize) if year == 1999
	replace wic_amt_hh = 100*12*34.31*wic_num_recipients / (cpi*hhsize) if year == 2001
	replace wic_amt_hh = 100*12*35.28*wic_num_recipients / (cpi*hhsize) if year == 2003
	replace wic_amt_hh = 100*12*37.42*wic_num_recipients / (cpi*hhsize) if year == 2005
	replace wic_amt_hh = 100*12*39.04*wic_num_recipients / (cpi*hhsize) if year == 2007
	replace wic_amt_hh = 100*12*42.40*wic_num_recipients / (cpi*hhsize) if year == 2009
	replace wic_amt_hh = 100*12*46.69*wic_num_recipients / (cpi*hhsize) if year == 2011
	replace wic_amt_hh = 100*12*43.26*wic_num_recipients / (cpi*hhsize) if year == 2013
	replace wic_amt_hh = 100*12*43.37*wic_num_recipients / (cpi*hhsize) if year == 2015
	replace wic_amt_hh = 100*12*41.24*wic_num_recipients / (cpi*hhsize) if year == 2017
	replace wic_amt_hh = 100*12*40.90*wic_num_recipients / (cpi*hhsize) if year == 2019
	drop wic_num_recipients
	
	label variable wic_amt_hh "Per capita real annual value of WIC"
	
* Merge in CPS imputations for values of Medicaid, public housing, rent subsidies, school lunch

	merge m:1 hhsize year using "$dir/data/cps/cps_imputation", nogen keep(1 3)
	
	replace medicaid_amt_hh = 100*medicaid_amt_hh*medicaid / (cpi*hhsize)
	replace rent_subsidy_amt_hh = 100*rent_subsidy_amt_hh*rent_subsidy / (cpi*hhsize)
	replace pubhou_amt_hh = 100*pubhou_amt_hh*pubhousing / (cpi*hhsize)
	gen schoolmeals_amt_hh = 100*spmlunch_amt_hh*schoolmeals / (cpi*hhsize)
	drop spmlunch_amt_hh
	
	egen housing_assistance_amt_hh = rowtotal(pubhou_amt_hh rent_subsidy_amt_hh)
	
	label variable schoolmeals_amt_hh "Imputed per capita annual value of school meals"
	label variable housing_assistance_amt_hh "Imputed per capita annual value of housing assistance"
	
* Calculate total assistance value

	egen tot_amt_hh = rowtotal(liheap_amt_hh snap_amt_hh tanf_amt_hh ssi_amt_hh wic_amt_hh pubhou_amt_hh rent_subsidy_amt_hh medicaid_amt_hh schoolmeals_amt_hh)
	egen cash_amt_hh = rowtotal(liheap_amt_hh snap_amt_hh tanf_amt_hh ssi_amt_hh)
	
	label variable tot_amt_hh "Total per capita annual value of transfers"
	label variable cash_amt_hh "Total per capita annual value of cash transfers"

* Clean earnings and income

	foreach person in h s {
		
		replace earnings_`person'_= . if earnings_`person'_== 9999999
		replace earnings_`person'_ = . if earnings_`person'_imp != 0
		
	}

	gen earnings = .
	replace earnings = earnings_h_ if head == 1 & spouse == 0
	replace earnings = earnings_s_ if head == 0 & spouse == 1

	egen income = rowtotal(earnings rent_amt div_amt int_amt trust_amt assetincbus laborincbus farminc)
	replace income = 0 if income < 0
	
	egen famearn = rowtotal(earnings_h_ earnings_s_)
	replace faminc = 0 if faminc < 0

	gen faminct = faminct_hs + faminct_oth
	replace faminct = 0 if faminct < 0

	foreach v of varlist earnings income famearn faminc faminct {
	
		replace `v' = 0 if missing(`v') & !missing(age) & age >= 18 & age <= 65
		replace `v' = . if age < 18 | age > 65 | missing(age)
		
		gen `v'_real = 100 * `v' / cpi
		rename `v' `v'_nominal
		
	}
	
	drop earnings_h_ earnings_h_imp earnings_s_ earnings_s_imp
	
	label variable income_nominal "Nominal individual income"
	label variable income_real "Real individual income"
	label variable earnings_nominal "Nominal individual earnings"
	label variable earnings_real "Real individual earnings"
	label variable famearn_real "Real family earnings"
	label variable faminct_nom "Nominal taxable family income"
	label variable faminct_real "Real taxable family income"
	


* Save resulting dataset

	sort id year
	save "$dir/data/psid_int.dta", replace
	
	
	
	
/*

Variables to delete before sharing:
foodsec
transfer
assetinc_other
regiongrewup
grewuppoor
applied_*
denied_*
hhid
edyears
wsav2_
ssi_spouse
ui_imp_head
ui_imp_spouse
split
annual_hrs_head 
annual_hrs_spouse
assetinc_other
faminct_oth
*/
