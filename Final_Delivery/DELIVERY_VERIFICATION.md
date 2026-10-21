# Final delivery verification

Tested on Windows with MATLAB R2025b, Simulink 25.2, Simscape and Simscape Electrical. The authoritative model is `model/Vataleni_PMSG_SSO_Final.slx`. Its SHA-256 is `355CCBA5B1D58151206AC449AACB5A798604957D0A3C22D6130EBB035BA1BF5A`.

| Check | Result |
|---|---|
| Regular `.slx` file, valid Simulink package, Windows `.slx` association points to MATLAB | PASS |
| Real MATLAB `load_system`, `open_system`, update/compile, `save_system`, close and fresh reload | PASS |
| Saved default model runs to 6 s without base-workspace initialization or external scripts | PASS |
| Baseline, wind variation, weak grid and mitigation run to 6 s | PASS |
| Native PMSM with integrated d/q states and physical shaft, converters, DC capacitor and grid | PASS |
| Twelve connected native Scopes with separate displays for their input signals | PASS |
| Convergence run, 23-state linearization and 25 numerical/physical checks | PASS |
| Copy in `tmp/delivery_roundtrip/standalone/`, with no `.m` files, compiles and runs to 6 s in fresh MATLAB | PASS; DC link ends at 1400.047921 V |
| SLX extracted from final ZIP to `tmp/delivery_roundtrip/extracted/`, with no `.m` files, compiles and runs to 6 s in fresh MATLAB | PASS; DC link ends at 1400.047921 V |
| Copied and extracted SLX SHA-256 matches the authoritative model | PASS |
| PowerPoint package import, geometry and exactly three slides | PASS |
| Editable Word export and PDF have exactly three pages each | PASS |

The SLX contains a normal internal ZIP/XML structure and should be opened as one `.slx` file in MATLAB. The default model is independently runnable; the optional `VaxSim_Parameters.m` is a reference only. The top-level and controller images in `Final_Delivery/Presentation_Assets` were exported by MATLAB/Simulink. The Scope images in the delivery were captured from simulated native Scope windows; blank renderer outputs were quarantined. The plots were regenerated in MATLAB from the final physical-model CSV output.

The weak-grid response is decaying. Its FFT peak is 4.681 Hz; a nearby linearized snapshot mode is 4.638 Hz with 5.24% damping. Retuning the PLL reduces the measured early PCC q-axis standard deviation from 3.997 V to 0.554 V and raises damping of the matched approximately 4.6 Hz mode to 18.99%. This is an assumed single-turbine, averaged-converter study, not a site-calibrated instability threshold.
