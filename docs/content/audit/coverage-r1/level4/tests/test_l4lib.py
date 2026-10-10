import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import l4lib  # noqa: E402

LESSON = """---
_id: "lesson-algebra-quadratic-equations"
title: "Quadratic Equations"
summary: "Solve quadratic equations."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 8
isActive: true
---
## Core Concept

A quadratic equation in $x$ can be written in standard form.

### Factoring

Factoring is efficient when the quadratic has
convenient factors.
"""


class ParseLesson(unittest.TestCase):
    def test_frontmatter_keys_keep_their_order(self):
        parsed = l4lib.parse_lesson(LESSON)
        self.assertEqual(
            list(parsed["frontmatter"]),
            ["_id", "title", "summary", "subject", "topic", "estimatedMinutes", "isActive"],
        )
        self.assertEqual(parsed["frontmatter"]["title"], "Quadratic Equations")
        self.assertEqual(parsed["frontmatter"]["estimatedMinutes"], 8)
        self.assertIs(parsed["frontmatter"]["isActive"], True)

    def test_headings_carry_level_title_and_line(self):
        parsed = l4lib.parse_lesson(LESSON)
        self.assertIn((2, "Core Concept", 10), parsed["headings"])
        self.assertIn((3, "Factoring", 14), parsed["headings"])

    def test_body_excludes_frontmatter(self):
        self.assertTrue(l4lib.parse_lesson(LESSON)["body"].startswith("## Core Concept"))

    def test_missing_frontmatter_is_an_error(self):
        with self.assertRaises(l4lib.L4Error):
            l4lib.parse_lesson("## Core Concept\n")


class QuoteIn(unittest.TestCase):
    def test_accepts_a_quote_wrapped_differently(self):
        self.assertTrue(l4lib.quote_in("the quadratic has convenient factors", LESSON))

    def test_rejects_a_changed_word(self):
        self.assertFalse(l4lib.quote_in("the quadratic has awkward factors", LESSON))

    def test_rejects_a_quote_too_short_to_locate(self):
        self.assertFalse(l4lib.quote_in("in $x$", LESSON))

    def test_rejects_a_non_string(self):
        self.assertFalse(l4lib.quote_in(None, LESSON))


class Rules(unittest.TestCase):
    def test_chat_rules_include_judged_and_source_check_rules_only(self):
        ids = l4lib.chat_rule_ids()
        self.assertIn("L17", ids)
        self.assertIn("L11", ids)
        self.assertNotIn("L22", ids)
        self.assertNotIn("L06", ids)
        self.assertNotIn("B04", ids)

    def test_every_major_chat_rule_requires_proof(self):
        for rule in l4lib.load_rules():
            if rule["kind"] == "chat" and rule["severity"].startswith(("Blocker", "Major")):
                self.assertTrue(rule["proof"], rule["id"])


class CheckCorpus(unittest.TestCase):
    def _repo(self):
        root = tempfile.mkdtemp()
        env = dict(os.environ, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t",
                   GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t")
        for args in (["init", "-q"], ["commit", "-q", "--allow-empty", "-m", "x"]):
            subprocess.check_call(["git"] + args, cwd=root, env=env)
        return Path(root)

    def test_wrong_commit_is_refused(self):
        with self.assertRaises(l4lib.L4Error):
            l4lib.check_corpus(self._repo())

    def test_dirty_tree_is_refused(self):
        root = self._repo()
        head = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip()
        (root / "stray.md").write_text("x")
        with self.assertRaises(l4lib.L4Error):
            l4lib.check_corpus(root, commit=head)

    def test_matching_clean_tree_passes(self):
        root = self._repo()
        head = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip()
        l4lib.check_corpus(root, commit=head)


class Json(unittest.TestCase):
    def test_save_then_load_round_trips(self):
        path = Path(tempfile.mkdtemp()) / "a" / "b.json"
        l4lib.save_json(path, {"k": [1, 2]})
        self.assertEqual(l4lib.load_json(path), {"k": [1, 2]})


if __name__ == "__main__":
    unittest.main()
