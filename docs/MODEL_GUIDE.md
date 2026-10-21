# Model guide for the physical PMSG SSO system

## Purpose and runtime

`model/Vataleni_PMSG_SSO_Final.slx` is the authoritative 5 MW, 690 V wind turbine model. It runs by itself in MATLAB R2025b with Simulink, Simscape and Simscape Electrical. Open the file and press **Run**. The saved default is the 12 m/s, nominal external SCR 10 case, mitigation off, over 6 s. All mandatory initial conditions and parameters are stored in the SLX; `parameters/VaxSim_Parameters.m` is a human-readable optional reference.

## Set a scenario

In Model Explorer, open the model workspace and edit the five variables below. Changes only take effect in that MATLAB session until saved to the SLX. For repeatable evidence, run `analysis/run_physical_scenarios.m`, which does not overwrite the saved defaults.

| Variable | Default | Meaning |
|---|---:|---|
| `wind_initial` | 12 | Wind speed before the step, m/s |
| `wind_final` | 12 | Wind speed after the step, m/s |
| `wind_step_time` | 2 | Wind step time, s |
| `grid_scr` | 10 | Nominal SCR of the external RL grid impedance |
| `mitigation_enable` | 0 | 0: baseline PLL; 1: higher proportional PLL gain |

For the wind variation use `wind_final=13`; for the weak-grid case also set `grid_scr=5`; then set `mitigation_enable=1` for the comparable mitigated case. The source block has an additional 500 MVA internal short-circuit impedance. Consequently the combined Thevenin SCR is lower than the external nominal value.

## What to inspect

Follow the visible physical path left to right. Wind and pitch signals enter a native mechanical turbine. The rotor connects to an inertia and native PMSM operated in generator mode. A native three-phase sensor, averaged MSC, series DC current sensor and capacitor form the first electrical section. A second series DC current sensor, averaged GSC, three-phase sensor, RL filter, PCC sensor, external RL grid impedance and 690 V source form the grid section. Electrical and mechanical references and the Simscape solver are visible.

The MSC Control subsystem contains the speed loop, machine d/q current loops, modulation limiter and a 1 ms actuator. GSC and PLL Control contains the DC loop, grid current loops, PLL, mitigation selector and a 10 µs actuator. Both control laws are MATLAB Function blocks with explicit continuous Integrator blocks. The physical PMSM, converters, capacitor and network retain their own native physical states.

Open `Telemetry and Scopes > Live Scopes` for twelve live Scope blocks covering wind/shaft, machine currents and voltages, MSC commands, DC link and current, GSC currents and power transfer, PCC voltage and active/reactive power, PLL, SSO response and mitigation. `Data Logging` writes the same named time series to simulation output. `Derived Measurements` transforms the **measured** machine phase voltage and computes generator power, copper loss, reactive power and DC energy.

## Machine and sign conventions

The native PMSM uses current entering its terminals as positive. Its d/q equations are

`Ld did/dt = vd - Rs id + omega_e Lq iq`,

`Lq diq/dt = vq - Rs iq - omega_e (Ld id + psi_f)`,

`Te = 1.5 p [psi_f iq + (Ld-Lq) id iq]`, with `omega_e = p omega_m`.

The surface machine has `Ld=Lq`. In generator operation `iq` and native electromagnetic torque are negative, while the displayed `generator_torque` is the positive opposing shaft torque `-Te`. The current sensor is oriented outward, so the MSC Park transform negates that sensor's phase current to follow the PMSM equations. Mechanical power into the generator approximately equals generated stator electrical power plus copper loss, with a small rate of change of magnetic energy during transients.

The DC sensor signs give `I_MSC>0` into the capacitor bus and `I_GSC<0` out. The diagnostic `dc_power_net = Vdc (I_MSC + I_GSC)` must equal the rate of change of `dc_energy = C Vdc²/2`. `machine_pgen` is `-1.5(vd id+vq iq)`, using measured stator voltage. The GSC `pcc_power` is `1.5(vd id+vq iq)` with current flowing into the grid.

## Fidelity and assumptions

The native machine integrates actual stator current states; no first-order q-current surrogate exists in this model. The averaged converters represent mean phase conversion and a fixed 5 kW loss per bridge. They do not resolve switching harmonics, thermal states or protection. The shaft is a single inertial mass without flexural torsion. The empirical turbine Cp lookup, 690 V rating, machine constants, filter/grid impedances, converter losses, control gains and source strength are engineering assumptions chosen for a plausible 5 MW equivalent. The 5 MW single-machine rating is taken from Wang et al. (2019); no paper's network thresholds or numeric gains are imported.

The 6 s wind-step runs resolve the electrical/PLL SSO transient but do not establish a final wind-speed mechanical equilibrium. Mechanical speed is still increasing at 6 s after the 13 m/s step. The steady baseline at 12 m/s is separately assessed in `docs/VERIFICATION_REPORT.md`.

## Source and evidence

The model equations and native block conventions are documented by [MathWorks PMSM](https://www.mathworks.com/help/simscape-electrical/ref/pmsm.html), [averaged three-phase VSC](https://www.mathworks.com/help/simscape-electrical/ref/averagevaluevoltagesourceconverterthreephase.html), and [Wind Turbine Mechanical](https://www.mathworks.com/help/simscape-electrical/ref/windturbinemechanical.html). The weak-grid interaction and modal/Prony method follow Wang et al., DOI 10.1109/EI247390.2019.9061793, while the general PMSG flux equations are consistent with Zhan et al., DOI 10.1049/joe.2018.8811. The project validates its own numeric results; published mode frequencies are not targets.
