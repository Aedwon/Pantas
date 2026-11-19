import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore, Timestamp} from 'firebase-admin/firestore';
import {allowAtMost, takeAtMost} from '../lib/_limits.js';
import {purgeGuardianRecords} from '../lib/guardianConsent.js';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const day = 86_400_000;
const now = Date.parse('2026-11-20T00:00:00Z');
const old = now - 31 * day;

test('both per-user counter writers timestamp the active window and cap long retention', async () => {
  const uid = 'retention-test';
  assert.equal(await allowAtMost(uid, 'short', 3, 60_000), true);
  assert.equal(await takeAtMost(uid, 'long', 3, 60 * day, 1), 1);
  for (const [key, window] of [['short', 60_000], ['long', 60 * day]]) {
    const row = await db.doc(`users/${uid}/limits/${key}`).get();
    const start = row.get('windowStartedAt').toMillis();
    const purgeAt = row.get('purgeAt');
    assert.ok(purgeAt instanceof Timestamp, key);
    assert.equal(purgeAt.toMillis(), start + Math.min(window, 29 * day));
  }
});

test('one hourly run purges due and legacy rate limits while retaining fresh counters', async () => {
  const overdue = {count: 1, purgeAt: new Date(old)};
  const fresh = {count: 1, purgeAt: new Date(now + day)};
  const expired = {
    'users/retention-old/limits/stamped': overdue,
    'users/retention-old/limits/legacy': {count: 1, windowStartedAt: Timestamp.fromMillis(old)},
    'guardianLimits/global-2026-10-01': {count: 1},
    'guardianLimits/retention-email': {count: 1, windowStartedAt: old},
    'guardianCodeLimits/retention-old-2026-10-01': {count: 1},
    'signInLimits/global-open-2026-10-01': {count: 1},
    'signInLimits/mailbox-retention-2026-10-01': {sent: 1},
    'signInLimits/ip-retention': {count: 1, windowStartedAt: old},
    'signInCodes/retention': {count: 1, windowStartedAt: old},
    'signInRequests/retention': {sentAt: old, challengeId: 'retention-test'},
    [`webhookRateLimits/retention_${old / 60_000}`]: {count: 1},
    'webhookRateLimits/retention-expired': {count: 1, expireAt: new Date(old)},
    'contentCeiling/2026-10-01-new/shards/1': {count: 1},
    'contentCeiling/2026-10-02/shards/1': {count: 1, purgeAfter: new Date(old)},
  };
  const kept = {
    'users/retention-fresh/limits/stamped': fresh,
    'users/retention-fresh/limits/legacy': {count: 1, windowStartedAt: Timestamp.fromMillis(now)},
    'guardianLimits/global-2026-11-20': {count: 1},
    'guardianCodeLimits/retention-fresh-2026-11-20': {count: 1},
    'signInLimits/retention-fresh': fresh,
    'signInCodes/retention-fresh': fresh,
    'signInRequests/retention-fresh': fresh,
    [`webhookRateLimits/retention_${now / 60_000}`]: {count: 1},
    'contentCeiling/2026-11-20/shards/1': {count: 1},
  };

  const batch = db.batch();
  for (const [path, data] of Object.entries({...expired, ...kept})) batch.set(db.doc(path), data);
  await batch.commit();
  await purgeGuardianRecords(db, now);

  const rows = await db.getAll(...Object.keys({...expired, ...kept}).map(path => db.doc(path)));
  for (const row of rows) assert.equal(row.exists, Object.hasOwn(kept, row.ref.path), row.ref.path);
});

test('legacy cleanup resumes past a full page of fresh counters', async () => {
  const batch = db.batch();
  for (let index = 0; index < 200; index += 1) {
    batch.set(db.doc(`guardianCodeLimits/page-${String(index).padStart(3, '0')}-2026-11-20`), {
      count: 1, purgeAt: new Date(now + day),
    });
  }
  const legacy = db.doc('guardianCodeLimits/zz-after-page-2026-10-01');
  batch.set(legacy, {count: 1});
  await batch.commit();

  await purgeGuardianRecords(db, now);
  assert.equal((await legacy.get()).exists, true);
  await purgeGuardianRecords(db, now + 3_600_000);
  assert.equal((await legacy.get()).exists, false);
});
