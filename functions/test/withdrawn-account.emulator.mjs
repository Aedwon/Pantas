import assert from 'node:assert/strict';
import test, {before} from 'node:test';
import * as endpoints from '../lib/index.js';
import {getFirestore} from 'firebase-admin/firestore';
import {getAuth} from 'firebase-admin/auth';
import {deleteUserData} from '../lib/deleteUserData.js';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
assert.ok(process.env.FIREBASE_AUTH_EMULATOR_HOST);
assert.ok(process.env.FIREBASE_STORAGE_EMULATOR_HOST);
const db = getFirestore();
const app = {appId: 'app', token: {}, alreadyConsumed: false};
const auth = uid => ({uid, token: {firebase: {sign_in_provider: 'google.com'}, pro: true,
  proUntil: Date.now() + 86400000, auth_time: 1}});
// These authorize a guardian's link, not the student's own account. They must
// keep supporting a withdrawal retry even while the student is blocked.
const guardianVisitors = new Set(['answerGuardianRequest', 'getGuardianRequest', 'getGuardianManage',
  'setGuardianSharing', 'withdrawGuardianPermission']);
const callables = Object.entries(endpoints).filter(([name, fn]) => fn?.__endpoint?.callableTrigger && !guardianVisitors.has(name));
assert.ok(callables.length >= 35, `Only ${callables.length} own-account callables found`);
const uidFor = state => `withdrawn-call-${state}`;
before(async () => {
  for (const state of ['withdrawn', 'deleting', 'deletedConsent']) {
    const uid = uidFor(state);
    await db.recursiveDelete(db.doc(`users/${uid}`));
    await db.doc(`accountDeletions/${uid}`).delete();
    if (state !== 'deletedConsent') await db.doc(`users/${uid}/server/guardianConsent`).set({status: state === 'withdrawn' ? 'withdrawn' : 'confirmed'});
    if (state !== 'withdrawn') await db.doc(`accountDeletions/${uid}`).set({reason: 'guardian_withdrawal'});
  }
});
for (const state of ['withdrawn', 'deleting', 'deletedConsent']) {
  for (const [name, fn] of callables) {
    test(`${state}: ${name} refuses the authenticated account before its handler`, async () => {
      const uid = uidFor(state);
      await assert.rejects(fn.run({auth: auth(uid), app, data: {uid, expectedUid: uid}}), error => {
        assert.equal(error.code, 'permission-denied', `${name}: ${error}`);
        assert.equal(error.details?.reason, 'account-closed', `${name}: structured final refusal`);
        return true;
      });
    });
  }
}

test('normal account with no consent can ingest; withdrawal then refuses the same stale token', async () => {
  const uid = 'withdrawn-call-normal';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  await db.doc(`accountDeletions/${uid}`).delete();
  const now = Date.now(), request = {auth: auth(uid), app, data: {
    sessionId: 'withdrawn-test-session', startedAt: now - 1000, finishedAt: now, durationMs: 1000,
    answers: [{questionId: 'withdrawn-q', chosen: 'a', correct: true, answeredAt: now}],
  }};
  assert.equal((await endpoints.ingestSession.run(request)).stored, true);
  const stored = db.doc(`users/${uid}/server/answers/items/withdrawn-test-session`);
  assert.equal((await stored.get()).exists, true);
  await db.doc(`users/${uid}/server/guardianConsent`).set({status: 'withdrawn'});
  await assert.rejects(endpoints.ingestSession.run(request), error => error.details?.reason === 'account-closed');
});

test('pending deletion is still completed by the unguarded Admin SDK path', async () => {
  const uid = 'withdrawn-call-cleanup', adminAuth = getAuth();
  await adminAuth.createUser({uid});
  await db.doc(`users/${uid}/server/guardianConsent`).set({status: 'withdrawn'});
  await db.doc(`accountDeletions/${uid}`).set({reason: 'guardian_withdrawal'});
  await deleteUserData(db, adminAuth, uid, 'guardian_withdrawal');
  assert.equal((await db.doc(`accountDeletions/${uid}`).get()).exists, false);
  assert.equal((await db.doc(`users/${uid}/server/guardianConsent`).get()).exists, false);
  await assert.rejects(adminAuth.getUser(uid), error => error.code === 'auth/user-not-found');
});
