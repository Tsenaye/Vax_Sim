# Requirements

| ID | Requirement | Verification |
|---|---|---|
| R1 | Dynamic PMSG wind turbine with full converter and DC link | Model compile, equations and signal logs |
| R2 | Stable strong-grid operation | `baseline.mat`, `test_baseline` |
| R3 | Vary wind, SCR and control gains | case configuration and sweep CSV files |
| R4 | Model-generated sub-50 Hz oscillation | nonlinear weak-grid run; no periodic source |
| R5 | Quantify SSO in time/frequency/modal domains | FFT, Prony and actual-ODE Jacobian |
| R6 | Controlled mitigation comparison | identical SCR/wind/disturbance, mitigation flag only |
| R7 | Rebuildable executable Simulink model | `build_model.m`, compile/update test |
| R8 | Publication-ready outputs | 14 generated PNGs and result CSVs |
| R9 | No fabricated numerical results | all reported values read from MAT/CSV artifacts |
| R10 | Student-level reproducibility | README, equations, controls, tests and validation report |
