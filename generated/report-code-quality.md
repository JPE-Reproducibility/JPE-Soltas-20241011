## Code Quality

### Stata

[CRITICAL] Hardcoded absolute path detected — the package will not run on another machine. (settings.do, line 17)
  → global dir "C:/Users/al2705/Princeton Dropbox/Allan Lee/TransferIncidence/replication"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_1ab_A23ab_A28ab.do, line 66)
  → keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_1ab_A23ab_A28ab.do, line 321)
  → keep if spec == "`spec'" & imputed == "`imputed'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_1ab_A23ab_A28ab.do, line 322)
  → drop if prog == "avg_of_5"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_1ab_A23ab_A28ab.do, line 369)
  → drop if regtype == "raw"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_1ab_A23ab_A28ab.do, line 549)
  → keep if spec == "`spec'" & imputed == "`imputed'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_1ab_A23ab_A28ab.do, line 550)
  → drop if prog == "avg_of_5"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_1ab_A23ab_A28ab.do, line 560)
  → drop if !inlist(regtype,"raw","ifelig")

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_1c_A23c.do, line 177)
  → keep if imputed_eligibility == "`eligvar'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_1c_A23c.do, line 185)
  → drop if !inlist(regtype,"raw","fe")

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_1d.do, line 34)
  → keep if !mi(eq_cons)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_1d.do, line 35)
  → keep if !mi(lifetime_income_hh)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_1d.do, line 36)
  → drop if hhsize - nchild == 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_1d.do, line 37)
  → drop if mi(snap) | mi(medicaid) | mi(liheap) | mi(housing_assistance)  | mi(tanf) |  mi(ssi)  | mi(schoolmeals) | mi(wic)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_1d.do, line 68)
  → drop if eq_cons - psi * hours_eq^(1+1/`ls') / (1+1/`ls') < 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_2_A23d.do, line 149)
  → keep if imputed == "no"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_2_A23d.do, line 161)
  → drop if prog == "avg"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_2_A23d.do, line 163)
  → keep if spec == "_c" & imputed == "no" & regtype == "ifelig"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_2_A23d.do, line 164)
  → keep if inlist(prog,"avg","snap","medicaid","ha","ssi","tanf")

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_2_A23d.do, line 230)
  → keep if imputed == "yes"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_2_A23d.do, line 242)
  → drop if prog == "avg"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_2_A23d.do, line 244)
  → keep if spec == "_c" & imputed == "yes" & regtype == "ifelig"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_2_A23d.do, line 245)
  → keep if inlist(prog,"avg","snap","medicaid","ha","ssi","tanf")

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A10ab.do, line 150)
  → keep if spec == "`spec'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A11a.do, line 145)
  → keep if spec == "`spec'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A11b.do, line 143)
  → keep if spec == "`spec'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A14.do, line 110)
  → keep if !missing(coef_c)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A16ab.do, line 206)
  → keep if outcome == "`outcome'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A16ab.do, line 219)
  → drop if !inlist(spec,"baseline","lowinc","highinc")

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A17.do, line 88)
  → keep if spec == "_c"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A19.do, line 85)
  → keep if _n<=8

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A21ab.do, line 194)
  → keep if outcome == "`outcome'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A21ab.do, line 207)
  → drop if !inlist(spec,"baseline","inclimit","assettest")

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A22.do, line 143)
  → keep if spec == "_c"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A24ab.do, line 175)
  → keep if spec == "`spec'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A25.do, line 97)
  → keep if spec == "_c"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A26ab.do, line 124)
  → keep if spec == "`spec'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A27ab.do, line 153)
  → keep if spec == "`spec'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A2ab.do, line 183)
  → keep if spec == "`spec'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A30.do, line 39)
  → keep if !missing(rk_current_eq) & !missing(rk_c_current_eq) & !missing(rk_lifetime_eq)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A31.do, line 111)
  → drop if missing(res1)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A4.do, line 87)
  → drop if missing(results1)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A6ab.do, line 54)
  → keep if !missing(rk_lifetime_hh) & !missing(rk_current_hh) & !missing(rk_c_current_hh)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A6ab.do, line 244)
  → keep if spec == "`spec'" & imputed == "`imputed'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A6ab.do, line 248)
  → drop if prog == "avg_of_5"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A6ab.do, line 255)
  → drop if !inlist(regtype,"raw","ifelig")

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A7ab.do, line 159)
  → keep if spec == "`spec'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A8.do, line 65)
  → keep if year == 1998

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (fig_A9ab.do, line 154)
  → keep if spec == "`spec'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (mvpf_progs.do, line 266)
  → drop if year == 1997

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (mvpf_progs.do, line 267)
  → keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (mvpf_progs.do, line 268)
  → keep if !mi(eq_cons)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (mvpf_progs.do, line 269)
  → keep if !mi(lifetime_income_hh)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (mvpf_progs.do, line 270)
  → drop if hhsize - nchild == 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (mvpf_progs.do, line 271)
  → drop if mi(snap) | mi(medicaid) | mi(liheap) | mi(housing_assistance)  | mi(tanf) |  mi(ssi)  | mi(schoolmeals) | mi(wic)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (mvpf_progs.do, line 423)
  → drop if eq_cons - psi * hours_eq^(1+1/`ls') / (1+1/`ls') < 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (mvpf_progs.do, line 452)
  → keep if wtfam_`prog' > 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (table_A14.do, line 42)
  → drop if mi(rk_lifetime_eq) | mi(rk_current_eq) | mi(rk_c_current_eq)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (table_A2.do, line 32)
  → keep if !missing(rk_inc) | !missing(rk_cons)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (table_A4.do, line 34)
  → keep if inrange(age, 18,65)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (table_A5.do, line 45)
  → keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (table_A6.do, line 129)
  → drop if missing(pname)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (table_A6.do, line 221)
  → drop if missing(pname)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (table_A6.do, line 372)
  → drop if missing(pname)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (table_A6.do, line 511)
  → drop if missing(pname)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (welfare_progs.do, line 261)
  → drop if year == 1997

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (welfare_progs.do, line 262)
  → keep if !missing(rk_lifetime_eq) & !missing(rk_current_eq) & !missing(rk_c_current_eq)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (welfare_progs.do, line 263)
  → keep if !mi(eq_cons)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (welfare_progs.do, line 264)
  → keep if !mi(lifetime_income_hh)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (welfare_progs.do, line 265)
  → drop if hhsize - nchild == 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (welfare_progs.do, line 266)
  → drop if mi(snap) | mi(medicaid) | mi(liheap) | mi(housing_assistance)  | mi(tanf) |  mi(ssi)  | mi(schoolmeals) | mi(wic)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (welfare_progs.do, line 418)
  → drop if eq_cons - psi * hours_eq^(1+1/`ls') / (1+1/`ls') < 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (welfare_progs.do, line 447)
  → keep if wtfam_`prog' > 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_process_cex.do, line 78)
  → keep if strpos(file,"lsd")>0 | strpos(file,"ovb")>0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_process_cex.do, line 174)
  → keep if strpos(file,"fmli")>0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_process_cex.do, line 268)
  → keep if (inrange(age,18,65) | inrange(age,18,65)) & (inlist(respstat,"1") | missing(respstat))

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_clean_cps_income_reg.do, line 28)
  → keep if head == 1 | spouse == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_clean_cps_income_reg.do, line 108)
  → keep if year == 1970

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_clean_cps_income_reg.do, line 129)
  → keep if year == 2000

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_clean_cps_income_reg.do, line 154)
  → keep if year == 2010

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_clean_cps_income_reg.do, line 237)
  → keep if psid == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_psid_reshape.do, line 409)
  → keep if inlist(year,1997,1999,2001)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_psid_reshape.do, line 426)
  → keep if inlist(year,2003,2005,2007,2009,2011,2013,2015)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_psid_reshape.do, line 443)
  → keep if inlist(year,2017,2019)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_psid_reshape.do, line 479)
  → keep if inlist(year,1997,1999,2001)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_psid_reshape.do, line 496)
  → keep if inlist(year,2003,2005,2007,2009,2011,2013,2015)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_psid_reshape.do, line 518)
  → keep if year == 2017 | year == 2019

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_psid_reshape.do, line 1261)
  → drop if missing(veh1_leaseval) & missing(veh2_leaseval) & missing(veh3_leaseval)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_psid_reshape.do, line 1270)
  → drop if missing(veh`i'_manuf)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_ebayes_lifetime_earnings.do, line 155)
  → keep if r == `r'

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (03_merge_psid_reshape_lifetime_earnings.do, line 127)
  → keep if year == 2019 & !missing(consumption_real)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (03_merge_psid_reshape_lifetime_earnings.do, line 138)
  → drop if missing(at_rk)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 94)
  → drop if hudmsacode == 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 124)
  → drop if hudmsacode == 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 153)
  → drop if hudmsacode == 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 182)
  → drop if msa == 10000

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 210)
  → drop if msa == 10000

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 238)
  → drop if msa == 10000

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 266)
  → drop if msa == 10000

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 294)
  → drop if msa == 10000

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 322)
  → keep if metro == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 350)
  → keep if metro == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 378)
  → keep if metro == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 406)
  → keep if metro == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 434)
  → keep if metro == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 462)
  → keep if metro == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 490)
  → keep if metro == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 518)
  → keep if metro == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 546)
  → keep if metro == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 574)
  → keep if metro == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 602)
  → keep if metro == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 630)
  → keep if metro == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 658)
  → keep if metro == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_housing_assistance.do, line 690)
  → drop if inlist(state,66,72,78) | missing(state)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_snap.do, line 109)
  → drop if missing(hhsize)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_tanf.do, line 71)
  → keep if year == 2017

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_tanf.do, line 109)
  → drop if mi(state)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_tanf.do, line 158)
  → drop if mi(state)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_tanf.do, line 189)
  → drop if mi(state)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_tanf.do, line 231)
  → drop if mi(state)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_tanf.do, line 232)
  → drop if mi(B)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_tanf.do, line 239)
  → keep if B == "`=strproper("`var'")'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (prepare_eligsim_tanf.do, line 307)
  → drop if _merge == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (create_covariates.do, line 164)
  → drop if _merge==2

