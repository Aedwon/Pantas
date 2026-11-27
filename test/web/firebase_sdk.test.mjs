// E-210, cold offline start: the Firebase JavaScript SDK comes from our own address. These
// checks tie the files in web/firebase_sdk, the page's import map and the SDK version that
// FlutterFire pins to one another, so none of them can drift alone. The real browser proof
// is pantas_real_build_boot.browser.mjs.
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {existsSync, readdirSync, readFileSync} from 'node:fs';
import {join} from 'node:path';
import test from 'node:test';
import {
  LOCKED_FIREBASE_CORE_WEB, SDK_FILES, SDK_FOLDER, SDK_ORIGIN, SDK_VERSION, importMap, sha256,
} from '../../tool/web/firebase_sdk.mjs';

const repo = new URL('../../', import.meta.url).pathname;
const page = readFileSync(join(repo, 'web/index.html'), 'utf8');

test('every SDK file is in web/firebase_sdk, with the bytes Google serves', () => {
  for (const [name, hash] of Object.entries(SDK_FILES)) {
    const path = join(repo, 'web', SDK_FOLDER, name);
    assert.ok(existsSync(path), `${path} is missing: run node tool/web/firebase_sdk.mjs`);
    assert.equal(sha256(readFileSync(path)), hash, name);
  }
});

test('no SDK file imports from anywhere but our own list of files', () => {
  for (const name of Object.keys(SDK_FILES)) {
    const text = readFileSync(join(repo, 'web', SDK_FOLDER, name), 'utf8');
    for (const [, address] of text.matchAll(/\bfrom\s*"(https?:[^"]+)"|\bimport\s*\(\s*"(https?:[^"]+)"/g)) {
      if (!address) continue;
      assert.ok(address.startsWith(SDK_ORIGIN) && address.slice(SDK_ORIGIN.length) in SDK_FILES, `${name} imports ${address}`);
    }
  }
});

test('the page carries the import map, ahead of every other script', () => {
  const first = page.indexOf('<script');
  const found = /<script type="importmap">\s*([\s\S]*?)\s*<\/script>/.exec(page);
  assert.ok(found, 'index.html has an import map');
  assert.equal(found.index, first, 'the import map is the first script (a map after a module request is ignored)');
  assert.deepEqual(JSON.parse(found[1]), importMap());
});

// The import map is an inline script, so the report-only security policy lists its hash.
// Without it every page load would file a violation report for it.
test('both security policies list the import map\'s hash, and the SDK folder is cached for good', () => {
  const found = /<script type="importmap">([\s\S]*?)<\/script>/.exec(page);
  const hash = `'sha256-${createHash('sha256').update(found[1]).digest('base64')}'`;
  for (const env of ['prod', 'staging']) {
    const headers = readFileSync(join(repo, `tool/cloudflare-app/headers.${env}`), 'utf8');
    const policy = /Content-Security-Policy-Report-Only: (.*)/.exec(headers)[1];
    assert.ok(/script-src ([^;]*)/.exec(policy)[1].split(' ').includes(hash), `${env}: script-src lacks ${hash}`);
    assert.match(headers, /\/firebase_sdk\/\*\n  Cache-Control: public, max-age=31536000, immutable/, `${env}: SDK folder cache rule`);
  }
});

test('the version is the one FlutterFire pins for the locked firebase_core_web', t => {
  const lock = readFileSync(join(repo, 'pubspec.lock'), 'utf8');
  const locked = /^  firebase_core_web:\n(?:    .*\n)*?    version: "([^"]+)"/m.exec(lock)[1];
  assert.equal(locked, LOCKED_FIREBASE_CORE_WEB,
    `firebase_core_web is now ${locked}: take its SDK version (lib/src/firebase_sdk_version.dart), run node tool/web/firebase_sdk.mjs, ` +
    'and update tool/web/firebase_sdk.mjs, so a new version is a new address');
  const cache = process.env.PUB_CACHE ?? join(process.env.HOME ?? '', '.pub-cache');
  const file = join(cache, 'hosted/pub.dev', `firebase_core_web-${locked}`, 'lib/src/firebase_sdk_version.dart');
  if (!existsSync(file)) return t.skip(`firebase_core_web ${locked} is not in the pub cache`);
  const pinned = /supportedFirebaseJsSdkVersion\s*=\s*'([^']+)'/.exec(readFileSync(file, 'utf8'))[1];
  assert.equal(SDK_VERSION, pinned, 'FlutterFire loads another version than the one served here, so it would go to Google again');
});

test('every service FlutterFire loads has its file', t => {
  const cache = process.env.PUB_CACHE ?? join(process.env.HOME ?? '', '.pub-cache');
  const core = join(cache, 'hosted/pub.dev', `firebase_core_web-${LOCKED_FIREBASE_CORE_WEB}`, 'lib/src/firebase_core_web.dart');
  if (!existsSync(core)) return t.skip('firebase_core_web is not in the pub cache');
  const lock = readFileSync(join(repo, 'pubspec.lock'), 'utf8');
  // Every Firebase web plugin in the lock registers the services it needs: registerService('<name>').
  const services = new Set(['core']);
  const plugins = [...lock.matchAll(/^  ((?:firebase|cloud)_\w+_web):\n(?:    .*\n)*?    version: "([^"]+)"/gm)]
    .filter(([, name]) => name !== 'firebase_core_web');
  assert.ok(plugins.length >= 8, `found only ${plugins.length} Firebase web plugins in pubspec.lock`);
  for (const [, plugin, version] of plugins) {
    const folder = join(cache, 'hosted/pub.dev', `${plugin}-${version}`, 'lib');
    if (!existsSync(folder)) return t.skip(`${plugin} ${version} is not in the pub cache`);
    for (const file of readdirSync(folder, {recursive: true}).filter(name => name.endsWith('.dart'))) {
      for (const [, name] of readFileSync(join(folder, file), 'utf8').matchAll(/registerService\(\s*'([\w-]+)'/g)) services.add(name);
    }
  }
  // The core is firebase-app.js and firestore loads as its pipelines bundle (firebase_core_web 3.10.0).
  const files = [...services].map(name => (name === 'core' ? 'firebase-app.js' : name === 'firestore' ? 'firebase-firestore-pipelines.js' : `firebase-${name}.js`));
  assert.deepEqual(files.sort(), Object.keys(SDK_FILES).sort());
});
