"""Close out the Level 4 paste run: check every accepted form again and publish the results.

Usage: python3 -I level4/paste/close_out.py

The paste run has one read per lesson (decision D4), no deciding chat and no
planted lessons, so each accepted form is the lesson's result. Every form is
validated again against the pinned lesson, then the existing report builders
write the findings, illustration list, counting check, hold list and summary
to level4/paste/results/.

Exit codes: 0 every check passed, 1 a check found gaps (results are still written).
"""
import sys
from pathlib import Path

PASTE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(PASTE_DIR))  # python3 -I does not add the script's folder

import paste_lib  # noqa: E402  (also puts the level 4 folder on sys.path)
import form  # noqa: E402
import l4lib  # noqa: E402
import report  # noqa: E402

SOURCE = "single"
OUT_DIR = PASTE_DIR / "results"


def to_result(accepted):
    """An accepted read as a final result, in the shape compare.apply_ruling writes."""
    rules = {rule_id: {"verdict": entry["verdict"], "checked": entry["checked"], "note": entry["note"],
                       "findings": [dict(finding, source=SOURCE) for finding in entry["findings"]],
                       "state": "single", "source": SOURCE}
             for rule_id, entry in accepted["rules"].items()}
    return {"lesson_sha256": accepted["lesson_sha256"], "standards_commit": accepted["standards_commit"],
            "rules": rules, "illustrations": [dict(item, source=SOURCE) for item in accepted["illustrations"]],
            "accuracy_concerns": [dict(item, source=SOURCE) for item in accepted["accuracy_concerns"]],
            "rulings": []}


class PasteData(report.Data):
    reads_heading = "Findings from the chat read"
    source_words = {SOURCE: "one read, paste run"}

    def __init__(self, state_dir=None, mechanical_dir=None, lesson_text=None):
        lists = paste_lib.LessonList(state_dir=state_dir, lesson_text=lesson_text)
        super().__init__(state_dir=lists.state_dir, mechanical_dir=mechanical_dir, lesson_text=lesson_text)
        paste_queue, self.results, self.problems = self.queue, {}, []
        lessons = {}
        for packet_id in paste_queue["order"]:
            state = lists.state_of(packet_id, paste_queue)
            attempt = paste_queue["expected"][packet_id]["attempt"]
            lessons[packet_id] = {"state": "finished" if state == "accepted" else state, "attempt": attempt}
            if state != "accepted":
                continue
            accepted = self.load("forms", "%s-%s-%d.json" % (packet_id, paste_lib.ROLE, attempt))
            entry = self.index[packet_id]
            # A fresh run of the hand-in validator over the saved form.
            for reason in form.validate(accepted, dict(entry, lesson_text=self.lesson_text(packet_id)), paste_lib.ROLE):
                self.problems.append("%s: %s" % (entry["lesson_id"], reason))
            self.results["%s.json" % packet_id] = to_result(accepted)
        self.queue = {"order": paste_queue["order"], "lessons": lessons}

    def load(self, folder, name):
        if folder == "results":
            return self.results.get(name)
        return super().load(folder, name)


def summary(data, gaps):
    severity = {rule["id"]: rule["severity"].split(" ")[0] for rule in l4lib.load_rules()}
    by_severity, by_rule, by_subject, script = {}, {}, {}, {}
    illustrations = concerns = source_checks = 0
    finished = data.finished(planted=False)
    for packet_id in finished:
        entry, result = data.index[packet_id], data.results["%s.json" % packet_id]
        for rule_id, record in result["rules"].items():
            count = len(record["findings"])
            source_checks += record["verdict"] == "needs_source_check"
            if count:
                by_severity[severity.get(rule_id, "")] = by_severity.get(severity.get(rule_id, ""), 0) + count
                by_rule[rule_id] = by_rule.get(rule_id, 0) + count
                by_subject[entry["subject"]] = by_subject.get(entry["subject"], 0) + count
        illustrations += len(result["illustrations"])
        concerns += len(result["accuracy_concerns"])
        mechanical = l4lib.load_json(data.mechanical_dir / ("%s.json" % entry["lesson_id"]))
        for finding in mechanical["findings"]:
            if not finding["candidate"]:
                script[finding["rule"]] = script.get(finding["rule"], 0) + 1
    held = sum(1 for p in data.queue["order"] if data.queue["lessons"][p]["state"] == "held")

    def listed(counts):
        return ", ".join("%s %d" % (key, counts[key]) for key in sorted(counts, key=lambda k: (-counts[k], k))) or "none"

    lines = ["# Level 4 summary, CSE paste run", "",
             "Scope: the %d CSE Professional and Subprofessional lessons in `scope.txt` (decision E1)." % len(data.queue["order"]),
             "One ChatGPT web chat per lesson, pasted by Aedwon (decision D4). No second read, no deciding chat and "
             "no planted lessons, so this run has no miss-rate measure.", "",
             "Lessons read: %d of %d. On hold: %d." % (len(finished), len(data.queue["order"]), held),
             "Chat findings by severity: %s." % listed(by_severity),
             "Chat findings by rule: %s." % listed(by_rule),
             "Chat findings by subject: %s." % listed(by_subject),
             "Rules marked needs a source check: %d." % source_checks,
             "Script findings by rule: %s." % listed(script),
             "Illustration entries: %d. Accuracy concerns: %d." % (illustrations, concerns),
             "Fresh validation of the saved forms: %s." % (
                 "PASS" if not data.problems else "FAIL, %d problems" % len(data.problems)),
             "Counting check: %s." % ("PASS" if gaps == 0 else "FAIL, %d gaps" % gaps), "",
             "Findings and recommendations only. No lesson was changed.", ""]
    lines += ["- %s" % problem for problem in data.problems]
    return "\n".join(lines)


def publish(data=None, out_dir=None):
    data = data or PasteData()
    out_dir = Path(out_dir or OUT_DIR)
    (out_dir / "findings").mkdir(parents=True, exist_ok=True)
    illustrations = []
    for packet_id in data.finished(planted=False):
        entry = data.index[packet_id]
        (out_dir / "findings" / ("%s.md" % entry["lesson_id"])).write_text(
            report.lesson_findings(data, packet_id), encoding="utf-8")
        result = data.results["%s.json" % packet_id]
        l4lib.save_json(out_dir / "data" / ("%s.json" % entry["lesson_id"]), result)
        illustrations += [(entry["lesson_id"], item) for item in result["illustrations"]]
    lines = ["# Level 4 illustration review, CSE paste run", "", "Entries: %d." % len(illustrations), ""]
    lines += ["- `%s`: %s, %s priority, %s, %s. At: \"%s\". Draw: %s. Why: %s" % (
        lesson_id, item["status"], item["priority"], item["kind"], item["method"],
        l4lib.norm(item["position_quote"]), item["description"], item["why"]) for lesson_id, item in illustrations]
    (out_dir / "illustrations.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    lessons = [data.index[packet_id]["lesson_id"] for packet_id in data.queue["order"]]
    check_text, gaps = report.counting_check(data, lessons)
    (out_dir / "counting-check.md").write_text(check_text, encoding="utf-8")
    (out_dir / "hold-list.md").write_text(report.hold_list(data), encoding="utf-8")
    (out_dir / "summary.md").write_text(summary(data, gaps), encoding="utf-8")
    return gaps + len(data.problems)


def main(argv):
    if len(argv) != 1:
        print(__doc__)
        return 2
    problems = publish()
    print((OUT_DIR / "summary.md").read_text(encoding="utf-8"))
    return 0 if problems == 0 else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
