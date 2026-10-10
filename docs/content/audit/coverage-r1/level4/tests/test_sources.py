import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import sources  # noqa: E402

LEDGER = """## Explicit per-lesson disposition

Paths below are relative to `content/lessons/`.

**CORRECTED**

- `mathematics/algebra/polynomials.md`

**VERIFIED**

- `science/chemistry/matter.md`
"""
LESSONS = [{"metadata__id": "a", "path": "content/lessons/mathematics/algebra/polynomials.md"},
           {"metadata__id": "b", "path": "content/lessons/science/chemistry/matter.md"},
           {"metadata__id": "c", "path": "content/lessons/science/chemistry/new.md"}]


class Check(unittest.TestCase):
    def test_a_lesson_the_ledger_lists_has_an_entry_and_one_it_does_not_list_has_none(self):
        rows = sources.check(LEDGER, LESSONS, [])
        self.assertEqual([rows[key]["in_ledger"] for key in "abc"], [True, True, False])

    def test_only_a_lesson_edited_after_the_ledger_is_marked_changed(self):
        rows = sources.check(LEDGER, LESSONS, ["content/lessons/science/chemistry/matter.md", ""])
        self.assertEqual([rows[key]["changed_since_ledger"] for key in "abc"], [False, True, False])


if __name__ == "__main__":
    unittest.main()
