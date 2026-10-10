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


def find_handin_issues(run_token, packet_id, role, run=_run):
    """Numbers of the relay Issues that carried this hand-in's saved form."""
    title = "[relay] %s save %s-%s" % (run_token, packet_id, role)
    code, output = run(["gh", "issue", "list", "-R", RELAY_REPO, "--state", "all", "--search",
                        '"%s" in:title' % title, "--json", "number,title", "--limit", "20"])
    if code != 0:
        raise l4lib.L4Error("could not search relay issues: %s" % output.strip()[-200:])
    return [issue["number"] for issue in json.loads(output or "[]") if issue["title"].strip() == title]
