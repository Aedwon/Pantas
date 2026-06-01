"""Structure sweep: sections, Solution labels, frontmatter, notation, forbidden markup."""
import re

import lib

KNOWN = ["Core Concept", "Mnemonics & Memory Aids", "Examples",
         "Speed Tricks & Shortcuts", "Traps to Watch For"]
FRONT_KEYS = ["_id", "title", "summary", "subject", "topic",
              "estimatedMinutes", "isActive"]


def run(root=None):
    for les in lib.iter_lessons(root):
        if list(les.front) != FRONT_KEYS:
            lib.finding("STRUCT", "polish", les, 1,
                        f"frontmatter keys {list(les.front)} differ from required order {FRONT_KEYS}")
        mins = les.front.get("estimatedMinutes", "")
        if not mins.isdigit() or not 8 <= int(mins) <= 15:
            lib.finding("STRUCT", "polish", les, 1, f"estimatedMinutes={mins!r} outside 8-15")
        names = list(les.sections)
        if "Core Concept" not in names or "Examples" not in names:
            lib.finding("STRUCT", "important", les, 1, f"missing core sections; has {names}")
        for n in names:
            if n not in KNOWN:
                lib.finding("STRUCT", "polish", les, 1,
                            f"extra section {n!r} (allowed sparingly - review in judgment pass)")
        for ln, title, body in lib.examples(les):
            if not any(re.search(r"\*\*Solution:?\*\*", t) for _, t in body):
                lib.finding("STRUCT", "important", les, ln, f"example {title!r} has no **Solution:** label")
        for ln, t in les.lines:
            if re.search(r"\\frac\b", t):
                lib.finding("STRUCT", "polish", les, ln, "\\frac used (style guide requires \\dfrac)")
            if t.lstrip().startswith("|"):
                lib.finding("STRUCT", "important", les, ln, "table markup (forbidden by style guide)")
            if "](http" in t:
                lib.finding("STRUCT", "important", les, ln, "link (forbidden by style guide)")
            if t.startswith("```"):
                lib.finding("STRUCT", "important", les, ln, "code fence (forbidden by style guide)")
            if "![" in t:
                lib.finding("STRUCT", "important", les, ln, "image markup (forbidden by style guide)")


if __name__ == "__main__":
    run()
