*******************************************************
* Replication: Belloni, Chernozhukov, and Hansen (2014)
* Abortion and Crime example
* Portable course-replication version for GitHub
*******************************************************

clear all
set more off
set maxvar 20000
capture set matsize 11000

// -----------------------------------------------------------------------------
* Repository paths and bundled dependency
* Run this file after setting Stata's working directory to the repository root.
// -----------------------------------------------------------------------------
global PROJECT_ROOT "`c(pwd)'"
global DATA_DIR     "${PROJECT_ROOT}/data"
global RESULTS_DIR  "${PROJECT_ROOT}/results"
global VENDOR_DIR   "${PROJECT_ROOT}/code/vendor"

capture mkdir "${RESULTS_DIR}"
adopath ++ "${VENDOR_DIR}"

capture which lassoShooting
if _rc {
    display as error "Bundled dependency lassoShooting.ado was not found."
    display as error "Set Stata's working directory to the repository root and rerun."
    exit 199
}

capture log close
log using "${RESULTS_DIR}/replication.log", replace text

*******************************************************
* 1. Load data
*******************************************************

insheet using "${DATA_DIR}/levitt_ex.dat", clear

* The uploaded log shows that it reads 17 variables and 1,734 observations.

*******************************************************
* 2. Sample restrictions
*******************************************************

* Drop Washington, DC.
drop if statenum == 9

* Keep the years used in the replication: 1985-1997.
drop if year < 85 | year > 97

* Normalized trend variable.
gen trend = (year - 85) / 12

* Declare panel structure.
tsset statenum year

*******************************************************
* 3. Baseline first-difference regressions
*******************************************************

xi: reg D.lpc_viol D.efaviol D.xx* i.year, cluster(statenum)
xi: reg D.lpc_prop D.efaprop D.xx* i.year, cluster(statenum)
xi: reg D.lpc_murd D.efamurd D.xx* i.year, cluster(statenum)

*******************************************************
* 4. Rescale some controls before LASSO
*******************************************************

replace xxincome = xxincome / 100
replace xxpover   = xxpover   / 100
replace xxafdc15  = xxafdc15  / 10000
replace xxbeer    = xxbeer    / 100

* Year dummies created by xi above.
local tdums "_Iyear_87 _Iyear_88 _Iyear_89 _Iyear_90 _Iyear_91 _Iyear_92 _Iyear_93 _Iyear_94 _Iyear_95 _Iyear_96 _Iyear_97"

* Original control variables.
local xx "xxprison xxpolice xxunemp xxincome xxpover xxafdc15 xxgunlaw xxbeer"

*******************************************************
* 5. Build high-dimensional controls
*******************************************************

* First differences.
local Dxx
foreach x of local xx {
    gen D`x' = D.`x'
    local Dxx `Dxx' D`x'
}

* Squared first differences.
local Dxx2
foreach x of local Dxx {
    gen `x'2 = `x'^2
    local Dxx2 `Dxx2' `x'2
}

* Pairwise interactions among first differences.
local DxxInt
local nxx : word count `Dxx'

forvalues ii = 1/`nxx' {
    local start = `ii' + 1
    forvalues jj = `start'/`nxx' {
        local temp1 : word `ii' of `Dxx'
        local temp2 : word `jj' of `Dxx'
        gen `temp1'X`temp2' = `temp1' * `temp2'
        local DxxInt `DxxInt' `temp1'X`temp2'
    }
}

* Lags.
local Lxx
foreach x of local xx {
    gen L`x' = L.`x'
    local Lxx `Lxx' L`x'
}

* Squared lags.
local Lxx2
foreach x of local Lxx {
    gen `x'2 = `x'^2
    local Lxx2 `Lxx2' `x'2
}

* Within-state means.
local Mxx
foreach x of local xx {
    bysort statenum: egen M`x' = mean(`x')
    local Mxx `Mxx' M`x'
}

* Squared within-state means.
local Mxx2
foreach x of local Mxx {
    gen `x'2 = `x'^2
    local Mxx2 `Mxx2' `x'2
}

* Initial levels.
local xx0
foreach x of local xx {
    bysort statenum (year): gen `x'0 = `x'[1]
    local xx0 `xx0' `x'0
}

* Squared initial levels.
local xx02
foreach x of local xx0 {
    gen `x'2 = `x'^2
    local xx02 `xx02' `x'2
}

* Initial differences.
local Dxx0
foreach x of local Dxx {
    bysort statenum (year): gen `x'0 = `x'[2]
    local Dxx0 `Dxx0' `x'0
}

* Squared initial differences.
local Dxx02
foreach x of local Dxx0 {
    gen `x'2 = `x'^2
    local Dxx02 `Dxx02' `x'2
}

* Combine all common controls.
local biglist `Dxx' `Dxx2' `DxxInt' `Lxx' `Lxx2' `Mxx' `Mxx2' `xx0' `xx02' `Dxx0' `Dxx02'

* Interactions with trend and trend squared.
local IntT
foreach x of local biglist {
    gen `x'Xt  = `x' * trend
    gen `x'Xt2 = `x' * (trend^2)
    local IntT `IntT' `x'Xt `x'Xt2
}

local shared `biglist' `IntT'

*******************************************************
* 6. Crime-specific controls
*******************************************************

* Violent crime-specific controls.
gen Dviol = D.efaviol
bysort statenum (year): gen viol0  = efaviol[1]
bysort statenum (year): gen Dviol0 = Dviol[2]

gen viol02     = viol0^2
gen Dviol02    = Dviol0^2
gen viol0Xt    = viol0 * trend
gen viol0Xt2   = viol0 * (trend^2)
gen viol02Xt   = viol02 * trend
gen viol02Xt2  = viol02 * (trend^2)
gen Dviol0Xt   = Dviol0 * trend
gen Dviol0Xt2  = Dviol0 * (trend^2)
gen Dviol02Xt  = Dviol02 * trend
gen Dviol02Xt2 = Dviol02 * (trend^2)

local contviol "viol0 viol0Xt viol0Xt2 viol02 viol02Xt viol02Xt2 Dviol0 Dviol0Xt Dviol0Xt2 Dviol02 Dviol02Xt Dviol02Xt2"
local AllViol `contviol' `shared'

* Property crime-specific controls.
gen Dprop = D.efaprop
bysort statenum (year): gen prop0  = efaprop[1]
bysort statenum (year): gen Dprop0 = Dprop[2]

gen prop02     = prop0^2
gen Dprop02    = Dprop0^2
gen prop0Xt    = prop0 * trend
gen prop0Xt2   = prop0 * (trend^2)
gen prop02Xt   = prop02 * trend
gen prop02Xt2  = prop02 * (trend^2)
gen Dprop0Xt   = Dprop0 * trend
gen Dprop0Xt2  = Dprop0 * (trend^2)
gen Dprop02Xt  = Dprop02 * trend
gen Dprop02Xt2 = Dprop02 * (trend^2)

local contprop "prop0 prop0Xt prop0Xt2 prop02 prop02Xt prop02Xt2 Dprop0 Dprop0Xt Dprop0Xt2 Dprop02 Dprop02Xt Dprop02Xt2"
local AllProp `contprop' `shared'

* Murder-specific controls.
gen Dmurd = D.efamurd
bysort statenum (year): gen murd0  = efamurd[1]
bysort statenum (year): gen Dmurd0 = Dmurd[2]

gen murd02     = murd0^2
gen Dmurd02    = Dmurd0^2
gen murd0Xt    = murd0 * trend
gen murd0Xt2   = murd0 * (trend^2)
gen murd02Xt   = murd02 * trend
gen murd02Xt2  = murd02 * (trend^2)
gen Dmurd0Xt   = Dmurd0 * trend
gen Dmurd0Xt2  = Dmurd0 * (trend^2)
gen Dmurd02Xt  = Dmurd02 * trend
gen Dmurd02Xt2 = Dmurd02 * (trend^2)

local contmurd "murd0 murd0Xt murd0Xt2 murd02 murd02Xt murd02Xt2 Dmurd0 Dmurd0Xt Dmurd0Xt2 Dmurd02 Dmurd02Xt Dmurd02Xt2"
local AllMurd `contmurd' `shared'

*******************************************************
* 7. Differenced outcomes
*******************************************************

gen Dyviol = D.lpc_viol
gen Dyprop = D.lpc_prop
gen Dymurd = D.lpc_murd

* Drop first year because first differences and lags are missing.
drop if trend == 0

*******************************************************
* 8. OLS with all high-dimensional controls
*******************************************************

reg Dyviol Dviol `AllViol' `tdums', cluster(statenum)
reg Dyprop Dprop `AllProp' `tdums', cluster(statenum)
reg Dymurd Dmurd `AllMurd' `tdums', cluster(statenum)

*******************************************************
* 9. Post-double-selection LASSO
*******************************************************

* Violent crime: outcome selection.
lassoShooting Dyviol `AllViol', controls(`tdums') lasiter(100) verbose(0) fdisplay(0)
local yvSel `r(selected)'
display "Selected controls for violent-crime outcome equation:"
display "`yvSel'"

* Violent crime: treatment selection.
lassoShooting Dviol `AllViol', controls(`tdums') lasiter(100) verbose(0) fdisplay(0)
local xvSel `r(selected)'
display "Selected controls for violent-crime abortion equation:"
display "`xvSel'"

* Union and final regression.
local vDS : list yvSel | xvSel
display "Union of selected violent-crime controls:"
display "`vDS'"

reg Dyviol Dviol `vDS' `tdums', cluster(statenum)


* Property crime: outcome selection.
lassoShooting Dyprop `AllProp', controls(`tdums') lasiter(100) verbose(0) fdisplay(0)
local ypSel `r(selected)'
display "Selected controls for property-crime outcome equation:"
display "`ypSel'"

* Property crime: treatment selection.
lassoShooting Dprop `AllProp', controls(`tdums') lasiter(100) verbose(0) fdisplay(0)
local xpSel `r(selected)'
display "Selected controls for property-crime abortion equation:"
display "`xpSel'"

* Union and final regression.
local pDS : list ypSel | xpSel
display "Union of selected property-crime controls:"
display "`pDS'"

reg Dyprop Dprop `pDS' `tdums', cluster(statenum)


* Murder: outcome selection.
lassoShooting Dymurd `AllMurd', controls(`tdums') lasiter(100) verbose(0) fdisplay(0)
local ymSel `r(selected)'
display "Selected controls for murder outcome equation:"
display "`ymSel'"

* Murder: treatment selection.
lassoShooting Dmurd `AllMurd', controls(`tdums') lasiter(100) verbose(0) fdisplay(0)
local xmSel `r(selected)'
display "Selected controls for murder abortion equation:"
display "`xmSel'"

* Union and final regression.
local mDS : list ymSel | xmSel
display "Union of selected murder controls:"
display "`mDS'"

reg Dymurd Dmurd `mDS' `tdums', cluster(statenum)

*******************************************************
* 10. Close log
*******************************************************

log close
display "Replication complete. Results log: ${RESULTS_DIR}/replication.log"