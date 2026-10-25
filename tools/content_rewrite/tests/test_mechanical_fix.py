"""Tests for tools/content_rewrite/mechanical_fix.py.

Run as a script: python3 -I tools/content_rewrite/tests/test_mechanical_fix.py
"""

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import mechanical_fix as mf  # noqa: E402

TOOL = str(Path(__file__).resolve().parents[1] / "mechanical_fix.py")
DASH = "—"

FRONT = ('---\n_id: "lesson-x-y"\ntitle: "T"\nsummary: "S"\nsubject: "subject-x"\ntopic: "topic-x"\n'
         "estimatedMinutes: 10\nisActive: true\n---\n")


def lesson(body):
    return FRONT + body


def fix(body, **kwargs):
    """Return the fixed body (frontmatter removed) and the result."""
    result = mf.analyze(lesson(body), **kwargs)
    return result["new_text"][len(FRONT):], result


def reasons(result, rule=None):
    return [r["reason"] for r in result["review"] if rule is None or r["rule"] == rule]


class SkipRules(unittest.TestCase):
    def assert_unchanged(self, body, review=False):
        new, result = fix(body)
        self.assertEqual(new, body)
        if not review:
            self.assertEqual(result["review"], [])
        return result

    def test_frontmatter_is_never_touched(self):
        result = mf.analyze(lesson("Plain.\n"))
        self.assertIn("estimatedMinutes: 10", result["new_text"])
        self.assertEqual(result["changes"], [])

    def test_headings_are_skipped(self):
        self.assert_unchanged("## Core Concept 2\n\n### #1: Add 5 and 6\n\n#### Part 3\n")

    def test_numbers_already_in_math(self):
        self.assert_unchanged("Add $5$ and $6.5$ to get $11.5\\%$.\n\n$$\n3 + 4 = 7\n$$\n\n$$ 8 \\times 9 $$\n")

    def test_list_markers(self):
        self.assert_unchanged("1. First step\n2) Second step\n> 3. In a quote\n**4. A bold label**\n")

    def test_example_title(self):
        self.assert_unchanged("## Examples\n\n### #1: Nested Grouping Symbols\n\nText.\n")

    def test_years(self):
        self.assert_unchanged("The law was signed in 1987 and amended in 2019.\n")

    def test_year_followed_by_unit_is_flagged_not_skipped(self):
        _, result = fix("The vault holds 1500 pesos.\n")
        self.assertIn("four-digit number that may be a quantity", reasons(result))

    def test_statute_and_section_identifiers(self):
        for text in ("RA 6713 sets the code.\n", "Republic Act No. 6713 sets the code.\n",
                     "R.A. 9003 is the waste act.\n", "See Section 8 of the act.\n",
                     "Sections 7, 8, or 9 apply.\n", "Sections 12 to 22 apply.\n",
                     "Article III, Section 2 applies.\n", "Sec. 4 applies.\n", "Article 3 applies.\n",
                     "PD 1586 set up the system.\n", "Section 8(D) applies.\n",
                     "RA 7586, as amended by RA 11038, applies.\n"):
            with self.subTest(text=text):
                self.assert_unchanged(text)

    def test_times(self):
        self.assert_unchanged("The light was on at 3 a.m. and the bell rang at 10:30 and at 8 PM.\n")

    def test_ordinal_words_have_no_digits(self):
        self.assert_unchanged("The first, second, and third steps come in order.\n")

    def test_numbers_in_quoted_passages(self):
        for text in ('The passage says "the bridge spans 1,280 meters" clearly.\n',
                     'The passage says “the stock fell 15% today” clearly.\n',
                     'It reads "First line 10\nsecond line 11" overall.\n'):
            with self.subTest(text=text):
                result = self.assert_unchanged(text)
                self.assertGreaterEqual(result["skipped"]["quoted passage"], 1)

    def test_urls(self):
        self.assert_unchanged("See https://example.com/page2?x=15 for more.\n")

    def test_link_target_and_inline_code(self):
        self.assert_unchanged("Use `12.05` here and ![fig](img/figure2.svg) there.\n")

    def test_html_comments_one_line_and_multi_line(self):
        self.assert_unchanged("<!-- ILLUSTRATION: triangle with legs 3 and 4 -->\n"
                              "<!-- ILLUSTRATION: a grid\nwith 5 rows and 6 columns\n-->\n")

    def test_letters_with_digits_and_dimension_terms(self):
        self.assert_unchanged("Water is H2O and a 3D shape.\n")

    def test_hash_reference(self):
        self.assert_unchanged("See trap #2 for details.\n")

    def test_fenced_code_is_skipped(self):
        self.assert_unchanged("```\nx = 15\n```\n")


class NumberFixes(unittest.TestCase):
    def test_plain_number(self):
        new, result = fix("Respond within 15 working days.\n")
        self.assertEqual(new, "Respond within $15$ working days.\n")
        self.assertEqual(result["counts"]["B08"], 1)

    def test_percent_decimal_thousands_hyphen(self):
        new, _ = fix("Use 10% of 4.5 meters across 7,000 islands for an 8-year-old.\n")
        self.assertEqual(new, "Use $10\\%$ of $4.5$ meters across $7,000$ islands for an $8$-year-old.\n")

    def test_bold_and_blockquote_and_list_body(self):
        new, _ = fix("> The answer is **24** sides.\n- Item with 5 parts\n3. Count 12 items\n")
        self.assertEqual(new, "> The answer is **$24$** sides.\n- Item with $5$ parts\n3. Count $12$ items\n")

    def test_multiple_numbers_one_line(self):
        new, result = fix("Between 30 and 60 days, then 10 more.\n")
        self.assertEqual(new, "Between $30$ and $60$ days, then $10$ more.\n")
        self.assertEqual(result["counts"]["B08"], 3)

    def test_number_after_math_on_same_line(self):
        new, _ = fix("Given $x = 2$, move 3 places.\n")
        self.assertEqual(new, "Given $x = 2$, move $3$ places.\n")

    def test_range_of_hyphenated_words(self):
        new, _ = fix("The 0-to-14 scale.\n")
        self.assertEqual(new, "The $0$-to-$14$ scale.\n")

    def test_bare_statute_numbers_not_wrapped_but_amounts_beside_them_are(self):
        new, _ = fix("Under RA 6713, report within 30 days.\n")
        self.assertEqual(new, "Under RA 6713, report within $30$ days.\n")


class NumberReviews(unittest.TestCase):
    def check(self, text, reason_part):
        new, result = fix(text)
        self.assertEqual(new, text, "flagged text must not change")
        self.assertTrue(any(reason_part in r for r in reasons(result, "B08")), reasons(result))

    def test_labels(self):
        self.check("Gear 1 turns clockwise.\n", "label number")
        self.check("See Example 3 above.\n", "label number")

    def test_dates(self):
        self.check("It was signed on March 15 this year.\n", "date")

    def test_currency(self):
        self.check("A fine of up to P5,000 applies.\n", "currency")
        self.check("It costs ₱2 million.\n", "currency")

    def test_arithmetic_in_prose(self):
        self.check("Add 1 + 2 to get 3.\n", "arithmetic")

    def test_hyphenated_name_ordinal_range_ratio_degree(self):
        self.check("Carbon-14 decays.\n", "hyphenated name")
        self.check("The 1st and 2nd terms differ.\n", "ordinal suffix")
        self.check("Use 10-15 items.\n", "range")
        self.check("The ratio is 85:81 here.\n", "ratio")
        self.check("At 25 °C water boils.\n", "degree")

    def test_arithmetic_line_leaves_every_number_alone(self):
        text = "1 Chairman + 2 Commissioners = 3 members in total.\n"
        new, result = fix("2. " + text)
        self.assertEqual(new, "2. " + text)
        self.assertEqual(len(result["changes"]), 0)

    def test_unbalanced_dollar(self):
        self.check("It costs $5 today.\n", "unmatched dollar")

    def test_reviews_on_one_line_merge(self):
        _, result = fix("On March 15 and June 1 we met.\n")
        self.assertEqual(len(result["review"]), 1)
        self.assertEqual(result["review"][0]["occurrences"], 2)


class DashChoice(unittest.TestCase):
    def test_label_takes_a_colon(self):
        new, _ = fix("**Mean** " + DASH + " the average of the values.\n")
        self.assertEqual(new, "**Mean**: the average of the values.\n")

    def test_after_intro_word_takes_a_colon(self):
        new, _ = fix("The rule for dates and times is " + DASH + " compare year first.\n")
        self.assertEqual(new, "The rule for dates and times is: compare year first.\n")

    def test_side_remark_takes_a_comma(self):
        new, _ = fix("The goal is clear reference" + DASH + "not guessing every time.\n")
        self.assertEqual(new, "The goal is clear reference, not guessing every time.\n")

    def test_pair_becomes_two_commas(self):
        new, _ = fix("Selected traits " + DASH + " often physical or behavioral " + DASH + " are exaggerated.\n")
        self.assertEqual(new, "Selected traits, often physical or behavioral, are exaggerated.\n")

    def test_spaces_are_normalized(self):
        new, _ = fix("A long sentence about records " + DASH + " such as names and dates.\n")
        self.assertEqual(new, "A long sentence about records, such as names and dates.\n")

    def test_unsure_is_flagged_and_unchanged(self):
        text = "A long enough clause about the arrows" + DASH + "from the eaten organism to the consumer.\n"
        new, result = fix(text)
        self.assertEqual(new, text)
        self.assertEqual(len(reasons(result, "B06")), 1)

    def test_dash_after_quotation_or_punctuation_is_flagged(self):
        for text in ('- "She writes." ' + DASH + " can express habits.\n",
                     "He said it, " + DASH + " later.\n"):
            with self.subTest(text=text):
                new, result = fix(text)
                self.assertEqual(new, text)
                self.assertEqual(len(reasons(result, "B06")), 1)

    def test_dash_at_end_of_text_is_flagged(self):
        text = "The sentence trails off " + DASH + "\n"
        new, result = fix(text)
        self.assertEqual(new, text)
        self.assertEqual(len(reasons(result, "B06")), 1)

    def test_quoted_passage_is_flagged_not_changed(self):
        text = 'The source reads "wait ' + DASH + ' stop now" in full.\n'
        new, result = fix(text)
        self.assertEqual(new, text)
        self.assertIn("em dash inside quote", reasons(result, "B06")[0])

    def test_headings_and_tables_are_flagged_not_changed(self):
        text = "## Title " + DASH + " part\n\n| a | " + DASH + " |\n"
        new, result = fix(text)
        self.assertEqual(new, text)
        self.assertEqual(len(reasons(result, "B06")), 2)

    def test_frontmatter_dash_is_flagged(self):
        text = FRONT.replace('title: "T"', 'title: "A ' + DASH + ' B"') + "Body.\n"
        result = mf.analyze(text)
        self.assertEqual(result["new_text"], text)
        self.assertEqual(result["review"][0]["reason"], "em dash in frontmatter")


class Protection(unittest.TestCase):
    def test_math_code_and_comments_keep_their_dashes_and_numbers(self):
        body = ("Inline $a " + DASH + " b = 5$ stays.\n"
                "Code `x " + DASH + " 5` stays.\n"
                "<!-- ILLUSTRATION: a " + DASH + " b with 7 parts -->\n"
                "<!-- ILLUSTRATION: line one " + DASH + "\nline two 8 " + DASH + " end\n-->\n"
                "$$\na " + DASH + " 9\n$$\n"
                "```\nfenced " + DASH + " 10\n```\n")
        new, result = fix(body)
        self.assertEqual(new, body)
        flagged = [r["reason"] for r in result["review"]]
        self.assertEqual(len(flagged), 7, flagged)

    def test_wrap_never_touches_text_inside_math_on_a_mixed_line(self):
        new, _ = fix("Compute $3 \\times 4$ in 2 steps.\n")
        self.assertEqual(new, "Compute $3 \\times 4$ in $2$ steps.\n")

    def test_number_touching_math_is_flagged(self):
        text = "The value $x$5 appears.\n"
        new, result = fix(text)
        self.assertEqual(new, text)
        self.assertTrue(reasons(result, "B08"))


class HeadingFormat(unittest.TestCase):
    def test_out_of_sequence_number_is_renumbered(self):
        body = "## Examples\n\n### #1: One\n\n### #3: Two\n"
        new, _ = fix(body)
        self.assertEqual(new, "## Examples\n\n### #1: One\n\n### #2: Two\n")

    def test_unambiguous_variant_is_fixed(self):
        new, _ = fix("## Traps to Watch For\n\n### #1 Mixing signs\n> Careful.\n")
        self.assertIn("### #1: Mixing signs", new)

    def test_unknown_form_is_flagged(self):
        body = "## Examples\n\n### Plain title\n"
        new, result = fix(body)
        self.assertEqual(new, body)
        self.assertEqual(result["review"][0]["rule"], "L20")

    def test_only_the_listed_lines_are_touched(self):
        body = "## Examples\n\n### #1: One\n\n### #3: Two\n"
        new, _ = fix(body, only_l20_lines=set())
        self.assertEqual(new, body)
        line = len(FRONT.split("\n")) + 4
        new, _ = fix(body, only_l20_lines={line})
        self.assertIn("### #2: Two", new)

    def test_headings_outside_examples_and_traps_are_ignored(self):
        body = "## Core Concept\n\n### Any Title\n"
        new, result = fix(body)
        self.assertEqual(new, body)
        self.assertEqual(result["review"], [])

    def test_trap_without_warning_is_listed_not_changed(self):
        body = "## Traps to Watch For\n\n### #1: No warning\n\nA paragraph only.\n\n### #2: Has one\n> Warn.\n\nText.\n"
        new, result = fix(body)
        self.assertEqual(new, body)
        self.assertEqual([t["text"] for t in result["l20_unautomated"]], ["### #1: No warning"])


class TablesListedOnly(unittest.TestCase):
    def test_table_is_listed_and_unchanged(self):
        body = "Intro.\n\n| a | b |\n|---|---|\n| 1 | 2 |\n\nAfter 5 steps.\n"
        new, result = fix(body)
        self.assertEqual(new, "Intro.\n\n| a | b |\n|---|---|\n| 1 | 2 |\n\nAfter $5$ steps.\n")
        tables = [b for b in result["l22"] if b["kind"] == "table"]
        self.assertEqual(len(tables), 1)
        self.assertEqual(tables[0]["rows"], 3)

    def test_link_rule_and_code_fence_are_listed(self):
        body = "A [link](http://x.org) here.\n\n---\n\n```\ncode\n```\n"
        _, result = fix(body)
        kinds = sorted(b["kind"] for b in result["l22"])
        self.assertEqual(kinds, ["code block", "code block", "horizontal rule", "link"])


class Idempotence(unittest.TestCase):
    BODY = ("## Examples\n\n### #2: Wrong number\n\nWithin 15 days, which is 10% of 7,000 " + DASH + " roughly.\n\n"
            "**Mean** " + DASH + " the average.\n\nBy RA 6713 and in 1987, Gear 2 spins " + DASH + "why?\n\n"
            "Selected traits " + DASH + " often rare " + DASH + " are shown.\n")

    def test_second_pass_changes_nothing(self):
        first, result1 = fix(self.BODY)
        self.assertNotEqual(first, self.BODY)
        second, result2 = fix(first)
        self.assertEqual(second, first)
        self.assertEqual(result2["changes"], [])

    def test_flagged_items_survive_unchanged(self):
        first, result1 = fix(self.BODY)
        _, result2 = fix(first)
        self.assertEqual(len(result1["review"]), len(result2["review"]))


class CommandLine(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.ids = ["lesson-a-one", "lesson-a-two"]
        index = {}
        for n, lid in enumerate(self.ids):
            rel = "content/lessons/s/t/%d.md" % n
            path = self.root / rel
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(lesson("Wait 15 days " + DASH + " not 5.\n\nReview Gear 3.\n\nThe set has 10% done.\n"),
                            encoding="utf-8")
            index["L4-%d" % n] = {"lesson_id": lid, "source": rel, "lesson_sha256": "x"}
        self.index = self.root / "index.json"
        self.index.write_text(json.dumps(index), encoding="utf-8")

    def tearDown(self):
        self.tmp.cleanup()

    def run_tool(self, *extra):
        cmd = [sys.executable, "-I", TOOL, "--index", str(self.index), "--root", str(self.root),
               "--mechanical-dir", "", "--triage", ""] + list(extra)
        return subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)

    def text(self, n):
        return (self.root / ("content/lessons/s/t/%d.md" % n)).read_text(encoding="utf-8")

    def test_dry_run_writes_report_and_no_lesson(self):
        before = [self.text(0), self.text(1)]
        report = self.root / "out" / "report.json"
        proc = self.run_tool("--report", str(report))
        self.assertEqual(proc.returncode, 0, proc.stderr)
        self.assertEqual([self.text(0), self.text(1)], before)
        data = json.loads(report.read_text(encoding="utf-8"))
        self.assertEqual(data["mode"], "dry-run")
        self.assertEqual(data["lesson_count"], 2)
        self.assertIn("lesson-a-one", data["lessons"])
        self.assertIn("--- a/content/lessons/s/t/0.md", proc.stdout)
        self.assertIn("needs-review", proc.stdout)

    def test_apply_refuses_without_names(self):
        before = [self.text(0), self.text(1)]
        proc = self.run_tool("--apply")
        self.assertEqual(proc.returncode, 2)
        self.assertEqual([self.text(0), self.text(1)], before)

    def test_apply_refuses_unknown_name(self):
        before = [self.text(0), self.text(1)]
        proc = self.run_tool("--apply", "--i-reviewed", "lesson-nope")
        self.assertEqual(proc.returncode, 2)
        self.assertEqual([self.text(0), self.text(1)], before)

    def test_apply_touches_only_named_lessons_and_only_unflagged_edits(self):
        other = self.text(1)
        proc = self.run_tool("--apply", "--i-reviewed", "lesson-a-one")
        self.assertEqual(proc.returncode, 0, proc.stderr)
        self.assertEqual(self.text(1), other)
        new = self.text(0)
        self.assertIn("Wait $15$ days, not $5$.", new)
        self.assertIn("Review Gear 3.", new)
        self.assertIn("$10\\%$", new)

    def test_apply_twice_changes_nothing_the_second_time(self):
        self.run_tool("--apply", "--i-reviewed", "lesson-a-one,lesson-a-two")
        once = [self.text(0), self.text(1)]
        proc = self.run_tool("--apply", "--i-reviewed", "lesson-a-one,lesson-a-two")
        self.assertEqual(proc.returncode, 0, proc.stderr)
        self.assertEqual([self.text(0), self.text(1)], once)
        self.assertIn("0 lesson file(s)", proc.stderr)

    def test_lesson_with_carriage_returns_is_skipped(self):
        path = self.root / "content/lessons/s/t/0.md"
        path.write_bytes(lesson("Wait 15 days.\n").replace("\n", "\r\n").encode("utf-8"))
        before = path.read_bytes()
        proc = self.run_tool("--apply", "--i-reviewed", "lesson-a-one")
        self.assertEqual(proc.returncode, 0, proc.stderr)
        self.assertEqual(path.read_bytes(), before)


if __name__ == "__main__":
    unittest.main(verbosity=1)
