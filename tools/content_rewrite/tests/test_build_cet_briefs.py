"""Tests for build_cet_briefs. Run: python3 -I tools/content_rewrite/tests/test_build_cet_briefs.py"""
import json
import os
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
import build_cet_briefs as bc  # noqa: E402

LESSON_ID = "lesson-chemistry-stoichiometry"
LESSON_PATH = "content/lessons/science/chemistry/stoichiometry.md"
LESSON_TEXT = '---\n_id: "%s"\ntitle: "Stoichiometry"\nestimatedMinutes: 14\n---\n\nBody.\n' % LESSON_ID

TOPIC_MD = """# Chemistry lesson structure audit

## Lesson findings

### lesson-chemistry-acids-bases-ph

Goal: Other lesson.

- Other bullet: explained; examples worked. x.py:1-2 (a). Requirement refs: upcat-L1.

Structure: retain. Fine.

### lesson-chemistry-stoichiometry

Goal: Use balanced reaction ratios.

- Mole-to-mole products: thin; examples thin. content/a.md:12-18 (a). Limits: none. Requirement refs: upcat-L161, ustet-L114.
- Mole-to-mass products: absent; examples none. content/a.md:12-18 (b). Requirement refs: upcat-L161.
- Limiting reactant: explained; examples worked. content/a.md:14-18 (c). Requirement refs: upcat-L144.
- Percent yield: named-only; examples worked. content/a.md:20-28 (d). Requirement refs: dcat-L082.
- Empirical formulas: explained; examples worked. content/a.md:30-42 (e). Requirement refs: local foundation.

Structure: split-candidate. Two goals. Proposal: split. Cost: new id.

Evidence: content/a.md:12-96.

### lesson-chemistry-thermodynamics-and-kinetics

Goal: Later.

## Explicit no-prerequisite accounting

Other text.
"""

ROWS_MD = """# Source requirement teaching findings, Level 3

## upcat

| Source record | Accepted statement | Level3 finding | Evidence |
|---|---|---|---|
| upcat-L161 | - Chemistry: the mole concept. [19]; **curriculum** | Observed local facets: explained=23, thin=3, absent=4. Complete compound scope/depth remains unestablished. | requirements/upcat.md:161; providers: science-chemistry |
| upcat-L145 | - Apply gas relationships. [8]; **weak** | Observed local facets: explained=14, named-only=1, absent=1. Complete. | requirements/upcat.md:145; providers: science-chemistry |
| upcat-L146 | - Explain kinetics. [6]; **weak** | Observed local facets: explained=8. Complete. | requirements/upcat.md:146; providers: science-chemistry |
| upcat-L200 | - Physics only. [6]; **weak** | Observed local facets: thin=5, absent=2. Complete. | requirements/upcat.md:200; providers: science-physics |
| upcat-L031 | Target cycle. | CONTEXT ACCOUNTED: source record | requirements/upcat.md:31; providers: explicit context/constraint/uncertainty |

## dcat

| Source record | Accepted statement | Level3 finding | Evidence |
|---|---|---|---|
| dcat-L082 | - Supported, curriculum: physical science. [12]; **official** | Observed local facets: absent=4, thin=7, explained=21. Complete. | requirements/dcat.md:82; providers: science-chemistry, science-physics |

## pupcet

| Source record | Accepted statement | Level3 finding | Evidence |
|---|---|---|---|
| pupcet-L115 | - Chemical change. [8]; **curriculum** | Observed local facets: explained=9, absent=3, thin=1. Complete. | requirements/pupcet.md:115; providers: science-chemistry |
"""

TAGS = {
    "corpusCommit": "765c5dc0",
    "lessons": [
        {"subject": "science", "topic": "chemistry", "slug": "stoichiometry", "path": LESSON_PATH,
         "metadata__id": LESSON_ID, "metadata_title": "Stoichiometry",
         "provisionalExamTags": ["cse-professional", "dcat", "pupcet", "upcat"]},
    ],
}

def skill(name, teaching, examples, refs, limits=()):
    return {"name": name, "teachingVerdict": teaching, "exampleVerdict": examples,
            "requirementRefs": list(refs), "limitations": list(limits), "teachingEvidence": [], "exampleEvidence": []}


STRUCTURE = {"topicRecords": [
    {"subject": "science", "topic": "chemistry", "lessons": [
        {"id": LESSON_ID, "skills": [
            skill("Mole-to-mole products", "thin", "thin", ["upcat-L161", "ustet-L114"], ["Demand is inferred."]),
            skill("Mole-to-mass products", "absent", "none", ["upcat-L161"]),
            skill("Limiting reactant", "explained", "worked", ["upcat-L144"]),
            skill("Percent yield", "named-only", "worked", ["dcat-L082", "local foundation"]),
            skill("Empirical formulas", "explained", "thin", ["upcat-L999"], ["Composition not worked."]),
        ]},
        {"id": "lesson-chemistry-acids-bases-ph", "skills": [skill("Other", "explained", "worked", [])]},
    ]},
]}


class SectionTests(unittest.TestCase):
    def test_section_stops_at_next_heading(self):
        sec = bc.find_section(TOPIC_MD, LESSON_ID)
        self.assertIn("Goal: Use balanced reaction ratios.", sec)
        self.assertIn("Structure: split-candidate.", sec)
        self.assertNotIn("Later", sec)
        self.assertNotIn("Other bullet", sec)

    def test_section_ends_at_level_two_heading(self):
        sec = bc.find_section(TOPIC_MD, "lesson-chemistry-thermodynamics-and-kinetics")
        self.assertIn("Goal: Later.", sec)
        self.assertNotIn("Other text", sec)

    def test_missing_heading_returns_none(self):
        self.assertIsNone(bc.find_section(TOPIC_MD, "lesson-biology-cell-biology"))

    def test_heading_must_match_whole_id(self):
        self.assertIsNone(bc.find_section(TOPIC_MD, "lesson-chemistry-stoich"))

    def test_level_two_heading_is_accepted_and_ends_at_the_next_level_two_heading(self):
        md = ("# T\n\n## lesson-biology-cell-biology\n\n**Learning goal:** Identify parts.\n\n### Sub\n\nkept\n\n"
              "**Structure: split-candidate.** Two goals.\n\n## lesson-biology-botany\n\nother\n")
        heading, text = bc.find_section_with_heading(md, "lesson-biology-cell-biology")
        self.assertEqual(heading, "## lesson-biology-cell-biology")
        self.assertIn("kept", text)
        self.assertNotIn("other", text)

    def test_level_four_heading_is_not_accepted(self):
        md = "#### lesson-biology-cell-biology\n\ntext\n"
        self.assertIsNone(bc.find_section(md, "lesson-biology-cell-biology"))
        self.assertTrue(bc.id_in_a_heading(md, "lesson-biology-cell-biology"))

    def test_id_named_only_in_body_text_is_not_a_heading(self):
        md = "# T\n\n- `lesson-x-y`: path\n\n## Other\n"
        self.assertFalse(bc.id_in_a_heading(md, "lesson-x-y"))

    def test_bold_labels_parse(self):
        info = bc.parse_section("**Pinned body:** a.md:1-2\n\n**Learning goal:** Identify parts.\n\n"
                                "**Structure: split-candidate.** Two goals.\n")
        self.assertEqual(info["goal"], "Goal: Identify parts.")
        self.assertEqual(info["verdict"], "split-candidate")
        self.assertTrue(info["structure"].startswith("Structure: split-candidate."))

    def test_where_lists_other_exact_id_headings(self):
        md = "# T\n\n## lesson-biology-cell-biology\n\ntext\n"
        self.assertEqual(bc.where_id_appears(md, "lesson-biology-cell-biology"),
                         ["line 3: ## lesson-biology-cell-biology"])

    def test_goal_and_structure_parse(self):
        info = bc.parse_section(bc.find_section(TOPIC_MD, LESSON_ID))
        self.assertTrue(info["goal"].startswith("Goal: Use balanced"))
        self.assertTrue(info["structure"].startswith("Structure: split-candidate."))
        self.assertEqual(info["verdict"], "split-candidate")

    def test_section_without_structure_fails_loudly(self):
        with self.assertRaises(bc.BriefError):
            bc.parse_section("Goal: x.\n\n- A bullet.\n")

    def test_section_without_goal_fails_loudly(self):
        with self.assertRaises(bc.BriefError):
            bc.parse_section("Structure: retain. ok.\n")

    def test_facets_found_by_exact_id(self):
        facets = bc.lesson_facets(STRUCTURE, "science", "chemistry", LESSON_ID)
        self.assertEqual([f["name"] for f in facets][:2], ["Mole-to-mole products", "Mole-to-mass products"])
        self.assertEqual(facets[0]["refs"], ["upcat-L161", "ustet-L114"])
        self.assertEqual(facets[0]["limits"], ["Demand is inferred."])

    def test_facets_missing_lesson_fails_loudly(self):
        with self.assertRaises(bc.BriefError):
            bc.lesson_facets(STRUCTURE, "science", "chemistry", "lesson-chemistry-nope")
        with self.assertRaises(bc.BriefError):
            bc.lesson_facets(STRUCTURE, "science", "physics", LESSON_ID)


class RowTests(unittest.TestCase):
    def test_rows_parse_with_exam_and_providers(self):
        rows = bc.parse_rows(ROWS_MD)
        self.assertEqual(len(rows), 7)
        r = rows[0]
        self.assertEqual((r["exam"], r["id"]), ("upcat", "upcat-L161"))
        self.assertEqual(r["providers"], ["science-chemistry"])
        self.assertIn("**curriculum**", r["statement"])
        self.assertEqual(r["gaps"], {"thin": 3, "named-only": 0, "absent": 4})

    def test_select_keeps_topic_exam_and_gap_rows_only(self):
        rows = bc.parse_rows(ROWS_MD)
        picked, total = bc.select_rows(rows, "science-chemistry", ["dcat", "upcat", "cse-professional", "pupcet"], cap=25)
        ids = [r["id"] for r in picked]
        self.assertEqual(total, 3)
        # exam order is upcat, dcat, ustet, acet; pupcet and cse are not in scope
        self.assertEqual(ids, ["upcat-L161", "upcat-L145", "dcat-L082"])

    def test_select_cap_is_shared_across_exams(self):
        rows = bc.parse_rows(ROWS_MD)
        picked, total = bc.select_rows(rows, "science-chemistry", ["upcat", "dcat"], cap=2)
        self.assertEqual(total, 3)
        self.assertEqual([r["id"] for r in picked], ["upcat-L161", "dcat-L082"])

    def test_no_tagged_scope_exam_gives_no_rows(self):
        rows = bc.parse_rows(ROWS_MD)
        picked, total = bc.select_rows(rows, "science-chemistry", ["cse-professional"], cap=25)
        self.assertEqual((picked, total), ([], 0))


class BriefTests(unittest.TestCase):
    def build(self):
        shown = {
            ("BASE", LESSON_PATH): LESSON_TEXT,
            ("AUDIT", bc.AUDIT_DIR + "/lesson-exam-tags.json"): json.dumps(TAGS),
            ("AUDIT", bc.AUDIT_DIR + "/topics/science-chemistry-lessons.md"): TOPIC_MD,
            ("AUDIT", bc.AUDIT_DIR + "/requirement-teaching-findings.md"): ROWS_MD,
            ("AUDIT", bc.AUDIT_DIR + "/lesson-structure-data.json"): json.dumps(STRUCTURE),
        }

        def show(ref, path):
            return shown.get((ref, path))
        pilot = [{"lesson": "science/chemistry/stoichiometry", "writer": "sonnet", "reader": "sol"}]
        return bc.build_all(pilot, show, "BASE", "AUDIT")

    def test_brief_holds_the_required_parts(self):
        briefs, problems = self.build()
        self.assertEqual(problems, [])
        text = briefs[LESSON_ID]
        self.assertIn("Lesson id: `%s`" % LESSON_ID, text)
        self.assertIn("Lesson path: `%s`" % LESSON_PATH, text)
        self.assertIn("Tagged exams (as the audit writes them): cse-professional, dcat, pupcet, upcat", text)
        self.assertIn("no case that another tagged exam needs is removed", text)
        self.assertIn("- Limiting reactant: explained; examples worked.", text)  # verbatim section line
        self.assertIn("- Mole-to-mole products: thin; examples thin. Limits: Demand is inferred. "
                      "Requirement refs: upcat-L161, ustet-L114.", text)
        self.assertIn("- Mole-to-mass products: absent; examples none. Requirement refs: upcat-L161.", text)
        self.assertIn("- Percent yield: named-only; examples worked.", text)
        self.assertIn("Explained, but the examples are thin or missing:", text)
        self.assertIn("- Empirical formulas: examples thin. Limits: Composition not worked.", text)
        self.assertIn("- upcat-L161: [19]; **curriculum**", text)  # evidence class tail, as written
        self.assertIn("- local foundation: no row in requirement-teaching-findings.md. Class: not given.", text)
        self.assertIn("- upcat-L999: no row in requirement-teaching-findings.md. Class: not given.", text)
        self.assertIn("NOT TO APPLY", text)
        self.assertIn("Structure: split-candidate.", text)
        self.assertIn("upcat-L161", text)
        self.assertIn("**curriculum**", text)
        self.assertNotIn("upcat-L200", text)   # physics provider only
        self.assertNotIn("pupcet-L115", text)  # exam outside upcat, dcat, ustet, acet
        self.assertNotIn("upcat-L146", text)   # nothing thin, named-only or absent

    def test_output_is_deterministic(self):
        a, _ = self.build()
        b, _ = self.build()
        self.assertEqual(a, b)

    def test_lesson_missing_from_tags_is_a_problem(self):
        pilot = [{"lesson": "science/chemistry/stoichiometry", "writer": "sonnet", "reader": "sol"}]
        shown = {("BASE", LESSON_PATH): LESSON_TEXT,
                 ("AUDIT", bc.AUDIT_DIR + "/lesson-exam-tags.json"): json.dumps({"lessons": []}),
                 ("AUDIT", bc.AUDIT_DIR + "/requirement-teaching-findings.md"): ROWS_MD,
                 ("AUDIT", bc.AUDIT_DIR + "/lesson-structure-data.json"): json.dumps(STRUCTURE)}
        briefs, problems = bc.build_all(pilot, lambda r, p: shown.get((r, p)), "BASE", "AUDIT")
        self.assertEqual(briefs, {})
        self.assertEqual(len(problems), 1)
        self.assertIn(LESSON_ID, problems[0])

    def test_level_two_section_builds_a_brief(self):
        topic = ("# T\n\n## lesson-chemistry-stoichiometry\n\n**Learning goal:** Use ratios.\n\n"
                 "**Structure: retain.** Fine.\n\n## lesson-chemistry-other\n\nx\n")
        shown = {
            ("BASE", LESSON_PATH): LESSON_TEXT,
            ("AUDIT", bc.AUDIT_DIR + "/lesson-exam-tags.json"): json.dumps(TAGS),
            ("AUDIT", bc.AUDIT_DIR + "/topics/science-chemistry-lessons.md"): topic,
            ("AUDIT", bc.AUDIT_DIR + "/requirement-teaching-findings.md"): ROWS_MD,
            ("AUDIT", bc.AUDIT_DIR + "/lesson-structure-data.json"): json.dumps(STRUCTURE),
        }
        pilot = [{"lesson": "science/chemistry/stoichiometry", "writer": "sonnet", "reader": "sol"}]
        briefs, problems = bc.build_all(pilot, lambda r, p: shown.get((r, p)), "BASE", "AUDIT")
        self.assertEqual(problems, [])
        text = briefs[LESSON_ID]
        self.assertIn("section `## lesson-chemistry-stoichiometry`", text)
        self.assertIn("**Learning goal:** Use ratios.", text)
        self.assertIn("The audit recommends keeping the structure.", text)
        self.assertIn("- Mole-to-mass products: absent", text)

    def test_id_with_no_heading_uses_its_facets_and_says_so(self):
        topic = "# T\n\n## Findings\n\n- `%s` is discussed here by id.\n" % LESSON_ID
        structure = json.loads(json.dumps(STRUCTURE))
        structure["topicRecords"][0]["lessons"][0]["goal"] = "Use balanced reaction ratios."
        shown = {
            ("BASE", LESSON_PATH): LESSON_TEXT,
            ("AUDIT", bc.AUDIT_DIR + "/lesson-exam-tags.json"): json.dumps(TAGS),
            ("AUDIT", bc.AUDIT_DIR + "/topics/science-chemistry-lessons.md"): topic,
            ("AUDIT", bc.AUDIT_DIR + "/requirement-teaching-findings.md"): ROWS_MD,
            ("AUDIT", bc.AUDIT_DIR + "/lesson-structure-data.json"): json.dumps(structure),
        }
        pilot = [{"lesson": "science/chemistry/stoichiometry", "writer": "sonnet", "reader": "sol"}]
        briefs, problems = bc.build_all(pilot, lambda r, p: shown.get((r, p)), "BASE", "AUDIT")
        self.assertEqual(problems, [])
        text = briefs[LESSON_ID]
        self.assertIn("NO TOPIC SECTION", text)
        self.assertIn("which has no section for this lesson", text)
        self.assertIn("Goal: Use balanced reaction ratios.", text)
        self.assertIn("- Mole-to-mass products: absent; examples none.", text)
        self.assertIn("None attached.", text)
        self.assertNotIn("NOT TO APPLY", text)

    def test_id_with_no_heading_and_no_facets_fails_loudly(self):
        topic = "# T\n\nnothing\n"
        structure = {"topicRecords": [{"subject": "science", "topic": "chemistry", "lessons": []}]}
        shown = {
            ("BASE", LESSON_PATH): LESSON_TEXT,
            ("AUDIT", bc.AUDIT_DIR + "/lesson-exam-tags.json"): json.dumps(TAGS),
            ("AUDIT", bc.AUDIT_DIR + "/topics/science-chemistry-lessons.md"): topic,
            ("AUDIT", bc.AUDIT_DIR + "/requirement-teaching-findings.md"): ROWS_MD,
            ("AUDIT", bc.AUDIT_DIR + "/lesson-structure-data.json"): json.dumps(structure),
        }
        pilot = [{"lesson": "science/chemistry/stoichiometry", "writer": "sonnet", "reader": "sol"}]
        briefs, problems = bc.build_all(pilot, lambda r, p: shown.get((r, p)), "BASE", "AUDIT")
        self.assertEqual(briefs, {})
        self.assertEqual(len(problems), 1)
        self.assertIn("no record of the lesson", problems[0])

    def test_heading_at_an_unaccepted_level_is_reported_not_guessed(self):
        topic = TOPIC_MD.replace("### lesson-chemistry-stoichiometry", "#### lesson-chemistry-stoichiometry")
        shown = {
            ("BASE", LESSON_PATH): LESSON_TEXT,
            ("AUDIT", bc.AUDIT_DIR + "/lesson-exam-tags.json"): json.dumps(TAGS),
            ("AUDIT", bc.AUDIT_DIR + "/topics/science-chemistry-lessons.md"): topic,
            ("AUDIT", bc.AUDIT_DIR + "/requirement-teaching-findings.md"): ROWS_MD,
            ("AUDIT", bc.AUDIT_DIR + "/lesson-structure-data.json"): json.dumps(STRUCTURE),
        }
        pilot = [{"lesson": "science/chemistry/stoichiometry", "writer": "sonnet", "reader": "sol"}]
        briefs, problems = bc.build_all(pilot, lambda r, p: shown.get((r, p)), "BASE", "AUDIT")
        self.assertEqual(briefs, {})
        self.assertEqual(len(problems), 1)
        self.assertIn("other than ## or ###", problems[0])
        self.assertIn("#### lesson-chemistry-stoichiometry", problems[0])

    def test_frontmatter_id_must_match_the_tag_file(self):
        shown = {
            ("BASE", LESSON_PATH): LESSON_TEXT.replace(LESSON_ID, "lesson-other"),
            ("AUDIT", bc.AUDIT_DIR + "/lesson-exam-tags.json"): json.dumps(TAGS),
            ("AUDIT", bc.AUDIT_DIR + "/topics/science-chemistry-lessons.md"): TOPIC_MD,
            ("AUDIT", bc.AUDIT_DIR + "/requirement-teaching-findings.md"): ROWS_MD,
            ("AUDIT", bc.AUDIT_DIR + "/lesson-structure-data.json"): json.dumps(STRUCTURE),
        }
        pilot = [{"lesson": "science/chemistry/stoichiometry", "writer": "sonnet", "reader": "sol"}]
        briefs, problems = bc.build_all(pilot, lambda r, p: shown.get((r, p)), "BASE", "AUDIT")
        self.assertEqual(briefs, {})
        self.assertIn("lesson-other", problems[0])


class MainTests(unittest.TestCase):
    def test_pilot_file_lists_15_unique_lessons(self):
        path = os.path.join(bc.ROOT, bc.PILOT_REL)
        if not os.path.exists(path):
            self.skipTest("pilot.json not written yet")
        with open(path, encoding="utf-8") as f:
            pilot = json.load(f)["lessons"]
        self.assertEqual(len(pilot), 15)
        self.assertEqual(len({p["lesson"] for p in pilot}), 15)
        self.assertEqual(sum(1 for p in pilot if p["writer"] == "sonnet"), 15)
        for p in pilot:
            self.assertNotEqual(p["writer"], p["reader"])


if __name__ == "__main__":
    unittest.main()
