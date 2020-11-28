*use data_for_tests.dta
set matsize 11000

*************************************************
* Test 1: nlcom vs xlincom without post option **
*************************************************

local iter 10
cap drop nlcom*
cap drop xlincom*
gen nlcom_xt = .
gen xlincom_xt = .
gen nlcom_reg = .
gen xlincom_reg = .

forval i = 1/`iter' {
	timer clear
	
	qui xtreg loggdppc c.l(0/4).ka_std##incgroup_th i.year##incgroup_th i.country#incgroup_th, fe cluster(country) noomit noempty

	timer on 1
	qui nlcom (_b[ka_std] + _b[l.ka_std] + _b[l2.ka_std] + _b[l3.ka_std] + _b[l4.ka_std]) ///
		  (_b[i2.incgroup_th#ka_std] + _b[i2.incgroup_th#l.ka_std] + _b[i2.incgroup_th#l2.ka_std] + _b[i2.incgroup_th#l3.ka_std] + _b[i2.incgroup_th#l4.ka_std]) ///
		  (_b[i3.incgroup_th#ka_std] + _b[i3.incgroup_th#l.ka_std] + _b[i3.incgroup_th#l2.ka_std] + _b[i3.incgroup_th#l3.ka_std] + _b[i3.incgroup_th#l4.ka_std]) ///
		  (_b[i4.incgroup_th#ka_std] + _b[i4.incgroup_th#l.ka_std] + _b[i4.incgroup_th#l2.ka_std] + _b[i4.incgroup_th#l3.ka_std] + _b[i4.incgroup_th#l4.ka_std]), df(88)
	timer off 1

	timer on 2
	qui xlincom (_b[ka_std] + _b[l.ka_std] + _b[l2.ka_std] + _b[l3.ka_std] + _b[l4.ka_std]) ///
		  (_b[i2.incgroup_th#ka_std] + _b[i2.incgroup_th#l.ka_std] + _b[i2.incgroup_th#l2.ka_std] + _b[i2.incgroup_th#l3.ka_std] + _b[i2.incgroup_th#l4.ka_std]) ///
		  (_b[i3.incgroup_th#ka_std] + _b[i3.incgroup_th#l.ka_std] + _b[i3.incgroup_th#l2.ka_std] + _b[i3.incgroup_th#l3.ka_std] + _b[i3.incgroup_th#l4.ka_std]) ///
		  (_b[i4.incgroup_th#ka_std] + _b[i4.incgroup_th#l.ka_std] + _b[i4.incgroup_th#l2.ka_std] + _b[i4.incgroup_th#l3.ka_std] + _b[i4.incgroup_th#l4.ka_std])
	timer off 2
	qui timer list
	
	qui replace nlcom_xt = `r(t1)' in `i'
	qui replace xlincom_xt = `r(t2)' in `i'
	
	timer clear
	
	qui reg d.loggdppc c.d.l(0/4).ka_std##incgroup_th i.year##incgroup_th, cluster(country) 
	
	timer on 1
	qui nlcom (_b[d.ka_std] + _b[d.l.ka_std] + _b[d.l2.ka_std] + _b[d.l3.ka_std] + _b[d.l4.ka_std]) ///
		  (_b[i2.incgroup_th#d.ka_std] + _b[i2.incgroup_th#d.l.ka_std] + _b[i2.incgroup_th#d.l2.ka_std] + _b[i2.incgroup_th#d.l3.ka_std] + _b[i2.incgroup_th#d.l4.ka_std]) ///
		  (_b[i3.incgroup_th#d.ka_std] + _b[i3.incgroup_th#d.l.ka_std] + _b[i3.incgroup_th#d.l2.ka_std] + _b[i3.incgroup_th#d.l3.ka_std] + _b[i3.incgroup_th#d.l4.ka_std]) ///
		  (_b[i4.incgroup_th#d.ka_std] + _b[i4.incgroup_th#d.l.ka_std] + _b[i4.incgroup_th#d.l2.ka_std] + _b[i4.incgroup_th#d.l3.ka_std] + _b[i4.incgroup_th#d.l4.ka_std]), df(88)
	timer off 1
	
	timer on 2
	qui xlincom (_b[d.ka_std] + _b[d.l.ka_std] + _b[d.l2.ka_std] + _b[d.l3.ka_std] + _b[d.l4.ka_std]) ///
		  (_b[i2.incgroup_th#d.ka_std] + _b[i2.incgroup_th#d.l.ka_std] + _b[i2.incgroup_th#d.l2.ka_std] + _b[i2.incgroup_th#d.l3.ka_std] + _b[i2.incgroup_th#d.l4.ka_std]) ///
		  (_b[i3.incgroup_th#d.ka_std] + _b[i3.incgroup_th#d.l.ka_std] + _b[i3.incgroup_th#d.l2.ka_std] + _b[i3.incgroup_th#d.l3.ka_std] + _b[i3.incgroup_th#d.l4.ka_std]) ///
		  (_b[i4.incgroup_th#d.ka_std] + _b[i4.incgroup_th#d.l.ka_std] + _b[i4.incgroup_th#d.l2.ka_std] + _b[i4.incgroup_th#d.l3.ka_std] + _b[i4.incgroup_th#d.l4.ka_std])
	timer off 2
	qui timer list
	
	qui replace nlcom_reg = `r(t1)' in `i'
	qui replace xlincom_reg = `r(t2)' in `i'
}
ttest nlcom_xt == xlincom_xt
local mu1 = r(mu_1)
local mu2 = r(mu_2)
di "On average, xlincom is " `r(mu_1)' / `r(mu_2)' " times faster than nlcom after xtreg, fe"
// On average, xlincom is 288.05939 times faster than nlcom after xtreg, fe

ttest nlcom_reg == xlincom_reg
local mu3 = r(mu_1)
local mu4 = r(mu_2)
di "On average, xlincom is " `r(mu_1)' / `r(mu_2)' " times faster than nlcom after reg"
// On average, xlincom is 25.834061 times faster than nlcom after reg

****************************************************
* Test 2: xlincom with post option COV vs COVZERO **
****************************************************

cap drop cov*
gen cov_xt = .
gen covzero_xt = .
gen cov_reg = .
gen covzero_reg = .

forval i = 1/`iter' {
	timer clear
	
	qui xtreg loggdppc c.l(0/4).ka_std##incgroup_th i.year##incgroup_th i.country#incgroup_th, fe cluster(country) noomit noempty
	timer on 1
	qui xlincom (ka_std + l.ka_std + l2.ka_std + l3.ka_std + l4.ka_std) ///
		  (i2.incgroup_th#ka_std + i2.incgroup_th#l.ka_std + i2.incgroup_th#l2.ka_std + i2.incgroup_th#l3.ka_std + i2.incgroup_th#l4.ka_std) ///
		  (i3.incgroup_th#ka_std + i3.incgroup_th#l.ka_std + i3.incgroup_th#l2.ka_std + i3.incgroup_th#l3.ka_std + i3.incgroup_th#l4.ka_std) ///
		  (i4.incgroup_th#ka_std + i4.incgroup_th#l.ka_std + i4.incgroup_th#l2.ka_std + i4.incgroup_th#l3.ka_std + i4.incgroup_th#l4.ka_std), post
	timer off 1

	qui xtreg loggdppc c.l(0/4).ka_std##incgroup_th i.year##incgroup_th i.country#incgroup_th, fe cluster(country) noomit noempty
	timer on 2
	qui xlincom (ka_std + l.ka_std + l2.ka_std + l3.ka_std + l4.ka_std) ///
		  (i2.incgroup_th#ka_std + i2.incgroup_th#l.ka_std + i2.incgroup_th#l2.ka_std + i2.incgroup_th#l3.ka_std + i2.incgroup_th#l4.ka_std) ///
		  (i3.incgroup_th#ka_std + i3.incgroup_th#l.ka_std + i3.incgroup_th#l2.ka_std + i3.incgroup_th#l3.ka_std + i3.incgroup_th#l4.ka_std) ///
		  (i4.incgroup_th#ka_std + i4.incgroup_th#l.ka_std + i4.incgroup_th#l2.ka_std + i4.incgroup_th#l3.ka_std + i4.incgroup_th#l4.ka_std), post covzero
	timer off 2
	qui timer list
	
	qui replace cov_xt = `r(t1)' in `i'
	qui replace covzero_xt = `r(t2)' in `i'
	
	timer clear
	qui reg d.loggdppc c.d.l(0/4).ka_std##incgroup_th i.year##incgroup_th, cluster(country) 
	
	timer on 1
	qui xlincom (D.ka_std + LD.ka_std + L2D.ka_std + L3D.ka_std + L4D.ka_std) ///
		  (i2.incgroup_th#D.ka_std + i2.incgroup_th#LD.ka_std + i2.incgroup_th#L2D.ka_std + i2.incgroup_th#L3D.ka_std + i2.incgroup_th#L4D.ka_std) ///
		  (i3.incgroup_th#D.ka_std + i3.incgroup_th#LD.ka_std + i3.incgroup_th#L2D.ka_std + i3.incgroup_th#L3D.ka_std + i3.incgroup_th#L4D.ka_std) ///
		  (i4.incgroup_th#D.ka_std + i4.incgroup_th#LD.ka_std + i4.incgroup_th#L2D.ka_std + i4.incgroup_th#L3D.ka_std + i4.incgroup_th#L4D.ka_std), post
	timer off 1
	
	qui reg d.loggdppc c.d.l(0/4).ka_std##incgroup_th i.year##incgroup_th, cluster(country) 
	timer on 2
	qui xlincom (D.ka_std + LD.ka_std + L2D.ka_std + L3D.ka_std + L4D.ka_std) ///
		  (i2.incgroup_th#D.ka_std + i2.incgroup_th#LD.ka_std + i2.incgroup_th#L2D.ka_std + i2.incgroup_th#L3D.ka_std + i2.incgroup_th#L4D.ka_std) ///
		  (i3.incgroup_th#D.ka_std + i3.incgroup_th#LD.ka_std + i3.incgroup_th#L2D.ka_std + i3.incgroup_th#L3D.ka_std + i3.incgroup_th#L4D.ka_std) ///
		  (i4.incgroup_th#D.ka_std + i4.incgroup_th#LD.ka_std + i4.incgroup_th#L2D.ka_std + i4.incgroup_th#L3D.ka_std + i4.incgroup_th#L4D.ka_std), post covzero
	timer off 2
	timer list
	
	qui replace cov_reg = `r(t1)' in `i'
	qui replace covzero_reg = `r(t2)' in `i'
}
ttest cov_xt == covzero_xt
local mu5 = r(mu_1)
local mu6 = r(mu_2)
di "On average, xlincom without COV is " `r(mu_1)' / `r(mu_2)' " times faster than xlincom with COV after xtreg"
// On average, xlincom without COV is 2.5765623 times faster than xlincom with COV after xtreg

ttest cov_reg == covzero_reg
local mu7 = r(mu_1)
local mu8 = r(mu_2)
di "On average, xlincom without COV is " `r(mu_1)' / `r(mu_2)' " times faster than xlincom with COV after reg"
// On average, xlincom without COV is 1.5474876 times faster than xlincom wit COV after reg


**********************************************
* Test 3: nlcom vs xlincom with post option **
**********************************************

cap drop *post
gen nlcom_xt_post = .
gen xlincom_xt_post = .
gen nlcom_reg_post = .
gen xlincom_reg_post = .

forval i = 1/`iter' {
	timer clear
	
	qui xtreg loggdppc c.l(0/4).ka_std##incgroup_th i.year##incgroup_th i.country#incgroup_th, fe cluster(country) noomit noempty

	timer on 1
	qui nlcom (_b[ka_std] + _b[l.ka_std] + _b[l2.ka_std] + _b[l3.ka_std] + _b[l4.ka_std]) ///
		  (_b[i2.incgroup_th#ka_std] + _b[i2.incgroup_th#l.ka_std] + _b[i2.incgroup_th#l2.ka_std] + _b[i2.incgroup_th#l3.ka_std] + _b[i2.incgroup_th#l4.ka_std]) ///
		  (_b[i3.incgroup_th#ka_std] + _b[i3.incgroup_th#l.ka_std] + _b[i3.incgroup_th#l2.ka_std] + _b[i3.incgroup_th#l3.ka_std] + _b[i3.incgroup_th#l4.ka_std]) ///
		  (_b[i4.incgroup_th#ka_std] + _b[i4.incgroup_th#l.ka_std] + _b[i4.incgroup_th#l2.ka_std] + _b[i4.incgroup_th#l3.ka_std] + _b[i4.incgroup_th#l4.ka_std]), df(88) post
	timer off 1

	qui xtreg loggdppc c.l(0/4).ka_std##incgroup_th i.year##incgroup_th i.country#incgroup_th, fe cluster(country) noomit noempty

	timer on 2
	qui xlincom (ka_std + l.ka_std + l2.ka_std + l3.ka_std + l4.ka_std) ///
		  (i2.incgroup_th#ka_std + i2.incgroup_th#l.ka_std + i2.incgroup_th#l2.ka_std + i2.incgroup_th#l3.ka_std + i2.incgroup_th#l4.ka_std) ///
		  (i3.incgroup_th#ka_std + i3.incgroup_th#l.ka_std + i3.incgroup_th#l2.ka_std + i3.incgroup_th#l3.ka_std + i3.incgroup_th#l4.ka_std) ///
		  (i4.incgroup_th#ka_std + i4.incgroup_th#l.ka_std + i4.incgroup_th#l2.ka_std + i4.incgroup_th#l3.ka_std + i4.incgroup_th#l4.ka_std), post
	timer off 2
	qui timer list
	
	qui replace nlcom_xt_post = `r(t1)' in `i'
	qui replace xlincom_xt_post = `r(t2)' in `i'
	
	timer clear
	
	qui reg d.loggdppc c.d.l(0/4).ka_std##incgroup_th i.year##incgroup_th, cluster(country) 
	
	timer on 1
	qui nlcom (_b[d.ka_std] + _b[d.l.ka_std] + _b[d.l2.ka_std] + _b[d.l3.ka_std] + _b[d.l4.ka_std]) ///
		  (_b[i2.incgroup_th#d.ka_std] + _b[i2.incgroup_th#d.l.ka_std] + _b[i2.incgroup_th#d.l2.ka_std] + _b[i2.incgroup_th#d.l3.ka_std] + _b[i2.incgroup_th#d.l4.ka_std]) ///
		  (_b[i3.incgroup_th#d.ka_std] + _b[i3.incgroup_th#d.l.ka_std] + _b[i3.incgroup_th#d.l2.ka_std] + _b[i3.incgroup_th#d.l3.ka_std] + _b[i3.incgroup_th#d.l4.ka_std]) ///
		  (_b[i4.incgroup_th#d.ka_std] + _b[i4.incgroup_th#d.l.ka_std] + _b[i4.incgroup_th#d.l2.ka_std] + _b[i4.incgroup_th#d.l3.ka_std] + _b[i4.incgroup_th#d.l4.ka_std]), df(88) post
	timer off 1

	qui reg d.loggdppc c.d.l(0/4).ka_std##incgroup_th i.year##incgroup_th, cluster(country) 
	
	timer on 2
	qui xlincom (D.ka_std + LD.ka_std + L2D.ka_std + L3D.ka_std + L4D.ka_std) ///
		  (i2.incgroup_th#D.ka_std + i2.incgroup_th#LD.ka_std + i2.incgroup_th#L2D.ka_std + i2.incgroup_th#L3D.ka_std + i2.incgroup_th#L4D.ka_std) ///
		  (i3.incgroup_th#D.ka_std + i3.incgroup_th#LD.ka_std + i3.incgroup_th#L2D.ka_std + i3.incgroup_th#L3D.ka_std + i3.incgroup_th#L4D.ka_std) ///
		  (i4.incgroup_th#D.ka_std + i4.incgroup_th#LD.ka_std + i4.incgroup_th#L2D.ka_std + i4.incgroup_th#L3D.ka_std + i4.incgroup_th#L4D.ka_std), post
	timer off 2
	qui timer list

	qui replace nlcom_reg_post = `r(t1)' in `i'
	qui replace xlincom_reg_post = `r(t2)' in `i'
}
ttest nlcom_xt_post == xlincom_xt_post
local mu9 = r(mu_1)
local mu10 = r(mu_2)

di "On average, xlincom is " `r(mu_1)' / `r(mu_2)' " times faster than nlcom after xtreg, fe with post option"
// On average, xlincom is 138.3159 times faster than nlcom after xtreg, fe with post option

ttest nlcom_reg_post == xlincom_reg_post
local mu11 = r(mu_1)
local mu12 = r(mu_2)
di "On average, xlincom is " `r(mu_1)' / `r(mu_2)' " times faster than nlcom after reg with post option"
// On average, xlincom is 28.529706 times faster than nlcom after reg with post option

************************************************************
* Test 4: xlincom test vs xlincom parser with post option **
************************************************************

cap drop *post
gen test_xtreg_post = .
gen parser_xtreg_post = .
gen test_reg_post = .
gen parser_reg_post = .

forval i = 1/`iter' {
	timer clear
	
	qui xtreg loggdppc c.l(0/4).ka_std##incgroup_th i.year##incgroup_th i.country#incgroup_th, fe cluster(country) noomit noempty

	timer on 1
	qui xlincom (_b[ka_std] + _b[l.ka_std] + _b[l2.ka_std] + _b[l3.ka_std] + _b[l4.ka_std]) ///
		  (_b[i2.incgroup_th#ka_std] + _b[i2.incgroup_th#l.ka_std] + _b[i2.incgroup_th#l2.ka_std] + _b[i2.incgroup_th#l3.ka_std] + _b[i2.incgroup_th#l4.ka_std]) ///
		  (_b[i3.incgroup_th#ka_std] + _b[i3.incgroup_th#l.ka_std] + _b[i3.incgroup_th#l2.ka_std] + _b[i3.incgroup_th#l3.ka_std] + _b[i3.incgroup_th#l4.ka_std]) ///
		  (_b[i4.incgroup_th#ka_std] + _b[i4.incgroup_th#l.ka_std] + _b[i4.incgroup_th#l2.ka_std] + _b[i4.incgroup_th#l3.ka_std] + _b[i4.incgroup_th#l4.ka_std]), post
	timer off 1
	
	qui xtreg loggdppc c.l(0/4).ka_std##incgroup_th i.year##incgroup_th i.country#incgroup_th, fe cluster(country) noomit noempty

	timer on 2
	qui xlincom2 (ka_std + l.ka_std + l2.ka_std + l3.ka_std + l4.ka_std) ///
		  (i2.incgroup_th#ka_std + i2.incgroup_th#l.ka_std + i2.incgroup_th#l2.ka_std + i2.incgroup_th#l3.ka_std + i2.incgroup_th#l4.ka_std) ///
		  (i3.incgroup_th#ka_std + i3.incgroup_th#l.ka_std + i3.incgroup_th#l2.ka_std + i3.incgroup_th#l3.ka_std + i3.incgroup_th#l4.ka_std) ///
		  (i4.incgroup_th#ka_std + i4.incgroup_th#l.ka_std + i4.incgroup_th#l2.ka_std + i4.incgroup_th#l3.ka_std + i4.incgroup_th#l4.ka_std), post
	timer off 2
	qui timer list
	
	qui replace test_xtreg_post = `r(t1)' in `i'
	qui replace parser_xtreg_post = `r(t2)' in `i'
	
	timer clear
	
	qui reg d.loggdppc c.d.l(0/4).ka_std##incgroup_th i.year##incgroup_th, cluster(country) 
	
	timer on 1
	qui xlincom (_b[d.ka_std] + _b[d.l.ka_std] + _b[d.l2.ka_std] + _b[d.l3.ka_std] + _b[d.l4.ka_std]) ///
		  (_b[i2.incgroup_th#d.ka_std] + _b[i2.incgroup_th#d.l.ka_std] + _b[i2.incgroup_th#d.l2.ka_std] + _b[i2.incgroup_th#d.l3.ka_std] + _b[i2.incgroup_th#d.l4.ka_std]) ///
		  (_b[i3.incgroup_th#d.ka_std] + _b[i3.incgroup_th#d.l.ka_std] + _b[i3.incgroup_th#d.l2.ka_std] + _b[i3.incgroup_th#d.l3.ka_std] + _b[i3.incgroup_th#d.l4.ka_std]) ///
		  (_b[i4.incgroup_th#d.ka_std] + _b[i4.incgroup_th#d.l.ka_std] + _b[i4.incgroup_th#d.l2.ka_std] + _b[i4.incgroup_th#d.l3.ka_std] + _b[i4.incgroup_th#d.l4.ka_std]), post
	timer off 1
	
	qui reg d.loggdppc c.d.l(0/4).ka_std##incgroup_th i.year##incgroup_th, cluster(country) 
	
	timer on 2
	qui xlincom2 (D.ka_std + LD.ka_std + L2D.ka_std + L3D.ka_std + L4D.ka_std) ///
		  (i2.incgroup_th#D.ka_std + i2.incgroup_th#LD.ka_std + i2.incgroup_th#L2D.ka_std + i2.incgroup_th#L3D.ka_std + i2.incgroup_th#L4D.ka_std) ///
		  (i3.incgroup_th#D.ka_std + i3.incgroup_th#LD.ka_std + i3.incgroup_th#L2D.ka_std + i3.incgroup_th#L3D.ka_std + i3.incgroup_th#L4D.ka_std) ///
		  (i4.incgroup_th#D.ka_std + i4.incgroup_th#LD.ka_std + i4.incgroup_th#L2D.ka_std + i4.incgroup_th#L3D.ka_std + i4.incgroup_th#L4D.ka_std), post
	timer off 2
	qui timer list

	qui replace test_reg_post = `r(t1)' in `i'
	qui replace parser_reg_post = `r(t2)' in `i'
}
ttest test_xtreg_post == parser_xtreg_post
local mu13 = r(mu_2)
local mu14 = r(mu_1)

di "On average, xlincom_test is " `r(mu_2)' / `r(mu_1)' " times faster than xlincom_parser after xtreg, fe with post option"
// On average, xlincom_test is 3.1569893 times faster than xlincom_parser after xtreg, fe with post option

ttest test_reg_post == parser_reg_post
local mu15 = r(mu_2)
local mu16 = r(mu_1)
di "On average, xlincom_test is " `r(mu_2)' / `r(mu_1)' " times faster than xlincom_parser after reg with post option"
// On average, xlincom_test is 1.625 times faster than xlincom_parser after reg with post option

************************************************************
* Test 5: xlincom test vs xlincom parser with repost option **
************************************************************

cap drop *repost
gen test_xtreg_repost = .
gen parser_xtreg_repost = .
gen test_reg_repost = .
gen parser_reg_repost = .

forval i = 1/`iter' {
	timer clear
	
	qui xtreg loggdppc c.l(0/4).ka_std##incgroup_th i.year##incgroup_th i.country#incgroup_th, fe cluster(country) noomit noempty

	timer on 1
	qui xlincom (_b[ka_std] + _b[l.ka_std] + _b[l2.ka_std] + _b[l3.ka_std] + _b[l4.ka_std]) ///
		  (_b[i2.incgroup_th#ka_std] + _b[i2.incgroup_th#l.ka_std] + _b[i2.incgroup_th#l2.ka_std] + _b[i2.incgroup_th#l3.ka_std] + _b[i2.incgroup_th#l4.ka_std]) ///
		  (_b[i3.incgroup_th#ka_std] + _b[i3.incgroup_th#l.ka_std] + _b[i3.incgroup_th#l2.ka_std] + _b[i3.incgroup_th#l3.ka_std] + _b[i3.incgroup_th#l4.ka_std]) ///
		  (_b[i4.incgroup_th#ka_std] + _b[i4.incgroup_th#l.ka_std] + _b[i4.incgroup_th#l2.ka_std] + _b[i4.incgroup_th#l3.ka_std] + _b[i4.incgroup_th#l4.ka_std]), repost
	timer off 1
	
	qui xtreg loggdppc c.l(0/4).ka_std##incgroup_th i.year##incgroup_th i.country#incgroup_th, fe cluster(country) noomit noempty

	timer on 2
	qui xlincom2 (ka_std + l.ka_std + l2.ka_std + l3.ka_std + l4.ka_std) ///
		  (i2.incgroup_th#ka_std + i2.incgroup_th#l.ka_std + i2.incgroup_th#l2.ka_std + i2.incgroup_th#l3.ka_std + i2.incgroup_th#l4.ka_std) ///
		  (i3.incgroup_th#ka_std + i3.incgroup_th#l.ka_std + i3.incgroup_th#l2.ka_std + i3.incgroup_th#l3.ka_std + i3.incgroup_th#l4.ka_std) ///
		  (i4.incgroup_th#ka_std + i4.incgroup_th#l.ka_std + i4.incgroup_th#l2.ka_std + i4.incgroup_th#l3.ka_std + i4.incgroup_th#l4.ka_std), repost
	timer off 2
	qui timer list
	
	qui replace test_xtreg_repost = `r(t1)' in `i'
	qui replace parser_xtreg_repost = `r(t2)' in `i'
	
	timer clear
	
	qui reg d.loggdppc c.d.l(0/4).ka_std##incgroup_th i.year##incgroup_th, cluster(country) 
	
	timer on 1
	qui xlincom (_b[d.ka_std] + _b[d.l.ka_std] + _b[d.l2.ka_std] + _b[d.l3.ka_std] + _b[d.l4.ka_std]) ///
		  (_b[i2.incgroup_th#d.ka_std] + _b[i2.incgroup_th#d.l.ka_std] + _b[i2.incgroup_th#d.l2.ka_std] + _b[i2.incgroup_th#d.l3.ka_std] + _b[i2.incgroup_th#d.l4.ka_std]) ///
		  (_b[i3.incgroup_th#d.ka_std] + _b[i3.incgroup_th#d.l.ka_std] + _b[i3.incgroup_th#d.l2.ka_std] + _b[i3.incgroup_th#d.l3.ka_std] + _b[i3.incgroup_th#d.l4.ka_std]) ///
		  (_b[i4.incgroup_th#d.ka_std] + _b[i4.incgroup_th#d.l.ka_std] + _b[i4.incgroup_th#d.l2.ka_std] + _b[i4.incgroup_th#d.l3.ka_std] + _b[i4.incgroup_th#d.l4.ka_std]), repost
	timer off 1
	
	qui reg d.loggdppc c.d.l(0/4).ka_std##incgroup_th i.year##incgroup_th, cluster(country) 
	
	timer on 2
	qui xlincom2 (D.ka_std + LD.ka_std + L2D.ka_std + L3D.ka_std + L4D.ka_std) ///
		  (i2.incgroup_th#D.ka_std + i2.incgroup_th#LD.ka_std + i2.incgroup_th#L2D.ka_std + i2.incgroup_th#L3D.ka_std + i2.incgroup_th#L4D.ka_std) ///
		  (i3.incgroup_th#D.ka_std + i3.incgroup_th#LD.ka_std + i3.incgroup_th#L2D.ka_std + i3.incgroup_th#L3D.ka_std + i3.incgroup_th#L4D.ka_std) ///
		  (i4.incgroup_th#D.ka_std + i4.incgroup_th#LD.ka_std + i4.incgroup_th#L2D.ka_std + i4.incgroup_th#L3D.ka_std + i4.incgroup_th#L4D.ka_std), repost
	timer off 2
	qui timer list

	qui replace test_reg_repost = `r(t1)' in `i'
	qui replace parser_reg_repost = `r(t2)' in `i'
}
ttest test_xtreg_repost == parser_xtreg_repost
local mu17 = r(mu_2)
local mu18 = r(mu_1)

di "On average, xlincom_test is " `r(mu_2)' / `r(mu_1)' " times faster than xlincom_parser after xtreg, fe with repost option"
// On average, xlincom_test is 14.408041 times faster than xlincom_parser after xtreg, fe with repost option

ttest test_reg_repost == parser_reg_repost
local mu19 = r(mu_2)
local mu20 = r(mu_1)
di "On average, xlincom_test is " `r(mu_2)' / `r(mu_1)' " times faster than xlincom_parser after reg with repost option"
// On average, xlincom_test is 1.625 times faster than xlincom_parser after reg with repost option


********************************************************************************************************
di "On average, xlincom is " `mu1' / `mu2' " times faster than nlcom after xtreg, fe"
// On average, xlincom is 481.37853 times faster than nlcom after xtreg, fe
di "On average, xlincom is " `mu3' / `mu4' " times faster than nlcom after reg"
// On average, xlincom is 37.694444 times faster than nlcom after reg
di "On average, xlincom without COV is " `mu5' / `mu6' " times faster than xlincom with COV after xtreg"
// On average, xlincom without COV is 1.0759637 times faster than xlincom with COV after xtreg
di "On average, xlincom without COV is " `mu7' / `mu8' " times faster than xlincom with COV after reg"
// On average, xlincom without COV is 1.0734597 times faster than xlincom with COV after reg
di "On average, xlincom is " `mu9' / `mu10' " times faster than nlcom after xtreg, fe with post option"
// On average, xlincom is 445.6045 times faster than nlcom after xtreg, fe with post option
di "On average, xlincom is " `mu11' / `mu12' " times faster than nlcom after reg with post option"
// On average, xlincom is 34.0625 times faster than nlcom after reg with post option
di "On average, xlincom_test is " `mu13' / `mu14' " times faster than xlincom_parser after xtreg, fe with post option"
// On average, xlincom_test is 3.1717921 times faster than xlincom_parser after xtreg, fe with post option
di "On average, xlincom_test is " `mu15' / `mu16' " times faster than xlincom_parser after reg with post option"
// On average, xlincom_test is 1.5844444 times faster than xlincom_parser after reg with post option
di "On average, xlincom_test is " `mu17' / `mu18' " times faster than xlincom_parser after xtreg, fe with repost option"
// On average, xlincom_test is 15.177485 times faster than xlincom_parser after xtreg, fe with repost option
di "On average, xlincom_test is " `mu19' / `mu20' " times faster than xlincom_parser after reg with repost option"
// On average, xlincom_test is 5.6861507 times faster than xlincom_parser after reg with repost option
