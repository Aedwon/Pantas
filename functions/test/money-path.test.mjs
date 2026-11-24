import assert from 'node:assert/strict';
import test from 'node:test';
import {commitPaymongoGrant} from '../lib/paymongoGrants.js';
import {webProduct, priceCentavos, addPrepaid} from '../lib/paymongoPolicy.js';
import {shortenedEnd} from '../lib/grants.js';
import {commitRevenueCatAnswer} from '../lib/revenuecatClaims.js';
import {adult} from './_declaration.mjs';

const uid = 'money-path-test';
const now = Date.parse('2027-03-14T12:00:00Z');
const product = webProduct('pantas_cs_monthly');

function firestore(seed = {}) {
  const rows = new Map(Object.entries(seed));
  const snapshot = ref => ({ref, id: ref.path.split('/').at(-1), exists: rows.has(ref.path),
    get: key => rows.get(ref.path)?.[key], data: () => rows.get(ref.path)});
  const doc = path => ({path, get: async () => snapshot({path}), set: async value => rows.set(path, value)});
  const collection = path => ({path, collection: true, doc: () => doc(`${path}/audit`), add: async () => {},
    where: () => ({limit: () => ({query: true, path})})});
  const get = async ref => ref.query ? {empty: true, docs: []} : ref.collection ? {docs: [...rows.keys()]
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
  return {doc, collection, runTransaction, rows, getAll: (...refs) => Promise.all(refs.map(get))};
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

test('checkout records its quote and reuses an open session even after the price changed', async () => {
  const {createCheckout} = await import('../lib/paymongoCheckout.js');
  const db = firestore();
  let count = 0;
  const auth = {uid, token: {email: 'buyer@example.test', email_verified: true,
    firebase: {sign_in_provider: 'google.com'}}};
  const client = {createCheckoutSession: async () => ({id: `cs_quote_${++count}`, checkoutUrl: 'https://example.test'}),
    getCheckoutSession: async () => ({status: 'active', payments: [], metadata: {uid}})};
  const deps = {db, client, origin: 'https://example.test', methods: ['card'], now: () => now, allow: async () => true};
  const first = await createCheckout(auth, {product: product.id, declaration: adult}, deps);
  assert.equal(db.rows.get(`paymongoOrders/${first.reference}`).amountCentavos, payment.paidAmount);
  const pending = [...db.rows.keys()].find(path => path.startsWith(`users/${uid}/pendingCheckouts/`));
  db.rows.get(pending).amountCentavos = payment.paidAmount - 100;
  const second = await createCheckout(auth, {product: product.id, declaration: adult}, deps);
  assert.equal(second.reference, first.reference);
  assert.equal(second.sessionId, first.sessionId);
  assert.equal(count, 1);
});

async function deliverPayment(db, amount, reference, auth = {getUser: async () => ({customClaims: {}}), setCustomUserClaims: async () => {}}) {
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
    sessionId: payment.sessionId, amountCentavos: quote}});
  assert.equal(db.rows.has(`webhookEvents/${payment.eventId}/users/${uid}`), false);
  assert.equal(await deliverPayment(db, quote, reference), 200);
  assert.equal(db.rows.has('paymongoFollowUps/pay_test'), false);
  const grant = db.rows.get(`users/${uid}/grants/pay_test`);
  assert.equal(grant.state, 'active');
  assert.equal(grant.paidAmount, quote);
  assert.equal(db.rows.get(`users/${uid}/server/entitlement`).pro, true);
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

const planRow = (startsAt, endsAt) => ({source: 'paymongo', product: product.id,
  tier: product.tier, startsAt, endsAt, state: 'active', createdAt: now});

test('exam-only coverage cannot anchor a tier-wide plan or its re-anchor', async () => {
  const {planGrant, reanchorQueued} = await import('../lib/paymongoGrants.js');
  const exam = {...planRow(now, now + 1000), product: pass.id};
  const trial = {...planRow(now, now + 500), source: 'trial', product: 'web_trial'};
  assert.equal(planGrant(product, [exam, trial], now, []).startsAt, trial.endsAt);
  const queued = new Map([['plan', planRow(now + 1000, now + 2000)]]);
  assert.equal(reanchorQueued(queued, [exam, trial], now).get('plan').startsAt, trial.endsAt);
});

test('refunding the third plan keeps the second plan in the replan cursor', async () => {
  const {replanAfterRevoke} = await import('../lib/paymongoGrants.js');
  const rows = new Map(['a', 'b', 'c', 'd'].map((id, i) =>
    [id, planRow(now + i * 1000, now + (i + 1) * 1000)]));
  rows.get('c').state = 'revoked';
  assert.equal(replanAfterRevoke(rows, 'c', now + 1).get('d').startsAt, rows.get('b').endsAt);
});

test('repair starts an exam-only anchored plan now and preserves its exact length', async () => {
  const {repairExamOnlyQueuedPlans} = await import('../lib/paymongoGrants.js');
  const root = `users/${uid}/grants`;
  const db = firestore({
    [`${root}/pass`]: {...planRow(now - 1, now + 1000), product: pass.id},
    [`${root}/plan`]: planRow(now + 1000, now + 2000),
    [`${root}/later`]: planRow(now + 2000, now + 3000),
  });
  assert.equal(await repairExamOnlyQueuedPlans(db, uid, now), 2);
  assert.equal(db.rows.get(`${root}/plan`).startsAt, now);
  assert.equal(db.rows.get(`${root}/later`).endsAt, now + 2000);
  assert.equal(await repairExamOnlyQueuedPlans(db, uid, now), 0);
});

test('a dispute win re-chains the next plan behind the restored end', async () => {
  const {resolvePaymongoDispute, revokePaymongoPayment} = await import('../lib/paymongoGrants.js');
  const db = firestore();
  await commitPaymongoGrant(db, payment, now, []);
  await commitPaymongoGrant(db, {...payment, eventId: 'evt_next', paymentId: 'pay_next'}, now, []);
  const firstEnd = db.rows.get(`users/${uid}/grants/pay_test`).endsAt;
  const ids = {paymentId: payment.paymentId, disputeId: 'disp_test'};
  await revokePaymongoPayment(db, {...ids, eventId: 'evt_open', dispute: true, reason: 'dispute.created'}, now + 1);
  await resolvePaymongoDispute(db, {...ids, eventId: 'evt_win', won: true}, now + 2);
  assert.equal(db.rows.get(`users/${uid}/grants/pay_next`).startsAt, firstEnd);
});

for (const beforePayment of [false, true]) {
  test(`a loss revokes without an opening event (before payment: ${beforePayment})`, async () => {
    const {resolvePaymongoDispute} = await import('../lib/paymongoGrants.js');
    const db = firestore();
    if (!beforePayment) await commitPaymongoGrant(db, payment, now, []);
    await resolvePaymongoDispute(db, {eventId: 'evt_loss', paymentId: payment.paymentId,
      disputeId: 'disp_test', won: false}, now + 1);
    if (beforePayment) await commitPaymongoGrant(db, payment, now + 2, []);
    const grant = db.rows.get(`users/${uid}/grants/pay_test`);
    assert.equal(grant.state, 'revoked');
    assert.equal(grant.disputeResolved, true);
  });
}

test('the entitlement read still returns the grant when the claims copy fails', async () => {
  const {webEntitlement} = await import('../lib/webEntitlement.js');
  const db = firestore({[`users/${uid}/grants/pay_test`]: planRow(now - 1, now + 1000),
    [`users/${uid}/server/entitlement`]: {version: 2, claimsVersion: 1, claimsPending: true,
      claimsLeaseHolder: 'other', claimsLeaseUntil: {toMillis: () => Date.now() + 60_000}}});
  const claimAuth = {getUser: async () => {throw new Error('busy');}, setCustomUserClaims: async () => {}};
  const result = await webEntitlement({uid, token: {}}, db, now, claimAuth);
  assert.equal(result.grants.length, 1);
  assert.equal(result.grants[0].product, product.id);
});

test('a refund follow-up from the grant path logs one ERROR line with the payment id only', async () => {
  const {mock} = await import('node:test');
  const lines = [];
  const spy = mock.method(console, 'error', (...args) => lines.push(args));
  try {
    const db = firestore({[`accountDeletions/${uid}`]: {}});
    assert.equal(await commitPaymongoGrant(db, payment, now, []), 'accountDeleted');
    await commitPaymongoGrant(firestore(), {...payment, paymentId: 'pay_ok'}, now, []);
  } finally { spy.mock.restore(); }
  assert.equal(lines.length, 1);
  assert.equal(lines[0][0], 'payment follow-up created accountDeleted');
  assert.deepEqual(lines[0].slice(1), [{paymentId: 'pay_test'}]);
});

test('redelivering a fulfilled payment of a deleted account opens no refund task', async () => {
  const marker = {accountDeleted: true, deletedAt: now};
  const db = firestore({[`accountDeletions/${uid}`]: {}, 'paymongoPayments/pay_test': marker});
  assert.equal(await commitPaymongoGrant(db, {...payment, eventId: 'evt_again'}, now, []), 'accountDeleted');
  assert.equal(db.rows.has('paymongoFollowUps/pay_test'), false);
  assert.deepEqual(db.rows.get('paymongoPayments/pay_test'), marker);
});

test('a refund or dispute for a payment kept without an account is unmatched and does not crash', async () => {
  const {revokePaymongoPayment, resolvePaymongoDispute} = await import('../lib/paymongoGrants.js');
  const db = firestore({'paymongoPayments/pay_test': {accountDeleted: true, deletedAt: now}});
  const refund = await revokePaymongoPayment(db, {eventId: 'evt_r', paymentId: 'pay_test', reason: 'refund',
    refunds: [{id: 'r1', amount: 100}]}, now);
  assert.equal(refund.outcome, 'unmatched');
  assert.equal(db.rows.get('paymongoRevocations/pay_test').refunds.r1, 100);
  const dispute = await revokePaymongoPayment(db, {eventId: 'evt_d', paymentId: 'pay_test', reason: 'dispute.created',
    dispute: true, disputeId: 'disp_x'}, now);
  assert.equal(dispute.outcome, 'unmatched');
  assert.equal(await resolvePaymongoDispute(db, {eventId: 'evt_w', paymentId: 'pay_test', disputeId: 'disp_x', won: true}, now), undefined);
});

const weekly = webProduct('pantas_cs_weekly');
const WEEK = 7 * 86_400_000;

async function monthlyWithQueuedWeek() {
  const db = firestore();
  await commitPaymongoGrant(db, payment, now, []);
  await commitPaymongoGrant(db, {...payment, eventId: 'evt_week', paymentId: 'pay_week', product: weekly,
    paidAmount: priceCentavos(weekly)}, now, []);
  const month = db.rows.get(`users/${uid}/grants/pay_test`);
  const week = db.rows.get(`users/${uid}/grants/pay_week`);
  assert.equal(week.startsAt, month.endsAt);
  return {db, originalEnd: week.endsAt, monthEnd: month.endsAt, week};
}

const coverageEnd = db => Math.max(...[...db.rows].filter(([path]) => path.startsWith(`users/${uid}/grants/`))
  .filter(([, row]) => row.state === 'active').map(([, row]) => row.endsAt));

test('a dispute records the schedule of each grant it pulls forward', async () => {
  const {revokePaymongoPayment} = await import('../lib/paymongoGrants.js');
  const {db, week} = await monthlyWithQueuedWeek();
  await revokePaymongoPayment(db, {eventId: 'evt_open', paymentId: payment.paymentId, disputeId: 'disp_test',
    dispute: true, reason: 'dispute.created'}, now + 1000);
  const moved = db.rows.get(`users/${uid}/grants/pay_week`);
  assert.equal(moved.startsAt, now + 1000);
  assert.equal(moved.disputeMoves.disp_test.startsAt, week.startsAt);
  assert.equal(moved.disputeMoves.disp_test.endsAt, week.endsAt);
});

test('a dispute win after the pulled-forward week ended restores the original coverage end', async () => {
  const {revokePaymongoPayment, resolvePaymongoDispute} = await import('../lib/paymongoGrants.js');
  const {db, originalEnd} = await monthlyWithQueuedWeek();
  await revokePaymongoPayment(db, {eventId: 'evt_open', paymentId: payment.paymentId, disputeId: 'disp_test',
    dispute: true, reason: 'dispute.created'}, now + 1000);
  // The week ran and ended while the dispute was open.
  await resolvePaymongoDispute(db, {eventId: 'evt_win', paymentId: payment.paymentId, disputeId: 'disp_test',
    won: true}, now + WEEK + 5000);
  assert.equal(db.rows.get(`users/${uid}/grants/pay_test`).state, 'active');
  assert.equal(coverageEnd(db), originalEnd);
  const week = db.rows.get(`users/${uid}/grants/pay_week`);
  assert.equal(week.startsAt, db.rows.get(`users/${uid}/grants/pay_test`).endsAt);
  assert.equal(week.endsAt - week.startsAt, WEEK);
});

test('a dispute win re-chains a moved grant from its current length when a later change moved it again', async () => {
  const {revokePaymongoPayment, resolvePaymongoDispute} = await import('../lib/paymongoGrants.js');
  const {db, monthEnd} = await monthlyWithQueuedWeek();
  await revokePaymongoPayment(db, {eventId: 'evt_open', paymentId: payment.paymentId, disputeId: 'disp_test',
    dispute: true, reason: 'dispute.created'}, now + 1000);
  const weekRow = db.rows.get(`users/${uid}/grants/pay_week`);
  const shorter = {...weekRow, endsAt: weekRow.endsAt - 86_400_000, fullEndsAt: weekRow.fullEndsAt - 86_400_000};
  db.rows.set(`users/${uid}/grants/pay_week`, shorter);
  await resolvePaymongoDispute(db, {eventId: 'evt_win', paymentId: payment.paymentId, disputeId: 'disp_test',
    won: true}, now + 2000);
  const week = db.rows.get(`users/${uid}/grants/pay_week`);
  assert.equal(week.startsAt, monthEnd);
  assert.equal(week.endsAt - week.startsAt, WEEK - 86_400_000);
});

test('an opening event for a dispute already won never revokes, even after its dedupe marker expired', async () => {
  const {revokePaymongoPayment, resolvePaymongoDispute} = await import('../lib/paymongoGrants.js');
  const db = firestore();
  await commitPaymongoGrant(db, payment, now, []);
  const open = {paymentId: payment.paymentId, disputeId: 'disp_test', dispute: true, reason: 'dispute.created'};
  await revokePaymongoPayment(db, {...open, eventId: 'evt_open'}, now + 1);
  await resolvePaymongoDispute(db, {eventId: 'evt_win', paymentId: payment.paymentId, disputeId: 'disp_test', won: true}, now + 2);
  assert.equal(db.rows.get(`users/${uid}/grants/pay_test`).state, 'active');
  db.rows.delete(`webhookEvents/evt_open/users/${uid}`);
  await revokePaymongoPayment(db, {...open, eventId: 'evt_open'}, now + 3);
  assert.equal(db.rows.get(`users/${uid}/grants/pay_test`).state, 'active');
});

test('repair also moves a plan queued at the original end of a pass that was postponed since', async () => {
  const {repairExamOnlyQueuedPlans} = await import('../lib/paymongoGrants.js');
  const root = `users/${uid}/grants`;
  // The plan was queued at the pass's first sitting end (now + 1000); the pass now ends later.
  const db = firestore({
    [`${root}/pass`]: {...planRow(now - 1, now + 5000), product: pass.id},
    [`${root}/plan`]: planRow(now + 1000, now + 2000),
  });
  assert.equal(await repairExamOnlyQueuedPlans(db, uid, now), 1);
  assert.equal(db.rows.get(`${root}/plan`).startsAt, now);
  assert.equal(await repairExamOnlyQueuedPlans(db, uid, now), 0);
});

test('repair leaves a plan queued behind a live plan while an unrelated pass is active', async () => {
  const {repairExamOnlyQueuedPlans} = await import('../lib/paymongoGrants.js');
  const root = `users/${uid}/grants`;
  const db = firestore({
    [`${root}/pass`]: {...planRow(now - 1, now + 5000), product: pass.id},
    [`${root}/first`]: planRow(now - 1, now + 1000),
    [`${root}/second`]: planRow(now + 1000, now + 2000),
  });
  assert.equal(await repairExamOnlyQueuedPlans(db, uid, now), 0);
  assert.equal(db.rows.get(`${root}/second`).startsAt, now + 1000);
});

test('repair in dry-run mode counts the plans it would move and writes nothing', async () => {
  const {repairExamOnlyQueuedPlans} = await import('../lib/paymongoGrants.js');
  const root = `users/${uid}/grants`;
  const db = firestore({
    [`${root}/pass`]: {...planRow(now - 1, now + 1000), product: pass.id},
    [`${root}/plan`]: planRow(now + 1000, now + 2000),
  });
  assert.equal(await repairExamOnlyQueuedPlans(db, uid, now, {dryRun: true}), 1);
  assert.equal(db.rows.get(`${root}/plan`).startsAt, now + 1000);
});

test('a partial refund that came before a late pass is kept, so refunding the balance closes the follow-up', async () => {
  const {revokePaymongoPayment} = await import('../lib/paymongoGrants.js');
  const db = firestore();
  await revokePaymongoPayment(db, {eventId: 'evt_early', paymentId: 'pay_test', reason: 'payment.refunded',
    refunds: [{id: 'ref_early', amount: 5000}]}, end - 1000);
  assert.equal(await commitPaymongoGrant(db, passPayment, end + 1, []), 'paidAfterSitting');
  assert.deepEqual(db.rows.get(`users/${uid}/grants/pay_test`).refunds, {ref_early: 5000});
  const path = 'paymongoFollowUps/pay_test';
  assert.equal(db.rows.get(path).status, 'pending');
  await revokePaymongoPayment(db, {eventId: 'evt_balance', paymentId: 'pay_test', reason: 'payment.refunded',
    refunds: [{id: 'ref_balance', amount: passPayment.paidAmount - 5000}]}, end + 2);
  assert.equal(db.rows.get(path).status, 'refunded');
});

test('a duplicate pass keeps an earlier partial refund the same way', async () => {
  const {revokePaymongoPayment} = await import('../lib/paymongoGrants.js');
  const db = firestore({[`users/${uid}/grants/pay_first`]: {product: pass.id, tier: pass.tier, source: 'paymongo',
    state: 'active', sitting, startsAt: now - 2000, endsAt: end, createdAt: now - 2000}});
  await revokePaymongoPayment(db, {eventId: 'evt_early', paymentId: 'pay_test', reason: 'payment.refunded',
    refunds: [{id: 'ref_early', amount: 100}]}, now);
  assert.equal(await commitPaymongoGrant(db, passPayment, now + 1, []), 'unusedDuplicate');
  assert.deepEqual(db.rows.get(`users/${uid}/grants/pay_test`).refunds, {ref_early: 100});
});

const YEAR = 365 * 86_400_000;
async function monthlyWithQueuedReward(examId = 'exam_cse_pro') {
  const db = firestore();
  await commitPaymongoGrant(db, payment, now, []);
  const monthEnd = db.rows.get(`users/${uid}/grants/pay_test`).endsAt;
  db.rows.set(`users/${uid}/grants/beta_reward_${examId}`, {source: 'beta_reward', product: 'beta_reward',
    tier: 'civilService', examId, startsAt: monthEnd, endsAt: monthEnd + YEAR, state: 'active', createdAt: now});
  return {db, monthEnd};
}

test('a reward queued behind paid coverage starts now after a full refund and keeps its length', async () => {
  const {revokePaymongoPayment} = await import('../lib/paymongoGrants.js');
  const {db} = await monthlyWithQueuedReward();
  await revokePaymongoPayment(db, {eventId: 'evt_full', paymentId: payment.paymentId, reason: 'payment.refunded',
    refunds: [{id: 'full', amount: payment.paidAmount}]}, now + 1000);
  const reward = db.rows.get(`users/${uid}/grants/beta_reward_exam_cse_pro`);
  assert.equal(reward.startsAt, now + 1000);
  assert.equal(reward.endsAt - reward.startsAt, YEAR);
});

test('a reward moves to the shortened end after a partial refund and ignores an unrelated pass', async () => {
  const {revokePaymongoPayment} = await import('../lib/paymongoGrants.js');
  const {db} = await monthlyWithQueuedReward();
  await revokePaymongoPayment(db, {eventId: 'evt_half', paymentId: payment.paymentId, reason: 'payment.refunded',
    refunds: [{id: 'half', amount: payment.paidAmount / 2}]}, now + 1000);
  const month = db.rows.get(`users/${uid}/grants/pay_test`);
  const reward = db.rows.get(`users/${uid}/grants/beta_reward_exam_cse_pro`);
  assert.equal(reward.startsAt, month.endsAt);
  assert.equal(reward.endsAt - reward.startsAt, YEAR);
});

test('a dispute pulls a queued reward forward and a win puts it back', async () => {
  const {revokePaymongoPayment, resolvePaymongoDispute} = await import('../lib/paymongoGrants.js');
  const {db, monthEnd} = await monthlyWithQueuedReward();
  await revokePaymongoPayment(db, {eventId: 'evt_open', paymentId: payment.paymentId, disputeId: 'disp_test',
    dispute: true, reason: 'dispute.created'}, now + 1000);
  assert.equal(db.rows.get(`users/${uid}/grants/beta_reward_exam_cse_pro`).startsAt, now + 1000);
  await resolvePaymongoDispute(db, {eventId: 'evt_win', paymentId: payment.paymentId, disputeId: 'disp_test', won: true}, now + 2000);
  const reward = db.rows.get(`users/${uid}/grants/beta_reward_exam_cse_pro`);
  assert.equal(reward.startsAt, monthEnd);
  assert.equal(reward.endsAt - reward.startsAt, YEAR);
});

test('a plan bought while a same-tier plan is disputed is re-chained behind it on a win', async () => {
  const {revokePaymongoPayment, resolvePaymongoDispute} = await import('../lib/paymongoGrants.js');
  const db = firestore();
  await commitPaymongoGrant(db, payment, now, []);
  const monthEnd = db.rows.get(`users/${uid}/grants/pay_test`).endsAt;
  await revokePaymongoPayment(db, {eventId: 'evt_open', paymentId: payment.paymentId, disputeId: 'disp_test',
    dispute: true, reason: 'dispute.created'}, now + 1000);
  await commitPaymongoGrant(db, {...payment, eventId: 'evt_week', paymentId: 'pay_week', product: weekly,
    paidAmount: priceCentavos(weekly), paidAt: now + 2000}, now + 2000, []);
  assert.equal(db.rows.get(`users/${uid}/grants/pay_week`).startsAt, now + 2000);
  await resolvePaymongoDispute(db, {eventId: 'evt_win', paymentId: payment.paymentId, disputeId: 'disp_test',
    won: true}, now + 3000);
  const week = db.rows.get(`users/${uid}/grants/pay_week`);
  assert.equal(week.startsAt, monthEnd);
  assert.equal(week.endsAt - week.startsAt, WEEK);
  assert.equal(coverageEnd(db), monthEnd + WEEK);
});

test('a dispute won before this branch never revokes and the win is persisted', async () => {
  const {revokePaymongoPayment} = await import('../lib/paymongoGrants.js');
  const db = firestore();
  await commitPaymongoGrant(db, payment, now, []);
  const path = `users/${uid}/grants/pay_test`;
  db.rows.set(path, {...db.rows.get(path), disputeId: 'disp_old', disputeResolved: true});
  await revokePaymongoPayment(db, {eventId: 'evt_open', paymentId: payment.paymentId, disputeId: 'disp_old',
    dispute: true, reason: 'dispute.created'}, now + 1);
  assert.equal(db.rows.get(path).state, 'active');
  assert.equal(db.rows.get(`paymongoRevocations/pay_test`).resolutions.disp_old, 'won');
  db.rows.delete(`webhookEvents/evt_open/users/${uid}`);
  await revokePaymongoPayment(db, {eventId: 'evt_open', paymentId: payment.paymentId, disputeId: 'disp_old',
    dispute: true, reason: 'dispute.created'}, now + 2);
  assert.equal(db.rows.get(path).state, 'active');
});

const monthly = product;
async function buy(db, id, prod, at) {
  await commitPaymongoGrant(db, {...payment, eventId: `evt_${id}`, paymentId: `pay_${id}`, product: prod,
    paidAmount: priceCentavos(prod), paidAt: at}, at, []);
}
const grantRow = (db, id) => db.rows.get(`users/${uid}/grants/pay_${id}`);

test('a win re-chains two plans bought during the dispute behind the restored plan, each with its exact length', async () => {
  const {revokePaymongoPayment, resolvePaymongoDispute} = await import('../lib/paymongoGrants.js');
  const db = firestore();
  await buy(db, 'test_m1', monthly, now);
  const first = {...grantRow(db, 'test_m1')};
  await revokePaymongoPayment(db, {eventId: 'evt_open', paymentId: 'pay_test_m1', disputeId: 'disp_test',
    dispute: true, reason: 'dispute.created'}, now + 1000);
  await buy(db, 'm2', monthly, now + 2000);
  await buy(db, 'wk', weekly, now + 3000);
  await resolvePaymongoDispute(db, {eventId: 'evt_win', paymentId: 'pay_test_m1', disputeId: 'disp_test', won: true}, now + 4000);
  const restored = grantRow(db, 'test_m1');
  assert.equal(restored.startsAt, first.startsAt);
  assert.equal(restored.endsAt, first.endsAt);
  assert.equal(grantRow(db, 'm2').startsAt, first.endsAt);
  // A calendar month: the length is the one the product gives at the new start.
  assert.equal(grantRow(db, 'm2').endsAt, addPrepaid(first.endsAt, monthly.prepaid));
  assert.equal(grantRow(db, 'wk').startsAt, grantRow(db, 'm2').endsAt);
  assert.equal(grantRow(db, 'wk').endsAt - grantRow(db, 'wk').startsAt, WEEK);
});

test('a reward pulled forward by a dispute does not delay a plan bought during it', async () => {
  const {revokePaymongoPayment, resolvePaymongoDispute} = await import('../lib/paymongoGrants.js');
  const {db, monthEnd} = await monthlyWithQueuedReward();
  await revokePaymongoPayment(db, {eventId: 'evt_open', paymentId: payment.paymentId, disputeId: 'disp_test',
    dispute: true, reason: 'dispute.created'}, now + 1000);
  await buy(db, 'wk', weekly, now + 2000);
  await resolvePaymongoDispute(db, {eventId: 'evt_win', paymentId: payment.paymentId, disputeId: 'disp_test', won: true}, now + 3000);
  const week = grantRow(db, 'wk');
  assert.equal(week.startsAt, monthEnd);
  assert.equal(week.endsAt - week.startsAt, WEEK);
  const reward = db.rows.get(`users/${uid}/grants/beta_reward_exam_cse_pro`);
  assert.equal(reward.endsAt - reward.startsAt, YEAR);
  assert.ok(reward.startsAt >= monthEnd);
});

function seeded(seed) {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6D2B79F5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

test('a win rebuilds the chain: a plan bought after the queue emptied keeps running and the restored plan follows it', async () => {
  const {revokePaymongoPayment, resolvePaymongoDispute} = await import('../lib/paymongoGrants.js');
  const DAY = 86_400_000;
  const db = firestore();
  await buy(db, 'a', weekly, now);
  await buy(db, 'b', monthly, now);
  const bLength = grantRow(db, 'b').endsAt - grantRow(db, 'b').startsAt;
  assert.equal(grantRow(db, 'b').startsAt, grantRow(db, 'a').endsAt);
  await revokePaymongoPayment(db, {eventId: 'evt_open', paymentId: 'pay_b', disputeId: 'disp_b', dispute: true,
    reason: 'dispute.created'}, now + 2 * DAY);
  await revokePaymongoPayment(db, {eventId: 'evt_ref', paymentId: 'pay_a', reason: 'payment.refunded',
    refunds: [{id: 'full', amount: priceCentavos(weekly)}]}, now + 3 * DAY);
  await buy(db, 'c', weekly, now + 4 * DAY);
  assert.equal(grantRow(db, 'c').startsAt, now + 4 * DAY);
  await resolvePaymongoDispute(db, {eventId: 'evt_win', paymentId: 'pay_b', disputeId: 'disp_b', won: true}, now + 5 * DAY);
  assert.equal(grantRow(db, 'c').startsAt, now + 4 * DAY);
  assert.equal(grantRow(db, 'c').endsAt - grantRow(db, 'c').startsAt, WEEK);
  assert.equal(grantRow(db, 'b').startsAt, grantRow(db, 'c').endsAt);
  assert.equal(grantRow(db, 'b').endsAt - grantRow(db, 'b').startsAt, bLength);
});

test('rechainAfterWin leaves an already contiguous chain unchanged', async () => {
  const {rechainAfterWin} = await import('../lib/paymongoGrants.js');
  const row = (id, startsAt, endsAt, createdAt) => [id, {id, state: 'active', tier: 'civilService', source: 'web',
    product: 'pantas_cs_monthly', startsAt, endsAt, createdAt}];
  const grants = new Map([row('a', now - 1000, now + 1000, 1), row('b', now + 1000, now + 5000, 2), row('c', now + 5000, now + 9000, 3)]);
  const out = rechainAfterWin(grants, 'a', 'disp_x', now);
  for (const [id, g] of grants) assert.equal(out.get(id), g, id);
});

test('a won dispute puts an expired restored plan behind the plan bought while it was disputed', async () => {
  const {revokePaymongoPayment, resolvePaymongoDispute} = await import('../lib/paymongoGrants.js');
  const DAY = 86_400_000;
  const db = firestore();
  await buy(db, 'a', weekly, now);
  await buy(db, 'b', weekly, now);
  assert.equal(grantRow(db, 'b').startsAt, now + WEEK);
  await revokePaymongoPayment(db, {eventId: 'evt_open', paymentId: 'pay_b', disputeId: 'disp_b', dispute: true,
    reason: 'dispute.created'}, now + DAY);
  await revokePaymongoPayment(db, {eventId: 'evt_ref', paymentId: 'pay_a', reason: 'payment.refunded',
    refunds: [{id: 'full', amount: priceCentavos(weekly)}]}, now + 2 * DAY);
  await buy(db, 'c', monthly, now + 3 * DAY);
  const c = {...grantRow(db, 'c')};
  assert.equal(c.startsAt, now + 3 * DAY);
  await resolvePaymongoDispute(db, {eventId: 'evt_win', paymentId: 'pay_b', disputeId: 'disp_b', won: true}, now + 15 * DAY);
  assert.equal(grantRow(db, 'b').state, 'active');
  assert.deepEqual([grantRow(db, 'c').startsAt, grantRow(db, 'c').endsAt], [c.startsAt, c.endsAt]);
  assert.equal(grantRow(db, 'b').startsAt, c.endsAt);
  assert.equal(grantRow(db, 'b').endsAt - c.endsAt, WEEK);
});

test('a won dispute leaves an already ended restored plan where it was when nothing overlapped it', async () => {
  const {revokePaymongoPayment, resolvePaymongoDispute} = await import('../lib/paymongoGrants.js');
  const DAY = 86_400_000;
  const db = firestore();
  await buy(db, 'a', weekly, now);
  const before = {...grantRow(db, 'a')};
  await revokePaymongoPayment(db, {eventId: 'evt_open', paymentId: 'pay_a', disputeId: 'disp_a', dispute: true,
    reason: 'dispute.created'}, now + DAY);
  await resolvePaymongoDispute(db, {eventId: 'evt_win', paymentId: 'pay_a', disputeId: 'disp_a', won: true}, now + 15 * DAY);
  assert.equal(grantRow(db, 'a').state, 'active');
  assert.equal(grantRow(db, 'a').startsAt, before.startsAt);
  assert.equal(grantRow(db, 'a').endsAt, before.endsAt);
});

const HOUR_MS = 3_600_000;
const liveOf = (db, ids, at) => ids.map(id => grantRow(db, id)).filter(row => row.state === 'active' && row.endsAt > at);
const snapshot = (db, ids) => new Map(ids.map(id => [id, {...grantRow(db, id)}]));

test('property: random purchases, refunds, revokes and disputes keep the chain whole after every step', async () => {
  const {revokePaymongoPayment, resolvePaymongoDispute} = await import('../lib/paymongoGrants.js');
  for (let n = 0; n < 1200; n++) {
    const seed = 1000 + n;
    const rand = seeded(seed);
    const pick = (max) => Math.floor(rand() * max);
    const db = firestore();
    const ids = [];
    const boughtAt = new Map();
    const disputes = []; // {id, target, open}
    let at = now;
    let step = 0;
    const history = [];
    const wonTargets = new Set();
    const lostTargets = new Set();
    const fail = (message) => assert.fail(`seed ${seed} step ${step}: ${message}${process.env.DEBUG_SEED ? `\n${history.join('\n')}` : ''}`);
    const live = () => ids.filter(id => grantRow(db, id).state === 'active');
    const stepCount = 1 + pick(6);
    for (step = 0; step < stepCount; step++) {
      at += pick(12 * 24) * HOUR_MS + HOUR_MS;
      const before = snapshot(db, ids);
      let target; let kind;
      const choices = ['buy', 'buy'];
      if (live().length) choices.push('partial', 'full', 'dispute');
      if (disputes.some(d => d.open)) choices.push('win', 'lose', 'win');
      const choice = ids.length === 0 ? 'buy' : choices[pick(choices.length)];
      if (choice === 'buy') {
        target = `p${ids.length}`; kind = 'buy';
        await buy(db, target, rand() < 0.5 ? weekly : monthly, at);
        ids.push(target); boughtAt.set(target, at);
      } else if (choice === 'partial' || choice === 'full') {
        target = live()[pick(live().length)]; kind = choice;
        const paid = grantRow(db, target).paidAmount;
        const amount = choice === 'full' ? paid : Math.max(1, Math.floor(paid * (0.1 + 0.6 * rand())));
        await revokePaymongoPayment(db, {eventId: `evt_r${step}`, paymentId: `pay_${target}`, reason: 'payment.refunded',
          refunds: [{id: `ref_${step}`, amount}]}, at);
      } else if (choice === 'dispute') {
        const candidates = live().filter(id => !disputes.some(d => d.target === id));
        if (!candidates.length || disputes.length >= 2) {step--; continue;}
        target = candidates[pick(candidates.length)]; kind = 'dispute';
        disputes.push({id: `disp_${step}`, target, open: true});
        await revokePaymongoPayment(db, {eventId: `evt_d${step}`, paymentId: `pay_${target}`, disputeId: `disp_${step}`,
          dispute: true, reason: 'dispute.created'}, at);
      } else {
        const open = disputes.filter(d => d.open);
        const dispute = open[pick(open.length)];
        dispute.open = false; target = dispute.target; kind = choice;
        await resolvePaymongoDispute(db, {eventId: `evt_w${step}`, paymentId: `pay_${target}`, disputeId: dispute.id,
          won: choice === 'win'}, at);
      }
      const label = `${kind} on ${target}`;
      const after = snapshot(db, ids);
      history.push(`t=${((at - now) / HOUR_MS / 24).toFixed(2)}d ${label}: ` + ids.map(id => {
        const r = after.get(id);
        return `${id}[${r.state[0]}${Object.keys(r.refunds ?? {}).length ? 'r' : ''} ${((r.startsAt - now) / HOUR_MS / 24).toFixed(2)}-${((r.endsAt - now) / HOUR_MS / 24).toFixed(2)}]`;
      }).join(' '));
      for (const id of ids) {
        const was = before.get(id); const row = after.get(id);
        if (!was) {
          if (row.startsAt < boughtAt.get(id)) fail(`${label}: ${id} starts before its purchase`);
          continue;
        }
        if (row.startsAt < boughtAt.get(id)) fail(`${label}: ${id} starts before its purchase`);
        if (id === target) continue;
        if (row.state !== was.state) fail(`${label}: ${id} changed state without its own event`);
      }
      // Each live plan has exactly the length the code's own start-at rule gives for its start:
      // the full length from the product, cut by the refunded share.
      for (const id of ids) {
        const row = after.get(id);
        if (row.state !== 'active' || row.endsAt <= at) continue;
        const prepaid = webProduct(row.product).prepaid;
        const fullEnd = addPrepaid(row.startsAt, prepaid);
        const refunded = Object.values(row.refunds ?? {}).reduce((a, b) => a + b, 0);
        if (row.endsAt !== shortenedEnd(row.startsAt, fullEnd, refunded, row.paidAmount)) fail(`${label}: ${id} does not have its exact length`);
      }
      if (kind === 'win') wonTargets.add(target);
      if (kind === 'lose') lostTargets.add(target);
      const refundedOf = (row) => Object.values(row.refunds ?? {}).reduce((a, b) => a + b, 0);
      // A dispute won keeps the payment: the plan is active, unless its own refund revoked it.
      for (const id of wonTargets) {
        const row = after.get(id);
        if (row.state !== 'active' && refundedOf(row) < row.paidAmount) fail(`${label}: ${id} won its dispute but is not active`);
      }
      // Paid coverage still owed (every plan not lost, not fully refunded, not under a live dispute)
      // is covered by the live and future coverage of the account.
      const openTargets = new Set(disputes.filter(d => d.open).map(d => d.target));
      const remaining = (row) => Math.max(0, row.endsAt - Math.max(row.startsAt, at));
      let owed = 0; let covered = 0;
      for (const id of ids) {
        const row = after.get(id);
        if (row.state === 'active') covered += remaining(row);
        if (!lostTargets.has(id) && !openTargets.has(id) && refundedOf(row) < row.paidAmount) owed += remaining(row);
      }
      if (covered < owed) fail(`${label}: live and future coverage ${covered} is below the paid length still owed ${owed}`);
      const running = liveOf(db, ids, at).sort((a, b) => a.startsAt - b.startsAt);
      for (let i = 1; i < running.length; i++) {
        if (Math.max(running[i].startsAt, at) < running[i - 1].endsAt) fail(`${label}: overlap after now`);
      }
      const queued = running.some(row => row.startsAt > at);
      if (queued && !running.some(row => row.startsAt <= at)) fail(`${label}: a plan is queued with nothing covering now`);
    }
  }
});

test('dispute, partial refund, then the paid webhook, then a win: the plan comes back with the shortened end', async () => {
  const {revokePaymongoPayment, resolvePaymongoDispute} = await import('../lib/paymongoGrants.js');
  const db = firestore();
  const paid = priceCentavos(monthly);
  await revokePaymongoPayment(db, {eventId: 'evt_open', paymentId: 'pay_a', disputeId: 'disp_a', dispute: true,
    reason: 'dispute.created'}, now - 2000);
  await revokePaymongoPayment(db, {eventId: 'evt_ref', paymentId: 'pay_a', reason: 'payment.refunded',
    refunds: [{id: 'half', amount: paid / 2}]}, now - 1000);
  await buy(db, 'a', monthly, now);
  const born = grantRow(db, 'a');
  assert.equal(born.state, 'revoked');
  assert.equal(born.endsAt, shortenedEnd(born.startsAt, addPrepaid(born.startsAt, monthly.prepaid), paid / 2, paid));
  await resolvePaymongoDispute(db, {eventId: 'evt_win', paymentId: 'pay_a', disputeId: 'disp_a', won: true}, now + 1000);
  const won = grantRow(db, 'a');
  assert.equal(won.state, 'active');
  assert.equal(won.endsAt, shortenedEnd(won.startsAt, addPrepaid(won.startsAt, monthly.prepaid), paid / 2, paid));
  assert.ok(won.endsAt - won.startsAt < (addPrepaid(now, monthly.prepaid) - now) * 0.6);
});

// An independent model: each plan's paid length, refunded share and status are tracked here, apart
// from the grants the real code writes. Coverage is measured on the real grants as a union of
// intervals, so overlapping plans are never counted twice.
test('property with a model ledger: coverage after now covers the time the model says is owed', async () => {
  const {revokePaymongoPayment, resolvePaymongoDispute} = await import('../lib/paymongoGrants.js');
  const DAY = 86_400_000;
  const lengths = {low: {pantas_cs_weekly: 7 * DAY, pantas_cs_monthly: 28 * DAY},
    high: {pantas_cs_weekly: 7 * DAY, pantas_cs_monthly: 31 * DAY}};
  const union = (rows, from, to) => {
    const spans = rows.map(r => [Math.max(r.startsAt, from), Math.min(r.endsAt, to)]).filter(([a, b]) => b > a)
      .sort((x, y) => x[0] - y[0]);
    let total = 0; let end = -Infinity;
    for (const [a, b] of spans) {total += b - Math.max(a, end); end = Math.max(end, b);}
    return total;
  };
  for (let n = 0; n < 1200; n++) {
    const seed = 5000 + n;
    const rand = seeded(seed);
    const pick = max => Math.floor(rand() * max);
    const db = firestore();
    const model = new Map(); // id -> {product, paid, refunded, status: 'active' | 'disputed' | 'lost' | 'full'}
    let at = now; let step = 0;
    const log = [];
    const fail = message => assert.fail(`seed ${seed} step ${step}: ${message}${process.env.DEBUG_SEED ? `\n${log.join('\n')}` : ''}`);
    const ids = () => [...model.keys()];
    const stepCount = 1 + pick(6);
    for (step = 0; step < stepCount; step++) {
      at += pick(12 * 24) * HOUR_MS + HOUR_MS;
      const choices = ['buy', 'buy', 'buyAfterEvents'];
      const active = ids().filter(id => model.get(id).status === 'active');
      const disputed = ids().filter(id => model.get(id).status === 'disputed');
      // A refund after a plan has fully run changes nothing it delivered, so refunds target plans still running.
      const refundable = active.filter(id => grantRow(db, id).endsAt > at);
      if (refundable.length) choices.push('partial', 'full');
      if (active.length) choices.push('dispute');
      if (disputed.length) choices.push('win', 'lose', 'win');
      const choice = model.size === 0 ? (rand() < 0.5 ? 'buy' : 'buyAfterEvents') : choices[pick(choices.length)];
      const prod = rand() < 0.5 ? weekly : monthly;
      const paid = priceCentavos(prod);
      if (choice === 'buy' || choice === 'buyAfterEvents') {
        const id = `p${model.size}`;
        const entry = {product: prod.id, paid, refunded: 0, status: 'active'};
        if (choice === 'buyAfterEvents') {
          const disputeFirst = rand() < 0.6; const refundFirst = rand() < 0.7 || !disputeFirst;
          if (disputeFirst) {
            await revokePaymongoPayment(db, {eventId: `evt_d${id}`, paymentId: `pay_${id}`, disputeId: `disp_${id}`,
              dispute: true, reason: 'dispute.created'}, at - 2000);
            entry.status = 'disputed';
          }
          if (refundFirst) {
            const amount = Math.max(1, Math.floor(paid * (0.1 + 0.6 * rand())));
            await revokePaymongoPayment(db, {eventId: `evt_r${id}`, paymentId: `pay_${id}`, reason: 'payment.refunded',
              refunds: [{id: `ref_${id}`, amount}]}, at - 1000);
            entry.refunded = amount;
          }
        }
        await buy(db, id, prod, at);
        model.set(id, entry);
        log.push(`${choice} ${id} ${entry.status} refunded ${entry.refunded}`);
      } else if (choice === 'partial' || choice === 'full') {
        const id = refundable[pick(refundable.length)]; const entry = model.get(id);
        const amount = choice === 'full' ? entry.paid - entry.refunded : Math.max(1, Math.floor(entry.paid * (0.1 + 0.4 * rand())));
        await revokePaymongoPayment(db, {eventId: `evt_r${step}`, paymentId: `pay_${id}`, reason: 'payment.refunded',
          refunds: [{id: `ref_${step}`, amount}]}, at);
        entry.refunded += amount;
        if (entry.refunded >= entry.paid) entry.status = 'full';
        log.push(`${choice} ${id}`);
      } else if (choice === 'dispute') {
        const id = active[pick(active.length)];
        await revokePaymongoPayment(db, {eventId: `evt_d${step}`, paymentId: `pay_${id}`, disputeId: `disp_${id}`,
          dispute: true, reason: 'dispute.created'}, at);
        model.get(id).status = 'disputed';
        log.push(`dispute ${id}`);
      } else {
        const id = disputed[pick(disputed.length)];
        await resolvePaymongoDispute(db, {eventId: `evt_w${step}`, paymentId: `pay_${id}`, disputeId: `disp_${id}`,
          won: choice === 'win'}, at);
        const entry = model.get(id);
        entry.status = choice === 'win' ? (entry.refunded >= entry.paid ? 'full' : 'active') : 'lost';
        log.push(`${choice} ${id}`);
      }
      const rows = ids().map(id => grantRow(db, id));
      const live = rows.filter(r => r.state === 'active');
      let owed = 0;
      for (const [id, entry] of model) {
        if (entry.status !== 'active') continue;
        const share = (entry.paid - entry.refunded) / entry.paid;
        const low = Math.floor(lengths.low[entry.product] * share) - 1000;
        const row = grantRow(db, id);
        // A plan's term runs from its own start; what is left of its paid length after now is owed.
        owed += Math.max(0, low - Math.min(Math.max(at - row.startsAt, 0), row.endsAt - row.startsAt));
        if (row.state !== 'active') fail(`${id} is active in the model but ${row.state} in the grants`);
        const high = lengths.high[entry.product] * share + 1000;
        if (row.endsAt - row.startsAt > high) fail(`${id} runs ${(row.endsAt - row.startsAt) / DAY} days, more than the ${high / DAY} it paid for`);
      }
      const after = union(live, at, Infinity);
      if (after < owed) fail(`coverage after now ${after / DAY}d is below the owed ${owed / DAY}d`);
    }
  }
});
