*********************************************************
*** Prep analysis of GE effects
*********************************************************


**** local directory

cd "C:\Users\Martin Hackmann\Documents\GitHub\Research"

clear all

set more off
*** load data

use IEB9pct_county_year_worker_counts.dta, clear

*** full pop

*keep if cut=="0"

*drop cut

*** rename select variables

rename sh_no_hzp exposure

*** random region id

gen region_rn=10000*runiform()


bys ao_kreis: egen regionid=mean(region_rn)

replace regionid=round(regionid,1)

gen out_SNF=az_reg_ltc/sample_size
*gen out2=(az_reg_ltc+az_nonreg_ltc)/sample_size
gen out_ue=ue/sample_size

xtset ao_kreis

*** controlling for IAB_ALQ?

xtreg out_SNF c.exposure#jahr i.jahr IAB_ALQ if jahr<2005 & jahr>1975 & cut=="0", fe 
xtreg out_ue c.exposure#jahr i.jahr IAB_ALQ if jahr<2005 & jahr>1984 & cut=="0", fe 


gen out_ue2=ue/age_75_over*1000

gen out_SNF2=az_reg_ltc/age_75_over*1000

xtreg out_ue2 c.exposure#jahr i.jahr IAB_ALQ if jahr<2005 & jahr>1984 & cut=="0", fe 

xtreg out_SNF2 c.exposure#jahr i.jahr IAB_ALQ if jahr<2005 & jahr>1975 & cut=="0", fe 


*** fix a given year
*gen IAB_ALQ1984=IAB_ALQ if jahr==1984

keep if cut=="0"
gen IAB_ALQ1984=out_ue if jahr==1984
bys ao_kreis: egen IAB_ALQ1984max=max(IAB_ALQ1984) 

xtreg out_ue c.exposure#jahr i.jahr c.IAB_ALQ1984max#jahr if jahr<2005 & jahr>1984 & cut=="0", fe 

* out_ue2 c.exposure#jahr i.jahr c.IAB_ALQ1989max#jahr if jahr<2005 & jahr>1984 & cut=="0", fe 

xtreg out_SNF c.exposure#jahr i.jahr c.IAB_ALQ1984max#jahr if jahr<2005 & jahr>1979 & cut=="0", fe 



*** extra control

xtreg out_ue i.jahr if jahr<1985 & cut=="0", fe 

predict shock_ue, e

sort ao_kreis jahr

gen diff_shock=shock_ue-shock_ue[_n-1] if ao_kreis==ao_kreis[_n-1]

bys ao_kreis: egen pre_shockUE=mean(diff_shock)






***** construct interaction terms


foreach x of numlist 1975/1992 1994/2005{

gen treat`x'=0
replace treat`x'=exposure if jahr==`x'
}



xtreg out_ue treat1980-treat2004 i.jahr c.pre_shockUE#jahr if jahr<2005 & jahr>1984 & cut=="0", fe 


**** OLS regs and plots

set more off 
xtreg out_ue treat1980-treat2004 i.jahr c.IAB_ALQ1984max#jahr if jahr<2005 & jahr>1984 & cut=="0", fe 
est store reg_uelms

xtreg out_SNF treat1980-treat2004 i.jahr c.IAB_ALQ1984max#jahr if jahr<2005 & jahr>1984 & cut=="0", fe 

est store reg_snflms

xtreg out_ue treat1980-treat2004 i.jahr IAB_ALQ if jahr<2005 & jahr>1979 & cut=="0", fe 

est store reg_uelms1

xtreg out_SNF treat1980-treat2004 i.jahr IAB_ALQ if jahr<2005 & jahr>1979 & cut=="0", fe 

est store reg_snflms1



***** LFP


gen lgsize=log(sample_size)
gen lgIAB_bzg=log(IAB_LFP_bzg)
gen lgpop1564=log(IAB_LFP_bev1564)

gen LFPmain=sample_size/0.09/IAB_LFP_bev1564

gen baseLFP=LFPmain if jahr==1985
bys ao_kreis: egen baseLFP1985=max(baseLFP)


xtreg lgsize IAB_LFP_lfp treat1980-treat2004 i.jahr  if jahr<2005 & jahr>1984 & cut=="0", fe 

xtreg lgsize treat1980-treat2004 i.jahr  if jahr<2005 & jahr>1984 & cut=="0", fe 

xtreg lgsize lgpop1564 treat1980-treat2004 i.jahr  if jahr<2005 & jahr>1984 & cut=="0", fe 

xtreg lgsize lgIAB_bzg lgpop1564 treat1980-treat2004 i.jahr  if jahr<2005 & jahr>1984 & cut=="0", fe 

xtreg LFPmain treat1986-treat2004 i.jahr if jahr<2005 & jahr>1984 & cut=="0", fe 

xtreg IAB_LFP_bev1564 treat1986-treat2004 i.jahr if jahr<2005 & jahr>1984 & cut=="0", fe 


gen popbase=IAB_LFP_bev1564 if jahr==1990
bys ao_kreis: egen popbase92=max(IAB_LFP_bev1564)

gen LFPmain2=sample_size/0.09/popbase92

xtreg LFPmain LFPmain2 treat1986-treat2004 i.jahr if jahr<2005 & jahr>1984 & cut=="0", fe 


gen lgpop=log(IAB_LFP_bev1564)

xtreg lgpop treat1986-treat2004 i.jahr if jahr<2005 & jahr>1984 & cut=="0", fe 


sort ao_kreis jahr

gen diff_lfpmain=LFPmain-LFPmain[_n-1] if jahr==1991

gen IAB_LFP_bev1564


merge ao_kreis using disp_inc_959005_destatis.dta

keep if _merge!=2

drop _merge


*** what predicts IAB_ALQ in 1989?


reg IAB_ALQ tot_pop age_60_over az_nonreg az_reg_energy-az_reg_hc_oth pc_disposable_income_1995 if jahr==1989

predict IAB_LTC_hat, xb

replace IAB_LTC_hat=. if jahr!=1989

bys ao_kreis: egen IAB_LTC_hat1989=max(IAB_LTC_hat)

xtreg out_ue treat1980-treat2004 i.jahr c.IAB_LTC_hat1989#jahr if jahr<2005 & jahr>1979 & cut=="0", fe 

est store reg_uelms2

xtreg out_SNF treat1980-treat2004 i.jahr c.IAB_LTC_hat1989#jahr if jahr<2005 & jahr>1979 & cut=="0", fe 

est store reg_snflms2


*** what predicts out_ue

reg out_ue tot_pop age_60_over az_nonreg az_reg_energy-az_reg_hc_oth pc_disposable_income_1995 if jahr==1979

predict out_ue_hat, xb

replace out_ue_hat=. if jahr!=1979

bys ao_kreis: egen out_ue_hat1979=max(out_ue_hat)	
	
xtreg out_ue treat1980-treat2004 i.jahr c.out_ue_hat1979#jahr if jahr<2005 & jahr>1979 & cut=="0", fe 

est store reg_uelms3

xtreg out_SNF treat1980-treat2004 i.jahr c.out_ue_hat1979#jahr if jahr<2005 & jahr>1979 & cut=="0", fe 

est store reg_snflms3

esttab reg_uelms reg_snflms reg_uelms1 reg_snflms1 reg_uelms2 reg_snflms2 reg_uelms3 reg_snflms3 using "GE_IABcontrols.tex", cells(b(star) ci(fmt(2)par)) keep(treat*) noobs nonumber mlabels("UE per LMS90" "SNF per LMS90" "UE per LMS90" "SNF per LMS90") ///
    collabels(none) title(Event Study Coefficients) replace



	
********************************************************************************************
********* exploring immigration
********************************************************************************************




gen out_diff=out_ue-IAB_ALQ1989max

xtreg out_diff c.exposure#jahr i.jahr  if jahr<2005 & jahr>1984 & cut=="0", fe 


keep if cut=="0"
outsheet jahr-IAB_ALQ1989max using data_all.csv, comma replace



xtreg out_ue2 c.exposure#jahr i.jahr ltc_pred_adaboost c.ltc_pred_adaboost#jahr if jahr<2005 & jahr>1984 & cut=="0", fe 

**** 


xtreg out_ue c.exposure#jahr i.jahr IAB_ALQ if jahr<2005 & jahr>1975 & cut=="0", fe 

replace ZEIT_immigrants_from_east =. if jahr!=1991

replace DESTAT_immigrants=. if jahr!=1991

bys ao_kreis: egen ZEIT_immigrants1991=max(ZEIT_immigrants_from_east)
bys ao_kreis: egen DESTAT_immigrants1991=max(DESTAT_immigrants)

*** other ideas

xtreg out_ue c.exposure#jahr i.jahr c.IAB_LFP_lfp#jahr if jahr<2005 & jahr>1975 & cut=="0", fe

xtreg out_ue c.exposure#jahr i.jahr c.ZEIT_immigrants1991#jahr if jahr<2005 & jahr>1984 & cut=="0", fe

xtreg out_ue c.exposure#jahr i.jahr c.DESTAT_immigrants1991#jahr if jahr<2005 & jahr>1984 & cut=="0", fe

xtreg out_ue c.exposure#jahr i.jahr c.IAB_LFP_lfp#jahr c.DESTAT_immigrants1991#jahr if jahr<2005 & jahr>1984 & cut=="0", fe

xtreg out_ue c.exposure#jahr i.jahr IAB_LFP_lfp c.DESTAT_immigrants1991#jahr if jahr<2005 & jahr>1984 & cut=="0", fe

foreach var of varlist az_reg_ltc- az_reg_hc_oth{

replace `var'=`var'/sample_size
}

*** industry mix 1991

gen az_reg_manuf1991=az_reg_manuf if jahr==1991
bys ao_kreis: egen az_reg_manuf1991max=max(az_reg_manuf1991)

xtreg out_ue c.exposure#jahr i.jahr c.IAB_LFP_lfp#jahr c.DESTAT_immigrants1991#jahr  if jahr<2005 & jahr>1984 & cut=="0.02", fe
xtreg out_ue c.exposure#jahr i.jahr  c.DESTAT_immigrants1991#jahr  if jahr<2005 & jahr>1975 & cut=="0.02", fe

*** 



drop out_ue out_SNF out_ue2 out_SNF2 DESTAT_immigrants1991 ZEIT_immigrants1991

















*****************************************************************
*****************************************************************
**** server analysis

clear all

set more off
*** load data

use IEB9pct_county_year_worker_counts.dta, clear

*** full pop

*keep if cut=="0"

*drop cut

*** rename select variables

rename sh_no_hzp exposure

*** random region id

gen region_rn=10000*runiform()


bys ao_kreis: egen regionid=mean(region_rn)




preserve 

keep ao_kreis regionid

collapse (mean) regionid, by(ao_kreis)

*** check if regionid unique

sort regionid

quietly count if regionid==regionid[_n-1]

local counter=`r(N)'

while `counter'>0 {

replace regionid=regionid+1 if regionid==regionid[_n-1]

sort regionid

quietly count if regionid==regionid[_n-1]

local counter=`r(N)'

}

sort ao_kreis regionid

save regionid_cw.dta, replace

restore



*** define outcomes

gen out1=az_reg_ltc/sample_size
*gen out2=(az_reg_ltc+az_nonreg_ltc)/sample_size
gen out_ue=ue/sample_size



*gen out2_lev=az_reg_ltc+az_nonreg_ltc
rename az_reg_ltc out1_lev
rename ue out_ue_lev

drop regionid

merge ao_kreis using regionid_cw.dta

drop _merge

drop ao_kreis ao_bula region_rn az_nonreg_ltc 



xtset regionid

xtreg out_ue c.exposure#jahr i.jahr IAB_ALQ if jahr<2005 & jahr>1975 & cut=="0", fe 

xtreg out_ue c.exposure#jahr i.jahr IAB_ALQ if jahr<2005 & jahr>1975 & cut=="0", fe 

xtreg out1 c.exposure#jahr i.jahr IAB_ALQ if jahr<2005 & jahr>1975 & cut=="0", fe 


order jahr regionid exposure out* 

local i=0

foreach var of varlist ltc_pred_adaboost-IAB_LFP_lfp {

gen X`i'=`var'

local i=`i'+1

}

keep if cut=="0" & jahr>=1980 & jahr<=2004

drop ltc_pred_adaboost-IAB_LFP_lfp

drop X6 X27-X38


foreach x of numlist 1980/1992 1994/2004{

gen treat`x'=0
replace treat`x'=exposure if jahr==`x'
}



outsheet jahr regionid exposure out* X* treat* using data_anonym.csv, comma replace

**** event study


**** region FE

xtset regionid

xtreg X5 treat* i.jahr if jahr<2005 & jahr>1984 & cut=="0", fe

gen lgX5=log(X5)

xtreg lgX5 treat* i.jahr X21 X42 X39 X24 if jahr<2005 & jahr>1984 & cut=="0", fe

xtreg lgX5 treat* i.jahr X42  if jahr<2005 & jahr>1984 & cut=="0", fe


gen lgX5base=lgX5 if jahr==1984

bys regionid: egen lgX5base1984=max(lgX5base)	

gen X42base=X42 if jahr==1985
bys regionid: egen X42base1984=max(X42base)	


xtreg lgX5 treat* i.jahr X42 if jahr<2005 & jahr>1984 & cut=="0", fe



xtreg out_ue c.exposure#jahr i.jahr X39 if jahr<2005 & jahr>1975, fe 

xtreg out_ue c.exposure#jahr i.jahr X0-X4 X7-X11 X13-X14 X16 X18 X19 X20 X21 X24 X39-X42 if jahr<2005 & jahr>1984, fe 

xtreg out_ue c.exposure#jahr i.jahr X0-X4 X9-X11 X13-X14 X16 X18 X19 X20 X21 X24 X39-X42 if jahr<2005 & jahr>1975, fe 

’X0’, ’X1’, ’X2’, ’X3’, ’X4’, ’X7’, ’X8’, ’X9’, ’X10’, ’X11’, ’X13’, ’X14’, ’X16’, ’X18’, ’X19’, ’X20’, ’X21’, ’X24’, ’X39’, ’X40’, ’X41’, ’X42’


*can you do a linear regression where X5 is the dependent variable and the controls are jahr and regionid fixed effects and all variables starting with treat. please plot the coefficients on the treat variables with the number in the variable name referring to the horizontal axis

