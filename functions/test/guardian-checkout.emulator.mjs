import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {FieldValue, getFirestore} from 'firebase-admin/firestore';
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
  for (const [uid, status] of [['gc-flag-pending', 'pending'], ['gc-flag-declined', 'declined'], ['gc-flag-only', undefined]]) {
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

test('reusing an open checkout without a declaration is refused and leaves the records alone', async () => {
  const uid = 'gc-reuse-refused'; await reset(uid);
  const d = deps();
  d.client.getCheckoutSession = async id => ({id, status: 'active', payments: []});
  const first = await createCheckout(caller(uid), {product, declaration: adult}, d);
  await refused(uid, {product}, d, 'adult');
  assert.equal((await db.doc(`paymongoOrders/${first.reference}`).get()).get('declaration.at'), NOW);
});

// ---- Round 2: immutable declarations, in-transaction consent, closure ---------------------------

const activeClient = d => { d.client.getCheckoutSession = async id => ({id, status: 'active', payments: []}); return d; };
const updateTimes = async refs => Promise.all(refs.map(async ref => (await ref.get()).updateTime.toMillis()));

test('reusing an open checkout never rewrites the stored declaration', async () => {
  const uid = 'gc-immutable'; await reset(uid);
  const d = activeClient(deps());
  const first = await createCheckout(caller(uid), {product, declaration: adult}, d);
  const refs = [db.doc(`paymongoCheckouts/${first.sessionId}`), db.doc(`paymongoOrders/${first.reference}`)];
  const before = await updateTimes(refs);
  const second = await createCheckout(caller(uid), {product, declaration: adult}, {...d, now: () => NOW + 60000});
  assert.deepEqual(second, first);
  assert.deepEqual(await updateTimes(refs), before, 'neither record was written');
  assert.equal((await refs[1].get()).get('declaration.at'), NOW);
});

test('a paid order keeps its declaration when the buyer reopens checkout', async () => {
  const uid = 'gc-paid-reopen'; await reset(uid);
  const d = activeClient(deps());
  const first = await createCheckout(caller(uid), {product, declaration: adult}, d);
  // PayMongo reports the session paid, and its grant is already processed.
  d.client.getCheckoutSession = async id => ({id, status: 'active', payments: [{id: 'pay_gc_1', status: 'paid', amount: 14900, currency: 'PHP'}]});
  const {grantDocId} = await import('../lib/paymongoGrants.js');
  await db.doc(`paymongoPayments/${grantDocId('pay_gc_1')}`).set({uid});
  await createCheckout(caller(uid), {product, declaration: adult}, {...d, now: () => NOW + 60000});
  assert.deepEqual((await db.doc(`paymongoOrders/${first.reference}`).get()).get('declaration'),
    {kind: 'adult', wordingVersion: 'checkout-adult-2026-11-23', termsVersion: terms, at: NOW});
  assert.deepEqual((await db.doc(`paymongoCheckouts/${first.sessionId}`).get()).get('declaration.at'), NOW);
});

test('an adult reopen cannot erase guardian evidence: the guardian session is replaced, not rewritten', async () => {
  const uid = 'gc-erase'; await reset(uid); await consent(uid, 'minor');
  const d = activeClient(deps());
  const first = await createCheckout(caller(uid), {product, declaration: guardian}, d);
  await consent(uid, 'adult');
  const second = await createCheckout(caller(uid), {product, declaration: adult}, {...d, now: () => NOW + 60000});
  assert.notEqual(second.reference, first.reference);
  assert.equal(d.calls.length, 2, 'a new session was made');
  assert.equal((await db.doc(`paymongoOrders/${first.reference}`).get()).get('declaration.kind'), 'guardian');
  assert.equal((await db.doc(`paymongoCheckouts/${first.sessionId}`).get()).get('declaration.kind'), 'guardian');
  assert.equal((await db.doc(`paymongoOrders/${second.reference}`).get()).get('declaration.kind'), 'adult');
});

test('an open session with no declaration (made before this release) is replaced on any reuse', async () => {
  const uid = 'gc-undeclared'; await reset(uid);
  const d = activeClient(deps());
  const first = await createCheckout(caller(uid), {product, declaration: adult}, d);
  await db.doc(`paymongoOrders/${first.reference}`).update({declaration: FieldValue.delete()});
  await db.doc(`paymongoCheckouts/${first.sessionId}`).update({declaration: FieldValue.delete()});
  const second = await createCheckout(caller(uid), {product, declaration: adult}, {...d, now: () => NOW + 60000});
  assert.notEqual(second.reference, first.reference);
  assert.equal((await db.doc(`paymongoOrders/${second.reference}`).get()).get('declaration.kind'), 'adult');
  assert.equal((await db.doc(`paymongoOrders/${first.reference}`).get()).get('declaration'), undefined, 'the old order is left as it was');
});

test('a stored wording that differs from the one required is replaced', async () => {
  const uid = 'gc-oldwording'; await reset(uid);
  const d = activeClient(deps());
  const first = await createCheckout(caller(uid), {product, declaration: adult}, d);
  await db.doc(`paymongoOrders/${first.reference}`).update({'declaration.wordingVersion': 'checkout-adult-2026-11-01'});
  const second = await createCheckout(caller(uid), {product, declaration: adult}, d);
  assert.notEqual(second.reference, first.reference);
});

test('a paid but ungranted session is still never replaced', async () => {
  const uid = 'gc-paid-guard'; await reset(uid);
  const d = activeClient(deps());
  await createCheckout(caller(uid), {product, declaration: adult}, d);
  await db.doc(`paymongoOrders/${(await db.collection('paymongoOrders').where('uid', '==', uid).get()).docs[0].id}`)
    .update({declaration: FieldValue.delete()});
  d.client.getCheckoutSession = async id => ({id, status: 'active', payments: [{id: 'pay_gc_2', status: 'paid', amount: 14900, currency: 'PHP'}]});
  await assert.rejects(createCheckout(caller(uid), {product, declaration: adult}, d), {code: 'failed-precondition'});
  assert.equal(d.calls.length, 1);
});

test('consent confirmed after the first check yields the guardian requirement, not an adult checkout', async () => {
  const uid = 'gc-mid-consent'; await reset(uid);
  const d = deps();
  d.allow = async () => { await consent(uid, 'minor'); return true; };
  await assert.rejects(createCheckout(caller(uid), {product, declaration: adult}, d), error => {
    assert.equal(error.code, 'failed-precondition');
    assert.deepEqual(error.details, {reason: 'declaration-required', kind: 'guardian'});
    return true;
  });
  await nothingWritten(uid, d);
});

test('consent confirmed while the session is made is caught before the link is handed out', async () => {
  const uid = 'gc-late-consent'; await reset(uid);
  const d = deps();
  const make = d.client.createCheckoutSession;
  d.client.createCheckoutSession = async input => { const out = await make(input); await consent(uid, 'minor'); return out; };
  await assert.rejects(createCheckout(caller(uid), {product, declaration: adult}, d),
    {code: 'failed-precondition', details: {reason: 'declaration-required', kind: 'guardian'}});
  assert.equal((await db.collection(`users/${uid}/pendingCheckouts`).get()).size, 0, 'the reservation is released');
});

test('an account closed after the first check gets no checkout', async () => {
  for (const [uid, close] of [['gc-closed-deletion', () => db.doc('accountDeletions/gc-closed-deletion').set({reason: 'user_request'})],
    ['gc-closed-withdrawn', () => consent('gc-closed-withdrawn', 'minor', 'withdrawn')]]) {
    await reset(uid); await db.doc(`accountDeletions/${uid}`).delete();
    const d = deps();
    d.allow = async () => { await close(); return true; };
    await assert.rejects(createCheckout(caller(uid), {product, declaration: adult}, d), {code: 'permission-denied', details: {reason: 'account-closed'}});
    await nothingWritten(uid, d);
    await db.doc(`accountDeletions/${uid}`).delete();
  }
});
