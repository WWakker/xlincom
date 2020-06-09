# mlincom

## Description
`mlincom` computes point estimates, standard errors, t or z statistics, p-values, and confidence intervals for multiple linear combinations of coefficients as well as their covariances. `nlcom` is also able to do this, but `mlincom` is much faster (up to 300 times for complex models). `mlincom` internally calls `lincom` for each linear combination and extracts estimates and variances from its output. It has an optional `post` option to post estimation results for subsequent testing or exporting with pretty table commands. 

## Installation
To install from SSC, type in Stata:
```Stata
ssc install mlincom, replace
```

To install from GitHub, type in Stata:
```Stata
net install mlincom, from(https://raw.githubusercontent.com/WWakker/mlincom/master/) replace
```

## Requirements
* Stata 8 or higher
