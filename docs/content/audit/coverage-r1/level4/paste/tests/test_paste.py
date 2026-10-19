import json
import sys
import tempfile
import unittest
from pathlib import Path

PASTE = Path(__file__).resolve().parents[1]
LEVEL4 = PASTE.parent
sys.path.insert(0, str(LEVEL4 / "tests"))
sys.path.insert(0, str(PASTE))
import fixtures  # noqa: E402
import l4lib  # noqa: E402
import paste_lib  # noqa: E402
import setup_paste  # noqa: E402

PACKETS = LEVEL4 / "packets"
REAL = ("L4-1055", "L4-1065", "L4-1079")
START, END = "<<<<<<<< LESSON START", ">>>>>>>> LESSON END"
REAL_QUOTE = "Factoring is efficient when the quadratic has convenient factors."


def between(text, start, stop):
    return text[text.index(start):text.index(stop, text.index(start))]


class AdaptPrompt(unittest.TestCase):
    def test_real_packets_keep_lesson_and_form_and_lose_the_relay(self):
        for packet_id in REAL:
            original = (PACKETS / ("%s.md" % packet_id)).read_text(encoding="utf-8")
            adapted = paste_lib.adapt_prompt(original, "A", 1)
            with self.subTest(packet=packet_id):
                # Lesson text, blank form, rules table and standards are byte for byte the same.
                self.assertEqual(between(adapted, START, END + "\n"), between(original, START, END + "\n"))
                self.assertEqual(between(adapted, "## The form\n", "## The lesson to audit"),
                                 between(original, "## The form\n", "## The lesson to audit"))
                self.assertEqual(adapted[adapted.index("## How to judge"):adapted.index("## How to hand in")],
                                 original[original.index("## How to judge"):original.index("## How to hand in")])
                self.assertIn("reply with only the completed form as one JSON code block, and nothing else", adapted)
                self.assertIn("Your role is `A` and this is attempt 1", adapted)
                for gone in ("relay", "handin.py", "workspace_exec", "Step 1.", "[relay]"):
                    self.assertNotIn(gone, adapted)
                # The rules the check enforces stay.
                self.assertIn("What the check enforces:", adapted)
                self.assertIn("Do not reuse one `checked` text across several rules.", adapted)

    def test_attempt_number_is_written_into_the_prompt(self):
        original = (PACKETS / "L4-1055.md").read_text(encoding="utf-8")
        self.assertIn("this is attempt 2", paste_lib.adapt_prompt(original, "A", 2))

    def test_every_packet_can_be_adapted(self):
        for path in sorted(PACKETS.glob("L4-*.md")):
            paste_lib.adapt_prompt(path.read_text(encoding="utf-8"))

    def test_a_packet_without_the_markers_is_refused(self):
        original = (PACKETS / "L4-1055.md").read_text(encoding="utf-8")
        for marker in (paste_lib.START, paste_lib.KEEP, paste_lib.CUT, paste_lib.END):
            with self.subTest(marker=marker.strip()):
                with self.assertRaises(paste_lib.PasteError):
                    paste_lib.adapt_prompt(original.replace(marker, "\n"))
        with self.assertRaises(paste_lib.PasteError):  # a marker that appears twice is not safe either
            paste_lib.adapt_prompt(original + paste_lib.END)


class ExtractJson(unittest.TestCase):
    FORM = {"packet": "L4-0417", "note": "a \\ backslash"}

    def test_bare_json(self):
        text, problem = paste_lib.extract_json(json.dumps(self.FORM))
        self.assertIsNone(problem)
        self.assertEqual(json.loads(text), self.FORM)

    def test_json_fence_with_chatter_around_it(self):
        reply = "Here is the form.\n```json\n%s\n```\nDone." % json.dumps(self.FORM, indent=1)
        text, problem = paste_lib.extract_json(reply)
        self.assertIsNone(problem)
        self.assertEqual(json.loads(text), self.FORM)

    def test_plain_fence_and_crlf(self):
        text, _ = paste_lib.extract_json("```\r\n%s\r\n```" % json.dumps(self.FORM))
        self.assertEqual(json.loads(text), self.FORM)

    def test_json_fence_wins_over_an_earlier_other_fence(self):
        reply = "```text\n{\"x\": 1}\n```\n```json\n%s\n```" % json.dumps(self.FORM)
        text, _ = paste_lib.extract_json(reply)
        self.assertEqual(json.loads(text), self.FORM)

    def test_json_after_unfenced_chatter(self):
        text, _ = paste_lib.extract_json("Sure thing: %s thanks" % json.dumps(self.FORM))
        self.assertEqual(json.loads(text), self.FORM)

    def test_nothing_found(self):
        for reply in ("", "   ", "I could not do that.", "[1, 2, 3]"):
            with self.subTest(reply=reply):
                text, problem = paste_lib.extract_json(reply)
                self.assertIsNone(text)
                self.assertTrue(problem)

    def test_broken_json_is_named_as_such(self):
        text, problem = paste_lib.extract_json('```json\n{"a": "unterminated\n```')
        self.assertIsNone(text)
        self.assertIn("not valid JSON", problem)


class Scope(unittest.TestCase):
    def test_comments_blank_lines_and_duplicates(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "scope.txt"
            path.write_text("# header\n\nL4-1055\nL4-1065  # why\nL4-1055\n", encoding="utf-8")
            self.assertEqual(paste_lib.read_scope(path), ["L4-1055", "L4-1065"])
            path.write_text("L4-10\n", encoding="utf-8")
            with self.assertRaises(paste_lib.PasteError):
                paste_lib.read_scope(path)

    def test_shipped_scope_file_parses(self):
        paste_lib.read_scope()


def make_list(tmp, attempt=1):
    """A prepared paste run for the fixture lesson, checked by the real validator."""
    state = Path(tmp) / "state"
    packet = fixtures.packet()
    entry = {"id": packet["id"], "lesson_sha256": packet["lesson_sha256"],
             "standards_commit": packet["standards_commit"], "rule_ids": l4lib.chat_rule_ids(),
             "filipino": False, "source": "unused.md", "title": "Quadratic Equations",
             "subject": "mathematics", "planted": False}
    packets = Path(tmp) / "packets"
    packets.mkdir()
    setup_paste.create([packet["id"]], {packet["id"]: entry}, state)
    return paste_lib.LessonList(state_dir=state, packets_dir=packets, lesson_text=lambda e: fixtures.LESSON_TEXT)


class Check(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.lessons = make_list(self.tmp.name)

    def test_setup_expects_only_role_a(self):
        queue = l4lib.load_json(Path(self.tmp.name) / "state" / "queue.json")
        self.assertEqual(queue["expected"]["L4-0417"], {"roles": ["A"], "attempt": 1})

    def test_valid_form_is_accepted_even_inside_a_fence(self):
        reply = "```json\n%s\n```" % json.dumps(fixtures.valid_form("A"), indent=1)
        result = self.lessons.check("L4-0417", reply)
        self.assertEqual((result["code"], result["word"]), (0, "ACCEPTED"))
        self.assertEqual(self.lessons.view()["counts"]["accepted"], 1)
        self.assertTrue((Path(self.tmp.name) / "state" / "forms" / "L4-0417-A-1.json").exists())
        self.assertEqual(list((Path(self.tmp.name) / "state" / "inbox").iterdir()), [])

    def test_invalid_form_is_rejected_with_numbered_reasons_and_a_reply_for_the_chat(self):
        form = fixtures.failing(fixtures.valid_form("A"), "B01", "this quote is not in the lesson at all")
        result = self.lessons.check("L4-0417", json.dumps(form))
        self.assertEqual((result["code"], result["word"]), (1, "REJECTED"))
        self.assertTrue(result["lines"][1].startswith("1. "))
        self.assertIn("quote is not exact text", result["lines"][1])
        self.assertIn("1. ", result["reply"])
        self.assertIn("one JSON code block", result["reply"])
        self.assertEqual(self.lessons.view()["items"][0]["state"], "rejected")

    def test_second_rejection_holds_and_start_over_moves_the_old_forms_aside(self):
        form = json.dumps(fixtures.failing(fixtures.valid_form("A"), "B01", "this quote is not in the lesson"))
        self.lessons.check("L4-0417", form)
        result = self.lessons.check("L4-0417", form)
        self.assertEqual(result["word"], "HELD")
        self.assertEqual(self.lessons.view()["items"][0]["state"], "held")
        with self.assertRaises(paste_lib.PasteError):
            self.lessons.start_over("nope")
        self.lessons.start_over("L4-0417")
        view = self.lessons.view()["items"][0]
        self.assertEqual((view["state"], view["attempt"]), ("todo", 2))
        moved = list((Path(self.tmp.name) / "state" / "forms" / "discarded").rglob("*.bin"))
        self.assertEqual(len(moved), 2)
        # The next attempt is accepted under its own name.
        form2 = fixtures.valid_form("A")
        self.assertEqual(self.lessons.check("L4-0417", json.dumps(form2))["word"], "ACCEPTED")
        self.assertTrue((Path(self.tmp.name) / "state" / "forms" / "L4-0417-A-2.json").exists())

    def test_start_over_is_refused_unless_held(self):
        with self.assertRaises(paste_lib.PasteError):
            self.lessons.start_over("L4-0417")

    def test_no_json_does_not_use_up_an_attempt(self):
        result = self.lessons.check("L4-0417", "I am unable to comply.")
        self.assertEqual(result["word"], "NOT CHECKED")
        self.assertEqual(self.lessons.view()["items"][0]["state"], "todo")

    def test_a_packet_outside_the_run_is_refused(self):
        with self.assertRaises(paste_lib.PasteError):
            self.lessons.check("L4-9999", "{}")

    def test_changed_lesson_stops_the_run(self):
        lessons = paste_lib.LessonList(state_dir=self.lessons.state_dir, packets_dir=self.lessons.packets_dir,
                                       lesson_text=lambda e: fixtures.LESSON_TEXT + "\nchanged")
        result = lessons.check("L4-0417", json.dumps(fixtures.valid_form("A")))
        self.assertEqual(result["word"], "STOPPED")
        self.assertTrue(lessons.view()["stopped"])


class Setup(unittest.TestCase):
    def test_problems(self):
        index = {"L4-1": {"planted": False}, "L4-2": {"planted": True}}
        with tempfile.TemporaryDirectory() as tmp:
            self.assertEqual(setup_paste.problems_with([], index, tmp), ["scope.txt lists no packet ids"])
            text = " ".join(setup_paste.problems_with(["L4-1", "L4-2", "L4-3"], index, tmp))
            self.assertIn("L4-1 has no packet file", text)
            self.assertIn("L4-2 is a planted check", text)
            self.assertIn("L4-3 is not in the packet index", text)

    def test_existing_state_is_refused_then_moved_aside_with_force_new(self):
        with tempfile.TemporaryDirectory() as tmp:
            state = Path(tmp) / "paste-state"
            setup_paste.create(["L4-1"], {"L4-1": {"title": "t"}}, state)
            marker = state / "queue.json"
            self.assertTrue(marker.exists())
            moved = setup_paste.move_aside(state)
            self.assertFalse(state.exists())
            self.assertTrue((moved / "queue.json").exists())
            self.assertIn(".moved-", moved.name)


if __name__ == "__main__":
    unittest.main()


class LatexBackslashTest(unittest.TestCase):
    def test_single_backslash_latex_is_kept_literally(self):
        text, error = paste_lib.extract_json('```json\n{"p": "a \\frac{1}{2} and \\sqrt{x}"}\n```')
        self.assertIsNone(error)
        self.assertEqual(json.loads(text)["p"], "a \\frac{1}{2} and \\sqrt{x}")

    def test_valid_escapes_still_work(self):
        text, _ = paste_lib.extract_json('{"p": "caf\\u00e9 \\"q\\""}')
        self.assertEqual(json.loads(text)["p"], 'café "q"')


if __name__ == "__main__":
    unittest.main()
