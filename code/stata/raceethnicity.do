/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Author:		Daniel Perez
Title: 		agebins.do
Date: 		03-22-2020
Created by: 	Daniel Perez
Purpose:    	Create simplified race/ethnicity variable
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

gen wbho = .

replace wbho = 1 if race==1 & hispan==0
replace wbho = 2 if race==2 & hispan==0
replace wbho = 4 if race==3 | race==4 | race==5 |  race==6 | race==7 | race==8 | race==9 & hispan==0
*hispanic
replace wbho = 3 if hispan!=0

lab var wbho "Race/ethnicity, including Asian"
#delimit ;
lab define wbho
1 "White"
2 "Black"
3 "Hispanic"
4 "Other"
#delimit cr
lab val wbho wbho
