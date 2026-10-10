"""The answer form a chat hands in, and the check that accepts or rejects it.

Every reason string is written for the chat that must fix the form, and
names the rule id or field at fault. Reasons never repeat form content.
"""
import l4lib

VERDICTS = ("pass", "fail", "not_applicable", "needs_source_check")
FILIPINO_RULES = ("L08", "L09", "L10", "L11", "L12")
# Rules that can truly have nothing to judge in a lesson: no exam verb (L03),
# the Filipino rules in a lesson without Filipino, no prompt that points at a
# word (L14), no display equation (L21), no illustration placeholder (L23).
# Every other rule applies to every lesson and must be pass or fail.
NA_ALLOWED = ("L03", "L14", "L21", "L23") + FILIPINO_RULES
MAX_SAME_PROOF = 2
ENTRY_KEYS = ("verdict", "findings", "checked", "note")
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


def rule_ids_for(packet):
    """Chat-judged rules for this packet: the standing ones plus any rule whose
    script candidates a reader must confirm in this lesson."""
    return packet.get("rule_ids") or l4lib.chat_rule_ids()


def _needs_proof(rule):
    return rule["severity"].startswith(("Blocker", "Major")) and rule["kind"] != "source-check"


def blank_form(packet, role="A or B"):
    return {
        "packet": packet["id"],
        "role": role,
        "lesson_sha256": packet["lesson_sha256"],
        "standards_commit": packet["standards_commit"],
        "rules": {
            rule_id: {"verdict": "", "findings": [], "checked": [], "note": ""}
            for rule_id in rule_ids_for(packet)
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
    shape = "rule %s must be an object with verdict (text), findings (list), checked (list of text), and note (text)" % rule_id
    if not isinstance(entry, dict):
        return [shape]
    verdict = entry.get("verdict")
    if not isinstance(verdict, str) or verdict not in VERDICTS:
        return ["rule %s has no valid verdict; use one of %s" % (rule_id, ", ".join(VERDICTS))]
    checked = entry.get("checked")
    if (not isinstance(entry.get("findings"), list) or not isinstance(entry.get("note"), str)
            or not isinstance(checked, list) or not all(isinstance(item, str) for item in checked)):
        return [shape + "; use [] and \"\" for empty values, never null"]
    reasons = []
    if verdict == "needs_source_check" and rule_id != "L11":
        reasons.append("rule %s cannot be needs_source_check; only L11 can" % rule_id)
    if rule_id == "L11" and verdict in ("pass", "fail"):
        reasons.append("rule L11 cannot be pass or fail; use needs_source_check, or not_applicable for a lesson not in Filipino")
    # Reasons below never say which verdict the form gave: they are posted to GitHub.
    evidence = ("rule %s: its verdict and its evidence do not fit. A fail needs a finding, a pass on a "
                "Blocker or Major rule needs checked items of at least %d characters, and not_applicable "
                "needs a note of at least %d characters" % (rule_id, MIN_CHECKED, MIN_NOTE))
    if verdict == "not_applicable":
        if rule_id not in NA_ALLOWED:
            reasons.append("rule %s applies to every lesson; judge it" % rule_id)
        elif rule_id in FILIPINO_RULES and packet["filipino"]:
            reasons.append("rule %s applies because this lesson is in Filipino" % rule_id)
        if not _text(entry.get("note"), MIN_NOTE):
            reasons.append(evidence)
    findings = entry["findings"]
    if verdict == "fail" and not findings:
        reasons.append(evidence)
    if verdict != "fail" and findings:
        reasons.append("rule %s: findings belong only under a fail" % rule_id)
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
    if verdict == "pass" and _needs_proof(rule) and not any(_text(item, MIN_CHECKED) for item in checked):
        reasons.append(evidence)
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
    wanted = rule_ids_for(packet)
    missing = [rule_id for rule_id in wanted if rule_id not in rules]
    extra = sorted(rule_id for rule_id in rules if rule_id not in wanted)
    if missing:
        reasons.append("rules are missing: %s" % ", ".join(missing))
    if extra:
        # Unknown keys are counted, never echoed: a key can carry any text.
        reasons.append("the form has %d rule ids that are not on this packet's form; remove them" % len(extra))
    proofs = {}
    for rule in l4lib.load_rules():
        if rule["id"] in wanted and rule["id"] in rules:
            found = _rule_reasons(rule, rules[rule["id"]], packet)
            reasons.extend(found)
            entry = rules[rule["id"]]
            if not found and entry["verdict"] == "pass" and _needs_proof(rule):
                proofs.setdefault(l4lib.norm(" ".join(entry["checked"])).lower(), []).append(rule["id"])
    for same in proofs.values():
        if len(same) > MAX_SAME_PROOF:
            reasons.append("rules %s give the same checked text; say what you checked for each rule" % ", ".join(same))
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
        reasons.append("the form has %d rulings for items that were not asked; remove them" % len(extra))
    for item in items:
        entry = rulings.get(item["id"])
        if entry is None:
            continue
        allowed = RULINGS[item["type"]]
        if not isinstance(entry, dict) or not isinstance(entry.get("ruling"), str) or entry["ruling"] not in allowed:
            reasons.append("item %s: ruling must be one of %s" % (item["id"], ", ".join(allowed)))
            continue
        if not l4lib.quote_in(entry.get("quote"), packet["lesson_text"]):
            reasons.append("item %s: the quote is not exact text from the lesson" % item["id"])
        if not _text(entry.get("reason"), MIN_REASON):
            reasons.append("item %s: reason must explain the ruling in at least %d characters" % (item["id"], MIN_REASON))
    return reasons


def clean(form, role):
    """An accepted form reduced to its known fields. Anything else a chat added is
    dropped, so it cannot ride along to the deciding chat or into the results."""
    header = {key: form[key] for key in ("packet", "role", "lesson_sha256", "standards_commit")}
    if role == "D":
        return dict(header, rulings={item_id: {key: entry[key] for key in ("ruling", "quote", "reason")}
                                     for item_id, entry in form["rulings"].items()})
    return dict(
        header,
        rules={rule_id: {"verdict": entry["verdict"], "checked": list(entry["checked"]), "note": entry["note"],
                         "findings": [{"quote": f["quote"], "problem": f["problem"]} for f in entry["findings"]]}
               for rule_id, entry in form["rules"].items()},
        illustrations=[{key: item[key] for key in sorted(ILLUSTRATION_VALUES) + list(ILLUSTRATION_TEXT)}
                       for item in form.get("illustrations", [])],
        accuracy_concerns=[{"quote": item["quote"], "concern": item["concern"]}
                           for item in form.get("accuracy_concerns", [])],
    )


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
