import * as endpoints from '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getAuth} from 'firebase-admin/auth';
import {getFirestore} from 'firebase-admin/firestore';

const db = getFirestore();
const auth = getAuth();
const holder = 'actions-holder';
const first = 'actions-child-one';
const second = 'actions-child-two';
const last = 'actions-child-three';
const token = (uid, ageGroup = 'adult') => ({uid, token: {ageGroup, auth_time: 1,
  firebase: {sign_in_provider: ageGroup === 'child' ? 'custom' : 'google.com'}}});
const call = (name, uid, data = {}, ageGroup) => endpoints[name]?.run({auth: token(uid, ageGroup), app: {}, data});
const proof = async (childId, action, serial) => {
  const id = serial.toString(16).padStart(32, '0');
  await db.doc(`guardianCodeProofs/${id}`).set({holderUid: holder, childId, action,
    expiresAt: new Date(Date.now() + 60_000)});
  return id;
};

test('holder study callables refuse study while child management stays available', async () => {
  await auth.createUser({uid: holder, email: 'actions@example.test', emailVerified: true});
  await db.doc(`users/${holder}/server/holder`).set({});
  for (const childId of [first, second, last]) {
    await auth.createUser({uid: childId});
    await db.doc(`users/${childId}/server/childLink`).set({holderUid: holder});
    await db.doc(`users/${childId}/server/guardianConsent`).set({ageGroup: 'child'});
    await db.doc(`users/${holder}/server/children/items/${childId}`).set({active: true, nickname: 'Kid'});
  }
  for (const name of ['ingestSession', 'startMock', 'submitMock', 'controlMock', 'setExamSettings',
    'recordLessonRead', 'recordSetupAcceptance', 'startWebTrial', 'getSessionDiagnosis', 'reportUsageVisit']) {
    await assert.rejects(call(name, holder), {details: {reason: 'holder-cannot-study'}}, name);
  }
  await call('listChildren', holder);
});

test('sibling access requires the matching proof to turn on and turns off without proof', async () => {
  assert.ok(endpoints.setSiblingOpen);
  const guardianProofId = await proof(first, 'siblingOptIn', 1);
  await assert.rejects(call('setSiblingOpen', holder, {childId: last, open: true, guardianProofId}),
    {details: {reason: 'guardian-proof-invalid'}});
  await call('setSiblingOpen', holder, {childId: first, open: true, guardianProofId});
  const entry = db.doc(`users/${holder}/server/children/items/${first}`);
  assert.equal((await entry.get()).get('siblingOpenWithoutCode'), true);
  assert.equal((await entry.get()).get('siblingNoticeVersion'), '2026-11-20');
  assert.equal(typeof (await entry.get()).get('siblingAccessChangedAt'), 'number');
  await call('setSiblingOpen', holder, {childId: first, open: false});
  assert.equal((await entry.get()).get('siblingOpenWithoutCode'), false);
  await assert.rejects(call('setSiblingOpen', holder, {childId: first, open: true, guardianProofId}),
    {details: {reason: 'guardian-proof-invalid'}});
});

test('withdraw closes only its child and proven deletion closes the final child and holder', async () => {
  await assert.rejects(call('deleteAccount', first, {}, 'child'),
    {details: {reason: 'guardian-proof-invalid'}});
  assert.ok(endpoints.withdrawChild);
  const sample = db.doc(`users/${first}/sessions/synthetic`);
  await sample.set({points: 1});
  const evidence = db.doc(`guardianConsentEvidence/${first}/responses/synthetic`);
  await evidence.set({decidedAt: 1, action: 'child_setup'});
  await call('withdrawChild', holder, {childId: first, guardianProofId: await proof(first, 'withdraw', 2)});
  await assert.rejects(auth.getUser(first), {code: 'auth/user-not-found'});
  assert.equal((await db.doc(`users/${holder}/server/children/items/${first}`).get()).exists, false);
  assert.equal((await db.doc(`users/${first}/server/childLink`).get()).exists, false);
  assert.equal((await sample.get()).exists, false);
  assert.equal((await evidence.get()).exists, true);
  assert.equal((await evidence.parent.parent.get()).get('reason'), 'guardian_withdrawal');
  const secondProof = await proof(second, 'delete', 4);
  await assert.rejects(call('deleteChild', 'actions-unrelated', {childId: second, guardianProofId: secondProof}),
    {details: {reason: 'not-linked'}});
  await call('deleteChild', holder, {childId: second, guardianProofId: secondProof});
  await assert.rejects(auth.getUser(second), {code: 'auth/user-not-found'});
  await auth.getUser(holder);
  await call('deleteAccount', last, {guardianProofId: await proof(last, 'delete', 3)}, 'child');
  await assert.rejects(auth.getUser(last), {code: 'auth/user-not-found'});
  await assert.rejects(auth.getUser(holder), {code: 'auth/user-not-found'});
});
