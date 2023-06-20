#Master script for poverty and full employment project

library(tidyverse)
library(data.table)
library(epiextractr)
library(epidatatools)
library(realtalk)
library(labelled)
library(here)
library(blsAPI)
library(openxlsx)
library(zoo)
library(ggplot2)
# 
# This script adapts methodology from Saenz & Sherman 2020
# https://www.cbpp.org/research/poverty-and-inequality/research-note-number-of-people-in-families-with-below-poverty#_ftnref2
# 

# [1] These figures reflect three refinements to a previous version of this analysis released on June 16, 2020. First, when calculating weekly earnings, we assigned zero earnings to workers who reported that they were absent from work all week without pay, even if they reported a “usual weekly earnings” amount. Second, for individuals classified as hourly workers, we calculated their weekly earnings as their hourly wage times their actual hours worked during the reference week. Third, we excluded families where all individuals who are employed (or who were employed recently) are self-employed because Census does not report weekly self-employment earnings.
# 
# [2] The analysis includes people in one-person family units.
# 
# [3] The latest official poverty estimates from the CPS Annual Social and Economic Supplement were based on 68,000 households interviewed in February through April 2019.
# 
# The Census Bureau multiplies each CPS respondent’s results by a “sample weight” to represent the total U.S. population. For the ORG sample, Census provides special ORG sample weights for persons ages 16 and older, which we use in this analysis. For children under 16, we use their final sample weight multiplied by their family head’s ORG-to-final-sample weight ratio.


#Load CPS supplement and geographic labels
source("code/02_poverty_rates.Rmd", echo = TRUE)

source("code/03_analysis.R", echo = TRUE)

#This script will benchmark (almost) our market based income measure to
#CBPP's report:
# https://www.cbpp.org/research/poverty-and-inequality/research-note-number-of-people-in-families-with-below-poverty#_ftnref2

source("code/04_cbpp_benchmark.R", echo = TRUE)