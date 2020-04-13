/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Author:		Daniel Perez
	Title: 		macropoverty.do
	Date: 		01/10/2020
	Created by: 	Daniel Perez
	Purpose:	Use ACS data to construct income quintiles for US 
				families

	Outline:
	
	1. Preamble
	2. File Preparation
	3. Data Processing
		3.1 Universe and variables creation
		3.2 Measuring income (from wages and salary) by family + quintiles
		3.3 Calculating hours and weeks worked per year, and usual hours per week
			by family
		3.4 Calculating implied hourly wages from wages, salary and hours worked
	4. Analysis
		4.1 exports.do, create and export hour and wage breakdowns
			
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

				* hi

**************************************************************
* 1. Preamble
**************************************************************
cap log close
clear all
set more off

capture log using macropoverty.txt, text replace

*Install useful packages one time before running code
//ssc install gtools
//ssc install egenmore

**************************************************************
* 2. Create directories for data and code, load ACS data set
**************************************************************

global dir = "/projects/dperez/macropoverty"

global data = "${dir}/data/"
global code = "${dir}/code/"

* load CPI data
sysuse cpi_annual, clear 
keep year cpiurs 
tempfile cpi 
save `cpi' 

*load ACS dataset
use ${data}acs_extract.dta, clear

*later we will append 1970, 1980, 1990 data using
//append using ${data}acs_historical.dta, gen(acs_ext)

*merge cpi data to ACS
merge m:1 year using `cpi', keep(3) nogenerate

*adjust wages for 2018 values
sum year
local maxyear =`r(max)'
sum cpiurs if year ==`maxyear'
local basevalue =`r(mean)'

**************************************************************
* 3.1 Universe and variable creation
**************************************************************

*keep if in laborforce
*keep 

*Delineate poverty threshold using poverty variable
do acs_povcut.do

*intervalled age variable
do agebins.do

*create wbhao variable
do raceethnicity.do

*create EPI-style education variable
do education.do

**************************************************************
* 3.2 Measuring income (from wages and salary) by family + quintiles
**************************************************************
*remove missing values from wage and salary
mvdecode incwage, mv(999999) 

*adjust wage and salary to real 2018 dollars
gen r_incwage = incwage * [`basevalue'/cpiurs]
label var r_incwage "wages and salary income in real 2018 dollars"

*sum real wages within families
gegen rf_incwage = total(r_incwage), by(year serial famsize) missing
label var rf_incwage "income from salary and wages summed over family size"

*transform real wages
gen rft_incwage = (rf_incwage / sqrt(famsize))
label var rft_incwage "Transformed family salary and wages"

*create quintiles using real transformed family salary and wage incomes
gegen rft_incwage5 = xtile(rft_incwage) if labforce==2 [pw=perwt], by(year) nq(5)
label var rft_incwage5 "Transformed family salary and wage quintiles"

*label our quintiles
#delimit;
label def rft_incwage5
1 "First quintile 0–20%"
2 "Second quintile 20–40%"
3 "Third quintile 40–60%"
4 "Fourth quintile 60–80%"
5 "Fifth quintile 80–100%"
;
#delimit cr
lab val rft_incwage5 rft_incwage5

/*
Note: Working-age households are those headed by someone under age 65. 
Data are for money income. Percentage changes are approximated by taking
the difference of natural logs of wages and hours.

*/

**************************************************************
* 3.3 Calculating hours and weeks worked per year, and usual hours per week by family
**************************************************************

*average weeks worked per year, by individuals
mvdecode wkswork*, mv(0)
gen avgwkswork =.

/*
replace avgwkswork = wkswork2
recode avgwkswork (1 = 7) (2 = 20) (3 = 33) (4 = 43.5) (5=48.5) (6=51)
*/

*slightly less precise measure in years 2008-2018, using midpoint of intervaled variable
replace avgwkswork = wkswork2 if year>=2008 & year<=2018
recode avgwkswork (1 = 7) (2 = 20) (3 = 33) (4 = 43.5) (5=48.5) (6=51)
*exact weeks worked per year 2000-2007
replace avgwkswork = wkswork1 if year>=2000 & year<=2007


*Usual hours worked per week, by family
gegen weeklyfamhours = total(uhrswork), by(year serial famsize) missing
label var weeklyfamhours "Usual hours worked per week, by family"

*annual hours worked per person, which is usual hours worked * avg weeks worked
gen annualhours = uhrswork * avgwkswork
label var annualhours "Usual hours worked annually, by individual"

*annual hours worked by family
gegen annual_famhours = total(annualhours), by(year serial famsize) missing
label var annual_famhours "Annual hours worked by family"

/**************************************************************
3.4 Calculating implied hourly wages from wages, salary and hours worked

https://www.epi.org/data/methodology/
https://irle.berkeley.edu/files/2014/The-Impact-of-Oakland-data-and-methods.pdf
https://www.brookings.edu/wp-content/uploads/2019/11/201911_Brookings-Metro_low-wage-workforce_Ross-Bateman_TECHNICAL-APPENDIX.pdf

**************************************************************/

gen hrwage0 = r_incwage / (annualhours) 
label var hrwage0 "Implied hourly wages from wages and salary excluding hours topcode"
*exclude outliers per EPI methodology
replace hrwage0 = . if hrwage0 < .98
replace hrwage0 = . if hrwage0 > 196.08

gen hrwage1 = rf_incwage / (annual_famhours) 
label var hrwage1 "Implied hourly family wages from wages and salary"

*gen hrwage3 = rf_incwage / (annual_famhours) if rft_incwage5==1

*do exports.do

capture log close
