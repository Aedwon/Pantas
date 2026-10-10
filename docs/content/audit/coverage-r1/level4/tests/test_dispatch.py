import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import dispatch  # noqa: E402
import l4lib  # noqa: E402


def comment(**event):
    return "worker-event\n```json\n%s\n```" % json.dumps(event)


class Register(unittest.TestCase):
    def setUp(self):
        self.state = tempfile.mkdtemp()
        self.envelope = dispatch.assignment("l4-x-L4-0417-a", "Level 4 read", "lesson reader", "ASSIGNMENT", "a" * 40)

    def test_assignment_pairs_can_run_together_and_never_get_replaced(self):
        self.assertIsNone(self.envelope["worktree"])
        self.assertIs(self.envelope["runner_required"], True)
        self.assertIs(self.envelope["replacement_allowed"], False)
        self.assertEqual((self.envelope["requested_model"], self.envelope["requested_effort"]), ("GPT-6 Sol", "High"))

    def test_register_returns_the_task_and_its_issue(self):
        calls = []

        def run(command, cwd=None):
            calls.append(command)
            return 0, "registered l4-x-L4-0417-a https://github.com/Aedwon/chatgpt-terminal-relay/issues/9500\n"

        result = dispatch.register(self.envelope, run=run, state_dir=self.state)
        self.assertEqual(result["issue_number"], 9500)
        saved = l4lib.load_json(Path(calls[0][-1]))
        self.assertEqual(saved["assignment_markdown"], "ASSIGNMENT")

    def test_failed_register_raises_with_the_dispatcher_message(self):
        with self.assertRaises(l4lib.L4Error) as caught:
            dispatch.register(self.envelope, run=lambda command, cwd=None: (1, "error: requested model is not mapped\n"),
                              state_dir=self.state)
        self.assertIn("requested model is not mapped", str(caught.exception))


class Classify(unittest.TestCase):
    def state(self, *events):
        return dispatch.classify(dispatch.parse_events([comment(**event) for event in events]))["state"]

    def test_no_event_yet_is_active(self):
        self.assertEqual(self.state(), "active")

    def test_progress_events_are_active(self):
        for event in ("launching", "dispatched", "working", "heartbeat", "continuation_sent"):
            self.assertEqual(self.state({"event": event}), "active", event)

    def test_completed(self):
        self.assertEqual(self.state({"event": "working"}, {"event": "completed"}), "completed")

    def test_usage_and_rate_limits(self):
        for kind in ("usage_limit", "rate_limit", "model_limit"):
            self.assertEqual(self.state({"event": "blocked", "blocker_code": "restriction_blocked", "blocker": kind}), "limit")

    def test_sign_in_and_security_check(self):
        for kind in ("auth_required", "captcha"):
            self.assertEqual(self.state({"event": "blocked", "blocker_code": "restriction_blocked", "blocker": kind}), "signin")

    def test_other_endings_are_failures_with_their_reason(self):
        result = dispatch.classify(dispatch.parse_events([comment(event="stalled", reason_code="browser_lost")]))
        self.assertEqual(result, {"state": "failed", "detail": "stalled: browser_lost"})
        self.assertEqual(self.state({"event": "blocked", "blocker_code": "HELD", "blocker": "form rejected twice"}), "failed")
        self.assertEqual(self.state({"event": "cancelled"}), "failed")

    def test_comments_that_are_not_events_are_ignored(self):
        events = dispatch.parse_events(["just a note", "worker-event\n```json\n{not json}\n```", comment(event="working")])
        self.assertEqual([event["event"] for event in events], ["working"])


class Github(unittest.TestCase):
    def test_task_state_reads_event_comments(self):
        lines = "\n".join(json.dumps(body) for body in (comment(event="working"), comment(event="completed")))
        self.assertEqual(dispatch.task_state(9500, run=lambda command, cwd=None: (0, lines))["state"], "completed")

    def test_runner_count(self):
        self.assertEqual(dispatch.runners_online(run=lambda command, cwd=None: (0, "2\n")), 2)

    def test_gh_failure_raises(self):
        with self.assertRaises(l4lib.L4Error):
            dispatch.runners_online(run=lambda command, cwd=None: (1, "HTTP 502"))


WS = "Pantas-wt-content-coverage-audit-r1"
INBOX = "docs/content/audit/coverage-r1/level4/inbox/"
REGISTERED = {"L4-0417|A|1", "L4-0417|B|1", "L4-0417|D|1"}


def request(**body):
    return {"number": 5, "title": "[relay] t hand-in", "body": json.dumps(dict({"relay_version": 2, "workspace": WS}, **body))}


class Listing(unittest.TestCase):
    def row(self, number, created, title="[relay] t hand-in", **extra):
        return json.dumps(dict({"number": number, "title": title, "body": "{}", "created_at": created,
                                "user": {"login": "Aedwon"}}, **extra))

    def test_it_reads_the_issues_list_not_search_and_keeps_relay_issues_opened_since(self):
        calls = []

        def run(command, cwd=None):
            calls.append(command)
            return 0, "\n".join([self.row(1, "2026-10-11T08:00:00Z"), self.row(2, "2026-10-11T09:00:30Z"),
                                  self.row(3, "2026-10-11T09:05:00Z", title="[worker] x"),
                                  self.row(4, "2026-10-11T09:06:00Z")]) + "\n"

        found = dispatch.list_relay_issues("2026-10-11T09:00:00+00:00", run=run)
        self.assertEqual([issue["number"] for issue in found], [2, 4])
        command = " ".join(calls[0])
        self.assertIn("repos/Aedwon/chatgpt-terminal-relay/issues?", command)
        self.assertIn("state=all", command)
        self.assertIn("creator=Aedwon", command)
        self.assertIn("since=2026-10-11T08:59:00Z", command)
        self.assertNotIn("search", command)

    def test_a_failing_gh_raises(self):
        with self.assertRaises(l4lib.L4Error):
            dispatch.list_relay_issues("2026-10-11T09:00:00+00:00", run=lambda command, cwd=None: (1, "HTTP 502"))


class Classify(unittest.TestCase):
    def kind(self, issue, registered=REGISTERED):
        return dispatch.classify_request(issue, WS, registered)

    def test_the_two_hand_in_requests_are_expected(self):
        self.assertEqual(self.kind(request(action="workspace_write_file", path=INBOX + "L4-0417-A-1.json", content="{}")), "expected")
        self.assertEqual(self.kind(request(action="workspace_exec", timeout_seconds=120,
                                           argv=["python3", dispatch.HANDIN_SCRIPT, "L4-0417", "D", "1"])), "expected")

    def test_a_hand_in_the_run_did_not_register_is_forbidden(self):
        for path in ("L4-0417-A-2.json", "L4-0520-A-1.json", "L4-0417-C-1.json", "../x-A-1.json", "L4-0417-A-1.json.bak"):
            self.assertEqual(self.kind(request(action="workspace_write_file", path=INBOX + path, content="{}")), "forbidden", path)
        self.assertEqual(self.kind(request(action="workspace_exec", argv=["python3", dispatch.HANDIN_SCRIPT, "L4-0417", "A", "2"])), "forbidden")

    def test_anything_else_for_the_audit_worktree_is_forbidden(self):
        for body in ({"action": "workspace_exec", "argv": ["cat", "state.json"]},
                     {"action": "workspace_exec", "argv": ["python3", dispatch.HANDIN_SCRIPT, "L4-0417", "A", "1", "x"]},
                     {"action": "workspace_exec", "argv": ["python3", dispatch.HANDIN_SCRIPT, "L4-0417", "A", "1"], "cwd": "/"},
                     {"action": "workspace_write_file", "path": INBOX + "L4-0417-A-1.json", "content": "{}", "append": True},
                     {"action": "workspace_write_file", "path": INBOX + "L4-0417-A-1.json", "content": 5},
                     {"action": "git_push_current"}, {"action": "workspace_read_file", "path": "x"}):
            self.assertEqual(self.kind(request(**body)), "forbidden", body)

    def test_a_request_for_another_workspace_or_no_relay_request_is_unrelated(self):
        other = request(action="workspace_exec", argv=["ls"])
        other["body"] = json.dumps({"relay_version": 2, "workspace": "Pantas", "action": "workspace_exec", "argv": ["ls"]})
        self.assertEqual(self.kind(other), "unrelated")
        for body in ("not json", "", None, "[1]", '{"no": "action"}', "Hand-in form removed."):
            self.assertEqual(self.kind({"body": body}), "unrelated", body)

    def test_the_audit_worktree_is_recognized_however_it_is_written(self):
        for target in (WS.upper(), "/Users/a/Documents/Projects/" + WS, WS + "/"):
            self.assertEqual(self.kind(request(action="workspace_exec", argv=["ls"], workspace=target)), "forbidden", target)
        # A request that does not say where it is aimed is treated as aimed here.
        self.assertEqual(self.kind({"body": json.dumps({"action": "workspace_exec", "argv": ["ls"]})}), "forbidden")


if __name__ == "__main__":
    unittest.main()
