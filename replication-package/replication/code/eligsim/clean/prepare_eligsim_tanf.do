/***************************************************************************
			TANF – Temporary Assistance for Needy Families

Input:
- data/eligsim/snap/immigrant_elig.csv
- data/eligsim/tanf/raw/FamilyMonthlyNeed.xlsx
- data/eligsim/snap/snap_params.csv
- data/eligsim/tanf/raw/GrossNet.xlsx
- data/eligsim/tanf/raw/DAX1.xlsx
- data/eligsim/tanf/raw/DAX2.xlsx
- data/eligsim/tanf/raw/DAX3.xlsx
- data/eligsim/tanf/raw/DAX4.xlsx
- data/eligsim/tanf/raw/DAX5.xlsx
- data/eligsim/tanf/raw/DAX6.xlsx
- data/eligsim/tanf/raw/DAX7.xlsx
- data/eligsim/tanf/raw/DAX8.xlsx
- data/eligsim/tanf/raw/DAX9.xlsx
- data/eligsim/tanf/raw/DAX10.xlsx
- data/eligsim/tanf/raw/DAX11.xlsx
- data/eligsim/tanf/raw/DAX12.xlsx
- data/eligsim/tanf/raw/NetFactor.xlsx
- data/eligsim/tanf/raw/NetIncomeDAMapping.xlsx
- data/eligsim/tanf/raw/GrossFactor.xlsx
- data/eligsim/tanf/raw/GrossIncomeDAMapping.xlsx
- data/eligsim/tanf/raw/DisregardUsedFor.xlsx
- data/eligsim/tanf/raw/EarningsFraction.xlsx
- data/eligsim/tanf/raw/DisregardFixed.xlsx

Output:
- data/eligsim/tanf_immigrant.dta
- data/eligsim/tanf/tanf_need.dta
- data/eligsim/tanf/tanf_gross_standard_adjustment.dta
- data/eligsim/tanf/tanf_asset.dta
- data/eligsim/tanf/da_long.dta
- data/eligsim/tanf/netfactor.dta
- data/eligsim/tanf/netincomedamapping.dta
- data/eligsim/tanf/grossfactor.dta
- data/eligsim/tanf/disregardusedfor.dta
- data/eligsim/tanf/earningsfraction.dta
- data/eligsim/tanf/disregardfixed.dta

***************************************************************************/

* Settings

	do code/settings
	
	set more off
	

capture pr drop append_other_years
pr define append_other_years
syntax, [forward] 
    * append 1996 and previous as = 2002, since no data before that 
    preserve
        keep if year == 2002
        drop year
        tempfile data_2002
        save `data_2002' 
    restore 

    * append previous years 
    forv i = 1996/2001 {
      append using `data_2002' 
      replace year = `i' if mi(year)
    }

  * optionally append 2017 and forward  = 2017, since no data after that   
  if !mi("`forward'") {
    preserve
        keep if year == 2017
        drop year
        tempfile data_2017
        save `data_2017' 
    restore 

    * append future years 
    forv i = 2018/2019 {
      append using `data_2017' 
      replace year = `i' if mi(year)
    }

  }
  
end 

*** Compile immigrant exceptions file

import delimited "$dir/data/eligsim/snap/immigrant_elig.csv", clear

rename state_fips state
keep state tanf*

save "$dir/data/eligsim/tanf_immigrant.dta", replace

********** DEFINE TANF ASSET THRESHOLD
* load monthly need
forv hhsize = 1/12 { 
    import excel using "$dir/data/eligsim/tanf/raw/FamilyMonthlyNeed.xlsx", clear sheet(Fam`hhsize')

    ren A state

    * rename variables 
    local i = 0 
    foreach var of varlist B-Q {
      ren `var' elig`=2017-`i''
      local i = `i' + 1
    }
    drop if mi(state)
  destring elig*, replace
  
   tempfile need_`hhsize'
  save `need_`hhsize''

  count if state == "2017"
  if `r(N)' != 0 di `hhsize'
  if `r(N)' != 0 stop   
}

* append long using family size 
clear
gen hhsize = . 
forv i = 1/12 {
  append using `need_`i''
  replace hhsize = `i' if mi(hhsize) 
}

* reshape long by year 
reshape long elig, i(state hhsize) j(year)

* append 1996 and previous as = 2002, since no data before that
append_other_years, forward 

* extract fips 
statastates, name(state)
drop if _merge == 1
drop _merge 

ren state state_name
ren state_abbrev state_postal
ren state_fips state 

ren elig tanf_gross_elig

save "$dir/data/eligsim/tanf/tanf_need", replace

********* EXTRACT GROSS STANDARD ADJUSTMENT
* = the amount that the monthly standard of need is "adjusted up" 
import excel using "$dir/data/eligsim/tanf/raw/GrossNet.xlsx", clear sheet(GrossRate)
ren A state

* rename variables 
local i = 0 
foreach var of varlist B-Q {
  ren `var' gross_standard`=2017-`i''
  local i = `i' + 1
}
drop if mi(state)
destring gross_standard*, replace 

* reshape long by year 
reshape long gross_standard, i(state) j(year)

* append 1996 and previous as = 2002, since no data before that
append_other_years, forward

* extract fips 
statastates, name(state)
drop if _merge == 1
drop _merge 

ren state state_name
ren state_abbrev state_postal
ren state_fips state 
ren gross_standard tanf_gross_standard

save "$dir/data/eligsim/tanf/tanf_gross_standard_adjustment.dta", replace 

******** ASSET THRESHOLDS 
import excel using "$dir/data/eligsim/tanf/raw/GrossNet.xlsx", clear sheet(Asset)
ren A state

* rename variables 
local i = 0 
foreach var of varlist B-Q {
  ren `var' asset`=2017-`i''
  local i = `i' + 1
}
drop if mi(state)
destring asset*, replace 

* reshape long by year 
reshape long asset, i(state) j(year)

* append 1996 and previous as = 2002, since no data before that
append_other_years, forward 

* extract fips 
statastates, name(state)
drop if _merge == 1
drop _merge 

ren state state_name
ren state_abbrev state_postal
ren state_fips state 
ren asset tanf_asset

assert !mi(tanf_asset)

* these are missing assets 
replace tanf_asset = 9999999 if tanf_asset >= 99999

save "$dir/data/eligsim/tanf/tanf_asset.dta", replace 

/*************/
/* DA variables  */
/*************/
forv hhsize = 1/12 {
  
    import excel using "$dir/data/eligsim/tanf/raw/DAX`hhsize'.xlsx", clear 
    ren A state

    * rename variables 
    local i = 0 
    foreach var of varlist C-V {
      ren `var' da_`=2021-`i''
      local i = `i' + 1
    }
  
    replace state = state[_n-1] if mi(state) 
    drop if mi(state)
    drop if mi(B)
    assert da_2021 != "(Baseline)"
  
  * keep da1 and da2 and make them separate files   
    foreach var in one two {
    
     preserve
        keep if B == "`=strproper("`var'")'"
        if "`var'" == "one"   ren da_* da1_*
        if "`var'" == "two"   ren da_* da2_*
        drop B     
        tempfile da_`var'_`hhsize'
        save `da_`var'_`hhsize''
     restore
    }  
}

* append long using family size
foreach cat in one two { 
    clear
    gen hhsize = . 
    forv i = 1/12 {
      append using `da_`cat'_`i''
      replace hhsize = `i' if mi(hhsize)
    }

    destring da*, replace
    tempfile da_`cat'  
    save `da_`cat''
}

use `da_one'
merge 1:1 hhsize state using `da_two', assert(match) nogen 

reshape long da1_ da2_, i(state hhsize) j(year)
ren (da1_ da2_) (da1 da2)

append_other_years

* extract fips 
statastates, name(state)
drop if _merge == 1
drop _merge 

ren state state_name
ren state_abbrev state_postal
ren state_fips state 

save "$dir/data/eligsim/tanf/da_long", replace

/**************************/
/* net and gross factors  */
/**************************/
foreach sheet in NetFactor NetIncomeDAMapping GrossFactor GrossIncomeDAMapping DisregardUsedFor EarningsFraction DisregardFixed {
import excel using "$dir/data/eligsim/tanf/raw/`sheet'.xlsx", clear
  local name = lower("`sheet'")

    ren A state

    * rename variables 
    local i = 0 
    foreach var of varlist B-U {
      ren `var' `name'_`=2021-`i''
      local i = `i' + 1
    }

    * reshape long   
    drop if mi(state)
    if regexm("`sheet'","DA") == 0 destring `name'_*, replace
    if regexm("`sheet'","DA") == 1 tostring `name'_*, replace

    reshape long `name'_, i(state) j(year)
    append_other_years
  
    statastates, name(state)
    drop if _merge == 1
    drop _merge 

    ren state state_name
    ren state_abbrev state_postal
    ren state_fips state 
  
    save "$dir/data/eligsim/tanf/`name'", replace
}
