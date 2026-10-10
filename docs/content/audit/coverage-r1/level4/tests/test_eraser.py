import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import eraser  # noqa: E402

CONFIG = {"run_token": "l4abc123", "eraser_confirmed": True}
PATH = "docs/content/audit/coverage-r1/level4/inbox/L4-0417-A.json"


def issue(**changes):
    base = {
        "title": "[relay] l4abc123 save L4-0417-A",
        "user": {"login": "Aedwon"},
        "body": json.dumps({"relay_version": 2, "action": "workspace_write_file",
                            "workspace": "Pantas-wt-content-coverage-audit-r1", "path": PATH, "content": "{}"}),
    }
    base.update(changes)
    return base


class FakeGh:
    def __init__(self, found):
        self.found = found
        self.edits = []

    def __call__(self, command, cwd=None):
        if command[:2] == ["gh", "api"]:
            return 0, json.dumps(self.found)
        if command[:3] == ["gh", "issue", "edit"]:
            self.edits.append(command)
            return 0, ""
        if command[:3] == ["gh", "issue", "list"]:
            return 0, json.dumps([{"number": 77, "title": self.found["title"]}])
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
            self.assertEqual(eraser.erase_handin("L4-0417", "A", config, run=gh), [])

    def test_issues_that_are_not_this_runs_hand_ins_are_refused(self):
        other_request = json.dumps({"relay_version": 2, "action": "workspace_exec", "argv": ["git", "status"]})
        outside = json.dumps({"relay_version": 2, "action": "workspace_write_file", "path": "lib/main.dart", "content": "x"})
        for bad in (issue(title="[relay] workspace_exec BetterGov"),
                    issue(title="[relay] l4zzzzzz save L4-0417-A"),
                    issue(title="[relay] l4abc123 check L4-0417-A"),
                    issue(user={"login": "someone-else"}),
                    issue(body=other_request), issue(body=outside), issue(body="not json"), issue(body=None)):
            gh = FakeGh(bad)
            erased, reason = eraser.erase(77, CONFIG, run=gh)
            self.assertFalse(erased, bad)
            self.assertEqual(gh.edits, [], reason)

    def test_unreadable_issue_is_not_edited(self):
        self.assertEqual(eraser.erase(77, CONFIG, run=lambda command, cwd=None: (1, "HTTP 404"))[0], False)

    def test_erase_handin_finds_and_erases_the_save_issue(self):
        gh = FakeGh(issue())
        self.assertEqual(eraser.erase_handin("L4-0417", "A", CONFIG, run=gh), [(77, True, "erased")])


if __name__ == "__main__":
    unittest.main()
