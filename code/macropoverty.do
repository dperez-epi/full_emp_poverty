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
		3.1 Exploratory analysis
		3.2 Generate revised income
		3.3 Descriptive statistics
			
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


****************************************
*1. Preamble
****************************************

clear all
cap log close
set more off

*use once
//ssc install gtools
//ssc install egenmore


****************************************
*2. Create directories for data and code, load ACS data set
****************************************

global dir = "/projects/dperez/macropoverty"

global data = "${dir}/data"
global code = "${dir}/code"

cd ${data}
use acs_extract.dta


****************************************
*3.0 Generate income and rank by quintiles
****************************************

*transformed family income
gen tfaminc = (ftotinc / sqrt(famsize))
label var tfaminc "Transformed family income
"
*create quintiles based off transformed family income (tfaminc)
gegen tfaminc5 = xtile(tfaminc) [pw=perwt], nq(5)

label var tfaminc5 "Transformed family income quintiles"
#delimit ;
label def tfaminc5
1 "First quintile 0–20%"
2 "Second quintile 20–40%"
3 "Third quintile 40–60%"
4 "Fourth quintile 60–80%"
5 "Fifth quintile 80–100%"
;
#delimit cr;
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

*annual hours worked per person
gen anpersnhrs = uhrswork * avgwkswork 
label var anpersnhrs "Usual hours worked annually, by individual"

*annual hours worked by family
gegen annual_famhours = total(hrswrk_year), by(year serial famsize)
label var anpersnhrs "Annual hours worked by family"

****************************************
*3.3 Descriptive stats
****************************************

hashsort sample year serial pernum
list year serial famsize pernum tfaminc uhrswork famhours avgwkswork hrswrk_year annual_famhours in 1/20, table

*Transformed family income by quintile
bysort tfaminc5: sum tfaminc
*Annual hours worked by family, by quintile
bysort tfaminc5: sum annual_famhours

*Hours worked annually by bottom 20% of earner families, by year
bysort year: sum annual_famhours if tfaminc5==1
*Transformed income for bottom 20% of earning families, by year
bysort year: sum tfaminc if tfaminc5==1

*How have hours worked by bottom 20% changed over time?

