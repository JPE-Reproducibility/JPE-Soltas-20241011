global imputation 0 

if "`c(username)'" == "esoltas" {
	
	global dir "~/Dropbox (MIT)/Research/TransferIncidence/replication/"
	graph set window fontface default
	do "$dir/code/stata-tex.do"
	do "$dir/code/progs.do"
   
	discard
	set scheme s2color
	
}

if "`c(username)'" == "al705" {

   global dir "C:/Users/al2705/Princeton Dropbox/Allan Lee/TransferIncidence/replication"
   
	discard
	adopath + "$dir/code"
	adopath + "$dir/code/analyze"  
	adopath + "$dir/code/eligsim"
	do "$dir/code/stata-tex.do"
	do "$dir/code/progs.do"
	set scheme simplescheme
	
}

* Run eligsims

do "$dir/code/eligsim/eligsim_snap.ado"
do "$dir/code/eligsim/eligsim_medicaid.ado"
do "$dir/code/eligsim/eligsim_liheap.ado"
do "$dir/code/eligsim/eligsim_ui.ado"
do "$dir/code/eligsim/eligsim_ssi.ado"
do "$dir/code/eligsim/eligsim_wic.ado"
do "$dir/code/eligsim/eligsim_housing_assistance.ado"
do "$dir/code/eligsim/eligsim_tanf.ado"
do "$dir/code/eligsim/eligsim_schoolmeals.ado"
 