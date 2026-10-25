"""Tests for the prompt builder: what a chat is told for a rewrite batch and a read batch.

Run as a script: python3 -I tools/content_rewrite/tests/test_relay_prompts.py
"""
import json
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


class RewritePrompt(unittest.TestCase):
    def setUp(self):
        self.repo = F.Repo()
        self.addCleanup(self.repo.cleanup)
        self.ctx = self.repo.ctx
        planner.plan(self.ctx)
        self.batch = self.ctx.batch("RW-001")
        self.text = item_types.get("rewrite").prompt(self.ctx, self.batch, "relay")

    def test_holds_brief_and_current_lesson_for_every_lesson(self):
        for lesson_id in self.batch["lessons"]:
            slug = lesson_id.replace("lesson-algebra-", "")
            self.assertIn(F.brief_text(slug).strip(), self.text)
            self.assertIn(F.lesson_text(slug).rstrip("\n"), self.text)
            self.assertIn("%s/RW-001/%s.md" % (rw_lib.INBOX_REL, lesson_id), self.text)
        self.assertEqual(self.text.count(prompts.LESSON_START), 3)
        self.assertEqual(self.text.count(prompts.BRIEF_START), 3)

    def test_standards_are_inlined_once(self):
        self.assertEqual(self.text.count(F.STYLE_GUIDE.strip()), 1)
        self.assertEqual(self.text.count(F.CHECKLIST.strip()), 1)
        main = F.git(self.repo.root, "rev-parse", "--short=8", "origin/main").strip()
        self.assertIn(main, self.text)

    def test_the_rules(self):
        for needle in (
            'Fix every item under "Fix these"', 'Add every item under "CSE teaching to add"',
            'only when you are editing that passage anyway', "Never remove a case", "frontmatter id line",
            "<!-- ILLUSTRATION:", "Write no em dashes", "American spelling", "\\dfrac", "Grade 5",
            "Write the whole lesson file",
        ):
            self.assertIn(needle, self.text)

    def test_relay_steps(self):
        for needle in (
            "workspace_write_file", "workspace_exec", "git_push_current", "Pantas-wt-cse-rewrite-r1",
            "tools/content_rewrite/relay/handin.py", "Aedwon/chatgpt-terminal-relay", "make no other relay request",
            "Read no other Issue", "Change no file other than the saved files", "rejected twice is held",
            "ACCEPTED", "REJECTED", "HELD", "COMMITTED",
        ):
            self.assertIn(needle, self.text)
        bodies = re.findall(r"```json\n(.*?)\n```", self.text, re.S)
        requests = [json.loads(b) for b in bodies]
        self.assertEqual([r["action"] for r in requests], ["workspace_write_file", "workspace_exec", "git_push_current"])
        self.assertEqual(requests[1]["argv"], ["python3", "-I", rw_lib.HANDIN_REL, "RW-001", "1"])
        self.assertTrue(all(r["relay_version"] == 2 and r["workspace"] == rw_lib.WORKSPACE for r in requests))

    def test_no_forbidden_words_in_the_authored_text(self):
        parts = prompts.Parts()
        parts.add("fine text")
        prompts.check_authored(parts)
        for bad in ("A {{PLACEHOLDER}}", "TODO later", "pass ROLE here", "use ATTEMPT", "a dash \u2014 here",
                    "the colour red", "<batch-id>"):
            parts = prompts.Parts()
            parts.add(bad)
            with self.assertRaises(rw_lib.RewriteError, msg=bad):
                prompts.check_authored(parts)
        # The built prompt's own text is clean, while the lessons and standards it carries may hold anything.
        for word in ("{{", "TODO", "ROLE", "ATTEMPT", "<batch", "<lesson"):
            self.assertNotIn(word, self.text)

    def test_embedded_text_is_not_checked(self):
        self.repo.write(F.lesson_path("alpha"), F.lesson_text("alpha") + "\nOld text \u2014 with a dash and colour.\n")
        F.git(self.repo.root, "commit", "-qam", "dash")
        text = item_types.get("rewrite").prompt(self.ctx, self.batch, "relay")
        self.assertIn("Old text \u2014 with a dash and colour.", text)

    def test_missing_standards_is_an_error(self):
        F.git(self.repo.root, "update-ref", "-d", "refs/remotes/origin/main")
        with self.assertRaises(rw_lib.RewriteError):
            item_types.get("rewrite").prompt(self.ctx, self.batch, "relay")


class ReadPrompt(unittest.TestCase):
    def setUp(self):
        self.repo = F.Repo()
        self.addCleanup(self.repo.cleanup)
        self.ctx = self.repo.ctx
        planner.plan(self.ctx)

    def accept_and_plan(self, with_stray_change=False):
        if with_stray_change:
            self.repo.inbox("RW-001", F.lesson_id("alpha") + ".md", F.rewritten("alpha").replace(
                "## Traps to Watch For", "Pineapples grow on bushes near tropical shores.\n\n## Traps to Watch For"))
            self.repo.inbox("RW-001", F.lesson_id("beta") + ".md", F.rewritten("beta"))
            self.repo.inbox("RW-001", F.lesson_id("delta") + ".md", F.rewritten("delta"))
            import handin
            handin.process("RW-001", "1", self.ctx)
        else:
            F.accept_rewrite(self.repo, "RW-001")
        planner.plan(self.ctx, kinds=["read"])
        batch = self.ctx.batch("RD-001")
        return batch, item_types.get("read").prompt(self.ctx, batch, "relay")

    def test_holds_rewritten_lessons_brief_form_and_standards(self):
        batch, text = self.accept_and_plan()
        for lesson_id in batch["lessons"]:
            slug = lesson_id.replace("lesson-algebra-", "")
            self.assertIn(F.rewritten(slug).rstrip("\n"), text)
            self.assertNotIn(F.lesson_text(slug).rstrip("\n"), text, "the old text is not given to the reader")
            self.assertIn(F.brief_text(slug).strip(), text)
            self.assertIn("`%s/RD-001/%s.json`" % (rw_lib.INBOX_REL, lesson_id), text)
        self.assertEqual(text.count(F.STYLE_GUIDE.strip()), 1)
        self.assertIn("How to judge", text)
        self.assertIn("### Brief items", text)

    def test_form_blocks_carry_brief_items_and_no_l01(self):
        batch, text = self.accept_and_plan()
        forms = [json.loads(b) for b in re.findall(r"```json\n(\{\n \"packet\".*?)\n```", text, re.S)]
        self.assertEqual(len(forms), 3)
        form = forms[0]
        lid = form["packet"]
        self.assertEqual(form["role"], "A")
        self.assertIn("brief_items", form)
        self.assertEqual(set(form["brief_items"]), {lid + "|L02|0", lid + "#7", lid + "|L03|0"})
        self.assertNotIn("L01", form["rules"])
        self.assertIn("L02", form["rules"])
        self.assertEqual(form["lesson_sha256"], rw_lib.sha256_text(F.rewritten(lid.replace("lesson-algebra-", ""))))

    def test_l18_example_coverage_guidance_in_both_modes(self):
        batch, _ = self.accept_and_plan()
        paragraph = (
            "Judge L18 by the cases the target exam actually tests. A missing case is a finding only when it is "
            "a distinct exam-relevant scenario the lesson teaches or the brief asks for, not every possible "
            "variation, and not a case another lesson teaches. Changing only numbers or nouns is not a new case."
        )
        for mode in ("relay", "pr"):
            with self.subTest(mode=mode):
                text = item_types.get("read").prompt(self.ctx, batch, mode)
                self.assertIn(paragraph, text)

    def test_relay_steps_save_json_forms(self):
        batch, text = self.accept_and_plan()
        bodies = [json.loads(b) for b in re.findall(r"```json\n(\{\"relay_version.*?)\n```", text, re.S)]
        self.assertEqual(bodies[0]["path"], "%s/RD-001/%s.json" % (rw_lib.INBOX_REL, batch["lessons"][0]))
        self.assertEqual(bodies[1]["argv"][-2:], ["RD-001", "1"])
        self.assertIn("git_push_current", text)
        for word in ("{{", "TODO", "ROLE", "ATTEMPT"):
            self.assertNotIn(word, text)

    def test_unmatched_changes_are_shown_to_the_reader(self):
        batch, text = self.accept_and_plan(with_stray_change=True)
        self.assertIn("### Changes that match no brief item", text)
        self.assertIn("Pineapples grow on bushes", text)

    def test_prerequisites_when_the_lead_provides_them(self):
        batch, _ = self.accept_and_plan()
        self.ctx.state.mkdir(parents=True, exist_ok=True)
        lid = batch["lessons"][0]
        other = batch["lessons"][1]
        (self.ctx.state / "prerequisites.json").write_text(json.dumps({lid: [other]}))
        text = item_types.get("read").prompt(self.ctx, batch, "relay")
        self.assertIn("#### Prerequisite lesson: %s" % other, text)

    def test_a_lesson_changed_after_the_batch_was_built_is_an_error(self):
        batch, _ = self.accept_and_plan()
        self.repo.write(F.lesson_path("alpha"), F.rewritten("alpha") + "\nextra\n")
        F.git(self.repo.root, "commit", "-qam", "edit")
        with self.assertRaises(rw_lib.RewriteError):
            item_types.get("read").prompt(self.ctx, batch, "relay")


if __name__ == "__main__":
    unittest.main()
