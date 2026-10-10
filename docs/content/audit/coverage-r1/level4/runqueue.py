"""The run: which lesson is in flight, what each chat is doing, what happens next.

One lesson runs at a time. The next lesson starts only after the current one
is green: both forms accepted, every deciding item ruled, the result saved
and re-checked. Anything that keeps a lesson from finishing sets the run to
"needs_you" and nothing new starts; only Aedwon restarts or holds a lesson.

Results stay in the local state directory until the run ends. A planted
lesson and its real twin are the same lesson, so a result on GitHub mid-run
would hand one reader the other's answers.
"""
import datetime
import hashlib
import json
import re
import subprocess
from pathlib import Path

import compare
import dispatch
import form
import handin
import l4lib

ROLE_NAMES = {"A": "Chat 1", "B": "Chat 2", "D": "Deciding chat"}
WAITING = ("limit", "signin")
SUBJECTS = [("general-information", "General Information"), ("language-proficiency", "Language Proficiency"),
            ("mathematics", "Mathematics"), ("reading-comprehension", "Reading Comprehension"),
            ("reasoning", "Reasoning"), ("science", "Science")]


def plan_order(index, prerequisites, pilot_real):
    """Run order: the pilot (its real and planted lessons alternating), then the
    rest by subject and topic with prerequisite lessons first, the remaining
    planted lessons spread evenly through it."""
    real = {entry["lesson_id"]: packet_id for packet_id, entry in index.items() if not entry["planted"]}
    planted = sorted(packet_id for packet_id, entry in index.items() if entry["planted"])
    pilot_planted, later_planted = planted[:len(pilot_real)], planted[len(pilot_real):]
    pilot = []
    for position, lesson_id in enumerate(pilot_real):
        pilot.append(real[lesson_id])
        if position < len(pilot_planted):
            pilot.append(pilot_planted[position])

    rest, placed = [], set(pilot_real)

    def place(lesson_id, trail=()):
        if lesson_id in placed or lesson_id not in real:
            return
        placed.add(lesson_id)
        for needed in prerequisites.get(lesson_id, []):
            if needed not in trail:
                place(needed, trail + (lesson_id,))
        rest.append(real[lesson_id])

    for lesson_id in sorted(real, key=lambda key: (index[real[key]]["subject"], index[real[key]]["topic"], key)):
        place(lesson_id)
    # A planted lesson's deciding assignment carries both reads' disputed items into a
    # GitHub Issue, so it must come after its real twin has been read. Only the pilot's
    # planted lessons are exempt: the pilot has to read them first. Recorded limit.
    step = len(rest) // (len(later_planted) + 1) if later_planted else 0
    slots = []
    for number, packet_id in enumerate(later_planted, 1):
        twin = real.get(index[packet_id]["lesson_id"])
        after_twin = rest.index(twin) + 1 if twin in rest else 0
        slots.append((max(number * step, after_twin), number, packet_id))
    slots.sort()
    ordered, taken = [], 0
    for position, _number, packet_id in slots:
        ordered.extend(rest[taken:position])
        taken = max(taken, position)
        ordered.append(packet_id)
    ordered.extend(rest[taken:])
    return pilot + ordered, len(pilot)


class Run:
    def __init__(self, dispatcher, state_dir=None, config=None, erase=None, now=None,
                 audit_wt=None, lesson_text=None, prompts_dir=None, changes=None, standards_diff=None):
        self.dispatcher = dispatcher
        self.state_dir = Path(state_dir or l4lib.STATE_DIR)
        self.config = config or l4lib.load_json(self.state_dir / "config.json")
        self.erase = erase or (lambda packet_id, role, attempt, since: [])
        self.now = now or (lambda: datetime.datetime.now(datetime.timezone.utc))
        self.audit_wt = Path(audit_wt or l4lib.AUDIT_WT)
        self.lesson_text = lesson_text or handin._lesson_text
        self.prompts_dir = Path(prompts_dir or (l4lib.LEVEL4_DIR / "prompts"))
        self.changes = changes or (lambda queue: handin.unexpected_changes(queue, self.audit_wt))
        self.standards_diff = standards_diff or self._standards_diff
        self.index = l4lib.load_json(self.state_dir / "index.json")
        path = self.state_dir / "queue.json"
        self.q = l4lib.load_json(path) if path.exists() else None

    # ---- setup and persistence -------------------------------------------------

    def create(self, order, pilot_count, packets_commit):
        self.q = {
            "state": "ready", "reason": "", "order": order, "pilot_count": pilot_count,
            "pilot_acknowledged": False, "current": None, "expected": {}, "written": {},
            "baseline_head": None, "baseline_files": {}, "packets_commit": packets_commit,
            "events_seen": 0, "started_at": None,
            # Every (packet, role, attempt) a chat was ever told to hand in, as "packet|role|attempt".
            "registered": [],
            # Relay Issues that stopped the run and were then cleared by Aedwon.
            "relay_stopped_on": [], "relay_ignore": [],
            # The newest origin/main commit Aedwon accepted after the lesson standards changed.
            "standards_pending": None, "standards_accepted": None,
            "lessons": {packet_id: {"state": "pending", "attempt": 0, "tasks": {}} for packet_id in order},
        }
        self.save()

    def save(self):
        l4lib.save_json(self.state_dir / "queue.json", self.q)

    def _stamp(self):
        return self.now().isoformat(timespec="seconds")

    def _git(self, *args):
        return subprocess.check_output(["git"] + list(args), cwd=str(self.audit_wt))

    def _baseline(self):
        raw = self._git("status", "--porcelain", "-z", "--no-renames", "--untracked-files=all")
        paths = [entry.decode("utf-8", "surrogateescape")[3:] for entry in raw.split(b"\0") if entry]
        self.q["baseline_head"] = self._git("rev-parse", "HEAD").decode().strip()
        self.q["baseline_files"] = {path: handin.file_hash(self.audit_wt / path) for path in paths}

    def _standards_diff(self, base):
        """(origin/main commit, paths under docs/content/ and AGENTS.md that differ from base)."""
        self._git("fetch", "origin", "main")
        head = self._git("rev-parse", "origin/main").decode().strip()
        raw = self._git("diff", "--name-only", "-z", "--no-renames", base, head, "--", "docs/content", "AGENTS.md")
        return head, [name.decode("utf-8", "surrogateescape") for name in raw.split(b"\0") if name]

    # ---- Aedwon's controls -----------------------------------------------------

    def start(self):
        if self.q["state"] != "ready":
            return
        self._baseline()
        self.q["started_at"] = self._stamp()
        self.q["state"] = "running"
        self.save()

    def pause(self):
        if self.q["state"] == "running":
            self.q["state"] = "paused"
            self.save()

    def resume(self):
        state = self.q["state"]
        if state == "stopped":
            # Only the lead can clear a stop: by resolving the cause and removing stop.json.
            if (self.state_dir / "stop.json").exists():
                return
            self.q["relay_ignore"] = sorted(set(self.q.get("relay_ignore", [])) | set(self.q.get("relay_stopped_on", [])))
            self.q["relay_stopped_on"] = []
            if self.q.get("standards_pending"):
                self.q["standards_accepted"], self.q["standards_pending"] = self.q["standards_pending"], None
            self._baseline()
        elif state == "pilot_done":
            self.q["pilot_acknowledged"] = True
        elif state not in ("paused", "run_trouble") + WAITING:
            return
        self.q["state"], self.q["reason"] = "running", ""
        self.save()

    def trouble(self, reason):
        """The run itself is failing (a dead dispatcher, a failing gh): ask for Aedwon.

        Leaves needs_you, the waiting states, stopped and the pilot gate alone: each already asks for him.
        """
        if self.q is not None and self.q["state"] in ("running", "paused", "offline"):
            self.q["state"], self.q["reason"] = "run_trouble", reason
            self.save()

    def _move_aside(self, packet_id, attempt):
        """Move this lesson's forms, comparison and result out of the live folders."""
        discard = self.state_dir / "forms" / "discarded" / ("%s-attempt-%d" % (packet_id, attempt))
        for path in (list((self.state_dir / "forms").glob("%s-*.json" % packet_id))
                     + list((self.state_dir / "forms" / "rejected").glob("%s-*.bin" % packet_id))
                     + list((self.state_dir / "deciding").glob("%s.json" % packet_id))
                     + list((self.state_dir / "results").glob("%s.json" % packet_id))):
            discard.mkdir(parents=True, exist_ok=True)
            path.rename(discard / path.name)

    def _retire_current(self, new_state):
        packet_id = self.q["current"]
        if packet_id is None:
            return None
        lesson = self.q["lessons"][packet_id]
        for task in lesson["tasks"].values():
            try:
                self.dispatcher.cancel(task["task_id"])
            except l4lib.L4Error:
                pass
        self._move_aside(packet_id, lesson["attempt"])
        lesson.update(state=new_state, tasks={})
        self.q["expected"].pop(packet_id, None)
        self.q["current"] = None
        return packet_id

    def _leave_needs_you(self):
        # Only a lesson that was waiting for Aedwon returns to running; a pause, a limit,
        # a sign-in wait or a stop stays as it was.
        if self.q["state"] == "needs_you":
            self.q["state"], self.q["reason"] = "running", ""

    def restart_current(self):
        """Throw away this lesson's chats and forms and read it again from the start."""
        packet_id = self._retire_current("pending")
        if packet_id is not None:
            self._leave_needs_you()
            self.save()

    def hold_current(self, reason):
        packet_id = self._retire_current("held")
        if packet_id is not None:
            self.q["lessons"][packet_id]["held_reason"] = reason or self.q["reason"]
            self._leave_needs_you()
            self.save()

    # ---- the tick --------------------------------------------------------------

    def _needs_you(self, reason):
        self.q["state"], self.q["reason"] = "needs_you", reason

    def _stop(self):
        stop = l4lib.load_json(self.state_dir / "stop.json")
        self.q["state"] = "stopped"
        self.q["reason"] = "%s: %s" % (stop.get("reason", "stopped"), ", ".join(stop.get("paths", [])))

    def _stop_run(self, reason, paths):
        handin.stop_run(self.state_dir, reason, paths, "queue")
        self._stop()

    def _register(self, packet_id, role, markdown):
        lesson = self.q["lessons"][packet_id]
        task_id = ("%s-%s-%s-%d" % (self.config["run_token"], packet_id, role, lesson["attempt"])).lower()
        key = "%s|%s|%d" % (packet_id, role, lesson["attempt"])
        if key not in self.q.setdefault("registered", []):
            self.q["registered"].append(key)
            self.save()
        envelope = self.dispatcher.assignment(task_id, "Pantas L4 %s %s" % (packet_id, role),
                                              "lesson audit deciding reader" if role == "D" else "lesson audit reader",
                                              markdown, self.q["packets_commit"])
        task = self.dispatcher.register(envelope)
        lesson["tasks"][role] = {"task_id": task["task_id"], "issue_number": task["issue_number"],
                                 "started_at": self._stamp(), "status": "working"}

    def _fill(self, name, values):
        template = (self.prompts_dir / name).read_text(encoding="utf-8")
        return re.sub(r"\{\{(\w+)\}\}", lambda match: values[match.group(1)], template)

    def _assignment(self, packet_id, role):
        lesson = self.q["lessons"][packet_id]
        values = {"PACKET": packet_id, "ROLE": role, "ATTEMPT": str(lesson["attempt"]), "COMMIT": self.q["packets_commit"]}
        if role != "D":
            return self._fill("reader.md", values)
        comparison = l4lib.load_json(self.state_dir / "deciding" / ("%s.json" % packet_id))
        items = compare.public_items(comparison)
        entry = self.index[packet_id]
        ruling_form = {"packet": packet_id, "role": "D", "lesson_sha256": entry["lesson_sha256"],
                       "standards_commit": entry["standards_commit"],
                       "rulings": {item["id"]: {"ruling": "", "quote": "", "reason": ""} for item in items}}
        return self._fill("decider.md", dict(values, FORM=json.dumps(ruling_form, indent=1),
                                             ITEMS=json.dumps(items, indent=1, ensure_ascii=False)))

    def _register_missing(self, packet_id):
        """Register every expected role that has no chat yet. False when that failed (the run is then in trouble)."""
        lesson = self.q["lessons"][packet_id]
        for role in self.q["expected"][packet_id]["roles"]:
            if role in lesson["tasks"]:
                continue
            try:
                self._register(packet_id, role, self._assignment(packet_id, role))
            except Exception as exc:
                self.trouble("%s could not be started: %s" % (ROLE_NAMES[role], str(exc).strip()[-200:] or type(exc).__name__))
                return False
            self.save()
        return True

    def _start_lesson(self, packet_id):
        lesson = self.q["lessons"][packet_id]
        lesson["attempt"] += 1
        lesson.update(state="reading", started_at=self._stamp())
        self.q["current"] = packet_id
        self.q["expected"][packet_id] = {"roles": ["A", "B"], "attempt": lesson["attempt"]}
        self.save()
        self._register_missing(packet_id)

    # ---- hand-in events, handled in every state ---------------------------------

    def _read_events(self):
        path = self.state_dir / "handin-events.jsonl"
        return path.read_text(encoding="utf-8").splitlines() if path.exists() else []

    def _erase(self, event):
        try:
            outcome = self.erase(event["packet"], event["role"], event.get("attempt"), self.q.get("started_at"))
        except Exception as exc:  # erasing is best effort; the result is logged, never lost
            outcome = [["error", "%s: %s" % (type(exc).__name__, str(exc)[-200:])]]
        entry = {"at": self._stamp(), "packet": event.get("packet"), "role": event.get("role"),
                 "attempt": event.get("attempt"), "result": outcome}
        with open(str(self.state_dir / "eraser.log"), "a", encoding="utf-8") as handle:
            handle.write(json.dumps(entry) + "\n")

    def _handle_event(self, event):
        if event.get("result") in ("accepted", "rejected", "held"):
            self._erase(event)
        packet_id = event.get("packet")
        lesson = self.q["lessons"].get(packet_id)
        if lesson is None or packet_id != self.q["current"] or event.get("attempt") != lesson["attempt"]:
            return
        task = lesson["tasks"].get(event.get("role"))
        if task is None:
            return
        task["status"] = {"accepted": "done", "rejected": "fixing"}.get(event["result"], task["status"])
        if event["result"] == "accepted":
            task["finished_at"] = event["at"]
        if event["result"] == "held":
            self._needs_you("%s had its form rejected twice." % ROLE_NAMES[event["role"]])

    def _process_events(self):
        """Handle new hand-in events one at a time; one is counted as seen only after it is handled."""
        lines = self._read_events()
        while self.q["events_seen"] < len(lines):
            try:
                event = json.loads(lines[self.q["events_seen"]])
            except ValueError:
                event = None
            if isinstance(event, dict):
                self._handle_event(event)
            self.q["events_seen"] += 1
            self.save()

    # ---- safety checks, run on every tick ---------------------------------------

    def _watch_relay(self):
        """Stop the run when a chat made a relay request it was not allowed to make."""
        since = self.q.get("started_at")
        if not since:
            return False
        registered = set(self.q.get("registered", []))
        ignore = set(self.q.get("relay_ignore", []))
        forbidden = [issue["number"] for issue in self.dispatcher.list_relay_issues(since)
                     if issue["number"] not in ignore
                     and dispatch.classify_request(issue, self.audit_wt.name, registered) == "forbidden"]
        if not forbidden:
            return False
        self.q["relay_stopped_on"] = forbidden
        self._stop_run("a chat made a relay request it was not allowed to make", ["Issue #%d" % n for n in forbidden])
        return True

    def _watch_changes(self):
        found = self.changes(self.q)
        if not found:
            return False
        self._stop_run("unexpected change", found)
        return True

    def _chat_expected(self):
        current = self.q["current"]
        expected = self.q["expected"].get(current) if current is not None else None
        return bool(expected) and any(self._form(current, role) is None for role in expected["roles"])

    # ---- one lesson --------------------------------------------------------------

    def _form(self, packet_id, role):
        attempt = self.q["lessons"][packet_id]["attempt"]
        path = self.state_dir / "forms" / ("%s-%s-%d.json" % (packet_id, role, attempt))
        return l4lib.load_json(path) if path.exists() else None

    def _chat_trouble(self, packet_id, roles):
        """Set a waiting or needs_you state when a chat without an accepted form has ended. True if set."""
        lesson = self.q["lessons"][packet_id]
        for role in roles:
            task = lesson["tasks"].get(role)
            if task is None or self._form(packet_id, role) is not None:
                continue
            seen = self.dispatcher.task_state(task["issue_number"])
            if seen["state"] in WAITING:
                self.q["state"], self.q["reason"] = seen["state"], seen["detail"]
                return True
            if seen["state"] == "failed":
                self._needs_you("%s stopped before handing in (%s)." % (ROLE_NAMES[role], seen["detail"]))
                return True
            if seen["state"] == "completed":
                self._needs_you("%s ended without an accepted form." % ROLE_NAMES[role])
                return True
        return False

    def _packet(self, packet_id):
        entry = self.index[packet_id]
        return dict(entry, lesson_text=self.lesson_text(entry))

    def _finish(self, packet_id, final):
        lesson = self.q["lessons"][packet_id]
        entry = self.index[packet_id]
        result = dict(final, packet=packet_id, lesson_id=entry["lesson_id"], lesson_sha256=entry["lesson_sha256"],
                      standards_commit=entry["standards_commit"], attempt=lesson["attempt"],
                      started_at=lesson["started_at"], finished_at=self._stamp())
        path = self.state_dir / "results" / ("%s.json" % packet_id)
        l4lib.save_json(path, result)
        problems = check_result(l4lib.load_json(path), self._packet(packet_id))
        if problems:
            self._needs_you("The saved result failed its check: %s." % problems[0])
            return
        lesson.update(state="finished", finished_at=result["finished_at"])
        self.q["expected"].pop(packet_id, None)
        self.q["current"] = None

    def _advance_current(self):
        packet_id = self.q["current"]
        lesson = self.q["lessons"][packet_id]
        paused = self.q["state"] == "paused"
        if any(role not in lesson["tasks"] for role in self.q["expected"][packet_id]["roles"]):
            # A chat that failed to register is registered again, but not while paused: a pause starts no chat.
            if paused or not self._register_missing(packet_id):
                return
        if lesson["state"] == "reading":
            form_a, form_b = self._form(packet_id, "A"), self._form(packet_id, "B")
            if form_a is None or form_b is None:
                self._chat_trouble(packet_id, ("A", "B"))
                return
            seed = int(hashlib.sha256(("%s|%s" % (self.config["seed"], packet_id)).encode()).hexdigest()[:8], 16)
            comparison = compare.compare(form_a, form_b, seed, self.lesson_text(self.index[packet_id]))
            l4lib.save_json(self.state_dir / "deciding" / ("%s.json" % packet_id), comparison)
            if comparison["copied"]:
                self._needs_you("The two forms look copied from each other.")
            elif comparison["items"]:
                if paused:
                    return  # the comparison is saved; the deciding chat starts after Resume
                lesson["state"] = "deciding"
                self.q["expected"][packet_id] = {"roles": ["D"], "attempt": lesson["attempt"]}
                self.save()
                self._register_missing(packet_id)
            else:
                self._finish(packet_id, compare.apply_ruling(comparison))
        elif lesson["state"] == "deciding":
            ruling = self._form(packet_id, "D")
            if ruling is None:
                self._chat_trouble(packet_id, ("D",))
                return
            comparison = l4lib.load_json(self.state_dir / "deciding" / ("%s.json" % packet_id))
            self._finish(packet_id, compare.apply_ruling(comparison, ruling))

    def tick(self):
        """Advance the run by at most one step. Safe to call again at any time."""
        q = self.q
        if q is None or q["state"] in ("ready", "stopped", "done"):
            return
        # Safety and bookkeeping come first and run in every other state.
        if (self.state_dir / "stop.json").exists():
            self._stop()
        elif not (self._watch_changes() or self._watch_relay()):
            self._process_events()
        if q["state"] != "stopped" and q["state"] not in ("needs_you", "pilot_done", "run_trouble") + WAITING:
            self._work()
        self.save()

    def _work(self):
        q = self.q
        if self.dispatcher.runners_online() == 0:
            if q["state"] == "running":
                q["state"] = "offline"
            return
        if q["state"] == "offline":
            q["state"] = "running"
        if q["current"] is not None and self._chat_expected() and self._dispatcher_down():
            return
        if q["current"] is not None:
            self._advance_current()
        elif q["state"] == "running":
            self._start_next()

    def _dispatcher_down(self):
        """True, and the run is in trouble, when a chat is expected but the dispatcher is not running."""
        if self.dispatcher.supervisor_running():
            return False
        self.trouble("The dispatcher is not running, so no chat can start or finish. Start it, then press Resume.")
        return True

    def _start_next(self):
        pending = [packet_id for packet_id in self.q["order"] if self.q["lessons"][packet_id]["state"] == "pending"]
        if not pending:
            self.q["state"] = "done"
            return
        position = self.q["order"].index(pending[0])
        if position >= self.q["pilot_count"] and not self.q["pilot_acknowledged"]:
            self.q["state"] = "pilot_done"
            return
        base = self.q.get("standards_accepted") or l4lib.standards_commit()
        head, changed = self.standards_diff(base)
        if changed:
            self.q["standards_pending"] = head
            self._stop_run("main's lesson standards changed during the run", changed[:5])
        elif not self._dispatcher_down():
            self._start_lesson(pending[0])

    # ---- what the page shows ---------------------------------------------------

    def _minutes(self, since):
        started = datetime.datetime.fromisoformat(since)
        return max(0, int((self.now() - started).total_seconds() // 60))

    def view(self):
        q = self.q
        lessons = q["lessons"]
        real = [packet_id for packet_id in q["order"] if not self.index[packet_id]["planted"]]
        planted = [packet_id for packet_id in q["order"] if self.index[packet_id]["planted"]]
        current = q["current"]
        chats = []
        lesson_view = None
        if current is not None:
            entry = self.index[current]
            group = planted if entry["planted"] else real
            lesson_view = {"title": entry["title"], "subject": dict(SUBJECTS).get(entry["subject"], entry["subject"]),
                           "planted": entry["planted"], "number": group.index(current) + 1, "total": len(group)}
            for role in ("A", "B", "D"):
                task = lessons[current]["tasks"].get(role)
                if role == "D" and lessons[current]["state"] != "deciding":
                    continue
                if task is None:
                    chats.append({"name": ROLE_NAMES[role], "status": "idle"})
                else:
                    chats.append({"name": ROLE_NAMES[role], "status": task["status"],
                                  "minutes": self._minutes(task["started_at"])})

        def cell(packet_id):
            state = lessons[packet_id]["state"]
            return "now" if packet_id == current else {"finished": "done", "held": "held"}.get(state, "")

        strip = [{"name": name, "cells": [cell(packet_id) for packet_id in real if self.index[packet_id]["subject"] == key]}
                 for key, name in SUBJECTS]
        strip.append({"name": "Checks", "cells": [cell(packet_id) for packet_id in planted]})

        durations = [(datetime.datetime.fromisoformat(lessons[p]["finished_at"])
                      - datetime.datetime.fromisoformat(lessons[p]["started_at"])).total_seconds()
                     for p in q["order"] if lessons[p]["state"] == "finished"]
        remaining = sum(1 for p in q["order"] if lessons[p]["state"] in ("pending", "reading", "deciding"))
        hours_left = None
        if len(durations) >= 2 and remaining:
            hours_left = max(1, int(round(sum(durations) / len(durations) * remaining / 3600.0)))
        return {
            "state": q["state"], "reason": q["reason"], "lesson": lesson_view, "chats": chats, "strip": strip,
            "finished": sum(1 for p in real if lessons[p]["state"] == "finished"), "total": len(real),
            "held": sum(1 for p in q["order"] if lessons[p]["state"] == "held"),
            "hours_left": hours_left, "in_pilot": not q["pilot_acknowledged"],
            "pilot_total": q["pilot_count"],
            "disputed_items": self._item_count(current) if current else 0,
        }

    def _item_count(self, packet_id):
        path = self.state_dir / "deciding" / ("%s.json" % packet_id)
        return len(l4lib.load_json(path)["items"]) if path.exists() else 0


def check_result(result, packet):
    """The pacing gate: reasons a saved result is not yet a finished lesson."""
    problems = []
    wanted = form.rule_ids_for(packet)
    missing = [rule_id for rule_id in wanted if rule_id not in result.get("rules", {})]
    if missing:
        problems.append("rules missing: %s" % ", ".join(missing))
    for rule_id, record in sorted(result.get("rules", {}).items()):
        if record.get("verdict") not in form.VERDICTS:
            problems.append("rule %s has no final verdict" % rule_id)
        for finding in record.get("findings", []):
            if not l4lib.quote_in(finding.get("quote"), packet["lesson_text"]):
                problems.append("rule %s has a finding whose quote is not in the lesson" % rule_id)
        if record.get("verdict") == "fail" and not record.get("findings"):
            problems.append("rule %s is fail with no finding left" % rule_id)
    for entry in result.get("illustrations", []):
        if not l4lib.quote_in(entry.get("position_quote"), packet["lesson_text"]):
            problems.append("an illustration's position is not in the lesson")
    if result.get("lesson_sha256") != packet["lesson_sha256"]:
        problems.append("the result names a different lesson version")
    return problems
