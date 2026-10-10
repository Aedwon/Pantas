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

    def test_only_the_exact_hand_in_title_matches(self):
        found = json.dumps([{"number": 1, "title": "[relay] l4abc save L4-0417-A"},
                            {"number": 2, "title": "[relay] l4abc save L4-0417-AB"},
                            {"number": 3, "title": "[relay] other save L4-0417-A"}])
        self.assertEqual(dispatch.find_handin_issues("l4abc", "L4-0417", "A", run=lambda command, cwd=None: (0, found)), [1])


if __name__ == "__main__":
    unittest.main()
