import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {createCheckout} from '../lib/paymongoCheckout.js';
import {deleteUserData} from '../lib/deleteUserData.js';
import {handlePaymongoWebhook} from '../lib/paymongoWebhook.js';
import {fakeAuth, paidEvent, signed, SECRET} from './_paymongo-helpers.mjs';
import {adult} from './_declaration.mjs';

const db = getFirestore();
const T0 = Date.parse('2027-02-01T10:00:00+08:00');
const MIN = 60_000;
const product = 'pantas_cs_monthly';
const caller = uid => ({uid, token: {firebase: {sign_in_provider: 'google.com'}}});

/** A fake PayMongo whose first session is paid (or not) as the test says. */
function paymongo({uid, paid, paymentId}) {
  const made = [];
  const client = {
    createCheckoutSession: async input => {
      made.push(input);
      return {id: `cs_${input.referenceNumber}`, checkoutUrl: 'https://checkout.paymongo.test/x'};
    },
    getCheckoutSession: async id => {
      const first = made[0];
      return {id, status: 'active', metadata: {uid, product, reference: first?.referenceNumber ?? ''},
        payments: paid && first && id === `cs_${first.referenceNumber}` ?
          [{id: paymentId, amount: 14900, currency: 'PHP', status: 'paid', paidAt: T0 + MIN}] : []};
    },
    getRefund: async () => { throw new Error('no refund reads here'); },
  };
  return {client, made};
}
const checkoutDeps = (client, now, auth) => ({client, db, origin: 'https://pantas.test', methods: ['card'],
  allow: async () => true, now: () => now, ...(auth ? {auth} : {})});
const grantIds = async uid => (await db.collection(`users/${uid}/grants`).get()).docs.map(d => d.id);

test('a paid session with no grant older than 10 minutes is completed by the checkout call; under 10 minutes it is only reported', async () => {
  const uid = 'heal-paid';
  const {client, made} = paymongo({uid, paid: true, paymentId: 'pay_heal_1'});
  await createCheckout(caller(uid), {product, declaration: adult}, checkoutDeps(client, T0));
  const sessionId = `cs_${made[0].referenceNumber}`;
  const auth = fakeAuth();
  await assert.rejects(createCheckout(caller(uid), {product, declaration: adult}, checkoutDeps(client, T0 + 5 * MIN, auth)),
    error => error.message === 'Your payment is being confirmed. Pro will appear shortly.');
  assert.deepEqual(await grantIds(uid), []);
  // A request cannot supply the session or payment: the call reads both from PayMongo.
  await createCheckout(caller(uid), {product, declaration: adult, sessionId: 'cs_forged', paymentId: 'pay_forged'}, checkoutDeps(client, T0 + 12 * MIN, auth));
  assert.deepEqual(await grantIds(uid), ['pay_heal_1']);
  assert.equal((await db.doc('paymongoPayments/pay_heal_1').get()).get('uid'), uid);
  assert.equal((await db.doc(`webhookEvents/heal_pay_heal_1/users/${uid}`).get()).exists, true);
  assert.equal(auth.current().pro, true);
  // The real webhook arriving later is a duplicate and changes nothing.
  const grantBefore = (await db.doc(`users/${uid}/grants/pay_heal_1`).get()).data();
  const recordBefore = (await db.doc(`users/${uid}/server/entitlement`).get()).data();
  const {raw, header} = signed(paidEvent({id: 'evt_real_after_heal', sessionId, uid, product}), {now: T0 + 13 * MIN});
  assert.equal(await handlePaymongoWebhook(raw, header, {db, auth, client, signingSecret: SECRET, livemode: false,
    now: () => T0 + 13 * MIN}), 200);
  assert.deepEqual(await grantIds(uid), ['pay_heal_1']);
  assert.deepEqual((await db.doc(`users/${uid}/grants/pay_heal_1`).get()).data(), grantBefore);
  assert.deepEqual((await db.doc(`users/${uid}/server/entitlement`).get()).data(), recordBefore);
});

test('a payment on a checkout link that outlived account deletion becomes one refund task and no grant, with no uid kept', async () => {
  const uid = 'heal-deleted';
  const {client, made} = paymongo({uid, paid: true, paymentId: 'pay_del_1'});
  const out = await createCheckout(caller(uid), {product, declaration: adult}, checkoutDeps(client, T0));
  const reference = made[0].referenceNumber;
  await deleteUserData(db, {getUser: async () => ({}), deleteUser: async () => {}}, uid, 'user_request', {now: () => T0 + MIN});
  // The checkout and order records stay, cut down to the quote.
  for (const path of [`paymongoCheckouts/${out.sessionId}`, `paymongoOrders/${reference}`]) {
    const row = (await db.doc(path).get()).data();
    assert.deepEqual(row, {accountDeleted: true, deletedAt: T0 + MIN, product, amountCentavos: 14900}, path);
  }
  const auth = fakeAuth();
  const {raw, header} = signed(paidEvent({id: 'evt_after_delete', sessionId: out.sessionId, uid, product}), {now: T0 + 3 * MIN});
  assert.equal(await handlePaymongoWebhook(raw, header, {db, auth, client, signingSecret: SECRET, livemode: false,
    now: () => T0 + 3 * MIN}), 200);
  const tasks = (await db.collection('paymongoFollowUps').where('paymentId', '==', 'pay_del_1').get()).docs;
  assert.equal(tasks.length, 1);
  assert.equal(tasks[0].get('status'), 'pending');
  assert.equal(tasks[0].get('refundRequired'), true);
  assert.equal(tasks[0].get('paidAmount'), 14900);
  assert.deepEqual(await grantIds(uid), []);
  assert.equal((await db.doc('paymongoPayments/pay_del_1').get()).exists, false);
  for (const collection of ['paymongoFollowUps', 'paymongoCheckouts', 'paymongoOrders', 'paymongoPayments', 'paymongoRevocations']) {
    for (const doc of (await db.collection(collection).get()).docs) {
      assert.equal(JSON.stringify([doc.id, doc.data()]).includes(uid), false, `${collection}/${doc.id} holds the uid`);
    }
  }
});
