#!/usr/bin/env python3
"""Regenerate docs/content/illustrations/worklist.tsv from ILLUSTRATION markers.

Preserves the status column of an existing worklist (matched by
subject/topic/lesson/seq) so re-running after lesson edits does not lose
tracking progress. Run from anywhere: python3 tools/audit/list_illustrations.py
"""
import csv
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LESSONS = os.path.join(ROOT, "content", "lessons")
OUT = os.path.join(ROOT, "docs", "content", "illustrations", "worklist.tsv")

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


def load_existing_status():
    status = {}
    if os.path.exists(OUT):
        with open(OUT, encoding="utf-8", newline="") as f:
            for row in csv.DictReader(f, delimiter="\t"):
                key = (row["subject"], row["topic"], row["lesson"], row["seq"])
                status[key] = row.get("status", "todo")
    return status


def main():
    existing = load_existing_status()
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
                    status = existing.get((subject, topic, lesson, str(seq)), "todo")
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


if __name__ == "__main__":
    main()
