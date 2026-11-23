import './_secrets-helper.mjs';
import '../lib/index.js';
import test from 'node:test';
import assert from 'node:assert/strict';
import {getFirestore} from 'firebase-admin/firestore';
import {storeQuestionReport, MAX_PER_QUESTION} from '../lib/questionReports.js';
import {sendQuestionReport} from '../lib/index.js';
import {RateLimiter} from '../lib/clientTelemetry.js';

const db = getFirestore();
const uid = 'qr-emulator';
const report = (n, extra = {}) => ({reportId: `emulator-report-${String(n).padStart(4, '0')}`, questionId: 'cse-q-1',
  questionVersion: 2, examId: 'cse-pro', message: `Concern ${n}`, build: '7', ...extra});
const request = (data, who = uid) => ({auth: {uid: who}, app: {appId: 'test'}, data});
const at = Date.parse('2026-11-23T10:00:00+08:00');
const deps = () => ({db, now: () => at, limiter: new RateLimiter(1000)});
const clean = async () => {
  await db.recursiveDelete(db.doc(`users/${uid}`));
  for (const doc of (await db.collection('questionReports').where('accountId', '==', uid).get()).docs) await doc.ref.delete();
};

test('the callable is exported and a real Firestore transaction stores, dedupes and limits', async () => {
  assert.ok(sendQuestionReport.__endpoint?.callableTrigger);
  await clean();
  await storeQuestionReport(request(report(1)), deps());
  await storeQuestionReport(request(report(1)), deps());
  const stored = await db.collection('questionReports').where('accountId', '==', uid).get();
  assert.equal(stored.size, 1);
  assert.equal(stored.docs[0].id, `${uid}_${report(1).reportId}`);
  assert.equal(stored.docs[0].get('message'), 'Concern 1');
  assert.equal(stored.docs[0].get('createdAt').toMillis(), at);
  assert.equal((await db.doc(`users/${uid}/server/questionReportCounts`).get()).get('dayCount'), 1);
  for (let n = 2; n <= MAX_PER_QUESTION; n++) await storeQuestionReport(request(report(n)), deps());
  await assert.rejects(storeQuestionReport(request(report(9)), deps()),
    (e) => e.code === 'resource-exhausted' && e.details.reason === 'question-limit');
  assert.equal((await db.collection('questionReports').where('accountId', '==', uid).get()).size, 3);
  await clean();
});

test('concurrent sends of one report id store it once and count it once', async () => {
  await clean();
  await Promise.all([1, 2, 3, 4].map(() => storeQuestionReport(request(report(5)), deps())));
  assert.equal((await db.collection('questionReports').where('accountId', '==', uid).get()).size, 1);
  assert.equal((await db.doc(`users/${uid}/server/questionReportCounts`).get()).get('perQuestion')['cse-q-1'], 1);
  await clean();
});

test('concurrent sends of different reports cannot pass the per-question limit', async () => {
  await clean();
  const results = await Promise.allSettled([1, 2, 3, 4, 5, 6].map((n) => storeQuestionReport(request(report(n + 10)), deps())));
  assert.equal(results.filter((r) => r.status === 'fulfilled').length, 3);
  assert.equal((await db.collection('questionReports').where('accountId', '==', uid).get()).size, 3);
  await clean();
});

test('deleting the account deletes its reports and counts, and only its own', async () => {
  const {deleteUserData} = await import('../lib/deleteUserData.js');
  const doomed = 'qr-doomed', kept = 'qr-kept';
  for (const who of [doomed, kept]) {
    await db.recursiveDelete(db.doc(`users/${who}`));
    await storeQuestionReport(request(report(20), who), deps());
  }
  const adminAuth = {getUser: async () => ({uid: doomed, providerData: []}), deleteUser: async () => {}};
  await deleteUserData(db, adminAuth, doomed, 'user_request', {now: () => at});
  assert.equal((await db.doc(`questionReports/${doomed}_${report(20).reportId}`).get()).exists, false);
  assert.equal((await db.doc(`users/${doomed}/server/questionReportCounts`).get()).exists, false);
  assert.equal((await db.doc(`questionReports/${kept}_${report(20).reportId}`).get()).exists, true);
  await db.doc(`questionReports/${kept}_${report(20).reportId}`).delete();
  await db.recursiveDelete(db.doc(`users/${kept}`));
});
