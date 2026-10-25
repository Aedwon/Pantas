#!/usr/bin/env python3
"""Report question YAML scalars that YAML would read as the wrong type.

Checks choice text and one-line stem, explanation and rationale values.
Standard library only. Run as: python3 -I check_question_typing.py [paths]

Rules:
  1  unquoted, purely digits (read as a number)
  2  unquoted True/False/Yes/No/On/Off in any casing (read as a boolean)
  3  unquoted, contains ": " (read as a nested mapping)
  4  double-quoted, single backslash before a letter (read as an escape)

Exit code 0 when clean, 1 when any problem is found.
"""

import argparse
import re
import string
import sys
from pathlib import Path

DEFAULT_ROOT = "content/questions"
CHECKED_KEYS = ("text", "stem", "explanation", "rationale")
LINE_RE = re.compile(r"^\s*(?:-\s+)?(text|stem|explanation|rationale):[ \t]+(.*?)\s*$")
BLOCK_RE = re.compile(r"^\s*(?:-\s+)?[A-Za-z_][\w-]*:\s+[|>][-+0-9]*\s*(?:#.*)?$")
BOOL_WORDS = frozenset({"true", "false", "yes", "no", "on", "off"})
LETTERS = frozenset(string.ascii_letters)


def _closing_double(raw):
    """Return the index of the closing double quote, or -1."""
    i = 1
    while i < len(raw):
        if raw[i] == "\\":
            i += 2
            continue
        if raw[i] == '"':
            return i
        i += 1
    return -1


def _plain_value(raw):
    """Drop a trailing comment from an unquoted value."""
    match = re.search(r"\s#", raw)
    if match:
        raw = raw[: match.start()]
    return raw.rstrip()


def _has_single_backslash_escape(content):
    """True when a backslash starts an escape, not an already doubled pair."""
    i = 0
    while i < len(content) - 1:
        if content[i] == "\\":
            following = content[i + 1]
            if following == "\\":
                i += 2
                continue
            if following in LETTERS:
                return True
        i += 1
    return False


def rule_for_value(raw):
    """Return the rule number broken by a raw scalar, or None."""
    if not raw or raw[0] in "|>[{&!*'":
        return None
    if raw[0] == '"':
        end = _closing_double(raw)
        if end < 0:
            return None
        return 4 if _has_single_backslash_escape(raw[1:end]) else None
    value = _plain_value(raw)
    if re.fullmatch(r"[0-9]+", value):
        return 1
    if value.lower() in BOOL_WORDS:
        return 2
    if ": " in value:
        return 3
    return None


def find_problems(text):
    """Return (line number, rule, raw value) for each problem in YAML text."""
    problems = []
    block_indent = None
    for lineno, line in enumerate(text.splitlines(), 1):
        if block_indent is not None:
            if not line.strip():
                continue
            indent = len(line) - len(line.lstrip(" "))
            if indent > block_indent:
                continue
            block_indent = None
        if BLOCK_RE.match(line):
            stripped = line.lstrip(" ")
            block_indent = len(line) - len(stripped)
            if stripped.startswith("- "):
                block_indent += 2
            continue
        match = LINE_RE.match(line)
        if not match:
            continue
        raw = match.group(2)
        rule = rule_for_value(raw)
        if rule is not None:
            problems.append((lineno, rule, raw))
    return problems


def collect_files(paths):
    """Expand arguments into YAML files. Directories are searched recursively."""
    if not paths:
        paths = [DEFAULT_ROOT]
    files = []
    for entry in paths:
        path = Path(entry)
        if path.is_dir():
            files.extend(sorted(path.rglob("*.yaml")))
        else:
            files.append(path)
    return files


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[1])
    parser.add_argument("paths", nargs="*", help="YAML files or folders; default content/questions")
    args = parser.parse_args(argv)

    problem_count = 0
    for path in collect_files(args.paths):
        try:
            text = path.read_text(encoding="utf-8")
        except OSError as error:
            print(f"{path}: cannot read: {error}", file=sys.stderr)
            return 2
        for lineno, rule, raw in find_problems(text):
            print(f"{path}:{lineno}: rule {rule}: {raw}")
            problem_count += 1
    return 1 if problem_count else 0


if __name__ == "__main__":
    sys.exit(main())
