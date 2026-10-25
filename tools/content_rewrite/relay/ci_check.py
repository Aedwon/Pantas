#!/usr/bin/env python3
"""The checks the GitHub workflow runs on a push to the rewrite branch.

Usage: python3 -I tools/content_rewrite/relay/ci_check.py <before-sha> lessons|typing

lessons  every lesson the push added or changed gets the hand-in's lesson checks against the version
         it replaced (frontmatter id, definite style findings, structure, device, formula and figure sweeps).
typing   the question typing check runs on the question files the push changed. The whole corpus is not
         checked: it has older problems that the question fixes will clear file by file.
Exit 0 when clean, 1 when a check fails, 64 on a bad request.
Python 3.9 standard library only.
"""
import re
import subprocess
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))

import checks  # noqa: E402
import rw_lib  # noqa: E402

TYPING = rw_lib.RELAY_DIR.parent / "check_question_typing.py"


def base_for(git, before):
    """The commit to compare with: the push's previous head, or the parent when the branch is new."""
    if re.fullmatch(r"[0-9a-f]{40}", before or "") and set(before) != {"0"} and git.ok("cat-file", "-e", before + "^{commit}"):
        return before
    return "HEAD~1"


def changed(git, base, folder, suffixes):
    names = git.text("diff", "--name-only", "--diff-filter=AM", "-z", base, "HEAD", "--", folder).split("\0")
    return [n for n in names if n and n.endswith(suffixes)]


def check_lessons(ctx, before):
    base = base_for(ctx.git, before)
    failed = 0
    files = changed(ctx.git, base, rw_lib.LESSON_ROOT_REL, (".md",))
    for path in files:
        old = ctx.git.show("%s:%s" % (base, path)) or ""
        new = (ctx.root / path).read_text(encoding="utf-8")
        if not old:
            print("%s: new lesson, no earlier version to compare with" % path)
            old = new
        reasons, notes = checks.check_rewrite_text(old, new, path)
        for note in notes:
            print("%s: note: %s" % (path, note))
        for reason in reasons:
            print("%s: %s" % (path, reason))
        failed += bool(reasons)
    print("lessons checked: %d, failed: %d" % (len(files), failed))
    return 1 if failed else 0


def check_typing(ctx, before):
    files = changed(ctx.git, base_for(ctx.git, before), "content/questions", (".yaml", ".yml"))
    if not files:
        print("no question files changed")
        return 0
    proc = subprocess.run([sys.executable, "-I", str(TYPING)] + files, cwd=str(ctx.root))
    return proc.returncode


def main(argv):
    if len(argv) != 3 or argv[2] not in ("lessons", "typing"):
        print(__doc__)
        return 64
    ctx = rw_lib.Ctx()
    return (check_lessons if argv[2] == "lessons" else check_typing)(ctx, argv[1])


if __name__ == "__main__":
    sys.exit(main(sys.argv))
