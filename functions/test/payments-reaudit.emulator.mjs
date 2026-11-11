import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {createHmac} from 'node:crypto';
import {getFirestore} from 'firebase-admin/firestore';
import {commitPaymongoGrant} from '../lib/paymongoGrants.js';
import {addPrepaid, webProduct} from '../lib/paymongoPolicy.js';
import {webEntitlement} from '../lib/webEntitlement.js';
import {recomputePassRecords} from '../lib/revenuecatPasses.js';
import {reconcileWebhook} from '../lib/revenuecatWebhook.js';
import {fakeAuth, fakeClient, paidEvent, ph, resourceEvent, send, session, SECRET} from './_paymongo-helpers.mjs';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
const db = getFirestore();
const sitting = {firstDay: '2027-03-14', lastDay: '2027-03-14', sourceUrl: 'https://example.test/sitting'};
const catalog = [{id: 'exam_cse_pro', publishedSittings: [sitting]}];
const reset = uid => db.recursiveDelete(db.doc(`users/${uid}`));
const grantDoc = async (uid, id) => (await db.doc(`users/${uid}/grants/${id}`).get()).data();
const PRICE = {pantas_cs_monthly: 14900, pantas_pass_cse_pro: 49900};
const paidAt = Date.parse('2027-03-10T10:00:00+08:00');

function webhookDeps(uid, product, sessionId, paymentId, now) {
  const auth = fakeAuth();
  const client = fakeClient({[sessionId]: session({id: sessionId, uid, product, paymentId, amount: PRICE[product], paidAt: now})});
  return {auth, deps: {db, auth, client, signingSecret: SECRET, livemode: false, catalog, now: () => now}};
}
const dispute = (uid, paymentId, disputeId, type, status = 'under_review') => resourceEvent({
  id: `${uid}-${disputeId}-${type}`, type, resource: 'dispute', resourceId: disputeId,
  attributes: {payment_id: paymentId, status}});

// Finding 1
test('reaudit 1: a win delivered before the paid event restores the original dates', async () => {
  const uid = 'ra1-win-before-paid'; await reset(uid);
  const now = ph('2026-10-20T10:00:00+08:00');
  const {auth, deps} = webhookDeps(uid, 'pantas_cs_monthly', 'cs_ra1', `pay_${uid}`, now);
  assert.equal(await send(dispute(uid, `pay_${uid}`, 'dp_ra1', 'dispute.created'), deps), 200);
  assert.equal(await send(dispute(uid, `pay_${uid}`, 'dp_ra1', 'dispute.resolved', 'won'), deps), 200);
  assert.equal(await send(paidEvent({id: `${uid}-paid`, sessionId: 'cs_ra1', uid, product: 'pantas_cs_monthly'}), deps), 200);
  const g = await grantDoc(uid, `pay_${uid}`);
  assert.equal(g.state, 'active');
  assert.equal(g.startsAt, now);
  assert.equal(g.endsAt, ph('2026-11-20T10:00:00+08:00'));
  assert.equal(auth.current().pro, true);
  // A retry of the same events stays idempotent.
  assert.equal(await send(dispute(uid, `pay_${uid}`, 'dp_ra1', 'dispute.resolved', 'won'), deps), 200);
  assert.deepEqual(await grantDoc(uid, `pay_${uid}`), g);
});
test('reaudit 1: a loss delivered before the paid event keeps the grant revoked', async () => {
  const uid = 'ra1-loss-before-paid'; await reset(uid);
  const now = ph('2026-10-20T10:00:00+08:00');
  const {deps} = webhookDeps(uid, 'pantas_cs_monthly', 'cs_ra1l', `pay_${uid}`, now);
  assert.equal(await send(dispute(uid, `pay_${uid}`, 'dp_ra1l', 'dispute.created'), deps), 200);
  assert.equal(await send(dispute(uid, `pay_${uid}`, 'dp_ra1l', 'dispute.resolved', 'lost'), deps), 200);
  assert.equal(await send(paidEvent({id: `${uid}-paid`, sessionId: 'cs_ra1l', uid, product: 'pantas_cs_monthly'}), deps), 200);
  assert.equal((await grantDoc(uid, `pay_${uid}`)).state, 'revoked');
});
test('reaudit 1: a win delivered before dispute.created keeps an existing grant active', async () => {
  const uid = 'ra1-win-before-created'; await reset(uid);
  const now = ph('2026-10-20T10:00:00+08:00');
  const {auth, deps} = webhookDeps(uid, 'pantas_cs_monthly', 'cs_ra1c', `pay_${uid}`, now);
  assert.equal(await send(paidEvent({id: `${uid}-paid`, sessionId: 'cs_ra1c', uid, product: 'pantas_cs_monthly'}), deps), 200);
  assert.equal(await send(dispute(uid, `pay_${uid}`, 'dp_ra1c', 'dispute.resolved', 'won'), deps), 200);
  assert.equal(await send(dispute(uid, `pay_${uid}`, 'dp_ra1c', 'dispute.created'), deps), 200);
  assert.equal((await grantDoc(uid, `pay_${uid}`)).state, 'active');
  assert.equal(auth.current().pro, true);
});
test('reaudit 1: a loss delivered before dispute.created revokes the existing grant', async () => {
  const uid = 'ra1-loss-before-created'; await reset(uid);
  const now = ph('2026-10-20T10:00:00+08:00');
  const {deps} = webhookDeps(uid, 'pantas_cs_monthly', 'cs_ra1d', `pay_${uid}`, now);
  assert.equal(await send(paidEvent({id: `${uid}-paid`, sessionId: 'cs_ra1d', uid, product: 'pantas_cs_monthly'}), deps), 200);
  assert.equal(await send(dispute(uid, `pay_${uid}`, 'dp_ra1d', 'dispute.resolved', 'lost'), deps), 200);
  assert.equal(await send(dispute(uid, `pay_${uid}`, 'dp_ra1d', 'dispute.created'), deps), 200);
  assert.equal((await grantDoc(uid, `pay_${uid}`)).state, 'revoked');
});

// Finding 2
test('reaudit 2: an early-disputed duplicate pass is flagged for refund and a win never activates it', async () => {
  const uid = 'ra2-dup'; await reset(uid);
  const first = await commitPaymongoGrant(db, {uid, eventId: 'evt_ra2_a', sessionId: 'cs_ra2_a', paymentId: 'pay_ra2_a',
    paidAmount: 49900, product: webProduct('pantas_pass_cse_pro'), paidAt, sitting}, paidAt + 1000, catalog);
  assert.equal(first, 'granted');
  const now = paidAt + 60000;
  const {deps} = webhookDeps(uid, 'pantas_pass_cse_pro', 'cs_ra2_b', 'pay_ra2_b', now);
  assert.equal(await send(dispute(uid, 'pay_ra2_b', 'dp_ra2', 'dispute.created'), deps), 200);
  assert.equal(await commitPaymongoGrant(db, {uid, eventId: 'evt_ra2_b', sessionId: 'cs_ra2_b', paymentId: 'pay_ra2_b',
    paidAmount: 49900, product: webProduct('pantas_pass_cse_pro'), paidAt: now, sitting}, now, catalog), 'bornRevoked');
  const b = await grantDoc(uid, 'pay_ra2_b');
  assert.equal(b.unusedDuplicateOf, 'pay_ra2_a');
  const flag = (await db.doc('paymongoFollowUps/pay_ra2_b').get()).data();
  assert.equal(flag.refundRequired, true);
  assert.equal(await send(dispute(uid, 'pay_ra2_b', 'dp_ra2', 'dispute.resolved', 'won'), deps), 200);
  assert.equal((await grantDoc(uid, 'pay_ra2_b')).state, 'revoked');
  assert.equal((await db.doc('paymongoFollowUps/pay_ra2_b').get()).get('refundRequired'), true);
});
test('reaudit 2: a duplicate pass whose win arrived first is also unused', async () => {
  const uid = 'ra2-dup-win-first'; await reset(uid);
  await commitPaymongoGrant(db, {uid, eventId: 'evt_ra2w_a', sessionId: 'cs_ra2w_a', paymentId: 'pay_ra2w_a',
    paidAmount: 49900, product: webProduct('pantas_pass_cse_pro'), paidAt, sitting}, paidAt + 1000, catalog);
  const now = paidAt + 60000;
  const {deps} = webhookDeps(uid, 'pantas_pass_cse_pro', 'cs_ra2w_b', 'pay_ra2w_b', now);
  await send(dispute(uid, 'pay_ra2w_b', 'dp_ra2w', 'dispute.created'), deps);
  await send(dispute(uid, 'pay_ra2w_b', 'dp_ra2w', 'dispute.resolved', 'won'), deps);
  assert.equal(await commitPaymongoGrant(db, {uid, eventId: 'evt_ra2w_b', sessionId: 'cs_ra2w_b', paymentId: 'pay_ra2w_b',
    paidAmount: 49900, product: webProduct('pantas_pass_cse_pro'), paidAt: now, sitting}, now, catalog), 'unusedDuplicate');
  const b = await grantDoc(uid, 'pay_ra2w_b');
  assert.equal(b.state, 'revoked');
  assert.equal((await db.doc('paymongoFollowUps/pay_ra2w_b').get()).get('refundRequired'), true);
});

// Finding 3
test('reaudit 3: a payment after the sitting ended is unusable and flagged for refund', async () => {
  const uid = 'ra3-late'; await reset(uid);
  const late = Date.parse('2027-03-15T00:00:30+08:00');
  const outcome = await commitPaymongoGrant(db, {uid, eventId: 'evt_ra3', sessionId: 'cs_ra3', paymentId: 'pay_ra3',
    paidAmount: 49900, product: webProduct('pantas_pass_cse_pro'), paidAt: late, sitting}, late + 5000, catalog);
  assert.notEqual(outcome, 'noSitting');
  const g = await grantDoc(uid, 'pay_ra3');
  assert.ok(g.startsAt <= g.endsAt);
  assert.equal(g.state, 'revoked');
  assert.equal((await db.doc('paymongoFollowUps/pay_ra3').get()).get('refundRequired'), true);
  assert.equal((await db.doc(`webhookEvents/evt_ra3/users/${uid}`).get()).exists, true);
  assert.equal((await db.doc(`users/${uid}/server/entitlement`).get()).get('pro') ?? false, false);
});

// Finding 4
test('reaudit 4: a paid event processed after a postponement uses the new sitting', async () => {
  const uid = 'ra4-postponed'; await reset(uid);
  const moved = {...sitting, firstDay: '2027-03-21', lastDay: '2027-03-21'};
  const movedCatalog = [{id: 'exam_cse_pro', publishedSittings: [moved]}];
  await recomputePassRecords(db, movedCatalog, fakeAuth(), {'exam_cse_pro:2027-03-14': '2027-03-21'});
  assert.equal(await commitPaymongoGrant(db, {uid, eventId: 'evt_ra4', sessionId: 'cs_ra4', paymentId: 'pay_ra4',
    paidAmount: 49900, product: webProduct('pantas_pass_cse_pro'), paidAt, sitting}, paidAt + 1000, movedCatalog), 'granted');
  const g = await grantDoc(uid, 'pay_ra4');
  assert.deepEqual(g.sitting, moved);
  assert.equal(g.endsAt, Date.parse('2027-03-21T23:59:59.999+08:00'));
});

test('reaudit 4: postponement chains survive a removed intermediate sitting', async () => {
  const uid = 'ra4-chain'; await reset(uid);
  const middle = {...sitting, firstDay: '2027-04-04', lastDay: '2027-04-04'};
  const final = {...sitting, firstDay: '2027-04-18', lastDay: '2027-04-18'};
  await recomputePassRecords(db, [{id: 'exam_cse_pro', publishedSittings: [middle]}], fakeAuth(),
    {'exam_cse_pro:2027-03-14': middle.firstDay});
  const finalCatalog = [{id: 'exam_cse_pro', publishedSittings: [final]}];
  await recomputePassRecords(db, finalCatalog, fakeAuth(), {'exam_cse_pro:2027-04-04': final.firstDay});
  assert.equal(await commitPaymongoGrant(db, {uid, eventId: 'evt_ra4_chain', sessionId: 'cs_ra4_chain', paymentId: 'pay_ra4_chain',
    paidAmount: 49900, product: webProduct('pantas_pass_cse_pro'), paidAt, sitting}, paidAt + 1000, finalCatalog), 'granted');
  const g = await grantDoc(uid, 'pay_ra4_chain');
  assert.deepEqual(g.sitting, final);
  assert.equal(g.endsAt, Date.parse('2027-04-18T23:59:59.999+08:00'));
});

// Finding 5
test('reaudit 5: removing native coverage re-anchors queued web time', async () => {
  const uid = 'ra5-native-revoked'; await reset(uid);
  const t0 = Date.parse('2026-10-30T00:00:00Z');
  const nativeEnd = Date.parse('2026-11-20T00:00:00Z');
  const source = {productId: 'pantas_cs_monthly', entitlementIds: ['pro'], appId: 'app-test',
    environment: 'production', store: 'play_store', endsAt: nativeEnd, active: true};
  const deliver = async (id, sources, at) => {
    const body = {event: {id, type: 'EXPIRATION', app_user_id: uid, app_id: 'app-test', environment: 'PRODUCTION'}};
    const raw = Buffer.from(JSON.stringify(body)); const t = Math.floor(at / 1000);
    return reconcileWebhook(body, raw, `t=${t},v1=${createHmac('sha256', 'rc-secret').update(`${t}.`).update(raw).digest('hex')}`, {
      db, auth: fakeAuth(), appId: 'app-test', firebaseProjectId: 'pantas-prod', signingSecret: 'rc-secret',
      now: () => at, readCustomer: async () => sources});
  };
  assert.equal(await deliver('evt_ra5_buy', [source], t0), 200);
  assert.equal(await commitPaymongoGrant(db, {uid, eventId: 'evt_ra5_web', sessionId: 'cs_ra5', paymentId: 'pay_ra5',
    paidAmount: 14900, product: webProduct('pantas_cs_monthly'), paidAt: t0 + 1000, sitting: undefined}, t0 + 1000, catalog), 'granted');
  const queued = await grantDoc(uid, 'pay_ra5');
  assert.equal(queued.startsAt, nativeEnd);
  const length = queued.endsAt - queued.startsAt;
  const later = t0 + 60000;
  assert.equal(await deliver('evt_ra5_refund', [{...source, active: false}], later), 200);
  const g = await grantDoc(uid, 'pay_ra5');
  assert.ok(g.startsAt <= later, `start ${g.startsAt}`);
  assert.equal(g.endsAt - g.startsAt > 0, true);
  assert.equal(g.endsAt, addPrepaid(g.startsAt, webProduct('pantas_cs_monthly').prepaid));
  assert.ok(length > 0);
  const record = (await db.doc(`users/${uid}/server/entitlement`).get()).data();
  assert.equal(record.pro, true);
});

// Finding 6
test('reaudit 6: a promotional entitlement counts as coverage and web purchases queue behind it', async () => {
  const uid = 'ra6-promo'; await reset(uid);
  const t0 = Date.parse('2026-10-30T00:00:00Z');
  const promoEnd = Date.parse('2026-12-01T00:00:00Z');
  await db.doc(`users/${uid}/server/entitlement`).set({version: 1, facts: {
    coverageContext: {appId: 'app-test', firebaseProjectId: 'pantas-prod', sandboxTester: false},
    sources: [{productId: null, appId: null, entitlementIds: ['promo_civil_service'], environment: 'production',
      store: 'promotional', endsAt: promoEnd, active: true}]}});
  const reply = await webEntitlement({uid, token: {}}, db, t0);
  assert.equal(reply.grants.length, 1);
  assert.equal(reply.grants[0].tier, 'civilService');
  assert.equal(reply.grants[0].endsAt, promoEnd);
  assert.equal(await commitPaymongoGrant(db, {uid, eventId: 'evt_ra6', sessionId: 'cs_ra6', paymentId: 'pay_ra6',
    paidAmount: 14900, product: webProduct('pantas_cs_monthly'), paidAt: t0, sitting: undefined}, t0, catalog), 'granted');
  assert.equal((await grantDoc(uid, 'pay_ra6')).startsAt, promoEnd);
});
