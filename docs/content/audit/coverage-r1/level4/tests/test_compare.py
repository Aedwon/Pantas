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


def run(form_a, form_b, seed, lesson_text=fixtures.LESSON_TEXT):
    return compare.compare(form_a, form_b, seed, lesson_text)


def forms():
    return fixtures.valid_form("A"), fixtures.valid_form("B")


def ruling_for(comparison, choices):
    return {"rulings": {item["id"]: {"ruling": choices[item["id"]], "quote": Q_FACTOR,
                                     "reason": "The lesson text supports this ruling."}
                        for item in comparison["items"]}}


class Compare(unittest.TestCase):
    def test_full_agreement_needs_no_deciding_chat(self):
        a, b = forms()
        result = run(a, b, 1)
        self.assertEqual(result["items"], [])
        self.assertEqual(result["rules"]["L17"]["state"], "agree_pass")
        self.assertEqual(result["rules"]["L11"]["state"], "agree_other")
        final = compare.apply_ruling(result)
        self.assertEqual(final["rules"]["L17"]["verdict"], "pass")
        self.assertEqual(final["rules"]["L17"]["source"], "both")

    def test_pass_against_fail_is_disputed(self):
        a, b = forms()
        a = fixtures.failing(a, "L17", Q_FACTOR)
        result = run(a, b, 1)
        self.assertEqual(result["rules"]["L17"]["state"], "disputed")
        self.assertEqual([(i["type"], i["rule"]) for i in result["items"]], [("disputed", "L17")])

    def test_different_non_verdicts_are_disputed(self):
        a, b = forms()
        b["rules"]["L11"] = {"verdict": "needs_source_check", "findings": [], "checked": [], "note": ""}
        self.assertEqual(run(a, b, 1)["rules"]["L11"]["state"], "disputed")

    def test_both_fail_on_the_same_text_agree(self):
        a, b = forms()
        a = fixtures.failing(a, "L17", Q_FACTOR)
        b = fixtures.failing(b, "L17", Q_FACTOR_PART, problem="This sentence states a claim without the formula.")
        result = run(a, b, 1)
        self.assertEqual(result["items"], [])
        self.assertEqual(result["rules"]["L17"]["findings"][0]["source"], "both")

    def test_both_fail_on_different_text_sends_each_finding_to_the_deciding_chat(self):
        a, b = forms()
        a = fixtures.failing(a, "L17", Q_STANDARD)
        b = fixtures.failing(b, "L17", Q_TRAP)
        result = run(a, b, 1)
        self.assertEqual(result["rules"]["L17"]["state"], "agree_fail")
        self.assertEqual(sorted(i["origin"] for i in result["items"]), ["A", "B"])

    def test_same_place_by_containment_and_by_overlap(self):
        text = fixtures.LESSON_TEXT
        self.assertTrue(l4lib.same_place(Q_FACTOR, Q_FACTOR_PART, text))
        self.assertTrue(l4lib.same_place("Factoring is efficient when the quadratic", "when the quadratic has convenient factors", text))
        self.assertFalse(l4lib.same_place(Q_STANDARD, Q_TRAP, text))

    def test_findings_that_only_share_words_are_not_merged(self):
        # Review item 11: these two quotes share the words "the", "quadratic" and "factors"
        # but sit in different sentences, so they are two findings, not one.
        near_a = "A quadratic equation in $x$"
        near_b = "the quadratic has convenient factors"
        a, b = forms()
        a = fixtures.failing(a, "L17", near_a)
        b = fixtures.failing(b, "L17", near_b)
        result = run(a, b, 1)
        self.assertEqual(result["rules"]["L17"]["findings"], [])
        self.assertEqual(sorted(item["origin"] for item in result["items"]), ["A", "B"])

    def test_a_quote_that_occurs_twice_pairs_with_either_place(self):
        text = fixtures.LESSON_TEXT + "\nFactoring only works when one side is zero.\n"
        a, b = forms()
        result = run(fixtures.failing(a, "L17", Q_TRAP), fixtures.failing(b, "L17", Q_TRAP), 1, text)
        self.assertEqual(result["items"], [])
        self.assertEqual(result["rules"]["L17"]["findings"][0]["source"], "both")

    def test_illustration_from_one_read_becomes_an_item(self):
        a, b = forms()
        a["illustrations"] = [ILLUSTRATION]
        result = run(a, b, 1)
        self.assertEqual(len(result["items"]), 1)
        self.assertIn("illustration", result["items"][0])
        b["illustrations"] = [dict(ILLUSTRATION, description="Rectangle split into factor areas")]
        agreed = run(a, b, 1)
        self.assertEqual(agreed["items"], [])
        self.assertEqual(agreed["illustrations"][0]["source"], "both")

    def test_public_items_do_not_reveal_which_read_wrote_what(self):
        a, b = forms()
        a = fixtures.failing(a, "L17", Q_FACTOR)
        a = fixtures.failing(a, "L26", Q_STANDARD)
        b = fixtures.failing(b, "L26", Q_TRAP)
        text = json.dumps(compare.public_items(run(a, b, 3)))
        self.assertNotIn("swap", text)
        self.assertNotIn("origin", text)

    def test_position_order_depends_on_the_seed(self):
        a, b = forms()
        a = fixtures.failing(a, "L17", Q_FACTOR)
        orders = {run(a, b, s)["items"][0]["A"]["verdict"] for s in range(20)}
        self.assertEqual(orders, {"pass", "fail"})

    def test_same_seed_gives_the_same_result(self):
        a, b = forms()
        a = fixtures.failing(a, "L17", Q_FACTOR)
        self.assertEqual(run(a, b, 5), run(a, b, 5))


class CopyFlag(unittest.TestCase):
    def test_identical_free_text_is_flagged(self):
        a, b = forms()
        for form in (a, b):
            for entry in form["rules"].values():
                if entry["verdict"] == "pass":
                    entry["checked"] = ["Traced each formula in the examples back to Core Concept and found each one there."]
        self.assertTrue(run(a, b, 1)["copied"])

    def test_independent_wording_is_not_flagged(self):
        a, b = forms()
        for number, entry in enumerate(sorted(a["rules"].items())):
            entry[1]["checked"] = ["Read A check %d: followed the solution steps one at a time against the stem." % number]
        for number, entry in enumerate(sorted(b["rules"].items())):
            entry[1]["checked"] = ["Second reader, item %d. Core Concept states the idea before any worked example uses it." % number]
        self.assertFalse(run(a, b, 1)["copied"])

    SENTENCES = (
        "Core Concept introduces the standard form and the examples use it without any new symbol.",
        "The worked solution moves from the stem to the answer in numbered steps with none skipped.",
        "Each term is explained before it appears and the trap section names the case where factoring fails.",
        "The numbers in the stem are small enough that the arithmetic never becomes the point of the example.",
        "Nothing here assumes a skill taught only in a later topic, so the order of ideas holds together.",
    )

    def long_form(self, role, reword):
        form = fixtures.valid_form(role)
        for number, entry in enumerate(sorted(form["rules"].items())):
            if entry[1]["verdict"] == "pass":
                text = " ".join(self.SENTENCES[(number + step) % 5] for step in range(3))
                entry[1]["checked"] = [reword(text, number)]
        return form

    def test_a_lightly_reworded_long_copy_is_flagged(self):
        # Review item 3: with difflib's autojunk on, a reworded copy of this length scores near zero.
        a = self.long_form("A", lambda text, n: text)
        b = self.long_form("B", lambda text, n: text.replace("The ", "That ").replace("each", "every")
                           .replace(" is ", " was ").replace("never", "not"))
        self.assertGreater(len(compare._free_text(a)), 3000)
        self.assertGreaterEqual(compare.similarity(a, b), compare.COPY_RATIO)
        self.assertTrue(run(a, b, 1)["copied"])

    def test_two_long_independent_forms_are_not_flagged(self):
        a = self.long_form("A", lambda text, n: text)
        b = fixtures.valid_form("B")
        for number, entry in enumerate(sorted(b["rules"].items())):
            if entry[1]["verdict"] == "pass":
                entry[1]["checked"] = ["Item %d: I followed %s through the lesson and compared my result with the one printed there, "
                                       "then looked for any step that a ninth grader could not supply alone." % (
                                           number, ("the first example", "the second example", "the trap section", "the core idea")[number % 4])]
        self.assertGreater(len(compare._free_text(b)), 1500)
        self.assertLess(compare.similarity(a, b), compare.COPY_RATIO)
        self.assertFalse(run(a, b, 1)["copied"])

    def test_the_same_five_quotes_in_both_reads_are_flagged(self):
        quotes = [Q_FACTOR, Q_STANDARD, Q_TRAP, "Move every term to one side first.", "Write $(x-2)(x-3)=0$, so $x=2$ or $x=3$."]
        a, b = forms()
        for rule_id, quote in zip(("L17", "L18", "L19", "L25", "L26"), quotes):
            a = fixtures.failing(a, rule_id, quote, problem="Reader one says the first thing is wrong here.")
            b = fixtures.failing(b, rule_id, quote, problem="A completely different complaint about this text.")
        self.assertTrue(compare.same_quotes(a, b))
        self.assertTrue(run(a, b, 1)["copied"])
        b = fixtures.failing(b, "L26", Q_FACTOR_PART)
        self.assertFalse(compare.same_quotes(a, b))

    def test_very_short_forms_are_not_judged(self):
        a, b = forms()
        for form in (a, b):
            for entry in form["rules"].values():
                entry["checked"], entry["note"] = [], ""
        self.assertFalse(run(a, b, 1)["copied"])


class Ruling(unittest.TestCase):
    def test_items_without_a_ruling_are_refused(self):
        a, b = forms()
        result = run(fixtures.failing(a, "L17", Q_FACTOR), b, 1)
        with self.assertRaises(l4lib.L4Error):
            compare.apply_ruling(result)

    def test_disputed_rule_takes_the_upheld_position(self):
        a, b = forms()
        result = run(fixtures.failing(a, "L17", Q_FACTOR), b, 1)
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
        result = run(a, b, 1)
        first, second = [item["id"] for item in result["items"]]
        final = compare.apply_ruling(result, ruling_for(result, {first: "uphold", second: "reject"}))
        self.assertEqual(len(final["rules"]["L17"]["findings"]), 1)
        self.assertEqual(final["rules"]["L17"]["verdict"], "fail")
        self.assertEqual(len(final["rulings"]), 2)

    def test_ruling_does_not_change_the_comparison(self):
        a, b = forms()
        result = run(fixtures.failing(a, "L17", Q_FACTOR), b, 1)
        before = copy.deepcopy(result)
        compare.apply_ruling(result, ruling_for(result, {"I1": "uphold_a"}))
        self.assertEqual(result, before)

    def test_both_fail_on_different_text_and_every_finding_rejected_becomes_a_pass(self):
        # Review item 10: nothing supports the failure, so the rule must not stay "fail" with no finding.
        a, b = forms()
        a = fixtures.failing(a, "L17", Q_STANDARD)
        b = fixtures.failing(b, "L17", Q_TRAP)
        result = run(a, b, 1)
        final = compare.apply_ruling(result, ruling_for(result, {i["id"]: "reject" for i in result["items"]}))
        self.assertEqual(final["rules"]["L17"]["verdict"], "pass")
        self.assertEqual(final["rules"]["L17"]["state"], "ruled")
        self.assertEqual(final["rules"]["L17"]["source"], "ruled")
        self.assertEqual(final["rules"]["L17"]["findings"], [])
        # A rule that failed with a finding both reads agree on is not touched.
        agreed = run(fixtures.failing(a, "L26", Q_FACTOR), fixtures.failing(b, "L26", Q_FACTOR_PART), 1)
        self.assertEqual(compare.apply_ruling(agreed, ruling_for(agreed, {i["id"]: "reject" for i in agreed["items"]}))
                         ["rules"]["L26"]["verdict"], "fail")


if __name__ == "__main__":
    unittest.main()
