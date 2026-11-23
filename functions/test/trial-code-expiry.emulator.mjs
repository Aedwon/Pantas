import {setTestSecrets} from './_secrets-helper.mjs';
setTestSecrets({TRIAL_IDENTITY_HMAC_KEY: 'expiry-emulator-only-hmac-key'});
import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore, Timestamp} from 'firebase-admin/firestore';
import {getAuth} from 'firebase-admin/auth';
import {deleteUserData} from '../lib/deleteUserData.js';
import {identityMarkers} from '../lib/webTrial.js';
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

  assert.deepEqual(await addTrialCodeExpiry({db, live: false, deployAt}), {reads: 3, missing: 2, writes: 0});
  assert.deepEqual((await col.doc('a'.repeat(64)).get()).data(), {used: true});

  assert.deepEqual(await addTrialCodeExpiry({db, live: true, deployAt}), {reads: 3, missing: 2, writes: 2});
  for (const id of ['a', 'b']) {
    const row = (await col.doc(id.repeat(64)).get()).data();
    assert.equal(row.used, true);
    assert.equal(row.startedAt, deployAt);
    assert.equal(row.expireAt.toMillis(), deployAt + TRIAL_CODE_DAYS * DAY);
  }
  // A code that already had an expiry is untouched.
  assert.equal((await col.doc('c'.repeat(64)).get()).get('expireAt').toMillis(), keep.toMillis());
  assert.deepEqual(await addTrialCodeExpiry({db, live: true, deployAt: deployAt + DAY}), {reads: 3, missing: 0, writes: 0});
});

test('D7 deletion path never moves an existing code expiry earlier', async () => {
  const uid = 'tce-keep'; await reset(uid); await auth.createUser({uid}).catch(() => {});
  await db.doc(`users/${uid}/server/trial`).set({usedAt: T0, grantId: 'trial'});
  const who = caller(uid, 'tce-keep-sub');
  const [later, earlier, legacy] = identityMarkers(who, db);
  const keep = Timestamp.fromMillis(T0 + 900 * DAY), early = Timestamp.fromMillis(T0 + 10 * DAY);
  await later.set({used: true, startedAt: T0 + 170 * DAY, expireAt: keep});
  await earlier.set({used: true, startedAt: T0 - 720 * DAY, expireAt: early});
  if (legacy) await legacy.set({used: true});
  await deleteUserData(db, auth, uid, 'user_request', {requestAuth: who, now: () => T0 + 20 * DAY});
  const got = async ref => (await ref.get()).data();
  assert.deepEqual(await got(later), {used: true, startedAt: T0 + 170 * DAY, expireAt: keep});
  const raised = await got(earlier);
  assert.equal(raised.expireAt.toMillis(), T0 + 730 * DAY);
  if (legacy) assert.equal((await got(legacy)).expireAt.toMillis(), T0 + 730 * DAY);
});
