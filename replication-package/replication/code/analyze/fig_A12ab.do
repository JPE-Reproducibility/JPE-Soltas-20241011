/***************************************************************************
 * Appendix Figure A12, Panel A and B: Demographic Heterogeneity in Self-Targeting (PSID), SNAP and Medicaid
 *
 * Description:
 * This script estimates the predictive effect of transfer receipt on
 * consumption rank for various demographic subgroups. The analysis examines
 * heterogeneity in self-targeting by education level, race/ethnicity, and
 * several at-risk groups (non-native English speakers, single parents,
 * individuals with disabilities, and car non-owners). For each subgroup and
 * transfer program, the script runs regressions and stores the
 * coefficient of the transfer variable and its standard error. It also
 * calculates the average consumption level for each group. The script then
 * generates scatter plots displaying the self-targeting coefficients against
 * the average consumption level for each group, with error bars representing
 * 95% confidence intervals. A population-average self-targeting coefficient
 * and consumption rank are also included in the plots.
 *
 * Inputs:
 * - PSID-based dataset: `"$dir/data/psid_base"`
 *
 * Outputs:
 * - Figures:
 * - `"$dir/figures/het_self_targeting_snap.gph"`
 * - `"$dir/figures/het_self_targeting_medicaid.gph"`
 * - `"$dir/figures/het_self_targeting_ha.gph"`
 * - `"$dir/figures/het_self_targeting_wic.gph"`
 * - `"$dir/figures/het_self_targeting_liheap.gph"`
 * - `"$dir/figures/het_self_targeting_schoolmeals.gph"`
 * - `"$dir/figures/het_self_targeting_tanf.gph"`
 * - Corresponding `.pdf` files (generated from `.gph` files)
 * - Note that only the SNAP and Medicaid figures are shown in the paper. Other figures are kept for reference.
 ***************************************************************************/


* Load data

	do code/settings

	use "$dir/data/psid_base", clear
	
	run_all_eligsims
	
	* Limit sample to having ranks
	keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

	rename eligsim_housing eligsim_ha
	rename housing_assistance ha
		
* Housekeeping

		* Recode edcat
		replace edcat = 1 if edcat==0
	
		* Recode race_eth 
		gen race_eth = 0 if white == 1 & hispanic == 0
		replace race_eth = 1 if black == 1 & hispanic == 0
		replace race_eth = 2 if hispanic == 1
		replace race_eth = 3 if white == 0 & black == 0 & hispanic == 0
		
		* Outcome
		cap gen equivalence_scale = ((hhsize-nchild)+0.7*nchild)^0.7
		cap gen eq_cons_real = consumption_real / equivalence_scale
		cap gen outcome = ln(eq_cons_real)
	
* Create basis spline for rk_current_eq
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
		
* Run regressions	

	foreach p in snap medicaid ha wic liheap schoolmeals tanf {
		
		mat scat_`p' = J(20,3,.)
				
			* By edcat
			forvalues k = 1/5 {
							
				reg outcome `p' bs_rk* if eligsim_`p'==1 & edcat==`k' [pw=wtfam], cl(famid_orig)
				mat scat_`p'[`k',2] = _b[`p']
				mat scat_`p'[`k',3] = _se[`p']
				
				summ eq_cons_real if edcat==`k' [aw=wtfam]
				mat scat_`p'[`k',1] = r(mean)

			
			}
			
			* By race/ethnicity
			
			forvalues k = 0/3 {
											
				reg outcome `p' bs_rk* if eligsim_`p'==1 & race_eth==`k' [pw=wtfam], cl(famid_orig)
				mat scat_`p'[6+`k',2] = _b[`p']
				mat scat_`p'[6+`k',3] = _se[`p']
				
				summ eq_cons_real if race_eth==`k' [aw=wtfam]
				mat scat_`p'[6+`k',1] = r(mean)

			
			}
			
			* Special concern groups
			
				* Non-native English speakers
								
					capture gen non_native_english = lang != 1 if !missing(lang)
				
					reg outcome `p' bs_rk* if eligsim_`p'==1 & non_native_english==1 [pw=wtfam], cl(famid_orig)
					mat scat_`p'[10,2] = _b[`p']
					mat scat_`p'[10,3] = _se[`p']
					
					summ eq_cons_real if non_native_english==1 [aw=wtfam]
					mat scat_`p'[10,1] = r(mean)
					
				* Single parents
				
					capture gen nadults = hhsize - nchild
					capture gen single_parent = nadults == 1 & nchild > 0 & !missing(nchild)
				
					reg outcome `p' bs_rk* if eligsim_`p'==1 & single_parent==1 [pw=wtfam], cl(famid_orig)
					mat scat_`p'[11,2] = _b[`p']
					mat scat_`p'[11,3] = _se[`p']
					
					summ eq_cons_real if single_parent==1 [aw=wtfam]
					mat scat_`p'[11,1] = r(mean)
					
				* People with disabilities
				
					reg outcome `p' bs_rk* if eligsim_`p'==1 & disabled==1 [pw=wtfam], cl(famid_orig)
					mat scat_`p'[12,2] = _b[`p']
					mat scat_`p'[12,3] = _se[`p']
					
					summ eq_cons_real if disabled==1 [aw=wtfam]
					mat scat_`p'[12,1] = r(mean)
				
				* Car non-owners
				
					reg outcome `p' bs_rk* if eligsim_`p'==1 & owncar==0 [pw=wtfam], cl(famid_orig)
					mat scat_`p'[13,2] = _b[`p']
					mat scat_`p'[13,3] = _se[`p']
					
					summ eq_cons_real if owncar==0 [aw=wtfam]
					mat scat_`p'[13,1] = r(mean)
					
			* Main estimate
			
				reg outcome `p' bs_rk* if eligsim_`p'==1 [pw=wtfam], cl(famid_orig)
				mat scat_`p'[14,2] = _b[`p']
				
				summ eq_cons_real [aw=wtfam]
				mat scat_`p'[14,1] = r(mean)
				
			
	}
				
				
* Display results

	foreach p in snap medicaid ha wic liheap schoolmeals tanf {

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
		replace grouplabel = "Non-Native English Speaker" if _n==10
		replace grouplabel = "Single Parent" if _n==11
		replace grouplabel = "Disabled" if _n==12
		replace grouplabel = "Car Non-Owner" if _n==13
		
		* Add error bands
		gen lo = scat_`p'2 - 1.96*scat_`p'3
		gen hi = scat_`p'2 + 1.96*scat_`p'3
		
		tw scatter scat_`p'2 scat_`p'1 if inrange(_n,1,5), mlabel(group) color(navy) mlabcolor(navy) mlabsize(medsmall) || ///
			rcap lo hi scat_`p'1 if inrange(_n,1,5), color(navy%50) || ///
			scatter scat_`p'2 scat_`p'1 if inrange(_n,6,9), mlabel(group) msymbol(square) color(maroon) mlabcolor(maroon) mlabsize(medsmall) || ///
			rcap lo hi scat_`p'1 if inrange(_n,6,9), color(maroon%50) || ///
			scatter scat_`p'2 scat_`p'1 if inrange(_n,10,13), mlabel(group) msymbol(diamond) color(green) mlabcolor(green) mlabsize(medsmall) || ///
			rcap lo hi scat_`p'1 if inrange(_n,10,13), color(green%50) || ///
			scatter scat_`p'2 scat_`p'1 if _n==14, mlabel(group) msymbol(X) color(black) || ///
		, xscale(range(10000(10000)50000)) xlabel(10000(10000)50000,format(%8.0fc)) ///
		ylabel(,format(%3.1f)) legend(region(lwidth(none)) col(3) order(1 "Education" 3 "Race & Ethnicity" 5 "At-Risk Groups") size(medsmall)) ///
		graphregion(color(white)) xtitle("Group Average Consumption Level", size(medsmall)) ///
		ytitle("Self-Targeting Coefficient in Group", size(medsmall)) ylabel(,nogrid angle(horizontal)) ///
		name(het_`p',replace)
		
		graph display het_`p', ysize(4) xsize(6)
		
		graph save "$dir/figures/het_self_targeting_`p'.gph", replace
		gr export "$dir/figures/het_self_targeting_`p'.pdf", replace
		
	}
