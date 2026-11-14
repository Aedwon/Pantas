import assert from 'node:assert/strict';
import test, {before} from 'node:test';
import {spawnSync} from 'node:child_process';
import {readFileSync} from 'node:fs';
import {initializeApp} from 'firebase-admin/app';
import {getAuth} from 'firebase-admin/auth';
import {getFirestore, Timestamp} from 'firebase-admin/firestore';
import {getStorage} from 'firebase-admin/storage';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
assert.ok(process.env.FIREBASE_AUTH_EMULATOR_HOST);
assert.ok(process.env.FIREBASE_STORAGE_EMULATOR_HOST);
let endpoints, db;
before(async () => {
  initializeApp({projectId: 'demo-pantas-test', storageBucket: 'demo-pantas-test.appspot.com'});
  endpoints = await import('../lib/index.js');
  db = getFirestore();
});
const app = {appId: 'app', token: {}, alreadyConsumed: false};
const named = uid => ({uid, token: {firebase: {sign_in_provider: 'google.com'}, pro: true, proUntil: Date.now() + 86_400_000, auth_time: 1}});
const seedLimit = (uid, key, count) => db.doc(`users/${uid}/limits/${key}`).set({windowStartedAt: Timestamp.now(), count});
const limitCount = async (uid, key) => (await db.doc(`users/${uid}/limits/${key}`).get()).get('count');
const exhausted = error => error.code === 'resource-exhausted';

// ------------------------------------------------------------------ ruling 3: callable limits

test('getWebEntitlement allows 120 calls an hour per account, then refuses', async () => {
  const uid = 'r1-entitlement';
  await getAuth().createUser({uid});
  await db.recursiveDelete(db.doc(`users/${uid}`));
  await seedLimit(uid, 'getWebEntitlement', 119);
  const reply = await endpoints.getWebEntitlement.run({auth: named(uid), app, data: {uid}});
  assert.ok(Array.isArray(reply.grants));
  assert.equal(await limitCount(uid, 'getWebEntitlement'), 120);
  await assert.rejects(endpoints.getWebEntitlement.run({auth: named(uid), app, data: {uid}}), exhausted);
});

test('activateSyncGeneration allows 30 calls an hour per account, then refuses before any work', async () => {
  const uid = 'r1-sync';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  const request = {auth: named(uid), app, data: {generationId: 'g1', expectedActiveGenerationId: null}};
  await seedLimit(uid, 'activateSyncGeneration', 29);
  await assert.rejects(endpoints.activateSyncGeneration.run(request), error => !exhausted(error), 'the 30th call reaches the handler');
  assert.equal(await limitCount(uid, 'activateSyncGeneration'), 30);
  await assert.rejects(endpoints.activateSyncGeneration.run(request), exhausted);
});

test('recordSetupAcceptance allows 30 calls an hour per account, then refuses', async () => {
  const uid = 'r1-acceptance';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  const request = {auth: named(uid), app, data: {version: '2026-11-09'}};
  await seedLimit(uid, 'recordSetupAcceptance', 29);
  await endpoints.recordSetupAcceptance.run(request);
  await assert.rejects(endpoints.recordSetupAcceptance.run(request), exhausted);
});

test('recordSetupAcceptance writes nothing when the same version is already recorded', async () => {
  const uid = 'r1-acceptance-noop';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  const request = {auth: named(uid), app, data: {version: '2026-11-09'}};
  await endpoints.recordSetupAcceptance.run(request);
  const ref = db.doc(`users/${uid}/server/acceptance`);
  const first = await ref.get();
  await new Promise(resolve => setTimeout(resolve, 20));
  assert.deepEqual(await endpoints.recordSetupAcceptance.run(request), {version: '2026-11-09'});
  const second = await ref.get();
  assert.equal(second.updateTime.toMillis(), first.updateTime.toMillis(), 'no second write');
  assert.equal(second.get('acceptedAt'), first.get('acceptedAt'));
});

// ------------------------------------------------------------------ ruling 6: cleanup cursors

test('both cleanup jobs run up to 540 seconds', () => {
  assert.equal(endpoints.cleanupOrphanAnons.__endpoint.scheduleTrigger && endpoints.cleanupOrphanAnons.__endpoint.timeoutSeconds, 540);
  assert.equal(endpoints.cleanupWrappedOrphans.__endpoint.timeoutSeconds, 540);
});

test('a full cleanup run leaves a finished cursor in jobState', async () => {
  await db.doc('jobState/cleanupOrphanAnons').delete();
  await db.doc('jobState/cleanupWrappedOrphans').delete();
  await endpoints.cleanupOrphanAnons.run({scheduleTime: new Date().toISOString()});
  await endpoints.cleanupWrappedOrphans.run({scheduleTime: new Date().toISOString()});
  for (const job of ['cleanupOrphanAnons', 'cleanupWrappedOrphans']) {
    const state = await db.doc(`jobState/${job}`).get();
    assert.ok(state.exists, `${job} keeps its place`);
    assert.equal(state.get('cursor'), null, `${job} wraps to the start when it reaches the end`);
  }
});

test('cleanupOrphanAnons resumes from its cursor and clears it at the end of the list', async () => {
  const {runOrphanAnonCleanup} = await import('../lib/cleanupOrphanAnons.js');
  const old = new Date(Date.now() - 31 * 86_400_000).toISOString();
  const uids = Array.from({length: 5}, (_, i) => `r1-cursor-anon-${i}`);
  assert.equal((await getAuth().importUsers(uids.map(uid => ({uid, metadata: {creationTime: old, lastSignInTime: old}})))).failureCount, 0);
  await db.doc('jobState/cleanupOrphanAnons').delete();
  const tokens = [];
  const auth = {listUsers: (max, token) => { tokens.push(token); return getAuth().listUsers(max, token); },
    getUser: uid => getAuth().getUser(uid), deleteUser: uid => getAuth().deleteUser(uid)};
  let runs = 0, saved;
  for (; runs < 100; runs += 1) {
    const result = await runOrphanAnonCleanup({auth, db, pageSize: 2, maxPages: 1});
    saved = (await db.doc('jobState/cleanupOrphanAnons').get()).get('cursor');
    if (result.finished) break;
    assert.equal(typeof saved, 'string', 'an unfinished run saves where it stopped');
  }
  assert.ok(runs >= 2, 'five users in pages of two take several runs');
  assert.equal(saved, null);
  assert.equal(tokens[0], undefined);
  assert.ok(tokens.slice(1).every(token => typeof token === 'string'), 'later runs start from the saved cursor');
  for (const uid of uids) await assert.rejects(getAuth().getUser(uid), {code: 'auth/user-not-found'});
});

test('cleanupWrappedOrphans resumes from its cursor and clears it at the end of the list', async () => {
  const {runWrappedCleanup} = await import('../lib/cleanupWrappedOrphans.js');
  const bucket = getStorage().bucket();
  const names = Array.from({length: 5}, (_, i) => `wrapped/r1-cursor-owner/${String(i).repeat(32)}.png`);
  for (const name of names) await bucket.file(name).save(Buffer.from('x'));
  await db.doc('jobState/cleanupWrappedOrphans').delete();
  let runs = 0, saved;
  for (; runs < 200; runs += 1) {
    const result = await runWrappedCleanup({db, bucket, now: () => Date.now() + 2 * 86_400_000, pageSize: 2, maxPages: 1});
    saved = (await db.doc('jobState/cleanupWrappedOrphans').get()).get('cursor');
    if (result.finished) break;
    assert.equal(typeof saved, 'string');
  }
  assert.ok(runs >= 2);
  assert.equal(saved, null);
  for (const name of names) assert.equal((await bucket.file(name).exists())[0], false, name);
});

// ------------------------------------------------------------------ ruling 7: renderWrappedPage invoker

const invokerWith = value => {
  const env = {...process.env};
  delete env.WRAPPED_PAGE_PUBLIC;
  if (value !== undefined) env.WRAPPED_PAGE_PUBLIC = value;
  const run = spawnSync(process.execPath, ['--input-type=module', '-e',
    "const m = await import('./lib/index.js'); console.log(JSON.stringify(m.renderWrappedPage.__endpoint.httpsTrigger.invoker ?? null));"],
  {env, encoding: 'utf8'});
  assert.equal(run.status, 0, run.stderr);
  return JSON.parse(run.stdout.trim().split('\n').pop());
};

test('renderWrappedPage is private unless WRAPPED_PAGE_PUBLIC=true, and only staging sets it', () => {
  assert.deepEqual(invokerWith(undefined), ['private']);
  assert.deepEqual(invokerWith('false'), ['private']);
  assert.deepEqual(invokerWith('true'), ['public']);
  assert.match(readFileSync(new URL('../.env.pantas-staging', import.meta.url), 'utf8'), /^WRAPPED_PAGE_PUBLIC=true$/m);
  assert.doesNotMatch(readFileSync(new URL('../.env.pantas-prod', import.meta.url), 'utf8'), /WRAPPED_PAGE_PUBLIC/);
});
