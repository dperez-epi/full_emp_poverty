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
*3.1 Exploratory analysis
****************************************

*9999999=NA so replace all values with .

mvdecode ftotinc, mv(9999999)
gstats sum ftotinc, d

****************************************
*3.2 Generate revised income and rank by quintiles
****************************************

gen tfaminc = (ftotinc / sqrt(famsize))

gegen tfaminc5 = xtile(tfaminc) [pw=perwt], nq(5)

****************************************
*3.3 Descriptive stats
****************************************

*summarize the transformed family income for the bottom 20% of families
bysort tfaminc5: sum tfaminc

*summarize for all years combined
sum tfaminc if tfaminc5==1, d

****************************************
*3.4 Total weekly hours worked by family
****************************************

*uhrswork is usual hours worked per week.
*will usual hours worked per week, summed by family, give us what we need?

/*
UHRSWORK Specific Variable Codes
00 = N/A
99 = 99 hours (Top Code)
*/

mvdecode incwage, mv(999999)

gegen famhours = total(uhrswork), by(year serial famsize)


****************************************
*3.5 Total weeks worked per year by family
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
*1-13 weeks |  1,883,648        3.91       51.82
*14-26 weeks |  1,423,530        2.96       54.77
*27-39 weeks |  1,583,948        3.29       58.06
*40-47 weeks |  1,658,749        3.44       61.50
*48-49 weeks |    756,096        1.57       63.07
*50-52 weeks | 17,784,439       36.93      100.00
*------------+-----------------------------------
*      Total | 48,162,117      100.00
***********************************/

gen avgwkswork = wkswork2
recode avgwkswork (0=0) (1= 7) (2 = 20) (3 = 33) (4 = 43.5) (5=48.5) (6=51)

****************************************
*3.6 Total hours worked per year by family
****************************************

gen hrswrk_year = uhrswork * avgwkswork 

gegen annual_famhours = total(hrswrk_year), by(year serial famsize)

hashsort sample year serial pernum
list year serial famsize pernum tfaminc uhrswork famhours avgwkswork hrswrk_year annual_famhours in 1/20, table

bysort tfaminc5: sum tfaminc
bysort tfaminc5: sum annual_famhours
bysort year: sum annual_famhours if tfaminc5==1
bysort year: sum tfaminc if tfaminc5==1
