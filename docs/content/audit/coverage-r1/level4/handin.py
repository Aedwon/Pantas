"""The one command a chat runs to hand in its form.

Usage: python3 handin.py <packet-id> <role> <attempt>      role is A, B, or D

Prints ACCEPTED, REJECTED with numbered reasons, HELD, or STOPPED. The output
is posted to GitHub by the relay, so it never contains verdicts, quotes, or
findings: only what the chat must fix.

Exit codes: 0 accepted, 1 rejected, 2 held, 3 stopped, 64 bad request.
"""
import datetime
import hashlib
import json
import subprocess
import sys
from pathlib import Path

import form
import l4lib

MAX_REJECTIONS = 2
# A form that is not valid JSON is a transport slip, not a judgment failure, so
# it gets its own, larger allowance before the lesson is held.
MAX_UNREADABLE = 5
DELETED = "deleted"


def _now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds")


def _event(state_dir, **fields):
    fields["at"] = _now()
    path = Path(state_dir) / "handin-events.jsonl"
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(str(path), "a", encoding="utf-8") as handle:
        handle.write(json.dumps(fields) + "\n")


def file_hash(path):
    """Content hash of a file, or DELETED when it does not exist."""
    try:
        return hashlib.sha256(Path(path).read_bytes()).hexdigest()
    except OSError:
        return DELETED


def stop_run(state_dir, reason, paths, seen_by):
    l4lib.save_json(Path(state_dir) / "stop.json", {"at": _now(), "reason": reason, "paths": paths, "seen_by": seen_by})


def unexpected_changes(queue, audit_wt=None, corpus_wt=None):
    """Paths changed since the run started that the run itself did not write.

    A changed path is expected only when its current content matches the hash
    recorded for it: in "written" for files the run wrote, or in
    "baseline_files" for files already dirty when the run started. Matching by
    content, not by path, means an edit to an already-dirty file is still seen.
    """
    audit_wt = Path(audit_wt or l4lib.AUDIT_WT)
    if not queue.get("baseline_head"):
        # Without the commit the run started from, a moved HEAD cannot be
        # told from an untouched one, so nothing can be trusted.
        return ["(no starting commit is recorded for this run)"]
    pinned = dict(queue.get("baseline_files", {}))
    pinned.update(queue.get("written", {}))

    def git(*args):
        return subprocess.check_output(["git"] + list(args), cwd=str(audit_wt))

    def names(raw):
        return [name.decode("utf-8", "surrogateescape") for name in raw.split(b"\0") if name]

    # -z gives exact paths with no quoting; --no-renames lists a rename as its
    # deletion and its addition, so neither side can hide behind the other.
    dirty = {entry[3:] for entry in names(git("status", "--porcelain", "-z", "--no-renames", "--untracked-files=all"))}
    committed = set(names(git("diff", "--name-only", "-z", "--no-renames", queue["baseline_head"], "HEAD")))
    # A file flagged skip-worktree or assume-unchanged is hidden from git status,
    # so an edit to it would go unseen. No such flag is expected in this worktree.
    hidden = [entry[2:] for entry in names(git("ls-files", "-v", "-z")) if entry[:1] == "S" or entry[:1].islower()]

    def blob_hash(spec):
        """Hash of a committed ("HEAD:path") or staged (":path") copy, or None when there is none."""
        try:
            return hashlib.sha256(subprocess.check_output(
                ["git", "show", spec], cwd=str(audit_wt), stderr=subprocess.DEVNULL)).hexdigest()
        except subprocess.CalledProcessError:
            return None

    unexpected = sorted("%s (hidden from git status)" % path for path in hidden)
    for path in sorted(dirty | committed):
        pin = pinned.get(path)
        # Every copy git holds must match the recorded hash: the working file,
        # the committed copy when the path was committed since the run started,
        # and the staged copy. A staged copy may instead equal an untouched
        # committed copy, which is the case when nothing is staged for a file
        # that was already edited before the run.
        head = blob_hash("HEAD:%s" % path)
        staged = blob_hash(":%s" % path)
        staged_ok = staged is None or staged == pin or (path not in committed and staged == head)
        if staged is None and pin == DELETED:
            staged_ok = True
        if (pin is None or file_hash(audit_wt / path) != pin or not staged_ok
                or (path in committed and head != pin)):
            unexpected.append(path)
    try:
        l4lib.check_corpus(corpus_wt)
    except l4lib.L4Error:
        unexpected.append("(the lesson corpus)")
    return unexpected


def _lesson_text(entry):
    source = Path(entry["source"])
    path = source if source.is_absolute() else l4lib.CORPUS_WT / source
    return path.read_text(encoding="utf-8")


def process(packet_id, role, attempt, state_dir=None, inbox_dir=None, changes=unexpected_changes, lesson_text=_lesson_text):
    """Return (exit code, lines to print)."""
    state_dir = Path(state_dir or l4lib.STATE_DIR)
    inbox_dir = Path(inbox_dir or (l4lib.LEVEL4_DIR / "inbox"))
    name = "%s-%s-%s" % (packet_id, role, attempt)
    try:
        index = l4lib.load_json(state_dir / "index.json")
        queue = l4lib.load_json(state_dir / "queue.json")
    except (OSError, ValueError):
        return 64, ["BAD REQUEST: no audit run is set up on this machine."]
    waiting = queue.get("expected", {}).get(packet_id) or {}
    if role not in waiting.get("roles", []) or str(waiting.get("attempt")) != str(attempt):
        return 64, ["BAD REQUEST: this is not a hand-in the run is waiting for. "
                    "Check the packet id, your role, and your attempt number against your assignment."]
    if (state_dir / "stop.json").exists():
        return 3, ["STOPPED: the run is stopped. Do not hand in again."]
    accepted_path = state_dir / "forms" / ("%s.json" % name)
    if accepted_path.exists():
        return 0, ["ACCEPTED: this form was already accepted. You are done."]
    rejected_dir = state_dir / "forms" / "rejected"
    rejections = sum(1 for _ in rejected_dir.glob("%s-r*.bin" % name))
    unreadable = sum(1 for _ in rejected_dir.glob("%s-u*.bin" % name))
    if rejections >= MAX_REJECTIONS or unreadable >= MAX_UNREADABLE:
        return 2, ["HELD: this form was rejected too many times. Do not hand in again."]

    stray = changes(queue)
    if stray:
        stop_run(state_dir, "unexpected change", stray, name)
        _event(state_dir, packet=packet_id, role=role, attempt=attempt, result="stopped")
        return 3, ["STOPPED: files changed that this run did not write. Do not hand in again."]

    entry = index[packet_id]
    text = lesson_text(entry)
    if l4lib.sha256_text(text) != entry["lesson_sha256"]:
        stop_run(state_dir, "lesson no longer matches its packet", [entry["source"]], name)
        _event(state_dir, packet=packet_id, role=role, attempt=attempt, result="stopped")
        return 3, ["STOPPED: the lesson changed after this packet was built. Do not hand in again."]

    inbox_path = inbox_dir / ("%s.json" % name)
    try:
        raw = inbox_path.read_bytes()
    except OSError:
        return 64, ["BAD REQUEST: no saved form found. Do step 1 first, with the exact path your assignment gives."]
    inbox_path.unlink()

    candidate, readable = None, True
    try:
        candidate = json.loads(raw.decode("utf-8"))
        items = None
        if role == "D":
            import compare
            items = compare.public_items(l4lib.load_json(state_dir / "deciding" / ("%s.json" % packet_id)))
        reasons = form.validate(candidate, dict(entry, lesson_text=text), role, items)
        if not reasons:
            candidate = form.clean(candidate, role)
            json.dumps(candidate, ensure_ascii=False).encode("utf-8")  # a lone surrogate cannot be stored
    except (ValueError, RecursionError, UnicodeError):
        # Not valid JSON, nested too deep to read, or text that cannot be stored.
        readable = False
        reasons = ["the saved form is not valid JSON. The form goes into the request as one JSON string: "
                   "every backslash in it must be doubled and every double quote escaped"]
    except Exception:  # a form must never crash the check; an unknown fault is a rejection
        reasons = ["the form could not be checked; rebuild it from the packet's blank form"]

    if not reasons:
        l4lib.save_json(accepted_path, candidate)
        _event(state_dir, packet=packet_id, role=role, attempt=attempt, result="accepted")
        return 0, ["ACCEPTED: the form is saved. You are done."]

    rejected_dir.mkdir(parents=True, exist_ok=True)
    count = (rejections if readable else unreadable) + 1
    (rejected_dir / ("%s-%s%d.bin" % (name, "r" if readable else "u", count))).write_bytes(raw)
    lines = ["REJECTED: fix these and hand in again."]
    lines.extend("%d. %s" % (number, reason) for number, reason in enumerate(reasons, 1))
    if count >= (MAX_REJECTIONS if readable else MAX_UNREADABLE):
        _event(state_dir, packet=packet_id, role=role, attempt=attempt, result="held")
        lines[0] = "HELD: this form was rejected too many times. Do not hand in again. The reasons were:"
        return 2, lines
    _event(state_dir, packet=packet_id, role=role, attempt=attempt, result="rejected")
    if readable:
        lines[0] = "REJECTED: fix these and hand in again. This is your only retry."
    return 1, lines


def main(argv):
    if len(argv) != 4 or argv[2] not in ("A", "B", "D") or not argv[3].isdigit():
        print(__doc__)
        return 64
    code, lines = process(argv[1], argv[2], argv[3])
    print("\n".join(lines))
    return code


if __name__ == "__main__":
    sys.exit(main(sys.argv))
