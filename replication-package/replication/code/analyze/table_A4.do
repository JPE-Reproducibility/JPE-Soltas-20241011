/***************************************************************************
 * Self-Targeting on Additional Measures of Need
 * Appendix Table A4
 * 
 * Description:
 * This script estimates the relationship between transfer program receipt and 
 * alternative indicators of household need, including low education, disability, 
 * single parenthood, race, wage, savings, and poor health. Each outcome is 
 * regressed on an indicator for program receipt, controlling flexibly for 
 * income rank using cubic basis splines and conditioning on simulated eligibility. 
 * Specification 2 additionally controls for consumption rank.
 * 
 * Mean outcomes are computed among the bottom quintile of the income distribution.
 * Standard errors are clustered at the household level.
 * 
 * Inputs:
 * - PSID-based dataset: `"$dir/data/psid_base"`
 * - Simulated eligibility indicators: `run_all_eligsims`
 * 
 * Outputs:
 * - CSV of estimates: `tables/data/other_outcomes.csv`
 * - CSV of estimates with consumption controls: `tables/data/other_outcomes_c.csv`
 * - LaTeX tables:
 *     - `tables/output/other_outcomes.tex`
 *     - `tables/output/other_outcomes_c.tex`
 ***************************************************************************/

qui do code/settings.do

* preamble 	

use "$dir/data/psid_base", clear

keep if inrange(age, 18,65)

/******************************/
/* * generate other outcomes  */
/******************************/
cap drop *tmp
cap drop single_mom
cap drop low_ed

* education
gen low_ed = edcat == 1 if edcat != 0 & !missing(edcat)
gen single_parent_tmp = (hhsize == nchild + 1) & nchild > 0 if !mi(hhsize) & !mi(nchild) 
bys famid year: egen single_parent = max(single_parent_tmp)
gen pos_savings = wsav_nom > 0 if !missing(wsav_nom) 

gen fphealth = inlist(health,4,5) if !missing(health)

/**************************/
/* * get equivalized wage */
/**************************/

* total hours in the hh 
bys famid year: egen total_hours = total(hours)
gen faminct_eq = faminct_real / equivalence_scale

* wage is not done by equivalized hours - just by equivalized income by total hours
cap drop hours 
gen hours = total_hours / (hhsize - nchild)
replace hours = max(hours, 0)
gen wage = faminct_eq / (hours * 50)

* Calculate winsorized log wage
gen lwage = ln(wage)
summ lwage, d
replace lwage = r(p1) if lwage < r(p1)
replace lwage = r(p99) if lwage > r(p99) & !missing(lwage)
		
* Create list
local refpts 0 10 25 50 100

* Create basis spline for both income and consumption 
frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
frencurv, gen(cs_rk) x(rk_c_current_eq) p(3) refpts(`refpts') omit(0)

* Generate eligibility variables
run_all_eligsims

rename housing_assistance ha
ren eligsim_housing_assistance eligsim_ha


cd "$dir" 
* run regression
foreach outcome in low_ed disabled single_parent nonwhite wage pos_savings {

  foreach transfer in snap medicaid ha wic ssi schoolmeals tanf liheap {
			
  	reg `outcome' `transfer' bs_rk* if eligsim_`transfer'==1 [pw=wtfam], cl(famid_orig)
  	store_est_tpl using "tables/data/other_outcomes.csv", coef(`transfer') name(`outcome'_`transfer') all			
   
  }
  
  * get mean in the bottom quintile of current income 
  sum `outcome' if rk_current_eq < 20 [aw=wtfam] 
  insert_into_file using "tables/data/other_outcomes.csv", key(`outcome'_mean) value(`r(mean)') format(%5.3f)
  
}

/*********************************************************************/
/* Specification 1: alternate outcomes, controlling for income rank  */
/*********************************************************************/
cd "$dir" 
* run regression
foreach outcome in lwage low_ed disabled single_parent nonwhite pos_savings fphealth {
  local digits = 3
  if "`outcome'" == "wage" local digits = 1   

  foreach transfer in snap medicaid ha wic ssi schoolmeals tanf liheap {
			
  	reg `outcome' `transfer' bs_rk* if eligsim_`transfer'==1 [pw=wtfam], cl(famid_orig)
  	store_est_tpl using "tables/data/other_outcomes.csv", coef(`transfer') name(`outcome'_`transfer') all			
   
  }
  
  * get mean in the bottom quintile of current income 
  sum `outcome' if rk_current_eq < 20 [aw=wtfam]
  insert_into_file using "tables/data/other_outcomes.csv", key(`outcome'_mean) value(`r(mean)') format(%5.`digits'f)
  
}


/***************************************************************/
/* Specification 2: additionally control for consumption rank  */
/***************************************************************/
cd "$dir" 
* run regression
foreach outcome in low_ed disabled single_parent nonwhite wage {
  local digits = 3
  if "`outcome'" == "wage" local digits = 1   

  foreach transfer in snap medicaid ha wic ssi schoolmeals tanf liheap {
			
  	reg `outcome' `transfer' bs_rk* cs_rk* if eligsim_`transfer'==1 [pw=wtfam], cl(famid_orig)
  	store_est_tpl using "tables/data/other_outcomes_c.csv", coef(`transfer') name(`outcome'_`transfer') all			
   
  }
  
  * get mean in the bottom quintile of current income 
  sum `outcome' if rk_current_eq < 20 [aw=wtfam] 
  insert_into_file using "tables/data/other_outcomes.csv", key(`outcome'_mean) value(`r(mean)') format(%5.`digits'f)
  
}

* first table: do not control 	for consumption rank
cap erase "../tables/output/other_outcomes.tex"

cd "$dir/code"

table_from_tpl, t("../tables/template/other_outcomes_template.tex") ///
			r("../tables/data/other_outcomes.csv") ///
			o("../tables/output/other_outcomes.tex") 

* second table: control  for consumption rank
cap erase "../tables/output/other_outcomes_c.tex"

cd "$dir/code"

table_from_tpl, t("../tables/template/other_outcomes_template.tex") ///
			r("../tables/data/other_outcomes_c.csv") ///
			o("../tables/output/other_outcomes_c.tex") 
 
 				
	cd "$dir"
