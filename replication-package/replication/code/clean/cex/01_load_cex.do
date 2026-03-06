* Input for 02_process_cex.do
* Purpose: Loads the CEX files from raw data, pulling out the variables needed

do code/settings.do	

*** Helper program to load datasets

capture program drop load
program define load

	syntax, file(str) vars(str) year(int) qtr(int)
	
	* Use data file
	di "$dir/data/cex/raw/`file'"
	capture use "$dir/data/cex/raw/`file'", clear
	
	* Fix folder structure inconsistency in CEX waves
	if _rc != 0 {
		local newfile = substr("`file'",strpos("`file'","/")+1,.)
		use "$dir/data/cex/raw/`newfile'", clear
	}
	
	* Find common support of variable names
	quietly ds
	local vlist_local "`r(varlist)'"
	local vlist_external "`vars'"
	local vlist_common : list vlist_external & vlist_local
	keep `vlist_common'
	
	* Add year and quarter variables
	gen year = `year'
	gen qtr = `qtr'
	
	* Add filename variable
	local newfile = substr("`file'",strpos("`file'","/")+1,.)
	local newfile = substr("`newfile'",strpos("`newfile'","/")+1,.)
	gen file = "`newfile'"
	
	* Make sure variable types are consistent
	capture tostring newid, replace
	
	* Save output
	save "$dir/data/cex/int/`newfile'", replace
	
end

capture program drop load_annual
program define load_annual

	syntax, file(str) vars(str) year(int)
	
	* Use data file
	di "$dir/data/cex/raw/`file'"
	capture use "$dir/data/cex/raw/`file'", clear
	
	* Fix folder structure inconsistency in CEX waves
	if _rc != 0 {
		local newfile = substr("`file'",strpos("`file'","/")+1,.)
		use "$dir/data/cex/raw/`newfile'", clear
	}
	
	* Find common support of variable names
	quietly ds
	local vlist_local "`r(varlist)'"
	local vlist_external "`vars'"
	local vlist_common : list vlist_external & vlist_local
	keep `vlist_common'
	
	* Add year and quarter variables
	gen year = `year'
	
	* Add filename variable
	local newfile = substr("`file'",strpos("`file'","/")+1,.)
	local newfile = substr("`newfile'",strpos("`newfile'","/")+1,.)
	gen file = "`newfile'"
	
	* Make sure variable types are consistent
	capture tostring newid, replace
	capture tostring hhipdlib, replace
	
	* Save output
	save "$dir/data/cex/int/`newfile'", replace
	
end


*** Variable lists by concept (apply across years)

	* Transfer programs
	local vlist_snap "foodsmpm foodsmpq foodsmpx foodsmp1 foodsmp2 foodsmp3 foodsmp4 foodsmp5 foodsmpi foodspbx fs_amtx fs_amtx1 fs_amtx2 fs_amtx3 fs_amtx4 fs_amtx5 fs_amtxi fs_mthi jfdstmpa jfs_amt jfs_amt1 jfs_amt2 jfs_amt3 jfs_amt4 jfs_amt5 jfs_amtm"
	local vlist_medicaid "jmdcdqvx mdcdcov mdcdenr mdcdprmx medicaid medprem hhmcrcov othmed othplan hhipdlib"
	local vlist_ssi "fssix fssixm ssibx ssix ssixm"
	local vlist_housing "publhous govtcost"
	local vlist_tanf "welfarex welfrebx welfarem welfareb"
	local vlist_alltransfers `vlist_snap' `vlist_medicaid' `vlist_ssi' `vlist_housing' `vlist_tanf'
	
	* Family size / equivalence scale / demographics
	local vlist_size "fam_size age age_ref age2 educ_ref educa2 ref_race race2 horigin horref1 horref2 hisp_ref hisp2 marital1 sex_ref sex2"
	
	* Consumption (and adjustments)
	local vlist_cons "etotalp etotalc etotapx4 etotacx4 totexppq totexpcq rnteqvx owndwecq owndwepq  vehfinpq vehfincq cartknpq cartkncq cartkupq cartkucq mkmdel mkmdly make mkmodel model lsd_make modelyr typeveh autotype vehicyr modelyr milesveh vehmile qadpmt1x qadpmt2x qadpmt3x vehnewu hlthinpq hlthincq fdhomecq fdhomepq gasmocq gasmopq utilcq utilpq vehq int_phon cntralac minapply mnappl1 mnappl2 mnappl3 mnappl4 mnappl5 mnappl6 mnappl7 mnappl8 mnappl9 cutenure roomsq majcode rntxrpcq rntxrppq perinspq perinscq"
	  
	* Income
	local vlist_inc "respstat fincatax fincatxm fincbtxm fincbtax inc_rank inc_rnkm earnincx fsalaryx fnonfrmx ffrmincx frretirx intearnx finincx pensionx inclossa inclossb fsmpfrmx fsalarym fsmpfrxm fnonfrmm ffrmincm povlevcy sheltcq sheltpq savacctx liquidx secestx stockx irax whlfyrx othastx incnonw1 incnonw2 fincbt_x frretirm unemplxm compensm intearnm finincxm pensionm inclosam inclosbm chdothxm aliothxm othrincm retsurvm intrdvxm royestxm netrentm othregxm intrdvx intrdvbx royestx royestbx othregx compensx othregbx retsurvx retsrvbx netrentx netrntbx othrincx otrincbx frretirx unemplx chdothx aliothx inc_hrs1 inc_hrs2"
	
	* Weights
	local vlist_wts "finlwt21" 
	
	* Identifiers
	local vlist_ids "newid hhid cuid state interi"
	
	* COMBINED VLIST
	local vlist_all `vlist_alltransfers' `vlist_size' `vlist_cons' `vlist_inc' `vlist_wts' `vlist_ids'

*** Loop through years and files

	* Format year
	forvalues y = 1997/2019 {
		
		local short_year = string(mod(`y', 100), "%02.0f")

		di "$dir/data/cex/raw/intrvw`short_year'.zip"

		* Unzip year folder
		cd "$dir/data/cex/raw"
		unzipfile "$dir/data/cex/raw/intrvw`short_year'.zip", replace
	
		foreach f in fmli memi {

			load, file("intrvw`short_year'/intrvw`short_year'/`f'`short_year'1x.dta") vars("`vlist_all'") year(`y') qtr(1)
			load, file("intrvw`short_year'/intrvw`short_year'/`f'`short_year'2.dta") vars("`vlist_all'") year(`y') qtr(2)
			load, file("intrvw`short_year'/intrvw`short_year'/`f'`short_year'3.dta") vars("`vlist_all'") year(`y') qtr(3)
			load, file("intrvw`short_year'/intrvw`short_year'/`f'`short_year'4.dta") vars("`vlist_all'") year(`y') qtr(4)
			
		}
		
		foreach f in hhp ihp ihb opi ihc hhm rnt lsd ovb eqb apb apl {
		
			capture load_annual, file("expn`short_year'/expn`short_year'/`f'`short_year'.dta") vars("`vlist_all'") year(`y') 
			capture load_annual, file("intrvw`short_year'/expn`short_year'/`f'`short_year'.dta") vars("`vlist_all'") year(`y') 
		
		}
		
		* Delete folders
		capture shell rm -r "intrvw`short_year'" "expn`short_year'" "para`short_year'"
		capture shell rm -r "mchi1011" "__MACOSX"
		
	}
	
cd "$dir"
