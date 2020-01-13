*Daniel Perez
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*	Title: 		povwages.do
*	Date: 		01/10/2020
*	Created by: 	Daniel Perez
*	Purpose:	Use ACS data to construct income quintiles for US 
*			households
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/*******************************************************************************
Outline:
	
	1. Preamble
	2. File Preparation
	3. Analysis
		3.1 Exploratory analysis
		3.2 Generate revised income
			
*******************************************************************************/

********************
*1. Preamble
********************

clear all
cap log close
set more off

*use once
ssc install gtools
ssc install egenmore


********************
*2. Create directories for data and code, load ACS data set
********************

cap mkdir macropoverty
global dir = "/projects/dperez/macropoverty"

cap mkdir "${dir}/data"
cap mkdir "${dir}/code"

global data = "${dir}/data"
global code = "${dir}/code"

cd ${data}
use acs_extract.dta

********************
*3.1 Exploratory analysis
********************

*9999999=NA so replace all values with .

replace hhincome =. if hhincome == 9999999
replace ftotinc =. if ftotinc == 9999999

gstats sum hhincome, d
gstats sum ftotinc, d

********************
*3.2 Generate revised income and rank by quintiles
********************

gen sfaminc = (ftotinc / sqrt(famsize))
gen shhinc = (hhincome / sqrt(famsize))

gegen sfaminc5 = xtile(sfaminc), nq(5)
gegen shhinc5 = xtile(shhinc), nq(5)

hashsort year hhincome ftotinc sfaminc5 shhinc5

tab shhinc5
tab sfaminc5
*gquantiles shhinc5 = shhinc, xtile nq(5)

********************
*3.3 Descriptive stats
********************

bysort year shhinc5: sum hhincome
