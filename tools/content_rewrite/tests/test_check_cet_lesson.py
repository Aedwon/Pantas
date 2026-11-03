"""Tests for check_cet_lesson. Run: python3 -I tools/content_rewrite/tests/test_check_cet_lesson.py"""
import os
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
import check_cet_lesson as cc  # noqa: E402

REL = "content/lessons/mathematics/algebra/quadratic-equations.md"


def current():
    with open(os.path.join(cc.ROOT, REL), encoding="utf-8") as f:
        return f.read()


class CheckTests(unittest.TestCase):
    def test_unchanged_lesson_passes(self):
        text = current()
        result = cc.check_text(REL, text, text)
        self.assertEqual(result["reasons"], [])
        self.assertLessEqual(result["words"], cc.WORD_CEILING)
        self.assertEqual(cc.exit_code(result), 0)

    def test_word_count_is_whitespace_words_of_the_whole_file(self):
        self.assertEqual(cc.count_words("---\na: b\n---\n\none two\nthree\n"), 7)

    def test_over_ceiling_fails_even_with_no_other_reason(self):
        text = current()
        result = cc.check_text(REL, text, text)
        result["words"] = cc.WORD_CEILING + 1
        self.assertEqual(cc.exit_code(result), 1)

    def test_changed_id_is_a_reason(self):
        text = current()
        new = text.replace('_id: "lesson-algebra-quadratic-equations"', '_id: "lesson-algebra-other"', 1)
        self.assertNotEqual(new, text)
        result = cc.check_text(REL, text, new)
        self.assertTrue(any("_id" in r for r in result["reasons"]))
        self.assertEqual(cc.exit_code(result), 1)

    def test_new_em_dash_is_a_reason(self):
        text = current()
        new = text.rstrip("\n") + "\n\nA new sentence \u2014 with a dash.\n"
        result = cc.check_text(REL, text, new)
        self.assertTrue(result["reasons"])

    def test_report_shows_reasons_notes_and_words(self):
        out = cc.format_report(REL, {"reasons": ["r1"], "notes": ["n1"], "words": 1701})
        self.assertIn("FAIL", out)
        self.assertIn("r1", out)
        self.assertIn("n1", out)
        self.assertIn("1701", out)
        self.assertIn("over the 1700-word ceiling", out)

    def test_path_outside_lessons_is_refused(self):
        with self.assertRaises(cc.CheckError):
            cc.lesson_rel_path("tools/content_rewrite/check_cet_lesson.py")


if __name__ == "__main__":
    unittest.main()
