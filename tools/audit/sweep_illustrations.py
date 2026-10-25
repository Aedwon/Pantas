"""Illustration sweep: heuristic fixtures plus exact live strategy validation."""
import re

import check_lesson_illustrations
import lib

ALWAYS = {
    "reasoning/spatial-abstract-reasoning",
    "reasoning/mechanical-technical-reasoning",
    "mathematics/geometry",
    "testsubj/testtopic",
}
CUES = re.compile(
    r"\b(figure|diagram|graph|triangle|rectangle|circle|angle|gear|pulley|lever|"
    r"circuit|wave|vector|rotat\w*|fold(?:s|ed|ing)?|shaded?|plot|number line|bar chart|pie chart)\b",
    re.I)

VISUAL_MARKER = re.compile(r"<!--\s*(?:FIGURE|ILLUSTRATION):", re.I)


def _run_heuristic(root):
    for les in lib.iter_lessons(root):
        parts = les.rel.split("/")
        topic = "/".join(parts[:2]) if len(parts) >= 3 else ""
        body = "\n".join(t for _, t in les.lines)
        if topic in ALWAYS and not VISUAL_MARKER.search(body):
            lib.finding("ILLUS", "important", les, 1,
                        "visual-topic lesson has zero visual markers")
        for ln, title, blk in lib.examples(les):
            joined = "\n".join(t for _, t in blk)
            needs = topic in ALWAYS or CUES.search(joined)
            if needs and not VISUAL_MARKER.search(joined):
                lib.finding("ILLUS", "important", les, ln,
                            f"example {title!r} is figure-dependent but has no visual marker in its block")


def run(root=None):
    if root is not None:
        _run_heuristic(root)
        return

    inventory = check_lesson_illustrations.check_inventory(
        check_lesson_illustrations.DEFAULT_STRATEGY,
        check_lesson_illustrations.DEFAULT_WORKLIST,
    )
    check_lesson_illustrations.check_lesson_marker_state(
        inventory,
        check_lesson_illustrations.DEFAULT_LESSONS,
    )


if __name__ == "__main__":
    run()
