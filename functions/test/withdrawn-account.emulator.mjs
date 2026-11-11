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
  assert.equal(typeof (await db.doc(`accountDeletions/${uid}`).get()).get('closedUntil'), 'number');
  assert.equal((await db.doc(`users/${uid}/server/guardianConsent`).get()).exists, false);
  await assert.rejects(adminAuth.getUser(uid), error => error.code === 'auth/user-not-found');
});

test('completed deletion keeps only a two-hour closure marker, then scheduled cleanup removes it', async () => {
  const {runInactivityPass} = await import('../lib/purgeInactiveAccounts.js');
  const uid = 'withdrawn-completed-marker', at = Date.now();
  const adminAuth = getAuth();
  await adminAuth.createUser({uid});
  await deleteUserData(db, adminAuth, uid, 'user_request', {now: () => at});
  const marker = db.doc(`accountDeletions/${uid}`);
  assert.deepEqual((await marker.get()).data(), {closedUntil: at + 7200000, nextRetryAt: at + 7200000});
  const deps = {db, auth: adminAuth, mailer: {send: async () => {}}, linkOrigin: 'http://localhost', warningCap: 0};
  await runInactivityPass({...deps, now: () => at + 7199999});
  assert.equal((await marker.get()).exists, true);
  await runInactivityPass({...deps, now: () => at + 7200000});
  assert.equal((await marker.get()).exists, false);
});

test('original ID token cannot recreate root, upload, or call after completed deletion', async t => {
  const {getStorage} = await import('firebase-admin/storage');
  const signup = await fetch(`http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=demo-key`, {
    method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({returnSecureToken: true, email: `replay-${Date.now()}@example.test`, password: 'test-password-123'}),
  });
  const {localId: uid, idToken} = await signup.json();
  assert.ok(idToken);
  const originalAuth = {uid, token: await getAuth().verifyIdToken(idToken)};
  await deleteUserData(db, getAuth(), uid, 'user_request');
  await t.test('Firestore rejects original token root recreation', async () => {
    const response = await fetch(`http://${process.env.FIRESTORE_EMULATOR_HOST}/v1/projects/demo-pantas-test/databases/(default)/documents:commit`, {
      method: 'POST', headers: {Authorization: `Bearer ${idToken}`, 'Content-Type': 'application/json'},
      body: JSON.stringify({writes: [{update: {name: `projects/demo-pantas-test/databases/(default)/documents/users/${uid}`, fields: {}}, updateTransforms: [{fieldPath: 'createdAt', setToServerValue: 'REQUEST_TIME'}]}]}),
    });
    assert.equal(response.status, 403);
  });
  await t.test('Storage rejects original token upload', async () => {
    const path = `betaFeedback/${uid}/${'A'.repeat(20)}/0`;
    const response = await fetch(`http://${process.env.FIREBASE_STORAGE_EMULATOR_HOST}/v0/b/${getStorage().bucket().name}/o?name=${encodeURIComponent(path)}`, {
      method: 'POST', headers: {Authorization: `Bearer ${idToken}`, 'Content-Type': 'image/png'}, body: Buffer.from('replay'),
    });
    assert.equal(response.status, 403);
  });
  await t.test('shared callable check rejects original token', async () => {
    await assert.rejects(endpoints.ingestSession.run({auth: originalAuth, app, data: {}}), error => error.details?.reason === 'account-closed');
  });
});

test('completed deletion removes beta feedback attachments and invalidates their download URL', async () => {
  const {getStorage} = await import('firebase-admin/storage');
  const uid = 'withdrawn-feedback-delete', bucket = getStorage().bucket();
  const path = `betaFeedback/${uid}/${'A'.repeat(20)}/0`, control = `betaFeedback/${uid}-other/${'A'.repeat(20)}/0`;
  const token = 'feedback-download-test-token';
  await getAuth().createUser({uid});
  await bucket.file(path).save(Buffer.from('feedback'), {metadata: {metadata: {firebaseStorageDownloadTokens: token}}});
  await bucket.file(control).save(Buffer.from('keep'));
  const url = `http://${process.env.FIREBASE_STORAGE_EMULATOR_HOST}/v0/b/${bucket.name}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
  assert.equal((await fetch(url)).status, 200);
  await deleteUserData(db, getAuth(), uid, 'user_request');
  // The emulator can hide a missing private object with 403 when another rules
  // suite installed deny-read rules. Either response must invalidate the URL.
  assert.ok([403, 404].includes((await fetch(url)).status));
  assert.equal((await bucket.file(path).exists())[0], false);
  assert.equal((await bucket.file(control).exists())[0], true);
});
