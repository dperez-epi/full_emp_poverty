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

*merge cpi data to ACS
merge m:1 year using `cpi', keep(3) nogenerate

**************************************************************
*3.0 Generate family income from all sources, and rank by quintiles
**************************************************************

*get rid of missing values
mvdecode ftotinc, mv(9999999)

*adjust wages for 2018 values
sum year
local maxyear =`r(max)'
sum cpiurs if year ==`maxyear'
local basevalue =`r(mean)'

*generate total family income in real wages
gen realftotinc = ftotinc * [`basevalue'/cpiurs]

*transform our family income variable
gen tfaminc = (realftotinc / sqrt(famsize))
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

**************************************************************
*3.1 Generate family income from salary and wages, and rank by quintiles
**************************************************************

*remove missing values from wage and salary
mvdecode incwage, mv(999999 999998) 

*adjust wage and salary to real 2018 dollars
gen realincwage = incwage * [`basevalue'/cpiurs]

*sum real wages within families
gegen incwagefam = total(realincwage), by(year serial famsize)
*transform real wages
gen tincwagefam = (incwagefam / sqrt(famsize))

label var tincwagefam "Transformed family salary and wages"

*create quintiles for family salary and wage incomes
gegen tincwagefam5 = xtile(incwagefam) [pw=perwt], nq(5)
label var tincwagefam5 "Transformed family salary and wage quintiles"

#delimit;
label def tincwagefam5
1 "First quintile 0–20%"
2 "Second quintile 20–40%"
3 "Third quintile 40–60%"
4 "Fourth quintile 60–80%"
5 "Fifth quintile 80–100%"
;
#delimit cr
lab val tincwagefam5 tincwagefam5

/*
It appears that the amount of observations with 0 wage and salary income
certainly skew the distribution of our data. This seems problematic
should we restrict our sample somehow? What does our data look like?

.  gstats sum tincwagefam

             Transformed family salary and wages             
-------------------------------------------------------------
      Percentiles      Smallest                              
  1%            0             0                              
  5%            0             0                              
 10%            0             0      Obs           48,162,117
 25%     5481.521             0      Sum of Wgt.   48,162,117
                                                             
 50%     28542.65                    Mean            40055.29
                        Largest      Std. Dev.       49263.01
 75%     55833.76       1739392                              
 90%     89453.55       1919415      Variance        2.43e+09
 95%     119935.1       1919415      Skewness        3.408496
 99%       245602       1919415      Kurtosis        24.63875

. gstats sum tfaminc

                  Transformed family income                  
-------------------------------------------------------------
      Percentiles      Smallest                              
  1%            0     -35308.84                              
  5%     5884.696     -35308.84                              
 10%        10455     -33065.05      Obs           46,484,362
 25%     21203.68     -33065.05      Sum of Wgt.   46,484,362
                                                             
 50%     39576.57                    Mean            52883.23
                        Largest      Std. Dev.       54712.68
 75%     65618.98       1824336                              
 90%     102952.8       1824336      Variance        2.99e+09
 95%     141592.5       1848603      Skewness        3.885136
 99%     286661.1       1848603      Kurtosis        30.14801

. 

*/
****************************************
*3.2 Calculate annual hours worked by family
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

hashsort year sample serial pernum
list year serial famsize pernum tfaminc incwage tincwagefam uhrswork avgwkswork annpersonhrs annual_famhours in 1/20, table

*Transformed family income by quintile
bysort tincwagefam5: sum tincwagefam
*Annual hours worked by family, by quintile
bysort tincwagefam5: sum annual_famhours
stop

*Hours worked annually by bottom 20% of earner families, by year
bysort year: sum annual_famhours if tincwagefam5==1
*Transformed income for bottom 20% of earning families, by year
bysort year: sum tincwagefam if tincwagefam5==1

*How have hours worked by bottom 20% changed over time?
*lets collapse our data to get tranformed income, and hours worked, by year

preserve
gcollapse (mean) meanwages = tincwagefam [pw=perwt], by(year tincwagefam5)
keep if tincwagefam5!="." 
reshape wide meanwages, i(year) j(tincwagefam5)
list
export excel "meanwages_bottom20.xls", firstrow(variables) replace
restore

preserve
gcollapse (mean) meanhours = annual_famhours [pw=perwt], by(year tincwagefam5)
keep if tincwagefam!=. 
reshape wide meanhours, i(year) j(tincwagefam5)
list
export excel "meanhours_bottom20.xls", firstrow(variables) replace
restore

/*Future analysis might also include mean wages and hours worked
for all quintiles, by age by race, and more. */
*/
capture log close
