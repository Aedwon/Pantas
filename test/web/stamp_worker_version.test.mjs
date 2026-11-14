import assert from 'node:assert/strict';
import {mkdtempSync, mkdirSync, readFileSync, writeFileSync} from 'node:fs';
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
  assert.match(readFileSync(join(dir, 'b', first, 'flutter_bootstrap.js'), 'utf8'), new RegExp(`registerWorker\\("${first}"`));
});

test('a bootstrap without the version token is refused', () => {
  const dir = build('code');
  writeFileSync(join(dir, 'flutter_bootstrap.js'), 'nothing here');
  assert.throws(() => stamp(dir), /No registerWorker/);
});
