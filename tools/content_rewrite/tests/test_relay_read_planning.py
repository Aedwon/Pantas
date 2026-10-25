"""Read planning regressions. All state is temporary and git is a fake."""
import sys
import tempfile
import threading
import unittest
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from unittest.mock import patch

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
import relay_fixtures  # noqa: E402,F401
import planner  # noqa: E402
import rw_lib  # noqa: E402
import status  # noqa: E402


class ReadPlanning(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.texts = {lesson: 'Current ' + lesson for lesson in ('a', 'b', 'c')}
        self.briefs = {lesson: {'path': lesson + '.md'} for lesson in self.texts}
        outer = self

        class Git:
            def show(self, spec):
                return outer.texts.get(spec.split(':', 1)[1].removesuffix('.md'))

            def text(self, *args, **kwargs):
                return ''

        self.ctx = rw_lib.Ctx(root=tmp.name, state_dir=Path(tmp.name) / 'state', git=Git())
        self.ctx.save_batches({'order': ['RW-001'], 'batches': {
            'RW-001': {'id': 'RW-001', 'type': 'rewrite', 'topic': 't', 'lessons': ['a', 'b', 'c']}}})
        for lesson in self.texts:
            self.accept(lesson)
        mock = patch.object(planner.briefs_mod, 'load_all', return_value=self.briefs)
        mock.start()
        self.addCleanup(mock.stop)

    def accept(self, lesson, commit='rewrite-1'):
        rw_lib.json_save(self.ctx.accepted_path('rewrite', lesson), {
            'commit': commit, 'sha256': rw_lib.sha256_text(self.texts[lesson]), 'batch': 'RW-001'})

    def plan(self):
        return planner.plan(self.ctx, kinds=['read'])

    def add_batch(self, batch_id, kind, lessons):
        data = self.ctx.load_batches()
        data['order'].append(batch_id)
        data['batches'][batch_id] = {
            'id': batch_id, 'type': kind, 'topic': 't', 'lessons': lessons}
        self.ctx.save_batches(data)

    def test_requeued_lessons_appear_only_once(self):
        self.add_batch('RW-002', 'rewrite', ['a', 'a', 'b'])
        self.assertEqual(self.plan(), ['RD-001'])
        self.assertEqual(self.ctx.batch('RD-001')['lessons'], ['a', 'b', 'c'])
        self.assertEqual(self.plan(), [])

    def test_current_accepted_rewrite_is_already_covered(self):
        self.plan()
        self.assertEqual(self.plan(), [])
        self.assertEqual(self.ctx.load_batches()['order'], ['RW-001', 'RD-001'])

    def test_concurrent_planning_checks_coverage_inside_lock(self):
        entered, release, second_started, second_entered = (threading.Event() for _ in range(4))
        original = planner._read_proposals
        calls = []

        def proposals(ctx):
            calls.append(ctx)
            if len(calls) == 1:
                entered.set()
                if not release.wait(5):
                    raise AssertionError('first planner was not released')
            else:
                second_entered.set()
            return original(ctx)

        def second():
            second_started.set()
            # A second context, as another App instance could use.
            ctx = rw_lib.Ctx(self.ctx.root, self.ctx.state, self.ctx.git)
            return planner.plan(ctx, kinds=['read'])

        with patch.object(planner, '_read_proposals', side_effect=proposals):
            with ThreadPoolExecutor(max_workers=2) as pool:
                first = pool.submit(self.plan)
                try:
                    self.assertTrue(entered.wait(5))
                    other = pool.submit(second)
                    self.assertTrue(second_started.wait(5))
                    self.assertFalse(second_entered.wait(0.1))
                finally:
                    release.set()
                self.assertEqual(first.result(timeout=5), ['RD-001'])
                self.assertEqual(other.result(timeout=5), [])
        self.assertEqual(self.ctx.load_batches()['order'], ['RW-001', 'RD-001'])

    def test_new_rewrite_gets_a_read_even_with_the_same_text(self):
        self.plan()
        self.accept('a', 'rewrite-2')
        self.assertEqual(self.plan(), ['RD-002'])
        self.assertEqual(self.ctx.batch('RD-002')['lessons'], ['a'])
        self.assertEqual(self.ctx.batch('RD-002')['rewrites'], {'a': 'rewrite-2'})
        self.assertEqual(self.plan(), [])

    def test_lead_fix_gets_current_hash_without_changing_accepted_record(self):
        self.plan()
        accepted = self.ctx.accepted('rewrite', 'a')
        self.texts['a'] += '\nLead fix\n'
        # A stale read needs a replacement even if another lesson is pending.
        self.ctx.accepted_path('rewrite', 'c').unlink()
        self.assertEqual(self.plan(), ['RD-002'])
        batch = self.ctx.batch('RD-002')
        self.assertEqual(batch['lessons'], ['a'])
        self.assertEqual(batch['sha256']['a'], rw_lib.sha256_text(self.texts['a']))
        self.assertEqual(self.ctx.accepted('rewrite', 'a'), accepted)
        self.assertEqual(self.plan(), [])

    def test_read_replacement_requires_all_lessons_and_counts_as_done(self):
        self.plan()
        old = self.ctx.batch('RD-001')
        self.add_batch('RW-002', 'rewrite', ['a', 'b', 'c'])
        self.assertIsNone(status.replacement(self.ctx, old))
        self.add_batch('RD-002', 'read', ['a'])
        self.assertIsNone(status.replacement(self.ctx, old))
        self.add_batch('RD-003', 'read', ['b', 'c'])
        view = status.batch_view(self.ctx, old, [], {}, [])
        self.assertEqual(view['state'], 'replaced')
        self.assertEqual(view['label'], 'Replaced by RD-002, RD-003')
        self.assertTrue(view['done'])

        class Gh:
            def runs(self):
                return []

        overview = status.overview(self.ctx, Gh())
        self.assertEqual(overview['next'], 'RD-002')
        self.assertEqual(overview['counts']['done'], 1)
        self.assertIsNone(status.replacement(self.ctx, self.ctx.batch('RD-003')))

    def test_duplicate_read_is_replaced_by_newer_unstarted_read(self):
        self.plan()
        data = self.ctx.load_batches()
        data['order'].append('RD-002')
        data['batches']['RD-002'] = dict(self.ctx.batch('RD-001'), id='RD-002')
        self.ctx.save_batches(data)
        old = status.batch_view(self.ctx, self.ctx.batch('RD-001'), [], {}, [])
        self.assertEqual((old['state'], old['label'], old['done']),
                         ('replaced', 'Replaced by RD-002', True))


if __name__ == '__main__':
    unittest.main()
