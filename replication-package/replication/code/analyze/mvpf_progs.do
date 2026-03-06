/******************************/
* Input for table_3_ii_A17.do
* Purpose: command for creating Appendix Table A17
/******************************/
cap pr drop mvpf_percentiles
pr define mvpf_percentiles, rclass 
  syntax, weighttype(string) [main negishi avgmuelig nm(string)]
  
  /* loop over each program */
  foreach prog in snap ssi wic medicaid liheap ha tanf schoolmeals {
    
    * for negishi weights use the main dataset     
    if mi("`negishi'") use "$dir/data/tmp/emp_mvpf_`weighttype'`nm'_`prog'", clear
    if !mi("`negishi'") use "$dir/data/tmp/emp_mvpf_crramain_`prog'", clear  

    * get total amount in a cell 
    bys rd_rk_c: egen total_pop_pct_c = total(wtfam_`prog')  
    bys id: egen total_pop_pct_l = total(wtfam_`prog') 
    
    * get the avg mu in the lifetime rank 
    bys id: egen double mean_mu = total(marg_util * wtfam_`prog')
    replace mean_mu = mean_mu / total_pop_pct_l     

    * get mean marginal utility within a lifetime rank, weighting using the population weight 
    gen double redist_outcome = social_marg_util * mean_mu  

     * implement the negishi weights if in that loop 
      if !mi("`negishi'") {
        cap drop smmu
      
        replace social_marg_util = 1 / mean_mu
        sum social_marg_util
        summ social_marg_util [aw=wtfam_`prog']
        replace social_marg_util = r(p95) if social_marg_util>r(p95) & !missing(social_marg_util)

        replace welfare_weight = social_marg_util

        gen smmu = social_marg_util * marg_util

        sum smmu [aw=wtfam_`prog'],d
        replace smmu = r(p95) if smmu>r(p95) & !missing(social_marg_util)
      
        }
    
    * basic assert statements 
    assert wtfam_`prog' > 0    
    assert inlist("`weighttype'","crra")
  
  /***********************************************/
  /* counterfactual: rotation of the tax and automatic  */
  /***********************************************/
 	  
    ***** self-targeting term *******
        egen total_N_`prog' = total(wtfam_`prog')
        bys rd_rk_c: egen total_pop_pct_c_`prog' = total(wtfam_`prog')
    
        * get the total weight at each percentile if they take up 
        bys rd_rk_c: egen total_tu_`prog'_c = total(`prog' * wtfam_`prog')

        * get total weight if they take up across percentiles 
        egen total_tu_`prog' = total(total_tu_`prog'_c)

        * mean take-up rate by percentile (code as zero if no eligible population at percentile)
        gen double mean_tu_`prog'_c = total_tu_`prog'_c / total_pop_pct_c_`prog'
       	replace mean_tu_`prog'_c = 0 if mi(mean_tu_`prog'_c)

        * get the variance term, weighting appropriately by wtfam 
        egen double sigma_sq_`prog' = total(mean_tu_`prog'_c * (1-mean_tu_`prog'_c) * wtfam_`prog')
        replace sigma_sq_`prog' = sigma_sq_`prog' / (total_N_`prog')
		
		* get the 'across' variance term, weighting appropriately by wtfam 
        gegen sigma_sq_`prog'_across = variance(mean_tu_`prog'_c) [aw=wtfam_`prog']
        replace sigma_sq_`prog'_across = sigma_sq_`prog'_across
		
        * main regression coefficient - within
        reghdfe smmu `prog' [aw=wtfam_`prog'], absorb(rd_rk_c)
        gen mean_within_`prog' = _b[`prog'] / mean_smmu_overall * sigma_sq_`prog'
    		gen coeff_`prog' = _b[`prog'] / mean_smmu_overall 

        * main regression coefficient - across
        reg smmu mean_tu_`prog'_c [aw=wtfam_`prog']
        gen mean_across_`prog' = _b[mean_tu_`prog'_c] /  mean_smmu_overall * sigma_sq_`prog'_across
		
        * takeup externality (uses: m(z) S(z) = M(z) \eta), noting that eta is constant so it can go inside the integral  
        egen mean_fc_`prog' = total(mean_tu_`prog'_c * takeup_elasticity * wtfam_`prog')
        replace mean_fc_`prog' = mean_fc_`prog' / total_N_`prog'
		
		* take-up rate overall
		summ `prog' [aw=wtfam_`prog']
		gen mean_tu_overall_`prog' = r(mean)

    /******************************************/
    /* /\* **** labor supply effect  **** *\/ */
    /******************************************/
  
    /* approximate participation function by z */
    * mean real income within percentile 
    bys rd_rk_c: egen total_faminct_eq = total(faminct_eq * wtfam_`prog')
    gen mean_faminct_eq = total_faminct_eq / total_pop_pct_c

      * generate a conditional benefit | takeup (equivalized) 
        bys rd_rk_c: egen total_ben_`prog'_amt_eq = total(`prog'_amt_hh*hhsize / equivalence_scale * (wtfam_`prog' * `prog') )

      * note that the denominator is the total N who take up, also has a wtfam term in it, so that nets out 
        gen mean_ben_`prog'_amt_eq = total_ben_`prog'_amt_eq / total_tu_`prog'_c
        replace mean_ben_`prog'_amt_eq = 0 if total_tu_`prog'_c == 0 

    * get an average rank, to smooth things 
    egen cut_rk_c = cut(rd_rk_c), at(1 6 11 16 21 26 31 56 101)

      * get slopes of benefit and takeup rates
        preserve 
          collapse (mean) mean_tu_* mean_ben_*_amt_eq mean_T_inc mean_faminct_eq (rawsum) wtfam_`prog' [aw=wtfam_`prog'], by(cut_rk_c)
          sort cut_rk_c

           * get the avg diff (first-order approximation to slopes) 
           gen slope_tu_`prog' = (mean_tu_`prog'_c[_n+1] - mean_tu_`prog'_c[_n-1]) / 2 
           replace slope_tu_`prog' = (mean_tu_`prog'_c[_n+1] - mean_tu_`prog'_c[_n]) if _n == 1
           replace slope_tu_`prog' = (mean_tu_`prog'_c[_n] - mean_tu_`prog'_c[_n-1]) if _n == _N

           gen slope_ben_`prog' = (mean_ben_`prog'[_n+1] - mean_ben_`prog'[_n-1]) / 2 
           replace slope_ben_`prog' = (mean_ben_`prog'[_n+1] - mean_ben_`prog'[_n]) if _n == 1
           replace slope_ben_`prog' = (mean_ben_`prog'[_n] - mean_ben_`prog'[_n-1]) if _n == _N    

          * note that we want the slope of taxable income as you move up or down by one unit in rank space 
           gen slope_T = (mean_T_inc[_n+1] - mean_T_inc[_n-1]) / 2 
           replace slope_T = (mean_T_inc[_n+1] - mean_T_inc[_n]) if _n == 1
           replace slope_T = (mean_T_inc[_n] - mean_T_inc[_n-1]) if _n == _N        
           
           gen slope_inc = (mean_faminct_eq[_n+1] - mean_faminct_eq[_n-1]) / 2 
           replace slope_inc = (mean_faminct_eq[_n+1] - mean_faminct_eq[_n]) if _n == 1
           replace slope_inc = (mean_faminct_eq[_n] - mean_faminct_eq[_n-1]) if _n == _N

           * address issue where denominator isn't defined on flat parts of income 
           gen keep_rate = slope_inc - slope_T

           * get slope of the product of benefits and takeup rates 
           gen sl_tu_x_ben = (mean_ben_`prog'[_n+1] * mean_tu_`prog'_c[_n+1] - mean_ben_`prog'[_n-1] * mean_tu_`prog'_c[_n-1]) / 2
           replace sl_tu_x_ben = (mean_ben_`prog'[_n+1] * mean_tu_`prog'_c[_n+1] - mean_ben_`prog'[_n] * mean_tu_`prog'_c[_n]) if _n == 1 
           replace sl_tu_x_ben = (mean_ben_`prog'[_n] * mean_tu_`prog'_c[_n] - mean_ben_`prog'[_n-1] * mean_tu_`prog'_c[_n-1]) if _n == _N
           list sl_tu_x_ben wtfam_`prog' slope_inc

           * solution: define the elasticity as the minimum if it existed 
           foreach var in keep_rate slope_inc slope_T sl_tu_x_ben {
      
               gen min_rd_rk_def_`var'_tmp = cut_rk_c if !mi(`var') & (`var' != 0 )
               egen min_rd_rk_def_`var' = min(min_rd_rk_def_`var'_tmp)
               gen `var'_min_def_tmp = `var' if round(cut_rk_c,1) == round(min_rd_rk_def_`var',1)
               egen `var'_min_def = min(`var'_min_def_tmp)
               replace `var' = `var'_min_def if cut_rk_c < min_rd_rk_def_`var' & !mi(min_rd_rk_def_`var')
               
               assert !mi(`var')
          
          }
         drop *tmp
         tempfile slopes
         save `slopes' 

      restore

     * merge slopes back into dataset 
      merge m:1 cut_rk_c using `slopes', assert(match) keep(match) nogen  
  
      * get ls term 

      * use labor supply equation: see appendix for change of variables equation 
        egen mean_LS_`prog' = total( ///
         slope_tu_`prog' * mean_faminct_eq * (- ls_elast) / (slope_inc - slope_T)  * ///
          ( (sl_tu_x_ben - slope_T) / slope_inc ) * wtfam_`prog'  )

        * assert not missing any components 
				foreach component in slope_tu_`prog' rd_rk_c slope_ben_`prog' mean_tu_`prog'_c mean_ben_`prog'  slope_tu_`prog' slope_T keep_rate wtfam_`prog' {
            di "`component'"
            assert !mi(`component')
        }      
        assert !mi(              slope_tu_`prog' * mean_faminct_eq * (- ls_elast) / (slope_inc - slope_T)  * ///
          ( (sl_tu_x_ben - slope_T) / slope_inc ) * wtfam_`prog')
    
    * adjust for weights/sign 
    replace mean_LS_`prog' = - mean_LS_`prog' / total_N_`prog'

	* MVPFs	
    gen mvpf_v_`prog' = (1 + (mean_within_`prog' + mean_across_`prog') / mean_tu_overall_`prog') / (1 + mean_fc_`prog' / mean_tu_overall_`prog')
	gen mvpf_a_`prog' = (1 + mean_across_`prog' / mean_tu_overall_`prog') / (1 + mean_LS_`prog' / mean_tu_overall_`prog')

    ren *, lower

    * collapse to facilitate merge 
    keep if _n == 1
    gen i = 1
    keep mvpf* mean_tu* mean_within* mean_across* mean_tu* mean_fc* mean_ls* weight_dollars* coeff* i 
    
    * close program specific loop
    tempfile `prog'
    save ``prog'' 
}

* load results from all programs   
  clear
  use `snap' 
  foreach prog in wic medicaid liheap ha tanf ssi schoolmeals {
    merge 1:1 i using ``prog'', nogen assert(match) keep(match) 
  }
  
  
    foreach var in mvpf_a mvpf_v mean_tu_overall mean_within mean_across mean_fc mean_ls coeff {
	* removed: mean_ls_optimiz mean_ls
	
        gen `var'_avg = `var'_snap * weight_dollars_snap + /// 
        `var'_wic * weight_dollars_wic + /// 
        `var'_medicaid * weight_dollars_medicaid + /// 
        `var'_liheap * weight_dollars_liheap + /// 
        `var'_ha * weight_dollars_ha + /// 
        `var'_tanf * weight_dollars_tanf + /// 
        `var'_schoolmeals * weight_dollars_schoolmeals + /// 
          `var'_ssi * weight_dollars_ssi
    }
 
  * export data only if entering a table 
   save "$dir/data/tmp/mvpf_for_table_`weighttype'`nm'", replace

  
    /********************/
    /* export to table  */
    /********************/
    if mi("`main'") local suffix = "`nm'"
    if !mi("`main'") local suffix = "" 
    if "`weighttype'" == "hendren" local suffix = "hendren"

    use "$dir/data/tmp/mvpf_for_table_`weighttype'`nm'" , clear
    
    cap file close fh
    file open fh using "$dir/figures/mvpf_means_`weighttype'`nm'.csv", write replace
      
     foreach var of varlist mvpf* mean_within* mean_across* mean_fc* mean_ls* mvpf_a* mvpf_v* mean_tu_overall* {
      sum `var'
      file write fh "`var'`suffix'," %5.2f (`=`r(mean)'') _n 
  }
    cap file close fh
  
    

end

/****************************************/
/* * prepare data for mvpf analysis  */
/****************************************/
cap pr drop prep_mvpf
pr define prep_mvpf
  syntax, weighttype(string) [avgmuelig ta(real 0.4) ls(real 0.3) ra(real 2) socialra(real 1) psi(string) outcome(string) negishi nm(string)]
  
  * ~~ OPTIONS ~~ * 
  * ta corresponds to takeup elasticity
  * ls corresponds to ETI
  * ra corresponds to risk aversion parameter
  * ra corresponds to risk aversion parameter
  * socialra corresponds to SWF elasticity
  * psi corresponds to GHH preference parameter  
  * outcome corresponds to the outcome over which SWF are formed
  * nm is the name that you want to be passed to the export program  

    assert inlist("`weighttype'","crra","hendren")
  
    use "$dir/data/psid_base", clear 
	
	drop if year == 1997
    keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)
    keep if !mi(eq_cons)
    keep if !mi(lifetime_income_hh)
    drop if hhsize - nchild == 0
	drop if mi(snap) | mi(medicaid) | mi(liheap) | mi(housing_assistance)  | mi(tanf) |  mi(ssi)  | mi(schoolmeals) | mi(wic)     
  
	capture drop equivalence_scale
    gen equivalence_scale = ((hhsize-nchild)+0.7*nchild)^0.7
  
    gen rd_rk_c = ceil(rk_current_eq)
    replace rd_rk_c = 1 if rd_rk_c == 0

	/*
    gen rd_rk_l = ceil(rk_lifetime_eq)
    replace rd_rk_l = 1 if rd_rk_l == 0 */

    cap ren *housing_assistance* *ha* 

	qui run_all_eligsims
      	adopath + "$dir/code"
      	adopath + "$dir/code/eligsim"      
         
    foreach prog in snap wic medicaid liheap ha tanf ssi schoolmeals {

     * we create program-specific weights and call these = 0 if ineligible or the program doesn't exist in psid at that time (meaning we don't include that year at all)      
       gen wtfam_`prog' = wtfam
			 if "`prog'" != "ha" replace wtfam_`prog' = 0 if eligsim_`prog' == 0 
			 if "`prog'" == "ha" replace wtfam_`prog' = 0 if eligsim_housing_assistance == 0

       * don't include 1997, due to limited data coverage  
       replace wtfam_`prog' = 0 if year == 1997
      
    }

  /* 
  /* CBO MTRs */
    Lowest Income	Highest Income	MTR
    0	10860	0.142
    10860	21720	0.235
    21720	32580	0.338
    32580	43440	0.339
    43440	54300	0.328
    54300	65160	0.325
    65160	76020	0.326
    76020	86880	0.327
    86880	inf	0.335
*/

      local mtr_1 0.142 
      local mtr_2 0.235
      local mtr_3 0.338
      local mtr_4 0.339
      local mtr_5 0.328
      local mtr_6 0.325
      local mtr_7 0.326
      local mtr_8 0.327
      local mtr_9 0.335
      local cut_0 0
      local cut_1 10860
      local cut_2 21720
      local cut_3 43440
      local cut_4 54300
      local cut_5 65160
      local cut_6 76020
      local cut_7 86880
      local cut_8 1000000000000

      * total tax liability up to a certain point 
      local ttr_0 0

      forv i = 1/8 { 
        local ttr_`i' = `mtr_`i'' * (`cut_`i'' - `cut_`=`i'-1'') + `ttr_`=`i'-1''
        noisily di `ttr_`i''
      }
    
      * total tax liability at the individual level 
      gen mean_T_inc = 0

      forv i = 1 / 8 {
        replace mean_T_inc = `ttr_`=`i'-1'' + `mtr_`i'' * (faminct_real - `cut_`=`i'-1'') if inrange(faminct_real,`cut_`=`i'-1'',`cut_`i'')
      }
      
      * convert income tax at each leve lto an equivalence scale for consistency 
      replace mean_T_inc = mean_T_inc / equivalence_scale

        * equivalize faminc 
      gen faminct_eq = faminct_real / equivalence_scale
  
    * censor consumption at p5
        assert !mi(eq_cons)
        assert !mi(lifetime_income_eq)

       * censor consumption at p5
        sum eq_cons if eq_cons > 0, d    
        replace eq_cons = `r(p5)' if inrange(eq_cons,0,`r(p5)')

       * censor lifetime_income_hh at p5
        sum lifetime_income_eq if lifetime_income_eq > 0, d    
        replace lifetime_income_eq = `r(p5)' if inrange(lifetime_income_eq,0,`r(p5)')
	
        if mi("`outcome'") local outcome = "eq_cons" 

        * obtain ghh utility preference parameter using - u_h = u_c w
      if mi("`psi'") {
          bys famid year: egen total_hours = total(hours)
          gen hours_eq = total_hours / (hhsize - nchild)
          replace hours_eq = max(hours_eq, 0)
          
          gen wage = faminct_eq / (hours_eq * 50)
          replace wage = 0 if hours_eq == 0 | mi(faminct_eq) 
          gen psi = wage  / hours_eq^(1/`ls')
          assert !mi(hours_eq) 
          assert !mi(psi) if hours_eq != 0
          replace psi = 0 if hours_eq == 0 
        }
  
        if !mi("`psi'") gen psi = `psi'

        * ghh utility and ghh marginal utility 
        gen double util = (`outcome' - psi * hours_eq^(1+1/`ls')/(1+1/`ls'))^(1-`ra') / (1-`ra')
        gen double marg_util = (`outcome' - psi * hours_eq^(1+1/`ls')/(1+1/`ls'))^(-`ra')
		  
        * log utility if ra = 1 
        if "`ra'" == "1" {
          drop util marg_util
          gen double util = ln(`outcome' - psi * hours_eq^(1+1/`ls')/(1+1/`ls'))
          gen double marg_util = 1/(`outcome' - psi * hours_eq^(1+1/`ls')/(1+1/`ls')) 
        }

        * get social marginal welfare weights 
        gen double social_marg_util = (`outcome' - psi * hours_eq^(1+1/`ls')/(1+1/`ls'))^(-`socialra')
		
		* get social marginal welfare weights (social * marginal utility), for *all people in society*  
		gen double smmu = social_marg_util * marg_util
		
        * get welfare weights (just the social component) 
        gen double welfare_weight = social_marg_util
        
		* censor welfare objects
		foreach w in marg_util social_marg_util smmu {
			summ `w' [aw=wtfam],d  
			replace `w' = r(p95) if `w'>r(p95) & !missing(`w')
		}
		
        * get the total number of poeople
         egen total_N = total(wtfam)

        * generate labor supply elasticity 
        gen ls_elast = `ls'
  
        * generate takeup elasticity
        gen takeup_elasticity = `ta'

    * confirm the argument to utility is always pos, drop a small number of exceptions 
     count if eq_cons - psi * hours_eq^(1+1/`ls') / (1+1/`ls') < 0
     assert `r(N)' < 5
     drop if eq_cons - psi * hours_eq^(1+1/`ls') / (1+1/`ls') < 0  
     assert !mi(eq_cons - psi * hours_eq^(1+1/`ls') / (1+1/`ls') ) 

    * get dollar amounts by program
    foreach prog in snap wic medicaid liheap ha tanf ssi schoolmeals {
    
    * take just the first person in the family
    bys famid year: gen wtfam_`prog'_1 = wtfam_`prog' if _n == 1 
    
    * get dollar share in each program (note not equivalized bc just adding up shares) - this is in $2019    
    egen total_dollars_`prog' = total(`prog'_amt_hh * hhsize * wtfam_`prog'_1 * (year == 2019) )
    
  }

    egen total_dollars = rowtotal(total_dollars*) 

    * get dollar weights by program     
    foreach prog in snap wic medicaid liheap ha tanf ssi schoolmeals {

      gen weight_dollars_`prog' = total_dollars_`prog' / total_dollars 
  }

    * get overall avg marginal utility , across all progs 
    qui summ smmu [aw=wtfam]
    gen double mean_smmu_overall = `r(mean)'
  
    * export
        foreach prog in snap wic medicaid liheap ha tanf ssi schoolmeals {
        preserve 
          keep if wtfam_`prog' > 0

            * if avgmuelig is invoked, you divide by avg marginal utility among people who are eligible 
             if !mi("`avgmuelig'") {
                 cap drop  mean_smmu_overall
                 qui summ smmu [aw=wtfam_`prog']
                gen double mean_smmu_overall = `r(mean)'
            }
    
          save "$dir/data/tmp/emp_mvpf_`weighttype'`nm'_`prog'", replace
        restore 
        }

  
end 



