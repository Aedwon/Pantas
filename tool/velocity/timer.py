#!/usr/bin/env python3
"""Task timer for the velocity log.

Every task row in docs/superpowers/estimates/velocity-log.md takes its actual
times from this timer, never from a guess.

  python3 tool/velocity/timer.py E-030 start
  python3 tool/velocity/timer.py E-030 pause ci        # reason: ci, aedwon, away, other
  python3 tool/velocity/timer.py E-030 resume
  python3 tool/velocity/timer.py E-030 stop
  python3 tool/velocity/timer.py E-030 status

State lives outside the repository so every worktree and thread shares it:
~/.local/state/pantas/timers/<id>.log, one "UTC-timestamp event [reason]" line
per event. "stop" and "status" print the wall time, the active time, and the
paused time by reason, ready to copy into the log row.
"""
import sys
from datetime import datetime, timezone
from pathlib import Path

STATE = Path.home() / ".local/state/pantas/timers"
REASONS = {"ci", "aedwon", "away", "other"}


def now():
    return datetime.now(timezone.utc).replace(microsecond=0)


def read(path):
    if not path.exists():
        return []
    events = []
    for line in path.read_text().splitlines():
        parts = line.split()
        events.append((datetime.fromisoformat(parts[0]), parts[1], parts[2] if len(parts) > 2 else ""))
    return events


def fmt(seconds):
    seconds = int(seconds)
    h, rem = divmod(seconds, 3600)
    m, s = divmod(rem, 60)
    if h:
        return f"{h} h {m} min"
    if m:
        return f"{m} min {s} s"
    return f"{s} s"


def summary(events, until):
    start = events[0][0]
    end = until
    paused = {}
    pause_at, reason = None, ""
    for at, event, why in events:
        if event == "pause":
            pause_at, reason = at, why
        elif event in ("resume", "stop") and pause_at:
            paused[reason] = paused.get(reason, 0) + (at - pause_at).total_seconds()
            pause_at = None
        if event == "stop":
            end = at
    if pause_at:
        paused[reason] = paused.get(reason, 0) + (end - pause_at).total_seconds()
    wall = (end - start).total_seconds()
    active = wall - sum(paused.values())
    lines = [
        f"start  {start:%b %d %H:%M} UTC",
        f"end    {end:%b %d %H:%M} UTC" + ("" if events[-1][1] == "stop" else " (still running)"),
        f"wall   {fmt(wall)}",
        f"active {fmt(active)}",
    ]
    for why, secs in sorted(paused.items()):
        lines.append(f"paused {why}: {fmt(secs)}")
    return "\n".join(lines)


def main(argv):
    if len(argv) < 3:
        sys.exit(__doc__)
    task, action = argv[1], argv[2]
    STATE.mkdir(parents=True, exist_ok=True)
    path = STATE / f"{task}.log"
    events = read(path)
    state = events[-1][1] if events else None
    if action == "status":
        if not events:
            sys.exit(f"{task}: no timer")
        print(summary(events, now()))
        return
    allowed = {
        "start": state is None,
        "pause": state in ("start", "resume"),
        "resume": state == "pause",
        "stop": state in ("start", "resume", "pause"),
    }
    if action not in allowed:
        sys.exit(f"unknown action {action}")
    if not allowed[action]:
        sys.exit(f"{task}: cannot {action} when the timer is {state or 'not started'}")
    reason = ""
    if action == "pause":
        reason = argv[3] if len(argv) > 3 else "other"
        if reason not in REASONS:
            sys.exit(f"pause reason must be one of {sorted(REASONS)}")
    with path.open("a") as f:
        f.write(f"{now().isoformat()} {action} {reason}".rstrip() + "\n")
    if action == "stop":
        print(summary(read(path), now()))
    else:
        print(f"{task}: {action} {reason}".rstrip())


if __name__ == "__main__":
    main(sys.argv)
