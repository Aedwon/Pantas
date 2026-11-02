"""A line break inside a sentence in text a student reads.

Written on 2 November after the app showed a stem as "...is a public" and,
on the next line, "trust under Article XI...". Question text is stored in
YAML block scalars (`stem: |`), and several generation runs hard wrapped
those blocks at about 80 columns. A block scalar keeps every newline, the
question widget draws each newline as a line break, and so the wrap points
showed on screen. Lessons are unaffected: their paragraph lines are joined
with a space before they are drawn.

The fields checked are the ones a student sees: `stem`, `explanation` and
each choice's `rationale`. Passage bodies are not checked, because their
line breaks are verse or paragraph structure.

A break is flagged when the line before it stops without ending punctuation
and the next line is plain continuing text. These are left alone, because
they are deliberate: a blank line, a table row, a list item, a labeled line
("Step 2:", "Premise 1:", "I."), display math, and a line that ends a
sentence (a passage followed by its question, or a sentence per line).

A break inside `$...$` is a second finding. It is not a wrap: a `\\n` in
LaTeX such as `\\ne` was read as a newline while the file was written, so
the formula is broken and the fix is to restore the backslash, not to join.
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2] / "content" / "questions"
KEYS = ("stem", "explanation", "rationale")
HEADER = re.compile(r"^(\s*(?:- )?)(\w+): \|[-+]?\s*$")
STRUCTURAL = re.compile(
    r"^(?:[-*+]\s|\d+[.)]\s|\(?[A-Ha-h][.)]\s|\(?(?:i{1,3}|iv|vi{0,3}|ix|x)[.)]\s"
    r"|(?:I{1,3}|IV|VI{0,3}|IX|X)[.):]\s|>\s|#{1,6}\s|```|\$\$|\|"
    r"|\(?[A-Za-z]{1,2}\)|[A-Z][A-Za-z\-]{2,22}(?: [A-Z0-9IVX]{1,3}| \d+)?:\s)"
)
MIN_LINE = 35  # a shorter line before a capitalized one is a label or an item


def blocks(lines):
    """Yield (key, first_line_index, content_lines) for each literal block."""
    i = 0
    while i < len(lines):
        m = HEADER.match(lines[i])
        if m and m.group(2) in KEYS:
            base = len(m.group(1).replace("-", " "))
            j = i + 1
            while j < len(lines) and not lines[j].strip():
                j += 1
            if j < len(lines) and len(lines[j]) - len(lines[j].lstrip()) > base:
                indent = len(lines[j]) - len(lines[j].lstrip())
                k = i + 1
                while k < len(lines) and (
                    not lines[k].strip()
                    or len(lines[k]) - len(lines[k].lstrip()) >= indent
                ):
                    k += 1
                end = k
                while end > i + 1 and not lines[end - 1].strip():
                    end -= 1
                yield m.group(2), i + 1, lines[i + 1:end]
                i = k
                continue
        i += 1


def dollars(text):
    return len(re.findall(r"(?<!\\)\$", text.replace("$$", "")))


def ends_sentence(text):
    text = text.rstrip()
    return text[-1:] in ".?!:;\"”'" or text.endswith((".)", "?)"))


def findings(lines):
    """Yield (line_index, kind) for each break that should not be there."""
    for key, start, block in blocks(lines):
        open_math = 0
        for n, a in enumerate(block):
            if not a.strip():
                open_math = 0
                continue
            open_math += dollars(a)
            if n + 1 >= len(block):
                break
            b = block[n + 1]
            sa, sb = a.strip(), b.strip()
            if not sb or sa.startswith("|") or sb.startswith("|"):
                continue
            if "$$" in sa or "$$" in sb:
                continue
            at = start + n
            if open_math % 2 == 1:
                yield at, "math"
                continue
            if STRUCTURAL.match(sb) or ends_sentence(sa):
                continue
            if sb[0].islower() or (not sa.endswith("$") and len(sa) >= MIN_LINE):
                yield at, "wrap"


def run(root=None):
    root = Path(root) if root else ROOT
    for path in sorted(root.rglob("*.yaml")):
        rel = str(path.relative_to(root))
        lines = path.read_text(encoding="utf-8").splitlines()
        for at, kind in findings(lines):
            if kind == "wrap":
                print(
                    f"QBREAK\timportant\t{rel}:{at + 1}\ta line break inside a "
                    f"sentence (hard wrapped text): {lines[at].strip()[-40:]!r}"
                )
            else:
                print(
                    f"QMATHBREAK\tblocker\t{rel}:{at + 1}\ta line break inside "
                    f"$...$, likely a LaTeX command that lost its backslash: "
                    f"{lines[at].strip()[-40:]!r}"
                )


if __name__ == "__main__":
    run()
