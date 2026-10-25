"""Tests for the batch planner and the item type registry.

Run as a script: python3 -I tools/content_rewrite/tests/test_relay_planner.py
"""
import sys
import unittest

sys.dont_write_bytecode = True
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import relay_fixtures as F  # noqa: E402

import grouping  # noqa: E402
import item_types  # noqa: E402
import planner  # noqa: E402
import rw_lib  # noqa: E402


class SplitSizes(unittest.TestCase):
    def test_sizes(self):
        self.assertEqual(grouping.split_sizes(3, 4), [3])
        self.assertEqual(grouping.split_sizes(4, 4), [4])
        self.assertEqual(grouping.split_sizes(6, 4), [3, 3])
        self.assertEqual(grouping.split_sizes(7, 4), [4, 3])
        self.assertEqual(grouping.split_sizes(10, 4), [4, 3, 3])
        self.assertEqual(grouping.split_sizes(13, 4), [4, 3, 3, 3])
        self.assertEqual(grouping.split_sizes(4, 3), [2, 2])
        self.assertEqual(grouping.split_sizes(7, 3), [3, 2, 2])
        self.assertEqual(grouping.split_sizes(0, 4), [])

    def test_every_size_from_3_is_in_range_except_5(self):
        for count in range(3, 60):
            sizes = grouping.split_sizes(count, 4)
            self.assertEqual(sum(sizes), count)
            if count != 5:
                self.assertTrue(all(3 <= s <= 4 for s in sizes), (count, sizes))
        self.assertEqual(grouping.split_sizes(5, 4), [3, 2])


class Registry(unittest.TestCase):
    def test_both_types_registered(self):
        self.assertEqual(item_types.get("rewrite").prefix, "RW")
        self.assertEqual(item_types.get("read").prefix, "RD")
        self.assertIs(item_types.by_prefix("RD"), item_types.get("read"))

    def test_unknown_and_duplicate(self):
        with self.assertRaises(rw_lib.RewriteError):
            item_types.get("solve")
        with self.assertRaises(rw_lib.RewriteError):
            item_types.register(item_types.get("rewrite"))

    def test_a_new_type_is_one_class(self):
        class Solve(item_types.ItemType):
            name, prefix, file_ext, commit_verb = "solve", "SV", ".json", "solve"

            def plan(self, ctx):
                return [{"lessons": ["q1", "q2"], "topic": "t"}]

        item_types.register(Solve())
        try:
            repo = F.Repo(slugs=["alpha"])
            self.addCleanup(repo.cleanup)
            added = planner.plan(repo.ctx, kinds=["solve"])
            self.assertEqual(added, ["SV-001"])
            self.assertEqual(repo.ctx.batch("SV-001")["type"], "solve")
        finally:
            del item_types.REGISTRY["solve"]


class RewritePlan(unittest.TestCase):
    def setUp(self):
        self.repo = F.Repo()
        self.addCleanup(self.repo.cleanup)
        self.ctx = self.repo.ctx

    def test_groups_one_topic_in_batches_of_3_or_4(self):
        planner.plan(self.ctx)
        data = self.ctx.load_batches()
        self.assertEqual(data["order"], ["RW-001", "RW-002"])
        sizes = [len(data["batches"][i]["lessons"]) for i in data["order"]]
        self.assertEqual(sizes, [3, 2])  # 5 lessons cannot be 3 or 4 each; the only allowed exception
        for batch in data["batches"].values():
            self.assertEqual(batch["topic"], "mathematics/algebra")
            self.assertEqual(batch["type"], "rewrite")
            for lesson_id, path in batch["paths"].items():
                self.assertTrue(path.startswith("content/lessons/mathematics/algebra/"))

    def test_new_lessons_file_is_not_a_lesson(self):
        planner.plan(self.ctx)
        ids = [i for b in self.ctx.load_batches()["batches"].values() for i in b["lessons"]]
        self.assertEqual(len(ids), 5)
        self.assertFalse(any("new-lessons" in i for i in ids))

    def test_plan_is_stable_and_only_adds(self):
        planner.plan(self.ctx)
        first = self.ctx.load_batches()
        self.assertEqual(planner.plan(self.ctx), [])
        self.assertEqual(self.ctx.load_batches(), first)

    def test_selection_limits_and_orders(self):
        self.ctx.state.mkdir(parents=True, exist_ok=True)
        (self.ctx.state / "selection.txt").write_text(
            "# pilot\n%s\n%s # second\n%s\n" % (F.lesson_id("gamma"), F.lesson_id("alpha"), F.lesson_id("beta")))
        planner.plan(self.ctx)
        batch = self.ctx.batch("RW-001")
        self.assertEqual(batch["lessons"], [F.lesson_id("gamma"), F.lesson_id("alpha"), F.lesson_id("beta")])
        self.assertIsNone(self.ctx.batch("RW-002"))

    def test_selection_with_unknown_lesson_is_an_error(self):
        self.ctx.state.mkdir(parents=True, exist_ok=True)
        (self.ctx.state / "selection.txt").write_text("lesson-nope\n")
        with self.assertRaises(rw_lib.RewriteError):
            planner.plan(self.ctx)

    def test_state_is_outside_the_repo(self):
        planner.plan(self.ctx)
        self.assertFalse(str(self.ctx.state).startswith(str(self.ctx.root)))
        self.assertTrue((self.ctx.state / "batches.json").exists())
        # Only the batch files are new in the repository: they are committed by the lead.
        self.assertEqual(F.git(self.ctx.root, "status", "--porcelain", "--untracked-files=all").split(),
                         ["??", "%s/RW-001.json" % rw_lib.BATCHES_REL] + ["??", "%s/RW-002.json" % rw_lib.BATCHES_REL])

    def test_state_folder_override_by_environment(self):
        import os
        old = os.environ.get("PANTAS_REWRITE_STATE")
        os.environ["PANTAS_REWRITE_STATE"] = "/tmp/somewhere-else"
        try:
            self.assertEqual(str(rw_lib.default_state()), "/tmp/somewhere-else")
        finally:
            if old is None:
                del os.environ["PANTAS_REWRITE_STATE"]
            else:
                os.environ["PANTAS_REWRITE_STATE"] = old

    def test_requeue_makes_a_second_round_batch(self):
        planner.plan(self.ctx)
        new = planner.requeue(self.ctx, [F.lesson_id("alpha"), F.lesson_id("beta")])
        self.assertEqual(new, "RW-003")
        self.assertEqual(self.ctx.batch(new)["round"], 2)
        with self.assertRaises(rw_lib.RewriteError):
            planner.requeue(self.ctx, ["lesson-nope"])


class ReadPlan(unittest.TestCase):
    def setUp(self):
        self.repo = F.Repo()
        self.addCleanup(self.repo.cleanup)
        self.ctx = self.repo.ctx
        planner.plan(self.ctx)

    def test_nothing_before_any_rewrite_is_accepted(self):
        self.assertEqual(planner.plan(self.ctx, kinds=["read"]), [])

    def test_waits_for_three_until_the_topic_is_complete(self):
        code, _ = F.accept_rewrite(self.repo, "RW-001")
        self.assertEqual(code, 0)
        added = planner.plan(self.ctx, kinds=["read"])
        self.assertEqual(added, ["RD-001"])
        self.assertEqual(len(self.ctx.batch("RD-001")["lessons"]), 3)
        self.assertEqual(planner.plan(self.ctx, kinds=["read"]), [])  # no duplicate

    def test_complete_topic_splits_the_rest_evenly(self):
        F.accept_rewrite(self.repo, "RW-001")
        planner.plan(self.ctx, kinds=["read"])
        F.accept_rewrite(self.repo, "RW-002")
        added = planner.plan(self.ctx, kinds=["read"])
        self.assertEqual(added, ["RD-002"])
        self.assertEqual(len(self.ctx.batch("RD-002")["lessons"]), 2)
        batch = self.ctx.batch("RD-002")
        self.assertEqual(set(batch["rewrites"]), set(batch["lessons"]))


if __name__ == "__main__":
    unittest.main()
