import {setTestSecrets} from './_secrets-helper.mjs';
import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getAuth} from 'firebase-admin/auth';
import {getFirestore} from 'firebase-admin/firestore';
import {runOrphanAnonCleanup} from '../lib/cleanupOrphanAnons.js';
import {deleteUserData} from '../lib/deleteUserData.js';
import {purgeGuardianRecords} from '../lib/guardianConsent.js';
import {startTrial, trialEligible} from '../lib/webTrial.js';

// Local emulator fixture only.
setTestSecrets({TRIAL_IDENTITY_HMAC_KEY: 'emailless-child-emulator-only-hmac-key'});

const db = getFirestore();
const DAY = 86400000;
const entry = childUid => ({childUid, nickname: 'Kid', active: true, siblingOpenWithoutCode: false, createdAt: 1});
async function link(holder, child, active = true) {
  await db.doc(`users/${child}/server/childLink`).set({holderUid: holder});
  await db.doc(`users/${holder}/server/children/items/${child}`).set({...entry(child), active});
}

test('orphan cleanup keeps a linked child older than 30 days and still removes a real orphan', async () => {
  const old = new Date(Date.now() - 90 * DAY).toISOString();
  const uids = ['e13-linked', 'e13-unlinked', 'e13-orphan'];
  const imported = await getAuth().importUsers(uids.map(uid => ({uid, metadata: {creationTime: old, lastSignInTime: old}})));
  assert.equal(imported.failureCount, 0);
  await link('e13-orphan-holder', 'e13-linked');
  await link('e13-orphan-holder', 'e13-unlinked', false);
  await runOrphanAnonCleanup({auth: getAuth(), db});
  assert.equal((await getAuth().getUser('e13-linked')).uid, 'e13-linked');
  assert.equal((await db.doc('users/e13-linked/server/childLink').get()).exists, true);
  for (const uid of ['e13-unlinked', 'e13-orphan']) {
    await assert.rejects(getAuth().getUser(uid), {code: 'auth/user-not-found'}, uid);
  }
  await getAuth().deleteUser('e13-linked');
  await db.recursiveDelete(db.doc('users/e13-linked'));
  await db.recursiveDelete(db.doc('users/e13-orphan-holder'));
});

// ---- web trial and deletion: one trial per parent email -----------------------------------------

const records = {
  'e13-h': {uid: 'e13-h', email: 'Parent@Example.test', emailVerified: true,
    providerData: [{providerId: 'google.com', uid: 'e13-h-sub'}], customClaims: {}},
};
const adminAuth = {
  deleted: [],
  getUser: async uid => records[uid] ?? {uid, emailVerified: false, providerData: [], customClaims: {}},
  setCustomUserClaims: async () => {},
  deleteUser: async function (uid) { this.deleted.push(uid); },
};
const child = uid => ({uid, token: {firebase: {sign_in_provider: 'custom'}}});
const holderToken = {uid: 'e13-h', token: {email: 'parent@example.test', email_verified: true,
  firebase: {sign_in_provider: 'google.com', identities: {'google.com': ['e13-h-sub']}}}};
const deps = {db, auth: adminAuth, allow: async () => true, now: () => Date.parse('2026-12-01T00:00:00Z')};

test('a second child of the same holder is not eligible once the first child used the trial', async () => {
  await link('e13-h', 'e13-c1');
  await link('e13-h', 'e13-c2');
  assert.equal(await trialEligible(child('e13-c1'), db, adminAuth), true);
  await startTrial(child('e13-c1'), deps);
  assert.equal(await trialEligible(child('e13-c1'), db, adminAuth), false);
  assert.equal(await trialEligible(child('e13-c2'), db, adminAuth), false);
  await assert.rejects(startTrial(child('e13-c2'), deps), {code: 'failed-precondition'});
  // The holder's own sign-in shares the same email and provider markers.
  assert.equal(await trialEligible(holderToken, db), false);
});

test('a child is not eligible when its holder already used the trial', async () => {
  records['e13-h2'] = {uid: 'e13-h2', email: 'second.parent@example.test', emailVerified: true, providerData: [], customClaims: {}};
  await link('e13-h2', 'e13-c3');
  const holder = {uid: 'e13-h2', token: {email: 'second.parent@example.test', email_verified: true,
    firebase: {sign_in_provider: 'custom'}}};
  await startTrial(holder, deps);
  assert.equal(await trialEligible(child('e13-c3'), db, adminAuth), false);
  await assert.rejects(startTrial(child('e13-c3'), deps), {code: 'failed-precondition'});
});

test('an unlinked emailless user is refused, not given a trial', async () => {
  await assert.rejects(trialEligible(child('e13-nobody'), db, adminAuth), {code: 'failed-precondition'});
});

test('deleting a child with a trial record does not throw, with or without the request token', async () => {
  await deleteUserData(db, adminAuth, 'e13-c1', 'user_request', {requestAuth: child('e13-c1'), now: () => 1});
  assert.ok(adminAuth.deleted.includes('e13-c1'));
  assert.equal((await db.doc('users/e13-c1/server/trial').get()).exists, false);
  // The trial it used still blocks the sibling.
  assert.equal(await trialEligible(child('e13-c2'), db, adminAuth), false);
  await db.doc('users/e13-c2/server/trial').set({usedAt: 1, grantId: 'trial'});
  await deleteUserData(db, adminAuth, 'e13-c2', 'inactive_24_months', {now: () => 1});
  assert.ok(adminAuth.deleted.includes('e13-c2'));
});

// ---- retention for the code-gate rows -----------------------------------------------------------

test('the existing hourly guardian purge removes expired code-gate rows and keeps live ones', async () => {
  const now = Date.parse('2026-12-01T00:00:00Z');
  const past = new Date(now - 1000);
  const future = new Date(now + DAY);
  const rows = {
    'guardianCodes/e13-old': {purgeAt: past}, 'guardianCodes/e13-live': {purgeAt: future},
    'guardianCodeLimits/e13-old-2026-11-30': {count: 1, purgeAt: past}, 'guardianCodeLimits/e13-live-2026-12-01': {count: 1, purgeAt: future},
    'guardianCodeProofs/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa': {purgeAt: past},
    'guardianCodeProofs/bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb': {purgeAt: future},
  };
  for (const [path, data] of Object.entries(rows)) await db.doc(path).set(data);
  await purgeGuardianRecords(db, now);
  for (const [path, data] of Object.entries(rows)) {
    assert.equal((await db.doc(path).get()).exists, data.purgeAt === future, path);
    await db.doc(path).delete();
  }
});
