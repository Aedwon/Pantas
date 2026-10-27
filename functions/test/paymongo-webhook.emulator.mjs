import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {reconcileWebhook} from '../lib/revenuecatWebhook.js';
import {recomputePassRecords} from '../lib/revenuecatPasses.js';
import {handlePaymongoWebhook} from '../lib/paymongoWebhook.js';
import {createHmac} from 'node:crypto';
import {fakeAuth, fakeClient, paidEvent, ph, resourceEvent, send, session, signed} from './_paymongo-helpers.mjs';
import {SECRET} from './_paymongo-helpers.mjs';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
const db = getFirestore();
const catalog = [{id: 'exam_cse_pro', publishedSittings: [
  {firstDay: '2027-03-14', lastDay: '2027-03-14', sourceUrl: 'https://example.test/a'}]}];
const reset = uid => db.recursiveDelete(db.doc(`users/${uid}`));
const entitlement = async uid => (await db.doc(`users/${uid}/server/entitlement`).get()).data();
const grants = async uid => (await db.collection(`users/${uid}/grants`).get()).docs.map(d => ({id: d.id, ...d.data()}));
const PRICE = {pantas_cs_weekly: 4900, pantas_cs_monthly: 14900, pantas_cs_yearly: 119900, pantas_pass_cse_pro: 49900};

function setup(uid, product, {now = ph('2026-10-20T10:00:00+08:00'), sessionId = 'cs_1', paymentId = `pay_${uid}`, amount} = {}) {
  const auth = fakeAuth();
  const client = fakeClient({[sessionId]: session({id: sessionId, uid, product, paymentId, amount: amount ?? PRICE[product], paidAt: now})});
  const deps = {db, auth, client, signingSecret: SECRET, livemode: false, catalog, now: () => now};
  return {auth, client, deps, now};
}

test('a paid monthly checkout grants access, copies claims and re-reads the session', async () => {
  const uid = 'pm-grant';
  await reset(uid);
  const {auth, client, deps, now} = setup(uid, 'pantas_cs_monthly');
  assert.equal(await send(paidEvent({uid, product: 'pantas_cs_monthly'}), deps), 200);
  assert.deepEqual(client.calls, ['cs_1']);
  const [grant] = await grants(uid);
  assert.equal(grant.id, 'pay_pm-grant');
  assert.equal(grant.source, 'paymongo');
  assert.equal(grant.product, 'pantas_cs_monthly');
  assert.equal(grant.tier, 'civilService');
  assert.equal(grant.paymentId, 'pay_pm-grant');
  assert.equal(grant.state, 'active');
  assert.equal(grant.startsAt, now);
  assert.equal(grant.endsAt, ph('2026-11-20T10:00:00+08:00'));
  const record = await entitlement(uid);
  assert.equal(record.pro, true);
  assert.equal(record.proUntil, grant.endsAt + 86400000);
  assert.equal(record.version, 1);
  assert.equal(record.claimsVersion, 1);
  assert.equal(auth.current().pro, true);
  assert.equal(auth.current().other, 'kept');
  assert.equal((await db.doc(`webhookEvents/evt_1/users/${uid}`).get()).exists, true);
});

test('a replayed event changes nothing and does not call PayMongo or write again', async () => {
  const uid = 'pm-replay';
  await reset(uid);
  const {client, deps} = setup(uid, 'pantas_cs_weekly');
  const body = paidEvent({uid, product: 'pantas_cs_weekly'});
  assert.equal(await send(body, deps), 200);
  const before = {record: await entitlement(uid), grants: await grants(uid)};
  assert.equal(await send(body, deps), 200);
  // Same payment under a new event id is also a no-op.
  assert.equal(await send(paidEvent({id: 'evt_other', uid, product: 'pantas_cs_weekly'}), deps), 200);
  assert.deepEqual(await grants(uid), before.grants);
  const after = await entitlement(uid);
  assert.equal(after.version, before.record.version);
  assert.equal(after.proUntil, before.record.proUntil);
  assert.equal(client.calls.length, 3);
});

test('signature failures: bad secret, stale timestamp, missing raw body, wrong mode', async () => {
  const uid = 'pm-sig';
  await reset(uid);
  const {client, deps, now} = setup(uid, 'pantas_cs_weekly');
  const body = paidEvent({uid, product: 'pantas_cs_weekly'});
  const bad = signed(body, {now, secret: 'wrong'});
  assert.equal(await handlePaymongoWebhook(bad.raw, bad.header, deps), 401);
  const stale = signed(body, {now, at: now - 6 * 60_000});
  assert.equal(await handlePaymongoWebhook(stale.raw, stale.header, deps), 401);
  assert.equal(await handlePaymongoWebhook(undefined, '', deps), 401);
  assert.equal(await handlePaymongoWebhook(JSON.stringify(body), signed(body, {now}).header, deps), 401);
  const live = signed(body, {now, livemode: true});
  assert.equal(await handlePaymongoWebhook(live.raw, live.header, deps), 401);
  assert.deepEqual(client.calls, []);
  assert.deepEqual(await grants(uid), []);
});

test('malformed signed bodies return 400; other event types and livemode mismatches return 200 and grant nothing', async () => {
  const uid = 'pm-malformed';
  await reset(uid);
  const {client, deps, now} = setup(uid, 'pantas_cs_weekly');
  const notJson = Buffer.from('not json');
  const t = Math.floor(now / 1000);
  const header = raw => `t=${t},te=${createHmac('sha256', SECRET).update(`${t}.`).update(raw).digest('hex')},li=`;
  assert.equal(await handlePaymongoWebhook(notJson, header(notJson), deps), 400);
  const noEnvelope = Buffer.from('{"data":{}}');
  assert.equal(await handlePaymongoWebhook(noEnvelope, header(noEnvelope), deps), 400);
  assert.equal(await send(resourceEvent({id: 'evt_x', type: 'payment.failed', resource: 'payment', attributes: {}}), deps), 200);
  assert.equal(await send(paidEvent({uid, product: 'pantas_cs_weekly', livemode: true}), deps), 200);
  assert.deepEqual(client.calls, []);
  assert.deepEqual(await grants(uid), []);
});

test('metadata that differs between the event and the PayMongo re-read is refused', async () => {
  const uid = 'pm-meta';
  await reset(uid);
  const {deps} = setup(uid, 'pantas_cs_weekly');
  // Event claims another product; session says weekly.
  assert.equal(await send(paidEvent({uid, product: 'pantas_cs_yearly'}), deps), 500);
  // Event claims another account.
  assert.equal(await send(paidEvent({id: 'evt_2', uid: 'someone-else', product: 'pantas_cs_weekly'}), deps), 500);
  // Session has no metadata at all.
  const empty = {...deps, client: fakeClient({cs_1: session({uid, product: 'x', amount: 4900, metadata: {}})})};
  assert.equal(await send(paidEvent({id: 'evt_3', uid, product: 'pantas_cs_weekly'}), empty), 500);
  assert.deepEqual(await grants(uid), []);
  assert.deepEqual(await grants('someone-else'), []);
  assert.equal((await entitlement(uid)), undefined);
});

test('the paid amount must equal the products.json price', async () => {
  const uid = 'pm-amount';
  await reset(uid);
  for (const [i, amount] of [4800, 14900, 0].entries()) {
    const {deps} = setup(uid, 'pantas_cs_weekly', {amount, sessionId: `cs_a${i}`, paymentId: `pay_a${i}`});
    assert.equal(await send(paidEvent({id: `evt_a${i}`, sessionId: `cs_a${i}`, uid, product: 'pantas_cs_weekly'}), deps), 500);
  }
  const wrongCurrency = {...setup(uid, 'pantas_cs_weekly').deps, client: fakeClient({cs_1: {...session({uid, product: 'pantas_cs_weekly', amount: 4900}),
    payments: [{id: 'pay_c', amount: 4900, currency: 'USD', status: 'paid'}]}})};
  assert.equal(await send(paidEvent({id: 'evt_c', uid, product: 'pantas_cs_weekly'}), wrongCurrency), 500);
  assert.deepEqual(await grants(uid), []);
  const audits = (await db.collection('audit_logs').where('uid', '==', uid).get()).docs.map(d => d.get('event'));
  assert.ok(audits.filter(e => e === 'paymongoAmountMismatch').length >= 4);
});

test('unknown and non-web products are refused', async () => {
  const uid = 'pm-unknown';
  await reset(uid);
  for (const [i, product] of ['pantas_made_up', 'pantas_pro_monthly', 'promo_student'].entries()) {
    const {deps} = setup(uid, product, {amount: 14900, sessionId: `cs_u${i}`, paymentId: `pay_u${i}`});
    assert.equal(await send(paidEvent({id: `evt_u${i}`, sessionId: `cs_u${i}`, uid, product}), deps), 500);
  }
  assert.deepEqual(await grants(uid), []);
});

test('a payment PayMongo does not yet report as paid returns 500 so the event is retried, then grants', async () => {
  const uid = 'pm-late';
  await reset(uid);
  const {deps} = setup(uid, 'pantas_cs_weekly');
  const pending = {...deps, client: fakeClient({cs_1: session({uid, product: 'pantas_cs_weekly', amount: 4900, status: 'awaiting'})})};
  assert.equal(await send(paidEvent({uid, product: 'pantas_cs_weekly'}), pending), 500);
  assert.equal((await grants(uid)).length, 0);
  assert.equal(await send(paidEvent({uid, product: 'pantas_cs_weekly'}), deps), 200);
  assert.equal((await grants(uid)).length, 1);
  const down = {...deps, client: fakeClient({})};
  assert.equal(await send(paidEvent({id: 'evt_d', uid, product: 'pantas_cs_weekly'}), down), 500);
});

test('an unknown or deleted account is not granted', async () => {
  const uid = 'pm-gone';
  await reset(uid);
  const {deps} = setup(uid, 'pantas_cs_weekly');
  const gone = {...deps, auth: {...deps.auth, getUser: async () => {throw Object.assign(new Error('gone'), {code: 'auth/user-not-found'});}}};
  assert.equal(await send(paidEvent({uid, product: 'pantas_cs_weekly'}), gone), 500);
  assert.deepEqual(await grants(uid), []);
});

test('early renewal stacks from the current end, and the entitlement follows the latest end', async () => {
  const uid = 'pm-stack';
  await reset(uid);
  const first = setup(uid, 'pantas_cs_monthly', {sessionId: 'cs_s1', paymentId: 'pay_s1'});
  assert.equal(await send(paidEvent({id: 'evt_s1', sessionId: 'cs_s1', uid, product: 'pantas_cs_monthly'}), first.deps), 200);
  const later = setup(uid, 'pantas_cs_monthly', {sessionId: 'cs_s2', paymentId: 'pay_s2', now: ph('2026-10-25T09:00:00+08:00')});
  assert.equal(await send(paidEvent({id: 'evt_s2', sessionId: 'cs_s2', uid, product: 'pantas_cs_monthly'}), later.deps), 200);
  const rows = Object.fromEntries((await grants(uid)).map(g => [g.id, g]));
  assert.equal(rows.pay_s1.endsAt, ph('2026-11-20T10:00:00+08:00'));
  assert.equal(rows.pay_s2.startsAt, ph('2026-11-20T10:00:00+08:00'));
  assert.equal(rows.pay_s2.endsAt, ph('2026-12-20T10:00:00+08:00'));
  const record = await entitlement(uid);
  assert.equal(record.proUntil, rows.pay_s2.endsAt + 86400000);
  assert.equal(record.version, 2);
});

test('a monthly purchase on January 31 ends February 28, and February 29 in a leap year', async () => {
  for (const [uid, now, end] of [['pm-jan31', '2027-01-31T10:00:00+08:00', '2027-02-28T10:00:00+08:00'],
    ['pm-jan31-leap', '2028-01-31T10:00:00+08:00', '2028-02-29T10:00:00+08:00']]) {
    await reset(uid);
    const {deps} = setup(uid, 'pantas_cs_monthly', {now: ph(now)});
    assert.equal(await send(paidEvent({uid, product: 'pantas_cs_monthly'}), deps), 200);
    assert.equal((await grants(uid))[0].endsAt, ph(end));
  }
});

test('a yearly purchase ends on the same date next year; weekly is 7 days', async () => {
  const uid = 'pm-year';
  await reset(uid);
  const y = setup(uid, 'pantas_cs_yearly', {now: ph('2026-10-20T10:00:00+08:00')});
  assert.equal(await send(paidEvent({uid, product: 'pantas_cs_yearly'}), y.deps), 200);
  assert.equal((await grants(uid))[0].endsAt, ph('2027-10-20T10:00:00+08:00'));
  const week = 'pm-week';
  await reset(week);
  const w = setup(week, 'pantas_cs_weekly');
  assert.equal(await send(paidEvent({uid: week, product: 'pantas_cs_weekly'}), w.deps), 200);
  assert.equal((await grants(week))[0].endsAt, w.now + 7 * 86400000);
});

test('a pass ends at the end of the next published sitting (sittingFor), Philippine time', async () => {
  const uid = 'pm-pass';
  await reset(uid);
  const {deps, auth} = setup(uid, 'pantas_pass_cse_pro');
  assert.equal(await send(paidEvent({uid, product: 'pantas_pass_cse_pro'}), deps), 200);
  const [grant] = await grants(uid);
  assert.equal(grant.endsAt, ph('2027-03-14T23:59:59.999+08:00'));
  assert.equal((await entitlement(uid)).proUntil, grant.endsAt + 86400000);
  assert.equal(auth.current().pro, true);
});

test('a paid pass with no published sitting keeps the evidence and grants nothing', async () => {
  const uid = 'pm-pass-none';
  await reset(uid);
  const {deps} = setup(uid, 'pantas_pass_cse_pro');
  assert.equal(await send(paidEvent({uid, product: 'pantas_pass_cse_pro'}), {...deps, catalog: []}), 500);
  assert.deepEqual(await grants(uid), []);
  const audits = (await db.collection('audit_logs').where('uid', '==', uid).get()).docs.map(d => d.get('event'));
  assert.deepEqual(audits, ['paymongoPassNoPublishedSitting']);
});

test('a refund revokes the grant, recomputes the entitlement and the claims drop', async () => {
  const uid = 'pm-refund';
  await reset(uid);
  const {deps, auth} = setup(uid, 'pantas_cs_monthly');
  assert.equal(await send(paidEvent({uid, product: 'pantas_cs_monthly'}), deps), 200);
  assert.equal(auth.current().pro, true);
  const refund = resourceEvent({id: 'evt_r1', type: 'refund.succeeded', resource: 'refund', attributes: {payment_id: 'pay_pm-refund', amount: 14900, status: 'succeeded'}, resourceId: 'ref_full'});
  assert.equal(await send(refund, deps), 200);
  const [grant] = await grants(uid);
  assert.equal(grant.state, 'revoked');
  const record = await entitlement(uid);
  assert.equal(record.pro, false);
  assert.equal(record.proUntil, 0);
  assert.equal(record.version, 2);
  assert.equal(auth.current().pro, false);
  assert.equal(auth.current().proUntil, 0);
  // A replayed refund event changes nothing.
  assert.equal(await send(refund, deps), 200);
  assert.equal((await entitlement(uid)).version, 2);
});

test('a dispute revokes; a refund keeps other live grants, and refunds with no payment id fail for retry', async () => {
  const uid = 'pm-dispute';
  await reset(uid);
  const a = setup(uid, 'pantas_cs_monthly', {sessionId: 'cs_d1', paymentId: 'pay_d1'});
  const b = setup(uid, 'pantas_cs_weekly', {sessionId: 'cs_d2', paymentId: 'pay_d2'});
  assert.equal(await send(paidEvent({id: 'evt_d1', sessionId: 'cs_d1', uid, product: 'pantas_cs_monthly'}), a.deps), 200);
  assert.equal(await send(paidEvent({id: 'evt_d2', sessionId: 'cs_d2', uid, product: 'pantas_cs_weekly'}), b.deps), 200);
  const dispute = resourceEvent({id: 'evt_dsp', type: 'dispute.created', resource: 'dispute', attributes: {payment_id: 'pay_d2', status: 'under_review'}});
  assert.equal(await send(dispute, b.deps), 200);
  const rows = Object.fromEntries((await grants(uid)).map(g => [g.id, g.state]));
  assert.deepEqual(rows, {pay_d1: 'active', pay_d2: 'revoked'});
  assert.equal((await entitlement(uid)).pro, true);
  const before = (await entitlement(uid)).version;
  // No payment id anywhere: 500 so PayMongo retries and the log alerts. Nothing changes.
  assert.equal(await send(resourceEvent({id: 'evt_no', type: 'refund.succeeded', resource: 'refund', attributes: {amount: 1}}), b.deps), 500);
  // A payment we have not seen yet: tombstone, 200, nothing else changes.
  assert.equal(await send(resourceEvent({id: 'evt_un', type: 'refund.succeeded', resource: 'refund', attributes: {payment_id: 'pay_unknown', amount: 100}}), b.deps), 200);
  assert.equal((await entitlement(uid)).version, before);
});

test('a RevenueCat answer keeps live PayMongo grants; recomputing pass ends keeps them too', async () => {
  const uid = 'pm-rc';
  await reset(uid);
  const {deps, auth} = setup(uid, 'pantas_cs_monthly', {now: Date.now()});
  assert.equal(await send(paidEvent({uid, product: 'pantas_cs_monthly'}), deps), 200);
  const grantEnd = (await grants(uid))[0].endsAt;
  const rc = (event) => {
    const body = {event: {app_id: 'app-test', environment: 'PRODUCTION', app_user_id: uid, ...event}};
    const raw = Buffer.from(JSON.stringify(body));
    const t = Math.floor(Date.now() / 1000);
    return import('node:crypto').then(({createHmac}) =>
      reconcileWebhook(body, raw, `t=${t},v1=${createHmac('sha256', 'rc-secret').update(`${t}.`).update(raw).digest('hex')}`,
        {db, auth, appId: 'app-test', firebaseProjectId: 'pantas-prod', signingSecret: 'rc-secret', readCustomer: async () => []}));
  };
  assert.equal(await rc({id: 'rc-1', type: 'EXPIRATION'}), 200);
  const record = await entitlement(uid);
  assert.equal(record.pro, true);
  assert.equal(record.proUntil, grantEnd + 86400000);
  assert.equal(auth.current().pro, true);
  // Pass-end recompute reads the grant ledger as well.
  const passUid = 'pm-rc-pass';
  await reset(passUid);
  await db.doc(`users/${passUid}/passes/p1`).set({transactionId: 'p1', product: 'pantas_pass_cse_pro', examId: 'exam_cse_pro',
    purchasedAt: 1, sitting: {firstDay: '2027-03-14', lastDay: '2027-03-14', sourceUrl: 'x'}, endsAt: ph('2027-03-14T23:59:59.999+08:00'), state: 'active'});
  const gEnd = ph('2030-01-01T00:00:00+08:00');
  await db.doc(`users/${passUid}/grants/pay_x`).set({source: 'paymongo', product: 'pantas_cs_yearly', tier: 'civilService',
    startsAt: 1, endsAt: gEnd, paymentId: 'pay_x', state: 'active', createdAt: 1});
  await db.doc(`users/${passUid}/server/entitlement`).set({pro: true, proUntil: 1, version: 1, claimsVersion: 1, claimsPending: false,
    facts: {sources: [], coverageContext: {appId: 'a', firebaseProjectId: 'p', sandboxTester: false}}});
  const later = [{id: 'exam_cse_pro', publishedSittings: [{firstDay: '2027-03-14', lastDay: '2027-03-20', sourceUrl: 'x'}]}];
  const changed = await recomputePassRecords(db, later, fakeAuth());
  assert.ok(changed >= 1);
  assert.equal((await entitlement(passUid)).proUntil, gEnd + 86400000);
});

test('the per-account rate limit stops a flood with 429', async () => {
  const uid = 'pm-rate';
  await reset(uid);
  const {deps, now} = setup(uid, 'pantas_cs_weekly');
  const minute = Math.floor(now / 60_000);
  await db.doc(`webhookRateLimits/${uid}_${minute}`).set({uid, count: 30});
  assert.equal(await send(paidEvent({uid, product: 'pantas_cs_weekly'}), deps), 429);
  assert.deepEqual(await grants(uid), []);
  assert.equal((await db.doc('paymongoFollowUps/pay_pm-rate').get()).get('status'), 'pending');
  assert.equal((await db.doc(`webhookEvents/evt_1/users/${uid}`).get()).exists, false);
});

const refundOf = (id, paymentId, amount = 14900, refundId = `ref_${id}`) => resourceEvent({id, type: 'refund.succeeded', resource: 'refund',
  resourceId: refundId, attributes: {payment_id: paymentId, amount, status: 'succeeded'}});
const at = iso => () => ph(iso);

test('two stacked months: refunding the first pulls the second forward so coverage ends one month later, not two', async () => {
  const uid = 'pm-restack';
  await reset(uid);
  const a = setup(uid, 'pantas_cs_monthly', {sessionId: 'cs_a', paymentId: 'pay_ra', now: ph('2026-10-20T10:00:00+08:00')});
  const b = setup(uid, 'pantas_cs_monthly', {sessionId: 'cs_b', paymentId: 'pay_rb', now: ph('2026-10-25T09:00:00+08:00')});
  assert.equal(await send(paidEvent({id: 'evt_ra', sessionId: 'cs_a', uid, product: 'pantas_cs_monthly'}), a.deps), 200);
  assert.equal(await send(paidEvent({id: 'evt_rb', sessionId: 'cs_b', uid, product: 'pantas_cs_monthly'}), b.deps), 200);
  assert.equal((await entitlement(uid)).proUntil, ph('2026-12-20T10:00:00+08:00') + 86400000);
  const refundTime = ph('2026-10-30T09:00:00+08:00');
  assert.equal(await send(refundOf('evt_rr', 'pay_ra'), {...a.deps, now: () => refundTime}), 200);
  const rows = Object.fromEntries((await grants(uid)).map(g => [g.id, g]));
  assert.equal(rows.pay_ra.state, 'revoked');
  assert.equal(rows.pay_rb.startsAt, refundTime);
  assert.equal(rows.pay_rb.endsAt, ph('2026-11-30T09:00:00+08:00'));
  const record = await entitlement(uid);
  assert.equal(record.proUntil, ph('2026-11-30T09:00:00+08:00') + 86400000);
  assert.equal(a.auth.current().proUntil, record.proUntil);
});

test('two stacked months: refunding the second leaves the first untouched', async () => {
  const uid = 'pm-restack-2';
  await reset(uid);
  const a = setup(uid, 'pantas_cs_monthly', {sessionId: 'cs_a', paymentId: 'pay_sa', now: ph('2026-10-20T10:00:00+08:00')});
  const b = setup(uid, 'pantas_cs_monthly', {sessionId: 'cs_b', paymentId: 'pay_sb', now: ph('2026-10-25T09:00:00+08:00')});
  await send(paidEvent({id: 'evt_sa', sessionId: 'cs_a', uid, product: 'pantas_cs_monthly'}), a.deps);
  await send(paidEvent({id: 'evt_sb', sessionId: 'cs_b', uid, product: 'pantas_cs_monthly'}), b.deps);
  assert.equal(await send(refundOf('evt_sr', 'pay_sb'), {...b.deps, now: at('2026-10-30T09:00:00+08:00')}), 200);
  const rows = Object.fromEntries((await grants(uid)).map(g => [g.id, g]));
  assert.deepEqual([rows.pay_sa.state, rows.pay_sa.startsAt, rows.pay_sa.endsAt],
    ['active', ph('2026-10-20T10:00:00+08:00'), ph('2026-11-20T10:00:00+08:00')]);
  assert.equal(rows.pay_sb.state, 'revoked');
  assert.equal((await entitlement(uid)).proUntil, ph('2026-11-20T10:00:00+08:00') + 86400000);
});

test('payment.refunded with the payment as the resource revokes by data.id; pending updates are ignored', async () => {
  const uid = 'pm-payres';
  await reset(uid);
  const a = setup(uid, 'pantas_cs_monthly', {sessionId: 'cs_a', paymentId: 'pay_pr'});
  await send(paidEvent({id: 'evt_pa', sessionId: 'cs_a', uid, product: 'pantas_cs_monthly'}), a.deps);
  const pending = resourceEvent({id: 'evt_pu1', type: 'payment.refund.updated', resource: 'refund', attributes: {payment_id: 'pay_pr', status: 'pending'}});
  assert.equal(await send(pending, a.deps), 200);
  assert.equal((await grants(uid))[0].state, 'active');
  const payment = resourceEvent({id: 'evt_pr', type: 'payment.refunded', resource: 'payment', resourceId: 'pay_pr', attributes: {status: 'paid', refunds: [{id: 'ref_1', amount: 14900, status: 'succeeded'}]}});
  assert.equal(await send(payment, a.deps), 200);
  assert.equal((await grants(uid))[0].state, 'revoked');
  assert.equal((await entitlement(uid)).pro, false);
});

test('payment.refund.updated succeeded revokes through either resource shape', async () => {
  for (const [uid, shape] of [['pm-upd-refund', 'refund'], ['pm-upd-payment', 'payment']]) {
    await reset(uid);
    const paymentId = `pay_${uid}`;
    const a = setup(uid, 'pantas_cs_weekly', {sessionId: 'cs_a', paymentId});
    await send(paidEvent({id: `evt_${uid}`, sessionId: 'cs_a', uid, product: 'pantas_cs_weekly'}), a.deps);
    const event = shape === 'refund'
      ? resourceEvent({id: `evt_u_${uid}`, type: 'payment.refund.updated', resource: 'refund', attributes: {payment_id: paymentId, amount: 4900, status: 'succeeded'}})
      : resourceEvent({id: `evt_u_${uid}`, type: 'payment.refund.updated', resource: 'payment', resourceId: paymentId, attributes: {refunds: [{id: 'r', attributes: {status: 'succeeded', amount: 4900}}]}});
    assert.equal(await send(event, a.deps), 200);
    assert.equal((await grants(uid))[0].state, 'revoked', uid);
  }
});

test('a refund or dispute with no findable payment id returns 500 and logs an alert row', async () => {
  const uid = 'pm-noid';
  const {deps} = setup(uid, 'pantas_cs_weekly');
  for (const [i, type] of ['refund.succeeded', 'payment.refunded', 'dispute.created'].entries()) {
    const event = resourceEvent({id: `evt_noid${i}`, type, resource: type.startsWith('dispute') ? 'dispute' : 'refund', attributes: {amount: 1}});
    assert.equal(await send(event, deps), 500, type);
  }
  const audits = await db.collection('audit_logs').where('event', '==', 'paymongoRevokeWithoutPayment').get();
  assert.ok(audits.size >= 3);
});

test('refund before the paid event: a tombstone is kept and the later paid event creates a revoked grant', async () => {
  const uid = 'pm-tomb';
  await reset(uid);
  const {deps, auth} = setup(uid, 'pantas_cs_monthly', {sessionId: 'cs_t', paymentId: 'pay_tomb'});
  assert.equal(await send(refundOf('evt_tr', 'pay_tomb'), deps), 200);
  const tomb = await db.doc('paymongoRevocations/pay_tomb').get();
  assert.equal(tomb.exists, true);
  assert.equal(tomb.get('reason'), 'refund.succeeded');
  // A replayed refund keeps the same single tombstone.
  assert.equal(await send(refundOf('evt_tr', 'pay_tomb'), deps), 200);
  assert.equal(await send(paidEvent({id: 'evt_tp', sessionId: 'cs_t', uid, product: 'pantas_cs_monthly'}), deps), 200);
  const [grant] = await grants(uid);
  assert.equal(grant.state, 'revoked');
  // No access was ever given: there is no entitlement record and no claim.
  assert.notEqual((await entitlement(uid))?.pro, true);
  assert.notEqual(auth.current().pro, true);
  const audits = (await db.collection('audit_logs').where('uid', '==', uid).get()).docs.map(d => d.get('event'));
  assert.deepEqual(audits, ['paymongoGrantBornRevoked']);
  // The paid event again changes nothing.
  assert.equal(await send(paidEvent({id: 'evt_tp', sessionId: 'cs_t', uid, product: 'pantas_cs_monthly'}), deps), 200);
  assert.equal((await grants(uid)).length, 1);
});

test('a dispute before the paid event is tombstoned too; paid before refund is the ordinary revoke', async () => {
  const uid = 'pm-tomb-dsp';
  await reset(uid);
  const {deps} = setup(uid, 'pantas_cs_weekly', {sessionId: 'cs_t', paymentId: 'pay_tomb_dsp'});
  const dispute = resourceEvent({id: 'evt_td', type: 'dispute.created', resource: 'dispute', attributes: {payment_id: 'pay_tomb_dsp'}});
  assert.equal(await send(dispute, deps), 200);
  assert.equal(await send(paidEvent({id: 'evt_tdp', sessionId: 'cs_t', uid, product: 'pantas_cs_weekly'}), deps), 200);
  assert.equal((await grants(uid))[0].state, 'revoked');
  assert.notEqual((await entitlement(uid))?.pro, true);
});

test('a revoked-at-birth grant does not hold up the stack and never extends a later purchase', async () => {
  const uid = 'pm-tomb-stack';
  await reset(uid);
  const dead = setup(uid, 'pantas_cs_monthly', {sessionId: 'cs_x', paymentId: 'pay_dead'});
  await send(refundOf('evt_dead_r', 'pay_dead'), dead.deps);
  await send(paidEvent({id: 'evt_dead_p', sessionId: 'cs_x', uid, product: 'pantas_cs_monthly'}), dead.deps);
  const live = setup(uid, 'pantas_cs_monthly', {sessionId: 'cs_y', paymentId: 'pay_live'});
  await send(paidEvent({id: 'evt_live', sessionId: 'cs_y', uid, product: 'pantas_cs_monthly'}), live.deps);
  const rows = Object.fromEntries((await grants(uid)).map(g => [g.id, g]));
  assert.equal(rows.pay_live.startsAt, live.now);
  assert.equal((await entitlement(uid)).pro, true);
});

// ---- partial refunds shorten the grant in proportion to the refunded share ----
const T0 = ph('2026-10-20T10:00:00+08:00');
const MONTH = ph('2026-11-20T10:00:00+08:00') - T0;           // 31 days
const REFUND_AT = at('2026-10-30T09:00:00+08:00');
async function buyMonthly(uid, paymentId, now = T0, sessionId = 'cs_pm') {
  await reset(uid);
  const s = setup(uid, 'pantas_cs_monthly', {sessionId, paymentId, now});
  assert.equal(await send(paidEvent({id: `evt_buy_${paymentId}`, sessionId, uid, product: 'pantas_cs_monthly'}), s.deps), 200);
  return s;
}
const grantOf = async (uid, id) => (await db.doc(`users/${uid}/grants/${id}`).get()).data();

test('a 50% refund of a monthly halves its length from startsAt and stores the paid amount and refund', async () => {
  const uid = 'pm-part-50';
  const s = await buyMonthly(uid, 'pay_p50');
  assert.equal(await send(refundOf('evt_p50', 'pay_p50', 7450, 'ref_a'), {...s.deps, now: REFUND_AT}), 200);
  const g = await grantOf(uid, 'pay_p50');
  assert.equal(g.state, 'active');
  assert.equal(g.paidAmount, 14900);
  assert.deepEqual(g.refunds, {ref_a: 7450});
  assert.equal(g.startsAt, T0);
  assert.equal(g.endsAt, T0 + Math.floor(MONTH / 2 / 1000) * 1000);
  const record = await entitlement(uid);
  assert.equal(record.proUntil, g.endsAt + 86400000);
  assert.equal(s.auth.current().proUntil, record.proUntil);
});

test('two 25% refunds add up to one 50% refund', async () => {
  const uid = 'pm-part-25x2';
  const s = await buyMonthly(uid, 'pay_p25');
  assert.equal(await send(refundOf('evt_p25a', 'pay_p25', 3725, 'ref_a'), {...s.deps, now: REFUND_AT}), 200);
  assert.equal(await send(refundOf('evt_p25b', 'pay_p25', 3725, 'ref_b'), {...s.deps, now: REFUND_AT}), 200);
  const g = await grantOf(uid, 'pay_p25');
  assert.equal(g.endsAt, T0 + Math.floor(MONTH / 2 / 1000) * 1000);
  assert.deepEqual(g.refunds, {ref_a: 3725, ref_b: 3725});
});

test('the same refund replayed, or reported by a second event, changes nothing', async () => {
  const uid = 'pm-part-replay';
  const s = await buyMonthly(uid, 'pay_prp');
  const deps = {...s.deps, now: REFUND_AT};
  assert.equal(await send(refundOf('evt_rp1', 'pay_prp', 7450, 'ref_a'), deps), 200);
  const before = {g: await grantOf(uid, 'pay_prp'), r: await entitlement(uid)};
  assert.equal(await send(refundOf('evt_rp1', 'pay_prp', 7450, 'ref_a'), deps), 200);
  // Another event carrying the same refund (payment.refunded after refund.succeeded).
  const again = resourceEvent({id: 'evt_rp2', type: 'payment.refunded', resource: 'payment', resourceId: 'pay_prp',
    attributes: {status: 'paid', refunds: [{id: 'ref_a', amount: 7450, status: 'succeeded'}]}});
  assert.equal(await send(again, deps), 200);
  assert.deepEqual(await grantOf(uid, 'pay_prp'), before.g);
  assert.equal((await entitlement(uid)).proUntil, before.r.proUntil);
});

test('a partial refund followed by a refund that completes the payment revokes the grant', async () => {
  const uid = 'pm-part-full';
  const s = await buyMonthly(uid, 'pay_pfl');
  const deps = {...s.deps, now: REFUND_AT};
  await send(refundOf('evt_pf1', 'pay_pfl', 7450, 'ref_a'), deps);
  assert.equal((await grantOf(uid, 'pay_pfl')).state, 'active');
  await send(refundOf('evt_pf2', 'pay_pfl', 7450, 'ref_b'), deps);
  const g = await grantOf(uid, 'pay_pfl');
  assert.equal(g.state, 'revoked');
  assert.equal((await entitlement(uid)).pro, false);
  assert.equal(s.auth.current().pro, false);
});

test('a dispute still revokes the whole grant, even after a partial refund', async () => {
  const uid = 'pm-part-dispute';
  const s = await buyMonthly(uid, 'pay_pdp');
  const deps = {...s.deps, now: REFUND_AT};
  await send(refundOf('evt_pd1', 'pay_pdp', 1490, 'ref_a'), deps);
  assert.equal((await grantOf(uid, 'pay_pdp')).state, 'active');
  assert.equal(await send(resourceEvent({id: 'evt_pd2', type: 'dispute.created', resource: 'dispute', attributes: {payment_id: 'pay_pdp'}}), deps), 200);
  assert.equal((await grantOf(uid, 'pay_pdp')).state, 'revoked');
  assert.equal((await entitlement(uid)).pro, false);
});

test('a partial refund of the first of two stacked grants pulls the second earlier by the removed time', async () => {
  const uid = 'pm-part-stack';
  await reset(uid);
  const a = setup(uid, 'pantas_cs_monthly', {sessionId: 'cs_a', paymentId: 'pay_psa', now: T0});
  const b = setup(uid, 'pantas_cs_monthly', {sessionId: 'cs_b', paymentId: 'pay_psb', now: ph('2026-10-25T09:00:00+08:00')});
  await send(paidEvent({id: 'evt_psa', sessionId: 'cs_a', uid, product: 'pantas_cs_monthly'}), a.deps);
  await send(paidEvent({id: 'evt_psb', sessionId: 'cs_b', uid, product: 'pantas_cs_monthly'}), b.deps);
  const bBefore = await grantOf(uid, 'pay_psb');
  assert.equal(bBefore.startsAt, T0 + MONTH);
  assert.equal(await send(refundOf('evt_psr', 'pay_psa', 7450, 'ref_a'), {...a.deps, now: REFUND_AT}), 200);
  const removed = MONTH - Math.floor(MONTH / 2 / 1000) * 1000;
  const aAfter = await grantOf(uid, 'pay_psa');
  const bAfter = await grantOf(uid, 'pay_psb');
  assert.equal(aAfter.endsAt, T0 + MONTH - removed);
  assert.equal(bAfter.startsAt, aAfter.endsAt);
  assert.equal(bBefore.startsAt - bAfter.startsAt, removed);
  assert.equal(bAfter.endsAt, ph('2026-12-04T22:00:00+08:00'));
  assert.equal((await entitlement(uid)).proUntil, bAfter.endsAt + 86400000);
});

test('a partial refund arriving before the paid event: the grant is born already shortened', async () => {
  const uid = 'pm-part-early';
  await reset(uid);
  const s = setup(uid, 'pantas_cs_monthly', {sessionId: 'cs_e', paymentId: 'pay_pe'});
  assert.equal(await send(refundOf('evt_pe1', 'pay_pe', 7450, 'ref_a'), s.deps), 200);
  assert.equal((await db.doc('paymongoRevocations/pay_pe').get()).get('refunds').ref_a, 7450);
  // A second partial refund before the payment adds to the tombstone; a replay does not.
  assert.equal(await send(refundOf('evt_pe2', 'pay_pe', 1490, 'ref_b'), s.deps), 200);
  assert.equal(await send(refundOf('evt_pe2', 'pay_pe', 1490, 'ref_b'), s.deps), 200);
  assert.deepEqual((await db.doc('paymongoRevocations/pay_pe').get()).get('refunds'), {ref_a: 7450, ref_b: 1490});
  assert.equal(await send(paidEvent({id: 'evt_pe3', sessionId: 'cs_e', uid, product: 'pantas_cs_monthly'}), s.deps), 200);
  const g = await grantOf(uid, 'pay_pe');
  assert.equal(g.state, 'active');
  assert.deepEqual(g.refunds, {ref_a: 7450, ref_b: 1490});
  assert.equal(g.endsAt, T0 + Math.floor(MONTH * (14900 - 8940) / 14900 / 1000) * 1000);
  assert.equal((await entitlement(uid)).proUntil, g.endsAt + 86400000);
});

test('refunds that already cover the payment before the paid event give a revoked grant', async () => {
  const uid = 'pm-part-early-full';
  await reset(uid);
  const s = setup(uid, 'pantas_cs_monthly', {sessionId: 'cs_e', paymentId: 'pay_pef'});
  await send(refundOf('evt_pef1', 'pay_pef', 7450, 'ref_a'), s.deps);
  await send(refundOf('evt_pef2', 'pay_pef', 7450, 'ref_b'), s.deps);
  assert.equal(await send(paidEvent({id: 'evt_pef3', sessionId: 'cs_e', uid, product: 'pantas_cs_monthly'}), s.deps), 200);
  assert.equal((await grantOf(uid, 'pay_pef')).state, 'revoked');
  assert.notEqual((await entitlement(uid))?.pro, true);
});

test('a refund without an amount is re-read from PayMongo; an untrustworthy re-read returns 500 with an audit row', async () => {
  const uid = 'pm-part-api';
  const s = await buyMonthly(uid, 'pay_pap');
  const noAmount = id => resourceEvent({id, type: 'refund.succeeded', resource: 'refund', resourceId: 'ref_api',
    attributes: {payment_id: 'pay_pap'}});
  const good = {id: 'ref_api', amount: 7450, status: 'succeeded', paymentId: 'pay_pap'};
  const bad = {...s.deps, now: REFUND_AT, client: fakeClient({}, {})};
  assert.equal(await send(noAmount('evt_api0'), bad), 500);
  for (const [i, wrong] of [{...good, paymentId: 'pay_other'}, {...good, status: 'pending'}, {...good, amount: 0}, {...good, id: 'ref_zzz'}].entries()) {
    const deps = {...s.deps, now: REFUND_AT, client: fakeClient({}, {ref_api: wrong})};
    assert.equal(await send(noAmount(`evt_api_bad${i}`), deps), 500, JSON.stringify(wrong));
  }
  assert.deepEqual(await grantOf(uid, 'pay_pap').then(g => g.refunds ?? {}), {});
  const ok = {...s.deps, now: REFUND_AT, client: fakeClient({}, {ref_api: good})};
  assert.equal(await send(noAmount('evt_api1'), ok), 200);
  assert.deepEqual(ok.client.refundCalls, ['ref_api']);
  assert.deepEqual((await grantOf(uid, 'pay_pap')).refunds, {ref_api: 7450});
  const audits = (await db.collection('audit_logs').where('event', '==', 'paymongoRefundAmountUnverified').get()).size;
  assert.ok(audits >= 5);
});

test('a payment.refunded payload with several refunds applies each once; one without refund details is re-read or fails', async () => {
  const uid = 'pm-part-multi';
  const s = await buyMonthly(uid, 'pay_pmu');
  const deps = {...s.deps, now: REFUND_AT};
  const event = resourceEvent({id: 'evt_mu1', type: 'payment.refunded', resource: 'payment', resourceId: 'pay_pmu',
    attributes: {status: 'paid', refunds: [{id: 'ref_a', amount: 3725, status: 'succeeded'}, {id: 'ref_b', attributes: {amount: 3725, status: 'succeeded'}}, {id: 'ref_c', amount: 100, status: 'pending'}]}});
  assert.equal(await send(event, deps), 200);
  assert.deepEqual((await grantOf(uid, 'pay_pmu')).refunds, {ref_a: 3725, ref_b: 3725});
  const empty = resourceEvent({id: 'evt_mu2', type: 'payment.refunded', resource: 'payment', resourceId: 'pay_pmu', attributes: {status: 'paid'}});
  assert.equal(await send(empty, deps), 500);
});

test('a refund against an ended grant only records the refund', async () => {
  const uid = 'pm-part-ended';
  const s = await buyMonthly(uid, 'pay_pen');
  const g0 = await grantOf(uid, 'pay_pen');
  assert.equal(await send(refundOf('evt_pen', 'pay_pen', 7450, 'ref_a'), {...s.deps, now: at('2026-12-25T09:00:00+08:00')}), 200);
  const g = await grantOf(uid, 'pay_pen');
  assert.equal(g.endsAt, g0.endsAt);
  assert.deepEqual(g.refunds, {ref_a: 7450});
  assert.equal(g.state, 'active');
});

for (const scenario of ['won', 'lost', 'partial-before', 'partial-after', 'full-after', 'other-revoke', 'other-before', 'wrong-dispute', 'expired']) {
  test(`dispute resolution: ${scenario}`, async () => {
    const uid = `pm-resolution-${scenario}`;
    await reset(uid);
    const {deps, auth, now} = setup(uid, 'pantas_cs_monthly');
    const paymentId = `pay_${uid}`;
    const event = (type, status, id = type) => resourceEvent({id: `${uid}-${id}`, type,
      resource: 'dispute', resourceId: `dp_${uid}`, attributes: {payment_id: paymentId, status}});
    const refund = () => send(resourceEvent({id: `${uid}-refund`, type: 'refund.succeeded',
      resource: 'refund', resourceId: `ref_${uid}`, attributes: {payment_id: paymentId,
        status: 'succeeded', amount: scenario === 'full-after' ? 14900 : 7450}}), deps);
    assert.equal(await send(paidEvent({id: `${uid}-paid`, uid, product: 'pantas_cs_monthly'}), deps), 200);
    if (scenario === 'partial-before') assert.equal(await refund(), 200);
    const original = (await grants(uid))[0];
    if (scenario === 'other-before') await db.doc(`users/${uid}/grants/${paymentId}`).update({state: 'revoked', revokedReason: 'admin'});
    assert.equal(await send(event('dispute.created', 'under_review'), deps), 200);
    if (scenario.endsWith('after')) assert.equal(await refund(), 200);
    if (scenario === 'other-revoke') await db.doc(`users/${uid}/grants/${paymentId}`).update({revokedReason: 'admin'});
    if (scenario === 'expired') deps.now = () => ph('2026-12-01T10:00:00+08:00');
    const resolution = event('dispute.resolved', scenario === 'lost' ? 'lost' : 'won');
    if (scenario === 'wrong-dispute') resolution.data.attributes.data.id = 'dp_unrelated';
    assert.equal(await send(resolution, deps), 200);
    const restored = (await grants(uid))[0];
    const shouldRestore = scenario === 'won' || scenario === 'expired';
    assert.equal(restored.state, shouldRestore ? 'active' : 'revoked');
    assert.ok(restored.endsAt <= original.endsAt);
    if (shouldRestore) {
      assert.equal(restored.endsAt, original.endsAt);
      assert.equal(auth.current().pro, scenario !== 'expired');
    }
    const beforeRetry = await entitlement(uid);
    assert.equal(await send(resolution, deps), 200);
    if (scenario !== 'wrong-dispute') assert.equal(await send(event('dispute.resolved', 'won', 'another-resolution'), deps), 200);
    assert.deepEqual(await grants(uid), [restored]);
    assert.equal((await entitlement(uid)).version, beforeRetry.version);
  });
}

test('a win restores a grant born revoked by an earlier dispute', async () => {
  const uid = 'pm-early-dispute-win';
  await reset(uid);
  const {deps, auth} = setup(uid, 'pantas_cs_monthly');
  const dispute = type => resourceEvent({id: `${uid}-${type}`, type, resource: 'dispute',
    resourceId: 'dp_early_win', attributes: {payment_id: `pay_${uid}`, status: type === 'dispute.resolved' ? 'won' : 'under_review'}});
  assert.equal(await send(dispute('dispute.created'), deps), 200);
  assert.equal(await send(paidEvent({id: `${uid}-paid`, uid, product: 'pantas_cs_monthly'}), deps), 200);
  const [before] = await grants(uid);
  assert.equal(before.state, 'revoked');
  assert.equal(await send(dispute('dispute.resolved'), deps), 200);
  const [after] = await grants(uid);
  assert.equal(after.state, 'active');
  assert.equal(after.endsAt, ph('2026-11-20T10:00:00+08:00'));
  assert.equal(auth.current().pro, true);
});
