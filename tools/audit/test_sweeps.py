"""Seeded tests: sweeps must catch known-bad fixtures and known live defects."""
import contextlib
import io
from pathlib import Path

import lib
import sweep_structure
import sweep_devices
import sweep_illustrations
import sweep_formulas

FIXTURES = Path(__file__).parent / "fixtures"
fails = []


def output(mod, root):
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        mod.run(root)
    return buf.getvalue()


def check(name, cond):
    print(("PASS" if cond else "FAIL"), name)
    if not cond:
        fails.append(name)


fx_dev = output(sweep_devices, FIXTURES)
check("fixture: underline without markup flagged", "underlin" in fx_dev and "broken.md" in fx_dev)
check("fixture: missing answer choices flagged", "no A)-D) choices" in fx_dev)
check("fixture: clean lesson silent in device sweep", "clean.md" not in fx_dev)
check("fixture: untaught formula flagged", "not taught" in output(sweep_formulas, FIXTURES))
check("fixture: missing Solution label flagged", "no **Solution:**" in output(sweep_structure, FIXTURES))
check("fixture: figure-dependent example flagged", "broken.md" in output(sweep_illustrations, FIXTURES))

live_dev = output(sweep_devices, None)
check("live seed: context-clues underline defect", "vocabulary/context-clues.md" in live_dev)
live_ill = output(sweep_illustrations, None)
check("live seed: figure-series prose-only examples", "figure-series.md" in live_ill)

raise SystemExit(1 if fails else 0)
