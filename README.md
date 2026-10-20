# Vataleni PMSG + SSO Simulink Project

Self-contained reduced-order, averaged dq model of a 5 MW PMSG full-converter wind turbine for weak-grid sub-synchronous oscillation (SSO) and PLL-gain mitigation studies.

- MATLAB: R2025b
- Simulink: 25.2
- Authoritative model: `model/Vataleni_PMSG_SSO_Final.slx`
- Core custom Level-2 MATLAB S-Functions: none
- Required manual initialization: none
- Native math implementations: turbine/rotor, MSC, DC link, GSC, PLL, filter/grid current, and PCC
- Embedded MATLAB Function blocks: one, for diagnostic vector assembly and reconstructed abc waveforms

## Open and run

From the repository root in a fresh MATLAB session:

```matlab
load_system('model/Vataleni_PMSG_SSO_Final.slx');
out = sim('Vataleni_PMSG_SSO_Final');
```

The model owns its default parameters, initial conditions, solver step, stop time and scenario inputs. Project scripts are not required for the standalone run.

## Select a scenario inside the model

Open **Model Explorer > Model Workspace** for `Vataleni_PMSG_SSO_Final` and set the three variables below, then press **Run**. The grid-strength change occurs at 2 s. The default is the baseline case.

| Case | `scr_initial` | `scr_final` | `mitigation_enable` |
|---|---:|---:|---:|
| Baseline | 10 | 10 | 0 |
| Weak-grid SSO | 10 | 5 | 0 |
| Mitigated weak grid | 10 | 5 | 1 |

The 12 native Scope blocks are in **Measurements and Analysis Interface > Engineering Scopes**. They show wind, rotor, torque, converter, DC-link, PCC, PLL and active-power response channels. Each Scope has Dataset logging and a visible grid and legend; a saved-model run verified finite data from every Scope. The `parameters/VaxSim_Parameters.m` file is an optional parameter reference; the model does not call it.

## Model fidelity

The machine-side current loop is a first-order q-axis torque-current equivalent. The model does not resolve PMSG stator d/q voltage dynamics, semiconductor switching, PWM harmonics or shaft torsional modes. The 4.84 Hz SSO and damping metrics therefore characterize this reduced-order benchmark only, not a validated physical wind farm. See `docs/MODEL_EQUATIONS.md` and `docs/SOURCE_AUDIT.md` for equations and source classifications.

## Run all scenarios

```matlab
run('analysis/run_all_scenarios.m')
```

This regenerates baseline, wind-step, SSO and mitigation MAT files, CSV summaries and 17 figures.

## Validate from scratch

```matlab
run('validation/validate_project.m')
```

Headless equivalent:

```powershell
matlab -batch "cd('<repo-root>'); run('validation/validate_project.m')"
```

The validator throws an error unless all 20 checks pass.

## Outputs

- Scenario data: `results/baseline/`, `results/sso/`, `results/mitigation/`
- Compact result tables: `results/*.csv`
- Validation evidence: `results/validation/`
- Figures: `figures/`
- Technical report: `report/Vataleni_PMSG_SSO_Technical_Report.pdf` and `.docx`
- Model guide: `report/Vataleni_PMSG_SSO_Model_Guide.pdf`
- Verification report: `report/Vataleni_PMSG_SSO_Validation_Report.pdf`
- Supervisor explainer: `report/Vataleni_PMSG_SSO_Progress_Explainer.pdf`
- Architecture: `MODEL_ARCHITECTURE.md`
