/***************************************************************************
* Appendix Table A14: Simulated Eligibility and Receipt Rates
* 
* Description:
* This script generates Table A14, which reports simulated eligibility and 
* actual receipt rates by program in the PSID. For each transfer program, 
* it estimates:
*  - the share of recipients who are eligible (Pr(Eligible | Receipt))
*  - the share of non-recipients who are eligible (Pr(Eligible | No Receipt))
*  - the share of eligibles who receive the program (Pr(Receipt | Eligible))
*  - the share of non-eligibles who receive the program (Pr(Receipt | Not Eligible))
*
* These conditional shares are estimated using weighted linear regressions 
* with no covariates. Results are exported to a CSV and used to populate 
* a LaTeX table via a custom template.
* 
* Inputs:
* - PSID data with simulated eligibility indicators (`"$dir/data/psid_base"`)
* - Stata-TeX helper and settings scripts (`code/stata-tex.do`, `code/settings`)
* - Eligibility simulation script (`run_all_eligsims`)
* 
* Outputs:
* - CSV of conditional receipt and eligibility rates (`tables/data/elig_share.csv`)
* - LaTeX-formatted table (`tables/output/elig_share.tex`)
 ***************************************************************************/
 
* Load data

  qui do code/stata-tex.do
	qui do code/settings

	use "$dir/data/psid_base", clear

****** Prepare data	

* Simulate eligibility

run_all_eligsims
rename housing_assistance ha
rename eligsim_housing_assistance eligsim_ha

drop if mi(rk_lifetime_eq) | mi(rk_current_eq) | mi(rk_c_current_eq) 

* make tables

foreach var in snap liheap schoolmeals ssi medicaid wic ha tanf {

  reg `var' if eligsim_`var' == 1 [pw = wtfam]  
  insert_into_file using "tables/data/elig_share.csv", key(p_r_e_`var') value(`=_b[_cons]') format(%5.2f)
  
  reg `var' if eligsim_`var' == 0 [pw = wtfam] 
  insert_into_file using "tables/data/elig_share.csv", key(p_r_ne_`var') value(`=_b[_cons]') format(%5.2f)

  reg eligsim_`var' if `var' == 1 [pw = wtfam] 
  insert_into_file using "tables/data/elig_share.csv", key(p_e_r_`var') value(`=_b[_cons]') format(%5.2f)

  reg eligsim_`var' if `var' == 0 [pw = wtfam] 
  insert_into_file using "tables/data/elig_share.csv", key(p_e_nr_`var') value(`=_b[_cons]') format(%5.2f)
  
}


cd code 
table_from_tpl, t(../tables/template/eligibility_share_template.tex) r(../tables/data/elig_share.csv) o(../tables/output/elig_share.tex) 
cd ../
