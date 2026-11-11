import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {listPlans} from '../lib/webPlans.js';
import './_paymongo-helpers.mjs';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const catalog = [{id: 'exam_cse_pro', publishedSittings: [{firstDay: '2027-03-14', lastDay: '2027-03-14', sourceUrl: 'https://x.test'}]}];
const code = async promise => {try {await promise; return 'ok';} catch (e) {return e.code;}};

test('the real per-account limit allows 30 lists in the window, then refuses, per account', async () => {
  await db.recursiveDelete(db.doc('users/pl-a'));
  await db.recursiveDelete(db.doc('users/pl-b'));
  const deps = {catalog, now: () => Date.parse('2026-10-20T10:00:00+08:00')};
  for (let i = 0; i < 30; i++) assert.equal(await code(listPlans({uid: 'pl-a', token: {firebase: {sign_in_provider: 'google.com', identities: {'google.com': ['plans-provider']}}}}, deps)), 'ok', `call ${i + 1}`);
  assert.equal(await code(listPlans({uid: 'pl-a', token: {firebase: {sign_in_provider: 'google.com', identities: {'google.com': ['plans-provider']}}}}, deps)), 'resource-exhausted');
  assert.equal(await code(listPlans({uid: 'pl-b', token: {firebase: {sign_in_provider: 'google.com', identities: {'google.com': ['plans-provider']}}}}, deps)), 'ok');
});
