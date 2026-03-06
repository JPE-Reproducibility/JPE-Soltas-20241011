/***************************************************************************
			Housing Assistance - Public Housing & Rent Subsidies
			
Data sources:
- Section 8 income limits by family size: https://www.huduser.gov/portal/datasets/il.html
			
Input:
- data/eligsim/housing_assistance/incfy97.dta
- data/eligsim/housing_assistance/incfy98.dta
- data/eligsim/housing_assistance/incfy99.dta
- data/eligsim/housing_assistance/incfy00.dta
- data/eligsim/housing_assistance/incfy01.dta
- data/eligsim/housing_assistance/incfy02.dta
- data/eligsim/housing_assistance/incfy03.dta
- data/eligsim/housing_assistance/incfy04.dta
- data/eligsim/housing_assistance/incfy05.dta
- data/eligsim/housing_assistance/incfy06.dta
- data/eligsim/housing_assistance/incfy07.dta
- data/eligsim/housing_assistance/incfy08.dta
- data/eligsim/housing_assistance/incfy09.dta
- data/eligsim/housing_assistance/incfy10.dta
- data/eligsim/housing_assistance/incfy11.dta
- data/eligsim/housing_assistance/incfy12.dta
- data/eligsim/housing_assistance/incfy13.dta
- data/eligsim/housing_assistance/incfy14.dta
- data/eligsim/housing_assistance/incfy15.dta
- data/eligsim/housing_assistance/incfy16.dta
- data/eligsim/housing_assistance/incfy17.dta
- data/eligsim/housing_assistance/incfy18.dta
- data/eligsim/housing_assistance/incfy19.dta

Output:
- data/eligsim/housing_assistance/inc_limit.dta

***************************************************************************/
* Settings

	do code/settings
	
	set more off
* 1997

	use "$dir/data/eligsim/housing_assistance/incfy97.dta", clear
	
	gen ami_hhsize1 = inclimit*0.5*0.7
	gen ami_hhsize2 = inclimit*0.5*0.8
	gen ami_hhsize3 = inclimit*0.5*0.9
	gen ami_hhsize4 = inclimit*0.5
	gen ami_hhsize5 = inclimit*0.5*1.08
	gen ami_hhsize6 = inclimit*0.5*1.16
	gen ami_hhsize7 = inclimit*0.5*1.24
	gen ami_hhsize8 = inclimit*0.5*1.32
	
	drop inclimit
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 1997
	
	tempfile dat1997
	save `dat1997', replace
	

* 1998

	use "$dir/data/eligsim/housing_assistance/incfy98.dta", clear
	
	gen ami_hhsize1 = inclimit*0.5*0.7
	gen ami_hhsize2 = inclimit*0.5*0.8
	gen ami_hhsize3 = inclimit*0.5*0.9
	gen ami_hhsize4 = inclimit*0.5
	gen ami_hhsize5 = inclimit*0.5*1.08
	gen ami_hhsize6 = inclimit*0.5*1.16
	gen ami_hhsize7 = inclimit*0.5*1.24
	gen ami_hhsize8 = inclimit*0.5*1.32
	
	drop inclimit
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 1998
	
	tempfile dat1998
	save `dat1998', replace

* 1999
	
	import excel "$dir/data/eligsim/housing_assistance/incfy99.xls", sheet("netskim") firstrow case(lower) clear
	
	drop if hudmsacode == 0
	
	keep fipsstatecode verylow50incomelimit1 q r s t u v w
	
	rename fipsstatecode state
	rename verylow50incomelimit1 ami_hhsize1 
	rename q ami_hhsize2
	rename r ami_hhsize3
	rename s ami_hhsize4
	rename t ami_hhsize5
	rename u ami_hhsize6
	rename v ami_hhsize7
	rename w ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 1999
	
	tempfile dat1999
	save `dat1999', replace
	

* 2000
	
	import excel "$dir/data/eligsim/housing_assistance/incfy00.xls", sheet("long") firstrow case(lower) clear
	
	drop if hudmsacode == 0
	
	keep fipsstatecode verylow50incomelimit1 q r s t u v w
	
	rename fipsstatecode state
	rename verylow50incomelimit1 ami_hhsize1 
	rename q ami_hhsize2
	rename r ami_hhsize3
	rename s ami_hhsize4
	rename t ami_hhsize5
	rename u ami_hhsize6
	rename v ami_hhsize7
	rename w ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2000
	
	tempfile dat2000
	save `dat2000', replace
	
* 2001
	
	import excel "$dir/data/eligsim/housing_assistance/incfy01.xls", sheet("incfy01") firstrow case(lower) clear
	
	drop if hudmsacode == 0
	
	keep fipsstatecode verylow50incomelimit1 q r s t u v w
	
	rename fipsstatecode state
	rename verylow50incomelimit1 ami_hhsize1 
	rename q ami_hhsize2
	rename r ami_hhsize3
	rename s ami_hhsize4
	rename t ami_hhsize5
	rename u ami_hhsize6
	rename v ami_hhsize7
	rename w ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2001
	
	tempfile dat2001
	save `dat2001', replace
	
* 2002

	import excel "$dir/data/eligsim/housing_assistance/incfy02.xls", firstrow case(lower) clear
	
	drop if msa == 10000
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2002
	
	tempfile dat2002
	save `dat2002', replace
	
* 2003

	import excel "$dir/data/eligsim/housing_assistance/incfy03.xls", firstrow case(lower) clear
	
	drop if msa == 10000
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2003
	
	tempfile dat2003
	save `dat2003', replace
	
* 2004

	import excel "$dir/data/eligsim/housing_assistance/incfy04.xls", firstrow case(lower) clear
	
	drop if msa == 10000
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2004
	
	tempfile dat2004
	save `dat2004', replace
	
* 2005

	import excel "$dir/data/eligsim/housing_assistance/incfy05.xls", firstrow case(lower) clear
	
	drop if msa == 10000
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2005
	
	tempfile dat2005
	save `dat2005', replace
	
* 2006

	import excel "$dir/data/eligsim/housing_assistance/incfy06.xls", firstrow case(lower) clear
	
	drop if msa == 10000
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2006
	
	tempfile dat2006
	save `dat2006', replace
	
* 2007

	import excel "$dir/data/eligsim/housing_assistance/incfy07.xls", firstrow case(lower) clear
	
	keep if metro == 1
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2007
	
	tempfile dat2007
	save `dat2007', replace
	
* 2008

	import excel "$dir/data/eligsim/housing_assistance/incfy08.xls", firstrow case(lower) clear
	
	keep if metro == 1
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2008

	tempfile dat2008
	save `dat2008', replace
	
* 2009

	import excel "$dir/data/eligsim/housing_assistance/incfy09.xls", firstrow case(lower) clear
	
	keep if metro == 1
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2009
	
	tempfile dat2009
	save `dat2009', replace

* 2010

	import excel "$dir/data/eligsim/housing_assistance/incfy10.xls", firstrow case(lower) clear
	
	keep if metro == 1
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2010
	
	tempfile dat2010
	save `dat2010', replace
	
* 2011

	import excel "$dir/data/eligsim/housing_assistance/incfy11.xls", firstrow case(lower) clear
	
	keep if metro == 1
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2011
	
	tempfile dat2011
	save `dat2011', replace
	
* 2012

	import excel "$dir/data/eligsim/housing_assistance/incfy12.xls", firstrow case(lower) clear
	
	keep if metro == 1
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2012
	
	tempfile dat2012
	save `dat2012', replace
	
* 2013

	import excel "$dir/data/eligsim/housing_assistance/incfy13.xls", firstrow case(lower) clear
	
	keep if metro == 1
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2013
	
	tempfile dat2013
	save `dat2013', replace

* 2014

	import excel "$dir/data/eligsim/housing_assistance/incfy14.xls", firstrow case(lower) clear
	
	keep if metro == 1
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2014
	
	tempfile dat2014
	save `dat2014', replace
	
* 2015

	import excel "$dir/data/eligsim/housing_assistance/incfy15.xlsx", firstrow case(lower) clear
	
	keep if metro == 1
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2015
	
	tempfile dat2015
	save `dat2015', replace
	
* 2016

	import excel "$dir/data/eligsim/housing_assistance/incfy16.xlsx", firstrow case(lower) clear
	
	keep if metro == 1
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2016
	
	tempfile dat2016
	save `dat2016', replace
	
* 2017

	import excel "$dir/data/eligsim/housing_assistance/incfy17.xlsx", firstrow case(lower) clear
	
	keep if metro == 1
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2017
	
	tempfile dat2017
	save `dat2017', replace
	
* 2018

	import excel "$dir/data/eligsim/housing_assistance/incfy18.xlsx", firstrow case(lower) clear
	
	keep if metro == 1
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2018
	
	tempfile dat2018
	save `dat2018', replace
	
* 2019

	import excel "$dir/data/eligsim/housing_assistance/incfy19.xlsx", firstrow case(lower) clear
	
	keep if metro == 1
	
	keep state l50_1 l50_2 l50_3 l50_4 l50_5 l50_6 l50_7 l50_8
	
	rename l50_1 ami_hhsize1 
	rename l50_2 ami_hhsize2
	rename l50_3 ami_hhsize3
	rename l50_4 ami_hhsize4
	rename l50_5 ami_hhsize5
	rename l50_6 ami_hhsize6
	rename l50_7 ami_hhsize7
	rename l50_8 ami_hhsize8
	
	collapse (median) ami_hhsize*, by(state)
	
	reshape long ami_hhsize, i(state) j(hhsize)
	
	rename ami_hhsize ami
	
	gen year = 2019
	
	tempfile dat2019
	save `dat2019', replace
	
* Assemble data 

	use `dat1997', clear
	
	forvalues y = 1998(1)2019 {
		append using `dat`y''
	}
	
	drop if inlist(state,66,72,78) | missing(state)
	
	save "$dir/data/eligsim/housing_assistance/inc_limit.dta", replace
