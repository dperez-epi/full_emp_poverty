/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Author:		Daniel Perez
	Title: 		povwages.do
	Date: 		01/10/2020
	Created by: 	Daniel Perez
	Purpose:	Use ACS data to construct income quintiles for US 
			households

	Outline:
	
	1. Preamble
	2. File Preparation
	3. Analysis
		3.0 Generate income and rank by quintiles
		3.1 Calculate annual hours worked by family
		3.2 Descriptive stats
			
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

****************************************
*1. Preamble
****************************************

clear all
cap log close
set more off

capture log using macropoverty.txt, text replace

*Install useful packages one time before running code
//ssc install gtools
//ssc install egenmore

****************************************
*2. Create directories for data and code, load ACS data set
****************************************

global dir = "/projects/dperez/macropoverty"

global data = "${dir}/data"
global code = "${dir}/code"

cd ${data}

* load CPI data
sysuse cpi_annual, clear 
keep year cpiurs 
tempfile cpi 
save `cpi' 

*load ACS dataset
use acs_extract.dta, clear


****************************************
*3.0 Generate income and rank by quintiles
****************************************

*get rid of missing values
mvdecode ftotinc, mv(9999999)

*transformed family income

gen tfaminc = (ftotinc / sqrt(famsize))
label var tfaminc "Transformed family income"

*create quintiles based off transformed family income (tfaminc)
gegen tfaminc5 = xtile(tfaminc) [pw=perwt], nq(5)

label var tfaminc5 "Transformed family income quintiles"
#delimit;
label def tfaminc5
1 "First quintile 0–20%"
2 "Second quintile 20–40%"
3 "Third quintile 40–60%"
4 "Fourth quintile 60–80%"
5 "Fifth quintile 80–100%"
;
#delimit cr
lab val tfaminc5 tfaminc5

****************************************
*3.1 Calculate annual hours worked by family
****************************************

/***********************************
We take the mid-point of each interval
*
*      weeks |
*worked last |
*      year, |
*intervalled |      Freq.     Percent        Cum.
*------------+-----------------------------------
*        n/a | 23,071,707       47.90       47.90
*1-13  weeks |  1,883,648        3.91       51.82
*14-26 weeks |  1,423,530        2.96       54.77
*27-39 weeks |  1,583,948        3.29       58.06
*40-47 weeks |  1,658,749        3.44       61.50
*48-49 weeks |    756,096        1.57       63.07
*50-52 weeks | 17,784,439       36.93      100.00
*------------+-----------------------------------
*      Total | 48,162,117      100.00
***********************************/

*average hours worked per week, by individual
gen avgwkswork = wkswork2
recode avgwkswork (0=0) (1= 7) (2 = 20) (3 = 33) (4 = 43.5) (5=48.5) (6=51)

*annual hours worked per person, which is usual hours worked * avg weeks worked
gen annpersonhrs = uhrswork * avgwkswork 
label var annpersonhrs "Usual hours worked annually, by individual"

*annual hours worked by family
gegen annual_famhours = total(annpersonhrs), by(year serial famsize)
label var annual_famhours "Annual hours worked by family"

****************************************
*3.2 Descriptive stats
****************************************

hashsort sample year serial pernum
list year serial famsize pernum tfaminc uhrswork avgwkswork annpersonhrs annual_famhours in 1/20, table

*Transformed family income by quintile
bysort tfaminc5: sum tfaminc
*Annual hours worked by family, by quintile
bysort tfaminc5: sum annual_famhours

*Hours worked annually by bottom 20% of earner families, by year
bysort year: sum annual_famhours if tfaminc5==1
*Transformed income for bottom 20% of earning families, by year
bysort year: sum tfaminc if tfaminc5==1

*How have hours worked by bottom 20% changed over time?
*lets collapse our data to get tranformed income, and hours worked, by year

****decode tfaminc5, gen(tfaminc5string)****

preserve
gcollapse (mean) meanwages = tfaminc [pw=perwt], by(year tfaminc5)
keep if tfaminc5!=. 
reshape wide meanwages, i(year) j(tfaminc5)
list
export excel "meanwages_bottom20.xls", firstrow(variables) replace
restore


preserve
gcollapse (mean) meanhours = annual_famhours [pw=perwt], by(year tfaminc5)
keep if tfaminc5!=. 
reshape wide meanhours, i(year) j(tfaminc5)
list
export excel "meanhours_bottom20.xls", firstrow(variables) replace
restore

/*Future analysis might also include mean wages and hours worked
for all quintiles, by age by race, and more. */
*/
capture log close
