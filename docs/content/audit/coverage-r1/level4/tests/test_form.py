import copy
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import fixtures  # noqa: E402
import form  # noqa: E402
import l4lib  # noqa: E402

REAL_QUOTE = "Factoring is efficient when the quadratic has convenient factors."


def reasons(candidate, role="A", packet=None, items=None):
    return form.validate(candidate, packet or fixtures.packet(), role, items)


class ReaderForm(unittest.TestCase):
    def setUp(self):
        self.form = fixtures.valid_form()

    def assert_one_reason(self, candidate, fragment, **kwargs):
        found = reasons(candidate, **kwargs)
        self.assertEqual(len(found), 1, found)
        self.assertIn(fragment, found[0])

    def test_valid_form_is_accepted(self):
        self.assertEqual(reasons(self.form), [])

    def test_blank_form_lists_every_chat_rule_and_is_rejected(self):
        blank = form.blank_form(fixtures.packet(), "A")
        self.assertEqual(sorted(blank["rules"]), sorted(self.form["rules"]))
        self.assertTrue(reasons(blank))

    def test_wrong_lesson_version_is_rejected(self):
        self.form["lesson_sha256"] = "0" * 64
        self.assert_one_reason(self.form, "lesson_sha256")

    def test_wrong_standards_version_is_rejected(self):
        self.form["standards_commit"] = "b" * 40
        self.assert_one_reason(self.form, "standards_commit")

    def test_wrong_role_is_rejected(self):
        self.assert_one_reason(self.form, "role", role="B")

    def test_missing_rule_is_rejected(self):
        del self.form["rules"]["L17"]
        self.assert_one_reason(self.form, "L17")

    def test_extra_rule_is_rejected_and_never_echoed(self):
        # An unknown key can carry any text, so the reason counts it and does not print it.
        self.form["rules"]["ZEBRA-KEY L22"] = copy.deepcopy(self.form["rules"]["L17"])
        found = reasons(self.form)
        self.assertEqual(len(found), 1, found)
        self.assertIn("1 rule ids", found[0])
        self.assertNotIn("ZEBRA", found[0])
        self.assertNotIn("L22", found[0])

    def test_unknown_verdict_is_rejected(self):
        self.form["rules"]["L17"]["verdict"] = "fine"
        self.assert_one_reason(self.form, "L17")

    def test_source_check_verdict_only_on_l11(self):
        self.form["rules"]["L17"]["verdict"] = "needs_source_check"
        self.assert_one_reason(self.form, "L17")

    def test_l11_cannot_be_pass(self):
        self.form["rules"]["L11"] = {"verdict": "pass", "findings": [], "checked": ["Checked the spelling."], "note": ""}
        self.assert_one_reason(self.form, "L11")

    def test_filipino_rules_apply_to_a_filipino_lesson(self):
        found = reasons(self.form, packet=fixtures.packet(filipino=True))
        self.assertEqual(len(found), 5, found)

    def test_fail_needs_a_finding(self):
        self.form["rules"]["L17"] = {"verdict": "fail", "findings": [], "checked": [], "note": ""}
        self.assert_one_reason(self.form, "L17")

    def test_fail_with_a_real_quote_is_accepted(self):
        self.assertEqual(reasons(fixtures.failing(self.form, "L17", REAL_QUOTE)), [])

    def test_invented_quote_is_rejected(self):
        self.assert_one_reason(fixtures.failing(self.form, "L17", "The lesson never says this sentence."), "quote")

    def test_short_problem_is_rejected(self):
        self.assert_one_reason(fixtures.failing(self.form, "L17", REAL_QUOTE, problem="Bad."), "problem")

    def test_pass_on_a_major_rule_needs_proof(self):
        self.form["rules"]["L17"]["checked"] = []
        self.assert_one_reason(self.form, "L17")

    def test_pass_on_a_minor_rule_needs_no_proof(self):
        self.form["rules"]["L03"]["checked"] = []
        self.assertEqual(reasons(self.form), [])

    def test_a_packet_can_add_a_candidate_rule(self):
        packet = dict(fixtures.packet(), rule_ids=sorted(self.form["rules"]) + ["B10"])
        found = reasons(self.form, packet=packet)
        self.assertEqual(len(found), 1, found)
        self.assertIn("B10", found[0])
        self.form["rules"]["B10"] = {"verdict": "pass", "findings": [], "note": "",
                                     "checked": ["Each flagged word is subject matter, not app wording."]}
        self.assertEqual(reasons(self.form, packet=packet), [])

    def test_not_applicable_needs_a_note(self):
        self.form["rules"]["L23"] = {"verdict": "not_applicable", "findings": [], "checked": [], "note": ""}
        self.assert_one_reason(self.form, "L23")

    def test_illustration_needs_allowed_values_and_a_real_position(self):
        good = {"status": "missing", "position_quote": REAL_QUOTE, "description": "Area model of the two factors",
                "why": "Shows why the factors multiply to the constant", "priority": "medium",
                "method": "code", "kind": "concept"}
        self.form["illustrations"] = [good]
        self.assertEqual(reasons(self.form), [])
        self.form["illustrations"] = [dict(good, priority="urgent")]
        self.assert_one_reason(self.form, "priority")
        self.form["illustrations"] = [dict(good, position_quote="Not in the lesson at all.")]
        self.assert_one_reason(self.form, "position_quote")

    def test_accuracy_concern_needs_a_real_quote(self):
        self.form["accuracy_concerns"] = [{"quote": "Not in the lesson at all.", "concern": "The value looks wrong here."}]
        self.assert_one_reason(self.form, "accuracy concern 1")

    def test_reasons_never_repeat_form_content(self):
        secret = "ZEBRA-PROBLEM-TEXT that explains the finding in detail"
        candidate = fixtures.failing(self.form, "L17", "An invented quote ZEBRA-QUOTE", problem=secret)
        candidate["rules"]["L26"]["checked"] = ["ZEBRA-CHECKED"]
        candidate["rules"]["L25"] = {"verdict": "ZEBRA-VERDICT", "findings": [], "checked": [], "note": ""}
        candidate["rules"]["ZEBRA-RULE"] = copy.deepcopy(candidate["rules"]["L18"])
        candidate["illustrations"] = [{"status": "ZEBRA-STATUS", "position_quote": "ZEBRA-POSITION"}]
        found = reasons(candidate)
        # The form really was checked: each fault is reported, so the test cannot pass on an accepted form.
        joined = " ".join(found)
        for fault in ("rule L17 finding 1", "rule L26", "rule L25", "1 rule ids", "illustration 1"):
            self.assertIn(fault, joined)
        self.assertGreaterEqual(len(found), 5)
        self.assertNotIn("ZEBRA", joined)
        self.assertNotIn("invented", joined)


class Hardening(unittest.TestCase):
    """Review items 1, 2 and 7."""

    def setUp(self):
        self.form = fixtures.valid_form()

    def not_applicable(self, rule_id):
        candidate = copy.deepcopy(self.form)
        candidate["rules"][rule_id] = {"verdict": "not_applicable", "findings": [], "checked": [],
                                       "note": "No part of this lesson gives this rule anything to judge."}
        return reasons(candidate)

    def test_only_the_listed_rules_may_be_not_applicable(self):
        self.assertEqual(form.NA_ALLOWED, ("L03", "L14", "L21", "L23", "L08", "L09", "L10", "L11", "L12"))
        for rule_id in form.NA_ALLOWED:
            self.assertEqual(self.not_applicable(rule_id), [], rule_id)

    def test_every_other_chat_rule_must_be_judged(self):
        refused = [rule_id for rule_id in sorted(self.form["rules"]) if rule_id not in form.NA_ALLOWED]
        self.assertIn("L17", refused)
        for rule_id in refused:
            found = self.not_applicable(rule_id)
            self.assertEqual(len(found), 1, (rule_id, found))
            self.assertIn("applies to every lesson", found[0])
            self.assertIn(rule_id, found[0])

    def test_the_same_proof_on_three_rules_is_refused_but_two_are_allowed(self):
        major = [rule["id"] for rule in l4lib.load_rules()
                 if rule["id"] in self.form["rules"] and self.form["rules"][rule["id"]]["verdict"] == "pass"
                 and form._needs_proof(rule)]
        self.assertGreaterEqual(len(major), 3)
        same = "traced every formula back to the place the lesson first introduces it"
        for rule_id in major[:2]:
            self.form["rules"][rule_id]["checked"] = [same]
        self.assertEqual(reasons(self.form), [])
        self.form["rules"][major[2]]["checked"] = [same.upper()]
        found = reasons(self.form)
        self.assertEqual(len(found), 1, found)
        self.assertIn("same checked text", found[0])
        self.assertTrue(all(rule_id in found[0] for rule_id in major[:3]))

    def test_a_quote_made_only_of_shared_lesson_text_is_refused(self):
        for boilerplate in ("## Core Concept", "**Solution:**", "isActive: true", "## Traps to Watch For"):
            found = reasons(fixtures.failing(self.form, "L17", boilerplate))
            self.assertEqual(len(found), 1, (boilerplate, found))
            self.assertIn("quote", found[0])
        # Real teaching text that merely sits under a heading is still a good quote.
        self.assertEqual(reasons(fixtures.failing(self.form, "L17", REAL_QUOTE)), [])

    def test_null_and_wrong_typed_fields_are_rejected_not_crashed(self):
        for key, bad in (("findings", None), ("findings", "none"), ("checked", None), ("checked", [None]),
                         ("checked", "text"), ("note", None), ("note", 5)):
            candidate = copy.deepcopy(self.form)
            candidate["rules"]["L17"][key] = bad
            found = reasons(candidate)
            self.assertEqual(len(found), 1, (key, bad, found))
            self.assertIn("L17", found[0])
            self.assertIn("never null", found[0])
        for bad_entry in (None, "pass", ["pass"], 7):
            candidate = copy.deepcopy(self.form)
            candidate["rules"]["L17"] = bad_entry
            self.assertEqual(len(reasons(candidate)), 1, bad_entry)
        for key, bad in (("rules", None), ("rules", []), ("illustrations", None), ("accuracy_concerns", None)):
            candidate = copy.deepcopy(self.form)
            candidate[key] = bad
            self.assertTrue(reasons(candidate), (key, bad))
        self.assertTrue(reasons([]))
        self.assertTrue(reasons(None))

    def test_a_reason_never_says_what_verdict_the_form_gave(self):
        # A pass with no proof and a fail with no finding must be rejected with the same words,
        # so the reasons posted to GitHub do not reveal which verdict a read chose.
        thin_pass = copy.deepcopy(self.form)
        thin_pass["rules"]["L17"]["checked"] = []
        thin_fail = copy.deepcopy(self.form)
        thin_fail["rules"]["L17"] = {"verdict": "fail", "findings": [], "checked": [], "note": ""}
        thin_na = copy.deepcopy(self.form)
        thin_na["rules"]["L23"] = {"verdict": "not_applicable", "findings": [], "checked": [], "note": ""}
        self.assertEqual(reasons(thin_pass), reasons(thin_fail))
        for found in (reasons(thin_pass), reasons(thin_fail), reasons(thin_na)):
            self.assertEqual(len(found), 1)
            self.assertNotRegex(found[0], r"(?i)\b(you|your form|it|verdict)\s+(is|was|gave|marked|said|chose)\b")
        wrong = copy.deepcopy(self.form)
        wrong["rules"]["L17"]["verdict"] = "ZEBRA-VERDICT"
        found = " ".join(reasons(wrong))
        self.assertNotIn("ZEBRA", found)

    def test_a_non_string_verdict_is_rejected(self):
        for bad in (["pass"], {"pass": 1}, 3, None, True):
            candidate = copy.deepcopy(self.form)
            candidate["rules"]["L17"]["verdict"] = bad
            self.assertEqual(len(reasons(candidate)), 1, bad)


class Clean(unittest.TestCase):
    def test_clean_drops_everything_that_is_not_a_known_field(self):
        candidate = fixtures.valid_form()
        candidate["ZEBRA-TOP"] = "carried along"
        candidate["rules"]["L17"]["ZEBRA-ENTRY"] = "carried along"
        candidate["rules"]["L17"]["checked"].append("x" * 20)
        candidate["accuracy_concerns"] = [{"quote": REAL_QUOTE, "concern": "The value looks wrong here.", "ZEBRA": 1}]
        cleaned = form.clean(candidate, "A")
        self.assertNotIn("ZEBRA", str(cleaned))
        self.assertEqual(sorted(cleaned["rules"]["L17"]), ["checked", "findings", "note", "verdict"])
        self.assertEqual(cleaned["rules"]["L17"]["checked"], candidate["rules"]["L17"]["checked"])


class DeciderForm(unittest.TestCase):
    ITEMS = [{"id": "I1", "type": "disputed"}, {"id": "I2", "type": "single"}]

    def decided(self):
        pkt = fixtures.packet()
        return {
            "packet": pkt["id"], "role": "D", "lesson_sha256": pkt["lesson_sha256"],
            "standards_commit": pkt["standards_commit"],
            "rulings": {
                "I1": {"ruling": "uphold_a", "quote": REAL_QUOTE, "reason": "Position A matches the lesson text."},
                "I2": {"ruling": "reject", "quote": REAL_QUOTE, "reason": "The lesson does explain this term."},
            },
        }

    def test_valid_ruling_is_accepted(self):
        self.assertEqual(reasons(self.decided(), role="D", items=self.ITEMS), [])

    def test_missing_item_is_rejected(self):
        candidate = self.decided()
        del candidate["rulings"]["I2"]
        found = reasons(candidate, role="D", items=self.ITEMS)
        self.assertEqual(len(found), 1)
        self.assertIn("I2", found[0])

    def test_ruling_must_fit_the_item_type(self):
        candidate = self.decided()
        candidate["rulings"]["I1"]["ruling"] = "reject"
        found = reasons(candidate, role="D", items=self.ITEMS)
        self.assertEqual(len(found), 1)
        self.assertIn("I1", found[0])

    def test_ruling_needs_a_real_quote_and_a_reason(self):
        candidate = self.decided()
        candidate["rulings"]["I1"]["quote"] = "Nowhere in the lesson."
        candidate["rulings"]["I2"]["reason"] = "No."
        self.assertEqual(len(reasons(candidate, role="D", items=self.ITEMS)), 2)


if __name__ == "__main__":
    unittest.main()
