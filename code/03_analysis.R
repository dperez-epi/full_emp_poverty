# Wrangle poverty data

unemp_data <- load_basic(1994:2022, orgwgt, basicwgt, year, month, minsamp, selfemp, selfinc, emp, unemp, lfstat, age, wbhao) %>% 
  #keep only those interviewed in the ORG
  mutate(selfemp0 = ifelse(selfemp==1 & !is.na(selfemp), yes=1, no=0),
         selfinc0 = ifelse(selfinc==1 & !is.na(selfinc), yes=1, no=0),
         selfany = ifelse(selfinc0==1 | selfemp0==1, yes=1, no=0),
         emp0 = ifelse(emp==1 & !is.na(emp), yes=1, no=0))


#Overall unemployment, annual, not seasonally adjusted
overall_urate <- unemp_data %>% 
  filter(age>=16, lfstat %in% c(1,2), selfemp0==0, selfinc0==0) %>% 
  summarize(urate_16plus = weighted.mean(unemp, w=basicwgt/12, na.rm=TRUE), .by = year)


#Load poverty data csv(). This is just the cps_families dataframe.
poverty_data <- fread(here('input/poverty_rate_data.csv'), na.strings = "NA")


#annual poverty data
povrates_0to64 <- cps_families %>% 
  summarise(poverty_0to64 = weighted.mean(inpoverty, w=adj_wgt/12, na.rm=TRUE), .by=year) %>% 
  left_join(overall_urate)


povlevels_0to64 <- cps_families %>% 
  summarize(povlevel_0to64 = sum(inpoverty * adj_wgt/12, na.rm = TRUE), .by=year) %>% 
  left_join(overall_urate)


urate_wbhao <- unemp_data %>% 
  filter(age>=16, lfstat %in% c(1,2), selfemp0==0, selfinc0==0) %>% 
  summarize(urate_16plus_wbhao = weighted.mean(unemp, w=basicwgt/12, na.rm=TRUE), .by = c(year,wbhao))


povrates_0to64_wbhao <- cps_families %>% 
  mutate(wbhao = to_factor(wbhao)) %>% 
  summarise(povrate_0to64 = weighted.mean(inpoverty, w=adj_wgt, na.rm=TRUE), .by=c(year, wbhao)) %>% 
  pivot_wider(id_cols = year, names_from = wbhao, values_from = c(povrate_0to64)) %>% 
  left_join(overall_urate)

povlevels_0to64_wbhao <- cps_families %>% 
  mutate(wbhao = to_factor(wbhao)) %>% 
  summarise(povlevel_0to64 = sum(inpoverty * adj_wgt/12, na.rm=TRUE), .by=c(year, wbhao)) %>% 
  pivot_wider(id_cols = year, names_from = wbhao, values_from = c(povlevel_0to64)) %>% 
  left_join(overall_urate)


pov_data <- createWorkbook()

addWorksheet(pov_data, sheetName = "Pov. rates overall")
addWorksheet(pov_data, sheetName = "Pov. rates wbhao")
addWorksheet(pov_data, sheetName = "Pov. levels overall")
addWorksheet(pov_data, sheetName = "Pov. levels wbhao")

pct = createStyle(numFmt = '0.0%')
acct = createStyle(numFmt = '#,0' )
hs1 <- createStyle(fgFill = "#4F81BD", halign = "CENTER", textDecoration = "Bold",
                   border = "Bottom", fontColour = "white")

writeData(pov_data, headerStyle = hs1, povrates_0to64, sheet = "Pov. rates overall",
          startCol = 1, startRow = 1, colNames = TRUE)
writeData(pov_data, povrates_0to64_wbhao, headerStyle = hs1, sheet = "Pov. rates wbhao",
          startCol = 1, startRow = 1, colNames = TRUE)
writeData(pov_data, headerStyle = hs1, povlevels_0to64, sheet = "Pov. levels overall",
          startCol = 1, startRow = 1, colNames = TRUE)
writeData(pov_data, povlevels_0to64_wbhao, headerStyle = hs1, sheet = "Pov. levels wbhao",
          startCol = 1, startRow = 1, colNames = TRUE)


#add percent format
addStyle(pov_data, "Pov. rates overall", style=pct, cols=c(2:3), rows=2:(nrow(povrates_0to64)+1), gridExpand=TRUE)
addStyle(pov_data, "Pov. rates wbhao", style=pct, cols=c(2:7), rows=2:(nrow(povrates_0to64_wbhao)+1), gridExpand=TRUE)
addStyle(pov_data, "Pov. levels overall", style=pct, cols=c(3), rows=2:(nrow(povlevels_0to64)+1), gridExpand=TRUE)
addStyle(pov_data, "Pov. levels wbhao", style=pct, cols=c(7), rows=2:(nrow(povlevels_0to64_wbhao)+1), gridExpand=TRUE)

#add accounting format
addStyle(pov_data, "Pov. levels overall", style=acct, cols=c(2), rows=2:(nrow(povlevels_0to64)+1), gridExpand=TRUE)
addStyle(pov_data, "Pov. levels wbhao", style=acct, cols=c(2:6), rows=2:(nrow(povlevels_0to64_wbhao)+1), gridExpand=TRUE)


saveWorkbook(pov_data, here("output/06-23-2023 pov. levels and rates.xlsx"), overwrite = TRUE)
