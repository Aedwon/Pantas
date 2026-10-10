"""Replace the text of a hand-in Issue once the form is saved locally.

A hand-in travels through the relay as a GitHub Issue whose body holds the
whole form, where the other reader could find it. This removes the form from
the Issue body. GitHub keeps an Issue's edit history, so this makes copying
harder, not impossible; the comparer's copy flag covers the rest.

It edits an Issue only when every check passes, and does nothing at all
unless Aedwon's confirmation is recorded in the local config.
"""
import json

import dispatch
import l4lib

INBOX_PREFIX = "docs/content/audit/coverage-r1/level4/inbox/"
ERASED_BODY = ("Hand-in form removed after it was saved on the audit Mac. "
               "Pantas Level 4 audit, run %s.")


def refusal(issue, run_token):
    """Why this Issue must not be edited, or None when it is a hand-in of this run."""
    title = issue.get("title") or ""
    if not title.startswith("[relay] %s save " % run_token):
        return "title is not a hand-in of this run"
    if (issue.get("user") or {}).get("login") != "Aedwon":
        return "issue was not opened by Aedwon"
    try:
        body = json.loads(issue.get("body") or "")
    except ValueError:
        return "body is not a relay request"
    if not isinstance(body, dict) or body.get("action") != "workspace_write_file":
        return "body is not a file save request"
    if not str(body.get("path", "")).startswith(INBOX_PREFIX):
        return "request does not save into the hand-in inbox"
    return None


def erase(issue_number, config, run=dispatch._run):
    """Return (erased, reason). Never raises for a refused Issue."""
    if config.get("eraser_confirmed") is not True:
        return False, "eraser is not confirmed"
    code, output = run(["gh", "api", "repos/%s/issues/%d" % (dispatch.RELAY_REPO, issue_number)])
    if code != 0:
        return False, "could not read issue %d" % issue_number
    try:
        issue = json.loads(output)
    except ValueError:
        return False, "could not read issue %d" % issue_number
    reason = refusal(issue, config["run_token"])
    if reason:
        return False, reason
    code, output = run(["gh", "issue", "edit", str(issue_number), "-R", dispatch.RELAY_REPO,
                        "--body", ERASED_BODY % config["run_token"]])
    if code != 0:
        return False, "could not edit issue %d" % issue_number
    return True, "erased"


def erase_handin(packet_id, role, config, run=dispatch._run):
    """Erase every Issue that carried this hand-in. Returns [(issue number, erased, reason)]."""
    if config.get("eraser_confirmed") is not True:
        return []
    try:
        numbers = dispatch.find_handin_issues(config["run_token"], packet_id, role, run=run)
    except l4lib.L4Error as exc:
        return [(0, False, str(exc))]
    return [(number,) + erase(number, config, run=run) for number in numbers]
