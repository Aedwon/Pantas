"""What an earlier read left open for one lesson, written as extra brief text for a new rewrite.

The read forms are the files at docs/content/rewrite/reads/<batch id>/<lesson id>.json. A form is either the
wrapped record the old hand-in stored ({"form": {...}}) or the bare form a pull request carries.
Python 3.9 standard library only.
"""
import json

import briefs as briefs_mod
import rw_lib

import l4lib  # noqa: E402  (vendored)


def latest_form(ctx, lesson_id):
    """(batch id, form) from the newest read of this lesson, or None."""
    found = sorted((ctx.root / rw_lib.READS_REL).glob("*/%s.json" % lesson_id))
    if not found:
        return None
    path = found[-1]
    data = json.loads(path.read_text(encoding="utf-8"))
    form = data["form"] if isinstance(data, dict) and isinstance(data.get("form"), dict) else data
    return path.parent.name, form


def open_items(ctx, lesson_id, brief):
    """{"read": batch id, "findings": [...], "concerns": [...], "not_fixed": [...]} or None without a read.

    findings   a failed rule's findings: rule id, severity, quote, problem
    concerns   accuracy concerns the reader raised: quote, concern
    not_fixed  brief items the reader judged not fixed: item id, the item's own text, the reader's note
    """
    latest = latest_form(ctx, lesson_id)
    if latest is None:
        return None
    batch_id, form = latest
    rules = {rule["id"]: rule for rule in l4lib.load_rules()}
    findings = []
    for rule_id, entry in (form.get("rules") or {}).items():
        if entry.get("verdict") == "fail":
            for finding in entry.get("findings") or []:
                findings.append({"rule": rule_id, "severity": rules.get(rule_id, {}).get("severity", ""),
                                 "quote": finding.get("quote", ""), "problem": finding.get("problem", "")})
    concerns = [{"quote": c.get("quote", ""), "concern": c.get("concern", "")} for c in form.get("accuracy_concerns") or []]
    by_id = {x["id"]: x for x in brief["fix"] + brief["gaps"] + brief["optional"]}
    not_fixed = []
    for item_id, entry in (form.get("brief_items") or {}).items():
        if entry.get("status") == "not_fixed":
            item = by_id.get(item_id, {})
            not_fixed.append({"id": item_id, "text": " ".join((item.get("quote") or item.get("text") or "").split()),
                              "note": entry.get("note", "")})
    return {"read": batch_id, "findings": findings, "concerns": concerns, "not_fixed": not_fixed}


def brief_addition(items):
    """Markdown added to the end of a brief, or '' when the read left nothing open."""
    if not items or not (items["findings"] or items["concerns"] or items["not_fixed"]):
        return ""
    lines = ["## Left open by the earlier read (%s)" % items["read"], "",
             "An independent reader judged the previous rewrite of this lesson. Fix everything below as well. "
             "Each item is as serious as an item under \"Fix these\"."]
    if items["findings"]:
        lines += ["", "### Findings", ""]
        for number, f in enumerate(items["findings"], 1):
            lines += ["%d. Rule %s (%s). Problem: %s" % (number, f["rule"], f["severity"] or "no severity", f["problem"]),
                      "   > " + " ".join(f["quote"].split())]
    if items["concerns"]:
        lines += ["", "### Accuracy concerns", ""]
        for number, c in enumerate(items["concerns"], 1):
            lines += ["%d. %s" % (number, c["concern"]), "   > " + " ".join(c["quote"].split())]
    if items["not_fixed"]:
        lines += ["", "### Brief items not fixed", ""]
        for number, n in enumerate(items["not_fixed"], 1):
            lines += ["%d. Item `%s`: %s" % (number, n["id"], n["text"]), "   Reader's note: %s" % n["note"]]
    return "\n".join(lines)
