/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Author:		Daniel Perez
Title: 		agebins.do
Date: 		03-19-2020
Created by: 	Daniel Perez
Purpose:    	Create age bins for working age population
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

gen ageb = age if age>17 & age<65
recode ageb (18/24 = 1) (25/34 = 2) (35/44 = 3) (45/54 = 4) (55/64 = 5)

lab var ageb "Age (intervalled)"
label def ageb 1 "18–24" 2 "25–34" 3 "35–44" 4 "45–54" 5 "55–64"
label value ageb ageb
