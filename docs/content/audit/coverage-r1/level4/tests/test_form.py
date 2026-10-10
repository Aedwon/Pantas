import copy
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import fixtures  # noqa: E402
import form  # noqa: E402

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

    def test_extra_rule_is_rejected(self):
        self.form["rules"]["L22"] = copy.deepcopy(self.form["rules"]["L17"])
        self.assert_one_reason(self.form, "L22")

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
        text = " ".join(reasons(candidate))
        self.assertNotIn("ZEBRA", text)


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
