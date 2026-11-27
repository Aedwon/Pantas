"""Structure sweep: sections, Solution labels, frontmatter, notation, forbidden markup."""
import re

import lib

KNOWN = ["Core Concept", "Mnemonics & Memory Aids", "Examples",
         "Speed Tricks & Shortcuts", "Traps to Watch For"]
FRONT_KEYS = ["_id", "title", "summary", "subject", "topic",
              "estimatedMinutes", "isActive"]
BITE_SIZED_KEYS = {
    "_id", "title", "summary", "subject", "topic", "estimatedMinutes",
    "isActive", "part", "partCount", "ordering", "keyPoints",
    "status", "replacedBy",
}
PAIR_OPEN_RE = re.compile(r"^:::pair\s+#([a-z0-9]+(?:-[a-z0-9]+)*)$")
CHECKLIST_ITEM_RE = re.compile(r"^\s*-\s+")
CHECKLIST_ANCHOR_RE = re.compile(r"\{#([a-z0-9]+(?:-[a-z0-9]+)*)\}\s*$")


def _heading_slug(title):
    return re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")


def _check_frontmatter(les):
    if "part" in les.front or "status" in les.front:
        extra = [k for k in les.front if k not in BITE_SIZED_KEYS]
        if extra:
            lib.finding("STRUCT", "polish", les, 1,
                        f"unknown frontmatter keys {extra}")
        return
    if list(les.front) != FRONT_KEYS:
        lib.finding("STRUCT", "polish", les, 1,
                    f"frontmatter keys {list(les.front)} differ from required order {FRONT_KEYS}")
    mins = les.front.get("estimatedMinutes", "")
    if not mins.isdigit() or not 8 <= int(mins) <= 15:
        lib.finding("STRUCT", "polish", les, 1, f"estimatedMinutes={mins!r} outside 8-15")


def _check_walkthrough_blocks(les):
    heading_slugs = set()
    for _, t in les.lines:
        m = re.match(r"^###\s+(.+)$", t)
        if m:
            heading_slugs.add(_heading_slug(m.group(1)))

    block = None
    pair_slugs = set()
    checklist_refs = []

    for ln, t in les.lines:
        stripped = t.strip()
        if stripped.startswith(":::"):
            if block is None:
                if stripped == ":::":
                    lib.finding("STRUCT", "important", les, ln,
                                "stray closing ::: with no open block")
                elif stripped == ":::answer":
                    lib.finding("STRUCT", "important", les, ln,
                                ":::answer is only allowed inside :::check or :::try")
                elif stripped in (":::check", ":::try", ":::why", ":::checklist"):
                    block = {"kind": stripped[3:], "line": ln, "answers": 0}
                elif stripped == ":::pair" or stripped.startswith(":::pair ") or stripped.startswith(":::pair\t"):
                    m = PAIR_OPEN_RE.match(stripped)
                    if m:
                        slug = m.group(1)
                        if slug in pair_slugs:
                            lib.finding("STRUCT", "important", les, ln,
                                        f"duplicate :::pair #{slug}")
                        else:
                            pair_slugs.add(slug)
                    else:
                        lib.finding("STRUCT", "important", les, ln,
                                    f"invalid :::pair header {stripped!r}; expected :::pair #kebab-slug")
                    block = {"kind": "pair", "line": ln, "has_right": False, "has_wrong": False}
                else:
                    lib.finding("STRUCT", "important", les, ln,
                                f"unknown block {stripped!r}")
                    block = {"kind": "unknown", "line": ln}
            else:
                if stripped == ":::":
                    if block["kind"] in ("check", "try") and block["answers"] == 0:
                        lib.finding("STRUCT", "important", les, block["line"],
                                    f":::{block['kind']} missing :::answer block")
                    elif block["kind"] == "pair":
                        if not block["has_right"]:
                            lib.finding("STRUCT", "important", les, block["line"],
                                        ":::pair missing 'Right:' line")
                        if not block["has_wrong"]:
                            lib.finding("STRUCT", "important", les, block["line"],
                                        ":::pair missing 'Wrong:' line")
                    block = None
                elif stripped == ":::answer":
                    if block["kind"] in ("check", "try"):
                        block["answers"] += 1
                        if block["answers"] > 1:
                            lib.finding("STRUCT", "important", les, ln,
                                        f":::{block['kind']} has multiple :::answer blocks")
                    else:
                        lib.finding("STRUCT", "important", les, ln,
                                    f":::answer not allowed inside :::{block['kind']}")
                else:
                    lib.finding("STRUCT", "important", les, ln,
                                f"nested block {stripped!r} not allowed inside :::{block['kind']}")
            continue

        if block is not None:
            if block["kind"] == "pair":
                if t.lstrip().startswith("Right:"):
                    block["has_right"] = True
                if t.lstrip().startswith("Wrong:"):
                    block["has_wrong"] = True
            elif block["kind"] == "checklist" and CHECKLIST_ITEM_RE.match(t):
                m = CHECKLIST_ANCHOR_RE.search(t)
                if not m:
                    lib.finding("STRUCT", "important", les, ln,
                                ":::checklist item missing trailing {#slug}")
                else:
                    checklist_refs.append((ln, m.group(1)))

    if block is not None:
        lib.finding("STRUCT", "important", les, block["line"],
                    f"unclosed :::{block['kind']} block")

    valid_slugs = pair_slugs | heading_slugs
    for ln, slug in checklist_refs:
        if slug not in valid_slugs:
            lib.finding("STRUCT", "important", les, ln,
                        f":::checklist anchor {{#{slug}}} does not match any :::pair or ### heading")


def _check_try_check_placement(les, title, body):
    in_try = False
    in_try_answer = False
    try_closed = False
    for bln, bt in body:
        s = bt.strip()
        if s == ":::try":
            in_try = True
            in_try_answer = False
        elif s == ":::answer" and in_try:
            in_try_answer = True
        elif s == ":::" and in_try:
            in_try = False
            in_try_answer = False
            try_closed = True
        elif re.search(r"\*\*Check:?\*\*", bt):
            if try_closed:
                lib.finding("STRUCT", "important", les, bln,
                            f"example {title!r} has **Check:** after :::try closing :::")
            elif in_try and not in_try_answer:
                lib.finding("STRUCT", "important", les, bln,
                            f"example {title!r} has **Check:** before :::answer inside :::try")


def run(root=None):
    for les in lib.iter_lessons(root):
        _check_frontmatter(les)
        names = list(les.sections)
        if "Core Concept" not in names or "Examples" not in names:
            lib.finding("STRUCT", "important", les, 1, f"missing core sections; has {names}")
        for n in names:
            if n not in KNOWN:
                lib.finding("STRUCT", "polish", les, 1,
                            f"extra section {n!r} (allowed sparingly - review in judgment pass)")
        _check_walkthrough_blocks(les)
        for ln, title, body in lib.examples(les):
            if not any(re.search(r"\*\*Solution:?\*\*", t) for _, t in body):
                lib.finding("STRUCT", "important", les, ln, f"example {title!r} has no **Solution:** label")
            _check_try_check_placement(les, title, body)
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
