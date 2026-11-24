import assert from 'node:assert/strict';
import {existsSync, mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import test from 'node:test';
import {stamp, LOAD_SIZES} from '../../tool/web/stamp_worker_version.mjs';

function build(mainJs) {
  const dir = mkdtempSync(join(tmpdir(), 'stamp-'));
  mkdirSync(join(dir, 'icons'));
  writeFileSync(join(dir, 'main.dart.js'), mainJs);
  writeFileSync(join(dir, 'icons', 'Icon-192.png'), 'png');
  writeFileSync(join(dir, 'flutter_bootstrap.js'),
    'await pwa.registerWorker("213919009" /* note */);');
  return dir;
}

test('a Dart-only change gives the worker a new version', () => {
  const a = stamp(build('old code'));
  const b = stamp(build('new code'));
  assert.match(a, /^213919009-[0-9a-f]{12}$/);
  assert.notEqual(a, b);
});

test('the same build always gets the same version, and stamping twice is stable', () => {
  const dir = build('same code');
  const first = stamp(dir);
  assert.equal(stamp(dir), first);
  assert.equal(stamp(build('same code')), first);
  assert.match(readFileSync(join(dir, 'flutter_bootstrap.js'), 'utf8'), new RegExp(`registerWorker\\("${first}"`));
});

test('a bootstrap without the version token is refused', () => {
  const dir = build('code');
  writeFileSync(join(dir, 'flutter_bootstrap.js'), 'nothing here');
  assert.throws(() => stamp(dir), /No registerWorker/);
});

test('version metadata adds only the comparable stamped build identity', () => {
  const dir = build('code');
  writeFileSync(join(dir, 'version.json'), '{"version":"1.0.0","build_number":"4"}');
  const first = stamp(dir);
  assert.deepEqual(JSON.parse(readFileSync(join(dir, 'version.json'), 'utf8')), {
    version: '1.0.0', build_number: '4', pantasBuildVersion: first,
  });
  assert.equal(stamp(dir), first);
});

// The size list the loading percent divides by (UX lead, Nov 25, board A).
function bigBuild() {
  const dir = build('main code');
  mkdirSync(join(dir, 'canvaskit', 'chromium'), {recursive: true});
  writeFileSync(join(dir, 'canvaskit', 'canvaskit.js'), 'full js');
  writeFileSync(join(dir, 'canvaskit', 'canvaskit.wasm'), 'full wasm bytes');
  writeFileSync(join(dir, 'canvaskit', 'chromium', 'canvaskit.js'), 'chromium js');
  writeFileSync(join(dir, 'canvaskit', 'chromium', 'canvaskit.wasm'), 'chromium wasm');
  return dir;
}

test('stamping writes the decoded size of each file the loader fetches', () => {
  const dir = bigBuild();
  stamp(dir);
  const list = JSON.parse(readFileSync(join(dir, LOAD_SIZES), 'utf8'));
  assert.equal(list.v, 1);
  assert.deepEqual(list.files, {
    'main.dart.js': 'main code'.length,
    'canvaskit/canvaskit.js': 'full js'.length,
    'canvaskit/canvaskit.wasm': 'full wasm bytes'.length,
    'canvaskit/chromium/canvaskit.js': 'chromium js'.length,
    'canvaskit/chromium/canvaskit.wasm': 'chromium wasm'.length,
  });
});

test('the list names the build it belongs to, so a worker can refuse another build\'s list', () => {
  const dir = bigBuild();
  const version = stamp(dir);
  const list = JSON.parse(readFileSync(join(dir, LOAD_SIZES), 'utf8'));
  assert.equal(list.version, version);
  assert.equal(list.alternatives, undefined);
});

test('the list is not part of the build hash and stamping twice is stable', () => {
  const dir = bigBuild();
  const first = stamp(dir);
  const text = readFileSync(join(dir, LOAD_SIZES), 'utf8');
  assert.equal(stamp(dir), first);
  assert.equal(readFileSync(join(dir, LOAD_SIZES), 'utf8'), text);
  assert.equal(stamp(bigBuild()), first);
  const bare = bigBuild();
  assert.equal(stamp(bare), first);
});

test('a build with no main script gets no list, so the page shows the spinner only', () => {
  const dir = build('code');
  rmSync(join(dir, 'main.dart.js'));
  stamp(dir);
  assert.equal(existsSync(join(dir, LOAD_SIZES)), false);
});

test('only files that exist are listed', () => {
  const dir = build('code');
  stamp(dir);
  const list = JSON.parse(readFileSync(join(dir, LOAD_SIZES), 'utf8'));
  assert.deepEqual(Object.keys(list.files), ['main.dart.js']);
});
