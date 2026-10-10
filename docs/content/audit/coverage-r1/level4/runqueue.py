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
    step = len(rest) // (len(later_planted) + 1) if later_planted else 0
    for number, packet_id in enumerate(later_planted, 1):
        rest.insert(number * step + number - 1, packet_id)
    return pilot + rest, len(pilot)


class Run:
    def __init__(self, dispatcher, state_dir=None, config=None, erase=None, now=None,
                 audit_wt=None, lesson_text=None, prompts_dir=None):
        self.dispatcher = dispatcher
        self.state_dir = Path(state_dir or l4lib.STATE_DIR)
        self.config = config or l4lib.load_json(self.state_dir / "config.json")
        self.erase = erase or (lambda packet_id, role: [])
        self.now = now or (lambda: datetime.datetime.now(datetime.timezone.utc))
        self.audit_wt = Path(audit_wt or l4lib.AUDIT_WT)
        self.lesson_text = lesson_text or handin._lesson_text
        self.prompts_dir = Path(prompts_dir or (l4lib.LEVEL4_DIR / "prompts"))
        self.index = l4lib.load_json(self.state_dir / "index.json")
        path = self.state_dir / "queue.json"
        self.q = l4lib.load_json(path) if path.exists() else None

    # ---- setup and persistence -------------------------------------------------

    def create(self, order, pilot_count, packets_commit):
        self.q = {
            "state": "ready", "reason": "", "order": order, "pilot_count": pilot_count,
            "pilot_acknowledged": False, "current": None, "expected": {}, "written": {},
            "baseline_head": None, "baseline_files": {}, "packets_commit": packets_commit,
            "events_seen": 0,
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

    # ---- Aedwon's controls -----------------------------------------------------

    def start(self):
        if self.q["state"] != "ready":
            return
        self._baseline()
        self.q["state"] = "running"
        self.save()

    def pause(self):
        if self.q["state"] == "running":
            self.q["state"] = "paused"
            self.save()

    def resume(self):
        if self.q["state"] == "pilot_done":
            self.q["pilot_acknowledged"] = True
        if self.q["state"] in ("paused", "pilot_done") + WAITING:
            self.q["state"], self.q["reason"] = "running", ""
            self.save()

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
        discard = self.state_dir / "forms" / "discarded" / ("%s-attempt-%d" % (packet_id, lesson["attempt"]))
        for path in list((self.state_dir / "forms").glob("%s-*.json" % packet_id)) + \
                list((self.state_dir / "forms" / "rejected").glob("%s-*.json" % packet_id)) + \
                list((self.state_dir / "deciding").glob("%s.json" % packet_id)):
            discard.mkdir(parents=True, exist_ok=True)
            path.rename(discard / path.name)
        lesson.update(state=new_state, tasks={})
        self.q["expected"].pop(packet_id, None)
        self.q["current"] = None
        return packet_id

    def restart_current(self):
        """Throw away this lesson's chats and forms and read it again from the start."""
        packet_id = self._retire_current("pending")
        if packet_id is not None:
            self.q["state"], self.q["reason"] = "running", ""
            self.save()

    def hold_current(self, reason):
        packet_id = self._retire_current("held")
        if packet_id is not None:
            self.q["lessons"][packet_id]["held_reason"] = reason or self.q["reason"]
            self.q["state"], self.q["reason"] = "running", ""
            self.save()

    # ---- the tick --------------------------------------------------------------

    def _needs_you(self, reason):
        self.q["state"], self.q["reason"] = "needs_you", reason

    def _register(self, packet_id, role, markdown):
        lesson = self.q["lessons"][packet_id]
        task_id = ("%s-%s-%s-%d" % (self.config["run_token"], packet_id, role, lesson["attempt"])).lower()
        envelope = self.dispatcher.assignment(task_id, "Pantas L4 %s %s" % (packet_id, role),
                                              "lesson audit deciding reader" if role == "D" else "lesson audit reader",
                                              markdown, self.q["packets_commit"])
        task = self.dispatcher.register(envelope)
        lesson["tasks"][role] = {"task_id": task["task_id"], "issue_number": task["issue_number"],
                                 "started_at": self._stamp(), "status": "working"}

    def _fill(self, name, values):
        template = (self.prompts_dir / name).read_text(encoding="utf-8")
        return re.sub(r"\{\{(\w+)\}\}", lambda match: values[match.group(1)], template)

    def _start_lesson(self, packet_id):
        lesson = self.q["lessons"][packet_id]
        lesson["attempt"] += 1
        lesson.update(state="reading", started_at=self._stamp())
        self.q["current"] = packet_id
        self.q["expected"][packet_id] = ["A", "B"]
        self.save()
        for role in ("A", "B"):
            self._register(packet_id, role, self._fill("reader.md", {
                "PACKET": packet_id, "ROLE": role, "COMMIT": self.q["packets_commit"]}))

    def _read_events(self):
        path = self.state_dir / "handin-events.jsonl"
        lines = path.read_text(encoding="utf-8").splitlines() if path.exists() else []
        fresh = [json.loads(line) for line in lines[self.q["events_seen"]:]]
        self.q["events_seen"] = len(lines)
        return fresh

    def _form(self, packet_id, role):
        path = self.state_dir / "forms" / ("%s-%s.json" % (packet_id, role))
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
        for event in self._read_events():
            if event.get("result") in ("accepted", "rejected", "held"):
                self.erase(event["packet"], event["role"])
            if event.get("packet") != packet_id:
                continue
            task = lesson["tasks"].get(event["role"])
            if task is None:
                continue
            task["status"] = {"accepted": "done", "rejected": "fixing"}.get(event["result"], task["status"])
            if event["result"] == "accepted":
                task["finished_at"] = event["at"]
            if event["result"] == "held":
                self._needs_you("%s had its form rejected twice." % ROLE_NAMES[event["role"]])
                return
        if lesson["state"] == "reading":
            form_a, form_b = self._form(packet_id, "A"), self._form(packet_id, "B")
            if form_a is None or form_b is None:
                self._chat_trouble(packet_id, ("A", "B"))
                return
            seed = int(hashlib.sha256(("%s|%s" % (self.config["seed"], packet_id)).encode()).hexdigest()[:8], 16)
            comparison = compare.compare(form_a, form_b, seed)
            l4lib.save_json(self.state_dir / "deciding" / ("%s.json" % packet_id), comparison)
            if comparison["copied"]:
                self._needs_you("The two forms look copied from each other.")
            elif comparison["items"]:
                items = compare.public_items(comparison)
                ruling_form = {"packet": packet_id, "role": "D", "lesson_sha256": self.index[packet_id]["lesson_sha256"],
                               "standards_commit": self.index[packet_id]["standards_commit"],
                               "rulings": {item["id"]: {"ruling": "", "quote": "", "reason": ""} for item in items}}
                lesson["state"] = "deciding"
                self.q["expected"][packet_id] = ["D"]
                self.save()
                self._register(packet_id, "D", self._fill("decider.md", {
                    "PACKET": packet_id, "COMMIT": self.q["packets_commit"],
                    "FORM": json.dumps(ruling_form, indent=1), "ITEMS": json.dumps(items, indent=1, ensure_ascii=False)}))
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
        if self.q is None or self.q["state"] in ("ready", "needs_you", "stopped", "pilot_done", "done") + WAITING:
            if self.q and self.q["state"] != "stopped" and (self.state_dir / "stop.json").exists():
                self._stop()
                self.save()
            return
        if (self.state_dir / "stop.json").exists():
            self._stop()
        elif self.dispatcher.runners_online() == 0:
            if self.q["state"] == "running":
                self.q["state"] = "offline"
        else:
            if self.q["state"] == "offline":
                self.q["state"] = "running"
            if self.q["current"] is not None:
                self._advance_current()
            elif self.q["state"] == "running":
                self._start_next()
        self.save()

    def _stop(self):
        stop = l4lib.load_json(self.state_dir / "stop.json")
        self.q["state"] = "stopped"
        self.q["reason"] = "%s: %s" % (stop.get("reason", "stopped"), ", ".join(stop.get("paths", [])))

    def _start_next(self):
        pending = [packet_id for packet_id in self.q["order"] if self.q["lessons"][packet_id]["state"] == "pending"]
        if not pending:
            self.q["state"] = "done"
            return
        position = self.q["order"].index(pending[0])
        if position >= self.q["pilot_count"] and not self.q["pilot_acknowledged"]:
            self.q["state"] = "pilot_done"
            return
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
