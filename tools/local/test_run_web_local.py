"""No services are started by these checks."""
from pathlib import Path
import json
import subprocess
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import local_seed

ROOT = Path(__file__).resolve().parents[2]
RUNNER = ROOT / 'tools/local/run_web_local.sh'


class LocalRunnerTest(unittest.TestCase):
    def test_dry_runs_cover_pipeline_without_writes(self):
        state = ROOT / 'build/local-web'
        snapshot = lambda: {str(p): p.stat().st_mtime_ns for p in state.rglob('*') if p.is_file()}
        before = snapshot()
        for options, host in [([], '127.0.0.1'), (['--lan'], '<Mac-LAN-IP>')]:
            result = subprocess.run([str(RUNNER), '--dry-run', *options],
                                    capture_output=True, text=True, check=True)
            output = result.stdout
            stages = ['flutter pub get', 'build_runner build', 'functions ci',
                      'functions run build', 'build_content_export.dart',
                      'emulators:start --project demo-pantas-local', 'wait for Auth',
                      'upload_content.mjs', 'seed_accounts.mjs', 'flutter build web --profile',
                      'local App Check debug exchange', 'serve build/web', 'getContent', 'Ctrl-C']
            positions = [output.index(stage) for stage in stages]
            self.assertEqual(positions, sorted(positions))
            self.assertIn(f'LOCAL_EMULATOR_HOST={host}', output)
            self.assertNotIn('--live', output)
            self.assertNotIn('deploy', output)
        self.assertEqual(before, snapshot())

    def test_code_corpus_skips_content_branch(self):
        result = subprocess.run([str(RUNNER), '--dry-run', '--corpus', 'code'],
                                capture_output=True, text=True, check=True)
        self.assertNotIn('git archive', result.stdout)
        self.assertIn('build_content_export.dart build/export.json', result.stdout)

    def test_default_corpus_has_explicit_fallback(self):
        result = subprocess.run([str(RUNNER), '--dry-run'],
                                capture_output=True, text=True, check=True)
        self.assertIn('if CSE export fails', result.stdout)
        self.assertIn('fallback to code corpus', result.stdout)

    def test_invalid_options_stop_before_pipeline(self):
        for options in [['--host', '192.168.1.1'], ['--port', '0'], ['--unknown']]:
            result = subprocess.run([str(RUNNER), *options], capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn('flutter pub get', result.stdout)

    def test_runtime_guard_rejects_external_service_before_network(self):
        source = """
require('./tools/local/offline_guard.cjs');
(async () => {
  for (const endpoint of ['https://api.paymongo.com/v2/checkout_sessions',
                           'https://firestore.googleapis.com/']) {
    let blocked = false;
    try { await fetch(endpoint); }
    catch (error) { blocked = error.message.startsWith('Local runner blocked external service:'); }
    if (!blocked) throw Error('External service was not blocked');
  }
  let blocked = false;
  try { require('node:https').get('https://api.paymongo.com/'); }
  catch (error) { blocked = error.message.startsWith('Local runner blocked external service:'); }
  if (!blocked) throw Error('HTTPS client was not blocked');
})();
"""
        subprocess.run(['node', '-e', source], cwd=ROOT, check=True)


class LocalSeedRequestTest(unittest.TestCase):
    ok = json.dumps({'uid': 'local-free', 'profile': 'steady'}).encode()

    def check(self, body=ok, content_type='application/json', ip='127.0.0.1',
              origin='http://127.0.0.1:7357', lan=False):
        return local_seed.check(body, content_type, ip, '127.0.0.1', 7357, origin, lan)

    def refused(self, status, **kwargs):
        with self.assertRaises(local_seed.Refused) as caught:
            self.check(**kwargs)
        self.assertEqual(caught.exception.status, status)

    def test_accepts_this_machine_and_each_profile(self):
        self.assertEqual(self.check(), ('local-free', 'steady'))
        self.assertEqual(self.check(origin=None, ip='::1'), ('local-free', 'steady'))
        self.assertEqual(self.check(origin='http://localhost:7357'), ('local-free', 'steady'))
        for profile in ['new', 'steady', 'behind', 'examWeek']:
            body = json.dumps({'uid': 'local-pro', 'profile': profile}).encode()
            self.assertEqual(self.check(body=body), ('local-pro', profile))

    def test_refuses_other_machines_pages_and_lan_runs(self):
        self.refused(403, ip='192.168.1.20')
        self.refused(403, origin='http://evil.example')
        self.refused(403, origin='http://localhost:9999')
        self.refused(403, lan=True)
        self.refused(415, content_type='text/plain')

    def test_refuses_bad_bodies(self):
        for body in [b'not json', b'{}', b'[]', b'{"uid":"a/b","profile":"steady"}',
                     b'{"uid":"local-free","profile":"expert"}', b'{"uid":1,"profile":"new"}']:
            self.refused(400, body=body)

    def test_dry_run_announces_the_seed_endpoint(self):
        result = subprocess.run([str(RUNNER), '--dry-run'], capture_output=True, text=True, check=True)
        self.assertIn('POST /local-seed runs tools/local/seed_student.mjs', result.stdout)
        self.assertTrue((ROOT / 'tools/local/seed_student.mjs').exists())


if __name__ == '__main__':
    unittest.main()
