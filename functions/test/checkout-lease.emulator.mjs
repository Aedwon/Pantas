import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {createCheckout} from '../lib/paymongoCheckout.js';
import {fakeAuth} from './_paymongo-helpers.mjs';
import {adult} from './_declaration.mjs';

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
      expireCheckoutSession: async () => true,
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
  await assert.rejects(createCheckout(caller(uid), {product, declaration: adult}, setup({create: () => { throw new Error('PayMongo checkout create failed: 400'); }})),
    /create failed/);
  assert.equal((await pendingDocs(uid)).length, 0);
  const out = await createCheckout(caller(uid), {product, declaration: adult}, setup());
  assert.match(out.checkoutUrl, /^https:/);
  assert.equal((await pendingDocs(uid))[0].get('state'), 'open');
});

test('a lost response leaves the account retryable and the retry makes a new session', async () => {
  const uid = 'lease-lost';
  const first = setup({create: () => { throw new Error('lost response'); }});
  await assert.rejects(createCheckout(caller(uid), {product, declaration: adult}, first), /lost response/);
  const retry = setup({now: () => T0 + LEASE + 1});
  const out = await createCheckout(caller(uid), {product, declaration: adult}, retry);
  assert.equal(retry.created.length, 1);
  assert.notEqual(retry.created[0].referenceNumber, first.created[0].referenceNumber);
  assert.equal(out.reference, retry.created[0].referenceNumber);
  assert.equal((await pendingDocs(uid))[0].get('state'), 'open');
});

test('a creating reservation older than the lease is taken over, a younger one is refused', async () => {
  const uid = 'lease-stale';
  const gate = Promise.withResolvers();
  const slow = createCheckout(caller(uid), {product, declaration: adult}, setup({create: () => gate.promise}));
  while ((await pendingDocs(uid)).length === 0) await new Promise(r => setTimeout(r, 20));
  await assert.rejects(createCheckout(caller(uid), {product, declaration: adult}, setup({now: () => T0 + LEASE - 1})), /pending/);
  const out = await createCheckout(caller(uid), {product, declaration: adult}, setup({now: () => T0 + LEASE}));
  assert.match(out.checkoutUrl, /^https:/);
  gate.reject(new Error('late failure'));
  await assert.rejects(slow);
});

test('a failure during the final write resets the reservation', async () => {
  const uid = 'lease-batch';
  await assert.rejects(createCheckout(caller(uid), {product, declaration: adult}, setup({database: failingWrites('paymongoCheckouts/')})), /final write failed/);
  assert.equal((await pendingDocs(uid)).length, 0);
  const out = await createCheckout(caller(uid), {product, declaration: adult}, setup());
  assert.match(out.checkoutUrl, /^https:/);
});

test('two racing attempts produce one session link and no stranded reservation', async () => {
  const uid = 'lease-race';
  const gate = Promise.withResolvers();
  const a = setup({create: () => gate.promise.then(() => ({id: 'cs_race', checkoutUrl: 'https://checkout.paymongo.test/r'}))});
  const b = setup();
  const first = createCheckout(caller(uid), {product, declaration: adult}, a);
  while ((await pendingDocs(uid)).length === 0) await new Promise(r => setTimeout(r, 20));
  await assert.rejects(createCheckout(caller(uid), {product, declaration: adult}, b), /pending/);
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
  const slowResult = createCheckout(caller(uid), {product, declaration: adult}, slow).then(v => ({v}), error => ({error}));
  while ((await pendingDocs(uid)).length === 0) await new Promise(r => setTimeout(r, 20));
  const newer = await createCheckout(caller(uid), {product, declaration: adult}, setup({now: () => T0 + LEASE + 5}));
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
  await createCheckout(caller(uid), {product, declaration: adult}, setup());
  await assert.rejects(createCheckout(caller(uid), {product, declaration: adult}, setup({create: () => { throw new Error('rejected'); }})), /rejected/);
  assert.equal((await pendingDocs(uid)).length, 0);
  const out = await createCheckout(caller(uid), {product, declaration: adult}, setup());
  assert.match(out.checkoutUrl, /^https:/);
});

const paidRemote = id => ({id, status: 'active', metadata: {}, payments: [{id: 'pay_unconfirmed', amount: 14900, currency: 'PHP', status: 'paid'}]});

test('a previous session already paid but not yet granted never leads to a second session', async () => {
  const uid = 'lease-paid';
  const first = await createCheckout(caller(uid), {product, declaration: adult}, setup());
  const retry = setup();
  retry.client.getCheckoutSession = async id => paidRemote(id);
  await assert.rejects(createCheckout(caller(uid), {product, declaration: adult}, retry), error => {
    assert.equal(error.code, 'failed-precondition');
    assert.equal(error.message, 'Your payment is being confirmed. Pro will appear shortly.');
    return true;
  });
  assert.equal(retry.created.length, 0);
  const rows = await pendingDocs(uid);
  assert.equal(rows.length, 1);
  assert.equal(rows[0].get('state'), 'open');
  assert.equal(rows[0].get('reference'), first.reference);
});

test('once the webhook has granted, a new purchase works as before', async () => {
  const uid = 'lease-granted';
  await createCheckout(caller(uid), {product, declaration: adult}, setup());
  await db.doc('paymongoPayments/pay_unconfirmed').set({uid, processed: true});
  const next = setup();
  next.client.getCheckoutSession = async id => paidRemote(id);
  const out = await createCheckout(caller(uid), {product, declaration: adult}, next);
  assert.equal(next.created.length, 1);
  assert.equal(out.reference, next.created[0].referenceNumber);
});

test('a final write that commits but loses its acknowledgment leaves the reservation open and a retry returns the same link', async () => {
  const uid = 'lease-ack';
  const lossy = new Proxy(db, {get(target, key) {
    if (key !== 'runTransaction') { const v = target[key]; return typeof v === 'function' ? v.bind(target) : v; }
    return async fn => {
      let final = false;
      const result = await target.runTransaction(t => fn(new Proxy(t, {get(tt, k) {
        const v = tt[k];
        if (k === 'set') return (ref, ...rest) => { if (ref.path.startsWith('paymongoCheckouts/')) final = true; return tt.set(ref, ...rest); };
        return typeof v === 'function' ? v.bind(tt) : v;
      }})));
      if (final) throw new Error('acknowledgment lost');
      return result;
    };
  }});
  const first = setup({database: lossy});
  await assert.rejects(createCheckout(caller(uid), {product, declaration: adult}, first), /acknowledgment lost/);
  const rows = await pendingDocs(uid);
  assert.equal(rows.length, 1);
  assert.equal(rows[0].get('state'), 'open');
  const retry = setup();
  retry.client.getCheckoutSession = async id => ({id, status: 'active', metadata: {}, payments: []});
  const out = await createCheckout(caller(uid), {product, declaration: adult}, retry);
  assert.equal(retry.created.length, 0);
  assert.equal(out.reference, rows[0].get('reference'));
  assert.equal(out.checkoutUrl, rows[0].get('checkoutUrl'));
});

const passId = 'pantas_pass_cse_pro';
const firstSitting = {firstDay: '2027-03-14', lastDay: '2027-03-14', sourceUrl: 'https://example.test/s1'};
const nextSitting = {firstDay: '2027-08-08', lastDay: '2027-08-08', sourceUrl: 'https://example.test/s2'};
const passCatalog = [{id: 'exam_cse_pro', publishedSittings: [firstSitting, nextSitting]}];
const beforeSitting = Date.parse('2027-03-10T10:00:00+08:00');
const afterSitting = Date.parse('2027-03-20T10:00:00+08:00');

test('a pass retried after its sitting passed returns the open session; an expired one is replaced', async () => {
  const uid = 'lease-rollover';
  const first = setup({now: () => beforeSitting});
  first.catalog = passCatalog;
  const original = await createCheckout(caller(uid), {product: passId, declaration: adult}, first);
  assert.equal((await pendingDocs(uid)).length, 1);
  // The next sitting now applies, so the sitting key changes. The earlier session is still open and unpaid.
  const retry = setup({now: () => afterSitting});
  retry.catalog = passCatalog;
  retry.client.getCheckoutSession = async id => ({id, status: 'active', metadata: {}, payments: []});
  const again = await createCheckout(caller(uid), {product: passId, declaration: adult}, retry);
  assert.deepEqual(again, original);
  assert.equal(retry.created.length, 0);
  assert.equal((await pendingDocs(uid)).length, 1);
  // Once PayMongo reports it expired, a new session is made for the next sitting.
  const expired = setup({now: () => afterSitting});
  expired.catalog = passCatalog;
  const replaced = await createCheckout(caller(uid), {product: passId, declaration: adult}, expired);
  assert.equal(expired.created.length, 1);
  assert.notEqual(replaced.sessionId, original.sessionId);
  assert.equal((await db.doc(`paymongoOrders/${replaced.reference}`).get()).get('sitting').firstDay, '2027-08-08');
});

// The earlier-sitting session found on a rollover follows the same rules as the same-key session.
async function rolloverWith(uid, remote, extra = {}) {
  const first = setup({now: () => beforeSitting});
  first.catalog = passCatalog;
  const original = await createCheckout(caller(uid), {product: passId, declaration: adult}, first);
  const retry = setup({now: () => afterSitting});
  retry.catalog = passCatalog;
  retry.client.getCheckoutSession = async id => ({id, ...remote(original)});
  Object.assign(retry, extra);
  return {original, retry};
}

test('a rollover finding an earlier session with an unknown status refuses and creates nothing', async () => {
  const {retry} = await rolloverWith('lease-rollover-unknown', () => ({status: 'pending', metadata: {}, payments: []}));
  await assert.rejects(createCheckout(caller('lease-rollover-unknown'), {product: passId, declaration: adult}, retry),
    error => error.message === 'Checkout status is unavailable. Try again later.');
  assert.equal(retry.created.length, 0);
});

test('a rollover finding an earlier pass paid without a grant says it is being confirmed, and heals it after 10 minutes', async () => {
  const uid = 'lease-rollover-paid';
  const paid = original => ({status: 'active', metadata: {uid, product: passId, reference: original.reference},
    payments: [{id: 'pay_roll_1', amount: 49900, currency: 'PHP', status: 'paid', paidAt: afterSitting - 2 * 60_000}]});
  const {retry} = await rolloverWith(uid, paid);
  // Under 10 minutes, or with no way to complete the grant, the caller is told to wait.
  retry.auth = fakeAuth();
  retry.now = () => afterSitting;
  retry.catalog = passCatalog;
  await assert.rejects(createCheckout(caller(uid), {product: passId, declaration: adult}, retry),
    error => error.message === 'Your payment is being confirmed. Pro will appear shortly.');
  assert.equal(retry.created.length, 0);
  assert.equal((await db.doc('paymongoPayments/pay_roll_1').get()).exists, false);
  // After 10 minutes the call completes the grant through the shared path and answers already-paid: no link in that call.
  retry.now = () => afterSitting + 11 * 60_000;
  await assert.rejects(createCheckout(caller(uid), {product: passId, declaration: adult}, retry),
    error => error.code === 'already-exists' && error.details?.reason === 'already-paid');
  assert.equal((await db.doc('paymongoPayments/pay_roll_1').get()).get('uid'), uid);
  assert.equal((await db.doc(`users/${uid}/grants/pay_roll_1`).get()).exists, true);
  assert.equal(retry.created.length, 0);
});

// Another sitting key's reservation counts exactly as the same key's (review 8).
const seedOther = (uid, row) => db.doc(`users/${uid}/pendingCheckouts/earlier-sitting-key`)
  .set({product: passId, reference: 'ref_earlier', ...row});

test('a rollover finding another key still creating within its lease says pending and returns no link', async () => {
  const uid = 'lease-other-creating';
  await seedOther(uid, {state: 'creating', createdAt: afterSitting - 30_000});
  const retry = setup({now: () => afterSitting});
  retry.catalog = passCatalog;
  await assert.rejects(createCheckout(caller(uid), {product: passId, declaration: adult}, retry), /pending/);
  assert.equal(retry.created.length, 0);
  // Once its lease lapses, the reservation no longer blocks.
  const later = setup({now: () => afterSitting + LEASE});
  later.catalog = passCatalog;
  assert.match((await createCheckout(caller(uid), {product: passId, declaration: adult}, later)).checkoutUrl, /^https:/);
});

test('a rollover finding another key creating, and an older open one, never returns the open link', async () => {
  const uid = 'lease-other-creating-open';
  const first = setup({now: () => beforeSitting});
  first.catalog = passCatalog;
  await createCheckout(caller(uid), {product: passId, declaration: adult}, first);
  await seedOther(uid, {state: 'creating', createdAt: afterSitting - 30_000});
  const retry = setup({now: () => afterSitting});
  retry.catalog = passCatalog;
  retry.client.getCheckoutSession = async id => ({id, status: 'active', metadata: {}, payments: []});
  await assert.rejects(createCheckout(caller(uid), {product: passId, declaration: adult}, retry), /pending/);
  assert.equal(retry.created.length, 0);
});

test('another key that turns open between the scan and the reservation write blocks the new link', async () => {
  const uid = 'lease-other-opens-late';
  // The scan finds an old open reservation whose session is expired, so it may be replaced.
  await seedOther(uid, {state: 'open', createdAt: beforeSitting, sessionId: 'cs_old', checkoutUrl: 'https://checkout.paymongo.test/old'});
  const retry = setup({now: () => afterSitting});
  retry.catalog = passCatalog;
  // Before the reservation write, that key is replaced by another live session (another request got there first).
  retry.client.getCheckoutSession = async id => {
    await seedOther(uid, {state: 'open', createdAt: afterSitting, sessionId: 'cs_raced', reference: 'ref_raced', checkoutUrl: 'https://checkout.paymongo.test/raced'});
    return {id, status: 'expired', metadata: {}, payments: []};
  };
  await assert.rejects(createCheckout(caller(uid), {product: passId, declaration: adult}, retry), /pending/);
  assert.equal(retry.created.length, 0);
});

test('an earlier-sitting call that outlives its lease cannot issue a second payable link after a rollover', async () => {
  const uid = 'lease-outlives';
  const earlier = setup({now: () => beforeSitting});
  earlier.catalog = passCatalog;
  let rolled;
  const slow = earlier.client.createCheckoutSession;
  earlier.client.createCheckoutSession = async input => {
    // While the earlier call is still making its session, its lease lapses and the rollover call runs to the end.
    const rollover = setup({now: () => afterSitting});
    rollover.catalog = passCatalog;
    rolled = await createCheckout(caller(uid), {product: passId, declaration: adult}, rollover);
    return slow(input);
  };
  const expired = [];
  earlier.client.expireCheckoutSession = async id => { expired.push(id); return true; };
  earlier.client.getCheckoutSession = async id => ({id, status: 'expired', metadata: {}, payments: []});
  await assert.rejects(createCheckout(caller(uid), {product: passId, declaration: adult}, earlier), /pending/);
  assert.match(rolled.checkoutUrl, /^https:/);
  assert.equal(expired.length, 1);
  assert.notEqual(expired[0], rolled.sessionId);
  const open = (await pendingDocs(uid)).filter(d => d.get('state') === 'open');
  assert.equal(open.length, 1);
  assert.equal(open[0].get('sessionId'), rolled.sessionId);
});

test('a rollover finding another key unissued settles it first, then makes the new link', async () => {
  const uid = 'lease-other-unissued';
  await seedOther(uid, {state: 'unissued', createdAt: beforeSitting, unissuedSessionId: 'cs_unissued_old'});
  const retry = setup({now: () => afterSitting});
  retry.catalog = passCatalog;
  const calls = [];
  retry.client.expireCheckoutSession = async id => { calls.push(['expire', id]); return true; };
  retry.client.getCheckoutSession = async id => { calls.push(['get', id]); return {id, status: 'expired', metadata: {}, payments: []}; };
  const create = retry.client.createCheckoutSession;
  retry.client.createCheckoutSession = async input => { calls.push(['create']); return create(input); };
  await createCheckout(caller(uid), {product: passId, declaration: adult}, retry);
  assert.deepEqual(calls[0], ['expire', 'cs_unissued_old']);
  assert.ok(calls.findIndex(c => c[0] === 'create') > 0);
  assert.equal((await db.doc(`users/${uid}/pendingCheckouts/earlier-sitting-key`).get()).exists, false);
});

test('a rollover finding another key unissued that is not confirmed expired makes no link', async () => {
  const uid = 'lease-other-unissued-live';
  await seedOther(uid, {state: 'unissued', createdAt: beforeSitting, unissuedSessionId: 'cs_unissued_live'});
  const retry = setup({now: () => afterSitting});
  retry.catalog = passCatalog;
  retry.client.getCheckoutSession = async id => ({id, status: 'active', metadata: {}, payments: []});
  await assert.rejects(createCheckout(caller(uid), {product: passId, declaration: adult}, retry),
    error => error.message === 'Checkout status is unavailable. Try again later.');
  assert.equal(retry.created.length, 0);
  assert.equal((await db.doc(`users/${uid}/pendingCheckouts/earlier-sitting-key`).get()).get('state'), 'unissued');
});

test('a reused session that the second read reports expired is replaced, never returned', async () => {
  const uid = 'lease-reuse-expired';
  const original = await createCheckout(caller(uid), {product, declaration: adult}, setup());
  const retry = setup();
  let reads = 0;
  retry.client.getCheckoutSession = async id => ({id, status: ++reads === 1 ? 'active' : 'expired', metadata: {}, payments: []});
  const out = await createCheckout(caller(uid), {product, declaration: adult}, retry);
  assert.equal(retry.created.length, 1);
  assert.notEqual(out.sessionId, original.sessionId);
});

test('a reused earlier-sitting session that the second read reports expired is replaced, never returned', async () => {
  const uid = 'lease-reuse-expired-rollover';
  const first = setup({now: () => beforeSitting});
  first.catalog = passCatalog;
  const original = await createCheckout(caller(uid), {product: passId, declaration: adult}, first);
  const retry = setup({now: () => afterSitting});
  retry.catalog = passCatalog;
  let reads = 0;
  retry.client.getCheckoutSession = async id => ({id, status: ++reads === 1 ? 'active' : 'expired', metadata: {}, payments: []});
  const out = await createCheckout(caller(uid), {product: passId, declaration: adult}, retry);
  assert.equal(retry.created.length, 1);
  assert.notEqual(out.sessionId, original.sessionId);
});
