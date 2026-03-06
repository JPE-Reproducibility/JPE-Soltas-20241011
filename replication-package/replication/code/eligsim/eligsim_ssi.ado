*** Sub-function to simulate SSI eligibility

capture program drop eligsim_ssi
program define eligsim_ssi, rclass

syntax, faminc(varname) famearn(varname) hhsize(varname) nchild(varname) wsav(varname) wcar(varname) disabled(varname) famid(varname) state(varname) year(varname) married(varname) child_disabled(varname) qualified_imm(varname) citizen(varname) yr_us(varname) ssi_amt(varname) cpi(varname)

	* Confirm program variables do not exist
	local vlist "sga_cutoff fbr_single fbr_couple fbr inc_ssi_calc nadults_ssi countable_resources_ssi"
	capture confirm variable eligsim_ssi `vlist'

	if !_rc {
		display as error "One of your variable names conflicts with eligsim variables and must be renamed"
		exit 110
	}

	* Define simulated eligibility variable
	gen eligsim_ssi = .
	
	* Must be disabled
	gegen disabled_hh = max(`disabled'), by(`famid' `year')
	replace disabled_hh = 1 if `child_disabled' == 1
	replace eligsim_ssi = disabled_hh
	drop disabled_hh
	
	* Income test
	
		* Substantial gainful activity cutoffs by year

		gen sga_cutoff = .
		replace sga_cutoff = 500 if `year' == 1997
		replace sga_cutoff = 700 if `year' == 1999
		replace sga_cutoff = 740 if `year' == 2001
		replace sga_cutoff = 800 if `year' == 2003
		replace sga_cutoff = 830 if `year' == 2005
		replace sga_cutoff = 900 if `year' == 2007
		replace sga_cutoff = 980 if `year' == 2009
		replace sga_cutoff = 1000 if `year' == 2011
		replace sga_cutoff = 1040 if `year' == 2013
		replace sga_cutoff = 1090 if `year' == 2015
		replace sga_cutoff = 1170 if `year' == 2017
		replace sga_cutoff = 1220 if `year' == 2019

		* Federal benefit rate

		gen fbr_single = .
		replace fbr_single = 484 if `year' == 1997
		replace fbr_single = 500 if `year' == 1999
		replace fbr_single = 531 if `year' == 2001
		replace fbr_single = 552 if `year' == 2003
		replace fbr_single = 579 if `year' == 2005
		replace fbr_single = 623 if `year' == 2007
		replace fbr_single = 674 if `year' == 2009
		replace fbr_single = 674 if `year' == 2011
		replace fbr_single = 710 if `year' == 2013
		replace fbr_single = 733 if `year' == 2015
		replace fbr_single = 735 if `year' == 2017
		replace fbr_single = 771 if `year' == 2019
		
		gen fbr_couple = .
		replace fbr_couple = 726 if `year' == 1997
		replace fbr_couple = 751 if `year' == 1999
		replace fbr_couple = 796 if `year' == 2001
		replace fbr_couple = 829 if `year' == 2003
		replace fbr_couple = 869 if `year' == 2005
		replace fbr_couple = 934 if `year' == 2007
		replace fbr_couple = 1011 if `year' == 2009
		replace fbr_couple = 1011 if `year' == 2011
		replace fbr_couple = 1066 if `year' == 2013
		replace fbr_couple = 1100 if `year' == 2015
		replace fbr_couple = 1103 if `year' == 2017
		replace fbr_couple = 1157 if `year' == 2019
		
		gen nadults_ssi = `hhsize'-`nchild'>1 if !missing(`hhsize') & !missing(`nchild')
		
		merge m:1 `state' `year' using "$dir/data/eligsim/ssi/ssi_state_supplement.dta", nogen keep(1 3)
		
		replace supplement_single_indep = 0 if missing(supplement_single_indep)
		replace supplement_couple_indep = 0 if missing(supplement_couple_indep)
		
		gen fbr = (nadults_ssi==1)*(fbr_single+supplement_single_indep) + (nadults_ssi>=2 & married==1 & !missing(nadults_ssi))*(fbr_couple+supplement_couple_indep)
		
		* Countable earnings to compare to federal benefit rate: https://www.ssa.gov/ssi/text-income-ussi.htm
		* Note: we "undo" SSI income from family income here, b/c faminc includes SSI
		gen ssi_amt_nom = `ssi_amt'*`cpi'
		replace ssi_amt_nom = 0 if missing(ssi_amt_nom)
		gen faminc_less_ssi = `faminc' - ssi_amt_nom
		gen inc_ssi_calc = max(0,faminc_less_ssi - 0.5*max(0,`famearn'-12*65) - 12*20) if !missing(`faminc') & !missing(`famearn')
		drop faminc_less_ssi ssi_amt_nom
		
		* Household is ineligible if excluded by one of the income tests
		
		replace eligsim_ssi = 0 if eligsim_ssi == 1 & `famearn' >= 12*sga_cutoff & !missing(`famearn')
		replace eligsim_ssi = 0 if eligsim_ssi == 1 & inc_ssi_calc >= 12*fbr & !missing(inc_ssi_calc)
		
		* Exclude immigrants under PRWORA
	
		merge m:1 `state' using "$dir/data/eligsim/ssi_immigrant.dta", nogen keep(1 3)
		
			* Disqualify non-qualified aliens
			replace eligsim_ssi = 0 if `qualified_imm' == 0
		
			* Disqualify if early arrival and state bans early arrivals
			replace eligsim_ssi = 0 if ssi_imm_early == 0 & `yr_us' < 1996 & `qualified_imm' == 1 & `citizen' == 0	
		
			* Disqualify if late and state bans late arrivals, pre 5 year wait (2002)
			replace eligsim_ssi = 0 if ssi_imm_late == 0 & (`yr_us' >= 1996 | missing(yr_us)) & `year' >= 1996 & `year' < 2003 & `qualified_imm' == 1 & `citizen' == 0	
			
			* Disqualify if late and state bans late arrivals, post 5 year wait (2002)
			replace eligsim_ssi = 0 if ssi_imm_late2002 == 0 & ((`yr_us' >= 1996 & `year' - `yr_us' < 5) | missing(yr_us)) & `year' >= 2003 & `qualified_imm' == 1 & `citizen' == 0
	
	* Asset test: $3000 for couples, $2000 for singles
		
		gen countable_resources_ssi = max(0,`wsav') if `year' >= 2005
		replace countable_resources_ssi = max(0,`wsav'+max(0,`wcar'-4500)) if `year' < 2005
		
		replace eligsim_ssi = 0 if eligsim_ssi == 1 & countable_resources_ssi > 2000 & (nadults_ssi == 1 | `married'==0)
		replace eligsim_ssi = 0 if eligsim_ssi == 1 & countable_resources_ssi > 3000
		
	drop fbr fbr_single fbr_couple nadults_ssi inc_ssi_calc sga_cutoff countable_resources_ssi supplement_couple_indep supplement_couple_indep

	replace eligsim_ssi = 0 if missing(eligsim_ssi)
	
end
