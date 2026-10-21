# Verification report for the saved physical model

## Verification decision

The authoritative `model/Vataleni_PMSG_SSO_Final.slx` compiled and completed the baseline, 12 to 13 m/s wind-step, weak-grid and mitigated weak-grid runs in MATLAB R2025b. The weak-grid response is a damped physical/control oscillation. It is amplified by lower external SCR and reduced by the retuned PLL. The 25 numerical relationship checks in `results/physical/engineering_checks.csv` pass. The benchmark at `benchmark-aa80f23` was not used as a source of final-model waveforms or pass counts.

## Independent evidence

| Test | Result | Evidence |
|---|---|---|
| Native physical network compilation | Pass | Saved SLX Simscape update and four 6 s runs |
| Full PMSG d and q dynamics | Pass | Measured stator voltage and current residuals, 1.86e-7 and 3.45e-7 V RMS on baseline 4 to 6 s |
| Rotor/electrical speed and torque | Pass | `omega_e=23 omega_m`; torque formula maximum error 7.45e-9 N m |
| Independent turbine/shaft torque balance | Pass | Native Cp lookup torque minus generator torque minus total-inertia acceleration has 81.2 N m RMS residual against approximately 3.2 MN m torque |
| Mechanical/electrical/copper balance | Pass | 18.81 W RMS residual against approximately 4.35 MW power flow |
| DC capacitor energy conservation | Pass | 0.97 W RMS difference between `d(0.5 C Vdc²)/dt` and `Vdc(I_MSC+I_GSC)` |
| MSC converter loss | Pass | 5000.00 W measured power difference, matching native fixed-loss setting |
| GSC and filter loss | Pass | Measured DC-to-PCC difference matches 5 kW converter plus `1.5 Rf(i_d²+i_q²)` within the stated 100 W tolerance |
| Current-reference limits | Pass | MSC q and GSC d references do not exceed 6.5 kA in the four runs |
| PLL and baseline DC control | Pass | Late baseline DC mean 1400.0499 V; PLL speed within 0.1 rad/s of 2π50 |
| Weak-grid SSO mechanism | Pass | Early PCC q standard deviation 3.997 V at external SCR 5 versus 1.788 V at SCR 10 for the same wind step |
| Mitigation on identical disturbance | Pass | Early weak-grid PCC q standard deviation falls to 0.554 V with PLL proportional gain 0.02 |
| Linearized mode | Pass | Weak-grid 23-state snapshot pole `-1.5277 ± j29.1420 s^-1`, 4.638 Hz, 5.24% damping |
| Mitigated mode | Pass | Former 4.6 Hz mode moves to `-5.5226 ± j28.5549 s^-1`, 4.545 Hz, 18.99% damping |
| No nonfinite case data | Pass | All saved scenario columns finite |
| Solver step sensitivity | Pass | Halving maximum step from 1 to 0.5 ms changes late mean DC voltage by 4.21e-5 V and PCC active power by 4.54 W |
| Twelve live native Scopes | Pass | The saved model has twelve Scope blocks connected to live From-tag signals; the clean-session audit checks logged physical channels |

The full machine-voltage residual uses the measured physical stator sensor, not the MSC voltage command. The capacitor balance uses series native current sensors, whose signs were checked directly. The native physical machine and converter blocks have electrical energy states; the diagnostic subsystem performs measurements only. MATLAB Function blocks implement the controllers and algebraic measurements. No custom S-functions or external model dependencies are required.

## Scenario record

| Run | Wind after 2 s | Nominal external SCR | Mitigation | Late DC mean V | Late PCC power MW |
|---|---:|---:|---:|---:|---:|
| Baseline | 12 m/s | 10 | Off | 1400.0499 | 4.30091 |
| Wind variation | 13 m/s | 10 | Off | 1405.2706 | 4.91566 |
| Weak grid | 13 m/s | 5 | Off | 1405.4162 | 4.91641 |
| Mitigated weak grid | 13 m/s | 5 | On | 1405.4156 | 4.91630 |

All four outputs come from the completed saved SLX. The last 0.5 s is not a final mechanical equilibrium for the 13 m/s cases; shaft acceleration continues. The baseline case is approximately settled. The physically coupled oscillation is decaying, so this validation does not claim unstable SSO or a critical SCR threshold.

## Numerical and modal methods

The physical model uses the stiff `ode15s` solver, relative tolerance `1e-5`, maximum step 1 ms, averaged 3-phase converters, a 1 ms MSC actuator and a 10 µs GSC actuator. The convergence run uses maximum step 0.5 ms with the same weak-grid disturbance and parameters. Scenario outputs are interpolated to a 10 ms grid for analysis; this grid is an export rate, not a simulation step. Physical equation residuals use central differences on that grid in the nearly settled 4 to 6 s baseline window.

The 1 to 45 Hz FFT peak of weak-grid PCC q voltage is 4.681 Hz. A 3 to 8 Hz band-limited AR(2)/Prony estimate gives `-1.4369 ± j29.3565 s^-1` (4.672 Hz; damping ratio 4.89%) over the transient. Independent Simulink Control Design snapshot linearization uses 12 m/s constant wind and a 5.5 s snapshot. It yields a 23-state closed-loop model and the 4.638 Hz weak-grid pole above. Frequency and damping need not match exactly because one estimate fits a nonlinear, disturbed trajectory and the other freezes a near-equilibrium state. Both indicate a stable oscillatory mode. The 4.6 Hz linearized mode damping increases from 5.24% to 18.99% after mitigation. The least-damped mitigated mode overall is 1.843 Hz with damping ratio 27.57%.

## Self-containment and visual review

The SLX stores the default parameters in its model workspace and native block dialogs. Analysis scripts write CSV evidence but are never called by core blocks. The top-level diagram has visible wind, machine, converter, capacitor, filter, PCC and grid equipment; the control, measured quantities, data logging and twelve Scopes are grouped. Model and internal subsystem snapshots are in `artifacts/model_snapshots/`. Named Goto/From connections carry diagnostics without a cached data source.

The physical ports create some long net lines at the top level; the exported diagram is readable at full resolution but is not a substitute for opening the SLX to inspect individual branches. Figure evidence and interface labels were reviewed after the final save.

## Remaining engineering assumptions

The 5 MW rating is supported by Wang et al. (2019); the other numeric machine, source, grid, filter, turbine and controller parameters are project engineering assumptions or tuning. The physical model has no measured site impedance, transformer, saturation, shaft torsion, switching harmonics, protection or thermal dynamics. Its validation establishes behavior of this specified averaged single-turbine system under the stated scenarios, not a prediction of a particular field event.
