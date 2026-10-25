"""Tests for the page's done-state on the pull-request path, with git and gh mocked, and for the merge sync.

Run as a script: python3 -I tools/content_rewrite/tests/test_relay_pr_status.py
"""
import json
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import relay_fixtures as F  # noqa: E402

import planner  # noqa: E402
import pr_sync  # noqa: E402
import rw_lib  # noqa: E402
import server  # noqa: E402
import status  # noqa: E402

MERGE_A, MERGE_B = "a" * 40, "b" * 40


class FakeGit:
    """Answers the git questions the status code asks: which commits descend from which."""

    def __init__(self, descends=()):
        self.descends = set(descends)

    def text(self, *args, check=True):
        return "  origin/other\n"

    def ok(self, *args):
        assert args[:2] == ("merge-base", "--is-ancestor"), args
        return (args[2], args[3]) in self.descends

    def run(self, *args, check=True):
        return b""


class FakeGh:
    def __init__(self, runs=None, prs=None, runs_error=None, prs_error=None):
        self._runs, self._prs, self._runs_error, self._prs_error = runs or [], prs or [], runs_error, prs_error

    def runs(self):
        if self._runs_error:
            raise status.GhError(self._runs_error)
        return self._runs

    def prs(self):
        if self._prs_error:
            raise status.GhError(self._prs_error)
        return self._prs


def pr(batch_id, state="MERGED", number=1, commit=MERGE_A, labels=()):
    return {"number": number, "state": state, "headRefName": "cse-inbox/" + batch_id,
            "mergeCommit": {"oid": commit} if state == "MERGED" else None, "labels": [{"name": n} for n in labels]}


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

    def view(self, gh, batch_id):
        data = status.overview(self.ctx, gh)
        return next(b for b in data["batches"] if b["id"] == batch_id), data


class DoneState(Base):
    def test_merged_handin_title_identifies_batch_after_branch_change(self):
        merged = pr("RW-001")
        merged.update(headRefName="rebased-handin", title="[handin] RW-001")
        batch, _ = self.view(FakeGh([run(MERGE_A, "success")], [merged]), "RW-001")
        self.assertTrue(batch["done"])
        merged["title"] = "[handin] RW-0010"
        self.assertEqual(self.view(FakeGh(prs=[merged]), "RW-001")[0]["state"], "not_started")

    def test_a_merged_pull_request_with_a_passed_check_is_done(self):
        batch, data = self.view(FakeGh([run(MERGE_A, "success")], [pr("RW-001")]), "RW-001")
        self.assertEqual((batch["state"], batch["done"], batch["commits"]), ("done", True, [MERGE_A[:8]]))
        self.assertEqual(data["counts"]["done"], 1)

    def test_the_check_decides_after_the_merge(self):
        for runs, state, done in (([run(MERGE_A, None)], "pushed", False), ([run(MERGE_A, "failure")], "check_failed", False),
                                  ([], "pushed", False)):
            batch, _ = self.view(FakeGh(runs, [pr("RW-001")]), "RW-001")
            self.assertEqual((batch["state"], batch["done"]), (state, done), runs)
        batch, _ = self.view(FakeGh([], [pr("RW-001")]), "RW-001")
        self.assertIn("waiting for the check", batch["label"])

    def test_a_later_run_that_contains_the_merge_counts(self):
        self.git.descends = {(MERGE_A, MERGE_B)}
        batch, _ = self.view(FakeGh([run(MERGE_B, "success")], [pr("RW-001")]), "RW-001")
        self.assertEqual(batch["state"], "done")

    def test_a_failed_check_blocks_the_next_batch(self):
        _, data = self.view(FakeGh([run(MERGE_A, "failure")], [pr("RW-001")]), "RW-001")
        self.assertIsNone(data["next"])
        self.assertIn("RW-001", data["blocked"])

    def test_an_open_pull_request_is_in_progress_and_not_offered_again(self):
        batch, data = self.view(FakeGh([], [pr("RW-001", "OPEN", 5)]), "RW-001")
        self.assertEqual((batch["state"], batch["pr"], batch["done"]), ("pr_open", 5, False))
        self.assertIn("#5", batch["label"])
        self.assertNotEqual(data["next"], "RW-001")

    def test_a_held_pull_request_shows_as_held(self):
        batch, data = self.view(FakeGh([], [pr("RW-001", "OPEN", 5, labels=["held"])]), "RW-001")
        self.assertEqual((batch["state"], batch["pr"]), ("held", 5))
        self.assertEqual(data["held"], [{"id": "RW-001", "pr": 5}])
        self.assertNotEqual(data["next"], "RW-001")

    def test_a_closed_unmerged_pull_request_does_not_count(self):
        batch, _ = self.view(FakeGh([], [pr("RW-001", "CLOSED", 5)]), "RW-001")
        self.assertEqual(batch["state"], "not_started")

    def test_a_merged_pull_request_wins_over_an_older_held_one(self):
        prs = [pr("RW-001", "OPEN", 5, labels=["held"]), pr("RW-001", "MERGED", 6)]
        self.assertEqual(self.view(FakeGh([run(MERGE_A, "success")], prs), "RW-001")[0]["state"], "done")

    def test_other_batches_pull_requests_are_not_mixed_up(self):
        batch, _ = self.view(FakeGh([run(MERGE_A, "success")], [pr("RW-002")]), "RW-001")
        self.assertEqual(batch["state"], "not_started")
        self.assertEqual(self.view(FakeGh([run(MERGE_A, "success")], [pr("RW-002")]), "RW-002")[0]["state"], "done")

    def test_without_gh_the_page_says_check_unknown_and_does_not_fail(self):
        gh = FakeGh(runs_error="gh is not available", prs_error="gh is not available")
        batch, data = self.view(gh, "RW-001")
        self.assertEqual(batch["state"], "not_started")
        self.assertTrue(any("Check unknown" in note for note in data["notes"]), data["notes"])
        self.assertTrue(any("Pull request state unknown" in note for note in data["notes"]), data["notes"])
        self.assertEqual(data["counts"]["done"], 0)

    def test_merged_but_runs_unavailable_shows_check_unknown(self):
        batch, data = self.view(FakeGh(prs=[pr("RW-001")], runs_error="gh could not list runs"), "RW-001")
        self.assertEqual((batch["state"], batch["done"]), ("done", True))
        self.assertIn("check unknown", batch["label"])
        self.assertTrue(any("Check unknown" in note for note in data["notes"]))


class MergedRepo(unittest.TestCase):
    """A repository where the pull request for RW-001 has been squash-merged."""

    def setUp(self):
        self.repo = F.Repo()
        self.addCleanup(self.repo.cleanup)
        self.ctx = self.repo.ctx
        planner.plan(self.ctx)
        self.repo.commit_batches()
        self.batch = self.ctx.batch("RW-001")
        for lid in self.batch["lessons"]:
            slug = lid.replace("lesson-algebra-", "")
            self.repo.write(F.lesson_path(slug), F.rewritten(slug))
        F.git(self.repo.root, "add", "-A")
        F.git(self.repo.root, "commit", "-q", "-m", "[handin] RW-001 (#1)")   # what the squash merge makes
        self.merge = self.repo.head()
        self.prs = [pr("RW-001", commit=self.merge)]


class Sync(MergedRepo):
    """A merged rewrite pull request becomes an accepted record, so the read batch for it is planned."""

    def test_sync_records_the_merge_and_plans_the_read(self):
        self.assertEqual(pr_sync.sync(self.ctx, self.prs), ["RW-001"])
        for lid in self.batch["lessons"]:
            record = self.ctx.accepted("rewrite", lid)
            self.assertEqual((record["batch"], record["commit"]), ("RW-001", self.merge))
            self.assertEqual(len(record["sha256"]), 64)
        added = planner.plan(self.ctx, kinds=["read"])
        self.assertEqual(added, ["RD-001"])
        self.assertEqual(self.ctx.batch("RD-001")["rewrites"][self.batch["lessons"][0]], self.merge)

    def test_sync_runs_once_per_merge(self):
        pr_sync.sync(self.ctx, self.prs)
        self.assertEqual(pr_sync.sync(self.ctx, self.prs), [])

    def test_an_open_or_unpulled_pull_request_is_skipped(self):
        self.assertEqual(pr_sync.sync(self.ctx, [pr("RW-001", "OPEN")]), [])
        self.assertEqual(pr_sync.sync(self.ctx, [pr("RW-001", commit="c" * 40)]), [], "commit not fetched yet")
        self.assertEqual(pr_sync.sync(self.ctx, [pr("RW-099", commit=self.merge)]), [], "no such batch file")
        self.assertEqual(pr_sync.sync(self.ctx, self.prs), ["RW-001"], "and it still works afterwards")

    def test_a_merged_read_needs_no_record(self):
        self.assertEqual(pr_sync.sync(self.ctx, self.prs), ["RW-001"])
        planner.plan(self.ctx, kinds=["read"])
        self.repo.commit_batches()
        read_merge = self.repo.head()
        self.assertEqual(pr_sync.sync(self.ctx, [pr("RD-001", number=2, commit=read_merge)]), ["RD-001"])


class PageApp(MergedRepo):
    def test_the_page_refresh_syncs_merges_and_offers_the_read(self):
        gh = FakeGh([run(self.merge, "success")], self.prs)
        clock = type("Clock", (), {"now": 0.0, "__call__": lambda self: self.now})()
        app = server.App(self.ctx, gh, clock=clock)
        view = app.view(force=True)
        by_id = {b["id"]: b for b in view["batches"]}
        self.assertEqual(by_id["RW-001"]["state"], "done")
        self.assertEqual(view["next"], "RD-001")

    def test_the_page_prompt_uses_the_pull_request_path_and_the_old_one_stays_available(self):
        repo = F.Repo()
        self.addCleanup(repo.cleanup)
        planner.plan(repo.ctx)
        app = server.App(repo.ctx, FakeGh())
        self.assertIn("`cse-inbox/RW-001`", app.prompt("RW-001"))
        self.assertNotIn("workspace_exec", app.prompt("RW-001"))
        self.assertIn("workspace_exec", app.prompt("RW-001", "relay"))
        with self.assertRaises(rw_lib.RewriteError):
            app.prompt("RW-001", "other")


if __name__ == "__main__":
    unittest.main()
