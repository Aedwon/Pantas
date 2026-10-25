#!/usr/bin/env python3
"""Plan batches. State lives in ~/.pantas-rewrite (override: PANTAS_REWRITE_STATE), never in the repo.

Usage:
  python3 -I tools/content_rewrite/relay/planner.py plan     add batches for lessons not yet planned
  python3 -I tools/content_rewrite/relay/planner.py list     show every batch
  python3 -I tools/content_rewrite/relay/planner.py requeue <lesson-id>...
                                                              new rewrite batch for lessons from one topic

The plan only ever adds batches. A batch id is never reused or changed. To limit the pilot, put the lesson
ids (one per line, # comments allowed) in <state>/selection.txt before running plan.
Python 3.9 standard library only.
"""
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))

import item_types  # noqa: E402
import rw_lib  # noqa: E402


def next_id(data, prefix):
    numbers = [int(batch_id.split("-")[1]) for batch_id in data["batches"] if batch_id.startswith(prefix + "-")]
    return "%s-%03d" % (prefix, max(numbers, default=0) + 1)


def plan(ctx, kinds=None):
    """Add the batches each type proposes. Returns the new batch ids."""
    added = []
    for name, item_type in sorted(item_types.REGISTRY.items()):
        if kinds and name not in kinds:
            continue
        for proposal in item_type.plan(ctx):
            data = ctx.load_batches()
            batch_id = next_id(data, item_type.prefix)
            data["batches"][batch_id] = dict(proposal, id=batch_id, type=name, created=rw_lib.now())
            data["order"].append(batch_id)
            ctx.save_batches(data)
            added.append(batch_id)
    return added


def requeue(ctx, lesson_ids):
    """A new rewrite batch for lessons that already have one, for example after a read found problems."""
    batch = item_types.get("rewrite").propose(ctx, lesson_ids)
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
    if len(argv) >= 3 and argv[1] == "requeue":
        print("batch added: " + requeue(ctx, argv[2:]))
        return 0
    print(__doc__)
    return 64


if __name__ == "__main__":
    sys.exit(main(sys.argv))
