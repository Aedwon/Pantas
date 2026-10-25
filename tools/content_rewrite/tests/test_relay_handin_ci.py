"""Tests for the pull-request hand-in check: accept, each rejection, stray files, the batch file round trip.

Run as a script: python3 -I tools/content_rewrite/tests/test_relay_handin_ci.py
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

import handin_ci  # noqa: E402
import planner  # noqa: E402
import rw_lib  # noqa: E402

DASH = "\u2014"
SLUGS = ("alpha", "beta", "delta")        # RW-001
IDS = [F.lesson_id(s) for s in SLUGS]


class CiCase(unittest.TestCase):
    def setUp(self):
        self.repo = F.Repo()
        self.addCleanup(self.repo.cleanup)
        self.ctx = self.repo.ctx
        planner.plan(self.ctx)
        self.repo.commit_batches()

    def good_files(self):
        return {F.lesson_path(s): F.rewritten(s) for s in SLUGS}

    def check(self, files, remove=(), batch="RW-001"):
        base, head = F.pr_branch(self.repo, batch, files, remove)
        return handin_ci.process(batch, base, head, rw_lib.Ctx(root=self.repo.root, state_dir=self.repo.state))

    def text(self, lines):
        return "\n".join(lines)


class Accept(CiCase):
    def test_a_clean_rewrite_pull_request_is_accepted(self):
        code, lines = self.check(self.good_files())
        self.assertEqual((code, lines[0]), (0, "## ACCEPTED"), lines)
        self.assertIn("All 3 files", self.text(lines))

    def test_nothing_in_the_checkout_changes(self):
        self.check(self.good_files())
        self.assertEqual(F.git(self.repo.root, "status", "--porcelain", "--untracked-files=all").strip(), "")
        self.assertEqual(self.repo.remote_head(), F.git(self.repo.origin, "rev-parse", rw_lib.BRANCH).strip())

    def test_a_branch_made_before_the_base_moved_on_is_still_judged_on_its_own_changes(self):
        base, head = F.pr_branch(self.repo, "RW-001", self.good_files())
        self.repo.write("docs/other.md", "someone else's merge\n")
        F.git(self.repo.root, "add", "-A")
        F.git(self.repo.root, "commit", "-q", "-m", "other")
        moved = self.repo.head()
        code, lines = handin_ci.process("RW-001", moved, head, rw_lib.Ctx(root=self.repo.root, state_dir=self.repo.state))
        self.assertEqual(code, 0, lines)


class Rejections(CiCase):
    def test_a_stray_file_is_refused_and_named(self):
        files = self.good_files()
        files["docs/notes.md"] = "extra\n"
        files["content/lessons/mathematics/algebra/epsilon.md"] = F.rewritten("epsilon")   # not in this batch
        code, lines = self.check(files)
        out = self.text(lines)
        self.assertEqual((code, lines[0]), (1, "## REJECTED"))
        self.assertIn("**Pull request**", out)
        self.assertIn("`docs/notes.md` is not a file this batch may change", out)
        self.assertIn("epsilon.md", out)

    def test_a_stray_file_in_the_hand_in_blocks_acceptance_even_when_every_lesson_is_clean(self):
        files = self.good_files()
        files[".github/workflows/x.yml"] = "name: x\n"
        self.assertEqual(self.check(files)[0], 1)

    def test_a_deleted_file_is_refused(self):
        code, lines = self.check({}, remove=[F.lesson_path("gamma")])
        self.assertEqual(code, 1)
        self.assertIn("gamma.md", self.text(lines))
        self.assertIn("is not in the pull request", self.text(lines))

    def test_a_missing_lesson_is_named_by_id(self):
        files = self.good_files()
        del files[F.lesson_path("delta")]
        code, lines = self.check(files)
        self.assertEqual(code, 1)
        out = self.text(lines)
        self.assertIn("**%s**" % F.lesson_id("delta"), out)
        self.assertIn("1. the file is not in the pull request", out)

    def test_an_empty_pull_request_lists_every_lesson(self):
        code, lines = self.check({})
        self.assertEqual(code, 1)
        for lesson in IDS:
            self.assertIn("**%s**" % lesson, self.text(lines))

    def test_a_lesson_check_failure_gives_numbered_reasons_and_no_lesson_text(self):
        files = self.good_files()
        files[F.lesson_path("alpha")] = F.lesson_text("alpha").replace("yet.", "yet " + DASH + " secretword.")
        code, lines = self.check(files)
        out = self.text(lines)
        self.assertEqual(code, 1)
        self.assertIn("**%s**" % IDS[0], out)
        self.assertRegex(out, r"(?m)^1\. ")
        for fragment in ("secretword", "stands for a number", "We use letters", "Count the letters"):
            self.assertNotIn(fragment, out)
        self.assertNotIn("**%s**" % IDS[1], out, "a clean lesson is not listed")

    def test_a_changed_frontmatter_id_and_a_short_lesson_are_rejected(self):
        files = self.good_files()
        files[F.lesson_path("alpha")] = F.rewritten("alpha").replace('_id: "%s"' % IDS[0], '_id: "other"')
        files[F.lesson_path("beta")] = F.rewritten("beta")[:120] + "\n"
        code, lines = self.check(files)
        out = self.text(lines)
        self.assertEqual(code, 1)
        self.assertIn("frontmatter _id changed", out)
        self.assertIn("**%s**" % IDS[1], out)

    def test_crlf_line_ends_are_rejected_not_silently_fixed(self):
        files = self.good_files()
        files[F.lesson_path("alpha")] = F.rewritten("alpha").replace("\n", "\r\n").encode("utf-8")
        code, lines = self.check(files)
        self.assertEqual(code, 1)
        self.assertIn("LF line ends", self.text(lines))

    def test_a_missing_final_newline_is_rejected(self):
        files = self.good_files()
        files[F.lesson_path("alpha")] = F.rewritten("alpha").rstrip("\n")
        self.assertIn("one final newline", self.text(self.check(files)[1]))

    def test_a_symlink_in_place_of_a_lesson_is_refused(self):
        base = self.repo.head()
        F.git(self.repo.root, "checkout", "-q", "-b", "cse-inbox/RW-001", rw_lib.BRANCH)
        for slug in SLUGS[1:]:
            self.repo.write(F.lesson_path(slug), F.rewritten(slug))
        link = self.repo.root / F.lesson_path("alpha")
        link.unlink()
        os.symlink("beta.md", str(link))
        F.git(self.repo.root, "add", "-A")
        F.git(self.repo.root, "commit", "-q", "-m", "link")
        head = self.repo.head()
        F.git(self.repo.root, "checkout", "-q", rw_lib.BRANCH)
        code, lines = handin_ci.process("RW-001", base, head, rw_lib.Ctx(root=self.repo.root, state_dir=self.repo.state))
        self.assertEqual(code, 1)
        self.assertIn("regular file", self.text(lines))


class BadRequests(CiCase):
    def test_bad_ids_and_commits(self):
        ctx = rw_lib.Ctx(root=self.repo.root, state_dir=self.repo.state)
        head = self.repo.head()
        self.assertEqual(handin_ci.process("rw-1", head, head, ctx)[0], 64)
        self.assertEqual(handin_ci.process("RW-001", "zzz", head, ctx)[0], 64)
        self.assertEqual(handin_ci.process("RW-001", "a" * 40, head, ctx)[0], 64)

    def test_a_batch_with_no_file_at_the_base_is_an_error(self):
        code, lines = self.check(self.good_files(), batch="RW-009")
        self.assertEqual((code, lines[0]), (64, "## ERROR"))

    def test_the_batch_is_read_from_the_base_not_from_the_branch(self):
        files = self.good_files()
        files["%s/RW-001.json" % rw_lib.BATCHES_REL] = json.dumps({"id": "RW-001", "type": "rewrite", "topic": "x",
                                                                    "lessons": [], "paths": {}})
        code, lines = self.check(files)
        self.assertEqual(code, 1)
        self.assertIn("RW-001.json", self.text(lines))

    def test_the_script_exit_codes_and_output(self):
        base, head = F.pr_branch(self.repo, "RW-001", self.good_files())
        env = dict(os.environ, PANTAS_REWRITE_ROOT=str(self.repo.root), PANTAS_REWRITE_STATE=str(self.repo.state))
        script = str(rw_lib.RELAY_DIR / "handin_ci.py")
        proc = subprocess.run([sys.executable, "-I", script, "RW-001", base, head], env=env, stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE)
        self.assertEqual((proc.returncode, proc.stdout.decode().splitlines()[0]), (0, "## ACCEPTED"), proc.stderr)
        proc = subprocess.run([sys.executable, "-I", script, "RW-001"], env=env, stdout=subprocess.PIPE)
        self.assertEqual(proc.returncode, 64)


class ReadPullRequests(unittest.TestCase):
    def setUp(self):
        self.repo = F.Repo()
        self.addCleanup(self.repo.cleanup)
        self.ctx = self.repo.ctx
        planner.plan(self.ctx)
        code, _ = F.accept_rewrite(self.repo, "RW-001")
        assert code == 0
        planner.plan(self.ctx, kinds=["read"])
        self.repo.commit_batches()
        self.batch = self.ctx.batch("RD-001")
        self.lessons = self.batch["lessons"]

    def forms(self):
        return {F.read_path("RD-001", lid): json.dumps(F.good_form(self.repo, lid), indent=1) + "\n"
                for lid in self.lessons}

    def check(self, files, remove=()):
        base, head = F.pr_branch(self.repo, "RD-001", files, remove)
        return handin_ci.process("RD-001", base, head, rw_lib.Ctx(root=self.repo.root, state_dir=self.repo.state))

    def test_valid_forms_are_accepted(self):
        code, lines = self.check(self.forms())
        self.assertEqual((code, lines[0]), (0, "## ACCEPTED"), lines)

    def test_the_form_is_checked_against_the_lesson_at_the_base(self):
        files = self.forms()
        form = json.loads(files[F.read_path("RD-001", self.lessons[0])])
        key = next(iter(form["brief_items"]))
        form["brief_items"][key]["quote"] = "This sentence is not in the lesson at all."
        files[F.read_path("RD-001", self.lessons[0])] = json.dumps(form)
        code, lines = self.check(files)
        out = "\n".join(lines)
        self.assertEqual(code, 1)
        self.assertIn("**%s**" % self.lessons[0], out)
        self.assertIn("quote is not exact text", out)
        self.assertNotIn("This sentence is not in the lesson", out)

    def test_a_form_that_is_not_json_is_rejected(self):
        files = self.forms()
        files[F.read_path("RD-001", self.lessons[0])] = "{not json"
        code, lines = self.check(files)
        self.assertEqual(code, 1)
        self.assertIn("not valid JSON", "\n".join(lines))

    def test_a_form_at_the_wrong_path_is_a_stray_file_and_the_right_one_is_missing(self):
        files = self.forms()
        form = files.pop(F.read_path("RD-001", self.lessons[0]))
        files["docs/content/rewrite/reads/RD-001/other.json"] = form
        code, lines = self.check(files)
        out = "\n".join(lines)
        self.assertEqual(code, 1)
        self.assertIn("other.json", out)
        self.assertIn("**%s**" % self.lessons[0], out)

    def test_a_form_that_overwrites_an_existing_one_is_not_an_addition(self):
        path = F.read_path("RD-001", self.lessons[0])
        self.repo.write(path, "{}\n")
        F.git(self.repo.root, "add", "-A")
        F.git(self.repo.root, "commit", "-q", "-m", "an earlier form")
        code, lines = self.check(self.forms())
        self.assertEqual(code, 1)
        self.assertIn("adds a new file", "\n".join(lines))


class BatchFiles(unittest.TestCase):
    def setUp(self):
        self.repo = F.Repo()
        self.addCleanup(self.repo.cleanup)
        self.ctx = self.repo.ctx

    def test_plan_writes_a_batch_file_and_the_state_keeps_only_progress(self):
        planner.plan(self.ctx)
        batch = self.ctx.batch("RW-001")
        on_disk = json.loads((self.repo.root / rw_lib.BATCHES_REL / "RW-001.json").read_text())
        self.assertEqual(on_disk, batch)
        state = json.loads((self.repo.state / "batches.json").read_text())
        self.assertEqual(sorted(state), ["order"])
        self.assertEqual(state["order"], ["RW-001", "RW-002"])

    def test_round_trip_through_git(self):
        planner.plan(self.ctx)
        self.repo.commit_batches()
        committed = self.ctx.batch_at("HEAD", "RW-002")
        self.assertEqual(committed, self.ctx.batch("RW-002"))
        self.assertIsNone(self.ctx.batch_at("HEAD", "RW-099"))
        self.assertIsNone(self.ctx.batch_at("HEAD", "../x"))

    def test_a_state_file_with_inline_batches_is_read_and_moved_to_files(self):
        planner.plan(self.ctx)
        legacy = {"order": self.ctx.load_batches()["order"], "batches": self.ctx.load_batches()["batches"]}
        for path in (self.repo.root / rw_lib.BATCHES_REL).glob("*.json"):
            path.unlink()
        rw_lib.json_save(self.repo.state / "batches.json", legacy)
        self.assertEqual(self.ctx.batch("RW-001")["id"], "RW-001")
        self.ctx.save_batches(self.ctx.load_batches())   # what `planner.py export` does
        self.assertTrue((self.repo.root / rw_lib.BATCHES_REL / "RW-002.json").exists())
        self.assertEqual(sorted(json.loads((self.repo.state / "batches.json").read_text())), ["order"])

    def test_a_batch_file_is_never_changed(self):
        planner.plan(self.ctx)
        data = self.ctx.load_batches()
        data["batches"]["RW-001"]["topic"] = "changed"
        with self.assertRaises(rw_lib.RewriteError):
            self.ctx.save_batches(data)


if __name__ == "__main__":
    unittest.main()
