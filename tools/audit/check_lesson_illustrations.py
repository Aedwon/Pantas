#!/usr/bin/env python3
"""Audit and verification tool for lesson illustration strategies and markers.

Phases:
  inventory: validates strategy.tsv against worklist.tsv and asserts exact approved totals
             (total=279 code=241 open=4 native=23 cut=8 founder=3).
  complete:  asserts full implementation state (241 valid FIGURE markers, 7 remaining
             ILLUSTRATION markers, 7 PNG slots on disk, 0 native/cut markers remaining).

Usage:
  python3 tools/audit/check_lesson_illustrations.py --phase inventory
  python3 tools/audit/check_lesson_illustrations.py --phase complete
"""

import argparse
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEFAULT_STRATEGY = os.path.join(ROOT, "docs", "content", "illustrations", "strategy.tsv")
DEFAULT_WORKLIST = os.path.join(ROOT, "docs", "content", "illustrations", "worklist.tsv")
DEFAULT_LESSONS = os.path.join(ROOT, "content", "lessons")
DEFAULT_ILLUSTRATIONS = os.path.join(ROOT, "content", "illustrations")

EXPECTED_TOTALS = {
    "code": 241,
    "open": 4,
    "native": 23,
    "cut": 8,
    "founder": 3,
}
TOTAL_EXPECTED = 279
VALID_STRATEGIES = set(EXPECTED_TOTALS.keys())

FIGURE_MARKER = re.compile(r"<!--\s*FIGURE:\s*(\{.*?\})\s*-->")
ILLUSTRATION_MARKER = re.compile(r"<!--\s*ILLUSTRATION:\s*(.*?)\s*-->")

KNOWN_FIGURE_KINDS = {
    "gear-train",
    "spring-scale",
    "lever-balance",
    "pulley-system",
    "fluid-vessel",
    "stability-shape",
    "shape-row",
    "coordinate-graph",
    "geometry-diagram",
    "chart",
    "concept-diagram",
    "figure-matrix",
    "figure-series",
    "cube-net",
    "paper-fold",
    "venn-diagram",
    "reading-diagram",
    "biology-diagram",
    "chemistry-diagram",
    "earth-science-diagram",
    "physics-mechanics-diagram",
    "physics-energy-diagram",
}


def make_key(subject: str, topic: str, lesson: str, seq: str) -> str:
    if topic:
        return f"{subject}/{topic}/{lesson}#{seq}"
    return f"{subject}/{lesson}#{seq}"


def check_inventory(strategy_path: str, worklist_path: str) -> dict:
    if not os.path.isfile(strategy_path):
        sys.stderr.write(f"Error: strategy file not found: {strategy_path}\n")
        sys.exit(1)

    strategy_rows = []
    seen_keys = set()
    counts = {s: 0 for s in VALID_STRATEGIES}

    with open(strategy_path, "r", encoding="utf-8") as f:
        header_line = f.readline()
        if not header_line:
            sys.stderr.write("Error: strategy file is empty\n")
            sys.exit(1)
        headers = [h.strip() for h in header_line.split("\t")]
        expected_headers = ["subject", "topic", "lesson", "seq", "target_file", "description", "strategy", "batch"]
        if headers != expected_headers:
            sys.stderr.write(f"Error: strategy header mismatch. Expected {expected_headers}, got {headers}\n")
            sys.exit(1)

        for line_num, line in enumerate(f, start=2):
            line = line.strip()
            if not line:
                continue
            parts = line.split("\t")
            if len(parts) != len(expected_headers):
                sys.stderr.write(f"Error: invalid column count on line {line_num} of {strategy_path}\n")
                sys.exit(1)

            subject, topic, lesson, seq, target_file, desc, strategy, batch = parts
            key = make_key(subject, topic, lesson, seq)

            if key in seen_keys:
                sys.stderr.write(f"Error: duplicate key found in strategy: {key}\n")
                sys.exit(1)
            seen_keys.add(key)

            if strategy not in VALID_STRATEGIES:
                sys.stderr.write(f"Error: unknown strategy '{strategy}' for key {key}\n")
                sys.exit(1)

            counts[strategy] += 1
            strategy_rows.append({
                "subject": subject,
                "topic": topic,
                "lesson": lesson,
                "seq": seq,
                "target_file": target_file,
                "description": desc,
                "strategy": strategy,
                "batch": batch,
                "key": key,
            })

    total = sum(counts.values())

    # Check worklist containment if worklist exists
    if os.path.isfile(worklist_path):
        with open(worklist_path, "r", encoding="utf-8") as f:
            wl_header = f.readline()
            for line_num, line in enumerate(f, start=2):
                line = line.strip()
                if not line:
                    continue
                parts = line.split("\t")
                if len(parts) < 4:
                    continue
                wl_subject, wl_topic, wl_lesson, wl_seq = parts[0], parts[1], parts[2], parts[3]
                wl_key = make_key(wl_subject, wl_topic, wl_lesson, wl_seq)
                if wl_key not in seen_keys:
                    sys.stderr.write(f"Error: missing key in strategy manifest: {wl_key}\n")
                    sys.exit(1)

    if total != TOTAL_EXPECTED or counts != EXPECTED_TOTALS:
        sys.stderr.write(
            f"Error: total count mismatch. Expected total={TOTAL_EXPECTED} {EXPECTED_TOTALS}, "
            f"got total={total} {counts}\n"
        )
        sys.exit(1)

    print(
        f"total={total} code={counts['code']} open={counts['open']} "
        f"native={counts['native']} cut={counts['cut']} founder={counts['founder']}"
    )
    return {"rows": strategy_rows, "counts": counts, "keys": seen_keys}


def check_complete(strategy_path: str, worklist_path: str, lessons_dir: str, illustrations_dir: str):
    inv = check_inventory(strategy_path, worklist_path)
    strategy_by_key = {r["key"]: r for r in inv["rows"]}

    strategy_by_lesson = {}
    for r in inv["rows"]:
        lesson_key = (
            f"{r['subject']}/{r['topic']}/{r['lesson']}"
            if r["topic"]
            else f"{r['subject']}/{r['lesson']}"
        )
        strategy_by_lesson.setdefault(lesson_key, []).append(r)

    if not os.path.isdir(lessons_dir):
        sys.stderr.write(f"Error: lessons directory not found: {lessons_dir}\n")
        sys.exit(1)

    lesson_figures = {}
    lesson_illustrations = {}
    all_figure_markers = []
    all_illustration_markers = []
    unrecognized_kinds = []
    json_errors = []

    for dirpath, _, filenames in os.walk(lessons_dir):
        for fn in sorted(filenames):
            if not fn.endswith(".md"):
                continue
            path = os.path.join(dirpath, fn)
            rel = os.path.relpath(path, lessons_dir)
            parts = rel.split(os.sep)
            subject = parts[0]
            topic = parts[1] if len(parts) > 2 else ""
            lesson = os.path.splitext(parts[-1])[0]
            lesson_key = f"{subject}/{topic}/{lesson}" if topic else f"{subject}/{lesson}"

            with open(path, "r", encoding="utf-8") as f:
                content = f.read()

            for lineno, line in enumerate(content.splitlines(), start=1):
                f_match = FIGURE_MARKER.search(line)
                if f_match:
                    raw_json = f_match.group(1)
                    try:
                        spec = json.loads(raw_json)
                    except Exception as e:
                        json_errors.append((path, lineno, str(e)))
                        continue

                    kind = spec.get("kind")
                    if not kind or kind not in KNOWN_FIGURE_KINDS:
                        unrecognized_kinds.append((path, lineno, kind))
                    lesson_figures.setdefault(lesson_key, []).append((lineno, spec))
                    all_figure_markers.append((subject, topic, lesson, path, lineno, spec))

                i_match = ILLUSTRATION_MARKER.search(line)
                if i_match:
                    desc = i_match.group(1).strip()
                    lesson_illustrations.setdefault(lesson_key, []).append((lineno, desc))
                    all_illustration_markers.append((subject, topic, lesson, path, lineno, desc))

    if json_errors:
        for path, lineno, err in json_errors:
            sys.stderr.write(f"Error: invalid FIGURE JSON at {path}:{lineno}: {err}\n")
        sys.exit(1)

    if unrecognized_kinds:
        for path, lineno, kind in unrecognized_kinds:
            sys.stderr.write(f"Error: unrecognized figure kind '{kind}' at {path}:{lineno}\n")
        sys.exit(1)

    errors = []

    # Check global FIGURE markers total
    if len(all_figure_markers) != EXPECTED_TOTALS["code"]:
        errors.append(
            f"Error: expected {EXPECTED_TOTALS['code']} valid FIGURE markers, "
            f"found {len(all_figure_markers)}"
        )

    # Check global ILLUSTRATION markers total (4 open + 3 founder = 7)
    expected_illustrations = EXPECTED_TOTALS["open"] + EXPECTED_TOTALS["founder"]
    if len(all_illustration_markers) != expected_illustrations:
        errors.append(
            f"Error: expected {expected_illustrations} remaining ILLUSTRATION markers, "
            f"found {len(all_illustration_markers)}"
        )

    # Lesson-level validation
    all_lesson_keys = sorted(
        set(strategy_by_lesson.keys())
        | set(lesson_figures.keys())
        | set(lesson_illustrations.keys())
    )

    for lk in all_lesson_keys:
        rows = strategy_by_lesson.get(lk, [])
        planned_code = [r for r in rows if r["strategy"] == "code"]
        planned_open_founder = [r for r in rows if r["strategy"] in ("open", "founder")]
        planned_native_cut = [r for r in rows if r["strategy"] in ("native", "cut")]

        actual_figs = lesson_figures.get(lk, [])
        actual_illus = lesson_illustrations.get(lk, [])
        actual_illus_descs = [desc for _, desc in actual_illus]

        # 1. Lesson-level FIGURE count
        if len(actual_figs) != len(planned_code):
            errors.append(
                f"Error in {lk}: expected {len(planned_code)} code FIGURE markers, "
                f"found {len(actual_figs)}"
            )

        # 2. Native or cut markers remaining
        native_cut_descs = {r["description"].strip() for r in planned_native_cut}
        for desc in actual_illus_descs:
            if desc in native_cut_descs:
                errors.append(
                    f"Error in {lk}: native/cut illustration marker remained: {desc}"
                )

        # 3. Unexpected illustration markers
        open_founder_descs = [r["description"].strip() for r in planned_open_founder]
        open_founder_set = set(open_founder_descs)
        for desc in actual_illus_descs:
            if desc not in open_founder_set and desc not in native_cut_descs:
                errors.append(
                    f"Error in {lk}: unexpected illustration marker: {desc}"
                )

        # 4. Missing open or founder markers
        for exp_desc in open_founder_descs:
            if exp_desc not in actual_illus_descs:
                errors.append(
                    f"Error in {lk}: missing planned open/founder illustration marker: {exp_desc}"
                )

    if errors:
        for err in errors:
            sys.stderr.write(f"{err}\n")
        sys.exit(1)

    # Check exact PNG assets exist for all open and founder rows
    missing_pngs = []
    for r in inv["rows"]:
        if r["strategy"] in ("open", "founder"):
            target_rel = r["target_file"]
            if target_rel.startswith("content/illustrations/"):
                subpath = os.path.relpath(target_rel, "content/illustrations")
                target_path = os.path.join(illustrations_dir, subpath)
            else:
                target_path = os.path.join(illustrations_dir, target_rel)

            if not os.path.isfile(target_path):
                missing_pngs.append(r["target_file"])

    if missing_pngs:
        sys.stderr.write(f"Error: {len(missing_pngs)} missing PNG targets:\n")
        for p in missing_pngs[:10]:
            sys.stderr.write(f"  {p}\n")
        sys.exit(1)

    print(
        f"complete: {EXPECTED_TOTALS['code']} valid figures, {expected_illustrations} illustrations "
        f"({expected_illustrations} pngs), 0 native/cut markers remaining"
    )


def main():
    parser = argparse.ArgumentParser(description="Check lesson illustration inventory and complete state.")
    parser.add_argument(
        "--phase",
        required=True,
        choices=["inventory", "complete"],
        help="Check phase: inventory or complete",
    )
    parser.add_argument(
        "--strategy",
        default=DEFAULT_STRATEGY,
        help="Path to strategy.tsv",
    )
    parser.add_argument(
        "--worklist",
        default=DEFAULT_WORKLIST,
        help="Path to worklist.tsv",
    )
    parser.add_argument(
        "--lessons",
        default=DEFAULT_LESSONS,
        help="Path to content/lessons directory",
    )
    parser.add_argument(
        "--illustrations",
        default=DEFAULT_ILLUSTRATIONS,
        help="Path to content/illustrations directory",
    )

    args = parser.parse_args()

    if args.phase == "inventory":
        check_inventory(args.strategy, args.worklist)
    elif args.phase == "complete":
        check_complete(args.strategy, args.worklist, args.lessons, args.illustrations)


if __name__ == "__main__":
    main()
