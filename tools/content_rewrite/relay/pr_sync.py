"""Record the rewrites that pull requests merged, so read batches can be planned for them.

The local hand-in wrote an "accepted" record for every lesson it committed. The pull-request hand-in is
merged on GitHub, so this reads the merge instead: for each merged rewrite pull request it stores the same
record, with the squash commit and the lesson text at that commit. It changes nothing in the repository.
Python 3.9 standard library only.
"""
import briefs as briefs_mod
import checks
import rw_lib

import l4lib  # noqa: E402  (vendored)


def _synced(ctx):
    path = ctx.state_file("synced.json")
    return rw_lib.json_load(path) if path.exists() else []


def sync(ctx, prs):
    """Returns the batch ids synced now. prs is what status.Gh.prs() returns."""
    done = _synced(ctx)
    added = []
    for pr in sorted(prs or [], key=lambda p: p["number"]):
        batch_id = str(pr.get("headRefName", ""))[len(rw_lib.PR_BRANCH_PREFIX):]
        if pr.get("state") != "MERGED" or not pr.get("mergeCommit") or batch_id in done:
            continue
        commit = pr["mergeCommit"]["oid"]
        batch = ctx.batch(batch_id) if ctx.batch_file(batch_id).exists() else None
        if batch is None or not ctx.git.ok("cat-file", "-e", commit + "^{commit}"):
            continue   # not pulled yet: try again on the next refresh
        if batch["type"] == "rewrite":
            briefs = briefs_mod.load_all(ctx)
            for key in batch["lessons"]:
                path = batch["paths"][key]
                text = ctx.git.show("%s:%s" % (commit, path))
                if text is None:
                    continue
                before = ctx.git.show("%s^:%s" % (commit, path)) or text
                try:
                    flags = checks.change_flags(before, text, briefs[key])
                except l4lib.L4Error:
                    flags = []
                rw_lib.json_save(ctx.accepted_path("rewrite", key), {
                    "sha256": l4lib.sha256_text(text), "changes": flags, "batch": batch_id, "commit": commit,
                    "at": rw_lib.now(), "attempt": 0, "via": "pull request %d" % pr["number"]})
        done.append(batch_id)
        added.append(batch_id)
    if added:
        rw_lib.json_save(ctx.state_file("synced.json"), done)
    return added
