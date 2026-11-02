"""Seeded tests: sweeps must catch known-bad fixtures and known live defects."""
import contextlib
import io
from pathlib import Path

import lib
import sweep_structure
import sweep_devices
import sweep_illustrations
import sweep_formulas
import sweep_line_breaks

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

# Hard wrapped question text. The fixture holds a wrapped stem, a wrapped
# rationale and a broken `\\ne`, beside a table, a list, labeled lines and a
# question after a sentence end, none of which may be flagged.
fx_breaks = output(sweep_line_breaks, FIXTURES / "questions")
check("fixture: stem wrapped mid-sentence flagged",
      "line-breaks.yaml:11" in fx_breaks)
check("fixture: rationale wrapped mid-sentence flagged",
      "line-breaks.yaml:20" in fx_breaks)
check("fixture: break inside math flagged",
      "QMATHBREAK" in fx_breaks and "line-breaks.yaml:46" in fx_breaks)
check("fixture: table, list, labels and sentence ends not flagged",
      fx_breaks.count("QBREAK") == 2 and fx_breaks.count("QMATHBREAK") == 1)
check("live: no question text is wrapped mid-sentence",
      "QBREAK" not in output(sweep_line_breaks, None).replace("QMATHBREAK", ""))

# Live device seeds (underlined-word defects) were fixed in Phase 1, so the
# corpus should now be clean of them; the fixture above still guards the logic.
check("live: no underlined-word device blockers remain",
      "underlined word" not in output(sweep_devices, None))
# figure-series placeholders were added in Phase 5, so its examples should now
# be clean; the fixture (broken.md) still guards the illustration logic.
check("live: figure-series examples now have placeholders",
      "figure-series.md" not in output(sweep_illustrations, None))

raise SystemExit(1 if fails else 0)
