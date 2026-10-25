"""Where each batch stands: not started, handed in, pushed, check passed.

Remote commit subjects and merged hand-in pull requests identify batches across rebases.
Those batches are done when the push check passed or is unknown. Git and gh are passed in, so tests can replace them. Python 3.9 standard library only.
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

    def _json(self, args, what):
        try:
            proc = subprocess.run(["gh"] + args, cwd=str(self.root), stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE, timeout=60)
        except (OSError, subprocess.SubprocessError) as exc:
            raise GhError("gh is not available (%s)" % type(exc).__name__)
        if proc.returncode != 0:
            raise GhError("gh could not list %s" % what)
        try:
            return json.loads(proc.stdout.decode("utf-8"))
        except ValueError:
            raise GhError("gh returned something that is not JSON")

    def runs(self):
        """Workflow runs on the rewrite branch, newest first: [{"headSha", "conclusion"}]."""
        return self._json(["run", "list", "--branch", rw_lib.BRANCH, "--workflow", WORKFLOW,
                           "--json", "headSha,conclusion", "--limit", "50"], "runs")

    def prs(self):
        """Hand-in pull requests into the rewrite branch, any state: [{"number", "state", "headRefName",
        "mergeCommit": {"oid"} or None, "labels": [{"name"}]}]. One call for every batch."""
        found = self._json(["pr", "list", "--state", "all", "--base", rw_lib.BRANCH, "--json",
                            "number,state,headRefName,mergeCommit,labels,title", "--limit", "200"], "pull requests")
        return [pr for pr in found if str(pr.get("headRefName", "")).startswith(rw_lib.PR_BRANCH_PREFIX)
                or str(pr.get("title", "")).startswith("[handin] ")]


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


def pr_state(prs, batch_id):
    """('merged', pr), ('held', pr), ('open', pr) or (None, None) for the hand-in pull requests of one batch."""
    mine = [pr for pr in prs or [] if pr.get("headRefName") == rw_lib.PR_BRANCH_PREFIX + batch_id
            or pr.get("title", "").split()[:2] == ["[handin]", batch_id]]
    for want in ("MERGED", "OPEN"):
        for pr in sorted((p for p in mine if p.get("state") == want), key=lambda p: p["number"], reverse=True):
            if want == "MERGED" and pr.get("mergeCommit"):
                return "merged", pr
            if want == "OPEN":
                held = any(label.get("name") == "held" for label in pr.get("labels") or [])
                return ("held" if held else "open"), pr
    return None, None


CHECK_STATES = {
    "passed": ("done", "Done: merged, check passed"),
    "failed": ("check_failed", "Merged, check failed"),
    "running": ("pushed", "Merged, check running"),
    "none": ("pushed", "Merged, waiting for the check"),
    "unknown": ("done", "Done: merged, check unknown"),
}


def remote_commits(git):
    """Index remote hand-ins by batch ID, so rebases do not hide them."""
    found = {}
    for line in git.text("log", rw_lib.REMOTE_BRANCH, "--format=%H%x09%s", check=False).splitlines():
        sha, sep, subject = line.partition("\t")
        words = subject.split()
        if sep and len(words) >= 2 and words[0] in ("rewrite:", "read:"):
            found.setdefault(words[1], sha)
    return found


def replacement(ctx, batch):
    if batch["type"] not in ("rewrite", "read") or not batch["lessons"]:
        return None
    data = ctx.load_batches()
    order = data["order"]
    newer = set(order[order.index(batch["id"]) + 1:])
    if batch["type"] == "read":
        covering = {}
        for batch_id in order[order.index(batch["id"]) + 1:]:
            candidate = data["batches"][batch_id]
            if candidate["type"] == "read":
                for lesson in candidate["lessons"]:
                    covering[lesson] = batch_id
        if all(lesson in covering for lesson in batch["lessons"]):
            return ", ".join(sorted({covering[lesson] for lesson in batch["lessons"]}, key=order.index))
        return None
    records = [ctx.accepted("rewrite", key) for key in batch["lessons"]]
    if all(record and record.get("batch") in newer for record in records):
        return ", ".join(sorted({record["batch"] for record in records}, key=order.index))
    return None


def batch_view(ctx, batch, runs, copied, events, prs=None, remote=None):
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
    pr_kind, pr = pr_state(prs, batch["id"])
    replaced = replacement(ctx, batch)
    remote_commit = (remote or {}).get(batch["id"])
    if replaced:
        state, label = "replaced", "Replaced by " + replaced
        view["done"] = True
    elif remote_commit:
        view["commits"] = [rw_lib.short(remote_commit)]
        outcome = check_outcome(ctx.git, runs, remote_commit)
        state, label = CHECK_STATES[outcome]
        label = label.replace("merged", "pushed").replace("Merged", "Pushed")
        view["done"] = state == "done"
    elif pr_kind == "merged":
        # The pull-request hand-in: done when the pull request is merged and the push check on the merge passed.
        commit = pr["mergeCommit"]["oid"]
        view["commits"] = [rw_lib.short(commit)]
        state, label = CHECK_STATES[check_outcome(ctx.git, runs, commit)]
        view["done"] = state == "done"
    elif pr_kind == "held":
        state, label = "held", "Held: pull request #%d needs the lead" % pr["number"]
        view["pr"] = pr["number"]
    elif pr_kind == "open":
        state, label = "pr_open", "Pull request #%d open" % pr["number"]
        view["pr"] = pr["number"]
    elif held:
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
    runs, prs, notes = None, None, []
    try:
        runs = gh.runs()
    except GhError as exc:
        notes.append("Check unknown: %s." % exc)
    if hasattr(gh, "prs"):
        try:
            prs = gh.prs()
        except GhError as exc:
            notes.append("Pull request state unknown: %s." % exc)
    if not fetched:
        notes.append("The last git fetch failed, so pushed and done may be out of date.")
    data = ctx.load_batches()
    copied, events = ctx.copied(), ctx.events()
    remote = remote_commits(ctx.git)
    views = [batch_view(ctx, data["batches"][i], runs, copied, events, prs, remote) for i in data["order"]]
    blocked = None
    failed = [v["id"] for v in views if v["state"] == "check_failed"]
    if failed:
        blocked = "The GitHub check failed for %s. Fix it before starting a new batch." % ", ".join(failed)
    elif ctx.stopped():
        blocked = "The run is stopped (an unexpected change was found). Fix the cause, then delete stop.json in the state folder."
    held = [{"id": v["id"], "pr": v.get("pr")} for v in views if v["state"] == "held"]
    pending = [v for v in views if v["state"] == "not_started"]
    pending.sort(key=lambda v: item_types.get(v["type"]).priority)  # stable: batches keep their order within a type
    return {
        "batches": views,
        "next": None if blocked or not pending else pending[0]["id"],
        "blocked": blocked,
        "held": held,
        "notes": notes,
        "counts": {"total": len(views), "done": sum(1 for v in views if v["done"])},
    }
