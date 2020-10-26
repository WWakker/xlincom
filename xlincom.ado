*! 1.1.2                08jul2020
*! Wouter Wakker        wouter.wakker@outlook.com

* 1.1.2     25oct2020   up to two digits in level option allowed
* 1.1.1     21oct2020   allow eqno:coef syntax
* 1.1.0     08jul2020   name specification syntax change (name) --> name=
* 1.0.4     30jun2020   aesthetic changes
* 1.0.3     26jun2020   name change mlincom --> xlincom
* 1.0.2     09jun2020   proper error code when parentheses found in equation
* 1.0.1     07may2020   if statements for display options run slightly faster
* 1.0.0     05may2020   born

program xlincom, eclass
	version 8

	if replay() {
		if "`e(cmd)'" != "xlincom" error 301
		
		syntax [, EForm(string)           ///
		          OR                      ///
		          HR                      ///
		          SHR                     ///
		          IRr                     ///
		          RRr                     ///
		          Level(cilevel)          ///
		          ]
		
		// Only one display option allowed
		local eformopt : word count `eform' `or' `hr' `shr' `irr' `rrr' 
		if `eformopt' > 1 {
				di as error "only one display option can be specified"
				exit 198
		}
	}
	else {
		syntax anything [, EForm(string)           ///
		                   OR                      ///
		                   HR                      ///
		                   SHR                     ///
		                   IRr                     ///
		                   RRr                     ///
		                   Level(cilevel)          ///
		                   DF(numlist max=1 >0)    ///
		                   POST                    ///
		                   COVZERO                 ///
		                   noHEADer                ///
		                   ]
		
		// Only one display option allowed
		local eformopt : word count `eform' `or' `hr' `shr' `irr' `rrr' 
		if `eformopt' > 1 {
				di as error "only one display option can be specified"
				exit 198
		}
		
		// Header option
		if "`header'" != "" local dont *
		
		// Parse input, must be within parentheses,
		// return list of "[name=] equation" and number of equations
		xlincom_check_parentheses `anything'
		local name_eq_list "`s(name_eq_list)'"
		local n_lc = s(n_lc)
			
		// Store e(V) matrix
		tempname eV
		mat `eV' = e(V)
		local rownames : rowfullnames `eV'
		local n_eV = rowsof(`eV')
		
		// Extract estimation output (code based on Roger Newson's lincomest.ado)
		local depname = e(depvar)
		tempvar esample
		local obs = e(N)
		if "`df'" == "" local dof = e(df_r)
		else local dof = `df' 
		gen byte `esample' = e(sample)
		
		// Define tempnames and matrices for results
		tempname estimate se variance beta vcov
		mat def `beta' = J(1, `n_lc',0)
		mat def `vcov' = J(`n_lc',`n_lc',0)	
		
		`dont' di
		
		// Start execution
		local i 1
		foreach name_eq of local name_eq_list {
			xlincom_parse_name_eq `"`name_eq'"' `i'
			local eq_names "`eq_names' `s(eq_name)'"
			local name "`s(eq_name)'"
			local eq "`s(eq)'"
			
			xlincom_parse_eq_for_test "`eq'" "`post'" "`covzero'"
			qui lincom `s(eq_for_test)', level(`level') df(`df')
			
			`dont' di as txt %13s abbrev("`name':",13)  _column(16) as res "`eq' = 0"

			scalar `estimate' = r(estimate)
			scalar `se' = r(se)
			
			// Calculate transform se and var if previous command is logistic (from Roger Newson's lincomest.ado)
			if "`e(cmd)'" == "logistic" {
				scalar `se' = `se' / `estimate'
				scalar `estimate' = log(`estimate')
				if `"`eform'"' == "" local eform "Odds Ratio"
			}
			
			scalar `variance' = `se' * `se'
			mat `beta'[1, `i'] = `estimate'
			mat `vcov'[`i', `i'] = `variance'
			
			// Get column vectors for covariance calculations
			if "`post'" != "" & "`covzero'" == "" & `n_lc' > 1 {
				xlincom_get_eq_vector `"`eq'"' `"`rownames'"' `n_eV'
				tempname c`i'
				mat `c`i'' = r(eq_vector)
			}
			
			local ++i
		}
		
		// Fill VCOV matrix with covariances
		if "`post'" != "" & "`covzero'" == "" & `n_lc' > 1 {
			forval i = 1 / `n_lc' {
				forval j = 1 / `n_lc' {
					if `i' != `j' mat `vcov'[`i',`j'] = `c`i''' * `eV' * `c`j''
				}
			}	
		}
			
		// Name rows/cols matrices
		mat rownames `beta' = y1
		mat colnames `beta' = `eq_names'
		mat rownames `vcov' = `eq_names'
		mat colnames `vcov' = `eq_names'
	}
	
	// Eform options 
	if `"`eform'"' == "" {
		if "`or'" != "" local eform "Odds Ratio"
		else if "`hr'" != "" local eform "Haz. Ratio"
		else if "`shr'" != "" local eform "SHR"
		else if "`irr'" != "" local eform "IRR"
		else if "`rrr'" != "" local eform "RRR"
	}
	
	di
	
	// Display and post results
	if "`post'" != "" {
		ereturn post `beta' `vcov' , depname("`depname'") obs(`obs') dof(`dof') esample(`esample')
		ereturn local cmd "xlincom"
		ereturn local predict "xlincom_p"
		ereturn display, eform(`eform') level(`level')
	}
	else if replay() ereturn display, eform(`eform') level(`level')
	else {
		tempname hold
		nobreak {
			_estimates hold `hold'
			capture noisily break {
				ereturn post `beta' `vcov' , depname("`depname'") obs(`obs') dof(`dof') esample(`esample')
				ereturn local cmd "xlincom"
				ereturn display, eform(`eform') level(`level')
			}
			local rc = _rc
			_estimates unhold `hold'
			if `rc' exit `rc'
		}
	}
end

// Check if parentheses are properly specified
program xlincom_check_parentheses, sclass
	version 8
	
	local n_lc 0
	gettoken first : 0, parse(" (")
	if `"`first'"' == "(" { 
		while `"`first'"' != "" {
			local ++n_lc
			gettoken first 0 : 0, parse(" (") match(paren)
			local first `first'
			local name_eq_list `"`name_eq_list' `"`first'"'"'
			gettoken first : 0, parse(" (")
			if !inlist(`"`first'"', "(", "") {
				di as error "equation must be contained within parentheses"
				exit 198
			}
		}
	}
	else {
		di as error "equation must be contained within parentheses"
		exit 198
	}
	
	sreturn local name_eq_list "`name_eq_list'"
	sreturn local n_lc = `n_lc'
end

// Parse name/eq expressions
// Return name and equation
program xlincom_parse_name_eq, sclass
	version 8
	args name_eq n
	
	gettoken first eq : name_eq, parse("=")
	if "`first'" != "`name_eq'" {
		if "`first'" != "=" {
			local wc : word count `first'
			if `wc' > 1 {
				di as error "{bf:`first'} invalid name"
				exit 7
			}
			confirm names `first'
			local eq_name `first'
			gettoken equalsign eq : eq, parse("=")
		}
		else local eq_name lc_`n'
	}
	else {
		local eq_name lc_`n'
		local eq `name_eq'
	}
	
	sreturn local eq_name `eq_name'
	sreturn local eq `eq'
end	

// Parse equations, look for multiple equation expressions
// Return equation that is accepted by test
program xlincom_parse_eq_for_test, sclass
	version 8
	args eq post covzero
	
	if "`post'" != "" & "`covzero'" == "" {
		gettoken first rest : eq , parse("()")
		if `"`first'"' != `"`eq'"' {
			di as error "parentheses not allowed in equation"
			exit 198
		}
	}
	gettoken first rest : eq , parse(":")
	if `"`first'"' == `"`eq'"' local eq_for_test `"`eq'"'
	else {
		tokenize `"`eq'"', parse(":+-/*()")
		local i 1
		local 0
		while "``i''" != "" {
			local `i' = strtrim("``i''")
			if inlist("``i''", "*", "/", "+", "-", "(", ")") local eq_for_test `"`eq_for_test' ``i''"'
			else if "``=`i'+1''" == ":" & !strpos("``i''", "[") local eq_for_test `"`eq_for_test' [``i'']"'
			else if "``=`i'-1''" == ":" local eq_for_test `"`eq_for_test'``i''"'
			else if "``i''" != ":" & !strpos("``=`i'-1''", "[") local eq_for_test `"`eq_for_test' ``i''"'
			else if !strpos("``=`i'-1''", "]") & strpos("``=`i'-1''", "[") local eq_for_test `"`eq_for_test':"'
			local ++i
		}
	}
	
	sreturn local eq_for_test `eq_for_test'
end


// Parse equation when post option is specified
// Return matrix for covariance calculations
program xlincom_get_eq_vector, rclass
	version 8
	args eq rownames n
	
	tempname A
	mat `A' = J(`n',1,0)
	mat rownames `A' = `rownames'
	tokenize `eq', parse("+-*/")
	local 0
	local i 1
	while "``i''" != "" {
		local `i' = strtrim("``i''")
		cap confirm number ``i''
		if _rc {
			if inlist("``i''", "+", "-") {
				if inlist("``=`i'+1''", "-", "+") { 
					di as error "++, --, +-, -+ not allowed"
					exit 198
				}
			}
			else if inlist("``i''", "*", "/") {
				 if inlist("``=`i'+2''", "*", "/") | inlist("``=`i'+3''", "*", "/") { 
					di as error "maximum number of multiplications/divisions per estimate = 1"
					exit 198
				}
			}
			else if rownumb(`A',"``i''") == . {
				di as error "{bf:``i''} not found in matrix e(V)"
				exit 303
			}
			else { // If parameter in e(V)
				if inlist("``=`i'-1''", "+", "-", "") { 
					if inlist("``=`i'+1''", "+", "-", "") {
						if "``=`i'-1''" == "-" {
							if "``=`i'-2''" == "*" {
								if "``=`i'-4''" == "-" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + ``=`i'-3''
								else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - ``=`i'-3''
							}
							else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - 1
						}
						else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + 1
					}
					else if inlist("``=`i'+1''", "*", "/") {
						if "``=`i'+1''" == "*" {
							if "``=`i'-1''" == "-" {
								if "``=`i'+2''" == "-" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + ``=`i'+3''
								else if "``=`i'+2''" == "+" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - ``=`i'+3''
								else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - ``=`i'+2''
							}
							else {
								if "``=`i'+2''" == "-" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - ``=`i'+3''
								else if "``=`i'+2''" == "+" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + ``=`i'+3''
								else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + ``=`i'+2''
							}
						}
						else if "``=`i'+1''" == "/" {
							if "``=`i'-1''" == "-" {
								if "``=`i'+2''" == "-" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + 1 / ``=`i'+3''
								else if "``=`i'+2''" == "+" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - 1 / ``=`i'+3''
								else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - 1 / ``=`i'+2''
							}
							else {
								if "``=`i'+2''" == "-" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - 1 / ``=`i'+3''
								else if "``=`i'+2''" == "+" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + 1 / ``=`i'+3''
								else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + 1 / ``=`i'+2''
							}
						}
					}
				}
				else if "``=`i'-1''" == "*" {
					if "``=`i'-3''" == "-" mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] - ``=`i'-2''
					else mat `A'[rownumb(`A',"``i''"),1] = `A'[rownumb(`A',"``i''"),1] + ``=`i'-2''
				}
			}				
		}
		local ++i
	}
	
	return matrix eq_vector = `A'
end
