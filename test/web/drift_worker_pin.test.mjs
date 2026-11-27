// Run with: node --test test/web/drift_worker_pin.test.mjs
//
// Fix list item 1 (service worker option A, Nov 26): drift_worker.js keeps its root
// address and its bytes, so the worker that shipped before build folders (which caches
// it under that address) serves an identical copy to a page of the new build.
// A browser keys a shared worker by address and name, so one address means one worker.
//
// Before any Drift upgrade: a Drift upgrade can change what the database worker and the
// page say to each other. A tab on the old build and a tab on the new one would then
// share one database through two protocols. Add a lock that refuses to open the
// database while a worker of another version holds it, then change the pin below.
// This test is the reminder: it fails on a Drift or worker change until that is done.
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFileSync} from 'node:fs';
import test from 'node:test';
import {PINNED_ROOT_FILES} from '../../tool/deploy/check_worker_stamp.mjs';

const repo = new URL('../../', import.meta.url);
const sha = bytes => createHash('sha256').update(bytes).digest('hex');

// The first web commit (5cd9f119c) shipped these bytes; prod serves them today.
const FIRST_COMMIT_DRIFT_WORKER = '88a90a723fd84013c92fe5106fd0b4d324279224195f94ea33bcae94477ef2a0';
const LOCKED_DRIFT = '2.34.3';

test('web/drift_worker.js is byte for byte the file prod serves today', () => {
  assert.equal(sha(readFileSync(new URL('web/drift_worker.js', repo))), FIRST_COMMIT_DRIFT_WORKER,
    'drift_worker.js changed: add the database lock (see this file) before shipping a new worker file');
  assert.equal(PINNED_ROOT_FILES['drift_worker.js'], FIRST_COMMIT_DRIFT_WORKER, 'the deploy guard pins the same bytes');
});

test('the locked Drift version is the one this pin was made for', () => {
  const lock = readFileSync(new URL('pubspec.lock', repo), 'utf8');
  const version = /^  drift:\n(?:    .*\n)*?    version: "([^"]+)"/m.exec(lock)?.[1];
  assert.equal(version, LOCKED_DRIFT,
    `Drift is now ${version}: add the lock that refuses to open the database while another worker version holds it, then update this pin`);
});
