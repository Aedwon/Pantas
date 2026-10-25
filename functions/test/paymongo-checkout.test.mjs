import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {createCheckout} from '../lib/paymongoCheckout.js';

test('checkout returns its unique reference in both return URLs and the client response', async () => {
  const calls = [];
  const deps = {db: {}, origin: 'https://pantas.study', methods: ['card'],
    allow: async () => true,
    client: {createCheckoutSession: async input => {
      calls.push(input);
      return {id: `cs_${calls.length}`, checkoutUrl: 'https://checkout.paymongo.com/test'};
    }}};
  const auth = {uid: 'owner', token: {firebase: {sign_in_provider: 'google.com'}}};
  const first = await createCheckout(auth, {product: 'pantas_cs_monthly'}, deps);
  const second = await createCheckout(auth, {product: 'pantas_cs_monthly'}, deps);
  for (const [i, out] of [first, second].entries()) {
    assert.equal(out.reference, calls[i].referenceNumber);
    assert.match(out.reference, /^[0-9a-f-]{36}$/);
    assert.equal(calls[i].successUrl, `https://pantas.study/pro?checkout=success&ref=${out.reference}`);
    assert.equal(calls[i].cancelUrl, `https://pantas.study/pro?checkout=cancelled&ref=${out.reference}`);
    assert.equal(out.sessionId, `cs_${i + 1}`);
  }
  assert.notEqual(first.reference, second.reference);
});
