/*****

Loads the CEX files from raw data, pulling out the variables we need

Input:
- raw files in data/cex/raw/intrvw{year}, where each {year} represents a year from 1997–2019

Output:
- CEX-based dataset: `"$dir/data/cex/raw/workfile.dta"`
******/

* Settings
do code/settings.do	

*** Variable lists by concept (apply across years)

	* Transfer programs
	local vlist_medicaid "jmdcdqvx mdcdcov mdcdenr mdcdprmx medicaid medprem hhmcrcov othmed othplan hhipdlib"
	
*** Append everything together

	local files : dir "$dir/data/cex/int" files "*.dta"
	local first : word 1 of `files'
	
	use "$dir/data/cex/int/`first'", clear
	
	foreach f in `files' {
		
		append using "$dir/data/cex/int/`f'"
		
	}
	
*** Clean up ID and time units

	gen cuid_ = substr(newid,1,length(newid)-1)
	drop cuid
	rename cuid_ cuid
	
	destring cuid newid sex_ref sex2, replace
	
	gen yq = yq(year,qtr) 
	
*** Get age of youngest member

	gegen age_youngest = min(age), by(cuid year)
	
*** Get ownership of consumer durables

	gen computer_ = max(minapply == "640",mnappl1 == "640",mnappl2 == "640",mnappl3 == "640",mnappl4 == "640",mnappl5 == "640",mnappl6 == "640",mnappl7 == "640",mnappl8 == "640",mnappl9 == "640")
	replace computer_ = 1 if majcode == "13"
	gegen computer = max(computer_), by(cuid year)
	drop computer_ majcode mnappl* minapply*
	
*** Pull in rental equivalents

	gegen equivrent = max(rnteqvx), by(cuid year)
	drop rnteqvx
	
*** Medicaid variables --> merge into main data

	foreach v of varlist `vlist_medicaid' {
		
		capture destring `v', replace
		
		gegen tmp1 = max(`v'), by(newid year)
		gegen tmp2 = max(tmp1), by(cuid year)
		
		rename (tmp2 `v') (`v' tmp2)
		drop tmp1 tmp2
		
	}
	
*** Run vehicle valuation module

	preserve
		
	keep file newid cuid year mkmdel mkmdly make mkmodel model lsd_make modelyr typeveh autotype vehicyr modelyr milesveh vehmile qadpmt1x qadpmt2x qadpmt3x vehnewu
	keep if strpos(file,"lsd")>0 | strpos(file,"ovb")>0
	
	gegen owns_new = max(vehnewu=="1"), by(cuid year)
	gegen owns_used = max(vehnewu=="2"), by(cuid year)
	
	gen lease_cost = qadpmt1x + qadpmt2x + qadpmt3x
	gen ln_lease_cost = ln(lease_cost)
	drop qadpmt*x
	
	* Consolidate variables
		
		* Mileage
		replace milesveh = vehmile if missing(milesveh)
		gen ln_milesveh = ln(milesveh)
		gen missing_miles = missing(ln_milesveh)
		replace ln_milesveh = -1 if missing(ln_milesveh)
		drop vehmile
			
		* Model
		do "$dir/code/clean/cex/00_car_models.do"
		replace modelid = 0 if missing(modelid)
		drop model make mkmdly mkmodel mkmdel lsd_make

	* Type
	
		destring typeveh autotype, replace force
		gen cartype = typeveh
		replace cartype = autotype if missing(cartype)
		replace cartype = 0 if missing(cartype)
		drop typeveh autotype
		
	* Age of car
	
		destring vehicyr modelyr, force replace
		replace modelyr = 1969 if inlist(vehicyr,0,1)
		replace modelyr = 1972 if inlist(vehicyr,2)
		replace modelyr = 1977 if inlist(vehicyr,3)
		replace modelyr = 1981 if inlist(vehicyr,4)
		replace modelyr = 1984 if inlist(vehicyr,5)
	
		forvalues t = 6/40 {
			replace modelyr = 1980 + `t' if vehicyr == `t'
		}
		
		replace modelyr = . if inlist(modelyr,19,98,200,1909,1957)
		
		gen missing_model_year = missing(modelyr)
		replace modelyr = 1900 if missing(modelyr)
		
		gen age = year - modelyr
		replace age = . if age < 0
		replace age = 25 if age >= 25 & !missing(age)
		
		gen missing_age = missing(age)
		replace age = 100 if missing(age)
		
	* Poisson prediction
	poisson lease_cost i.cartype i.modelid##c.age ln_milesveh i.modelyr i.year missing_miles missing_model_year
	predict lease_cost_pred
	
	* Populate lease_cost_pred
	replace lease_cost_pred = lease_cost if !missing(lease_cost) & missing(lease_cost_pred)
		
	* Sum within the household
	gcollapse (sum) lease_cost lease_cost_pred owns_used owns_new, by(cuid year)
		
	* Save to tempfile
	tempfile lease
	save `lease', replace
	
	restore
	
	* Merge into main file
	merge m:1 cuid year using `lease', keep(1 3) nogen
		
	* Replace financing outlays with consumption flows	
	replace totexpcq = totexpcq - (vehfincq + cartkncq + cartkucq) + lease_cost_pred if !missing(lease_cost_pred)
	replace totexppq = totexppq - (vehfinpq + cartknpq + cartkupq)
		
	* Delete all car variables
	drop vehfinpq vehfincq cartknpq cartkncq cartkupq cartkucq mkmdel mkmdly make mkmodel model lsd_make modelyr typeveh autotype vehicyr modelyr milesveh vehmile qadpmt1x qadpmt2x qadpmt3x
		
*** Count adults/children, adjust other person-level variables, then drop person files

	* Count people
	gegen n_adults = sum((age>=18)*!missing(age)), by(year qtr newid)
	gegen n_children = sum((age<18)*!missing(age)), by(year qtr newid)
	gen n_people = n_adults + n_children
		
	* Sum up person level SSI payments
	foreach v of varlist ssibx ssix ssixm {
		gegen `v'_memi = sum(`v'), by(year qtr newid)
		drop `v'
		rename `v'_memi `v'
	}
	
	keep if strpos(file,"fmli")>0
	drop age file
	
*** Set up person-level sample
	
	xtset cuid yq
	destring state, replace
	
	gen has_spouse = !missing(age2)
	gen expand_key = 1 + has_spouse
	
	expand expand_key
	gsort cuid yq

	gen perid = 1
	replace perid = perid[_n-1] + 1 if cuid == cuid[_n-1] & yq == yq[_n-1]
	
	replace finlwt21 = finlwt21 / expand_key
	
	drop has_spouse expand_key
	
*** Person-level demographics

	* Age
	gen age = .
	replace age = age_ref if perid == 1
	replace age = age2 if perid == 2
	drop age_ref age2
	
	* Sex
	gen sex = sex_ref if perid == 1
	replace sex = sex2 if perid == 2
	drop sex_ref sex2

	* Hispanic ethnicity
	destring hisp_ref hisp2, replace
	gen hispanic = .
	replace hispanic = hisp_ref == 1 if perid == 1 &  !missing(hisp_ref)
	replace hispanic =  hisp2 == 1 if perid == 2 & !missing(hisp2)
	
	* Race
	destring ref_race race2, replace
	
	gen race = .
	
	replace race = 1 if ref_race == 1 & perid == 1 & !missing(ref_race)
	replace race = 2 if ref_race == 2 & perid == 1 & !missing(ref_race)
	replace race = 3 if hispanic == 1 & perid == 1 & !missing(ref_race)
	replace race = 4 if missing(race) & perid == 1 & !missing(ref_race)
	
	replace race = 1 if race2 == 1 & perid == 2 & !missing(ref_race)
	replace race = 2 if race2 == 2 & perid == 2 & !missing(ref_race)
	replace race = 3 if hispanic == 1 & perid == 2 & !missing(ref_race)
	replace race = 4 if missing(race) & perid == 2 & !missing(ref_race)
	
	* Education
	destring educ_ref educa2, replace
	
	gen educ = .
	replace educ = 1 if inlist(educ_ref,0,10,11) & perid == 1
	replace educ = 2 if inlist(educ_ref,12) & perid == 1
	replace educ = 3 if inlist(educ_ref,13,14) & perid == 1
	replace educ = 4 if inlist(educ_ref,15) & perid == 1
	replace educ = 5 if inlist(educ_ref,16) & perid == 1
	
	replace educ = 1 if inlist(educa2,0,10,11) & perid == 2
	replace educ = 2 if inlist(educa2,12) & perid == 2
	replace educ = 3 if inlist(educa2,13,14) & perid == 2
	replace educ = 4 if inlist(educa2,15) & perid == 2
	replace educ = 5 if inlist(educa2,16,17) & perid == 2
	
	* Disability indicator
	destring incnonw*, replace
	gen disabled = max(incnonw1==4,incnonw2==4)
	
	* Labor force indicators
	forvalues t = 1/2 {
		gen nilf`t' = inlist(incnonw`t',1,2,3,4,6)
		gen unemployed`t' = incnonw`t'==5
	}
	drop incnonw*

	* Employment status	
	gen unemploy = unemployed1 if perid == 1
	replace unemploy = unemployed2 if perid == 2
	drop unemployed1 unemployed2
	
	gen nilf = nilf1 if perid == 1
	replace nilf = nilf2 if perid == 2
	drop nilf1 nilf2
	
	gen employ = inc_hrs1 > 0 if !missing(inc_hrs1) & perid == 1
	replace employ = inc_hrs2 > 0 if !missing(inc_hrs2) & perid == 2
	
	keep if (inrange(age,18,65) | inrange(age,18,65)) & (inlist(respstat,"1") | missing(respstat))
 
*** CPI for inflation adjustments

	gen cpi = .
	replace cpi = 62.0156 if year == 1997
	replace cpi = 62.97498 if year == 1998
	replace cpi = 64.35611 if year == 1999
	replace cpi = 66.52278 if year == 2000
	replace cpi = 68.39648 if year == 2001
	replace cpi = 69.48786 if year == 2002
	replace cpi = 71.08469 if year == 2003
	replace cpi = 72.98093 if year == 2004
	replace cpi = 75.43734 if year == 2005
	replace cpi = 77.868 if year == 2006
	replace cpi = 80.10324 if year == 2007
	replace cpi = 83.15914 if year == 2008
	replace cpi = 82.89273 if year == 2009
	replace cpi = 84.24933 if year == 2010
	replace cpi = 86.89447 if year == 2011
	replace cpi = 88.69596 if year == 2012
	replace cpi = 89.99621 if year == 2013
	replace cpi = 91.45007 if year == 2014
	replace cpi = 91.56085 if year == 2015
	replace cpi = 92.72126 if year == 2016
	replace cpi = 94.69756 if year == 2017
	replace cpi = 97.00723 if year == 2018
	replace cpi = 98.76622 if year == 2019
	
*** Recode variables

	gen housing_exp = (sheltcq + sheltpq)*4
	egen wsav_nom = rowtotal(savacctx liquidx secestx stockx irax whlfyrx othastx)
	
	* Demographics (family-level)
	
		rename fam_size hhsize
			
		gen single_parent = n_adults == 1 & n_children > 1 & !missing(n_children)
				
		gen has_child = n_children >= 1 if !missing(n_children)
	
	* Consumption measures
		   
		gen food_at_home = fdhomecq + fdhomepq
		replace food_at_home = 100 * food_at_home / (cpi * hhsize)
		drop fdhomecq fdhomepq
		
		gen gasoline = gasmocq + gasmopq
		replace gasoline = 100 * gasoline / (cpi * hhsize)
		drop gasmocq gasmopq
		
		gen utility_exp = utilcq + utilpq
		replace utility_exp = 100 * utility_exp / (cpi * hhsize)
		drop utilcq utilpq
		
		gen owns_car = vehq > 0 if !missing(vehq)
		drop vehq
		
		gen central_ac = inlist(cntralac,"05","12")
		drop cntralac
		
		gen owns_home = inlist(cutenure,"1","2")
		drop cutenure
		
		replace roomsq = 20 if !missing(roomsq) & roomsq>20
		rename roomsq nrooms
	
	* Marital status indicator
	gen married = marital1 == "1" if !missing(marital1)
	drop marital1
	
	* Health expenditures
	gen health_exp = (hlthincq + hlthinpq)*4
	drop hlthincq hlthinpq
	
	* SNAP
			
		* Fill in with interval median
		replace foodsmpx = foodspbx if missing(foodsmpx)
		
		* Consolidate across measures
		forvalues t = 1/5  {
			
			replace foodsmp`t' = 0 if missing(foodsmpx) & missing(foodsmp`t')
			replace jfs_amt`t' = 0 if missing(jfs_amt) & missing(jfs_amt`t')
			replace fs_amtx`t' = 0 if missing(fs_amtx`t')
			
			egen amt_snap`t' = rowmax(foodsmp`t' fs_amtx`t' jfs_amt`t' foodsmpx)
			replace amt_snap`t' = 100 * amt_snap`t' / (cpi * hhsize)
			
			drop foodsmp`t' jfs_amt`t' fs_amtx`t'
		}
		drop fs_amtx jfs_amt foodspbx
		
		replace foodsmpx = 0 if missing(foodsmpx)
		replace foodsmpx = 100 * foodsmpx / (cpi * hhsize)		
		rename foodsmpx amt_snap
		replace amt_snap = (amt_snap1 + amt_snap2 + amt_snap3 + amt_snap4 + amt_snap5)/5 if inrange(year,2013,2019) | inrange(year,2004,2005)
		foreach v of varlist amt_snap* {
			replace `v' = . if year < 2001 | (year == 2001 & qtr == 1)
		}
		replace amt_snap = 100 * jfdstmpa / (cpi * hhsize) if (amt_snap == 0 | missing(amt_snap)) & !missing(jfdstmpa)
		drop jfdstmpa
		
		gen snap = amt_snap > 0 if !missing(amt_snap)
		replace snap = 1 if inrange(foodsmpq,1,12)
		drop foodsmpq
	
	* SSI
	
		* Fill in with interval median (will use multiple imputations in full analysis)
		replace fssix = fssixm if (missing(fssix) | fssix == 0) & !missing(fssixm)
		
		replace fssix = 100 * fssix / (cpi * hhsize)
		replace ssix = 100 * ssix / (cpi * hhsize)
		rename fssix amt_ssi
		
		gen ssi = amt_ssi > 0 if !missing(amt_ssi)
	
	
	* Medicaid
	
	gen medicaid_ = .
	replace medicaid_ = mdcdenr == 1 if !missing(mdcdenr)
	replace medicaid_ = medicaid == 1 if !missing(medicaid) & missing(medicaid_)
	
	drop mdcdenr medicaid
	rename medicaid_ medicaid
		
	* Housing assistance
	destring publhous govtcost, replace
	gen housing_assistance = publhous == 1 | govtcost == 1
	replace publhous = 0 if publhous == 2
	replace govtcost = 0 if govtcost == 2
	rename govtcost rentsubsidy
	
	* TANF
	
	rename welfarex amt_tanf 
	destring welfrebx, replace
		
	replace amt_tanf = welfarem if missing(amt_tanf)
	replace amt_tanf = welfrebx if missing(amt_tanf)
	replace amt_tanf = 0 if missing(amt_tanf) & !missing(amt_snap)

	drop welfrebx welfarem
		
	replace amt_tanf = 100 * amt_tanf / (cpi*hhsize)
	
	gen tanf = amt_tanf > 0 if !missing(amt_tanf)

*** Compute ranks

	* Equivalence scale
	gen eqscale = (n_adults + 0.7*n_children)^0.7
	gen anychild = n_children>0 if !missing(n_children)
	
	* Income
	
	replace fincatxm = fincatax if missing(fincatxm)
	replace fincbtxm = fincbtax if missing(fincbtxm)		
		
	gen inc_adj = 100 * fincbtxm / (cpi*eqscale)
	gegen rk_inc = rank(inc_adj) [aw=finlwt21], by(yq)
	gegen max_rk_inc = max(rk_inc), by(yq)
	replace rk_inc = 100 * (rk_inc-1) / (max_rk_inc-1)
	drop inc_adj max_rk_inc		
		
	* Consumption
	
	gen cons_a = totexppq + totexpcq - (perinspq + perinscq)
	replace cons_a = (totexppq - owndwepq + equivrent*3) + (totexpcq - owndwecq + equivrent*3) if !missing(equivrent) & !missing(owndwecq) & !missing(owndwepq) & owns_home == 1
	replace cons_a = cons_a*4

	gen cons_adj = 100*cons_a / (cpi*eqscale)
	
	gegen rk_cons = rank(cons_adj)  [aw=finlwt21], by(yq)
	gegen max_rk_cons = max(rk_cons), by(yq)
	replace rk_cons = 100 * (rk_cons-1) / (max_rk_cons-1)
	drop max_rk_cons owndwepq owndwecq
	
	* Earnings
	
	replace fsalaryx = fsalarym if missing(fsalaryx)
	replace fnonfrmx = fnonfrmm if missing(fnonfrmx)
	replace ffrmincx = ffrmincm if missing(ffrmincx)
	replace fsmpfrmx = fsmpfrxm if missing(fsmpfrmx)
	
	gen earnings_qx = earnincx
	gegen tmp_earn = rowtotal(fsalaryx fnonfrmx ffrmincx fsmpfrmx)
	replace earnings_qx = tmp_earn if missing(earnings_qx)
	drop tmp_earn

*** Merge in amounts for in-kind transfers

	merge m:1 hhsize year using "$dir/data/cps/cps_imputation", nogen keep(1 3)

	rename (medicaid_amt_hh rent_subsidy_amt_hh pubhou_amt_hh) (amt_medicaid amt_rentsubsidy amt_publichousing)
	
	replace amt_medicaid = 100*amt_medicaid*medicaid / (cpi*hhsize)
	replace amt_rentsubsidy = 100*amt_rentsubsidy*rentsubsidy / (cpi*hhsize)
	replace amt_publichousing = 100*amt_publichousing*publhous / (cpi*hhsize)

	egen amt_housing_assistance = rowtotal(amt_publichousing amt_rentsubsidy)
	
*** Eligibility

	* Create variables needed to fill in data gaps in CEX

	gen wcar_nom = 2000*owns_used + 5000*owns_new
	gen woth_nom = 0
	gen whome_nom = 0
	gen yr_us = .
	gen qualified_imm = 1
	gen citizen = 1
		
	gen head = perid == 1
	gen spouse = perid == 2
	
	gen child_disabled = 0
	
	gen famid = cuid
	
	eligsim_snap, state(state) year(year) faminc(fincbtxm) famearn(earnings_qx) hhsize(hhsize) fpl(povlevcy) housing_exp(housing_exp) wsav(wsav_nom) wcar(wcar_nom) yr_us(yr_us) qualified_imm(qualified_imm) citizen(citizen)
		
	eligsim_housing_assistance, state(state) year(year) faminc(fincbtxm) hhsize(hhsize) whome(whome_nom) woth(woth_nom) wsav(wsav_nom) famid(famid) qualified_imm(qualified_imm)

	eligsim_ssi, faminc(fincbtxm) famearn(earnings_qx) hhsize(hhsize) nchild(n_children) wsav(wsav_nom) wcar(wcar_nom) disabled(disabled) state(state) year(year) famid(famid) married(married) child_disabled(child_disabled) yr_us(yr_us) qualified_imm(qualified_imm) citizen(citizen) ssi_amt(amt_ssi) cpi(cpi)

	eligsim_medicaid, state(state) year(year) faminc(fincbtxm) fpl(povlevcy) age(age) age_youngest(age_youngest) nchild(n_children) eligsim_ssi(eligsim_ssi) disabled(disabled) earnings(earnings_qx) health_exp(health_exp) wsav(wsav_nom) married(married) yr_us(yr_us) qualified_imm(qualified_imm) citizen(citizen)

	gegen id = group(newid perid)
	eligsim_tanf, state(state) year(year) hhsize(hhsize) faminc(fincbtxm) anychild(anychild) wcar(wcar_nom) wsav(wsav_nom) qualified_imm(qualified_imm) citizen(citizen) yr_us(yr_us) tanf_amt(amt_tanf) cpi(cpi) id(id) wt(finlwt21) 
	drop id
		
	
	drop snap_imm_early snap_imm_late snap_imm_late2021
	drop supplement_single_indep supplement_single_institution _merge ssi_imm_early ssi_imm_late ssi_imm_late2002
	drop medicaid_imm_early medicaid_imm_late medicaid_imm_late2012 medicaid_buyin medically_needy tanf_gross_elig tanf_asset tanf_earnings_fixed tanf_earnings_fraction state_name netfactor_ state_postal grossfactor_ da1 da2 netincomedamapping_ grossincomedamapping_ disregardusedfor_ nonzero_tanf tanf_rolling_sum uses_gross net_map uses_net earnings_disregard_flag pass_gross_test disregard pass_net_test pass_gross_test_2002 pass_net_test_2002 median_da1 median_gross_elig pass_gross_test_imp pass_gross_test_imp_2002 above_asset
drop tanf_imm_early tanf_imm_late tanf_imm_late2011

* Label variables		
do "code/clean/cex/00_label_vars"

*** Save
save "$dir/data/cex/raw/workfile.dta", replace
