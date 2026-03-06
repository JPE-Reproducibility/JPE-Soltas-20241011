capture program drop trim
program define trim, rclass

	version 16.1
	syntax varlist(min=1 max=100 numeric), [ ll(real 0) ul(numlist max=1) ]
	
	if "`ul'" == "" local ul = . 
	
	quietly {
		
		foreach v of varlist `varlist' {
			
			if !missing(`ll') {
			replace `v' = `ll' if `v'<`ll' & !missing(`v')
			}
			
			if !missing(`ul') {
			replace `v' = `ul' if `v'>`ul' & !missing(`v')
			}
			
		}

	}
	
end

capture program drop lpoly_supt
program define lpoly_supt, rclass

	version 16.1
	syntax varlist(min=2 max=2 numeric) [fweight aweight], bw(real) deg(integer) boot(integer) bootcluster(varname) [ gen(namelist) n(integer 50) ]
	
	quietly {
	
	* Extract dependent and independent variables
	local y : word 1 of `varlist'
	local x : word 2 of `varlist'
	
	local xnew : word 1 of `gen'
	local ypred : word 2 of `gen'
	local lo : word 3 of `gen'
	local hi : word 4 of `gen'
		
	* Save original data to tempfile
	tempfile tmp_original
	save `tmp_original', replace
		
	* Run lpoly
	lpoly `y' `x' [`weight' `exp'], gen(`xnew' `ypred') bw(`bw') deg(`deg') n(`n') nograph
	sort `xnew'
	
	* Extract xnew for lpoly for later use
	preserve
	
	keep `xnew'
	drop if missing(`xnew')
	
	tempfile tmp_pos
	save `tmp_pos', replace
	
	restore
			
	* Store lpoly run on true data (not bsample'd)
	keep `xnew' `ypred'
	drop if missing(`xnew')
	rename `ypred' `ypred'_
	
	tempfile tmp_boot
	save `tmp_boot', replace
	
	}
	
	_dots 0

	* Loop through bootstrap replications
	forvalues i = 1/`boot' {
		
		qui sum `xnew' in `i'
        _dots `i' 0
		
		quietly {
			
		use `tmp_original', clear
		bsample, cluster(`bootcluster')
		
		merge 1:1 _n using `tmp_pos', nogen
		
		lpoly `y' `x' [`weight' `exp'], gen(`ypred') at(`xnew') bw(`bw') deg(`deg') nograph
		
		keep `xnew' `ypred'
		drop if missing(`xnew')
	
		append using `tmp_boot'
		save `tmp_boot', replace
		
		}
		
	}

	quietly {
		
	gen b = 1+floor((_n-1)/`n')
	bys `xnew': egen `ypred'1 = max(`ypred'_)
	drop `ypred'_

	gen stderr_ = (`ypred' - `ypred'1)^2
	bys `xnew': egen stderr = sum(stderr_)
	replace stderr = sqrt(stderr/`boot')
	drop stderr_

	gen t = abs((`ypred'-`ypred'1)/stderr)
	bys b: egen max_t = max(t)

	egen pctile = pctile(max_t), p(97.5)
	summ pctile
	local t_stat = r(mean)

	gen `lo' = `ypred'1 - `t_stat'*stderr
	gen `hi' = `ypred'1 + `t_stat'*stderr
	
	keep if b == 1
	drop b max_t t `ypred' stderr
	
	sort `xnew'
	rename `ypred'1 `ypred'
		
	save `tmp_boot', replace
	
	merge 1:1 _n using `tmp_original', nogen
	
	}

end
