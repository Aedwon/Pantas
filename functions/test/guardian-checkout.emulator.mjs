import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {createCheckout, CHECKOUT_DECLARATION_WORDING} from '../lib/paymongoCheckout.js';
import {GUARDIAN_DOCUMENT_VERSIONS} from '../lib/guardianConsent.js';
import {adult, guardian} from './_declaration.mjs';

const db = getFirestore();
const NOW = Date.parse('2026-11-10T10:00:00+08:00');
const terms = GUARDIAN_DOCUMENT_VERSIONS.terms;
const caller = uid => ({uid, token: {firebase: {sign_in_provider: 'google.com'}}});
const consent = (uid, ageGroup, status = 'confirmed') =>
  db.doc(`users/${uid}/server/guardianConsent`).set({status, ageGroup, decidedAt: NOW});

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
const refused = async (uid, data, d, kind) => {
  await assert.rejects(createCheckout(caller(uid), data, d), error => {
    assert.equal(error.code, 'failed-precondition');
    assert.deepEqual(error.details, {reason: 'declaration-required', kind});
    return true;
  });
};
const nothingWritten = async (uid, d) => {
  assert.equal(d.calls.length, 0);
  assert.equal((await db.collection(`users/${uid}/pendingCheckouts`).get()).size, 0);
  assert.equal((await db.collection('paymongoOrders').where('uid', '==', uid).get()).size, 0);
};

test('the wording version ids are fixed per kind', () => {
  assert.deepEqual(CHECKOUT_DECLARATION_WORDING, {adult: 'checkout-adult-2026-11-23', guardian: 'checkout-guardian-2026-11-23'});
});

test('an adult checkout without a valid declaration is refused before anything is written', async () => {
  for (const [uid, group] of [['gc-adult-none', null], ['gc-adult-doc', 'adult']]) {
    await reset(uid);
    if (group) await consent(uid, group);
    const d = deps();
    for (const data of [{product}, {product, declaration: null}, {product, declaration: {}}, {product, declaration: 'adult'},
      {product, declaration: {...adult, kind: 'guardian'}},
      {product, declaration: {...adult, wordingVersion: 'checkout-adult-2020-01-01'}},
      {product, declaration: {...adult, wordingVersion: CHECKOUT_DECLARATION_WORDING.guardian}},
      {product, declaration: {...adult, termsVersion: '2020-01-01'}},
      {product, declaration: {...adult, termsVersion: 5}},
      {product, guardianAttestation: {termsVersion: terms}}]) {
      await refused(uid, data, d, 'adult');
    }
    await nothingWritten(uid, d);
  }
});

test('an adult declaration is recorded on the order and the checkout with kind, wording, Terms, time and product', async () => {
  const uid = 'gc-adult-ok'; await reset(uid);
  const d = deps();
  const result = await createCheckout(caller(uid), {product, declaration: adult}, d);
  const want = {kind: 'adult', wordingVersion: 'checkout-adult-2026-11-23', termsVersion: terms, at: NOW};
  const checkout = (await db.doc(`paymongoCheckouts/${result.sessionId}`).get()).data();
  assert.deepEqual(checkout.declaration, want);
  assert.equal(checkout.product, product);
  assert.equal('attestedAt' in checkout, false);
  const order = (await db.doc(`paymongoOrders/${result.reference}`).get()).data();
  assert.deepEqual(order.declaration, want);
  assert.equal(order.product, product);
});

test('the under-18 flag alone no longer asks for a guardian: no confirmed guardian means the adult declaration', async () => {
  for (const [uid, status] of [['gc-flag-pending', 'pending'], ['gc-flag-declined', 'declined'], ['gc-flag-withdrawn', 'withdrawn'], ['gc-flag-only', undefined]]) {
    await reset(uid);
    await db.doc(`users/${uid}/server/guardianConsent`).set({ageGroup: 'minor', ...(status ? {status} : {})});
    const d = deps();
    await refused(uid, {product, declaration: guardian}, d, 'adult');
    const result = await createCheckout(caller(uid), {product, declaration: adult}, d);
    assert.equal((await db.doc(`paymongoOrders/${result.reference}`).get()).get('declaration.kind'), 'adult');
  }
});

test('an account with a confirmed guardian needs the guardian declaration, and an adult one is refused', async () => {
  const uid = 'gc-guardian'; await reset(uid); await consent(uid, 'minor');
  const d = deps();
  for (const data of [{product}, {product, declaration: adult}, {product, declaration: {...guardian, wordingVersion: 'x'}},
    {product, declaration: {...guardian, termsVersion: '2020-01-01'}}, {product, guardianAttestation: {termsVersion: terms}}]) {
    await refused(uid, data, d, 'guardian');
  }
  await nothingWritten(uid, d);
  const result = await createCheckout(caller(uid), {product, declaration: guardian}, d);
  const want = {kind: 'guardian', wordingVersion: 'checkout-guardian-2026-11-23', termsVersion: terms, at: NOW};
  assert.deepEqual((await db.doc(`paymongoCheckouts/${result.sessionId}`).get()).get('declaration'), want);
  assert.deepEqual((await db.doc(`paymongoOrders/${result.reference}`).get()).get('declaration'), want);
});

test('a confirmed record that became adult is an adult account', async () => {
  const uid = 'gc-became-adult'; await reset(uid); await consent(uid, 'adult');
  const d = deps();
  await refused(uid, {product, declaration: guardian}, d, 'adult');
  await createCheckout(caller(uid), {product, declaration: adult}, d);
});

test('reusing an open checkout writes the current declaration to both records', async () => {
  for (const [uid, kind, decl] of [['gc-reuse-adult', 'adult', adult], ['gc-reuse', 'guardian', guardian]]) {
    await reset(uid);
    if (kind === 'guardian') await consent(uid, 'minor');
    const d = deps();
    d.client.getCheckoutSession = async id => ({id, status: 'active', payments: []});
    const first = await createCheckout(caller(uid), {product, declaration: decl}, d);
    const later = {...d, now: () => NOW + 60000};
    const second = await createCheckout(caller(uid), {product, declaration: decl}, later);
    assert.deepEqual(second, first, 'the same open session is returned');
    assert.equal(d.calls.length, 1);
    const want = {kind, wordingVersion: CHECKOUT_DECLARATION_WORDING[kind], termsVersion: terms, at: NOW + 60000};
    assert.deepEqual((await db.doc(`paymongoCheckouts/${first.sessionId}`).get()).get('declaration'), want);
    assert.deepEqual((await db.doc(`paymongoOrders/${first.reference}`).get()).get('declaration'), want);
  }
});

test('reusing an open checkout without a declaration is refused and leaves the records alone', async () => {
  const uid = 'gc-reuse-refused'; await reset(uid);
  const d = deps();
  d.client.getCheckoutSession = async id => ({id, status: 'active', payments: []});
  const first = await createCheckout(caller(uid), {product, declaration: adult}, d);
  await refused(uid, {product}, d, 'adult');
  assert.equal((await db.doc(`paymongoOrders/${first.reference}`).get()).get('declaration.at'), NOW);
});
