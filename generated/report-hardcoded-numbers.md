## Potentially Hardcoded Numeric Constants


We found the following set of hard coded numbers. This may be completely legitimate (parameter input, thresholds for computations, etc), and is hence only for information.

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/_archive/well_measured_c.tex**

- Line 10, : Receives Transfer                              & -0.496***             & -0.392***          & -0.819***          & -0.376***          & 0.067          & -0.225***          & -0.191***          & -0.270***          \\
- Line 11, : & (0.036)                   & (0.035)                & (0.037)                & (0.077)                & (0.104)                & (0.029)                & (0.028)                & (0.043)                \\  \addlinespace
- Line 13, : Receives Transfer                              & -0.310***    & -0.330*** & -0.177*** & -0.021 & -0.009 & -0.254*** & -0.083*** & -0.154*** \\
- Line 14, : & (0.020)          & (0.023)       & (0.025)       & (0.038)       & (0.066)       & (0.015)       & (0.019)       & (0.026)       \\  \addlinespace
- Line 16, : Receives Transfer                              & -0.600***      & -0.328***   & -0.238***   & -0.470***   & -0.057   & -0.053**   & -0.283***   & -0.297***   \\
- Line 17, : & (0.025)            & (0.030)         & (0.031)         & (0.064)         & (0.102)         & (0.025)         & (0.029)         & (0.034)         \\  \addlinespace
- Line 19, : Receives Transfer                              & -0.093***         & -0.170***      & -0.339***      & -0.169**      & 0.144**      & -0.155***      & -0.114***      & 0.017      \\
- Line 20, : & (0.030)               & (0.034)            & (0.048)            & (0.066)            & (0.068)            & (0.024)            & (0.026)            & (0.032)            \\  \addlinespace
- Line 22, : Receives Transfer                              & -0.116***        & -0.198***     & -0.128***     & -0.098     & -0.275**     & -0.100***     & -0.054*     & -0.178***     \\
- Line 23, : & (0.032)              & (0.038)           & (0.039)           & (0.071)           & (0.114)           & (0.026)           & (0.029)           & (0.042)          \\  \addlinespace

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/code/clean/psid/ebayes_chandra_et_al_2016.ado**

- Line 24, : tol(real 0.000001) maxiter(integer 100) ]

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/_archive/snap_by_month_final.tex**

- Line 9, : Received SNAP in Year  & 0.063*** &                      &                      &                      & 0.056*** &                      &                      &                      \\
- Line 10, : & (0.010)     &                      &                      &                      & (0.015)     &                      &                      &                      \\
- Line 11, : Share of Year on SNAP  &                      & 0.076*** &                      &                      &                      & 0.061*** &                      &                      \\
- Line 12, : &                      & (0.013)     &                      &                      &                      & (0.018)     &                      &                      \\
- Line 13, : Received SNAP in Month &                      &                      & 0.072*** & 0.040*** &                      &                      & 0.058*** & 0.025 \\
- Line 14, : &                      &                      & (0.012)     & (0.012)     &                      &                      & (0.016)     & (0.018)     \\ \addlinespace \midrule

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/_archive/well_measured_cex.tex**

- Line 10, : Receives Transfer                              & -0.550***             & -0.442***          & -0.667***          & -0.317***          & -0.202***           \\
- Line 11, : & (0.016)                   & (0.026)                & (0.021)                & (0.032)                & (0.027)               \\  \addlinespace
- Line 13, : Receives Transfer                              & -0.136***    & -0.182*** & -0.308*** & -0.270*** & -0.109***   \\
- Line 14, : & (0.016)          & (0.022)       & (0.019)       & (0.040)       & (0.030)      \\  \addlinespace
- Line 16, : Receives Transfer                              & -0.113***      & -0.167***   & -0.051***   & 0.026   & -0.073***    \\
- Line 17, : & (0.009)            & (0.014)         & (0.010)         & (0.017)         & (0.015)         \\  \addlinespace
- Line 19, : Receives Transfer                              & -0.134***         & -0.258***      & -0.228***      & -0.235***      & -0.104***     \\
- Line 20, : & (0.012)               & (0.018)            & (0.014)            & (0.026)            & (0.018)             \\  \addlinespace
- Line 22, : Receives Transfer                              & -0.512***        & -0.413***     & -0.535***     & -0.596***     & -0.315***       \\
- Line 23, : & (0.020)              & (0.029)           & (0.021)           & (0.050)           & (0.032)         \\  \addlinespace

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/code/clean/cex/02_process_cex.do**

- Line 273, : replace cpi = 62.0156 if year == 1997
- Line 274, : replace cpi = 62.97498 if year == 1998
- Line 275, : replace cpi = 64.35611 if year == 1999
- Line 276, : replace cpi = 66.52278 if year == 2000
- Line 277, : replace cpi = 68.39648 if year == 2001
- Line 278, : replace cpi = 69.48786 if year == 2002
- Line 279, : replace cpi = 71.08469 if year == 2003
- Line 280, : replace cpi = 72.98093 if year == 2004
- Line 281, : replace cpi = 75.43734 if year == 2005
- Line 282, : replace cpi = 77.868 if year == 2006
- Line 283, : replace cpi = 80.10324 if year == 2007
- Line 284, : replace cpi = 83.15914 if year == 2008
- Line 285, : replace cpi = 82.89273 if year == 2009
- Line 286, : replace cpi = 84.24933 if year == 2010
- Line 287, : replace cpi = 86.89447 if year == 2011
- Line 288, : replace cpi = 88.69596 if year == 2012
- Line 289, : replace cpi = 89.99621 if year == 2013
- Line 290, : replace cpi = 91.45007 if year == 2014
- Line 291, : replace cpi = 91.56085 if year == 2015
- Line 292, : replace cpi = 92.72126 if year == 2016
- Line 293, : replace cpi = 94.69756 if year == 2017
- Line 294, : replace cpi = 97.00723 if year == 2018
- Line 295, : replace cpi = 98.76622 if year == 2019

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/code/stata-tex.do**

- Line 185, : est1,3.544
- Line 186, : est2,3.234***
- Line 189, : "est1" is the key. "3.544" is the value.
- Line 193, : insert_into_file using $tmp/estimates.csv, key(est1) value(3.54493) format(%5.2f)

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/levels_outcomes.tex**

- Line 10, : SNAP               & -0.551***   & -0.497***    & -0.886***     & -8,291***          & -11,607***                     & -17,257***                       \\
- Line 11, : & (0.039)   & (0.013)    & (0.156)     & (641)         & (326)                        & (3,862)                       \\ \addlinespace
- Line 12, : Medicaid           & -0.492*** & -0.485*** & -0.775*** & -6,637***     & -11,849***                   & -14,698***                   \\
- Line 13, : & (0.044)  & (0.021) & (0.114) & (669)     & (558)                    & (2,580)                   \\  \addlinespace
- Line 14, : Housing Assistance & -0.451***    & -0.479***       & -0.498***       & -7,476***        & -15,876***                        & -15,360***                         \\
- Line 15, : & (0.035)    & (0.016)     & (0.183)       & (618)         & (530)                         & (5,656)                         \\  \addlinespace
- Line 16, : TANF               & -0.341***    & -0.434***     & -0.224     & -3,538***      & -10,102***                    & -4,645                       \\
- Line 17, : & (0.094)   & (0.027)    & (0.268)     & (975)          & (638)                 & (5,604)                       \\  \addlinespace
- Line 18, : SSI                & -0.003    & -0.247***     & -0.198      & -23     & -7,083***                           & -1,283                        \\
- Line 19, : & (0.079)    & (0.022)      & (0.245)      & (693)        & (637)                   & (1,553)                        \\  \addlinespace
- Line 20, : School Meals                 & -0.341***   &    & -0.336**       & -3,774***          &                 & -5,651**                         \\
- Line 21, : & (0.027)  &     & (0.165)       & (325)        &                  & (2,742)                         \\  \addlinespace
- Line 22, : WIC                & -0.239***   &   & -0.180      & -2,564***           &                    & -4,271*                        \\
- Line 23, : & (0.026)    &  & (0.111)      & (297)               &                & (2,551)                        \\   \addlinespace
- Line 24, : LIHEAP             & -0.379*** &  & -0.476***   & -5,377***             &               & -8,935***                     \\
- Line 25, : & (0.037) &  & (0.146)   & (599)                 &           & (2,779)                 \\ \addlinespace \bottomrule

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/code/analyze/welfare_progs.do**

- Line 299, : 0	10860	0.142
- Line 300, : 10860	21720	0.235
- Line 301, : 21720	32580	0.338
- Line 302, : 32580	43440	0.339
- Line 303, : 43440	54300	0.328
- Line 304, : 54300	65160	0.325
- Line 305, : 65160	76020	0.326
- Line 306, : 76020	86880	0.327
- Line 307, : 86880	inf	0.335
- Line 310, : local mtr_1 0.142
- Line 311, : local mtr_2 0.235
- Line 312, : local mtr_3 0.338
- Line 313, : local mtr_4 0.339
- Line 314, : local mtr_5 0.328
- Line 315, : local mtr_6 0.325
- Line 316, : local mtr_7 0.326
- Line 317, : local mtr_8 0.327
- Line 318, : local mtr_9 0.335

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/_archive/other_outcomes.tex**

- Line 8, : \multicolumn{9}{@{}l}{\emph{Panel A: Log Wage (Mean: 1.742)}  }                                                                                                                                                                                                   \\ \addlinespace
- Line 9, : Receives Transfer & -0.089***    & -0.043    & -0.112***    & -0.062    & 0.409***    & -0.027    & 0.029    & 0.008    \\
- Line 10, : & (0.022)          &
- Line 11, : (0.027)          & (0.021)          &
- Line 12, : (0.047)          & (0.134)          &
- Line 13, : (0.019)          & (0.019)
- Line 14, : & (0.029)          \\ \addlinespace
- Line 15, : \multicolumn{9}{@{}l}{\emph{Panel B: High-School Dropout (Mean: 0.186)}  }                                                                                                                                                                                                   \\ \addlinespace
- Line 16, : Receives Transfer & 0.092***    & 0.053***    & 0.065***    & 0.049    & -0.004    & 0.066***    & 0.023    & 0.058***    \\
- Line 17, : & (0.017)          &
- Line 18, : (0.016)          & (0.023)          &
- Line 19, : (0.033)          & (0.054)          &
- Line 20, : (0.018)          & (0.016)
- Line 21, : & (0.020)          \\ \addlinespace
- Line 22, : \multicolumn{9}{@{}l}{\emph{Panel C: Single Parent (Mean: 0.147) } }
- Line 24, : Receives Transfer & 0.191***    & 0.165***    & 0.152***    & 0.197***    & 0.000    & 0.267***    & 0.010    & 0.077***    \\
- Line 25, : & (0.015)          & (0.014)          & (0.019)          & (0.031)          & (0.000)          & (0.016)          & (0.020)          & (0.019)          \\ \addlinespace
- Line 26, : \multicolumn{9}{@{}l}{\emph{Panel D: Disabled (Mean: 0.325) }  }
- Line 28, : Receives Transfer & 0.106***      & 0.147***      & 0.047**      & 0.050*      & 0.199***      & -0.124***      & 0.014      & 0.114***      \\
- Line 29, : & (0.015)            & (0.019)            & (0.019)            & (0.027)            & (0.036)            & (0.013)            & (0.010)            & (0.018)            \\ \addlinespace
- Line 30, : \multicolumn{9}{@{}l}{\emph{Panel E: Fair or Poor Health (Mean: 0.328) }  }
- Line 32, : Receives Transfer & 0.090***      & 0.108***      & 0.014      & 0.033      & 0.083      & -0.054***      & 0.014      & 0.097***      \\
- Line 33, : & (0.016)            & (0.020)            & (0.018)            & (0.036)            & (0.056)            & (0.015)            & (0.014)            & (0.021)            \\ \addlinespace
- Line 34, : \multicolumn{9}{@{}l}{\emph{Panel F: Nonwhite or Hispanic (Mean: 0.471)}   }                                                                                                                                                                                                              \\ \addlinespace
- Line 35, : Receives Transfer & 0.125***     & 0.068***     & 0.256***     & 0.029     & -0.055     & 0.061***     & -0.016     & -0.009     \\
- Line 36, : & (0.024)           & (0.025)           & (0.029)           & (0.037)           & (0.071)           & (0.021)           & (0.022)           & (0.032)           \\ \addlinespace
- Line 37, : \multicolumn{9}{@{}l}{\emph{Panel G: Has Savings (Mean: 0.539)}  }                                                                                                                                                                                                          \\ \addlinespace
- Line 38, : Receives Transfer & -0.149***   & -0.009   & -0.136***   & -0.044   & 0.162**   & -0.035**   & -0.022   & -0.017   \\
- Line 39, : & (0.019)         &
- Line 40, : (0.021)         & (0.028)
- Line 41, : & (0.036)         & (0.063)
- Line 42, : & (0.018)         &
- Line 43, : (0.020)         & (0.025)

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/other_outcomes.tex**

- Line 8, : \multicolumn{9}{@{}l}{\emph{Panel A: Log Wage (Mean: 1.742)}  }                                                                                                                                                                                                   \\ \addlinespace
- Line 9, : Receives Transfer & -0.089***    & -0.043    & -0.112***    & -0.061    & 0.408***    & -0.027    & 0.029    & 0.008    \\
- Line 10, : & (0.022)          &
- Line 11, : (0.027)          & (0.021)          &
- Line 12, : (0.047)          & (0.134)          &
- Line 13, : (0.019)          & (0.019)
- Line 14, : & (0.029)          \\ \addlinespace
- Line 15, : \multicolumn{9}{@{}l}{\emph{Panel B: High-School Dropout (Mean: 0.186)}  }                                                                                                                                                                                                   \\ \addlinespace
- Line 16, : Receives Transfer & 0.092***    & 0.054***    & 0.065***    & 0.047    & -0.002    & 0.066***    & 0.023    & 0.058***    \\
- Line 17, : & (0.017)          &
- Line 18, : (0.017)          & (0.023)          &
- Line 19, : (0.032)          & (0.053)          &
- Line 20, : (0.018)          & (0.016)
- Line 21, : & (0.020)          \\ \addlinespace
- Line 22, : \multicolumn{9}{@{}l}{\emph{Panel C: Single Parent (Mean: 0.147) } }
- Line 24, : Receives Transfer & 0.192***    & 0.165***    & 0.152***    & 0.196***    & 0.000    & 0.266***    & 0.010    & 0.077***    \\
- Line 25, : & (0.015)          & (0.014)          & (0.019)          & (0.032)          & (0.000)          & (0.016)          & (0.020)          & (0.019)          \\ \addlinespace
- Line 26, : \multicolumn{9}{@{}l}{\emph{Panel D: Disabled (Mean: 0.325) }  }
- Line 28, : Receives Transfer & 0.105***      & 0.149***      & 0.048**      & 0.047*      & 0.200***      & -0.123***      & 0.014      & 0.113***      \\
- Line 29, : & (0.015)            & (0.020)            & (0.019)            & (0.026)            & (0.036)            & (0.013)            & (0.010)            & (0.018)            \\ \addlinespace
- Line 30, : \multicolumn{9}{@{}l}{\emph{Panel E: Fair or Poor Health (Mean: 0.328) }  }
- Line 32, : Receives Transfer & 0.090***      & 0.109***      & 0.015      & 0.030      & 0.080      & -0.054***      & 0.014      & 0.097***      \\
- Line 33, : & (0.016)            & (0.020)            & (0.018)            & (0.036)            & (0.057)            & (0.015)            & (0.014)            & (0.021)            \\ \addlinespace
- Line 34, : \multicolumn{9}{@{}l}{\emph{Panel F: Nonwhite or Hispanic (Mean: 0.472)}   }                                                                                                                                                                                                              \\ \addlinespace
- Line 35, : Receives Transfer & 0.125***     & 0.069***     & 0.256***     & 0.027     & -0.054     & 0.060***     & -0.015     & -0.009     \\
- Line 36, : & (0.024)           & (0.025)           & (0.029)           & (0.037)           & (0.072)           & (0.021)           & (0.022)           & (0.032)           \\ \addlinespace
- Line 37, : \multicolumn{9}{@{}l}{\emph{Panel G: Has Savings (Mean: 0.539)}  }                                                                                                                                                                                                          \\ \addlinespace
- Line 38, : Receives Transfer & -0.147***   & -0.010   & -0.136***   & -0.043   & 0.165**   & -0.035**   & -0.023   & -0.017   \\
- Line 39, : & (0.019)         &
- Line 40, : (0.021)         & (0.027)
- Line 41, : & (0.035)         & (0.064)
- Line 42, : & (0.018)         &
- Line 43, : (0.020)         & (0.025)

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/well_measured_cex.tex**

- Line 10, : Receives Transfer                              & -0.550***             & -0.442***          & -0.667***          & -0.317***          & -0.202***           \\
- Line 11, : & (0.016)                   & (0.026)                & (0.021)                & (0.032)                & (0.027)               \\  \addlinespace
- Line 13, : Receives Transfer                              & -0.136***    & -0.182*** & -0.308*** & -0.270*** & -0.109***   \\
- Line 14, : & (0.016)          & (0.022)       & (0.019)       & (0.040)       & (0.030)      \\  \addlinespace
- Line 16, : Receives Transfer                              & -0.113***      & -0.167***   & -0.051***   & 0.026   & -0.073***    \\
- Line 17, : & (0.009)            & (0.014)         & (0.010)         & (0.017)         & (0.015)         \\  \addlinespace
- Line 19, : Receives Transfer                              & -0.134***         & -0.258***      & -0.228***      & -0.235***      & -0.104***     \\
- Line 20, : & (0.012)               & (0.018)            & (0.014)            & (0.026)            & (0.018)             \\  \addlinespace
- Line 22, : Receives Transfer                              & -0.512***        & -0.413***     & -0.535***     & -0.596***     & -0.315***       \\
- Line 23, : & (0.020)              & (0.029)           & (0.021)           & (0.050)           & (0.032)         \\  \addlinespace

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/durable_good_ownership_cex.tex**

- Line 10, : Receives Transfer & -0.131***    & -0.153***    & -0.294***    & -0.203***    & -0.133***      \\
- Line 11, : & (0.007)          & (0.011)          & (0.005)          & (0.013)          & (0.013)                 \\ \addlinespace
- Line 13, : Receives Transfer & -0.383***      & -0.479***      & -0.712***      & -0.354***      & -0.285***        \\
- Line 14, : & (0.026)            & (0.043)            & (0.024)            & (0.056)            & (0.048)                  \\ \addlinespace
- Line 16, : Receives Transfer & -0.110***    & -0.067***    & 0.033***    & -0.168***    & -0.082*** \\
- Line 17, : & (0.007)          & (0.011)          & (0.008)          & (0.016)          & (0.013)          \\ \addlinespace
- Line 19, : Receives Transfer & -0.132***     & -0.093***     & -0.210***     & -0.276***     & -0.125***   \\
- Line 20, : & (0.007)           & (0.011)           & (0.008)           & (0.017)           & (0.013)        \\ \addlinespace
- Line 22, : Receives Transfer & -0.162***   & -0.008   & -0.011   & -0.098***   & -0.042***    \\
- Line 23, : & (0.007)         & (0.011)         & (0.008)         & (0.016)         & (0.012)        \\ \addlinespace \bottomrule

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/code/analyze/fig_2_A23d.do**

- Line 208, : (scatter n b if data == "CEX", msymbol(D) color($orange) yline(0.6 1.6 2.6 3.6 4.6 5.6,lpattern(dash) lcolor(gray) ) yscale(range(-0.2 5.425)) legend(label(4 "CEX") label(2 "PSID") order(2 4) cols(2)))
- Line 289, : (scatter n b if data == "CEX", color($orange) yline(0.6 1.6 2.6 3.6 4.6 5.6,lpattern(dash) lcolor(gray) ) yscale(range(-0.2 5.425)) legend(label(4 "CEX") label(2 "PSID") order(2 4)  cols(2)))

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/code/analyze/table_A2.do**

- Line 37, : gen quintile_consumption = floor(rk_cons/20.001)
- Line 38, : gen quintile_income = floor(rk_inc/20.001)

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/durable_good_ownership.tex**

- Line 10, : Receives Transfer & -0.128***    & -0.074***    & -0.381***    & -0.156***    & 0.090    & 0.034*    & 0.008    & -0.038    \\
- Line 11, : & (0.016)          & (0.018)          & (0.012)          & (0.027)          & (0.061)          & (0.019)          & (0.017)          & (0.027)          \\ \addlinespace
- Line 13, : Receives Transfer & -0.417***      & -0.242***      & -0.711***      & -0.150      & 0.120      & -0.164***      & -0.425***      & 0.124      \\
- Line 14, : & (0.068)            & (0.076)            & (0.066)            & (0.150)            & (0.166)            & (0.063)            & (0.073)            & (0.078)            \\ \addlinespace
- Line 16, : Receives Transfer & -0.015    & 0.013    & 0.015    & -0.164***    & -0.018    & -0.004    & -0.050*    & -0.027    \\
- Line 17, : & (0.021)          & (0.025)          & (0.029)          & (0.032)          & (0.073)          & (0.019)          & (0.026)          & (0.027)          \\ \addlinespace
- Line 19, : Receives Transfer & -0.083***     & -0.025     & -0.190***     & -0.080**     & 0.026     & 0.099***     & 0.035*     & -0.019     \\
- Line 20, : & (0.020)           & (0.021)           & (0.023)           & (0.037)           & (0.055)           & (0.017)           & (0.020)           & (0.021)           \\ \addlinespace
- Line 22, : Receives Transfer & -0.087***   & 0.025   & -0.080***   & -0.071   & 0.087   & 0.069***   & -0.042*   & -0.039*   \\
- Line 23, : & (0.019)         & (0.024)         & (0.024)         & (0.047)         & (0.054)         & (0.018)         & (0.025)         & (0.023)         \\ \addlinespace
- Line 25, : Receives Transfer & -0.003 & 0.063** & -0.009 & -0.022 & -0.042 & 0.087*** & 0.031* & -0.062* \\
- Line 26, : & (0.024)       & (0.028)       & (0.031)       & (0.073)       & (0.091)       & (0.019)       & (0.017)       & (0.038)      \\ \addlinespace

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/_archive/levels_outcomes.tex**

- Line 10, : SNAP               & -0.551***   & -0.497***    & -0.898***     & -8,291***          & -11,607***                     & -17,854***                       \\
- Line 11, : & (0.039)   & (0.013)    & (0.159)     & (641)         & (326)                        & (4,116)                       \\ \addlinespace
- Line 12, : Medicaid           & -0.492*** & -0.485*** & -0.777*** & -6,637***     & -11,849***                   & -15,017***                   \\
- Line 13, : & (0.044)  & (0.021) & (0.109) & (669)     & (558)                    & (2,592)                   \\  \addlinespace
- Line 14, : Housing Assistance & -0.451***    & -0.479***       & -0.458**       & -7,476***        & -15,876***                        & -14,221**                         \\
- Line 15, : & (0.035)    & (0.016)     & (0.199)       & (618)         & (530)                         & (6,159)                         \\  \addlinespace
- Line 16, : TANF               & -0.341***    & -0.434***     & -0.264     & -3,538***      & -10,102***                    & -5,507                       \\
- Line 17, : & (0.094)   & (0.027)    & (0.268)     & (975)          & (638)                 & (5,674)                       \\  \addlinespace
- Line 18, : SSI                & -0.003    & -0.247***     & -0.208      & -23     & -7,083***                           & -1,373                        \\
- Line 19, : & (0.079)    & (0.022)      & (0.241)      & (693)        & (637)                   & (1,549)                        \\  \addlinespace
- Line 20, : School Meals                 & -0.341***   &    & -0.325*       & -3,774***          &                 & -5,589*                         \\
- Line 21, : & (0.027)  &     & (0.171)       & (325)        &                  & (2,883)                         \\  \addlinespace
- Line 22, : WIC                & -0.239***   &   & -0.186*      & -2,564***           &                    & -4,447*                        \\
- Line 23, : & (0.026)    &  & (0.108)      & (297)               &                & (2,511)                        \\   \addlinespace
- Line 24, : LIHEAP             & -0.379*** &  & -0.449***   & -5,377***             &               & -8,523***                     \\
- Line 25, : & (0.037) &  & (0.148)   & (599)                 &           & (2,818)                 \\ \addlinespace \bottomrule

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/snap_by_month_final.tex**

- Line 9, : Received SNAP in Year  & 0.063*** &                      &                      &                      & 0.057*** &                      &                      &                      \\
- Line 10, : & (0.010)     &                      &                      &                      & (0.015)     &                      &                      &                      \\
- Line 11, : Share of Year on SNAP  &                      & 0.076*** &                      &                      &                      & 0.062*** &                      &                      \\
- Line 12, : &                      & (0.013)     &                      &                      &                      & (0.018)     &                      &                      \\
- Line 13, : Received SNAP in Month &                      &                      & 0.072*** & 0.040*** &                      &                      & 0.059*** & 0.025 \\
- Line 14, : &                      &                      & (0.012)     & (0.012)     &                      &                      & (0.016)     & (0.018)     \\ \addlinespace \midrule

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/_archive/durable_good_ownership_cex.tex**

- Line 10, : Receives Transfer & -0.131***    & -0.153***    & -0.294***    & -0.203***    & -0.133***      \\
- Line 11, : & (0.007)          & (0.011)          & (0.005)          & (0.013)          & (0.013)                 \\ \addlinespace
- Line 13, : Receives Transfer & -0.383***      & -0.479***      & -0.712***      & -0.354***      & -0.285***        \\
- Line 14, : & (0.026)            & (0.043)            & (0.024)            & (0.056)            & (0.048)                  \\ \addlinespace
- Line 16, : Receives Transfer & -0.110***    & -0.067***    & 0.033***    & -0.168***    & -0.082*** \\
- Line 17, : & (0.007)          & (0.011)          & (0.008)          & (0.016)          & (0.013)          \\ \addlinespace
- Line 19, : Receives Transfer & -0.132***     & -0.093***     & -0.210***     & -0.276***     & -0.125***   \\
- Line 20, : & (0.007)           & (0.011)           & (0.008)           & (0.017)           & (0.013)        \\ \addlinespace
- Line 22, : Receives Transfer & -0.162***   & -0.008   & -0.011   & -0.098***   & -0.042***    \\
- Line 23, : & (0.007)         & (0.011)         & (0.008)         & (0.016)         & (0.012)        \\ \addlinespace \bottomrule

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/_archive/other_outcomes_c.tex**

- Line 16, : Receives Transfer & 0.051***    & 0.016    & 0.019    & 0.028    & -0.011    & 0.059***    & 0.009    & 0.031    \\
- Line 17, : & (0.016)          &
- Line 18, : (0.017)          & (0.022)          &
- Line 19, : (0.032)          & (0.052)          &
- Line 20, : (0.018)          & (0.016)
- Line 21, : & (0.020)          \\ \addlinespace
- Line 24, : Receives Transfer & 0.168***    & 0.146***    & 0.123***    & 0.188***    & 0.000    & 0.270***    & 0.005    & 0.055***    \\
- Line 25, : & (0.014)          & (0.014)          & (0.018)          & (0.031)          & (0.000)          & (0.016)          & (0.020)          & (0.019)          \\ \addlinespace
- Line 28, : Receives Transfer & 0.113***      & 0.147***      & 0.053***      & 0.052*      & 0.188***      & -0.126***      & 0.013      & 0.106***      \\
- Line 29, : & (0.016)            & (0.020)            & (0.019)            & (0.027)            & (0.036)            & (0.013)            & (0.010)            & (0.018)            \\ \addlinespace
- Line 35, : Receives Transfer & 0.066***     & 0.025     & 0.199***     & 0.001     & -0.054     & 0.052***     & -0.032     & -0.052*     \\
- Line 36, : & (0.024)           & (0.024)           & (0.030)           & (0.036)           & (0.070)           & (0.020)           & (0.022)           & (0.031)           \\ \addlinespace

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/_archive/durable_good_ownership.tex**

- Line 10, : Receives Transfer & -0.129***    & -0.074***    & -0.381***    & -0.156***    & 0.088    & 0.035*    & 0.008    & -0.039    \\
- Line 11, : & (0.016)          & (0.019)          & (0.012)          & (0.027)          & (0.061)          & (0.019)          & (0.017)          & (0.026)          \\ \addlinespace
- Line 13, : Receives Transfer & -0.417***      & -0.243***      & -0.709***      & -0.152      & 0.114      & -0.163***      & -0.426***      & 0.124      \\
- Line 14, : & (0.067)            & (0.076)            & (0.066)            & (0.149)            & (0.165)            & (0.063)            & (0.073)            & (0.079)            \\ \addlinespace
- Line 16, : Receives Transfer & -0.015    & 0.013    & 0.016    & -0.162***    & -0.015    & -0.005    & -0.051*    & -0.026    \\
- Line 17, : & (0.021)          & (0.025)          & (0.029)          & (0.032)          & (0.073)          & (0.019)          & (0.026)          & (0.027)          \\ \addlinespace
- Line 19, : Receives Transfer & -0.084***     & -0.024     & -0.189***     & -0.082**     & 0.025     & 0.098***     & 0.037*     & -0.019     \\
- Line 20, : & (0.020)           & (0.021)           & (0.023)           & (0.037)           & (0.055)           & (0.016)           & (0.020)           & (0.021)           \\ \addlinespace
- Line 22, : Receives Transfer & -0.088***   & 0.026   & -0.080***   & -0.070   & 0.074   & 0.069***   & -0.043*   & -0.040*   \\
- Line 23, : & (0.019)         & (0.024)         & (0.024)         & (0.047)         & (0.054)         & (0.018)         & (0.025)         & (0.023)         \\ \addlinespace
- Line 25, : Receives Transfer & -0.004 & 0.067** & -0.011 & -0.019 & -0.030 & 0.088*** & 0.031* & -0.061 \\
- Line 26, : & (0.024)       & (0.028)       & (0.031)       & (0.076)       & (0.089)       & (0.019)       & (0.017)       & (0.038)      \\ \addlinespace

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/other_outcomes_c.tex**

- Line 16, : Receives Transfer & 0.050***    & 0.017    & 0.019    & 0.027    & -0.010    & 0.059***    & 0.009    & 0.031    \\
- Line 17, : & (0.016)          &
- Line 18, : (0.017)          & (0.022)          &
- Line 19, : (0.032)          & (0.052)          &
- Line 20, : (0.018)          & (0.016)
- Line 21, : & (0.020)          \\ \addlinespace
- Line 24, : Receives Transfer & 0.168***    & 0.145***    & 0.122***    & 0.187***    & 0.000    & 0.269***    & 0.006    & 0.055***    \\
- Line 25, : & (0.014)          & (0.014)          & (0.018)          & (0.031)          & (0.000)          & (0.016)          & (0.020)          & (0.019)          \\ \addlinespace
- Line 28, : Receives Transfer & 0.112***      & 0.149***      & 0.053***      & 0.049*      & 0.188***      & -0.124***      & 0.013      & 0.106***      \\
- Line 29, : & (0.016)            & (0.020)            & (0.019)            & (0.026)            & (0.036)            & (0.013)            & (0.010)            & (0.018)            \\ \addlinespace
- Line 35, : Receives Transfer & 0.065***     & 0.027     & 0.199***     & 0.000     & -0.052     & 0.051**     & -0.032     & -0.052*     \\
- Line 36, : & (0.024)           & (0.024)           & (0.030)           & (0.036)           & (0.070)           & (0.020)           & (0.022)           & (0.032)           \\ \addlinespace

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/code/analyze/fig_A1.do**

- Line 124, : (rcap high low n if spec == "_c" & nonemployed == 0, color( $navy ) msize(medium) horizontal xline(0,lcolor(gs9)) xlabel(-15(5)10) xscale(range(-15 10)) yscale(range(0.5 12.125))) ///

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/code/analyze/table_2_A1.do**

- Line 28, : * Use 20.001 to classify rk = 100 --> quintile = 4 (quintile variable takes values 0,1,2,3,4)
- Line 29, : gen quintile_consumption = floor(rk_c_current_eq/20.001)
- Line 30, : gen quintile_lifetimeincome = floor(rk_lifetime_eq/20.001)
- Line 31, : gen quintile_income = floor(rk_current_eq/20.001)

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/tables/output/well_measured_c.tex**

- Line 10, : Receives Transfer                              & -0.497***             & -0.392***          & -0.820***          & -0.374***          & 0.065          & -0.224***          & -0.191***          & -0.271***          \\
- Line 11, : & (0.036)                   & (0.035)                & (0.037)                & (0.077)                & (0.104)                & (0.030)                & (0.028)                & (0.043)                \\  \addlinespace
- Line 13, : Receives Transfer                              & -0.312***    & -0.330*** & -0.177*** & -0.019 & -0.008 & -0.253*** & -0.083*** & -0.155*** \\
- Line 14, : & (0.020)          & (0.023)       & (0.025)       & (0.037)       & (0.066)       & (0.015)       & (0.019)       & (0.026)       \\  \addlinespace
- Line 16, : Receives Transfer                              & -0.602***      & -0.327***   & -0.239***   & -0.477***   & -0.048   & -0.050**   & -0.283***   & -0.298***   \\
- Line 17, : & (0.025)            & (0.029)         & (0.031)         & (0.064)         & (0.104)         & (0.025)         & (0.029)         & (0.034)         \\  \addlinespace
- Line 19, : Receives Transfer                              & -0.095***         & -0.168***      & -0.340***      & -0.169**      & 0.146**      & -0.154***      & -0.115***      & 0.017      \\
- Line 20, : & (0.030)               & (0.034)            & (0.048)            & (0.066)            & (0.068)            & (0.024)            & (0.026)            & (0.032)            \\  \addlinespace
- Line 22, : Receives Transfer                              & -0.116***        & -0.198***     & -0.127***     & -0.097     & -0.276**     & -0.098***     & -0.055*     & -0.178***     \\
- Line 23, : & (0.032)              & (0.038)           & (0.039)           & (0.072)           & (0.114)           & (0.026)           & (0.029)           & (0.041)          \\  \addlinespace

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/code/analyze/mvpf_progs.do**

- Line 304, : 0	10860	0.142
- Line 305, : 10860	21720	0.235
- Line 306, : 21720	32580	0.338
- Line 307, : 32580	43440	0.339
- Line 308, : 43440	54300	0.328
- Line 309, : 54300	65160	0.325
- Line 310, : 65160	76020	0.326
- Line 311, : 76020	86880	0.327
- Line 312, : 86880	inf	0.335
- Line 315, : local mtr_1 0.142
- Line 316, : local mtr_2 0.235
- Line 317, : local mtr_3 0.338
- Line 318, : local mtr_4 0.339
- Line 319, : local mtr_5 0.328
- Line 320, : local mtr_6 0.325
- Line 321, : local mtr_7 0.326
- Line 322, : local mtr_8 0.327
- Line 323, : local mtr_9 0.335

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/packages/ebayes.ado**

- Line 24, : tol(real 0.000001) maxiter(integer 100) ]

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/code/clean/psid/03_merge_psid_reshape_lifetime_earnings.do**

- Line 133, : lpoly eq_cons rk, bw(0.005) deg(2) gen(consumption_real_at_rk) at(at_rk) nograph n(1000)

**/var/folders/5q/yhcyv3z55wvg6lhgc3h22kk00000gq/T/20241011-2/replication-package/replication/code/clean/psid/01_psid_reshape.do**

- Line 149, : replace cpi = 62.01610 if year == 1997
- Line 150, : replace cpi = 64.35663 if year == 1999
- Line 151, : replace cpi = 68.39703 if year == 2001
- Line 152, : replace cpi = 71.08526 if year == 2003
- Line 153, : replace cpi = 75.43795 if year == 2005
- Line 154, : replace cpi = 80.10388 if year == 2007
- Line 155, : replace cpi = 82.89340 if year == 2009
- Line 156, : replace cpi = 86.89517 if year == 2011
- Line 157, : replace cpi = 89.99694 if year == 2013
- Line 158, : replace cpi = 91.56159 if year == 2015
- Line 159, : replace cpi = 94.70392 if year == 2017
- Line 160, : replace cpi = 98.76702 if year == 2019
- Line 662, : * 52.1429 weeks in a year
- Line 663, : replace tanf_amt_`v' = 52.1429 * tanf_amt_`v' if tanf_unit_`v' == 3
- Line 664, : replace tanf_amt_`v' = (52.1429/2) * tanf_amt_`v' if tanf_unit_`v' == 4
- Line 746, : replace snap_amt_hh = 52.1429 * snap_amt_hh if snap_unit == 3
- Line 747, : replace snap_amt_hh = (52.1429/2) * snap_amt_hh if snap_unit == 4
- Line 783, : replace ssi_amt_`v' = 52.1429 * ssi_amt_`v' if ssi_unit_`v' == 3
- Line 784, : replace ssi_amt_`v' = (52.1429/2) * ssi_amt_`v' if ssi_unit_`v' == 4
- Line 847, : replace ui_amt_`v' = 52.1429 * ui_amt_`v' if ui_unit_`v' == 3
- Line 848, : replace ui_amt_`v' = (52.1429/2) * ui_amt_`v' if ui_unit_`v' == 4
- Line 891, : replace wc_amt_`v' = 52.1429 * wc_amt_`v' if wc_freq_`v' == 3
- Line 892, : replace wc_amt_`v' = (52.1429/2) * wc_amt_`v' if wc_freq_`v' == 4
- Line 998, : replace othwelf_amt_`v' = 52.1429 * othwelf_amt_`v' if othwelf_unit_`v' == 3
- Line 999, : replace othwelf_amt_`v' = (52.1429/2) * othwelf_amt_`v' if othwelf_unit_`v' == 4
- Line 1171, : replace `v' = 52.1429 * `v' if `v'_unit == 3
- Line 1172, : replace `v' = (52.1429/2) * `v' if `v'_unit == 4
- Line 1297, : replace `p'_`v'_amt = 52.1429 * `p'_`v'_amt if `p'_`v'_unit == 3
- Line 1298, : replace `p'_`v'_amt = (52.1429/2) * `p'_`v'_amt if `p'_`v'_unit == 4

