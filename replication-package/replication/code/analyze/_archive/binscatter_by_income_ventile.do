
* Settings

	qui do code/settings.do
	
	discard
	adopath + "$dir/code"
	adopath + "$dir/code/eligsim"

	do "$dir/code/stata-tex.do"
	set scheme simplescheme
	
* Load data 

	use "$dir/data/psid_base", clear
	
	* Create basis spline for rk_current_eq
		
		* Create list
		local refpts 0 10 25 50 100
		
		* Create basis spline
		frencurv, gen(bs_rk) x(rk_current_eq) p(3) refpts(`refpts') omit(0)
		
	* log spending or income variables to address outliers 
	gen ln_faminc = ln(faminct_real+1)
	gen ln_famearn = ln(famearn_real+1)
	gen ln_housing_exp = ln(housing_exp+1)
	gen ln_utility_exp = ln(utility_exp+1)
	gen ln_earnings = ln(earnings_real+1 )
	gen ln_wsav = ln(wsav_real+1)
	gen ln_wcar = ln(wcar_real+1)

	qui run_all_eligsims
	qui get_dollar_shares
	ren *housing_assistance* *ha*

  keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

	* parameterize the eligiblity function for each variable 
	global allvars i.state i.year i.hhsize c.ln_faminc fpl i.age i.age_youngest i.nchild c.ln_famearn c.ln_utility_exp c.ln_earn c.wks_unemp i.why_unemp c.ln_wsav c.ln_wcar i.disabled 
	global medicaidvars i.state#i.year i.hhsize ln_faminc fpl i.age i.age_youngest i.nchild i.ssi
	global snapvars i.state i.year i.hhsize ln_faminc ln_famearn fpl hhsize#c.ln_faminc#c.fpl i.hhsize#c.ln_famearn#c.fpl i.hhsize#c.ln_housing_exp#c.fpl
	global liheapvars i.state i.year ln_faminc i.hhsize ln_utility_exp
	global ssivars ln_earnings ln_faminc ln_famearn i.hhsize i.nchild ln_wsav ln_wcar i.disabled i.year
	global wicvars ln_faminc fpl i.snap i.tanf i.medicaid
	global havars i.state i.hhsize i.year ln_faminc ln_wsav 
	global tanfvars i.state i.year i.hhsize ln_faminc i.anychild ln_wcar ln_wsav

/****************************************/
/* * get imputed eligibility variables  */
/****************************************/
foreach prog in snap medicaid liheap schoolmeals ssi wic ha tanf { 

    * generate an imputed eligibility variable 
    cap drop imp_elig_`prog'
	gen imp_elig_`prog' = eligsim_`prog'
	replace imp_elig_`prog' = 1 if `prog' == 1      

      * partial 
      local threshold_low = 10
      local threshold_high = 50 

      cap drop imp_part_`prog' 
      gen imp_part_`prog' = eligsim_`prog'
      replace imp_part_`prog' = 1 if rk_current_eq < `threshold_low'
      
      cap drop max_rk_current_eq 
      bys id (year): egen max_rk_current_eq = max(rk_current_eq)
      bys id (year): replace imp_part_`prog' = 0 if max_rk_current_eq > `threshold_high' & !mi(max_rk_current_eq) 

}

save "$dir/data/tmp/prepped_for_main_reg", replace


/*********/
/* cdfs  */
/*********/
use  "$dir/data/tmp/prepped_for_main_reg", clear

* first do cdf in bottom 20% 
keep if rk_current_eq <= 20
gen cdf_ranker = snap if eligsim_snap == 1 
replace cdf_ranker = 2 if eligsim_snap == 0

cap drop ecdf
bys cdf_ranker (rk_c_current_eq): gen ecdf = _n / _N 

gr twoway ///
    (function y = 0.01*x, lpattern(dash) range(0 100) )  /// 
(line ecdf rk_c_current_eq if snap == 0 & eligsim_snap == 1, subtitle("Empirical CDF of consumption" "(bottom 20% of income only)", position(11) justification(left) margin(-10 0 0 0) size(large)) ///
    lwidth(thick) color(white) sort lpattern(J)) /// 
(line ecdf rk_c_current_eq if snap == 1 & eligsim_snap == 1, color(white) xtitle("Consumption rank") ///
    lwidth(thick) sort lpattern(J)) ///
(line ecdf rk_c_current_eq if eligsim_snap == 0, color(gray) xtitle("Consumption rank in full distribution" , size(large) ) ///
    xlab(,labsize(large) ) xsize(5) ysize(5) lwidth(thick) legend(off) ylab(#5, labsize(large)) sort lpattern(J)  ///
    text(0.6 70 "Not eligible for SNAP", box lcolor(white) fcolor(white) size(large) color(gray)) ///
    text(0.4 30 "Not on SNAP", size(large) place(e) color(none) ) ///
    text(1 2 "On SNAP (eligible)", size(large) place(e) color(none) ) ) ///
      (pcarrowi 0.44 33 0.72 33, color(none) plotregion(margin(b=0 t=5 l=0))  )    ///  
    
gr export figures/ecdf_snap_1.pdf, replace

gr twoway ///
    (function y = 0.01*x, lpattern(dash) range(0 100) )    ///
(line ecdf rk_c_current_eq if snap == 0 & eligsim_snap == 1, subtitle("Empirical CDF of consumption" "(bottom 20% of income only)", position(11) margin(-10 0 0 0) justification(left) size(large)) /// 
lwidth(thick)     color(${orange}) sort lpattern(J)) /// 
(line ecdf rk_c_current_eq if snap == 1 & eligsim_snap == 1, color(white) xtitle("Consumption rank") ///
lwidth(thick)     sort lpattern(J)) ///
(line ecdf rk_c_current_eq if eligsim_snap == 0, color(gray) xtitle("Consumption rank in full distribution" , size(large) ) ///
    legend(off) ylab(#5, labsize(large)) sort lpattern(J)  ///
xlab(,labsize(large) ) xsize(5) ysize(5) lwidth(thick)     ///
    text(0.6 70 "Not eligible for SNAP", box lcolor(white) fcolor(white) size(large) color(gray)) ///
    text(0.4 30 "Not on SNAP (eligible)", place(e) box fcolor(white) lcolor(white) size(large) color(${orange}) ) ///
    text(1 2 "On SNAP (eligible)", size(large) place(e) color(none) ) ) ///
     (pcarrowi 0.44 33 0.72 33, plotregion(margin(b=0 t=5 l=0)) color(${orange}))    ///  
    
gr export figures/ecdf_snap_2.pdf, replace


gr twoway ///
    (function y = 0.01*x, lpattern(dash) range(0 100) ) ///     
(line ecdf rk_c_current_eq if snap == 0 & eligsim_snap == 1, subtitle("Empirical CDF of consumption" "(bottom 20% of income only)", position(11) margin(-10 0 0 0) justification(left) size(large)) ///
lwidth(thick)     color(${orange}) sort lpattern(J)) /// 
(line ecdf rk_c_current_eq if snap == 1 & eligsim_snap == 1, color(${navy}) xtitle("Consumption rank") ///
xlab(,labsize(large) ) xsize(5) ysize(5) lwidth(thick)     sort lpattern(J)) ///
(line ecdf rk_c_current_eq if eligsim_snap == 0, color(gray) xtitle("Consumption rank in full distribution", size(large) ) ///
lwidth(thick)     legend(off) ylab(#5, labsize(large)) sort lpattern(J)  ///
    text(0.6 70 "Not eligible for SNAP", box lcolor(white) fcolor(white) size(large) color(gray)) ///
    text(0.4 30 "Not on SNAP (eligible)", box fcolor(white) lcolor(white)  size(large) place(e) color(${orange}) ) ///
    text(1.02 2 "On SNAP (eligible)", size(large) place(e) color(${navy}) ) ) ///
   (pcarrowi 0.44 33 0.72 33, plotregion(margin(b=0 t=5 l=0)) color(${orange}))    ///  
    
gr export figures/ecdf_snap.pdf, replace

* and restrict to bottom 10%
keep if rk_current_eq <= 10

cap drop ecdf
bys cdf_ranker (rk_c_current_eq): gen ecdf = _n / _N 
 
gr twoway ///
    (function y = 0.01*x, lpattern(dash) range(0 100) ) ///         
(line ecdf rk_c_current_eq if snap == 0 & eligsim_snap == 1, subtitle("Empirical CDF of consumption" "(bottom 10% of income only)", position(11) margin(-10 0 0 0) justification(left) size(large)) /// 
     lwidth(thick)     color(${orange}) sort lpattern(J)) /// 
(line ecdf rk_c_current_eq if snap == 1 & eligsim_snap == 1, color(${navy}) xtitle("Consumption rank") ///
     lwidth(thick)     sort lpattern(J)) ///
(line ecdf rk_c_current_eq if eligsim_snap == 0, color(gray) xtitle("Consumption rank in full distribution" , size(large) ) ///
xlab(,labsize(large) ) xsize(5) ysize(5)     lwidth(thick)     legend(off) ylab(#5, labsize(large)) sort lpattern(J)  ///
    text(0.50 75 "Not eligible for SNAP", size(large) box fcolor(white) lcolor(white) color(gray)) ///
    text(0.35 30 "Not on SNAP (eligible)", size(large) box fcolor(white) lcolor(white)  place(e) color(${orange}) ) ///
    text(1.02 2 "On SNAP (eligible)", size(large) place(e) color(${navy}) ) ) ///
  (pcarrowi 0.39 33 0.75 33, plotregion(margin(b=0 t=5 l=0)) color(${orange}))    ///  
    
gr export figures/ecdf_snap_bottom10.pdf, replace
 
/***********/
/* regressions  */
/***********/
foreach prog in snap medicaid ha tanf wic schoolmeals liheap ssi { 
use  "$dir/data/tmp/prepped_for_main_reg", clear 
cap drop income_ventile 
egen income_ventile = cut(rk_current_eq), at(0(5)55)
tab income_ventile
replace income_ventile = 50 if mi(income_ventile) & rk_current_eq >= 55

keep if eligsim_`prog' == 1
drop if mi(`prog') 
collapse (mean) rk_c_current_eq (semean) rk_c_se = rk_c_current_eq (sum) wtfam, by(income_ventile `prog') 

    global navy `" "51 122 183" "'
    global green `" "92 184 92" "'
    global ltblue `" "91 192 222" "'
    global red `" "217 83 79" "'
    global orange `" "240 173 78" "'


local wicname WIC
local snapname SNAP
local schoolmealsname "School Meals"
local ssiname SSI
local tanfname TANF
local medicaidname Medicaid
local liheapname LIHEAP
local haname Housing 


* plot nonparametric distribution  
twoway /// 
(scatter rk_c_current_eq income if `prog' == 0 [w=wtfam], ///
    msize(medsmall) msymbol(S) mcolor(${orange}) ) /// 
(scatter rk_c_current_eq income if `prog' == 1 [w=wtfam], ///
    plotregion(margin(l=10 b=0)) msize(medsmall) msymbol(O) ytitle(" " )  subtitle("Average consumption rank by income bin", orientation(horizontal) placement(top) pos(11) size(large) margin(-50 0 0 0 ) ) ///
      xtitle("Equivalized current income rank", size(large)) ///
    ylab(0(10)50) xlab(0 "[0,5)" 5 "[5,10)" 10 "[10,15)" 15 "[15,20)" 20 "[20,25)" 25 "[25,30)" 30 "[30,35)" 35 "[35,40)" ///
    40 "[40,45)" 45 "[45,50)" 50 "{&ge}50", angle(45) ) legend(off) mcolor(${navy}) ///
    text(35 5 "Not on ``prog'name'", size(large) color($orange) ) ///
    text(10 30 "On ``prog'name'", size(large) color($navy) ) ) 

gr export figures/binscatter_cons_distrib_`prog'.pdf, replace

* plot nonparametric distribution  - for combining 
twoway  ///
(scatter rk_c_current_eq income if `prog' == 0, ///
    title(``prog'name') msize(medsmall) msymbol(S) mcolor(${orange}) ) ///      
(scatter rk_c_current_eq income if `prog' == 1, ///
    plotregion(margin(l=2 b=0)) msize(medsmall) msymbol(O) ytitle("Avg consumption rank",  ) ///
      xtitle("Current income rank",) ///
    ylab(0(10)70,labsize(small)) xlab(0(10)40 50 "{&ge}50", labsize(small)) legend(off) mcolor(${navy}) ///
    xsize(5) ysize(5) text(50 18 "Not on ``prog'name'", size(small) color($orange) ) ///
    text(10 30 "On ``prog'name'", size(small) color($navy) ) name(`prog', replace) ) 
  

* have the diff at one cell appear 
sum rk_c_current_eq if income == 15 & `prog' == 0
local y0 = `r(mean)'
sum rk_c_current_eq if income == 15 & `prog' == 1
local y1 = `r(mean)'
local diff: di %3.1fc `=abs(`y0'-`y1')' 
  
twoway /// 
(scatter rk_c_current_eq income if `prog' == 0 [w=wtfam], ///
    msize(medsmall) msymbol(Sh) mcolor(${orange}) ) /// 
(scatter rk_c_current_eq income if `prog' == 1 [w=wtfam], ///
    plotregion(margin(l=10 b=0)) msize(medsmall) msymbol(Oh) ytitle(" " )  subtitle("Average consumption rank by income bin", orientation(horizontal) placement(top) pos(11) size(large) margin(-50 0 0 0 ) ) /// 
      xtitle("Equivalized current income rank", size(large)) ///
    ylab(0(10)50) xlab(0 "[0,5)" 5 "[5,10)" 10 "[10,15)" 15 "[15,20)" 20 "[20,25)" 25 "[25,30)" 30 "[30,35)" 35 "[35,40)" ///
    40 "[40,45)" 45 "[45,50)" 50 "{&ge}50", angle(45) ) legend(off) mcolor(${navy}) ///
    text(35 5 "Not on ``prog'name'", size(large) color($orange) ) ///
    text(10 30 "On ``prog'name'", size(large) color($navy) ) )  ///
(pcarrowi `y0' 15 `y1' 15, color(black)) ///
(pcarrowi `y1' 15 `y0' 15, color(black) ) 
    
gr export figures/binscatter_cons_distrib_`prog'_1.pdf, replace

twoway /// 
(scatter rk_c_current_eq income if `prog' == 0 [w=wtfam], ///
    msize(medsmall) msymbol(Sh) mcolor(${orange}) ) /// 
(scatter rk_c_current_eq income if `prog' == 1 [w=wtfam], ///
    plotregion(margin(l=10 b=0)) msize(medsmall) msymbol(Oh) ytitle(" " )  subtitle("Average consumption rank by income bin", orientation(horizontal) placement(top) pos(11) size(large) margin(-50 0 0 0 ) ) /// 
      xtitle("Equivalized current income rank", size(large)) ///
    ylab(0(10)50) xlab(0 "[0,5)" 5 "[5,10)" 10 "[10,15)" 15 "[15,20)" 20 "[20,25)" 25 "[25,30)" 30 "[30,35)" 35 "[35,40)" ///
    40 "[40,45)" 45 "[45,50)" 50 "{&ge}50", angle(45) ) legend(off) mcolor(${navy}) ///
    text(35 5 "Not on ``prog'name'", size(large) color($orange) ) ///
    text(10 30 "On ``prog'name'", size(large) color($navy) )  ///
    text(`=2' 10 ///
    "Cell-level {&beta} = `diff'", placement(e))  )   ///
(pcarrowi `y0' 15 `y1' 15, color(black)) ///
(pcarrowi `y1' 15 `y0' 15, color(black) ) 
    
gr export figures/binscatter_cons_distrib_`prog'_2.pdf, replace
}

gr combine snap medicaid ha tanf wic schoolmeals liheap ssi, ycommon xcommon col(4) common
gr export figures/combined_bs_distrib.pdf, replace 


* categorize by consumption ventile
use  "$dir/data/tmp/prepped_for_main_reg", clear
binsreg medicaid rk_c_current_eq rk_current_eq if rk_c_current_eq < 50 & eligsim_medicaid == 1, savedata(figures/bs_data_medicaid_tu) replace randcut(1)
use figures/bs_data_medicaid_tu, clear

scatter dots_fit dots_x, mcolor(black) msymbol(O) ytitle(" ") ///
    ylab(#5)  xtitle("Consumption rank", size(large)) ///
    subtitle("Average Medicaid take-up rates", orientation(horizontal) ///
    placement(top) pos(11) size(large) margin(-50 0 0 0 ) ) 

gr export figures/bs_medicaid_tu.pdf, replace 



cap drop income_ventile 
egen income_ventile = cut(rk_current_eq), at(0(5)55)
tab income_ventile
replace income_ventile = 50 if mi(income_ventile) & rk_current_eq >= 55



