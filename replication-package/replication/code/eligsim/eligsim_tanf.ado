*** Sub-function to simulate tanf eligibility
capture program drop eligsim_tanf
program define eligsim_tanf, rclass

  syntax, state(varname) year(varname) hhsize(varname) ///
      faminc(varname) anychild(varname) wcar(varname) wsav(varname) qualified_imm(varname) citizen(varname) yr_us(varname) tanf_amt(varname) cpi(varname) id(varname) wt(varname) 
  
	* Confirm program variables do not exist
	local vlist "tanf_gross_elig tanf_elig _mt_*"
	capture confirm variable eligsim_tanf `vlist'

	if !_rc {
		display as error "One of your variable names ///
        conflicts with eligsim variables and must be renamed"    
		exit 110
	}

  *** Bring in two multiplicative factors, one for gross income test and one for net
  merge m:1 `state' `year' using "$dir/data/eligsim/tanf/netfactor", keep(master match) nogen
  merge m:1 `state' `year' using "$dir/data/eligsim/tanf/grossfactor", keep(master match) nogen

  * bring in dollar amounts 
  merge m:1 `state' `year' `hhsize' using "$dir/data/eligsim/tanf/da_long", keep(master match) nogen
  
  * get the asset variable
  merge m:1 `state' `year' using "$dir/data/eligsim/tanf/tanf_asset", keepusing(tanf_asset) keep(master match) gen(_mt_tanfasset)
  
  * get the earnings disregard variables
  merge m:1 `state' `year' using "$dir/data/eligsim/tanf/disregardfixed", keep(master match) gen(_mt_tanfearnfixed)
  ren disregardfixed tanf_earnings_fixed
  
  * get the earnings disregard _fraction_ variable  
  merge m:1 `state' `year' using "$dir/data/eligsim/tanf/earningsfraction", keep(master match) gen(_mt_tanfearnfrac)
  ren earningsfraction tanf_earnings_fraction
  
  * there are some typos in the fractions, which are coded as percentages inaccurately in a small number of cases 
  replace tanf_earnings_fraction = tanf_earnings_fraction / 100 if tanf_earnings_fraction > 1 & !mi(tanf_earnings_fraction)

  * bring in flag that indicates which DA the net and gross income test refers to
  merge m:1 `state' `year' using "$dir/data/eligsim/tanf/netincomedamapping", keep(master match) nogen
  merge m:1 `state' `year' using "$dir/data/eligsim/tanf/grossincomedamapping", keep(master match) nogen
  
  * bring in flag for whether earnings disregard applies to net income test  
  merge m:1 `state' `year' using "$dir/data/eligsim/tanf/disregardusedfor", keep(master match)  nogen 

  * bring in the eligibility for 2002 and earlier
  merge m:1 `state' `year' `hhsize' using "$dir/data/eligsim/tanf/tanf_need", keep(master match) nogen keepusing(tanf_gross_elig)

  * replace the tanf income variable as being the main income less tanf
  tempvar faminc_tanf  
  gen `faminc_tanf' = `faminc' - `tanf_amt' 
  
  * assume ineligible if observed taking tanf in 3 years. include all ages for this computation, so use tanf_amt. 
  gen nonzero_tanf = `tanf_amt' > 0 if !mi(`tanf_amt') 
  bys `id' (year): gen tanf_rolling_sum = sum(nonzero_tanf)
  replace tanf_rolling_sum = tanf_rolling_sum - nonzero_tanf
  
  * determine whether there is a gross income test 
  gen uses_gross = 0 if grossincomedamapping == "None"
  replace uses_gross = 1 if grossincomedamapping != "None" & !mi(grossincomedamapping) 
  
  * obtain net income test type 
  gen net_map = . if netincomedamapping == "None"
  replace net_map = da1 if netincomedamapping == "Use Dollar Amount #1"
  replace net_map = da2 if netincomedamapping == "Use Dollar Amount #2"

  gen uses_net = net_map != .
  
  * for <5% of state-years after 2002, the net income test is another variable -> replace it as the modal one (da #1) 
  replace net_map = da1 if !mi(netincomedamapping) & mi(net_map) 
  
  * earnings disregard (omit the two-parent vs. one-parent family distinction in a small share of states) 
  gen earnings_disregard_flag = 1 if inlist(disregardusedfor,"Earnings disregard used for benefit calculation and net income test","Earnings disregard used only for the net income test.")
  replace earnings_disregard_flag = 0 if mi(earnings_disregard_flag)
  
  *** gross income test logic:
  *** pass the gross income test iff Gross income < DA1 * Gross income factor
  gen pass_gross_test = ( (`faminc_tanf' / 12) <= da1 * grossfactor) if grossfactor != 0 & uses_gross == 1 
  
  *** net income test logic:
  *** net_DA_mapping indicates which DA the net income test refers to for a given state/year. 
  *** If net_DA_mapping=0, no net income test, if net_DA_mapping=1, DA1, if net_DA_mapping=2, DA2.
  *** Assume the result is called "Net_Income_DA"
  *** disregard_earnings_net_flag indicates whether the earnings disregard applies to net income test
  
  *** If disregard_earnings_net_flag==1, then disregard = tanf_earnings_fixed + tanf_earnings_fraction * (gross_earnings - tanf_earnings_fixed)
  *** If disregard_earnings_net_flag==0, disregard =0
  gen disregard = tanf_earnings_fixed + tanf_earnings_fraction * (`faminc_tanf' - tanf_earnings_fixed) if earnings_disregard_flag == 1 
  replace disregard = 0 if earnings_disregard_flag == 0

  *** Pass the net income test if gross_earnings - disregard < Net_Income_DA * Net income factor 
  gen pass_net_test =  (`faminc_tanf' / 12 - disregard) <= (net_map * netfactor) if !mi(net_map) & uses_net == 1 
  
  *** 2002 and earlier don't use the DAs 
  gen pass_gross_test_2002 = `faminc_tanf' / 12 <= tanf_gross_elig * grossfactor if !mi(tanf_gross_elig) & !mi(grossfactor) 
  
  * use gross eligibility threshold for the net test   
  gen pass_net_test_2002 = ((`faminc_tanf' / 12) - disregard) <= tanf_gross_elig * netfactor if !mi(tanf_gross_elig) & !mi(netfactor) 

  * if missing state, assume that they are in a state that only uses the gross test and have them use the median da1
  preserve
      collapse (p50) median_da1 = da1 median_gross_elig = tanf_gross_elig [aw=`wt'], by(year)
      tempfile medians
      save `medians'
  restore
  merge m:1 year using `medians', nogen   
  
  * the modal factor if used is 1.85, so that is the imputed factor for people w/ missing state or other tanf information 
  local imputed_gross_factor = 1.85 
  gen pass_gross_test_imp = (`faminc_tanf' / 12) <= median_da1 * `imputed_gross_factor'
  gen pass_gross_test_imp_2002 = (`faminc_tanf' / 12) <= median_gross_elig * `imputed_gross_factor'
  
	* Asset test
  
  * only count as being above the asset threshold if positive evidence of being above
  * assume vehicles are fully exempt -> note there are 9 millions, these will never bind 
  gen above_asset = max(0,`wsav') > tanf_asset if !mi(tanf_asset) 
  
  /***************************************/
  /* * construct eligibility simulation  */
  /***************************************/
  * must pass a gross test, or a net test
  * and then have a child, and pass the asset test, and not have been present for 6 years on the program 
  
  * main: after 2002 
  gen eligsim_tanf = (pass_gross_test == 1 | uses_gross == 0) & (pass_net_test == 1 | uses_net == 0 ) & `anychild' == 1 & (above_asset == 0) & tanf_rolling_sum <= 2 if year > 2002

  * 2002 and earlier have different eligibility thresholds
  replace eligsim_tanf = (pass_gross_test_2002 == 1 | uses_gross == 0) & (pass_net_test_2002 == 1 | uses_net == 0 ) & `anychild' == 1 & (above_asset == 0) & tanf_rolling_sum <= 2 if year <= 2002 

  * if you do not observe EITHER a net OR a gross test (e.g., missing state) then assume they are like the median state
  replace eligsim_tanf = pass_gross_test_imp == 1  & `anychild' == 1 & (above_asset == 0) & tanf_rolling_sum <= 2 if year > 2002 & uses_net != 1 & uses_gross != 1
  replace eligsim_tanf = pass_gross_test_imp_2002 == 1 & `anychild' == 1 & (above_asset == 0) & tanf_rolling_sum <= 2 if year <= 2002 & uses_net != 1 & uses_gross != 1


  drop _mt_*
  
  * Exclude immigrants under PRWORA
	merge m:1 `state' using "$dir/data/eligsim/tanf_immigrant.dta", nogen keep(1 3)
	
  * Disqualify non-qualified aliens
  replace eligsim_tanf = 0 if `qualified_imm' == 1 & `citizen' == 0

  * Disqualify if early arrival and state bans early arrivals
  replace eligsim_tanf = 0 if tanf_imm_early == 0 & `yr_us' < 1996 & `qualified_imm' == 1	 & `citizen' == 0

  * Disqualify if late and state bans late arrivals, pre 5 year wait (2002)
  replace eligsim_tanf = 0 if tanf_imm_late == 0 & (`yr_us' >= 1996 | missing(yr_us)) & `year' >= 1996 & `year' < 2003 & `qualified_imm' == 1 & `citizen' == 0	

  * Disqualify if late and state bans late arrivals, post 5 year wait (2002)
  replace eligsim_tanf = 0 if tanf_imm_late2011 == 0 & ((`yr_us' >= 1996 & `year' - `yr_us' < 5) | missing(yr_us)) & `year' >= 2003 & `year' < 2011 & `qualified_imm' == 1 & `citizen' == 0		
  replace eligsim_tanf = 0 if tanf_imm_late2011 == 0 & ((`yr_us' >= 1996 & `year' - `yr_us' < 5) | missing(yr_us)) & `year' >= 2003 & `year' >= 2011 & `qualified_imm' == 1 & `citizen' == 0		

end
