/***************************************************************************

This code uses CPS data to compute average tax liabilities and marginal tax
rates at each equivalized household earnings percentile rank.

***************************************************************************/

*** Raw cleaning code from IPUMS (unchanged)

	* NOTE: You need to set the Stata working directory to the path
	* where the data file is located.

	set more off

	clear
	quietly infix                ///
	  int     year      1-4      ///
	  long    serial    5-9      ///
	  byte    month     10-11    ///
	  double  cpsid     12-25    ///
	  byte    asecflag  26-26    ///
	  double  asecwth   27-36    ///
	  byte    pernum    37-38    ///
	  double  cpsidp    39-52    ///
	  double  asecwt    53-62    ///
	  int     relate    63-66    ///
	  byte    age       67-68    ///
	  byte    famsize   69-70    ///
	  byte    nchild    71-71    ///
	  double  ftotval   72-81    ///
	  double  adjginc   82-89    ///
	  double  fedtax    90-97    ///
	  double  fedtaxac  98-105   ///
	  byte    filestat  106-106  ///
	  byte    margtax   107-108  ///
	  long    taxinc    109-115  ///
	  using `"$dir/data/cps/cps_00066.dat"'

	replace asecwth  = asecwth  / 10000
	replace asecwt   = asecwt   / 10000

	format cpsid    %14.0f
	format asecwth  %10.4f
	format cpsidp   %14.0f
	format asecwt   %10.4f
	format ftotval  %10.0f
	format adjginc  %8.0f
	format fedtax   %8.0f
	format fedtaxac %8.0f

	label var year     `"Survey year"'
	label var serial   `"Household serial number"'
	label var month    `"Month"'
	label var cpsid    `"CPSID, household record"'
	label var asecflag `"Flag for ASEC"'
	label var asecwth  `"Annual Social and Economic Supplement Household weight"'
	label var pernum   `"Person number in sample unit"'
	label var cpsidp   `"CPSID, person record"'
	label var asecwt   `"Annual Social and Economic Supplement Weight"'
	label var relate   `"Relationship to household head"'
	label var age      `"Age"'
	label var famsize  `"Number of own family members in hh"'
	label var nchild   `"Number of own children in household"'
	label var ftotval  `"Total family income"'
	label var adjginc  `"Adjusted gross income"'
	label var fedtax   `"Federal income tax liability, before credits"'
	label var fedtaxac `"Federal income tax liability, after all credits"'
	label var filestat `"Tax filer status"'
	label var margtax  `"Federal income marginal tax rate"'
	label var taxinc   `"Taxable income amount"'

	label define month_lbl 01 `"January"'
	label define month_lbl 02 `"February"', add
	label define month_lbl 03 `"March"', add
	label define month_lbl 04 `"April"', add
	label define month_lbl 05 `"May"', add
	label define month_lbl 06 `"June"', add
	label define month_lbl 07 `"July"', add
	label define month_lbl 08 `"August"', add
	label define month_lbl 09 `"September"', add
	label define month_lbl 10 `"October"', add
	label define month_lbl 11 `"November"', add
	label define month_lbl 12 `"December"', add
	label values month month_lbl

	label define asecflag_lbl 1 `"ASEC"'
	label define asecflag_lbl 2 `"March Basic"', add
	label values asecflag asecflag_lbl

	label define relate_lbl 0101 `"Head/householder"'
	label define relate_lbl 0201 `"Spouse"', add
	label define relate_lbl 0202 `"Opposite sex spouse"', add
	label define relate_lbl 0203 `"Same sex spouse"', add
	label define relate_lbl 0301 `"Child"', add
	label define relate_lbl 0303 `"Stepchild"', add
	label define relate_lbl 0501 `"Parent"', add
	label define relate_lbl 0701 `"Sibling"', add
	label define relate_lbl 0901 `"Grandchild"', add
	label define relate_lbl 1001 `"Other relatives, n.s."', add
	label define relate_lbl 1113 `"Partner/roommate"', add
	label define relate_lbl 1114 `"Unmarried partner"', add
	label define relate_lbl 1116 `"Opposite sex unmarried partner"', add
	label define relate_lbl 1117 `"Same sex unmarried partner"', add
	label define relate_lbl 1115 `"Housemate/roomate"', add
	label define relate_lbl 1241 `"Roomer/boarder/lodger"', add
	label define relate_lbl 1242 `"Foster children"', add
	label define relate_lbl 1260 `"Other nonrelatives"', add
	label define relate_lbl 9100 `"Armed Forces, relationship unknown"', add
	label define relate_lbl 9200 `"Age under 14, relationship unknown"', add
	label define relate_lbl 9900 `"Relationship unknown"', add
	label define relate_lbl 9999 `"NIU"', add
	label values relate relate_lbl

	label define age_lbl 00 `"Under 1 year"'
	label define age_lbl 01 `"1"', add
	label define age_lbl 02 `"2"', add
	label define age_lbl 03 `"3"', add
	label define age_lbl 04 `"4"', add
	label define age_lbl 05 `"5"', add
	label define age_lbl 06 `"6"', add
	label define age_lbl 07 `"7"', add
	label define age_lbl 08 `"8"', add
	label define age_lbl 09 `"9"', add
	label define age_lbl 10 `"10"', add
	label define age_lbl 11 `"11"', add
	label define age_lbl 12 `"12"', add
	label define age_lbl 13 `"13"', add
	label define age_lbl 14 `"14"', add
	label define age_lbl 15 `"15"', add
	label define age_lbl 16 `"16"', add
	label define age_lbl 17 `"17"', add
	label define age_lbl 18 `"18"', add
	label define age_lbl 19 `"19"', add
	label define age_lbl 20 `"20"', add
	label define age_lbl 21 `"21"', add
	label define age_lbl 22 `"22"', add
	label define age_lbl 23 `"23"', add
	label define age_lbl 24 `"24"', add
	label define age_lbl 25 `"25"', add
	label define age_lbl 26 `"26"', add
	label define age_lbl 27 `"27"', add
	label define age_lbl 28 `"28"', add
	label define age_lbl 29 `"29"', add
	label define age_lbl 30 `"30"', add
	label define age_lbl 31 `"31"', add
	label define age_lbl 32 `"32"', add
	label define age_lbl 33 `"33"', add
	label define age_lbl 34 `"34"', add
	label define age_lbl 35 `"35"', add
	label define age_lbl 36 `"36"', add
	label define age_lbl 37 `"37"', add
	label define age_lbl 38 `"38"', add
	label define age_lbl 39 `"39"', add
	label define age_lbl 40 `"40"', add
	label define age_lbl 41 `"41"', add
	label define age_lbl 42 `"42"', add
	label define age_lbl 43 `"43"', add
	label define age_lbl 44 `"44"', add
	label define age_lbl 45 `"45"', add
	label define age_lbl 46 `"46"', add
	label define age_lbl 47 `"47"', add
	label define age_lbl 48 `"48"', add
	label define age_lbl 49 `"49"', add
	label define age_lbl 50 `"50"', add
	label define age_lbl 51 `"51"', add
	label define age_lbl 52 `"52"', add
	label define age_lbl 53 `"53"', add
	label define age_lbl 54 `"54"', add
	label define age_lbl 55 `"55"', add
	label define age_lbl 56 `"56"', add
	label define age_lbl 57 `"57"', add
	label define age_lbl 58 `"58"', add
	label define age_lbl 59 `"59"', add
	label define age_lbl 60 `"60"', add
	label define age_lbl 61 `"61"', add
	label define age_lbl 62 `"62"', add
	label define age_lbl 63 `"63"', add
	label define age_lbl 64 `"64"', add
	label define age_lbl 65 `"65"', add
	label define age_lbl 66 `"66"', add
	label define age_lbl 67 `"67"', add
	label define age_lbl 68 `"68"', add
	label define age_lbl 69 `"69"', add
	label define age_lbl 70 `"70"', add
	label define age_lbl 71 `"71"', add
	label define age_lbl 72 `"72"', add
	label define age_lbl 73 `"73"', add
	label define age_lbl 74 `"74"', add
	label define age_lbl 75 `"75"', add
	label define age_lbl 76 `"76"', add
	label define age_lbl 77 `"77"', add
	label define age_lbl 78 `"78"', add
	label define age_lbl 79 `"79"', add
	label define age_lbl 80 `"80"', add
	label define age_lbl 81 `"81"', add
	label define age_lbl 82 `"82"', add
	label define age_lbl 83 `"83"', add
	label define age_lbl 84 `"84"', add
	label define age_lbl 85 `"85"', add
	label define age_lbl 86 `"86"', add
	label define age_lbl 87 `"87"', add
	label define age_lbl 88 `"88"', add
	label define age_lbl 89 `"89"', add
	label define age_lbl 90 `"90 (90+, 1988-2002)"', add
	label define age_lbl 91 `"91"', add
	label define age_lbl 92 `"92"', add
	label define age_lbl 93 `"93"', add
	label define age_lbl 94 `"94"', add
	label define age_lbl 95 `"95"', add
	label define age_lbl 96 `"96"', add
	label define age_lbl 97 `"97"', add
	label define age_lbl 98 `"98"', add
	label define age_lbl 99 `"99+"', add
	label values age age_lbl

	label define famsize_lbl 00 `"Missing"'
	label define famsize_lbl 01 `"1 family member present"', add
	label define famsize_lbl 02 `"2 family members present"', add
	label define famsize_lbl 03 `"3 family members present"', add
	label define famsize_lbl 04 `"4 family members present"', add
	label define famsize_lbl 05 `"5 family members present"', add
	label define famsize_lbl 06 `"6 family members present"', add
	label define famsize_lbl 07 `"7 family members present"', add
	label define famsize_lbl 08 `"8 family members present"', add
	label define famsize_lbl 09 `"9 family members present"', add
	label define famsize_lbl 10 `"10 family members present"', add
	label define famsize_lbl 11 `"11 family members present"', add
	label define famsize_lbl 12 `"12 family members present"', add
	label define famsize_lbl 13 `"13 family members present"', add
	label define famsize_lbl 14 `"14 family members present"', add
	label define famsize_lbl 15 `"15 family members present"', add
	label define famsize_lbl 16 `"16 family members present"', add
	label define famsize_lbl 17 `"17 family members present"', add
	label define famsize_lbl 18 `"18 family members present"', add
	label define famsize_lbl 19 `"19 family members present"', add
	label define famsize_lbl 20 `"20 family members present"', add
	label define famsize_lbl 21 `"21 family members present"', add
	label define famsize_lbl 22 `"22 family members present"', add
	label define famsize_lbl 23 `"23 family members present"', add
	label define famsize_lbl 24 `"24 family members present"', add
	label define famsize_lbl 25 `"25 family members present"', add
	label define famsize_lbl 26 `"26 family members present"', add
	label define famsize_lbl 27 `"27 family members present"', add
	label define famsize_lbl 28 `"28 family members present"', add
	label define famsize_lbl 29 `"29 family members present"', add
	label values famsize famsize_lbl

	label define nchild_lbl 0 `"0 children present"'
	label define nchild_lbl 1 `"1 child present"', add
	label define nchild_lbl 2 `"2"', add
	label define nchild_lbl 3 `"3"', add
	label define nchild_lbl 4 `"4"', add
	label define nchild_lbl 5 `"5"', add
	label define nchild_lbl 6 `"6"', add
	label define nchild_lbl 7 `"7"', add
	label define nchild_lbl 8 `"8"', add
	label define nchild_lbl 9 `"9+"', add
	label values nchild nchild_lbl

	label define filestat_lbl 0 `"No data"'
	label define filestat_lbl 1 `"Joint, both less than 65"', add
	label define filestat_lbl 2 `"Joint, one less than 65, one 65+"', add
	label define filestat_lbl 3 `"Joint, both 65+"', add
	label define filestat_lbl 4 `"Head of household"', add
	label define filestat_lbl 5 `"Single"', add
	label define filestat_lbl 6 `"Nonfiler"', add
	label values filestat filestat_lbl

*** OUR CODE BEGINS HERE
	
* Keep household heads
keep if relate == 101

rename margtax mtr_fedinc

* Compute ranks (for equivalized households)

	gen equivalence_scale = ((famsize-nchild)+0.7*nchild)^0.7
	gen eq_earnings = adjginc / equivalence_scale

	egen rk_current_eq = rank(eq_earnings), unique by(year)
	bys year: gegen max_rk_current_eq = max(rk_current_eq)
	replace rk_current_eq = 100*(rk_current_eq - 1) / (max_rk_current_eq - 1)

* Compute ATR from federal income tax
gen atr_fedinc = 100 * fedtaxac / adjginc
replace atr_fedinc = . if atr_fedinc > 100

* Simulate payroll tax

	* Taxable wage base by year
	gen twb = .
	replace twb = 68400 if year == 1997
	replace twb = 72600 if year == 1999
	replace twb = 80400 if year == 2001
	replace twb = 87000 if year == 2003
	replace twb = 90000 if year == 2005
	replace twb = 97500 if year == 2007
	replace twb = 106800 if year == 2009
	replace twb = 106800 if year == 2011
	replace twb = 113700 if year == 2013
	replace twb = 118500 if year == 2015
	replace twb = 127200 if year == 2017
	replace twb = 132900 if year == 2019

	* Compute ATR and MTR
	gen atr_payroll = max(0,15.3*(1-max(0,(adjginc-twb)/twb)))
	gen mtr_payroll = 2.9 + 12.4*(adjginc < twb) + 0.9*(adjginc > 200000 & year >= 2013)

* Compute total tax rates
gen atr_tot = atr_fedinc + atr_payroll
gen mtr_tot = mtr_fedinc + mtr_payroll

* Compute total liability
gen taxliab = fedtaxac + (atr_tot/100)*adjginc

* Adjust tax liabilities as per CPI

	gen cpi = .
	replace cpi = 62.01610 if year == 1997
	replace cpi = 64.35663 if year == 1999
	replace cpi = 68.39703 if year == 2001
	replace cpi = 71.08526 if year == 2003
	replace cpi = 75.43795 if year == 2005
	replace cpi = 80.10388 if year == 2007
	replace cpi = 82.89340 if year == 2009
	replace cpi = 86.89517 if year == 2011
	replace cpi = 89.99694 if year == 2013
	replace cpi = 91.56159 if year == 2015
	replace cpi = 94.70392 if year == 2017
	replace cpi = 98.76702 if year == 2019
	
	replace taxliab = 100*taxliab/cpi

* Round to nearest percentile and then collapse to means
replace rk_current_eq = ceil(rk_current_eq)
replace rk_current_eq = 1 if rk_current_eq == 0
collapse mtr_tot atr_tot taxliab [aw=asecwth], by(rk_current_eq)

* Fill in missings (due to income=0)
foreach v of varlist mtr_tot atr_tot taxliab {
	replace `v' = `v'[_n-1] if missing(`v') & !missing(`v'[_n-1])
}

* Save to data file
save "$dir/data/cps/taxrates.dta", replace
