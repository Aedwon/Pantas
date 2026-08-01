"""Does the question corpus support the Free and Pro split at all?

The entitlement spec gives the answer reveal two notes:

  note A, the question's `explanation`   Free and Pro both see it
  note B, the chosen choice's rationale  Pro only, and only on a miss

So two things have to be true of every question, and nothing had ever
checked either one:

1. **Note B has to exist**, or Pro buys nothing at the reveal.
2. **Note A must not already do note B's job.** An explanation that walks
   through each wrong option has spent the Pro grant on the free tier.

Source of truth for the split:
`docs/superpowers/specs/2026-08-02-pro-entitlement-consolidation-design.md`,
Section 2. The reveal's two notes are drawn in
`docs/superpowers/specs/2026-07-28-quiz-tab-design.md`, Section 3.
"""
import re
from pathlib import Path

from sweep_questions import load

ROOT = Path(__file__).resolve().parents[2] / "content" / "questions"

# Note A talking about the options rather than about the answer. Letters are
# matched only where they are named as options, so "Section 5(a)" and
# "(b) of RA 6713" do not count: an earlier pass flagged 48 of those and
# every one was a legal citation.
NAMES_AN_OPTION = re.compile(
    r"\b(option|choice|answer)s?\s+[A-E]\b"
    r"|\bthe other (option|choice|answer)s\b"
    r"|\bdistractors?\b"
    r"|\b[A-E]\s+is\s+(wrong|incorrect|not\s+correct)\b",
    re.IGNORECASE,
)

# Note A explaining why something is wrong at all. Narrower than it looks:
# it wants a verdict on an alternative, not the word "wrong" in passing.
JUDGES_AN_ALTERNATIVE = re.compile(
    r"\b(is|are)\s+(wrong|incorrect)\b"
    r"|\bwould be (wrong|incorrect)\b"
    r"|\bthe common (mistake|error)\b"
    r"|\bstudents often (pick|choose)\b",
    re.IGNORECASE,
)


def run(root=None):
    root = Path(root) if root else ROOT
    files = sorted(root.rglob("*.yaml"))

    total = 0
    without_note_b = 0
    files_without_note_b = 0

    for path in files:
        rel = str(path.relative_to(root))
        _, questions = load(path)
        if not questions:
            continue

        file_missing = 0
        for q in questions:
            total += 1
            where = f"{rel}:{q['line']}"
            explanation = (q.get("explanation") or "").strip()

            if not explanation:
                print(f"TIERA\tblocker\t{where}\tno explanation, so not even note A exists")
            else:
                if NAMES_AN_OPTION.search(explanation):
                    print(
                        f"TIERLEAK\timportant\t{where}\tnote A names the options, which is "
                        f"note B's job and is what Pro pays for"
                    )
                elif JUDGES_AN_ALTERNATIVE.search(explanation):
                    print(
                        f"TIERLEAK\tpolish\t{where}\tnote A rules on an alternative, which "
                        f"edges into note B"
                    )

            # `rationale` is the per-choice note B. The reader in
            # sweep_questions does not parse it because nothing in the corpus
            # has ever carried one; the raw text is checked instead so this
            # keeps working the day one appears.
            file_missing += 1

        raw = path.read_text(encoding="utf-8")
        if "rationale:" not in raw:
            files_without_note_b += 1
            without_note_b += file_missing
            print(
                f"TIERB\tblocker\t{rel}:1\tno choice in this file carries a rationale, "
                f"so Pro sees exactly what Free sees on every one of its "
                f"{file_missing} questions"
            )

    if without_note_b:
        print(
            f"TIERB\tblocker\t{'summary'}:1\t{without_note_b} questions across "
            f"{files_without_note_b} files have no note B at all, out of {total}"
        )


if __name__ == "__main__":
    run()
