qui do code/settings
cd "$dir/"

qui do code/settings
qui do code/progs
qui do code/analyze/welfare_progs.do

* rob table
welfare_percentiles, weighttype(crra) main nm(main)
welfare_percentiles, weighttype(crra)  nm(ra2)
welfare_percentiles, weighttype(crra)  nm(rahalf)
welfare_percentiles, weighttype(crra)  nm(tahalf)
welfare_percentiles, weighttype(crra)  nm(tatwice)
welfare_percentiles, weighttype(crra)  nm(etihalf)
welfare_percentiles, weighttype(crra)  nm(etitwice)
welfare_percentiles, weighttype(crra)  nm(util)
welfare_percentiles, weighttype(crra)  nm(lp)
welfare_percentiles, weighttype(crra)  nm(mp)
welfare_percentiles, weighttype(crra)  nm(ngs) negishi 
welfare_percentiles, weighttype(crra)  nm(avgmuelig) avgmuelig

cd "$dir/code/"
table_from_tpl, t(../tables/template/welfare_automatic_insurance.tex) r(../figures/welfare_means_crramain.csv) o(../figures/welfare_automatic.tex)
table_from_tpl, t(../figures/welfare_automatic.tex)  r(../figures/welfare_means_crrara2.csv) o(../figures/welfare_automatic.tex)
table_from_tpl, t(../figures/welfare_automatic.tex)  r(../figures/welfare_means_crrarahalf.csv) o(../figures/welfare_automatic.tex)
table_from_tpl, t(../figures/welfare_automatic.tex)  r(../figures/welfare_means_crrali.csv) o(../figures/welfare_automatic.tex)
table_from_tpl, t(../figures/welfare_automatic.tex)  r(../figures/welfare_means_crratahalf.csv) o(../figures/welfare_automatic.tex)
table_from_tpl, t(../figures/welfare_automatic.tex)  r(../figures/welfare_means_crratatwice.csv) o(../figures/welfare_automatic.tex)
table_from_tpl, t(../figures/welfare_automatic.tex)  r(../figures/welfare_means_crraetihalf.csv) o(../figures/welfare_automatic.tex)
table_from_tpl, t(../figures/welfare_automatic.tex)  r(../figures/welfare_means_crraetitwice.csv) o(../figures/welfare_automatic.tex)
table_from_tpl, t(../figures/welfare_automatic.tex)  r(../figures/welfare_means_crrautil.csv) o(../figures/welfare_automatic.tex)
table_from_tpl, t(../figures/welfare_automatic.tex)  r(../figures/welfare_means_crralp.csv) o(../figures/welfare_automatic.tex)
table_from_tpl, t(../figures/welfare_automatic.tex)  r(../figures/welfare_means_crramp.csv) o(../figures/welfare_automatic.tex)
table_from_tpl, t(../figures/welfare_automatic.tex)  r(../figures/welfare_means_crraelig.csv) o(../figures/welfare_automatic.tex)
table_from_tpl, t(../figures/welfare_automatic.tex)  r(../figures/welfare_means_crraavgmuelig.csv) o(../figures/welfare_automatic.tex)

cd "$dir/code/"
mvpf_percentiles, weighttype(crra) main nm(main)
table_from_tpl, t(../tables/template/mvpf_template.tex) r(../figures/mvpf_means_crramain.csv) o(../tables/output/mvpf.tex)

