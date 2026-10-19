"""Prepare the paste run for exactly the packets in scope.txt, role A only.

Usage: python3 -I level4/paste/setup_paste.py [--force-new]

Refuses when a paste run state already exists. With --force-new the existing
state folder is moved aside with a timestamp, never deleted.
"""
import os
import sys
from pathlib import Path

PASTE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(PASTE_DIR))  # python3 -I does not add the script's folder

import paste_lib  # noqa: E402  (also puts the level 4 folder on sys.path)
import l4lib  # noqa: E402


def problems_with(ids, source_index, packets_dir):
    """Reasons the scope cannot be set up. Empty means ready."""
    problems = []
    if not ids:
        problems.append("scope.txt lists no packet ids")
    for packet_id in ids:
        entry = source_index.get(packet_id)
        if entry is None:
            problems.append("%s is not in the packet index" % packet_id)
        elif entry["planted"]:
            problems.append("%s is a planted check, not a lesson to audit" % packet_id)
        elif not (Path(packets_dir) / ("%s.md" % packet_id)).exists():
            problems.append("%s has no packet file" % packet_id)
    return problems


def create(ids, source_index, state_dir):
    state_dir = Path(state_dir)
    l4lib.save_json(state_dir / "index.json", {packet_id: source_index[packet_id] for packet_id in ids})
    l4lib.save_json(state_dir / "queue.json", {
        "order": list(ids),
        "expected": {packet_id: {"roles": [paste_lib.ROLE], "attempt": 1} for packet_id in ids},
    })


def move_aside(state_dir):
    moved = state_dir.with_name("%s.moved-%s" % (state_dir.name, paste_lib.timestamp()))
    os.rename(str(state_dir), str(moved))
    return moved


def main(argv):
    force = "--force-new" in argv
    if [arg for arg in argv[1:] if arg != "--force-new"]:
        print(__doc__)
        return 2
    state_dir = paste_lib.STATE_DIR
    try:
        ids = paste_lib.read_scope()
        source_index = l4lib.load_json(l4lib.STATE_DIR / "index.json")
    except (paste_lib.PasteError, OSError, ValueError) as exc:
        print("Cannot set up the paste run: %s" % exc)
        return 1
    problems = problems_with(ids, source_index, paste_lib.LEVEL4_DIR / "packets")
    if problems:
        print("Cannot set up the paste run:\n- " + "\n- ".join(problems))
        return 1
    if (state_dir / "queue.json").exists() or (state_dir / "index.json").exists():
        if not force:
            print("A paste run state already exists at %s.\nIt is never replaced. "
                  "Run again with --force-new to move it aside and start fresh." % state_dir)
            return 1
        print("Moved the old state to %s" % move_aside(state_dir))
    create(ids, source_index, state_dir)
    print("Paste run ready: %d packets, role A only. State: %s" % (len(ids), state_dir))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
