#!/usr/bin/env python3
"""The one command a chat runs to hand in a batch.

Usage: python3 -I tools/content_rewrite/relay/handin.py <batch-id> <attempt>

It checks every saved file for the batch in tools/content_rewrite/relay/inbox/<batch-id>/, puts the
accepted ones in place, and commits them. It never pushes: the chat runs the relay's git_push_current.
The first line of the output is ACCEPTED, REJECTED, HELD, STOPPED or BAD REQUEST. The output is posted to
GitHub by the relay, so it holds reasons, rule ids, counts and line numbers, never lesson text.

Exit codes: 0 accepted, 1 rejected, 2 held, 3 stopped, 64 bad request.
Python 3.9 standard library only.
"""
import os
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))

import item_types  # noqa: E402
import rw_lib  # noqa: E402


USAGE = "usage: python3 -I %s <batch-id> <attempt>" % rw_lib.HANDIN_REL


def stray_changes(ctx, allowed):
    """Names of things in the worktree that this hand-in may not find.

    Allowed: the inbox folder, and the paths in `allowed` (the files this batch will place).
    Everything else that is modified, staged, untracked, or hidden from git status is a stray change.
    Deletions and renames are listed as a deletion and an addition, so neither can hide the other.
    """
    git = ctx.git
    stray = []
    branch = git.text("rev-parse", "--abbrev-ref", "HEAD").strip()
    if branch != rw_lib.BRANCH:
        stray.append("(the worktree is not on the rewrite branch)")
    raw = git.text("status", "--porcelain", "-z", "--no-renames", "--untracked-files=all")
    inbox = rw_lib.INBOX_REL + "/"
    batches = rw_lib.BATCHES_REL + "/"   # the planner writes batch files here before the lead commits them
    for entry in (e for e in raw.split("\0") if e):
        path = entry[3:]
        if path.startswith(inbox) or path.startswith(batches) or path in allowed:
            continue
        stray.append(path)
    # A file flagged skip-worktree or assume-unchanged is hidden from git status, so an edit to it goes unseen.
    for entry in (e for e in git.text("ls-files", "-v", "-z").split("\0") if e):
        if entry[:1] == "S" or entry[:1].islower():
            stray.append("%s (hidden from git status)" % entry[2:])
    return stray


def _write(root, rel, data):
    target = Path(root) / rel
    target.parent.mkdir(parents=True, exist_ok=True)
    temp = target.with_name(target.name + ".tmp")
    temp.write_bytes(data)
    os.replace(str(temp), str(target))


def _place_and_commit(ctx, kind, batch, accepted):
    """Write the accepted files and commit them in one commit. Returns the commit sha.

    On any failure the files are put back as they were and RewriteError is raised.
    """
    before = {}
    for _, result in accepted:
        for rel in result.files:
            path = ctx.root / rel
            before[rel] = path.read_bytes() if path.exists() else None
    paths = sorted(before)
    try:
        for _, result in accepted:
            for rel, data in result.files.items():
                _write(ctx.root, rel, data)
        ctx.git.run("add", "--", *paths)
        ids = " ".join(key for key, _ in accepted)
        ctx.git.run("commit", "-q", "-m", "%s: %s %s" % (kind.commit_verb, batch["id"], ids), "--", *paths)
        return ctx.git.text("rev-parse", "HEAD").strip()
    except Exception:
        ctx.git.run("reset", "-q", "--", *paths, check=False)
        for rel, old in before.items():
            path = ctx.root / rel
            if old is None:
                if path.exists():
                    path.unlink()
            else:
                _write(ctx.root, rel, old)
        raise rw_lib.RewriteError("the commit failed")


def process(batch_id, attempt, ctx=None):
    """Return (exit code, lines to print)."""
    ctx = ctx or rw_lib.Ctx()
    if not re.fullmatch(r"[A-Z]{2}-\d{3}", batch_id or "") or not str(attempt).isdigit() or int(attempt) < 1:
        return 64, ["BAD REQUEST: " + USAGE]
    batch = ctx.batch(batch_id)
    if batch is None:
        return 64, ["BAD REQUEST: this is not a batch the run is waiting for. Check the batch id against your assignment."]
    if ctx.stopped():
        return 3, ["STOPPED: the run is stopped. Do not hand in again."]
    kind = item_types.get(batch["type"])
    keys = kind.items(batch)
    allowed = {rel for key in keys for rel in kind.target_paths(batch, key)}

    stray = stray_changes(ctx, allowed)
    if stray:
        ctx.stop("unexpected change", batch_id)
        ctx.event(batch=batch_id, attempt=attempt, result="stopped", stray=len(stray))
        return 3, ["STOPPED: files changed that this run did not write. Do not hand in again."]

    already, held, missing, todo = [], [], [], []
    inbox = ctx.inbox_dir(batch_id)
    for key in keys:
        record = ctx.accepted(kind.name, key)
        if record and record.get("batch") == batch_id:
            already.append(key)
        elif ctx.is_held(batch_id, key):
            held.append(key)
        elif (inbox / kind.inbox_name(key)).is_file():
            todo.append(key)
        else:
            missing.append(key)
    if not todo:
        if held:
            return 2, ["HELD: these were rejected too many times. Do not hand in again: " + ", ".join(held)]
        if len(already) == len(keys):
            return 0, ["ACCEPTED: everything in this batch was already accepted. You are done."]
        return 64, ["BAD REQUEST: no saved file found. Do step 1 first, with the exact path your assignment gives."]

    accepted, rejected, raws = [], [], {}
    for key in todo:
        path = inbox / kind.inbox_name(key)
        raw = raws[key] = path.read_bytes()
        path.unlink()
        try:
            result = item_types.check_safely(ctx, kind, batch, key, raw)
        except rw_lib.RewriteError as exc:
            ctx.stop(str(exc), batch_id)
            ctx.event(batch=batch_id, attempt=attempt, item=key, result="stopped")
            return 3, ["STOPPED: %s. Do not hand in again." % exc]
        (rejected if result.reasons else accepted).append((key, result))

    lines, commit = [], None
    if accepted:
        try:
            commit = _place_and_commit(ctx, kind, batch, accepted)
        except rw_lib.RewriteError as exc:
            ctx.stop(str(exc), batch_id)
            ctx.event(batch=batch_id, attempt=attempt, result="stopped", why="commit")
            return 3, ["STOPPED: %s. Do not hand in again." % exc]
        for key, result in accepted:
            rw_lib.json_save(ctx.accepted_path(kind.name, key), dict(
                result.record, batch=batch_id, commit=commit, at=rw_lib.now(), attempt=int(attempt)))
        ids = [key for key, _ in accepted]
        ctx.event(batch=batch_id, attempt=attempt, result="accepted", items=ids, commit=commit)

    body, now_held, last_retry = [], [], []
    for key, result in rejected:
        count = ctx.add_rejection(batch_id, key, result.readable)
        limit = rw_lib.MAX_REJECTIONS if result.readable else rw_lib.MAX_UNREADABLE
        rejected_dir = ctx.state_file("rejected")
        rejected_dir.mkdir(parents=True, exist_ok=True)
        # Kept in the state folder (never the repo) so the lead can see what was handed in.
        (rejected_dir / ("%s-%s-%s%d.bin" % (batch_id, key, "r" if result.readable else "u", count))).write_bytes(
            raws[key])
        ctx.event(batch=batch_id, attempt=attempt, item=key, result="held" if count >= limit else "rejected")
        if count >= limit:
            now_held.append(key)
            body.append("%s: HELD after %d rejections. Do not hand in %s again. The reasons were:" % (key, count, key))
        else:
            if count == limit - 1:
                last_retry.append(key)
            body.append("%s:" % key + (" (this is your last retry)" if key in last_retry else ""))
        body.extend("%d. %s" % (number, reason) for number, reason in enumerate(result.reasons, 1))

    retry = [key for key, _ in rejected if key not in now_held]
    if retry:
        code, head = 1, "REJECTED: fix these and hand in again."
    elif now_held or held:
        code, head = 2, "HELD: these were rejected too many times. Do not hand in again: " + ", ".join(now_held + held)
    else:
        code, head = 0, "ACCEPTED: %d of %d accepted and committed." % (len(accepted) + len(already), len(keys))
    lines.append(head)
    if commit:
        lines.append("COMMITTED %s (%s)" % (rw_lib.short(commit), ", ".join(key for key, _ in accepted)))
    for key, result in accepted:
        for note in result.notes:
            lines.append("FLAG %s: %s" % (key, note))
    lines.extend(body)
    if missing and (code != 2 or accepted):
        lines.append("NOT RECEIVED: " + ", ".join(missing))
    return code, lines


def main(argv):
    if len(argv) != 3:
        print("BAD REQUEST: " + USAGE)
        return 64
    code, lines = process(argv[1], argv[2])
    print("\n".join(lines))
    return code


if __name__ == "__main__":
    sys.exit(main(sys.argv))
