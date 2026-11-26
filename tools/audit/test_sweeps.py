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
WALKTHROUGH_FIXTURES = FIXTURES / "walkthrough"
SAMPLES = Path(__file__).resolve().parents[2] / "docs" / "content" / "walkthrough-samples"
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

# Live device seeds (underlined-word defects) were fixed in Phase 1, so the
# corpus should now be clean of them; the fixture above still guards the logic.
check("live: no underlined-word device blockers remain",
      "underlined word" not in output(sweep_devices, None))
# figure-series placeholders were added in Phase 5, so its examples should now
# be clean; the fixture (broken.md) still guards the illustration logic.
check("live: figure-series examples now have placeholders",
      "figure-series.md" not in output(sweep_illustrations, None))

fx_wt = output(sweep_structure, WALKTHROUGH_FIXTURES)
check("walkthrough: clean fixture produces no structure findings",
      "clean_walkthrough.md" not in fx_wt)
check("walkthrough: retired fixture produces no structure findings",
      "retired_clean.md" not in fx_wt)
check("walkthrough: unknown frontmatter key flagged",
      "bad_frontmatter.md" in fx_wt and "unknown frontmatter keys" in fx_wt and "bogusKey" in fx_wt)
check("walkthrough: unknown ::: block flagged",
      "bad_nesting.md" in fx_wt and ":::note" in fx_wt)
check("walkthrough: :::answer inside :::why flagged",
      "bad_nesting.md" in fx_wt and ":::answer" in fx_wt and ":::why" in fx_wt)
check("walkthrough: :::check without :::answer flagged",
      "bad_nesting.md" in fx_wt and "missing :::answer" in fx_wt)
check("walkthrough: invalid :::pair slug flagged",
      "bad_pair.md" in fx_wt and "Bad_Slug" in fx_wt)
check("walkthrough: :::pair missing Wrong line flagged",
      "bad_pair.md" in fx_wt and "Wrong:" in fx_wt)
check("walkthrough: duplicate :::pair slug flagged",
      "bad_pair.md" in fx_wt and "duplicate :::pair #dup-trap" in fx_wt)
check("walkthrough: checklist item missing {#slug} flagged",
      "bad_checklist.md" in fx_wt and "missing trailing {#slug}" in fx_wt)
check("walkthrough: checklist unknown {#slug} flagged",
      "bad_checklist.md" in fx_wt and "does-not-exist" in fx_wt)
check("walkthrough: **Check:** after :::try closing ::: flagged",
      "bad_try_check.md" in fx_wt and "**Check:**" in fx_wt)
check("walkthrough: docs/content/walkthrough-samples/ passes structure sweep cleanly",
      output(sweep_structure, SAMPLES) == "")

raise SystemExit(1 if fails else 0)
