// staging_delete_images.sh deletes the container images of staging's functions after a staging
// functions deploy (Fable 5.2 rule 7 ruling 4: Artifact Registry's free tier is 0.5 GB and a deploy
// leaves hundreds of MiB). The test runs it against a fake gcloud and never touches a real project.
import assert from 'node:assert/strict';
import {execFileSync, spawnSync} from 'node:child_process';
import {chmodSync, mkdtempSync, readFileSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import test from 'node:test';
import {fileURLToPath} from 'node:url';

const script = fileURLToPath(new URL('./staging_delete_images.sh', import.meta.url));

function fakeGcloud() {
  const dir = mkdtempSync(join(tmpdir(), 'fake-gcloud-'));
  const log = join(dir, 'calls.log');
  writeFileSync(join(dir, 'gcloud'), `#!/bin/bash
echo "$*" >> "${log}"
if [[ "$*" == *"packages list"* ]]; then printf 'pkg-one\\npkg-two__asia-southeast1\\n'; fi
`);
  chmodSync(join(dir, 'gcloud'), 0o755);
  return {dir, calls: () => { try { return readFileSync(log, 'utf8').trim().split('\n'); } catch { return []; } }};
}

const run = (args = [], env = {}) => {
  const fake = fakeGcloud();
  const result = spawnSync('bash', [script, ...args], {env: {PATH: `${fake.dir}:${process.env.PATH}`, HOME: process.env.HOME, ...env}, encoding: 'utf8'});
  return {result, calls: fake.calls()};
};

test('it deletes every package in staging gcf-artifacts and nothing else', () => {
  const {result, calls} = run();
  assert.equal(result.status, 0, result.stderr);
  assert.match(calls[0], /artifacts packages list .*--repository=gcf-artifacts .*--location=asia-southeast1 .*--project=pantas-staging/);
  const deletes = calls.filter((c) => c.includes('packages delete'));
  assert.equal(deletes.length, 2);
  for (const call of deletes) {
    assert.match(call, /--repository=gcf-artifacts/);
    assert.match(call, /--location=asia-southeast1/);
    assert.match(call, /--project=pantas-staging/);
    assert.match(call, /--quiet/);
  }
  assert.match(deletes[0], /packages delete pkg-one /);
  assert.ok(calls.every((c) => !c.includes('pantas-prod')));
});

test('a dry run lists but deletes nothing', () => {
  const {result, calls} = run(['--dry-run']);
  assert.equal(result.status, 0, result.stderr);
  assert.equal(calls.filter((c) => c.includes('delete')).length, 0);
  assert.match(result.stdout, /pkg-one/);
});

test('it refuses a project argument, so it cannot be pointed at prod', () => {
  const {result, calls} = run(['pantas-prod']);
  assert.notEqual(result.status, 0);
  assert.deepEqual(calls, []);
});

test('it is not executed by a deploy of prod: the script names no prod project', () => {
  const text = readFileSync(script, 'utf8');
  assert.doesNotMatch(text, /pantas-prod/);
  assert.equal(execFileSync('bash', ['-n', script]).toString(), '');
});

// Nov 15, 2026: gcloud lists short package ids, some with a /cache suffix
// ("pantas--staging__asia--southeast1__advance_roadmap/cache"). Keeping only the text after the last
// slash turned every cache package into "cache", the delete failed with NOT_FOUND and set -e stopped
// the run after one package.
function fakeGcloudWith(listing, failOn = '') {
  const dir = mkdtempSync(join(tmpdir(), 'fake-gcloud-'));
  const log = join(dir, 'calls.log');
  writeFileSync(join(dir, 'gcloud'), `#!/bin/bash
echo "$*" >> "${log}"
if [[ "$*" == *"packages list"* ]]; then printf '${listing}'; exit 0; fi
if [[ -n "${failOn}" && "$*" == *"${failOn}"* ]]; then echo "NOT_FOUND" >&2; exit 1; fi
`);
  chmodSync(join(dir, 'gcloud'), 0o755);
  return {dir, calls: () => readFileSync(log, 'utf8').trim().split('\n')};
}

test('cache packages keep their full id, and full resource paths lose only the prefix', () => {
  const fake = fakeGcloudWith('pantas--staging__asia--southeast1__advance_roadmap\\npantas--staging__asia--southeast1__advance_roadmap/cache\\nprojects/pantas-staging/locations/asia-southeast1/repositories/gcf-artifacts/packages/x__y/cache\\n');
  const result = spawnSync('bash', [script], {env: {PATH: `${fake.dir}:${process.env.PATH}`, HOME: process.env.HOME}, encoding: 'utf8'});
  assert.equal(result.status, 0, result.stderr);
  const ids = fake.calls().filter((c) => c.includes('packages delete')).map((c) => c.split(' ')[3]);
  assert.deepEqual(ids, ['pantas--staging__asia--southeast1__advance_roadmap', 'pantas--staging__asia--southeast1__advance_roadmap/cache', 'x__y/cache']);
});

test('one failed delete does not stop the others, and the run then exits 1', () => {
  const fake = fakeGcloudWith('a\\nb/cache\\nc\\n', 'delete b/cache');
  const result = spawnSync('bash', [script], {env: {PATH: `${fake.dir}:${process.env.PATH}`, HOME: process.env.HOME}, encoding: 'utf8'});
  assert.equal(result.status, 1);
  assert.equal(fake.calls().filter((c) => c.includes('packages delete')).length, 3);
  assert.match(result.stdout + result.stderr, /1 failed/);
});
