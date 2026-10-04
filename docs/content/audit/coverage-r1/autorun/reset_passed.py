#!/usr/bin/env python3
"""Exit 0 if the latest Codex usage-limit reset time has passed (or none found)."""
import re, sys, datetime as dt
text = open(sys.argv[1], errors="ignore").read() if len(sys.argv) > 1 else ""
hits = re.findall(r"try again at ([A-Z][a-z]{2} \d{1,2}(?:st|nd|rd|th), \d{4} )?(\d{1,2}:\d{2} [AP]M)", text)
if not hits:
    sys.exit(0)
day, clock = hits[-1]
now = dt.datetime.now()
t = dt.datetime.strptime(clock, "%I:%M %p").time()
if day:
    d = dt.datetime.strptime(re.sub(r"(st|nd|rd|th),", ",", day.strip()), "%b %d, %Y").date()
    reset = dt.datetime.combine(d, t)
else:
    # Time-only messages refer to the next occurrence after the message;
    # the log has no message time, so treat a past time today as passed.
    reset = dt.datetime.combine(now.date(), t)
reset += dt.timedelta(minutes=2)
if "--show" in sys.argv:
    print(reset.strftime("%Y-%m-%d %H:%M"))
sys.exit(0 if now >= reset else 1)
