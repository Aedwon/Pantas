#!/usr/bin/env python3
"""Plan batches. Progress lives in ~/.pantas-rewrite (override: PANTAS_REWRITE_STATE). Each batch definition is a file in
docs/content/rewrite/batches/<batch id>.json, which the pull-request check reads at the base commit.

Usage:
  python3 -I tools/content_rewrite/relay/planner.py plan     add batches for lessons not yet planned
  python3 -I tools/content_rewrite/relay/planner.py list     show every batch
  python3 -I tools/content_rewrite/relay/planner.py requeue <lesson-id>...
                                                              new rewrite batch for lessons from one topic;
                                                              its brief adds what their latest read left open
  python3 -I tools/content_rewrite/relay/planner.py export   write every batch to its file under
                                                              docs/content/rewrite/batches (the lead commits them)

The plan only ever adds batches. A batch id is never reused or changed. To limit the pilot, put the lesson
ids (one per line, # comments allowed) in <state>/selection.txt before running plan.
Python 3.9 standard library only.
"""
import sys
import threading
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))

import briefs as briefs_mod  # noqa: E402
import grouping  # noqa: E402
import item_types  # noqa: E402
import readfindings  # noqa: E402
import rw_lib  # noqa: E402


def next_id(data, prefix):
    numbers = [int(batch_id.split("-")[1]) for batch_id in data["batches"] if batch_id.startswith(prefix + "-")]
    return "%s-%03d" % (prefix, max(numbers, default=0) + 1)


# Shared by all contexts and App instances in the threaded page server.
_PLAN_LOCK = threading.Lock()


def _read_proposals(ctx):
    """Plan each accepted lesson once, against the content the prompt will read."""
    data = ctx.load_batches()
    rewrites = ctx.accepted_all("rewrite")
    planned = {}
    seen = set()
    reads = [b for b in data["batches"].values() if b["type"] == "read"]
    for batch in data["batches"].values():
        if batch["type"] == "rewrite":
            for lesson in batch["lessons"]:
                if lesson not in seen:
                    planned.setdefault(batch["topic"], []).append(lesson)
                    seen.add(lesson)
    briefs = briefs_mod.load_all(ctx)
    proposals = []
    for topic, lessons in planned.items():
        waiting, hashes = [], {}
        stale = False
        for lesson in lessons:
            if lesson not in rewrites:
                continue
            path = briefs[lesson]["path"]
            text = ctx.git.show("%s:%s" % (ctx.base_ref, path))
            if text is None:
                raise rw_lib.RewriteError("lesson %s is missing" % lesson)
            hashes[lesson] = rw_lib.sha256_text(text)
            previous = [b for b in reads if lesson in b["lessons"]]
            if any(b.get("rewrites", {}).get(lesson) == rewrites[lesson]["commit"]
                   and b.get("sha256", {}).get(lesson) == hashes[lesson] for b in previous):
                continue
            waiting.append(lesson)
            stale = stale or bool(previous)
        complete = all(lesson in rewrites for lesson in lessons)
        size = item_types.get("read").batch_size
        # A stale prompt needs a replacement even while other rewrites are pending.
        sizes = (grouping.split_sizes(len(waiting), size) if complete or stale else
                 [size] * (len(waiting) // size))
        for group in grouping.chunk(waiting, sizes):
            proposals.append({
                "lessons": group, "topic": topic,
                "rewrites": {i: rewrites[i]["commit"] for i in group},
                "sha256": {i: hashes[i] for i in group},
                "paths": {i: briefs[i]["path"] for i in group},
            })
    return proposals


def plan(ctx, kinds=None):
    """Serialize proposal generation and saving, including coverage and id checks."""
    with _PLAN_LOCK:
        added = []
        for name, item_type in sorted(item_types.REGISTRY.items()):
            if kinds and name not in kinds:
                continue
            proposals = _read_proposals(ctx) if name == "read" else item_type.plan(ctx)
            for proposal in proposals:
                data = ctx.load_batches()
                batch_id = next_id(data, item_type.prefix)
                data["batches"][batch_id] = dict(proposal, id=batch_id, type=name, created=rw_lib.now())
                data["order"].append(batch_id)
                ctx.save_batches(data)
                added.append(batch_id)
        return added


def requeue(ctx, lesson_ids):
    with _PLAN_LOCK:
        return _requeue(ctx, lesson_ids)


def _requeue(ctx, lesson_ids):
    """A new rewrite batch for lessons that already have one, for example after a read found problems.

    The batch carries, for each lesson, what the lesson's latest read left open: failed rule findings, accuracy
    concerns and brief items not fixed. The prompt adds them to the lesson's brief.
    """
    batch = item_types.get("rewrite").propose(ctx, lesson_ids)
    briefs = briefs_mod.load_all(ctx)
    extra = {}
    for lesson_id in lesson_ids:
        text = readfindings.brief_addition(readfindings.open_items(ctx, lesson_id, briefs[lesson_id]))
        if text:
            extra[lesson_id] = text
    if extra:
        batch["extra_brief"] = extra
    data = ctx.load_batches()
    batch_id = next_id(data, "RW")
    data["batches"][batch_id] = dict(batch, id=batch_id, type="rewrite", created=rw_lib.now())
    data["order"].append(batch_id)
    ctx.save_batches(data)
    return batch_id


def main(argv):
    ctx = rw_lib.Ctx()
    if argv[1:] == ["plan"]:
        added = plan(ctx)
        print("batches added: %d%s" % (len(added), (" (" + ", ".join(added) + ")") if added else ""))
        return 0
    if argv[1:] == ["list"]:
        data = ctx.load_batches()
        for batch_id in data["order"]:
            batch = data["batches"][batch_id]
            print("%s %-7s %-40s %s" % (batch_id, batch["type"], batch["topic"], " ".join(batch["lessons"])))
        return 0
    if argv[1:] == ["export"]:
        ctx.save_batches(ctx.load_batches())
        print("batch files: %d" % len(ctx.load_batches()["order"]))
        return 0
    if len(argv) >= 3 and argv[1] == "requeue":
        print("batch added: " + requeue(ctx, argv[2:]))
        return 0
    print(__doc__)
    return 64


if __name__ == "__main__":
    sys.exit(main(sys.argv))
