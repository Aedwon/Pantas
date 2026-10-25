"""Where each batch stands: not started, handed in, pushed, check passed.

A batch is done when every commit it made is on origin/content/cse-rewrite-r1 and the GitHub check for
that push passed. Git and gh are passed in, so tests can replace them. Python 3.9 standard library only.
"""
import json
import subprocess

import item_types
import rw_lib

WORKFLOW = "cse-rewrite-checks.yml"
FAILED = ("failure", "cancelled", "timed_out", "startup_failure", "action_required", "stale")


class GhError(Exception):
    pass


class Gh:
    """The GitHub command line, read only."""

    def __init__(self, root):
        self.root = root

    def runs(self):
        """Workflow runs on the rewrite branch, newest first: [{"headSha", "conclusion"}]."""
        try:
            proc = subprocess.run(
                ["gh", "run", "list", "--branch", rw_lib.BRANCH, "--workflow", WORKFLOW,
                 "--json", "headSha,conclusion", "--limit", "50"],
                cwd=str(self.root), stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=60)
        except (OSError, subprocess.SubprocessError) as exc:
            raise GhError("gh is not available (%s)" % type(exc).__name__)
        if proc.returncode != 0:
            raise GhError("gh could not list runs")
        try:
            return json.loads(proc.stdout.decode("utf-8"))
        except ValueError:
            raise GhError("gh returned something that is not JSON")


def fetch(git):
    """git fetch; False when it fails (offline), so the page can say its view of the remote is old."""
    try:
        git.run("fetch", "-q", "origin")
        return True
    except rw_lib.RewriteError:
        return False


def on_remote(git, commit):
    """True when `git branch -r --contains <commit>` lists the rewrite branch on origin."""
    names = [line.strip().lstrip("* ") for line in git.text("branch", "-r", "--contains", commit, check=False).splitlines()]
    return rw_lib.REMOTE_BRANCH in names


def check_outcome(git, runs, commit):
    """'passed', 'running', 'failed', 'unknown' or 'none' for the first run that carried this commit."""
    if runs is None:
        return "unknown"
    for run in reversed(runs):  # oldest first: the push that first carried the commit
        sha = run.get("headSha") or ""
        if sha == commit or (sha and git.ok("merge-base", "--is-ancestor", commit, sha)):
            conclusion = run.get("conclusion")
            if conclusion == "success":
                return "passed"
            if not conclusion:
                return "running"
            return "failed" if conclusion in FAILED else "unknown"
    return "none"


WORST = ("failed", "unknown", "running", "none", "passed")  # a batch shows its worst commit


def batch_view(ctx, batch, runs, copied, events):
    kind = item_types.get(batch["type"])
    keys = kind.items(batch)
    mine = []
    for key in keys:
        record = ctx.accepted(kind.name, key)
        if record and record.get("batch") == batch["id"]:
            mine.append(record)
    commits = sorted({r["commit"] for r in mine})
    held = [key for key in keys if ctx.is_held(batch["id"], key)]
    view = {"id": batch["id"], "type": batch["type"], "topic": batch["topic"], "lessons": keys,
            "accepted": len(mine), "commits": [rw_lib.short(c) for c in commits], "done": False}
    if held:
        state, label = "held", "Held: %d of %d need the lead" % (len(held), len(keys))
    elif not mine:
        touched = any(e.get("batch") == batch["id"] for e in events)
        state, label = (("in_progress", "In progress") if touched else
                        (("copied", "Prompt copied") if batch["id"] in copied else ("not_started", "Not started")))
    elif len(mine) < len(keys):
        state, label = "in_progress", "In progress (%d of %d accepted)" % (len(mine), len(keys))
    elif not all(on_remote(ctx.git, c) for c in commits):
        state, label = "handed_in", "Handed in at %s" % ", ".join(view["commits"])
    else:
        outcomes = [check_outcome(ctx.git, runs, c) for c in commits]
        worst = next(o for o in WORST if o in outcomes)
        state, label = {
            "passed": ("done", "Done: check passed"),
            "failed": ("check_failed", "Check failed"),
            "running": ("pushed", "Pushed, check running"),
            "none": ("pushed", "Pushed, waiting for the check"),
            "unknown": ("check_unknown", "Pushed, check unknown"),
        }[worst]
        view["done"] = state == "done"
    view["state"], view["label"] = state, label
    return view


def overview(ctx, gh, fetched=True):
    """The page's state: every batch, the next one to start, and anything that blocks starting it."""
    runs, notes = None, []
    try:
        runs = gh.runs()
    except GhError as exc:
        notes.append("Check unknown: %s." % exc)
    if not fetched:
        notes.append("The last git fetch failed, so pushed and done may be out of date.")
    data = ctx.load_batches()
    copied, events = ctx.copied(), ctx.events()
    views = [batch_view(ctx, data["batches"][i], runs, copied, events) for i in data["order"]]
    blocked = None
    failed = [v["id"] for v in views if v["state"] == "check_failed"]
    if failed:
        blocked = "The GitHub check failed for %s. Fix it before starting a new batch." % ", ".join(failed)
    elif ctx.stopped():
        blocked = "The run is stopped (an unexpected change was found). Fix the cause, then delete stop.json in the state folder."
    pending = [v for v in views if v["state"] == "not_started"]
    pending.sort(key=lambda v: item_types.get(v["type"]).priority)  # stable: batches keep their order within a type
    return {
        "batches": views,
        "next": None if blocked or not pending else pending[0]["id"],
        "blocked": blocked,
        "notes": notes,
        "counts": {"total": len(views), "done": sum(1 for v in views if v["done"])},
    }
