"""Referenced-device sweep: every device a question mentions must actually exist."""
import re

import lib

CHOICE = re.compile(r"^(?:[*-]\s*)?\(?[A-D][).]")
QUESTION_CUES = re.compile(
    r"which of the following|select the (word|phrase|answer|option)|among the (following|choices)",
    re.I)
FIGURE_CUES = re.compile(
    r"\b(as )?shown (above|below)\b|\bthe (figure|diagram|illustration) (above|below|shows)\b",
    re.I)
ITALIC = re.compile(r"(?<!\*)\*[^*\s][^*]*\*(?!\*)")


def run(root=None):
    for les in lib.iter_lessons(root):
        for ln, title, blk in lib.examples(les):
            joined = "\n".join(t for _, t in blk)
            has_choices = (any(CHOICE.match(t.strip()) for _, t in blk)
                           or re.search(r"\(A\).+\(B\)", joined, re.S))
            if re.search(r"underlin", joined, re.I) and "<u>" not in joined:
                for l, t in blk:
                    if re.search(r"underlin", t, re.I):
                        lib.finding("DEVICE", "blocker", les, l,
                                    f"example {title!r} references an underlined word but has "
                                    "no <u> markup (markdown cannot underline)")
            for l, t in blk:
                if QUESTION_CUES.search(t) and not has_choices:
                    lib.finding("DEVICE", "blocker", les, l,
                                f"example {title!r} says choose-from-options but lists no A)-D) choices")
                if re.search(r"\bbold-?faced?\b", t, re.I) and "**" not in joined:
                    lib.finding("DEVICE", "blocker", les, l,
                                f"example {title!r} mentions a boldfaced word but has no bold markup")
                if re.search(r"\bitalicized\b", t, re.I) and not ITALIC.search(joined):
                    lib.finding("DEVICE", "blocker", les, l,
                                f"example {title!r} mentions an italicized word but has no italics")
                if FIGURE_CUES.search(t) and "ILLUSTRATION:" not in joined:
                    lib.finding("DEVICE", "important", les, l,
                                f"example {title!r} refers to a figure but has no ILLUSTRATION placeholder")


if __name__ == "__main__":
    run()
