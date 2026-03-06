/***************************************************************************

This code collects sub-programs used frequently across code files.

***************************************************************************/

* Run all eligsims
capture program drop run_all_eligsims
program define run_all_eligsims

	eligsim_snap, state(state) year(year) faminc(faminc_nom)  famearn(famearn_nom) hhsize(hhsize) fpl(fpl) housing_exp(housing_exp) wsav(wsav_nom) wcar(wcar_nom) yr_us(yr_us) qualified_imm(qualified_imm) citizen(citizen) cpi(cpi)
	eligsim_liheap, state(state) year(year) faminc(faminc_nom)  hhsize(hhsize) utility_exp(utility_exp) wsav(wsav_nom) qualified_imm(qualified_imm)
	eligsim_ui, wks_unemp(wks_unemp) why_unemploy(why_unemploy) earnings(earnings_nom) state(state) year(year)
	eligsim_ssi, faminc(faminc_nom)  famearn(famearn_nom) hhsize(hhsize) nchild(nchild) wsav(wsav_nom) wcar(wcar_nom) disabled(disabled) state(state) year(year) famid(famid) married(married) child_disabled(child_disabled) yr_us(yr_us) qualified_imm(qualified_imm) citizen(citizen) ssi_amt(ssi_amt_hh) cpi(cpi)
	eligsim_medicaid, state(state) year(year) faminc(faminc_nom) fpl(fpl) age(age) age_youngest(age_youngest) nchild(nchild) eligsim_ssi(eligsim_ssi) disabled(disabled) earnings(earnings_nom) health_exp(health_exp) wsav(wsav_nom) married(married) yr_us(yr_us) qualified_imm(qualified_imm) citizen(citizen)
	eligsim_wic, faminc(faminc_nom)  fpl(fpl) snap(snap) tanf(tanf) medicaid(medicaid) age_youngest(age_youngest) age_eldest(age_eldest)
	eligsim_housing_assistance, state(state) year(year) faminc(faminc_nom) hhsize(hhsize) whome(whome_nom) woth(woth_nom) wsav(wsav_nom) famid(famid) qualified_imm(qualified_imm)
	eligsim_tanf, state(state) year(year) hhsize(hhsize) faminc(faminc_nom) anychild(anychild) wcar(wcar_nom) wsav(wsav_nom) qualified_imm(qualified_imm) citizen(citizen) yr_us(yr_us) tanf_amt(tanf_amt_hh) cpi(cpi) id(id) wt(wtfam) 
	eligsim_schoolmeals, state(state) year(year) age_youngest(age_youngest) age_eldest(age_eldest) anychild(anychild) faminc(faminc_nom) fpl(fpl)

end

* Get dollar shares (PSID)
capture program drop get_dollar_shares
program define get_dollar_shares

	cap rename housing_assistance_amt_hh ha_amt_hh

	* get dollar share in each program (note not equivalized bc just adding up shares) - this is in $2019 
	foreach prog in snap wic medicaid liheap ha tanf schoolmeals ssi { 
	  egen total_dollars_`prog' = total(`prog'_amt_hh * wtfam  * hhsize * (year == 2019) )  
	  egen total_wt_`prog' = total(wtfam * hhsize * (year == 2019) )  
	  replace total_dollars_`prog' = total_dollars_`prog' / total_wt_`prog'
	  drop total_wt_`prog'
	}

	* total dollars across programs 
	egen total_dollars = rowtotal(total_dollars*) 

	* total dollars 
	foreach prog in snap wic medicaid liheap ha tanf schoolmeals ssi { 
	  gen float weight_dollars_`prog' = total_dollars_`prog' / total_dollars 
	  summ weight_dollars_`prog'
	  global wt_`prog' = r(mean)
	  drop weight_dollars_`prog' total_dollars_`prog'
	}
	drop total_dollars
	
end

* Get dollar shares (CEX)
capture program drop get_dollar_shares_cex
program define get_dollar_shares_cex

	cap rename amt_housing_assistance amt_ha

	* get dollar share in each program (note not equivalized bc just adding up shares) - this is in $2019
	* No coverage of housing assistance programs in the CEX after 2013, so use final value as substitute
	foreach prog in snap medicaid ha tanf ssi { 
	  egen total_dollars_`prog' = total(amt_`prog' * finlwt21 * hhsize * (year == 2019 | (year == 2013 & "`prog'" == "ha")) )  
	  egen total_wt_`prog' = total(finlwt21 * hhsize * (year == 2019  | (year == 2013 & "`prog'" == "ha")) )  
	  replace total_dollars_`prog' = total_dollars_`prog' / total_wt_`prog'
	  drop total_wt_`prog'
	}

	* total dollars across programs 
	egen total_dollars = rowtotal(total_dollars*) 

	* total dollars 
	foreach prog in snap medicaid ha tanf ssi { 
	  gen float weight_dollars_`prog' = total_dollars_`prog' / total_dollars 
	  summ weight_dollars_`prog'
	  global wt_`prog' = r(mean)
	  drop weight_dollars_`prog' total_dollars_`prog'
	}
	drop total_dollars
	
	rename amt_ha amt_housing_assistance 
	
end


* Compute mobility, eligibility, takeup, and net effects
capture program drop compute_decomp_effects
program define compute_decomp_effects

	syntax, outcome(string) runvar(string)
	* outcome = (amt,sh)
	* runvar = (cons,lifetime)

	foreach p in snap medicaid ha ssi tanf schoolmeals wic liheap {
	
		gen mobility_effect_`p' = `outcome'_`p'_cf - `outcome'_`p'_current
		gen eligibility_effect_`p' = `outcome'_takeup_`p'_cf - `outcome'_`p'_cf
		gen takeup_effect_`p' = `outcome'_`p'_`runvar' - `outcome'_takeup_`p'_cf
		gen net_effect_`p' = `outcome'_`p'_`runvar' - `outcome'_`p'_current
		
	}
	
	if "`outcome'" == "amt" {
					
		gen mobility_effect_totamt = tot_amt_cf - tot_amt_current
		gen eligibility_effect_totamt = tot_amt_takeup_cf - tot_amt_cf
		gen takeup_effect_totamt = tot_amt_`runvar' - tot_amt_takeup_cf
		gen net_effect_totamt = tot_amt_`runvar' - tot_amt_current
		
		gen mobility_effect_cashamt = cash_amt_cf - cash_amt_current
		gen eligibility_effect_cashamt = cash_amt_takeup_cf - cash_amt_cf
		gen takeup_effect_cashamt = cash_amt_`runvar' - cash_amt_takeup_cf
		gen net_effect_cashamt = cash_amt_`runvar' - cash_amt_current
		
	}
		
end

cap program drop clean_decomp
pr define clean_decomp
syntax, outcome(string) runvar(string) case(string)

    * only permit case to be eq - that is how this is presently set up 
    if "`case'" != "eq" {
        di "case must be 'eq'"
        stop 
    }

   * Simulate eligibility		
		run_all_eligsims
		rename eligsim_housing_assistance eligsim_ha

		* Robustness check: impute simulated eligibility for transfer recipients
		if $imputation == 1 {
			foreach v of varlist snap medicaid liheap schoolmeals ssi wic ha tanf {
			replace eligsim_`v' = 1 if `v' == 1
			} 
		}

*** EQUIVALIZED HOUSEHOLDS
		gen x = round(rk_current_eq*10)/10
		drop if missing(rk_c_current_eq) | missing(rk_current_eq)

		foreach p in snap medicaid ha tanf ssi schoolmeals wic liheap {
		
			gegen `outcome'_`p' = mean(`p') [aw=wtfam], by(x)
			gegen `outcome'_takeup_`p' = mean(`p') [aw=wtfam], by(x eligsim_`p')
		
		}

		drop x
		
	* Estimate local linear regressions	

    if "`runvars'" == "cons" keep if !missing(rk_current_eq) & !missing(rk_c_current_eq) & !missing(rk_lifetime_eq)
		if "`runvars'" == "lifetime" keep if !missing(rk_current_eq) & !missing(rk_lifetime_eq) & !missing(rk_c_current_eq)

     gen pct = _n if _n <= 100

end 

* Estimate local linear regressions 
capture program drop estimate_lpolys
program define estimate_lpolys

	syntax, case(string) outcome(string) runvar(string)
	* case = (eq,hh,ind)
	* outcome = (amt,sh)
	* runvar = (cons,lifetime)
	
	if "`runvar'" == "cons" {
		
	foreach p in snap medicaid ha ssi tanf schoolmeals wic liheap {
			
			lpoly `outcome'_`p' rk_current_`case' [aw=wtfam], deg(1) bw(3) gen(`outcome'_`p'_current) at(pct) nograph
			lpoly `outcome'_`p' rk_c_current_`case' [aw=wtfam], deg(1) bw(3) gen(`outcome'_`p'_cf) at(pct) nograph
			lpoly `outcome'_takeup_`p' rk_c_current_`case' [aw=wtfam], deg(1) bw(3) gen(`outcome'_takeup_`p'_cf) at(pct) nograph
			lpoly `p' rk_c_current_`case' [aw=wtfam], deg(1) bw(3) gen(`outcome'_`p'_cons) at(pct) nograph
		
		}
	}
	
	if "`runvar'" == "lifetime" {
		
		foreach p in snap medicaid ha ssi tanf schoolmeals wic liheap {
		
			lpoly `outcome'_`p' rk_current_`case' [aw=wtfam], deg(1) bw(3) gen(`outcome'_`p'_current) at(pct) nograph
			lpoly `outcome'_`p' rk_lifetime_`case' [aw=wtfam], deg(1) bw(3) gen(`outcome'_`p'_cf) at(pct) nograph
			lpoly `outcome'_takeup_`p' rk_lifetime_`case' [aw=wtfam], deg(1) bw(3) gen(`outcome'_takeup_`p'_cf) at(pct) nograph
			lpoly `p' rk_lifetime_`case' [aw=wtfam], deg(1) bw(3) gen(`outcome'_`p'_lifetime) at(pct) nograph
							
		}
	}
	
		* Calculate total/cash amounts
		
		if "`outcome'" == "amt" {
			
			if "`runvar'" == "cons" {
		
			egen tot_amt_current = rowtotal(amt_snap_current amt_medicaid_current amt_ha_current amt_ssi_current amt_tanf_current amt_schoolmeals_current amt_wic_current amt_liheap_current)
			egen tot_amt_cons = rowtotal(amt_snap_cons amt_medicaid_cons amt_ha_cons amt_ssi_cons amt_tanf_cons amt_schoolmeals_cons amt_wic_cons amt_liheap_cons)
			egen tot_amt_cf = rowtotal(amt_snap_cf amt_medicaid_cf amt_ha_cf amt_ssi_cf  amt_tanf_cf amt_schoolmeals_cf amt_wic_cf amt_liheap_cf)
			egen tot_amt_takeup_cf = rowtotal(amt_takeup_snap_cf amt_takeup_medicaid_cf amt_takeup_ha_cf amt_takeup_ssi_cf amt_takeup_tanf_cf amt_takeup_schoolmeals_cf amt_takeup_wic_cf amt_takeup_liheap_cf)
			
			egen cash_amt_current = rowtotal(amt_snap_current amt_ssi_current amt_tanf_current amt_schoolmeals_current amt_liheap_current)
			egen cash_amt_cons = rowtotal(amt_snap_cons amt_ssi_cons amt_tanf_cons amt_schoolmeals_cons amt_liheap_cons)
			egen cash_amt_cf = rowtotal(amt_snap_cf amt_ssi_cf  amt_tanf_cf amt_schoolmeals_cf amt_liheap_cf)
			egen cash_amt_takeup_cf = rowtotal(amt_takeup_snap_cf amt_takeup_ssi_cf amt_takeup_tanf_cf amt_takeup_schoolmeals_cf amt_takeup_liheap_cf)
			
			}
			
			if "`runvar'" == "lifetime" {
				
			egen tot_amt_current = rowtotal(amt_snap_current amt_medicaid_current amt_ha_current amt_ssi_current amt_tanf_current amt_schoolmeals_current amt_wic_current amt_liheap_current)
			egen tot_amt_lifetime = rowtotal(amt_snap_lifetime amt_medicaid_lifetime amt_ha_lifetime amt_ssi_lifetime amt_tanf_lifetime amt_schoolmeals_lifetime amt_wic_lifetime amt_liheap_lifetime)
			egen tot_amt_cf = rowtotal(amt_snap_cf amt_medicaid_cf amt_ha_cf amt_ssi_cf  amt_tanf_cf amt_schoolmeals_cf amt_wic_cf amt_liheap_cf)
			egen tot_amt_takeup_cf = rowtotal(amt_takeup_snap_cf amt_takeup_medicaid_cf amt_takeup_ha_cf amt_takeup_ssi_cf amt_takeup_tanf_cf amt_takeup_schoolmeals_cf amt_takeup_wic_cf amt_takeup_liheap_cf)
			
			egen cash_amt_current = rowtotal(amt_snap_current amt_ssi_current amt_tanf_current amt_schoolmeals_current amt_liheap_current)
			egen cash_amt_lifetime = rowtotal(amt_snap_lifetime amt_ssi_lifetime amt_tanf_lifetime amt_schoolmeals_lifetime amt_liheap_lifetime)
			egen cash_amt_cf = rowtotal(amt_snap_cf amt_ssi_cf  amt_tanf_cf amt_schoolmeals_cf amt_liheap_cf)
			egen cash_amt_takeup_cf = rowtotal(amt_takeup_snap_cf amt_takeup_ssi_cf amt_takeup_tanf_cf amt_takeup_schoolmeals_cf amt_takeup_liheap_cf)
			
			}
		
		}
		
		* Adjust for small numerical issues in lpoly
		
		foreach p in snap medicaid ha ssi tanf schoolmeals wic liheap {
			
			summ `outcome'_`p'_current
			local refmean = r(mean)
			
			summ `outcome'_`p'_cf
			local compmean = r(mean)
			replace `outcome'_`p'_cf = `outcome'_`p'_cf - `compmean' + `refmean'
			
			summ `outcome'_takeup_`p'_cf
			local compmean = r(mean)
			replace `outcome'_takeup_`p'_cf = `outcome'_takeup_`p'_cf - `compmean' + `refmean'
			
			summ `outcome'_`p'_`runvar'
			local compmean = r(mean)
			replace `outcome'_`p'_`runvar' = `outcome'_`p'_`runvar' - `compmean' + `refmean'
				
		}
		
		if "`outcome'" == "amt" {
			foreach p in tot_amt cash_amt {
				
				summ `p'_current
				local refmean = r(mean)
				
				summ `p'_cf
				local compmean = r(mean)
				replace `p'_cf = `p'_cf - `compmean' + `refmean'
				
				summ `p'_takeup_cf
				local compmean = r(mean)
				replace `p'_takeup_cf = `p'_takeup_cf - `compmean' + `refmean'
				
				summ `p'_`runvar'
				local compmean = r(mean)
				replace `p'_`runvar' = `p'_`runvar' - `compmean' + `refmean'
					
			}
		}
		
	end
	
* Make decomposition plots
capture program drop make_decomp_plots
program define make_decomp_plots

	syntax, outcome(string)
	* outcome = (amt,sh)
	
	capture gen zero = 0

	tw 	area net_effect_snap pct, fcolor(ltblue) lwidth(none) || line zero mobility_effect_snap eligibility_effect_snap takeup_effect_snap pct, ///
		lcolor(gs3 midblue navy orange) lwidth(thin medthick medthick medthick) ylab(,nogrid) ///
		ytitle("") xtitle("") legend(region(lwidth(none)) order(3 "Mobility Effect" 4 "Eligibility Effect" 5 "Take-Up Effect" 1 "Net Effect") rows(1) size(small)) ///
		graphregion(lcolor(white) color(white)) yline(0, lstyle(foreground)) name(snap, replace) title("SNAP",color(black))

	tw 	area net_effect_medicaid pct, fcolor(ltblue) lwidth(none) || line zero mobility_effect_medicaid eligibility_effect_medicaid takeup_effect_medicaid pct, ///
		lcolor(gs3 midblue navy orange) lwidth(thin medthick medthick medthick) ylab(,nogrid) ///
		ytitle("") xtitle("") legend(region(lwidth(none)) order(3 "Mobility Effect" 4 "Eligibility Effect" 5 "Take-Up Effect" 1 "Net Effect") rows(1) size(small)) ///
		graphregion(lcolor(white) color(white)) yline(0, lstyle(foreground)) name(medicaid, replace) title("Medicaid",color(black))
	
	tw 	area net_effect_ha pct, fcolor(ltblue) lwidth(none) || line zero mobility_effect_ha eligibility_effect_ha takeup_effect_ha pct, ///
		lcolor(gs3 midblue navy orange) lwidth(thin medthick medthick medthick) ylab(,nogrid) ///
		ytitle("") xtitle("") legend(region(lwidth(none)) order(3 "Mobility Effect" 4 "Eligibility Effect" 5 "Take-Up Effect" 1 "Net Effect") rows(1) size(small)) ///
		graphregion(lcolor(white) color(white)) yline(0, lstyle(foreground)) name(ha, replace) title("Housing Assistance",color(black))

	tw 	area net_effect_ssi pct, fcolor(ltblue) lwidth(none) || line zero mobility_effect_ssi eligibility_effect_ssi takeup_effect_ssi pct, ///
		lcolor(gs3 midblue navy orange) lwidth(thin medthick medthick medthick) ylab(,nogrid) ///
		ytitle("") xtitle("") legend(region(lwidth(none)) order(3 "Mobility Effect" 4 "Eligibility Effect" 5 "Take-Up Effect" 1 "Net Effect") rows(1) size(small)) ///
		graphregion(lcolor(white) color(white)) yline(0, lstyle(foreground)) name(ssi, replace) title("SSI",color(black))
	
	tw 	area net_effect_tanf pct, fcolor(ltblue) lwidth(none) || line zero mobility_effect_tanf eligibility_effect_tanf takeup_effect_tanf pct, ///
		lcolor(gs3 midblue navy orange) lwidth(thin medthick medthick medthick) ylab(,nogrid) ///
		ytitle("") xtitle("") legend(region(lwidth(none)) order(3 "Mobility Effect" 4 "Eligibility Effect" 5 "Take-Up Effect" 1 "Net Effect") rows(1) size(small)) ///
		graphregion(lcolor(white) color(white)) yline(0, lstyle(foreground)) name(tanf, replace) title("TANF",color(black))
		
	tw 	area net_effect_schoolmeals pct, fcolor(ltblue) lwidth(none) || line zero mobility_effect_schoolmeals eligibility_effect_schoolmeals takeup_effect_schoolmeals pct, ///
		lcolor(gs3 midblue navy orange) lwidth(thin medthick medthick medthick) ylab(,nogrid) ///
		ytitle("") xtitle("") legend(region(lwidth(none)) order(3 "Mobility Effect" 4 "Eligibility Effect" 5 "Take-Up Effect" 1 "Net Effect") rows(1) size(small)) ///
		graphregion(lcolor(white) color(white)) yline(0, lstyle(foreground)) name(schoolmeals, replace) title("School Meals",color(black))
		
	tw 	area net_effect_wic pct, fcolor(ltblue) lwidth(none) || line zero mobility_effect_wic eligibility_effect_wic takeup_effect_wic pct, ///
		lcolor(gs3 midblue navy orange) lwidth(thin medthick medthick medthick) ylab(,nogrid) ///
		ytitle("") xtitle("") legend(region(lwidth(none)) order(3 "Mobility Effect" 4 "Eligibility Effect" 5 "Take-Up Effect" 1 "Net Effect") rows(1) size(small)) ///
		graphregion(lcolor(white) color(white)) yline(0, lstyle(foreground)) name(wic, replace) title("WIC",color(black))
		
	tw 	area net_effect_liheap pct, fcolor(ltblue) lwidth(none) || line zero mobility_effect_liheap eligibility_effect_liheap takeup_effect_liheap pct, ///
		lcolor(gs3 midblue navy orange) lwidth(thin medthick medthick medthick) ylab(,nogrid) ///
		ytitle("") xtitle("") legend(region(lwidth(none)) order(3 "Mobility Effect" 4 "Eligibility Effect" 5 "Take-Up Effect" 1 "Net Effect") rows(1) size(small)) ///
		graphregion(lcolor(white) color(white)) yline(0, lstyle(foreground)) name(liheap, replace) title("LIHEAP",color(black))
		
	if "`outcome'" == "amt" {	
		
		tw 	area net_effect_totamt pct, fcolor(ltblue) lwidth(none) || line zero mobility_effect_totamt eligibility_effect_totamt takeup_effect_totamt pct, ///
			lcolor(gs3 midblue navy orange) lwidth(thin medthick medthick medthick) ylab(,nogrid) xtitle("") ytitle("") ///
			legend(region(lwidth(none)) order(3 "Mobility Effect" 4 "Eligibility Effect" 5 "Take-Up Effect" 1 "Net Effect") rows(1) size(small)) ///
			graphregion(lcolor(white) color(white)) yline(0, lstyle(foreground)) name(tot_amt, replace) title("Cash & In-Kind",color(black))

		tw 	area net_effect_cashamt pct, fcolor(ltblue) lwidth(none) || line zero mobility_effect_cashamt eligibility_effect_cashamt takeup_effect_cashamt pct, ///
			lcolor(gs3 midblue navy orange) lwidth(thin medthick medthick medthick) ylab(,nogrid)  xtitle("") ytitle("") ///
			legend(region(lwidth(none)) order(3 "Mobility Effect" 4 "Eligibility Effect" 5 "Take-Up Effect" 1 "Net Effect") rows(1) size(small)) ///
			graphregion(lcolor(white) color(white)) yline(0, lstyle(foreground)) name(cash_amt, replace) title("Cash Only",color(black))
		
	}
	
end


* Make counterfactuals plots
capture program drop make_cf_plots
program define make_cf_plots

	syntax, outcome(string) runvar(string)
	* outcome = (amt,sh)
	* runvar = (cons,lifetime)
	
		tw 	line `outcome'_snap_current `outcome'_snap_`runvar' `outcome'_snap_cf `outcome'_takeup_snap_cf pct, ///
			ylab(,nogrid) ytitle("") xtitle("") legend(order(1 "Income, Actual" 2 "Consumption, Actual" 3 "Consumption, Mobility Only" 4 "Consumption, Mobility & Eligibility") rows(2) size(small)) ///
			graphregion(lcolor(white) color(white)) name(snap, replace) title("SNAP")
			
		tw 	line `outcome'_medicaid_current `outcome'_medicaid_`runvar' `outcome'_medicaid_cf `outcome'_takeup_medicaid_cf pct, ///
			ylab(,nogrid) ytitle("") xtitle("") legend(order(1 "Income, Actual" 2 "Consumption, Actual" 3 "Consumption, Mobility Only" 4 "Consumption, Mobility & Eligibility") rows(2) size(small)) ///
			graphregion(lcolor(white) color(white)) name(medicaid, replace) title("Medicaid")
			
		tw 	line `outcome'_ha_current `outcome'_ha_`runvar' `outcome'_ha_cf `outcome'_takeup_ha_cf pct, ///
			ylab(,nogrid) ytitle("") xtitle("") legend(order(1 "Income, Actual" 2 "Consumption, Actual" 3 "Consumption, Mobility Only" 4 "Consumption, Mobility & Eligibility") rows(2) size(small)) ///
			graphregion(lcolor(white) color(white)) name(ha, replace) title("Housing Assistance")

		tw 	line `outcome'_ssi_current `outcome'_ssi_`runvar' `outcome'_ssi_cf `outcome'_takeup_ssi_cf pct, ///
			ylab(,nogrid) ytitle("") xtitle("") legend(order(1 "Income, Actual" 2 "Consumption, Actual" 3 "Consumption, Mobility Only" 4 "Consumption, Mobility & Eligibility") rows(2) size(small)) ///
			graphregion(lcolor(white) color(white)) name(ssi, replace) title("SSI")

		tw 	line `outcome'_tanf_current `outcome'_tanf_`runvar' `outcome'_tanf_cf `outcome'_takeup_tanf_cf pct, ///
			ylab(,nogrid) ytitle("") xtitle("") legend(order(1 "Income, Actual" 2 "Consumption, Actual" 3 "Consumption, Mobility Only" 4 "Consumption, Mobility & Eligibility") rows(2) size(small)) ///
			graphregion(lcolor(white) color(white)) name(tanf, replace) title("TANF")

		tw 	line `outcome'_schoolmeals_current `outcome'_schoolmeals_`runvar' `outcome'_schoolmeals_cf `outcome'_takeup_schoolmeals_cf pct, ///
			ylab(,nogrid) ytitle("") xtitle("") legend(order(1 "Income, Actual" 2 "Consumption, Actual" 3 "Consumption, Mobility Only" 4 "Consumption, Mobility & Eligibility") rows(2) size(small)) ///
			graphregion(lcolor(white) color(white)) name(schoolmeals, replace) title("School Meals")
			
		tw 	line `outcome'_wic_current `outcome'_wic_`runvar' `outcome'_wic_cf `outcome'_takeup_wic_cf pct, ///
			ylab(,nogrid) ytitle("") xtitle("") legend(order(1 "Income, Actual" 2 "Consumption, Actual" 3 "Consumption, Mobility Only" 4 "Consumption, Mobility & Eligibility") rows(2) size(small)) ///
			graphregion(lcolor(white) color(white)) name(wic, replace) title("WIC")

		tw 	line `outcome'_liheap_current `outcome'_liheap_`runvar' `outcome'_liheap_cf `outcome'_takeup_liheap_cf pct, ///
			ylab(,nogrid) ytitle("") xtitle("") legend(order(1 "Income, Actual" 2 "Consumption, Actual" 3 "Consumption, Mobility Only" 4 "Consumption, Mobility & Eligibility") rows(2) size(small)) ///
			graphregion(lcolor(white) color(white)) name(liheap, replace) title("LIHEAP")

end

