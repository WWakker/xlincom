*********************************
** XLINCOM FUNCTIONALITY TESTS **
*********************************

discard
clear all

// Syntax

** Syntax equations
* Test 1
cap xlincom
assert _rc == 301

* Test 2
sysuse auto
reg price mpg weight

cap xlincom mpg
assert _rc == 198 

xlincom (mpg)

* Test 3
xlincom (name=mpg)
xlincom ( name= mpg)
xlincom ( name= mpg)
xlincom (  name = mpg)
xlincom ( mpg)
xlincom ( mpg) ( weight)
xlincom (name = mpg) (name2 =  weight)
xlincom (      name    =    mpg    ) (   name2    =   weight    )
cap xlincom ((mpg - 2) / weight)
assert _rc == 131
xlincom ((mpg - 2) / 2)
cap xlincom ((mpg - 2) / 2), post
assert _rc == 198
xlincom (name1=(mpg - 2) / 2)
cap xlincom ((name1=mpg - 2) / 2)
assert _rc == 7
cap xlincom (name1 name2 = mpg)
assert _rc == 7
cap xlincom (1name1 = mpg)
assert _rc == 7
cap xlincom (name= (mpg)
assert _rc == 198
xlincom (name= (mpg))
xlincom ((mpg))
xlincom ((mpg + 2))
cap xlincom (mpg) (mpg
assert _rc == 198
cap xlincom (mpg) mpg
assert _rc == 198
cap xlincom (mpg) mpg)
assert _rc == 198

* Test 4
reg price mpg weight
xlincom (name= mpg) (weight * 2), post
xlincom
xlincom, level(90)
xlincom, level(90) eform(exp)
xlincom, level(90) or
cap xlincom, level(90) or eform(exp)
assert _rc == 198

* Test 5
qui reg price mpg weight
cap xlincom (name= mpg) (weight1 * 2), post
assert _rc == 111

qui reg price mpg weight
cap xlincom (name= mpg) (weight = weight1 * 2), post
assert _rc == 111

qui reg price mpg weight
cap xlincom (name= mpg) (_b[weight] * 2), post
assert _rc == 303

qui reg price mpg weight
cap xlincom (name= mpg) (name= mpg) (_b[weight] * 2), post
assert _rc == 303

qui reg price mpg weight
xlincom (name= mpg) (name= mpg) (_b[weight] * 2), post covzero

qui reg price mpg weight
xlincom (name= mpg) (name= mpg) (weight * 2), post 

qui reg price mpg weight
cap xlincom (mpg * (2+3)) (name= mpg) (weight * 2), post 
assert _rc == 198

qui reg price mpg weight
cap xlincom (name= mpg * (2+3)) (name= mpg) (weight * 2), post 
assert _rc == 198

** Syntax options
qui reg price mpg weight
xlincom (mpg)
xlincom (mpg), eform(or)
xlincom (mpg), or
cap xlincom (mpg), or hr
assert _rc == 198
xlincom (mpg), or nohead

// Functionality

* Test 1 REGRESS
webuse regress, clear

qui regress y x1 x2 x3
lincom x2-x1
scalar a = r(se)
xlincom (x2-x1)
mat B = r(table)
scalar b = B[2,1]
di reldif(a,b)
assert reldif(a,b) == 0

qui regress y x1 x2 x3
nlcom (_b[x2] - _b[x1]) (_b[x3] - _b[x2]), post
mat A = e(V)
qui regress y x1 x2 x3
xlincom (x2 - x1) (x3 - x2), post
mat B = e(V)
di mreldif(A,B)
assert mreldif(A, B) <1e-10

* Test 2
qui regress y x1 x2 x3
lincom 3*x1 + 500*x3
scalar a = r(se)
xlincom (3*x1 + 500*x3)
mat B = r(table)
scalar b = B[2,1]
di reldif(a,b)
assert reldif(a,b) == 0

qui regress y x1 x2 x3
nlcom (2 * _b[x2] - _b[x1] * 2 + 2) (_b[x3] / 1.5 - 2 * - _b[x2] - 2), post
mat A = e(V)
qui regress y x1 x2 x3
xlincom (2 * x2 - x1 * 2 + 2) (x3 / 1.5 - 2 * - x2 - 2), post
mat B = e(V)
di mreldif(A,B)
assert mreldif(A, B) <1e-10

* Test 3
qui regress y x1 x2 x3
lincom 3*x1 + 500*x3 - 12
scalar a = r(se)
xlincom (3*x1 + 500*x3 - 12)
mat B = r(table)
scalar b = B[2,1]
di reldif(a,b)
assert reldif(a,b) == 0

* Test 4 LOGIT
webuse lbw, clear
qui logit low age lwt i.race smoke ptl ht ui
lincom 2.race+smoke
scalar a = r(se)
xlincom (2.race+smoke)
mat B = r(table)
scalar b = B[2,1]
di reldif(scalar(a),scalar(b))
assert reldif(scalar(a),scalar(b)) == 0

qui logit low age lwt i.race smoke ptl ht ui
nlcom (_b[2.race]+_b[smoke]) (_b[3.race] - 1.5 * _b[ui]) (_b[3.race] - 1.5 * _b[ui]), post
mat A = e(V)
qui logit low age lwt i.race smoke ptl ht ui
xlincom (2.race+smoke) (3.race - 1.5 * ui) (3.race - 1.5 * ui), post
mat B = e(V)
di mreldif(A,B)
assert mreldif(A, B) <1e-10

* Test 5 LOGIT OR
qui logit low age lwt i.race smoke ptl ht ui
lincom 2.race+smoke, or
scalar a = r(se)
xlincom (2.race+smoke), or
mat B = r(table)
scalar b = B[2,1]
di reldif(scalar(a),scalar(b))
assert reldif(scalar(a),scalar(b)) == 0

* Test 6 LOGISTIC
qui logistic low age lwt i.race smoke ptl ht ui
lincom 2.race+smoke
scalar a = r(se)
xlincom (2.race+smoke)
mat B = r(table)
scalar b = B[2,1]
di reldif(scalar(a),scalar(b))
assert reldif(scalar(a),scalar(b)) == 0

* Test 7 MLOGIT
webuse sysdsn1, clear
qui mlogit insure age male nonwhite i.site
lincom [Prepaid]male + [Prepaid]nonwhite
scalar a = r(se)
xlincom ([Prepaid]male + [Prepaid]nonwhite)
mat B = r(table)
scalar b = B[2,1]
di reldif(scalar(a),scalar(b))
assert reldif(scalar(a),scalar(b)) == 0

* Test 8 SVY
webuse nhanes2f
svyset psuid [pweight=finalwgt], strata(stratid)
qui svy: regress zinc age age2 weight female black orace rural
nlcom (_b[age] + _b[age2]) (2 * _b[age] - _b[female] / 1.5 - 1), post
mat NL = e(V)
qui svy: regress zinc age age2 weight female black orace rural
xlincom (age + age2) (2 * age - female / 1.5 - 1), post
mat L = e(V)
di mreldif(NL, L)
assert mreldif(NL, L) <1e-10

qui svy: regress zinc age age2 weight female black orace rural
nlcom (_b[age] + _b[age2]) (2 * _b[age] - _b[female] / 1.5 - 1) (2 * _b[black] - _b[rural] + 1 / 1.5 - 1), post
mat NL = e(V)
qui svy: regress zinc age age2 weight female black orace rural
xlincom (age + age2) (2 * age - female / 1.5 - 1) (2 * black - rural + 1 / 1.5 - 1), post
mat L = e(V)
di mreldif(NL, L)
assert mreldif(NL, L) <1e-10

* Test 9 SUREG
sysuse auto
sureg (price foreign weight length) (mpg foreign weight) (displ foreign weight)
nlcom _b[price:foreign] + 2, post
mat NL = e(V)
qui sureg (price foreign weight length) (mpg foreign weight) (displ foreign weight)
xlincom (price:foreign + 2), post
mat L = e(V)
di mreldif(NL, L)
assert mreldif(NL, L) <1e-10

sureg (price foreign weight length) (mpg foreign weight) (displ foreign weight)
nlcom (-_b[price:foreign] / 2 + 2) (-_b[price:foreign] / -2 + 2) (-_b[mpg:_cons] + _b[displacement:weight] / 1.5), post
mat NL = e(V)
qui sureg (price foreign weight length) (mpg foreign weight) (displ foreign weight)
xlincom (-price:foreign / 2 + 2) (name=-price:foreign / -2 + 2) (-mpg:_cons + displacement:weight / 1.5), post
mat L = e(V)
di mreldif(NL, L)
assert mreldif(NL, L) <1e-10

* Test 10 parser
sysuse auto
qui reg price mpg weight length
xlincom (mpg) (mpg + weight) (mpg - weight) (-mpg + weight) (-mpg - weight) ///
	    (-mpg * 2) (-mpg * - 2) (mpg * 2) (mpg * + 2) (mpg / 2) (-mpg / 2) (-mpg / -2) ///
		(2 * mpg) (-2 * mpg) (2 * - mpg) (-2 * - mpg), post
mat A = e(V)

qui reg price mpg weight length
nlcom (_b[mpg]) (_b[mpg] + _b[weight]) (_b[mpg] - _b[weight]) (-_b[mpg] + _b[weight]) (-_b[mpg] - _b[weight]) ///
	    (-_b[mpg] * 2) (-_b[mpg] * - 2) (_b[mpg] * 2) (_b[mpg] * + 2) (_b[mpg] / 2) (-_b[mpg] / 2) (-_b[mpg] / -2) ///
		(2 * _b[mpg]) (-2 * _b[mpg]) (2 * - _b[mpg]) (-2 * - _b[mpg]), post
mat B = e(V)
di mreldif(A, B)
assert mreldif(A, B) <1e-10

* Test 11 predict
qui reg price mpg weight length
xlincom (mpg), post
cap predict
assert _rc == 498

di "All tests passed"
