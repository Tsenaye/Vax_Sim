# Literature Verification

This document cross-checks the implemented model against the actual reference material in
`Background Docs/Reference articles.zip` (extracted text: `tmp/source/Referenvce/{2,4,5,6}.txt`).
Equations quoted below are transcribed directly from those files, not from memory or general
textbook knowledge. See `docs/SOURCE_AUDIT.md` for the full source list and per-source
relevance/limitation notes; this document adds equation-level traceability for the sources that
contain equations actually comparable to the implementation.

Verdict key: **MATCH** (implementation follows the same equation/structure), **MATCH WITH
DOCUMENTED ASSUMPTION** (implementation follows the same general form under a stated
simplification), **N/A** (source used for background/motivation only, not equations).

| Model component | Literature equation/concept | Implemented equation/block | Parameter source | Verdict |
|---|---|---|---|---|
| Prony modal decomposition | Wang et al. [2], Eq. (1): f̂(t) = Σ Aᵢ e^(σᵢt) cos(2πfᵢt+φᵢ) | `analyse_prony.m` fits the identical exponentially-damped-sinusoid form (validated against a synthetic signal of exactly this form, `docs/SOURCE_AUDIT.md`/report Section 10) | Algorithm form from [2]; implementation is this project's own linear-prediction fit | MATCH |
| Short-circuit ratio definition | Wang et al. [2], Eq. (2): SCR = S_ac / P_wind | `grid_filter_dynamics.m`: X_g = 1/SCR with E = 1.0 pu base voltage, so S_sc ≈ E²/X_g = SCR·S_base under matching per-unit bases | SCR concept from [2]; X/R = 10 split and R_g = X_g/(X/R) are this project's engineering assumption (`docs/PARAMETERS.md`) | MATCH WITH DOCUMENTED ASSUMPTION |
| GSC control structure | Wang et al. [2], Fig. 3: DC-voltage outer loop (K_pudc, T_iudc) → i_d,ref; reactive-power outer loop (Q_ref = 0) → i_q,ref; current inner loops (K_pdg, K_pqg) with ωL cross-coupling → v_d,ref, v_q,ref | `gsc_control_dynamics.m`: DC-voltage PI (K_p,dc, K_i,dc) → i_d*; i_q* = 0; current PI loops (K_p,i, K_i,i) with L_f cross-coupling decoupling terms → v_cd, v_cq | Structure from [2]; specific gain values are this project's own tuning for its 5 MW rating (`docs/PARAMETERS.md`, marked ENGINEERING ASSUMPTION / TUNED THROUGH VALIDATED EXPERIMENT, not copied from [2]'s Xinjiang-scale system) | MATCH |
| SSO mechanism (grid weakening) | Wang et al. [2], Section III.B.1: "with the decrease of SCR, the sub-synchronous damping varies from positive to negative...the SSO incident will happen"; frequency and damping both move with SCR | Report Section 9: SCR step 10→5 produces a mode whose real part crosses from +0.047 to (implicitly, at the threshold) negative; both FFT frequency and eigenvalue damping change with grid strength | Mechanism from [2]; the specific SCR threshold (this model: unstable at SCR=5, stable at SCR=10) and 4.8 Hz frequency are this project's own result, not copied from [2]'s reported ≈21-25 Hz / SCR<3 threshold (different machine rating and grid, correctly not conflated — see `docs/SOURCE_AUDIT.md`) | MATCH (mechanism); values independent |
| Mitigation via PLL retuning | Zhan et al. [4], Introduction: "measures to suppress SSO caused by wind turbines are by added damping controller...or optimised PLL...parameters" | Report Section 14: mitigation is PLL integral gain retuning, K_i,pll 2.80 → 0.50 | Mitigation family from [4]; this project implements the "optimised PLL parameters" branch specifically, not [4]'s own proposed HVDC-side SSDC/PR-controller scheme (this model has no HVDC stage, so that scheme does not apply and is not claimed) | MATCH |
| PMSG dq voltage/flux relations | Zhan et al. [4], Eqs. (13)-(14): U_d = R_s i_d + pΨ_d - ω_e Ψ_q, U_q = R_s i_q + pΨ_q + ω_e Ψ_d, with Ψ_d = L_d i_d + Ψ_f, Ψ_q = L_q i_q | Report Section 3.1/3.2: surface-PMSG simplification L_d = L_q, so electromagnetic torque (and hence i_q,m) is directly proportional to Ψ_f — the standard reduction of [4]'s general-salient-pole form | Equation form from [4]; L_d = L_q surface-PMSG assumption is explicitly documented in the report (Section 3.1) and `docs/PARAMETERS.md` | MATCH WITH DOCUMENTED ASSUMPTION |
| Weak-grid Thevenin/PCC representation | Wang et al. [2] Fig. 1/2 and Zhan et al. [4] Fig. 4: PMSG wind farm represented as a voltage/current source behind grid impedance, PCC voltage assumed as the coupling point | `grid_filter_dynamics.m`: infinite bus E∠0 behind X_g = 1/SCR, R_g = X_g/(X/R), PCC voltage/power computed from the same Thevenin equivalent | Representation convention from [2]/[4]; numeric grid parameters are this project's own | MATCH |
| Eigenvalue/damping/modal-frequency convention | Kundur [5], standard linear-systems convention: λ = σ ± jω, f = \|ω\|/2π, ζ = -σ/\|λ\| | `analyse_eigenvalues.m`, report Section 11. Numerically re-verified this session: λ = 0.047491 + 30.414487i ⇒ f = 30.414487/2π = 4.8406 Hz (matches reported value) and ζ = -0.047491/\|λ\| = -0.047491/30.41453 = -0.001562 (matches reported -0.00156) | Convention from [5] (general textbook reference, not PMSG-specific — see `docs/SOURCE_AUDIT.md`) | MATCH |
| Complementary time/frequency/eigenvalue methodology | Bongiorno et al. [6], pp. 3-10: frequency scanning, eigenanalysis and EMT simulation identified as complementary SSR analysis methods | Report Sections 9-12 use time-domain, FFT, Prony and eigenvalue analysis together and cross-validate them (a superset of [6]'s three methods) | Methodology framing from [6]; [6] is primarily series-compensated/DFIG-oriented and is not used for any PMSG/weak-grid parameter value (`docs/SOURCE_AUDIT.md`) | MATCH (methodology only) |
| Wind energy context | Global Wind Report 2023 [1] | Report Section 1.1 background paragraph only | Motivation/background only | N/A — no equations |

## Conventions explicitly checked

- **Sign convention**: both [2] and [4] use the same generator-convention dq frame (positive real
  power flowing from machine to grid) as this project's `pmsg_dynamics.m`/split equivalents; no
  sign inversion was needed or introduced.
- **Reference-frame orientation**: [4]'s Eq. (13) uses the standard synchronous dq frame aligned
  with rotor flux; this project's PLL-referenced dq frame for the grid-side quantities (Section
  3.7/3.8) is the standard grid-following equivalent used in converter-control literature and is
  consistent with [2] Fig. 3's PLL-referenced GSC control.
- **Per-unit vs. SI**: [2]'s SCR definition (Eq. 2) is a ratio of powers, dimensionless in either
  system; this project's implementation is fully per-unit (`docs/PARAMETERS.md` base quantities),
  consistent with [2]/[4]'s own per-unit control-block presentation (gains such as K_pdg have no
  explicit SI unit in either source).
- **Mechanical vs. electrical angular velocity**: this project's `pmsg_aerodynamics.m` explicitly
  distinguishes rotor mechanical speed (used for tip-speed ratio) from electrical angular
  frequency ω_base = 2πf (used in the dq current equations), matching the standard distinction
  implicit in [4]'s Eq. (13) (ω_e denotes electrical angular velocity).
- **Frequency band**: this project's sub-synchronous band (1-45 Hz, `docs/PARAMETERS.md`) is
  consistent with [2]'s and [4]'s usage of "sub-synchronous" to mean below the 50 Hz fundamental
  (both papers use a 50 Hz system).

## Assumptions distinguished from literature values

Every model parameter is classified in `docs/PARAMETERS.md` as LITERATURE, DERIVED, ENGINEERING
ASSUMPTION, or TUNED THROUGH VALIDATED EXPERIMENT. No parameter in this table or in
`docs/PARAMETERS.md` is presented as a literature value unless it is genuinely one (only the 5 MW
power rating is literature-sourced, from Wang et al. [2] p. 2782, "The rated capacity of one PMSG
is 5 MW"). All control gains, the SCR threshold at which this specific model becomes unstable, and
the resulting ≈4.8 Hz frequency are this project's own results, produced by its own simulation and
sweeps, and are not copied from any reference.
