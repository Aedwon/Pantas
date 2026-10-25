"""Checks on one rewritten lesson: what it may not get worse at, and what changed.

Reasons returned from here are shown to the chat through GitHub, so they hold rule ids,
counts and line numbers only, never lesson text.
Python 3.9 standard library only.
"""
import collections
import contextlib
import difflib
import importlib
import io
import re
import sys
import tempfile
from pathlib import Path

import rw_lib

import l4lib  # noqa: E402  (vendored)
import mechanical  # noqa: E402  (vendored)

AUDIT_DIR = rw_lib.RELAY_DIR.parents[1] / "audit"
# A new finding in these classes rejects the lesson. AI-TELL and FORMULA are counts the lead and reader watch, not gates:
# FORMULA is a rough heuristic that flagged correct examples defining their own letters.
BLOCKING_SWEEPS = ("STRUCT", "DEVICE", "ILLUS")
SWEEP_MODULES = ("sweep_structure", "sweep_devices", "sweep_illustrations", "sweep_formulas", "sweep_ai_tells")
MIN_LENGTH_SHARE = 0.6
COVER_TOKENS = 3

STOP_WORDS = frozenset("""
lesson lessons example examples teaching teaches taught section sections student students explain explained
explains because which their there without about after before other these those being should would could where
while never first every state states stated using uses used rule claim fact facts unconfirmed required require
requires within between already still also only then than that this with from have into more most much when what
text paragraph sentence sentences problem reason size small medium large missing needs need never always
""".split())


def _sweeps():
    if str(AUDIT_DIR) not in sys.path:
        sys.path.insert(0, str(AUDIT_DIR))
    return [importlib.import_module(name) for name in SWEEP_MODULES]


def sweep_findings(text, rel):
    """Run the lesson sweeps on one lesson. rel is its path under content/lessons.

    Returns a list of (class, severity, line, message). The sweeps scan a folder, so the lesson
    is written alone into a temporary folder at the same relative path.
    """
    found = []
    with tempfile.TemporaryDirectory() as folder:
        target = Path(folder) / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text, encoding="utf-8")
        for module in _sweeps():
            buffer = io.StringIO()
            with contextlib.redirect_stdout(buffer):
                module.run(root=folder)
            for row in buffer.getvalue().splitlines():
                parts = row.split("\t")
                if len(parts) < 4:
                    continue
                line = parts[2].rsplit(":", 1)[-1]
                found.append((parts[0], parts[1], int(line) if line.isdigit() else 0, parts[3]))
    return found


def _count(rows, key):
    return collections.Counter(key(row) for row in rows)


def bad_markers(text):
    """Lines holding an HTML comment that is not closed on its own line, or an empty illustration marker."""
    bad = []
    for number, line in enumerate(text.split("\n"), 1):
        if "<!--" in line and "-->" not in line:
            bad.append(number)
        elif re.search(r"<!--\s*ILLUSTRATION:\s*-->", line):
            bad.append(number)
    return bad


def check_rewrite_text(base, new, path):
    """(reasons, notes) for a rewritten lesson compared with the version it replaces."""
    reasons, notes = [], []
    try:
        parsed = l4lib.parse_lesson(new)
    except l4lib.L4Error:
        return ["the lesson does not parse: it needs a frontmatter block that opens and closes with ---"], notes
    try:
        base_parsed = l4lib.parse_lesson(base)
    except l4lib.L4Error:
        base_parsed = None
    base_id = base_parsed["raw_frontmatter"].get("_id") if base_parsed else None
    if base_id is not None and parsed["raw_frontmatter"].get("_id") != base_id:
        reasons.append("the frontmatter _id changed; it must stay exactly as it was")
    if base_parsed is not None and len(new) < MIN_LENGTH_SHARE * len(base):
        reasons.append("the lesson is under %d%% of the length of the current one; write the whole lesson, "
                       "not part of it" % int(MIN_LENGTH_SHARE * 100))

    parts = rw_lib.path_parts(path)
    new_found = mechanical.check_lesson(new, parts)
    old_found = mechanical.check_lesson(base, parts) if base_parsed is not None else []
    old_counts = _count([f for f in old_found if not f["candidate"]], lambda f: (f["rule"], f["problem"]))
    grouped = collections.OrderedDict()
    for finding in new_found:
        if not finding["candidate"]:
            grouped.setdefault((finding["rule"], finding["problem"]), []).append(finding["line"])
    for (rule, problem), lines in grouped.items():
        if len(lines) > old_counts.get((rule, problem), 0):
            reasons.append("rule %s (%s) has more definite findings than before; lines %s"
                           % (rule, problem, ", ".join(str(n) for n in lines[:12])))

    rel = rw_lib.lesson_rel(path)
    old_sweep = _count(sweep_findings(base, rel), lambda row: (row[0], row[1], row[3])) if base_parsed else {}
    new_rows = sweep_findings(new, rel)
    new_counts = _count(new_rows, lambda row: (row[0], row[1], row[3]))
    for cls in sorted({key[0] for key in new_counts}):
        extra_lines, blocking = [], False
        for key, count in new_counts.items():
            if key[0] != cls:
                continue
            more = count - old_sweep.get(key, 0)
            if more > 0:
                extra_lines += [row[2] for row in new_rows if (row[0], row[1], row[3]) == key][-more:]
                # A polish finding asks for judgment, so it goes to the reader instead of rejecting.
                blocking = blocking or key[1] != "polish"
        if not extra_lines:
            continue
        if cls in BLOCKING_SWEEPS and blocking:
            reasons.append("sweep %s found %d more than before; lines %s"
                           % (cls, len(extra_lines), ", ".join(str(n) for n in sorted(set(extra_lines))[:12])))
        else:
            notes.append("sweep %s count rose by %d" % (cls, len(extra_lines)))

    if len(bad_markers(new)) > len(bad_markers(base)):
        reasons.append("an HTML comment is not closed on its own line, or an ILLUSTRATION marker is empty; "
                       "write <!-- ILLUSTRATION: one line describing the figure --> on a single line; lines %s"
                       % ", ".join(str(n) for n in bad_markers(new)[:12]))
    return reasons, notes


# ---- change guard ----------------------------------------------------------

def paragraphs(text):
    """[(first line number, text)] for the body of a lesson: runs of non-blank lines."""
    parsed = l4lib.parse_lesson(text)
    out, current, start = [], [], None
    for offset, line in enumerate(parsed["body"].split("\n")):
        if line.strip():
            if not current:
                start = parsed["body_first_line"] + offset
            current.append(line)
        elif current:
            out.append((start, "\n".join(current)))
            current = []
    if current:
        out.append((start, "\n".join(current)))
    return out


def tokens(text):
    return {w for w in re.findall(r"[a-z]{5,}", text.lower()) if w not in STOP_WORDS}


def _items(brief):
    """(id, quote or '', text) for every brief item the change guard can match against."""
    rows = [(x["id"], x["quote"], x["quote"] + " " + x["problem"]) for x in brief["fix"]]
    rows += [(x["id"], "", x["text"]) for x in brief["gaps"]]
    rows += [(x["id"], "", x["text"]) for x in brief["optional"]]
    return rows


def change_guard(base, new, brief):
    """Every changed passage and the brief item or gap part that covers it, or None.

    A changed passage is covered when a quote of a "Fix these" item sits in the text it replaced,
    or when it shares at least COVER_TOKENS distinctive words with an item. The match is a
    heuristic and only reports: a passage with no match is flagged for the reader, never blocked.
    """
    old_paras, new_paras = paragraphs(base), paragraphs(new)
    matcher = difflib.SequenceMatcher(None, [l4lib.norm(t) for _, t in old_paras],
                                      [l4lib.norm(t) for _, t in new_paras], autojunk=False)
    items = [(item_id, quote, tokens(text)) for item_id, quote, text in _items(brief)]
    changes = []
    for tag, i1, i2, j1, j2 in matcher.get_opcodes():
        if tag == "equal":
            continue
        old_text = "\n\n".join(t for _, t in old_paras[i1:i2])
        news = new_paras[j1:j2] or [(new_paras[j1][0] if j1 < len(new_paras) else 0, "")]
        for line, new_text in news:
            kind = "removed" if not new_text else ("added" if not old_text else "changed")
            by = None
            for item_id, quote, _ in items:
                if quote and old_text and l4lib.quote_in(quote, old_text):
                    by = item_id
                    break
            if by is None:
                have = tokens(new_text + " " + old_text)
                best = max(((len(have & words), item_id) for item_id, _, words in items), default=(0, None))
                if best[0] >= COVER_TOKENS:
                    by = best[1]
            changes.append({"line": line, "kind": kind, "by": by, "text": new_text if kind != "removed" else old_text})
    return changes


def change_flags(base, new, brief):
    """The change guard's result in the form stored with an accepted rewrite.

    Only a passage with no match keeps its text: the reader is shown those and no others.
    """
    return [{"line": c["line"], "kind": c["kind"], "by": c["by"], "text": c["text"] if c["by"] is None else ""}
            for c in change_guard(base, new, brief)]


def uncovered(changes):
    return [c for c in changes if c["by"] is None]
