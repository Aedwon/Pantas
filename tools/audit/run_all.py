"""Run every sweep and write combined results to docs/content/audit/sweep-results.tsv."""
import contextlib
import io
from pathlib import Path

import sweep_structure
import sweep_devices
import sweep_illustrations
import sweep_formulas
import sweep_ai_tells
import sweep_questions
import sweep_tier_boundary
import sweep_note_b
import sweep_near_duplicates

OUT = Path(__file__).resolve().parents[2] / "docs" / "content" / "audit" / "sweep-results.tsv"
SWEEPS = (
    sweep_structure,
    sweep_devices,
    sweep_illustrations,
    sweep_formulas,
    sweep_ai_tells,
    sweep_questions,
    sweep_tier_boundary,
    sweep_note_b,
    sweep_near_duplicates,
)


def main():
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        for mod in SWEEPS:
            mod.run()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(buf.getvalue())
    lines = buf.getvalue().splitlines()
    print(f"{len(lines)} findings -> {OUT}")
    for sev in ("blocker", "important", "polish"):
        print(f"  {sev}: {sum(1 for l in lines if l.split(chr(9))[1] == sev)}")


if __name__ == "__main__":
    main()
