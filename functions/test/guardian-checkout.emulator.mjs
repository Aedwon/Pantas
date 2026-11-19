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
const consent = (uid, ageGroup) => db.doc(`users/${uid}/server/guardianConsent`).set({status: 'confirmed', ...(ageGroup === undefined ? {} : {ageGroup}), decidedAt: NOW});

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

test('a minor who reuses an open checkout gets the current attestation written to both records', async () => {
  const uid = 'gc-reuse'; await reset(uid); await consent(uid, 'minor');
  const d = deps();
  d.client.getCheckoutSession = async id => ({id, status: 'active', payments: []});
  const first = await createCheckout(caller(uid), {product, guardianAttestation: {termsVersion: terms}}, d);
  const later = {...d, now: () => NOW + 60000};
  const second = await createCheckout(caller(uid), {product, guardianAttestation: {termsVersion: terms}}, later);
  assert.deepEqual(second, first, 'the same open session is returned');
  assert.equal(d.calls.length, 1);
  const checkout = (await db.doc(`paymongoCheckouts/${first.sessionId}`).get()).data();
  assert.equal(checkout.attestedAt, NOW + 60000);
  assert.equal(checkout.termsVersion, terms);
  const order = (await db.doc(`paymongoOrders/${first.reference}`).get()).data();
  assert.equal(order.attestedAt, NOW + 60000);
  assert.equal(order.termsVersion, terms);
});

test('an adult who reuses an open checkout gets no attestation written', async () => {
  const uid = 'gc-reuse-adult'; await reset(uid);
  const d = deps();
  d.client.getCheckoutSession = async id => ({id, status: 'active', payments: []});
  const first = await createCheckout(caller(uid), {product}, d);
  await createCheckout(caller(uid), {product}, d);
  assert.equal('attestedAt' in (await db.doc(`paymongoCheckouts/${first.sessionId}`).get()).data(), false);
  assert.equal((await db.doc(`paymongoOrders/${first.reference}`).get()).get('attestedAt'), undefined);
});

test('an unknown group and a record with no group are all refused without the attestation', async () => {
  for (const [uid, group] of [['gc-unknown', 'teen'], ['gc-blank', undefined], ['gc-null', null]]) {
    await reset(uid); await consent(uid, group);
    const d = deps();
    await assert.rejects(createCheckout(caller(uid), {product}, d),
      {code: 'failed-precondition', details: {reason: 'guardian-attestation-required'}}, uid);
    assert.equal(d.calls.length, 0, uid);
    assert.equal((await db.collection(`users/${uid}/pendingCheckouts`).get()).size, 0, uid);
  }
});

test('a child cannot buy a non-PSHS product even with the guardian attestation', async () => {
  const uid = 'gc-child'; await reset(uid); await consent(uid, 'child');
  const d = deps();
  await assert.rejects(createCheckout(caller(uid), {product, guardianAttestation: {termsVersion: terms}}, d),
    {details: {reason: 'child-product'}});
  assert.equal(d.calls.length, 0);
});

test('PSHS checkout requires the current declaration for every age group and binds the child uid', async () => {
  const product = 'pantas_pass_pshs_nce';
  const checkoutBoxTextVersion = '2026-11-19';
  const holder = 'gc-pshs-holder';
  for (const group of ['adult', 'minor', 'child', 'unknown']) {
    const uid = `gc-pshs-${group}`; await reset(uid); await consent(uid, group);
    const d = deps();
    const auth = group === 'child' ? {uid, token: {ageGroup: 'child', holder,
      firebase: {sign_in_provider: 'custom'}}} : caller(uid);
    d.productFor = id => id === product ? {id, tier: 'nce', kind: 'pass', examId: 'exam_pshs_nce',
      webPricePhp: 1499, prepaid: {unit: 'sitting'}} : undefined;
    d.catalog = [{id: 'exam_pshs_nce', publishedSittings: [{firstDay: '2026-12-01', lastDay: '2026-12-01', sourceUrl: 'https://example.test/exam'}]}];
    for (const version of [undefined, '2020-01-01']) {
      await assert.rejects(createCheckout(auth, {product, checkoutBoxTextVersion: version}, d),
        {details: {reason: 'stale-checkout-box'}});
    }
    if (group === 'child') {
      await assert.rejects(createCheckout(auth, {product, checkoutBoxTextVersion}, d),
        {details: {reason: 'not-linked'}});
      await db.doc(`users/${uid}/server/childLink`).set({holderUid: holder});
      const entry = db.doc(`users/${holder}/server/children/items/${uid}`);
      await entry.set({active: false});
      await assert.rejects(createCheckout(auth, {product, checkoutBoxTextVersion}, d),
        {details: {reason: 'not-linked'}});
      await entry.update({active: true});
    }
    const result = await createCheckout(auth, {product, checkoutBoxTextVersion, childId: 'ignored-other-child'}, d);
    const record = await db.doc(`paymongoCheckouts/${result.sessionId}`).get();
    assert.equal(record.get('uid'), uid);
    assert.equal(record.get('checkoutBoxTextVersion'), checkoutBoxTextVersion);
    assert.equal(record.get('attestedAt'), NOW);
  }
});
