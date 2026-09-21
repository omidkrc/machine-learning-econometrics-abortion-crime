# Running the Stata Replication

## 1. Requirements

Use a Stata installation capable of running the legacy `xi` syntax retained from the original replication code. The bundled `lassoShooting.ado` declares Stata version 12 and is added to the ado path automatically by the public script.

No external dataset download is required because the licensed replication dataset is included in `data/`.

## 2. Set the repository root

Open Stata and change the working directory to the folder containing `README.md`.

Windows example:

```stata
cd "C:/Users/YourName/Documents/machine-learning-econometrics-abortion-crime"
```

macOS/Linux example:

```stata
cd "/Users/YourName/Documents/machine-learning-econometrics-abortion-crime"
```

## 3. Run the analysis

```stata
do "code/abortion_crime_double_selection.do"
```

The script will add `code/vendor/` to Stata's ado path, verify `lassoShooting`, read `data/levitt_ex.dat`, apply the sample restrictions, construct the high-dimensional control dictionary, estimate all-controls specifications, run outcome and treatment LASSO selection, and estimate the final post-double-selection regressions.

A fresh Stata log is written to:

```text
results/replication.log
```

## 4. Expected sample

The source file contains 17 variables and 1,734 observations. After dropping Washington, DC and restricting the years to 1985-1997, the panel is strongly balanced. The first-difference regressions use 600 observations with standard errors clustered across 50 states.

## 5. Reference outputs

`results/key_results.md` contains the main coefficients from the successful course run. `results/course_run.log` is a sanitized copy of that Stata session with local filesystem paths removed.

## 6. Notes

The repository script is a portability-focused refactor of the course replication code: it replaces the hard-coded local working directory with repository-relative paths and uses the bundled LASSO ado file. The econometric specification and high-dimensional variable construction are retained from the course implementation.
