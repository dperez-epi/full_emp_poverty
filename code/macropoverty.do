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
		2.1 load ACS dataset
			
*******************************************************************************/

*1. Preamble
clear all
cap log close
set more off

*2 Create directories for data and code

cap mkdir macropoverty
global dir = "/projects/dperez/macropoverty"

cap mkdir "${dir}/data"
cap mkdir "${dir}/code"

global data = "${dir}/data"
global code = "${dir}/code"

cap copy usa_00001.dta ${dir}/data/acs_extract.dta, replace
copy macropoverty.do ${dir}/code/macropoverty.do, replace

*erase macropoverty.do
*erase usa_00001.dta

cd ${data}

use acs_extract.dta