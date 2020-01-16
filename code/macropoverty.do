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

replace ftotinc =. if ftotinc == 9999999

gstats sum ftotinc, d

****************************************
*3.2 Generate revised income and rank by quintiles
****************************************

gen sfaminc = (ftotinc / sqrt(famsize))

gegen sfaminc5 = xtile(sfaminc), nq(5)

*sort on these variables
hashsort year sfaminc ftotinc 

tab sfaminc5

****************************************
*3.3 Descriptive stats
****************************************

*summarize the scaled family income for the bottom 20% of families
bysort year: sum sfaminc if sfaminc5 == 1

*summarize for all years combined
sum sfaminc if sfaminc5==1, d

****************************************
*3.4 Total hours worked by family
****************************************

*uhrswork is hours worked

bysort famunit:	gegen famhours = sum(uhrswork)