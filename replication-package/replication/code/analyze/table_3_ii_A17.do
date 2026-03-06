/***************************************************************************
 * Table 3: Welfare Effects of Budgetary Shifts Toward Automatic Transfers (Cents per Transfer Dollar)
 * Appendix Table A17: Marginal Value of Public Funds (MVPF), Voluntary and Automatic Transfers
 *
 * Description:
 * This script calls the welfare_prog.do and mvpf_progs.do files to create Table 3 and Appendix Table A 17.
 *
 * Table 3: This table reports estimates of the welfare effects of the reform, which marginally reduces the voluntary transfer to make it automatic. All columns report the money-metric welfare gains in cents per transfer dollar.
 * 
 * Appendix Table 17: this table presents the Marginal Value of Public Funds (MVPF) for various transfer programs, distinguishing between automatic and voluntary transfers.
 * The values provide all inputs to the MVPFs: within-income and across-income targeting benefits, social costs of ordeals, fiscal externalities from labor supply
 * effects, and take-up rates. Social benefits, social costs, and MVPFs are all in units of dollars per transfer dollar.
 *
 * Inputs:
 * - Command: mvpf_progs.do
 * - Command: welfare_progs.do
 * 
 * Outputs:
 * - Table 3 (`"$dir/figures/welfare_automatic.txt"`)
 * - Appendix Table 17 (`"$dir/tables/output/mvpf.tex"`)
 * 
 ***************************************************************************/ 

*** Settings

qui do code/settings
cd "$dir/"

qui do code/settings
qui do code/progs
qui do code/analyze/welfare_progs.do
qui do code/analyze/mvpf_progs.do

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

