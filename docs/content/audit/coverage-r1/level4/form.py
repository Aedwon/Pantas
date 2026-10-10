"""The answer form a chat hands in, and the check that accepts or rejects it.

Every reason string is written for the chat that must fix the form, and
names the rule id or field at fault. Reasons never repeat form content.
"""
import l4lib

VERDICTS = ("pass", "fail", "not_applicable", "needs_source_check")
FILIPINO_RULES = ("L08", "L09", "L10", "L11", "L12")
ILLUSTRATION_VALUES = {
    "status": ("missing", "insufficient", "unneeded_existing"),
    "priority": ("high", "medium", "low"),
    "method": ("code", "library", "table_or_formula"),
    "kind": ("exact_exam_figure", "concept"),
}
ILLUSTRATION_TEXT = ("position_quote", "description", "why")
MIN_PROBLEM = 20
MIN_CHECKED = 15
MIN_NOTE = 15
MIN_REASON = 20
RULINGS = {"disputed": ("uphold_a", "uphold_b"), "single": ("uphold", "reject")}


def blank_form(packet, role="A or B"):
    return {
        "packet": packet["id"],
        "role": role,
        "lesson_sha256": packet["lesson_sha256"],
        "standards_commit": packet["standards_commit"],
        "rules": {
            rule_id: {"verdict": "", "findings": [], "checked": [], "note": ""}
            for rule_id in l4lib.chat_rule_ids()
        },
        "illustrations": [],
        "accuracy_concerns": [],
    }


def _header_reasons(form, packet, role):
    reasons = []
    for key, expected in (
        ("packet", packet["id"]),
        ("role", role),
        ("lesson_sha256", packet["lesson_sha256"]),
        ("standards_commit", packet["standards_commit"]),
    ):
        if form.get(key) != expected:
            reasons.append("field %s does not match this packet; copy it from the packet's form" % key)
    return reasons


def _text(value, minimum):
    return isinstance(value, str) and len(l4lib.norm(value)) >= minimum


def _rule_reasons(rule, entry, packet):
    rule_id = rule["id"]
    if not isinstance(entry, dict):
        return ["rule %s must be an object with verdict, findings, checked, and note" % rule_id]
    verdict = entry.get("verdict")
    if verdict not in VERDICTS:
        return ["rule %s has no valid verdict; use one of %s" % (rule_id, ", ".join(VERDICTS))]
    reasons = []
    if verdict == "needs_source_check" and rule_id != "L11":
        reasons.append("rule %s cannot be needs_source_check; only L11 can" % rule_id)
    if rule_id == "L11" and verdict in ("pass", "fail"):
        reasons.append("rule L11 cannot be pass or fail; use needs_source_check, or not_applicable for a lesson not in Filipino")
    if verdict == "not_applicable":
        if rule_id in FILIPINO_RULES and packet["filipino"]:
            reasons.append("rule %s applies because this lesson is in Filipino" % rule_id)
        if not _text(entry.get("note"), MIN_NOTE):
            reasons.append("rule %s is not_applicable without a note saying why (at least %d characters)" % (rule_id, MIN_NOTE))
    findings = entry.get("findings") or []
    if verdict == "fail" and not findings:
        reasons.append("rule %s is fail with no finding" % rule_id)
    if not isinstance(findings, list):
        return reasons + ["rule %s findings must be a list" % rule_id]
    for number, finding in enumerate(findings, 1):
        if not isinstance(finding, dict):
            reasons.append("rule %s finding %d must be an object with quote and problem" % (rule_id, number))
            continue
        if not l4lib.quote_in(finding.get("quote"), packet["lesson_text"]):
            reasons.append("rule %s finding %d: the quote is not exact text from the lesson (or is under %d characters)"
                           % (rule_id, number, l4lib.MIN_QUOTE_CHARS))
        if not _text(finding.get("problem"), MIN_PROBLEM):
            reasons.append("rule %s finding %d: problem must say what is wrong in at least %d characters"
                           % (rule_id, number, MIN_PROBLEM))
    if verdict == "pass" and rule["proof"]:
        checked = entry.get("checked")
        if not isinstance(checked, list) or not any(_text(item, MIN_CHECKED) for item in checked):
            reasons.append("rule %s is pass without proof; list in checked what you checked in this lesson" % rule_id)
    return reasons


def _illustration_reasons(entries, packet):
    if not isinstance(entries, list):
        return ["illustrations must be a list (it may be empty)"]
    reasons = []
    for number, entry in enumerate(entries, 1):
        if not isinstance(entry, dict):
            reasons.append("illustration %d must be an object" % number)
            continue
        for key, allowed in sorted(ILLUSTRATION_VALUES.items()):
            if entry.get(key) not in allowed:
                reasons.append("illustration %d: %s must be one of %s" % (number, key, ", ".join(allowed)))
        for key in ILLUSTRATION_TEXT:
            if not _text(entry.get(key), 1):
                reasons.append("illustration %d: %s is empty" % (number, key))
        if not l4lib.quote_in(entry.get("position_quote"), packet["lesson_text"]):
            reasons.append("illustration %d: position_quote is not exact text from the lesson" % number)
    return reasons


def _reader_reasons(form, packet):
    reasons = []
    rules = form.get("rules")
    if not isinstance(rules, dict):
        return ["rules must be an object keyed by rule id"]
    wanted = l4lib.chat_rule_ids()
    missing = [rule_id for rule_id in wanted if rule_id not in rules]
    extra = sorted(rule_id for rule_id in rules if rule_id not in wanted)
    if missing:
        reasons.append("rules are missing: %s" % ", ".join(missing))
    if extra:
        reasons.append("rules that are not on this form: %s" % ", ".join(extra))
    for rule in l4lib.load_rules():
        if rule["id"] in wanted and rule["id"] in rules:
            reasons.extend(_rule_reasons(rule, rules[rule["id"]], packet))
    reasons.extend(_illustration_reasons(form.get("illustrations", []), packet))
    concerns = form.get("accuracy_concerns", [])
    if not isinstance(concerns, list):
        return reasons + ["accuracy_concerns must be a list (it may be empty)"]
    for number, concern in enumerate(concerns, 1):
        if not isinstance(concern, dict) or not l4lib.quote_in(concern.get("quote"), packet["lesson_text"]):
            reasons.append("accuracy concern %d: the quote is not exact text from the lesson" % number)
        elif not _text(concern.get("concern"), MIN_PROBLEM):
            reasons.append("accuracy concern %d: concern must say what looks wrong" % number)
    return reasons


def _decider_reasons(form, packet, items):
    rulings = form.get("rulings")
    if not isinstance(rulings, dict):
        return ["rulings must be an object keyed by item id"]
    reasons = []
    wanted = [item["id"] for item in items]
    missing = [item_id for item_id in wanted if item_id not in rulings]
    extra = sorted(item_id for item_id in rulings if item_id not in wanted)
    if missing:
        reasons.append("rulings are missing for items: %s" % ", ".join(missing))
    if extra:
        reasons.append("rulings for items that were not asked: %s" % ", ".join(extra))
    for item in items:
        entry = rulings.get(item["id"])
        if entry is None:
            continue
        allowed = RULINGS[item["type"]]
        if not isinstance(entry, dict) or entry.get("ruling") not in allowed:
            reasons.append("item %s: ruling must be one of %s" % (item["id"], ", ".join(allowed)))
            continue
        if not l4lib.quote_in(entry.get("quote"), packet["lesson_text"]):
            reasons.append("item %s: the quote is not exact text from the lesson" % item["id"])
        if not _text(entry.get("reason"), MIN_REASON):
            reasons.append("item %s: reason must explain the ruling in at least %d characters" % (item["id"], MIN_REASON))
    return reasons


def validate(form, packet, role, items=None):
    """Return the reasons a form is rejected. An empty list means accepted.

    packet: {"id", "lesson_sha256", "standards_commit", "lesson_text", "filipino"}
    role: "A" or "B" for a read, "D" for the deciding chat (then items is the
    list of deciding items from compare.compare).
    """
    if not isinstance(form, dict):
        return ["the form must be one JSON object"]
    reasons = _header_reasons(form, packet, role)
    if role == "D":
        return reasons + _decider_reasons(form, packet, items or [])
    return reasons + _reader_reasons(form, packet)
