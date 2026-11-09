import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {createCheckout} from '../lib/paymongoCheckout.js';
import {GUARDIAN_DOCUMENT_VERSIONS} from '../lib/guardianConsent.js';

const db = getFirestore();
const NOW = Date.parse('2026-11-10T10:00:00+08:00');
const terms = GUARDIAN_DOCUMENT_VERSIONS.terms;
const caller = uid => ({uid, token: {firebase: {sign_in_provider: 'google.com'}}});
const consent = (uid, ageGroup) => db.doc(`users/${uid}/server/guardianConsent`).set({status: 'confirmed', ageGroup, decidedAt: NOW});

function deps() {
  const calls = [];
  return {calls, db, origin: 'https://pantas.test', methods: ['card'], allow: async () => true, now: () => NOW,
    client: {getCheckoutSession: async id => ({id, status: 'expired', payments: []}),
      createCheckoutSession: async input => { calls.push(input); return {id: `cs_gc_${calls.length}_${input.uid}`, checkoutUrl: 'https://checkout.paymongo.test/x'}; }}};
}
const reset = async uid => {
  await db.recursiveDelete(db.doc(`users/${uid}`));
};
const product = 'pantas_cs_monthly';

test('a minor without the attestation is refused before anything is written', async () => {
  const uid = 'gc-none'; await reset(uid); await consent(uid, 'minor');
  const d = deps();
  for (const data of [{product}, {product, guardianAttestation: {}}, {product, guardianAttestation: null},
    {product, guardianAttestation: {termsVersion: 5}}]) {
    await assert.rejects(createCheckout(caller(uid), data, d), error => {
      assert.equal(error.code, 'failed-precondition');
      assert.equal(error.message, 'A parent or guardian must confirm this purchase.');
      assert.deepEqual(error.details, {reason: 'guardian-attestation-required'});
      return true;
    });
  }
  assert.equal(d.calls.length, 0);
  assert.equal((await db.collection(`users/${uid}/pendingCheckouts`).get()).size, 0);
  assert.equal((await db.collection('paymongoOrders').where('uid', '==', uid).get()).size, 0);
});

test('a minor with a stale Terms version is refused', async () => {
  const uid = 'gc-stale'; await reset(uid); await consent(uid, 'minor');
  const d = deps();
  await assert.rejects(createCheckout(caller(uid), {product, guardianAttestation: {termsVersion: '2020-01-01'}}, d),
    {code: 'failed-precondition', details: {reason: 'guardian-attestation-required'}});
  assert.equal(d.calls.length, 0);
});

test('a minor with the current Terms version gets a checkout that records the attestation', async () => {
  const uid = 'gc-ok'; await reset(uid); await consent(uid, 'minor');
  const d = deps();
  const result = await createCheckout(caller(uid), {product, guardianAttestation: {termsVersion: terms}}, d);
  const checkout = (await db.doc(`paymongoCheckouts/${result.sessionId}`).get()).data();
  assert.equal(checkout.attestedAt, NOW);
  assert.equal(checkout.termsVersion, terms);
  assert.equal(checkout.reference, result.reference);
  const order = (await db.doc(`paymongoOrders/${result.reference}`).get()).data();
  assert.equal(order.attestedAt, NOW);
  assert.equal(order.termsVersion, terms);
});

test('adults are unaffected and send nothing new', async () => {
  for (const [uid, group] of [['gc-adult-none', null], ['gc-adult-doc', 'adult']]) {
    await reset(uid);
    if (group) await consent(uid, group);
    const d = deps();
    const result = await createCheckout(caller(uid), {product}, d);
    const checkout = (await db.doc(`paymongoCheckouts/${result.sessionId}`).get()).data();
    assert.equal('attestedAt' in checkout, false);
    assert.equal('termsVersion' in checkout, false);
    assert.equal((await db.doc(`paymongoOrders/${result.reference}`).get()).get('attestedAt'), undefined);
  }
});
