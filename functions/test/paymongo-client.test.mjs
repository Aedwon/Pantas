import assert from 'node:assert/strict';
import test from 'node:test';
import {httpPaymongoClient} from '../lib/paymongoClient.js';

const input = {uid: 'u1', product: 'pantas_cs_monthly', name: 'Pantas', amountCentavos: 14900,
  successUrl: 'https://x.test/ok', cancelUrl: 'https://x.test/no', paymentMethodTypes: ['card', 'gcash'], referenceNumber: 'ref-1'};

test('checkout create posts the v2 body with Basic auth, metadata uid and product', async () => {
  const calls = [];
  const client = httpPaymongoClient('sk_test_abc', async (url, init) => {
    calls.push({url, init});
    return {ok: true, status: 200, json: async () => ({data: {id: 'cs_9', attributes: {checkout_url: 'https://checkout.paymongo.com/z'}}})};
  });
  assert.deepEqual(await client.createCheckoutSession(input), {id: 'cs_9', checkoutUrl: 'https://checkout.paymongo.com/z'});
  assert.equal(calls[0].url, 'https://api.paymongo.com/v2/checkout_sessions');
  assert.equal(calls[0].init.headers.Authorization, `Basic ${Buffer.from('sk_test_abc:').toString('base64')}`);
  const attrs = JSON.parse(calls[0].init.body).data.attributes;
  assert.deepEqual(attrs.metadata, {uid: 'u1', product: 'pantas_cs_monthly', reference: 'ref-1'});
  assert.deepEqual(attrs.line_items, [{name: 'Pantas', amount: 14900, currency: 'PHP', quantity: 1}]);
  assert.deepEqual(attrs.payment_method_types, ['card', 'gcash']);
  assert.equal(attrs.success_url, 'https://x.test/ok');
});

test('checkout create fails on an error status or a missing or non-https URL', async () => {
  const make = response => httpPaymongoClient('k', async () => response);
  await assert.rejects(make({ok: false, status: 400, json: async () => ({})}).createCheckoutSession(input));
  await assert.rejects(make({ok: true, status: 200, json: async () => ({data: {id: 'cs'}})}).createCheckoutSession(input));
  await assert.rejects(make({ok: true, status: 200, json: async () => ({data: {id: 'cs', attributes: {checkout_url: 'http://x'}}})}).createCheckoutSession(input));
});

test('session read parses metadata and payments, falls back to the nested intent, rejects odd ids', async () => {
  const body = attrs => ({ok: true, status: 200, json: async () => ({data: {id: 'cs_1', attributes: attrs}})});
  const pay = {id: 'pay_1', attributes: {amount: 14900, currency: 'PHP', status: 'paid', paid_at: 1792461600}};
  let url;
  const top = httpPaymongoClient('k', async u => {url = u; return body({metadata: {uid: 'u1', n: 5}, payments: [pay]});});
  assert.deepEqual(await top.getCheckoutSession('cs_1'), {id: 'cs_1', status: '', metadata: {uid: 'u1'},
    payments: [{id: 'pay_1', amount: 14900, currency: 'PHP', status: 'paid', paidAt: 1792461600000}]});
  assert.equal(url, 'https://api.paymongo.com/v1/checkout_sessions/cs_1');
  const nested = httpPaymongoClient('k', async () => body({metadata: {}, payment_intent: {attributes: {payments: [pay]}}}));
  assert.equal((await nested.getCheckoutSession('cs_1')).payments[0].id, 'pay_1');
  await assert.rejects(top.getCheckoutSession('../x'));
  await assert.rejects(httpPaymongoClient('k', async () => ({ok: true, status: 200, json: async () => ({data: {id: 'cs_other', attributes: {}}})})).getCheckoutSession('cs_1'));
  await assert.rejects(httpPaymongoClient('k', async () => ({ok: false, status: 404})).getCheckoutSession('cs_1'));
});

test('refund read calls GET /v1/refunds/{id} and parses amount, status and payment id', async () => {
  let call;
  const client = httpPaymongoClient('k', async (url, init) => {call = {url, init};
    return {ok: true, status: 200, json: async () => ({data: {id: 'ref_1', type: 'refund', attributes: {amount: 5000, status: 'succeeded', payment_id: 'pay_9'}}})};});
  assert.deepEqual(await client.getRefund('ref_1'), {id: 'ref_1', amount: 5000, status: 'succeeded', paymentId: 'pay_9'});
  assert.equal(call.url, 'https://api.paymongo.com/v1/refunds/ref_1');
  assert.equal(call.init.method, 'GET');
  await assert.rejects(client.getRefund('../x'));
  await assert.rejects(httpPaymongoClient('k', async () => ({ok: true, status: 200, json: async () => ({data: {id: 'ref_2', attributes: {}}})})).getRefund('ref_1'));
  await assert.rejects(httpPaymongoClient('k', async () => ({ok: false, status: 404})).getRefund('ref_1'));
});
