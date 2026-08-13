# Dependency Inventory

## Runtime dependencies of the authoritative model

| Dependency | Required |
|---|---|
| MATLAB R2025b | Yes |
| Simulink 25.2 | Yes |
| Custom Level-2 MATLAB S-Functions | No |
| Project `.m` files | No |
| Base-workspace parameter structure | No |
| Model callbacks | No |
| External library links | No |
| Machine-specific paths | No |

The SLX contains its equations, continuous states, default scenario variables, fixed step, stop time and initial conditions.

## External reproducibility tooling

Files under `scripts/`, `analysis/` and `validation/` are optional tooling for scenario sweeps, result exports, FFT/Prony/eigenvalue analysis, plots, snapshots, reports and acceptance tests. They are not called by the model during a standalone simulation.
