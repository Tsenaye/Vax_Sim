"""Assemble the student-facing directory from validated physical-model evidence."""
from __future__ import annotations
import csv
import hashlib
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'Final_Delivery'
RESULTS = OUT / 'Results'
SRC = ROOT / 'results' / 'physical'
FIG = ROOT / 'figures' / 'physical'

for name in ('01_Baseline','02_Weak_Grid_SSO','03_Mitigation',
             '04_Comparisons','05_Scope_Captures','06_Numerical_Data'):
    (RESULTS / name).mkdir(parents=True, exist_ok=True)

def cp(src: Path, dst: Path):
    if not src.is_file():
        raise FileNotFoundError(src)
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)

model = ROOT / 'model' / 'Vataleni_PMSG_SSO_Final.slx'
digest = hashlib.sha256(model.read_bytes()).hexdigest().upper()
cp(model, OUT / model.name)
cp(ROOT / 'parameters' / 'VaxSim_Parameters.m', OUT / 'VaxSim_Parameters.m')
for stem in ('Technical_Report','Model_Guide','Validation_Report'):
    src = ROOT / 'report' / f'Vataleni_PMSG_SSO_{stem}.pdf'
    cp(src, OUT / src.name)
cp(ROOT/'report'/'DELIVERY_VERIFICATION.md',OUT/'DELIVERY_VERIFICATION.md')

for name, folder in [('baseline.csv','01_Baseline'),
                     ('weak_grid.csv','02_Weak_Grid_SSO'),
                     ('weak_grid_mitigated.csv','03_Mitigation')]:
    cp(SRC/name, RESULTS/folder/name)
cp(FIG/'04_power_balance.png',RESULTS/'01_Baseline'/'04_power_balance.png')
for name in ('01_pcc_and_dc_response.png','02_pcc_frequency.png',
             '03_machine_electrical_dynamics.png','05_physical_eigenvalues.png'):
    cp(FIG/name,RESULTS/'04_Comparisons'/name)
for name in ('06_sso_unmitigated.png','06_sso_unmitigated.pdf'):
    cp(OUT/'Presentation_Assets'/name,RESULTS/'02_Weak_Grid_SSO'/name)
for name in ('07_sso_mitigated.png','07_sso_mitigated.pdf'):
    cp(OUT/'Presentation_Assets'/name,RESULTS/'03_Mitigation'/name)
for name in ('08_scenario_comparison.png','08_scenario_comparison.pdf'):
    cp(OUT/'Presentation_Assets'/name,RESULTS/'04_Comparisons'/name)
for file in SRC.glob('*.csv'):
    cp(file,RESULTS/'06_Numerical_Data'/file.name)

with (SRC/'scenario_metrics.csv').open(newline='') as f:
    rows=list(csv.DictReader(f))
summary='| Case | Late DC voltage (V) | Late PCC power (MW) | Early PCC q std (V) |\n'
summary+='|---|---:|---:|---:|\n'
for row in rows:
    summary+=(f"| {row['case'].replace('_',' ')} | "
              f"{float(row['late_dc_voltage_V']):.2f} | "
              f"{float(row['late_pcc_active_MW']):.3f} | "
              f"{float(row['early_pcc_q_std_V']):.3f} |\n")

(RESULTS/'README_RESULTS.md').write_text(f'''# Simulation results - saved physical PMSG model

These outputs come from **`Vataleni_PMSG_SSO_Final.slx`**, SHA-256 `{digest}`. MATLAB R2025b ran the saved model for 6 s in each case. The evidence was generated after the repository source revision `0ec932fc4330bd9ae63b70914b047c8ad30b0a9e`; the final delivery commit is the HEAD of `codex/native-reconstruction`. The historical reduced-order benchmark is not used here.

## Open these first

- [Baseline power balance](01_Baseline/04_power_balance.png) and [baseline numerical output](01_Baseline/baseline.csv): approximately settled 12 m/s wind, nominal external SCR 10.
- [Unmitigated SSO waveform](02_Weak_Grid_SSO/06_sso_unmitigated.png) and [weak-grid data](02_Weak_Grid_SSO/weak_grid.csv): 12 to 13 m/s wind step at 2 s, nominal external SCR 5.
- [Mitigated waveform](03_Mitigation/07_sso_mitigated.png) and [mitigated data](03_Mitigation/weak_grid_mitigated.csv): the same weak-grid disturbance with PLL proportional gain increased to 0.02 rad/(s V).
- [Common-axis scenario comparison](04_Comparisons/08_scenario_comparison.png), [PCC and DC comparison](04_Comparisons/01_pcc_and_dc_response.png), [spectrum](04_Comparisons/02_pcc_frequency.png), and [linearized pole comparison](04_Comparisons/05_physical_eigenvalues.png).
- [Actual Simulink Scope captures](05_Scope_Captures/) show data displayed by native Scope windows after simulation.
- [Raw numerical CSVs and check tables](06_Numerical_Data/) include the wind-variation case, modal estimates, 23-state linearization results and 25 numerical checks.

## Measured comparison

{summary}
The early PCC q-axis standard deviation is measured from 2.25 to 3.25 s. The weak-grid response is a **decaying** oscillation, with 4.681 Hz FFT peak and a 4.638 Hz, 5.24% damped physical-model snapshot pole. PLL retuning reduces the early weak-grid metric from 3.997 V to 0.554 V; damping of the matched approximately 4.6 Hz mode rises to 18.99%. The mitigated least-damped *overall* mode is a different 1.843 Hz mode.

## Reproduce

Open the standalone SLX in MATLAB R2025b with Simulink, Simscape and Simscape Electrical. Press **Run** for the default baseline without running any script. The twelve live Scopes are under **Telemetry and Scopes > Live Scopes**. For scripted scenarios, use repository `analysis/run_physical_scenarios.m`, then `analysis/analyse_physical_results.py`; optional modal analysis also requires Simulink Control Design. The SLX itself needs no external `.m` file, `.mat` file or base-workspace initialization.
''',encoding='utf-8')

(OUT/'README_START_HERE.md').write_text(f'''# Start here - Vataleni PMSG-SSO delivery

## Open and run the model

Open [Vataleni_PMSG_SSO_Final.slx](Vataleni_PMSG_SSO_Final.slx) directly in MATLAB **R2025b** with **Simulink, Simscape and Simscape Electrical**. Press **Run**. The default is 12 m/s wind, nominal external SCR 10, mitigation off, 6 s, `ode15s`. No setup script is needed. `VaxSim_Parameters.m` is an optional reference for editing parameters.

The twelve Scopes are inside **Telemetry and Scopes > Live Scopes**. To choose a scenario, edit the Model Workspace variables `wind_final`, `grid_scr` and `mitigation_enable`: wind variation `(13,10,0)`, weak grid `(13,5,0)`, mitigation `(13,5,1)`. `wind_initial=12` m/s and `wind_step_time=2` s in these comparisons. Restore `(12,10,0)` for the default.

## Results and presentation

- [VIEW RESULTS](Results/README_RESULTS.md) - waveforms, comparisons, Scope captures, numerical data and the measured summary.
- [Three-slide editable PowerPoint](Vataleni_PMSG_SSO_Three_Slide_Presentation.pptx) - present this file.
- [Three-page illustrated explainer PDF](Vataleni_PMSG_SSO_Three_Page_Explainer.pdf) and [editable Word file](Vataleni_PMSG_SSO_Three_Page_Explainer.docx) - submit or share these.
- [Technical report](Vataleni_PMSG_SSO_Technical_Report.pdf), [model guide](Vataleni_PMSG_SSO_Model_Guide.pdf), and [validation report](Vataleni_PMSG_SSO_Validation_Report.pdf) - methods and engineering evidence.
- [Presentation assets](Presentation_Assets/) - actual Simulink diagram exports and native MATLAB plots.
- [Delivery verification](DELIVERY_VERIFICATION.md) - MATLAB execution and package round-trip checks.

The physical model uses a native PMSM with integrated d/q electrical dynamics and averaged converters. It studies a damped, controller/network weak-grid oscillation under the specified wind step. The 5 MW rating is literature-supported; the other machine/grid/controller numbers are project engineering assumptions. It is not site-calibrated and does not resolve PWM switching, shaft torsion, transformer saturation or protection.

**Model SHA-256:** `{digest}`. The `.slx` is one genuine MATLAB file. Its internal ZIP/XML package is the normal Simulink format; leave it intact and open the `.slx` in MATLAB. On the tested Windows installation, `.slx` is associated with MATLAB.
''',encoding='utf-8')
print('Final_Delivery core, result index and student guide assembled; SLX SHA-256',digest)
