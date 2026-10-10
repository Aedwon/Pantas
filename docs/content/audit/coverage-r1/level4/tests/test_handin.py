import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

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
        l4lib.save_json(self.state / "queue.json", {"expected": {packet["id"]: {"roles": ["A", "B"], "attempt": 1}}})
        self.stray = []

    def save(self, form, role="A", attempt=1):
        (self.inbox / ("L4-0417-%s-%d.json" % (role, attempt))).write_text(json.dumps(form), encoding="utf-8")

    def run_handin(self, role="A", text=fixtures.LESSON_TEXT, attempt=1):
        return handin.process("L4-0417", role, attempt, state_dir=self.state, inbox_dir=self.inbox,
                              changes=lambda queue: list(self.stray), lesson_text=lambda entry: text)

    def expect(self, roles, attempt=1):
        l4lib.save_json(self.state / "queue.json", {"expected": {"L4-0417": {"roles": roles, "attempt": attempt}}})

    def events(self):
        path = self.state / "handin-events.jsonl"
        return [json.loads(line)["result"] for line in path.read_text().splitlines()] if path.exists() else []

    def test_valid_form_is_accepted_and_moved_out_of_the_inbox(self):
        self.save(fixtures.valid_form("A"))
        code, lines = self.run_handin()
        self.assertEqual((code, lines[0][:8]), (0, "ACCEPTED"))
        self.assertTrue((self.state / "forms" / "L4-0417-A-1.json").exists())
        self.assertFalse((self.inbox / "L4-0417-A-1.json").exists())
        self.assertEqual(self.events(), ["accepted"])

    def test_handing_in_again_after_acceptance_changes_nothing(self):
        self.save(fixtures.valid_form("A"))
        self.run_handin()
        broken = fixtures.valid_form("A")
        del broken["rules"]["L17"]
        self.save(broken)
        code, _ = self.run_handin()
        self.assertEqual(code, 0)
        self.assertIn("L17", l4lib.load_json(self.state / "forms" / "L4-0417-A-1.json")["rules"])

    def test_rejected_form_gets_numbered_reasons_and_is_kept(self):
        broken = fixtures.valid_form("A")
        del broken["rules"]["L17"]
        self.save(broken)
        code, lines = self.run_handin()
        self.assertEqual(code, 1)
        self.assertTrue(lines[0].startswith("REJECTED"))
        self.assertTrue(lines[1].startswith("1. "))
        self.assertTrue((self.state / "forms" / "rejected" / "L4-0417-A-1-r1.bin").exists())
        self.assertFalse((self.state / "forms" / "L4-0417-A-1.json").exists())

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
        code, _ = handin.process("L4-9999", "A", 1, state_dir=self.state, inbox_dir=self.inbox)
        self.assertEqual(code, 64)

    def test_missing_saved_form_is_a_bad_request(self):
        self.assertEqual(self.run_handin()[0], 64)

    def test_invalid_json_is_rejected_not_crashed(self):
        (self.inbox / "L4-0417-A-1.json").write_text("{not json", encoding="utf-8")
        code, lines = self.run_handin()
        self.assertEqual(code, 1)
        self.assertIn("JSON", lines[1])

    def test_unexpected_change_stops_the_run_and_saves_nothing(self):
        self.stray = ["docs/content/audit/coverage-r1/level4/packets/L4-0388.md"]
        self.save(fixtures.valid_form("A"))
        code, lines = self.run_handin()
        self.assertEqual(code, 3)
        self.assertTrue(lines[0].startswith("STOPPED"))
        self.assertFalse((self.state / "forms" / "L4-0417-A-1.json").exists())
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
        broken["rules"]["ZEBRA-RULE-KEY"] = {"verdict": "fail"}
        broken["accuracy_concerns"] = [{"quote": "ZEBRA concern quote", "concern": "ZEBRA concern text that is long enough."}]
        self.save(broken)
        code, lines = self.run_handin()
        # The form was really checked and rejected for several different faults, and none was echoed.
        self.assertEqual(code, 1)
        text = "\n".join(lines)
        for fault in ("rule L17", "rule L26", "1 rule ids", "accuracy concern 1"):
            self.assertIn(fault, text)
        self.assertNotIn("ZEBRA", text)
        self.assertNotIn("invented", text)

    def test_output_never_names_a_verdict_even_for_an_accepted_or_held_form(self):
        self.save(fixtures.failing(fixtures.valid_form("A"), "L17", REAL_QUOTE, problem="ZEBRA is long enough to pass."))
        code, lines = self.run_handin()
        self.assertEqual(code, 0)
        self.assertEqual(lines, ["ACCEPTED: the form is saved. You are done."])

    def test_a_hand_in_for_an_old_attempt_is_refused_and_leaves_no_trace(self):
        self.expect(["A", "B"], attempt=2)
        self.save(fixtures.valid_form("A"), attempt=1)
        code, lines = self.run_handin(attempt=1)
        self.assertEqual(code, 64)
        self.assertIn("BAD REQUEST", lines[0])
        self.assertTrue((self.inbox / "L4-0417-A-1.json").exists())
        self.assertFalse((self.state / "forms").exists())
        self.assertEqual(self.events(), [])
        self.save(fixtures.valid_form("A"), attempt=2)
        self.assertEqual(self.run_handin(attempt=2)[0], 0)
        self.assertTrue((self.state / "forms" / "L4-0417-A-2.json").exists())
        self.assertEqual(json.loads((self.state / "handin-events.jsonl").read_text())["attempt"], 2)

    def test_a_hand_in_for_a_later_attempt_than_the_waiting_one_is_refused(self):
        self.save(fixtures.valid_form("A"), attempt=2)
        self.assertEqual(self.run_handin(attempt=2)[0], 64)
        self.assertFalse((self.state / "forms").exists())

    def test_every_event_carries_its_attempt(self):
        broken = fixtures.valid_form("A")
        del broken["rules"]["L17"]
        self.save(broken)
        self.run_handin()
        self.save(fixtures.valid_form("A"))
        self.run_handin()
        attempts = [json.loads(line)["attempt"] for line in (self.state / "handin-events.jsonl").read_text().splitlines()]
        self.assertEqual(attempts, [1, 1])

    def test_rejected_copies_are_kept_as_inert_bin_files(self):
        broken = fixtures.valid_form("A")
        del broken["rules"]["L17"]
        self.save(broken)
        self.run_handin()
        (self.inbox / "L4-0417-A-1.json").write_text("{not json", encoding="utf-8")
        self.run_handin()
        names = sorted(path.name for path in (self.state / "forms" / "rejected").iterdir())
        self.assertEqual(names, ["L4-0417-A-1-r1.bin", "L4-0417-A-1-u1.bin"])

    def test_unreadable_json_gets_five_tries_before_the_hold(self):
        codes = []
        for _ in range(5):
            (self.inbox / "L4-0417-A-1.json").write_text("{not json", encoding="utf-8")
            codes.append(self.run_handin()[0])
        self.assertEqual(codes, [1, 1, 1, 1, 2])
        (self.inbox / "L4-0417-A-1.json").write_text(json.dumps(fixtures.valid_form("A")), encoding="utf-8")
        self.assertEqual(self.run_handin()[0], 2)
        self.assertEqual(self.events()[-1], "held")

    def test_one_readable_rejection_still_leaves_one_retry_after_unreadable_slips(self):
        for _ in range(3):
            (self.inbox / "L4-0417-A-1.json").write_text("{not json", encoding="utf-8")
            self.run_handin()
        broken = fixtures.valid_form("A")
        del broken["rules"]["L17"]
        self.save(broken)
        self.assertEqual(self.run_handin()[0], 1)
        self.save(fixtures.valid_form("A"))
        self.assertEqual(self.run_handin()[0], 0)

    def test_hostile_json_is_rejected_and_never_crashes(self):
        good = fixtures.valid_form("A")
        hostile = [
            ("deeply nested lists", ("[" * 100000 + "]" * 100000).encode()),
            ("deeply nested objects", (b'{"a":' * 50000)),
            ("null", b"null"), ("empty list", b"[]"), ("a string", b'"text"'), ("a number", b"7"),
            ("huge exponent", b"1e999"), ("rules null", b'{"rules": null}'),
            ("typed wrongly", b'{"rules": {"L17": null}, "packet": ["x"], "role": {"a": 1}}'),
            ("invalid utf-8", b"\xff\xfe"),
            ("rules as text", json.dumps(dict(good, rules="all pass")).encode()),
            ("illustrations of junk", json.dumps(dict(good, illustrations=[None, 1, "x", {"status": ["a"]}])).encode()),
            ("concerns of junk", json.dumps(dict(good, accuracy_concerns=[None, 5, {"quote": 7}])).encode()),
        ]
        for name, raw in hostile:
            self.setUp()
            (self.inbox / "L4-0417-A-1.json").write_bytes(raw)
            code, lines = self.run_handin()
            self.assertEqual(code, 1, (name, lines))
            self.assertTrue(lines[0].startswith("REJECTED"), (name, lines))
            self.assertFalse((self.state / "forms" / "L4-0417-A-1.json").exists(), name)

    def test_a_lone_surrogate_in_an_otherwise_valid_form_is_rejected_not_a_crash(self):
        # JSON allows "\\ud800"; the file store cannot write it. It must be a rejection, not a traceback
        # that also loses the chat's saved form.
        candidate = fixtures.valid_form("A")
        candidate["rules"]["L17"]["checked"] = ["traced each formula to Core Concept XSURROGATEX and back again"]
        raw = json.dumps(candidate).replace("XSURROGATEX", "\\ud800")
        self.assertIn("\\ud800", raw)
        (self.inbox / "L4-0417-A-1.json").write_text(raw, encoding="utf-8")
        code, lines = self.run_handin()
        self.assertEqual(code, 1)
        self.assertFalse((self.state / "forms" / "L4-0417-A-1.json").exists())

    def test_extra_fields_a_chat_adds_never_reach_the_saved_form(self):
        candidate = fixtures.valid_form("A")
        candidate["ZEBRA-TOP"] = "hidden"
        candidate["rules"]["L17"]["ZEBRA-ENTRY"] = "hidden"
        self.save(candidate)
        self.assertEqual(self.run_handin()[0], 0)
        self.assertNotIn("ZEBRA", (self.state / "forms" / "L4-0417-A-1.json").read_text())

    def test_deciding_form_is_checked_against_its_items(self):
        a = fixtures.failing(fixtures.valid_form("A"), "L17", REAL_QUOTE)
        comparison = compare.compare(a, fixtures.valid_form("B"), 1, fixtures.LESSON_TEXT)
        l4lib.save_json(self.state / "deciding" / "L4-0417.json", comparison)
        self.expect(["D"])
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
        # A stand-in for the lesson corpus, so no test reads the real corpus worktree.
        self.corpus = Path(tempfile.mkdtemp())
        self.git("init", "-q", cwd=self.corpus)
        (self.corpus / "lesson.md").write_text("x")
        self.git("add", ".", cwd=self.corpus)
        self.git("commit", "-q", "-m", "x", cwd=self.corpus)
        pinned = self.git("rev-parse", "HEAD", cwd=self.corpus).strip()
        patcher = mock.patch.object(l4lib, "CORPUS_COMMIT", pinned)
        patcher.start()
        self.addCleanup(patcher.stop)

    def git(self, *args, **kwargs):
        return subprocess.check_output(["git"] + list(args), cwd=str(kwargs.get("cwd", self.root)), env=self.env,
                                       universal_newlines=True)

    def changes(self, **queue):
        queue.setdefault("baseline_head", self.head)
        return handin.unexpected_changes(queue, audit_wt=self.root, corpus_wt=self.corpus)

    def test_the_corpus_must_stay_pinned_and_clean(self):
        self.assertEqual(self.changes(), [])
        (self.corpus / "lesson.md").write_text("edited")
        self.assertEqual(self.changes(), ["(the lesson corpus)"])
        self.git("checkout", "-q", "--", "lesson.md", cwd=self.corpus)
        (self.corpus / "new.md").write_text("x")
        self.assertEqual(self.changes(), ["(the lesson corpus)"])

    def test_a_tracked_file_deleted_before_the_run_is_not_a_change_until_it_returns_or_changes(self):
        # Review item 16: this used to stop the run at the first hand-in.
        (self.root / "kept.md").unlink()
        pins = {"baseline_files": {"kept.md": handin.file_hash(self.root / "kept.md")}}
        self.assertEqual(pins["baseline_files"]["kept.md"], handin.DELETED)
        self.assertEqual(self.changes(**pins), [])
        (self.root / "kept.md").write_text("back")
        self.assertEqual(self.changes(**pins), ["kept.md"])

    def test_a_file_hidden_with_skip_worktree_is_reported(self):
        self.git("update-index", "--skip-worktree", "kept.md")
        (self.root / "kept.md").write_text("edited where git status cannot see it")
        found = self.changes()
        self.assertEqual(len(found), 1)
        self.assertIn("kept.md", found[0])
        self.assertIn("hidden from git status", found[0])

    def test_a_file_hidden_with_assume_unchanged_is_reported(self):
        self.git("update-index", "--assume-unchanged", "kept.md")
        (self.root / "kept.md").write_text("edited where git status cannot see it")
        found = self.changes()
        self.assertEqual(len(found), 1)
        self.assertIn("hidden from git status", found[0])

    def test_clean_tree_has_no_unexpected_change(self):
        self.assertEqual(self.changes(), [])

    def test_a_run_without_a_starting_commit_is_never_trusted(self):
        found = handin.unexpected_changes({}, audit_wt=self.root, corpus_wt=self.corpus)
        self.assertEqual(len(found), 1)
        self.assertIn("starting commit", found[0])

    def test_new_and_edited_files_are_reported(self):
        (self.root / "stray.md").write_text("x")
        (self.root / "kept.md").write_text("changed")
        self.assertEqual(self.changes(), ["kept.md", "stray.md"])

    def test_files_the_run_wrote_and_baseline_files_are_allowed_while_unchanged(self):
        (self.root / "result.md").write_text("x")
        (self.root / "old-untracked.md").write_text("x")
        pins = {"written": {"result.md": handin.file_hash(self.root / "result.md")},
                "baseline_files": {"old-untracked.md": handin.file_hash(self.root / "old-untracked.md")}}
        self.assertEqual(self.changes(**pins), [])

    def test_an_edit_to_an_already_dirty_file_is_reported(self):
        (self.root / "old-untracked.md").write_text("x")
        (self.root / "kept.md").write_text("dirty before the run")
        pins = {"baseline_files": {"old-untracked.md": handin.file_hash(self.root / "old-untracked.md"),
                                   "kept.md": handin.file_hash(self.root / "kept.md")}}
        self.assertEqual(self.changes(**pins), [])
        (self.root / "old-untracked.md").write_text("tampered")
        (self.root / "kept.md").write_text("tampered")
        self.assertEqual(self.changes(**pins), ["kept.md", "old-untracked.md"])

    def test_an_edit_to_a_file_the_run_wrote_is_reported(self):
        (self.root / "result.md").write_text("x")
        pins = {"written": {"result.md": handin.file_hash(self.root / "result.md")}}
        (self.root / "result.md").write_text("tampered")
        self.assertEqual(self.changes(**pins), ["result.md"])

    def test_a_committed_result_is_allowed_only_while_its_content_matches(self):
        (self.root / "result.md").write_text("x")
        pins = {"written": {"result.md": handin.file_hash(self.root / "result.md")}}
        self.git("add", ".")
        self.git("commit", "-q", "-m", "saved by the watcher")
        self.assertEqual(self.changes(**pins), [])

    def test_a_committed_change_hidden_by_a_restored_working_file_is_reported(self):
        (self.root / "result.md").write_text("x")
        pins = {"written": {"result.md": handin.file_hash(self.root / "result.md")}}
        (self.root / "result.md").write_text("tampered")
        self.git("add", ".")
        self.git("commit", "-q", "-m", "tampered commit")
        (self.root / "result.md").write_text("x")
        self.assertEqual(self.changes(**pins), ["result.md"])

    def test_a_staged_change_hidden_by_a_restored_working_file_is_reported(self):
        (self.root / "result.md").write_text("x")
        pins = {"written": {"result.md": handin.file_hash(self.root / "result.md")}}
        self.git("add", "result.md")
        self.assertEqual(self.changes(**pins), [])
        (self.root / "result.md").write_text("tampered")
        self.git("add", "result.md")
        (self.root / "result.md").write_text("x")
        self.assertEqual(self.changes(**pins), ["result.md"])

    def test_both_sides_of_a_rename_are_reported(self):
        self.git("mv", "kept.md", "moved.md")
        self.assertEqual(self.changes(), ["kept.md", "moved.md"])
        self.git("commit", "-q", "-m", "renamed")
        self.assertEqual(self.changes(), ["kept.md", "moved.md"])

    def test_a_path_with_spaces_and_quotes_is_reported_exactly(self):
        (self.root / 'odd "name" -> x.md').write_text("x")
        self.assertEqual(self.changes(), ['odd "name" -> x.md'])

    def test_a_commit_of_an_unexpected_file_is_reported(self):
        (self.root / "sneaky.md").write_text("x")
        self.git("add", ".")
        self.git("commit", "-q", "-m", "y")
        self.assertEqual(self.changes(), ["sneaky.md"])


if __name__ == "__main__":
    unittest.main()
