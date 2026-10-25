"""The rewrite batch type: 3 or 4 lessons from one topic, rewritten in one chat."""
import briefs as briefs_mod
import checks
import grouping
import item_types
import prompts
import rw_lib

import l4lib


def read_selection(ctx):
    """Lesson ids from <state>/selection.txt, in order, or None when the file does not exist."""
    path = ctx.state_file("selection.txt")
    if not path.exists():
        return None
    ids = []
    for line in path.read_text(encoding="utf-8").splitlines():
        entry = line.split("#", 1)[0].strip()
        if entry and entry not in ids:
            ids.append(entry)
    return ids


class RewriteType(item_types.ItemType):
    name = "rewrite"
    prefix = "RW"
    file_ext = ".md"
    commit_verb = "rewrite"
    batch_size = 4
    priority = 1

    def plan(self, ctx):
        briefs = briefs_mod.load_all(ctx)
        selection = read_selection(ctx)
        if selection is not None:
            missing = [lesson_id for lesson_id in selection if lesson_id not in briefs]
            if missing:
                raise rw_lib.RewriteError("selection.txt names %d lessons that have no brief" % len(missing))
        wanted = selection if selection is not None else sorted(briefs, key=lambda i: briefs[i]["path"])
        assigned = {lesson for batch in ctx.load_batches()["batches"].values() if batch["type"] == self.name
                    for lesson in batch["lessons"]}
        pending = [lesson_id for lesson_id in wanted if lesson_id not in assigned]
        groups = grouping.group_by_topic(pending, lambda i: rw_lib.topic_of(briefs[i]["path"]))
        new = []
        for topic, ids in groups.items():
            for lessons in grouping.chunk(ids, grouping.split_sizes(len(ids), self.batch_size)):
                new.append(self.propose(ctx, lessons, briefs))
        return new

    def propose(self, ctx, lessons, briefs=None):
        """One rewrite batch for these lessons, which must all be from one topic."""
        briefs = briefs or briefs_mod.load_all(ctx)
        unknown = [i for i in lessons if i not in briefs]
        if unknown:
            raise rw_lib.RewriteError("%d lessons have no brief" % len(unknown))
        topics = {rw_lib.topic_of(briefs[i]["path"]) for i in lessons}
        if len(topics) != 1:
            raise rw_lib.RewriteError("a rewrite batch holds lessons from one topic")
        earlier = sum(1 for b in ctx.load_batches()["batches"].values()
                      if b["type"] == self.name and set(lessons) & set(b["lessons"]))
        return {"lessons": list(lessons), "topic": topics.pop(), "round": earlier + 1,
                "paths": {i: briefs[i]["path"] for i in lessons}}

    def target_paths(self, batch, key):
        return [batch["paths"][key]]

    def prompt(self, ctx, batch):
        return prompts.rewrite_prompt(ctx, batch)

    def check_item(self, ctx, batch, key, raw):
        brief = briefs_mod.load_all(ctx)[key]
        try:
            new = rw_lib.clean_text(raw)
        except UnicodeError:
            return item_types.ItemResult(["the saved file is not valid UTF-8 text"], readable=False)
        base = ctx.git.show("HEAD:" + brief["path"])
        if base is None:
            return item_types.ItemResult(["the lesson is not in the repository at this commit"])
        reasons, notes = checks.check_rewrite_text(base, new, brief["path"])
        flags = []
        if not any("does not parse" in r for r in reasons):
            changes = checks.change_guard(base, new, brief)
            loose = checks.uncovered(changes)
            if loose:
                lines = sorted({c["line"] for c in loose})
                notes.append("%d changed passages match no brief item or gap part (lines %s)"
                             % (len(loose), ", ".join(str(n) for n in lines[:15])))
            # Only a passage with no match keeps its text: the reader is shown those.
            flags = [{"line": c["line"], "kind": c["kind"], "by": c["by"],
                      "text": c["text"] if c["by"] is None else ""} for c in changes]
        record = {"sha256": l4lib.sha256_text(new), "changes": flags}
        return item_types.ItemResult(reasons, notes, {brief["path"]: new.encode("utf-8")}, record)


item_types.register(RewriteType())
