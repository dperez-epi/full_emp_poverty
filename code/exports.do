**************************************************************
* 4.0 Analysis
**************************************************************

/*browse year serial famsize famunit pernum age incwage r_incwage ///
 rf_incwage rft_incwage rft_incwage5 uhrswork hrwage0 annualhours avgwkswork ///
 weeklyfamhours annual_famhours povcut
*/
**************************************************************
* Employable people in poverty breakdown
**************************************************************

*Annual hours worked, by poverty threshold NOTE: We should try to get as close to Table 3 figures as possible
preserve
keep if rft_incwage5!=. & povcut!=.
gcollapse (mean) avg_annual_hrs = annualhours [pw=perwt], by(year povcut)
reshape wide avg_annual_hrs, i(year) j(povcut)
export excel "${data}poverty_hrs.xls", firstrow(variable) replace
restore

preserve
gcollapse (mean) avgincome = r_incwage [pw=perwt], by(year povcut)
keep if povcut!=.
reshape wide avgincome, i(year) j(povcut)
export excel "${data}poverty_wages.xls", firstrow(variable) replace
restore

**************************************************************
* Quintile breakdown
**************************************************************

*** collapse hourly wages to mean, by year and salary + wage quintiles
preserve
gcollapse (mean) avghrwage = hrwage0 [pw=perwt], by(year rft_incwage5)
keep if rft_incwage5!=.
reshape wide avghrwage, i(year) j(rft_incwage5)
export excel "${data}quint_wages.xls", firstrow(variable) replace
restore

preserve
gcollapse (mean) avghrs = annualhours [pw=perwt], by(year rft_incwage5)
keep if rft_incwage5!=.
reshape wide avghrs, i(year) j(rft_incwage5)
export excel "${data}quint_hours.xls", firstrow(variable) replace
restore

**************************************************************
* Age breakdown
**************************************************************

preserve
gcollapse (mean) avghrwage = hrwage0 [pw=perwt], by(year ageb)
keep if age!=.
reshape wide avghrwage, i(year) j(ageb)
export excel "${data}age_wages.xls", firstrow(variables) replace
restore

preserve
gcollapse (mean) avghrs = annualhours [pw=perwt], by(year ageb)
keep if age!=.
reshape wide avghrs, i(year) j(ageb)
export excel "${data}age_wages.xls", firstrow(variables) replace
restore

/*Future analysis might also include mean wages and hours worked
for all quintiles, by age by race, and more. */
*/

**************************************************************
* Race breakdown
**************************************************************

preserve
gcollapse (mean) avghrwage = hrwage0 [pw=perwt], by(year wbhao)
keep if wbhao!=.
reshape wide avghrwage, i(year) j(wbhao)
export excel "${data}wbhao_wages.xls", firstrow(variables) replace
restore

preserve
gcollapse (mean) avghrs = annualhours [pw=perwt], by(year wbhao)
keep if wbhao!=.
reshape wide avghrs, i(year) j(wbhao)
export excel "${data}wbhao_hours.xls", firstrow(variables) replace
restore

**************************************************************
* 2018 breakdown
**************************************************************
/*
preserve
keep if year==2018
tab wbhao, generate(wbhaodum)
gcollapse (count) white=wbhaodum1 Black=wbhaodum2 Hispanic=wbhaodum3 ///
Asian=wbhaodum4 Other=wbhaodum5 [pw=perwt]
list
restore

*/

