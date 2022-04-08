/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Author:		Daniel Perez
	Title: 		macropoverty.do
	Date: 		02/10/2022
	Created by: 	Daniel Perez
	Purpose:	Use CPS to estimate hours and wages by income quintiles
			
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


**************************************************************
* 1. Preamble
**************************************************************
clear all
set more off


global base "/projects/dperez/pov_full_emp/"
global code ${base}code/
global data ${base}data/

sysuse cpi_annual, clear
keep year cpiurs
tempfile cpi
save `cpi'

* load CPS ORG: wage, wbho
load_epiextracts, begin(2009m1) end(2021m12) sample(ORG) keep(year month orgwgt statefips ///
 age emp selfemp selfinc hoursu1 hoursu1i hourslwt hourslw1 multjobs hoursuorg lfstat wage earnhour)

*merge cpi data to CPS
merge m:1 year using `cpi', keep(3) nogenerate

*adjust wages to 2021 values
sum year
local maxyear =`r(max)'
sum cpiurs if year ==`maxyear'
local basevalue =`r(mean)'

********* Generate necessary variables *********
gen wgt = orgwgt/12

// weekly pay based off wage * hours last week 1st job
gen weekpay = wage * hourslw1

*adjust weekly pay to 2021 dollars
gen weekpay_r = weekpay * [`basevalue'/cpiurs]
label var weekpay_r "wages and salary income in real 2021 dollars"

*replace weekly pay with 0 if unemployed/NILF
gen byte weekpay_r0 = .
replace weekpay_r0 = weekpay_r
replace weekpay_r0 = 0 if emp==0

set seed 1017

*replace zeros with random numbers
gen noisey_weekpay_r0 = weekpay_r0
*replace noisey_weekpay_r0 = weekpay_r0 + runiform(-.005 ,.005) if weekpay_r0 >= 0
replace noisey_weekpay_r0 = weekpay_r0 + runiform(.005 ,.99) if weekpay_r0 == 0


*generate positive wages indicator
gen byte pwages = .
replace pwages = 1 if weekpay_r0 > 0 & weekpay_r0~=.
replace pwages = 0 if weekpay_r0 == 0

{
lab var pwages "Positive wages indicator"
#delimit ;
lab def pwages
0 "Zero wages, primary job"
1 "Positive wages, primary job"
;
#delimit cr
lab val pwages pwages
}

gen byte phours = .
replace phours = 1 if hourslw1 > 0 & hourslw1~=.
replace phours = 0 if hourslw1 == 0

{
lab var phours "Positive hours indicator"
#delimit ;
lab def phours
0 "Zero hours, primary job"
1 "Positive hours, primary job"
;
#delimit cr
lab val phours phours
}



*restrictions
keep if age<65
drop if selfemp==1
drop if selfinc==1

tempfile allthedata
save `allthedata'

* Generate wage medians for all workers by year
use `allthedata', clear
binipolate noisey_weekpay_r0 [pw=wgt], binsize(1) by(year) collapsefun(gcollapse) p(20 40 50 60 80)
reshape wide noisey_weekpay_r0_binned, i(year) j(percentile)

*tempfile with quintiles
tempfile quintiles_real
save `quintiles_real'

use `allthedata', clear
merge m:1 year using `quintiles_real'

* generate bins
gen bin= .
replace bin = 1 if noisey_weekpay_r0 <= noisey_weekpay_r0_binned20
replace bin = 2 if noisey_weekpay_r0 <= noisey_weekpay_r0_binned40 & noisey_weekpay_r0 > noisey_weekpay_r0_binned20
replace bin = 3 if noisey_weekpay_r0 <= noisey_weekpay_r0_binned60 & noisey_weekpay_r0 > noisey_weekpay_r0_binned40
replace bin = 4 if noisey_weekpay_r0 <= noisey_weekpay_r0_binned80 & noisey_weekpay_r0 > noisey_weekpay_r0_binned60
replace bin = 5 if noisey_weekpay_r0 > noisey_weekpay_r0_binned80

tempfile merged_data
save `merged_data'

** Calculate average hours worked in each bin

use `merged_data', clear

gcollapse (mean) avghrs= hourslw1 [pw=wgt], by(year bin)
reshape wide avghrs, i(year) j(bin)

tempfile avghours
save`avghours'

** Calculate weighted counts of each bin

use `merged_data', clear
gcollapse (count) wgt_n=wgt [pw=wgt], by(year bin)
reshape wide wgt_n, i(year) j(bin)

tempfile weighted_count
save`weighted_count'

** Calculate epop of each bin

use `merged_data', clear
gcollapse (mean) epop=emp [pw=wgt], by(year bin)
reshape wide epop, i(year) j(bin)

tempfile epops
save`epops'

** Calculate average weekpay of each bin

use `merged_data', clear
gcollapse (mean) weekpay_r0 [pw=wgt], by(year bin)
reshape wide weekpay_r0, i(year) j(bin)

tempfile weekpay
save`weekpay'

** Calculate average hourly wage of each bin

use `merged_data', clear
gcollapse (mean) wage [pw=wgt], by(year bin)
reshape wide wage, i(year) j(bin)

tempfile hourlywage
save`hourlywage'

** Calculate weekpay cutoffs of each bin

use `merged_data', clear
gcollapse (max) maxweekpay=weekpay_r0 [pw=wgt], by(year bin)
reshape wide maxweekpay, i(year) j(bin)

tempfile maxweekpay
save`maxweekpay'

** append all tempfiles

*append data
use `weighted_count', clear
append using `weekpay'
append using `hourlywage'
append using `avghours'
append using `epops'
append using `maxweekpay'

export delim ${data}bin_cuts.csv, replace

use `merged_data', clear

