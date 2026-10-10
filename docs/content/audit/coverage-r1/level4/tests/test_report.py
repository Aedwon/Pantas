import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import compare  # noqa: E402
import fixtures  # noqa: E402
import l4lib  # noqa: E402
import report  # noqa: E402

PLANTED_TEXT = "Factoring is efficient when the quadratic has convenient factors."
OTHER_TEXT = "Factoring only works when one side is zero."
T0, T1 = "2026-10-11T09:00:00+00:00", "2026-10-11T09:06:00+00:00"


class ReportCase(unittest.TestCase):
    def setUp(self):
        self.state = Path(tempfile.mkdtemp())
        self.mechanical = Path(tempfile.mkdtemp())
        self.out = Path(tempfile.mkdtemp())
        self.index, self.lessons = {}, {}
        for packet_id, lesson_id, planted in (("L4-1000", "lesson-real", False), ("L4-2000", "lesson-twin", True),
                                              ("L4-3000", "lesson-twin", False), ("L4-4000", "lesson-held", False)):
            self.index[packet_id] = {"lesson_id": lesson_id, "planted": planted, "title": lesson_id.title(),
                                     "subject": "mathematics", "topic": "algebra",
                                     "lesson_sha256": "a" * 64, "rule_ids": l4lib.chat_rule_ids()}
        for lesson_id in ("lesson-real", "lesson-twin", "lesson-held"):
            l4lib.save_json(self.mechanical / ("%s.json" % lesson_id), {"findings": [
                {"rule": "B06", "line": 12, "text": "a dash", "problem": "em dash", "candidate": False},
                {"rule": "B09", "line": 14, "text": "marks", "problem": "maybe", "candidate": True}]})
        l4lib.save_json(self.state / "index.json", self.index)
        l4lib.save_json(self.state / "planted" / "key.json", {"lesson-twin": [
            {"rule": "L17", "label": "formula first used in an example", "must_quote": PLANTED_TEXT},
            {"rule": "L27", "label": "condition removed", "must_quote": OTHER_TEXT}]})
        # The planted lesson: chat 1 catches the L17 error, chat 2 catches neither, the ruling upholds chat 1.
        a = fixtures.failing(fixtures.valid_form("A"), "L17", PLANTED_TEXT)
        b = fixtures.valid_form("B")
        self.finish("L4-2000", a, b, ruling="fail")
        self.finish("L4-1000", fixtures.valid_form("A"), fixtures.valid_form("B"))
        self.finish("L4-3000", fixtures.valid_form("A"), fixtures.valid_form("B"))
        self.queue = {"order": ["L4-1000", "L4-2000", "L4-3000", "L4-4000"], "pilot_count": 2, "lessons": {
            packet_id: {"state": "finished", "attempt": 1, "tasks": {"A": {"started_at": T0, "finished_at": T1},
                                                       "B": {"started_at": T0, "finished_at": T1}}}
            for packet_id in ("L4-1000", "L4-2000", "L4-3000")}}
        self.queue["lessons"]["L4-4000"] = {"state": "held", "attempt": 1, "tasks": {}, "held_reason": "form rejected twice"}
        l4lib.save_json(self.state / "queue.json", self.queue)
        with open(str(self.state / "handin-events.jsonl"), "w") as handle:
            for packet_id, result in (("L4-1000", "rejected"), ("L4-1000", "accepted"), ("L4-3000", "rejected")):
                handle.write(json.dumps({"packet": packet_id, "role": "A", "result": result, "at": T1}) + "\n")

    def finish(self, packet_id, a, b, ruling=None):
        l4lib.save_json(self.state / "forms" / ("%s-A-1.json" % packet_id), a)
        l4lib.save_json(self.state / "forms" / ("%s-B-1.json" % packet_id), b)
        comparison = compare.compare(a, b, 1, fixtures.LESSON_TEXT)
        l4lib.save_json(self.state / "deciding" / ("%s.json" % packet_id), comparison)
        form = None
        if comparison["items"]:
            item = comparison["items"][0]
            pick = "uphold_a" if item["A"]["verdict"] == ruling else "uphold_b"
            form = {"rulings": {item["id"]: {"ruling": pick, "quote": PLANTED_TEXT, "reason": "The lesson supports it."}}}
        result = dict(compare.apply_ruling(comparison, form), lesson_sha256="a" * 64, standards_commit="b" * 40)
        l4lib.save_json(self.state / "results" / ("%s.json" % packet_id), result)

    def data(self):
        return report.Data(state_dir=self.state, mechanical_dir=self.mechanical,
                           lesson_text=lambda entry: fixtures.LESSON_TEXT)


class Pilot(ReportCase):
    def test_counts_caught_and_missed_planted_errors_per_chat(self):
        text = report.pilot_report(self.data())
        self.assertIn("Lessons read: 2 of 2 in the pilot (1 real, 1 check lessons).", text)
        self.assertIn("| L17 | 1 | 1 | 0 | 1 |", text)
        self.assertIn("| L27 | 1 | 0 | 0 | 0 |", text)
        self.assertIn("L27, condition removed: Chat 1 missed, Chat 2 missed, final missed", text)

    def test_counts_disputes_rejections_and_time_for_pilot_lessons_only(self):
        text = report.pilot_report(self.data())
        self.assertIn("- L17: 1", text)
        self.assertIn("Forms rejected by the check: 1.", text)
        self.assertIn("Minutes per chat: average 6, shortest 6, longest 6.", text)

    def test_does_not_name_a_packet_or_lesson(self):
        text = report.pilot_report(self.data())
        for secret in ("L4-", "lesson-twin", "lesson-real"):
            self.assertNotIn(secret, text)

    def test_a_failed_rule_at_other_text_does_not_count_as_caught(self):
        defect = {"rule": "L17", "must_quote": PLANTED_TEXT}
        elsewhere = {"L17": {"verdict": "fail", "findings": [{"quote": OTHER_TEXT, "problem": "x"}]}}
        text = fixtures.LESSON_TEXT
        self.assertFalse(report.caught(defect, elsewhere, text))
        self.assertFalse(report.caught(defect, {"L17": {"verdict": "pass", "findings": []}}, text))
        self.assertFalse(report.caught(defect, None, text))

    def test_a_defect_may_be_caught_under_any_of_its_rules_at_any_of_its_anchors(self):
        defect = {"rule": "L17", "rules": ["L17", "L25"], "must_quote": ["Not in this finding.", PLANTED_TEXT]}
        under_l25 = {"L25": {"verdict": "fail", "findings": [{"quote": PLANTED_TEXT, "problem": "x"}]}}
        under_l26 = {"L26": {"verdict": "fail", "findings": [{"quote": PLANTED_TEXT, "problem": "x"}]}}
        self.assertTrue(report.caught(defect, under_l25, fixtures.LESSON_TEXT))
        self.assertFalse(report.caught(defect, under_l26, fixtures.LESSON_TEXT))


    def test_a_finding_counts_when_it_is_near_the_planted_text_in_the_lesson_and_not_when_it_only_shares_words(self):
        # Review item 11: nearness is measured in the lesson (80 characters), not by shared words.
        defect = {"rule": "L17", "must_quote": PLANTED_TEXT}
        text = fixtures.LESSON_TEXT
        near = {"L17": {"verdict": "fail", "findings": [{"quote": "can be written in standard form as", "problem": "x"}]}}
        far_same_words = {"L17": {"verdict": "fail", "findings": [{"quote": "Move every term to one side first.", "problem": "x"}]}}
        self.assertTrue(report.caught(defect, near, text))
        self.assertFalse(report.caught(defect, far_same_words, text))
        self.assertFalse(report.caught(defect, near, "A lesson that holds neither of these passages at all."))


class Final(ReportCase):
    LESSONS = ["lesson-real", "lesson-twin", "lesson-held"]

    def test_publishes_real_lessons_and_leaves_planted_packets_out(self):
        gaps = report.publish_final(self.data(), out_dir=self.out, lessons=self.LESSONS)
        self.assertEqual(gaps, 0)
        written = sorted(path.name for path in (self.out / "findings").iterdir())
        self.assertEqual(written, ["lesson-real.md", "lesson-twin.md"])
        twin = (self.out / "findings" / "lesson-twin.md").read_text()
        self.assertIn("No rule failed.", twin)
        self.assertIn("**B06** (Minor), line 12", twin)
        self.assertNotIn("B09", twin)
        summary = (self.out / "summary.md").read_text()
        self.assertIn("Lessons read: 2 of 3. On hold: 1.", summary)
        self.assertIn("Planted errors: 2 planted, 1 caught in the final result.", summary)
        self.assertIn("Counting check: PASS.", summary)

    def test_hold_list_gives_the_reason(self):
        self.assertIn("form rejected twice", report.hold_list(self.data()))

    def test_counting_check_fails_on_a_missing_rule_or_lesson(self):
        result = l4lib.load_json(self.state / "results" / "L4-1000.json")
        del result["rules"]["L17"]
        l4lib.save_json(self.state / "results" / "L4-1000.json", result)
        text, gaps = report.counting_check(self.data(), self.LESSONS + ["lesson-never-read"])
        self.assertEqual(gaps, 2)
        self.assertIn("lesson-real: rule L17 has no verdict", text)
        self.assertIn("lesson-never-read: no finished result", text)
        self.assertIn("B04: not assessed", text)

    def edit_result(self, packet_id, change):
        result = l4lib.load_json(self.state / "results" / ("%s.json" % packet_id))
        change(result)
        l4lib.save_json(self.state / "results" / ("%s.json" % packet_id), result)

    def test_the_counting_check_revalidates_every_saved_result(self):
        self.edit_result("L4-1000", lambda r: r["rules"]["L17"].update(verdict="fail", findings=[
            {"quote": "A sentence that is not in the lesson anywhere.", "problem": "x" * 25}]))
        self.edit_result("L4-3000", lambda r: r.update(lesson_sha256="f" * 64))
        text, gaps = report.counting_check(self.data(), self.LESSONS)
        self.assertEqual(gaps, 2)
        self.assertIn("lesson-real: rule L17 has a finding whose quote is not in the lesson", text)
        self.assertIn("lesson-twin: the result names a different lesson version", text)
        self.assertIn("FAIL, 2 gaps", text)

    def test_publish_final_reports_a_failed_revalidation_as_a_gap(self):
        self.edit_result("L4-1000", lambda r: r["rules"]["L17"].update(verdict="fail", findings=[]))
        gaps = report.publish_final(self.data(), out_dir=self.out, lessons=self.LESSONS)
        self.assertEqual(gaps, 1)
        self.assertIn("Counting check: FAIL, 1 gaps.", (self.out / "summary.md").read_text())

    def test_the_counting_check_requires_a_packets_own_candidate_rule(self):
        self.index["L4-1000"]["rule_ids"] = l4lib.chat_rule_ids() + ["B09"]
        l4lib.save_json(self.state / "index.json", self.index)
        text, gaps = report.counting_check(self.data(), self.LESSONS)
        self.assertEqual(gaps, 1)
        self.assertIn("lesson-real: rule B09 has no verdict", text)
        self.edit_result("L4-1000", lambda r: r["rules"].update(B09={"verdict": "pass", "findings": []}))
        self.assertEqual(report.counting_check(self.data(), self.LESSONS)[1], 0)

    def test_a_packet_without_a_candidate_rule_is_not_asked_for_one(self):
        self.assertEqual(report.counting_check(self.data(), self.LESSONS)[1], 0)

    def test_findings_name_how_each_was_settled(self):
        self.finish("L4-1000", fixtures.failing(fixtures.valid_form("A"), "L17", PLANTED_TEXT),
                    fixtures.failing(fixtures.valid_form("B"), "L17", PLANTED_TEXT))
        text = report.lesson_findings(self.data(), "L4-1000")
        self.assertIn("**L17** (Major; both reads agreed)", text)


if __name__ == "__main__":
    unittest.main()
