import './_secrets-helper.mjs';
import '../lib/index.js';
import test from 'node:test';
import assert from 'node:assert/strict';
import {getFirestore} from 'firebase-admin/firestore';
import {storeQuestionReport, reportDocId, questionCounterId} from '../lib/questionReports.js';
import {sendQuestionReport} from '../lib/index.js';
import {deleteUserData} from '../lib/deleteUserData.js';
import {RateLimiter} from '../lib/clientTelemetry.js';

const db = getFirestore();
const uid = 'qr-emulator';
const report = (n, extra = {}) => ({reportId: `emulator-report-${String(n).padStart(4, '0')}`, questionId: 'cse-q-1',
  questionVersion: 2, examId: 'cse-pro', message: `Concern ${n}`, build: '7', ...extra});
const request = (data, who = uid) => ({auth: {uid: who}, app: {appId: 'test'}, data: {accountId: who, ...data}});
const at = Date.parse('2026-11-23T10:00:00+08:00');
const deps = () => ({db, now: () => at, limiter: new RateLimiter(1000)});
const mine = async (who = uid) => (await db.collection('questionReports').where('accountId', '==', who).get());
const clean = async (who = uid) => {
  await db.recursiveDelete(db.doc(`users/${who}`));
  await db.doc(`accountDeletions/${who}`).delete();
  for (const doc of (await mine(who)).docs) await doc.ref.delete();
};

test('the callable is exported and a real Firestore transaction stores, dedupes and limits', async () => {
  assert.ok(sendQuestionReport.__endpoint?.callableTrigger);
  await clean();
  await storeQuestionReport(request(report(1)), deps());
  await storeQuestionReport(request(report(1)), deps());
  const stored = await mine();
  assert.equal(stored.size, 1);
  assert.equal(stored.docs[0].id, reportDocId(uid, report(1).reportId));
  assert.equal(stored.docs[0].get('message'), 'Concern 1');
  assert.equal(stored.docs[0].get('createdAt').toMillis(), at);
  assert.equal((await db.doc(`users/${uid}/server/questionReportDay`).get()).get('count'), 1);
  assert.equal((await db.doc(`users/${uid}/questionReportCounts/${questionCounterId('cse-q-1')}`).get()).get('count'), 1);
  for (let n = 2; n <= 3; n++) await storeQuestionReport(request(report(n)), deps());
  await assert.rejects(storeQuestionReport(request(report(9)), deps()),
    (e) => e.code === 'resource-exhausted' && e.details.reason === 'question-limit');
  assert.equal((await mine()).size, 3);
  await clean();
});

test('every report stored in Firestore carries a server-made expireAt 85 days out', async () => {
  await clean();
  for (let n = 60; n < 63; n++) await storeQuestionReport(request(report(n, {questionId: `ttl-${n}`})), deps());
  const stored = await mine();
  assert.equal(stored.size, 3);
  for (const doc of stored.docs) {
    const expireAt = doc.get('expireAt');
    assert.ok(expireAt, `${doc.id} has no expireAt`);
    assert.equal(expireAt.toMillis(), doc.get('createdAt').toMillis() + 85 * 86_400_000);
    assert.equal(expireAt.toMillis(), at + 85 * 86_400_000);
  }
  await clean();
});

test('the callable itself refuses a wrong account and a signed-out call before storing anything', async () => {
  await clean();
  await assert.rejects(sendQuestionReport.run({auth: {uid}, app: {appId: 'test'}, data: {...report(1), accountId: 'someone-else'}}),
    (e) => e.details?.reason === 'wrong-account');
  await assert.rejects(sendQuestionReport.run({auth: undefined, app: {appId: 'test'}, data: {...report(1), accountId: uid}}),
    (e) => e.code === 'unauthenticated');
  assert.equal((await mine()).size, 0);
});

test('concurrent sends of one report id store it once and count it once', async () => {
  await clean();
  await Promise.all([1, 2, 3, 4].map(() => storeQuestionReport(request(report(5)), deps())));
  assert.equal((await mine()).size, 1);
  assert.equal((await db.doc(`users/${uid}/questionReportCounts/${questionCounterId('cse-q-1')}`).get()).get('count'), 1);
  await clean();
});

test('concurrent sends of different reports cannot pass the per-question limit', async () => {
  await clean();
  const results = await Promise.allSettled([1, 2, 3, 4, 5, 6].map((n) => storeQuestionReport(request(report(n + 10)), deps())));
  assert.equal(results.filter((r) => r.status === 'fulfilled').length, 3);
  assert.equal((await mine()).size, 3);
  await clean();
});

test('a reused report id with other content is refused against real storage', async () => {
  await clean();
  await storeQuestionReport(request(report(30)), deps());
  await assert.rejects(storeQuestionReport(request({...report(30), message: 'something else'}), deps()),
    (e) => e.code === 'already-exists');
  await clean();
});

test('different custom uids with underscores store different reports for one report id', async () => {
  const a = 'qr_x', b = 'qr';
  for (const who of [a, b]) await clean(who);
  await storeQuestionReport(request(report(31), a), deps());
  await storeQuestionReport(request(report(31), b), deps());
  assert.equal((await mine(a)).size, 1);
  assert.equal((await mine(b)).size, 1);
  for (const who of [a, b]) await clean(who);
});

test('a send after the deletion marker is refused, and nothing is written', async () => {
  await clean();
  await db.doc(`accountDeletions/${uid}`).set({reason: 'user_request'});
  await assert.rejects(storeQuestionReport(request(report(40)), deps()),
    (e) => e.code === 'permission-denied' && e.details.reason === 'account-closed');
  assert.equal((await mine()).size, 0);
  assert.equal((await db.doc(`users/${uid}/server/questionReportDay`).get()).exists, false);
  await clean();
});

test('sends racing a deletion leave no report behind once the deletion has finished', async () => {
  const who = 'qr-race';
  for (let round = 0; round < 5; round++) {
    await clean(who);
    await db.doc(`users/${who}/server/seed`).set({x: 1});
    const adminAuth = {getUser: async () => ({uid: who, providerData: []}), deleteUser: async () => {}};
    const sends = [1, 2, 3, 4, 5, 6].map((n) => storeQuestionReport(request(report(50 + n, {questionId: `race-${n}`}), who), deps())
      .catch((e) => { assert.equal(e.details?.reason, 'account-closed'); }));
    await Promise.all([...sends, deleteUserData(db, adminAuth, who, 'user_request', {now: () => at})]);
    assert.equal((await mine(who)).size, 0, `round ${round}: a report outlived the deletion`);
    assert.equal((await db.doc(`users/${who}/server/questionReportDay`).get()).exists, false);
  }
  await db.doc(`accountDeletions/${who}`).delete();
});

test('deleting the account deletes its reports and counts, and only its own', async () => {
  const doomed = 'qr-doomed', kept = 'qr-kept';
  for (const who of [doomed, kept]) {
    await clean(who);
    await storeQuestionReport(request(report(20), who), deps());
  }
  const adminAuth = {getUser: async () => ({uid: doomed, providerData: []}), deleteUser: async () => {}};
  await deleteUserData(db, adminAuth, doomed, 'user_request', {now: () => at});
  assert.equal((await mine(doomed)).size, 0);
  assert.equal((await db.doc(`users/${doomed}/server/questionReportDay`).get()).exists, false);
  assert.equal((await mine(kept)).size, 1);
  await db.doc(`accountDeletions/${doomed}`).delete();
  await clean(kept);
});
