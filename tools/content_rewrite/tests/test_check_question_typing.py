"""Tests for tools/content_rewrite/check_question_typing.py.

Run as a script: python3 -I tools/content_rewrite/tests/test_check_question_typing.py
"""

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import check_question_typing as checker  # noqa: E402


def rules_in(yaml_text):
    """Return the rule numbers reported for a YAML snippet, in order."""
    return [rule for _, rule, _ in checker.find_problems(yaml_text)]


def choice(value):
    return f"choices:\n  - text: {value}\n    correct: true\n"


class Rule1DigitsTest(unittest.TestCase):
    def test_unquoted_digits_fail(self):
        self.assertEqual(rules_in(choice("18")), [1])

    def test_quoted_digits_pass(self):
        self.assertEqual(rules_in(choice('"18"')), [])
        self.assertEqual(rules_in(choice("'18'")), [])

    def test_digits_with_other_characters_pass(self):
        self.assertEqual(rules_in(choice("3-")), [])
        self.assertEqual(rules_in(choice("18 neutrons")), [])

    def test_trailing_comment_is_ignored(self):
        self.assertEqual(rules_in(choice("18 # answer")), [1])


class Rule2BooleanTest(unittest.TestCase):
    def test_unquoted_boolean_words_fail(self):
        for word in ("True", "false", "YES", "no", "On", "oFF"):
            with self.subTest(word=word):
                self.assertEqual(rules_in(choice(word)), [2])

    def test_quoted_boolean_words_pass(self):
        self.assertEqual(rules_in(choice('"True"')), [])
        self.assertEqual(rules_in(choice("'False'")), [])

    def test_words_that_only_contain_booleans_pass(self):
        self.assertEqual(rules_in(choice("Truthful")), [])
        self.assertEqual(rules_in(choice("Nothing")), [])


class Rule3MappingTest(unittest.TestCase):
    def test_unquoted_colon_space_fails(self):
        self.assertEqual(rules_in(choice("X states the opposite: Y")), [3])

    def test_quoted_colon_space_passes(self):
        self.assertEqual(rules_in(choice('"X states the opposite: Y"')), [])
        self.assertEqual(rules_in(choice("'X states the opposite: Y'")), [])

    def test_colon_without_space_passes(self):
        self.assertEqual(rules_in(choice("ratio 3:4")), [])


class Rule4EscapeTest(unittest.TestCase):
    def test_single_backslash_before_letter_fails(self):
        self.assertEqual(rules_in(choice(r'"$\times 2$"')), [4])

    def test_doubled_backslash_passes(self):
        self.assertEqual(rules_in(choice(r'"$\\times 2$"')), [])

    def test_doubled_then_single_backslash_fails(self):
        self.assertEqual(rules_in(choice(r'"$\\\times 2$"')), [4])

    def test_single_quoted_backslash_passes(self):
        self.assertEqual(rules_in(choice(r"'$\times 2$'")), [])

    def test_backslash_before_non_letter_passes(self):
        self.assertEqual(rules_in(choice(r'"50\%"')), [])


class BlockScalarTest(unittest.TestCase):
    def test_block_scalar_values_are_ignored(self):
        yaml_text = (
            "rationale: |\n"
            "  The answer is 18.\n"
            "  text: 18\n"
            "  stem: True\n"
            "  explanation: a: b\n"
            "  text: \"$\\times$\"\n"
            "stem: |-\n"
            "  text: 5\n"
        )
        self.assertEqual(rules_in(yaml_text), [])

    def test_check_resumes_after_block_scalar(self):
        yaml_text = "stem: |\n  line one\n  line two\ntext: 7\n"
        self.assertEqual(rules_in(yaml_text), [1])

    def test_folded_block_scalar_is_ignored(self):
        yaml_text = "explanation: >\n  text: 9\n"
        self.assertEqual(rules_in(yaml_text), [])

    def test_list_item_block_scalar_is_ignored(self):
        yaml_text = (
            "choices:\n"
            "  - text: |\n"
            "      18\n"
            "    correct: true\n"
        )
        self.assertEqual(rules_in(yaml_text), [])


class OneLineScalarTest(unittest.TestCase):
    def test_one_line_stem_is_checked(self):
        self.assertEqual(rules_in("stem: True\n"), [2])

    def test_one_line_explanation_and_rationale_are_checked(self):
        self.assertEqual(rules_in("explanation: 4\nrationale: a: b\n"), [1, 3])

    def test_empty_value_is_ignored(self):
        self.assertEqual(rules_in("stem:\n"), [])


class ReportTest(unittest.TestCase):
    def test_reports_line_number_and_value(self):
        yaml_text = "id: x\nchoices:\n  - text: 18\n  - text: \"ok\"\n"
        self.assertEqual(checker.find_problems(yaml_text), [(3, 1, "18")])

    def test_clean_file_has_no_problems(self):
        self.assertEqual(checker.find_problems("id: x\n"), [])


if __name__ == "__main__":
    unittest.main()
