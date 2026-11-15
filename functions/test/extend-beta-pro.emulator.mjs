import '../lib/index.js';
import test from 'node:test';
import assert from 'node:assert/strict';
import {getFirestore} from 'firebase-admin/firestore';
import {extendBetaPro, recopyClaims, OLD_CUTOFF, NEW_CUTOFF} from '../scripts/extend_beta_pro.mjs';
import {fakeAuth} from './_paymongo-helpers.mjs';
assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore(), now = OLD_CUTOFF - 60_000;
const grant = (state, endsAt = OLD_CUTOFF) => ({source: 'beta', product: 'beta_pro', tier: 'civilService',
  examId: 'exam_cse_pro', startsAt: now - 1000, endsAt, createdAt: now - 1000, state});
const entitlement = uid => db.doc(`users/${uid}/server/entitlement`);
const endOf = async uid => (await db.doc(`users/${uid}/grants/beta_exam_cse_pro`).get()).get('endsAt');

test('extend beta Pro: dry run writes nothing, live extends only active old-cutoff grants, rerun is a no-op', async () => {
  const [a, b, c] = ['extend-active', 'extend-revoked', 'extend-other'];
  for (const uid of [a, b, c]) await db.recursiveDelete(db.doc(`users/${uid}`));
  await db.doc(`users/${a}/grants/beta_exam_cse_pro`).set(grant('active'));
  await entitlement(a).set({pro: true, proUntil: OLD_CUTOFF, version: 1, claimsVersion: 1, claimsPending: false});
  await db.doc(`users/${b}/grants/beta_exam_cse_pro`).set(grant('revoked'));
  await db.doc(`users/${c}/grants/beta_exam_cse_pro`).set(grant('active', OLD_CUTOFF + 1));
  const auth = fakeAuth(), deps = {db, auth, now: () => now};

  assert.deepEqual(await extendBetaPro({...deps, live: false}), {users: 1, grants: 1});
  assert.equal(await endOf(a), OLD_CUTOFF);
  assert.equal((await entitlement(a).get()).get('version'), 1);

  assert.deepEqual(await extendBetaPro({...deps, live: true}), {users: 1, grants: 1, claimsFailed: 0});
  assert.equal(await endOf(a), NEW_CUTOFF);
  assert.equal(await endOf(b), OLD_CUTOFF);
  assert.equal(await endOf(c), OLD_CUTOFF + 1);
  const record = await entitlement(a).get();
  assert.equal(record.get('proUntil'), NEW_CUTOFF); assert.equal(record.get('pro'), true);
  assert.equal(record.get('claimsPending'), false);
  assert.equal(auth.current().pro, true); assert.equal(auth.current().proUntil, NEW_CUTOFF);
  assert.equal((await db.doc(`users/${b}/server/entitlement`).get()).exists, false);

  const version = record.get('version');
  assert.deepEqual(await extendBetaPro({...deps, live: true}), {users: 0, grants: 0, claimsFailed: 0});
  assert.equal((await entitlement(a).get()).get('version'), version);

  // The claims-only rerun copies claims again for the extended user only.
  assert.deepEqual(await recopyClaims({db, auth}), {users: 1, copied: 1, claimsFailed: 0});
});
