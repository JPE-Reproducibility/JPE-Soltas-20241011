*** Sub-function to simulate SNAP eligibility

capture program drop eligsim_snap
program define eligsim_snap, rclass

syntax, state(varname) year(varname) faminc(varname) famearn(varname) hhsize(varname) fpl(varname) wsav(varname) wcar(varname) yr_us(varname) qualified_imm(varname) citizen(varname) [ housing_exp(varname) cpi(varname) ]

	* Confirm program variables do not exist
	local vlist "max_allotment std_deduction max_excess_shelter_deduction inc_limit asset_limit vehexclall vehexclamt vehexclone inc_fpl excess_shelter netinc netinc_fpl check_elderly* check_disabled*"
	capture confirm variable eligsim_snap `vlist'

	if !_rc {
		display as error "One of your variable names conflicts with eligsim variables and must be renamed"
		exit 110
	}

	* Define simulated eligibility variable
	gen eligsim_snap = .

	quietly {
		
	* Merge with eligibility data
	merge m:1 `state' `year' `hhsize' using "$dir/data/eligsim/snap/snap", keep(1 3) nogen
	
	* Calculate gross income as a share of FPL
	gen inc_fpl = 100 * `faminc' / `fpl'
	
	local excess_shelter_thresh = 0.5
	
	* Calculate excess shelter costs
	if "`housing_exp'" != ""  & "`cpi'" != "" {
		gen excess_shelter = min(`faminc'*max((`cpi'*`housing_exp'/100)/`faminc' - `excess_shelter_thresh', 0), max_excess_shelter_deduction)
	}
	if "`housing_exp'" == "" | "`cpi'" == "" {
		gen excess_shelter = 0 
	}
	
	* Calculate net income as a share of FPL
	gen netinc = `faminc' - std_deduction - 0.2*`famearn' - excess_shelter
	gen netinc_fpl = 100 * netinc / `fpl'
	
	* Apply eligibility rules
		
		* Gross income test
			
			replace eligsim_snap = 0 if inc_fpl > inc_limit & !missing(inc_limit)
			replace eligsim_snap = 1 if inc_fpl <= inc_limit & !missing(inc_limit)
			
		* Net income test: see https://www.cbpp.org/research/food-assistance/a-quick-guide-to-snap-eligibility-and-benefits
		
			local net_inc_limit = 100
						
			replace eligsim_snap = 0 if netinc_fpl > `net_inc_limit'
						
		* Asset test (ignoring vehicles)
		
			replace eligsim_snap = 0 if `wsav' > asset_limit & !missing(`wsav')
			
		* Asset test (with vehicles)

			replace eligsim_snap = 0 if `wsav' + max(0,`wcar'-4650) > asset_limit & vehexclall == 0 & vehexclamt == 0 & vehexclone == 0 & !missing(`wcar') & !missing(`wsav')
		
		* Categorical eligibility

			replace eligsim_snap = 1 if tanf == 1 | ssi == 1
			
		* PRWORA disqualification of immigrants
		
		merge m:1 `state' using "$dir/data/eligsim/snap_immigrant.dta", nogen keep(1 3)
		
			* Disqualify non-qualified aliens
			replace eligsim_snap = 0 if `qualified_imm' == 0 & `citizen' == 0
		
			* Disqualify if early arrival and state bans early arrivals
			replace eligsim_snap = 0 if snap_imm_early == 0 & `yr_us' < 1996 & `qualified_imm' == 1	 & `citizen' == 0	
		
			* Disqualify if late and state bans late arrivals, pre 5 year wait (2002)
			replace eligsim_snap = 0 if snap_imm_late == 0 & (`yr_us' >= 1996 | missing(yr_us)) & `year' >= 1996 & `year' < 2003 & `qualified_imm' == 1 & `citizen' == 0	
			
			* Disqualify if late and state bans late arrivals, post 5 year wait (2002)
			replace eligsim_snap = 0 if snap_imm_late == 0 & ((`yr_us' >= 1996 & `year' - `yr_us' < 5) | missing(yr_us)) & `year' >= 2003 & `year' < 2011 & `qualified_imm' == 1 & `citizen' == 0
			replace eligsim_snap = 0 if snap_imm_late2021 == 0 & ((`yr_us' >= 1996 & `year' - `yr_us' < 5)| missing(yr_us)) & `year' >= 2011 & `qualified_imm' == 1 & `citizen' == 0		
					
	* Special eligibility rules for elderly or disabled - exempt from gross income test
	
		local asset_limit_eld_dis = 4250
	
		* Check for elderly head/spouse (60+)
		gen check_elderly_ = max(head,spouse)*(age>=60)
		gegen check_elderly = max(check_elderly_), by(famid year)
		replace eligsim_snap = 1 if check_elderly == 1 & netinc_fpl <= `net_inc_limit' & `wsav' <= max(asset_limit,`asset_limit_eld_dis')
		
		* Check for disabled head/spouse
		gen check_disabled_ = max(head,spouse)*disabled
		gegen check_disabled = max(check_disabled_), by(famid year)
		replace eligsim_snap = 1 if check_disabled == 1 & netinc_fpl <= `net_inc_limit' & `wsav' <= max(asset_limit,`asset_limit_eld_dis')

	* Drop variables
	drop `vlist'
	
	}
		
end
