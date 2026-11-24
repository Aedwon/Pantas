// staging_disable_ttl.sh turns off every Firestore TTL policy of pantas-staging (TTL deletes have no
// free tier; security and billing lead ruling, Nov 24, 2026). The test runs it against a fake gcloud
// and never touches a real project.
import assert from 'node:assert/strict';
import {execFileSync, spawnSync} from 'node:child_process';
import {chmodSync, mkdtempSync, readFileSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import test from 'node:test';
import {fileURLToPath} from 'node:url';

const script = fileURLToPath(new URL('./staging_disable_ttl.sh', import.meta.url));

function fakeGcloud(listing = 'sessions\\texpiresAt\\nusers\\tpurgeAt\\n', failOn = '') {
  const dir = mkdtempSync(join(tmpdir(), 'fake-gcloud-'));
  const log = join(dir, 'calls.log');
  writeFileSync(join(dir, 'gcloud'), `#!/bin/bash
echo "$*" >> "${log}"
if [[ "$*" == *"ttls list"* ]]; then printf '${listing}'; exit 0; fi
if [[ -n "${failOn}" && "$*" == *"${failOn}"* ]]; then echo "FAILED" >&2; exit 1; fi
`);
  chmodSync(join(dir, 'gcloud'), 0o755);
  return {dir, calls: () => { try { return readFileSync(log, 'utf8').trim().split('\n'); } catch { return []; } }};
}

const run = (args = [], fake = fakeGcloud()) => {
  const result = spawnSync('bash', [script, ...args], {env: {PATH: `${fake.dir}:${process.env.PATH}`, HOME: process.env.HOME}, encoding: 'utf8'});
  return {result, calls: fake.calls()};
};

test('it lists staging TTL policies and disables each one, asynchronously, in staging only', () => {
  const {result, calls} = run();
  assert.equal(result.status, 0, result.stderr);
  assert.match(calls[0], /firestore fields ttls list .*--project=pantas-staging/);
  const updates = calls.filter((c) => c.includes('ttls update'));
  assert.equal(updates.length, 2);
  assert.match(updates[0], /ttls update expiresAt --collection-group=sessions --disable-ttl --project pantas-staging/);
  for (const call of updates) {
    assert.match(call, /--disable-ttl/);
    assert.match(call, /--async/);
    assert.match(call, /--quiet/);
    assert.match(call, /pantas-staging/);
  }
  assert.ok(calls.every((c) => !c.includes('pantas-prod')));
});

test('a dry run lists but changes nothing', () => {
  const {result, calls} = run(['--dry-run']);
  assert.equal(result.status, 0, result.stderr);
  assert.equal(calls.filter((c) => c.includes('update')).length, 0);
  assert.match(result.stdout, /would disable sessions\.expiresAt/);
});

test('with no TTL policy it does nothing and succeeds', () => {
  const {result, calls} = run([], fakeGcloud(''));
  assert.equal(result.status, 0, result.stderr);
  assert.equal(calls.filter((c) => c.includes('update')).length, 0);
  assert.match(result.stdout, /0 TTL policy/);
});

test('it refuses a project argument, so it cannot be pointed at prod', () => {
  const {result, calls} = run(['pantas-prod']);
  assert.notEqual(result.status, 0);
  assert.deepEqual(calls, []);
  const extra = run(['--dry-run', 'pantas-prod']);
  assert.notEqual(extra.result.status, 0);
  assert.deepEqual(extra.calls, []);
});

test('the script names no prod project and is valid bash', () => {
  assert.doesNotMatch(readFileSync(script, 'utf8'), /pantas-prod/);
  assert.equal(execFileSync('bash', ['-n', script]).toString(), '');
});

test('one failed update does not stop the others, and the run then exits 1', () => {
  const {result, calls} = run([], fakeGcloud('a\\tx\\nb\\ty\\nc\\tz\\n', 'update y'));
  assert.equal(result.status, 1);
  assert.equal(calls.filter((c) => c.includes('ttls update')).length, 3);
  assert.match(result.stdout + result.stderr, /1 failed/);
});
