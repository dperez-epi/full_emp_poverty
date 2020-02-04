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

*sort on these variables
hashsort year tfaminc ftotinc 

 
****************************************
*3.3 Descriptive stats
****************************************

*summarize the transformed family income for the bottom 20% of families
bysort year: sum tfaminc if tfaminc5 == 1

*summarize for all years combined
sum tfaminc if tfaminc5==1, d

****************************************
*3.4 Total hours worked by family
****************************************

*uhrswork is usual hours worked per week.
*will usual hours worked per week, summed by family, give us what we need?


/*
UHRSWORK Specific Variable Codes
00 = N/A
99 = 99 hours (Top Code)
*/

mvdecode incwage, mv(999999)

replace uhrswork = . if uhrswork==0
gegen famhours = total(uhrswork), by(year serial famsize)

****************************************
*3.5 Total weeks worked per year by family
****************************************

replace wkswork1 = . if wkswork1==0
gegen wksperyear = total(wkswork1), by(year serial famsize)

replace wksperyear = . if wksperyear ==0
****************************************
*3.6 Total weeks worked per year by family
****************************************

gen annual_famhours = famhours*wksperyear

replace annual_famhours = . if annual_famhours == 0
/*
WKSWORK1 Specific Variable Codes
00 = N/A
*/
browse year sample serial famsize pernum ftotinc tfaminc uhrswork famhours ///
	wksperyear annual_famhours 

