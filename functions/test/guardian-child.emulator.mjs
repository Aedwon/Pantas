import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import * as guardian from '../lib/guardianConsent.js';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const KEY = 'guardian-child-key';
const T0 = Date.parse('2026-11-19T10:00:00+08:00');
const anon = uid => ({uid, token: {firebase: {sign_in_provider: 'anonymous'}}});
const app = {appId: 'app', token: {}, alreadyConsumed: false};
const req = (uid, data) => ({auth: anon(uid), app, data, rawRequest: {ip: '10.9.9.9'}});
const code = async promise => { try { await promise; return 'ok'; } catch (e) { assert.equal(typeof e.code, 'string', String(e)); return e.code; } };
const stored = uid => db.doc(`users/${uid}/server/guardianConsent`).get().then(s => s.data());
const sent = [];
const deps = {db, key: KEY, linkOrigin: 'https://app.example.test/', now: () => T0, allow: async () => true,
  mailer: {send: async m => { sent.push(m); }}};
const reset = async uid => { await db.recursiveDelete(db.doc(`users/${uid}`)); await db.recursiveDelete(db.collection('guardianLimits')); };
const record = async (uid, data) => { await reset(uid); await db.doc(`users/${uid}/server/guardianConsent`).set(data); };

test('getStatus reports child, and treats an unknown or missing group on an existing record as minor', async () => {
  await record('gch-status-child', {status: 'confirmed', ageGroup: 'child', decidedAt: T0});
  assert.equal((await guardian.getStatus(req('gch-status-child', {}), deps)).ageGroup, 'child');
  await record('gch-status-unknown', {status: 'confirmed', ageGroup: 'teen', decidedAt: T0});
  assert.equal((await guardian.getStatus(req('gch-status-unknown', {}), deps)).ageGroup, 'minor');
  await record('gch-status-blank', {status: 'confirmed', decidedAt: T0});
  assert.equal((await guardian.getStatus(req('gch-status-blank', {}), deps)).ageGroup, 'minor');
  await record('gch-status-adult', {ageGroup: 'adult'});
  assert.equal((await guardian.getStatus(req('gch-status-adult', {}), deps)).ageGroup, 'adult');
  await reset('gch-status-none');
  assert.equal((await guardian.getStatus(req('gch-status-none', {}), deps)).ageGroup, null);
});

test('sendLink refuses a child or unknown group: the emailed teen link never applies, and nothing is written or mailed', async () => {
  for (const [uid, ageGroup] of [['gch-send-child', 'child'], ['gch-send-unknown', 'teen']]) {
    const before = {status: 'confirmed', ageGroup, decidedAt: T0};
    await record(uid, before);
    sent.length = 0;
    const result = await code(guardian.sendLink(req(uid, {guardianName: 'Maria', guardianEmail: 'maria@gmail.com'}), deps));
    assert.equal(result, 'failed-precondition', uid);
    assert.deepEqual(await stored(uid), before, uid);
    assert.equal(sent.length, 0, uid);
  }
});

test('sendLink also refuses a pending-style child record', async () => {
  const before = {status: 'pending', ageGroup: 'child', expiresAt: T0 + 1000};
  await record('gch-send-child-pending', before);
  assert.equal(await code(guardian.sendLink(req('gch-send-child-pending',
    {guardianName: 'Maria', guardianEmail: 'maria@gmail.com'}), deps)), 'failed-precondition');
  assert.deepEqual(await stored('gch-send-child-pending'), before);
});

test('markAdult never flips a child or unknown group to adult', async () => {
  for (const [uid, ageGroup] of [['gch-adult-child', 'child'], ['gch-adult-unknown', 'teen']]) {
    const before = {status: 'confirmed', ageGroup, decidedAt: T0};
    await record(uid, before);
    assert.equal(await code(guardian.markAdult(req(uid, {}), deps)), 'failed-precondition', uid);
    assert.deepEqual(await stored(uid), before, uid);
  }
});

test('a manage link on a child or unknown record reads as unknown; a minor still reads as active', async () => {
  const token = 'c'.repeat(64);
  const hash = guardian.hashValue(KEY, 'token', token);
  for (const [uid, ageGroup] of [['gch-manage-child', 'child'], ['gch-manage-unknown', 'teen']]) {
    await record(uid, {status: 'confirmed', ageGroup, decidedAt: T0, sharingAllowed: true});
    await db.doc(`guardianTokens/${hash}`).set({kind: 'manage', uid, state: 'open', createdAt: T0});
    assert.deepEqual(await guardian.readManage(req('visitor', {token}), deps), {state: 'unknown'}, uid);
  }
  await record('gch-manage-minor', {status: 'confirmed', ageGroup: 'minor', decidedAt: T0, sharingAllowed: true});
  await db.doc(`guardianTokens/${hash}`).set({kind: 'manage', uid: 'gch-manage-minor', state: 'open', createdAt: T0});
  assert.equal((await guardian.readManage(req('visitor', {token}), deps)).state, 'active');
});
