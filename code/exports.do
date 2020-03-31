**************************************************************
* 4.0 Analysis
**************************************************************
/*
browse year serial famsize famunit pernum age incwage r_incwage ///
 rf_incwage rft_incwage rft_incwage5 uhrswork hrwage0 annualhours avgwkswork ///
 weeklyfamhours annual_famhours povcut wbhao educ
*/
**************************************************************
* all employable people versus those in poverty
**************************************************************

*Annual hours worked by all versus those in poverty
preserve
	keep if labforce==2
	tempfile alldata
	save `alldata'
	use `alldata', clear
	gcollapse (mean) avghrall = annualhours [pw=perwt], by(year)
	list
	tempfile allcoll
	save `allcoll'
	use `alldata', clear
	gcollapse (mean) avghrpov = annualhours [pw=perwt], by(year povcut)
	list
	reshape wide avghrpov, i(year) j(povcut)
	*merge collapsed hours for all v. those in poverty
	merge 1:1 year using `allcoll', assert(3) nogenerate
	export excel "${data}emp_hours.xls", firstrow(variable) replace
restore

*Annual hours (per family) worked by all versus those in poverty
preserve
	keep if labforce==2
	tempfile alldata
	save `alldata'
	use `alldata', clear
	gcollapse (mean) avghrall = annual_famhours [pw=perwt], by(year)
	tempfile allcoll
	save `allcoll'
	use `alldata', clear
	keep if povcut==1
	gcollapse (mean) avghrpov = annual_famhours [pw=perwt], by(year)
	*merge collapsed hours for all v. those in poverty
	merge 1:1 year using `allcoll', assert(3) nogenerate
	export excel "${data}emp_famhours.xls", firstrow(variable) replace
restore

*Annual wages for all versus those in poverty
preserve
	keep if labforce==2
	tempfile alldata
	save `alldata'
	use `alldata', clear
	gcollapse (mean) avgwgsall = hrwage0 [pw=perwt], by(year)
	tempfile allcoll
	save `allcoll'
	use `alldata', clear
	keep if povcut==1
	gcollapse (mean) avgwgspov = hrwage0 [pw=perwt], by(year)
	*merge collapsed hours for all v. those in poverty
	merge 1:1 year using `allcoll', assert(3) nogenerate
	export excel "${data}emp_wages.xls", firstrow(variable) replace
restore



**************************************************************
* Bottom fifth vs all hours, incomes, wages
**************************************************************

*** Annual hours worked per family, bottom fifth vs all

preserve
	keep if labforce==2
	*save all data
	tempfile alldata
	save `alldata'
	use `alldata', clear
	*Collapse family hours
	gcollapse (mean) avgwgsall = annual_famhours [pw=perwt], by(year)
	*save collapsed data
	tempfile allcoll
	save `allcoll'
	*use all data to collapse bottom fifth family hours
	use `alldata', clear
	keep if rft_incwage5==1
	gcollapse (mean) avghours = annual_famhours [pw=perwt], by(year)
	*merge collapsed hours for all v. those in poverty
	merge 1:1 year using `allcoll', assert(3) nogenerate
	export excel "${data}quint_famhours.xls", firstrow(variable) replace
restore


*** Implied hourly family wage for bottom fifth vs all

preserve
	keep if labforce==2
	*save all data
	tempfile alldata
	save `alldata'
	use `alldata', clear
	*Collapse family hours
	gcollapse (mean) avgwgsall = hrwage1 [pw=perwt], by(year)
	*save collapsed data
	tempfile allcoll
	save `allcoll'
	*use all data to collapse bottom fifth family hours
	use `alldata', clear
	keep if rft_incwage5==1
	gcollapse (mean) avgwgsfifth = hrwage1 [pw=perwt], by(year)
	*merge collapsed hours for all v. those in poverty
	merge 1:1 year using `allcoll', assert(3) nogenerate
	export excel "${data}quint_famwages.xls", firstrow(variable) replace
restore

*** Implied family incomes for bottom fifth vs all

preserve
	keep if labforce==2
	*save all data
	tempfile alldata
	save `alldata'
	use `alldata', clear
	*Collapse family hours
	gcollapse (mean) avgincall = rf_incwage [pw=perwt], by(year)
	*save collapsed data
	tempfile allcoll
	save `allcoll'
	*use all data to collapse bottom fifth family hours
	use `alldata', clear
	keep if rft_incwage5==1
	gcollapse (mean) avgincfifth = rf_incwage [pw=perwt], by(year)
	*merge collapsed hours for all v. those in poverty
	merge 1:1 year using `allcoll', assert(3) nogenerate
	export excel "${data}quint_faminc.xls", firstrow(variable) replace
restore


**************************************************************
* Age breakdown
**************************************************************


*** Implied incomes for all age bins

preserve
	*save all data
	keep if labforce==2	
	tempfile alldata
	save `alldata'
	use `alldata', clear
	*Collapse hourly wages
	gcollapse (mean) avgwageall = hrwage0 [pw=perwt], by(year ageb)
	keep if age!=.
	decode ageb, gen(agestr)
	drop ageb
	reshape wide avgwageall, i(agestr) j(year)
	*save collapsed data
	tempfile allcoll
	save `allcoll'
	*use all data to collapse hr wages by age bins in poverty
	use `alldata', clear
	keep if povcut==1
	gcollapse (mean) avgwagepov = hrwage0 [pw=perwt], by(year ageb)
	keep if age!=.
	decode ageb, gen(agestr)
	drop ageb
	reshape wide avgwagepov, i(agestr) j(year)
	*merge collapsed hours for all v. those in poverty
	merge 1:1 agestr using `allcoll', assert(3) nogenerate
	export excel "${data}age_hrwage.xls", firstrow(variable) replace
restore

*** annual hours worked by age bin, all versus in poverty

preserve
	keep if labforce==2
	*save all data
	tempfile alldata
	save `alldata'
	use `alldata', clear
	*Collapse hourly wages
	gcollapse (mean) avghrsall = annualhours [pw=perwt], by(year ageb)
	keep if ageb!=.
	decode ageb, gen(agestr)
	drop ageb
	reshape wide avghrsall, i(agestr) j(year)
	*save collapsed data
	tempfile allcoll
	save `allcoll'
	*use all data to collapse hr wages by age bins in poverty
	use `alldata', clear
	keep if povcut==1 & ageb!=.
	gcollapse (mean) avghrspov = annualhours [pw=perwt], by(year ageb)
	*merge collapsed hours for all v. those in poverty
	decode ageb, gen(agestr)
	drop ageb
	reshape wide avghrspov, i(agestr) j(year)
	merge 1:1 agestr using `allcoll', assert(3) nogenerate
	export excel "${data}age_hours.xls", firstrow(variable) replace
restore


/*Future analysis might also include mean wages and hours worked
for all quintiles, by age by race, and more. */
*/

**************************************************************
* Race breakdown
**************************************************************

*** annual hours worked by race/ethnicity all versus in poverty

preserve
	keep if labforce==2
	*save all data
	tempfile alldata
	save `alldata'
	use `alldata', clear
	*Collapse hourly wages
	gcollapse (mean) avghrsall = annualhours [pw=perwt], by(year wbhao)
	keep if wbhao!=.
	decode wbhao, gen(wbhaostr)
	drop wbhao
	reshape wide avghrsall, i(wbhaostr) j(year)
	*save collapsed data
	tempfile allcoll
	save `allcoll'
	*use all data to collapse hr wages by race/ethnicity in poverty
	use `alldata', clear
	keep if povcut==1 & wbhao!=.
	gcollapse (mean) avghrspov = annualhours [pw=perwt], by(year wbhao)
	*merge collapsed hours for all v. those in poverty
	decode wbhao, gen(wbhaostr)
	drop wbhao
	reshape wide avghrspov, i(wbhaostr) j(year)
	merge 1:1 wbhaostr using `allcoll', assert(3) nogenerate
	export excel "${data}wbhao_hours.xls", firstrow(variable) replace
restore

/*
preserve
gcollapse (mean) avghrwage = hrwage0 [pw=perwt], by(year wbhao)
keep if wbhao!=.
reshape wide avghrwage, i(year) j(wbhao)
export excel "${data}wbhao_wages.xls", firstrow(variables) replace
restore

*/

**************************************************************
* gender breakdown
**************************************************************


**************************************************************
* Educational attainment breakdown
**************************************************************
preserve
	keep if labforce==2
	*save all data
	tempfile alldata
	save `alldata'
	use `alldata', clear
	*Collapse annual hours worked
	gcollapse (mean) avghrsall = annualhours [pw=perwt], by(year educ)
	keep if educ!=.
	decode educ, gen(educstr)
	drop educ
	reshape wide avghrsall, i(educstr) j(year)
	*save collapsed data
	tempfile allcoll
	save `allcoll'
	*use all data to collapse annual hours by educ in poverty
	use `alldata', clear
	keep if povcut==1 & educ!=.
	gcollapse (mean) avghrspov = annualhours [pw=perwt], by(year educ)
	*merge collapsed hours for all educ categories v. those in poverty
	decode educ, gen(educstr)
	drop educ
	reshape wide avghrspov, i(educstr) j(year)
	merge 1:1 educstr using `allcoll', assert(3) nogenerate
	export excel "${data}educ_hours.xls", firstrow(variable) replace
restore

