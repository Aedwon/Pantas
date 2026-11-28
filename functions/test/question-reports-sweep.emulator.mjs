import './_secrets-helper.mjs';
import '../lib/index.js';
import test from 'node:test';
import assert from 'node:assert/strict';
import {getFirestore, Timestamp} from 'firebase-admin/firestore';
import {runPurgeOverdueQuestionReports, MAX_PER_RUN} from '../lib/purgeOverdueQuestionReports.js';
import * as jobs from '../lib/scheduledJobs.js';

const db = getFirestore();
const DAY = 86_400_000;
const now = Date.parse('2026-12-01T03:00:00+08:00');
const put = (id, ageDays, extra = {}) => db.doc(`questionReports/${id}`).set({
  accountId: 'sweep', questionId: 'q', message: 'm', createdAt: Timestamp.fromMillis(now - ageDays * DAY),
  expireAt: Timestamp.fromMillis(now - ageDays * DAY + 85 * DAY), ...extra,
});
const clean = async () => { for (const d of (await db.collection('questionReports').where('accountId', '==', 'sweep').get()).docs) await d.ref.delete(); };

test('a report older than 86 days does not survive one run, a newer one does', async () => {
  await clean();
  await put('sweep_old_a', 87);
  await put('sweep_old_b', 120);
  await put('sweep_edge_under', 85.5);
  await put('sweep_new', 10);
  const result = await runPurgeOverdueQuestionReports({db, now: () => now});
  assert.deepEqual(result, {deleted: 2});
  const left = (await db.collection('questionReports').where('accountId', '==', 'sweep').get()).docs.map((d) => d.id).sort();
  assert.deepEqual(left, ['sweep_edge_under', 'sweep_new']);
  await clean();
});

test('a run with nothing overdue deletes nothing, and a second run is a no-op', async () => {
  await clean();
  await put('sweep_new', 1);
  assert.deepEqual(await runPurgeOverdueQuestionReports({db, now: () => now}), {deleted: 0});
  assert.deepEqual(await runPurgeOverdueQuestionReports({db, now: () => now}), {deleted: 0});
  assert.equal((await db.doc('questionReports/sweep_new').get()).exists, true);
  await clean();
});

test('it finds overdue reports by receipt time even when the expiry field is missing', async () => {
  await clean();
  await db.doc('questionReports/sweep_noexpiry').set({accountId: 'sweep', createdAt: Timestamp.fromMillis(now - 100 * DAY)});
  assert.deepEqual(await runPurgeOverdueQuestionReports({db, now: () => now}), {deleted: 1});
  await clean();
});

test('a run is bounded: it deletes at most one run\'s worth and the next run takes the rest', async () => {
  await clean();
  const extra = 5;
  const writer = db.bulkWriter();
  for (let i = 0; i < MAX_PER_RUN + extra; i++) {
    writer.set(db.doc(`questionReports/sweep_bulk_${i}`), {accountId: 'sweep', createdAt: Timestamp.fromMillis(now - 90 * DAY)});
  }
  await writer.close();
  assert.deepEqual(await runPurgeOverdueQuestionReports({db, now: () => now}), {deleted: MAX_PER_RUN});
  assert.deepEqual(await runPurgeOverdueQuestionReports({db, now: () => now}), {deleted: extra});
  await clean();
});

test('the sweep is a task in an existing daily job, not a job of its own', () => {
  assert.ok(jobs.DAILY_EARLY_TASKS.includes('purgeOverdueQuestionReports'));
  assert.equal(jobs.TASKS.purgeOverdueQuestionReports.name, 'purgeOverdueQuestionReports');
});
