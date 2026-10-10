"""Create the run queue once the packets, real and planted, are committed.

Usage: python3 setup_run.py <pilot lesson id> [<pilot lesson id> ...]

Refuses to run when a queue already exists, when any packet is missing from
the commit the chats will read, or when a pilot lesson is unknown or planted.
"""
import subprocess
import sys

import build_packets
import dispatch
import l4lib
import runqueue

PACKETS = "docs/content/audit/coverage-r1/level4/packets"


def committed_packets(audit_wt, commit):
    listed = subprocess.check_output(["git", "ls-tree", "--name-only", "%s:%s" % (commit, PACKETS)],
                                     cwd=str(audit_wt), universal_newlines=True)
    return {name[:-3] for name in listed.split() if name.endswith(".md")}


def check(index, pilot_real, committed, queue_exists):
    """Reasons the run cannot be set up. Empty means ready."""
    problems = []
    if queue_exists:
        problems.append("a run queue already exists; it is never replaced")
    missing = sorted(set(index) - committed)
    if missing:
        problems.append("%d packets are not in the pushed commit, for example %s" % (len(missing), missing[0]))
    real = {entry["lesson_id"] for entry in index.values() if not entry["planted"]}
    planted = {entry["lesson_id"] for entry in index.values() if entry["planted"]}
    for lesson_id in pilot_real:
        if lesson_id not in real:
            problems.append("pilot lesson %s is not in the corpus" % lesson_id)
        elif lesson_id in planted:
            problems.append("pilot lesson %s also has a planted copy; choose another" % lesson_id)
    if len(planted) < len(pilot_real):
        problems.append("the pilot needs %d planted lessons and only %d exist" % (len(pilot_real), len(planted)))
    return problems


def main(argv):
    pilot_real = argv[1:]
    if not pilot_real:
        print(__doc__)
        return 2
    index = l4lib.load_json(l4lib.STATE_DIR / "index.json")
    git = lambda *args: subprocess.check_output(["git"] + list(args), cwd=str(l4lib.AUDIT_WT), universal_newlines=True).strip()
    head = git("rev-parse", "HEAD")
    if git("rev-parse", "origin/%s" % dispatch.AUDIT_BRANCH) != head:
        print("The audit branch is not pushed at HEAD. Push first, so chats can read the packets.")
        return 1
    problems = check(index, pilot_real, committed_packets(l4lib.AUDIT_WT, head), (l4lib.STATE_DIR / "queue.json").exists())
    if problems:
        print("Cannot set up the run:\n- " + "\n- ".join(problems))
        return 1
    prerequisites = l4lib.load_json(l4lib.LEVEL4_DIR.parent / "lesson-prerequisites.json")
    order, pilot_count = runqueue.plan_order(index, prerequisites, pilot_real)
    run = runqueue.Run(dispatch, config=build_packets.load_config())
    run.create(order, pilot_count, head)
    print("Run ready: %d packets, %d in the pilot, chats read commit %s." % (len(order), pilot_count, head[:12]))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
