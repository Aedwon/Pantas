import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import build_packets  # noqa: E402
import fixtures  # noqa: E402
import l4lib  # noqa: E402
import mechanical  # noqa: E402

STANDARDS = {"guide": "GUIDE TEXT\n", "expected": "EXPECTED TEXT\n", "voice": "VOICE TEXT\n"}


def render(prerequisites=(), findings=(), rule_ids=None):
    packet = dict(fixtures.packet(), rule_ids=rule_ids or l4lib.chat_rule_ids())
    return build_packets.render(packet, fixtures.LESSON_TEXT, list(prerequisites),
                                {"goal": "Solve quadratics.", "skills": []}, list(findings), STANDARDS, "l4abc123")


class Render(unittest.TestCase):
    def test_packet_carries_the_lesson_verbatim_between_markers(self):
        text = render()
        start = text.index(build_packets.LESSON_START) + len(build_packets.LESSON_START) + 1
        end = text.index(build_packets.LESSON_END)
        self.assertEqual(text[start:end].rstrip("\n"), fixtures.LESSON_TEXT.rstrip("\n"))

    def test_packet_lists_every_rule_on_its_form(self):
        text = render()
        for rule_id in l4lib.chat_rule_ids():
            self.assertIn("| %s |" % rule_id, text)
            self.assertIn('"%s": {' % rule_id, text)

    def test_packet_includes_prerequisite_lessons_in_full(self):
        text = render(prerequisites=[("lesson-a", "FIRST PREREQUISITE BODY"), ("lesson-b", "SECOND PREREQUISITE BODY")])
        self.assertIn("FIRST PREREQUISITE BODY", text)
        self.assertIn("SECOND PREREQUISITE BODY", text)

    def test_candidate_rule_appears_with_its_flagged_lines(self):
        flagged = mechanical.check_lesson(fixtures.LESSON_TEXT.replace(
            "## Core Concept\n", "## Core Concept\n\nEach item is worth two marks.\n", 1))
        text = render(findings=flagged, rule_ids=l4lib.chat_rule_ids() + ["B09"])
        self.assertIn("| B09 |", text)
        self.assertIn("worth two marks", text.split("## Script candidates")[1].split("## Prerequisite")[0])

    def test_no_placeholder_is_left_unfilled(self):
        self.assertNotIn("{{", render())

    def test_hand_in_names_the_packet_token_and_script(self):
        text = render()
        self.assertIn("[relay] l4abc123 save L4-0417-ROLE", text)
        self.assertIn(build_packets.HANDIN, text)

    def test_packet_never_says_whether_it_is_planted(self):
        self.assertNotIn("planted", render().lower())


class Ids(unittest.TestCase):
    def test_same_seed_gives_the_same_ids(self):
        keys = ["b|0", "a|0", "a|1"]
        self.assertEqual(build_packets.assign_ids(keys, 7), build_packets.assign_ids(keys, 7))

    def test_ids_are_unique_and_do_not_follow_key_order(self):
        keys = ["lesson-%03d|0" % number for number in range(170)]
        ids = build_packets.assign_ids(keys, 7)
        self.assertEqual(len(set(ids.values())), 170)
        ordered = [ids[key] for key in sorted(keys)]
        self.assertNotEqual(ordered, sorted(ordered))

    def test_known_keys_keep_their_ids_when_new_ones_arrive(self):
        first = build_packets.assign_ids(["a|0", "b|0"], 7)
        second = build_packets.assign_ids(["a|0", "b|0", "a|1"], 7, existing=first)
        self.assertEqual(second["a|0"], first["a|0"])
        self.assertNotIn(second["a|1"], first.values())


class Config(unittest.TestCase):
    def test_config_is_created_once_with_the_eraser_off(self):
        state = Path(tempfile.mkdtemp())
        original = l4lib.STATE_DIR
        l4lib.STATE_DIR = state
        try:
            first = build_packets.load_config()
            self.assertIs(first["eraser_confirmed"], False)
            self.assertEqual(build_packets.load_config(), first)
        finally:
            l4lib.STATE_DIR = original


if __name__ == "__main__":
    unittest.main()
