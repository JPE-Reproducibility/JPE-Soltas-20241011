/***************************************************************************
 * Appendix Figure A32: Bounds Analysis of Self-Targeting on Consumption: Measurement Error Simulations
 * 
 * Description:
 * This script predicts lifetime rank conditional on current rank
 * 
 * 
 * Inputs:
 * - Harmonized PSID data (`"$dir/data/psid_base"`)
 * - Eligibility simulation results (via `run_all_eligsims`) 
 * 
 * Outputs:
 * - CSV file with regression results (`"$dir/figures/adversarial_reg.csv"`)
 * - PDF figure (`"$dir/figures/adversarial_reg.pdf"`)
 ***************************************************************************/

* Include settings and configurations
do code/settings.do

discard
adopath + "$dir/code"
do "$dir/code/stata-tex.do"
set scheme simplescheme

******* Load data 

* Load the dataset
use "$dir/data/psid_base", clear

* Set random seed for reproducibility
set seed 188888
set sortseed 188718

* Define reference points for basis spline
local refpts 0 10 25 50 100

* Create basis spline
frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)

*************************************
* Adversarially try to break these  *
*************************************

* Prepare to write results to a .csv file
cap file close fh
file open fh using "$dir/figures/adversarial_reg.csv", write replace
file write fh "prog,simulation,spec,regtype,b,se" _n

* Loop over simulations and specifications
forv simulation = 0(1)30 { 
	
	* Need simulation-run specific speeds
	set seed `=188888 + `simulation''
	
    foreach spec in 1 0.5 {

        foreach prog in snap medicaid liheap schoolmeals ssi wic housing_assistance tanf {
        
            preserve

            * Compute the take-up share of people below 50 pct
            sum `prog' [aw=wtfam] if rk_c_current_eq < 50
            local mean = `r(mean)' 
            cap drop rand 
            gen rand = runiform()

            * Adjust `prog` values based on simulation and specification
            replace `prog' = 1 if rk_c_current_eq > 100-`simulation' & rand < `r(mean)' * `spec' 
            replace `prog' = 0 if rk_c_current_eq > 100-`simulation' & rand >= `r(mean)' * `spec' 

            di "`prog'"

            * Perform raw regression
            qui reg rk_c_current_eq bs_rk* `prog' [pw=wtfam], cl(famid_orig)

            * Capture regression coefficients and standard errors
            local b = _b[`prog']
            local se = _se[`prog']
            file write fh "`prog',`simulation',`spec',raw," (`b') "," (`se') _n

            restore 
        }
    }
}
cap file close fh

**********
* Graph  *
**********

* Import the results for graphing
import delimited using "$dir/figures/adversarial_reg.csv", clear

* Generate confidence intervals
gen hi = b + 1.96 * se 
gen lo = b - 1.96 * se 

* Define program names for labeling
foreach prog in snap medicaid liheap schoolmeals ssi wic housing_assistance tanf {
    local wicname WIC
    local snapname SNAP
    local schoolmealsname "School Meals"
    local ssiname SSI
    local tanfname TANF
    local medicaidname Medicaid
    local liheapname LIHEAP
    local housing_assistancename Housing 
  
    * Create graphs for each program
    gr twoway ///
        ( rarea hi lo sim if prog == "`prog'" & spec == 0.5, color(%30) msize(large) lwidth(none) fcolor(gray) ) ///      
        ( rarea hi lo sim if prog == "`prog'" & spec == 1, color(%30) lwidth(none) msize(large) fcolor(ltblue) ) ///      
        ( line b simulation if prog == "`prog'" & spec == 1, lpattern(line) color(midblue) msymbol(O) ///
          xtitle(" ") ytitle(" ") ) ///
        ( line b sim if prog == "`prog'" & spec == 0.5, lpattern(line) color(black) msymbol(S) ///
          xtitle(" ") ytitle(" ") ///
          xlab(0(10)30) ylab(-20(5)10) yline(0) legend(order(3 4) title("Simulation:", ///
          size(medsmall)) col(2) ///
          lab(3 "Same take-up as bottom 50%") ///
          lab(4 "Half take-up as bottom 50%") ring(1) ) name(`prog', replace) title(``prog'name') )
}

* Combine all graphs into one legend
grc1leg snap medicaid liheap schoolmeals ssi wic housing_assistance tanf, xcomm ///
    rows(2) ///
    l1title("Estimated coefficient", size(small)) ///
    b1title("Simulated receipt among the top {it:x} percentile", size(small)) ring(1)

* Export the combined graph as a PDF
gr export "$dir/figures/adversarial_reg.pdf", replace
