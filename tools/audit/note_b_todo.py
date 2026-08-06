"""What is left of note B, and what to run next.

Note B is the reveal's Pro note. Until every wrong choice has one, a Pro
subscriber gets nothing extra on the questions that do not.

Run it with no arguments to see the state:

    python3 tools/audit/note_b_todo.py

It prints the subjects, the files still to do, and the dispatch line for
the next one.
"""
import sys
from pathlib import Path

from sweep_questions import load

ROOT = Path(__file__).resolve().parents[2] / "content" / "questions"

PLAN = "docs/superpowers/plans/2026-08-13-content-note-b-generation.md"


def main(root=None):
    root = Path(root) if root else ROOT
    by_subject = {}

    for path in sorted(root.rglob("*.yaml")):
        subject = path.relative_to(root).parts[0]
        _, questions = load(path)
        has_notes = "rationale:" in path.read_text(encoding="utf-8")
        entry = by_subject.setdefault(subject, {"done": [], "todo": [], "q": 0})
        entry["q"] += len(questions)
        entry["done" if has_notes else "todo"].append(
            (str(path.relative_to(root)), len(questions))
        )

    remaining = 0
    print(f"{'subject':24s} {'files':>12s}  {'questions left':>14s}")
    for subject, entry in sorted(by_subject.items()):
        left = sum(n for _, n in entry["todo"])
        remaining += left
        total = len(entry["done"]) + len(entry["todo"])
        state = "done" if not entry["todo"] else f"{len(entry['done'])}/{total}"
        print(f"{subject:24s} {state:>12s}  {left:>14d}")
    print(f"\n{remaining} questions still have no note B.")

    nxt = next(
        (s for s, e in sorted(by_subject.items()) if e["todo"]),
        None,
    )
    if nxt is None:
        print("\nNothing left. Every wrong choice carries a note.")
        return

    print(f"\nNext subject: {nxt}. Files still to do:")
    for rel, count in by_subject[nxt]["todo"][:8]:
        print(f"  {rel}  ({count} questions)")
    if len(by_subject[nxt]["todo"]) > 8:
        print(f"  ... and {len(by_subject[nxt]['todo']) - 8} more")

    print(
        "\nTo dispatch it, from the repository root, in a fresh worktree:\n"
        f"  agy --model gemini-3.6-flash-high --effort high \\\n"
        f"    --dangerously-skip-permissions --add-dir <worktree> \\\n"
        f"    --print-timeout 30m --prompt \"...execute {PLAN}, "
        f"subject {nxt}, files without a rationale...\"\n"
        "\nRead the notes before merging. One in twenty has a wrong claim,\n"
        "and no sweep can catch that."
    )


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else None)
