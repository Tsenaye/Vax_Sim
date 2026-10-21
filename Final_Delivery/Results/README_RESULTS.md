# Simulation results - saved physical PMSG model

These outputs come from **`Vataleni_PMSG_SSO_Final.slx`**, SHA-256 `355CCBA5B1D58151206AC449AACB5A798604957D0A3C22D6130EBB035BA1BF5A`. MATLAB R2025b ran the saved model for 6 s in each case. The evidence was generated after the repository source revision `0ec932fc4330bd9ae63b70914b047c8ad30b0a9e`; the final delivery commit is the HEAD of `codex/native-reconstruction`. The historical reduced-order benchmark is not used here.

## Open these first

- [Baseline power balance](01_Baseline/04_power_balance.png) and [baseline numerical output](01_Baseline/baseline.csv): approximately settled 12 m/s wind, nominal external SCR 10.
- [Unmitigated SSO waveform](02_Weak_Grid_SSO/06_sso_unmitigated.png) and [weak-grid data](02_Weak_Grid_SSO/weak_grid.csv): 12 to 13 m/s wind step at 2 s, nominal external SCR 5.
- [Mitigated waveform](03_Mitigation/07_sso_mitigated.png) and [mitigated data](03_Mitigation/weak_grid_mitigated.csv): the same weak-grid disturbance with PLL proportional gain increased to 0.02 rad/(s V).
- [Common-axis scenario comparison](04_Comparisons/08_scenario_comparison.png), [PCC and DC comparison](04_Comparisons/01_pcc_and_dc_response.png), [spectrum](04_Comparisons/02_pcc_frequency.png), and [linearized pole comparison](04_Comparisons/05_physical_eigenvalues.png).
- [Actual Simulink Scope captures](05_Scope_Captures/) show data displayed by native Scope windows after simulation.
- [Raw numerical CSVs and check tables](06_Numerical_Data/) include the wind-variation case, modal estimates, 23-state linearization results and 25 numerical checks.

## Measured comparison

| Case | Late DC voltage (V) | Late PCC power (MW) | Early PCC q std (V) |
|---|---:|---:|---:|
| baseline | 1400.05 | 4.301 | 1.262 |
| wind variation | 1405.27 | 4.916 | 1.788 |
| weak grid | 1405.42 | 4.916 | 3.997 |
| weak grid mitigated | 1405.42 | 4.916 | 0.554 |

The early PCC q-axis standard deviation is measured from 2.25 to 3.25 s. The weak-grid response is a **decaying** oscillation, with 4.681 Hz FFT peak and a 4.638 Hz, 5.24% damped physical-model snapshot pole. PLL retuning reduces the early weak-grid metric from 3.997 V to 0.554 V; damping of the matched approximately 4.6 Hz mode rises to 18.99%. The mitigated least-damped *overall* mode is a different 1.843 Hz mode.

## Reproduce

Open the standalone SLX in MATLAB R2025b with Simulink, Simscape and Simscape Electrical. Press **Run** for the default baseline without running any script. The twelve live Scopes are under **Telemetry and Scopes > Live Scopes**. For scripted scenarios, use repository `analysis/run_physical_scenarios.m`, then `analysis/analyse_physical_results.py`; optional modal analysis also requires Simulink Control Design. The SLX itself needs no external `.m` file, `.mat` file or base-workspace initialization.
