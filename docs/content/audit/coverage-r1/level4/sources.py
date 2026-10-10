"""Rule B04 by script: does each lesson have an entry in the lesson source ledger?

Usage: python3 sources.py

The ledger (docs/content/audit/lesson-content-qa-r1.md) records one
disposition per lesson and one shared bibliography. It does not tie a fact to
its source, so this checks only what the ledger can show: the lesson has an
entry, and the lesson has not changed since the ledger was finished. Rule B05
needs fact-level records and is reported as not confirmable.
"""
import re
import subprocess
import sys

import l4lib

LEDGER = "docs/content/audit/lesson-content-qa-r1.md"
PREFIX = "content/lessons/"


def ledger_entries(ledger_text):
    """Lesson paths (relative to the repo) the ledger gives a disposition."""
    return {PREFIX + path for path in re.findall(r"^- `([^`]+\.md)`", ledger_text, flags=re.M)}


def check(ledger_text, lessons, changed):
    """lessons: [{"metadata__id", "path"}]; changed: paths edited after the ledger was finished."""
    entries, changed = ledger_entries(ledger_text), set(changed)
    rows = {}
    for lesson in lessons:
        path = lesson["path"]
        rows[lesson["metadata__id"]] = {"path": path, "in_ledger": path in entries,
                                        "changed_since_ledger": path in changed}
    return rows


def main(argv):
    if argv[1:]:
        print(__doc__)
        return 2
    l4lib.check_corpus()
    root, commit = str(l4lib.CORPUS_WT), l4lib.CORPUS_COMMIT

    def git(*args):
        return subprocess.check_output(["git"] + list(args), cwd=root, universal_newlines=True)

    ledger_commit = git("log", "-1", "--format=%H", commit, "--", LEDGER).strip()
    if not ledger_commit:
        raise l4lib.L4Error("the corpus has no lesson source ledger at %s" % LEDGER)
    changed = git("diff", "--name-only", "--no-renames", ledger_commit, commit, "--", PREFIX).split("\n")
    lessons = l4lib.load_json(l4lib.LEVEL4_DIR.parent / "inventory-lessons.json")["lessons"]
    rows = check(git("show", "%s:%s" % (commit, LEDGER)), lessons, changed)
    l4lib.save_json(l4lib.LEVEL4_DIR / "source-record.json", {
        "ledger": LEDGER, "ledger_commit": ledger_commit, "corpus_commit": commit, "lessons": rows})
    print("lessons: %d" % len(rows))
    print("no ledger entry: %d" % sum(not row["in_ledger"] for row in rows.values()))
    print("changed since the ledger was finished: %d" % sum(row["changed_since_ledger"] for row in rows.values()))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv))
    except l4lib.L4Error as exc:
        print("ERROR: %s" % exc)
        sys.exit(1)
