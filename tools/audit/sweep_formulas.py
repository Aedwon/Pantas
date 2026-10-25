"""Formula-completeness sweep: formulas used in solutions must be taught before Examples.

Heuristic: a display equation inside an example that contains '=' and two or
more distinct single-letter variables is treated as a formula; its variables
must all appear among the variables of display equations in teaching sections,
or be named on their own in the example's text (as in "Let the width be $w$").
Over-reports by design; judgment pass curates.
"""
import re

import lib

CMD = re.compile(r"\\[a-zA-Z]+")
SINGLE = re.compile(r"(?<![a-zA-Z])[a-zA-Z](?![a-zA-Z])")


def display_eqs(lines):
    return re.findall(r"\$\$(.+?)\$\$", "\n".join(t for _, t in lines), re.S)


NAMED = re.compile(r"(?<!\$)\$([a-zA-Z])\$(?!\$)")


def named(lines):
    """Letters an example names on their own in inline math, such as $x$ in "Let the number be $x$"."""
    return set(NAMED.findall("\n".join(t for _, t in lines)))


def letters(eq):
    return set(SINGLE.findall(CMD.sub(" ", eq)))


def run(root=None):
    for les in lib.iter_lessons(root):
        taught = set()
        for name, body in les.sections.items():
            if name != "Examples":
                for eq in display_eqs(body):
                    taught |= letters(eq)
        for ln, title, blk in lib.examples(les):
            missing, known = set(), taught | named(blk)
            for eq in display_eqs(blk):
                ls = letters(eq)
                if "=" in eq and len(ls) >= 2 and not ls <= known:
                    missing |= ls - known
            if missing:
                lib.finding("FORMULA", "important", les, ln,
                            f"example {title!r} uses formula vars {sorted(missing)} not taught before Examples")


if __name__ == "__main__":
    run()
