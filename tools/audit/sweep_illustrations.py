"""Illustration sweep: visual topics need a placeholder in every figure-dependent example."""
import re

import lib

ALWAYS = {
    "reasoning/spatial-abstract-reasoning",
    "reasoning/mechanical-technical-reasoning",
    "mathematics/geometry",
    "testsubj/testtopic",
}
CUES = re.compile(
    r"\b(figure|diagram|graph|triangle|rectangle|circle|angle|gear|pulley|lever|"
    r"circuit|wave|vector|rotat\w*|fold\w*|shaded?|plot|number line|bar chart|pie chart)\b",
    re.I)


def run(root=None):
    for les in lib.iter_lessons(root):
        parts = les.rel.split("/")
        topic = "/".join(parts[:2]) if len(parts) >= 3 else ""
        body = "\n".join(t for _, t in les.lines)
        if topic in ALWAYS and "ILLUSTRATION:" not in body:
            lib.finding("ILLUS", "important", les, 1,
                        "visual-topic lesson has zero ILLUSTRATION placeholders")
        for ln, title, blk in lib.examples(les):
            joined = "\n".join(t for _, t in blk)
            needs = topic in ALWAYS or CUES.search(joined)
            if needs and "ILLUSTRATION:" not in joined:
                lib.finding("ILLUS", "important", les, ln,
                            f"example {title!r} is figure-dependent but has no placeholder in its block")


if __name__ == "__main__":
    run()
