/***************************************************************************
* Appendix Figure A13, Panel A and B: Demographic Heterogeneity in Self-Targeting (CEX), SNAP and Medicaid
*
* Description: This script creates figures that display estimates of the predictive effects of transfer receipt on consumption rank or 
* lifetime-income rank, conditional on current-income rank. We split the sample by education
* (less than HS, HS degree, some college, BA only, more than BA), race/ethnicity (non-Hispanic white, non-Hispanic
* black, Hispanic, non-Hispanic other), and by "at-risk" group (single parent, disabled, non-native English speaker, car
* non-owner). The data are simulated-eligible members of the listed demographic group in the CEX. Panels A and B
* show results SNAP and Medicaid respectively. Confidence intervals are at the 95-percent level and reflect clustered
* standard errors by household. The black "x" point indicates the population-average self-targeting coefficient and
* consumption rank.
*
*
* Inputs:
* - CEX-based dataset: `"$dir/data/cex/raw/workfile.dta"`
*
* Outputs:
* - Figures:
* - `"$dir/figures/het_self_targeting_cex_tanf.gph"`
* - `"$dir/figures/het_self_targeting_cex_ha.gph"`
* - `"$dir/figures/het_self_targeting_cex_medicaid.gph"`
* - `"$dir/figures/het_self_targeting_cex_anytransfer.gph"`
* - Corresponding `.pdf` files (generated from `.gph` files)
* - Note that only the SNAP and Medicaid figures are shown in the paper. Other figures are kept for reference.
*
***************************************************************************/

* Load data

	do code/settings

	use "$dir/data/cex/raw/workfile.dta", clear
	
	* Limit sample to having ranks
	keep if !missing(rk_cons) & !missing(rk_inc)
	
	egen anytransfer = rowmax(snap medicaid housing_assistance ssi tanf)
	egen eligsim_anytransfer = rowmax(eligsim_snap eligsim_medicaid eligsim_housing_assistance eligsim_ssi eligsim_tanf)
		
	rename eligsim_housing eligsim_ha
	rename housing_assistance ha
		
	gen outcome = ln(cons_adj)
	
* Create basis spline for rk_current_eq
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_inc) p(3) refpts(`refpts') omit(0)
		
* Run regressions	

	foreach p in anytransfer snap medicaid ha tanf {
		
		mat scat_`p' = J(20,3,.)
				
			* By education
			forvalues k = 1/5 {
							
				reg outcome `p' bs_rk* if eligsim_`p'==1 & educ==`k' [pw=finlwt21], cl(cuid)
				mat scat_`p'[`k',2] = _b[`p']
				mat scat_`p'[`k',3] = _se[`p']
				
				summ cons_adj if educ==`k' [aw=finlwt21]
				mat scat_`p'[`k',1] = r(mean)

			
			}
			
			* By race/ethnicity
			
			forvalues k = 1/4 {
											
				reg outcome `p' bs_rk* if eligsim_`p'==1 & race==`k' [pw=finlwt21], cl(cuid)
				mat scat_`p'[5+`k',2] = _b[`p']
				mat scat_`p'[5+`k',3] = _se[`p']
				
				summ cons_adj if race==`k' [aw=finlwt21]
				mat scat_`p'[5+`k',1] = r(mean)

			
			}
			
			* Special concern groups
					
				* Single parents
								
					reg outcome `p' bs_rk* if eligsim_`p'==1 & single_parent==1 [pw=finlwt21], cl(cuid)
					mat scat_`p'[10,2] = _b[`p']
					mat scat_`p'[10,3] = _se[`p']
					
					summ cons_adj if single_parent==1 [aw=finlwt21]
					mat scat_`p'[10,1] = r(mean)
					
				* People with disabilities
				
					reg outcome `p' bs_rk* if eligsim_`p'==1 & disabled==1 [pw=finlwt21], cl(cuid)
					mat scat_`p'[11,2] = _b[`p']
					mat scat_`p'[11,3] = _se[`p']
					
					summ cons_adj if disabled==1 [aw=finlwt21]
					mat scat_`p'[11,1] = r(mean)
				
				* Car non-owners
				
					reg outcome `p' bs_rk* if eligsim_`p'==1 & owns_car==0 [pw=finlwt21], cl(cuid)
					mat scat_`p'[12,2] = _b[`p']
					mat scat_`p'[12,3] = _se[`p']
					
					summ cons_adj if owns_car==0 [aw=finlwt21]
					mat scat_`p'[12,1] = r(mean)
					
			* Main estimate
			
				reg outcome `p' bs_rk* if eligsim_`p'==1 [pw=finlwt21], cl(cuid)
				mat scat_`p'[13,2] = _b[`p']
				
				summ cons_adj [aw=finlwt21]
				mat scat_`p'[13,1] = r(mean)
				
			
	}
				
				
* Display results

	foreach p in anytransfer snap medicaid ha tanf {

		clear
		svmat scat_`p'

		* Add labels
		gen grouplabel = ""
		replace grouplabel = "Less than HS" if _n==1
		replace grouplabel = "HS Degree" if _n==2
		replace grouplabel = "Some College" if _n==3
		replace grouplabel = "BA Degree" if _n==4
		replace grouplabel = "More than BA" if _n==5
		replace grouplabel = "Non-Hispanic White" if _n==6
		replace grouplabel = "Non-Hispanic Black" if _n==7
		replace grouplabel = "Hispanic" if _n==8
		replace grouplabel = "Non-Hispanic Other" if _n==9
		replace grouplabel = "Single Parent" if _n==10
		replace grouplabel = "Disabled" if _n==11
		replace grouplabel = "Car Non-Owner" if _n==12
		
		* Add error bands
		gen lo = scat_`p'2 - 1.96*scat_`p'3
		gen hi = scat_`p'2 + 1.96*scat_`p'3
		
		tw scatter scat_`p'2 scat_`p'1 if inrange(_n,1,5), mlabel(group) color(navy) mlabcolor(navy) mlabsize(medsmall) || ///
			rcap lo hi scat_`p'1 if inrange(_n,1,5), color(navy%50) || ///
			scatter scat_`p'2 scat_`p'1 if inrange(_n,6,9), mlabel(group) msymbol(square) color(maroon) mlabcolor(maroon) mlabsize(medsmall) || ///
			rcap lo hi scat_`p'1 if inrange(_n,6,9), color(maroon%50) || ///
			scatter scat_`p'2 scat_`p'1 if inrange(_n,10,12), mlabel(group) msymbol(diamond) color(green) mlabcolor(green) mlabsize(medsmall) || ///
			rcap lo hi scat_`p'1 if inrange(_n,10,12), color(green%50) || ///
			scatter scat_`p'2 scat_`p'1 if _n==13, mlabel(group) msymbol(X) color(black) || ///
		, xscale(range(25000(250000)100000)) xlabel(25000(25000)100000,format(%8.0fc)) ///
		ylabel(,format(%3.1f)) legend(region(lwidth(none)) col(3) order(1 "Education" 3 "Race & Ethnicity" 5 "At-Risk Groups") size(medsmall)) ///
		graphregion(color(white)) xtitle("Group Average Consumption Level", size(medsmall)) ///
		ytitle("Self-Targeting Coefficient in Group", size(medsmall)) ylabel(,nogrid angle(horizontal)) ///
		name(het_`p',replace)
		
		graph display het_`p', ysize(4) xsize(6)
		
		graph save "$dir/figures/het_self_targeting_cex_`p'.gph", replace
		gr export "$dir/figures/het_self_targeting_cex_`p'.pdf", replace
		
	}
