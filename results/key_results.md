# Key Replication Results

The following estimates are taken from the successful Stata course run included as `course_run.log`. Standard errors are clustered by state and shown in parentheses.

| Specification | Violent crime | Property crime | Murder |
|---|---:|---:|---:|
| Baseline first-difference OLS | -0.1567411 (0.0339323) | -0.1056067 (0.0211387) | -0.2179677 (0.0677003) |
| All generated controls | -0.3122610 (0.0750990) | -0.1566886 (0.0371747) | -0.2640930 (0.1677569) |
| Post-double-selection | -0.2741210 (0.0490120) | -0.1451659 (0.0276788) | -0.4338729 (0.0764358) |

## Statistical significance in the course run

- Baseline violent crime: p < 0.001
- Baseline property crime: p < 0.001
- Baseline murder: p = 0.002
- Post-double-selection violent crime: p < 0.001
- Post-double-selection property crime: p < 0.001
- Post-double-selection murder: p < 0.001
- All-controls murder specification: p = 0.122

These values document the output of this course implementation. They should not be presented as exact numerical reproduction of every published Belloni-Chernozhukov-Hansen specification.
