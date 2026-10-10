import copy
import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import compare  # noqa: E402
import fixtures  # noqa: E402
import l4lib  # noqa: E402

Q_FACTOR = "Factoring is efficient when the quadratic has convenient factors."
Q_FACTOR_PART = "the quadratic has convenient factors"
Q_STANDARD = "A quadratic equation in $x$ can be written in standard form"
Q_TRAP = "Factoring only works when one side is zero."
ILLUSTRATION = {"status": "missing", "position_quote": Q_FACTOR, "description": "Area model of two factors",
                "why": "Shows the product", "priority": "medium", "method": "code", "kind": "concept"}


def forms():
    return fixtures.valid_form("A"), fixtures.valid_form("B")


def ruling_for(comparison, choices):
    return {"rulings": {item["id"]: {"ruling": choices[item["id"]], "quote": Q_FACTOR,
                                     "reason": "The lesson text supports this ruling."}
                        for item in comparison["items"]}}


class Compare(unittest.TestCase):
    def test_full_agreement_needs_no_deciding_chat(self):
        a, b = forms()
        result = compare.compare(a, b, seed=1)
        self.assertEqual(result["items"], [])
        self.assertEqual(result["rules"]["L17"]["state"], "agree_pass")
        self.assertEqual(result["rules"]["L11"]["state"], "agree_other")
        final = compare.apply_ruling(result)
        self.assertEqual(final["rules"]["L17"]["verdict"], "pass")
        self.assertEqual(final["rules"]["L17"]["source"], "both")

    def test_pass_against_fail_is_disputed(self):
        a, b = forms()
        a = fixtures.failing(a, "L17", Q_FACTOR)
        result = compare.compare(a, b, seed=1)
        self.assertEqual(result["rules"]["L17"]["state"], "disputed")
        self.assertEqual([(i["type"], i["rule"]) for i in result["items"]], [("disputed", "L17")])

    def test_different_non_verdicts_are_disputed(self):
        a, b = forms()
        b["rules"]["L11"] = {"verdict": "needs_source_check", "findings": [], "checked": [], "note": ""}
        self.assertEqual(compare.compare(a, b, seed=1)["rules"]["L11"]["state"], "disputed")

    def test_both_fail_on_the_same_text_agree(self):
        a, b = forms()
        a = fixtures.failing(a, "L17", Q_FACTOR)
        b = fixtures.failing(b, "L17", Q_FACTOR_PART, problem="This sentence states a claim without the formula.")
        result = compare.compare(a, b, seed=1)
        self.assertEqual(result["items"], [])
        self.assertEqual(result["rules"]["L17"]["findings"][0]["source"], "both")

    def test_both_fail_on_different_text_sends_each_finding_to_the_deciding_chat(self):
        a, b = forms()
        a = fixtures.failing(a, "L17", Q_STANDARD)
        b = fixtures.failing(b, "L17", Q_TRAP)
        result = compare.compare(a, b, seed=1)
        self.assertEqual(result["rules"]["L17"]["state"], "agree_fail")
        self.assertEqual(sorted(i["origin"] for i in result["items"]), ["A", "B"])

    def test_same_place_by_containment_and_by_shared_words(self):
        self.assertTrue(compare.same_place(Q_FACTOR, Q_FACTOR_PART))
        self.assertTrue(compare.same_place("Factoring is efficient when the quadratic", "when the quadratic has convenient factors"))
        self.assertFalse(compare.same_place(Q_STANDARD, Q_TRAP))

    def test_illustration_from_one_read_becomes_an_item(self):
        a, b = forms()
        a["illustrations"] = [ILLUSTRATION]
        result = compare.compare(a, b, seed=1)
        self.assertEqual(len(result["items"]), 1)
        self.assertIn("illustration", result["items"][0])
        b["illustrations"] = [dict(ILLUSTRATION, description="Rectangle split into factor areas")]
        agreed = compare.compare(a, b, seed=1)
        self.assertEqual(agreed["items"], [])
        self.assertEqual(agreed["illustrations"][0]["source"], "both")

    def test_public_items_do_not_reveal_which_read_wrote_what(self):
        a, b = forms()
        a = fixtures.failing(a, "L17", Q_FACTOR)
        a = fixtures.failing(a, "L26", Q_STANDARD)
        b = fixtures.failing(b, "L26", Q_TRAP)
        text = json.dumps(compare.public_items(compare.compare(a, b, seed=3)))
        self.assertNotIn("swap", text)
        self.assertNotIn("origin", text)

    def test_position_order_depends_on_the_seed(self):
        a, b = forms()
        a = fixtures.failing(a, "L17", Q_FACTOR)
        orders = {compare.compare(a, b, seed=s)["items"][0]["A"]["verdict"] for s in range(20)}
        self.assertEqual(orders, {"pass", "fail"})

    def test_same_seed_gives_the_same_result(self):
        a, b = forms()
        a = fixtures.failing(a, "L17", Q_FACTOR)
        self.assertEqual(compare.compare(a, b, seed=5), compare.compare(a, b, seed=5))


class CopyFlag(unittest.TestCase):
    def test_identical_free_text_is_flagged(self):
        a, b = forms()
        for form in (a, b):
            for entry in form["rules"].values():
                if entry["verdict"] == "pass":
                    entry["checked"] = ["Traced each formula in the examples back to Core Concept and found each one there."]
        self.assertTrue(compare.compare(a, b, seed=1)["copied"])

    def test_independent_wording_is_not_flagged(self):
        a, b = forms()
        for number, entry in enumerate(sorted(a["rules"].items())):
            entry[1]["checked"] = ["Read A check %d: followed the solution steps one at a time against the stem." % number]
        for number, entry in enumerate(sorted(b["rules"].items())):
            entry[1]["checked"] = ["Second reader, item %d. Core Concept states the idea before any worked example uses it." % number]
        self.assertFalse(compare.compare(a, b, seed=1)["copied"])

    def test_very_short_forms_are_not_judged(self):
        a, b = forms()
        for form in (a, b):
            for entry in form["rules"].values():
                entry["checked"], entry["note"] = [], ""
        self.assertFalse(compare.compare(a, b, seed=1)["copied"])


class Ruling(unittest.TestCase):
    def test_items_without_a_ruling_are_refused(self):
        a, b = forms()
        result = compare.compare(fixtures.failing(a, "L17", Q_FACTOR), b, seed=1)
        with self.assertRaises(l4lib.L4Error):
            compare.apply_ruling(result)

    def test_disputed_rule_takes_the_upheld_position(self):
        a, b = forms()
        result = compare.compare(fixtures.failing(a, "L17", Q_FACTOR), b, seed=1)
        item = result["items"][0]
        fail_label = "uphold_a" if item["A"]["verdict"] == "fail" else "uphold_b"
        pass_label = "uphold_b" if fail_label == "uphold_a" else "uphold_a"
        upheld = compare.apply_ruling(result, ruling_for(result, {item["id"]: fail_label}))
        self.assertEqual(upheld["rules"]["L17"]["verdict"], "fail")
        self.assertEqual(upheld["rules"]["L17"]["source"], "ruled")
        self.assertEqual(upheld["rules"]["L17"]["findings"][0]["source"], "ruled")
        cleared = compare.apply_ruling(result, ruling_for(result, {item["id"]: pass_label}))
        self.assertEqual(cleared["rules"]["L17"]["verdict"], "pass")
        self.assertEqual(cleared["rules"]["L17"]["findings"], [])

    def test_single_finding_is_kept_or_dropped(self):
        a, b = forms()
        a = fixtures.failing(a, "L17", Q_STANDARD)
        b = fixtures.failing(b, "L17", Q_TRAP)
        result = compare.compare(a, b, seed=1)
        first, second = [item["id"] for item in result["items"]]
        final = compare.apply_ruling(result, ruling_for(result, {first: "uphold", second: "reject"}))
        self.assertEqual(len(final["rules"]["L17"]["findings"]), 1)
        self.assertEqual(final["rules"]["L17"]["verdict"], "fail")
        self.assertEqual(len(final["rulings"]), 2)

    def test_ruling_does_not_change_the_comparison(self):
        a, b = forms()
        result = compare.compare(fixtures.failing(a, "L17", Q_FACTOR), b, seed=1)
        before = copy.deepcopy(result)
        compare.apply_ruling(result, ruling_for(result, {"I1": "uphold_a"}))
        self.assertEqual(result, before)


if __name__ == "__main__":
    unittest.main()
