// compare.mjs checks the Worker against the local build folder and never fetches from Firebase
// (Fable 5.2 rule 7 ruling 2: tooling that downloaded the app from Firebase billed Hosting egress).
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {mkdtempSync, mkdirSync, readFileSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import test from 'node:test';
import {fileURLToPath} from 'node:url';
import {compare, parseHeaders} from './compare.mjs';

const HEADERS = `# test rules
/*
  Strict-Transport-Security: max-age=31556926
/assets/*
  Cache-Control: max-age=3600
/sqlite3.wasm
  Cache-Control: max-age=3600
`;
const KEY = 'test-key';
const FILES = {
  'index.html': '<html>app</html>',
  'main.dart.js': 'console.log(1)',
  'sqlite3.wasm': 'wasm-bytes',
  'assets/data.json': '{"a":1}',
  'assets/NOTICES': 'licenses',
};
const TYPES = {html: 'text/html', js: 'text/javascript', wasm: 'application/wasm', json: 'application/json'};

function setup() {
  const dir = mkdtempSync(join(tmpdir(), 'compare-'));
  for (const [name, body] of Object.entries(FILES)) {
    mkdirSync(join(dir, name, '..'), {recursive: true});
    writeFileSync(join(dir, name), body);
  }
  const headersFile = join(mkdtempSync(join(tmpdir(), 'compare-rules-')), '_headers');
  writeFileSync(headersFile, HEADERS);
  return {dir, headersFile};
}

/** A stand-in Worker: serves FILES the way Cloudflare does, with tweaks per test. Records every URL. */
function workerFetch(urls, tweak = () => ({})) {
  return async (url, init = {}) => {
    urls.push(String(url));
    const {pathname} = new URL(url);
    const path = pathname === '/' ? '/index.html' : pathname;
    const override = tweak(pathname, init) ?? {};
    if (pathname.startsWith('/__/')) {
      if (override.status) return new Response('', {status: override.status});
      if (pathname === '/__/firebase/init.json') return new Response(JSON.stringify({apiKey: KEY}), {headers: {'content-type': 'application/json'}});
      if (init.method === 'POST') return new Response('', {status: 200});
      return new Response('ok', {headers: {'content-type': pathname.endsWith('.js') ? 'text/javascript' : 'text/html'}});
    }
    let name = path.slice(1);
    if (!(name in FILES)) name = 'index.html'; // app route: single-page fallback
    const ext = name.split('.').pop();
    const age = override.age ?? (/^assets\/|^sqlite3\.wasm$/.test(name) ? 3600 : 0);
    const headers = {
      'content-type': override.type ?? TYPES[ext] ?? '',
      'cache-control': age ? `max-age=${age}` : 'public, max-age=0, must-revalidate',
      'strict-transport-security': override.hsts ?? 'max-age=31556926',
    };
    return new Response(override.body ?? FILES[name], {status: override.status ?? 200, headers});
  };
}

const run = async (tweak) => {
  const {dir, headersFile} = setup();
  const urls = [];
  const logs = [];
  const result = await compare({worker: 'https://worker.test', buildDir: dir, apiKey: KEY, headersFile, fetchFn: workerFetch(urls, tweak), log: (l) => logs.push(l)});
  return {...result, urls, logs};
};

test('a Worker that serves the build exactly matches', async () => {
  const result = await run();
  assert.deepEqual(result.mismatches, []);
  assert.ok(result.total >= Object.keys(FILES).length + 8, `checked ${result.total} paths`);
});

test('it fetches only the Worker, never a Firebase address', async () => {
  const {urls} = await run();
  assert.ok(urls.length > 5);
  for (const url of urls) assert.equal(new URL(url).origin, 'https://worker.test', url);
  const source = readFileSync(fileURLToPath(new URL('./compare.mjs', import.meta.url)), 'utf8');
  assert.doesNotMatch(source, /https?:\/\/[^\s'"`]*(web\.app|firebaseapp\.com)/);
});

test('a body that differs from the local file is a mismatch', async () => {
  const {mismatches} = await run((path) => (path === '/main.dart.js' ? {body: 'console.log(2)'} : {}));
  assert.equal(mismatches.length, 1);
  assert.match(mismatches[0], /main\.dart\.js.*body differs/);
});

test('a missing file, a wrong type and a wrong cache lifetime are mismatches', async () => {
  const missing = await run((path) => (path === '/assets/data.json' ? {status: 404} : {}));
  assert.match(missing.mismatches.join('\n'), /assets\/data\.json.*status 404/);
  const type = await run((path) => (path === '/main.dart.js' ? {type: 'text/html'} : {}));
  assert.match(type.mismatches.join('\n'), /main\.dart\.js.*type text\/html/);
  const age = await run((path) => (path === '/sqlite3.wasm' ? {age: 0} : {}));
  assert.match(age.mismatches.join('\n'), /sqlite3\.wasm.*max-age 0, expected 3600/);
});

test('a header the rules file sets on every path is checked', async () => {
  const {mismatches} = await run((path) => (path === '/index.html' ? {hsts: 'max-age=1'} : {}));
  assert.match(mismatches.join('\n'), /index\.html.*strict-transport-security/);
});

test('an app route must return the local index.html', async () => {
  const {mismatches} = await run((path) => (path === '/quiz/some-id' ? {body: 'not the app'} : {}));
  assert.match(mismatches.join('\n'), /quiz\/some-id.*body differs/);
});

test('the sign-in paths are checked through the Worker', async () => {
  const {urls, mismatches} = await run();
  assert.deepEqual(mismatches, []);
  assert.ok(urls.some((u) => u.includes('/__/auth/handler?')));
  assert.ok(urls.some((u) => u.endsWith('/__/firebase/init.json')));
  const down = await run((path) => (path === '/__/auth/handler.js' ? {status: 502} : {}));
  assert.match(down.mismatches.join('\n'), /__\/auth\/handler\.js: status 502/);
});

test('the headers file is parsed into rules per path', () => {
  const rules = parseHeaders(HEADERS);
  assert.equal(rules.expected('/assets/x/y.png')['cache-control'], 'max-age=3600');
  assert.equal(rules.expected('/sqlite3.wasm')['cache-control'], 'max-age=3600');
  assert.equal(rules.expected('/main.dart.js')['cache-control'], undefined);
  assert.equal(rules.expected('/main.dart.js')['strict-transport-security'], 'max-age=31556926');
});
