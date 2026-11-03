#!/usr/bin/env python3
"""Check one CET lesson after a rewrite (plan 2026-11-03-cet-content-pilot, Task 1).

Usage: python3 -I tools/content_rewrite/check_cet_lesson.py <lesson path> [--base REF]

The lesson is the file in the worktree, for example content/lessons/science/chemistry/stoichiometry.md.
It is compared with the same file at the base revision. The comparison is the CSE hand-in check
(relay/checks.py check_rewrite_text): frontmatter _id, length share, definite style findings, structure,
device and figure-marker sweeps. The script also counts words. A lesson takes the length its teaching needs, so
length never fails. Over 3,000 words the report prints a note that the lesson is a split candidate.

Exit 0 when there is no reason, 1 when a check fails, 64 on a bad request.
Python 3.9 standard library only.
"""
import argparse
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent / "relay"))

import checks  # noqa: E402
import rw_lib  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
BASE_REF = "7032eec5b8fbdac51cef7e7b6dc7272d0e965f9a"  # origin/content/cse-rewrite-r1, the branch point
SPLIT_TRIPWIRE = 3000  # words; over this the report notes a split candidate. It is not a failure.


class CheckError(Exception):
    pass


def lesson_rel_path(arg):
    """The lesson path relative to the repository, or CheckError when it is not one lesson file."""
    path = Path(arg)
    if path.is_absolute():
        try:
            path = path.resolve().relative_to(ROOT)
        except ValueError:
            raise CheckError("the path is outside this worktree")
    rel = str(path)
    if rw_lib.path_parts(rel) is None or not rel.endswith(".md"):
        raise CheckError("expected content/lessons/<subject>/<topic>/<slug>.md")
    return rel


def count_words(text):
    """Whitespace-separated words of the whole file. This is how the 372 to 1,685 word range of the CSE
    lessons was counted, so the tripwire means the same thing here."""
    return len(text.split())


def check_text(rel, base, new):
    reasons, notes = checks.check_rewrite_text(base, new, rel)
    return {"reasons": reasons, "notes": notes, "words": count_words(new)}


def exit_code(result):
    return 1 if result["reasons"] else 0


def format_report(rel, result):
    lines = ["%s %s" % ("FAIL" if exit_code(result) else "OK", rel),
             "words: %d" % result["words"]]
    lines += ["reason: " + r for r in result["reasons"]]
    lines += ["note: " + n for n in result["notes"]]
    if result["words"] > SPLIT_TRIPWIRE:
        lines.append("note: %d words, over %d. This lesson is a split candidate. Report it and make no split."
                     % (result["words"], SPLIT_TRIPWIRE))
    return "\n".join(lines)


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("lesson")
    ap.add_argument("--base", default=BASE_REF)
    args = ap.parse_args(argv)
    try:
        rel = lesson_rel_path(args.lesson)
        file = ROOT / rel
        if not file.is_file():
            raise CheckError("no such lesson file in the worktree")
        base = rw_lib.Git(ROOT).show("%s:%s" % (args.base, rel))
        if base is None:
            raise CheckError("the lesson is not in the base revision %s" % args.base)
        new = file.read_text(encoding="utf-8")
    except CheckError as err:
        print("BAD REQUEST: %s" % err)
        return 64
    result = check_text(rel, base, new)
    print(format_report(rel, result))
    return exit_code(result)


if __name__ == "__main__":
    sys.exit(main())
