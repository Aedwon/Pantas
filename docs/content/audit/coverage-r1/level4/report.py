"""Reports built from the run's local results.

pilot_report: counts only, for Aedwon's go or no-go decision. Safe to show
mid-run: it names no pending planted packet and carries no lesson findings.

publish_final: writes every result into the audit folder. Run it only when
the run has ended, because it reveals which packets were planted.
"""
import datetime
import json
from pathlib import Path

import handin
import l4lib

NOT_ASSESSED = {
    "B04": "not assessed at Level 4: this run has no item-level source ledger to check lesson facts against",
    "B05": "not assessed at Level 4: this run has no item-level source ledger to check lesson facts against",
    "L06": "deferred to Level 5, which checks in-lesson quiz items against the question rules",
}


class Data:
    def __init__(self, state_dir=None, mechanical_dir=None, lesson_text=None):
        self._lesson_text = lesson_text or handin._lesson_text
        self.state_dir = Path(state_dir or l4lib.STATE_DIR)
        self.mechanical_dir = Path(mechanical_dir or (l4lib.LEVEL4_DIR / "mechanical"))
        self.index = l4lib.load_json(self.state_dir / "index.json")
        self.queue = l4lib.load_json(self.state_dir / "queue.json")
        key_path = self.state_dir / "planted" / "key.json"
        self.key = l4lib.load_json(key_path) if key_path.exists() else {}

    def load(self, folder, name):
        path = self.state_dir / folder / name
        return l4lib.load_json(path) if path.exists() else None

    def finished(self, planted):
        return [packet_id for packet_id in self.queue["order"]
                if self.queue["lessons"][packet_id]["state"] == "finished" and self.index[packet_id]["planted"] == planted]

    def lesson_text(self, packet_id):
        """The text of the lesson as this packet carried it (the edited copy for a planted packet)."""
        return self._lesson_text(self.index[packet_id])

    def attempt(self, packet_id):
        return self.queue["lessons"][packet_id]["attempt"]

    def form(self, packet_id, role):
        return self.load("forms", "%s-%s-%d.json" % (packet_id, role, self.attempt(packet_id)))

    def events(self):
        path = self.state_dir / "handin-events.jsonl"
        return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines()] if path.exists() else []


CAUGHT_GAP = 80


def caught(defect, rules, lesson_text):
    """A read caught a planted defect when it failed one of the defect's rules at the planted text.

    rules: the "rules" object of a form or of a final result. A finding counts
    when its quote lies in the lesson within CAUGHT_GAP characters of the anchor.
    """
    anchors = defect["must_quote"] if isinstance(defect["must_quote"], list) else [defect["must_quote"]]
    for rule_id in defect.get("rules") or [defect["rule"]]:
        entry = (rules or {}).get(rule_id) or {}
        if entry.get("verdict") != "fail":
            continue
        for finding in entry.get("findings", []):
            if any(l4lib.same_place(anchor, finding["quote"], lesson_text, gap=CAUGHT_GAP) for anchor in anchors):
                return True
    return False


def _minutes(started, finished):
    delta = datetime.datetime.fromisoformat(finished) - datetime.datetime.fromisoformat(started)
    return delta.total_seconds() / 60.0


def planted_table(data, packet_ids):
    rows, totals = [], {}
    for packet_id in packet_ids:
        lesson_id = data.index[packet_id]["lesson_id"]
        form_a, form_b = data.form(packet_id, "A"), data.form(packet_id, "B")
        result = data.load("results", "%s.json" % packet_id)
        text = data.lesson_text(packet_id)
        for defect in data.key.get(lesson_id, []):
            marks = [caught(defect, (source or {}).get("rules"), text) for source in (form_a, form_b, result)]
            rows.append((defect["rule"], defect["label"], marks))
            tally = totals.setdefault(defect["rule"], [0, 0, 0, 0])
            tally[0] += 1
            for position, mark in enumerate(marks, 1):
                tally[position] += int(mark)
    return rows, totals


def pilot_report(data=None):
    data = data or Data()
    pilot = data.queue["order"][:data.queue["pilot_count"]]
    done = [packet_id for packet_id in pilot if data.queue["lessons"][packet_id]["state"] == "finished"]
    planted = [packet_id for packet_id in done if data.index[packet_id]["planted"]]
    rows, totals = planted_table(data, planted)
    lines = ["# Level 4 pilot report", "",
             "Lessons read: %d of %d in the pilot (%d real, %d check lessons)." % (
                 len(done), len(pilot), len(done) - len(planted), len(planted)), "",
             "## Planted errors: caught or missed", "",
             "A read caught an error when it failed the right rule and quoted the planted text.", "",
             "| Rule | Planted | Chat 1 caught | Chat 2 caught | Final result caught |", "|---|---|---|---|---|"]
    for rule in sorted(totals):
        count, a, b, final = totals[rule]
        lines.append("| %s | %d | %d | %d | %d |" % (rule, count, a, b, final))
    lines += ["", "Each planted error:", ""]
    for rule, label, marks in rows:
        lines.append("- %s, %s: Chat 1 %s, Chat 2 %s, final %s" % (
            (rule, label) + tuple("caught" if mark else "missed" for mark in marks)))

    disputes, compared = {}, 0
    for packet_id in done:
        comparison = data.load("deciding", "%s.json" % packet_id)
        if not comparison:
            continue
        compared += 1
        for item in comparison["items"]:
            rule = item.get("rule", "illustration")
            disputes[rule] = disputes.get(rule, 0) + 1
    lines += ["", "## Where the two reads differed", "",
              "Lessons compared: %d. Items sent to a deciding chat, by rule:" % compared, ""]
    lines += ["- %s: %d" % (rule, disputes[rule]) for rule in sorted(disputes)] or ["- none"]

    events = [event for event in data.events() if event["packet"] in pilot]
    rejected = sum(1 for event in events if event["result"] in ("rejected", "held"))
    minutes = []
    for packet_id in done:
        for task in data.queue["lessons"][packet_id]["tasks"].values():
            if task.get("finished_at"):
                minutes.append(_minutes(task["started_at"], task["finished_at"]))
    lines += ["", "## Forms and time", "",
              "Forms rejected by the check: %d." % rejected,
              "Chats timed: %d." % len(minutes)]
    if minutes:
        lines.append("Minutes per chat: average %.0f, shortest %.0f, longest %.0f." % (
            sum(minutes) / len(minutes), min(minutes), max(minutes)))
    lines += ["", "No pass mark is set. Decide whether to continue, move some rules to a stronger model, or stop.", ""]
    return "\n".join(lines)


def hold_list(data=None):
    data = data or Data()
    held = [packet_id for packet_id in data.queue["order"] if data.queue["lessons"][packet_id]["state"] == "held"]
    lines = ["# Lessons on hold", ""]
    for packet_id in held:
        entry = data.index[packet_id]
        lines.append("- %s (`%s`): %s" % (entry["title"], entry["lesson_id"],
                                           data.queue["lessons"][packet_id].get("held_reason") or "no reason recorded"))
    return "\n".join(lines + ([] if held else ["None."]) + [""])


def _severity():
    return {rule["id"]: rule["severity"] for rule in l4lib.load_rules()}


def lesson_findings(data, packet_id):
    entry = data.index[packet_id]
    result = data.load("results", "%s.json" % packet_id)
    mechanical = l4lib.load_json(data.mechanical_dir / ("%s.json" % entry["lesson_id"]))
    severity = _severity()
    lines = ["# %s" % entry["title"], "", "Lesson: `%s`. Lesson version: `%s`. Standards: `%s`." % (
        entry["lesson_id"], result["lesson_sha256"][:12], result["standards_commit"][:12]), "",
             "## Findings from the two reads", ""]
    any_finding = False
    for rule_id in sorted(result["rules"]):
        record = result["rules"][rule_id]
        if record["verdict"] == "needs_source_check":
            lines.append("- %s: needs a source check; not judged here." % rule_id)
        for finding in record["findings"]:
            any_finding = True
            source = "both reads agreed" if finding.get("source") == "both" else "a deciding chat ruled"
            lines += ["- **%s** (%s; %s)" % (rule_id, severity.get(rule_id, ""), source),
                      "  - Quote: \"%s\"" % l4lib.norm(finding["quote"]),
                      "  - Problem: %s" % l4lib.norm(finding["problem"])]
    if not any_finding:
        lines.append("No rule failed.")
    lines += ["", "## Findings from the script", ""]
    definite = [finding for finding in mechanical["findings"] if not finding["candidate"]]
    lines += ["- **%s** (%s), line %d: %s. Text: \"%s\"" % (
        finding["rule"], severity.get(finding["rule"], ""), finding["line"], finding["problem"], finding["text"])
        for finding in definite] or ["None."]
    lines += ["", "## Illustration review", ""]
    lines += ["- %s, %s priority, %s, %s. At: \"%s\". Draw: %s. Why: %s" % (
        item["status"], item["priority"], item["kind"], item["method"], l4lib.norm(item["position_quote"]),
        item["description"], item["why"]) for item in result["illustrations"]] or ["No illustration change recommended."]
    if result["accuracy_concerns"]:
        lines += ["", "## Accuracy concerns", ""]
        lines += ["- \"%s\": %s" % (l4lib.norm(item["quote"]), item["concern"]) for item in result["accuracy_concerns"]]
    return "\n".join(lines) + "\n"


def counting_check(data, lessons):
    """Return (text, missing count). Every lesson and every in-scope rule must be accounted for."""
    by_lesson = {data.index[packet_id]["lesson_id"]: packet_id for packet_id in data.queue["order"]
                 if not data.index[packet_id]["planted"]}
    rules = l4lib.load_rules()
    missing, held, read = [], 0, 0
    for lesson_id in lessons:
        packet_id = by_lesson.get(lesson_id)
        state = data.queue["lessons"][packet_id]["state"] if packet_id else None
        if state == "held":
            held += 1
            continue
        result = data.load("results", "%s.json" % packet_id) if state == "finished" else None
        if result is None:
            missing.append("%s: no finished result" % lesson_id)
            continue
        read += 1
        if not (data.mechanical_dir / ("%s.json" % lesson_id)).exists():
            missing.append("%s: no script result" % lesson_id)
        for rule in rules:
            if rule["kind"] in ("chat", "source-check") and rule["id"] not in result["rules"]:
                missing.append("%s: rule %s has no verdict" % (lesson_id, rule["id"]))
    lines = ["# Level 4 counting check", "", "Lessons in the corpus: %d." % len(lessons),
             "Read with a finished result: %d. On hold: %d. Unaccounted: %d." % (
                 read, held, len(lessons) - read - held), "",
             "Rules judged by the chats: %s." % ", ".join(r["id"] for r in rules if r["kind"] in ("chat", "source-check")),
             "Rules checked by script: %s." % ", ".join(r["id"] for r in rules if r["kind"].startswith("script")), ""]
    lines += ["%s: %s." % (rule_id, reason) for rule_id, reason in sorted(NOT_ASSESSED.items())]
    lines += ["", "Result: %s." % ("PASS" if not missing else "FAIL, %d gaps" % len(missing)), ""]
    lines += ["- %s" % gap for gap in missing]
    return "\n".join(lines) + "\n", len(missing)


def publish_final(data=None, out_dir=None, lessons=None):
    data = data or Data()
    out_dir = Path(out_dir or (l4lib.LEVEL4_DIR / "results"))
    if lessons is None:
        lessons = [lesson["metadata__id"] for lesson in
                   l4lib.load_json(l4lib.LEVEL4_DIR.parent / "inventory-lessons.json")["lessons"]]
    (out_dir / "findings").mkdir(parents=True, exist_ok=True)
    severity = _severity()
    counts, illustrations = {}, []
    for packet_id in data.finished(planted=False):
        entry = data.index[packet_id]
        (out_dir / "findings" / ("%s.md" % entry["lesson_id"])).write_text(lesson_findings(data, packet_id), encoding="utf-8")
        result = data.load("results", "%s.json" % packet_id)
        l4lib.save_json(out_dir / "data" / ("%s.json" % entry["lesson_id"]), result)
        for rule_id, record in result["rules"].items():
            if record["findings"]:
                level = severity.get(rule_id, "").split(" ")[0]
                counts[level] = counts.get(level, 0) + len(record["findings"])
        illustrations += [(entry["lesson_id"], item) for item in result["illustrations"]]
    lines = ["# Level 4 illustration review", "", "Entries: %d." % len(illustrations), ""]
    lines += ["- `%s`: %s, %s priority, %s, %s. At: \"%s\". Draw: %s. Why: %s" % (
        lesson_id, item["status"], item["priority"], item["kind"], item["method"],
        l4lib.norm(item["position_quote"]), item["description"], item["why"]) for lesson_id, item in illustrations]
    (out_dir / "illustrations.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    check_text, gaps = counting_check(data, lessons)
    (out_dir / "counting-check.md").write_text(check_text, encoding="utf-8")
    (out_dir / "hold-list.md").write_text(hold_list(data), encoding="utf-8")
    rows, totals = planted_table(data, data.finished(planted=True))
    l4lib.save_json(out_dir / "planted-key.json", {"key": data.key, "by_rule": {
        rule: {"planted": t[0], "chat_1_caught": t[1], "chat_2_caught": t[2], "final_caught": t[3]}
        for rule, t in totals.items()}})
    summary = ["# Level 4 summary", "",
               "Lessons read: %d of %d. On hold: %d." % (
                   len(data.finished(planted=False)), len(lessons),
                   sum(1 for p in data.queue["order"] if data.queue["lessons"][p]["state"] == "held")),
               "Findings from the two reads, by severity: %s." % (
                   ", ".join("%s %d" % (level, counts[level]) for level in sorted(counts)) or "none"),
               "Illustration entries: %d." % len(illustrations),
               "Planted errors: %d planted, %d caught in the final result." % (
                   sum(t[0] for t in totals.values()), sum(t[3] for t in totals.values())),
               "Counting check: %s." % ("PASS" if gaps == 0 else "FAIL, %d gaps" % gaps), "",
               "Findings and recommendations only. No lesson was changed.", ""]
    (out_dir / "summary.md").write_text("\n".join(summary), encoding="utf-8")
    return gaps
