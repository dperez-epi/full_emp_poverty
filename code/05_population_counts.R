#This script aims to compare population and family sizes with the CPS ASEC


popcount <- crosstab(cps, year, under18, w=adj_wgt/12)

nonelderly_popcount <- crosstab(cps_families, year, under18, w=adj_wgt/12)

wbhao_popcount <- crosstab(cps, year, wbhao, under18, w=adj_wgt/12)
