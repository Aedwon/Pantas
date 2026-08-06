"""Does the explanation agree with the choice marked correct?

**This is the only mechanical check in this repository that can find a
wrong answer key.** Whether an answer is right is a judgment pass, but
whether the question *contradicts itself* is not: if the explanation
works through to one value and a different choice carries the tick, one
of the two is wrong and a student meets the disagreement.

Three tests, in order of how much they mean:

- **CONTRADICTS**: the explanation contains a wrong choice's text word for
  word and never contains the correct one. That is the strong signal.

  **It took four passes to stop this lying.** "5" matched inside "15",
  then a full stop after a word blocked the match, then a full stop after
  a number did. Each version reported dozens of good questions. **Read
  the finding before you believe it**: the two real defects it eventually
  found were reading-comprehension answers written as "33 billion" among
  distractors written as "Twenty-six billion", where the only numeral on
  the screen was the correct one.
- **ABSENT**: the correct choice's text appears nowhere in the
  explanation, and neither does any other choice. Weak on its own, so it
  is `polish`: plenty of good explanations describe the answer instead of
  repeating it.
- **DUPLICATE**: two choices in one question say the same thing. Then the
  key is arbitrary, whichever one is ticked.

Numbers are compared loosely, because `$-1$` and `-1` and `-1.0` are the
same answer written three ways.
"""
import re
from pathlib import Path

from sweep_questions import load

ROOT = Path(__file__).resolve().parents[2] / "content" / "questions"

# Apostrophes survive. A punctuation question's whole point can be
# "It's" against "Its'", and stripping them made 23 of those look like
# duplicate choices.
NOISE = re.compile(r"[$\\{}]+")


def unquote(text):
    """Remove YAML's own quoting, and only that.

    A matching pair, once. Stripping every trailing quote turned "Its'"
    into "Its" and reported three good apostrophe questions as having
    duplicate choices.
    """
    value = (text or "").strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        return value[1:-1]
    return value
SPACES = re.compile(r"\s+")
TRAILING_ZEROS = re.compile(r"^(-?\d+)\.0+$")


def canon(text):
    """Lowercase, LaTeX noise gone, spacing normalized.

    Separators survive on purpose. An earlier version stripped everything,
    which made "5" a substring of "15" and reported a dozen good questions
    as broken keys.
    """
    value = SPACES.sub(" ", NOISE.sub("", unquote(text))).strip().lower()
    match = TRAILING_ZEROS.match(value)
    return match.group(1) if match else value


def canon_cased(text):
    """[canon] without the lowercasing, for comparing choices to choices."""
    return SPACES.sub(" ", NOISE.sub("", unquote(text))).strip()


def contains(haystack, needle):
    """Whole-token containment, so 5 does not match 15 or 0.5.

    The boundary depends on the needle. A number must not be followed by a
    decimal point; a word must be allowed to be, because explanations end
    sentences: `making it a pronoun.` was read as not containing
    "pronoun" until this split existed.
    """
    if not needle:
        return False
    # Only a needle that *ends* in a digit can be truncated by a decimal
    # point. "$4\pi cm$" ends in a letter and was being blocked by the
    # full stop that ended the sentence after it.
    # The only thing a trailing dot must block is a decimal: "5" inside
    # "5.5". A dot that ends a sentence is not a truncation, and treating
    # it as one reported sixty good questions as broken keys.
    numeric = needle[-1].isdigit()
    after = r"(?!\w)(?!\.\d)" if numeric else r"(?!\w)"
    before = r"(?<!\w)(?<!\d\.)" if numeric else r"(?<!\w)"
    return re.search(before + re.escape(needle) + after, haystack) is not None


def run(root=None):
    root = Path(root) if root else ROOT
    for path in sorted(root.rglob("*.yaml")):
        rel = str(path.relative_to(root))
        _, questions = load(path)
        for q in questions:
            where = f"{rel}:{q['line']}"
            choices = q["choices"]
            correct = [c for c in choices if c["correct"]]
            if len(correct) != 1 or not choices:
                continue  # the question sweep already reports these

            # Case matters here and nowhere else. A capitalization question
            # offers "We visited manila" against "we visited Manila", and a
            # lowercasing comparison called them the same choice.
            seen = {}
            for c in choices:
                key = canon_cased(c["text"])
                if key in seen:
                    print(
                        f"QKEY\tblocker\t{where}\ttwo choices say the same thing "
                        f"({c['text'][:40]!r}), so the tick is arbitrary"
                    )
                seen[key] = c

            explanation = canon(q.get("explanation") or "")
            if not explanation:
                continue

            # A negation question's explanation names the things that *are*
            # true, which is every wrong choice. "Which is NOT a ground for
            # impeachment" listed treason and bribery and was reported as a
            # broken key. It is the opposite: the question is working.
            stem_raw = (q.get("stem") or "")
            if re.search(r"\bNOT\b|\bEXCEPT\b|\bnot true\b|\bfalse\b",
                         stem_raw, re.IGNORECASE):
                continue
            stem = canon(stem_raw)

            right = canon(correct[0]["text"])
            has_right = contains(explanation, right)
            # A value that is already in the stem is an input, not a claim
            # about the answer. `Evaluate $(-x)^2$ when $x = 2$` explains
            # itself with $-2$, which is also a distractor.
            wrong_in = [
                c for c in choices
                if not c["correct"]
                and contains(explanation, canon(c["text"]))
                and not contains(stem, canon(c["text"]))
            ]

            if not has_right and wrong_in:
                names = ", ".join(repr(c["text"][:28]) for c in wrong_in[:2])
                print(
                    f"QKEY\tblocker\t{where}\tthe explanation names {names} and "
                    f"never the choice marked correct ({correct[0]['text'][:28]!r})"
                )
            elif not has_right and not wrong_in:
                print(
                    f"QKEY\tpolish\t{where}\tthe explanation never repeats the "
                    f"correct answer, so nothing here can confirm the key"
                )


if __name__ == "__main__":
    run()
