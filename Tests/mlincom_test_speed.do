use data_for_tests.dta
set matsize 11000

*************************************************
* Test 1: nlcom vs mlincom without post option **
*************************************************

local iter 100
cap drop nlcom_xt mlincom_xt nlcom_reg mlincom_reg
gen nlcom_xt = .
gen mlincom_xt = .
gen nlcom_reg = .
gen mlincom_reg = .

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
	qui mlincom (_b[ka_std] + _b[l.ka_std] + _b[l2.ka_std] + _b[l3.ka_std] + _b[l4.ka_std]) ///
		  (_b[i2.incgroup_th#ka_std] + _b[i2.incgroup_th#l.ka_std] + _b[i2.incgroup_th#l2.ka_std] + _b[i2.incgroup_th#l3.ka_std] + _b[i2.incgroup_th#l4.ka_std]) ///
		  (_b[i3.incgroup_th#ka_std] + _b[i3.incgroup_th#l.ka_std] + _b[i3.incgroup_th#l2.ka_std] + _b[i3.incgroup_th#l3.ka_std] + _b[i3.incgroup_th#l4.ka_std]) ///
		  (_b[i4.incgroup_th#ka_std] + _b[i4.incgroup_th#l.ka_std] + _b[i4.incgroup_th#l2.ka_std] + _b[i4.incgroup_th#l3.ka_std] + _b[i4.incgroup_th#l4.ka_std])
	timer off 2
	timer list
	
	qui replace nlcom_xt = `r(t1)' in `i'
	qui replace mlincom_xt = `r(t2)' in `i'
	
	timer clear
	
	qui reg d.loggdppc c.d.l(0/4).ka_std##incgroup_th i.year##incgroup_th, cluster(country) 
	
	timer on 1
	qui nlcom (_b[d.ka_std] + _b[d.l.ka_std] + _b[d.l2.ka_std] + _b[d.l3.ka_std] + _b[d.l4.ka_std]) ///
		  (_b[i2.incgroup_th#d.ka_std] + _b[i2.incgroup_th#d.l.ka_std] + _b[i2.incgroup_th#d.l2.ka_std] + _b[i2.incgroup_th#d.l3.ka_std] + _b[i2.incgroup_th#d.l4.ka_std]) ///
		  (_b[i3.incgroup_th#d.ka_std] + _b[i3.incgroup_th#d.l.ka_std] + _b[i3.incgroup_th#d.l2.ka_std] + _b[i3.incgroup_th#d.l3.ka_std] + _b[i3.incgroup_th#d.l4.ka_std]) ///
		  (_b[i4.incgroup_th#d.ka_std] + _b[i4.incgroup_th#d.l.ka_std] + _b[i4.incgroup_th#d.l2.ka_std] + _b[i4.incgroup_th#d.l3.ka_std] + _b[i4.incgroup_th#d.l4.ka_std]), df(88)
	timer off 1
	
	timer on 2
	qui mlincom (_b[d.ka_std] + _b[d.l.ka_std] + _b[d.l2.ka_std] + _b[d.l3.ka_std] + _b[d.l4.ka_std]) ///
		  (_b[i2.incgroup_th#d.ka_std] + _b[i2.incgroup_th#d.l.ka_std] + _b[i2.incgroup_th#d.l2.ka_std] + _b[i2.incgroup_th#d.l3.ka_std] + _b[i2.incgroup_th#d.l4.ka_std]) ///
		  (_b[i3.incgroup_th#d.ka_std] + _b[i3.incgroup_th#d.l.ka_std] + _b[i3.incgroup_th#d.l2.ka_std] + _b[i3.incgroup_th#d.l3.ka_std] + _b[i3.incgroup_th#d.l4.ka_std]) ///
		  (_b[i4.incgroup_th#d.ka_std] + _b[i4.incgroup_th#d.l.ka_std] + _b[i4.incgroup_th#d.l2.ka_std] + _b[i4.incgroup_th#d.l3.ka_std] + _b[i4.incgroup_th#d.l4.ka_std])
	timer off 2
	qui timer list
	
	qui replace nlcom_reg = `r(t1)' in `i'
	qui replace mlincom_reg = `r(t2)' in `i'
}
ttest nlcom_xt == mlincom_xt
di "On average, mlincom is " `r(mu_1)' / `r(mu_2)' " times faster than nlcom after xtreg, fe"
// On average, mlincom is 288.05939 times faster than nlcom after xtreg, fe

ttest nlcom_reg == mlincom_reg
di "On average, mlincom is " `r(mu_1)' / `r(mu_2)' " times faster than nlcom after reg"
// On average, mlincom is 25.834061 times faster than nlcom after reg

****************************************************
* Test 2: mlincom with post option COV vs COVZERO **
****************************************************

cap drop cov*
local iter 100
gen cov_xt = .
gen covzero_xt = .
gen cov_reg = .
gen covzero_reg = .

forval i = 1/`iter' {
	timer clear
	
	qui xtreg loggdppc c.l(0/4).ka_std##incgroup_th i.year##incgroup_th i.country#incgroup_th, fe cluster(country) noomit noempty
	timer on 1
	qui mlincom (ka_std + l.ka_std + l2.ka_std + l3.ka_std + l4.ka_std) ///
		  (i2.incgroup_th#ka_std + i2.incgroup_th#l.ka_std + i2.incgroup_th#l2.ka_std + i2.incgroup_th#l3.ka_std + i2.incgroup_th#l4.ka_std) ///
		  (i3.incgroup_th#ka_std + i3.incgroup_th#l.ka_std + i3.incgroup_th#l2.ka_std + i3.incgroup_th#l3.ka_std + i3.incgroup_th#l4.ka_std) ///
		  (i4.incgroup_th#ka_std + i4.incgroup_th#l.ka_std + i4.incgroup_th#l2.ka_std + i4.incgroup_th#l3.ka_std + i4.incgroup_th#l4.ka_std), post
	timer off 1

	qui xtreg loggdppc c.l(0/4).ka_std##incgroup_th i.year##incgroup_th i.country#incgroup_th, fe cluster(country) noomit noempty
	timer on 2
	qui mlincom (ka_std + l.ka_std + l2.ka_std + l3.ka_std + l4.ka_std) ///
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
	qui mlincom (D.ka_std + LD.ka_std + L2D.ka_std + L3D.ka_std + L4D.ka_std) ///
		  (i2.incgroup_th#D.ka_std + i2.incgroup_th#LD.ka_std + i2.incgroup_th#L2D.ka_std + i2.incgroup_th#L3D.ka_std + i2.incgroup_th#L4D.ka_std) ///
		  (i3.incgroup_th#D.ka_std + i3.incgroup_th#LD.ka_std + i3.incgroup_th#L2D.ka_std + i3.incgroup_th#L3D.ka_std + i3.incgroup_th#L4D.ka_std) ///
		  (i4.incgroup_th#D.ka_std + i4.incgroup_th#LD.ka_std + i4.incgroup_th#L2D.ka_std + i4.incgroup_th#L3D.ka_std + i4.incgroup_th#L4D.ka_std), post
	timer off 1
	
	qui reg d.loggdppc c.d.l(0/4).ka_std##incgroup_th i.year##incgroup_th, cluster(country) 
	timer on 2
	qui mlincom (D.ka_std + LD.ka_std + L2D.ka_std + L3D.ka_std + L4D.ka_std) ///
		  (i2.incgroup_th#D.ka_std + i2.incgroup_th#LD.ka_std + i2.incgroup_th#L2D.ka_std + i2.incgroup_th#L3D.ka_std + i2.incgroup_th#L4D.ka_std) ///
		  (i3.incgroup_th#D.ka_std + i3.incgroup_th#LD.ka_std + i3.incgroup_th#L2D.ka_std + i3.incgroup_th#L3D.ka_std + i3.incgroup_th#L4D.ka_std) ///
		  (i4.incgroup_th#D.ka_std + i4.incgroup_th#LD.ka_std + i4.incgroup_th#L2D.ka_std + i4.incgroup_th#L3D.ka_std + i4.incgroup_th#L4D.ka_std), post covzero
	timer off 2
	timer list
	
	qui replace cov_reg = `r(t1)' in `i'
	qui replace covzero_reg = `r(t2)' in `i'
}
ttest cov_xt == covzero_xt
di "On average, mlincom without COV is " `r(mu_1)' / `r(mu_2)' " times faster than mlincom with COV after xtreg"
// On average, mlincom without COV is 2.5765623 times faster than mlincom with COV after xtreg

ttest cov_reg == covzero_reg
di "On average, mlincom without COV is " `r(mu_1)' / `r(mu_2)' " times faster than mlincom with COV after reg"
// On average, mlincom without COV is 1.5474876 times faster than mlincom wit COV after reg


**********************************************
* Test 3: nlcom vs mlincom with post option **
**********************************************

local iter 100
cap drop *post
gen nlcom_xt_post = .
gen mlincom_xt_post = .
gen nlcom_reg_post = .
gen mlincom_reg_post = .

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
	qui mlincom (ka_std + l.ka_std + l2.ka_std + l3.ka_std + l4.ka_std) ///
		  (i2.incgroup_th#ka_std + i2.incgroup_th#l.ka_std + i2.incgroup_th#l2.ka_std + i2.incgroup_th#l3.ka_std + i2.incgroup_th#l4.ka_std) ///
		  (i3.incgroup_th#ka_std + i3.incgroup_th#l.ka_std + i3.incgroup_th#l2.ka_std + i3.incgroup_th#l3.ka_std + i3.incgroup_th#l4.ka_std) ///
		  (i4.incgroup_th#ka_std + i4.incgroup_th#l.ka_std + i4.incgroup_th#l2.ka_std + i4.incgroup_th#l3.ka_std + i4.incgroup_th#l4.ka_std), post
	timer off 2
	qui timer list
	
	qui replace nlcom_xt_post = `r(t1)' in `i'
	qui replace mlincom_xt_post = `r(t2)' in `i'
	
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
	qui mlincom (D.ka_std + LD.ka_std + L2D.ka_std + L3D.ka_std + L4D.ka_std) ///
		  (i2.incgroup_th#D.ka_std + i2.incgroup_th#LD.ka_std + i2.incgroup_th#L2D.ka_std + i2.incgroup_th#L3D.ka_std + i2.incgroup_th#L4D.ka_std) ///
		  (i3.incgroup_th#D.ka_std + i3.incgroup_th#LD.ka_std + i3.incgroup_th#L2D.ka_std + i3.incgroup_th#L3D.ka_std + i3.incgroup_th#L4D.ka_std) ///
		  (i4.incgroup_th#D.ka_std + i4.incgroup_th#LD.ka_std + i4.incgroup_th#L2D.ka_std + i4.incgroup_th#L3D.ka_std + i4.incgroup_th#L4D.ka_std), post
	timer off 2
	qui timer list

	qui replace nlcom_reg_post = `r(t1)' in `i'
	qui replace mlincom_reg_post = `r(t2)' in `i'
}
ttest nlcom_xt_post == mlincom_xt_post
di "On average, mlincom is " `r(mu_1)' / `r(mu_2)' " times faster than nlcom after xtreg, fe with post option"
// On average, mlincom is 138.3159 times faster than nlcom after xtreg, fe with post option

ttest nlcom_reg_post == mlincom_reg_post
di "On average, mlincom is " `r(mu_1)' / `r(mu_2)' " times faster than nlcom after reg with post option"
// On average, mlincom is 28.529706 times faster than nlcom after reg with post option
