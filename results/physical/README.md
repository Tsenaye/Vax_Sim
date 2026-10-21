# Physical model result data

These files were generated from `model/Vataleni_PMSG_SSO_Final.slx`, not from the historical reduced-order benchmark.

- `baseline.csv`, `wind_variation.csv`, `weak_grid.csv`, and `weak_grid_mitigated.csv` contain live physical and control signals sampled for export at 10 ms over 6 s. The Simscape solver uses adaptive steps up to 1 ms.
- `weak_grid_half_step.csv` uses the identical weak-grid scenario with maximum solver step 0.5 ms.
- `scenario_metrics.csv` reports means on 5.5 to 6 s and PCC q standard deviations on 2.25 to 3.25 s and 5.5 to 6 s.
- `modal_estimates.csv` contains the 1 to 45 Hz periodogram peak and a 3 to 8 Hz band-limited AR(2)/Prony pole of the disturbed trajectory.
- `linearized_modes.csv` contains eigenvalues from 23-state native physical-model snapshot linearization at 5.5 s with constant 12 m/s wind. `grid_scr` and PLL mitigation vary; Simulink Control Design is needed to regenerate this optional file.
- `engineering_checks.csv` contains 25 numerical relationship checks. `fresh_session_audit.txt` and `final_saved_model_run.log` document an independent MATLAB process opening and running the final SLX without initialization.

The CSV files use SI units except explicit `MW`, `kW` and dimensionless columns in the summary tables. Positive machine q current is into the PMSM, so generator operation has negative q current. Positive MSC DC current enters the capacitor bus; GSC DC current is negative when power leaves it.
