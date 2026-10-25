"""Tests for the workflow's decisions (who may hand in, the rejection count) and the workflow file itself.

Run as a script: python3 -I tools/content_rewrite/tests/test_relay_pr_guard.py
"""
import json
import os
import re
import subprocess
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import relay_fixtures as F  # noqa: E402,F401  (puts the relay folder on the path)

import pr_guard  # noqa: E402
import rw_lib  # noqa: E402

WORKFLOWS = Path(rw_lib.RELAY_DIR).parents[2] / ".github" / "workflows"
SHA = ["%040x" % n for n in range(1, 6)]
REPORT_REJECTED = ["## REJECTED", "", "Fix exactly these reasons.", "", "**lesson-x**", "1. the lesson is too short"]
REPORT_ACCEPTED = ["## ACCEPTED", "", "All 3 files passed the checks."]


def guard(**changes):
    args = dict(head_repo="Aedwon/Pantas", author="Aedwon", head_ref="cse-inbox/RW-001",
                base_ref="content/cse-rewrite-r1", labels=[])
    args.update(changes)
    return pr_guard.evaluate(**args)


class Guard(unittest.TestCase):
    def test_the_normal_hand_in_runs(self):
        self.assertEqual(guard(), (True, "RW-001", ""))
        self.assertEqual(guard(head_ref="cse-inbox/RD-012")[:2], (True, "RD-012"))

    def test_a_fork_is_ignored(self):
        run, batch, reason = guard(head_repo="someone/Pantas")
        self.assertEqual((run, batch), (False, ""))
        self.assertIn("Aedwon/Pantas", reason)

    def test_another_author_is_ignored(self):
        self.assertFalse(guard(author="mallory")[0])
        self.assertFalse(guard(author="")[0])

    def test_the_comparison_ignores_case_but_not_names(self):
        self.assertTrue(guard(author="aedwon", head_repo="aedwon/pantas")[0])
        self.assertFalse(guard(author="Aedwon2")[0])
        self.assertFalse(guard(head_repo="Aedwon/Pantas-fork")[0])

    def test_a_missing_head_repository_is_ignored(self):
        self.assertFalse(guard(head_repo=None)[0])

    def test_only_the_rewrite_branch_and_inbox_branch_names_count(self):
        self.assertFalse(guard(base_ref="main")[0])
        for ref in ("feature/x", "cse-inbox/", "cse-inbox/rw-001", "cse-inbox/RW-001/extra", "cse-inbox/RW-0011",
                    "xcse-inbox/RW-001", "cse-inbox/RW-001; echo hi"):
            self.assertFalse(guard(head_ref=ref)[0], ref)

    def test_a_held_pull_request_is_ignored(self):
        run, _, reason = guard(labels=["held"])
        self.assertFalse(run)
        self.assertIn("held", reason)
        self.assertTrue(guard(labels=["other"])[0])

    def test_the_reason_never_repeats_what_the_pull_request_says(self):
        _, _, reason = guard(head_ref="cse-inbox/$(rm -rf)", author="x\ny")
        self.assertNotIn("rm", reason)

    def test_the_ignored_comment_says_it_is_ignored(self):
        self.assertTrue(pr_guard.ignored_comment("only Aedwon may hand in").startswith("## IGNORED"))


class Decide(unittest.TestCase):
    def test_accepted(self):
        result = pr_guard.decide(0, SHA[0], [], REPORT_ACCEPTED)
        self.assertEqual(result["verdict"], "accepted")
        self.assertIn("## ACCEPTED", result["body"].splitlines()[1])
        self.assertEqual(result["rejected"], [])

    def test_first_and_second_rejection_ask_for_a_fix(self):
        first = pr_guard.decide(1, SHA[0], [], REPORT_REJECTED)
        self.assertEqual((first["verdict"], first["rejected"]), ("rejected", [SHA[0]]))
        self.assertIn("Rejection 1 of 3", first["body"])
        self.assertIn("1. the lesson is too short", first["body"])
        second = pr_guard.decide(1, SHA[1], first["rejected"], REPORT_REJECTED)
        self.assertEqual((second["verdict"], len(second["rejected"])), ("rejected", 2))
        self.assertIn("Rejection 2 of 3", second["body"])

    def test_the_third_rejection_holds(self):
        third = pr_guard.decide(1, SHA[2], SHA[:2], REPORT_REJECTED)
        self.assertEqual(third["verdict"], "held")
        self.assertEqual(third["body"].splitlines()[1], "## HELD")
        self.assertIn("1. the lesson is too short", third["body"], "the lead sees the last reasons")

    def test_the_same_commit_checked_twice_counts_once(self):
        again = pr_guard.decide(1, SHA[0], [SHA[0], SHA[1]], REPORT_REJECTED)
        self.assertEqual((again["verdict"], again["rejected"]), ("rejected", [SHA[0], SHA[1]]))

    def test_an_accepted_run_after_rejections_keeps_the_history(self):
        result = pr_guard.decide(0, SHA[2], SHA[:2], REPORT_ACCEPTED)
        self.assertEqual((result["verdict"], result["rejected"]), ("accepted", SHA[:2]))

    def test_an_error_holds_at_once(self):
        for code in (3, 64):
            result = pr_guard.decide(code, SHA[0], [], ["## ERROR", "", "The lead must look."])
            self.assertEqual(result["verdict"], "held")
            self.assertEqual(result["body"].splitlines()[1], "## ERROR")

    def test_the_marker_round_trips_through_a_comment(self):
        body = pr_guard.decide(1, SHA[0], [], REPORT_REJECTED)["body"]
        comments = [{"id": 7, "user": {"login": "someone"}, "body": body},
                    {"id": 8, "user": {"login": pr_guard.BOT_LOGIN}, "body": "no marker here"},
                    {"id": 9, "user": {"login": pr_guard.BOT_LOGIN}, "body": body}]
        self.assertEqual(pr_guard.find_bot_comment(comments), (9, [SHA[0]]), "only the bot's own comment counts")
        self.assertEqual(pr_guard.find_bot_comment([]), (None, []))

    def test_paginated_output_with_several_arrays_is_read(self):
        text = json.dumps([{"id": 1}]) + "\n" + json.dumps([{"id": 2}, {"id": 3}])
        self.assertEqual([c["id"] for c in pr_guard.parse_comments(text)], [1, 2, 3])
        self.assertEqual(pr_guard.parse_comments(""), [])


class CommandLine(unittest.TestCase):
    def run_cli(self, args, env):
        merged = dict(os.environ)
        merged.update(env)
        return subprocess.run([sys.executable, "-I", str(rw_lib.RELAY_DIR / "pr_guard.py")] + args, env=merged,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    def test_guard_writes_outputs_and_the_ignored_comment(self):
        with tempfile.TemporaryDirectory() as tmp:
            out, comment = Path(tmp) / "out", Path(tmp) / "ignored.md"
            env = {"GITHUB_OUTPUT": str(out), "HEAD_REPO": "Aedwon/Pantas", "AUTHOR": "Aedwon",
                   "HEAD_REF": "cse-inbox/RW-004", "BASE_REF": "content/cse-rewrite-r1", "LABELS": "[]"}
            proc = self.run_cli(["guard", "--ignored-file", str(comment)], env)
            self.assertEqual(proc.returncode, 0, proc.stderr)
            self.assertEqual(out.read_text().split(), ["run=true", "batch=RW-004"])
            self.assertFalse(comment.exists())
            env["AUTHOR"] = "mallory\nrun=true"
            out.unlink()
            proc = self.run_cli(["guard", "--ignored-file", str(comment)], env)
            self.assertEqual(out.read_text().split(), ["run=false", "batch="], "no outside text reaches the outputs")
            self.assertTrue(comment.read_text().startswith("## IGNORED"))

    def test_decide_reads_the_earlier_comment_and_writes_the_new_one(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp = Path(tmp)
            earlier = pr_guard.decide(1, SHA[0], [], REPORT_REJECTED)["body"]
            (tmp / "comments.json").write_text(json.dumps(
                [{"id": 41, "user": {"login": pr_guard.BOT_LOGIN}, "body": earlier}]))
            (tmp / "report.md").write_text("\n".join(REPORT_REJECTED) + "\n")
            out = tmp / "out"
            args = ["decide", "--exit-code", "1", "--head", SHA[1], "--comments", str(tmp / "comments.json"),
                    "--report", str(tmp / "report.md"), "--out", str(tmp / "comment.md")]
            proc = self.run_cli(args, {"GITHUB_OUTPUT": str(out)})
            self.assertEqual(proc.returncode, 0, proc.stderr)
            self.assertEqual(out.read_text().split(), ["verdict=rejected", "comment_id=41"])
            self.assertIn("Rejection 2 of 3", (tmp / "comment.md").read_text())


class WorkflowFile(unittest.TestCase):
    """The workflow cannot run here, so these check the things that must never change."""

    def setUp(self):
        self.text = (WORKFLOWS / "cse-handin.yml").read_text(encoding="utf-8")
        self.code = "\n".join(line for line in self.text.splitlines() if not line.lstrip().startswith("#"))

    def test_trigger_and_permissions(self):
        self.assertIn("pull_request:", self.code)
        self.assertNotIn("pull_request_target", self.code)
        self.assertIn("types: [opened, synchronize, reopened]", self.code)
        self.assertIn("branches: [content/cse-rewrite-r1]", self.code)
        self.assertIn("contents: write", self.code)
        self.assertIn("pull-requests: write", self.code)
        self.assertNotIn("secrets.", self.code)

    def test_the_check_is_named_cse_hand_in(self):
        self.assertRegex(self.code, r"(?m)^    name: CSE hand-in$")
        self.assertIn("startsWith(github.head_ref, 'cse-inbox/')", self.code)

    def test_actions_are_pinned_to_the_commits_the_other_workflow_uses(self):
        other = (WORKFLOWS / "cse-rewrite-checks.yml").read_text(encoding="utf-8")
        used = re.findall(r"uses: (actions/checkout@\S+ # \S+)", self.code)
        self.assertTrue(used)
        for use in used:
            self.assertIn(use, other)
        self.assertEqual(set(re.findall(r"uses: (\S+)@", self.code)), {"actions/checkout"})

    def test_nothing_from_the_pull_request_is_put_into_shell_text(self):
        runs = re.findall(r"(?ms)^ +run: (.*?)(?=^      - |\Z)", self.code)
        self.assertGreaterEqual(len(runs), 8)
        for run in runs:
            self.assertNotIn("${{ github.", run, "values reach scripts through env, not through shell text")

    def test_the_tools_come_from_the_base_commit_and_the_merge_uses_the_checked_commit(self):
        self.assertIn("ref: ${{ github.event.pull_request.base.sha }}", self.code)
        self.assertIn("trusted/tools/content_rewrite/relay/handin_ci.py", self.code)
        self.assertIn("--squash --delete-branch", self.code)
        self.assertIn('--match-head-commit "$HEAD_SHA"', self.code)
        self.assertIn("fetch-depth: 0", self.code)

    def test_the_push_checks_can_be_started_by_hand(self):
        other = (WORKFLOWS / "cse-rewrite-checks.yml").read_text(encoding="utf-8")
        self.assertIn("workflow_dispatch:", other)
        self.assertIn("gh workflow run cse-rewrite-checks.yml", self.code)


if __name__ == "__main__":
    unittest.main()
