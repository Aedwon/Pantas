"""A distractor lengthened with adverbs instead of ideas.

Written on 13 August after a run "fixed" 193 over-short distractors by
stuffing words into them:

    "Yes: the time variable formally does not actually mathematically
    affect the final calculated power value in any given physical
    situation."

**That is a worse tell than the length was.** A student spots the padded
option faster than the long one, so the question still measures nothing.
All 39 files were thrown away, and this sweep exists so the next attempt
gets caught by a machine rather than by somebody reading diffs.

The test is a count, not a judgment: three or more of these hedges in one
choice is padding. Ordinary writing uses one.
"""
import re
from pathlib import Path

from sweep_questions import load

ROOT = Path(__file__).resolve().parents[2] / "content" / "questions"

HEDGES = (
    "actually", "formally", "technically", "structurally", "functionally",
    "explicitly", "exclusively", "fundamentally", "universally", "mathematically",
    "physically", "logically", "strictly", "purely", "completely", "absolutely",
    "specifically", "given", "final", "total", "standard", "simple",
)
HEDGE = re.compile(r"\b(" + "|".join(HEDGES) + r")\b", re.IGNORECASE)
LIMIT = 3


def run(root=None):
    root = Path(root) if root else ROOT
    for path in sorted(root.rglob("*.yaml")):
        rel = str(path.relative_to(root))
        _, questions = load(path)
        for q in questions:
            for choice in q["choices"]:
                found = HEDGE.findall(choice["text"])
                if len(found) >= LIMIT:
                    which = ", ".join(sorted({f.lower() for f in found}))
                    print(
                        f"QPAD\timportant\t{rel}:{q['line']}\ta choice carries "
                        f"{len(found)} hedges ({which}), which reads as padding"
                    )


if __name__ == "__main__":
    run()
