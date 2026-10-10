"""The one command a chat runs to hand in its form.

Usage: python3 handin.py <packet-id> <role>      role is A, B, or D

Prints ACCEPTED, REJECTED with numbered reasons, HELD, or STOPPED. The output
is posted to GitHub by the relay, so it never contains verdicts, quotes, or
findings: only what the chat must fix.

Exit codes: 0 accepted, 1 rejected, 2 held, 3 stopped, 64 bad request.
"""
import datetime
import json
import subprocess
import sys
from pathlib import Path

import form
import l4lib

MAX_REJECTIONS = 2
STATUS_PATH = "docs/content/audit/coverage-r1/status.md"


def _now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds")


def _event(state_dir, **fields):
    fields["at"] = _now()
    path = Path(state_dir) / "handin-events.jsonl"
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(str(path), "a", encoding="utf-8") as handle:
        handle.write(json.dumps(fields) + "\n")


def unexpected_changes(queue, audit_wt=None, corpus_wt=None):
    """Paths changed since the run started that the run itself did not write."""
    audit_wt = Path(audit_wt or l4lib.AUDIT_WT)
    allowed = set(queue.get("written", [])) | {STATUS_PATH}
    baseline = set(queue.get("baseline_status", []))

    def git(root, *args):
        return subprocess.check_output(["git"] + list(args), cwd=str(root), universal_newlines=True)

    changed = set()
    for line in git(audit_wt, "status", "--porcelain", "--untracked-files=all").splitlines():
        if line not in baseline:
            changed.add(line[3:].strip().strip('"'))
    if queue.get("baseline_head"):
        changed.update(path for path in git(audit_wt, "diff", "--name-only", queue["baseline_head"], "HEAD").splitlines() if path)
    try:
        l4lib.check_corpus(corpus_wt)
    except l4lib.L4Error:
        changed.add("(the lesson corpus)")
    return sorted(path for path in changed if path not in allowed)


def _lesson_text(entry):
    source = Path(entry["source"])
    path = source if source.is_absolute() else l4lib.CORPUS_WT / source
    return path.read_text(encoding="utf-8")


def process(packet_id, role, state_dir=None, inbox_dir=None, changes=unexpected_changes, lesson_text=_lesson_text):
    """Return (exit code, lines to print)."""
    state_dir = Path(state_dir or l4lib.STATE_DIR)
    inbox_dir = Path(inbox_dir or (l4lib.LEVEL4_DIR / "inbox"))
    name = "%s-%s" % (packet_id, role)
    try:
        index = l4lib.load_json(state_dir / "index.json")
        queue = l4lib.load_json(state_dir / "queue.json")
    except (OSError, ValueError):
        return 64, ["BAD REQUEST: no audit run is set up on this machine."]
    if role not in queue.get("expected", {}).get(packet_id, []):
        return 64, ["BAD REQUEST: %s is not a hand-in this run is waiting for. Check the packet id and your role." % name]
    if (state_dir / "stop.json").exists():
        return 3, ["STOPPED: the run is stopped. Do not hand in again."]
    accepted_path = state_dir / "forms" / ("%s.json" % name)
    if accepted_path.exists():
        return 0, ["ACCEPTED: this form was already accepted. You are done."]
    rejections = sum(1 for _ in (state_dir / "forms" / "rejected").glob("%s-*.json" % name))
    if rejections >= MAX_REJECTIONS:
        return 2, ["HELD: this form was rejected %d times. Do not hand in again." % rejections]

    stray = changes(queue)
    if stray:
        l4lib.save_json(state_dir / "stop.json", {"at": _now(), "reason": "unexpected change", "paths": stray, "seen_by": name})
        _event(state_dir, packet=packet_id, role=role, result="stopped")
        return 3, ["STOPPED: files changed that this run did not write. Do not hand in again."]

    entry = index[packet_id]
    text = lesson_text(entry)
    if l4lib.sha256_text(text) != entry["lesson_sha256"]:
        l4lib.save_json(state_dir / "stop.json", {"at": _now(), "reason": "lesson no longer matches its packet",
                                                  "paths": [entry["source"]], "seen_by": name})
        _event(state_dir, packet=packet_id, role=role, result="stopped")
        return 3, ["STOPPED: the lesson changed after this packet was built. Do not hand in again."]

    inbox_path = inbox_dir / ("%s.json" % name)
    try:
        raw = inbox_path.read_text(encoding="utf-8")
    except OSError:
        return 64, ["BAD REQUEST: no saved form found for %s. Do step 1 first, with the exact path the packet gives." % name]
    try:
        candidate = json.loads(raw)
        reasons = None
    except ValueError as exc:
        candidate = None
        reasons = ["the saved form is not valid JSON (%s)" % str(exc)[:80]]
    if reasons is None:
        items = None
        if role == "D":
            import compare
            items = compare.public_items(l4lib.load_json(state_dir / "deciding" / ("%s.json" % packet_id)))
        packet = dict(entry, lesson_text=text)
        reasons = form.validate(candidate, packet, role, items)
    inbox_path.unlink()

    if not reasons:
        l4lib.save_json(accepted_path, candidate)
        _event(state_dir, packet=packet_id, role=role, result="accepted")
        return 0, ["ACCEPTED: the form is saved. You are done."]

    rejected_dir = state_dir / "forms" / "rejected"
    rejected_dir.mkdir(parents=True, exist_ok=True)
    (rejected_dir / ("%s-%d.json" % (name, rejections + 1))).write_text(raw, encoding="utf-8")
    lines = ["REJECTED: fix these and hand in again."]
    lines.extend("%d. %s" % (number, reason) for number, reason in enumerate(reasons, 1))
    if rejections + 1 >= MAX_REJECTIONS:
        _event(state_dir, packet=packet_id, role=role, result="held")
        lines[0] = "HELD: this form was rejected %d times. Do not hand in again. The reasons were:" % (rejections + 1)
        return 2, lines
    _event(state_dir, packet=packet_id, role=role, result="rejected")
    return 1, lines


def main(argv):
    if len(argv) != 3 or argv[2] not in ("A", "B", "D"):
        print(__doc__)
        return 64
    code, lines = process(argv[1], argv[2])
    print("\n".join(lines))
    return code


if __name__ == "__main__":
    sys.exit(main(sys.argv))
