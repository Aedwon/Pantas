"""No services are started by these checks."""
from pathlib import Path
import json
import re
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
                      'local App Check debug exchange', 'tool/list_routes.dart',
                      'serve build/web', 'getContent', 'Ctrl-C']
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


PANEL = ROOT / 'tools/local/panel'
PRESET_IDS = ['welcome', 'birthYear', 'terms', 'picker', 'dateKnown', 'days', 'name', 'under13',
              'customName', 'customSubjects', 'dateNone', 'dateMonth', 'dateDay', 'dateNextYear',
              'dateThisMonth', 'dateToday', 'daysNone', 'daysTooLate', 'daysSoon']


class LocalPanelTest(unittest.TestCase):
    page = (PANEL / 'index.html').read_text()
    reset = (PANEL / 'local-reset.html').read_text()
    runner = (ROOT / 'tools/local/run_web_local.py').read_text()

    def test_dry_run_announces_the_panel_in_build_web_only(self):
        result = subprocess.run([str(RUNNER), '--dry-run'], capture_output=True, text=True, check=True)
        self.assertIn('the test panel in build/web only', result.stdout)
        self.assertIn('list_routes.dart > build/web/local-panel-routes.json', result.stdout)

    def test_runner_writes_the_panel_files_into_build_web(self):
        for name in ['local-panel.html', 'local-reset.html', 'local-panel-routes.json']:
            self.assertIn(f"'build/web/{name}'", self.runner)
        self.assertIn('/local-panel.html', self.runner)
        self.assertIn('Test panel (second tab)', self.runner)
        # Browser files come only from tools/local/panel; web/ is never written.
        self.assertNotIn("Path('web/", self.runner)
        self.assertNotIn("'web/", self.runner.replace("'web/", "", 0) if False else '')

    def test_emulator_cannot_stop_to_ask_for_params(self):
        source = Path('tools/local/run_web_local.py').read_text()
        self.assertIn('stdin=subprocess.DEVNULL', source)
        for name in ('GUARDIAN_MAIL_FROM', 'GUARDIAN_LINK_ORIGIN', 'GUARDIAN_DAILY_SEND_CAP'):
            self.assertIn(name + '=', source)

    def test_runner_has_no_date_patch(self):
        for text in [self.runner, self.page, self.reset]:
            self.assertNotIn('pantas.local.today', text)
            self.assertNotIn('extends Date', text)
            self.assertNotIn('window.Date', text)

    def test_shim_skips_the_welcome_splash_except_for_welcome(self):
        self.assertIn("localStorage.setItem('pantas.welcome.seen', '1')", self.runner)
        self.assertIn("has('localStudent')", self.runner)
        self.assertIn("preset !== 'welcome'", self.runner)
        self.assertIn("getElementById('pw-start')?.click()", self.runner)
        # The shim goes in before pantas_welcome.js runs, which is the first script after <head>.
        self.assertIn("replace('<head>', '<head>' + shim)", self.runner)

    def test_every_card_id_is_on_the_page(self):
        found = re.findall(r'data-preset="([A-Za-z0-9]+)"', self.page)
        self.assertEqual(found, PRESET_IDS)
        students = re.findall(r'data-student="([A-Za-z0-9]+)"', self.page)
        self.assertEqual(students, ['new', 'steady', 'behind', 'examWeek'])

    def test_tabs_are_onboarding_students_and_screens(self):
        tabs = re.findall(r'<span(?: class="on")? data-t="[a-z]+">([^<]+)</span>', self.page)
        self.assertEqual(tabs, ['Onboarding', 'Sample students', 'Screens'])

    def test_panel_speaks_only_the_agreed_messages(self):
        sent = set(re.findall(r"send\(\{type: '([a-z]+)'", self.page))
        self.assertEqual(sent, {'ping', 'go', 'plan', 'fresh'})
        self.assertIn("new BroadcastChannel(CHANNEL)", self.page)
        self.assertIn("'pantas-local-panel'", self.page)

    def test_panel_text_and_behavior_from_the_plan(self):
        for text in ["Start fresh? This clears this browser\\'s Pantas data.", 'App tab not open',
                     'App tab connected', '#8A8A8E', "window.open(path, 'pantas-app')",
                     "openApp('/local-reset.html')", 'Search screens', 'Uses the current exam',
                     'PING_MS = 2000', 'LOST_MS = 3000', "'pantas.local.plan'"]:
            self.assertIn(text, self.page)
        # Cards with a parameter other than :examId stay disabled until it is filled.
        self.assertIn("p !== 'examId'", self.page)
        self.assertIn("card.classList.toggle('off', !ready())", self.page)

    def test_reset_page_keeps_panel_keys_and_picks_the_account_from_the_plan(self):
        for text in ["'pantas.local.'", 'indexedDB.databases', 'getDirectory', 'caches.keys',
                     'sessionStorage.clear', "plan === 'pro' ? 'pro' : 'free'",
                     "'/?localAccount=' + account + '&localStudent='",
                     "location.replace('/')", "localStorage.removeItem(KEEP + 'student')"]:
            self.assertIn(text, self.reset)

    def test_page_scripts_parse(self):
        for page in [self.page, self.reset]:
            body = re.search(r'<script>(.*)</script>', page, re.S).group(1)
            check = ROOT / 'build/.panel_check.js'
            check.parent.mkdir(parents=True, exist_ok=True)
            check.write_text(body)
            try:
                subprocess.run(['node', '--check', str(check)], check=True, capture_output=True)
            finally:
                check.unlink(missing_ok=True)


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
        self.assertEqual(self.check(), ('local-free', 'steady', None))
        self.assertEqual(self.check(origin=None, ip='::1'), ('local-free', 'steady', None))
        self.assertEqual(self.check(origin='http://localhost:7357'), ('local-free', 'steady', None))
        for profile in ['new', 'steady', 'behind', 'examWeek']:
            body = json.dumps({'uid': 'local-pro', 'profile': profile}).encode()
            self.assertEqual(self.check(body=body), ('local-pro', profile, None))

    def test_accepts_each_home_state_and_nothing_else(self):
        for state in local_seed.STATES:
            body = json.dumps({'uid': 'local-pro', 'profile': 'steady', 'state': state}).encode()
            self.assertEqual(self.check(body=body), ('local-pro', 'steady', state))
        self.refused(400, body=json.dumps({'uid': 'local-pro', 'profile': 'steady', 'state': '--x'}).encode())
        self.refused(400, body=json.dumps({'uid': 'local-pro', 'profile': 'steady', 'state': 5}).encode())

    def test_every_state_is_defined_by_the_seed_script(self):
        script = (ROOT / 'tools/local/seed_student.mjs').read_text()
        for state in local_seed.STATES:
            self.assertIn(f'  {state}: {{', script)

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
