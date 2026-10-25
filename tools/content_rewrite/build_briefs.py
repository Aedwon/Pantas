#!/usr/bin/env python3
"""Build per-lesson rewrite briefs (plan P0.1).

Run: python3 -I tools/content_rewrite/build_briefs.py
Python 3.9, standard library only. Output is deterministic.
"""
import argparse
import glob
import json
import os
import re
import subprocess
import sys

AUDIT = ("/Users/aedwon/Documents/Projects/Pantas-wt-content-coverage-audit-r1/"
         "docs/content/audit/coverage-r1")
DEFAULT_TRIAGE = AUDIT + "/level4/paste/results/triage.jsonl"
DEFAULT_GAPS = AUDIT + "/level4/paste/results/cse-teaching-gaps.jsonl"
DEFAULT_TAGS = AUDIT + "/lesson-exam-tags.json"
REPO = "/Users/aedwon/Documents/Projects/Pantas"
WORKTREE = "/Users/aedwon/Documents/Projects/Pantas-wt-cse-rewrite-r1"
OUT_DIR = "docs/content/rewrite/briefs"

PLACE_RE = re.compile(r"^(add to|Filipino section in)\s+(\S+)\s*$")
NEW_RE = re.compile(r"^new lesson:\s*(.+?)\s*$")
RULE_ID_RE = re.compile(r"^[A-Z]+\d+[a-z]?$")
FIX_ORDER = {"large": 0, "medium": 1, "small": 2, "": 3}


def read_jsonl(path):
    rows = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def natural_key(text):
    return [int(p) if p.isdigit() else p for p in re.split(r"(\d+)", text)]


def parse_place(place):
    """Return (kind, target). kind: add, filipino, new, skip."""
    place = (place or "").strip()
    m = PLACE_RE.match(place)
    if m:
        return ("filipino" if m.group(1).startswith("Filipino") else "add"), m.group(2)
    m = NEW_RE.match(place)
    if m:
        return "new", m.group(1)
    return "skip", place


def parse_checklist(text):
    """Map rule id to the exact table row text."""
    rules = {}
    for line in text.splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if line.lstrip().startswith("|") and cells and RULE_ID_RE.match(cells[0]):
            rules.setdefault(cells[0], line.strip())
    return rules


def rule_ids(rule):
    return [p for p in re.split(r"[\s,/;+]+", rule or "") if RULE_ID_RE.match(p)]


def quote_block(text):
    text = (text or "").strip()
    if not text:
        return "(no quote)"
    return "\n".join("> " + ln if ln else ">" for ln in text.splitlines())


def build_briefs(triage, gaps, tags, rules, lesson_titles=None):
    """Return (briefs, new_lessons_md, stats).

    briefs: {lesson_id: markdown}. tags: {lesson_id: {path, title, exams}}.
    """
    lesson_titles = lesson_titles or {}
    per = {}

    def slot(lid):
        return per.setdefault(lid, {"real": [], "judgment": [], "illustration": [],
                                    "gaps": []})

    for r in triage:
        if r.get("verdict") in ("real", "judgment", "illustration"):
            slot(r["lesson"])[r["verdict"]].append(r)
    new_groups = {}
    skipped_gaps = []
    for g in gaps:
        if g.get("duplicate_of"):
            continue
        kind, target = parse_place(g.get("place"))
        if kind in ("add", "filipino"):
            slot(target)["gaps"].append((kind, g))
        elif kind == "new":
            new_groups.setdefault(target, []).append(g)
        else:
            skipped_gaps.append(g)

    def gkey(g):
        return natural_key(g["key"])

    def tkey(r):
        return (FIX_ORDER.get(r.get("fix", ""), 3), natural_key(r["id"]))

    briefs = {}
    stats = {"real": 0, "gap": 0, "judgment": 0, "illustration": 0, "new_gap": 0,
             "missing_rules": [], "missing_files": []}
    for lid in sorted(per):
        d = per[lid]
        info = tags.get(lid)
        if info is None:
            stats["missing_files"].append(lid)
        info = info or {"path": "(no file found)", "title": lesson_titles.get(lid, lid),
                        "exams": []}
        used = set()
        out = ["# Brief: %s" % info["title"], "",
               "Lesson id: `%s`" % lid,
               "Lesson path: `%s`" % info["path"], "",
               "Tagged exams: %s" % (", ".join(info["exams"]) or "(none)"),
               "",
               "Rule: a rewrite may add CSE cases but never removes a case another "
               "tagged exam needs.", ""]

        out += ["## Fix these", ""]
        reals = sorted(d["real"], key=tkey)
        if not reals:
            out += ["None.", ""]
        for i, r in enumerate(reals, 1):
            used.update(rule_ids(r["rule"]))
            out += ["### %d. `%s`" % (i, r["id"]),
                    "- Rule: %s" % r["rule"],
                    "- Fix size: %s" % (r.get("fix") or "unspecified"),
                    "- Quote:", quote_block(r.get("quote")),
                    "- Problem: %s" % r["problem"],
                    "- Triage reason: %s" % r["reason"], ""]
            stats["real"] += 1

        out += ["## CSE teaching to add", ""]
        gl = sorted(d["gaps"], key=lambda kg: gkey(kg[1]))
        if not gl:
            out += ["None.", ""]
        for i, (kind, g) in enumerate(gl, 1):
            flags = []
            if kind == "filipino":
                flags.append("FILIPINO SECTION")
            if g.get("tier") == "weak":
                flags.append("weak tier: add only if it fits")
            out += ["### %d. `%s`%s" % (i, g["key"],
                                         " [%s]" % "; ".join(flags) if flags else ""),
                    "- Facet: %s" % g["facet"],
                    "- Verdict: %s" % g["verdict"],
                    "- Tier: %s" % g.get("tier", ""),
                    "- Missing ideas:"]
            out += ["  - %s" % m for m in g.get("missing", [])] or ["  - (none listed)"]
            out.append("")
            stats["gap"] += 1

        out += ["## Optional, fix only if editing that passage anyway", ""]
        js = sorted(d["judgment"], key=lambda r: natural_key(r["id"]))
        if not js:
            out += ["None.", ""]
        for r in js:
            used.update(rule_ids(r["rule"]))
            out += ["- `%s` (%s): %s Reason: %s" % (r["id"], r["rule"], r["problem"],
                                                    r["reason"])]
            stats["judgment"] += 1
        if js:
            out.append("")

        out += ["## Figures", ""]
        fs = sorted(d["illustration"], key=lambda r: natural_key(r["id"]))
        if not fs:
            out += ["None.", ""]
        for r in fs:
            used.update(rule_ids(r["rule"]))
            out += ["### `%s` (%s)" % (r["id"], r["rule"]),
                    "- Quote:", quote_block(r.get("quote")),
                    "- Problem: %s" % r["problem"],
                    "- Triage reason: %s" % r["reason"], ""]
            stats["illustration"] += 1

        out += ["## Rules cited", ""]
        cited = sorted(used, key=natural_key)
        if not cited:
            out += ["None.", ""]
        for rid in cited:
            if rid in rules:
                out.append(rules[rid])
            else:
                out.append("%s: no row in the checklist" % rid)
                if rid not in stats["missing_rules"]:
                    stats["missing_rules"].append(rid)
        if cited:
            out.append("")
        briefs[lid] = "\n".join(out).rstrip("\n") + "\n"

    nl = ["# New lessons", "",
          "Gap rows placed as a new lesson, grouped by proposed title.", ""]
    if not new_groups:
        nl += ["None.", ""]
    for title in sorted(new_groups):
        nl += ["## %s" % title, ""]
        for g in sorted(new_groups[title], key=gkey):
            tier = g.get("tier", "")
            note = " (weak tier: add only if it fits)" if tier == "weak" else ""
            nl += ["- `%s`%s: %s (%s, %s)" % (g["key"], note, g["facet"], g["verdict"], tier)]
            nl += ["  - Missing: %s" % m for m in g.get("missing", [])]
            stats["new_gap"] += 1
        nl.append("")
    stats["skipped_gaps"] = len(skipped_gaps)
    return briefs, "\n".join(nl).rstrip("\n") + "\n", stats


def load_tags(tags_path, worktree):
    with open(tags_path, encoding="utf-8") as f:
        data = json.load(f)
    tags = {}
    for les in data["lessons"]:
        tags[les["metadata__id"]] = {
            "path": les["path"],
            "title": les.get("metadata_title") or les["metadata__id"],
            "exams": list(les.get("provisionalExamTags") or []),
        }
    # Lessons added to the CSE scope on October 25 after the accepted exam maps; their map tags
    # predate the addition (see the audit branch status.md and cse-professional map note).
    for lesson_id, exams in CSE_ADDED.items():
        if lesson_id in tags:
            tags[lesson_id]["exams"] += [e for e in exams if e not in tags[lesson_id]["exams"]]
    return tags


CSE_ADDED = {
    "lesson-spatial-abstract-reasoning-figure-grouping": ["cse-professional"],
    "lesson-spatial-abstract-reasoning-figure-matrices": ["cse-professional"],
    "lesson-spatial-abstract-reasoning-figure-series": ["cse-professional"],
    "lesson-spatial-abstract-reasoning-mental-rotation-3d-visualization": ["cse-professional"],
    "lesson-spatial-abstract-reasoning-paper-folding-and-cutting": ["cse-professional"],
    "lesson-comprehension-skills-choosing-a-title": ["cse-professional", "cse-subprofessional"],
    "lesson-comprehension-skills-fact-vs-opinion": ["cse-professional", "cse-subprofessional"],
}


def write_all(briefs, new_md, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    keep = set(lid + ".md" for lid in briefs) | {"new-lessons.md"}
    for p in glob.glob(os.path.join(out_dir, "*.md")):
        if os.path.basename(p) not in keep:
            os.remove(p)
    for lid, text in briefs.items():
        with open(os.path.join(out_dir, lid + ".md"), "w", encoding="utf-8") as f:
            f.write(text)
    with open(os.path.join(out_dir, "new-lessons.md"), "w", encoding="utf-8") as f:
        f.write(new_md)


def git_show(path):
    return subprocess.check_output(
        ["git", "-C", REPO, "show", "origin/main:" + path]).decode("utf-8")


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--triage", default=DEFAULT_TRIAGE)
    ap.add_argument("--gaps", default=DEFAULT_GAPS)
    ap.add_argument("--tags", default=DEFAULT_TAGS)
    ap.add_argument("--worktree", default=WORKTREE)
    ap.add_argument("--out", default=None)
    a = ap.parse_args(argv)
    out_dir = a.out or os.path.join(a.worktree, OUT_DIR)
    rules = parse_checklist(git_show("docs/content/content-checklist.md"))
    tags = load_tags(a.tags, a.worktree)
    briefs, new_md, stats = build_briefs(read_jsonl(a.triage), read_jsonl(a.gaps),
                                         tags, rules)
    no_file = sorted(lid for lid in briefs
                     if lid not in tags or
                     not os.path.exists(os.path.join(a.worktree, tags[lid]["path"])))
    write_all(briefs, new_md, out_dir)
    print("briefs: %d" % len(briefs))
    print("real: %d gap: %d judgment: %d illustration: %d new-lesson gaps: %d "
          "skipped gaps: %d" % (stats["real"], stats["gap"], stats["judgment"],
                                stats["illustration"], stats["new_gap"],
                                stats["skipped_gaps"]))
    print("rules missing from checklist: %s" % (stats["missing_rules"] or "none"))
    print("lessons with no file: %s" % (no_file or "none"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
