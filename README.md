# Vataleni PMSG + SSO Simulink Project

Self-contained averaged dq model of a 5 MW PMSG full-converter wind turbine for weak-grid sub-synchronous oscillation (SSO) and PLL-gain mitigation studies.

- MATLAB: R2025b
- Simulink: 25.2
- Authoritative model: `model/Vataleni_PMSG_SSO_Final.slx`
- Core custom Level-2 MATLAB S-Functions: none
- Required manual initialization: none

## Open and run

From the repository root in a fresh MATLAB session:

```matlab
load_system('model/Vataleni_PMSG_SSO_Final.slx');
out = sim('Vataleni_PMSG_SSO_Final');
```

The model owns its default parameters, initial conditions, solver step, stop time and scenario inputs. Project scripts are not required for the standalone run.

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

The repository-level package audit can also be run without MATLAB:

```text
python3 tools/audit_slx.py
```

It verifies that the Git path is one intact SLX package, that extracted package
internals are not tracked separately, and that neither retired custom
S-Function names nor external Model Reference blocks occur in the package.

## Outputs

- Scenario data: `results/baseline/`, `results/sso/`, `results/mitigation/`
- Compact result tables: `results/*.csv`
- Validation evidence: `results/validation/`
- Figures: `figures/`
- Technical report: `report/Vataleni_PMSG_SSO_Technical_Report.pdf` and `.docx`
- Supervisor explainer: `report/Vataleni_PMSG_SSO_Progress_Explainer.pdf`
- Architecture: `MODEL_ARCHITECTURE.md`
