import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {createCheckout} from '../lib/paymongoCheckout.js';

const db = getFirestore();
const T0 = Date.parse('2026-11-10T10:00:00+08:00');
const LEASE = 2 * 60_000;
const product = 'pantas_cs_monthly';
const caller = uid => ({uid, token: {firebase: {sign_in_provider: 'google.com'}}});
const pendingDocs = async uid => (await db.collection(`users/${uid}/pendingCheckouts`).get()).docs;

function setup({create, now = () => T0, database = db} = {}) {
  const created = [];
  return {created, db: database, origin: 'https://pantas.test', methods: ['card'], allow: async () => true, now,
    client: {
      getCheckoutSession: async id => ({id, status: 'expired', metadata: {}, payments: []}),
      createCheckoutSession: async input => {
        created.push(input);
        if (create) return create(input, created.length);
        return {id: `cs_${input.referenceNumber}`, checkoutUrl: 'https://checkout.paymongo.test/x'};
      }}};
}

// Fails any transaction write to a collection, as a timed-out final write would.
function failingWrites(prefix) {
  return new Proxy(db, {get(target, key) {
    if (key !== 'runTransaction') { const v = target[key]; return typeof v === 'function' ? v.bind(target) : v; }
    return fn => target.runTransaction(t => fn(new Proxy(t, {get(tt, k) {
      const v = tt[k];
      if (k === 'set') return (ref, ...rest) => {
        if (ref.path.startsWith(prefix)) throw new Error('final write failed');
        return tt.set(ref, ...rest);
      };
      return typeof v === 'function' ? v.bind(tt) : v;
    }})));
  }});
}

test('a definite PayMongo rejection resets the reservation at once and a retry succeeds', async () => {
  const uid = 'lease-reject';
  await assert.rejects(createCheckout(caller(uid), {product}, setup({create: () => { throw new Error('PayMongo checkout create failed: 400'); }})),
    /create failed/);
  assert.equal((await pendingDocs(uid)).length, 0);
  const out = await createCheckout(caller(uid), {product}, setup());
  assert.match(out.checkoutUrl, /^https:/);
  assert.equal((await pendingDocs(uid))[0].get('state'), 'open');
});

test('a lost response leaves the account retryable and the retry makes a new session', async () => {
  const uid = 'lease-lost';
  const first = setup({create: () => { throw new Error('lost response'); }});
  await assert.rejects(createCheckout(caller(uid), {product}, first), /lost response/);
  const retry = setup({now: () => T0 + LEASE + 1});
  const out = await createCheckout(caller(uid), {product}, retry);
  assert.equal(retry.created.length, 1);
  assert.notEqual(retry.created[0].referenceNumber, first.created[0].referenceNumber);
  assert.equal(out.reference, retry.created[0].referenceNumber);
  assert.equal((await pendingDocs(uid))[0].get('state'), 'open');
});

test('a creating reservation older than the lease is taken over, a younger one is refused', async () => {
  const uid = 'lease-stale';
  const gate = Promise.withResolvers();
  const slow = createCheckout(caller(uid), {product}, setup({create: () => gate.promise}));
  while ((await pendingDocs(uid)).length === 0) await new Promise(r => setTimeout(r, 20));
  await assert.rejects(createCheckout(caller(uid), {product}, setup({now: () => T0 + LEASE - 1})), /pending/);
  const out = await createCheckout(caller(uid), {product}, setup({now: () => T0 + LEASE}));
  assert.match(out.checkoutUrl, /^https:/);
  gate.reject(new Error('late failure'));
  await assert.rejects(slow);
});

test('a failure during the final write resets the reservation', async () => {
  const uid = 'lease-batch';
  await assert.rejects(createCheckout(caller(uid), {product}, setup({database: failingWrites('paymongoCheckouts/')})), /final write failed/);
  assert.equal((await pendingDocs(uid)).length, 0);
  const out = await createCheckout(caller(uid), {product}, setup());
  assert.match(out.checkoutUrl, /^https:/);
});

test('two racing attempts produce one session link and no stranded reservation', async () => {
  const uid = 'lease-race';
  const gate = Promise.withResolvers();
  const a = setup({create: () => gate.promise.then(() => ({id: 'cs_race', checkoutUrl: 'https://checkout.paymongo.test/r'}))});
  const b = setup();
  const first = createCheckout(caller(uid), {product}, a);
  while ((await pendingDocs(uid)).length === 0) await new Promise(r => setTimeout(r, 20));
  await assert.rejects(createCheckout(caller(uid), {product}, b), /pending/);
  assert.equal(b.created.length, 0);
  gate.resolve();
  const out = await first;
  const rows = await pendingDocs(uid);
  assert.equal(rows.length, 1);
  assert.equal(rows[0].get('state'), 'open');
  assert.equal(rows[0].get('reference'), out.reference);
});

test('a slow attempt finishing after a newer one succeeded does not overwrite it and returns no link', async () => {
  const uid = 'lease-slow';
  const gate = Promise.withResolvers();
  const slow = setup({create: () => gate.promise.then(() => ({id: 'cs_slow', checkoutUrl: 'https://checkout.paymongo.test/slow'}))});
  const slowResult = createCheckout(caller(uid), {product}, slow).then(v => ({v}), error => ({error}));
  while ((await pendingDocs(uid)).length === 0) await new Promise(r => setTimeout(r, 20));
  const newer = await createCheckout(caller(uid), {product}, setup({now: () => T0 + LEASE + 5}));
  gate.resolve();
  const settled = await slowResult;
  assert.equal(settled.v, undefined);
  assert.ok(settled.error, 'the slow attempt must not return a link');
  const rows = await pendingDocs(uid);
  assert.equal(rows.length, 1);
  assert.equal(rows[0].get('state'), 'open');
  assert.equal(rows[0].get('sessionId'), newer.sessionId);
  assert.equal((await db.doc('paymongoCheckouts/cs_slow').get()).exists, false);
});

test('a failed replacement of an expired open checkout resets and a retry succeeds', async () => {
  const uid = 'lease-replace';
  await createCheckout(caller(uid), {product}, setup());
  await assert.rejects(createCheckout(caller(uid), {product}, setup({create: () => { throw new Error('rejected'); }})), /rejected/);
  assert.equal((await pendingDocs(uid)).length, 0);
  const out = await createCheckout(caller(uid), {product}, setup());
  assert.match(out.checkoutUrl, /^https:/);
});
