// Audit PAY-13 (Nov 23, 2026): prod runs PayMongo test keys before the live switch, and the beta gate is client-only,
// so any signed-in account could pay with a public test card and receive real prod Pro. Checkout is refused on prod
// while its key is not live, except for an account holding the admin claim.
import assert from 'node:assert/strict';
import test from 'node:test';
import {checkoutClosed, createCheckout} from '../lib/paymongoCheckout.js';

test('checkout is closed only on pantas-prod with a key that is not live', () => {
  assert.equal(checkoutClosed('pantas-prod', 'sk_test_abc'), true);
  assert.equal(checkoutClosed('pantas-prod', ''), true);
  assert.equal(checkoutClosed('pantas-prod', 'sk_live_abc'), false);
  assert.equal(checkoutClosed('pantas-staging', 'sk_test_abc'), false);
  assert.equal(checkoutClosed(undefined, 'sk_test_abc'), false);
});

const untouchable = new Proxy({}, {get: () => { throw new Error('the database must not be touched'); }});
const deps = (closed) => ({db: untouchable, origin: 'https://app.pantas.study', methods: ['card'], closedForTestMode: closed,
  allow: async () => true, client: {createCheckoutSession: async () => { throw new Error('no session'); }}});
const student = {uid: 'student-1', token: {firebase: {sign_in_provider: 'google.com'}}};
const owner = {uid: 'owner-1', token: {admin: true, firebase: {sign_in_provider: 'google.com'}}};

test('a closed checkout refuses a student before any database access or PayMongo call', async () => {
  await assert.rejects(createCheckout(student, {product: 'pantas_cs_monthly'}, deps(true)),
    (error) => error.code === 'failed-precondition' && error.details?.reason === 'checkout-closed');
});

test('a closed checkout still lets an admin-claim account through (it reaches the database next)', async () => {
  await assert.rejects(createCheckout(owner, {product: 'pantas_cs_monthly'}, deps(true)), /must not be touched/);
});

test('an open checkout is not refused for being closed', async () => {
  await assert.rejects(createCheckout(student, {product: 'pantas_cs_monthly'}, deps(false)), /must not be touched/);
});

test('checkout offers QR Ph only unless the environment names other methods', async () => {
  const {DEFAULT_METHODS} = await import('../lib/paymongoCheckout.js');
  assert.deepEqual(DEFAULT_METHODS, ['qrph']);
});
