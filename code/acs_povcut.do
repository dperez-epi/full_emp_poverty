/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Author:		Daniel Perez
Title: 		acs_povcut.do
Date: 		03-18-2020
Created by: 	Daniel Perez
Purpose:    	Create poverty cut for ACS analysis
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

gen byte povcut = .
replace povcut = 1 if poverty < 100
replace povcut = 0 if poverty >= 100

lab var povcut "Poverty threshold"
label def povcut 0 "Family income above poverty threshold" 1 "Family income below poverty threshold"
label value povcut povcut
