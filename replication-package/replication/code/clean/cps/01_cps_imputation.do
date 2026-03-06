/***************************************************************************

This code cleans the raw CPS data and then imputes average values of 
Medicaid, public housing, and rent subsidies by year and family size.

Input:
- data/cps/cps_00092.dat

Output:
- data/cps/cps_imputation.dta

***************************************************************************/

* Set working directory

	do code/settings.do
	set more off

*** IPUMS CLEANER CODE
* NOTE: You need to set the Stata working directory to the path
* where the data file is located.

	set more off

	clear
	quietly infix                  ///
	  int     year        1-4      ///
	  long    serial      5-9      ///
	  byte    month       10-11    ///
	  double  cpsid       12-25    ///
	  byte    asecflag    26-26    ///
	  double  asecwth     27-37    ///
	  byte    pubhous     38-38    ///
	  byte    rentsub     39-39    ///
	  byte    pernum      40-41    ///
	  double  cpsidp      42-55    ///
	  double  asecwt      56-66    ///
	  int     relate      67-70    ///
	  byte    age         71-72    ///
	  byte    famsize     73-74    ///
	  byte    famunit     75-76    ///
	  byte    famid       77-78    ///
	  double  asecfwt     79-90    ///
	  double  incwage     91-98    ///
	  int     houssub     99-101   /// 
	  long    spmlunch    102-106  ///
	  double  spmcaphous  107-124  ///
	  long    ffngcaid    125-129  ///
	  using `"$dir/data/cps/cps_00092.dat"'

	replace asecwth    = asecwth    / 10000
	replace asecwt     = asecwt     / 10000
	replace asecfwt    = asecfwt    / 100

	format cpsid      %14.0f
	format asecwth    %11.4f
	format cpsidp     %14.0f
	format asecwt     %11.4f
	format asecfwt    %12.2f
	format incwage    %8.0f
	format spmcaphous %18.0g

	label var year       `"Survey year"'
	label var serial     `"Household serial number"'
	label var month      `"Month"'
	label var cpsid      `"CPSID, household record"'
	label var asecflag   `"Flag for ASEC"'
	label var asecwth    `"Annual Social and Economic Supplement Household weight"'
	label var pubhous    `"Living in public housing"'
	label var rentsub    `"Paying lower rent due to government subsidy"'
	label var pernum     `"Person number in sample unit"'
	label var cpsidp     `"CPSID, person record"'
	label var asecwt     `"Annual Social and Economic Supplement Weight"'
	label var relate     `"Relationship to household head"'
	label var age        `"Age"'
	label var famsize    `"Number of own family members in hh"'
	label var famunit    `"Family unit membership"'
	label var famid      `"Unique Family Identifier"'
	label var asecfwt    `"ASEC Family weight"'
	label var incwage    `"Wage and salary income"'
	label var houssub    `"Family market value of housing"'
	label var spmlunch   `"SPM unit's school lunch value"'
	label var spmcaphous `"SPM unit's capped housing subsidy"'
	label var ffngcaid   `"Family fungible value of Medicaid"'

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

	label define pubhous_lbl 0 `"NIU"'
	label define pubhous_lbl 1 `"No"', add
	label define pubhous_lbl 2 `"Yes"', add
	label values pubhous pubhous_lbl

	label define rentsub_lbl 0 `"NIU"'
	label define rentsub_lbl 1 `"No"', add
	label define rentsub_lbl 2 `"Yes"', add
	label values rentsub rentsub_lbl

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

	label define famunit_lbl 01 `"1st family in household or group quarters"'
	label define famunit_lbl 02 `"2nd family in household or group quarters"', add
	label define famunit_lbl 03 `"3rd"', add
	label define famunit_lbl 04 `"4th"', add
	label define famunit_lbl 05 `"5th"', add
	label define famunit_lbl 06 `"6th"', add
	label define famunit_lbl 07 `"7th"', add
	label define famunit_lbl 08 `"8th"', add
	label define famunit_lbl 09 `"9th"', add
	label define famunit_lbl 10 `"10"', add
	label define famunit_lbl 11 `"11"', add
	label define famunit_lbl 12 `"12"', add
	label define famunit_lbl 13 `"13"', add
	label define famunit_lbl 14 `"14"', add
	label define famunit_lbl 15 `"15"', add
	label define famunit_lbl 16 `"16"', add
	label define famunit_lbl 17 `"17"', add
	label define famunit_lbl 18 `"18"', add
	label define famunit_lbl 19 `"19"', add
	label define famunit_lbl 20 `"20"', add
	label define famunit_lbl 21 `"21"', add
	label define famunit_lbl 22 `"22"', add
	label define famunit_lbl 23 `"23"', add
	label define famunit_lbl 24 `"24"', add
	label define famunit_lbl 25 `"25"', add
	label define famunit_lbl 26 `"26"', add
	label define famunit_lbl 27 `"27"', add
	label define famunit_lbl 28 `"28"', add
	label define famunit_lbl 29 `"29"', add
	label values famunit famunit_lbl
	
*** IMPUTATION

	replace famsize = 7 if famsize > 7 & !missing(famsize)

	* Estimate Medicaid value by year and HH size

		preserve

		gen ffngcaid_ = ffngcaid
		replace ffngcaid_ = . if ffngcaid == 0
		
		ppmlhdfe ffngcaid_ i.famsize i.year [pw=asecfwt]
		mat b = e(b)
		local year_2011_fe = b[1,15]
		
		predict medicaid_amt_hh, mu
		
		gcollapse medicaid_amt_hh [aw=asecfwt], by(famsize year)
		
		replace medicaid_amt_hh = exp(`year_2011_fe')*medicaid_amt_hh if year > 2011 & !missing(year)
		
		tempfile cps_imputation
		save `cps_imputation', replace
		
		restore
		
	* Estimate public housing value by year and HH size

		preserve
				
		ppmlhdfe spmcaphous i.famsize i.year if pubhous == 2 [pw=asecfwt]
		
		predict pubhou_amt_hh, mu
		
		gcollapse pubhou_amt_hh [aw=asecfwt], by(famsize year)
		
		merge 1:1 famsize year using `cps_imputation', nogen keep(3)
		save `cps_imputation', replace
		
		restore
		
	* Estimate rent subsidy value by year and HH size
		
		preserve
		
		ppmlhdfe spmcaphous i.famsize i.year if rentsub == 2 [pw=asecfwt]
		
		predict rent_subsidy_amt_hh, mu
		
		gcollapse rent_subsidy_amt_hh [aw=asecfwt], by(famsize year)
		
		merge 1:1 famsize year using `cps_imputation', nogen keep(3)
		save `cps_imputation', replace
		
		restore
		
	* Estimate school lunch by year and HH size
		
		ppmlhdfe spmlunch i.famsize i.year if spmlunch > 0 [pw=asecfwt]
		
		predict spmlunch_amt_hh, mu
		
		gcollapse spmlunch_amt_hh [aw=asecfwt], by(famsize year)
		
		merge 1:1 famsize year using `cps_imputation', nogen keep(3)
		save `cps_imputation', replace
				
	* Save dataset
	
		use `cps_imputation', clear
	
		rename famsize hhsize
	
		save "$dir/data/cps/cps_imputation.dta", replace
