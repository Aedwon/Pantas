"""Tests for the rewrite hand-in script: accept, each rejection, stray changes, commit without push.

Run as a script: python3 -I tools/content_rewrite/tests/test_relay_handin.py
"""
import os
import subprocess
import sys
import unittest

sys.dont_write_bytecode = True
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import relay_fixtures as F  # noqa: E402

import checks  # noqa: E402
import handin  # noqa: E402
import planner  # noqa: E402
import rw_lib  # noqa: E402

BATCH = "RW-001"
ALPHA, BETA, DELTA = (F.lesson_id(s) for s in ("alpha", "beta", "delta"))  # RW-001 holds these three
DASH = "\u2014"


class HandinCase(unittest.TestCase):
    def setUp(self):
        self.repo = F.Repo()
        self.addCleanup(self.repo.cleanup)
        self.ctx = self.repo.ctx
        planner.plan(self.ctx)
        self.repo.commit_batches()

    def hand_in(self, attempt="1"):
        return handin.process(BATCH, attempt, self.ctx)

    def save(self, slug, text=None):
        self.repo.inbox(BATCH, F.lesson_id(slug) + ".md", text if text is not None else F.rewritten(slug))

    def reasons_text(self, lines):
        return "\n".join(lines)


class Accept(HandinCase):
    def test_accepts_commits_places_and_does_not_push(self):
        before, remote = self.repo.head(), self.repo.remote_head()
        for slug in ("alpha", "beta", "delta"):
            self.save(slug)
        code, lines = self.hand_in()
        self.assertEqual(code, 0, lines)
        self.assertTrue(lines[0].startswith("ACCEPTED"), lines)
        self.assertTrue(any(line.startswith("COMMITTED ") for line in lines), lines)
        self.assertNotEqual(self.repo.head(), before)
        self.assertEqual(self.repo.remote_head(), remote, "the script must never push")
        message = F.git(self.repo.root, "log", "-1", "--format=%B").strip()
        self.assertEqual(message, "rewrite: RW-001 %s %s %s" % (ALPHA, BETA, DELTA))
        self.assertEqual(F.git(self.repo.root, "status", "--porcelain").strip(), "")
        placed = (self.repo.root / F.lesson_path("alpha")).read_text()
        self.assertEqual(placed, F.rewritten("alpha"))
        self.assertFalse((self.repo.root / rw_lib.INBOX_REL / BATCH / (ALPHA + ".md")).exists(), "inbox is consumed")
        record = self.ctx.accepted("rewrite", ALPHA)
        self.assertEqual(record["batch"], BATCH)
        self.assertEqual(record["commit"], self.repo.head())
        files = F.git(self.repo.root, "show", "--name-only", "--format=", "HEAD").split()
        self.assertEqual(sorted(files), sorted(F.lesson_path(s) for s in ("alpha", "beta", "delta")))

    def test_output_never_holds_lesson_text(self):
        self.save("alpha", F.lesson_text("alpha").replace("yet.", "yet " + DASH + " secretword."))
        self.save("beta")
        code, lines = self.hand_in()
        out = self.reasons_text(lines)
        for fragment in ("secretword", "stands for a number", "We use letters", "Count the letters"):
            self.assertNotIn(fragment, out)

    def test_a_second_call_after_everything_is_accepted(self):
        for slug in ("alpha", "beta", "delta"):
            self.save(slug)
        self.hand_in()
        code, lines = self.hand_in("2")
        self.assertEqual(code, 0)
        self.assertIn("already accepted", lines[0])

    def test_partial_hand_in_reports_the_missing_lessons(self):
        self.save("alpha")
        code, lines = self.hand_in()
        self.assertEqual(code, 0)
        self.assertIn("NOT RECEIVED: %s, %s" % (BETA, DELTA), lines)
        self.assertTrue(lines[0].startswith("ACCEPTED: 1 of 3"))

    def test_line_ends_and_final_newline_are_normalized(self):
        self.save("alpha", F.rewritten("alpha").replace("\n", "\r\n").rstrip() + "\r\n\r\n")
        code, lines = self.hand_in()
        self.assertEqual(code, 0, lines)
        self.assertEqual((self.repo.root / F.lesson_path("alpha")).read_text(), F.rewritten("alpha"))

    def test_uncovered_change_is_flagged_not_blocked(self):
        text = F.rewritten("alpha").replace(
            "## Traps to Watch For",
            "Pineapples grow on bushes near tropical shores around Mindanao.\n\n## Traps to Watch For")
        self.save("alpha", text)
        code, lines = self.hand_in()
        self.assertEqual(code, 0, lines)
        flags = [line for line in lines if line.startswith("FLAG %s:" % ALPHA)]
        self.assertEqual(len(flags), 1, lines)
        self.assertIn("match no brief item", flags[0])
        self.assertNotIn("Pineapples", flags[0])
        saved = self.ctx.accepted("rewrite", ALPHA)["changes"]
        self.assertTrue(any(c["by"] is None and "Pineapples" in c["text"] for c in saved))


class Rejections(HandinCase):
    def rejected(self, text, expect):
        self.save("alpha", text)
        code, lines = self.hand_in()
        self.assertEqual(code, 1, lines)
        self.assertTrue(lines[0].startswith("REJECTED"), lines)
        self.assertTrue(any(expect in line for line in lines), (expect, lines))
        self.assertFalse(any(line.startswith("COMMITTED") for line in lines))
        self.assertEqual(self.repo.head(), F.git(self.repo.root, "rev-parse", "HEAD").strip())
        self.assertEqual((self.repo.root / F.lesson_path("alpha")).read_text(), F.lesson_text("alpha"), "not placed")
        return lines

    def test_frontmatter_id_changed(self):
        self.rejected(F.rewritten("alpha").replace('_id: "lesson-algebra-alpha"', '_id: "lesson-algebra-other"'), "_id")

    def test_does_not_parse(self):
        self.rejected("## Core Concept\n\nNo frontmatter here at all.\n", "does not parse")

    def test_not_valid_utf8(self):
        self.save("alpha", b"---\n_id: \xff\xfe\n---\n")
        code, lines = self.hand_in()
        self.assertEqual(code, 1)
        self.assertIn("UTF-8", "\n".join(lines))

    def test_new_em_dash(self):
        lines = self.rejected(F.rewritten("alpha").replace("yet.", "yet " + DASH + " really."), "B06")
        self.assertTrue(any("lines" in line for line in lines))

    def test_new_top_level_frac(self):
        self.rejected(F.rewritten("alpha").replace("What is $x + x$?", "What is $\\frac{1}{2} + x$?"), "B08")

    def test_much_shorter(self):
        text = F.rewritten("alpha").split("## Core Concept")[0] + "## Core Concept\n\nShort.\n"
        self.rejected(text, "under 60%")

    def test_missing_solution_label(self):
        self.rejected(F.rewritten("alpha").replace("**Solution:**", "Answer:"), "sweep STRUCT")

    def test_changed_frontmatter_shape(self):
        self.rejected(F.rewritten("alpha").replace("estimatedMinutes: 10", "estimatedMinutes: 30"), "L24")

    def test_unclosed_illustration_marker(self):
        self.rejected(F.rewritten("alpha").replace("number line with x and 2x marked -->", "number line"),
                      "not closed")

    def test_empty_illustration_marker(self):
        self.rejected(F.rewritten("alpha").replace("ILLUSTRATION: number line with x and 2x marked", "ILLUSTRATION:"),
                      "empty")

    def test_existing_problems_are_not_new(self):
        base = F.lesson_text("alpha") + "\nOld text " + DASH + " already had a dash.\n"
        self.repo.write(F.lesson_path("alpha"), base)
        F.git(self.repo.root, "commit", "-qam", "base with a dash")
        code, lines = self.hand_in_with(base.replace("Old text", "Older text"))
        self.assertEqual(code, 0, lines)

    def hand_in_with(self, text):
        self.save("alpha", text)
        return self.hand_in()

    def test_second_rejection_holds_and_a_third_call_stays_held(self):
        bad = F.rewritten("alpha").replace("yet.", "yet " + DASH + " x.")
        self.save("alpha", bad)
        code, lines = self.hand_in("1")
        self.assertEqual(code, 1)
        self.assertIn("last retry", "\n".join(lines))
        self.save("alpha", bad)
        code, lines = self.hand_in("2")
        self.assertEqual(code, 2, lines)
        self.assertTrue(lines[0].startswith("HELD"))
        self.save("alpha")
        code, lines = self.hand_in("3")
        self.assertEqual(code, 2)
        self.assertEqual(self.ctx.rejections(BATCH, ALPHA), (2, 0))

    def test_one_rejected_and_one_accepted_in_the_same_call(self):
        self.save("alpha")
        self.save("beta", F.rewritten("beta").replace("yet.", "yet " + DASH + " x."))
        code, lines = self.hand_in()
        self.assertEqual(code, 1)
        self.assertTrue(any(line.startswith("COMMITTED") and ALPHA in line for line in lines), lines)
        self.assertIsNotNone(self.ctx.accepted("rewrite", ALPHA))
        self.assertIsNone(self.ctx.accepted("rewrite", BETA))
        self.save("beta")
        code, lines = self.hand_in("2")
        self.assertEqual(code, 0, lines)

    def test_rejected_file_is_kept_in_state_not_the_repo(self):
        self.save("alpha", F.rewritten("alpha").replace("yet.", "yet " + DASH + " x."))
        self.hand_in()
        kept = list((self.ctx.state / "rejected").glob("*.bin"))
        self.assertEqual(len(kept), 1)
        self.assertEqual(F.git(self.repo.root, "status", "--porcelain").strip(), "")


class Stray(HandinCase):
    def stopped(self):
        code, lines = self.hand_in()
        self.assertEqual(code, 3, lines)
        self.assertTrue(lines[0].startswith("STOPPED"))
        self.assertTrue((self.ctx.state / "stop.json").exists())
        return lines

    def test_edit_outside_the_batch(self):
        self.save("alpha")
        self.repo.write(F.lesson_path("gamma"), F.lesson_text("gamma") + "\nstray\n")
        before = self.repo.head()
        self.stopped()
        self.assertEqual(self.repo.head(), before)
        self.assertEqual((self.repo.root / F.lesson_path("alpha")).read_text(), F.lesson_text("alpha"))

    def test_new_untracked_file(self):
        self.save("alpha")
        self.repo.write("notes.txt", "x")
        self.stopped()

    def test_staged_change(self):
        self.save("alpha")
        self.repo.write(F.lesson_path("gamma"), "changed\n")
        F.git(self.repo.root, "add", F.lesson_path("gamma"))
        self.stopped()

    def test_deleted_file(self):
        self.save("alpha")
        (self.repo.root / F.lesson_path("gamma")).unlink()
        self.stopped()

    def test_wrong_branch(self):
        self.save("alpha")
        F.git(self.repo.root, "checkout", "-q", "-b", "other")
        self.stopped()

    def test_hidden_by_skip_worktree(self):
        self.save("alpha")
        F.git(self.repo.root, "update-index", "--skip-worktree", F.lesson_path("gamma"))
        self.stopped()

    def test_stop_blocks_later_hand_ins_until_the_file_is_deleted(self):
        self.save("alpha")
        self.repo.write("notes.txt", "x")
        self.stopped()
        (self.repo.root / "notes.txt").unlink()
        code, lines = self.hand_in("2")
        self.assertEqual(code, 3)
        (self.ctx.state / "stop.json").unlink()
        code, lines = self.hand_in("3")
        self.assertEqual(code, 0, lines)

    def test_files_the_batch_will_place_may_already_be_edited(self):
        self.save("alpha")
        self.repo.write(F.lesson_path("alpha"), F.lesson_text("alpha") + "\nchat edit\n")
        code, lines = self.hand_in()
        self.assertEqual(code, 0, lines)

    def test_other_batches_inbox_files_are_ignored(self):
        self.save("alpha")
        self.repo.inbox("RW-002", F.lesson_id("gamma") + ".md", "work in progress")
        code, lines = self.hand_in()
        self.assertEqual(code, 0, lines)


class BadRequests(HandinCase):
    def test_unknown_batch_and_bad_arguments(self):
        self.assertEqual(handin.process("RW-099", "1", self.ctx)[0], 64)
        self.assertEqual(handin.process("nonsense", "1", self.ctx)[0], 64)
        self.assertEqual(handin.process(BATCH, "x", self.ctx)[0], 64)
        self.assertEqual(handin.process(BATCH, "0", self.ctx)[0], 64)

    def test_no_saved_file(self):
        code, lines = self.hand_in()
        self.assertEqual(code, 64)
        self.assertIn("no saved file", lines[0])


class CommitFailure(HandinCase):
    def test_a_failing_commit_puts_everything_back_and_stops(self):
        hook = self.repo.root / ".git" / "hooks" / "pre-commit"
        hook.parent.mkdir(exist_ok=True)
        hook.write_text("#!/bin/sh\nexit 1\n")
        hook.chmod(0o755)
        self.save("alpha")
        code, lines = self.hand_in()
        self.assertEqual(code, 3, lines)
        self.assertEqual((self.repo.root / F.lesson_path("alpha")).read_text(), F.lesson_text("alpha"))
        self.assertEqual(F.git(self.repo.root, "status", "--porcelain").strip(), "")
        self.assertIsNone(self.ctx.accepted("rewrite", ALPHA))


class AsScript(HandinCase):
    """The way the relay runs it: python3 -I on the script, with the worktree and state from the environment."""

    def run_script(self, *args):
        script = Path(rw_lib.RELAY_DIR) / "handin.py"
        env = dict(os.environ, PANTAS_REWRITE_ROOT=str(self.repo.root), PANTAS_REWRITE_STATE=str(self.repo.state),
                   GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@x.org", GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@x.org")
        proc = subprocess.run([sys.executable, "-I", str(script)] + list(args), stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE, env=env, cwd=str(self.repo.root))
        return proc.returncode, proc.stdout.decode(), proc.stderr.decode()

    def test_exit_codes_and_output(self):
        self.assertEqual(self.run_script()[0], 64)
        self.assertEqual(self.run_script(BATCH, "1")[0], 64)
        self.save("alpha")
        code, out, err = self.run_script(BATCH, "1")
        self.assertEqual(code, 0, err)
        self.assertTrue(out.startswith("ACCEPTED"))
        self.assertEqual(F.git(self.repo.root, "status", "--porcelain").strip(), "", "no stray bytecode or files")
        self.save("beta", F.rewritten("beta").replace("yet.", "yet " + DASH + " x."))
        code, out, err = self.run_script(BATCH, "2")
        self.assertEqual(code, 1)
        self.repo.write("notes.txt", "x")
        code, out, err = self.run_script(BATCH, "3")
        self.assertEqual(code, 3)


class ChangeGuard(unittest.TestCase):
    def setUp(self):
        import briefs
        self.brief = briefs.parse_brief(F.brief_text("alpha"))

    def test_brief_parse(self):
        self.assertEqual(self.brief["lesson_id"], F.lesson_id("alpha"))
        self.assertEqual([x["id"] for x in self.brief["fix"]], [F.lesson_id("alpha") + "|L02|0"])
        self.assertEqual(self.brief["fix"][0]["quote"], "A variable is one of these letters.")
        self.assertEqual([x["id"] for x in self.brief["gaps"]], [F.lesson_id("alpha") + "#7"])
        self.assertEqual([x["id"] for x in self.brief["optional"]], [F.lesson_id("alpha") + "|L03|0"])
        self.assertEqual(self.brief["exams"], ["cse-professional", "upcat"])

    def test_covered_by_quote_and_by_words_and_uncovered(self):
        base = F.lesson_text("alpha")
        new = base.replace("A variable is one of these letters.", "A variable is one letter for a number.")
        changes = checks.change_guard(base, new, self.brief)
        self.assertEqual([c["by"] for c in changes], [F.lesson_id("alpha") + "|L02|0"])
        gap = base.replace("## Examples", "Coefficients combine when letters match, as in a civil service style "
                           "example.\n\n## Examples")
        changes = checks.change_guard(base, gap, self.brief)
        self.assertEqual([c["by"] for c in changes], [F.lesson_id("alpha") + "#7"])
        loose = base.replace("## Examples", "Pineapples grow on bushes near tropical shores.\n\n## Examples")
        changes = checks.change_guard(base, loose, self.brief)
        self.assertEqual(len(checks.uncovered(changes)), 1)
        self.assertEqual(changes[0]["kind"], "added")

    def test_removed_text_is_reported(self):
        base = F.lesson_text("alpha")
        new = base.replace("Students write $x + x = x^2$. That is a mistake.\n", "")
        changes = checks.change_guard(base, new, self.brief)
        self.assertEqual([c["kind"] for c in changes], ["removed"])
        self.assertEqual(len(checks.uncovered(changes)), 1)

    def test_no_change_no_report(self):
        base = F.lesson_text("alpha")
        self.assertEqual(checks.change_guard(base, base, self.brief), [])


if __name__ == "__main__":
    unittest.main()
