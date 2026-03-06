qui do code/settings.do
    global navy `" "51 122 183" "'
    global green `" "92 184 92" "'
    global ltblue `" "91 192 222" "'
    global red `" "217 83 79" "'
    global orange `" "240 173 78" "'

* reshape
import delimited using figures/welfare_means_crramain.csv, clear

gen parameter = ""
gen prog = ""

* Separate the parameter and program
foreach suffix in snap wic medicaid liheap ha tanf ssi schoolmeals avg {
    replace parameter = substr(v1, 1, strpos(v1, "`suffix'") - 2) if strpos(v1, "`suffix'")
    replace prog = "`suffix'" if strpos(v1, "`suffix'")
}

* Clean up
drop v1
rename v2 value

* Reshape
reshape wide value, i(prog) j(parameter) string

ren valuedw0 net
ren valuemean_within selftarg
ren valuemean_ls lsedit
ren valuemean_fc oedit
gen net_sort = net
replace net_sort = -10000 if prog == "avg" 
sort net_sort
gen n = _n

local wicname WIC
local snapname SNAP
local schoolmealsname "School Meals"
local ssiname SSI
local tanfname TANF
local medicaidname Medicaid
local liheapname LIHEAP
local haname Housing

local xlab = `"1 "{bf:Dollar-Wt. Avg.}" "'

forv i = 2/`=_N' {
  local xlab = `" `xlab' `i' "``=prog[`i']'name'" "' 
}

tw bar selftarg oedit lsedit  n, ///
    xlab(`xlab', angle(45)) ///
    legend(symxsize(11)  ///
    order(1 "Self-Targeting" 2 "Ordeals" 3 "Labor Supply" 4 "{bf:Total}") ///
    ring(0) col(2) pos(4) bmargin(medsmall) region(lwidth(none))) ///
    xtitle("") barwidth(0.75 0.75 0.75) lwidth(0 0 0) fcolor(none none none) || ///
    bar net n, fcolor(none) lcolor(none) lwidth(medthick) barwidth(0.75) ///
    yline(0, lcolor(gs9)) subtitle("Cents per Transfer Dollar", span pos(11)) ///
    ylabel(-50(10)30) xline(1.5, lcolor(gs9) lpattern(dash)) graphregion(color(white) margin(3 2 0 2))

graph export "$dir/figures/welfare_summary_bar_fig0.pdf", as(pdf) replace

tw bar selftarg oedit lsedit  n, ///
    xlab(`xlab', angle(45)) ///  
    legend(symxsize(11)  ///
    order(1 "Self-Targeting" 2 "Ordeals" 3 "Labor Supply" 4 "{bf:Total}") ring(0) col(2)  pos(4) ///
    bmargin(medsmall) region(lwidth(none))) ///
    xtitle("") barwidth(0.75 0.75 0.75) lwidth(0 0 0) fcolor( $navy none none) || ///
    bar net n, fcolor(none) lcolor(none) lwidth(medthick) ///
    barwidth(0.75) yline(0, lcolor(gs9)) subtitle("Cents per Transfer Dollar", span pos(11)) ///
    ylabel(-50(10)30) xline(1.5, lcolor(gs9) lpattern(dash)) graphregion(color(white) margin(3 2 0 2))

graph export "$dir/figures/welfare_summary_bar_fig1.pdf", as(pdf) replace

tw bar selftarg oedit lsedit  n, ///
    xlab(`xlab', angle(45)) ///
    legend(symxsize(11)  order(1 "Self-Targeting" 2 "Ordeals" 3 "Labor Supply" 4 "{bf:Total}") ///
    col(2)  ring(0) pos(4) bmargin(medsmall) region(lwidth(none))) xtitle("") barwidth(0.75 0.75 0.75) ///
    lwidth(0 0 0) fcolor($navy $orange none) || bar net n, fcolor(none) lcolor(none) lwidth(medthick) barwidth(0.75) ///
    yline(0, lcolor(gs9)) subtitle("Cents per Transfer Dollar", span pos(11)) ylabel(-50(10)30) xline(1.5, lcolor(gs9) lpattern(dash)) graphregion(color(white) margin(3 2 0 2))

graph export "$dir/figures/welfare_summary_bar_fig2.pdf", as(pdf) replace


tw bar selftarg oedit lsedit  n, ///
    xlab(`xlab', angle(45)) ///
    legend(symxsize(11)  order(1 "Self-Targeting" 2 "Ordeals" 3 "Labor Supply" 4 "{bf:Total}") ///
    ring(0) pos(4) col(2) bmargin(medsmall) region(lwidth(none))) xtitle("") ///
    barwidth(0.75 0.75 0.75) lwidth(0 0 0) fcolor($navy  $orange $green ) || bar net n, ///
    fcolor(none) lcolor(none) lwidth(medthick) barwidth(0.75) yline(0, lcolor(gs9)) ///
    subtitle("Cents per Transfer Dollar", span pos(11)) ylabel(-50(10)30) xline(1.5, ///
    lcolor(gs9) lpattern(dash)) graphregion(color(white) margin(3 2 0 2))

graph export "$dir/figures/welfare_summary_bar_fig3.pdf", as(pdf) replace

tw bar selftarg oedit lsedit  n, ///
    xlab(`xlab', angle(45)) ///
    legend(symxsize(11)  order(1 "Self-Targeting" 2 "Ordeals" 3 ///
    "Labor Supply" 4 "{bf:Total}") ring(0) rows(2) ///
    pos(4) bmargin(medsmall) region(lwidth(none))) xtitle("") ///
    barwidth(0.75 0.75 0.75) lwidth(0 0 0) fcolor( $navy  $orange $green) || bar ///
    net n, fcolor(none) lcolor(black) lwidth(medthick) ///
    barwidth(0.75) yline(0, lcolor(gs9)) subtitle("Cents per Transfer Dollar", ///
    span pos(11)) ylabel(-50(10)30) xline(1.5, lcolor(gs9) lpattern(dash)) ///
    graphregion(color(white) margin(3 2 0 2))

graph export "$dir/figures/welfare_summary_bar_fig4.pdf", as(pdf) replace
