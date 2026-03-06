/***************************************************************************
 * Figure A10, Panel A and B: Self-Targeting by Age, Consumption and Lifetime Income
 *
 * Description:
 * This script estimates the predictive effect of transfer receipt on household
 * consumption rank, conditional on current-income rank. The analysis is
 * conducted for the full sample of simulated eligibles and then separately
 * for five age groups (16-25, 26-35, 36-45, 46-55, 56-65). The script focuses
 * on the receipt of Avg. Transfer, SNAP, and Medicaid, generating a CSV file
 * with the regression estimates and producing figures visualizing these effects
 * and their confidence intervals across age groups.
 *
 * Inputs:
 * - PSID-based dataset: `"$dir/data/psid_base"`
 *
 * Outputs:
 * - CSV of estimates: `"$dir/figures/participation_reg_robustness_age.csv"`
 * - Figures:
 * - `"$dir/figures/eligregs_robustness_age_c.pdf"` (Effect on Consumption Rank by Age)
 * - `"$dir/figures/eligregs_robustness_age_li.pdf"` (Effect on Lifetime Income Rank by Age)
 ***************************************************************************/


* Settings

	do code/settings.do
	do "$dir/code/stata-tex.do"
	
	discard
    set scheme simplescheme 

* Load data 

	use "$dir/data/psid_base", clear
		
	* Create basis spline for rk_current_eq
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
	
		run_all_eligsims

* Predict eligibility from demographics

	keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

	* Generate eligibility
	ren *housing_assistance* *ha*
	
	
* write a .csv
cap file close fh
file open fh using  "$dir/figures/participation_reg_robustness_age.csv", write replace
file write fh "prog,spec,age,b,se" _n

foreach prog in snap medicaid wic liheap schoolmeals ha ssi tanf {
	
	foreach spec in "_c" "_li" {
	
	* All sample
	if "`spec'" != "_c" {
        qui reg rk_lifetime_eq bs_rk* `prog' if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
		qui reg rk_c_current_eq bs_rk* `prog' if eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) 
	  }
	
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`spec',0," (`b') "," (`se') _n
		
		* By age   
	forvalues a = 16(10)56 {
		if "`spec'" != "_c" {
		qui reg rk_lifetime_eq `prog' bs_rk* if inrange(age,`a',`a'+10) & eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
	qui reg rk_c_current_eq `prog' bs_rk*  if inrange(age,`a',`a'+10) & eligsim_`prog'==1 [pw=wtfam], cl(famid_orig) 
	  }

	  
	local b = _b[`prog']
	local se = _se[`prog']
	file write fh "`prog',`spec'," (`a') "," (`b') "," (`se') _n
		}
}
}


* Run self-targeting regression pooled across programs

	rename (snap medicaid liheap wic tanf ssi ha schoolmeals) (r_snap r_medicaid r_liheap r_wic r_tanf r_ssi r_ha r_schoolmeals)
	keep r_* id year rk_current_eq rk_c_current_eq rk_lifetime_eq wtfam eligsim_* famid_orig bs_rk* age
	
	reshape long r_ eligsim_, i(id year) j(transfer) string
	
	egen prog = group(transfer)
	
	foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf {
		
		local wtname = "wt_`prog'"
		local wtval = ${`wtname'}
		replace wtfam = wtfam * `wtval'
		
		di "`prog' : `wtval'"
			
	}

foreach spec in _c _li {
	
	* Baseline
	if "`spec'" !== "_c" {
	qui reghdfe rk_c_current_eq i.prog#c.bs_rk* r_ if eligsim_==1 [pw=wtfam], a(prog) cl(famid_orig) 
	}
	if "`spec'" != "_c" {
	qui reghdfe rk_lifetime_eq i.prog#c.bs_rk* r_ if eligsim_==1 [pw=wtfam], a(prog) cl(famid_orig) 
	}
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,`spec',0," (`b') "," (`se') _n
		
	* By age
	forvalues a = 16(10)56 {
		if "`spec'" != "_c" {
		qui reghdfe rk_lifetime_eq r_  if inrange(age,`a',`a'+10) & eligsim_==1 [pw=wtfam], a(prog i.prog#c.bs_rk1 i.prog#c.bs_rk3 i.prog#c.bs_rk4 i.prog#c.bs_rk5 i.prog#c.bs_rk6 i.prog#c.bs_rk7) cl(famid_orig) 
	  }
	  if "`spec'" == "_c" {
	qui reghdfe rk_c_current_eq r_  if inrange(age,`a',`a'+10) & eligsim_==1 [pw=wtfam], a(prog i.prog#c.bs_rk1 i.prog#c.bs_rk3 i.prog#c.bs_rk4 i.prog#c.bs_rk5 i.prog#c.bs_rk6 i.prog#c.bs_rk7) cl(famid_orig) 
	  }
	
	local b = _b[r_]
	local se = _se[r_]
	file write fh "avg,`spec'," (`a') "," (`b') "," (`se') _n
	}

}


cap file close fh

* make plot
	
	foreach spec in "_c" "_li" {
		
	    import delimited using  "$dir/figures/participation_reg_robustness_age.csv", clear
		keep if spec == "`spec'"
		duplicates drop prog spec age, force
		
		gen high = b + 1.96 * se
		gen low = b - 1.96 * se

		bys prog spec (age): gen n = _n
		replace n = 0.5 if age == 0
		replace n = n + 0.25 if prog == "snap"
		replace n = n + 0.5 if prog == "medicaid"

		local avgname {bf:Average}
		local wicname WIC
		local snapname SNAP
		local schoolmealsname "School Meals"
		local ssiname SSI
		local tanfname TANF
		local medicaidname Medicaid
		local liheapname LIHEAP
		local haname Housing
		
		global navy `" "51 122 183" "'
		global green `" "92 184 92" "'
		global ltblue `" "91 192 222" "'
		global red `" "217 83 79" "'
		global orange `" "240 173 78" "'
		
		if spec == "_c" {

			tw (bar b n if prog=="avg" & spec=="_c", ytitle("Predictive Effect of Receipt on Rank") color($navy) xtitle("") yline(0, lcolor(gs3)) legend(rows(1) order(1 "Avg. Transfer" 3 "SNAP" 5 "Medicaid")) xline(1.5, lcolor(gs9) lpattern(dash)) barwidth(0.2) xlabel(0.75 "{bf:18-65}" 2.25 "18-25" 3.25 "24-35" 4.25 "34-45" 5.25 "44-55" 6.25 "54-65") xscale(range(0.25 7)) ylabel(-20(10)0) yscale(range(-20 0))) || (rcap high low n if prog=="avg" & spec=="_c", color($navy) yscale(range(-20 0))) || (bar b n if prog=="snap" & spec=="_c", color($green) barwidth(0.2) yscale(range(-20 0))) || (rcap high low n if prog=="snap" & spec=="_c", color($green) yscale(range(-20 0))) || (bar b n if prog=="medicaid" & spec=="_c", color($orange) barwidth(0.2) yscale(range(-20 0))) || (rcap high low n if prog=="medicaid" & spec=="_c", color($orange) yscale(range(-20 0))) 
			  
		}
		
		if spec == "_li" {

			tw (bar b n if prog=="avg" & spec=="_li", ytitle("Predictive Effect of Receipt on Rank") color($navy) xtitle("") yline(0, lcolor(gs3)) legend(rows(1) order(1 "Avg. Transfer" 3 "SNAP" 5 "Medicaid")) xline(1.5, lcolor(gs9) lpattern(dash)) barwidth(0.2) xlabel(0.75 "{bf:18-65}" 2.25 "18-25" 3.25 "24-35" 4.25 "34-45" 5.25 "44-55" 6.25 "54-65") xscale(range(0.25 7)) ylabel(-20(10)0) yscale(range(-20 0))) || (rcap high low n if prog=="avg" & spec=="_li", color($navy) yscale(range(-20 0))) || (bar b n if prog=="snap" & spec=="_li", color($green) barwidth(0.2) yscale(range(-20 0))) || (rcap high low n if prog=="snap" & spec=="_li", color($green) yscale(range(-20 0))) || (bar b n if prog=="medicaid" & spec=="_li", color($orange) barwidth(0.2) yscale(range(-20 0))) || (rcap high low n if prog=="medicaid" & spec=="_li", color($orange) yscale(range(-20 0))) 
			  
		}

		gr export "$dir/figures/eligregs_robustness_age`spec'.pdf", replace
		
	}
