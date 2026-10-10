import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import eraser  # noqa: E402

CONFIG = {"run_token": "l4abc123", "eraser_confirmed": True}
PATH = "docs/content/audit/coverage-r1/level4/inbox/L4-0417-A-1.json"
SINCE = "2026-10-11T09:00:00+00:00"


def issue(**changes):
    base = {
        "title": "[relay] l4abc123 hand-in", "number": 77, "created_at": "2026-10-11T09:05:00Z",
        "user": {"login": "Aedwon"},
        "body": json.dumps({"relay_version": 2, "action": "workspace_write_file",
                            "workspace": "Pantas-wt-content-coverage-audit-r1", "path": PATH, "content": "{}"}),
    }
    base.update(changes)
    return base


class FakeGh:
    """Answers the Issues list with `listing` and a single Issue read with `found`."""

    def __init__(self, found, listing=None):
        self.found = found
        self.listing = [found] if listing is None else listing
        self.edits, self.calls = [], []

    def __call__(self, command, cwd=None):
        self.calls.append(command)
        if command[:2] == ["gh", "api"] and "--paginate" in command:
            return 0, "\n".join(json.dumps(issue) for issue in self.listing)
        if command[:2] == ["gh", "api"]:
            return 0, json.dumps(self.found)
        if command[:3] == ["gh", "issue", "edit"]:
            self.edits.append(command)
            return 0, ""
        return 1, "unexpected"


class Erase(unittest.TestCase):
    def test_a_hand_in_of_this_run_is_erased(self):
        gh = FakeGh(issue())
        self.assertEqual(eraser.erase(77, CONFIG, run=gh), (True, "erased"))
        self.assertEqual(len(gh.edits), 1)
        body = gh.edits[0][gh.edits[0].index("--body") + 1]
        self.assertIn("l4abc123", body)
        self.assertNotIn("content", body)

    def test_nothing_is_edited_without_confirmation(self):
        for config in ({"run_token": "l4abc123", "eraser_confirmed": False}, {"run_token": "l4abc123"},
                       {"run_token": "l4abc123", "eraser_confirmed": "yes"}):
            gh = FakeGh(issue())
            self.assertEqual(eraser.erase(77, config, run=gh)[0], False)
            self.assertEqual(gh.edits, [])
            self.assertEqual(eraser.erase_handin("L4-0417", "A", 1, config, SINCE, run=gh), [])

    def test_issues_that_are_not_this_runs_hand_ins_are_refused(self):
        other_request = json.dumps({"relay_version": 2, "action": "workspace_exec", "argv": ["git", "status"]})
        outside = json.dumps({"relay_version": 2, "action": "workspace_write_file", "path": "lib/main.dart", "content": "x"})
        for bad in (issue(title="[relay] workspace_exec BetterGov"),
                    issue(title="[relay] l4zzzzzz hand-in"),
                    issue(title="[relay] l4abc123 hand-in extra"),
                    issue(title="[relay] l4abc123 save L4-0417-A"),
                    issue(user={"login": "someone-else"}),
                    issue(body=other_request), issue(body=outside), issue(body="not json"), issue(body=None)):
            gh = FakeGh(bad)
            erased, reason = eraser.erase(77, CONFIG, run=gh)
            self.assertFalse(erased, bad)
            self.assertEqual(gh.edits, [], reason)

    def test_unreadable_issue_is_not_edited(self):
        self.assertEqual(eraser.erase(77, CONFIG, run=lambda command, cwd=None: (1, "HTTP 404"))[0], False)

    def test_erase_handin_finds_the_save_issue_by_the_path_in_its_body_not_by_title(self):
        other_role = issue(number=78, body=json.dumps({"action": "workspace_write_file", "workspace": "w",
                                                       "path": PATH.replace("-A-", "-B-"), "content": "{}"}))
        other_attempt = issue(number=79, body=json.dumps({"action": "workspace_write_file", "workspace": "w",
                                                          "path": PATH.replace("-1.json", "-2.json"), "content": "{}"}))
        check = issue(number=80, body=json.dumps({"action": "workspace_exec", "argv": ["python3", "x", "L4-0417", "A", "1"]}))
        gh = FakeGh(issue(), listing=[other_role, other_attempt, check, issue(), {"number": 81, "body": "not json"}])
        self.assertEqual(eraser.erase_handin("L4-0417", "A", 1, CONFIG, SINCE, run=gh), [(77, True, "erased")])
        self.assertEqual(len(gh.edits), 1)
        self.assertEqual(gh.edits[0][3], "77")
        listing = [call for call in gh.calls if "--paginate" in call][0]
        self.assertIn("issues?", " ".join(listing))
        self.assertNotIn("search", " ".join(listing))

    def test_erase_handin_still_refuses_an_issue_whose_title_is_not_this_runs_hand_in(self):
        gh = FakeGh(issue(title="[relay] someone else"))
        self.assertEqual(eraser.erase_handin("L4-0417", "A", 1, CONFIG, SINCE, run=gh),
                         [(77, False, "title is not a hand-in of this run")])
        self.assertEqual(gh.edits, [])

    def test_a_failing_listing_is_reported_not_raised(self):
        result = eraser.erase_handin("L4-0417", "A", 1, CONFIG, SINCE, run=lambda command, cwd=None: (1, "HTTP 502"))
        self.assertEqual(len(result), 1)
        self.assertFalse(result[0][1])


if __name__ == "__main__":
    unittest.main()
