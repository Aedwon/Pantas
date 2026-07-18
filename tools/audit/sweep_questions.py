"""Question-corpus sweep.

The other sweeps read `content/lessons`. This one reads
`content/questions/**/*.yaml`, which nothing mechanical had looked at.

Every finding is something a machine can be sure about. Whether an answer
is *right* is a judgment pass and is not attempted here.
"""
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2] / "content" / "questions"

# The tell of a question written to a template rather than to a syllabus.
# Only the shapes that are not questions at all. An earlier version listed
# the openers it expected and flagged 822 ordinary stems, including every
# Filipino one, which is a sweep nobody reads twice.
STEM_SHAPE = re.compile(r"[?:.]\s*$|\?")
# "marks" is banned only in the score sense. Quotation marks, a store that
# marks up a price and a hallmark are all ordinary English, and a sweep
# that flags them is a sweep nobody will read twice.
BANNED_SCORE_SENSE = re.compile(
    r"\b(\d+|full|total|high|low|passing|final|raw)\s+marks\b", re.IGNORECASE
)
BANNED = {"\u2014": "em dash"}


def load(path):
    """A deliberately small YAML reader for the one shape this corpus uses.

    PyYAML is not a dependency of this repo and the question files are
    written by one generator to one template, so a parser for that
    template is honest and has no install cost.
    """
    questions = []
    meta = {}
    section = None
    current = None
    choice = None
    block_key = None
    block_lines = None

    def flush_block():
        nonlocal block_key, block_lines
        if current is not None and block_key:
            current[block_key] = "\n".join(block_lines).strip()
        block_key, block_lines = None, None

    for lineno, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = raw.rstrip()

        # A top level key ends whatever block was open. `passages:` holds
        # multi line bodies whose indentation looks exactly like a stem's,
        # so the section has to be tracked rather than inferred.
        if line and not line.startswith(" ") and line.endswith(":"):
            flush_block()
            section = line[:-1]
            current = None
            continue
        if section == "passages":
            continue

        if block_key is not None:
            if line.startswith("      ") or not line.strip():
                block_lines.append(line.strip())
                continue
            flush_block()

        if section == "meta" and re.match(r"^  \w+: ", line):
            key, value = line.strip().split(": ", 1)
            meta[key] = value
        elif line.startswith("  - id:"):
            current = {"line": lineno, "choices": []}
            questions.append(current)
            current["id"] = line.split("id:", 1)[1].strip()
        elif current is None:
            continue
        elif re.match(r"^    (stem|explanation): \|", line):
            block_key = line.strip().split(":", 1)[0]
            block_lines = []
        elif re.match(r"^    \w+:", line):
            key, _, value = line.strip().partition(": ")
            current[key] = value.strip()
        elif line.startswith("      - text:"):
            choice = {"text": line.split("text:", 1)[1].strip(), "correct": False}
            current["choices"].append(choice)
        elif line.strip() == "correct: true" and choice is not None:
            choice["correct"] = True
    flush_block()
    return meta, questions


def run(root=None):
    root = Path(root) if root else ROOT
    files = sorted(root.rglob("*.yaml"))
    seen_ids = {}
    stems_by_subtopic = defaultdict(dict)
    total = 0

    for path in files:
        rel = str(path.relative_to(root))
        meta, questions = load(path)
        total += len(questions)

        if not questions:
            print(f"QSTRUCT\tblocker\t{rel}:1\tno questions parsed from this file")
            continue

        correct_positions = []
        for q in questions:
            where = f"{rel}:{q['line']}"
            qid = q.get("id", "")

            if qid in seen_ids:
                print(f"QID\tblocker\t{where}\tduplicate id {qid}, first at {seen_ids[qid]}")
            seen_ids[qid] = where

            correct = [c for c in q["choices"] if c["correct"]]
            if len(correct) != 1:
                print(
                    f"QANSWER\tblocker\t{where}\t{len(correct)} choices marked correct, "
                    f"expected exactly 1"
                )
            if len(q["choices"]) != 4:
                print(
                    f"QCHOICES\timportant\t{where}\t{len(q['choices'])} choices, "
                    f"the corpus is otherwise 4"
                )
            if correct:
                correct_positions.append(q["choices"].index(correct[0]))
                longest = max(q["choices"], key=lambda c: len(c["text"]))
                if longest is correct[0] and len(q["choices"]) > 1:
                    others = max(
                        len(c["text"]) for c in q["choices"] if c is not correct[0]
                    )
                    if len(correct[0]["text"]) > others * 1.5:
                        print(
                            f"QLONGEST\timportant\t{where}\tthe correct choice is far the "
                            f"longest, which is a tell a student can read"
                        )

            stem = q.get("stem", "")
            if not stem:
                print(f"QSTEM\tblocker\t{where}\tno stem")
            elif len(stem) < 15:
                print(f"QSTEM\timportant\t{where}\tstem is {len(stem)} characters")
            elif not STEM_SHAPE.search(stem):
                print(
                    f"QSTEM\tpolish\t{where}\tstem ends without a question mark, "
                    f"colon or period: {stem[-40:]!r}"
                )

            explanation = q.get("explanation", "")
            if not explanation:
                print(f"QEXPLAIN\tblocker\t{where}\tno explanation")
            elif len(explanation) < 25:
                print(
                    f"QEXPLAIN\timportant\t{where}\texplanation is "
                    f"{len(explanation)} characters"
                )

            for text in (stem, explanation, *(c["text"] for c in q["choices"])):
                for banned, why in BANNED.items():
                    if banned in text:
                        print(f"QVOICE\tblocker\t{where}\t{why}")
                if BANNED_SCORE_SENSE.search(text):
                    print(
                        f"QVOICE\tblocker\t{where}\tscores are points, never marks"
                    )

            texts = [c["text"] for c in q["choices"]]
            if len(set(texts)) != len(texts):
                print(f"QCHOICES\tblocker\t{where}\ttwo choices are identical")

            key = (meta.get("subtopic", rel), stem.strip())
            if stem and key in stems_by_subtopic[meta.get("subtopic", rel)]:
                first = stems_by_subtopic[meta.get("subtopic", rel)][key]
                # Not wrong: a drill format reuses its instruction and varies
                # the sentences. It is still the same words on screen twice
                # in one subtopic, which a student notices.
                print(
                    f"QDUPE\timportant\t{where}\tstem repeats word for word the "
                    f"one at {first}"
                )
            elif stem:
                stems_by_subtopic[meta.get("subtopic", rel)][key] = where

            if "approved" in q:
                print(f"QAPPROVED\tpolish\t{where}\tcarries approved: {q['approved']}")

        # Authored answer position, before the app reorders from the id.
        if len(correct_positions) >= 8:
            first = sum(1 for p in correct_positions if p == 0)
            if first / len(correct_positions) > 0.8:
                # Informational only. `orderChoicesFor` reshuffles from the
                # question id when the app reads it, so authored position
                # never reaches a student. It matters if that ever changes.
                print(
                    f"QPOSITION\tpolish\t{rel}:1\tthe correct choice is authored "
                    f"first in {first} of {len(correct_positions)}"
                )

    print(f"QTOTAL\tpolish\t-\t{total} questions across {len(files)} files", file=sys.stderr)


if __name__ == "__main__":
    run()
