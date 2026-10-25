"""Read the per-lesson briefs that tools/content_rewrite/build_briefs.py writes.

A brief item is one thing the rewrite must deal with. Its id is the backticked id in the
brief: a triage row id for "Fix these" and "Optional", a gap id for "CSE teaching to add".
Python 3.9 standard library only.
"""
import re

import rw_lib

ITEM_HEAD = re.compile(r"^### \d+\. `([^`]+)`\s*$")
OPTIONAL_ROW = re.compile(r"^- `([^`]+)` \(([^)]*)\):\s*(.*)$")
FIELD = re.compile(r"^- ([A-Za-z ]+):\s*(.*)$")


def _sections(text):
    """{heading: lines} for the '## ' sections of a brief."""
    sections, current = {}, None
    for line in text.split("\n"):
        if line.startswith("## "):
            current = line[3:].strip()
            sections[current] = []
        elif current is not None:
            sections[current].append(line)
    return sections


def _blocks(lines):
    """Split the lines of a section into (id, [lines]) blocks that start at '### N. `id`'."""
    blocks, current = [], None
    for line in lines:
        match = ITEM_HEAD.match(line)
        if match:
            current = (match.group(1), [])
            blocks.append(current)
        elif current is not None:
            current[1].append(line)
    return blocks


def _fix_item(item_id, lines):
    item = {"id": item_id, "rule": "", "size": "", "quote": "", "problem": "", "text": "\n".join(lines).strip()}
    in_quote, quote = False, []
    for line in lines:
        if line.startswith(">"):
            if in_quote:
                quote.append(line[1:].lstrip(" ") if line != ">" else "")
            continue
        in_quote = False
        match = FIELD.match(line)
        if not match:
            continue
        name, value = match.group(1).strip().lower(), match.group(2).strip()
        if name == "rule":
            item["rule"] = value
        elif name == "fix size":
            item["size"] = value
        elif name == "quote":
            in_quote = True
        elif name == "problem":
            item["problem"] = value
    item["quote"] = "\n".join(quote).strip()
    return item


def parse_brief(text):
    """{lesson_id, path, title, exams, fix, gaps, optional, figures} for one brief file."""
    first = text.split("\n", 1)[0]
    title = first[len("# Brief:"):].strip() if first.startswith("# Brief:") else ""
    meta = {}
    for key, pattern in (("lesson_id", r"^Lesson id: `([^`]+)`"), ("path", r"^Lesson path: `([^`]+)`"),
                         ("exams", r"^Tagged exams: (.*)$")):
        match = re.search(pattern, text, re.M)
        if not match:
            raise rw_lib.RewriteError("a brief has no %s line" % key)
        meta[key] = match.group(1).strip()
    sections = _sections(text)
    fix = [_fix_item(i, lines) for i, lines in _blocks(sections.get("Fix these", []))]
    gaps = [{"id": i, "text": "\n".join(lines).strip()} for i, lines in _blocks(sections.get("CSE teaching to add", []))]
    optional = []
    for line in sections.get("Optional, fix only if editing that passage anyway", []):
        match = OPTIONAL_ROW.match(line)
        if match:
            optional.append({"id": match.group(1), "rule": match.group(2), "text": match.group(3)})
    figures = "\n".join(sections.get("Figures", [])).strip()
    return {
        "lesson_id": meta["lesson_id"], "path": meta["path"], "title": title,
        "exams": [e.strip() for e in meta["exams"].split(",") if e.strip()],
        "fix": fix, "gaps": gaps, "optional": optional, "figures": figures, "text": text,
    }


def item_ids(brief):
    """Every item id in the brief, in the order the brief lists them."""
    return [x["id"] for x in brief["fix"]] + [x["id"] for x in brief["gaps"]] + [x["id"] for x in brief["optional"]]


def load_all(ctx):
    """{lesson_id: brief} for every lesson brief in the worktree. new-lessons.md is not a lesson brief."""
    folder = ctx.root / rw_lib.BRIEFS_REL
    briefs = {}
    for path in sorted(folder.glob("lesson-*.md")):
        brief = parse_brief(path.read_text(encoding="utf-8"))
        if path.stem != brief["lesson_id"]:
            raise rw_lib.RewriteError("brief file %s does not match its lesson id" % path.name)
        briefs[brief["lesson_id"]] = brief
    return briefs
