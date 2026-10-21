# Standalone saved-SLX run

On 21 October 2026, the SHA-256 `d4dc9bcc27fa0a904b43eb40914887ab14503bafc3769898805618f43cdb4aaa` SLX was copied by itself into `D:\Documents\Jobs\Vax\tmp\standalone` outside the repository. A fresh MATLAB R2025b process started in that directory and ran `load_system`, `SimulationCommand=update` and `sim` without project files on its working path. The 12 s run returned 60,001 time samples by 35 finite diagnostic channels and a nonempty native Scope Dataset. The process exited successfully.

The first isolated-run wrapper made an incorrect channel-count assertion because the squeezed log was oriented as channels by time. The corrected wrapper uses the same orientation handling as the project validator. Its console output is: `Diagnostics: t=60001, y=60001x35, finite=1, scope=1. Standalone saved SLX PASS.` The final project validator independently records `[60001 35]` with all 2,100,035 values finite in `validation_summary.csv` and `final_saved_model_audit.log`.

The separate Scope configuration run loaded the saved SLX, enabled Dataset logging for all 12 native Scopes, simulated it, and asserted that each Scope Dataset contained finite data. It printed `Verified live Dataset outputs from 12 native Scope blocks.`
