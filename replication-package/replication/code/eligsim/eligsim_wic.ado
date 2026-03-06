*** Sub-function to simulate WIC eligibility

capture program drop eligsim_wic
program define eligsim_wic, rclass

syntax, faminc(varname) fpl(varname) snap(varname) tanf(varname) medicaid(varname) age_youngest(varname) age_eldest(varname)

	* Confirm program variables do not exist
	local vlist "eligsim_wic inc_fpl"
	capture confirm variable `vlist'

	if !_rc {
		display as error "One of your variable names conflicts with eligsim variables and must be renamed"
		exit 110
	}

	* Define simulated eligibility variable
	gen eligsim_wic = 0
	
	* Categorically eligible if have child under 5
	replace eligsim_wic = 1 if `age_youngest'<=4 | `age_eldest'<=4
	
	* Calculate gross income as a share of FPL
	gen inc_fpl = 100 * `faminc' / `fpl'
	
	* Must satisfy one of two income eligibility rules
	
		* Income eligibility test 1: must be under 185% of FPL
		* Income eligibility test 2: receives SNAP, TANF, or Medicaid
		replace eligsim_wic = 0 if eligsim_wic == 1 & inc_fpl > 185 & snap == 0 & tanf == 0 & medicaid == 0

	drop inc_fpl	
		
end
