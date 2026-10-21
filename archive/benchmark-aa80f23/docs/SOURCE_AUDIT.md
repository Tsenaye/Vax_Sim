# Source Audit

The original files under `../Background Docs/` were read only. The ZIP contains `Referenvce/1.pdf`, `2.pdf`, `4.pdf`, `5.pdf`, and `6.pdf`; the misspelling is present in the archive. No claimed model result is copied from a source.

| File | Title / authors / year | Identifier | Useful content and implementation decision | Limitation |
|---|---|---|---|---|
| `221362576_Vataleni Research Proposal.pdf` and `.docx` | *Analysis and Mitigation of Sub-Synchronous Oscillations in Grid Connected PMSG-Based Wind Turbine Systems*, Stefanus I. Vataleni, 2026 | Student 221362576 | pp. 7-10 require a dynamic full-converter PMSG model, wind/grid/control variation, time-domain, eigenvalue and frequency analysis, and before/after damping control. These requirements define the scenario and test matrix. | Proposal supplies objectives, not a complete parameter set or validated plant equations. |
| `Vataleni_221362576 RPP.pptx` | Proposal presentation, Stefanus I. Vataleni, 2026, 17 slides | none | Confirms weak-grid/high-impedance emphasis and MATLAB/Simulink methodology. | Condensed repetition of proposal; not used for numeric parameters. |
| `Reference articles.zip: Referenvce/1.pdf` | *Global Wind Report 2023*, Global Wind Energy Council, 2023 | none identified | Background motivation on wind deployment only. | No PMSG control or SSO model parameters; no numerical model decision derives from it. |
| `.../2.pdf` | *Research on Sub-synchronous Oscillation Characteristics between PMSG-based Wind Farms and Weak AC Grids Based on Prony Method*, Chao Wang, Chongru Liu, Jianyu Yu, Shitian Xu, 2019 | DOI 10.1109/EI247390.2019.9061793 | pp. 2782-2786 support a controlled-current machine-side equivalent, GSC outer/inner loops, SCR definition, Prony extraction, and sensitivity to grid strength/current-controller gains. It reports a 5 MW turbine rating; this is adopted as the model power base. | PSCAD Xinjiang-network thresholds and gains are not transferred. Its farm/network differs from this single-machine equivalent. Reported frequencies are comparison context only. |
| `.../4.pdf` | *Analysis and control on Sub-synchronous oscillation (SSO) of HVDC transmission for large-scale PMSG-based wind farm integration*, Zhan Xiaoyu, Liu Chao, Wang Zhibing, 2019 | DOI 10.1049/joe.2018.8811 | pp. 2442-2444 support extracting a sub-50 Hz component and applying phase/damping compensation; reinforces that controller-mediated SSO can be mitigated through supplementary control. | HVDC topology and PR-controller gains are incompatible with the present AC-grid case, so no values are copied. |
| `.../5.pdf` | *Power System Stability and Control*, Prabha Kundur, 1994 | ISBN 0-07-035958-X | General basis for linearization, eigenvalues, modal frequency and damping-ratio interpretation. | Scanned 1201-page textbook; not specific to type-4 PMSG control. No project numeric values copied. |
| `.../6.pdf` | *The Impact of Wind Farms on Subsynchronous Resonance in Power Systems*, Massimo Bongiorno, Andreas Petersson, Evert Agneholm, 2011 | Elforsk report 11:29 | pp. 3-10 distinguish subsynchronous phenomena and identify frequency scanning, eigenanalysis and EMT simulation as complementary methods. Supports reporting all three evidence types. | Primarily series-compensated/DFIG-oriented; not evidence for the present weak-grid threshold. |

## Traceability rules used

- Literature results establish mechanisms and analysis choices, not target outputs.
- Values scaled to per unit use the local 5 MW, 690 V bases and are marked `DERIVED` in `PARAMETERS.md`.
- Unspecified machine, converter, filter, PLL and grid values are marked `ENGINEERING ASSUMPTION`.
- The benchmark PLL integral gains are marked `TUNED THROUGH VALIDATED EXPERIMENT`; the reported stability change is produced by the model and recomputed by its Jacobian.
