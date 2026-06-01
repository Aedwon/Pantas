"""Formula-completeness sweep: formulas used in solutions must be taught before Examples.

Heuristic: a display equation inside an example that contains '=' and two or
more distinct single-letter variables is treated as a formula; its variables
must all appear among the variables of display equations in teaching sections.
Over-reports by design; judgment pass curates.
"""
import re

import lib

CMD = re.compile(r"\\[a-zA-Z]+")
SINGLE = re.compile(r"(?<![a-zA-Z])[a-zA-Z](?![a-zA-Z])")


def display_eqs(lines):
    return re.findall(r"\$\$(.+?)\$\$", "\n".join(t for _, t in lines), re.S)


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
            missing = set()
            for eq in display_eqs(blk):
                ls = letters(eq)
                if "=" in eq and len(ls) >= 2 and not ls <= taught:
                    missing |= ls - taught
            if missing:
                lib.finding("FORMULA", "important", les, ln,
                            f"example {title!r} uses formula vars {sorted(missing)} not taught before Examples")


if __name__ == "__main__":
    run()
