"""Two questions that ask the same thing in different words.

A student can meet both in one session. It reads as padding, and it is:
the second one measures nothing the first did not.

The earlier question sweep catches stems that repeat **word for word**.
This catches the reworded ones, which is the shape a generator produces.

The test is deliberately narrow, because a loose one flags every drill in
a grammar file:

- same subtopic file
- **the same correct answer text**
- stems more than 60% similar once numbers and punctuation are stripped

All three have to hold. Two questions with the same answer and different
stems are usually fine.

**It over-reports on templated drills, and that is expected.** A truth
table file asks "if P is true and Q is false" fifteen times over, and a
subject-verb file opens every question with "Choose the correct verb".
Those are the same shape by design and are not duplicates. So findings
here are `polish`: read them, dismiss the drills, keep the prose ones.
**The two confirmed cases so far are both prose**, in General
Information, where the same fact is asked twice in different words.
"""
import re
from difflib import SequenceMatcher
from pathlib import Path

from sweep_questions import load

ROOT = Path(__file__).resolve().parents[2] / "content" / "questions"
THRESHOLD = 0.6

STRIP = re.compile(r"[^a-z ]+")
FILLER = {
    "the", "a", "an", "of", "to", "in", "is", "are", "which", "what", "for",
    "under", "within", "from", "that", "must", "be", "and", "or", "on", "by",
    "how", "many", "does", "do", "following", "this", "these", "at", "with",
}


def normalize(stem):
    words = STRIP.sub(" ", stem.lower()).split()
    return " ".join(w for w in words if w not in FILLER)


def run(root=None):
    root = Path(root) if root else ROOT
    for path in sorted(root.rglob("*.yaml")):
        rel = str(path.relative_to(root))
        _, questions = load(path)

        by_answer = {}
        for q in questions:
            correct = [c for c in q["choices"] if c["correct"]]
            if not correct:
                continue
            by_answer.setdefault(correct[0]["text"].strip(), []).append(q)

        for answer, group in by_answer.items():
            if len(group) < 2:
                continue
            for i in range(len(group)):
                for j in range(i + 1, len(group)):
                    a, b = group[i], group[j]
                    stem_a = (a.get("stem") or "").strip()
                    stem_b = (b.get("stem") or "").strip()
                    ratio = SequenceMatcher(
                        None, normalize(stem_a), normalize(stem_b)
                    ).ratio()
                    # And on the raw text, numbers included. Stripping digits
                    # makes "Solve $2x + 3 = 7$" and "Solve $2(x + 3) = 10$"
                    # identical, and in Mathematics the numbers are the
                    # question. Both had the answer $2$, and both were
                    # reported as duplicates until this line existed.
                    raw = SequenceMatcher(None, stem_a, stem_b).ratio()
                    if ratio >= THRESHOLD and raw >= THRESHOLD:
                        print(
                            f"QDUPE\tpolish\t{rel}:{b['line']}\t{b['id']} asks what "
                            f"{a['id']} asks, {int(ratio * 100)}% the same and the same "
                            f"answer"
                        )


if __name__ == "__main__":
    run()
