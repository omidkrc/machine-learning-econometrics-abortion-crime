# Machine Learning in Econometrics: Post-Double-Selection LASSO and the Abortion-Crime Debate

## Overview

This repository contains a course replication of the abortion-crime application in Belloni, Chernozhukov, and Hansen (2014), developed for **Machine Learning Methods in Econometrics** at the University of Luxembourg.

The project studies how high-dimensional econometric methods can be used for inference on a low-dimensional treatment effect when the researcher faces many possible controls. The empirical application combines panel-data first differences with **LASSO**, **Post-LASSO**, and **post-double-selection** to estimate the relationship between effective abortion exposure and later crime outcomes.

The emphasis is methodological: variable selection for causal inference is different from variable selection for prediction. Double Selection uses controls selected from both the outcome equation and the treatment equation, reducing the risk that a confounder is omitted simply because it is only weakly predictive of the outcome.

## Course Context

- **Course:** Machine Learning Methods in Econometrics
- **Instructor:** Prof. Gautam Tripathi
- **Author:** Omid Karami
- **Date:** May 2026

The submitted report is preserved in [`report/course_report.pdf`](report/course_report.pdf).

## Empirical Design

The analysis uses a U.S. state-year panel from the Belloni-Chernozhukov-Hansen replication materials. The source data contain 17 variables and 1,734 observations before sample restrictions. Washington, DC is removed and the analysis is restricted to 1985-1997. After first differencing, the main regressions use **600 observations across 50 state clusters**.

The three outcomes are changes in log violent crime, property crime, and murder. The corresponding treatment variables are changes in the effective abortion-rate measures. Baseline controls include prison population, police, unemployment, income, poverty, welfare policy, gun laws, and beer consumption.

The high-dimensional dictionary expands the baseline controls using differences, lags, within-state means, initial values, squares, pairwise interactions, and interactions with a normalized time trend.

## Methods

- Panel-data first differencing
- Year effects and state-clustered standard errors
- High-dimensional control construction
- LASSO variable selection
- Post-LASSO estimation
- Post-double-selection / Double Selection
- Orthogonalization and partialling-out intuition
- Comparison with unrestricted all-controls specifications

## Replication Results

The included successful Stata run produces the following treatment coefficients:

| Specification | Violent crime | Property crime | Murder |
|---|---:|---:|---:|
| Baseline first-difference OLS | -0.1567 (0.0339) | -0.1056 (0.0211) | -0.2180 (0.0677) |
| Post-double-selection | -0.2741 (0.0490) | -0.1452 (0.0277) | -0.4339 (0.0764) |
| All generated controls | -0.3123 (0.0751) | -0.1567 (0.0372) | -0.2641 (0.1678) |

Standard errors are clustered by state and shown in parentheses. These are the estimates from the **course replication implementation** included here; they are not a claim that the published Belloni-Chernozhukov-Hansen table is reproduced numerically in every specification. The report discusses why high-dimensional estimates can be sensitive to the exact control dictionary, penalty choice, and generated-variable construction.

The substantive application is observational and depends on maintained identification assumptions. The project is an econometric replication and methodological exercise, not a policy recommendation.

## Repository Structure

```text
machine-learning-econometrics-abortion-crime/
├── README.md
├── .gitignore
├── ATTRIBUTION.md
├── LICENSE_REPLICATION_MATERIALS.txt
├── code/
│   ├── abortion_crime_double_selection.do
│   └── vendor/
│       └── lassoShooting.ado
├── data/
│   └── levitt_ex.dat
├── docs/
│   └── run_instructions.md
├── report/
│   └── course_report.pdf
├── results/
│   ├── key_results.md
│   └── course_run.log
└── source/
    ├── LevittExample.do
    ├── JEPAbortion.txt
    └── README_original.txt
```

## Running the Analysis

The repository is self-contained: the replication dataset and the original `lassoShooting.ado` dependency are included under the terms described in `LICENSE_REPLICATION_MATERIALS.txt`.

From Stata, set the working directory to the repository root and run:

```stata
do "code/abortion_crime_double_selection.do"
```

The script adds `code/vendor/` to Stata's ado path, reads `data/levitt_ex.dat`, and writes a fresh log to `results/replication.log`.

See [`docs/run_instructions.md`](docs/run_instructions.md) for details.

## Provenance and Licensing

The dataset, original replication script, original replication log/readme, and `lassoShooting.ado` come from the replication materials for Belloni, Chernozhukov, and Hansen (2014). The supplied license states that code/software are covered by a Modified BSD license and databases/text by Creative Commons Attribution 4.0, with copyright attributed to the American Economic Association (2014). See [`LICENSE_REPLICATION_MATERIALS.txt`](LICENSE_REPLICATION_MATERIALS.txt) and [`ATTRIBUTION.md`](ATTRIBUTION.md).

The course report and repository-specific documentation are presented as Omid Karami's course work and are not intended to alter the licensing terms of the upstream replication materials.

## References

Belloni, A., Chernozhukov, V., & Hansen, C. (2014). *High-Dimensional Methods and Inference on Structural and Treatment Effects*. Journal of Economic Perspectives, 28(2), 29-50.

Donohue, J. J., & Levitt, S. D. (2001). *The Impact of Legalized Abortion on Crime*. Quarterly Journal of Economics, 116(2), 379-420.

## Author

**Omid Karami**  
Master's in Finance and Economics  
University of Luxembourg
