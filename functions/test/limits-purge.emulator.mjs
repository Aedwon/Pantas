// Every rate-limit write carries purgeAt (a Timestamp), so the limits.purgeAt TTL removes a counter
// that a call racing an account deletion leaves behind (security and billing lead ruling, Nov 24).
import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore, Timestamp} from 'firebase-admin/firestore';
import {allowAtMost, takeAtMost} from '../lib/_limits.js';

const db = getFirestore();
const DAY = 86_400_000;

for (const [name, run] of [
  ['allowAtMost', (uid, key, windowMs) => allowAtMost(uid, key, 5, windowMs)],
  ['takeAtMost', (uid, key, windowMs) => takeAtMost(uid, key, 5, windowMs, 2)],
]) {
  test(`${name} writes purgeAt as a Timestamp one day after the window ends`, async () => {
    const uid = `limits-purge-${name}`, windowMs = 10 * 60_000;
    await run(uid, 'probe', windowMs);
    const doc = (await db.doc(`users/${uid}/limits/probe`).get()).data();
    assert.ok(doc.purgeAt instanceof Timestamp, 'purgeAt must be a Timestamp (TTL ignores numbers)');
    assert.equal(doc.purgeAt.toMillis(), doc.windowStartedAt.toMillis() + windowMs + DAY);
    // A second call in the same window keeps the window's purgeAt.
    await run(uid, 'probe', windowMs);
    const again = (await db.doc(`users/${uid}/limits/probe`).get()).data();
    assert.equal(again.purgeAt.toMillis(), doc.purgeAt.toMillis());
    await db.recursiveDelete(db.doc(`users/${uid}`));
  });
}
