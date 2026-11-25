import '../lib/index.js';
import {getFirestore} from 'firebase-admin/firestore';
import assert from 'node:assert/strict';
import {readdirSync, readFileSync} from 'node:fs';
import test from 'node:test';
import {commitRevenueCatAnswer, copyEntitlementClaims} from '../lib/revenuecatClaims.js';
import {mirrorEntitlementToSync} from '../lib/syncEntitlementMirror.js';
import {changeBetaPro} from '../lib/betaPro.js';
import {refreshRewardClaims} from '../lib/betaReward.js';
import {fakeAuth} from './_paymongo-helpers.mjs';
assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const at = Date.now();
const facts = {appId: 'app-pantas-test', environment: 'production', productIds: ['pantas_pro_monthly'], entitlementIds: ['pro'], expiry: at + 86400000};
const state = (uid) => db.doc(`users/${uid}/sync_state/current`);
async function fresh(uid, withState = true) {
  await db.recursiveDelete(db.doc(`users/${uid}`));
  if (withState) await state(uid).set({activeGenerationId: 'g1', schemaVersion: 1});
}
const plainAuth = () => {
  let current = {};
  return {getUser: async () => ({customClaims: current}), setCustomUserClaims: async (_, v) => { current = v; }, current: () => current};
};

test('a grant writes proUntil and the entitlement version to sync_state, keeping its other fields', async () => {
  const uid = 'mirror-grant'; await fresh(uid);
  await commitRevenueCatAnswer(db, uid, 'g-1', at, {pro: true, proUntil: at + 172800000}, facts);
  await copyEntitlementClaims(db, plainAuth(), uid);
  const data = (await state(uid).get()).data();
  assert.equal(data.proUntil, at + 172800000);
  assert.equal(data.entitlementVersion, 1);
  assert.equal(data.activeGenerationId, 'g1');
});

test('a refund (access ends) sets proUntil to 0', async () => {
  const uid = 'mirror-refund'; await fresh(uid);
  const auth = plainAuth();
  await commitRevenueCatAnswer(db, uid, 'r-1', at, {pro: true, proUntil: at + 172800000}, facts);
  await copyEntitlementClaims(db, auth, uid);
  await commitRevenueCatAnswer(db, uid, 'r-2', at + 1000, {pro: false, proUntil: 0}, facts);
  await copyEntitlementClaims(db, auth, uid);
  const data = (await state(uid).get()).data();
  assert.equal(data.proUntil, 0);
  assert.equal(data.entitlementVersion, 2);
});

test('pro false never leaves a future proUntil on sync_state', async () => {
  const uid = 'mirror-pro-false'; await fresh(uid);
  await commitRevenueCatAnswer(db, uid, 'p-1', at, {pro: false, proUntil: at + 999999}, facts);
  await copyEntitlementClaims(db, plainAuth(), uid);
  assert.equal((await state(uid).get()).get('proUntil'), 0);
});

test('with no sync_state document the mirror does not create one', async () => {
  const uid = 'mirror-absent'; await fresh(uid, false);
  await commitRevenueCatAnswer(db, uid, 'a-1', at, {pro: true, proUntil: at + 172800000}, facts);
  await copyEntitlementClaims(db, plainAuth(), uid);
  assert.equal((await state(uid).get()).exists, false);
});

test('if the mirror write fails the claim copy fails and stays pending for the repair job', async () => {
  const uid = 'mirror-fail'; await fresh(uid);
  await commitRevenueCatAnswer(db, uid, 'f-1', at, {pro: true, proUntil: at + 172800000}, facts);
  const brokenDb = new Proxy(db, {get(target, key) {
    if (key === 'runTransaction') return (run) => target.runTransaction((tx) => run(new Proxy(tx, {get(inner, name) {
      if (name === 'update') return (ref, ...rest) => {
        if (ref.path.endsWith('sync_state/current')) throw new Error('write failed');
        return inner.update(ref, ...rest);
      };
      const member = inner[name]; return typeof member === 'function' ? member.bind(inner) : member;
    }})));
    const value = target[key]; return typeof value === 'function' ? value.bind(target) : value;
  }});
  await assert.rejects(copyEntitlementClaims(brokenDb, plainAuth(), uid), /write failed/);
  assert.equal((await db.doc(`users/${uid}/server/entitlement`).get()).get('claimsPending'), true);
});

test('beta Pro on and off mirror the cutoff and 0', async () => {
  const end = Date.parse('2026-11-23T00:00:00+08:00'), now = end - 60000;
  const uid = 'mirror-beta'; await fresh(uid);
  await db.doc('betaApplications/mirror-beta-application').set({email: 'mirror@example.com', selected: true});
  const caller = {uid, token: {email: 'mirror@example.com', email_verified: true, firebase: {sign_in_provider: 'google.com'}}};
  const deps = {db, auth: fakeAuth(), allow: async () => true, now: () => now, until: () => end};
  const req = (enabled) => ({auth: caller, app: {appId: 'test'}, data: {enabled, examId: 'exam_cse_pro'}});
  await changeBetaPro(req(true), deps);
  assert.equal((await state(uid).get()).get('proUntil'), end);
  await changeBetaPro(req(false), deps);
  assert.equal((await state(uid).get()).get('proUntil'), 0);
});

test('the reward refresh path mirrors through the same copy', async () => {
  const uid = 'mirror-reward'; await fresh(uid);
  const claimed = [];
  const auth = {getUser: async () => ({customClaims: {}}), setCustomUserClaims: async (_, v) => claimed.push(v)};
  await db.doc(`users/${uid}/server/entitlement`).set({pro: true, proUntil: at + 5000, version: 4, claimsVersion: 3, claimsPending: true});
  await refreshRewardClaims(db, auth, uid, at);
  assert.equal((await state(uid).get()).get('proUntil'), at + 5000);
  assert.equal((await state(uid).get()).get('entitlementVersion'), 4);
});

test('a late mirror write with an older version cannot overwrite a newer one', async () => {
  const uid = 'mirror-late'; await fresh(uid);
  await mirrorEntitlementToSync(db, uid, {pro: false, proUntil: 0, version: 5});
  await mirrorEntitlementToSync(db, uid, {pro: true, proUntil: at + 5000, version: 4});
  const data = (await state(uid).get()).data();
  assert.equal(data.proUntil, 0);
  assert.equal(data.entitlementVersion, 5);
});

const activation = (uid) => ({data: {generationId: 'g2', expectedActiveGenerationId: 'g1'},
  auth: {uid, token: {pro: true, proUntil: at + 86400000, firebase: {sign_in_provider: 'google.com'}}}, app: {appId: 'test'}});
const withGeneration = async (uid, entitlement) => {
  await fresh(uid);
  await db.doc(`users/${uid}/sync_generations/g1`).set({status: 'active'});
  await db.doc(`users/${uid}/sync_generations/g2`).set({status: 'staging'});
  if (entitlement) await db.doc(`users/${uid}/server/entitlement`).set(entitlement);
};

test('activation writes the mirror from the server entitlement', async () => {
  const uid = 'mirror-activate'; await withGeneration(uid, {pro: true, proUntil: at + 5000, version: 7});
  const {activateSyncGeneration} = await import('../lib/index.js');
  await activateSyncGeneration.run(activation(uid));
  const data = (await state(uid).get()).data();
  assert.equal(data.activeGenerationId, 'g2');
  assert.equal(data.proUntil, at + 5000);
  assert.equal(data.entitlementVersion, 7);
});

test('activation is refused when the server entitlement is no longer Pro, even with an old Pro token', async () => {
  const uid = 'mirror-activate-refund'; await withGeneration(uid, {pro: false, proUntil: 0, version: 8});
  const {activateSyncGeneration} = await import('../lib/index.js');
  await assert.rejects(activateSyncGeneration.run(activation(uid)), {code: 'permission-denied'});
  assert.equal((await state(uid).get()).get('activeGenerationId'), 'g1');
});

test('activation keeps a newer mirror already written', async () => {
  const uid = 'mirror-activate-newer'; await withGeneration(uid, {pro: true, proUntil: at + 5000, version: 7});
  await state(uid).update({proUntil: at + 9000, entitlementVersion: 9});
  const {activateSyncGeneration} = await import('../lib/index.js');
  await activateSyncGeneration.run(activation(uid));
  assert.equal((await state(uid).get()).get('entitlementVersion'), 9);
  assert.equal((await state(uid).get()).get('proUntil'), at + 9000);
});

test('activating a generation keeps the pause and the mirrored entitlement', async () => {
  const src = readFileSync(new URL('../src/activateSyncGeneration.ts', import.meta.url), 'utf8');
  assert.match(src, /transaction\.set\(currentRef,[\s\S]*?\{\s*merge:\s*true\s*\}\s*\)/);
});

test('setCustomUserClaims is called only inside copyEntitlementClaims, so no path can skip the mirror', () => {
  const offenders = readdirSync(new URL('../src/', import.meta.url))
    .filter((name) => name.endsWith('.ts') && name !== 'revenuecatClaims.ts')
    .filter((name) => /\.setCustomUserClaims\(/.test(readFileSync(new URL(`../src/${name}`, import.meta.url), 'utf8')));
  assert.deepEqual(offenders, []);
});
