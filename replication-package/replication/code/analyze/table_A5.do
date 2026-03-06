/***************************************************************************
 * Appendix Table A5: Food Insecurity and SNAP Receipt (PSID)
 * 
 * Description:
 * This script analyzes the relationship between food security (as measured by the variable fsecmon)
 * and the receipt of SNAP benefits. The analysis considers both baseline and simulated eligibility 
 * for transfer programs, controlling for various consumption rank categories and time effects. 
 * It includes different regression specifications: baseline, baseline with continuous months, pooled, 
 * and within person-year, with and without simulated eligibility adjustments. Results are stored in 
 * CSV format and then converted into LaTeX tables for presentation.
 * 
 * Inputs:
 * - PSID data (`"$dir/data/psid_base"`)
 * - Eligibility simulation results (via `run_all_eligsims`)
 * - Stata-TeX helper and settings scripts (`code/stata-tex.do`, `code/settings`)
 * 
 * Outputs:
 * - CSV file with regression results (`"$dir/tables/data/snap_by_month.csv"`)
 * - LaTeX tables for monthly SNAP analysis (`"$dir/tables/output/snap_by_month_final.tex"`)
 ***************************************************************************/ 

* Settings

	qui do code/settings.do
	
	discard
	adopath + "$dir/code"
	adopath + "$dir/code/eligsim"

	do "$dir/code/stata-tex.do"
	
* Load data 

	use "$dir/data/psid_base", clear
	
	* Create basis spline for rk_current_eq
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
		
		qui run_all_eligsims
		keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)
		
		gegen fsecmonavg = mean(fsecmon*), by(id year)

		keep wtfam fsecmon* snap* id year bs_rk* wtfam eligsim_snap famid_orig
		reshape long fsecmon snap_m, i(id year) j(month)
		replace snap_months = snap_months/12
		
* Regression specifications
cd "$dir/tables/data"

	* All people
	
		summ fsecmonavg [aw=wtfam]
		insert_into_file using snap_by_month.csv, key(fsecmonavg_all) value(`r(mean)') format(%6.3f)
	
		* Baseline spec
		reghdfe fsecmonavg snap bs_rk* [pw=wtfam], cl(famid_orig) a(year#month)
		store_est_tpl using snap_by_month.csv, coef(snap) name(snap01) all format(%6.3fc) 
		
		* Baseline spec - cts months
		reghdfe fsecmonavg snap_months bs_rk* [pw=wtfam], cl(famid_orig) a(year#month)
		store_est_tpl using snap_by_month.csv, coef(snap) name(snap02) all format(%6.3fc)
		
		* Pooled 
		reghdfe fsecmon snap_m bs_rk* [pw=wtfam], cl(famid_orig) a(year#month)
		store_est_tpl using snap_by_month.csv, coef(snap) name(snap03) all format(%6.3fc)
		
		* Within person-year
		reghdfe fsecmon snap_m bs_rk* [pw=wtfam], cl(famid_orig) a(id#year year#month)
		store_est_tpl using snap_by_month.csv, coef(snap) name(snap04) all format(%6.3fc)
		
	* Simulated eligible
	
		summ fsecmonavg if eligsim_snap==1 [aw=wtfam]
		insert_into_file using snap_by_month.csv, key(fsecmonavg_elig) value(`r(mean)') format(%6.3f)
			
		* Baseline spec
		reghdfe fsecmonavg snap bs_rk* if eligsim_snap==1 [pw=wtfam], cl(famid_orig) a(year#month)
		store_est_tpl using snap_by_month.csv, coef(snap) name(snap11) all format(%6.3fc) 
		
		* Baseline spec - cts months
		reghdfe fsecmonavg snap_months bs_rk* if eligsim_snap==1 [pw=wtfam], cl(famid_orig) a(year#month)
		store_est_tpl using snap_by_month.csv, coef(snap) name(snap12) all format(%6.3fc) 
		
		* Pooled 
		reghdfe fsecmon snap_m bs_rk* if eligsim_snap==1 [pw=wtfam], cl(famid_orig) a(year#month)
		store_est_tpl using snap_by_month.csv, coef(snap) name(snap13) all format(%6.3fc) 
		
		* Within person-year
		reghdfe fsecmon snap_m bs_rk* if eligsim_snap==1 [pw=wtfam], cl(famid_orig) a(id#year year#month)
		store_est_tpl using snap_by_month.csv, coef(snap) name(snap14) all format(%6.3fc) 
		
*** Save tables

	cd "$dir/tables/data"

	cat snap_by_month.csv
	
	cd "$dir/code"

	table_from_tpl, t(../tables/template/snap_by_month_template.tex) ///
					r(../tables/data/snap_by_month.csv) ///
					o(../tables/output/snap_by_month_final.tex) 
						
	cd "$dir"
	
	exit

cd ../

