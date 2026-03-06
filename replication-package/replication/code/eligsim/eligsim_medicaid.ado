*** Sub-function to simulate Medicaid eligibility

capture program drop eligsim_medicaid
program define eligsim_medicaid, rclass

syntax, state(varname) year(varname) faminc(varname) fpl(varname) age(varname) age_youngest(varname) nchild(varname) eligsim_ssi(varname) disabled(varname) earnings(varname) health_exp(varname) wsav(varname) yr_us(varname) married(varname) qualified_imm(varname) citizen(varname)

	* Confirm program variables do not exist
	local vlist "inc_to_fpl fpl_pregnantwoman fpl_nondisabledadult fpl_parent has_obra86_option income_limit_single income_limit_couple income_limit_fpl_single income_limit_fpl_couple disregard_single disregard_couple asset_limit_single asset_couple has_medicaid_buyin buyin_income_limit buyin_asset_limit_single buyin_asset_limit_couple buyin_income_limit_fpl has_medically_needy_pathway needy_income_limit_single needy_income_limit_couple needy_asset_limit_single needy_asset_limit_couple"
	capture confirm variable eligsim_medicaid `vlist'

	if !_rc {
		display as error "One of your variable names conflicts with eligsim variables and must be renamed"
		exit 110
	}

	* Define simulated eligibility variable
	gen eligsim_medicaid = .

	* Merge with eligibility data
	merge m:1 `state' `year' using "$dir/data/eligsim/medicaid", keep(1 3) nogen
	
	* Calculate income as a share of FPL
	gen inc_to_fpl = 100 * `faminc' / `fpl'
	
	* Apply income eligibility rules
	
	replace eligsim_medicaid = 1 if inc_to_fpl <= fpl_nondisabledadult & `nchild' == 0 & `age' >= 18 & !missing(fpl_nondisabledadult)
	replace eligsim_medicaid = 1 if inc_to_fpl <= fpl_parent & `age' >= 18 & `nchild' > 0 & !missing(`nchild') & !missing(fpl_parent)
	replace eligsim_medicaid = 1 if inc_to_fpl <= fpl_pregnantwoman & `age' >= 18 & `age_youngest' == 0 & !missing(fpl_pregnantwoman)
	
	* Exclude immigrants under PRWORA
	
		merge m:1 `state' using "$dir/data/eligsim/medicaid_immigrant.dta", nogen keep(1 3)
		
		* Disqualify non-qualified immigrants
		replace eligsim_medicaid = 0 if `qualified_imm' == 0	
	
		* Disqualify if early arrival and state bans early arrivals
		replace eligsim_medicaid = 0 if medicaid_imm_early == 0 & `yr_us' < 1996 & `qualified_imm' == 1 & `citizen' == 0
	
		* Disqualify if late and state bans late arrivals, pre 5 year wait (2002)
		replace eligsim_medicaid = 0 if medicaid_imm_late == 0 & (`yr_us' >= 1996 | missing(yr_us)) & `year' >= 1996 & `year' < 2003 & `qualified_imm' == 1	& `citizen' == 0	
		
		* Disqualify if late and state bans late arrivals, post 5 year wait (2002)
		replace eligsim_medicaid = 0 if medicaid_imm_late == 0 & ((`yr_us' >= 1996 & `year' - `yr_us' < 5) | missing(yr_us)) & `year' >= 2003 & `year' < 2012 & `qualified_imm' == 1 & `citizen' == 0	
		replace eligsim_medicaid = 0 if medicaid_imm_late2012 == 0 & ((`yr_us' >= 1996 & `year' - `yr_us' < 5)| missing(yr_us)) & `year' >= 2012 & `qualified_imm' == 1	& `citizen' == 0	

	* Other income eligibility rules (complicated)
	
		* FPL pathway
		replace eligsim_medicaid = 1 if `disabled' == 1 & `age' >= 18 & `faminc' <= income_limit_single + disregard_single & `married' == 0 & !missing(income_limit_single)
		replace eligsim_medicaid = 1 if `disabled' == 1 & `age' >= 18 & `faminc' <= income_limit_couple + disregard_couple & `married' == 1 & !missing(income_limit_couple)
		replace eligsim_medicaid = 1 if `disabled' == 1 & `age' >= 18 & inc_to_fpl <= income_limit_fpl_single & `married' == 0 & !missing(income_limit_fpl_single)
		replace eligsim_medicaid = 1 if `disabled' == 1 & `age' >= 18 & inc_to_fpl <= income_limit_fpl_couple & `married' == 1 & !missing(income_limit_fpl_couple)
		
		* Medicaid buy-in pathway
		
		gen medicaid_buyin = 0
		replace medicaid_buyin = 1 if `disabled' == 1 & `age' >= 18 & `faminc' <= buyin_income_limit & !missing(buyin_income_limit) & `earnings' > 0 & !missing(`earnings')
		replace medicaid_buyin = 1 if `disabled' == 1 & `age' >= 18 & inc_to_fpl <= buyin_income_limit_fpl & !missing(buyin_income_limit_fpl) & `earnings' > 0 & !missing(`earnings')
		
		replace eligsim_medicaid = 1 if medicaid_buyin == 1
		
		* Medically needy pathway
		
		gen medically_needy = 0		
		replace medically_needy = 1 if `age' >= 18 & `faminc' - max(cpi*health_exp/100,0) <= 12*needy_income_limit_single & !missing(needy_income_limit_single) & `married' == 0
		replace medically_needy = 1 if `age' >= 18 & `faminc' - max(cpi*health_exp/100,0) <= 12*needy_income_limit_couple & !missing(needy_income_limit_couple) & `married' == 1
		
		replace eligsim_medicaid = 1 if medically_needy == 1
	
	
	* Asset tests: state rules
		
		replace eligsim_medicaid = 0 if `wsav' > asset_limit_single & !missing(`wsav') & !missing(asset_limit_single) & `married' == 0 & max(medicaid_buyin,medically_needy) == 0
		replace eligsim_medicaid = 0 if `wsav' > asset_limit_couple & !missing(`wsav') & !missing(asset_limit_couple) & `married' == 1 & max(medicaid_buyin,medically_needy) == 0
		
		* Medicaid buy-in group
		
		replace eligsim_medicaid = 0 if `wsav' > buyin_asset_limit_single & !missing(`wsav') & !missing(buyin_asset_limit_single) & `married' == 0 & medicaid_buyin == 1
		replace eligsim_medicaid = 0 if `wsav' > buyin_asset_limit_couple & !missing(`wsav') & !missing(buyin_asset_limit_couple) & `married' == 1 & medicaid_buyin == 1
		
		* Medically needy group
		
		replace eligsim_medicaid = 0 if `wsav' > needy_asset_limit_single & !missing(`wsav') & !missing(needy_asset_limit_single) & `married' == 0 & medically_needy == 1
		replace eligsim_medicaid = 0 if `wsav' > needy_asset_limit_couple & !missing(`wsav') & !missing(needy_asset_limit_couple) & `married' == 1 & medically_needy == 1
	
	* Asset tests: use national rules if cannot find state rules
	replace eligsim_medicaid = 0 if `wsav' > 2000 & !missing(`wsav') & missing(asset_limit_single) & `married' == 0 & max(medicaid_buyin,medically_needy) == 0
	replace eligsim_medicaid = 0 if `wsav' > 3000 & !missing(`wsav') & missing(asset_limit_couple) & `married' == 1 & max(medicaid_buyin,medically_needy) == 0

	* Categorical eligibility via SSI eligibility
	replace eligsim_medicaid = 1 if `eligsim_ssi' == 1 & `age' >= 18  // & !inlist(state,9,15,17,27,29,33,38,40,51) [states that do not auto-grant Medicaid w/ SSI]
	
	* Code remaining observations as ineligible
	replace eligsim_medicaid = 0 if missing(eligsim_medicaid)
	
	* Drop Medicaid policy variables
	drop fpl_pregnantwoman fpl_nondisabledadult fpl_parent has_obra86_option income_limit_single income_limit_couple income_limit_fpl_single income_limit_fpl_couple disregard_single disregard_couple asset_limit_single asset_limit_couple has_medicaid_buyin buyin_income_limit buyin_asset_limit_single buyin_asset_limit_couple buyin_income_limit_fpl has_medically_needy_pathway needy_income_limit_single needy_income_limit_couple needy_asset_limit_single needy_asset_limit_couple inc_to_fpl
	
end

		
		
		
