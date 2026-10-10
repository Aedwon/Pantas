import datetime
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import dispatch  # noqa: E402
import fixtures  # noqa: E402
import l4lib  # noqa: E402
import runqueue  # noqa: E402

REAL_QUOTE = "Factoring is efficient when the quadratic has convenient factors."
PACKETS = ["L4-0417", "L4-0520", "L4-0633"]


class FakeDispatcher:
    assignment = staticmethod(dispatch.assignment)

    def __init__(self):
        self.registered, self.cancelled, self.states, self.runners = [], [], {}, 1
        self.supervisor, self.relay, self.register_fails = True, [], []

    def register(self, envelope):
        if self.register_fails and envelope["task_id"].split("-")[-2] in self.register_fails:
            raise l4lib.L4Error("dispatcher did not register %s: boom" % envelope["task_id"])
        self.registered.append(envelope)
        number = 9000 + len(self.registered)
        return {"task_id": envelope["task_id"], "issue_url": "u", "issue_number": number}

    def task_state(self, issue_number):
        return self.states.get(issue_number, {"state": "active", "detail": "working"})

    def runners_online(self):
        return self.runners

    def cancel(self, task_id):
        self.cancelled.append(task_id)

    def supervisor_running(self):
        return self.supervisor

    def list_relay_issues(self, since):
        self.listed_since = since
        return list(self.relay)


class RunCase(unittest.TestCase):
    def setUp(self):
        self.state = Path(tempfile.mkdtemp())
        self.wt = Path(tempfile.mkdtemp())
        subprocess.check_call(["git", "init", "-q"], cwd=str(self.wt))
        subprocess.check_call(["git", "-c", "user.name=t", "-c", "user.email=t@t", "commit", "-q",
                               "--allow-empty", "-m", "x"], cwd=str(self.wt))
        packet = fixtures.packet()
        index = {}
        for number, packet_id in enumerate(PACKETS):
            index[packet_id] = {"id": packet_id, "lesson_id": "lesson-%d" % number, "planted": number == 1,
                                "title": "Lesson %d" % number, "subject": "mathematics", "topic": "algebra",
                                "lesson_sha256": packet["lesson_sha256"], "standards_commit": packet["standards_commit"],
                                "rule_ids": l4lib.chat_rule_ids(), "filipino": False, "source": "unused"}
        l4lib.save_json(self.state / "index.json", index)
        self.dispatcher = FakeDispatcher()
        self.clock = datetime.datetime(2026, 10, 11, 9, 0, tzinfo=datetime.timezone.utc)
        self.erased, self.changed, self.standards = [], [], []
        self.checked_bases = []
        prompts = Path(tempfile.mkdtemp())
        (prompts / "reader.md").write_text("READ {{PACKET}} {{ROLE}} {{ATTEMPT}} {{COMMIT}}")
        (prompts / "decider.md").write_text("DECIDE {{PACKET}} {{COMMIT}} {{FORM}} {{ITEMS}}")
        self.prompts = prompts
        self.run = self.new_run()
        self.run.create(PACKETS, pilot_count=2, packets_commit="c" * 40)

    def new_run(self):
        return runqueue.Run(self.dispatcher, state_dir=self.state, config={"seed": 5, "run_token": "l4abc123"},
                            erase=lambda packet_id, role, attempt, since: self.erased.append((packet_id, role, attempt)),
                            now=lambda: self.clock, audit_wt=self.wt,
                            lesson_text=lambda entry: fixtures.LESSON_TEXT, prompts_dir=self.prompts,
                            changes=lambda queue: list(self.changed), standards_diff=self.standards_diff)

    def standards_diff(self, base):
        self.checked_bases.append(base)
        return "m" * 40, list(self.standards)

    def hand_in(self, packet_id, role, form, result="accepted", attempt=None):
        attempt = attempt or self.run.q["lessons"][packet_id]["attempt"]
        if result == "accepted":
            form = dict(form, packet=packet_id, role=role)
            l4lib.save_json(self.state / "forms" / ("%s-%s-%d.json" % (packet_id, role, attempt)), form)
        with open(str(self.state / "handin-events.jsonl"), "a") as handle:
            handle.write(json.dumps({"packet": packet_id, "role": role, "attempt": attempt, "result": result,
                                     "at": self.clock.isoformat()}) + "\n")

    def minutes(self, count):
        self.clock += datetime.timedelta(minutes=count)

    def read_cleanly(self, packet_id):
        self.hand_in(packet_id, "A", fixtures.valid_form("A"))
        independent = fixtures.valid_form("B")
        for number, entry in enumerate(independent["rules"].values()):
            entry["checked"] = ["Second reader item %d: Core Concept states the idea before any example." % number]
        self.hand_in(packet_id, "B", independent)

    def state_of(self, packet_id):
        return self.run.q["lessons"][packet_id]["state"]


class HappyPath(RunCase):
    def test_nothing_starts_before_start_is_pressed(self):
        self.run.tick()
        self.assertEqual(self.dispatcher.registered, [])
        self.assertEqual(self.run.view()["state"], "ready")

    def test_start_registers_both_reads_of_the_first_lesson_together(self):
        self.run.start()
        self.run.tick()
        roles = [envelope["task_id"] for envelope in self.dispatcher.registered]
        self.assertEqual(roles, ["l4abc123-l4-0417-a-1", "l4abc123-l4-0417-b-1"])
        self.assertEqual(self.run.q["expected"], {"L4-0417": {"roles": ["A", "B"], "attempt": 1}})
        self.assertIn("READ L4-0417 A 1 " + "c" * 40, self.dispatcher.registered[0]["assignment_markdown"])
        self.assertTrue(self.run.q["baseline_head"])

    def test_agreeing_reads_finish_the_lesson_and_the_next_one_starts(self):
        self.run.start()
        self.run.tick()
        self.minutes(6)
        self.read_cleanly("L4-0417")
        self.run.tick()
        self.assertEqual(self.state_of("L4-0417"), "finished")
        self.assertEqual(len(self.dispatcher.registered), 2)
        result = l4lib.load_json(self.state / "results" / "L4-0417.json")
        self.assertEqual(result["rules"]["L17"]["verdict"], "pass")
        self.assertEqual(sorted(self.erased), [("L4-0417", "A", 1), ("L4-0417", "B", 1)])
        self.run.tick()
        self.assertEqual(self.run.q["current"], "L4-0520")
        self.assertEqual(len(self.dispatcher.registered), 4)

    def test_one_form_in_keeps_waiting(self):
        self.run.start()
        self.run.tick()
        self.hand_in("L4-0417", "A", fixtures.valid_form("A"))
        self.run.tick()
        self.assertEqual(self.state_of("L4-0417"), "reading")
        chats = {chat["name"]: chat["status"] for chat in self.run.view()["chats"]}
        self.assertEqual(chats, {"Chat 1": "done", "Chat 2": "working"})

    def test_a_rejected_form_shows_as_fixing(self):
        self.run.start()
        self.run.tick()
        self.hand_in("L4-0417", "A", None, result="rejected")
        self.run.tick()
        self.assertEqual(self.run.view()["chats"][0]["status"], "fixing")
        self.assertEqual(self.erased, [("L4-0417", "A", 1)])


class Deciding(RunCase):
    def dispute(self):
        self.run.start()
        self.run.tick()
        self.hand_in("L4-0417", "A", fixtures.failing(fixtures.valid_form("A"), "L17", REAL_QUOTE))
        independent = fixtures.valid_form("B")
        for number, entry in enumerate(independent["rules"].values()):
            entry["checked"] = ["Second reader item %d: Core Concept states the idea before any example." % number]
        self.hand_in("L4-0417", "B", independent)
        self.run.tick()

    def test_a_disagreement_starts_a_deciding_chat_and_does_not_finish(self):
        self.dispute()
        self.assertEqual(self.state_of("L4-0417"), "deciding")
        self.assertEqual(self.run.q["expected"], {"L4-0417": {"roles": ["D"], "attempt": 1}})
        markdown = self.dispatcher.registered[-1]["assignment_markdown"]
        self.assertIn("DECIDE L4-0417", markdown)
        self.assertIn('"I1"', markdown)
        self.assertNotIn("swap", markdown)
        self.assertNotIn("origin", markdown)
        view = self.run.view()
        self.assertEqual(view["disputed_items"], 1)
        self.assertEqual([chat["name"] for chat in view["chats"]], ["Chat 1", "Chat 2", "Deciding chat"])

    def test_the_ruling_finishes_the_lesson(self):
        self.dispute()
        ruling = {"rulings": {"I1": {"ruling": "uphold_a", "quote": REAL_QUOTE, "reason": "The lesson supports this."}}}
        self.hand_in("L4-0417", "D", ruling)
        self.run.tick()
        self.assertEqual(self.state_of("L4-0417"), "finished")
        result = l4lib.load_json(self.state / "results" / "L4-0417.json")
        self.assertEqual(result["rules"]["L17"]["source"], "ruled")


class PacingGate(RunCase):
    def stuck(self):
        self.run.start()
        self.run.tick()
        self.hand_in("L4-0417", "A", None, result="held")
        self.run.tick()

    def test_a_stuck_lesson_asks_for_aedwon_and_starts_nothing_new(self):
        self.stuck()
        self.assertEqual(self.run.view()["state"], "needs_you")
        self.assertIn("Chat 1", self.run.view()["reason"])
        registered = len(self.dispatcher.registered)
        for _ in range(5):
            self.run.tick()
        self.assertEqual(len(self.dispatcher.registered), registered)
        self.assertEqual(self.state_of("L4-0520"), "pending")

    def test_resume_does_not_skip_a_stuck_lesson(self):
        self.stuck()
        self.run.resume()
        self.assertEqual(self.run.view()["state"], "needs_you")

    def test_copied_forms_ask_for_aedwon(self):
        self.run.start()
        self.run.tick()
        self.hand_in("L4-0417", "A", fixtures.valid_form("A"))
        self.hand_in("L4-0417", "B", fixtures.valid_form("B"))
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "needs_you")
        self.assertIn("copied", self.run.view()["reason"])
        self.assertFalse((self.state / "results" / "L4-0417.json").exists())

    def test_a_chat_that_ends_without_a_form_asks_for_aedwon(self):
        self.run.start()
        self.run.tick()
        self.dispatcher.states[9001] = {"state": "completed", "detail": "completed"}
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "needs_you")
        self.dispatcher.states[9001] = {"state": "failed", "detail": "stalled: browser_lost"}
        self.run.restart_current()
        self.run.tick()
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "running")

    def test_restart_discards_the_attempt_and_reads_the_lesson_again(self):
        self.stuck()
        self.hand_in("L4-0417", "B", fixtures.valid_form("B"))
        self.run.restart_current()
        self.assertEqual(self.dispatcher.cancelled, ["l4abc123-l4-0417-a-1", "l4abc123-l4-0417-b-1"])
        self.assertFalse((self.state / "forms" / "L4-0417-B-1.json").exists())
        self.assertTrue((self.state / "forms" / "discarded" / "L4-0417-attempt-1" / "L4-0417-B-1.json").exists())
        self.run.tick()
        self.assertEqual(self.dispatcher.registered[-1]["task_id"], "l4abc123-l4-0417-b-2")
        self.assertEqual(self.run.q["current"], "L4-0417")

    def test_only_aedwon_holds_a_lesson_and_the_run_then_moves_on(self):
        self.stuck()
        self.assertEqual(self.run.view()["held"], 0)
        self.run.hold_current("could not be read")
        self.assertEqual(self.state_of("L4-0417"), "held")
        self.run.tick()
        self.assertEqual(self.run.q["current"], "L4-0520")
        self.assertEqual(self.run.view()["held"], 1)

    def test_a_result_that_fails_its_check_does_not_finish(self):
        packet = dict(fixtures.packet(), rule_ids=l4lib.chat_rule_ids())
        good = {"rules": {rule_id: {"verdict": "pass", "findings": []} for rule_id in l4lib.chat_rule_ids()},
                "illustrations": [], "lesson_sha256": packet["lesson_sha256"]}
        self.assertEqual(runqueue.check_result(good, packet), [])
        del good["rules"]["L17"]
        good["rules"]["L26"] = {"verdict": "fail", "findings": []}
        good["rules"]["L25"] = {"verdict": "fail", "findings": [{"quote": "Not in the lesson anywhere.", "problem": "x"}]}
        self.assertEqual(len(runqueue.check_result(good, packet)), 3)


class Interruptions(RunCase):
    def test_pause_lets_the_current_lesson_finish_and_starts_no_new_one(self):
        self.run.start()
        self.run.tick()
        self.run.pause()
        self.assertEqual(self.run.view()["state"], "paused")
        self.read_cleanly("L4-0417")
        self.run.tick()
        self.assertEqual(self.state_of("L4-0417"), "finished")
        for _ in range(3):
            self.run.tick()
        self.assertIsNone(self.run.q["current"])
        self.assertEqual(self.state_of("L4-0520"), "pending")
        self.assertEqual(len(self.dispatcher.registered), 2)  # no chat started while paused
        self.assertEqual(self.run.view()["state"], "paused")
        self.run.resume()
        self.run.tick()
        self.assertEqual(self.run.q["current"], "L4-0520")
        self.assertEqual(self.state_of("L4-0520"), "reading")
        self.assertEqual(len(self.dispatcher.registered), 4)

    def test_usage_limit_and_sign_in_wait_for_resume(self):
        for seen, state in (({"state": "limit", "detail": "usage_limit"}, "limit"),
                            ({"state": "signin", "detail": "auth_required"}, "signin")):
            self.setUp()
            self.run.start()
            self.run.tick()
            self.dispatcher.states[9001] = seen
            self.run.tick()
            self.assertEqual(self.run.view()["state"], state)
            self.dispatcher.states.clear()
            self.run.tick()
            self.assertEqual(self.run.view()["state"], state)
            self.run.resume()
            self.assertEqual(self.run.view()["state"], "running")

    def test_no_runner_waits_and_recovers_by_itself(self):
        self.run.start()
        self.dispatcher.runners = 0
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "offline")
        self.assertEqual(self.dispatcher.registered, [])
        self.dispatcher.runners = 1
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "running")
        self.assertEqual(len(self.dispatcher.registered), 2)

    def test_a_stop_from_the_hand_in_check_stops_the_run(self):
        self.run.start()
        self.run.tick()
        l4lib.save_json(self.state / "stop.json", {"reason": "unexpected change", "paths": ["packets/L4-0388.md"]})
        self.run.tick()
        view = self.run.view()
        self.assertEqual(view["state"], "stopped")
        self.assertIn("packets/L4-0388.md", view["reason"])
        self.run.resume()
        self.assertEqual(self.run.view()["state"], "stopped")

    def test_the_run_pauses_itself_after_the_pilot(self):
        self.run.start()
        for packet_id in PACKETS[:2]:
            self.run.tick()
            self.minutes(5)
            self.read_cleanly(packet_id)
            self.run.tick()
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "pilot_done")
        self.assertEqual(self.state_of("L4-0633"), "pending")
        self.run.resume()
        self.run.tick()
        self.assertEqual(self.run.q["current"], "L4-0633")

    def test_the_run_ends_when_every_lesson_is_finished(self):
        self.run.create(PACKETS[:1], pilot_count=1, packets_commit="c" * 40)
        self.run.q["pilot_acknowledged"] = True
        self.run.start()
        self.run.tick()
        self.read_cleanly("L4-0417")
        self.run.tick()
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "done")

    def test_a_restarted_process_continues_from_the_saved_state(self):
        self.run.start()
        self.run.tick()
        self.read_cleanly("L4-0417")
        fresh = self.new_run()
        fresh.tick()
        self.assertEqual(fresh.q["lessons"]["L4-0417"]["state"], "finished")
        self.assertEqual(len(self.dispatcher.registered), 2)


class View(RunCase):
    def test_strip_groups_real_lessons_by_subject_and_checks_apart(self):
        self.run.start()
        self.run.tick()
        strip = {group["name"]: group["cells"] for group in self.run.view()["strip"]}
        self.assertEqual(strip["Mathematics"], ["now", ""])
        self.assertEqual(strip["Checks"], [""])
        self.assertEqual(self.run.view()["total"], 2)

    def test_time_left_appears_only_after_two_finished_lessons(self):
        self.run.q["pilot_acknowledged"] = True
        self.run.start()
        for packet_id in PACKETS[:2]:
            self.run.tick()
            self.assertIsNone(self.run.view()["hours_left"])
            self.minutes(90)
            self.read_cleanly(packet_id)
            self.run.tick()
        self.assertEqual(self.run.view()["hours_left"], 2)

    def test_current_lesson_is_numbered_within_its_group(self):
        self.run.start()
        self.run.tick()
        self.assertEqual(self.run.view()["lesson"], {"title": "Lesson 0", "subject": "Mathematics",
                                                    "planted": False, "number": 1, "total": 2})


class Registration(RunCase):
    """Review items 5, 8 and 14: attempt numbers, a role that failed to register, a failing dispatcher."""

    def test_the_assignment_text_names_the_attempt_and_a_restart_raises_it(self):
        self.run.start()
        self.run.tick()
        self.assertIn("READ L4-0417 B 1 ", self.dispatcher.registered[1]["assignment_markdown"])
        self.run.restart_current()
        self.run.tick()
        self.assertIn("READ L4-0417 B 2 ", self.dispatcher.registered[-1]["assignment_markdown"])
        self.assertEqual(self.run.q["expected"]["L4-0417"], {"roles": ["A", "B"], "attempt": 2})

    def test_a_role_that_failed_to_register_puts_the_run_in_trouble_and_is_registered_again_after_resume(self):
        self.dispatcher.register_fails = ["b"]
        self.run.start()
        self.run.tick()
        view = self.run.view()
        self.assertEqual(view["state"], "run_trouble")
        self.assertIn("Chat 2 could not be started", view["reason"])
        self.assertEqual([e["task_id"] for e in self.dispatcher.registered], ["l4abc123-l4-0417-a-1"])
        self.assertEqual(self.run.q["current"], "L4-0417")
        for _ in range(3):
            self.run.tick()
        self.assertEqual(len(self.dispatcher.registered), 1)  # nothing is retried behind Aedwon's back
        self.dispatcher.register_fails = []
        self.run.resume()
        self.assertEqual(self.run.view()["state"], "running")
        self.run.tick()
        self.assertEqual([e["task_id"] for e in self.dispatcher.registered],
                         ["l4abc123-l4-0417-a-1", "l4abc123-l4-0417-b-1"])
        self.run.tick()
        self.assertEqual(len(self.dispatcher.registered), 2)

    def test_a_lesson_with_a_missing_chat_does_not_compare_or_finish(self):
        self.dispatcher.register_fails = ["b"]
        self.run.start()
        self.run.tick()
        self.hand_in("L4-0417", "A", fixtures.valid_form("A"))
        self.run.tick()
        self.assertEqual(self.state_of("L4-0417"), "reading")
        self.assertEqual(self.run.view()["state"], "run_trouble")

    def test_a_missing_chat_is_registered_on_the_next_tick_without_a_resume_when_the_run_is_running(self):
        self.run.start()
        self.run.tick()
        del self.run.q["lessons"]["L4-0417"]["tasks"]["B"]
        self.run.tick()
        self.assertEqual(self.dispatcher.registered[-1]["task_id"], "l4abc123-l4-0417-b-1")
        self.assertIn("B", self.run.q["lessons"]["L4-0417"]["tasks"])

    def test_a_pause_starts_no_chat_even_to_replace_one_that_failed_to_register(self):
        self.run.start()
        self.run.tick()
        del self.run.q["lessons"]["L4-0417"]["tasks"]["B"]
        self.run.pause()
        self.run.tick()
        self.assertEqual(len(self.dispatcher.registered), 2)
        self.run.resume()
        self.run.tick()
        self.assertEqual(len(self.dispatcher.registered), 3)

    def test_a_missing_deciding_chat_is_registered_again(self):
        self.dispatcher.register_fails = ["d"]
        self.run.start()
        self.run.tick()
        self.hand_in("L4-0417", "A", fixtures.failing(fixtures.valid_form("A"), "L17", REAL_QUOTE))
        self.read_cleanly_b_only("L4-0417")
        self.run.tick()
        self.assertEqual(self.state_of("L4-0417"), "deciding")
        self.assertEqual(self.run.view()["state"], "run_trouble")
        self.dispatcher.register_fails = []
        self.run.resume()
        self.run.tick()
        self.assertIn("DECIDE L4-0417", self.dispatcher.registered[-1]["assignment_markdown"])
        self.assertIn('"I1"', self.dispatcher.registered[-1]["assignment_markdown"])

    def read_cleanly_b_only(self, packet_id):
        independent = fixtures.valid_form("B")
        for number, entry in enumerate(independent["rules"].values()):
            entry["checked"] = ["Second reader item %d: Core Concept states the idea before any example." % number]
        self.hand_in(packet_id, "B", independent)

    def test_a_dead_dispatcher_while_a_chat_is_expected_is_trouble_not_running(self):
        self.run.start()
        self.run.tick()
        self.dispatcher.supervisor = False
        self.run.tick()
        view = self.run.view()
        self.assertEqual(view["state"], "run_trouble")
        self.assertIn("dispatcher is not running", view["reason"])
        self.dispatcher.supervisor = True
        self.run.resume()
        self.assertEqual(self.run.view()["state"], "running")
        self.assertEqual(self.run.view()["reason"], "")

    def test_a_dead_dispatcher_blocks_the_start_of_a_lesson(self):
        self.dispatcher.supervisor = False
        self.run.start()
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "run_trouble")
        self.assertEqual(self.dispatcher.registered, [])
        self.assertIsNone(self.run.q["current"])

    def test_a_dead_dispatcher_is_not_trouble_when_no_chat_is_expected(self):
        self.run.start()
        self.run.tick()
        self.read_cleanly("L4-0417")
        self.run.tick()
        self.run.pause()
        self.dispatcher.supervisor = False
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "paused")

    def test_trouble_waits_for_resume_and_asks_the_dispatcher_nothing(self):
        self.run.start()
        self.run.tick()
        self.run.trouble("gh keeps failing")
        self.assertEqual((self.run.q["state"], self.run.q["reason"]), ("run_trouble", "gh keeps failing"))
        before = len(self.dispatcher.registered)
        self.read_cleanly("L4-0417")
        for _ in range(3):
            self.run.tick()
        self.assertEqual(self.state_of("L4-0417"), "reading")
        self.assertEqual(len(self.dispatcher.registered), before)
        self.run.resume()
        self.run.tick()
        self.assertEqual(self.state_of("L4-0417"), "finished")

    def test_trouble_does_not_hide_a_lesson_that_already_needs_aedwon(self):
        self.run.start()
        self.run.tick()
        self.hand_in("L4-0417", "A", None, result="held")
        self.run.tick()
        self.run.trouble("gh keeps failing")
        self.assertEqual(self.run.view()["state"], "needs_you")
        self.assertIn("Chat 1", self.run.view()["reason"])


class Events(RunCase):
    """Review item 9: hand-in events and erasing do not wait for a lesson to advance."""

    def started(self):
        self.run.start()
        self.run.tick()

    def test_events_are_handled_while_the_run_waits_for_a_limit_reset(self):
        self.started()
        self.dispatcher.states[9001] = {"state": "limit", "detail": "usage_limit"}
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "limit")
        self.hand_in("L4-0417", "B", None, result="rejected")
        self.run.tick()
        self.assertEqual(self.erased, [("L4-0417", "B", 1)])
        self.assertEqual(self.run.view()["chats"][1]["status"], "fixing")
        self.assertEqual(self.run.view()["state"], "limit")

    def test_events_are_handled_while_the_lesson_needs_aedwon(self):
        self.started()
        self.hand_in("L4-0417", "A", None, result="held")
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "needs_you")
        self.hand_in("L4-0417", "B", fixtures.valid_form("B"))
        self.run.tick()
        self.assertEqual(self.erased, [("L4-0417", "A", 1), ("L4-0417", "B", 1)])
        self.assertEqual(self.run.view()["chats"][1]["status"], "done")

    def test_events_are_handled_while_paused_and_in_trouble_and_after_the_pilot_but_not_before_start(self):
        self.hand_in("L4-0417", "A", None, result="rejected", attempt=1)
        self.run.tick()
        self.assertEqual(self.erased, [])  # ready: nothing runs yet
        self.run.start()
        self.run.tick()
        self.run.pause()
        self.hand_in("L4-0417", "A", None, result="rejected")
        self.run.tick()
        self.run.trouble("x")
        self.hand_in("L4-0417", "A", None, result="rejected")
        self.run.tick()
        self.assertEqual(len(self.erased), 3)

    def test_an_old_attempts_event_is_erased_but_does_not_change_the_new_attempt(self):
        self.started()
        self.run.restart_current()
        self.run.tick()
        self.hand_in("L4-0417", "A", None, result="held", attempt=1)
        self.run.tick()
        self.assertEqual(self.erased, [("L4-0417", "A", 1)])
        self.assertEqual(self.run.view()["state"], "running")
        self.assertEqual(self.run.view()["chats"][0]["status"], "working")

    def test_each_event_is_counted_only_after_it_is_handled(self):
        self.started()
        self.hand_in("L4-0417", "A", None, result="rejected")
        self.hand_in("L4-0417", "B", None, result="rejected")
        original = self.run._handle_event
        calls = []

        def flaky(event):
            calls.append(event["role"])
            if event["role"] == "B" and len(calls) == 2:
                raise RuntimeError("disk full")
            original(event)

        self.run._handle_event = flaky
        with self.assertRaises(RuntimeError):
            self.run.tick()
        self.assertEqual(self.run.q["events_seen"], 1)
        self.assertEqual(l4lib.load_json(self.state / "queue.json")["events_seen"], 1)
        self.run._handle_event = original
        self.run.tick()
        self.assertEqual(self.run.q["events_seen"], 2)
        self.assertEqual(self.erased, [("L4-0417", "A", 1), ("L4-0417", "B", 1)])

    def test_every_erase_is_logged_and_a_failing_erase_does_not_stop_the_run(self):
        def erase(packet_id, role, attempt, since):
            if role == "A":
                raise RuntimeError("gh is down")
            return [[77, True, "erased"]]
        self.run.erase = erase
        self.started()
        self.hand_in("L4-0417", "A", None, result="rejected")
        self.hand_in("L4-0417", "B", None, result="rejected")
        self.run.tick()
        lines = [json.loads(line) for line in (self.state / "eraser.log").read_text().splitlines()]
        self.assertEqual([(line["role"], line["attempt"]) for line in lines], [("A", 1), ("B", 1)])
        self.assertIn("gh is down", json.dumps(lines[0]["result"]))
        self.assertEqual(lines[1]["result"], [[77, True, "erased"]])
        self.assertEqual(self.run.q["events_seen"], 2)

    def test_the_erase_gets_the_run_start_time_for_its_listing(self):
        seen = []
        self.run.erase = lambda packet_id, role, attempt, since: seen.append(since) or []
        self.started()
        self.hand_in("L4-0417", "A", None, result="rejected")
        self.run.tick()
        self.assertEqual(seen, [self.run.q["started_at"]])
        self.assertTrue(self.run.q["started_at"].startswith("2026-10-11T09:00:00"))


class Controls(RunCase):
    """Review items 10, 12, 13, 15 and 17, and the standards-changed stop."""

    def started(self):
        self.run.start()
        self.run.tick()

    def dispute_while(self, action):
        self.started()
        self.hand_in("L4-0417", "A", fixtures.failing(fixtures.valid_form("A"), "L17", REAL_QUOTE))
        independent = fixtures.valid_form("B")
        for number, entry in enumerate(independent["rules"].values()):
            entry["checked"] = ["Second reader item %d: Core Concept states the idea before any example." % number]
        self.hand_in("L4-0417", "B", independent)
        action()
        self.run.tick()

    def test_while_paused_a_dispute_is_saved_and_the_deciding_chat_waits_for_resume(self):
        self.dispute_while(self.run.pause)
        self.assertEqual(len(self.dispatcher.registered), 2)
        self.assertEqual(self.state_of("L4-0417"), "reading")
        self.assertTrue((self.state / "deciding" / "L4-0417.json").exists())
        self.assertEqual(self.run.view()["state"], "paused")
        for _ in range(3):
            self.run.tick()
        self.assertEqual(len(self.dispatcher.registered), 2)
        self.run.resume()
        self.run.tick()
        self.assertEqual(self.state_of("L4-0417"), "deciding")
        self.assertEqual(len(self.dispatcher.registered), 3)
        self.assertIn("DECIDE L4-0417", self.dispatcher.registered[-1]["assignment_markdown"])

    def test_resume_from_stopped_works_only_after_the_stop_is_cleared(self):
        self.started()
        l4lib.save_json(self.state / "stop.json", {"reason": "unexpected change", "paths": ["x.md"]})
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "stopped")
        self.run.resume()
        self.assertEqual(self.run.view()["state"], "stopped")
        (self.state / "stop.json").unlink()
        old_head = self.run.q["baseline_head"]
        (self.wt / "resolved.md").write_text("the lead's own fix")
        self.run.resume()
        self.assertEqual(self.run.view()["state"], "running")
        self.assertEqual(self.run.q["reason"], "")
        self.assertEqual(old_head, self.run.q["baseline_head"])
        self.assertIn("resolved.md", self.run.q["baseline_files"])  # a fresh baseline, not the old one

    def test_a_cleared_stop_is_not_raised_again_while_nothing_new_changed(self):
        self.started()
        self.changed = ["x.md"]
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "stopped")
        self.assertEqual(l4lib.load_json(self.state / "stop.json")["paths"], ["x.md"])
        self.changed = []
        (self.state / "stop.json").unlink()
        self.run.resume()
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "running")

    def test_hold_and_restart_keep_a_pause_a_limit_and_a_stop(self):
        for setup, expected in ((lambda: self.run.pause(), "paused"),
                                (lambda: self.run.q.update(state="limit"), "limit"),
                                (lambda: self.run.q.update(state="signin"), "signin"),
                                (lambda: self.run.q.update(state="stopped"), "stopped")):
            for action in (lambda: self.run.restart_current(), lambda: self.run.hold_current("x")):
                self.setUp()
                self.started()
                setup()
                action()
                self.assertEqual(self.run.q["state"], expected)
                self.assertIsNone(self.run.q["current"])

    def test_hold_and_restart_from_needs_you_return_to_running(self):
        for action in (lambda: self.run.restart_current(), lambda: self.run.hold_current("x")):
            self.setUp()
            self.started()
            self.hand_in("L4-0417", "A", None, result="held")
            self.run.tick()
            self.assertEqual(self.run.q["state"], "needs_you")
            action()
            self.assertEqual((self.run.q["state"], self.run.q["reason"]), ("running", ""))

    def test_restart_and_hold_move_the_stale_result_aside(self):
        for action in (lambda: self.run.restart_current(), lambda: self.run.hold_current("x")):
            self.setUp()
            self.started()
            l4lib.save_json(self.state / "results" / "L4-0417.json", {"stale": True})
            self.hand_in("L4-0417", "B", None, result="rejected")
            (self.state / "forms" / "rejected").mkdir(parents=True, exist_ok=True)
            (self.state / "forms" / "rejected" / "L4-0417-B-1-r1.bin").write_bytes(b"{}")
            action()
            self.assertFalse((self.state / "results" / "L4-0417.json").exists())
            self.assertTrue((self.state / "forms" / "discarded" / "L4-0417-attempt-1" / "L4-0417.json").exists())
            self.assertTrue((self.state / "forms" / "discarded" / "L4-0417-attempt-1" / "L4-0417-B-1-r1.bin").exists())

    def test_an_unexpected_change_stops_the_run_on_any_tick_in_any_waiting_state(self):
        for prepare in (lambda: None, lambda: self.run.pause(), lambda: self.run.q.update(state="limit"),
                        lambda: self.run.q.update(state="needs_you", reason="x"),
                        lambda: self.run.q.update(state="run_trouble", reason="x"),
                        lambda: self.run.q.update(state="pilot_done")):
            self.setUp()
            self.started()
            prepare()
            self.run.tick()
            self.assertNotEqual(self.run.q["state"], "stopped")
            self.changed = ["docs/content/audit/coverage-r1/level4/packets/L4-0388.md"]
            self.run.tick()
            self.assertEqual(self.run.q["state"], "stopped")
            self.assertIn("L4-0388.md", self.run.q["reason"])
            stop = l4lib.load_json(self.state / "stop.json")
            self.assertEqual((stop["reason"], stop["paths"]), ("unexpected change", self.changed))

    def test_the_change_check_runs_on_every_tick_and_not_before_start(self):
        calls = []
        self.run.changes = lambda queue: calls.append(1) or []
        self.run.tick()
        self.assertEqual(calls, [])
        self.started()
        for _ in range(3):
            self.run.tick()
        self.assertEqual(len(calls), 4)

    def test_main_changing_the_lesson_standards_stops_the_run_before_the_next_lesson(self):
        self.standards = ["docs/content/lesson-style-guide.md"]
        self.run.start()
        self.run.tick()
        view = self.run.view()
        self.assertEqual(view["state"], "stopped")
        self.assertIn("lesson standards changed", view["reason"])
        self.assertIn("lesson-style-guide.md", view["reason"])
        self.assertEqual(self.dispatcher.registered, [])
        self.assertEqual(self.checked_bases, [l4lib.standards_commit()])

    def test_after_the_lead_clears_a_standards_stop_the_run_goes_on_from_that_main(self):
        self.standards = ["AGENTS.md"]
        self.run.start()
        self.run.tick()
        (self.state / "stop.json").unlink()
        self.run.resume()
        self.assertEqual(self.run.q["standards_accepted"], "m" * 40)
        self.standards = []
        self.run.tick()
        self.assertEqual(self.checked_bases[-1], "m" * 40)
        self.assertEqual(self.run.q["current"], "L4-0417")

    def test_the_standards_check_runs_before_each_lesson_and_not_while_one_is_in_flight(self):
        self.started()
        self.assertEqual(len(self.checked_bases), 1)
        for _ in range(3):
            self.run.tick()
        self.assertEqual(len(self.checked_bases), 1)
        self.read_cleanly("L4-0417")
        self.run.tick()
        self.run.tick()
        self.assertEqual(len(self.checked_bases), 2)

    def test_a_stop_is_not_raised_by_the_standards_check_while_nothing_starts(self):
        self.started()
        self.standards = ["AGENTS.md"]
        for _ in range(3):
            self.run.tick()
        self.assertEqual(self.run.q["state"], "running")


class RelayWatch(RunCase):
    """Review item 6: a chat's relay request that was not one of its two hand-ins stops the run."""

    def request(self, number, **body):
        base = {"relay_version": 2, "workspace": self.wt.name}
        base.update(body)
        return {"number": number, "title": "[relay] l4abc123 hand-in", "user": {"login": "Aedwon"},
                "created_at": "2026-10-11T09:01:00Z", "body": json.dumps(base)}

    def started(self):
        self.run.start()
        self.run.tick()

    def test_the_listing_starts_at_the_run_start(self):
        self.started()
        self.run.tick()
        self.assertTrue(self.dispatcher.listed_since.startswith("2026-10-11T09:00:00"))

    def test_nothing_is_listed_before_start(self):
        self.run.tick()
        self.assertFalse(hasattr(self.dispatcher, "listed_since"))

    def test_a_chat_reading_the_state_directory_is_recorded_and_does_not_stop_the_run(self):
        self.started()
        self.dispatcher.relay = [self.request(4242, action="workspace_exec", argv=["cat", "/Users/x/.pantas-audit/level4/key.json"])]
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "running")
        self.assertEqual(self.run.q["relay_flagged"], [4242])
        self.assertFalse((self.state / "stop.json").exists())

    def test_the_two_hand_in_requests_and_other_workspaces_do_not_stop_the_run(self):
        self.started()
        inbox = "docs/content/audit/coverage-r1/level4/inbox/L4-0417-A-1.json"
        self.dispatcher.relay = [
            self.request(1, action="workspace_write_file", path=inbox, content="{}"),
            self.request(2, action="workspace_exec", argv=["python3", dispatch.HANDIN_SCRIPT, "L4-0417", "A", "1"],
                         timeout_seconds=120),
            dict(self.request(3, action="workspace_exec", argv=["rm", "-rf", "."]), body=json.dumps(
                {"relay_version": 2, "workspace": "Pantas", "action": "workspace_exec", "argv": ["ls"]})),
            dict(self.request(4), body="Hand-in form removed after it was saved."),
        ]
        self.run.tick()
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "running")

    def test_a_hand_in_for_a_role_or_attempt_the_run_never_registered_is_recorded(self):
        self.started()
        self.dispatcher.relay = [self.request(
            9, action="workspace_write_file", content="{}",
            path="docs/content/audit/coverage-r1/level4/inbox/L4-0520-A-1.json")]
        self.run.tick()
        self.assertEqual(self.run.view()["state"], "running")
        self.assertEqual(self.run.q["relay_flagged"], [9])

    def test_each_flagged_issue_is_recorded_once(self):
        self.started()
        self.dispatcher.relay = [self.request(4242, action="workspace_exec", argv=["ls"])]
        self.run.tick()
        self.run.tick()
        self.dispatcher.relay.append(self.request(4300, action="workspace_exec", argv=["ls"]))
        self.run.tick()
        self.assertEqual(self.run.q["relay_flagged"], [4242, 4300])
        self.assertEqual(self.run.view()["state"], "running")

    def test_a_failing_listing_is_an_error_for_the_loop_to_count_and_nothing_advances(self):
        self.started()

        def failing(since):
            raise l4lib.L4Error("could not list relay issues: HTTP 502")
        self.dispatcher.list_relay_issues = failing
        registered = len(self.dispatcher.registered)
        self.read_cleanly("L4-0417")
        with self.assertRaises(l4lib.L4Error):
            self.run.tick()
        self.assertEqual(self.state_of("L4-0417"), "reading")
        self.assertEqual(len(self.dispatcher.registered), registered)


class PlannedOrder(unittest.TestCase):
    def build(self, lessons, planted, pilot_real, prerequisites=None):
        index = {}
        number = 1000
        for lesson in lessons:
            index["L4-%04d" % number] = {"lesson_id": lesson, "planted": False, "subject": "mathematics", "topic": "algebra"}
            number += 1
        for lesson in planted:
            index["L4-%04d" % number] = {"lesson_id": lesson, "planted": True, "subject": "mathematics", "topic": "algebra"}
            number += 1
        order, pilot = runqueue.plan_order(index, prerequisites or {}, pilot_real)
        return index, order, pilot

    def test_every_planted_lesson_after_the_pilot_comes_after_its_real_twin(self):
        lessons = ["l%02d" % number for number in range(30)]
        # Twins chosen so an even spread alone would put them first.
        planted = ["l29", "l28", "l27", "l26", "l25", "l01", "l00"]
        index, order, pilot = self.build(lessons, planted, ["l10", "l11"])
        self.assertEqual(sorted(order), sorted(index))
        position = {packet_id: place for place, packet_id in enumerate(order)}
        real = {entry["lesson_id"]: packet_id for packet_id, entry in index.items() if not entry["planted"]}
        for packet_id, entry in index.items():
            if entry["planted"] and position[packet_id] >= pilot:
                self.assertGreater(position[packet_id], position[real[entry["lesson_id"]]], entry["lesson_id"])

    def test_the_pilot_keeps_its_planted_lessons_even_when_the_twin_comes_later(self):
        index, order, pilot = self.build(["a", "b", "c", "d"], ["a", "b", "c"], ["c", "d"])
        self.assertEqual(pilot, 4)
        self.assertEqual([index[p]["planted"] for p in order[:4]], [False, True, False, True])
        # The pilot's planted lessons are read before their twins: a recorded limit, not hidden.
        self.assertLess(order.index([p for p, e in index.items() if e["planted"] and e["lesson_id"] == "a"][0]),
                        order.index([p for p, e in index.items() if not e["planted"] and e["lesson_id"] == "a"][0]))


class Order(unittest.TestCase):
    def test_pilot_first_then_prerequisites_before_their_lessons(self):
        index = {}
        for number, (lesson, planted) in enumerate([("a", 0), ("b", 0), ("c", 0), ("d", 0), ("a", 1), ("c", 1)]):
            index["L4-%04d" % (1000 + number)] = {"lesson_id": lesson, "planted": bool(planted),
                                                 "subject": "mathematics", "topic": "algebra"}
        order, pilot = runqueue.plan_order(index, {"b": ["d"]}, pilot_real=["c"])
        self.assertEqual(pilot, 2)
        self.assertEqual(order[:2], ["L4-1002", "L4-1004"])
        rest = [index[packet_id]["lesson_id"] for packet_id in order[2:] if not index[packet_id]["planted"]]
        self.assertEqual(rest, ["a", "d", "b"])
        self.assertEqual(sorted(order), sorted(index))


if __name__ == "__main__":
    unittest.main()
