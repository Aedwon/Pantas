"""Tests for the done-state logic, with git and gh mocked.

Run as a script: python3 -I tools/content_rewrite/tests/test_relay_status.py
"""
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import relay_fixtures  # noqa: E402,F401  (puts the relay folder on the path)

import rw_lib  # noqa: E402
import status  # noqa: E402

SHA_A = "a" * 40
SHA_B = "b" * 40
SHA_C = "c" * 40   # a later commit that contains A and B
SHA_X = "d" * 40   # a commit that is not a descendant of anything here


class FakeGit:
    """Answers the three git questions the status code asks."""

    def __init__(self, on_remote=(), descends=None, fetch_ok=True):
        self.on_remote = set(on_remote)
        self.descends = descends or {}   # {(ancestor, descendant)}
        self.fetch_ok = fetch_ok
        self.calls = []
        self.log = ""

    def text(self, *args, check=True):
        self.calls.append(args)
        if args[0] == "log":
            return self.log
        assert args[:3] == ("branch", "-r", "--contains"), args
        return ("  origin/other\n  %s\n" % rw_lib.REMOTE_BRANCH) if args[3] in self.on_remote else "  origin/other\n"

    def ok(self, *args):
        assert args[:2] == ("merge-base", "--is-ancestor"), args
        return (args[2], args[3]) in self.descends

    def run(self, *args, check=True):
        if args[0] == "fetch" and not self.fetch_ok:
            raise rw_lib.RewriteError("git fetch failed")
        return b""


class FakeGh:
    def __init__(self, runs=None, error=None):
        self._runs, self._error = runs, error

    def runs(self):
        if self._error:
            raise status.GhError(self._error)
        return self._runs


def run(sha, conclusion):
    return {"headSha": sha, "conclusion": conclusion}


class Base(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.git = FakeGit()
        self.ctx = rw_lib.Ctx(root=tmp.name, state_dir=Path(tmp.name) / "state", git=self.git)
        self.ctx.save_batches({"order": ["RW-001", "RW-002", "RD-001"], "batches": {
            "RW-001": {"id": "RW-001", "type": "rewrite", "topic": "t", "lessons": ["l1", "l2"], "paths": {}},
            "RW-002": {"id": "RW-002", "type": "rewrite", "topic": "t", "lessons": ["l3"], "paths": {}},
            "RD-001": {"id": "RD-001", "type": "read", "topic": "t", "lessons": ["l1"], "rewrites": {}, "paths": {}},
        }})

    def accept(self, kind, lesson, batch, commit):
        rw_lib.json_save(self.ctx.accepted_path(kind, lesson), {"batch": batch, "commit": commit, "sha256": "s"})

    def overview(self, gh=None, fetched=True):
        return status.overview(self.ctx, gh or FakeGh([]), fetched)

    def state(self, view, batch_id):
        return next(b for b in view["batches"] if b["id"] == batch_id)


class States(Base):
    def test_newer_accepted_batch_replaces_all_lessons(self):
        data = self.ctx.load_batches()
        data["order"].append("RW-007")
        data["batches"]["RW-007"] = dict(data["batches"]["RW-001"], id="RW-007")
        self.ctx.save_batches(data)
        self.ctx.event(batch="RW-001", result="accepted")
        self.accept("rewrite", "l1", "RW-007", SHA_B)
        self.assertEqual(self.state(self.overview(), "RW-001")["state"], "in_progress")
        self.accept("rewrite", "l2", "RW-007", SHA_B)
        item = self.state(self.overview(), "RW-001")
        self.assertEqual((item["state"], item["label"]), ("replaced", "Replaced by RW-007"))
        page = (Path(status.__file__).parent / "page.html").read_text()
        self.assertIn('!batch.done && batch.state !== "replaced"', page)

    def test_remote_subject_survives_rebase_for_rewrite_and_read(self):
        for kind, batch_id, lesson in (("rewrite", "RW-002", "l3"), ("read", "RD-001", "l1")):
            self.accept(kind, lesson, batch_id, SHA_A)
            self.git.log = SHA_B + "\t" + kind + ": " + batch_id + " accepted\n"
            for conclusion, expected in (("success", "done"), ("skipped", "done"),
                                         ("failure", "check_failed"), (None, "pushed")):
                item = self.state(self.overview(FakeGh([run(SHA_B, conclusion)])), batch_id)
                self.assertEqual(item["state"], expected)
                self.assertEqual(item["commits"], [SHA_B[:8]])
            item = self.state(self.overview(FakeGh(error="offline")), batch_id)
            self.assertTrue(item["done"])
            self.git.log = SHA_B + "\t" + kind + ": " + batch_id + "0 accepted\n"
            self.assertEqual(self.state(self.overview(), batch_id)["state"], "handed_in")

    def test_not_started_then_copied_then_in_progress(self):
        view = self.overview()
        self.assertEqual(self.state(view, "RW-001")["state"], "not_started")
        self.assertEqual(self.state(view, "RW-001")["label"], "Not started")
        self.ctx.mark_copied("RW-001")
        self.assertEqual(self.state(self.overview(), "RW-001")["state"], "copied")
        self.ctx.event(batch="RW-001", attempt="1", result="rejected")
        self.assertEqual(self.state(self.overview(), "RW-001")["state"], "in_progress")

    def test_partly_accepted_is_in_progress(self):
        self.accept("rewrite", "l1", "RW-001", SHA_A)
        item = self.state(self.overview(), "RW-001")
        self.assertEqual(item["state"], "in_progress")
        self.assertIn("1 of 2", item["label"])

    def test_handed_in_but_not_pushed(self):
        self.accept("rewrite", "l1", "RW-001", SHA_A)
        self.accept("rewrite", "l2", "RW-001", SHA_A)
        item = self.state(self.overview(), "RW-001")
        self.assertEqual((item["state"], item["done"]), ("handed_in", False))
        self.assertEqual(item["label"], "Handed in at " + SHA_A[:8])

    def test_one_commit_not_pushed_keeps_the_batch_at_handed_in(self):
        self.accept("rewrite", "l1", "RW-001", SHA_A)
        self.accept("rewrite", "l2", "RW-001", SHA_B)
        self.git.on_remote = {SHA_A}
        self.assertEqual(self.state(self.overview(), "RW-001")["state"], "handed_in")

    def test_pushed_with_no_run_yet(self):
        self.accept("rewrite", "l3", "RW-002", SHA_A)
        self.git.on_remote = {SHA_A}
        item = self.state(self.overview(FakeGh([])), "RW-002")
        self.assertEqual(item["state"], "pushed")
        self.assertIn("waiting", item["label"])

    def test_pushed_check_running_passed_failed(self):
        self.accept("rewrite", "l3", "RW-002", SHA_A)
        self.git.on_remote = {SHA_A}
        cases = (("", "pushed", False), (None, "pushed", False), ("success", "done", True),
                 ("failure", "check_failed", False), ("cancelled", "check_failed", False),
                 ("skipped", "check_unknown", False))
        for conclusion, expected, done in cases:
            item = self.state(self.overview(FakeGh([run(SHA_A, conclusion)])), "RW-002")
            self.assertEqual((item["state"], item["done"]), (expected, done), conclusion)

    def test_a_later_push_that_contains_the_commit_counts(self):
        self.accept("rewrite", "l3", "RW-002", SHA_A)
        self.git.on_remote = {SHA_A}
        self.git.descends = {(SHA_A, SHA_C)}
        item = self.state(self.overview(FakeGh([run(SHA_C, "success")])), "RW-002")
        self.assertEqual(item["state"], "done")
        item = self.state(self.overview(FakeGh([run(SHA_X, "success")])), "RW-002")
        self.assertEqual(item["state"], "pushed", "a run that does not contain the commit says nothing about it")

    def test_the_first_run_that_carried_the_commit_decides(self):
        self.accept("rewrite", "l3", "RW-002", SHA_A)
        self.git.on_remote = {SHA_A}
        self.git.descends = {(SHA_A, SHA_C)}
        runs = [run(SHA_C, "failure"), run(SHA_A, "success")]  # newest first
        self.assertEqual(self.state(self.overview(FakeGh(runs)), "RW-002")["state"], "done")

    def test_a_batch_with_two_commits_shows_its_worst_check(self):
        self.accept("rewrite", "l1", "RW-001", SHA_A)
        self.accept("rewrite", "l2", "RW-001", SHA_B)
        self.git.on_remote = {SHA_A, SHA_B}
        runs = [run(SHA_B, "failure"), run(SHA_A, "success")]
        self.assertEqual(self.state(self.overview(FakeGh(runs)), "RW-001")["state"], "check_failed")

    def test_gh_unavailable_shows_check_unknown(self):
        self.accept("rewrite", "l3", "RW-002", SHA_A)
        self.git.on_remote = {SHA_A}
        view = self.overview(FakeGh(error="gh is not available (FileNotFoundError)"))
        item = self.state(view, "RW-002")
        self.assertEqual(item["state"], "check_unknown")
        self.assertIn("check unknown", item["label"].lower())
        self.assertFalse(item["done"])
        self.assertTrue(any("Check unknown" in n for n in view["notes"]))

    def test_failed_fetch_is_noted(self):
        view = self.overview(fetched=False)
        self.assertTrue(any("fetch failed" in n for n in view["notes"]))

    def test_held_lessons_show_held(self):
        for _ in range(2):
            self.ctx.add_rejection("RW-001", "l1", True)
        item = self.state(self.overview(), "RW-001")
        self.assertEqual(item["state"], "held")
        self.assertIn("1 of 2", item["label"])

    def test_a_record_from_another_batch_does_not_count(self):
        self.accept("rewrite", "l3", "RW-099", SHA_A)
        self.assertEqual(self.state(self.overview(), "RW-002")["state"], "not_started")


class NextBatch(Base):
    def test_next_is_the_first_not_started_and_counts(self):
        view = self.overview()
        self.assertEqual(view["next"], "RD-001", "reads are offered before rewrites")
        self.assertEqual(view["counts"], {"total": 3, "done": 0})

    def test_next_moves_on_once_the_prompt_is_copied(self):
        self.ctx.mark_copied("RD-001")
        self.assertEqual(self.overview()["next"], "RW-001")
        self.ctx.mark_copied("RW-001")
        self.assertEqual(self.overview()["next"], "RW-002")
        self.ctx.mark_copied("RW-002")
        self.assertIsNone(self.overview()["next"])

    def test_a_failed_check_blocks_new_batches(self):
        self.accept("rewrite", "l3", "RW-002", SHA_A)
        self.git.on_remote = {SHA_A}
        view = self.overview(FakeGh([run(SHA_A, "failure")]))
        self.assertIsNone(view["next"])
        self.assertIn("RW-002", view["blocked"])

    def test_done_batches_are_counted(self):
        self.accept("rewrite", "l3", "RW-002", SHA_A)
        self.git.on_remote = {SHA_A}
        view = self.overview(FakeGh([run(SHA_A, "success")]))
        self.assertEqual(view["counts"], {"total": 3, "done": 1})
        self.assertIsNone(view["blocked"])

    def test_a_stopped_run_blocks(self):
        self.ctx.stop("unexpected change", "RW-001")
        view = self.overview()
        self.assertIsNone(view["next"])
        self.assertIn("stopped", view["blocked"])


class RemoteHelpers(unittest.TestCase):
    def test_on_remote_matches_the_exact_branch_only(self):
        class G:
            def text(self, *a, check=True):
                return "  origin/content/cse-rewrite-r1-old\n  origin/other\n"
        self.assertFalse(status.on_remote(G(), SHA_A))

    def test_check_outcome_without_runs_is_unknown(self):
        self.assertEqual(status.check_outcome(FakeGit(), None, SHA_A), "unknown")


if __name__ == "__main__":
    unittest.main()
