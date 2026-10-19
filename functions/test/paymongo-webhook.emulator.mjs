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
  const client = fakeClient({[sessionId]: session({id: sessionId, uid, product, paymentId, amount: amount ?? PRICE[product]})});
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
  assert.equal(await send(paidEvent({uid, product: 'pantas_cs_yearly'}), deps), 200);
  // Event claims another account.
  assert.equal(await send(paidEvent({id: 'evt_2', uid: 'someone-else', product: 'pantas_cs_weekly'}), deps), 200);
  // Session has no metadata at all.
  const empty = {...deps, client: fakeClient({cs_1: session({uid, product: 'x', amount: 4900, metadata: {}})})};
  assert.equal(await send(paidEvent({id: 'evt_3', uid, product: 'pantas_cs_weekly'}), empty), 200);
  assert.deepEqual(await grants(uid), []);
  assert.deepEqual(await grants('someone-else'), []);
  assert.equal((await entitlement(uid)), undefined);
});

test('the paid amount must equal the products.json price', async () => {
  const uid = 'pm-amount';
  await reset(uid);
  for (const [i, amount] of [4800, 14900, 0].entries()) {
    const {deps} = setup(uid, 'pantas_cs_weekly', {amount, sessionId: `cs_a${i}`, paymentId: `pay_a${i}`});
    assert.equal(await send(paidEvent({id: `evt_a${i}`, sessionId: `cs_a${i}`, uid, product: 'pantas_cs_weekly'}), deps), 200);
  }
  const wrongCurrency = {...setup(uid, 'pantas_cs_weekly').deps, client: fakeClient({cs_1: {...session({uid, product: 'pantas_cs_weekly', amount: 4900}),
    payments: [{id: 'pay_c', amount: 4900, currency: 'USD', status: 'paid'}]}})};
  assert.equal(await send(paidEvent({id: 'evt_c', uid, product: 'pantas_cs_weekly'}), wrongCurrency), 200);
  assert.deepEqual(await grants(uid), []);
  const audits = (await db.collection('audit_logs').where('uid', '==', uid).get()).docs.map(d => d.get('event'));
  assert.ok(audits.filter(e => e === 'paymongoAmountMismatch').length >= 4);
});

test('unknown and non-web products are refused', async () => {
  const uid = 'pm-unknown';
  await reset(uid);
  for (const [i, product] of ['pantas_made_up', 'pantas_pro_monthly', 'promo_student'].entries()) {
    const {deps} = setup(uid, product, {amount: 14900, sessionId: `cs_u${i}`, paymentId: `pay_u${i}`});
    assert.equal(await send(paidEvent({id: `evt_u${i}`, sessionId: `cs_u${i}`, uid, product}), deps), 200);
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
  assert.equal(await send(paidEvent({uid, product: 'pantas_cs_weekly'}), gone), 200);
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
  assert.equal(await send(paidEvent({uid, product: 'pantas_pass_cse_pro'}), {...deps, catalog: []}), 200);
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
  const refund = resourceEvent({id: 'evt_r1', type: 'refund.succeeded', resource: 'refund', attributes: {payment_id: 'pay_pm-refund', amount: 14900, status: 'succeeded'}});
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
  assert.equal(await send(resourceEvent({id: 'evt_un', type: 'refund.succeeded', resource: 'refund', attributes: {payment_id: 'pay_unknown'}}), b.deps), 200);
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
});

const refundOf = (id, paymentId) => resourceEvent({id, type: 'refund.succeeded', resource: 'refund', attributes: {payment_id: paymentId, status: 'succeeded'}});
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
  const payment = resourceEvent({id: 'evt_pr', type: 'payment.refunded', resource: 'payment', resourceId: 'pay_pr', attributes: {status: 'paid', refunds: [{id: 'ref_1'}]}});
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
      ? resourceEvent({id: `evt_u_${uid}`, type: 'payment.refund.updated', resource: 'refund', attributes: {payment_id: paymentId, status: 'succeeded'}})
      : resourceEvent({id: `evt_u_${uid}`, type: 'payment.refund.updated', resource: 'payment', resourceId: paymentId, attributes: {refunds: [{id: 'r', attributes: {status: 'succeeded'}}]}});
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
