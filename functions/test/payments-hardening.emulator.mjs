import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {startTrial, trialEligible} from '../lib/webTrial.js';
import {fakeAuth} from './_paymongo-helpers.mjs';
const db = getFirestore();
const named = (uid, sub, email = 'Same@Example.test') => ({uid, token: {email, email_verified: true,
  firebase: {sign_in_provider: 'google.com', identities: {'google.com': [sub]}}}});
const deps = {db, auth: fakeAuth(), allow: async () => true, now: () => Date.parse('2026-10-20T02:00:00Z')};
test('trial identity marker survives deletion and blocks provider or verified email reuse', async () => {
  const first = named('hard-trial-first', 'same-sub');
  await startTrial(first, deps);
  await db.recursiveDelete(db.doc(`users/${first.uid}`));
  for (const caller of [named('hard-trial-again', 'same-sub', 'other@example.test'), named('hard-trial-email', 'other-sub', 'same@example.test')]) {
    assert.equal(await trialEligible(caller, db), false);
    await assert.rejects(startTrial(caller, deps), {code: 'failed-precondition'});
  }
  const markers = await db.collection('trialUsedIdentities').get();
  assert.ok(markers.size >= 2);
  for (const doc of markers.docs) {assert.match(doc.id, /^[0-9a-f]{64}$/); assert.deepEqual(doc.data(), {used: true});}
});

import {commitPaymongoGrant} from '../lib/paymongoGrants.js';
import {webProduct} from '../lib/paymongoPolicy.js';
import {createCheckout} from '../lib/paymongoCheckout.js';
const sitting = {firstDay: '2027-03-14', lastDay: '2027-03-14', sourceUrl: 'https://example.test/sitting'};
const catalog = [{id: 'exam_cse_pro', publishedSittings: [sitting, {...sitting, firstDay: '2027-08-08', lastDay: '2027-08-08'}]}];
const paidAt = Date.parse('2027-03-14T15:59:00Z');
async function grant(uid, product, id, extra = {}) {
  return commitPaymongoGrant(db, {uid, eventId: `evt_${id}`, sessionId: `cs_${id}`, paymentId: `pay_${id}`,
    paidAmount: product.includes('pass') ? 49900 : 14900, product: webProduct(product), paidAt, sitting, ...extra}, paidAt + 120000, catalog);
}
test('delayed pass delivery keeps the checkout sitting and PayMongo payment time', async () => {
  const uid = 'hard-delayed';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  assert.equal(await grant(uid, 'pantas_pass_cse_pro', 'delayed'), 'granted');
  const g = (await db.doc(`users/${uid}/grants/pay_delayed`).get()).data();
  assert.equal(g.endsAt, Date.parse('2027-03-14T23:59:59.999+08:00'));
  assert.equal(g.paidAt, paidAt);
  assert.deepEqual(g.sitting, sitting);
});
test('unbound paid passes stay unhandled and recoverable', async () => {
  const uid = 'hard-recovery';
  assert.equal(await grant(uid, 'pantas_pass_cse_pro', 'recover', {sitting: undefined}), 'noSitting');
  assert.equal((await db.doc(`webhookEvents/evt_recover/users/${uid}`).get()).exists, false);
  assert.equal((await db.doc('paymongoFollowUps/pay_recover').get()).get('status'), 'pending');
  assert.equal(await grant(uid, 'pantas_pass_cse_pro', 'recover'), 'granted');
  assert.equal((await db.doc('paymongoFollowUps/pay_recover').get()).get('status'), 'resolved');
});
test('duplicate pass adds no coverage and flags only the unused payment for refund', async () => {
  const uid = 'hard-duplicate';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  await grant(uid, 'pantas_pass_cse_pro', 'first');
  assert.equal(await grant(uid, 'pantas_pass_cse_pro', 'second'), 'unusedDuplicate');
  const first = (await db.doc(`users/${uid}/grants/pay_first`).get()).data();
  const second = (await db.doc(`users/${uid}/grants/pay_second`).get()).data();
  assert.equal(first.state, 'active'); assert.equal(second.state, 'revoked');
  assert.equal(second.unusedDuplicateOf, 'pay_first');
  assert.equal((await db.doc('paymongoFollowUps/pay_second').get()).get('reason'), 'unusedDuplicatePass');
  assert.equal((await db.doc('paymongoFollowUps/pay_second').get()).get('refundRequired'), true);
  assert.equal((await db.doc('paymongoFollowUps/pay_first').get()).exists, false);
});
test('Monthly and Yearly duplicate payments queue prepaid time', async () => {
  for (const product of ['pantas_cs_monthly', 'pantas_cs_yearly']) {
    const uid = `hard-stack-${product}`;
    await db.recursiveDelete(db.doc(`users/${uid}`));
    await grant(uid, product, `stack1_${product}`);
    await grant(uid, product, `stack2_${product}`);
    const first = (await db.doc(`users/${uid}/grants/pay_stack1_${product}`).get()).data();
    const second = (await db.doc(`users/${uid}/grants/pay_stack2_${product}`).get()).data();
    assert.equal(second.startsAt, first.endsAt); assert.ok(second.endsAt > first.endsAt);
    assert.equal((await db.doc(`paymongoFollowUps/pay_stack2_${product}`).get()).exists, false);
  }
});
test('checkout binds a sitting and reuses an open checkout for that account product and sitting', async () => {
  const uid = 'hard-checkout';
  await db.recursiveDelete(db.doc(`users/${uid}`));
  let calls = 0;
  const client = {createCheckoutSession: async () => ({id: `cs_hard_${++calls}`, checkoutUrl: 'https://checkout.paymongo.com/hard'}),
    getCheckoutSession: async id => ({id, status: 'active', payments: []})};
  const d = {db, client, origin: 'https://pantas.study', methods: ['card'], catalog, now: () => paidAt, allow: async () => true};
  const first = await createCheckout(named(uid, uid), {product: 'pantas_pass_cse_pro'}, d);
  const second = await createCheckout(named(uid, uid), {product: 'pantas_pass_cse_pro'}, d);
  assert.deepEqual(second, first); assert.equal(calls, 1);
  assert.deepEqual((await db.doc(`paymongoCheckouts/${first.sessionId}`).get()).get('sitting'), sitting);
});

const nativeEnd = paidAt + 10 * 86400000;
async function native(uid) {
  await db.doc(`users/${uid}/server/entitlement`).set({version: 1, facts: {
    coverageContext: {appId: 'app-test', firebaseProjectId: 'pantas-prod', sandboxTester: false},
    sources: [{productId: 'pantas_cs_monthly', entitlementIds: ['pro'], appId: 'app-test',
      environment: 'production', store: 'play_store', endsAt: nativeEnd, active: true}]}});
}
test('web prepaid starts after authoritative Play coverage', async () => {
  const uid = 'hard-native-stack';
  await db.recursiveDelete(db.doc(`users/${uid}`)); await native(uid);
  await grant(uid, 'pantas_cs_monthly', 'native_stack');
  assert.equal((await db.doc(`users/${uid}/grants/pay_native_stack`).get()).get('startsAt'), nativeEnd);
});
test('postponement recomputation extends the saved web sitting without reviving duplicates', async () => {
  const uid = 'hard-postpone';
  await db.recursiveDelete(db.doc(`users/${uid}`)); await native(uid);
  await grant(uid, 'pantas_pass_cse_pro', 'postpone');
  const {recomputePassRecords} = await import('../lib/revenuecatPasses.js');
  const moved = {...sitting, firstDay: '2027-03-21', lastDay: '2027-03-21'};
  await recomputePassRecords(db, [{id: 'exam_cse_pro', publishedSittings: [moved]}], fakeAuth(), {'exam_cse_pro:2027-03-14': '2027-03-21'});
  const g = (await db.doc(`users/${uid}/grants/pay_postpone`).get()).data();
  assert.deepEqual(g.sitting, moved);
  assert.equal(g.endsAt, Date.parse('2027-03-21T23:59:59.999+08:00'));
});

test('combined web reply includes Play subscriptions and native passes without claim grace', async () => {
  const uid = 'hard-native-display';
  await db.recursiveDelete(db.doc(`users/${uid}`)); await native(uid);
  await db.doc(`users/${uid}/passes/native`).set({product: 'pantas_pass_cse_pro', examId: 'exam_cse_pro',
    transactionId: 'native', purchasedAt: paidAt, sitting, endsAt: nativeEnd + 1000, state: 'active'});
  const {webEntitlement} = await import('../lib/webEntitlement.js');
  const reply = await webEntitlement(named(uid, uid), db, paidAt);
  assert.equal(reply.grants.find(g => g.product === 'pantas_cs_monthly').endsAt, nativeEnd);
  assert.equal(reply.grants.find(g => g.product === 'pantas_pass_cse_pro').endsAt, nativeEnd + 1000);
  assert.deepEqual((await webEntitlement(named('hard-other', 'other'), db, paidAt)).grants, []);
});

test('refund of a queued web grant preserves native coverage before the next grant', async () => {
  const uid = 'hard-refund-native';
  await native(uid);
  await grant(uid, 'pantas_cs_monthly', 'native_refund1');
  await grant(uid, 'pantas_cs_monthly', 'native_refund2');
  const {revokePaymongoPayment} = await import('../lib/paymongoGrants.js');
  await revokePaymongoPayment(db, {eventId: 'evt_native_refund', paymentId: 'pay_native_refund1',
    reason: 'refund.succeeded', refunds: [{id: 'ref_native', amount: 14900}]}, paidAt + 120000);
  assert.equal((await db.doc(`users/${uid}/grants/pay_native_refund2`).get()).get('startsAt'), nativeEnd);
});

test('checkout order survives a lost provider response with the purchased sitting', async () => {
  const uid = 'hard-lost-response';
  let captured;
  await assert.rejects(createCheckout(named(uid, uid), {product: 'pantas_pass_cse_pro'}, {
    db, origin: 'https://pantas.study', methods: ['card'], catalog, now: () => paidAt,
    allow: async () => true, client: {createCheckoutSession: async input => {captured = input; throw new Error('lost response');}},
  }));
  const order = (await db.doc(`paymongoOrders/${captured.referenceNumber}`).get()).data();
  assert.deepEqual(order?.sitting, sitting);
  assert.equal(order?.uid, uid);
});
test('a partially refunded web pass retains its refunded share after postponement', async () => {
  const uid = 'hard-postpone-refund';
  await native(uid);
  await grant(uid, 'pantas_pass_cse_pro', 'postpone_refund', {paidAt: paidAt - 20 * 86400000});
  const {revokePaymongoPayment} = await import('../lib/paymongoGrants.js');
  await revokePaymongoPayment(db, {eventId: 'evt_postpone_refund_actual', paymentId: 'pay_postpone_refund',
    reason: 'refund.succeeded', refunds: [{id: 'ref_postpone', amount: 24950}]}, paidAt - 10 * 86400000);
  const {recomputePassRecords} = await import('../lib/revenuecatPasses.js');
  const moved = {...sitting, lastDay: '2027-03-21'};
  await recomputePassRecords(db, [{id: 'exam_cse_pro', publishedSittings: [moved]}], fakeAuth());
  const g = (await db.doc(`users/${uid}/grants/pay_postpone_refund`).get()).data();
  const fullEnd = Date.parse('2027-03-21T23:59:59.999+08:00');
  assert.equal(g.fullEndsAt, fullEnd);
  assert.equal(g.endsAt, g.startsAt + Math.floor((fullEnd - g.startsAt) / 2 / 1000) * 1000);
});

test('a lost checkout response can still grant from its prewritten order', async () => {
  const uid = 'hard-lost-webhook';
  let captured;
  await assert.rejects(createCheckout(named(uid, uid), {product: 'pantas_pass_cse_pro'}, {
    db, origin: 'https://pantas.study', methods: ['card'], catalog, now: () => paidAt - 1000,
    allow: async () => true, client: {createCheckoutSession: async input => {captured = input; throw new Error('lost response');}},
  }));
  const {send, session, fakeClient, paidEvent, SECRET} = await import('./_paymongo-helpers.mjs');
  const verified = session({id: 'cs_lost', uid, product: 'pantas_pass_cse_pro', paymentId: 'pay_lost_webhook',
    amount: 49900, paidAt, metadata: {uid, product: 'pantas_pass_cse_pro', reference: captured.referenceNumber}});
  const client = fakeClient({cs_lost: verified});
  // No session-index fixture: the order saved before the provider call must suffice.
  delete client.sessions;
  assert.equal(await send(paidEvent({id: 'evt_lost_webhook', sessionId: 'cs_lost', uid, product: 'pantas_pass_cse_pro'}),
    {db, auth: fakeAuth(), client, signingSecret: SECRET, livemode: false, now: () => paidAt + 120000}), 200);
  assert.deepEqual((await db.doc(`users/${uid}/grants/pay_lost_webhook`).get()).get('sitting'), sitting);
});

test('real account deletion removes payment bindings but keeps only hashed trial markers', async () => {
  const {getAuth} = await import('firebase-admin/auth');
  const {deleteAccount} = await import('../lib/deleteAccount.js');
  const uid = 'hard-real-delete';
  await getAuth().createUser({uid});
  const caller = named(uid, 'real-delete-provider', 'delete@example.test');
  await startTrial(caller, deps);
  for (const collection of ['paymongoOrders', 'paymongoCheckouts', 'paymongoFollowUps']) {
    await db.doc(`${collection}/delete_test`).set({uid});
  }
  await deleteAccount.run({data: {}, auth: {...caller, token: {...caller.token, auth_time: Math.floor(Date.now() / 1000)}}, app: {appId: 'demo-app'}});
  for (const collection of ['paymongoOrders', 'paymongoCheckouts', 'paymongoFollowUps']) {
    assert.equal((await db.doc(`${collection}/delete_test`).get()).exists, false);
  }
  assert.equal(await trialEligible(named('hard-after-delete', 'real-delete-provider', 'delete@example.test'), db), false);
});

test('a duplicate payment for the original sitting stays unused after its pass is postponed', async () => {
  const uid = 'hard-postponed-duplicate';
  await native(uid);
  await grant(uid, 'pantas_pass_cse_pro', 'postponed_first');
  const {recomputePassRecords} = await import('../lib/revenuecatPasses.js');
  const moved = {...sitting, firstDay: '2027-03-21', lastDay: '2027-03-21'};
  await recomputePassRecords(db, [{id: 'exam_cse_pro', publishedSittings: [moved]}], fakeAuth(), {'exam_cse_pro:2027-03-14': '2027-03-21'});
  assert.equal(await grant(uid, 'pantas_pass_cse_pro', 'postponed_late'), 'unusedDuplicate');
});
test('a retried paid event resolves its session-level follow-up', async () => {
  const {send, session, fakeClient, paidEvent, SECRET} = await import('./_paymongo-helpers.mjs');
  const uid = 'hard-session-followup';
  const pending = session({id: 'cs_hard_followup', uid, product: 'pantas_cs_monthly', paymentId: 'pay_hard_followup', amount: 14900, paidAt, status: 'pending'});
  const d = {db, auth: fakeAuth(), client: fakeClient({cs_hard_followup: pending}), signingSecret: SECRET, livemode: false, now: () => paidAt + 120000};
  const event = paidEvent({id: 'evt_hard_followup', sessionId: 'cs_hard_followup', uid, product: 'pantas_cs_monthly'});
  assert.equal(await send(event, d), 500);
  pending.payments[0].status = 'paid';
  assert.equal(await send(event, d), 200);
  assert.equal((await db.doc('paymongoFollowUps/cs_hard_followup').get()).get('status'), 'resolved');
});

test('the combined coverage callable refuses a stale requested account', async () => {
  const {getWebEntitlement} = await import('../lib/webEntitlement.js');
  await assert.rejects(getWebEntitlement.run({data: {uid: 'old-owner'}, auth: named('new-owner', 'new-sub'), app: {appId: 'demo-app'}}), {code: 'permission-denied'});
});

test('second-precision paid_at can share the checkout creation second', async () => {
  const {send, session, fakeClient, paidEvent, SECRET} = await import('./_paymongo-helpers.mjs');
  const uid = 'hard-paid-second';
  const reference = '12345678-1234-1234-1234-123456789abc';
  await db.doc(`paymongoOrders/${reference}`).set({uid, product: 'pantas_cs_monthly', createdAt: paidAt + 900});
  const client = fakeClient({cs_second: session({id: 'cs_second', uid, product: 'pantas_cs_monthly', paymentId: 'pay_second_precision', amount: 14900, paidAt,
    metadata: {uid, product: 'pantas_cs_monthly', reference}})});
  delete client.sessions;
  assert.equal(await send(paidEvent({id: 'evt_second_precision', sessionId: 'cs_second', uid, product: 'pantas_cs_monthly'}),
    {db, auth: fakeAuth(), client, signingSecret: SECRET, livemode: false, now: () => paidAt + 120000}), 200);
});

test('refund replanning also preserves an existing web pass', async () => {
  const uid = 'hard-web-pass-stack';
  const august = {...sitting, firstDay: '2027-08-08', lastDay: '2027-08-08'};
  await grant(uid, 'pantas_pass_cse_pro', 'webpass_stack', {sitting: august});
  await grant(uid, 'pantas_cs_monthly', 'webpass_month1');
  await grant(uid, 'pantas_cs_monthly', 'webpass_month2');
  const {revokePaymongoPayment} = await import('../lib/paymongoGrants.js');
  await revokePaymongoPayment(db, {eventId: 'evt_webpass_refund_actual', paymentId: 'pay_webpass_month1',
    reason: 'refund.succeeded', refunds: [{id: 'ref_webpass', amount: 14900}]}, paidAt + 120000);
  assert.equal((await db.doc(`users/${uid}/grants/pay_webpass_month2`).get()).get('startsAt'), Date.parse('2027-08-08T23:59:59.999+08:00'));
});

test('a failed provider reread leaves an unhandled paid event and a follow-up', async () => {
  const {send, paidEvent, SECRET} = await import('./_paymongo-helpers.mjs');
  const uid = 'hard-provider-unavailable';
  const event = paidEvent({id: 'evt_provider_unavailable', sessionId: 'cs_provider_unavailable', uid, product: 'pantas_cs_monthly'});
  assert.equal(await send(event, {db, auth: fakeAuth(), signingSecret: SECRET, livemode: false,
    now: () => paidAt, client: {getCheckoutSession: async () => {throw new Error('provider unavailable');}}}), 500);
  assert.equal((await db.doc(`webhookEvents/evt_provider_unavailable/users/${uid}`).get()).exists, false);
  assert.equal((await db.doc('paymongoFollowUps/cs_provider_unavailable').get()).get('status'), 'pending');
});

test('deleting an account with a pre-hardening trial preserves its used identity', async () => {
  const {getAuth} = await import('firebase-admin/auth');
  const {deleteAccount} = await import('../lib/deleteAccount.js');
  const uid = 'hard-legacy-delete';
  await getAuth().createUser({uid});
  await db.doc(`users/${uid}/server/trial`).set({usedAt: paidAt, grantId: 'trial'});
  const caller = named(uid, 'legacy-delete-sub', 'legacy-delete@example.test');
  await deleteAccount.run({data: {}, auth: {...caller, token: {...caller.token, auth_time: Math.floor(Date.now() / 1000)}}, app: {appId: 'demo-app'}});
  assert.equal(await trialEligible(named('hard-legacy-recreated', 'legacy-delete-sub', 'legacy-delete@example.test'), db), false);
});
