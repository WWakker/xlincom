*********************************
** XLINCOM FUNCTIONALITY TESTS **
*********************************

discard
clear all

// Syntax

** Syntax equations
* Test 1
cap noisily xlincom
assert _rc == 301

* Test 2
sysuse auto
reg price mpg weight

xlincom mpg
xlincom (mpg)
cap noisily xlincom mpg mpg
assert _rc == 111

* Test 3
xlincom name=mpg
xlincom (name=mpg)
xlincom  name= mpg
xlincom ( name= mpg)
xlincom  name= mpg
xlincom ( name= mpg)
xlincom   name = mpg
xlincom (  name = mpg)
xlincom ( mpg)
xlincom ( mpg) ( weight)
cap noisily xlincom name = mpg (name2 =  weight)
assert _rc == 133
cap noisily xlincom name = mpg) (name2 =  weight)
assert _rc == 198
cap noisily xlincom (name = mpg) name2 =  weight
assert _rc == 198
cap noisily xlincom name = mpg name2 =  weight)
assert _rc == 198
cap noisily xlincom name = mpg (name2 =  weight
assert _rc == 198
cap noisily xlincom name = mpg name2 =  weight
assert _rc == 198
xlincom (name = mpg) (name2 =  weight)
xlincom (      name    =    mpg    ) (   name2    =   weight    )
cap noisily xlincom ((mpg - 2) / weight)
assert _rc == 131
xlincom ((mpg - 2) / 2)
xlincom (name1=(mpg - 2) / 2)
cap noisily xlincom ((name1=mpg - 2) / 2)
assert _rc == 7
cap noisily xlincom name = mpg = weight
assert _rc == 198
cap noisily xlincom (name1 name2 = mpg)
assert _rc == 7
cap noisily xlincom (1name1 = mpg)
assert _rc == 7
cap noisily xlincom (name= (mpg)
assert _rc == 198
xlincom (name= (mpg))
xlincom ((mpg))
xlincom ((mpg + 2))
cap noisily xlincom (mpg) (mpg
assert _rc == 198
cap noisily xlincom (mpg) mpg
assert _rc == 198
cap noisily xlincom (mpg) mpg)
assert _rc == 198

qui reg price mpg weight
xlincom name = mpg + (weight), post

qui reg price mpg weight
xlincom (name = mpg + (weight)), post

qui reg price mpg weight
cap noisily xlincom (name = mpg + (weight)) (mpg), post
assert _rc == 198

qui reg price mpg weight
cap noisily xlincom (name = mpg + (weight)) mpg, post
assert _rc == 198

qui reg price mpg weight
xlincom (name = mpg + (weight)) (mpg), post covzero
mat A = e(V)
qui reg price mpg weight
xlincom (name = mpg + weight) (mpg), post
mat B = e(V)
di mreldif(A, B)

qui reg price mpg weight
nlcom (_b[mpg] + _b[weight]) (_b[mpg]), post
mat C = e(V)
di mreldif(B, C)
assert mreldif(B, C) < 1e-10

* Test 4
reg price mpg weight
xlincom (name= mpg) (weight * 2), post nopvalues
xlincom
xlincom, level(90)
xlincom, level(90) eform
xlincom, level(90) or
cap noisily xlincom, level(90) hello
assert _rc == 198
xlincom, level(90) nopvalues
cap noisily xlincom, level(90) or eform(exp)
assert _rc == 198

* Test 5
qui reg price mpg weight
cap noisily xlincom (name= mpg) (weight1 * 2), post
assert _rc == 111

qui reg price mpg weight
cap noisily xlincom (name= mpg) (weight = weight1 * 2), post
assert _rc == 111

qui reg price mpg weight
cap noisily xlincom (name= mpg) (_b[weight] * 2), post
assert _rc == 303

qui reg price mpg weight
cap noisily xlincom (name= mpg) (name= mpg) (_b[weight] * 2), post
assert _rc == 303

qui reg price mpg weight
xlincom (name= mpg) (name= mpg) (_b[weight] * 2), post covzero

qui reg price mpg weight
xlincom (name= mpg) (name= mpg) (weight * 2), post 

qui reg price mpg weight
cap noisily xlincom (mpg * (2+3)) (name= mpg) (weight * 2), post 
assert _rc == 198

qui reg price mpg weight
cap noisily xlincom (name= mpg * (2+3)) (name= mpg) (weight * 2), post 
assert _rc == 198

** Syntax options
qui reg price mpg weight
xlincom (mpg)
xlincom (mpg), eform
xlincom (mpg), or
cap noisily xlincom (mpg), or hr
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

sureg (price foreign weight length) (mpg foreign weight)
xlincom (price:foreign - mpg:foreign) (price: foreign + mpg: foreign) , post
mat L = e(V)
sureg (price foreign weight length) (mpg foreign weight)
nlcom (_b[price: foreign] - _b[mpg:foreign]) (_b[price: foreign] + _b[mpg: foreign]), post
mat NL = e(V)
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
cap noisily predict
assert _rc == 498

* Test 11 make sure xlincom accepts anything lincom accepts
qui sureg (price foreign weight length) (mpg foreign weight)

lincom [price]foreign * (2 + 2) + [mpg]foreign / 3
xlincom ([price]foreign * (2 + 2) + [mpg]foreign / 3)

lincom [price]:foreign * (2 + 2) + [mpg]:foreign / 3
xlincom ([price]:foreign * (2 + 2) + [mpg]:foreign / 3)

lincom _b[price:foreign] * (2 + 2) + _b[mpg:foreign] / 3
xlincom (_b[price:foreign] * (2 + 2) + _b[mpg:foreign] / 3)

lincom [price]_b[foreign] * (2 + 2) + [mpg]_b[foreign] / 3
xlincom ([price]_b[foreign] * (2 + 2) + [mpg]_b[foreign] / 3)

lincom [#1]_b[foreign] * (2 + 2) + [#2]_b[foreign] / 3
xlincom ([#1]_b[foreign] * (2 + 2) + [#2]_b[foreign] / 3)

xlincom (price:foreign * (2 + 2) + mpg:foreign / 3)
xlincom (price: foreign * (2 + 2) + mpg :foreign / 3)

xlincom ([price]foreign * (2 + 2) + [mpg]foreign / 3), post

qui sureg (price foreign weight length) (mpg foreign weight)
cap noisily xlincom ([price]foreign * (2 + 2) + [mpg]foreign / 3) ([mpg]foreign), post
assert _rc == 198
cap noisily xlincom ([price]foreign * 4 + [mpg]foreign / 3) ([mpg]foreign), post
assert _rc == 303

xlincom (price:foreign * 4 + mpg:foreign / 3), post

qui sureg (price foreign weight length) (mpg foreign weight)
xlincom ( price:foreign * 4 + mpg: foreign / 3 ), post

qui sureg (price foreign weight length) (mpg foreign weight)
xlincom ( price:foreign * 4 + mpg: foreign / 3 ) ( 2 + price:foreign * 4 + mpg: weight / 3 ) (price:_cons / 2 - 3*mpg:_cons), post
mat L = e(V)
qui sureg (price foreign weight length) (mpg foreign weight)
nlcom ( _b[price:foreign] * 4 + _b[mpg: foreign] / 3 ) ( 2 + _b[price:foreign] * 4 + _b[mpg: weight] / 3 ) (_b[price:_cons] / 2 - 3*_b[mpg:_cons]), post
mat NL = e(V)
mat l L
mat l NL
di mreldif(NL, L)
assert mreldif(NL, L) <1e-10

qui sureg (price foreign weight length) (mpg foreign weight)
xlincom (_b[price:foreign] * 4 + _b[mpg:foreign] / 3), post

qui sureg (price foreign weight length) (mpg foreign weight)
cap noisily xlincom (_b[price:foreign] * 4 + _b[mpg:foreign] / 3) (price:foreign), post
assert _rc == 303

qui sureg (price foreign weight length) (mpg foreign weight)
cap noisily xlincom ([price]foreign * 4 + _b[mpg:] / 3) (price:foreign), post 
assert _rc == 303

qui sureg (price foreign weight length) (mpg foreign weight)
cap noisily xlincom (price:foreign * 4 + _b[mpg:] / 3) (price:foreign), post 
assert _rc == 303

qui sureg (price foreign weight length) (mpg foreign weight)
cap noisily xlincom (price * 4 + _b[mpg] / 3) (price:foreign), post 
assert _rc == 111

qui sureg (price foreign weight length) (mpg foreign weight)
xlincom (price:foreign * (2+2) + mpg:foreign / 3) (price:foreign), post covzero

qui sureg (price foreign weight length) (mpg foreign weight)
cap noisily xlincom (price:foreign * (2+2) + mpg:foreign / 3) (price:foreign), post
assert _rc == 198

qui sureg (price foreign weight length) (mpg foreign weight)
xlincom ((price:foreign + price:weight) * 2), post covzero

// Estadd unit tests
sysuse auto, clear
reg price mpg weight headroom
xlincom mpg, estadd()
cap noisily xlincom mpg, estadd(stars)
assert _rc == 198
cap noisily xlincom mpg, estadd(star, brackets parentheses)
assert _rc == 198
cap noisily xlincom mpg, estadd(star, fmt(wrongformat))
assert _rc == 7
cap noisily xlincom mpg, estadd(star, fmt(%4.3f) bfmt(%4.3f))
assert _rc == 198
xlincom mpg, estadd(nostar, se t brackets)
assert strpos("`e(se_lc_1)'", "[") == 1
assert strpos("`e(t_lc_1)'", "[") == 1
xlincom mpg, estadd(nostar, se t parentheses)
assert strpos("`e(se_lc_1)'", "(") == 1
assert strpos("`e(t_lc_1)'", ")") > 1
xlincom mpg, estadd(nostar, parentheses fmt(%4.3f))
xlincom mpg, level(90) estadd(nostar, se t p ci parentheses bfmt(%5.4f) sefmt(%4.3f) tfmt(%4.2f) pfmt(%4.2f) cifmt(%4.1f))
xlincom (mpg + weight) (mpg) (headroom), estadd(nostar, se t parentheses bfmt(%5.4f) sefmt(%4.3f) tfmt(%4.2f))
xlincom mpg, estadd(nostar)
confirm number `e(b_lc_1)'
xlincom name=mpg, estadd(nostar)
confirm number `e(b_name)'
cap noisily xlincom name=mpg, estadd(, se)
assert _rc == 100

// Starlevels suboption
discard
reg price mpg weight headroom
xlincom name=weight, estadd(star, se t)
xlincom weight, estadd(nostar, se t par)
xlincom (weight) (mpg) (headroom), estadd(star, se t par starlevels(* 1 "" .1))
cap noisily xlincom (weight) (mpg) (headroom), estadd(star, se t par starlevels(* 1 "" .1 ""))
assert _rc == 198
cap noisily xlincom (weight) (mpg) (headroom), estadd(star, se t par starlevels(* 1 2 .1))
assert _rc == 198
cap noisily xlincom (weight) (mpg) (headroom), estadd(star, se t par starlevels(*** 0.01 ** .1))
assert _rc == 198
cap noisily xlincom (weight) (mpg) (headroom), estadd(star, se t par starlevels(*** "string" ** .1))
assert _rc == 7

reg price mpg weight headroom
xlincom (mpg=mpg) (weight=weight) (headroom=headroom), estadd(star, se t ci par starlevels(* .1 ** .05 *** .01) cifmt(%2.1f))
esttab, starlevels(* .1 ** .05 *** .01) stats(b_mpg ci_mpg _ b_weight ci_weight _ b_headroom ci_headroom)

reg price i.foreign mpg
xlincom (price_dom = _cons) (price_for = _cons + 1.foreign), estadd(star, se par bfmt(%4.1f) sefmt(%4.2f) starlevels(* .1 ** .05 *** .01))
esttab, stats(b_price_dom se_price_dom _ b_price_for se_price_for ,star(r2_a)) starlevels(* .1 ** .05 *** .01)

// Repost
sysuse auto, clear
qui reg price mpg weight headroom i.foreign i.rep78

cap noisily xlincom mpg, post repost
assert _rc == 198

qui reg price mpg weight
cap noisily xlincom name = mpg + (weight), repost
assert _rc == 198

qui reg price mpg weight
xlincom (name = mpg + weight) , repost

qui reg price mpg weight
cap noisily xlincom (name = mpg + (weight)) (mpg), repost
assert _rc == 198

qui reg price mpg weight
cap noisily xlincom (name = mpg + (weight)) mpg, repost
assert _rc == 198

qui reg price mpg weight
xlincom (name = mpg + (weight)) (mpg), repost covzero
mat A = e(V)
qui reg price mpg weight
xlincom (name = mpg + weight) (mpg), repost
mat B = e(V)
di mreldif(A, B)

qui reg price mpg weight
nlcom (_b[mpg] + _b[weight]) (_b[mpg]), post
mat C = e(V)
mat l B
mat l C

webuse lbw, clear
qui logit low age lwt i.race smoke ptl ht ui
nlcom (_b[2.race]+_b[smoke]) (_b[3.race] - 1.5 * _b[ui]) (_b[3.race] - 1.5 * _b[ui]), post
mat A = e(V)
qui logit low age lwt i.race smoke ptl ht ui
xlincom (2.race+smoke) (3.race - 1.5 * ui) (3.race - 1.5 * ui), post
mat B = e(V)
di mreldif(A,B)
assert mreldif(A, B) <1e-10
logit low age lwt i.race smoke ptl ht ui
xlincom (2.race+smoke) (3.race - 1.5 * ui) (3.race - 1.5 * ui), repost
mat C = e(V)
mat l A
mat l C

webuse nhanes2f
svyset psuid [pweight=finalwgt], strata(stratid)
qui svy: regress zinc age age2 weight female black orace rural
nlcom (_b[age] + _b[age2]) (2 * _b[age] - _b[female] / 1.5 - 1) (2 * _b[black] - _b[rural] + 1 / 1.5 - 1), post
mat NL = e(V)
svy: regress zinc age age2 weight female black orace rural
xlincom (age + age2) (2 * age - female / 1.5 - 1) (2 * black - rural + 1 / 1.5 - 1), repost
mat L = e(V)
mat l NL
mat l L

sysuse auto
sureg (price foreign weight length) (mpg foreign weight) (displ foreign weight)
nlcom (-_b[price:foreign] / 2 + 2) (-_b[price:foreign] / -2 + 2) (-_b[mpg:_cons] + _b[displacement:weight] / 1.5), post
mat NL = e(V)
qui sureg (price foreign weight length) (mpg foreign weight) (displ foreign weight)
xlincom (-price:foreign / 2 + 2) (name=-price:foreign / -2 + 2) (-mpg:_cons + displacement:weight / 1.5), repost 
mat L = e(V)
mat l NL
mat l L

qui reg price mpg weight headroom i.foreign i.rep78
qui xlincom (mpg) (mpg + weight) (mpg - weight) (2 * mpg - weight) (2 - 1.foreign) (1.foreign / 2 + 2), repost
mat A = e(V)

qui reg price mpg weight headroom i.foreign i.rep78
test (mpg = 0) (weight = 0) (headroom = 0) (0b.foreign = 0) (1.foreign = 0) (1b.rep78 = 0) (2.rep78 = 0) (3.rep78 = 0) (4.rep78 = 0) (5.rep78 = 0) (_cons = 0) (mpg = 0) (mpg + weight = 0) (mpg - weight = 0) (2 * mpg - weight = 0) (2 - 1.foreign = 0) (1.foreign / 2 + 2 = 0),  matvlc(B)
di mreldif(A, B)
assert mreldif(A, B) <1e-10

webuse gxmpl1
reg gnp L(0/2).cpi
xlincom (t = cpi) (t1 = cpi + l1.cpi) (t2 = cpi + l1.cpi + l2.cpi), repost
esttab, eqlab("Main" "Sum of coefficients", span)

sysuse auto
reg price mpg foreign
xlincom mpg + foreign, repost
cap noisily xlincom mpg + foreign, repost
assert _rc == 198

di "All tests passed"
