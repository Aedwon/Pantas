import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {answerRequest, getStatus, readRequest, sendLink, GUARDIAN_WINDOW_MS, SEND_LIMIT, deleteGuardianRecords} from '../lib/guardianConsent.js';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const KEY = 'guardian-test-key';
const T0 = Date.parse('2026-11-02T10:00:00+08:00');
const DAY = 86400000;
const anon = uid => ({uid, token: {firebase: {sign_in_provider: 'anonymous'}}});
const app = {appId: 'app', token: {}, alreadyConsumed: false};
const req = (uid, data, extra = {}) => ({auth: anon(uid), app, data, ...extra});
const code = async promise => { try { await promise; return 'ok'; } catch (e) { assert.equal(typeof e.code, 'string', String(e)); return e.code; } };

function harness({now = T0} = {}) {
  const sent = [];
  let clock = now;
  let n = 0;
  return {
    sent, advance: ms => { clock += ms; },
    deps: {db, key: KEY, linkOrigin: 'https://app.example.test/', now: () => clock,
      token: () => (++n).toString(16).padStart(64, '0'),
      allow: async () => true,
      mailer: {send: async m => { sent.push(m); }}},
  };
}
const body = (over = {}) => ({guardianName: 'Maria', guardianEmail: 'Maria@Gmail.com', studentName: 'Juan', ...over});
const reset = async uid => {
  await db.recursiveDelete(db.doc(`users/${uid}`));
  await db.recursiveDelete(db.collection('guardianLimits'));
};
const tokenOf = m => /token=([a-f0-9]{64})/.exec(m.text)[1];
const stored = uid => db.doc(`users/${uid}/server/guardianConsent`).get().then(s => s.data());

test('a send stores hashes only, masks the address and mails a one-use link', async () => {
  const uid = 'g-send'; await reset(uid);
  const h = harness();
  const res = await sendLink(req(uid, body()), h.deps);
  assert.equal(res.maskedEmail, 'm***@g***.com');
  assert.equal(res.expiresAt, T0 + GUARDIAN_WINDOW_MS);
  assert.equal(h.sent.length, 1);
  assert.equal(h.sent[0].to, 'maria@gmail.com');
  const token = tokenOf(h.sent[0]);
  assert.ok(h.sent[0].text.includes(`https://app.example.test/guardian?token=${token}`));
  const doc = await stored(uid);
  assert.equal(doc.status, 'pending');
  assert.equal(doc.ageGroup, 'minor');
  const raw = JSON.stringify(doc);
  assert.ok(!raw.includes(token), 'token is not stored');
  assert.ok(!raw.toLowerCase().includes('maria@gmail.com'), 'email is not stored');
  assert.ok(!raw.includes('Maria'), 'guardian name is not stored');
  assert.match(doc.emailHash, /^[a-f0-9]{64}$/);
  assert.match(doc.tokenHash, /^[a-f0-9]{64}$/);
  const row = (await db.doc(`guardianTokens/${doc.tokenHash}`).get()).data();
  assert.deepEqual({uid: row.uid, state: row.state, expiresAt: row.expiresAt}, {uid, state: 'open', expiresAt: T0 + GUARDIAN_WINDOW_MS});
});

test('opening the link does not confirm; confirming needs the agreement box and works once', async () => {
  const uid = 'g-confirm'; await reset(uid);
  const h = harness();
  await sendLink(req(uid, body()), h.deps);
  const token = tokenOf(h.sent[0]);
  const guardian = 'g-visitor';
  assert.deepEqual(await readRequest(req(guardian, {token}), h.deps), {state: 'open', studentName: 'Juan', expiresAt: T0 + GUARDIAN_WINDOW_MS});
  await readRequest(req(guardian, {token}), h.deps);
  assert.equal((await stored(uid)).status, 'pending', 'reading never confirms');
  assert.equal(await code(answerRequest(req(guardian, {token, decision: 'confirm', agreed: false}), h.deps)), 'failed-precondition');
  assert.equal(await code(answerRequest(req(guardian, {token, decision: 'confirm'}), h.deps)), 'failed-precondition');
  assert.equal((await stored(uid)).status, 'pending');
  assert.deepEqual(await answerRequest(req(guardian, {token, decision: 'confirm', agreed: true}), h.deps), {state: 'confirmed'});
  assert.equal((await stored(uid)).status, 'confirmed');
  assert.deepEqual(await answerRequest(req(guardian, {token, decision: 'confirm', agreed: true}), h.deps), {state: 'used'});
  assert.deepEqual(await readRequest(req(guardian, {token}), h.deps), {state: 'used'});
  assert.equal((await getStatus(req(uid, {}), h.deps)).status, 'confirmed');
});

test('declining keeps the student waiting, and a new email replaces the old link', async () => {
  const uid = 'g-decline'; await reset(uid);
  const h = harness();
  await sendLink(req(uid, body()), h.deps);
  const first = tokenOf(h.sent[0]);
  assert.deepEqual(await answerRequest(req('v', {token: first, decision: 'decline'}), h.deps), {state: 'declined'});
  assert.equal((await getStatus(req(uid, {}), h.deps)).status, 'declined');
  h.advance(SEND_LIMIT.gapMs + 1);
  await sendLink(req(uid, body({guardianEmail: 'other@mail.com'})), h.deps);
  assert.equal((await getStatus(req(uid, {}), h.deps)).status, 'pending');
  assert.equal((await getStatus(req(uid, {}), h.deps)).maskedEmail, 'o***@m***.com');
  const second = tokenOf(h.sent[1]);
  assert.notEqual(first, second);
  assert.deepEqual(await answerRequest(req('v', {token: first, decision: 'confirm', agreed: true}), h.deps), {state: 'unknown'});
  assert.equal((await stored(uid)).status, 'pending', 'the old link cannot confirm');
  assert.deepEqual(await answerRequest(req('v', {token: second, decision: 'confirm', agreed: true}), h.deps), {state: 'confirmed'});
});

test('a resend revokes the earlier link', async () => {
  const uid = 'g-resend'; await reset(uid);
  const h = harness();
  await sendLink(req(uid, body()), h.deps);
  h.advance(SEND_LIMIT.gapMs + 1);
  await sendLink(req(uid, body()), h.deps);
  const [a, b] = h.sent.map(tokenOf);
  assert.deepEqual(await readRequest(req('v', {token: a}), h.deps), {state: 'unknown'});
  assert.equal((await readRequest(req('v', {token: b}), h.deps)).state, 'open');
});

test('an expired link cannot be read or confirmed, and the status says expired', async () => {
  const uid = 'g-expire'; await reset(uid);
  const h = harness();
  await sendLink(req(uid, body()), h.deps);
  const token = tokenOf(h.sent[0]);
  h.advance(GUARDIAN_WINDOW_MS - 1);
  assert.equal((await readRequest(req('v', {token}), h.deps)).state, 'open');
  h.advance(1);
  assert.deepEqual(await readRequest(req('v', {token}), h.deps), {state: 'expired'});
  assert.deepEqual(await answerRequest(req('v', {token, decision: 'confirm', agreed: true}), h.deps), {state: 'expired'});
  assert.equal((await getStatus(req(uid, {}), h.deps)).status, 'expired');
  assert.equal((await stored(uid)).status, 'pending', 'expiry is computed, not trusted from a write');
});

test('sends are rate limited per student, per gap and per guardian address', async () => {
  const uid = 'g-limit'; await reset(uid);
  const h = harness();
  await sendLink(req(uid, body()), h.deps);
  assert.equal(await code(sendLink(req(uid, body()), h.deps)), 'resource-exhausted', 'gap');
  h.advance(SEND_LIMIT.gapMs + 1);
  await sendLink(req(uid, body()), h.deps);
  h.advance(SEND_LIMIT.gapMs + 1);
  await sendLink(req(uid, body()), h.deps);
  h.advance(SEND_LIMIT.gapMs + 1);
  assert.equal(await code(sendLink(req(uid, body()), h.deps)), 'resource-exhausted', 'same address, fourth send in a day');
  h.advance(DAY);
  assert.equal(await code(sendLink(req(uid, body()), h.deps)), 'ok', 'a new day opens the window');
  const denied = {...h.deps, allow: async () => false};
  await reset('g-limit2');
  assert.equal(await code(sendLink(req('g-limit2', body()), denied)), 'resource-exhausted', 'per-student limiter');
  assert.equal(await code(getStatus(req('g-limit2', {}), denied)), 'resource-exhausted');
  assert.equal(await code(readRequest(req('g-limit2', {token: 'a'.repeat(64)}), denied)), 'resource-exhausted');
});

test('bad input, no App Check and no sign-in are refused; a confirmed student cannot send again', async () => {
  const uid = 'g-input'; await reset(uid);
  const h = harness();
  for (const bad of [body({guardianEmail: 'nope'}), body({guardianName: ''}), body({guardianName: 'x'.repeat(61)}), body({studentName: 'a\nb'}), {}]) {
    assert.equal(await code(sendLink(req(uid, bad), h.deps)), 'invalid-argument');
  }
  assert.equal(await code(sendLink({auth: anon(uid), data: body()}, h.deps)), 'unauthenticated');
  assert.equal(await code(sendLink({app, data: body()}, h.deps)), 'unauthenticated');
  assert.equal(await code(sendLink({auth: anon(uid), app: {...app, alreadyConsumed: true}, data: body()}, h.deps)), 'unauthenticated');
  assert.equal(await code(sendLink(req(uid, body(), {auth: {uid, token: {email: 'maria@gmail.com', firebase: {sign_in_provider: 'google.com'}}}}), h.deps)), 'invalid-argument', 'own email');
  assert.equal(h.sent.length, 0);
  await sendLink(req(uid, body()), h.deps);
  const token = tokenOf(h.sent[0]);
  await answerRequest(req('v', {token, decision: 'confirm', agreed: true}), h.deps);
  h.advance(SEND_LIMIT.gapMs + 1);
  assert.equal(await code(sendLink(req(uid, body()), h.deps)), 'failed-precondition');
});

test('unknown and malformed tokens reveal nothing', async () => {
  const h = harness();
  for (const token of [undefined, '', 'short', 'z'.repeat(64), 'a'.repeat(64), 5]) {
    assert.deepEqual(await readRequest(req('v', {token}), h.deps), {state: 'unknown'});
    assert.deepEqual(await answerRequest(req('v', {token, decision: 'decline'}), h.deps), {state: 'unknown'});
  }
  assert.equal(await code(answerRequest(req('v', {token: 'a'.repeat(64), decision: 'maybe'}), h.deps)), 'invalid-argument');
});

test('a failed mail leaves the student able to retry and reports it', async () => {
  const uid = 'g-mailfail'; await reset(uid);
  const h = harness();
  const failing = {...h.deps, mailer: {send: async () => { throw new Error('provider down'); }}};
  assert.equal(await code(sendLink(req(uid, body()), failing)), 'unavailable');
  h.advance(SEND_LIMIT.gapMs + 1);
  assert.equal(await code(sendLink(req(uid, body()), h.deps)), 'ok');
});

test('deleting the account removes the link record', async () => {
  const uid = 'g-delete'; await reset(uid);
  const h = harness();
  await sendLink(req(uid, body()), h.deps);
  const {tokenHash} = await stored(uid);
  await deleteGuardianRecords(db, uid);
  assert.equal((await db.doc(`guardianTokens/${tokenHash}`).get()).exists, false);
  await deleteGuardianRecords(db, 'g-never');
});
