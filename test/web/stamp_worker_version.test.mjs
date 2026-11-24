import assert from 'node:assert/strict';
import {existsSync, mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import test from 'node:test';
import {stamp} from '../../tool/web/stamp_worker_version.mjs';

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

// The sizes the loading percent divides by are written into the worker script
// (UX lead, Nov 25, board A). There is no list file.
const WORKER = [
  "'use strict';",
  'const VERSION = 1;',
  'const LOAD_SIZES = null; // stamped by tool/web/stamp_worker_version.mjs',
  'self.x = 1;',
].join('\n');

function bigBuild({local = false, worker = WORKER} = {}) {
  const dir = build('main code');
  writeFileSync(join(dir, 'pantas_sw.js'), worker);
  writeFileSync(join(dir, 'flutter_bootstrap.js'),
    'await pwa.registerWorker("213919009" /* note */);\n' +
    `_flutter.buildConfig = {"engineRevision":"abc","builds":[{"compileTarget":"dart2js","renderer":"canvaskit","mainJsPath":"main.dart.js"}]${local ? ',"useLocalCanvasKit":true' : ''}};`);
  mkdirSync(join(dir, 'canvaskit', 'chromium'), {recursive: true});
  writeFileSync(join(dir, 'canvaskit', 'canvaskit.js'), 'full js');
  writeFileSync(join(dir, 'canvaskit', 'canvaskit.wasm'), 'full wasm bytes');
  writeFileSync(join(dir, 'canvaskit', 'chromium', 'canvaskit.js'), 'chromium js');
  writeFileSync(join(dir, 'canvaskit', 'chromium', 'canvaskit.wasm'), 'chromium wasm');
  return dir;
}

function sizes(dir) {
  const line = readFileSync(join(dir, 'pantas_sw.js'), 'utf8').split('\n').find(l => l.startsWith('const LOAD_SIZES = '));
  return JSON.parse(line.slice('const LOAD_SIZES = '.length, line.indexOf(';')));
}

test('every build lists main.dart.js alone, so a number can never stall below 100%', () => {
  for (const local of [false, true]) {
    const dir = bigBuild({local});
    stamp(dir);
    assert.deepEqual(sizes(dir), {'main.dart.js': 'main code'.length}, local ? 'local CanvasKit' : 'CDN CanvasKit');
  }
});

test('the stamp step does not read the build config for CanvasKit', () => {
  const dir = bigBuild({local: true});
  writeFileSync(join(dir, 'flutter_bootstrap.js'), 'await pwa.registerWorker("1");\nnothing here');
  stamp(dir);
  assert.deepEqual(Object.keys(sizes(dir)), ['main.dart.js']);
});

test('no list file is written and the worker script keeps its other lines', () => {
  const dir = bigBuild();
  stamp(dir);
  assert.equal(existsSync(join(dir, 'pantas_load_sizes.json')), false);
  const lines = readFileSync(join(dir, 'pantas_sw.js'), 'utf8').split('\n');
  assert.deepEqual([lines[0], lines[1], lines[3]], ["'use strict';", 'const VERSION = 1;', 'self.x = 1;']);
});

test('the sizes are not part of the build hash and stamping twice is stable', () => {
  const dir = bigBuild();
  const first = stamp(dir);
  const text = readFileSync(join(dir, 'pantas_sw.js'), 'utf8');
  assert.equal(stamp(dir), first);
  assert.equal(readFileSync(join(dir, 'pantas_sw.js'), 'utf8'), text);
  assert.equal(stamp(bigBuild()), first);
  assert.notEqual(stamp(bigBuild({worker: WORKER + '\nself.y = 2;'})), first, 'worker code is still part of the hash');
});

test('a build with no main script leaves the worker unstamped', () => {
  const dir = bigBuild();
  rmSync(join(dir, 'main.dart.js'));
  stamp(dir);
  assert.match(readFileSync(join(dir, 'pantas_sw.js'), 'utf8'), /^const LOAD_SIZES = null;/m);
});

test('a build with no worker script still stamps', () => {
  const dir = build('code');
  assert.match(stamp(dir), /^213919009-/);
});
