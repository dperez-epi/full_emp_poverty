**************************************************************
* 4.0 Analysis
**************************************************************
/*
browse year serial famsize famunit pernum ftotinc age relate incwage r_incwage ///
 rf_incwage rft_incwage rft_incwage5 uhrswork hrwage0 hrwage1 annualhours avgwkswork ///
 weeklyfamhours annual_famhours povcut wbho educ
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
	gcollapse (mean) avgwgsall = annual_famhours (count) pop = pernum [pw=perwt], by(year)
	format pop %10.0f
	*save collapsed data
	tempfile allcoll
	save `allcoll'
	*use all data to collapse bottom fifth family hours
	use `alldata', clear
	keep if rft_incwage5==1
	gcollapse (mean) avghours = annual_famhours (count) poppov=pernum [pw=perwt], by(year)
	format poppov %10.0f
	*merge collapsed hours for all v. those in bottom fifth
	merge 1:1 year using `allcoll', assert(3) nogenerate
	gen share = poppov / pop
	export excel "${data}quint_famhours.xls", firstrow(variable) replace
	list
restore

*** Implied annual family incomes for bottom fifth vs all

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
	*merge collapsed hours for all v. those in bottom fifth
	merge 1:1 year using `allcoll', assert(3) nogenerate
	export excel "${data}quint_faminc.xls", firstrow(variable) replace
	list
restore

*** hourly family wage for bottom fifth vs all

preserve
	*save all data
	tempfile alldata
	save `alldata'
	use `alldata', clear
	gcollapse (mean) avgwgsall = hrwage1 [pw=perwt], by(year)
	*save collapsed data
	tempfile allcoll
	save `allcoll'
	*use all data to collapse bottom fifth family hours
	use `alldata', clear
	keep if rft_incwage5==1
	gcollapse (mean) avgwgsfifth = hrwage1 [pw=perwt], by(year)
	*merge collapsed hours for all v. those in bottom fifth
	merge 1:1 year using `allcoll', assert(3) nogenerate
	export excel "${data}quint_famwages.xls", firstrow(variable) replace
	list
restore

/*
My issue:

   Average annual hours worked	  Average annual incomes		Implied fam hrly wages			
Year	Bottom fifth	All	Bottom fifth	   All		     Bottom fifth  All
2000	 2,334 	 3,719 		 $17,319 	 $85,085 		 $7.42 	 $22.88 
2001	 2,314 	 3,637 		 $16,477 	 $84,730 		 $7.12 	 $23.30 
2002	 2,234 	 3,585 		 $15,946 	 $85,022 		 $7.14 	 $23.72 
2003	 2,177 	 3,553 		 $15,265 	 $83,828 		 $7.01 	 $23.60 
2004	 2,183 	 3,542 		 $14,840 	 $83,942 		 $6.80 	 $23.70 
2005	 2,165 	 3,561 		 $14,717 	 $83,957 		 $6.80 	 $23.58 
2006	 2,136 	 3,601 		 $14,327 	 $84,152 		 $6.71 	 $23.37 
2007	 2,146 	 3,608 		 $14,741 	 $86,070 		 $6.87 	 $23.85 
2008	 2,153 	 3,613 		 $14,598 	 $85,531 		 $6.78 	 $23.67 
2009	 2,001 	 3,496 		 $13,187 	 $84,608 		 $6.59 	 $24.20 
2010	 1,877 	 3,426 		 $11,485 	 $81,508 		 $6.12 	 $23.79 
2011	 1,855 	 3,432 		 $10,968 	 $80,374 		 $5.91 	 $23.42 
2012	 1,903 	 3,471 		 $11,491 	 $81,309 		 $6.04 	 $23.43 
2013	 1,933 	 3,509 		 $12,200 	 $83,453 		 $6.31 	 $23.78 
2014	 1,981 	 3,550 		 $12,778 	 $84,464 		 $6.45 	 $23.80 
2015	 2,032 	 3,599 		 $13,802 	 $88,000 		 $6.79 	 $24.45 
2016	 2,065 	 3,625 		 $14,449 	 $90,266 		 $7.00 	 $24.90 
2017	 2,103 	 3,658 		 $15,142 	 $91,964 		 $7.20 	 $25.14 
2018	 2,129 	 3,686 		 $15,532 	 $93,249 		 $7.29 	 $25.30 

but my non-implied wages calculated via,

gen hrwage0 = r_incwage / (annualhours) 
label var hrwage0 "Implied hourly wages from wages and salary excluding hours topcode"
*exclude outliers per EPI methodology
replace hrwage0 = . if hrwage0 < .98
replace hrwage0 = . if hrwage0 > 196.08

yields:
	Average hourly household wages	
 Year 	 Bottom fifth 	 All 
 2000 	 $10.46 	 $26.35 
 2001 	 $10.25 	 $26.34 
 2002 	 $10.27 	 $26.72 
 2003 	 $10.48 	 $26.59 
 2004 	 $10.50 	 $26.96 
 2005 	 $10.06 	 $27.19 
 2006 	 $9.67 	 	$26.76 
 2007 	 $9.90 	 	$26.83 
 2008 	 $9.31 	 	$25.79 
 2009 	 $9.52 	 	$26.29 
 2010 	 $9.55 	 	$25.75 
 2011 	 $9.22 	 	$25.27 
 2012 	 $9.14 	 	$25.37 
 2013 	 $9.37 	 	$25.72 
 2014 	 $9.28 	 	$25.68 
 2015 	 $9.48 	 	$26.55 
 2016 	 $9.64 	 	$26.85 
 2017 	 $9.97 	 	$27.37 
 2018 	 $9.90 	 	$27.60 
*/


**************************************************************
* Age breakdown
**************************************************************

*** Implied incomes for all age bins

preserve
	*save all data
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
	*export excel "${data}age_hrwage.xls", firstrow(variable) replace
	list
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
	gcollapse (mean) avghrsall = annualhours [pw=perwt], by(year wbho)
	keep if wbho!=.
	decode wbho, gen(wbhostr)
	drop wbho
	reshape wide avghrsall, i(wbhostr) j(year)
	*save collapsed data
	tempfile allcoll
	save `allcoll'
	*use all data to collapse hr wages by race/ethnicity in poverty
	use `alldata', clear
	keep if povcut==1 & wbho!=.
	gcollapse (mean) avghrspov = annualhours [pw=perwt], by(year wbho)
	*merge collapsed hours for all v. those in poverty
	decode wbho, gen(wbhostr)
	drop wbho
	reshape wide avghrspov, i(wbhostr) j(year)
	merge 1:1 wbhostr using `allcoll', assert(3) nogenerate
	export excel "${data}wbho_hours.xls", firstrow(variable) replace
restore


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
	reshape wide avghrsall, i(educ) j(year)
	*save collapsed data
	tempfile allcoll
	save `allcoll'
	*use all data to collapse annual hours by educ in poverty
	use `alldata', clear
	keep if povcut==1 & educ!=.
	gcollapse (mean) avghrspov = annualhours [pw=perwt], by(year educ)
	*merge collapsed hours for all educ categories v. those in poverty
	reshape wide avghrspov, i(educ) j(year)
	merge 1:1 educ using `allcoll', assert(3) nogenerate
	export excel "${data}educ_hours2.xls", firstrow(variable) replace
restore


/* Questions for Ben:

1. Should we createa new poverty measure not based on family income, not household?

*/
