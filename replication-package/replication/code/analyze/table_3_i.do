/***************************************************************************
* Table 3: Welfare Effects of Budgetary Shifts Toward Automatic Transfers (Cents per Transfer Dollar)

* Purpose: this do file loads the relevant settings for the creation of Table 3.

 ***************************************************************************/ 

qui do code/settings
qui do code/progs
qui do code/analyze/welfare_progs.do
qui do code/analyze/mvpf_progs.do
local ra = 2

prep_welfare, weighttype(crra) ra(`ra') nm(main)
prep_welfare, weighttype(crra)  ra(`ra') nm(avgmuelig) avgmuelig

prep_welfare, weighttype(crra) ra(`=0.5*`ra'') nm(rahalf)
prep_welfare, weighttype(crra) ra(3) nm(ra2)
prep_welfare, weighttype(crra) outcome(lifetime_income_hh) nm(li) ra(`ra') 
prep_welfare, weighttype(crra) ta(0.2) nm(tahalf) ra(`ra')
prep_welfare, weighttype(crra) ta(0.6) nm(tatwice) ra(`ra') 
prep_welfare, weighttype(crra) ls(0.15) nm(etihalf) ra(`ra')
prep_welfare, weighttype(crra) ls(0.6) nm(etitwice) ra(`ra') 
prep_welfare, weighttype(crra)  ra(`ra') socialra(0) nm(util)
prep_welfare, weighttype(crra)  ra(`ra') socialra(0.5) nm(lp) 
prep_welfare, weighttype(crra)  ra(`ra') socialra(2) nm(mp)
prep_welfare, weighttype(crra)  ra(`ra') nm(elig)

prep_mvpf, weighttype(crra) ra(`ra') nm(main)
