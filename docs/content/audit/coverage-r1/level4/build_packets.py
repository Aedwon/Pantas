"""Build one self-contained packet per lesson for the reading chats.

A packet carries everything a chat needs and nothing that tells it whether
the lesson is a planted check. Which packet maps to which lesson, and which
are planted, is written only to the local state directory.

Usage: python3 build_packets.py
"""
import json
import random
import re
import secrets
import subprocess
import sys

import form
import l4lib
import mechanical

AUDIT_DIR = l4lib.LEVEL4_DIR.parent
WORKSPACE = l4lib.AUDIT_WT.name
INBOX = "docs/content/audit/coverage-r1/level4/inbox"
HANDIN = "docs/content/audit/coverage-r1/level4/handin.py"
LESSON_START = "<<<<<<<< LESSON START"
LESSON_END = ">>>>>>>> LESSON END"


def load_config():
    path = l4lib.STATE_DIR / "config.json"
    if path.exists():
        return l4lib.load_json(path)
    config = {"seed": secrets.randbelow(10 ** 9), "run_token": "l4" + secrets.token_hex(3),
              "eraser_confirmed": False}
    l4lib.save_json(path, config)
    return config


def _show(commit, path):
    return subprocess.check_output(["git", "show", "%s:%s" % (commit, path)], cwd=str(l4lib.AUDIT_WT),
                                   universal_newlines=True)


def _section(text, start, stop):
    begin = text.index(start)
    end = text.index(stop, begin + len(start))
    return text[begin:end].rstrip() + "\n"


def standards_text(commit):
    guide = _show(commit, "docs/content/lesson-style-guide.md")
    questions = _show(commit, "docs/content/question-style-guide.md")
    agents = _show(commit, "AGENTS.md")
    return {
        "guide": guide,
        "expected": _section(questions, "## Problem information and expected knowledge", "\n## "),
        "voice": _section(agents, "## Voice, for in-app content and interface text", "\n## Pricing"),
    }


def assign_ids(keys, seed, existing=None):
    """Stable opaque ids: known keys keep theirs, new keys draw unused numbers."""
    ids = dict(existing or {})
    used = set(ids.values())
    rng = random.Random(seed)
    pool = ["L4-%04d" % number for number in rng.sample(range(1000, 10000), 9000)]
    free = (packet_id for packet_id in pool if packet_id not in used)
    for key in sorted(keys):
        if key not in ids:
            ids[key] = next(free)
    return ids


def _level3(record):
    if not record:
        return "No Level 3 record exists for this lesson. Treat rule L01 as fail and quote the lesson title line.\n"
    lines = ["Learning goal recorded at Level 3: %s" % record.get("goal", "(none recorded)"), "",
             "Skills Level 3 found in this lesson, with its verdicts:"]
    for skill in record.get("skills", []):
        lines.append("- %s (teaching: %s; example: %s)" % (
            skill.get("name"), skill.get("teachingVerdict"), skill.get("exampleVerdict")))
        for limit in skill.get("limitations", []):
            lines.append("  - Limitation noted: %s" % limit)
    return "\n".join(lines) + "\n"


def _candidates(findings):
    lines = []
    for finding in findings:
        if finding["candidate"]:
            lines.append("- %s, line %d: %s. Text: %s" % (
                finding["rule"], finding["line"], finding["problem"], json.dumps(finding["text"], ensure_ascii=False)))
    return "\n".join(lines)


def _rule_rows(rule_ids):
    rows = ["| Id | Rule | Severity | How to check | Guide section |", "|---|---|---|---|---|"]
    for rule in l4lib.load_rules():
        if rule["id"] in rule_ids:
            rows.append("| %s | %s | %s | %s | %s |" % (rule["id"], rule["rule"], rule["severity"], rule["how"], rule["source"]))
    return "\n".join(rows)


def render(packet, lesson_text, prerequisites, level3, findings, standards, run_token):
    template = (l4lib.LEVEL4_DIR / "prompts" / "packet.md").read_text(encoding="utf-8")
    candidates = _candidates(findings)
    prereq_text = "\n\n".join(
        "### Prerequisite lesson: %s\n\n%s" % (lesson_id, text) for lesson_id, text in prerequisites
    ) or "Level 3 found no prerequisite lesson for this lesson.\n"
    values = {
        "PACKET": packet["id"],
        "TOKEN": run_token,
        "WORKSPACE": WORKSPACE,
        "INBOX": INBOX,
        "HANDIN": HANDIN,
        "FORM": json.dumps(form.blank_form(packet, "<your role: A or B>"), indent=1),
        "RULES": _rule_rows(packet["rule_ids"]),
        "GUIDE": standards["guide"],
        "EXPECTED": standards["expected"],
        "VOICE": standards["voice"],
        "LEVEL3": _level3(level3),
        "CANDIDATES": candidates or "The script flagged nothing in this lesson that needs your confirmation.",
        "PREREQUISITES": prereq_text,
        "LESSON": "%s\n%s\n%s" % (LESSON_START, lesson_text.rstrip("\n"), LESSON_END),
    }
    return re.sub(r"\{\{(\w+)\}\}", lambda match: values[match.group(1)], template)


def build(planted_dir=None):
    l4lib.check_corpus()
    config = load_config()
    commit = l4lib.standards_commit()
    standards = standards_text(commit)
    lessons = l4lib.load_json(AUDIT_DIR / "inventory-lessons.json")["lessons"]
    prerequisites = l4lib.load_json(AUDIT_DIR / "lesson-prerequisites.json")
    level3 = {}
    for topic in l4lib.load_json(AUDIT_DIR / "lesson-structure-data.json")["topicRecords"]:
        for record in topic["lessons"]:
            level3[record["id"]] = record
    texts = {lesson["metadata__id"]: (l4lib.CORPUS_WT / lesson["path"]).read_text(encoding="utf-8") for lesson in lessons}
    by_id = {lesson["metadata__id"]: lesson for lesson in lessons}

    planted_dir = planted_dir or (l4lib.STATE_DIR / "planted")
    entries = [(lesson["metadata__id"], False, texts[lesson["metadata__id"]]) for lesson in lessons]
    if planted_dir.is_dir():
        for path in sorted(planted_dir.glob("*.md")):
            if path.stem not in by_id:
                raise l4lib.L4Error("planted copy %s matches no lesson" % path.name)
            entries.append((path.stem, True, path.read_text(encoding="utf-8")))

    index_path = l4lib.STATE_DIR / "index.json"
    old = l4lib.load_json(index_path) if index_path.exists() else {}
    existing = {"%s|%d" % (entry["lesson_id"], entry["planted"]): packet_id for packet_id, entry in old.items()}
    ids = assign_ids(["%s|%d" % (lesson_id, planted) for lesson_id, planted, _ in entries], config["seed"], existing)

    out_dir = l4lib.LEVEL4_DIR / "packets"
    out_dir.mkdir(exist_ok=True)
    index = {}
    for lesson_id, planted, text in entries:
        lesson = by_id[lesson_id]
        findings = mechanical.check_lesson(text, (lesson["subject"], lesson["topic"], lesson["slug"]))
        extra = sorted({finding["rule"] for finding in findings if finding["candidate"]})
        packet = {
            "id": ids["%s|%d" % (lesson_id, planted)],
            "lesson_sha256": l4lib.sha256_text(text),
            "standards_commit": commit,
            "rule_ids": l4lib.chat_rule_ids() + [rule for rule in extra if rule not in l4lib.chat_rule_ids()],
            "filipino": False,
        }
        prereq = [(other, texts[other]) for other in prerequisites.get(lesson_id, [])]
        body = render(packet, text, prereq, level3.get(lesson_id), findings, standards, config["run_token"])
        (out_dir / ("%s.md" % packet["id"])).write_text(body, encoding="utf-8")
        index[packet["id"]] = dict(
            packet, lesson_id=lesson_id, planted=planted, title=lesson["metadata_title"],
            subject=lesson["subject"], topic=lesson["topic"],
            source=str(planted_dir / ("%s.md" % lesson_id)) if planted else lesson["path"],
        )
    for stale in set(path.stem for path in out_dir.glob("L4-*.md")) - set(index):
        (out_dir / ("%s.md" % stale)).unlink()
    l4lib.save_json(index_path, index)
    return index


def main():
    index = build()
    planted = sum(1 for entry in index.values() if entry["planted"])
    print("packets written: %d (%d real, %d planted)" % (len(index), len(index) - planted, planted))
    return 0


if __name__ == "__main__":
    sys.exit(main())
