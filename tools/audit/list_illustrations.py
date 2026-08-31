#!/usr/bin/env python3
"""Regenerate docs/content/illustrations/worklist.tsv from ILLUSTRATION markers.

Status is derived from the filesystem: a row is "done" when an image file
matching its NN- prefix exists at the target folder, "todo" otherwise.
Run from anywhere: python3 tools/audit/list_illustrations.py
"""
import glob
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LESSONS = os.path.join(ROOT, "content", "lessons")
OUT = os.path.join(ROOT, "docs", "content", "illustrations", "worklist.tsv")
STRATEGY = os.path.join(ROOT, "docs", "content", "illustrations", "strategy.tsv")

MARKER = re.compile(r"<!--\s*ILLUSTRATION:\s*(.*?)\s*-->")
STOPWORDS = {"a", "an", "the", "of", "with", "and", "showing", "labeled",
             "simple", "small", "two", "three", "four", "five", "side",
             "by", "in", "on", "to", "for", "diagram", "diagrams"}


def short_slug(desc: str, maxwords: int = 4) -> str:
    words = re.findall(r"[a-z0-9]+", desc.lower())
    picked = [w for w in words if w not in STOPWORDS][:maxwords]
    if not picked:
        picked = words[:maxwords]
    return "-".join(picked)


def main():
    rows = []
    for dirpath, _, filenames in os.walk(LESSONS):
        for fn in sorted(filenames):
            if not fn.endswith(".md"):
                continue
            path = os.path.join(dirpath, fn)
            rel = os.path.relpath(path, LESSONS)
            parts = rel.split(os.sep)
            subject = parts[0]
            topic = parts[1] if len(parts) > 2 else ""
            lesson = os.path.splitext(parts[-1])[0]
            seq = 0
            with open(path, encoding="utf-8") as f:
                for lineno, line in enumerate(f, 1):
                    m = MARKER.search(line)
                    if not m:
                        continue
                    seq += 1
                    desc = m.group(1)
                    fname = f"{seq:02d}-{short_slug(desc)}.png"
                    subdir = f"{subject}/{topic}/{lesson}" if topic else f"{subject}/{lesson}"
                    target = f"content/illustrations/{subdir}/{fname}"
                    # Done if any image claims this slot (slug may differ if
                    # the description was edited after the file was connected).
                    slot = glob.glob(os.path.join(ROOT, "content", "illustrations",
                                                  subdir, f"{seq:02d}-*.png"))
                    status = "done" if slot else "todo"
                    rows.append((subject, topic, lesson, str(seq), str(lineno),
                                 target, status, desc))

    rows.sort(key=lambda r: (r[0], r[1], r[2], int(r[3])))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as f:
        f.write("subject\ttopic\tlesson\tseq\tline\ttarget_file\tstatus\tdescription\n")
        for r in rows:
            f.write("\t".join(r) + "\n")

    done = sum(1 for r in rows if r[6] == "done")
    print(f"{len(rows)} placeholders ({done} done) -> {os.path.relpath(OUT, ROOT)}")
    by_subject = {}
    for r in rows:
        by_subject[r[0]] = by_subject.get(r[0], 0) + 1
    for s, n in sorted(by_subject.items(), key=lambda kv: -kv[1]):
        print(f"  {s}: {n}")
    if os.path.isfile(STRATEGY):
        strat_counts = {}
        with open(STRATEGY, encoding="utf-8") as f:
            header = f.readline().strip().split("\t")
            strat_idx = header.index("strategy") if "strategy" in header else 6
            for line in f:
                parts = line.strip().split("\t")
                if len(parts) > strat_idx:
                    s = parts[strat_idx]
                    strat_counts[s] = strat_counts.get(s, 0) + 1
        strat_total = sum(strat_counts.values())
        print(f"  strategy: total={strat_total} code={strat_counts.get('code', 0)} "
              f"open={strat_counts.get('open', 0)} native={strat_counts.get('native', 0)} "
              f"cut={strat_counts.get('cut', 0)} founder={strat_counts.get('founder', 0)}")


if __name__ == "__main__":
    main()
