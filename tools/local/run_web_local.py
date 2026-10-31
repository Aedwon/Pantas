#!/usr/bin/env python3
"""One disposable demo project. No Firebase login, real config, or secret lookup."""
import argparse
import base64
import functools
import http.server
import json
import os
from pathlib import Path
import shlex
import shutil
import signal
import socket
import subprocess
import sys
import time
import urllib.request

sys.path.insert(0, str(Path(__file__).resolve().parent))
import local_seed

ROOT = Path(__file__).resolve().parents[2]
os.chdir(ROOT)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--lan', action='store_true')
parser.add_argument('--host', help='Mac LAN address (with --lan), otherwise auto-detected')
parser.add_argument('--port', type=int, default=7357)
parser.add_argument('--corpus', choices=['code', 'cse'], default='cse',
                    help='Content source (default: cse, falling back to code if export fails)')
parser.add_argument('--dry-run', action='store_true', help='Print every command; start nothing')
args = parser.parse_args()
if args.host and not args.lan:
    parser.error('--host requires --lan')
if not 1024 <= args.port <= 65535:
    parser.error('--port must be between 1024 and 65535')
host = '127.0.0.1'
if args.lan:
    if args.host:
        host = args.host
    elif args.dry_run:
        host = '<Mac-LAN-IP>'
    else:
        interface = subprocess.check_output(['route', '-n', 'get', 'default'], text=True)
        device = next(line.split(':')[1].strip() for line in interface.splitlines() if 'interface:' in line)
        host = subprocess.check_output(['ipconfig', 'getifaddr', device], text=True).strip()
    if not args.dry_run:
        socket.inet_aton(host)
        with socket.socket() as probe:
            probe.bind((host, 0))
project = 'demo-pantas-local'
state = ROOT / 'build/local-web'
env = {k: v for k, v in os.environ.items() if k not in (
    'GOOGLE_APPLICATION_CREDENTIALS', 'FIREBASE_TOKEN', 'GOOGLE_CLOUD_PROJECT',
    'GCLOUD_PROJECT', 'NODE_OPTIONS')}
env.update(GCLOUD_PROJECT=project, GOOGLE_CLOUD_PROJECT=project,
           FIRESTORE_EMULATOR_HOST=f'{host}:8080',
           FIREBASE_AUTH_EMULATOR_HOST=f'{host}:9099',
           FIREBASE_STORAGE_EMULATOR_HOST=f'{host}:9199',
           FIREBASE_CLI_DISABLE_MOTD='true', CI='true',
           XDG_CONFIG_HOME=str(state / 'cli-config'), CLOUDSDK_CONFIG=str(state / 'gcloud-config'))
children = []

def run(command, **kwargs):
    print('+ ' + shlex.join(map(str, command)), flush=True)
    if not args.dry_run:
        subprocess.run(list(map(str, command)), env=env, check=True, **kwargs)

def cleanup(*_):
    for child in reversed(children):
        try:
            os.killpg(child.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
    for child in children:
        try:
            child.wait(timeout=15)
        except subprocess.TimeoutExpired:
            os.killpg(child.pid, signal.SIGKILL)
            child.wait()


def start(command, log):
    print('+ ' + shlex.join(map(str, command)) + f' > {log}', flush=True)
    if args.dry_run:
        return
    with open(log, 'w') as output:
        child = subprocess.Popen(list(map(str, command)), env=env, stdout=output,
                                 stderr=subprocess.STDOUT, start_new_session=True)
    children.append(child)


def request(url, data=None, headers=None):
    req = urllib.request.Request(url, data=None if data is None else json.dumps(data).encode(),
                                 headers={'Content-Type': 'application/json', **(headers or {})})
    # LAN addresses must bypass system HTTP proxies.
    with urllib.request.build_opener(urllib.request.ProxyHandler({})).open(req, timeout=15) as reply:
        return json.load(reply)


def main():
    if not args.dry_run:
        for port in [8080, 9099, 9199, 5001, 4400, 4500, 9150, args.port]:
            with socket.socket() as probe:
                try:
                    probe.bind((host, port))
                except OSError:
                    raise SystemExit(f'Port {port} is busy. Nothing started. Stop its owner and retry.')
        state.mkdir(parents=True, exist_ok=True)
    run(['flutter', 'pub', 'get'])
    run(['dart', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'])
    run(['npm', '--prefix', 'functions', 'ci', '--no-audit', '--no-fund'])
    run(['npm', '--prefix', 'functions', 'run', 'build'])
    # An isolated source folder prevents the CLI from loading developer .env or secrets.
    isolated = state / 'functions'
    if not args.dry_run:
        if isolated.exists():
            shutil.rmtree(isolated)
        isolated.mkdir()
        shutil.copytree('functions/lib', isolated / 'lib')
        shutil.copy('functions/package.json', isolated)
        (isolated / 'node_modules').symlink_to(ROOT / 'functions/node_modules', target_is_directory=True)
        (isolated / '.secret.local').write_text(
            'TRIAL_IDENTITY_HMAC_KEY=local-emulator-only-not-a-secret\n'
            'PAYMONGO_SECRET_KEY=local-disabled\nPAYMONGO_WEBHOOK_SECRET=local-disabled\n')
        shutil.copy('tools/local/offline_guard.cjs', isolated)
        (isolated / '.env.local').write_text(f'NODE_OPTIONS=--require={isolated}/offline_guard.cjs\nBETA_PRO_UNTIL={env.get("BETA_PRO_UNTIL", "")}\n')
    content_root = ROOT
    selected_corpus = args.corpus
    # Require the actual CSE teaching corpus, not just the empty exam roster.
    outline = json.loads(Path('tools/lesson_author/outline.json').read_text())
    has_cse = (any(row.get('exam') == 'cse-pro' for row in outline['subjects'])
               and Path('content/lesson-prerequisites.json').exists())
    export_command = ['dart', 'run', 'tools/build_content_export/build_content_export.dart',
                      'build/export.json']
    if args.corpus == 'cse':
        try:
            if not has_cse:
                content_root = state / 'corpus'
                print('+ git archive origin/content/cse-rewrite-r1 content tools/lesson_author/outline.json | tar -x -C build/local-web/corpus')
                if not args.dry_run:
                    if content_root.exists():
                        shutil.rmtree(content_root)
                    content_root.mkdir()
                    archive = subprocess.run(['git', 'archive', 'origin/content/cse-rewrite-r1',
                                              'content', 'tools/lesson_author/outline.json'], check=True, stdout=subprocess.PIPE)
                    subprocess.run(['tar', '-x', '-C', str(content_root)], input=archive.stdout, check=True)
                    # The export also reads this code-branch file, which the content branch lacks.
                    historical = content_root / 'tools/build_content_export/historical_v1.json'
                    historical.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy(ROOT / 'tools/build_content_export/historical_v1.json', historical)
            run([*export_command, content_root, '--assets-out', 'assets/seed'])
        except subprocess.CalledProcessError:
            print('NOTICE: CSE export failed; using the code corpus for layout checks.', flush=True)
            content_root = ROOT
            selected_corpus = 'code'
            run(export_command)
        if args.dry_run:
            print('+ if CSE export fails: NOTICE and fallback to code corpus')
            run(export_command)
    else:
        run(export_command)
    config_path = state / 'firebase.json'
    if not args.dry_run:
        config = {
            'functions': {'source': 'functions', 'runtime': 'nodejs22'},
            'firestore': {'rules': str(ROOT / 'firestore.rules'), 'indexes': str(ROOT / 'firestore.indexes.json')},
            'storage': {'rules': str(ROOT / 'storage.rules')},
            'emulators': {name: {'host': host, 'port': port} for name, port in
                          [('auth', 9099), ('firestore', 8080), ('functions', 5001), ('storage', 9199),
                           ('hub', 4400), ('logging', 4500)]}}
        config['emulators'].update(ui={'enabled': False}, singleProjectMode=True)
        config['emulators']['firestore']['websocketPort'] = 9150
        config_path.write_text(json.dumps(config))
    start(['functions/node_modules/.bin/firebase', 'emulators:start', '--project', project,
           '--config', config_path, '--only', 'auth,firestore,functions,storage'], state / 'emulators.log')
    print('+ wait for Auth, Firestore, Functions and Storage (180 seconds maximum)', flush=True)
    if not args.dry_run:
        deadline = time.monotonic() + 180
        while True:
            try:
                for port in [9099, 8080, 5001, 9199]:
                    with socket.create_connection((host, port), timeout=1):
                        pass
                break
            except OSError:
                if children[0].poll() is not None or time.monotonic() > deadline:
                    raise SystemExit(f'Emulators failed. See {state}/emulators.log')
                time.sleep(1)
    upload_options = []
    if selected_corpus == 'code':
        print('NOTICE: Code corpus layout preview skips invalid sources; uploader lists each omission.', flush=True)
        upload_options = ['--skip-invalid']
    run(['node', 'tools/upload_content/upload_content.mjs', '--root', content_root / 'content',
         '--export', 'build/export.json', '--project', project, *upload_options])
    run(['node', 'tools/local/seed_accounts.mjs'])
    run(['flutter', 'build', 'web', '--profile', '--no-web-resources-cdn', '-t', 'lib/main_dev.dart',
         f'--dart-define=LOCAL_EMULATOR_HOST={host}'])
    print('+ install local App Check debug exchange and local account links in build/web only', flush=True)
    if not args.dry_run:
        index = Path('build/web/index.html')
        shim = '''<script>
// WebDebugProvider still asks for an exchange. Return an unsigned emulator token locally.
const localFetch = window.fetch.bind(window);
window.fetch = (input, init) => {
  const url = new URL(typeof input === 'string' ? input : input.url, location.href);
  if (url.hostname === 'firebaseappcheck.googleapis.com') {
    return localFetch('/local-app-check', {method: 'GET'});
  }
  if (url.hostname === 'api.paymongo.com') return Promise.reject(new Error('Checkout is disabled locally.'));
  return localFetch(input, init);
};
window.pantasPwa = null;
</script>'''
        index.write_text(index.read_text().replace('<head>', '<head>' + shim))
        # Do not register the production caching worker during a local visual check.
        Path('build/web/pantas_pwa.js').write_text('window.pantasPwa = null;\n')
        Path('build/web/local-login.html').write_text(
            '<h1>Local visual check</h1><p><a href="/?localAccount=free">Free account</a></p>'
            '<p><a href="/?localAccount=pro">Pro account</a></p>'
            '<p>Checkout cannot complete locally. Install and offline need HTTPS and are tested after deploy.</p>')
    print(f'+ serve build/web at http://{host}:{args.port} (SPA routes, no caching)', flush=True)
    print('+ local-only POST /local-seed runs tools/local/seed_student.mjs for a sample student', flush=True)
    print('+ curl served page and authenticated getContent through Functions emulator', flush=True)
    if args.dry_run:
        print('+ print URL, Free/Pro logins and optional ASCII QR; stop process groups on Ctrl-C')
        return

    class Handler(http.server.SimpleHTTPRequestHandler):
        def end_headers(self):
            self.send_header('Cache-Control', 'no-store')
            super().end_headers()

        def do_GET(self):
            if self.path == '/local-app-check':
                now = int(time.time())
                encode = lambda value: base64.urlsafe_b64encode(json.dumps(value).encode()).decode().rstrip('=')
                token = encode({'alg': 'none', 'typ': 'JWT'}) + '.' + encode(
                    {'sub': '1:123456789:web:local', 'iat': now, 'exp': now + 3600,
                     'aud': ['projects/123456789'], 'iss': 'https://firebaseappcheck.googleapis.com/123456789'}) + '.'
                payload = json.dumps({'token': token, 'ttl': '3600s'}).encode()
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(payload)
                return
            if not Path(self.translate_path(self.path)).exists():
                self.path = '/index.html'
            super().do_GET()

        def do_POST(self):
            # Sample students: server records are written by the server's own handlers, so a page
            # in this browser asks this server to run the seed script. Emulators only.
            try:
                if self.path != '/local-seed':
                    raise local_seed.Refused(404, 'Not found.')
                size = int(self.headers.get('Content-Length') or 0)
                if size > 4096:
                    raise local_seed.Refused(413, 'Too large.')
                uid, profile = local_seed.check(
                    self.rfile.read(size), self.headers.get('Content-Type'), self.client_address[0],
                    host, args.port, self.headers.get('Origin'), args.lan)
                status, reply = 200, local_seed.seed(uid, profile, env)
            except local_seed.Refused as refusal:
                status, reply = refusal.status, {'error': str(refusal)}
            except Exception as error:  # a timeout or a bad result must still answer the page
                status, reply = 500, {'error': f'Seed failed: {type(error).__name__}'}
            payload = json.dumps(reply).encode()
            self.send_response(status)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Content-Length', str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)

    import threading
    server = http.server.ThreadingHTTPServer((host, args.port),
        functools.partial(Handler, directory=str(ROOT / 'build/web')))
    threading.Thread(target=server.serve_forever, daemon=True).start()
    url = f'http://{host}:{args.port}'
    # Run curl explicitly as requested. Do not print page bodies or Auth tokens.
    run(['curl', '--noproxy', '*', '--fail', '--silent', '--output', os.devnull, url])
    signed = request(f'http://{host}:9099/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=demo-pantas-local-api-key',
                     {'email': 'free@pantas.local', 'password': 'Local-visual-check-123!', 'returnSecureToken': True})
    app_check = request(url + '/local-app-check')['token']
    result_file = state / 'content-check.json'
    curl_config = state / 'curl-local.conf'
    curl_config.write_text(f'header = "Authorization: Bearer {signed["idToken"]}"\n'
                           f'header = "X-Firebase-AppCheck: {app_check}"\n')
    curl_config.chmod(0o600)
    try:
        run(['curl', '--noproxy', '*', '--fail', '--silent', '--config', curl_config,
             '-H', 'Content-Type: application/json', '--data', '{"data":{"kind":"catalog","ids":["index"]}}',
             '--output', result_file, f'http://{host}:5001/{project}/asia-southeast1/getContent'])
        result = json.loads(result_file.read_text())['result']
        if result['items']['index']['status'] != 'ok' or 'exam_cse_pro' not in json.dumps(result):
            raise SystemExit('getContent did not serve the CSE catalog')
    finally:
        curl_config.unlink(missing_ok=True)
    print('PASS: served page and getContent CSE catalog through emulators.', flush=True)
    print(f'\nOpen {url}/local-login.html\n' + (state / 'logins.txt').read_text(), flush=True)
    print('Checkout cannot complete locally. Install and offline need HTTPS and are tested after deploy.', flush=True)
    if args.lan:
        # Use only an already installed package. Plain URL is the fallback.
        run(['node', '-e', "try {require('./functions/node_modules/qrcode-terminal').generate(process.argv[1], {small:true});} catch {console.log('QR unavailable. Open: ' + process.argv[1]);}", url + '/local-login.html'])
    print('Ctrl-C stops all local services. Emulator data resets next run.', flush=True)
    while True:
        if children[0].poll() is not None:
            raise SystemExit('Emulator process stopped. See build/local-web/emulators.log')
        time.sleep(1)


signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
try:
    main()
except KeyboardInterrupt:
    pass
finally:
    cleanup()
