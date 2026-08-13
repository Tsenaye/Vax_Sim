# Vataleni PMSG + SSO Model Architecture

## Authoritative artifact

`model/Vataleni_PMSG_SSO_Final.slx` is the only authoritative model. It is a self-contained Simulink file: core system equations and controller states are implemented with native Integrator blocks and MATLAB Function blocks whose source is stored inside the SLX.

The model has no external custom Level-2 MATLAB S-Function dependency, no model callback, no base-workspace initialization requirement, no unresolved library link and no machine-specific path.

## Top-level subsystems

| Subsystem | Inputs | Primary outputs | Continuous states |
|---|---|---|---|
| Wind Turbine + PMSG | wind speed, machine q-axis current | rotor speed, mechanical power, diagnostic vector | `omega_r` |
| MSC Control | rotor speed | machine q-axis current, diagnostic vector | `iq_m`, `xi_speed` |
| DC Link | mechanical power, rotor speed, grid power | DC-link voltage | `vdc` |
| GSC Control | DC voltage, grid `id/iq`, mechanical power | converter `vcd/vcq`, diagnostic vector | `xi_dc`, `xi_id`, `xi_iq` |
| PLL | PCC `vq`, mitigation selector | angle, pu frequency deviation, diagnostic vector | `delta_pll`, `xi_pll` |
| Grid Current Dynamics | converter voltage, PLL angle/frequency, SCR | grid `id/iq`, diagnostic vector | `id`, `iq` |
| PCC Interface | PLL angle, grid `id/iq`, SCR | PCC `vq`, active power, diagnostic vector | none |
| Measurements and Analysis Interface | seven diagnostic vectors/scalars plus time | 35-channel log vector | none |

The diagnostic vectors exist only to keep result routing compact. They do not change the physical/control signal paths.

## Governing equations

### Wind turbine and PMSG rotor

The embedded aerodynamic function evaluates the documented exponential `Cp(lambda,beta)` fit, clips `Cp` to `[0, 0.50]`, and limits mechanical power to `1.15 pu`.

```text
lambda = omega_r * omega_base * R / v_w
P_m = 0.5 * rho * A * Cp * v_w^3 / S_base
T_m = P_m / omega_r
d(omega_r)/dt = [T_m - iq_m - D(omega_r - 1)] / (2H)
```

### Machine-side control

```text
iq_m_ref = Kp_speed(omega_r - 1) + xi_speed
d(iq_m)/dt = (iq_m_ref - iq_m) / tau_current
d(xi_speed)/dt = Ki_speed(omega_r - 1)
```

The machine electrical inner loop is an averaged q-axis torque-current channel. Machine d-axis current is zero; switching-level machine voltage references are outside the declared fidelity.

### DC link

```text
d(vdc)/dt = (P_m * omega_r - P_grid) / [C_pu * max(vdc, 0.25)]
```

The denominator guard represents DC under-voltage protection against numerical division by zero.

### Grid-side control

```text
id_ref = P_m + Kp_dc(vdc - vdc_ref) + xi_dc
iq_ref = 0
vcd = E + Kp_current(id_ref - id) + xi_id - Xf*iq
vcq = Kp_current(iq_ref - iq) + xi_iq + Xf*id
d(xi_dc)/dt = Ki_dc(vdc - vdc_ref)
d(xi_id)/dt = Ki_current(id_ref - id)
d(xi_iq)/dt = Ki_current(iq_ref - iq)
```

### PLL

```text
domega_pll_pu = Kp_pll*vq + xi_pll
d(delta_pll)/dt = omega_base*domega_pll_pu
d(xi_pll)/dt = Ki_pll*vq
Ki_pll = 2.8 (base) or 0.5 (mitigated)
```

### Grid current and PCC

With `Xg=1/SCR`, `Rg=Xg/(X/R)`, `Lt=Xf+Xg` and `Rt=Rf+Rg`:

```text
vd = E*cos(delta) + Rg*id - Xg*iq
vq = -E*sin(delta) + Rg*iq + Xg*id
P = vd*id + vq*iq
Q = vq*id - vd*iq

d(id)/dt = omega_base/Lt * [vcd - E*cos(delta) - Rt*id
                            + Lt*(1+domega_pll_pu)*iq]
d(iq)/dt = omega_base/Lt * [vcq + E*sin(delta) - Rt*iq
                            - Lt*(1+domega_pll_pu)*id]
```

## Model-workspace parameters

The SLX model workspace stores only deterministic scenario defaults used by native Step and Constant blocks:

| Variable | Default |
|---|---:|
| `wind_nom` | 12 m/s |
| `wind_step` | 12 m/s |
| `wind_step_time` | 4 s |
| `scr_initial` | 10 |
| `scr_final` | 10 |
| `grid_disturbance_time` | 2 s |
| `mitigation_enable` | 0 |

Fixed physical/controller constants and initial conditions are compiled into the embedded MATLAB Function and Integrator block parameters when the model is built. Scenario automation overrides the model-workspace variables with `Simulink.SimulationInput`; a standalone default run needs no override.

## Solver and sample-time configuration

- Model type: continuous averaged nonlinear system
- Solver: `ode4` classical Runge-Kutta
- Solver type: fixed-step
- Step: `2e-4 s`
- Stop time: `12 s`
- Continuous states: 11
- Algebraic loops: 0
- Zero-crossing-dependent dynamics: none

A fresh `1e-3, 5e-4, 2e-4, 1e-4 s` sensitivity sweep reports the SSO frequency as `4.8370, 4.8370, 4.8447, 4.8447 Hz`; `2e-4 s` is converged to the refined result at the reported precision.

## Scenario mechanism

All scenarios use the same SLX:

| Scenario | SCR | Wind | Mitigation |
|---|---|---|---|
| baseline | 10 to 10 | 12 m/s | off |
| wind_step | 10 to 10 | 12 to 10.5 m/s at 4 s | off |
| sso_before | 10 to 5 at 2 s | 12 m/s | off |
| sso_after | 10 to 5 at 2 s | 12 m/s | on (`Ki_pll=0.5`) |

## Logging

The Measurements and Analysis Interface exports 35 channels: wind, mechanical states and powers, PMSG current/reference, DC voltage, grid dq currents and references, GSC commands, PCC voltage/power, PLL angle/frequency/gain, SCR, aerodynamic coefficients and reconstructed phase-a voltage/current. `scripts/run_case.m` assigns stable field names and stores one `R` structure per scenario.

## Algebraic-loop statement

Native Integrator state outputs break every dynamic feedback cycle physically. No Memory, Unit Delay or artificial loop-breaking element exists in the final model. `Simulink.BlockDiagram.getAlgebraicLoops` returns zero.

## Dependency statement

The authoritative SLX compiles and simulates without any file under `scripts/`. External MATLAB code is retained only for scenario automation, nonlinear reference analysis, FFT/Prony/eigenvalue calculation, figure generation and validation. It is not called by core model blocks or callbacks.
