import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test, {before, after} from 'node:test';
import {initializeTestEnvironment, assertFails, assertSucceeds} from '@firebase/rules-unit-testing';
import {doc, getDoc, getDocs, collection, setDoc, updateDoc, deleteDoc, serverTimestamp, Timestamp} from 'firebase/firestore';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);

const OWNER = 'l1-owner';
const OTHER = 'l1-other';
const FAR = Date.now() + 365 * 86400000;
let env;

const named = (uid, extra = {}) => env.authenticatedContext(uid, {firebase: {sign_in_provider: 'google.com'}, ...extra}).firestore();
const pro = uid => named(uid, {pro: true, proUntil: FAR});
const anon = uid => env.authenticatedContext(uid, {firebase: {sign_in_provider: 'anonymous'}}).firestore();
const signedOut = () => env.unauthenticatedContext().firestore();

// Every path below is written and read only by the Admin SDK (functions).
// No client may read, list, create, change or delete it, whatever its claims.
const SERVER_ONLY_DOCS = [
  `users/${OWNER}/server/entitlement`,
  `users/${OWNER}/server/trial`,
  `users/${OWNER}/server/answerTotals`,
  `users/${OWNER}/server/answers/items/s1`,
  `users/${OWNER}/server/mocks/items/m1`,
  `users/${OWNER}/server/reviews/items/q1`,
  `users/${OWNER}/server/lessonReads/items/l1`,
  `users/${OWNER}/server/settings`,
  `users/${OWNER}/server/roadmap`,
  `users/${OWNER}/server/roadmapDays/items/d1`,
  `users/${OWNER}/server/roadmapHistory/items/h1`,
  `users/${OWNER}/server/roadmapAdvances/items/r1`,
  `users/${OWNER}/server/studyInsights`,
  `users/${OWNER}/server/studyRevision`,
  `users/${OWNER}/pendingCheckouts/k1`,
  `users/${OWNER}/proDossiers/d1`,
  `users/${OWNER}/limits/syncGeneration`,
  `users/${OWNER}/limits/signInAudit`,
  'content/questions/items/q1',
  'content/lessons/items/l1',
  'content/catalog/items/exam_cse',
  'content/mocks/items/exam_cse',
  'content/gaps/items/tags',
  'contentPro/q1',
  'examTracks/exam_cse/proContent/p1',
  'audit_logs/a1',
  'publicIds/100000001',
  'retiredPublicIds/100000001',
  'passOwners/GPA.l1',
  'paymongoOrders/ref1',
  'paymongoCheckouts/cs_1',
  'paymongoPayments/pay_1',
  'paymongoFollowUps/pay_1',
  'paymongoRevocations/pay_1',
  'paymongoSittingMoves/exam_cse_pro:2027-03-14',
  'webhookEvents/evt_1/users/' + OWNER,
  'webhookRateLimits/' + OWNER + '_1',
  'trialUsedIdentities/abc123',
  'config/testers',
  'wrapped_shares/' + 'c'.repeat(32), // clients never read hosted cards back
];

before(async () => {
  env = await initializeTestEnvironment({projectId: 'demo-pantas-test',
    firestore: {rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8')}});
  await env.withSecurityRulesDisabled(async context => {
    const db = context.firestore();
    for (const path of SERVER_ONLY_DOCS) await setDoc(doc(db, path), {ownerUid: OWNER, uid: OWNER, payload: 'secret'});
    await setDoc(doc(db, `users/${OWNER}`), {createdAt: new Date('2026-08-01T00:00:00Z'), publicId: '100000001', claimsChangedAt: 1});
    await setDoc(doc(db, `users/${OWNER}/passes/GPA.l1`), {examId: 'exam_cse_pro', state: 'active', endsAt: 1900000000000});
    await setDoc(doc(db, `users/${OWNER}/grants/g1`), {source: 'paymongo', state: 'active', endsAt: 1900000000000});
    await setDoc(doc(db, `users/${OWNER}/sync_state/current`), {activeGenerationId: 'active', schemaVersion: 1});
    await setDoc(doc(db, `users/${OWNER}/sync_generations/active`), {
      status: 'active', schemaVersion: 1, createdAt: new Date('2026-08-01T00:00:00Z'), createdByDeviceId: 'seed', preferences: {}});
  });
});
after(async () => {
  // Other suites share this emulator and read the same collections as the Admin SDK.
  // Remove every fixture this file seeded so none leaks into them.
  await env.withSecurityRulesDisabled(async context => {
    const db = context.firestore();
    for (const path of SERVER_ONLY_DOCS) await deleteDoc(doc(db, path));
    for (const path of [`users/${OWNER}/passes/GPA.l1`, `users/${OWNER}/grants/g1`, `users/${OWNER}/sync_state/current`,
      `users/${OWNER}/sync_generations/active/lesson_progress/l1`, `users/${OWNER}/sync_generations/active/lesson_progress/bad`,
      `users/${OWNER}/sync_generations/active`, `users/${OWNER}`, 'users/l1-new-user', 'wrapped_shares/' + 'd'.repeat(32)]) {
      await deleteDoc(doc(db, path));
    }
  });
  await env.cleanup();
});

test('server-only paths deny every client: owner, Pro, admin, anonymous, other and signed out', async () => {
  const clients = {
    owner: named(OWNER), pro: pro(OWNER), admin: named(OWNER, {admin: true, pro: true, proUntil: FAR}),
    anonymous: anon(OWNER), other: pro(OTHER), signedOut: signedOut(),
  };
  for (const [who, db] of Object.entries(clients)) {
    for (const path of SERVER_ONLY_DOCS) {
      // wrapped_shares: owner create/revoke is allowed by design and covered below.
      await assertFails(getDoc(doc(db, path)), `${who} read ${path}`);
      if (path.startsWith('wrapped_shares/')) continue;
      await assertFails(setDoc(doc(db, path), {payload: 'x'}), `${who} write ${path}`);
      await assertFails(updateDoc(doc(db, path), {payload: 'x'}), `${who} update ${path}`);
      await assertFails(deleteDoc(doc(db, path)), `${who} delete ${path}`);
    }
  }
});

test('server-only collections cannot be listed by any client', async () => {
  for (const db of [named(OWNER), pro(OWNER), anon(OWNER), pro(OTHER), signedOut()]) {
    for (const path of ['content/gaps/items', 'content/questions/items', 'contentPro', `users/${OWNER}/server/answers/items`,
      `users/${OWNER}/server/mocks/items`, `users/${OWNER}/server`, `users/${OWNER}/pendingCheckouts`, `users/${OWNER}/limits`,
      'paymongoOrders', 'paymongoPayments', 'passOwners', 'audit_logs', 'webhookEvents', 'trialUsedIdentities', 'config']) {
      await assertFails(getDocs(collection(db, path)), path);
    }
  }
});

test('an unlisted path is denied by the default rule', async () => {
  await assertFails(getDoc(doc(pro(OWNER), 'somethingNew/doc1')));
  await assertFails(setDoc(doc(pro(OWNER), 'somethingNew/doc1'), {a: 1}));
  await assertFails(setDoc(doc(pro(OWNER), `users/${OWNER}/unlisted/doc1`), {a: 1}));
});

test('user root: owner reads; other, anonymous and signed-out clients cannot', async () => {
  assert.equal((await assertSucceeds(getDoc(doc(named(OWNER), `users/${OWNER}`)))).get('publicId'), '100000001');
  await assertFails(getDoc(doc(named(OTHER), `users/${OWNER}`)));
  await assertFails(getDoc(doc(anon(OWNER), `users/${OWNER}`)));
  await assertFails(getDoc(doc(signedOut(), `users/${OWNER}`)));
});

test('user root update accepts valid profile fields', async () => {
  const ref = doc(named(OWNER), `users/${OWNER}`);
  await assertSucceeds(updateDoc(ref, {displayName: 'Maria', photoUrl: 'https://example.com/a.png',
    lastSeenAt: serverTimestamp(), preferences: {theme: 'dark'}, schemaVersion: 1}));
  await assertSucceeds(updateDoc(ref, {displayName: null}));
});

test('user root update rejects wrong types and oversize values', async () => {
  const ref = doc(named(OWNER), `users/${OWNER}`);
  await assertFails(updateDoc(ref, {displayName: 42}));
  await assertFails(updateDoc(ref, {displayName: 'x'.repeat(129)}));
  await assertFails(updateDoc(ref, {photoUrl: 'x'.repeat(2049)}));
  await assertFails(updateDoc(ref, {lastSeenAt: 'yesterday'}));
  await assertFails(updateDoc(ref, {preferences: 'dark'}));
  await assertFails(updateDoc(ref, {preferences: Object.fromEntries(Array.from({length: 201}, (_, i) => [`k${i}`, 'v']))}));
  await assertFails(updateDoc(ref, {schemaVersion: '1'}));
});

test('user root update rejects server-owned fields; other, anonymous and signed-out clients cannot update', async () => {
  const ref = doc(named(OWNER), `users/${OWNER}`);
  for (const field of ['publicId', 'claimsChangedAt', 'pro', 'proUntil', 'tier', 'admin', 'createdAt']) {
    await assertFails(updateDoc(ref, {[field]: 'x'}), field);
  }
  const patch = {displayName: 'Hacked'};
  await assertFails(updateDoc(doc(named(OTHER), `users/${OWNER}`), patch));
  await assertFails(updateDoc(doc(anon(OWNER), `users/${OWNER}`), patch));
  await assertFails(updateDoc(doc(signedOut(), `users/${OWNER}`), patch));
});

test('user root create needs the owner, only createdAt and the server time; delete is never allowed', async () => {
  const uid = 'l1-new-user';
  await assertFails(setDoc(doc(named(uid), `users/${uid}`), {createdAt: serverTimestamp(), pro: true}));
  await assertFails(setDoc(doc(named(uid), `users/${uid}`), {createdAt: new Date('2020-01-01')}));
  await assertFails(setDoc(doc(named(OTHER), `users/${uid}`), {createdAt: serverTimestamp()}));
  await assertFails(setDoc(doc(signedOut(), `users/${uid}`), {createdAt: serverTimestamp()}));
  await assertFails(setDoc(doc(anon(uid), `users/${uid}`), {createdAt: serverTimestamp()}));
  await assertSucceeds(setDoc(doc(named(uid), `users/${uid}`), {createdAt: serverTimestamp()}));
  await assertFails(deleteDoc(doc(named(uid), `users/${uid}`)));
});

test('passes and grants: owner reads, nobody else; no client writes', async () => {
  for (const path of [`users/${OWNER}/passes/GPA.l1`, `users/${OWNER}/grants/g1`]) {
    await assertSucceeds(getDoc(doc(named(OWNER), path)));
    await assertSucceeds(getDoc(doc(anon(OWNER), path)));
    await assertFails(getDoc(doc(named(OTHER), path)));
    await assertFails(getDoc(doc(signedOut(), path)));
    await assertFails(setDoc(doc(named(OWNER), path), {state: 'active'}));
    await assertFails(updateDoc(doc(named(OWNER, {admin: true}), path), {endsAt: 4102444800000}));
    await assertFails(deleteDoc(doc(named(OWNER), path)));
  }
});

test('sync control: Pro owner reads sync_state, nobody writes it; other and signed-out denied', async () => {
  const path = `users/${OWNER}/sync_state/current`;
  await assertSucceeds(getDoc(doc(pro(OWNER), path)));
  await assertFails(getDoc(doc(named(OWNER), path)));
  await assertFails(getDoc(doc(pro(OTHER), path)));
  await assertFails(getDoc(doc(signedOut(), path)));
  await assertFails(setDoc(doc(pro(OWNER), path), {activeGenerationId: 'evil'}));
  await assertFails(updateDoc(doc(pro(OWNER), path), {activeGenerationId: 'evil'}));
  await assertFails(deleteDoc(doc(pro(OWNER), path)));
});

const row = (over = {}) => ({lessonId: 'l1', readAt: '2026-10-07T00:00:00Z', updatedAt: serverTimestamp(),
  originDeviceId: 'device-1', mutationId: 'mutation-1', schemaVersion: 1, deleted: false, ...over});

test('sync rows: Pro owner writes an exact row; other, Free, anonymous and signed-out clients cannot', async () => {
  const path = `users/${OWNER}/sync_generations/active/lesson_progress/l1`;
  await assertSucceeds(setDoc(doc(pro(OWNER), path), row()));
  await assertSucceeds(getDoc(doc(pro(OWNER), path)));
  await assertFails(getDoc(doc(pro(OTHER), path)));
  await assertFails(setDoc(doc(pro(OTHER), path), row()));
  await assertFails(setDoc(doc(named(OWNER), path), row()));
  await assertFails(getDoc(doc(named(OWNER), path)));
  await assertFails(setDoc(doc(anon(OWNER), path), row()));
  await assertFails(setDoc(doc(signedOut(), path), row()));
  await assertFails(deleteDoc(doc(pro(OWNER), path)));
});

test('sync rows reject invalid shape: extra field, bad types, empty or oversize identifiers', async () => {
  const path = `users/${OWNER}/sync_generations/active/lesson_progress/bad`;
  const db = pro(OWNER);
  await assertFails(setDoc(doc(db, path), row({extra: 'x'})));
  await assertFails(setDoc(doc(db, path), row({updatedAt: new Date('2020-01-01')})));
  await assertFails(setDoc(doc(db, path), row({schemaVersion: 2})));
  await assertFails(setDoc(doc(db, path), row({deleted: 'no'})));
  await assertFails(setDoc(doc(db, path), row({originDeviceId: ''})));
  await assertFails(setDoc(doc(db, path), row({originDeviceId: 'd'.repeat(129)})));
  await assertFails(setDoc(doc(db, path), row({mutationId: 'm'.repeat(129)})));
  await assertFails(setDoc(doc(db, path), row({mutationId: 7})));
  await assertSucceeds(setDoc(doc(db, path), row({originDeviceId: 'd'.repeat(128), mutationId: 'm'.repeat(128)})));
});

test('generation preferences must be a bounded map; clients cannot create or change lifecycle fields', async () => {
  const db = pro(OWNER);
  const active = doc(db, `users/${OWNER}/sync_generations/active`);
  await assertSucceeds(updateDoc(active, {preferences: {theme: 'dark'}}));
  await assertFails(updateDoc(active, {preferences: 'dark'}));
  await assertFails(updateDoc(active, {preferences: Object.fromEntries(Array.from({length: 201}, (_, i) => [`k${i}`, 'v']))}));
  await assertFails(updateDoc(active, {status: 'retired'}));
  await assertFails(updateDoc(doc(pro(OTHER), `users/${OWNER}/sync_generations/active`), {preferences: {}}));
  await assertFails(updateDoc(doc(signedOut(), `users/${OWNER}/sync_generations/active`), {preferences: {}}));
  await assertFails(deleteDoc(active));
});

test('wrapped_shares: owner creates the exact client shape and may only revoke', async () => {
  const id = 'd'.repeat(32);
  const record = {ownerUid: OWNER, storagePath: `wrapped/${OWNER}/${id}.png`, archetypeId: 'night_owl',
    createdAt: serverTimestamp(), revoked: false};
  const ref = doc(anon(OWNER), 'wrapped_shares', id);
  await assertFails(setDoc(ref, {...record, extra: 'x'}));
  await assertFails(setDoc(ref, {...record, archetypeId: 'a'.repeat(65)}));
  await assertFails(setDoc(ref, {...record, archetypeId: 5}));
  await assertFails(setDoc(ref, {...record, createdAt: 'now'}));
  await assertFails(setDoc(ref, {...record, revoked: true}));
  await assertFails(setDoc(doc(signedOut(), 'wrapped_shares', id), record));
  await assertFails(setDoc(doc(named(OTHER), 'wrapped_shares', id), record));
  await assertSucceeds(setDoc(ref, record));
  await assertFails(getDoc(ref));
  await assertFails(updateDoc(doc(named(OTHER), 'wrapped_shares', id), {revoked: true}));
  await assertFails(updateDoc(doc(signedOut(), 'wrapped_shares', id), {revoked: true}));
  await assertFails(updateDoc(ref, {archetypeId: 'other'}));
  await assertFails(updateDoc(ref, {revoked: false}));
  await assertFails(deleteDoc(ref));
  await assertSucceeds(updateDoc(ref, {revoked: true}));
});
