*** Sub-function to simulate UI eligibility

capture program drop eligsim_ui
program define eligsim_ui, rclass

syntax, wks_unemp(varname) why_unemploy(varname) earnings(varname) state(varname) year(varname)

	* Confirm program variables do not exist
	local vlist "eligsim_ui min_earn any_unemp"
	capture confirm variable eligsim_ui `vlist'

	if !_rc {
		display as error "One of your variable names conflicts with eligsim variables and must be renamed"
		exit 110
	}

	* Define simulated eligibility variable
	gen eligsim_ui = .
	
	* Must be have been unemployed
	gen any_unemp = `wks_unemp' > 0 if !missing(`wks_unemp')
	replace eligsim_ui = any_unemp == 1
	drop any_unemp
	
	* Earnings must be above threshold
	merge m:1 `state' `year' using "$dir/data/eligsim/ui/ui_params.dta", nogen keep(1 3)
	replace eligsim_ui = 0 if eligsim_ui == 1 & `earnings' < min_earn/1000
	drop min_earn
	
	* Cannot have quit job
	replace eligsim_ui = 0 if eligsim_ui == 1 & `why_unemploy' == 4
	
	* Ineligible if duration was too long
	replace eligsim_ui = 0 if eligsim_ui == 1 & `wks_unemp' > max_weeks
		
	* Must have previously worked in the covered sector

end
