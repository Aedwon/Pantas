"""The read batch type: 2 or 3 rewritten lessons read by a fresh chat, one answer form each."""
import json

import briefs as briefs_mod
import grouping
import item_types
import prompts
import readpacket
import rw_lib

import l4lib


class ReadType(item_types.ItemType):
    name = "read"
    prefix = "RD"
    file_ext = ".json"
    commit_verb = "read"
    batch_size = 3
    priority = 0
    expected_status = "A"

    def plan(self, ctx):
        """Read batches for rewritten lessons that no read batch covers yet.

        A topic is cut into batches of 3 while it has 3 or more waiting lessons. When every lesson
        the rewrite batches planned for the topic is accepted, the rest is split evenly into batches of
        2 or 3 (a topic with a single lesson gives a batch of 1).
        """
        data = ctx.load_batches()
        rewrites = ctx.accepted_all("rewrite")
        planned = {}  # topic -> every lesson its rewrite batches planned
        for batch in data["batches"].values():
            if batch["type"] == "rewrite":
                planned.setdefault(batch["topic"], []).extend(batch["lessons"])
        covered = {(lesson, commit) for batch in data["batches"].values() if batch["type"] == self.name
                   for lesson, commit in batch["rewrites"].items()}
        briefs = briefs_mod.load_all(ctx)
        new = []
        for topic, lessons in planned.items():
            waiting = [i for i in lessons if i in rewrites and (i, rewrites[i]["commit"]) not in covered]
            if not waiting:
                continue
            complete = all(i in rewrites for i in lessons)
            sizes = grouping.split_sizes(len(waiting), self.batch_size) if complete else [self.batch_size] * (len(waiting) // self.batch_size)
            for group in grouping.chunk(waiting, sizes):
                new.append({
                    "lessons": group, "topic": topic,
                    "rewrites": {i: rewrites[i]["commit"] for i in group},
                    "sha256": {i: rewrites[i]["sha256"] for i in group},
                    "paths": {i: briefs[i]["path"] for i in group},
                })
        return new

    def target_paths(self, batch, key):
        return ["%s/%s/%s.json" % (rw_lib.READS_REL, batch["id"], key)]

    def prompt(self, ctx, batch, mode="pr"):
        return prompts.read_prompt(ctx, batch, mode)

    def check_item(self, ctx, batch, key, raw):
        brief = briefs_mod.load_all(ctx)[key]
        path = brief["path"]
        text = ctx.git.show("%s:%s" % (ctx.base_ref, path))
        if text is None or l4lib.sha256_text(text) != batch["sha256"][key]:
            raise rw_lib.RewriteError("the lesson no longer matches this batch")
        try:
            candidate = json.loads(raw.decode("utf-8"))
        except (ValueError, RecursionError, UnicodeError):
            return item_types.ItemResult(
                ["the saved form is not valid JSON. The form goes into the request as one JSON string: every "
                 "backslash in it must be doubled and every double quote escaped"], readable=False)
        pkt = readpacket.packet(key, text, path)
        try:
            reasons = readpacket.validate(candidate, pkt, brief)
            if not reasons:
                cleaned = readpacket.clean(candidate, brief)
                saved = {"batch": batch["id"], "lesson_id": key, "path": path, "lesson_sha256": pkt["lesson_sha256"],
                         "rewrite_commit": batch["rewrites"][key], "form": cleaned}
                data = (json.dumps(saved, indent=1, ensure_ascii=False) + "\n").encode("utf-8")
        except (ValueError, RecursionError, UnicodeError):
            return item_types.ItemResult(["the form could not be stored; remove any odd characters and try again"])
        except Exception:  # a form must never crash the check; an unknown fault is a rejection
            return item_types.ItemResult(["the form could not be checked; rebuild it from the prompt's blank form"])
        if reasons:
            return item_types.ItemResult(reasons)
        entries = cleaned["brief_items"].values()
        fails = sum(1 for e in cleaned["rules"].values() if e["verdict"] == "fail")
        record = {"not_fixed": sum(1 for e in entries if e["status"] == "not_fixed"), "rule_fails": fails}
        return item_types.ItemResult([], [], {self.target_paths(batch, key)[0]: data}, record)


item_types.register(ReadType())
