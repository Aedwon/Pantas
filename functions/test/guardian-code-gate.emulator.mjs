import {setTestSecrets} from './_secrets-helper.mjs';
import '../lib/index.js';
import assert from 'node:assert/strict';
import test, {beforeEach} from 'node:test';
import {getAuth} from 'firebase-admin/auth';
import {getFirestore} from 'firebase-admin/firestore';
import {checkGuardianCode, consumeGuardianProof, sendGuardianCode} from '../lib/guardianCodeGate.js';

setTestSecrets();
assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const auth = getAuth();
const KEY = 'gate-emulator-key';
const T0 = Date.parse('2026-11-19T10:00:00Z');
const MIN = 60_000;
const HOLDER = 'gate-holder';
const KID_A = 'gate-kid-a';
const KID_B = 'gate-kid-b';
const STRANGER = 'gate-stranger';
const app = {appId: 'app', token: {}, alreadyConsumed: false};
const as = (uid, data) => ({auth: {uid, token: {firebase: {sign_in_provider: 'custom'}}}, app, data});
const rejected = async promise => { try { await promise; return null; } catch (e) { return e; } };

let clock;
let sent;
let n;
let c;
const deps = () => ({db, auth, key: KEY, now: () => clock, allow: async () => true, dailyCap: 100,
  random: () => ++c, proofId: () => String(++n).padStart(32, '0'), mailer: {send: async m => { sent.push(m); }}});

beforeEach(async () => {
  clock = T0; sent = []; n = 0; c = 41;
  await db.recursiveDelete(db.collection('guardianCodes'));
  await db.recursiveDelete(db.collection('guardianCodeProofs'));
  await db.recursiveDelete(db.collection('guardianCodeLimits'));
  await db.recursiveDelete(db.collection('guardianLimits'));
  for (const uid of [HOLDER, KID_A, KID_B, STRANGER]) await db.recursiveDelete(db.doc(`users/${uid}`));
  try { await auth.deleteUser(HOLDER); } catch { /* absent */ }
  await auth.createUser({uid: HOLDER, email: 'maria.gate@example.test', emailVerified: true});
  for (const [uid, nickname] of [[KID_A, 'Ana'], [KID_B, 'Ben']]) {
    await db.doc(`users/${HOLDER}/server/children/items/${uid}`).set(
      {childUid: uid, nickname, active: true, siblingOpenWithoutCode: false, createdAt: T0});
    await db.doc(`users/${uid}/server/childLink`).set({holderUid: HOLDER});
  }
});

test('request, verify and consume run against real Firestore and Auth', async () => {
  const asked = await sendGuardianCode(as(KID_A, {action: 'withdraw', childId: KID_A}), deps());
  assert.equal(asked.maskedEmail, 'm***@e***.test');
  assert.equal(sent.length, 1);
  assert.equal(sent[0].to, 'maria.gate@example.test');
  assert.match(sent[0].text, /confirm withdrawing permission for Ana: 000042\./);
  const stored = (await db.doc(`guardianCodes/${HOLDER}`).get()).data();
  assert.equal(stored.holderUid, HOLDER);
  assert.ok(!JSON.stringify(stored).includes('000042'));
  clock += MIN;
  const {proof} = await checkGuardianCode(as(KID_A, {action: 'withdraw', childId: KID_A, code: '000042'}), deps());
  assert.equal((await db.doc(`guardianCodes/${HOLDER}`).get()).exists, false);
  assert.equal((await rejected(consumeGuardianProof(proof, HOLDER, KID_B, 'withdraw', {db, now: () => clock}))).code, 'permission-denied');
  await consumeGuardianProof(proof, HOLDER, KID_A, 'withdraw', {db, now: () => clock});
  const again = await rejected(consumeGuardianProof(proof, HOLDER, KID_A, 'withdraw', {db, now: () => clock}));
  assert.equal(again.details.reason, 'guardian-proof-invalid');
});

test('switching children cancels the pending code, a stranger is refused, wrong tries run out', async () => {
  await sendGuardianCode(as(KID_A, {action: 'switchInto', childId: KID_B}), deps());
  await sendGuardianCode(as(KID_A, {action: 'switchInto', childId: KID_A}), deps());
  assert.equal(sent.length, 2);
  const old = await rejected(checkGuardianCode(as(KID_A, {action: 'switchInto', childId: KID_B, code: '000042'}), deps()));
  assert.equal(old.details.reason, 'expired');
  assert.equal((await rejected(sendGuardianCode(as(STRANGER, {action: 'switchInto', childId: KID_A}), deps()))).code, 'permission-denied');
  assert.equal((await rejected(checkGuardianCode(as(STRANGER, {action: 'switchInto', childId: KID_A, code: '000043'}), deps()))).code,
    'permission-denied');
  for (let i = 0; i < 5; i += 1) {
    assert.equal((await rejected(checkGuardianCode(as(KID_A, {action: 'switchInto', childId: KID_A, code: '999999'}), deps()))).details.reason, 'wrong');
  }
  assert.equal((await rejected(checkGuardianCode(as(KID_A, {action: 'switchInto', childId: KID_A, code: '000043'}), deps()))).details.reason,
    'tooManyTries');
});

test('the per-holder day limit and the shared guardian day cap hold against real transactions', async () => {
  for (let i = 0; i < 10; i += 1) {
    await sendGuardianCode(as(KID_A, {action: 'delete', childId: KID_A}), deps());
    clock += 61_000;
  }
  const full = await rejected(sendGuardianCode(as(KID_A, {action: 'delete', childId: KID_A}), deps()));
  assert.equal(full.code, 'resource-exhausted');
  assert.equal(full.details.reason, 'guardian-code-daily-limit');
  assert.equal(sent.length, 10);
  assert.equal((await db.doc('guardianLimits/global-2026-11-19').get()).get('count'), 10);
  clock += 24 * 60 * MIN;
  await sendGuardianCode(as(KID_A, {action: 'delete', childId: KID_A}), {...deps(), dailyCap: 100});
  assert.equal(sent.length, 11);
  clock += 61_000;
  const capped = await rejected(sendGuardianCode(as(KID_A, {action: 'delete', childId: KID_A}), {...deps(), dailyCap: 1}));
  assert.equal(capped.details.reason, 'guardian-code-daily-limit');
});

test('a mail failure leaves no pending code and returns the counts', async () => {
  const failing = {...deps(), mailer: {send: async () => { throw new Error('down'); }}};
  const e = await rejected(sendGuardianCode(as(KID_A, {action: 'delete', childId: KID_A}), failing));
  assert.equal(e.code, 'unavailable');
  assert.equal((await db.doc(`guardianCodes/${HOLDER}`).get()).exists, false);
  assert.equal((await db.doc('guardianLimits/global-2026-11-19').get()).get('count'), 0);
  assert.equal((await db.doc(`guardianCodeLimits/${HOLDER}-2026-11-19`).get()).get('count'), 0);
});
