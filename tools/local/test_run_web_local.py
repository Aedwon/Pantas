"""No services are started by these checks."""
from pathlib import Path
import subprocess
import unittest

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


if __name__ == '__main__':
    unittest.main()
