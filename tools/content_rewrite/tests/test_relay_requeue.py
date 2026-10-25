"""Tests for planner.py requeue: the new batch's brief adds what the latest read left open.

Run as a script: python3 -I tools/content_rewrite/tests/test_relay_requeue.py
"""
import json
import os
import subprocess
import sys
import unittest

sys.dont_write_bytecode = True
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import relay_fixtures as F  # noqa: E402

import item_types  # noqa: E402
import planner  # noqa: E402
import readfindings  # noqa: E402
import rw_lib  # noqa: E402

ALPHA, BETA = F.lesson_id("alpha"), F.lesson_id("beta")
QUOTE = "A variable is one letter that stands for a number."
PROBLEM = "The word coefficient is used before the lesson says what it means."


class RequeueCase(unittest.TestCase):
    def setUp(self):
        self.repo = F.Repo()
        self.addCleanup(self.repo.cleanup)
        self.ctx = self.repo.ctx
        planner.plan(self.ctx)
        F.accept_rewrite(self.repo, "RW-001")
        planner.plan(self.ctx, kinds=["read"])
        self.repo.commit_batches()

    def form_with_findings(self, lesson_id):
        form = F.good_form(self.repo, lesson_id)
        rule = next(rid for rid, e in form["rules"].items() if e["verdict"] == "pass")
        form["rules"][rule] = {"verdict": "fail", "checked": [], "note": "",
                               "findings": [{"quote": QUOTE, "problem": PROBLEM}]}
        item = next(iter(form["brief_items"]))
        form["brief_items"][item] = {"status": "not_fixed", "quote": QUOTE, "note": "The sentence still ends the same."}
        form["accuracy_concerns"] = [{"quote": QUOTE, "concern": "The sum is stated as a product."}]
        return form, rule, item

    def save_read(self, batch_id, lesson_id, form, wrapped):
        data = {"batch": batch_id, "lesson_id": lesson_id, "form": form} if wrapped else form
        self.repo.write(F.read_path(batch_id, lesson_id), json.dumps(data, indent=1))
        return data


class Contents(RequeueCase):
    def test_the_brief_adds_findings_concerns_and_items_not_fixed(self):
        form, rule, item = self.form_with_findings(ALPHA)
        self.save_read("RD-001", ALPHA, form, wrapped=True)
        batch_id = planner.requeue(self.ctx, [ALPHA, BETA])
        batch = self.ctx.batch(batch_id)
        self.assertEqual((batch_id, batch["type"], batch["round"]), ("RW-003", "rewrite", 2))
        self.assertEqual(sorted(batch["extra_brief"]), [ALPHA], "a lesson with no read gets no addition")
        text = batch["extra_brief"][ALPHA]
        self.assertIn("## Left open by the earlier read (RD-001)", text)
        self.assertIn("Rule %s" % rule, text)
        self.assertIn(PROBLEM, text)
        self.assertIn(QUOTE, text)
        self.assertIn("The sum is stated as a product.", text)
        self.assertIn("Item `%s`" % item, text)
        self.assertIn("The sentence still ends the same.", text)
        self.assertIn("A variable is one of these letters.", text, "the item's own quote from the brief is repeated")

    def test_a_bare_form_from_a_pull_request_is_read_like_a_wrapped_one(self):
        form, rule, _ = self.form_with_findings(ALPHA)
        self.save_read("RD-001", ALPHA, form, wrapped=False)
        batch = self.ctx.batch(planner.requeue(self.ctx, [ALPHA]))
        self.assertIn(PROBLEM, batch["extra_brief"][ALPHA])

    def test_the_newest_read_is_the_one_used(self):
        old, _, _ = self.form_with_findings(ALPHA)
        self.save_read("RD-001", ALPHA, old, wrapped=True)
        clean = F.good_form(self.repo, ALPHA)
        self.save_read("RD-007", ALPHA, clean, wrapped=False)
        batch = self.ctx.batch(planner.requeue(self.ctx, [ALPHA]))
        self.assertNotIn("extra_brief", batch, "the newest read left nothing open")

    def test_nothing_open_means_no_addition(self):
        self.save_read("RD-001", ALPHA, F.good_form(self.repo, ALPHA), wrapped=True)
        self.assertNotIn("extra_brief", self.ctx.batch(planner.requeue(self.ctx, [ALPHA])))

    def test_the_prompt_carries_the_addition_inside_the_brief_block(self):
        form, _, _ = self.form_with_findings(ALPHA)
        self.save_read("RD-001", ALPHA, form, wrapped=True)
        batch = self.ctx.batch(planner.requeue(self.ctx, [ALPHA]))
        for mode in ("pr", "relay"):
            text = item_types.get("rewrite").prompt(self.ctx, batch, mode)
            brief = text[text.index("<<<<<<<< BRIEF START"):text.index(">>>>>>>> BRIEF END")]
            self.assertIn("## Left open by the earlier read (RD-001)", brief)
            self.assertIn(PROBLEM, brief)
            self.assertIn("## A second round", text)

    def test_the_new_batch_is_a_file_and_the_old_batches_are_untouched(self):
        before = (self.repo.root / rw_lib.BATCHES_REL / "RW-001.json").read_text()
        batch_id = planner.requeue(self.ctx, [ALPHA])
        self.assertTrue((self.repo.root / rw_lib.BATCHES_REL / (batch_id + ".json")).exists())
        self.assertEqual((self.repo.root / rw_lib.BATCHES_REL / "RW-001.json").read_text(), before)
        self.assertEqual(self.ctx.load_batches()["order"][-1], batch_id)

    def test_an_unknown_lesson_is_refused(self):
        with self.assertRaises(rw_lib.RewriteError):
            planner.requeue(self.ctx, [ALPHA, "lesson-nope"])

    def test_the_command_line(self):
        form, _, _ = self.form_with_findings(ALPHA)
        self.save_read("RD-001", ALPHA, form, wrapped=True)
        env = dict(os.environ, PANTAS_REWRITE_ROOT=str(self.repo.root), PANTAS_REWRITE_STATE=str(self.repo.state))
        proc = subprocess.run([sys.executable, "-I", str(rw_lib.RELAY_DIR / "planner.py"), "requeue", ALPHA],
                              env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        self.assertEqual((proc.returncode, proc.stdout.decode().strip()), (0, "batch added: RW-003"), proc.stderr)
        proc = subprocess.run([sys.executable, "-I", str(rw_lib.RELAY_DIR / "planner.py"), "export"],
                              env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        self.assertEqual(proc.returncode, 0, proc.stderr)


class Helpers(unittest.TestCase):
    def test_brief_addition_is_empty_without_open_items(self):
        self.assertEqual(readfindings.brief_addition(None), "")
        self.assertEqual(readfindings.brief_addition({"read": "RD-001", "findings": [], "concerns": [], "not_fixed": []}), "")


if __name__ == "__main__":
    unittest.main()
