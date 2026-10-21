# Physical model architecture

The saved SLX has this physical sequence:

`Wind Turbine (Mechanical) -> shaft inertia and motion sensor -> PMSM used as PMSG -> machine three-phase current/voltage sensor -> averaged MSC -> series DC current sensor -> 0.408 F capacitor -> series DC current sensor -> averaged GSC -> three-phase current/voltage sensor -> RL filter -> PCC three-phase sensor -> RL grid impedance -> 690 V, 50 Hz three-phase source`.

Electrical and mechanical references and a Simscape Solver Configuration complete the connected network. Each converter has a 5 kW fixed loss in the native block. The grid source has an internal 500 MVA short-circuit parameter, so `grid_scr` specifies the **external** impedance SCR; the combined network SCR is slightly lower.

Two visible control subsystems contain their mathematical controllers, continuous integrators and finite-bandwidth actuation states. The MSC regulates rotor speed and d/q machine current. The GSC regulates DC voltage and d/q grid current, aligns its Park frame with a synchronous-reference-frame PLL, and selects a higher PLL proportional gain when mitigation is enabled. Their MATLAB Function blocks implement control laws only; they are not substitutes for the physical machine, converter or grid states.

The separate Telemetry and Scopes subsystem contains independent measured-voltage and power calculations, live data logging and twelve native Scope blocks. Global named Goto/From signals avoid crossing long diagnostic wires through the physical power path. See `artifacts/model_snapshots/physical_top_level.png` and the subsystem snapshots for actual saved-model evidence.

The model uses SI units. The machine operates in generator mode, while the native PMSM electrical convention defines positive current entering the machine; the MSC controller changes sign when it transforms its outward measured phase current. The grid sensor defines current flowing from the GSC into the network as positive. The two series DC sensors use positive current into and out of the capacitor bus respectively, so `d(0.5 C Vdc^2)/dt = Vdc (I_MSC + I_GSC)`.
