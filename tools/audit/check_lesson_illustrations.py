#!/usr/bin/env python3
"""Audit lesson illustration inventory, review readiness, and completion.

Phases:
  inventory:    validates strategy.tsv against worklist.tsv and asserts the
                approved 279-row breakdown.
  review-ready: preserves the lesson-marker checks, requires the 52 current
                two-theme code previews and four verified Commons PNGs, and
                reports missing founder PNGs without failing.
  complete:     requires all review-ready inputs, all three founder PNGs, and
                an approved review record bound to every current visual digest.
"""

import argparse
import hashlib
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEFAULT_STRATEGY = os.path.join(ROOT, "docs", "content", "illustrations", "strategy.tsv")
DEFAULT_WORKLIST = os.path.join(ROOT, "docs", "content", "illustrations", "worklist.tsv")
DEFAULT_LESSONS = os.path.join(ROOT, "content", "lessons")
DEFAULT_ILLUSTRATIONS = os.path.join(ROOT, "content", "illustrations")
DEFAULT_PREVIEWS = os.path.join(ROOT, "build", "lesson_author", "illustration_previews")
DEFAULT_REVIEW = os.path.join(ROOT, "docs", "content", "illustrations", "review.json")
COMMONS_MANIFESTS = (
    os.path.join(ROOT, "content", "illustrations", "sources", "open-a.yaml"),
    os.path.join(ROOT, "content", "illustrations", "sources", "open-b.yaml"),
)

EXPECTED_TOTALS = {
    "code": 241,
    "open": 4,
    "native": 23,
    "cut": 8,
    "founder": 3,
}
TOTAL_EXPECTED = 279
VALID_STRATEGIES = set(EXPECTED_TOTALS.keys())
REVIEW_BATCHES = {"original-code-a", "original-code-b"}
EXPECTED_REVIEW_COUNTS = {"code": 52, "open": 4, "founder": 3}
REVIEW_TOTAL_EXPECTED = 59
VALID_REVIEW_STATUSES = {"pending", "approved", "changes-requested"}
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")

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


def fail(message: str) -> None:
    sys.stderr.write(f"{message}\n")
    raise SystemExit(1)


def make_key(subject: str, topic: str, lesson: str, seq: str) -> str:
    if topic:
        return f"{subject}/{topic}/{lesson}#{seq}"
    return f"{subject}/{lesson}#{seq}"


def check_inventory(strategy_path: str, worklist_path: str) -> dict:
    if not os.path.isfile(strategy_path):
        fail(f"Error: strategy file not found: {strategy_path}")

    strategy_rows = []
    seen_keys = set()
    counts = {s: 0 for s in VALID_STRATEGIES}

    with open(strategy_path, "r", encoding="utf-8") as f:
        header_line = f.readline()
        if not header_line:
            fail("Error: strategy file is empty")
        headers = [h.strip() for h in header_line.split("\t")]
        expected_headers = [
            "subject",
            "topic",
            "lesson",
            "seq",
            "target_file",
            "description",
            "strategy",
            "batch",
        ]
        if headers != expected_headers:
            fail(
                f"Error: strategy header mismatch. Expected {expected_headers}, got {headers}"
            )

        for line_num, line in enumerate(f, start=2):
            line = line.strip()
            if not line:
                continue
            parts = line.split("\t")
            if len(parts) != len(expected_headers):
                fail(
                    f"Error: invalid column count on line {line_num} of {strategy_path}"
                )

            subject, topic, lesson, seq, target_file, desc, strategy, batch = parts
            key = make_key(subject, topic, lesson, seq)

            if key in seen_keys:
                fail(f"Error: duplicate key found in strategy: {key}")
            seen_keys.add(key)

            if strategy not in VALID_STRATEGIES:
                fail(f"Error: unknown strategy '{strategy}' for key {key}")

            counts[strategy] += 1
            strategy_rows.append(
                {
                    "subject": subject,
                    "topic": topic,
                    "lesson": lesson,
                    "seq": seq,
                    "target_file": target_file,
                    "description": desc,
                    "strategy": strategy,
                    "batch": batch,
                    "key": key,
                }
            )

    total = sum(counts.values())

    if os.path.isfile(worklist_path):
        with open(worklist_path, "r", encoding="utf-8") as f:
            f.readline()
            for line in f:
                line = line.strip()
                if not line:
                    continue
                parts = line.split("\t")
                if len(parts) < 4:
                    continue
                wl_key = make_key(parts[0], parts[1], parts[2], parts[3])
                if wl_key not in seen_keys:
                    fail(f"Error: missing key in strategy manifest: {wl_key}")

    if total != TOTAL_EXPECTED or counts != EXPECTED_TOTALS:
        fail(
            f"Error: total count mismatch. Expected total={TOTAL_EXPECTED} "
            f"{EXPECTED_TOTALS}, got total={total} {counts}"
        )

    print(
        f"total={total} code={counts['code']} open={counts['open']} "
        f"native={counts['native']} cut={counts['cut']} founder={counts['founder']}"
    )
    return {"rows": strategy_rows, "counts": counts, "keys": seen_keys}


def check_lesson_marker_state(inv: dict, lessons_dir: str) -> int:
    strategy_by_lesson = {}
    for row in inv["rows"]:
        lesson_key = (
            f"{row['subject']}/{row['topic']}/{row['lesson']}"
            if row["topic"]
            else f"{row['subject']}/{row['lesson']}"
        )
        strategy_by_lesson.setdefault(lesson_key, []).append(row)

    if not os.path.isdir(lessons_dir):
        fail(f"Error: lessons directory not found: {lessons_dir}")

    lesson_figures = {}
    lesson_illustrations = {}
    all_figure_markers = []
    all_illustration_markers = []
    unrecognized_kinds = []
    json_errors = []

    for dirpath, _, filenames in os.walk(lessons_dir):
        for filename in sorted(filenames):
            if not filename.endswith(".md"):
                continue
            path = os.path.join(dirpath, filename)
            rel = os.path.relpath(path, lessons_dir)
            parts = rel.split(os.sep)
            subject = parts[0]
            topic = parts[1] if len(parts) > 2 else ""
            lesson = os.path.splitext(parts[-1])[0]
            lesson_key = (
                f"{subject}/{topic}/{lesson}" if topic else f"{subject}/{lesson}"
            )

            with open(path, "r", encoding="utf-8") as f:
                content = f.read()

            for lineno, line in enumerate(content.splitlines(), start=1):
                figure_match = FIGURE_MARKER.search(line)
                if figure_match:
                    try:
                        spec = json.loads(figure_match.group(1))
                    except Exception as exc:
                        json_errors.append((path, lineno, str(exc)))
                        continue
                    if not isinstance(spec, dict):
                        json_errors.append((path, lineno, "FIGURE JSON must be an object"))
                        continue
                    kind = spec.get("kind")
                    if not kind or kind not in KNOWN_FIGURE_KINDS:
                        unrecognized_kinds.append((path, lineno, kind))
                    lesson_figures.setdefault(lesson_key, []).append((lineno, spec))
                    all_figure_markers.append((path, lineno, spec))

                illustration_match = ILLUSTRATION_MARKER.search(line)
                if illustration_match:
                    desc = illustration_match.group(1).strip()
                    lesson_illustrations.setdefault(lesson_key, []).append(
                        (lineno, desc)
                    )
                    all_illustration_markers.append((path, lineno, desc))

    if json_errors:
        for path, lineno, error in json_errors:
            sys.stderr.write(
                f"Error: invalid FIGURE JSON at {path}:{lineno}: {error}\n"
            )
        raise SystemExit(1)

    if unrecognized_kinds:
        for path, lineno, kind in unrecognized_kinds:
            sys.stderr.write(
                f"Error: unrecognized figure kind '{kind}' at {path}:{lineno}\n"
            )
        raise SystemExit(1)

    errors = []
    if len(all_figure_markers) != EXPECTED_TOTALS["code"]:
        errors.append(
            f"Error: expected {EXPECTED_TOTALS['code']} valid FIGURE markers, "
            f"found {len(all_figure_markers)}"
        )

    expected_illustrations = EXPECTED_TOTALS["open"] + EXPECTED_TOTALS["founder"]
    if len(all_illustration_markers) != expected_illustrations:
        errors.append(
            f"Error: expected {expected_illustrations} remaining ILLUSTRATION markers, "
            f"found {len(all_illustration_markers)}"
        )

    all_lesson_keys = sorted(
        set(strategy_by_lesson.keys())
        | set(lesson_figures.keys())
        | set(lesson_illustrations.keys())
    )
    for lesson_key in all_lesson_keys:
        rows = strategy_by_lesson.get(lesson_key, [])
        planned_code = [row for row in rows if row["strategy"] == "code"]
        planned_open_founder = [
            row for row in rows if row["strategy"] in ("open", "founder")
        ]
        planned_native_cut = [
            row for row in rows if row["strategy"] in ("native", "cut")
        ]
        actual_figs = lesson_figures.get(lesson_key, [])
        actual_illustrations = lesson_illustrations.get(lesson_key, [])
        actual_descriptions = [desc for _, desc in actual_illustrations]

        if len(actual_figs) != len(planned_code):
            errors.append(
                f"Error in {lesson_key}: expected {len(planned_code)} code "
                f"FIGURE markers, found {len(actual_figs)}"
            )

        native_cut_descriptions = {
            row["description"].strip() for row in planned_native_cut
        }
        for desc in actual_descriptions:
            if desc in native_cut_descriptions:
                errors.append(
                    f"Error in {lesson_key}: native/cut illustration marker remained: {desc}"
                )

        open_founder_descriptions = [
            row["description"].strip() for row in planned_open_founder
        ]
        open_founder_set = set(open_founder_descriptions)
        for desc in actual_descriptions:
            if desc not in open_founder_set and desc not in native_cut_descriptions:
                errors.append(
                    f"Error in {lesson_key}: unexpected illustration marker: {desc}"
                )

        for expected_desc in open_founder_descriptions:
            if expected_desc not in actual_descriptions:
                errors.append(
                    f"Error in {lesson_key}: missing planned open/founder "
                    f"illustration marker: {expected_desc}"
                )

    if errors:
        for error in errors:
            sys.stderr.write(f"{error}\n")
        raise SystemExit(1)

    return expected_illustrations


def build_review_catalog(inv: dict) -> dict:
    code_rows = [row for row in inv["rows"] if row["batch"] in REVIEW_BATCHES]
    open_rows = [row for row in inv["rows"] if row["strategy"] == "open"]
    founder_rows = [row for row in inv["rows"] if row["strategy"] == "founder"]

    if any(row["strategy"] != "code" for row in code_rows):
        fail("Error: original-code review batches contain a non-code strategy row")

    counts = {
        "code": len(code_rows),
        "open": len(open_rows),
        "founder": len(founder_rows),
    }
    if counts != EXPECTED_REVIEW_COUNTS:
        fail(
            f"Error: review catalog count mismatch. Expected {EXPECTED_REVIEW_COUNTS}, "
            f"got {counts}"
        )

    rows = code_rows + open_rows + founder_rows
    keys = {row["key"] for row in rows}
    if len(rows) != REVIEW_TOTAL_EXPECTED or len(keys) != REVIEW_TOTAL_EXPECTED:
        fail(
            f"Error: expected {REVIEW_TOTAL_EXPECTED} unique review keys, "
            f"found {len(keys)}"
        )

    return {
        "rows": rows,
        "code": code_rows,
        "open": open_rows,
        "founder": founder_rows,
        "keys": keys,
    }


def safe_relative_path(root: str, relative_path: str, label: str) -> str:
    if not isinstance(relative_path, str) or not relative_path:
        fail(f"Error: invalid {label} path")
    if os.path.isabs(relative_path) or re.match(r"^[A-Za-z]:[\\/]", relative_path):
        fail(f"Error: invalid absolute {label} path: {relative_path}")
    segments = re.split(r"[\\/]", relative_path)
    if ".." in segments:
        fail(f"Error: {label} traversal is not allowed: {relative_path}")
    clean_segments = [segment for segment in segments if segment not in ("", ".")]
    if not clean_segments:
        fail(f"Error: invalid {label} path: {relative_path}")
    normalized = os.path.join(*clean_segments)
    resolved_root = os.path.realpath(root)
    candidate = os.path.realpath(os.path.join(resolved_root, normalized))
    try:
        inside = os.path.commonpath([resolved_root, candidate]) == resolved_root
    except ValueError:
        inside = False
    if not inside or candidate == resolved_root:
        fail(f"Error: {label} path escapes its allowed root: {relative_path}")
    return candidate


def resolve_asset_path(illustrations_dir: str, target_file: str) -> str:
    prefix = "content/illustrations/"
    relative_path = (
        target_file[len(prefix) :] if target_file.startswith(prefix) else target_file
    )
    return safe_relative_path(illustrations_dir, relative_path, "illustration target")


def sha256_file(path: str) -> str:
    digest = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def combined_preview_digest(light_path: str, dark_path: str) -> str:
    light_hash = sha256_file(light_path)
    dark_hash = sha256_file(dark_path)
    return hashlib.sha256(f"{light_hash}:{dark_hash}".encode("utf-8")).hexdigest()


def load_preview_digests(previews_dir: str, expected_keys: set[str]) -> dict[str, str]:
    manifest_path = os.path.join(previews_dir, "manifest.json")
    if not os.path.isfile(manifest_path):
        fail(f"Error: preview manifest not found: {manifest_path}")
    try:
        with open(manifest_path, "r", encoding="utf-8") as f:
            parsed = json.load(f)
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"Error: Invalid preview manifest: {exc}")

    if (
        not isinstance(parsed, dict)
        or parsed.get("version") != 1
        or not isinstance(parsed.get("items"), list)
    ):
        fail("Error: Invalid preview manifest shape")

    entries = {}
    for entry in parsed["items"]:
        if not isinstance(entry, dict):
            fail("Error: Invalid preview manifest entry")
        key = entry.get("key")
        light_rel = entry.get("lightPath")
        dark_rel = entry.get("darkPath")
        stored_digest = entry.get("digest")
        if (
            not isinstance(key, str)
            or not isinstance(light_rel, str)
            or not isinstance(dark_rel, str)
            or not isinstance(stored_digest, str)
            or not SHA256_RE.fullmatch(stored_digest)
        ):
            fail("Error: Invalid preview manifest entry")
        if key in entries:
            fail(f"Error: duplicate preview key: {key}")
        light_path = safe_relative_path(previews_dir, light_rel, "preview")
        dark_path = safe_relative_path(previews_dir, dark_rel, "preview")
        entries[key] = (light_path, dark_path)

    actual_keys = set(entries)
    missing = sorted(expected_keys - actual_keys)
    unknown = sorted(actual_keys - expected_keys)
    if missing or unknown or len(entries) != EXPECTED_REVIEW_COUNTS["code"]:
        details = []
        if missing:
            details.append(f"missing={missing}")
        if unknown:
            details.append(f"unknown={unknown}")
        fail(
            f"Error: expected {EXPECTED_REVIEW_COUNTS['code']} code preview entries "
            f"for the exact review keys; {'; '.join(details)}"
        )

    digests = {}
    for key in sorted(expected_keys):
        light_path, dark_path = entries[key]
        if not os.path.isfile(light_path):
            fail(f"Error: missing light preview PNG for {key}: {light_path}")
        if not os.path.isfile(dark_path):
            fail(f"Error: missing dark preview PNG for {key}: {dark_path}")
        digests[key] = combined_preview_digest(light_path, dark_path)
    return digests


def yaml_scalar(raw: str):
    value = raw.strip()
    if not value:
        return ""
    if value[0] in ('"', "'"):
        try:
            if value[0] == '"':
                return json.loads(value)
            if value.endswith("'"):
                return value[1:-1].replace("''", "'")
        except json.JSONDecodeError:
            pass
    return value


def load_commons_manifests() -> dict:
    assets = {}
    required_fields = {
        "key",
        "sourcePage",
        "directUrl",
        "license",
        "creator",
        "credit",
        "target",
        "sha256",
    }
    for path in COMMONS_MANIFESTS:
        if not os.path.isfile(path):
            fail(f"Error: Commons manifest not found: {path}")
        version = None
        current = None
        parsed_assets = []
        with open(path, "r", encoding="utf-8") as f:
            for raw_line in f:
                stripped = raw_line.strip()
                if not stripped or stripped.startswith("#"):
                    continue
                if stripped.startswith("version:"):
                    version = yaml_scalar(stripped.split(":", 1)[1])
                    continue
                if stripped == "assets:":
                    continue
                if stripped.startswith("- "):
                    if current is not None:
                        parsed_assets.append(current)
                    current = {}
                    field_line = stripped[2:]
                    if ":" in field_line:
                        field, raw_value = field_line.split(":", 1)
                        current[field.strip()] = yaml_scalar(raw_value)
                    continue
                if current is not None and ":" in stripped:
                    field, raw_value = stripped.split(":", 1)
                    current[field.strip()] = yaml_scalar(raw_value)
        if current is not None:
            parsed_assets.append(current)

        if str(version) != "1" or not parsed_assets:
            fail(f"Error: Invalid Commons manifest shape: {path}")
        for asset in parsed_assets:
            if any(
                field not in asset
                or not isinstance(asset[field], str)
                or not asset[field]
                for field in required_fields
            ):
                fail(f"Error: Invalid Commons entry in {path}")
            if not SHA256_RE.fullmatch(asset["sha256"]):
                fail(f"Error: Invalid Commons sha256 for {asset['key']}")
            if asset["key"] in assets:
                fail(f"Error: duplicate Commons key: {asset['key']}")
            assets[asset["key"]] = asset
    return assets


def load_review_state(review_path: str, known_keys: set[str]) -> dict:
    if not os.path.isfile(review_path):
        fail(f"Error: review JSON not found: {review_path}")
    try:
        with open(review_path, "r", encoding="utf-8") as f:
            parsed = json.load(f)
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"Error: Invalid review JSON: {exc}")

    if (
        not isinstance(parsed, dict)
        or parsed.get("version") != 1
        or not isinstance(parsed.get("items"), dict)
    ):
        fail("Error: Invalid review JSON shape")

    for key, item in parsed["items"].items():
        if key not in known_keys:
            fail(f"Error: Unknown review key: {key}")
        if (
            not isinstance(item, dict)
            or item.get("status") not in VALID_REVIEW_STATUSES
            or not isinstance(item.get("notes"), str)
            or not isinstance(item.get("reviewedDigest"), str)
            or not SHA256_RE.fullmatch(item["reviewedDigest"])
            or not isinstance(item.get("reviewedAt"), str)
        ):
            fail(f"Error: Invalid review state for {key}")
    return parsed["items"]


def collect_visual_digests(
    catalog: dict,
    illustrations_dir: str,
    previews_dir: str,
    founder_required: bool,
) -> tuple[dict[str, str], list[dict]]:
    code_keys = {row["key"] for row in catalog["code"]}
    digests = load_preview_digests(previews_dir, code_keys)

    commons = load_commons_manifests()
    open_keys = {row["key"] for row in catalog["open"]}
    commons_keys = set(commons)
    missing_commons = sorted(open_keys - commons_keys)
    unknown_commons = sorted(commons_keys - open_keys)
    if (
        missing_commons
        or unknown_commons
        or len(commons) != EXPECTED_REVIEW_COUNTS["open"]
    ):
        details = []
        if missing_commons:
            details.append(f"missing={missing_commons}")
        if unknown_commons:
            details.append(f"unknown={unknown_commons}")
        fail(
            f"Error: expected {EXPECTED_REVIEW_COUNTS['open']} exact Commons keys; "
            f"{'; '.join(details)}"
        )

    for row in catalog["open"]:
        source = commons[row["key"]]
        if source["target"] != row["target_file"]:
            fail(
                f"Error: Commons target mismatch for {row['key']}: "
                f"strategy={row['target_file']} manifest={source['target']}"
            )
        target_path = resolve_asset_path(illustrations_dir, row["target_file"])
        if not os.path.isfile(target_path):
            fail(f"Error: missing Commons PNG for {row['key']}: {row['target_file']}")
        digest = sha256_file(target_path)
        if digest != source["sha256"]:
            fail(
                f"Error: Commons digest mismatch for {row['key']}: "
                f"expected {source['sha256']}, got {digest}"
            )
        digests[row["key"]] = digest

    missing_founders = []
    for row in catalog["founder"]:
        target_path = resolve_asset_path(illustrations_dir, row["target_file"])
        if not os.path.isfile(target_path):
            missing_founders.append(row)
        else:
            digests[row["key"]] = sha256_file(target_path)

    if founder_required and missing_founders:
        sys.stderr.write(
            f"Error: {len(missing_founders)} missing Founder PNG targets:\n"
        )
        for row in missing_founders:
            sys.stderr.write(f"  {row['key']}: {row['target_file']}\n")
        raise SystemExit(1)

    return digests, missing_founders


def check_review_ready(
    strategy_path: str,
    worklist_path: str,
    lessons_dir: str,
    illustrations_dir: str,
    previews_dir: str,
    review_path: str,
) -> None:
    inv = check_inventory(strategy_path, worklist_path)
    check_lesson_marker_state(inv, lessons_dir)
    catalog = build_review_catalog(inv)
    load_review_state(review_path, catalog["keys"])
    digests, missing_founders = collect_visual_digests(
        catalog,
        illustrations_dir,
        previews_dir,
        founder_required=False,
    )

    expected_ready = EXPECTED_REVIEW_COUNTS["code"] + EXPECTED_REVIEW_COUNTS["open"]
    present_founders = EXPECTED_REVIEW_COUNTS["founder"] - len(missing_founders)
    if len(digests) != expected_ready + present_founders:
        fail("Error: review-ready digest collection count mismatch")

    for row in missing_founders:
        print(f"missing founder asset (allowed): {row['target_file']}")
    print(
        f"review-ready: {EXPECTED_REVIEW_COUNTS['code']} code previews ready, "
        f"{EXPECTED_REVIEW_COUNTS['open']} Commons assets ready, "
        f"{len(missing_founders)} founder assets missing (allowed)"
    )


def check_complete(
    strategy_path: str,
    worklist_path: str,
    lessons_dir: str,
    illustrations_dir: str,
    previews_dir: str,
    review_path: str,
) -> None:
    inv = check_inventory(strategy_path, worklist_path)
    expected_illustrations = check_lesson_marker_state(inv, lessons_dir)
    catalog = build_review_catalog(inv)
    review_items = load_review_state(review_path, catalog["keys"])
    digests, _ = collect_visual_digests(
        catalog,
        illustrations_dir,
        previews_dir,
        founder_required=True,
    )

    if len(digests) != REVIEW_TOTAL_EXPECTED:
        fail(
            f"Error: expected {REVIEW_TOTAL_EXPECTED} current visual digests, "
            f"found {len(digests)}"
        )

    errors = []
    for key in sorted(catalog["keys"]):
        saved = review_items.get(key)
        if saved is None:
            errors.append(f"Error: {key} is pending; no review state recorded")
            continue
        if saved["status"] != "approved":
            errors.append(
                f"Error: {key} review status is {saved['status']}; complete requires approved"
            )
            continue
        if saved["reviewedDigest"] != digests[key]:
            errors.append(
                f"Error: stale reviewed digest for {key}: "
                f"reviewed={saved['reviewedDigest']} current={digests[key]}"
            )

    if errors:
        for error in errors:
            sys.stderr.write(f"{error}\n")
        raise SystemExit(1)

    print(
        f"complete: {REVIEW_TOTAL_EXPECTED} current illustration digests approved; "
        f"{EXPECTED_TOTALS['code']} valid figures, {expected_illustrations} illustrations, "
        "0 native/cut markers remaining"
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Check lesson illustration inventory, review readiness, and completion."
    )
    parser.add_argument(
        "--phase",
        required=True,
        choices=["inventory", "review-ready", "complete"],
        help="Check phase: inventory, review-ready, or complete",
    )
    parser.add_argument(
        "--strategy", default=DEFAULT_STRATEGY, help="Path to strategy.tsv"
    )
    parser.add_argument(
        "--worklist", default=DEFAULT_WORKLIST, help="Path to worklist.tsv"
    )
    parser.add_argument(
        "--lessons", default=DEFAULT_LESSONS, help="Path to content/lessons directory"
    )
    parser.add_argument(
        "--illustrations",
        default=DEFAULT_ILLUSTRATIONS,
        help="Path to content/illustrations directory",
    )
    parser.add_argument(
        "--previews",
        default=DEFAULT_PREVIEWS,
        help="Path to generated illustration preview directory",
    )
    parser.add_argument(
        "--review",
        default=DEFAULT_REVIEW,
        help="Path to illustration review JSON",
    )

    args = parser.parse_args()
    if args.phase == "inventory":
        check_inventory(args.strategy, args.worklist)
    elif args.phase == "review-ready":
        check_review_ready(
            args.strategy,
            args.worklist,
            args.lessons,
            args.illustrations,
            args.previews,
            args.review,
        )
    else:
        check_complete(
            args.strategy,
            args.worklist,
            args.lessons,
            args.illustrations,
            args.previews,
            args.review,
        )


if __name__ == "__main__":
    main()
