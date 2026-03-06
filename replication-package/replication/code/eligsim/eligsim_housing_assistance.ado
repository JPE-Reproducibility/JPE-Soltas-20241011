*** Sub-function to simulate housing assistance eligibility

capture program drop eligsim_housing_assistance
program define eligsim_housing_assistance, rclass

syntax, state(varname) year(varname) faminc(varname) hhsize(varname) woth(varname) whome(varname) wsav(varname) famid(varname) qualified_imm(varname)

	* Confirm program variables do not exist
	local vlist "ami faminc_ha qualified_imm_fam"
	capture confirm variable eligsim_housing_assistance `vlist'

	if !_rc {
		display as error "One of your variable names conflicts with eligsim variables and must be renamed"
		exit 110
	}

	* Define simulated eligibility variable
	gen eligsim_housing_assistance = 1 if !missing(`faminc')
		
	* Income test
	merge m:1 `state' `hhsize' `year' using "$dir/data/eligsim/housing_assistance/inc_limit.dta", nogen keep(1 3)
	
	gen faminc_ha = `faminc' + (`whome'+`wsav')*0.02*(`year'<2014)
	
	replace eligsim_housing_assistance = 0 if faminc_ha > ami & !missing(faminc_ha)
	
	drop ami faminc_ha
	
	* PRWORA immigrant exclusion
	gegen qualified_imm_fam = max(`qualified_imm'), by(`famid' `year')
	replace eligsim_housing_assistance = 0 if qualified_imm_fam == 0
	drop qualified_imm_fam

	
end


