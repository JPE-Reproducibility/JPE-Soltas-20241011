*** Sub-function to simulate NSLP eligibility

capture program drop eligsim_schoolmeals
program define eligsim_schoolmeals, rclass

syntax, state(varname) year(varname) faminc(varname) fpl(varname) age_eldest(varname) age_youngest(varname) anychild(varname)

	* Confirm program variables do not exist
	local vlist ""
	capture confirm variable eligsim_schoolmeals `vlist'

	if !_rc {
		display as error "One of your variable names conflicts with eligsim variables and must be renamed"
		exit 110
	}

	* Define simulated eligibility variable
	gen eligsim_schoolmeals = .
	
	* Calculate income as a share of FPL
	capture gen inc_to_fpl = 100 * `faminc' / `fpl'
	
	* Require school-age child
	replace eligsim_schoolmeals = anychild
	replace eligsim_schoolmeals = `age_youngest'<= 18 & `age_eldest' >= 5 if eligsim_schoolmeals == 1
	
	* Apply income eligibility rules
	replace eligsim_schoolmeals = inc_to_fpl <= 185 if eligsim_schoolmeals == 1
	
	* Categorical eligibility
	replace eligsim_schoolmeals = 1 if snap == 1 | tanf == 1
	
end

		
		
		
