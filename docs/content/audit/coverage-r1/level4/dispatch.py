"""Thin wrapper over the ChatGPT web dispatcher and gh.

Facts read from Aedwon/chatgpt-terminal-relay main on October 10, 2026:

- `python -m dispatcher.cli register <file>` prints `registered <task_id> <issue_url>`.
- An assignment needs: title, role, repository, branch, base_sha, worktree
  (null here, so two reads of one lesson are not serialized), runner_required,
  requested_model, requested_effort, max_continuations, replacement_allowed,
  assignment_markdown, worker_task_version 1.
- With ChatGPT's reasoning picker the adapter accepts exactly one model name,
  `REASONING_PICKER_MODEL` in dispatcher/chatgpt_web.py ("GPT-6 Sol" once relay
  pull request 9408 is merged), and efforts Instant, Medium, High, Extra High.
- Worker state is a series of `worker-event` JSON comments on the task's
  `[worker]` Issue. Events: launching, dispatched, working, heartbeat,
  continuation_sent, stalled (reason_code), replacement_started, blocked
  (blocker_code, blocker), failed, completed, cancelled.
- A restriction seen in the browser is recorded as a `blocked` event whose text
  carries the restriction kind: auth_required, captcha, rate_limit,
  usage_limit, model_limit, safety_restriction.

This module never reads a chat's reply text. It reads only those events.
"""
import datetime
import json
import re
import subprocess
from pathlib import Path

import l4lib

RELAY_REPO = "Aedwon/chatgpt-terminal-relay"
DISPATCHER_ROOT = l4lib.AUDIT_WT.parent / "chatgpt-terminal-relay"
DISPATCHER_PYTHON = DISPATCHER_ROOT / ".venv-dispatcher" / "bin" / "python"
MODEL = "GPT-6 Sol"
EFFORT = "High"
AUDIT_BRANCH = "docs/content-coverage-audit-r1"

ACTIVE = ("queued", "launching", "dispatched", "working", "heartbeat", "continuation_sent", "replacement_started")
LIMIT_KINDS = ("usage_limit", "rate_limit", "model_limit")
SIGNIN_KINDS = ("auth_required", "captcha")


def _run(command, cwd=None):
    done = subprocess.run(command, cwd=str(cwd) if cwd else None, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, universal_newlines=True)
    return done.returncode, done.stdout


def assignment(task_id, title, role, markdown, base_sha):
    return {
        "worker_task_version": 1, "task_id": task_id, "title": title, "role": role,
        "repository": "Aedwon/Pantas", "branch": AUDIT_BRANCH, "base_sha": base_sha,
        "worktree": None, "runner_required": True,
        "requested_model": MODEL, "requested_effort": EFFORT,
        "max_continuations": 2, "replacement_allowed": False,
        "assignment_markdown": markdown,
    }


def register(envelope, run=_run, state_dir=None):
    """Register one worker task. Returns {"task_id", "issue_url", "issue_number"}."""
    path = Path(state_dir or l4lib.STATE_DIR) / "assignments" / ("%s.json" % envelope["task_id"])
    l4lib.save_json(path, envelope)
    code, output = run([str(DISPATCHER_PYTHON), "-m", "dispatcher.cli", "register", str(path)], DISPATCHER_ROOT)
    match = re.search(r"^registered (\S+) (\S+/issues/(\d+))\s*$", output, re.M)
    if code != 0 or not match:
        raise l4lib.L4Error("dispatcher did not register %s: %s" % (envelope["task_id"], output.strip()[-300:]))
    return {"task_id": match.group(1), "issue_url": match.group(2), "issue_number": int(match.group(3))}


def cancel(task_id, run=_run):
    """Cancel a worker task that is no longer wanted. Safe on a finished task."""
    code, output = run([str(DISPATCHER_PYTHON), "-m", "dispatcher.cli", "cancel", task_id], DISPATCHER_ROOT)
    if code != 0:
        raise l4lib.L4Error("dispatcher did not cancel %s: %s" % (task_id, output.strip()[-200:]))


def parse_events(comment_bodies):
    events = []
    for body in comment_bodies:
        match = re.search(r"worker-event\s*```json\s*(\{.*?\})\s*```", body or "", re.S)
        if not match:
            continue
        try:
            event = json.loads(match.group(1))
        except ValueError:
            continue
        if isinstance(event, dict) and isinstance(event.get("event"), str):
            events.append(event)
    return events


def classify(events):
    """Reduce a task's events to what the queue acts on.

    Returns {"state": "active" | "completed" | "limit" | "signin" | "failed", "detail": str}.
    """
    if not events:
        return {"state": "active", "detail": "queued"}
    last = events[-1]
    kind = last["event"]
    if kind in ACTIVE:
        return {"state": "active", "detail": kind}
    if kind == "completed":
        return {"state": "completed", "detail": "completed"}
    text = json.dumps(last).lower()
    if kind == "blocked":
        if any(word in text for word in LIMIT_KINDS):
            return {"state": "limit", "detail": next(word for word in LIMIT_KINDS if word in text)}
        if any(word in text for word in SIGNIN_KINDS):
            return {"state": "signin", "detail": next(word for word in SIGNIN_KINDS if word in text)}
    detail = last.get("reason_code") or last.get("blocker_code") or last.get("failure_code") or kind
    return {"state": "failed", "detail": "%s: %s" % (kind, detail)}


def task_state(issue_number, run=_run):
    code, output = run(["gh", "api", "--paginate", "repos/%s/issues/%d/comments" % (RELAY_REPO, issue_number),
                        "--jq", ".[].body | @json"])
    if code != 0:
        raise l4lib.L4Error("could not read worker issue %d: %s" % (issue_number, output.strip()[-200:]))
    bodies = [json.loads(line) for line in output.splitlines() if line.strip()]
    return classify(parse_events(bodies))


def runners_online(run=_run):
    code, output = run(["gh", "api", "repos/%s/actions/runners" % RELAY_REPO,
                        "--jq", '[.runners[] | select(.status == "online")] | length'])
    if code != 0:
        raise l4lib.L4Error("could not read runner status: %s" % output.strip()[-200:])
    return int(output.strip() or 0)


def supervisor_running(run=_run):
    code, _ = run(["pgrep", "-f", "dispatcher.cli supervise"])
    return code == 0


INBOX_DIR = "docs/content/audit/coverage-r1/level4/inbox/"
HANDIN_SCRIPT = "docs/content/audit/coverage-r1/level4/handin.py"
WRITE_KEYS = {"relay_version", "action", "workspace", "path", "content"}
EXEC_KEYS = {"relay_version", "action", "workspace", "argv", "timeout_seconds"}
SINCE_MARGIN = datetime.timedelta(seconds=60)  # the Mac's clock may run a little behind GitHub's


def _time(text):
    return datetime.datetime.fromisoformat(text.replace("Z", "+00:00"))


def list_relay_issues(since, run=_run):
    """Relay Issues (title starting "[relay]") opened by Aedwon since the given time, oldest first.

    This reads the Issues list, not search: search lags behind new Issues, and a
    request a chat made a minute ago must be seen. Each row is
    {"number", "title", "body", "created_at", "user": {"login"}}.
    """
    start = _time(since) - SINCE_MARGIN
    query = "state=all&sort=created&direction=asc&creator=Aedwon&per_page=100&since=%s" % start.strftime("%Y-%m-%dT%H:%M:%SZ")
    code, output = run(["gh", "api", "--paginate", "repos/%s/issues?%s" % (RELAY_REPO, query), "--jq",
                        ".[] | select(.pull_request == null) | "
                        "{number, title, body, created_at, user: {login: .user.login}} | @json"])
    if code != 0:
        raise l4lib.L4Error("could not list relay issues: %s" % output.strip()[-200:])
    issues = []
    for line in output.splitlines():
        if not line.strip():
            continue
        try:
            issue = json.loads(line)
        except ValueError:
            raise l4lib.L4Error("could not read the relay issue list")
        if (issue.get("title") or "").startswith("[relay]") and _time(issue["created_at"]) >= start:
            issues.append(issue)
    return issues


def classify_request(issue, workspace, registered):
    """What a relay Issue is, as far as this run is concerned.

    "expected":  exactly one of the two hand-in requests the run told a chat to make.
    "unrelated": a request for another workspace, or not a relay request at all.
    "forbidden": anything else aimed at the audit worktree. The run must stop.

    workspace: the audit worktree's folder name. registered: the set of
    "packet|role|attempt" strings the run has told chats to hand in.
    """
    try:
        body = json.loads(issue.get("body") or "")
    except ValueError:
        return "unrelated"
    if not isinstance(body, dict) or not isinstance(body.get("action"), str):
        return "unrelated"
    target = body.get("workspace")
    if isinstance(target, str) and target.strip().rstrip("/").split("/")[-1].lower() != workspace.lower():
        return "unrelated"
    # From here the request is for the audit worktree, or does not say where it is aimed.
    # A request that does not say is treated as aimed here: nothing shows it is not.
    action = body["action"]
    if action == "workspace_write_file":
        match = re.fullmatch(re.escape(INBOX_DIR) + r"(L4-\d{4})-([ABD])-(\d+)\.json", str(body.get("path")))
        if (match and set(body) <= WRITE_KEYS and isinstance(body.get("content"), str)
                and "|".join(match.groups()) in registered):
            return "expected"
    elif action == "workspace_exec":
        argv = body.get("argv")
        if (isinstance(argv, list) and len(argv) == 5 and argv[:2] == ["python3", HANDIN_SCRIPT]
                and all(isinstance(item, str) for item in argv) and "|".join(argv[2:]) in registered
                and set(body) <= EXEC_KEYS
                and isinstance(body.get("timeout_seconds", 0), int) and not isinstance(body.get("timeout_seconds"), bool)):
            return "expected"
    return "forbidden"

