
# This script attempts to benchmark our market based poverty measure to Tables 1 and 2 from 
# https://www.cbpp.org/research/poverty-and-inequality/research-note-number-of-people-in-families-with-below-poverty#_ftnref2


popcount <- cps %>%
  group_by(month) %>% 
  filter(age>=16 & age<65) %>% 
  summarize(wgt_n = sum(orgwgt, na.rm=TRUE),
            employed = sum(emp * orgwgt, na.rm=TRUE),
            n = n())

#filtered bc I remove everyone who doesn't have a finalwgt and thus adj_wgt
popcount_filtered <- fam_poverty %>%
  group_by(month) %>% 
  filter(age>=16 & age<65) %>% 
  summarize(wgt_n = sum(orgwgt, na.rm=TRUE),
            employed = sum(emp * orgwgt, na.rm=TRUE),
            n = n())

povcount_all <- fam_poverty %>% 
  filter(year==2020) %>% 
  group_by(month) %>% 
  summarize(wgt_n = sum(inpoverty * adj_wgt, na.rm=TRUE),
            share = weighted.mean(inpoverty, w=adj_wgt/12, na.rm=TRUE),
            n = n()) %>% 
  mutate(group='Poverty, all',
         poverty_earnings='All',
         year=2020)

monthlypov_all <- fam_poverty %>% 
  filter(year==2020) %>% 
  group_by(month) %>% 
  summarize(inpov = sum(inpoverty * adj_wgt, na.rm=TRUE),
            share = weighted.mean(inpoverty, w=adj_wgt, na.rm=TRUE),
            n = n(),
            wgt_n = sum(inpoverty*adj_wgt, na.rm=TRUE)) %>%
  mutate(group='Poverty, all',
         poverty_earnings='All')

povcount_under18 <- fam_poverty %>%
  filter(year==2020) %>% 
  filter(age<18) %>% 
  group_by(month) %>% 
  summarize(wgt_n = sum(inpoverty * adj_wgt, na.rm=TRUE),
            share = weighted.mean(inpoverty, w=adj_wgt, na.rm=TRUE),
            n = n()) %>% 
  mutate(group='Poverty, all',
         poverty_earnings='All')

povcount_wbhao <- fam_poverty %>% 
  filter(year==2020) %>% 
  group_by(year, month, wbhao) %>% 
  summarize(wgt_n = sum(inpoverty * adj_wgt, na.rm=TRUE),
            share = weighted.mean(inpoverty, w=adj_wgt, na.rm=TRUE),
            n = n()) %>% 
  mutate(wbhao = to_factor(wbhao)) %>% 
  mutate(group='Poverty, wbhao',
         poverty_earnings=wbhao)

povcount_wbho_only <- fam_poverty %>%
  filter(year==2020) %>% 
  group_by(year, month, wbho_only) %>%
  summarize(wgt_n = sum(inpoverty * adj_wgt, na.rm=TRUE),
            share = weighted.mean(inpoverty, w=adj_wgt, na.rm=TRUE),
            n = n()) %>%
  mutate(wbho_only = to_factor(wbho_only)) %>%
  mutate(group='Poverty, wbho_only',
         poverty_earnings=wbho_only)

povcount_age <- fam_poverty %>% 
  filter(year==2020) %>% 
  group_by(year, month, under18) %>% 
  summarize(wgt_n= sum(inpoverty * adj_wgt, na.rm=TRUE),
            share = weighted.mean(inpoverty, w=adj_wgt, na.rm=TRUE),
            n=n()) %>% 
  mutate(under18 = as.character(to_factor(under18))) %>% 
  filter(under18=='under 18') %>% 
  mutate(group='Poverty, age') %>% 
  rename(poverty_earnings = under18)

noincome_all <- fam_poverty %>% 
  filter(year==2020) %>% 
  group_by(year, month) %>% 
  summarize(wgt_n = sum(noincome * adj_wgt, na.rm=TRUE),
            share = weighted.mean(noincome, w=adj_wgt, na.rm=TRUE),
            n = n()) %>% 
  mutate(group='No income, all',
         zero_earnings = 'All')

noincome_wbhao <- fam_poverty %>%
  filter(year==2020) %>% 
  mutate(wbhao=as_factor(wbhao)) %>% 
  group_by(year, month, wbhao) %>% 
  summarize(wgt_n = sum(noincome * adj_wgt, na.rm=TRUE),
            share = weighted.mean(noincome, w=adj_wgt, na.rm=TRUE),
            n = n()) %>% 
  mutate(group='No income, wbhao') %>% 
  rename(zero_earnings = wbhao)

noincome_age <- fam_poverty %>% 
  filter(year==2020) %>% 
  group_by(year, month, under18) %>% 
  summarize(wgt_n = sum(noincome * adj_wgt, na.rm=TRUE),
            share = weighted.mean(noincome, w=adj_wgt, na.rm=TRUE),
            n=n()) %>% 
  mutate(under18 = as.character(to_factor(under18))) %>% 
  filter(under18=='under 18') %>% 
  mutate(group='No income, age') %>% 
  rename(zero_earnings = under18)


#bind poverty tables
fams_in_poverty_count <- bind_rows(povcount_all, povcount_age, povcount_wbhao) %>% 
  filter(month %in% c(2,4,6)) %>% 
  mutate(month = to_factor(month)) %>%
  pivot_wider(id_cols = poverty_earnings, names_from = c(month,year), values_from = wgt_n) %>% 
  mutate(feb_to_jun_pct = (Jun_2020/Feb_2020)-1)

fams_in_poverty_share <- bind_rows(povcount_all,povcount_age, povcount_wbhao) %>% 
  filter(month %in% c(2,4,6)) %>% 
  mutate(month = to_factor(month)) %>%
  pivot_wider(id_cols = poverty_earnings, names_from = c(month, year), values_from = share) %>% 
  mutate(feb_to_jun_ppt = (Jun_2020-Feb_2020))

#bind zero income tables
fams_no_income_count <- bind_rows(noincome_all, noincome_age, noincome_wbhao) %>% 
  filter(month %in% c(2,4,6)) %>% 
  mutate(month = to_factor(month)) %>%
  pivot_wider(id_cols = zero_earnings, names_from = c(month,year), values_from = wgt_n) %>% 
  mutate(feb_to_jun_pct = (Jun_2020/Feb_2020)-1)

fams_no_income_share <- bind_rows(noincome_all, noincome_age, noincome_wbhao) %>% 
  filter(month %in% c(2,4,6)) %>% 
  mutate(month = to_factor(month)) %>%
  pivot_wider(id_cols = zero_earnings, names_from = c(month,year), values_from = share) %>% 
  mutate(feb_to_jun_ppt = (Jun_2020-Feb_2020))

table1 <- bind_rows(fams_in_poverty_count, fams_no_income_count) %>% 
  relocate(zero_earnings, .after=poverty_earnings) %>% 
  mutate(Feb_2020 = Feb_2020/1000000,
         Apr_2020 = Apr_2020/1000000,
         Jun_2020 = Jun_2020/1000000)

table2 <- bind_rows(fams_in_poverty_share, fams_no_income_share) %>% 
  relocate(zero_earnings, .after=poverty_earnings)



#benchmark of employed persons
adults <- fam_poverty %>% 
  filter(year==2020) %>% 
  summarize(adults_16plus = sum(orgwgt/12, na.rm=TRUE),
            adults_pwages = sum(orgwgt[weekpay>0]/12, na.rm=TRUE),
            n = n())

payeligible <- fam_poverty %>% 
  filter(year==2020) %>% 
  group_by(month) %>% 
  summarize(adults_16plus = sum(orgwgt, na.rm=TRUE),
            adults_elig = sum(orgwgt[emp==1], na.rm=TRUE),
            adult_pos_earn = sum(orgwgt[weekpay>0], na.rm=TRUE),
            n = n())

#count of population by age
agecount <- fam_poverty %>% 
  filter(year==2020) %>% 
  group_by(age) %>% 
  summarize(under16 = sum(adj_wgt/12, na.rm=TRUE),
            adults_pwages = sum(adj_wgt[weekpay>0]/12, na.rm=TRUE),
            n = n())


## median weekly pay benchmark to https://www.bls.gov/news.release/pdf/wkyeng.pdf
benchmarkpay <- thedata %>% 
  filter(age>=16, selfemp==0, selfinc==0, emp==1) %>% 
  mutate(date = as.Date(paste(year, month, 1, sep = "-"), "%Y-%m-%d")) %>% 
  #create quarterly date periods
  mutate(qtr=as.yearqtr(date)) %>%  
  filter(hoursu1i>=35 & !is.na(hoursu1i)) %>% 
  group_by(qtr) %>% 
  summarize(med_wages = median(realwage, w=orgwgt, na.rm=TRUE),
            med_weekpay.c = median(realweekpay.c, w=orgwgt, na.rm=TRUE),
            med_weekpay = median(realweekpay, w=orgwgt, na.rm=TRUE),
            wgt_n=sum(orgwgt/3, na.rm=TRUE)/1000)

# will break if age is not restricted to 16+
weekpay <- thedata %>% 
  filter(age>=16 & age<65, selfinc0==0, selfemp0==0) %>% 
  group_by(month) %>% 
  summarize(avg_wages = weighted.mean(realwage, w=orgwgt, na.rm=TRUE),
            avg_weekpay.c = weighted.mean(realweekpay.c, w=orgwgt, na.rm=TRUE),
            avg_weekpay = weighted.mean(realweekpay, w=orgwgt, na.rm=TRUE),
            n=n())

```