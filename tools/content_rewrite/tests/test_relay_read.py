"""Tests for the read hand-in: the Level 4 form plus the brief_items section.

Run as a script: python3 -I tools/content_rewrite/tests/test_relay_read.py
"""
import json
import sys
import unittest

sys.dont_write_bytecode = True
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import relay_fixtures as F  # noqa: E402

import handin  # noqa: E402
import planner  # noqa: E402
import readpacket  # noqa: E402
import rw_lib  # noqa: E402

BATCH = "RD-001"
ALPHA = F.lesson_id("alpha")


class ReadCase(unittest.TestCase):
    def setUp(self):
        self.repo = F.Repo()
        self.addCleanup(self.repo.cleanup)
        self.ctx = self.repo.ctx
        planner.plan(self.ctx)
        code, _ = F.accept_rewrite(self.repo, "RW-001")
        assert code == 0
        planner.plan(self.ctx, kinds=["read"])
        self.repo.commit_batches()
        self.batch = self.ctx.batch(BATCH)
        self.lessons = self.batch["lessons"]
        self.form = F.good_form(self.repo, self.lessons[0])

    def save(self, lesson_id, form):
        text = form if isinstance(form, (str, bytes)) else json.dumps(form)
        self.repo.inbox(BATCH, lesson_id + ".json", text)

    def hand_in(self, attempt="1"):
        return handin.process(BATCH, attempt, self.ctx)

    def reasons(self, form):
        self.save(self.lessons[0], form)
        code, lines = self.hand_in()
        return code, lines


class Accept(ReadCase):
    def test_valid_form_is_accepted_and_committed(self):
        before, remote = self.repo.head(), self.repo.remote_head()
        for lesson_id in self.lessons:
            self.save(lesson_id, F.good_form(self.repo, lesson_id))
        code, lines = self.hand_in()
        self.assertEqual(code, 0, lines)
        self.assertNotEqual(self.repo.head(), before)
        self.assertEqual(self.repo.remote_head(), remote)
        self.assertEqual(F.git(self.repo.root, "log", "-1", "--format=%B").strip(), "read: RD-001 " + " ".join(self.lessons))
        saved_path = self.repo.root / rw_lib.READS_REL / BATCH / (self.lessons[0] + ".json")
        saved = json.loads(saved_path.read_text())
        self.assertEqual(saved["lesson_id"], self.lessons[0])
        self.assertEqual(saved["lesson_sha256"], self.form["lesson_sha256"])
        self.assertEqual(saved["rewrite_commit"], self.batch["rewrites"][self.lessons[0]])
        self.assertEqual(set(saved["form"]["brief_items"]), set(self.form["brief_items"]))
        self.assertEqual(F.git(self.repo.root, "status", "--porcelain").strip(), "")
        self.assertEqual(self.ctx.accepted("read", self.lessons[0])["batch"], BATCH)

    def test_not_fixed_items_are_accepted_and_counted(self):
        for item in self.form["brief_items"].values():
            item["status"] = "not_fixed"
        code, lines = self.reasons(self.form)
        self.assertEqual(code, 0, lines)
        self.assertEqual(self.ctx.accepted("read", self.lessons[0])["not_fixed"], 3)

    def test_unknown_fields_are_dropped_from_the_saved_form(self):
        self.form["secret"] = "x"
        self.reasons(self.form)
        saved = (self.repo.root / rw_lib.READS_REL / BATCH / (self.lessons[0] + ".json")).read_text()
        self.assertNotIn("secret", saved)

    def test_output_has_no_lesson_text(self):
        code, lines = self.reasons(self.form)
        self.assertNotIn("stands for a number", "\n".join(lines))


class BriefItems(ReadCase):
    def rejected(self, form, expect):
        code, lines = self.reasons(form)
        self.assertEqual(code, 1, lines)
        self.assertTrue(any(expect in line for line in lines), (expect, lines))
        self.assertIsNone(self.ctx.accepted("read", self.lessons[0]))
        return lines

    def test_missing_section(self):
        del self.form["brief_items"]
        self.rejected(self.form, "brief_items must be an object")

    def test_missing_item(self):
        first = sorted(self.form["brief_items"])[0]
        del self.form["brief_items"][first]
        lines = self.rejected(self.form, "missing 1 brief items")
        self.assertTrue(any(first in line for line in lines))

    def test_unknown_item_is_counted_not_echoed(self):
        self.form["brief_items"]["made up id with text"] = {"status": "fixed", "quote": "x", "note": "y"}
        lines = self.rejected(self.form, "1 ids that are not on this lesson's brief")
        self.assertFalse(any("made up" in line for line in lines))

    def test_bad_status_and_empty_status(self):
        item = sorted(self.form["brief_items"])[0]
        self.form["brief_items"][item]["status"] = "partly"
        self.rejected(self.form, "status must be one of fixed, not_fixed")
        self.form["brief_items"][item]["status"] = ""
        self.save(self.lessons[0], self.form)

    def test_quote_must_be_in_the_rewritten_lesson(self):
        item = sorted(self.form["brief_items"])[0]
        self.form["brief_items"][item]["quote"] = "A variable is one of these letters."  # the old text
        self.rejected(self.form, "quote is not exact text from the rewritten lesson")

    def test_note_must_say_something(self):
        item = sorted(self.form["brief_items"])[0]
        self.form["brief_items"][item]["note"] = "ok"
        self.rejected(self.form, "note must say what you checked")


class FormRules(ReadCase):
    def rejected(self, form, expect, code_expected=1):
        code, lines = self.reasons(form)
        self.assertEqual(code, code_expected, lines)
        self.assertTrue(any(expect in line for line in lines), (expect, lines))
        return lines

    def test_header_must_match_the_new_hash(self):
        self.form["lesson_sha256"] = rw_lib.sha256_text(F.lesson_text("alpha"))  # the hash of the old lesson
        self.rejected(self.form, "field lesson_sha256 does not match")

    def test_every_rule_needs_a_verdict(self):
        self.form["rules"]["B01"]["verdict"] = ""
        self.rejected(self.form, "rule B01 has no valid verdict")

    def test_a_fail_needs_a_finding_with_a_real_quote(self):
        self.form["rules"]["B01"] = {"verdict": "fail", "checked": [], "note": "",
                                     "findings": [{"quote": "text that is not in the lesson", "problem": "This is wrong in a way."}]}
        self.rejected(self.form, "the quote is not exact text from the lesson")

    def test_a_rule_missing_from_the_form(self):
        del self.form["rules"]["B02"]
        self.rejected(self.form, "rules are missing: B02")

    def test_not_valid_json_gets_more_tries(self):
        for attempt in range(1, 5):
            self.save(self.lessons[0], '{"packet": "x", \\frac')
            code, lines = self.hand_in(str(attempt))
            self.assertEqual(code, 1, lines)
            self.assertIn("not valid JSON", "\n".join(lines))
        self.save(self.lessons[0], "{")
        code, lines = self.hand_in("5")
        self.assertEqual(code, 2, lines)
        self.assertEqual(self.ctx.rejections(BATCH, self.lessons[0]), (0, 5))

    def test_two_readable_rejections_hold(self):
        self.form["rules"]["B01"]["verdict"] = ""
        self.save(self.lessons[0], self.form)
        self.assertEqual(self.hand_in("1")[0], 1)
        self.save(self.lessons[0], self.form)
        code, lines = self.hand_in("2")
        self.assertEqual(code, 2, lines)

    def test_a_lesson_that_changed_since_the_batch_stops_the_run(self):
        self.save(self.lessons[0], self.form)
        self.repo.write(F.lesson_path("alpha"), F.rewritten("alpha") + "\nedited\n")
        F.git(self.repo.root, "commit", "-qam", "edit")
        code, lines = self.hand_in()
        self.assertEqual(code, 3, lines)
        self.assertTrue((self.ctx.state / "stop.json").exists())

    def test_stray_change_stops_a_read_too(self):
        self.save(self.lessons[0], self.form)
        self.repo.write("notes.txt", "x")
        self.assertEqual(self.hand_in()[0], 3)

    def test_rewrite_files_may_not_be_touched_by_a_read(self):
        self.save(self.lessons[0], self.form)
        self.repo.write(F.lesson_path("alpha"), F.rewritten("alpha") + "\nedited\n")
        self.assertEqual(self.hand_in()[0], 3)


class Packet(unittest.TestCase):
    def test_rule_ids_drop_l01_and_keep_script_candidates(self):
        text = F.lesson_text("alpha") + "\nThe marks are 5 points.\n"
        ids = readpacket.rule_ids(text, F.lesson_path("alpha"))
        self.assertNotIn("L01", ids)
        self.assertIn("L02", ids)
        self.assertIn("B09", ids)  # "marks" is a script candidate the reader must judge

    def test_filipino_detection(self):
        self.assertTrue(rw_lib.is_filipino("content/lessons/language-proficiency/filipino/x.md", "text"))
        self.assertTrue(rw_lib.is_filipino("content/lessons/a/b/c.md", "## Core Concept\n\n## Filipino section\n"))
        self.assertFalse(rw_lib.is_filipino("content/lessons/a/b/c.md", "## Core Concept\n"))


if __name__ == "__main__":
    unittest.main()
