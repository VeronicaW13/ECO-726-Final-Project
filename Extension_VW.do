*** ECO 726: Policy and Program Evaluation 
*** Paper Extension 

set more off
cap log close
clear 

cd "~/Documents/ECO 726 Final Project"

use "Public_FAFSA_finalwithGrad_2021_labeled.dta", clear

log using "Project_Extension_VW", replace

eststo clear 

** Generating Quintiles for school sizes 
preserve
keep if post == 0 
bysort sitecode: egen base_total = mean(total) 
collapse (firstnm) base_total, by(sitecode)

xtile size_q5 = base_total, nq(5) 

keep sitecode size_q5
tempfile sizeq
save `sizeq', replace
restore

merge m:1 sitecode using `sizeq', nogen

tab size_q5 

** Controls used by author 
encode sitecode, gen(id)
local controls per_white per_black per_hisp per_asian total totalsq act

** Size Quintile Regression Estimates 
generate treat = (1 - averc) * post
label var treat "Average Completion x Post"

forvalues q = 1/5 {
    display "Regression for Size Quintile `q'"
    eststo size_q`q':regress penroll treat per_white per_black per_hisp per_asian total totalsq act i.year if size_q5 == `q', cluster(sitecode)
}

est dir

** Creating Table for Extension 

esttab size_q1 size_q2 size_q3 size_q4 size_q5 using "Extension_SizeQuintiles.tex", replace ///
keep(treat) ///
cells(b(fmt(3) star) se(par fmt(3))) ///
label booktabs noobs ///
mtitle("Q1" "Q2" "Q3" "Q4" "Q5") ///
stats(N r2, labels("Observations" "R-squared")) ///
title("Effect of FAFSA Policy on Enrollment by School Size Quintile") ///

	
log close 
