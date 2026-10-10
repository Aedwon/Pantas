"""Shared helpers for the Level 4 web chat audit.

Python 3.9 standard library only: the relay runs these scripts with the
system python3.
"""
import hashlib
import json
import os
import re
import subprocess
from pathlib import Path

LEVEL4_DIR = Path(__file__).resolve().parent
AUDIT_WT = LEVEL4_DIR.parents[4]
CORPUS_WT = AUDIT_WT.parent / "Pantas-wt-content-qa-r2"
CORPUS_COMMIT = "765c5dc0fa5586281047bf4f7b30d09ab3707887"
# Run secrets (planted key, packet index, forms awaiting their pair) stay
# outside the pushed folder so no chat can read them from GitHub.
STATE_DIR = Path(os.environ.get("PANTAS_L4_STATE", str(Path.home() / ".pantas-audit" / "level4")))

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
    return load_json(LEVEL4_DIR / "rules.json")["rules"]


def standards_commit():
    return load_json(LEVEL4_DIR / "rules.json")["standards_commit"]


def chat_rule_ids():
    return [rule["id"] for rule in load_rules() if rule["kind"] in ("chat", "source-check")]


def _git(root, *args):
    return subprocess.check_output(["git"] + list(args), cwd=str(root), universal_newlines=True)


def check_corpus(root=None, commit=None):
    """Refuse to read a corpus that is not the pinned, clean input."""
    root = Path(root or CORPUS_WT)
    commit = commit or CORPUS_COMMIT
    try:
        head = _git(root, "rev-parse", "HEAD").strip()
        dirty = _git(root, "status", "--porcelain").strip()
    except (OSError, subprocess.CalledProcessError) as exc:
        raise L4Error("corpus worktree unreadable at %s: %s" % (root, exc))
    if head != commit:
        raise L4Error("corpus is at %s, expected %s" % (head, commit))
    if dirty:
        raise L4Error("corpus worktree has uncommitted changes")


def sha256_text(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def norm(text):
    return re.sub(r"\s+", " ", text).strip()


def quote_in(quote, lesson_text):
    """True when the quote is real lesson text, ignoring line wrapping."""
    if not isinstance(quote, str):
        return False
    wanted = norm(quote)
    return len(wanted) >= MIN_QUOTE_CHARS and wanted in norm(lesson_text)


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
        frontmatter[key.strip()] = _scalar(value)
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
