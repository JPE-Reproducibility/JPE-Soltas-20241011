/***************************************************************************
 * Appendix Table A4: Self-Targeting on Additional Measures of Need
 * 
 * Description:
 * This script creates the clean formatted figure from `code/analyze/table_A4_i.do`
 * 
 * Mean outcomes are computed among the bottom quintile of the income distribution.
 * Standard errors are clustered at the household level.
 * 
 * Inputs:
 * - PSID-based dataset: `"$dir/data/psid_base"`
 * - Simulated eligibility indicators: `run_all_eligsims`
 * - Stata-TeX helper and settings scripts (`code/stata-tex.do`, `code/settings`)
 * 
 * Outputs:
 * - CSV of estimates: `tables/data/other_outcomes.csv`
 * - CSV of estimates with consumption controls: `tables/data/other_outcomes_c.csv`
 * - LaTeX tables:
 *     - `tables/output/other_outcomes.tex`
 *     - `tables/output/other_outcomes_c.tex`
 ***************************************************************************/

qui do code/settings.do

/********************/
/* * Clean Figure Version */
/********************/
import delimited using tables/data/other_outcomes.csv, clear

// Step 1: Keep only _beta, _se, and _mean rows
keep if strpos(v1, "_beta") | strpos(v1, "_se") | strpos(v1, "_mean")

// Step 2: Extract outcome and program
gen str30 outcome = ""
gen str20 prog = ""

gen temp = v1
foreach p in snap medicaid ha wic ssi schoolmeals tanf liheap {
    replace temp = subinstr(temp, "_`p'", "", .)
}
gen outcome_prog = regexs(1) if regexm(temp, "(.+)_")
gen prog2 = v1
foreach p in snap medicaid ha wic ssi schoolmeals tanf liheap {
    replace prog2 = "`p'" if strpos(v1, "_`p'")
}
replace prog = prog2
replace outcome = outcome_prog
drop temp outcome_prog prog2

// Step 3: Tag the type
gen type = ""
replace type = "beta" if strpos(v1, "_beta")
replace type = "se" if strpos(v1, "_se")
replace type = "mean" if strpos(v1, "_mean")

// Step 4: Split into means and other types
gen is_mean = (type == "mean")
tempfile means other
preserve
    keep if is_mean
    rename v2 mean_value
    keep outcome mean_value
    save `means'
restore
keep if !is_mean

// Step 5: Merge the mean value onto all rows
merge m:1 outcome using `means', nogen

// Step 6: Reshape
drop v1 is_mean
drop if mi(type) 
reshape wide v2, i(outcome prog) j(type) string

rename v2beta beta
rename v2se se
rename mean_value mean

// Now you have: outcome, prog, beta, se, mean
keep if prog == "snap" 
keep if inlist(outcome,"black","disabled","fphealth","low_ed","single_parent","lwage","pos_savings") 

* get ses 
destring beta se mean , replace
cap drop hi
cap drop low 
gen hi = beta + 1.96 * se
gen low = beta - 1.96 * se



global navy `" "51 122 183" "'
global green `" "92 184 92" "'
global ltblue `" "91 192 222" "'
global red `" "217 83 79" "'
global orange `" "240 173 78" "'

local blackt = "Black"
local disabledt = "Disabled"
local fphealtht = "Poor health"
local low_edt = "HS dropout"
local lwaget = "log(wage)"
local pos_savingst = "Positive savings"
local single_parentt = "Single parent"

cap drop n 
gsort beta
gen n = _n

* auto xlabel 
local ylab = " " 
forv i = 1/`=_N' {
    local ylab = `" `ylab' `i' `" "{bf:``=outcome[`i']'t'}" "avg: `=mean[`i']'" "' "' 
}
di `" `ylab' "' 

cap drop pct
cap drop mlab
gen pct = beta / mean * 100
gen mlab = string(beta) + " (" + string(pct, "%09.0fc") + "%)"

gr twoway ///
    (scatter n beta, mlab(mlab) mlabsize(medlarge) mlabpos(12) mcolor(${navy}) msize(large) msymbol(O) ) /// 
    (rcap hi lo n, horizontal ytitle( " " ) color(${navy}) xtitle("{bf:Self-targeting coefficient in SNAP}", size(large)) ///
    xsize(10) xline(0, lcolor(gray)      lpattern(dash) )  legend(off)  ylab(`ylab', labsize(large)) xlab(,labsize(large)) mcolor(${navy}) ) /// 

gr export figures/other_outcomes.pdf, replace 
