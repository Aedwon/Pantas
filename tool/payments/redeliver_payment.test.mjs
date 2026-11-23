import assert from 'node:assert/strict';
import test from 'node:test';
import {normalizePaymongoEvent, verifyPaymongoSignature} from '../../functions/lib/paymongoPolicy.js';
import {redeliverPayment} from './redeliver_payment.mjs';

const SECRET_KEY = 'sk_test_SECRETKEYVALUE123';
const WEBHOOK_SECRET = 'whsk_SECRETWEBHOOKVALUE456';
const now = Date.parse('2027-03-14T12:00:00Z');
const session = {data: {id: 'cs_abc123', type: 'checkout_session', attributes: {
  metadata: {uid: 'u1', product: 'pantas_cs_monthly', reference: '11111111-1111-1111-1111-111111111111'},
  payments: [{id: 'pay_1', attributes: {amount: 14900, currency: 'PHP', status: 'paid', paid_at: 1800000000}}]}}};

function harness({secrets = {PAYMONGO_SECRET_KEY: SECRET_KEY, PAYMONGO_WEBHOOK_SECRET: WEBHOOK_SECRET},
  read = session, status = 200} = {}) {
  const calls = [], lines = [];
  const fetchImpl = async (url, init) => {
    calls.push({url, init});
    if (init.method === 'GET') return {ok: true, status: 200, json: async () => read};
    return {ok: status === 200, status, json: async () => ({ok: status === 200})};
  };
  const run = project => redeliverPayment({project, sessionId: 'cs_abc123', fetchImpl, now: () => now,
    readSecrets: () => secrets, log: (...args) => lines.push(args.join(' '))});
  return {calls, lines, run};
}

test('the signed event verifies with the webhook handler own check and carries the session', async () => {
  const {calls, lines, run} = harness();
  assert.equal(await run('pantas-staging'), 200);
  const get = calls[0], post = calls[1];
  assert.equal(get.url, 'https://api.paymongo.com/v1/checkout_sessions/cs_abc123');
  assert.equal(get.init.headers.Authorization, `Basic ${Buffer.from(`${SECRET_KEY}:`).toString('base64')}`);
  assert.equal(post.url, 'https://asia-southeast1-pantas-staging.cloudfunctions.net/paymongoWebhook');
  const raw = Buffer.from(post.init.body);
  const header = post.init.headers['Paymongo-Signature'];
  assert.equal(verifyPaymongoSignature(raw, header, WEBHOOK_SECRET, false, now), true);
  assert.equal(verifyPaymongoSignature(raw, header, 'wrong', false, now), false);
  const event = normalizePaymongoEvent(JSON.parse(post.init.body));
  assert.equal(event.type, 'checkout_session.payment.paid');
  assert.equal(event.data.id, 'cs_abc123');
  assert.equal(event.data.type, 'checkout_session');
  assert.deepEqual(event.data.attributes.metadata, session.data.attributes.metadata);
  assert.equal(event.livemode, false);
  assert.equal(lines.some(line => line.includes(SECRET_KEY) || line.includes(WEBHOOK_SECRET)), false);
});

test('a live key signs with the live field', async () => {
  const {calls, run} = harness({secrets: {PAYMONGO_SECRET_KEY: 'sk_live_X', PAYMONGO_WEBHOOK_SECRET: WEBHOOK_SECRET}});
  await run('pantas-prod');
  const post = calls[1];
  assert.equal(verifyPaymongoSignature(Buffer.from(post.init.body), post.init.headers['Paymongo-Signature'],
    WEBHOOK_SECRET, true, now), true);
});

test('bad arguments, an unpaid session and a failed delivery print no secret', async () => {
  const {lines, run, calls} = harness();
  await assert.rejects(run('pantas-dev'), /arguments/);
  const unpaid = harness({read: {data: {...session.data, attributes: {...session.data.attributes, payments: []}}}});
  await assert.rejects(unpaid.run('pantas-prod'), /no paid payment/);
  assert.equal(unpaid.calls.length, 1);
  const failed = harness({status: 500});
  assert.equal(await failed.run('pantas-prod'), 500);
  for (const text of [...lines, ...unpaid.lines, ...failed.lines]) {
    assert.equal(text.includes(SECRET_KEY) || text.includes(WEBHOOK_SECRET), false);
  }
  assert.equal(calls.length, 0);
});
