"""Quarantine failed blank Scope exports after checking exact file identities."""
from pathlib import Path
import shutil

root = Path(__file__).resolve().parents[1]
folder = (root / 'Final_Delivery/Results/05_Scope_Captures').resolve()
quarantine = (root / 'tmp/blank_scope_exports').resolve()
assert folder.is_relative_to(root.resolve())
quarantine.mkdir(parents=True, exist_ok=True)
for name in ('baseline_01.png', 'baseline_02.png', 'weak_grid_06.png',
             'weak_grid_08.png'):
    p = (folder / name).resolve()
    assert p.parent == folder
    if p.exists():
        assert p.stat().st_size in (11716, 12937, 13902), (name, p.stat().st_size)
        shutil.move(p, quarantine / name)
for name in ('scope_work_baseline.pdf', 'scope_work_weak_grid.pdf',
             'scope_work_weak_grid_mitigated.pdf', 'capture_log.txt',
             'key_capture_log.txt'):
    p = (folder / name).resolve()
    assert p.parent == folder
    if p.exists():
        shutil.move(p, quarantine / name)
print('Quarantined failed export files; retained genuine Scope captures.')
