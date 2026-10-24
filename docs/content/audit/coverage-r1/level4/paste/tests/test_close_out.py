import json
import sys
import tempfile
import unittest
from pathlib import Path

PASTE = Path(__file__).resolve().parents[1]
LEVEL4 = PASTE.parent
sys.path.insert(0, str(LEVEL4 / "tests"))
sys.path.insert(0, str(PASTE))
import fixtures  # noqa: E402
import l4lib  # noqa: E402
import close_out  # noqa: E402
import paste_lib  # noqa: E402
import setup_paste  # noqa: E402

LESSON_ID = "lesson-algebra-quadratic-equations"
QUOTE = "Factoring is efficient when the quadratic has convenient factors."


class CloseOut(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.tmp = Path(tmp.name)
        packet = fixtures.packet()
        entry = {"id": packet["id"], "lesson_sha256": packet["lesson_sha256"],
                 "standards_commit": packet["standards_commit"], "rule_ids": l4lib.chat_rule_ids(),
                 "filipino": False, "source": "unused.md", "title": "Quadratic Equations",
                 "subject": "mathematics", "planted": False, "lesson_id": LESSON_ID}
        self.state = self.tmp / "state"
        setup_paste.create([packet["id"]], {packet["id"]: entry}, self.state)
        (self.tmp / "packets").mkdir()
        self.mechanical = self.tmp / "mechanical"
        l4lib.save_json(self.mechanical / ("%s.json" % LESSON_ID), {"findings": []})
        self.lessons = paste_lib.LessonList(state_dir=self.state, packets_dir=self.tmp / "packets",
                                            lesson_text=lambda e: fixtures.LESSON_TEXT)

    def data(self):
        return close_out.PasteData(state_dir=self.state, mechanical_dir=self.mechanical,
                                   lesson_text=lambda e: fixtures.LESSON_TEXT)

    def test_accepted_read_becomes_the_published_result(self):
        form = fixtures.failing(fixtures.valid_form("A"), "L26", QUOTE)
        self.assertEqual(self.lessons.check("L4-0417", json.dumps(form))["code"], 0)
        out = self.tmp / "results"
        self.assertEqual(close_out.publish(self.data(), out), 0)
        findings = (out / "findings" / ("%s.md" % LESSON_ID)).read_text(encoding="utf-8")
        self.assertIn("## Findings from the chat read", findings)
        self.assertIn("**L26** (Major; one read, paste run)", findings)
        self.assertEqual(l4lib.load_json(out / "data" / ("%s.json" % LESSON_ID))["rules"]["L26"]["verdict"], "fail")
        summary = (out / "summary.md").read_text(encoding="utf-8")
        self.assertIn("Lessons read: 1 of 1. On hold: 0.", summary)
        self.assertIn("Chat findings by rule: L26 1.", summary)
        self.assertIn("Counting check: PASS.", summary)

    def test_unread_lesson_fails_the_counting_check(self):
        out = self.tmp / "results"
        self.assertGreater(close_out.publish(self.data(), out), 0)
        self.assertIn("no finished result", (out / "counting-check.md").read_text(encoding="utf-8"))

    def test_form_that_no_longer_validates_is_reported(self):
        form = fixtures.failing(fixtures.valid_form("A"), "L26", QUOTE)
        self.lessons.check("L4-0417", json.dumps(form))
        data = close_out.PasteData(state_dir=self.state, mechanical_dir=self.mechanical,
                                   lesson_text=lambda e: fixtures.LESSON_TEXT.replace(QUOTE, "Changed."))
        self.assertTrue(data.problems)
        self.assertGreater(close_out.publish(data, self.tmp / "results"), 0)


if __name__ == "__main__":
    unittest.main()
