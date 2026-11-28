import {setTestSecrets} from './_secrets-helper.mjs';
setTestSecrets({TRIAL_IDENTITY_HMAC_KEY: 'expiry-emulator-only-hmac-key'});
import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore, Timestamp} from 'firebase-admin/firestore';
import {getAuth} from 'firebase-admin/auth';
import {deleteUserData} from '../lib/deleteUserData.js';
import {identityMarkers, identityMarkersForUser, startTrial} from '../lib/webTrial.js';
import {fakeAuth} from './_paymongo-helpers.mjs';
import {addTrialCodeExpiry, TRIAL_CODE_DAYS} from '../scripts/add_trial_code_expiry.mjs';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore(), auth = getAuth();
const DAY = 86400000, T0 = Date.parse('2026-10-20T10:00:00+08:00');
const caller = (uid, sub) => ({uid, token: {email: `${uid}@example.test`, email_verified: true,
  firebase: {sign_in_provider: 'google.com', identities: {'google.com': [sub]}}}});
const reset = async uid => { await db.recursiveDelete(db.doc(`users/${uid}`)); await db.doc(`accountDeletions/${uid}`).delete(); };

test('D7 deletion path: the code expires 730 days after the trial start in the account record', async () => {
  const uid = 'tce-start'; await reset(uid); await auth.createUser({uid}).catch(() => {});
  await db.doc(`users/${uid}/server/trial`).set({usedAt: T0, grantId: 'trial'});
  const who = caller(uid, 'tce-start-sub');
  const paths = identityMarkers(who, db).map(ref => ref.path);
  await deleteUserData(db, auth, uid, 'user_request', {requestAuth: who, now: () => T0 + 300 * DAY});
  for (const path of paths) {
    const row = (await db.doc(path).get()).data();
    assert.equal(row.startedAt, T0);
    assert.equal(row.expireAt.toMillis(), T0 + 730 * DAY);
  }
});

test('D7 deletion path: without a trial start the code counts from the deletion time', async () => {
  const uid = 'tce-nostart'; await reset(uid); await auth.createUser({uid}).catch(() => {});
  await db.doc(`users/${uid}/server/trial`).set({grantId: 'trial'});
  const who = caller(uid, 'tce-nostart-sub');
  const paths = identityMarkers(who, db).map(ref => ref.path);
  const deletedAt = T0 + 40 * DAY;
  await deleteUserData(db, auth, uid, 'user_request', {requestAuth: who, now: () => deletedAt});
  for (const path of paths) {
    const row = (await db.doc(path).get()).data();
    assert.equal(row.startedAt, deletedAt);
    assert.equal(row.expireAt.toMillis(), deletedAt + 730 * DAY);
  }
});

test('D7 script: dry run counts only, live sets deploy date + 730 days on codes without one, rerun is a no-op', async () => {
  const col = db.collection('trialUsedIdentities');
  for (const doc of (await col.get()).docs) await doc.ref.delete();
  const keep = Timestamp.fromMillis(T0 + 5 * DAY);
  await col.doc('a'.repeat(64)).set({used: true});
  await col.doc('b'.repeat(64)).set({used: true});
  await col.doc('c'.repeat(64)).set({used: true, startedAt: T0, expireAt: keep});
  const deployAt = Date.parse('2026-12-01T00:00:00+08:00');

  assert.deepEqual(await addTrialCodeExpiry({db, live: false, deployAt}), {reads: 3, missing: 2, writes: 0, skipped: 0});
  assert.deepEqual((await col.doc('a'.repeat(64)).get()).data(), {used: true});

  assert.deepEqual(await addTrialCodeExpiry({db, live: true, deployAt}), {reads: 3, missing: 2, writes: 2, skipped: 0});
  for (const id of ['a', 'b']) {
    const row = (await col.doc(id.repeat(64)).get()).data();
    assert.equal(row.used, true);
    assert.equal(row.startedAt, deployAt);
    assert.equal(row.expireAt.toMillis(), deployAt + TRIAL_CODE_DAYS * DAY);
  }
  // A code that already had an expiry is untouched.
  assert.equal((await col.doc('c'.repeat(64)).get()).get('expireAt').toMillis(), keep.toMillis());
  assert.deepEqual(await addTrialCodeExpiry({db, live: true, deployAt: deployAt + DAY}), {reads: 3, missing: 0, writes: 0, skipped: 0});
});

test('D7 deletion path never moves an existing code expiry earlier', async () => {
  const uid = 'tce-keep'; await reset(uid); await auth.createUser({uid}).catch(() => {});
  await db.doc(`users/${uid}/server/trial`).set({usedAt: T0, grantId: 'trial'});
  const who = caller(uid, 'tce-keep-sub');
  const three = {uid, token: {...who.token, firebase: {sign_in_provider: 'custom',
    identities: {...who.token.firebase.identities, 'facebook.com': ['tce-keep-fb']}}}};
  const [later, earlier, legacy] = identityMarkers(three, db);
  assert.ok(later && earlier && legacy, 'the fixture needs three markers');
  const keep = Timestamp.fromMillis(T0 + 900 * DAY), early = Timestamp.fromMillis(T0 + 10 * DAY);
  await later.set({used: true, startedAt: T0 + 170 * DAY, expireAt: keep});
  await earlier.set({used: true, startedAt: T0 - 720 * DAY, expireAt: early});
  await legacy.set({used: true});
  await deleteUserData(db, auth, uid, 'user_request', {requestAuth: three, now: () => T0 + 20 * DAY});
  const got = async ref => (await ref.get()).data();
  assert.deepEqual(await got(later), {used: true, startedAt: T0 + 170 * DAY, expireAt: keep});
  const raised = await got(earlier);
  assert.equal(raised.expireAt.toMillis(), T0 + 730 * DAY);
  assert.equal((await got(legacy)).expireAt.toMillis(), T0 + 730 * DAY);
});

test('D7 deletion retry: with no trial start, the code counts from the FIRST deletion time', async () => {
  const uid = 'tce-retry'; await reset(uid); await auth.createUser({uid}).catch(() => {});
  await db.doc(`users/${uid}/server/trial`).set({grantId: 'trial'});
  const first = T0 + 40 * DAY;
  await db.doc(`accountDeletions/${uid}`).set({reason: 'user_request', startedAt: first});
  const who = caller(uid, 'tce-retry-sub');
  const paths = identityMarkers(who, db).map(ref => ref.path);
  await deleteUserData(db, auth, uid, 'user_request', {requestAuth: who, now: () => first + 90 * DAY});
  for (const path of paths) assert.equal((await db.doc(path).get()).get('expireAt').toMillis(), first + 730 * DAY);
});

test('D7 overlapping deletions keep the first start and its code expiry', {timeout: 30_000}, async t => {
  const uid = 'tce-overlap';
  await reset(uid);
  const user = {email: `${uid}@example.test`, emailVerified: true, providerData: []};
  const markers = identityMarkersForUser(user, db);
  for (const marker of markers) await marker.delete();
  await db.doc(`users/${uid}/server/trial`).set({grantId: 'trial'});
  const taskPath = `accountDeletions/${uid}`;
  const task = db.doc(taskPath);
  const doc = db.doc.bind(db);
  const laterRead = Promise.withResolvers();
  const firstRecorded = Promise.withResolvers();
  const interrupted = new Error('first worker stopped during identity lookup');
  let later;
  let recordedStart;
  const startLater = () => {
    later ??= deleteUserData(db, {
      getUser: async () => {
        recordedStart = (await task.get()).get('startedAt');
        return user;
      },
      deleteUser: async () => {},
    }, uid, 'user_request', {now: () => T0 + DAY});
    return later;
  };
  // If the task is read outside a transaction, force both reads to see the missing task.
  // Let the earlier caller write first, then let the later caller act on its stale read.
  let firstRead = true;
  t.mock.method(db, 'doc', path => {
    const ref = doc(path);
    if (path === taskPath) {
      const get = ref.get.bind(ref);
      t.mock.method(ref, 'get', async () => {
        const snapshot = await get();
        if (firstRead) {
          firstRead = false;
          void startLater();
          await laterRead.promise;
        } else {
          laterRead.resolve();
          await firstRecorded.promise;
        }
        return snapshot;
      });
    }
    return ref;
  });
  await assert.rejects(deleteUserData(db, {
    getUser: async () => {
      firstRecorded.resolve();
      await startLater();
      throw interrupted;
    },
    deleteUser: async () => {},
  }, uid, 'user_request', {now: () => T0}), interrupted);

  for (const marker of markers) {
    assert.equal((await marker.get()).get('expireAt').toMillis(), T0 + 730 * DAY);
  }
  assert.equal(recordedStart, T0);
});

test('D7 deletion: a code whose expiry is already past is not written', async () => {
  const uid = 'tce-past'; await reset(uid); await auth.createUser({uid}).catch(() => {});
  await db.doc(`users/${uid}/server/trial`).set({usedAt: T0 - 800 * DAY, grantId: 'trial'});
  const who = caller(uid, 'tce-past-sub');
  const paths = identityMarkers(who, db).map(ref => ref.path);
  for (const path of paths) await db.doc(path).delete();
  await deleteUserData(db, auth, uid, 'user_request', {requestAuth: who, now: () => T0});
  for (const path of paths) assert.equal((await db.doc(path).get()).exists, false);
});

test('D7 trial: a deleted account cannot start a trial or recreate its data', async () => {
  const uid = 'tce-closed'; await reset(uid);
  await db.doc(`accountDeletions/${uid}`).set({reason: 'user_request', startedAt: T0});
  const who = caller(uid, 'tce-closed-sub');
  await assert.rejects(startTrial(who, {db, auth: fakeAuth(), allow: async () => true, now: () => T0}), {code: 'permission-denied'});
  for (const path of ['server/trial', 'grants/trial', 'server/entitlement']) {
    assert.equal((await db.doc(`users/${uid}/${path}`).get()).exists, false, path);
  }
  for (const ref of identityMarkers(who, db)) assert.equal((await ref.get()).exists, false);
});

test('D7 script: a code changed or deleted after the scan is not overwritten and does not abort the batch', async () => {
  const col = db.collection('trialUsedIdentities');
  for (const doc of (await col.get()).docs) await doc.ref.delete();
  const [a, b, c] = ['d', 'e', 'f'].map(x => col.doc(x.repeat(64)));
  for (const ref of [a, b, c]) await ref.set({used: true});
  const deployAt = Date.parse('2026-12-01T00:00:00+08:00');
  const later = Timestamp.fromMillis(deployAt + 900 * DAY);
  const result = await addTrialCodeExpiry({db, live: true, deployAt, afterScan: async () => {
    await a.update({startedAt: deployAt, expireAt: later}); // assigned meanwhile, later than ours
    await b.delete();
  }});
  assert.deepEqual(result, {reads: 3, missing: 3, writes: 1, skipped: 2});
  assert.equal((await a.get()).get('expireAt').toMillis(), later.toMillis());
  assert.equal((await b.get()).exists, false);
  assert.equal((await c.get()).get('expireAt').toMillis(), deployAt + 730 * DAY);
});
