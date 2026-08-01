"""Is note B any good?

Note B is the reveal's Pro note, written on a choice and addressed to the
student who picked it. This sweep is how a generated pass gets checked
without reading seven thousand of them by hand.

Every rule here is mechanical. Whether a note is *true* is a judgment pass
and is not attempted.

The rules, and why each one exists:

- **Only on wrong choices.** The correct choice already has note A. A
  rationale there is a second explanation of the same thing.
- **Not a copy of note A.** If it repeats the explanation, Pro paid for a
  duplicate.
- **Never names a letter.** Choices are reshuffled per student by
  `orderChoicesFor`, so "option B" is wrong on somebody's screen.
- **Addressed to the student, in the second person.** It is the "what you
  picked" note. A note that talks about the choice in the abstract is note
  A written twice.
- **Between 40 and 400 characters.** Under 40 says nothing. Over 400 is a
  lesson, and the reveal sets it in 13.5px marginal type.
- **No em dash.** Project-wide ban.
"""
import re
from difflib import SequenceMatcher
from pathlib import Path

from sweep_questions import load

ROOT = Path(__file__).resolve().parents[2] / "content" / "questions"

NAMES_A_LETTER = re.compile(
    r"\b(option|choice|answer)\s+[A-E]\b|\bletter\s+[A-E]\b", re.IGNORECASE
)
# "You picked the antonym" and "Check the $a$ terms" both speak to the
# student. An imperative opener is second person with the subject left out,
# so it counts. Requiring the literal word "you" flagged seventeen notes
# that were addressed to the reader perfectly well.
SECOND_PERSON = re.compile(
    r"\byou\b|\byour\b|\byou're\b"
    r"|^(check|try|look|read|count|compare|watch|remember|notice|work)\b",
    re.IGNORECASE,
)
MIN_LEN, MAX_LEN = 40, 400


def _rationales(path):
    """Read `rationale:` blocks positionally, since the shared loader does
    not parse them. Returns {choice_index_within_question: text} per
    question id, in file order."""
    out = {}
    qid = None
    choice_index = -1
    key = None
    buf = []

    def flush():
        nonlocal key, buf
        if key is not None and qid is not None:
            out.setdefault(qid, {})[choice_index] = "\n".join(buf).strip()
        key, buf = None, []

    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.rstrip()
        if key is not None:
            if line.startswith("          ") or not line.strip():
                buf.append(line.strip())
                continue
            flush()
        if line.startswith("  - id:"):
            qid = line.split("id:", 1)[1].strip()
            choice_index = -1
        elif line.startswith("      - text:"):
            choice_index += 1
        elif re.match(r"^        rationale: \|", line):
            key, buf = "rationale", []
        elif re.match(r"^        rationale: ", line):
            out.setdefault(qid, {})[choice_index] = line.split(": ", 1)[1].strip()
    flush()
    return out


def run(root=None):
    root = Path(root) if root else ROOT
    for path in sorted(root.rglob("*.yaml")):
        rel = str(path.relative_to(root))
        _, questions = load(path)
        by_question = _rationales(path)
        if not by_question:
            continue

        for q in questions:
            qid = q.get("id", "")
            notes = by_question.get(qid, {})
            if not notes:
                continue
            where = f"{rel}:{q['line']}"
            explanation = (q.get("explanation") or "").strip()

            for index, note in notes.items():
                if index < 0 or index >= len(q["choices"]):
                    print(f"NOTEB\tblocker\t{where}\trationale on a choice that does not exist")
                    continue
                choice = q["choices"][index]

                if choice["correct"]:
                    print(
                        f"NOTEB\tblocker\t{where}\trationale on the correct choice, "
                        f"which already has note A"
                    )
                if not note:
                    print(f"NOTEB\tblocker\t{where}\tempty rationale")
                    continue
                if "—" in note:
                    print(f"NOTEB\tblocker\t{where}\tem dash in a rationale")
                if NAMES_A_LETTER.search(note):
                    print(
                        f"NOTEB\tblocker\t{where}\trationale names a letter, and choices "
                        f"are reshuffled per student"
                    )
                if len(note) < MIN_LEN:
                    print(f"NOTEB\timportant\t{where}\trationale is {len(note)} characters, under {MIN_LEN}")
                if len(note) > MAX_LEN:
                    print(f"NOTEB\timportant\t{where}\trationale is {len(note)} characters, over {MAX_LEN}")
                if not SECOND_PERSON.search(note):
                    print(
                        f"NOTEB\timportant\t{where}\trationale never addresses the student, "
                        f"so it reads as a second note A"
                    )
                if explanation:
                    ratio = SequenceMatcher(None, note.lower(), explanation.lower()).ratio()
                    if ratio > 0.7:
                        print(
                            f"NOTEB\timportant\t{where}\trationale is {int(ratio * 100)}% the "
                            f"same as note A, so Pro buys a duplicate"
                        )


if __name__ == "__main__":
    run()
