# Start here - Vataleni PMSG-SSO delivery

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

**Model SHA-256:** `355CCBA5B1D58151206AC449AACB5A798604957D0A3C22D6130EBB035BA1BF5A`. The `.slx` is one genuine MATLAB file. Its internal ZIP/XML package is the normal Simulink format; leave it intact and open the `.slx` in MATLAB. On the tested Windows installation, `.slx` is associated with MATLAB.
