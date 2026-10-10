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

    def register(self, envelope):
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
        return True

    def list_relay_issues(self, since):
        return []


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
        self.erased = []
        prompts = Path(tempfile.mkdtemp())
        (prompts / "reader.md").write_text("READ {{PACKET}} {{ROLE}} {{ATTEMPT}} {{COMMIT}}")
        (prompts / "decider.md").write_text("DECIDE {{PACKET}} {{COMMIT}} {{FORM}} {{ITEMS}}")
        self.prompts = prompts
        self.run = self.new_run()
        self.run.create(PACKETS, pilot_count=2, packets_commit="c" * 40)

    def new_run(self):
        return runqueue.Run(self.dispatcher, state_dir=self.state, config={"seed": 5, "run_token": "l4abc123"},
                            erase=lambda packet_id, role: self.erased.append((packet_id, role)),
                            now=lambda: self.clock, audit_wt=self.wt,
                            lesson_text=lambda entry: fixtures.LESSON_TEXT, prompts_dir=self.prompts)

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
        self.assertEqual(sorted(self.erased), [("L4-0417", "A"), ("L4-0417", "B")])
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
        self.assertEqual(self.erased, [("L4-0417", "A")])


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
        self.read_cleanly("L4-0417")
        self.run.tick()
        self.assertEqual(self.state_of("L4-0417"), "finished")
        self.run.tick()
        self.assertIsNone(self.run.q["current"])
        self.run.resume()
        self.run.tick()
        self.assertEqual(self.run.q["current"], "L4-0520")

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
