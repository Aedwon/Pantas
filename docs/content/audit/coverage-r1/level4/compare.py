"""Compare the two reads of one lesson and merge a deciding chat's rulings.

Where the reads agree, the verdict stands. Everything else becomes a
deciding item: a rule the reads disagree on, or a finding or illustration
only one read reported. The deciding chat sees positions labeled A and B in
a seeded random order, so it cannot tell which read wrote which.
"""
import copy
import difflib
import random

import l4lib

COPY_RATIO = 0.85
COPY_MIN_CHARS = 200
COPY_MIN_QUOTES = 5


def _klass(verdict):
    return verdict if verdict in ("pass", "fail") else "other"


def _pair(entries_a, entries_b, key, lesson_text):
    """Return (paired, only_a, only_b). Two entries pair when their quotes overlap in the lesson."""
    left = list(entries_b)
    paired, only_a = [], []
    for entry in entries_a:
        match = next((other for other in left if l4lib.same_place(entry[key], other[key], lesson_text)), None)
        if match is None:
            only_a.append(entry)
        else:
            left.remove(match)
            paired.append((entry, match))
    return paired, only_a, left


def _free_text(form):
    parts = []
    for rule_id in sorted(form["rules"]):
        entry = form["rules"][rule_id]
        parts.extend(finding.get("problem", "") for finding in entry.get("findings") or [])
        parts.extend(entry.get("checked") or [])
        parts.append(entry.get("note") or "")
    return l4lib.norm(" ".join(part for part in parts if isinstance(part, str) and part))


def _quotes(form):
    return {l4lib.norm(finding["quote"]) for entry in form["rules"].values() for finding in entry.get("findings") or []}


def similarity(form_a, form_b):
    """How alike the two reads' own words are, from 0 to 1.

    autojunk is off: with it on, difflib ignores common characters in long
    text and scores a lightly reworded copy near zero.
    """
    text_a, text_b = _free_text(form_a), _free_text(form_b)
    if min(len(text_a), len(text_b)) < COPY_MIN_CHARS:
        return 0.0
    return difflib.SequenceMatcher(None, text_a, text_b, autojunk=False).ratio()


def same_quotes(form_a, form_b):
    """True when both reads quote exactly the same set of lesson text, for a set too large to be chance."""
    quotes_a, quotes_b = _quotes(form_a), _quotes(form_b)
    return len(quotes_a) >= COPY_MIN_QUOTES and quotes_a == quotes_b


def compare(form_a, form_b, seed, lesson_text):
    rng = random.Random(seed)
    rules, items = {}, []

    def add_item(item):
        item["id"] = "I%d" % (len(items) + 1)
        items.append(item)

    for rule_id in sorted(form_a["rules"]):
        a, b = form_a["rules"][rule_id], form_b["rules"][rule_id]
        record = {"checked": {"A": a.get("checked", []), "B": b.get("checked", [])},
                  "notes": {"A": a.get("note", ""), "B": b.get("note", "")}, "findings": []}
        if _klass(a["verdict"]) != _klass(b["verdict"]) or (
                _klass(a["verdict"]) == "other" and a["verdict"] != b["verdict"]):
            swap = rng.random() < 0.5
            first, second = (b, a) if swap else (a, b)
            record.update(state="disputed", verdict=None)
            add_item({"type": "disputed", "rule": rule_id, "swap": swap,
                      "A": copy.deepcopy(first), "B": copy.deepcopy(second)})
        elif a["verdict"] == "fail":
            paired, only_a, only_b = _pair(a.get("findings", []), b.get("findings", []), "quote", lesson_text)
            record.update(state="agree_fail", verdict="fail")
            for mine, theirs in paired:
                record["findings"].append({"quote": mine["quote"], "problem": mine["problem"],
                                           "problem_b": theirs["problem"], "source": "both"})
            for origin, entries in (("A", only_a), ("B", only_b)):
                for finding in entries:
                    add_item({"type": "single", "rule": rule_id, "origin": origin, "finding": copy.deepcopy(finding)})
        else:
            record.update(state="agree_pass" if a["verdict"] == "pass" else "agree_other", verdict=a["verdict"])
        rules[rule_id] = record

    illustrations = []
    paired, only_a, only_b = _pair(form_a.get("illustrations", []), form_b.get("illustrations", []),
                                   "position_quote", lesson_text)
    for mine, _theirs in paired:
        illustrations.append(dict(mine, source="both"))
    for origin, entries in (("A", only_a), ("B", only_b)):
        for entry in entries:
            add_item({"type": "single", "origin": origin, "illustration": copy.deepcopy(entry)})

    concerns = [dict(concern, source=origin)
                for origin, form in (("A", form_a), ("B", form_b))
                for concern in form.get("accuracy_concerns", [])]
    ratio = similarity(form_a, form_b)
    return {"rules": rules, "illustrations": illustrations, "accuracy_concerns": concerns,
            "items": items, "similarity": round(ratio, 3),
            "copied": ratio >= COPY_RATIO or same_quotes(form_a, form_b)}


def public_items(comparison):
    """Deciding items as the deciding chat may see them: no trace of which read wrote what."""
    hidden = ("swap", "origin")
    return [{key: value for key, value in item.items() if key not in hidden} for item in comparison["items"]]


def apply_ruling(comparison, ruling_form=None):
    """Final result for the lesson. ruling_form is required when there are deciding items."""
    items = comparison["items"]
    if items and ruling_form is None:
        raise l4lib.L4Error("this lesson has deciding items and no ruling")
    rules = copy.deepcopy(comparison["rules"])
    illustrations = copy.deepcopy(comparison["illustrations"])
    rulings = []
    for item in items:
        ruling = ruling_form["rulings"][item["id"]]
        rulings.append({"item": item["id"], "rule": item.get("rule"), "ruling": ruling["ruling"],
                        "quote": ruling["quote"], "reason": ruling["reason"]})
        if item["type"] == "disputed":
            chosen = item["A"] if ruling["ruling"] == "uphold_a" else item["B"]
            record = rules[item["rule"]]
            record["verdict"] = chosen["verdict"]
            record["state"] = "ruled"
            record["findings"] = [dict(finding, source="ruled") for finding in chosen.get("findings", [])]
        elif ruling["ruling"] == "uphold":
            if "finding" in item:
                rules[item["rule"]]["findings"].append(dict(item["finding"], source="ruled"))
            else:
                illustrations.append(dict(item["illustration"], source="ruled"))
    for record in rules.values():
        if record["verdict"] == "fail" and not record["findings"]:
            # Both reads failed the rule on different text and the deciding chat
            # rejected every finding, so nothing supports the failure.
            record["verdict"], record["state"] = "pass", "ruled"
        record["source"] = "ruled" if record["state"] == "ruled" else "both"
    return {"rules": rules, "illustrations": illustrations,
            "accuracy_concerns": comparison["accuracy_concerns"], "rulings": rulings,
            "similarity": comparison["similarity"]}
