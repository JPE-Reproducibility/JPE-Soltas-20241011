*** Sub-function to simulate LIHEAP eligibility

capture program drop eligsim_liheap
program define eligsim_liheap, rclass

syntax, state(varname) year(varname) faminc(varname) hhsize(varname) wsav(varname) qualified_imm(varname) [ utility_exp(varname) ]

	* Confirm program variables do not exist
	local vlist "heating cooling winter_crisis summer_crisis weatherization notes source smi_4_person fpg_allother fpg_alaska fpg_hawaii catelig_ssi catelig_tanf catelig_snap"
	capture confirm variable eligsim_liheap `vlist'

	if !_rc {
		display as error "One of your variable names conflicts with eligsim variables and must be renamed"
		exit 110
	}

	* Define simulated eligibility variable
	gen eligsim_liheap = 0
	
	* Merge with eligibility data
	merge m:1 `state' `year' `hhsize' using "$dir/data/eligsim/liheap/liheap", keep(1 3) nogen
	
	* Income test
	
		* Tweaks for idiosyncratic state rules
		replace heating = max(heating,(55/100)*smi_4_person) if (notes == "all: 55 SMI if higher" | notes == "all: 55 SMI if larger")
		replace heating = (55/100)*smi_4_person if notes == "all: 55 SMI if age>60 or age<2" & (age>60 | age_youngest<2)
		replace heating = max(heating,(60/100)*smi_4_person) if notes == "all: 60 SMI if higher"
		replace heating = max(heating,(60/100)*smi_4_person) if notes == "heating: 60 SMI if higher"
		replace heating = (150/100)*fpg_allother if (notes == "all: 150 if age>=60" | notes == "all: 150 FPG if age>=60") & age>=60 & !inlist(state,2,15)
		replace heating = (170/100)*fpg_allother if notes == "all: 170 FPG if age>60 or age<2" & (age>60 | age_youngest<2) & !inlist(state,2,15)
		replace heating = (150/100)*fpg_allother if notes == "heating,crisis: 150 FPG if hhsize>=7" & hhsize>=7 & !inlist(state,2,15)
		replace heating = (150/100)*fpg_allother if notes == "all: 150 FPG if hhsize>=7" & hhsize>=7 & !inlist(state,2,15)
		replace heating = (150/100)*fpg_allother if notes == "all: 150 FPG if hhsize>=8" & hhsize>=8 & !inlist(state,2,15)
		replace heating = (150/100)*fpg_allother if notes == "all: 150 FPG if hhsize>=10" & hhsize>=10 & !inlist(state,2,15)
		replace heating = (150/100)*fpg_allother if notes == "all: 150 FPG if hhsize>=11" & hhsize>=11 & !inlist(state,2,15)
		replace heating = (150/100)*fpg_allother if notes == "all: 150 FPG if hhsize>10" & hhsize>10 & !inlist(state,2,15)
		replace heating = (115/100)*fpg_allother if notes == "all: 115 FPG if hhsize>=3" & hhsize>=3 & !inlist(state,2,15)
		replace heating = (110/100)*fpg_allother if notes == "all: 110 FPG if hhsize>=14" & hhsize>=14 & !inlist(state,2,15)
		
	replace eligsim_liheap = 1 if `faminc' <= heating & !missing(`faminc')
	
	* Pays utilities
	replace eligsim_liheap = 0 if `utility_exp' == 0
	
	* Asset test
	replace eligsim_liheap = 0 if has_asset_limit == 1 & `wsav' > asset_limit_amt & !missing(`wsav')
	
	* Exclude non-qualified immigrants under PRWORA
	replace eligsim_liheap = 0 if `qualified_imm' == 0				
	
	* Categorical eligibility
	replace eligsim_liheap = 1 if ssi == 1 & catelig_ssi == 1
	replace eligsim_liheap = 1 if tanf == 1 & catelig_tanf == 1
	replace eligsim_liheap = 1 if snap == 1 & catelig_snap == 1
	
	drop heating cooling winter_crisis summer_crisis weatherization notes source smi_4_person fpg_allother fpg_alaska fpg_hawaii asset_limit_amt catelig_*
		
end
