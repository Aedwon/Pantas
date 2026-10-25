"""Tests for the pull-request prompts: GitHub steps present, no word of the old relay, nothing else changed.

Run as a script: python3 -I tools/content_rewrite/tests/test_relay_pr_prompts.py
"""
import re
import sys
import unittest

sys.dont_write_bytecode = True
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import relay_fixtures as F  # noqa: E402

import item_types  # noqa: E402
import planner  # noqa: E402
import prompts  # noqa: E402
import rw_lib  # noqa: E402

RELAY_WORDS = ("relay", "terminal", "inbox", "workspace", "handin.py", "git_push", "workspace_exec", "[relay]",
               "chatgpt-terminal")


class Steps:
    """What both prompt kinds must say about handing in."""

    def steps(self):
        return self.text[self.text.index("## How to hand in"):]

    def test_the_github_steps_are_there(self):
        steps = self.steps()
        self.assertIn("`Aedwon/Pantas`", steps)
        self.assertIn("Create the branch `cse-inbox/%s` from the current head of the branch `content/cse-rewrite-r1`"
                      % self.batch["id"], steps)
        self.assertIn("into `content/cse-rewrite-r1`", steps)
        self.assertIn("`[handin] %s`" % self.batch["id"], steps)
        self.assertIn("`CSE hand-in`", steps)
        for word in ("`ACCEPTED`", "`REJECTED`", "`HELD`"):
            self.assertIn(word, steps)

    def test_the_rejection_rules(self):
        steps = self.steps()
        self.assertIn("Fix exactly the listed reasons and nothing else", steps)
        self.assertIn("same branch", steps)
        self.assertIn("Do not open a new pull request", steps)
        self.assertIn("after the first and the second rejection only", steps)
        self.assertIn("a workflow merges the pull request", steps)
        self.assertIn("Never merge the pull request yourself", steps)

    def test_the_scope_rules(self):
        steps = self.steps()
        self.assertIn("Read no other issue or pull request", steps)
        self.assertIn("create no other branch", steps)
        self.assertIn("Open no other pull request", steps)
        self.assertIn("Change no file other than the files named above", steps)

    def test_no_word_of_the_old_relay_anywhere(self):
        lowered = self.text.lower().replace("cse-inbox", "")   # the branch name is the one allowed use of the word
        for word in RELAY_WORDS:
            self.assertNotIn(word, lowered, word)

    def test_authored_text_check_catches_a_relay_word(self):
        parts = prompts.Parts()
        parts.add("Send it through the terminal.")
        with self.assertRaises(rw_lib.RewriteError):
            prompts.check_authored(parts, pull_request=True)
        prompts.check_authored(parts)   # the old prompt may still say it

    def test_every_file_has_its_path(self):
        for lesson_id in self.batch["lessons"]:
            self.assertIn("File path: `%s`" % self.path_of(lesson_id), self.text)


class Rewrite(Steps, unittest.TestCase):
    def setUp(self):
        self.repo = F.Repo()
        self.addCleanup(self.repo.cleanup)
        self.ctx = self.repo.ctx
        planner.plan(self.ctx)
        self.batch = self.ctx.batch("RW-001")
        self.text = item_types.get("rewrite").prompt(self.ctx, self.batch)

    def path_of(self, lesson_id):
        return self.batch["paths"][lesson_id]

    def test_the_lesson_goes_to_its_real_path(self):
        self.assertIn("File path: `content/lessons/mathematics/algebra/alpha.md`", self.text)
        self.assertNotIn("tools/content_rewrite", self.text)

    def test_the_rest_of_the_prompt_is_unchanged(self):
        relay = item_types.get("rewrite").prompt(self.ctx, self.batch, "relay")
        for marker in (prompts.LESSON_START, prompts.BRIEF_START, "## Rules for the rewrite", "What the check enforces"):
            self.assertEqual(self.text.count(marker), relay.count(marker), marker)

    def test_the_old_prompt_is_still_available_for_manual_use(self):
        relay = item_types.get("rewrite").prompt(self.ctx, self.batch, "relay")
        self.assertIn("terminal relay", relay)
        self.assertIn("workspace_exec", relay)
        self.assertIn("Save file: `%s/RW-001/" % rw_lib.INBOX_REL, relay)

    def test_the_prompt_says_a_lesson_file_ends_with_one_newline(self):
        self.assertIn("one final newline", self.text)

    def test_a_second_round_brief_is_added(self):
        batch = dict(self.batch, extra_brief={self.batch["lessons"][0]: "## Left open by the earlier read (RD-009)\n\n1. x"})
        text = item_types.get("rewrite").prompt(self.ctx, batch)
        self.assertEqual(text.count("## Left open by the earlier read (RD-009)"), 1)
        self.assertIn("## A second round", text)
        self.assertNotIn("## A second round", self.text)


class Read(Steps, unittest.TestCase):
    def setUp(self):
        self.repo = F.Repo()
        self.addCleanup(self.repo.cleanup)
        self.ctx = self.repo.ctx
        planner.plan(self.ctx)
        code, _ = F.accept_rewrite(self.repo, "RW-001")
        assert code == 0
        planner.plan(self.ctx, kinds=["read"])
        self.batch = self.ctx.batch("RD-001")
        self.text = item_types.get("read").prompt(self.ctx, self.batch)

    def path_of(self, lesson_id):
        return "%s/RD-001/%s.json" % (rw_lib.READS_REL, lesson_id)

    def test_the_form_goes_to_the_reads_folder(self):
        self.assertIn("Save it as `docs/content/rewrite/reads/RD-001/%s.json`" % self.batch["lessons"][0], self.text)
        self.assertIn("The path is new", self.text)

    def test_the_form_and_the_rules_are_still_there(self):
        self.assertEqual(self.text.count("### The form for"), 3)
        self.assertIn("What the check enforces", self.text)
        self.assertIn("It changes only the files named above", self.text)

    def test_the_old_prompt_is_still_available_for_manual_use(self):
        relay = item_types.get("read").prompt(self.ctx, self.batch, "relay")
        self.assertIn("terminal relay", relay)
        self.assertIn("`%s/RD-001/" % rw_lib.INBOX_REL, relay)


if __name__ == "__main__":
    unittest.main()
