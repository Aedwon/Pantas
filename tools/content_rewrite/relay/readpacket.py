"""What a reading chat is given and what its answer form must hold (shared by the prompt and the hand-in).

The form is the Level 4 answer form (vendored form.py) with one added section, brief_items: one
entry per brief item id, saying whether the rewrite fixed it. Python 3.9 standard library only.
"""
import briefs as briefs_mod
import rw_lib

import form  # noqa: E402  (vendored)
import l4lib  # noqa: E402  (vendored)
import mechanical  # noqa: E402  (vendored)

STATUSES = ("fixed", "not_fixed")
MIN_NOTE = 20
# L01 asks for a recorded learning goal. The checklist says it is not checked while none is recorded
# (Aedwon, 25 October 2026), and the rewrite worktree has no Level 3 records, so it is left off the form.
DROPPED_RULES = ("L01",)
ROLE = "A"


def rule_ids(lesson_text, path):
    """The rules on a read form: the chat-judged ones, plus any rule the script flagged candidates for."""
    found = mechanical.check_lesson(lesson_text, rw_lib.path_parts(path))
    extra = sorted({f["rule"] for f in found if f["candidate"]})
    chat = [rule for rule in l4lib.chat_rule_ids() if rule not in DROPPED_RULES]
    return chat + [rule for rule in extra if rule not in chat and rule not in DROPPED_RULES]


def candidates_text(lesson_text, path):
    rows = []
    for f in mechanical.check_lesson(lesson_text, rw_lib.path_parts(path)):
        if f["candidate"]:
            rows.append("- %s, line %d: %s. Text: %s" % (f["rule"], f["line"], f["problem"], f["text"]))
    return "\n".join(rows)


def packet(lesson_id, lesson_text, path):
    """The Level 4 'packet' dict that form.validate expects."""
    return {
        "id": lesson_id,
        "lesson_sha256": l4lib.sha256_text(lesson_text),
        "standards_commit": l4lib.standards_commit(),
        "rule_ids": rule_ids(lesson_text, path),
        "filipino": rw_lib.is_filipino(path, lesson_text),
        "lesson_text": lesson_text,
    }


def blank_form(pkt, brief):
    blank = form.blank_form(pkt, ROLE)
    blank["brief_items"] = {item_id: {"status": "", "quote": "", "note": ""} for item_id in briefs_mod.item_ids(brief)}
    return blank


def brief_item_reasons(candidate, brief, lesson_text):
    """Reasons a form's brief_items section is rejected. Reasons never repeat form content."""
    entries = candidate.get("brief_items") if isinstance(candidate, dict) else None
    if not isinstance(entries, dict):
        return ["brief_items must be an object with one entry for each brief item id"]
    wanted = briefs_mod.item_ids(brief)
    reasons = []
    missing = [item_id for item_id in wanted if item_id not in entries]
    extra = [item_id for item_id in entries if item_id not in wanted]
    if missing:
        reasons.append("brief_items is missing %d brief items: %s" % (len(missing), ", ".join(missing[:8])
                                                                   + (", ..." if len(missing) > 8 else "")))
    if extra:
        reasons.append("brief_items has %d ids that are not on this lesson's brief; remove them" % len(extra))
    for item_id in wanted:
        entry = entries.get(item_id)
        if entry is None:
            continue
        label = "brief item %s" % item_id
        if not isinstance(entry, dict) or entry.get("status") not in STATUSES:
            reasons.append("%s: status must be one of %s" % (label, ", ".join(STATUSES)))
            continue
        if not l4lib.quote_in(entry.get("quote"), lesson_text):
            reasons.append("%s: quote is not exact text from the rewritten lesson (or is under %d characters)"
                           % (label, l4lib.MIN_QUOTE_CHARS))
        note = entry.get("note")
        if not isinstance(note, str) or len(l4lib.norm(note)) < MIN_NOTE:
            reasons.append("%s: note must say what you checked, in at least %d characters" % (label, MIN_NOTE))
    return reasons


def validate(candidate, pkt, brief):
    """All reasons for a read form: the Level 4 checks, then the brief items."""
    reasons = form.validate(candidate, pkt, ROLE)
    if isinstance(candidate, dict):
        reasons = reasons + brief_item_reasons(candidate, brief, pkt["lesson_text"])
    return reasons


def clean(candidate, brief):
    cleaned = form.clean(candidate, ROLE)
    cleaned["brief_items"] = {item_id: {key: candidate["brief_items"][item_id][key] for key in ("status", "quote", "note")}
                              for item_id in briefs_mod.item_ids(brief)}
    return cleaned


def uncovered_changes(record):
    """Changed passages the change guard could not match, from an accepted rewrite record."""
    return [c for c in (record or {}).get("changes", []) if c.get("by") is None]

