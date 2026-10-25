#!/usr/bin/env python3
"""The hand-in check that GitHub Actions runs on a pull request from a chat.

Usage: python3 -I tools/content_rewrite/relay/handin_ci.py <batch-id> <base-commit> <head-commit>

Run it in a checkout that holds both commits. It reads the batch from the batch file committed at the point
where the branch started, falling back to the base branch head if missing
(docs/content/rewrite/batches/<batch-id>.json), checks that the pull request changes
only the files the batch may place, and runs the same per-file checks as the local hand-in (handin.py): the
rewrite checks for a lesson, the form checks for a read, against the lesson text at the base commit.
The output is a Markdown report. Its first line is "## ACCEPTED", "## REJECTED" or "## ERROR". It holds rule
ids, counts and line numbers, never lesson text. It changes nothing in the checkout.

Exit codes: 0 accepted, 1 rejected, 3 error that needs the lead, 64 bad request.
Python 3.9 standard library only.
"""
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))

import item_types  # noqa: E402
import rw_lib  # noqa: E402

USAGE = "python3 -I %s <batch-id> <base-commit> <head-commit>" % rw_lib.HANDIN_CI_REL
SHA = re.compile(r"[0-9a-f]{7,40}")
REGULAR_FILE = "100644"
MAX_LISTED = 10


def safe_path(path):
    """A path from the pull request, made safe to print in a comment."""
    text = "".join(ch for ch in path if ch.isprintable() and ch not in "`|<>\\")
    return text if len(text) <= 120 else text[:117] + "..."


def resolve(git, ref):
    out = git.text("rev-parse", "--verify", "--quiet", ref + "^{commit}", check=False).strip()
    return out or None


def changed_files(git, base, head):
    """{path: (status letter, new file mode)} for what the head changes since the base. Renames are split."""
    tokens = git.text("diff", "--raw", "--no-renames", "--no-abbrev", "-z", base, head).split("\0")
    found, index = {}, 0
    while index < len(tokens):
        meta = tokens[index]
        if meta.startswith(":") and index + 1 < len(tokens):
            fields = meta[1:].split()
            found[tokens[index + 1]] = (fields[4][:1], fields[1])
            index += 2
        else:
            index += 1
    return found


def pull_request_reasons(diff, allowed):
    """Reasons about files the batch may not change: a list of strings."""
    stray = sorted(path for path in diff if path not in allowed)
    reasons = ["`%s` is not a file this batch may change; remove it from the branch" % safe_path(path)
               for path in stray[:MAX_LISTED]]
    if len(stray) > MAX_LISTED:
        reasons.append("%d more files are not files this batch may change" % (len(stray) - MAX_LISTED))
    return reasons


def check_files(ctx, kind, batch, keys, diff, head):
    """({key: reasons}, [notes]) for the files of the batch. Raises RewriteError for a fault in the run."""
    reasons, notes = {}, []
    for key in keys:
        path = kind.target_paths(batch, key)[0]
        entry = diff.get(path)
        if entry is None:
            reasons[key] = ["the file is not in the pull request; commit it at the path given in your assignment"]
            continue
        status, mode = entry
        if status != kind.expected_status or mode != REGULAR_FILE:
            verb = "changes an existing file" if kind.expected_status == "M" else "adds a new file"
            reasons[key] = ["the pull request must hold a regular file at this path that %s" % verb]
            continue
        raw = ctx.git.run("show", "%s:%s" % (head, path))
        result = item_types.check_safely(ctx, kind, batch, key, raw)
        found = list(result.reasons)
        if not found and kind.verbatim and result.files.get(path) != raw:
            found.append("the file must use LF line ends and end with exactly one final newline")
        if found:
            reasons[key] = found
        notes.extend("%s: %s" % (key, note) for note in result.notes)
    return reasons, notes


def report(accepted, pr_reasons, item_reasons, notes, count):
    lines = ["## ACCEPTED" if accepted else "## REJECTED", ""]
    if accepted:
        lines.append("All %d files passed the checks. The pull request is merged next." % count)
    else:
        lines.append("Fix exactly these reasons and nothing else. Commit the fixes to the same branch.")
        if pr_reasons:
            lines += ["", "**Pull request**"]
            lines += ["%d. %s" % (number, reason) for number, reason in enumerate(pr_reasons, 1)]
        for key, reasons in item_reasons.items():
            lines += ["", "**%s**" % key]
            lines += ["%d. %s" % (number, reason) for number, reason in enumerate(reasons, 1)]
    if notes:
        lines += ["", "Notes for the lead (these do not block):"] + ["- " + note for note in notes]
    return lines


def process(batch_id, base, head, ctx=None):
    """Return (exit code, report lines)."""
    ctx = ctx or rw_lib.Ctx()
    git = ctx.git
    if (not re.fullmatch(r"[A-Z]{2}-\d{3}", batch_id or "") or not SHA.fullmatch(base or "")
            or not SHA.fullmatch(head or "")):
        return 64, ["## ERROR", "", "Bad request. Usage: " + USAGE]
    base_sha, head_sha = resolve(git, base), resolve(git, head)
    merge_base = git.text("merge-base", base_sha, head_sha, check=False).strip() if base_sha and head_sha else ""
    if not merge_base:
        return 64, ["## ERROR", "", "A commit is missing from the checkout, or the branch shares no history with "
                    "the base. The lead must look at this pull request."]
    ctx.base_ref = merge_base
    try:
        batch = ctx.batch_at(merge_base, batch_id)
        if batch is None:
            batch = ctx.batch_at(base_sha, batch_id)
        if batch is None:
            return 64, ["## ERROR", "", "There is no batch file for %s at the point where the branch started. "
                        "The lead must look at this pull request." % batch_id]
        kind = item_types.get(batch["type"])
        keys = kind.items(batch)
        allowed = {path for key in keys for path in kind.target_paths(batch, key)}
        diff = changed_files(git, merge_base, head_sha)
        pr_reasons = pull_request_reasons(diff, allowed)
        item_reasons, notes = check_files(ctx, kind, batch, keys, diff, head_sha)
    except rw_lib.RewriteError as exc:
        return 3, ["## ERROR", "", "%s. The lead must look at this pull request." % exc]
    accepted = not pr_reasons and not item_reasons
    return (0 if accepted else 1), report(accepted, pr_reasons, item_reasons, notes, len(keys))


def main(argv):
    if len(argv) != 4:
        print("## ERROR\n\nBad request. Usage: " + USAGE)
        return 64
    code, lines = process(argv[1], argv[2], argv[3])
    print("\n".join(lines))
    return code


if __name__ == "__main__":
    sys.exit(main(sys.argv))
