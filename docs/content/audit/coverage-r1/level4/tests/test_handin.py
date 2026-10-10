import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import compare  # noqa: E402
import fixtures  # noqa: E402
import handin  # noqa: E402
import l4lib  # noqa: E402

REAL_QUOTE = "Factoring is efficient when the quadratic has convenient factors."


class HandIn(unittest.TestCase):
    def setUp(self):
        self.state = Path(tempfile.mkdtemp())
        self.inbox = Path(tempfile.mkdtemp())
        packet = fixtures.packet()
        self.entry = {"id": packet["id"], "lesson_sha256": packet["lesson_sha256"],
                      "standards_commit": packet["standards_commit"], "rule_ids": l4lib.chat_rule_ids(),
                      "filipino": False, "source": "unused.md"}
        l4lib.save_json(self.state / "index.json", {packet["id"]: self.entry})
        l4lib.save_json(self.state / "queue.json", {"expected": {packet["id"]: ["A", "B"]}})
        self.stray = []

    def save(self, form, role="A"):
        (self.inbox / ("L4-0417-%s.json" % role)).write_text(json.dumps(form), encoding="utf-8")

    def run_handin(self, role="A", text=fixtures.LESSON_TEXT):
        return handin.process("L4-0417", role, state_dir=self.state, inbox_dir=self.inbox,
                              changes=lambda queue: list(self.stray), lesson_text=lambda entry: text)

    def events(self):
        path = self.state / "handin-events.jsonl"
        return [json.loads(line)["result"] for line in path.read_text().splitlines()] if path.exists() else []

    def test_valid_form_is_accepted_and_moved_out_of_the_inbox(self):
        self.save(fixtures.valid_form("A"))
        code, lines = self.run_handin()
        self.assertEqual((code, lines[0][:8]), (0, "ACCEPTED"))
        self.assertTrue((self.state / "forms" / "L4-0417-A.json").exists())
        self.assertFalse((self.inbox / "L4-0417-A.json").exists())
        self.assertEqual(self.events(), ["accepted"])

    def test_handing_in_again_after_acceptance_changes_nothing(self):
        self.save(fixtures.valid_form("A"))
        self.run_handin()
        broken = fixtures.valid_form("A")
        del broken["rules"]["L17"]
        self.save(broken)
        code, _ = self.run_handin()
        self.assertEqual(code, 0)
        self.assertIn("L17", l4lib.load_json(self.state / "forms" / "L4-0417-A.json")["rules"])

    def test_rejected_form_gets_numbered_reasons_and_is_kept(self):
        broken = fixtures.valid_form("A")
        del broken["rules"]["L17"]
        self.save(broken)
        code, lines = self.run_handin()
        self.assertEqual(code, 1)
        self.assertTrue(lines[0].startswith("REJECTED"))
        self.assertTrue(lines[1].startswith("1. "))
        self.assertTrue((self.state / "forms" / "rejected" / "L4-0417-A-1.json").exists())
        self.assertFalse((self.state / "forms" / "L4-0417-A.json").exists())

    def test_second_rejection_holds_and_later_hand_ins_are_refused(self):
        broken = fixtures.valid_form("A")
        del broken["rules"]["L17"]
        self.save(broken)
        self.run_handin()
        self.save(broken)
        code, lines = self.run_handin()
        self.assertEqual(code, 2)
        self.assertTrue(lines[0].startswith("HELD"))
        self.save(fixtures.valid_form("A"))
        code, lines = self.run_handin()
        self.assertEqual(code, 2)
        self.assertEqual(self.events(), ["rejected", "held"])

    def test_fixed_form_is_accepted_after_one_rejection(self):
        broken = fixtures.valid_form("A")
        del broken["rules"]["L17"]
        self.save(broken)
        self.run_handin()
        self.save(fixtures.valid_form("A"))
        self.assertEqual(self.run_handin()[0], 0)

    def test_unexpected_role_or_packet_is_refused(self):
        self.save(fixtures.valid_form("D"), role="D")
        self.assertEqual(self.run_handin(role="D")[0], 64)
        code, _ = handin.process("L4-9999", "A", state_dir=self.state, inbox_dir=self.inbox)
        self.assertEqual(code, 64)

    def test_missing_saved_form_is_a_bad_request(self):
        self.assertEqual(self.run_handin()[0], 64)

    def test_invalid_json_is_rejected_not_crashed(self):
        (self.inbox / "L4-0417-A.json").write_text("{not json", encoding="utf-8")
        code, lines = self.run_handin()
        self.assertEqual(code, 1)
        self.assertIn("JSON", lines[1])

    def test_unexpected_change_stops_the_run_and_saves_nothing(self):
        self.stray = ["docs/content/audit/coverage-r1/level4/packets/L4-0388.md"]
        self.save(fixtures.valid_form("A"))
        code, lines = self.run_handin()
        self.assertEqual(code, 3)
        self.assertTrue(lines[0].startswith("STOPPED"))
        self.assertFalse((self.state / "forms" / "L4-0417-A.json").exists())
        self.assertEqual(l4lib.load_json(self.state / "stop.json")["paths"], self.stray)
        self.stray = []
        self.assertEqual(self.run_handin()[0], 3)

    def test_changed_lesson_stops_the_run(self):
        self.save(fixtures.valid_form("A"))
        code, _ = self.run_handin(text=fixtures.LESSON_TEXT + "\nAn added line.\n")
        self.assertEqual(code, 3)

    def test_output_never_repeats_form_content(self):
        broken = fixtures.failing(fixtures.valid_form("A"), "L17", "ZEBRA invented quote text",
                                  problem="ZEBRA problem statement that is long enough.")
        broken["rules"]["L26"]["checked"] = []
        self.save(broken)
        _, lines = self.run_handin()
        self.assertNotIn("ZEBRA", "\n".join(lines))

    def test_deciding_form_is_checked_against_its_items(self):
        a = fixtures.failing(fixtures.valid_form("A"), "L17", REAL_QUOTE)
        comparison = compare.compare(a, fixtures.valid_form("B"), seed=1)
        l4lib.save_json(self.state / "deciding" / "L4-0417.json", comparison)
        l4lib.save_json(self.state / "queue.json", {"expected": {"L4-0417": ["D"]}})
        ruling = {"packet": "L4-0417", "role": "D", "lesson_sha256": self.entry["lesson_sha256"],
                  "standards_commit": self.entry["standards_commit"], "rulings": {}}
        self.save(ruling, role="D")
        code, lines = self.run_handin(role="D")
        self.assertEqual(code, 1)
        self.assertIn("I1", lines[1])
        ruling["rulings"]["I1"] = {"ruling": "uphold_a", "quote": REAL_QUOTE, "reason": "The lesson text supports this."}
        self.save(ruling, role="D")
        self.assertEqual(self.run_handin(role="D")[0], 0)


class UnexpectedChanges(unittest.TestCase):
    def setUp(self):
        self.root = Path(tempfile.mkdtemp())
        self.env = dict(os.environ, GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t",
                        GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t")
        self.git("init", "-q")
        (self.root / "kept.md").write_text("x")
        self.git("add", ".")
        self.git("commit", "-q", "-m", "x")
        self.head = self.git("rev-parse", "HEAD").strip()

    def git(self, *args):
        return subprocess.check_output(["git"] + list(args), cwd=str(self.root), env=self.env, universal_newlines=True)

    def changes(self, **queue):
        queue.setdefault("baseline_head", self.head)
        return handin.unexpected_changes(queue, audit_wt=self.root, corpus_wt=self.root_corpus())

    def root_corpus(self):
        return l4lib.CORPUS_WT

    def test_clean_tree_has_no_unexpected_change(self):
        self.assertEqual(self.changes(), [])

    def test_new_and_edited_files_are_reported(self):
        (self.root / "stray.md").write_text("x")
        (self.root / "kept.md").write_text("changed")
        self.assertEqual(self.changes(), ["kept.md", "stray.md"])

    def test_files_the_run_wrote_and_baseline_files_are_allowed(self):
        (self.root / "result.md").write_text("x")
        (self.root / "old-untracked.md").write_text("x")
        self.assertEqual(self.changes(written=["result.md"], baseline_status=["?? old-untracked.md"]), [])

    def test_a_commit_of_an_unexpected_file_is_reported(self):
        (self.root / "sneaky.md").write_text("x")
        self.git("add", ".")
        self.git("commit", "-q", "-m", "y")
        self.assertEqual(self.changes(), ["sneaky.md"])


if __name__ == "__main__":
    unittest.main()
