"""Small shared fixtures: one lesson, its packet, and a form that passes."""
import copy
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import l4lib  # noqa: E402

LESSON_TEXT = """---
_id: "lesson-algebra-quadratic-equations"
title: "Quadratic Equations"
summary: "Solve quadratic equations and describe their roots."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 8
isActive: true
---
## Core Concept

A quadratic equation in $x$ can be written in standard form as $ax^2+bx+c=0$.

Factoring is efficient when the quadratic has convenient factors.

## Examples

### #1: Basic Factoring

Solve $x^2-5x+6=0$.

**Solution:**

1. Find two numbers whose product is $6$ and whose sum is $-5$.
2. Write $(x-2)(x-3)=0$, so $x=2$ or $x=3$.

## Traps to Watch For

### #1: Not Setting the Equation to Zero

> Move every term to one side first.

Factoring only works when one side is zero.
"""


def packet(filipino=False):
    return {
        "id": "L4-0417",
        "lesson_sha256": l4lib.sha256_text(LESSON_TEXT),
        "standards_commit": "a" * 40,
        "lesson_text": LESSON_TEXT,
        "filipino": filipino,
    }


def valid_form(role="A"):
    pkt = packet()
    rules = {}
    for rule in l4lib.load_rules():
        if rule["kind"] not in ("chat", "source-check"):
            continue
        if rule["id"] in ("L08", "L09", "L10", "L11", "L12"):
            entry = {"verdict": "not_applicable", "findings": [], "checked": [],
                     "note": "This lesson is taught in English."}
        else:
            entry = {"verdict": "pass", "findings": [],
                     "checked": ["Read every section against this rule and found no breach."], "note": ""}
        rules[rule["id"]] = entry
    return {
        "packet": pkt["id"], "role": role,
        "lesson_sha256": pkt["lesson_sha256"], "standards_commit": pkt["standards_commit"],
        "rules": rules, "illustrations": [], "accuracy_concerns": [],
    }


def failing(form, rule_id, quote, problem="The lesson breaks this rule at the quoted text."):
    form = copy.deepcopy(form)
    form["rules"][rule_id] = {"verdict": "fail", "checked": [], "note": "",
                              "findings": [{"quote": quote, "problem": problem}]}
    return form
