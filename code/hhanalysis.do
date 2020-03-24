
**************************************************************
* 3.3 Measuring household income + quintiles
**************************************************************

*get rid of missing values in household income
mvdecode hhincome, mv(9999999)

*adjust household income to 2018 real dollars
gen r_hhincome= hhincome * [`basevalue'/cpiurs]
label var r_hhincome "Total household income in real 2018 dollars"

*transform household income variable according to OECD methodology
gen rt_hhincome = (rf_faminc / sqrt(famsize))
label var rt_hhincome "Real household income transformed"

*create quintiles based off transformed household income (rt_hhincome)
gegen rt_hhincome5 = xtile(rft_faminc) [pw=hhwt], nq(5)
label var rt_hhincome5 "Quintiles of transformed total family income"

#delimit;
label def rt_hhincome5
1 "First quintile 0–20%"
2 "Second quintile 20–40%"
3 "Third quintile 40–60%"
4 "Fourth quintile 60–80%"
5 "Fifth quintile 80–100%"
;
#delimit cr
lab val rt_hhincome5 rt_hhincome5
