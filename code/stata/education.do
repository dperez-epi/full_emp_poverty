/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Author:		Daniel Perez
Title: 		education.do
Date: 		03-25-2020
Created by: 	Daniel Perez
Purpose:    	Create simplified educational attainment variable

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

rename educ oldeduc

gen educ = .
*Less than HS
replace educ = 1 if educd<=61
*HS graduate/GED or equivalent
replace educ = 2 if educd>=62 & educd<=64
*Some college
replace educ = 3 if educd>=65 & educd<=90
*4 years of college / Bachelors
replace educ = 4 if educd==100 | educd==101
*5+ years of college, and/or professional degree
replace educ = 5 if educd>=110 & educd<=116

lab var educ "Education level"
#delimit ;
lab define educ
1 "Less than high school"
2 "High school"
3 "Some college"
4 "College"
5 "Advanced"
;
#delimit cr
lab val educ educ

notes educ: 2000-2018 IPUMS ACS: derived from educd

