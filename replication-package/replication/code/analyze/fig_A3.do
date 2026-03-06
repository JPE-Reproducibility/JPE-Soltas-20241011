/***************************************************************************
* Appendix Figure A3: Relationship Between Consumption and Income by Transfer Receipt and Eligibility
*
* Description:
* This file creates figure that displays binned scatterplots of the relationship
* between equivalized real household consumption and income, splitting the data by
* transfer receipt and eligibility. Each panel presents the consumption–income 
* relationship for three groups (recipients in blue circles, eligible nonrecipients 
* in red triangles, and ineligibles in green squares) for a specific transfer.
* 
* Inputs:
* - PSID base dataset ("$dir/data/psid_base")
* - Eligibility simulation results (generated via run_all_eligsims)
* 
* Outputs:
* - CSV file with regression results ("$dir/figures/participation_reg_ui_wc_ss.csv")
* - Coefficient plot comparing effects by program, outcome, and employment status:
*   "$dir/figures/participation_reg_ui_wc_ss.pdf"
 ***************************************************************************/

* Settings

	do code/settings.do
	do "$dir/code/stata-tex.do"
	
	discard
	set scheme s2color

* Load data 

	use "$dir/data/psid_base", clear

	qui run_all_eligsims
	qui get_dollar_shares

	rename eligsim_housing eligsim_ha
	rename housing_assistance ha
	
	* Generate equivalized household income
	gen eq_income_real = faminct_real / equivalence_scale

* Generate binned scatterplots
	
	egen bin_eq_income_real = cut(eq_income_real) if eq_income_real<40000, group(10)

	foreach p in snap medicaid ha tanf ssi schoolmeals wic liheap {
		
		if "`p'" == "snap" {
			local pname "SNAP"
		}
		if "`p'" == "medicaid" {
			local pname "Medicaid"
		}
		if "`p'" == "ha" {
			local pname "Housing Assistance"
		}
		if "`p'" == "tanf" {
			local pname "TANF"
		}
		if "`p'" == "ssi" {
			local pname "SSI"
		}
		if "`p'" == "wic" {
			local pname "WIC"
		}
		if "`p'" == "schoolmeals" {
			local pname "School Meals"
		}
		if "`p'" == "liheap" {
			local pname "LIHEAP"
		}
		
		preserve
		
		gcollapse (mean) eq_income_real=eq_income_real eq_cons_real=eq_cons_real (rawsum) wtfam  if eq_income_real<40000 [pw=wtfam], by(bin_eq_income_real `p' eligsim_`p')
		
		replace eq_income_real = eq_income_real/1000
		replace eq_cons_real = eq_cons_real/1000
		
		tw 	scatter eq_cons_real eq_income_real if `p'==1 & eligsim_`p'==1, color($navy) || ///
			scatter eq_cons_real eq_income_real if `p'==0 & eligsim_`p'==1, msymbol(T) color($orange) || ///
			scatter eq_cons_real eq_income_real if `p'==0 & eligsim_`p'==0, msymbol(S)  color($green) || ///
			lfit eq_income_real eq_income_real if `p'==0, xlabel(,labsize(medlarge)) ///
			lcolor(gs9) graphregion(color(white) margin(2 2 2 2)) ylabel(,nogrid angle(horizontal) labsize(medlarge)) ///
			subtitle("`pname'", color(black) size(medlarge)) ///
			legend(order(1 "Recipients" 2 "Eligible Nonrecipients" 3 "Ineligibles") region(lwidth(none)) rows(1) size(small)) name(gr_`p',replace)
		
		restore
	
	}
	
	grc1leg gr_snap gr_medicaid gr_ha gr_tanf gr_ssi gr_schoolmeals gr_wic gr_liheap, graphregion(color(white)) ///
		subtitle("Mean Equivalized Consumption (Thousands of 2020 Dollars)", size(small) pos(11) span) ///
		b1title("Mean Equivalized Income (Thousands of 2020 Dollars)", size(small)) ///
		rows(2) cols(4) name(gr_combined,replace)
		
	gr display gr_combined, xsize(7.5) ysize(5)
	graph export "$dir/figures/friedman_binscatter.pdf", as(pdf) replace

	
	
