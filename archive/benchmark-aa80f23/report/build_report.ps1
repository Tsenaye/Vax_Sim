# Rebuilds the technical explainer report from the live project.
# Run from the report/ directory: powershell -File build_report.ps1
# Requires: MATLAB R2025b on PATH, pdflatex (TeX Live), pdftoppm (poppler).

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")

Write-Host "1. Fresh validation + model/test audit..."
& matlab -batch "cd('$root'); addpath(genpath(pwd)); run('scripts/validate_project.m');"

Write-Host "2. Full rebuild (model, baseline, SSO, mitigation, sweeps, figures, snapshots)..."
& matlab -batch "cd('$root'); addpath(genpath(pwd)); run('scripts/run_all.m');"

Write-Host "3. Report-specific figures (timestep sensitivity, zoomed eigenvalue map)..."
& matlab -batch "cd('$root'); addpath(genpath(pwd)); generate_report_figures();"

Write-Host "4. Compiling LaTeX (three passes for cross-references)..."
Push-Location "$PSScriptRoot/source"
& pdflatex -interaction=nonstopmode -halt-on-error main.tex | Out-Null
& pdflatex -interaction=nonstopmode -halt-on-error main.tex | Out-Null
& pdflatex -interaction=nonstopmode -halt-on-error main.tex | Out-Null
Pop-Location

Write-Host "5. Publishing final PDF..."
Copy-Item "$PSScriptRoot/source/main.pdf" "$PSScriptRoot/final/Vataleni_PMSG_SSO_Technical_Explainer.pdf" -Force

Write-Host "Done. Perform visual QA on report/final/Vataleni_PMSG_SSO_Technical_Explainer.pdf before distribution."
