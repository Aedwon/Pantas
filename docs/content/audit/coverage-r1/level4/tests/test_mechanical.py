import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import fixtures  # noqa: E402
import mechanical  # noqa: E402

PARTS = ("mathematics", "algebra", "quadratic-equations")


def rules(text, candidate=False, parts=PARTS):
    return sorted({f["rule"] for f in mechanical.check_lesson(text, parts) if f["candidate"] == candidate})


def with_line(line, after="## Core Concept\n"):
    return fixtures.LESSON_TEXT.replace(after, after + "\n" + line + "\n", 1)


class Definite(unittest.TestCase):
    def test_clean_lesson_has_no_definite_finding(self):
        self.assertEqual(rules(fixtures.LESSON_TEXT), [])

    def test_em_dash(self):
        self.assertEqual(rules(with_line("Roots — also called zeros.")), ["B06"])

    def test_top_level_frac(self):
        self.assertEqual(rules(with_line("The root is $\\frac{a}{b}$.")), ["B08"])

    def test_dfrac_and_nested_frac_are_allowed(self):
        self.assertEqual(rules(with_line("The root is $\\dfrac{\\frac{a}{b}}{c}$.")), [])

    def test_frac_after_a_closed_fraction_is_top_level(self):
        self.assertEqual(mechanical.top_level_fracs("\\dfrac{a}{b}+\\frac{c}{d}"), [13])

    def test_bracket_math(self):
        self.assertEqual(rules(with_line("The root is \\(x\\).")), ["B08"])

    def test_table_link_code_and_rule(self):
        for line in ("| a | b |", "See [the guide](http://example.com).", "```", "---"):
            self.assertEqual(rules(with_line(line)), ["L22"], line)

    def test_example_heading_form_and_sequence(self):
        self.assertEqual(rules(fixtures.LESSON_TEXT.replace("### #1: Basic Factoring", "### Basic Factoring")), ["L20"])
        self.assertEqual(rules(fixtures.LESSON_TEXT.replace("### #1: Basic Factoring", "### #2: Basic Factoring")), ["L20"])

    def test_trap_without_blockquote(self):
        self.assertEqual(rules(fixtures.LESSON_TEXT.replace("> Move every term to one side first.\n", "")), ["L20"])

    def test_frontmatter_order_quoting_identity_and_minutes(self):
        text = fixtures.LESSON_TEXT
        swapped = text.replace('title: "Quadratic Equations"\nsummary: "Solve quadratic equations and describe their roots."',
                               'summary: "Solve quadratic equations and describe their roots."\ntitle: "Quadratic Equations"')
        for broken in (swapped, text.replace('title: "Quadratic Equations"', "title: Quadratic Equations"),
                       text.replace("lesson-algebra-quadratic-equations", "lesson-algebra-quadratics"),
                       text.replace("estimatedMinutes: 8", "estimatedMinutes: 5"),
                       text.replace("isActive: true", "isActive: false")):
            self.assertEqual(rules(broken), ["L24"])


class Candidates(unittest.TestCase):
    def test_clean_lesson_has_no_candidate(self):
        self.assertEqual(rules(fixtures.LESSON_TEXT, candidate=True), [])

    def test_patterns_that_need_a_reader(self):
        for line, rule in (("The colour of the graph helps.", "B07"), ("Each item is worth two marks.", "B09"),
                           ("Review these cards daily.", "B09"), ("The algorithm sorts the roots.", "B10"),
                           ("Read the WHOLE question.", "L13"), ("There are 3 cases.", "B08")):
            self.assertEqual(rules(with_line(line), candidate=True), [rule], line)
            self.assertEqual(rules(with_line(line)), [], line)

    def test_acronyms_math_and_comments_are_not_flagged(self):
        for line in ("Use PEMDAS here.", "Article XIII applies.", "There are $3$ cases.",
                     '<!-- FIGURE: {"kind":"SHAPE","n":3} -->'):
            self.assertEqual(rules(with_line(line), candidate=True), [], line)

    def test_unknown_section_title_is_a_candidate(self):
        text = fixtures.LESSON_TEXT.replace("## Traps to Watch For", "## Watch Out")
        self.assertEqual(rules(text, candidate=True), ["L16"])

    def test_subject_titles_are_allowed_for_that_subject_only(self):
        text = fixtures.LESSON_TEXT.replace("## Traps to Watch For", "## Key Terms")
        self.assertEqual(rules(text, candidate=True, parts=None), ["L16"])
        science = text.replace("subject-mathematics", "subject-science")
        self.assertEqual(rules(science, candidate=True, parts=None), [])


if __name__ == "__main__":
    unittest.main()
