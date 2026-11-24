import assert from 'node:assert/strict';
import {mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync} from 'node:fs';
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

// The size the loading percent divides by goes into flutter_bootstrap.js, which
// is rewritten for every build anyway. The worker script must not change with
// the build (UX lead, Nov 25, round 4).
const WORKER = ["'use strict';", 'const VERSION = 1;', 'self.x = 1;'].join('\n');

function bigBuild({main = 'main code', worker = WORKER} = {}) {
  const dir = build(main);
  writeFileSync(join(dir, 'pantas_sw.js'), worker);
  return dir;
}

const total = dir => {
  const match = readFileSync(join(dir, 'flutter_bootstrap.js'), 'utf8').match(/^window\.pantasLoadTotal = (\d+);/m);
  return match ? Number(match[1]) : null;
};

test('the worker script is byte-identical across stamps with different sizes', () => {
  const a = bigBuild({main: 'short'});
  const b = bigBuild({main: 'a much longer main script'});
  stamp(a);
  stamp(b);
  assert.equal(readFileSync(join(a, 'pantas_sw.js'), 'utf8'), WORKER);
  assert.equal(readFileSync(join(b, 'pantas_sw.js'), 'utf8'), WORKER);
});

test('the main script size is written into the bootstrap', () => {
  const dir = bigBuild({main: 'twelve bytes'});
  stamp(dir);
  assert.equal(total(dir), 12);
});

test('stamping twice keeps one total line and the same version', () => {
  const dir = bigBuild();
  const first = stamp(dir);
  const text = readFileSync(join(dir, 'flutter_bootstrap.js'), 'utf8');
  assert.equal(stamp(dir), first);
  assert.equal(readFileSync(join(dir, 'flutter_bootstrap.js'), 'utf8'), text);
  assert.equal((text.match(/pantasLoadTotal/g) || []).length, 1);
});

test('a build with no main script gets no total, so the page shows the spinner only', () => {
  const dir = bigBuild();
  rmSync(join(dir, 'main.dart.js'));
  stamp(dir);
  assert.equal(total(dir), null);
  assert.ok(!/pantasLoadTotal/.test(readFileSync(join(dir, 'flutter_bootstrap.js'), 'utf8')));
});

test('a stale total is removed when the main script is gone', () => {
  const dir = bigBuild();
  stamp(dir);
  rmSync(join(dir, 'main.dart.js'));
  stamp(dir);
  assert.equal(total(dir), null);
});

test('the bootstrap keeps its worker version token and its other lines', () => {
  const dir = bigBuild();
  const version = stamp(dir);
  const text = readFileSync(join(dir, 'flutter_bootstrap.js'), 'utf8');
  assert.match(text, new RegExp(`registerWorker\\("${version}"`));
});
