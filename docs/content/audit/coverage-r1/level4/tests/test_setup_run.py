import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import setup_run  # noqa: E402

INDEX = {
    "L4-1000": {"lesson_id": "a", "planted": False}, "L4-1001": {"lesson_id": "b", "planted": False},
    "L4-1002": {"lesson_id": "b", "planted": True},
}
ALL = set(INDEX)


class Check(unittest.TestCase):
    def test_ready_when_everything_is_committed(self):
        self.assertEqual(setup_run.check(INDEX, ["a"], ALL, False), [])

    def test_an_existing_queue_is_never_replaced(self):
        self.assertIn("already exists", setup_run.check(INDEX, ["a"], ALL, True)[0])

    def test_uncommitted_packets_block_the_run(self):
        problems = setup_run.check(INDEX, ["a"], ALL - {"L4-1002"}, False)
        self.assertEqual(len(problems), 1)
        self.assertIn("L4-1002", problems[0])

    def test_pilot_lessons_must_be_real_and_have_no_planted_twin(self):
        self.assertIn("not in the corpus", setup_run.check(INDEX, ["zzz"], ALL, False)[0])
        self.assertIn("planted copy", setup_run.check(INDEX, ["b"], ALL, False)[0])

    def test_the_pilot_needs_enough_planted_lessons(self):
        index = dict(INDEX, **{"L4-1003": {"lesson_id": "c", "planted": False}})
        self.assertIn("planted lessons", setup_run.check(index, ["a", "c"], set(index), False)[0])


if __name__ == "__main__":
    unittest.main()
