# Vataleni PMSG weak grid SSO model

The authoritative `model/Vataleni_PMSG_SSO_Final.slx` is a self-contained, averaged physical Simscape Electrical model of one 5 MW wind turbine with a permanent magnet synchronous generator (PMSG), full converter, DC capacitor, filter and weak AC grid. It runs in MATLAB R2025b with Simulink, Simscape and Simscape Electrical. Simulink Control Design is used only for optional modal linearization. No initialization script, project library, external data file or custom S-function is needed to press **Run**.

The validated reduced-order predecessor is preserved at Git tag `benchmark-aa80f23` and under `archive/benchmark-aa80f23/`. Its 4.84 Hz result does not describe this physical model.

## VIEW RESULTS AND FINAL DELIVERY

- [Start here: complete delivery](Final_Delivery/README_START_HERE.md)
- [Open the standalone MATLAB model](Final_Delivery/Vataleni_PMSG_SSO_Final.slx)
- [Simulation results and quantitative summary](Final_Delivery/Results/README_RESULTS.md)
- [Three-slide PowerPoint](Final_Delivery/Vataleni_PMSG_SSO_Three_Slide_Presentation.pptx)
- [Three-page illustrated PDF](Final_Delivery/Vataleni_PMSG_SSO_Three_Page_Explainer.pdf)
- [Validation report](Final_Delivery/Vataleni_PMSG_SSO_Validation_Report.pdf)
- [Download the complete ZIP](Vataleni_PMSG_SSO_Final_Delivery.zip)

## Run the saved model

```matlab
load_system('model/Vataleni_PMSG_SSO_Final.slx');
out = sim('Vataleni_PMSG_SSO_Final');
```

The model owns its default values in its Model Workspace. To select a scenario, edit `wind_final`, `grid_scr` and `mitigation_enable` there, or run `analysis/run_physical_scenarios.m`. The default is 12 m/s wind, nominal external SCR 10, mitigation off, with a 6 s `ode15s` run and a 1 ms maximum step. Scenario runs use a 12 to 13 m/s wind step at 2 s, nominal external SCR 10 or 5, and the same disturbance for the mitigated case. `parameters/VaxSim_Parameters.m` is an optional editable reference and is never called by the model.

The top level exposes the physical power path from the wind turbine to the grid, separate MSC and GSC/PLL control subsystems, a telemetry subsystem, and twelve live Scopes. The Scopes show measured shaft, machine, DC and PCC quantities and controller responses. Model snapshots are in `artifacts/model_snapshots/`.

## Reproduce the evidence

```matlab
run('analysis/run_physical_scenarios.m')
run('validation/convergence_check.m')
```

Then run `python analysis/analyse_physical_results.py`. Scenario CSVs, numerical checks and modal estimates are in `results/physical/`; regenerated figures are in `figures/physical/`. The numerical checks directly verify the PMSG d/q equations, speed conversion, torque, power and DC energy balances, converter losses, control limits and disturbance response.

## Scope and findings

The native PMSG block integrates stator electrical dynamics. The MSC and GSC use native bidirectional averaged three-phase converter blocks, so the model resolves control and network SSO dynamics but not switching harmonics. The observed weak-grid oscillation is a **decaying** approximately 4.7 Hz response, amplified by lower SCR; this model does not establish a sustained unstable mode. Raising the PLL proportional gain from 0.00558 to 0.02 rad/(s V) reduces the response for the tested wind disturbance. See `docs/TECHNICAL_REPORT.md`, `docs/MODEL_GUIDE.md` and `docs/VERIFICATION_REPORT.md` for methods, results and remaining assumptions.
