# Test Matrix

| Case | Wind | SCR | Mitigation | Purpose |
|---|---|---|---|---|
| Baseline | 12 m/s | 10 | off | strong-grid equilibrium and power balance |
| Wind step | 12 -> 10.5 m/s | 10 | off | aerodynamic/MSC response |
| SSO before | 12 m/s | 10 -> 5 at 2 s | off | excite inherent weak-grid control mode |
| SSO after | identical | identical | PLL retuning | controlled comparison |
| SCR sweep | 12 m/s | 3:0.25:12 | off | modal boundary/sensitivity |
| PLL sweep | 12 m/s | 5 | Ki 0.5:0.1:3.2 | control sensitivity |
| Numerical sensitivity | 12 m/s | 10 -> 5 | off | compare 1 ms and 0.5 ms steps |

Automated tests cover environment, parameters, baseline, grid-strength mapping, synthetic/model Prony, SSO cross-check, mitigation, small-signal equilibrium and output artifacts.
