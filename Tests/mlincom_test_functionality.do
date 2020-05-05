discard
** TESTS **
clear all

// Syntax

** Syntax equations
* Test 1
cap mlincom
assert _rc == 301

* Test 2
sysuse auto
reg price mpg weight

cap mlincom mpg
assert _rc == 198 

mlincom (mpg)

* Test 3

mlincom ((name) mpg)
mlincom ( (name) mpg)
mlincom (( name) mpg)
mlincom ( ( name ) mpg)
cap mlincom ((name) (mpg)
assert _rc == 198
mlincom ((name) (mpg))
cap mlincom ((mpg))
assert _rc == 198
cap mlincom ((mpg + 2))
assert _rc == 7
cap mlincom (mpg) (mpg
assert _rc == 198
cap mlincom (mpg) mpg
assert _rc == 198
cap mlincom (mpg) mpg)
assert _rc == 198

* Test 4
reg price mpg weight
mlincom ((name) mpg) (weight * 2), post
mlincom
mlincom, level(90)
mlincom, level(90) eform(exp)
mlincom, level(90) or
cap mlincom, level(90) or eform(exp)
assert _rc == 198

* Test 5
qui reg price mpg weight
cap mlincom ((name) mpg) (weight1 * 2), post
assert _rc == 111

qui reg price mpg weight
cap mlincom ((name) mpg) (_b[weight] * 2), post
assert _rc == 303

qui reg price mpg weight
cap mlincom ((name) mpg) ((name) mpg) (_b[weight] * 2), post
assert _rc == 303

qui reg price mpg weight
mlincom ((name) mpg) ((name) mpg) (_b[weight] * 2), post covzero

qui reg price mpg weight
mlincom ((name) mpg) ((name) mpg) (weight * 2), post 

** Syntax options
qui reg price mpg weight
mlincom (mpg)
mlincom (mpg), eform(or)
mlincom (mpg), or
cap mlincom (mpg), or hr
assert _rc == 198
mlincom (mpg), or nohead

// Functionality

* Test 1 REGRESS
webuse regress, clear

qui regress y x1 x2 x3
lincom x2-x1
scalar a = r(se)
mlincom (x2-x1)
mat B = r(table)
scalar b = B[2,1]
di reldif(a,b)
assert reldif(a,b) == 0

qui regress y x1 x2 x3
nlcom (_b[x2] - _b[x1]) (_b[x3] - _b[x2]), post
mat A = e(V)
qui regress y x1 x2 x3
mlincom (x2 - x1) (x3 - x2), post
mat B = e(V)
di mreldif(A,B)
assert mreldif(A, B) <1e-10

* Test 2
qui regress y x1 x2 x3
lincom 3*x1 + 500*x3
scalar a = r(se)
mlincom (3*x1 + 500*x3)
mat B = r(table)
scalar b = B[2,1]
di reldif(a,b)
assert reldif(a,b) == 0

qui regress y x1 x2 x3
nlcom (2 * _b[x2] - _b[x1] * 2 + 2) (_b[x3] / 1.5 - 2 * - _b[x2] - 2), post
mat A = e(V)
qui regress y x1 x2 x3
mlincom (2 * x2 - x1 * 2 + 2) (x3 / 1.5 - 2 * - x2 - 2), post
mat B = e(V)
di mreldif(A,B)
assert mreldif(A, B) <1e-10

* Test 3
qui regress y x1 x2 x3
lincom 3*x1 + 500*x3 - 12
scalar a = r(se)
mlincom (3*x1 + 500*x3 - 12)
mat B = r(table)
scalar b = B[2,1]
di reldif(a,b)
assert reldif(a,b) == 0

* Test 4 LOGIT
webuse lbw, clear
qui logit low age lwt i.race smoke ptl ht ui
lincom 2.race+smoke
scalar a = r(se)
mlincom (2.race+smoke)
mat B = r(table)
scalar b = B[2,1]
di reldif(scalar(a),scalar(b))
assert reldif(scalar(a),scalar(b)) == 0

qui logit low age lwt i.race smoke ptl ht ui
nlcom (_b[2.race]+_b[smoke]) (_b[3.race] - 1.5 * _b[ui]) (_b[3.race] - 1.5 * _b[ui]), post
mat A = e(V)
qui logit low age lwt i.race smoke ptl ht ui
mlincom (2.race+smoke) (3.race - 1.5 * ui) (3.race - 1.5 * ui), post
mat B = e(V)
di mreldif(A,B)
assert mreldif(A, B) <1e-10

* Test 5 LOGIT OR
qui logit low age lwt i.race smoke ptl ht ui
lincom 2.race+smoke, or
scalar a = r(se)
mlincom (2.race+smoke), or
mat B = r(table)
scalar b = B[2,1]
di reldif(scalar(a),scalar(b))
assert reldif(scalar(a),scalar(b)) == 0

* Test 6 LOGISTIC
qui logistic low age lwt i.race smoke ptl ht ui
lincom 2.race+smoke
scalar a = r(se)
mlincom (2.race+smoke)
mat B = r(table)
scalar b = B[2,1]
di reldif(scalar(a),scalar(b))
assert reldif(scalar(a),scalar(b)) == 0

* Test 7 MLOGIT
webuse sysdsn1, clear
qui mlogit insure age male nonwhite i.site
lincom [Prepaid]male + [Prepaid]nonwhite
scalar a = r(se)
mlincom ([Prepaid]male + [Prepaid]nonwhite)
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
mlincom (age + age2) (2 * age - female / 1.5 - 1), post
mat L = e(V)
di mreldif(NL, L)
assert mreldif(NL, L) <1e-10

qui svy: regress zinc age age2 weight female black orace rural
nlcom (_b[age] + _b[age2]) (2 * _b[age] - _b[female] / 1.5 - 1) (2 * _b[black] - _b[rural] + 1 / 1.5 - 1), post
mat NL = e(V)
qui svy: regress zinc age age2 weight female black orace rural
mlincom (age + age2) (2 * age - female / 1.5 - 1) (2 * black - rural + 1 / 1.5 - 1), post
mat L = e(V)
di mreldif(NL, L)
assert mreldif(NL, L) <1e-10

* Test 9 SUREG
sysuse auto
sureg (price foreign weight length) (mpg foreign weight) (displ foreign weight)
nlcom _b[price:foreign] + 2, post
mat NL = e(V)
qui sureg (price foreign weight length) (mpg foreign weight) (displ foreign weight)
mlincom (price:foreign + 2), post
mat L = e(V)
di mreldif(NL, L)
assert mreldif(NL, L) <1e-10

sureg (price foreign weight length) (mpg foreign weight) (displ foreign weight)
nlcom (-_b[price:foreign] / 2 + 2) (-_b[price:foreign] / -2 + 2) (-_b[mpg:_cons] + _b[displacement:weight] / 1.5), post
mat NL = e(V)
qui sureg (price foreign weight length) (mpg foreign weight) (displ foreign weight)
mlincom (-price:foreign / 2 + 2) ((name)-price:foreign / -2 + 2) (-mpg:_cons + displacement:weight / 1.5), post
mat L = e(V)
di mreldif(NL, L)
assert mreldif(NL, L) <1e-10

* Test 10 parser
sysuse auto
qui reg price mpg weight length
mlincom (mpg) (mpg + weight) (mpg - weight) (-mpg + weight) (-mpg - weight) ///
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
mlincom (mpg), post
cap predict
assert _rc == 498

di "All tests passed"
