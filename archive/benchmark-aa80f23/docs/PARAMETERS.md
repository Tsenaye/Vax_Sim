# Parameters and Traceability

| Parameter | Symbol | Value | Unit | Classification / source | Used in |
|---|---:|---:|---|---|---|
| Rated power | Sbase | 5 | MW | LITERATURE, Wang et al. p. 2782 | all pu bases |
| Rated line voltage | VLL | 690 | V | ENGINEERING ASSUMPTION, representative LV turbine converter | base conversion |
| Grid frequency | f | 50 | Hz | Proposal/project context | dq/abc conversion |
| Air density | rho | 1.225 | kg/m3 | ENGINEERING ASSUMPTION, standard sea-level value | aerodynamics |
| Rotor radius | R | 55 | m | ENGINEERING ASSUMPTION chosen for a plausible 5 MW operating point | aerodynamics |
| Nominal wind | vw | 12 | m/s | Literature scenario context; not copied outcome | cases |
| Optimal tip-speed ratio | lambda | 6.3 | - | ENGINEERING ASSUMPTION matched to selected Cp curve | aerodynamics |
| Inertia constant | H | 4.0 | s | ENGINEERING ASSUMPTION typical aggregated turbine-generator inertia | rotor |
| Mechanical damping | D | 0.02 | pu | ENGINEERING ASSUMPTION | rotor |
| PMSG dq inductances | Ld=Lq | 0.25 | pu | ENGINEERING ASSUMPTION, surface PMSG | documentation/kernel torque basis |
| PM flux | psi_pm | 1.0 | pu | DERIVED normalization | torque |
| MSC current time constant | tau_m | 0.02 | s | ENGINEERING ASSUMPTION | MSC |
| Speed PI | Kp/Ki | 2.0 / 1.0 | pu | ENGINEERING ASSUMPTION, stable bandwidth separation | MSC |
| DC energy capacitance | Cdc,pu | 0.08 | s | ENGINEERING ASSUMPTION | DC link |
| Filter resistance/reactance | Rf/Xf | 0.01 / 0.15 | pu | ENGINEERING ASSUMPTION | GSC/grid |
| GSC current PI | Kp/Ki | 0.30 / 20 | pu | ENGINEERING ASSUMPTION, verified stable strong-grid baseline | GSC |
| DC voltage PI | Kp/Ki | 0.80 / 20 | pu | ENGINEERING ASSUMPTION, verified baseline | GSC |
| Grid impedance | Xg=1/SCR | varied | pu | DERIVED from SCR definition with E=1 pu | grid sweep |
| Grid X/R | X/R | 10 | - | ENGINEERING ASSUMPTION, inductive transmission equivalent | grid |
| PLL proportional gain | Kp_pll | 0.01 | pu | TUNED THROUGH VALIDATED EXPERIMENT | PLL |
| PLL integral gain before | Ki_pll | 2.80 | pu | TUNED THROUGH VALIDATED EXPERIMENT; produces weak-grid mode, not copied | benchmark |
| PLL integral gain after | Ki_pll | 0.50 | pu | TUNED THROUGH VALIDATED EXPERIMENT; controlled mitigation | mitigation |
| Strong/weak SCR | SCR | 10 / 5 | - | ENGINEERING TEST CONDITIONS; outputs are local model results | scenarios |
| Solver step | dt | 0.0002 | s | DERIVED; convergence verified against 0.0001 s (see results/validation/numerical_sensitivity.csv) | simulation |

No parameter is claimed to reproduce the Xinjiang grid. Per-unit conversions use three-phase `Ibase=Sbase/(sqrt(3)VLL)`.
