import assert from 'node:assert/strict';
import {mkdtempSync, readFileSync, rmSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {spawnSync} from 'node:child_process';
import test from 'node:test';
import {stamp} from '../web/stamp_worker_version.mjs';
import {writeBuild} from '../../test/web/fixtures/sw_fixture_build.mjs';
import {stampProblems} from './check_worker_stamp.mjs';

const script = new URL('./check_worker_stamp.mjs', import.meta.url).pathname;
function stamped() {
  const dir = mkdtempSync(join(tmpdir(), 'stamp-check-'));
  writeBuild(dir, 'A');
  return dir;
}
const edit = (dir, name, change) => writeFileSync(join(dir, name), change(readFileSync(join(dir, name), 'utf8')));

test('a stamped build passes', () => {
  const dir = stamped();
  assert.deepEqual(stampProblems(dir), []);
  const run = spawnSync('node', [script, dir]);
  assert.equal(run.status, 0, run.stderr.toString());
  rmSync(dir, {recursive: true});
});

test('an unstamped worker is refused', () => {
  const dir = stamped();
  writeFileSync(join(dir, 'pantas_sw.js'), readFileSync(new URL('../../web/pantas_sw.js', import.meta.url), 'utf8'));
  assert.match(stampProblems(dir)[0], /unstamped/);
  const run = spawnSync('node', [script, dir]);
  assert.equal(run.status, 1);
  assert.match(run.stderr.toString(), /Refusing/);
  rmSync(dir, {recursive: true});
});

test('a startup file changed after the stamp is refused', () => {
  const dir = stamped();
  edit(dir, 'main.dart.js', text => text + '// edited');
  assert.deepEqual(stampProblems(dir), ['main.dart.js changed after the stamp']);
  rmSync(dir, {recursive: true});
});

test('a file added or removed after the stamp is refused', () => {
  const dir = stamped();
  writeFileSync(join(dir, 'pantas_extra.js'), 'x');
  assert.match(stampProblems(dir).join(), /pantas_extra\.js is in the build but not in the worker/);
  rmSync(join(dir, 'pantas_extra.js'));
  rmSync(join(dir, 'drift_worker.js'));
  assert.match(stampProblems(dir).join(), /drift_worker\.js is in the worker's list but not in the build/);
  rmSync(dir, {recursive: true});
});

test('a bootstrap or version.json from another build is refused', () => {
  const dir = stamped();
  edit(dir, 'version.json', text => text.replace(/"pantasBuildVersion":"[^"]+"/, '"pantasBuildVersion":"other"'));
  assert.match(stampProblems(dir).join(), /version\.json names another build/);
  rmSync(dir, {recursive: true});
});

test('restamping a changed build makes it pass again', () => {
  const dir = stamped();
  edit(dir, 'main.dart.js', text => text + '// edited');
  stamp(dir);
  assert.deepEqual(stampProblems(dir), []);
  rmSync(dir, {recursive: true});
});

test('the Cloudflare deploy script refuses an unstamped build before it uploads anything', () => {
  const dir = stamped();
  writeFileSync(join(dir, 'pantas_sw.js'), readFileSync(new URL('../../web/pantas_sw.js', import.meta.url), 'utf8'));
  const deploy = new URL('../cloudflare-app/deploy.sh', import.meta.url).pathname;
  for (const env of ['staging', 'prod']) {
    const run = spawnSync('bash', [deploy, env, dir], {encoding: 'utf8'});
    assert.equal(run.status, 1, run.stdout + run.stderr);
    assert.match(run.stderr, /Refusing .*unstamped/s);
  }
  rmSync(dir, {recursive: true});
});
