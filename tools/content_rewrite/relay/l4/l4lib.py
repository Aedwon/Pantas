"""The parts of the Level 4 audit helper library that the vendored form and mechanical checks use.

Vendored from docs/content/audit/coverage-r1/level4/l4lib.py (branch docs/content-coverage-audit-r1,
commit ecbfa88b). The run-state, corpus-pin and git helpers were left out because this tool keeps
its own state; parse_lesson, quote_in and the rules loader are unchanged. See SOURCE.txt.
Python 3.9 standard library only.
"""
import hashlib
import json
import os
import re
from pathlib import Path

L4_DIR = Path(__file__).resolve().parent

MIN_QUOTE_CHARS = 8


class L4Error(Exception):
    pass


def load_json(path):
    with open(str(path), encoding="utf-8") as handle:
        return json.load(handle)


def save_json(path, obj):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_name(path.name + ".tmp")
    with open(str(temp), "w", encoding="utf-8") as handle:
        json.dump(obj, handle, indent=1, ensure_ascii=False)
        handle.write("\n")
    os.replace(str(temp), str(path))


def load_rules():
    return load_json(L4_DIR / "rules.json")["rules"]


def standards_commit():
    return load_json(L4_DIR / "rules.json")["standards_commit"]


def chat_rule_ids():
    return [rule["id"] for rule in load_rules() if rule["kind"] in ("chat", "source-check")]


def sha256_text(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def norm(text):
    return re.sub(r"\s+", " ", text).strip()


# Text every lesson shares. A quote made only of this proves nothing about
# having read the lesson, so it is not accepted as evidence.
BOILERPLATE = ("core concept", "mnemonics & memory aids", "examples", "speed tricks & shortcuts",
               "traps to watch for", "solution", "isactive: true")


def is_boilerplate(quote):
    bare = norm(quote).strip("#*:> ").lower()
    return bare in BOILERPLATE or bool(re.fullmatch(r"(_id|subject|topic|estimatedminutes|isactive): .*", bare))


def quote_in(quote, lesson_text):
    """True when the quote is real lesson text, ignoring line wrapping."""
    if not isinstance(quote, str):
        return False
    wanted = norm(quote)
    return len(wanted) >= MIN_QUOTE_CHARS and not is_boilerplate(wanted) and wanted in norm(lesson_text)


def spans(quote, lesson_text):
    """Every (start, end) where the quote occurs in the lesson, in normalized text."""
    wanted, text = norm(quote), norm(lesson_text)
    found, start = [], text.find(wanted)
    while wanted and start != -1:
        found.append((start, start + len(wanted)))
        start = text.find(wanted, start + 1)
    return found


def _scalar(raw):
    raw = raw.strip()
    if raw in ("true", "false"):
        return raw == "true"
    if re.fullmatch(r"-?\d+", raw):
        return int(raw)
    if len(raw) >= 2 and raw[0] == '"' and raw[-1] == '"':
        return json.loads(raw)
    return raw


def parse_lesson(text):
    lines = text.split("\n")
    if not lines or lines[0].strip() != "---":
        raise L4Error("lesson has no frontmatter")
    try:
        end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
    except StopIteration:
        raise L4Error("lesson frontmatter is not closed")
    frontmatter = {}
    raw_frontmatter = {}
    for line in lines[1:end]:
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        try:
            frontmatter[key.strip()] = _scalar(value)
        except ValueError:
            raise L4Error("lesson frontmatter has a value that is not valid")
        raw_frontmatter[key.strip()] = value.strip()
    headings = []
    for number, line in enumerate(lines, 1):
        match = re.match(r"(#{1,6}) +(.*\S)\s*$", line)
        if match and number > end + 1:
            headings.append((len(match.group(1)), match.group(2), number))
    return {
        "frontmatter": frontmatter,
        "raw_frontmatter": raw_frontmatter,
        "body": "\n".join(lines[end + 1:]),
        "body_first_line": end + 2,
        "headings": headings,
    }
