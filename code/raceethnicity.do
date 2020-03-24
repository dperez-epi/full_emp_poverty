/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Author:		Daniel Perez
Title: 		agebins.do
Date: 		03-22-2020
Created by: 	Daniel Perez
Purpose:    	Create simplified race/ethnicity variable
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

gen wbhao = .

replace wbhao = 1 if race==1
replace wbhao = 2 if race==2
replace wbhao = 4 if race==4 | race==5 | race==6
replace wbhao = 5 if race==3 | racesing==7 | race==8 | race==9
*hispanic
replace wbhao = 3 if hispan!=0

lab var wbhao "Race/ethnicity, including Asian"
#delimit ;
lab define wbhao
1 "White"
2 "Black"
3 "Hispanic"
4 "Asian"
5 "Other";
#delimit cr
lab val wbhao wbhao
