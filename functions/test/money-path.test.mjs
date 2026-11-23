import assert from 'node:assert/strict';
import test from 'node:test';
import {commitPaymongoGrant} from '../lib/paymongoGrants.js';
import {webProduct, priceCentavos} from '../lib/paymongoPolicy.js';
import {commitRevenueCatAnswer} from '../lib/revenuecatClaims.js';

const uid = 'money-path-test';
const now = Date.parse('2027-03-14T12:00:00Z');
const product = webProduct('pantas_cs_monthly');

function firestore(seed = {}) {
  const rows = new Map(Object.entries(seed));
  const snapshot = ref => ({ref, id: ref.path.split('/').at(-1), exists: rows.has(ref.path),
    get: key => rows.get(ref.path)?.[key], data: () => rows.get(ref.path)});
  const doc = path => ({path, get: async () => snapshot({path}), set: async value => rows.set(path, value)});
  const collection = path => ({path, collection: true, doc: () => doc(`${path}/audit`), add: async () => {}});
  const get = async ref => ref.collection ? {docs: [...rows.keys()]
    .filter(path => path.startsWith(`${ref.path}/`) && !path.slice(ref.path.length + 1).includes('/'))
    .map(path => snapshot(doc(path)))} : snapshot(ref);
  const runTransaction = async callback => {
    const writes = [];
    const set = (ref, value, options) => writes.push(() => rows.set(ref.path,
      options?.merge ? {...rows.get(ref.path), ...value} : value));
    const result = await callback({get, getAll: (...refs) => Promise.all(refs.map(get)), set,
      create: set, update: (ref, value) => set(ref, value, {merge: true})});
    for (const write of writes) write();
    return result;
  };
  return {doc, collection, runTransaction, rows};
}

const payment = {uid, eventId: 'evt_test', sessionId: 'cs_test', paymentId: 'pay_test',
  paidAt: now, product, paidAmount: priceCentavos(product)};

test('PayMongo sends closed-account payments to refund without writing a grant', async () => {
  for (const marker of [{}, {startedAt: now}]) {
    const db = firestore({[`accountDeletions/${uid}`]: marker});
    assert.equal(await commitPaymongoGrant(db, payment, now, []), 'accountDeleted');
    assert.equal(db.rows.has(`users/${uid}/grants/pay_test`), false);
    assert.equal(db.rows.has(`users/${uid}/server/entitlement`), false);
    assert.equal(db.rows.has('paymongoPayments/pay_test'), false);
    const followUp = db.rows.get('paymongoFollowUps/pay_test');
    assert.equal(followUp.reason, 'accountDeleted');
    assert.equal(followUp.refundRequired, true);
  }
});

test('RevenueCat skips a closed account before preparing any store writes', async () => {
  for (const marker of [{}, {startedAt: now}]) {
    const db = firestore({[`accountDeletions/${uid}`]: marker});
    assert.equal(await commitRevenueCatAnswer(db, uid, 'evt_store_test', now, async () => ({
      claims: {pro: true, proUntil: now + 1000}, apply: () => assert.fail('Unexpected store write'),
    }), {}), false);
    assert.equal(db.rows.size, 1);
  }
});

const sitting = {firstDay: '2027-03-14', lastDay: '2027-03-14', sourceUrl: 'https://example.test'};
const pass = webProduct('pantas_pass_cse_pro');
const passPayment = {...payment, product: pass, sitting, paidAmount: priceCentavos(pass)};
const end = Date.parse('2027-03-14T23:59:59.999+08:00');

test('a pass first processed after the end of its sitting requires a refund', async () => {
  const db = firestore();
  assert.equal(await commitPaymongoGrant(db, passPayment, end + 1, []), 'paidAfterSitting');
  assert.equal(db.rows.get('paymongoFollowUps/pay_test').refundRequired, true);
  assert.equal(db.rows.get(`users/${uid}/grants/pay_test`).state, 'revoked');
});

test('an ended pass does not block a replacement for the same sitting', async () => {
  const db = firestore({[`users/${uid}/grants/pay_previous`]: {product: pass.id, tier: pass.tier,
    source: 'paymongo', state: 'active', sitting, startsAt: now - 2000, endsAt: now, createdAt: now - 2000}});
  assert.equal(await commitPaymongoGrant(db, passPayment, now + 1, []), 'granted');
  assert.equal(db.rows.has('paymongoFollowUps/pay_test'), false);
  assert.equal(db.rows.get(`users/${uid}/grants/pay_test`).endsAt, end);
});

test('refund follow-up stays open for a partial refund and closes when fully refunded', async () => {
  const {revokePaymongoPayment} = await import('../lib/paymongoGrants.js');
  const path = 'paymongoFollowUps/pay_test';
  const db = firestore({[path]: {status: 'pending', refundRequired: true}});
  await commitPaymongoGrant(db, payment, now, []);
  db.rows.get(path).status = 'pending';
  for (const [id, amount, status] of [['first', 1, 'pending'], ['rest', payment.paidAmount - 1, 'refunded']]) {
    await revokePaymongoPayment(db, {eventId: `evt_${id}`, paymentId: payment.paymentId,
      reason: 'refund', refunds: [{id, amount}]}, now + 1);
    assert.equal(db.rows.get(path).status, status);
  }
});

test('a refund closes a deleted-account follow-up without a payment index', async () => {
  const {revokePaymongoPayment} = await import('../lib/paymongoGrants.js');
  const path = 'paymongoFollowUps/pay_test';
  const db = firestore({[path]: {status: 'pending', refundRequired: true, paidAmount: payment.paidAmount}});
  await revokePaymongoPayment(db, {eventId: 'evt_refund', paymentId: payment.paymentId,
    reason: 'refund', refunds: [{id: 'full', amount: payment.paidAmount}]}, now + 1);
  assert.equal(db.rows.get(path).status, 'refunded');
});

test('checkout records its quote and replaces a stale open reservation', async () => {
  const {createCheckout} = await import('../lib/paymongoCheckout.js');
  const db = firestore();
  let count = 0;
  const auth = {uid, token: {email: 'buyer@example.test', email_verified: true,
    firebase: {sign_in_provider: 'google.com'}}};
  const client = {createCheckoutSession: async () => ({id: `cs_quote_${++count}`, checkoutUrl: 'https://example.test'}),
    getCheckoutSession: async () => ({status: 'active', payments: []})};
  const deps = {db, client, origin: 'https://example.test', methods: ['card'], now: () => now, allow: async () => true};
  const first = await createCheckout(auth, {product: product.id}, deps);
  assert.equal(db.rows.get(`paymongoOrders/${first.reference}`).amountCentavos, payment.paidAmount);
  const pending = [...db.rows.keys()].find(path => path.startsWith(`users/${uid}/pendingCheckouts/`));
  db.rows.get(pending).amountCentavos = payment.paidAmount - 100;
  const second = await createCheckout(auth, {product: product.id}, deps);
  assert.notEqual(second.reference, first.reference);
  assert.equal(count, 2);
});

async function deliverPayment(db, amount, reference, auth = {getUser: async () => ({})}) {
  const {handlePaymongoWebhook} = await import('../lib/paymongoWebhook.js');
  const {signed, paidEvent, SECRET} = await import('./_paymongo-helpers.mjs');
  const metadata = {uid, product: product.id, reference};
  const {raw, header} = signed(paidEvent({id: payment.eventId, sessionId: payment.sessionId, metadata}), {now});
  const client = {getCheckoutSession: async () => ({metadata, payments: [
    {id: payment.paymentId, amount, currency: 'PHP', status: 'paid', paidAt: now},
  ]})};
  return handlePaymongoWebhook(raw, header, {db, client, auth, signingSecret: SECRET,
    livemode: false, now: () => now});
}

const reference = 'e0d1832a-f156-44e9-9622-b006ce7bdfc8';

test('payment reconciliation accepts the amount on the order after a price change', async () => {
  const quote = payment.paidAmount - 100;
  const db = firestore({[`paymongoOrders/${reference}`]: {uid, product: product.id, createdAt: now - 1000,
    sessionId: payment.sessionId, amountCentavos: quote}, [`webhookEvents/${payment.eventId}/users/${uid}`]: {}});
  assert.equal(await deliverPayment(db, quote, reference), 200);
  assert.equal(db.rows.has('paymongoFollowUps/pay_test'), false);
});

test('a paid checkout cleared by account deletion still goes to refund', async () => {
  const db = firestore({[`accountDeletions/${uid}`]: {}});
  assert.equal(await deliverPayment(db, payment.paidAmount - 100, reference), 200);
  const followUp = db.rows.get('paymongoFollowUps/pay_test');
  assert.equal(followUp.reason, 'accountDeleted');
  assert.equal(followUp.refundRequired, true);
  assert.equal(db.rows.has(`users/${uid}/grants/pay_test`), false);
});

test('a payment goes to refund if account deletion completes during the Auth lookup', async () => {
  const order = `paymongoOrders/${reference}`;
  const db = firestore({[order]: {uid, product: product.id, createdAt: now - 1000,
    sessionId: payment.sessionId, amountCentavos: payment.paidAmount}});
  const auth = {getUser: async () => {
    db.rows.set(`accountDeletions/${uid}`, {});
    db.rows.delete(order);
    throw Object.assign(new Error('No user'), {code: 'auth/user-not-found'});
  }};
  assert.equal(await deliverPayment(db, payment.paidAmount, reference, auth), 200);
  assert.equal(db.rows.get('paymongoFollowUps/pay_test').reason, 'accountDeleted');
});
