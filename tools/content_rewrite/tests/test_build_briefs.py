"""Tests for build_briefs. Run: python3 -I tools/content_rewrite/tests/test_build_briefs.py"""
import os
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
import build_briefs as bb  # noqa: E402

RULES_MD = """| Id | Rule | Severity |
|---|---|---|
| B01 | Every fact is correct | Blocker |
| L02 | Grade 5 English | Major |
| L22a | Short paragraphs | Minor |
"""

TAGS = {
    "lesson-a": {"path": "content/lessons/x/a.md", "title": "Lesson A", "exams": ["cse-professional", "upcat"]},
    "lesson-b": {"path": "content/lessons/x/b.md", "title": "Lesson B", "exams": ["cse-professional"]},
}


def t(id_, lesson, rule, verdict, fix="small", quote="q"):
    return {"id": id_, "lesson": lesson, "subject": "s", "rule": rule, "severity": "Major",
            "quote": quote, "problem": "prob " + id_, "verdict": verdict, "fix": fix,
            "reason": "why " + id_, "by": "lead"}


def g(key, place, verdict="thin", tier="official", dup=""):
    return {"key": key, "topic": "tp", "facet": "facet " + key, "verdict": verdict,
            "tier": tier, "lessons": [], "missing": ["idea " + key], "place": place,
            "duplicate_of": dup, "requirements": []}


TRIAGE = [
    t("lesson-a|B01|0", "lesson-a", "B01", "real", "large", "line1\nline2"),
    t("lesson-a|L02|1", "lesson-a", "L02", "judgment"),
    t("lesson-b|L22a|0", "lesson-b", "L22a", "real"),
    t("lesson-b|L02|1", "lesson-b", "L02", "reject"),
    t("lesson-b|B01|2", "lesson-b", "B01", "illustration"),
    t("lesson-b|lead-add|0", "lesson-b", "lead-added", "real", quote=""),
]
GAPS = [
    g("t#1", "add to lesson-a"),
    g("t#2", "Filipino section in lesson-a"),
    g("t#3", "add to lesson-b", tier="weak"),
    g("t#4", "new lesson: Big Topic"),
    g("t#5", "new lesson: Big Topic"),
    g("t#6", "skip: not teachable"),
    g("t#7", "covered by t#1", dup="t#1"),
]


def rd(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


class FixtureTests(unittest.TestCase):
    def setUp(self):
        self.rules = bb.parse_checklist(RULES_MD)
        self.briefs, self.new_md, self.stats = bb.build_briefs(TRIAGE, GAPS, TAGS, self.rules)

    def test_parse_checklist(self):
        self.assertEqual(sorted(self.rules), ["B01", "L02", "L22a"])
        self.assertIn("Every fact is correct", self.rules["B01"])

    def test_real_rows_once(self):
        for r in TRIAGE:
            if r["verdict"] == "real":
                n = sum(("`%s`" % r["id"]) in b for b in self.briefs.values())
                self.assertEqual(n, 1, r["id"])

    def test_reject_nowhere(self):
        everything = "".join(self.briefs.values()) + self.new_md
        self.assertNotIn("lesson-b|L02|1", everything)

    def test_gaps_placed_once(self):
        for k in ("t#1", "t#2", "t#3"):
            n = sum(("`%s`" % k) in b for b in self.briefs.values())
            self.assertEqual(n, 1, k)
        for k in ("t#4", "t#5"):
            self.assertIn("`%s`" % k, self.new_md)
        everything = "".join(self.briefs.values()) + self.new_md
        self.assertNotIn("`t#6`", everything)
        self.assertNotIn("`t#7`", everything)
        self.assertEqual(self.new_md.count("## Big Topic"), 1)

    def test_markers(self):
        a = self.briefs["lesson-a"]
        self.assertIn("FILIPINO SECTION", a)
        self.assertIn("add only if it fits", self.briefs["lesson-b"])
        self.assertIn("never removes a case another tagged exam needs", a)
        self.assertIn("cse-professional, upcat", a)

    def test_sections_in_order(self):
        a = self.briefs["lesson-a"]
        heads = [l for l in a.splitlines() if l.startswith("## ")]
        self.assertEqual(heads, ["## Fix these", "## CSE teaching to add",
                                 "## Optional, fix only if editing that passage anyway",
                                 "## Figures", "## Rules cited"])
        self.assertTrue(a.startswith("# Brief: Lesson A"))

    def test_rules_cited_text_once(self):
        b = self.briefs["lesson-b"]
        self.assertEqual(b.count(self.rules["B01"]), 1)  # figure row only
        self.assertEqual(b.count(self.rules["L22a"]), 1)
        a = self.briefs["lesson-a"]
        self.assertIn(self.rules["B01"], a)
        self.assertIn(self.rules["L02"], a)  # judgment row

    def test_missing_rule_reported(self):
        _, _, st = bb.build_briefs([t("lesson-a|ZZ9|0", "lesson-a", "ZZ9", "real")], [], TAGS, self.rules)
        self.assertEqual(st["missing_rules"], ["ZZ9"])

    def test_deterministic(self):
        again = bb.build_briefs(list(reversed(TRIAGE)), list(reversed(GAPS)), TAGS, self.rules)
        self.assertEqual(again[0], self.briefs)
        self.assertEqual(again[1], self.new_md)

    def test_write_idempotent(self):
        with tempfile.TemporaryDirectory() as d:
            bb.write_all(self.briefs, self.new_md, d)
            first = {f: rd(os.path.join(d, f)) for f in os.listdir(d)}
            bb.write_all(self.briefs, self.new_md, d)
            second = {f: rd(os.path.join(d, f)) for f in os.listdir(d)}
            self.assertEqual(first, second)
            self.assertIn("new-lessons.md", first)


class RealInputTests(unittest.TestCase):
    @unittest.skipUnless(os.path.exists(bb.DEFAULT_TRIAGE) and os.path.exists(bb.DEFAULT_GAPS)
                         and os.path.exists(bb.DEFAULT_TAGS), "audit inputs not present")
    def test_real_inputs(self):
        triage = bb.read_jsonl(bb.DEFAULT_TRIAGE)
        gaps = bb.read_jsonl(bb.DEFAULT_GAPS)
        tags = bb.load_tags(bb.DEFAULT_TAGS, bb.WORKTREE)
        rules = bb.parse_checklist(bb.git_show("docs/content/content-checklist.md"))
        with tempfile.TemporaryDirectory() as d1, tempfile.TemporaryDirectory() as d2:
            for d in (d1, d2):
                briefs, new_md, stats = bb.build_briefs(triage, gaps, tags, rules)
                bb.write_all(briefs, new_md, d)
            for f in sorted(os.listdir(d1)):
                self.assertEqual(rd(os.path.join(d1, f)),
                                 rd(os.path.join(d2, f)))
            self.assertEqual(sorted(os.listdir(d1)), sorted(os.listdir(d2)))
            texts = {f: rd(os.path.join(d1, f)) for f in os.listdir(d1)}
            briefs_text = [v for k, v in texts.items() if k != "new-lessons.md"]
            all_text = "".join(texts.values())
            for r in triage:
                n = sum(("`%s`" % r["id"]) in b for b in briefs_text)
                if r["verdict"] == "real":
                    self.assertEqual(n, 1, r["id"])
                elif r["verdict"] == "reject":
                    self.assertNotIn("`%s`" % r["id"], all_text)
            for gp in gaps:
                kind, _ = bb.parse_place(gp["place"])
                key = "`%s`" % gp["key"]
                if gp["duplicate_of"] or kind == "skip":
                    self.assertNotIn(key, all_text, gp["key"])
                elif kind == "new":
                    self.assertEqual(texts["new-lessons.md"].count(key), 1, gp["key"])
                    self.assertEqual(sum(key in b for b in briefs_text), 0)
                else:
                    self.assertEqual(sum(key in b for b in briefs_text), 1, gp["key"])
                    self.assertNotIn(key, texts["new-lessons.md"])
            # every cited rule has its checklist row in the same brief
            for f, text in texts.items():
                if f == "new-lessons.md":
                    continue
                for line in text.split("## Rules cited")[1].splitlines():
                    self.assertNotIn("no row in the checklist", line, f)
                for r in triage:
                    if ("`%s`" % r["id"]) in text and r["verdict"] != "reject":
                        for rid in bb.rule_ids(r["rule"]):
                            self.assertIn(rules[rid], text.split("## Rules cited")[1], (f, rid))
            for lid in set(b for b in texts if b != "new-lessons.md"):
                self.assertTrue(os.path.exists(os.path.join(bb.WORKTREE, tags[lid[:-3]]["path"])), lid)


if __name__ == "__main__":
    unittest.main()
