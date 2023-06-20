# Wrangle poverty data

unemp_data <- load_basic(1994:2022, orgwgt, basicwgt, year, month, minsamp, selfemp, selfinc, emp, unemp, lfstat, age, wbhao) %>% 
  #keep only those interviewed in the ORG
  mutate(selfemp0 = ifelse(selfemp==1 & !is.na(selfemp), yes=1, no=0),
         selfinc0 = ifelse(selfinc==1 & !is.na(selfinc), yes=1, no=0),
         selfany = ifelse(selfinc0==1 | selfemp0==1, yes=1, no=0),
         emp0 = ifelse(emp==1 & !is.na(emp), yes=1, no=0))


#Overall unemployment
overall_urate <- unemp_data %>% 
  filter(age>=16, lfstat %in% c(1,2), selfemp0==0, selfinc0==0) %>% 
  group_by(year) %>% 
  summarize(urate_16plus = weighted.mean(unemp, w=basicwgt/12, na.rm=TRUE))


#Load poverty data csv ()
poverty_data <- fread(here('input/poverty_rate_data.csv'), na.strings = "NA")


poverty_16to64 <- cps_families %>% 
  group_by(year) %>% 
  summarise(poverty_16to64 = weighted.mean(inpoverty, w=adj_wgt, na.rm=TRUE)) %>% 
  left_join(overall_urate)


urate_wbhao <- unemp_data %>% 
  filter(age>=16, lfstat %in% c(1,2), selfemp0==0, selfinc0==0) %>% 
  group_by(year, wbhao) %>% 
  summarize(urate_16plus_wbhao = weighted.mean(unemp, w=basicwgt/12, na.rm=TRUE))


poverty_wbhao_16to64 <- cps_families %>% 
  group_by(year, wbhao) %>% 
  mutate(wbhao = to_factor(wbhao)) %>% 
  summarise(pov_16to64_wbhao = weighted.mean(inpoverty, w=adj_wgt, na.rm=TRUE)) %>% 
  pivot_wider(id_cols = year, names_from = wbhao, values_from = pov_16to64_wbhao) %>% 
  left_join(overall_urate)


pov_data <- createWorkbook()

addWorksheet(pov_data, sheetName = "Overall")
addWorksheet(pov_data, sheetName = "Wbhao")

pct = createStyle(numFmt = '0.0%')
acct = createStyle(numFmt = '#.0' )
hs1 <- createStyle(fgFill = "#4F81BD", halign = "CENTER", textDecoration = "Bold",
                   border = "Bottom", fontColour = "white")

writeData(pov_data, headerStyle = hs1, poverty_16to64, sheet = "Overall",
          startCol = 1, startRow = 1, colNames = TRUE)
writeData(pov_data, poverty_wbhao_16to64, headerStyle = hs1, sheet = "Wbhao",
          startCol = 1, startRow = 1, colNames = TRUE)


saveWorkbook(pov_data, here("output/poverty_workbook_2.0.xlsx"), overwrite = TRUE)
