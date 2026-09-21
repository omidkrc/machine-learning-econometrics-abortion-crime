# High-Dimensional Methods and Inference on Structural and Treatment Effects

## Replicating the Abortion-Crime Debate

**Omid Karami**  
Course: Machine Learning Methods in Econometrics  
Instructor: Prof. Gautam Tripathi  
May 17, 2026

> This is a GitHub-readable adaptation of the submitted course report. The empirical application is observational and the discussion is methodological; it is not a policy recommendation.

## Abstract

This project revisits the abortion-crime application discussed by Belloni, Chernozhukov, and Hansen (2014). The central econometric problem is that crime outcomes may depend on many state-level economic, demographic, and policy variables. Omitting relevant controls can bias the treatment estimate, while including a very large set of controls can make conventional regression unstable.

The project uses LASSO, Post-LASSO, and post-double-selection to select controls systematically for inference on a low-dimensional treatment coefficient. In the course replication, the baseline first-difference estimate for violent crime is about -0.157 with a clustered standard error of 0.034. The exercise illustrates how machine-learning methods can support econometric inference when there are many plausible controls.

## 1. Motivation

The empirical question concerns the relationship between effective abortion exposure and later crime outcomes across U.S. states and years. The identification strategy is observational rather than experimental, so credible inference depends on conditioning on a sufficiently rich set of observed confounders.

This creates a model-selection problem. A small regression may omit relevant controls; an unrestricted specification with every transformation and interaction may be too noisy. High-dimensional methods are useful because a modest set of underlying covariates can generate hundreds of candidate regressors once lags, differences, squares, initial values, averages, and time interactions are included.

The goal is not to treat machine learning as a substitute for causal identification. The goal is to use regularization to estimate nuisance components in a disciplined way while preserving valid inference on the treatment effect.

## 2. Econometric Framework

The project uses a partially linear model of the form

```text
Y_i = alpha_0 D_i + g_0(Z_i) + u_i
```

where `Y_i` is the crime outcome, `D_i` is effective abortion exposure, and `g_0(Z_i)` is a high-dimensional nuisance function of observed controls.

With panel data, the baseline specification is expressed in first differences:

```text
Delta y_it = alpha Delta A_it + Delta w_it' beta + lambda_t + Delta epsilon_it
```

First differencing removes time-invariant state effects, while year effects absorb common national shocks.

### LASSO and Post-LASSO

LASSO selects a sparse subset of controls from a large candidate set by applying an L1 penalty. This is useful for prediction and variable selection, but the shrinkage induced by the penalty can bias coefficient estimates.

Post-LASSO addresses this by re-estimating an unpenalized OLS regression using only the variables selected by LASSO.

### Double Selection

Outcome-only LASSO may omit a variable that is weakly related to the outcome but strongly related to treatment. Such an omission can still bias the treatment coefficient.

Post-double-selection therefore uses two selection steps:

1. Run LASSO of the outcome on the candidate controls.
2. Run LASSO of the treatment on the candidate controls.
3. Take the union of variables selected in either equation.
4. Estimate the final treatment regression by OLS with the selected controls and required year effects.

This union step is deliberately conservative and helps protect the treatment coefficient from regularization-induced omitted-variable bias.

## 3. Data and Replication Design

The replication uses `levitt_ex.dat`, containing 17 variables and 1,734 observations before restrictions.

The analysis:

- drops Washington, DC;
- restricts the sample to 1985-1997;
- declares a strongly balanced state-year panel;
- estimates first-difference specifications;
- clusters standard errors by state.

After restrictions and first differencing, the main regressions use 600 observations across 50 state clusters.

The three outcomes are log violent crime, log property crime, and log murder. Corresponding effective abortion-rate measures are used as treatment variables.

Baseline controls include prison population, policing, unemployment, income, poverty, welfare policy, gun laws, and beer consumption. The high-dimensional dictionary expands these controls using first differences, lags, within-state means, initial values, squares, pairwise interactions, and interactions with a normalized time trend.

## 4. Empirical Results

The successful course run produces the following treatment coefficients:

| Specification | Violent crime | Property crime | Murder |
|---|---:|---:|---:|
| Baseline first-difference OLS | -0.1567 (0.0339) | -0.1056 (0.0211) | -0.2180 (0.0677) |
| Post-double-selection | -0.2741 (0.0490) | -0.1452 (0.0277) | -0.4339 (0.0764) |
| All generated controls | -0.3123 (0.0751) | -0.1567 (0.0372) | -0.2641 (0.1678) |

Standard errors are clustered by state and shown in parentheses.

The baseline estimates are negative and statistically significant for all three crime outcomes in the course run. The post-double-selection estimates are also negative and statistically significant.

The course implementation does not reproduce every published Belloni-Chernozhukov-Hansen coefficient numerically. Differences can arise from the exact high-dimensional dictionary, penalty implementation, and generated-variable construction. The purpose of the exercise is therefore both empirical and methodological: to study how inference changes when control selection is performed systematically in a high-dimensional setting.

## 5. Interpretation

The key lesson is that prediction and causal inference are not the same task. A variable can be important for identification even if it contributes little to predicting the outcome, provided it is strongly related to treatment.

Double Selection addresses this by selecting controls from both the outcome and treatment equations. This reduces the risk that a confounder is excluded merely because it is weakly predictive of the outcome.

The project also illustrates why including every available control is not automatically preferable. Very large specifications can become imprecise or unstable. Post-double-selection provides a middle ground between hand-picked small models and unrestricted all-controls regressions.

## 6. Limitations

The analysis depends on the maintained selection-on-observables assumption. LASSO can only select among variables that are observed or constructed by the researcher; it cannot eliminate bias from unobserved confounding.

The method also relies on approximate sparsity: a relatively small subset of the candidate controls should capture the most important nuisance relationships. If the true confounding structure is dense, sparse selection may be less appropriate.

Finally, the substantive abortion-crime relationship is an empirical claim about cohort exposure and later outcomes. Statistical estimates do not resolve ethical, legal, or social debates concerning abortion.

## 7. Methodological Takeaways

This replication connects machine-learning tools to econometric inference:

- LASSO helps navigate large control dictionaries.
- Post-LASSO removes shrinkage from the final coefficient estimates.
- Double Selection uses information from both outcome and treatment equations.
- First differencing and year effects address panel structure and common shocks.
- Clustered standard errors account for within-state dependence.
- Orthogonalization provides the intuition for why nuisance-model errors can have limited first-order impact on the treatment estimate.

The broader lesson is that high-dimensional methods are most useful when combined with a credible research design and clear identifying assumptions.

## 8. Conclusion

The project applies high-dimensional methods to a classic empirical debate. The baseline first-difference estimate for violent crime is approximately -0.156, while the post-double-selection course implementation also produces a negative and statistically significant estimate.

The central contribution of the exercise is methodological rather than predictive. Double Selection provides a disciplined way to choose controls when the researcher faces many possible confounders, interactions, and functional forms, while keeping attention on inference for a specific low-dimensional treatment effect.

## References

1. Belloni, A., Chernozhukov, V., & Hansen, C. (2014). *High-Dimensional Methods and Inference on Structural and Treatment Effects*. Journal of Economic Perspectives, 28(2), 29-50.
2. Donohue, J. J., & Levitt, S. D. (2001). *The Impact of Legalized Abortion on Crime*. Quarterly Journal of Economics, 116(2), 379-420.
3. Belloni, A., Chernozhukov, V., & Hansen, C. (2014). *Inference on Treatment Effects after Selection among High-Dimensional Controls*. Review of Economic Studies, 81(2), 608-650.
