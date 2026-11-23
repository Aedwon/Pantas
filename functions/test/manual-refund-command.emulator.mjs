import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {spawnSync} from 'node:child_process';
import {mkdtempSync, readFileSync, writeFileSync, existsSync} from 'node:fs';
import {tmpdir} from 'node:os';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {getFirestore} from 'firebase-admin/firestore';
import {getAuth} from 'firebase-admin/auth';
import {handlePaymongoWebhook} from '../lib/paymongoWebhook.js';
import {commitPaymongoGrant, shortenedEnd} from '../lib/paymongoGrants.js';
import {webProduct} from '../lib/paymongoPolicy.js';
import {fakeAuth, fakeClient, paidEvent, resourceEvent, send, session, SECRET} from './_paymongo-helpers.mjs';

// Runs the command exactly as written in docs/OPERATIONS.md ("Manual QR Ph refund") in a child
// process, with fetch replaced by a stub that records the request. The recorded request is then
// delivered to the real webhook handler, which applies its own signature check.
assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
const db = getFirestore();

const docPath = path.join(path.dirname(fileURLToPath(import.meta.url)), '../../docs/OPERATIONS.md');
const section = readFileSync(docPath, 'utf8').split('\n## Manual QR Ph refund\n')[1]?.split('\n## ')[0] ?? '';
const block = /```js\n(\/\/ manual-refund\.mjs[\s\S]*?)\n```/.exec(section)?.[1];
assert.ok(block, 'docs/OPERATIONS.md must hold the manual-refund.mjs command under "Manual QR Ph refund"');
const dir = mkdtempSync(path.join(tmpdir(), 'manual-refund-'));
const commandFile = path.join(dir, 'manual-refund.mjs');
writeFileSync(commandFile, `${block}\n`);
const preload = path.join(dir, 'fetch-stub.mjs');
const captureFile = path.join(dir, 'captured.json');
writeFileSync(preload, `import {writeFileSync} from 'node:fs';
globalThis.fetch = async (url, init) => {
  writeFileSync(process.env.CAPTURE_FILE, JSON.stringify({url: String(url), method: init.method, headers: init.headers, body: init.body}));
  return new Response('ok', {status: 200});
};
`);

function runCommand({paymentId, amount, label, livemode}) {
  if (existsSync(captureFile)) writeFileSync(captureFile, '');
  const run = spawnSync(process.execPath, ['--import', preload, commandFile, 'pantas-staging', paymentId, String(amount), label], {
    env: {PATH: process.env.PATH, PAYMONGO_WEBHOOK_SECRET: SECRET, PAYMONGO_LIVEMODE: String(livemode), CAPTURE_FILE: captureFile},
    encoding: 'utf8'});
  assert.equal(run.status, 0, run.stderr);
  const request = JSON.parse(readFileSync(captureFile, 'utf8'));
  assert.equal(request.url, 'https://asia-southeast1-pantas-staging.cloudfunctions.net/paymongoWebhook');
  assert.equal(request.method, 'POST');
  return {request, stdout: run.stdout.trim()};
}

// Delivers the captured request to the real handler: same bytes, same header.
async function deliver(request, livemode, extra = {}) {
  const at = Date.now();
  return handlePaymongoWebhook(Buffer.from(request.body), request.headers['Paymongo-Signature'],
    {db, auth: fakeAuth(), client: fakeClient({}), signingSecret: SECRET, livemode, now: () => at, ...extra});
}
async function refundCommand({paymentId, amount, label, livemode = false}, extra) {
  const {request, stdout} = runCommand({paymentId, amount, label, livemode});
  assert.equal(await deliver(request, livemode, extra), 200);
  return {request, stdout};
}

const DAY = 86400000;
const PRICE = {pantas_cs_weekly: 4900, pantas_cs_monthly: 14900, pantas_pass_cse_pro: 49900};
const sitting = {firstDay: '2027-03-14', lastDay: '2027-03-14', sourceUrl: 'https://example.test/sitting'};
const catalog = [{id: 'exam_cse_pro', publishedSittings: [sitting]}];
const reset = uid => db.recursiveDelete(db.doc(`users/${uid}`));
const grantOf = async (uid, id) => (await db.doc(`users/${uid}/grants/${id}`).get()).data();
const entitlement = async uid => (await db.doc(`users/${uid}/server/entitlement`).get()).data();

// A paid checkout through the real webhook path, paid `daysAgo` days before the test runs.
async function buy(uid, product, paymentId, {daysAgo = 2, hoursAfter = 0, livemode = false} = {}) {
  const now = Date.now() - daysAgo * DAY + hoursAfter * 3600000;
  const sessionId = `cs_${paymentId}`;
  const client = fakeClient({[sessionId]: session({id: sessionId, uid, product, paymentId, amount: PRICE[product], paidAt: now})});
  const deps = {db, auth: fakeAuth(), client, signingSecret: SECRET, livemode, catalog, now: () => now};
  assert.equal(await send(paidEvent({id: `evt_buy_${paymentId}`, sessionId, uid, product, livemode}), deps, {livemode}), 200);
  return now;
}

test('1. card payment, full manual refund: grant revoked, refund recorded, access ends', async () => {
  const uid = 'mr-card';
  await reset(uid);
  await buy(uid, 'pantas_cs_monthly', 'pay_mrcard');
  assert.equal((await entitlement(uid)).pro, true);
  const {stdout} = await refundCommand({paymentId: 'pay_mrcard', amount: 14900, label: '20261120_1'});
  assert.match(stdout, /^manual_20261120_1: HTTP 200 /);
  const g = await grantOf(uid, 'pay_mrcard');
  assert.equal(g.state, 'revoked');
  assert.deepEqual(g.refunds, {manual_20261120_1: 14900});
  assert.equal((await entitlement(uid)).pro, false);
});

test('2. QR Ph payment, full manual refund in live mode: same result', async () => {
  const uid = 'mr-qrph';
  await reset(uid);
  await buy(uid, 'pantas_cs_monthly', 'pay_mrqrph', {livemode: true});
  const {request} = await refundCommand({paymentId: 'pay_mrqrph', amount: 14900, label: 'qrph_20261120', livemode: true},
    {livemode: true});
  assert.match(request.headers['Paymongo-Signature'], /^t=\d+,te=,li=[0-9a-f]{64}$/);
  const g = await grantOf(uid, 'pay_mrqrph');
  assert.equal(g.state, 'revoked');
  assert.deepEqual(g.refunds, {manual_qrph_20261120: 14900});
  assert.equal((await entitlement(uid)).pro, false);
});

test('3. a pass whose sitting has ended: refund recorded, no new access, no error', async () => {
  const uid = 'mr-ended';
  await reset(uid);
  const past = {firstDay: '2026-01-10', lastDay: '2026-01-10', sourceUrl: 'https://example.test/past'};
  const paidAt = Date.parse('2026-01-09T04:00:00Z');
  const make = (id, amount) => commitPaymongoGrant(db, {uid, eventId: `evt_${id}`, sessionId: `cs_${id}`, paymentId: `pay_${id}`,
    paidAmount: 49900, product: webProduct('pantas_pass_cse_pro'), paidAt, sitting: past}, paidAt + 30000, [{id: 'exam_cse_pro', publishedSittings: [past]}]);
  assert.equal(await make('mrended', 49900), 'granted');
  const before = await grantOf(uid, 'pay_mrended');
  assert.ok(before.endsAt < Date.now());
  // Partial first: an ended pass only records the refund and keeps its end.
  await refundCommand({paymentId: 'pay_mrended', amount: 10000, label: 'ended_part_1'});
  let g = await grantOf(uid, 'pay_mrended');
  assert.deepEqual(g.refunds, {manual_ended_part_1: 10000});
  assert.equal(g.endsAt, before.endsAt);
  await refundCommand({paymentId: 'pay_mrended', amount: 39900, label: 'ended_rest_1'});
  g = await grantOf(uid, 'pay_mrended');
  assert.deepEqual(g.refunds, {manual_ended_part_1: 10000, manual_ended_rest_1: 39900});
  assert.equal(g.state, 'revoked');
  assert.equal(g.endsAt, before.endsAt);
  assert.equal((await entitlement(uid)).pro, false);
  assert.equal((await db.collection(`users/${uid}/grants`).get()).size, 1);
});

test('4. queued plan behind the first: full refund moves it earlier, partial refund moves it by the removed time', async () => {
  const lengthOf = g => g.endsAt - g.startsAt;
  // Full refund.
  let uid = 'mr-queue-full';
  await reset(uid);
  await buy(uid, 'pantas_cs_weekly', 'pay_mrqf1');
  await buy(uid, 'pantas_cs_weekly', 'pay_mrqf2', {daysAgo: 1.9});
  const first = await grantOf(uid, 'pay_mrqf1');
  const queuedBefore = await grantOf(uid, 'pay_mrqf2');
  assert.equal(queuedBefore.startsAt, first.endsAt);
  const startedAt = Date.now();
  await refundCommand({paymentId: 'pay_mrqf1', amount: 4900, label: 'queue_full_1'});
  assert.equal((await grantOf(uid, 'pay_mrqf1')).state, 'revoked');
  let queued = await grantOf(uid, 'pay_mrqf2');
  assert.ok(queued.startsAt >= startedAt && queued.startsAt <= Date.now(), 'queued plan starts at the refund time');
  assert.equal(lengthOf(queued), lengthOf(queuedBefore));
  assert.equal(queued.state, 'active');
  assert.equal((await entitlement(uid)).pro, true);
  // Partial refund of half.
  uid = 'mr-queue-part';
  await reset(uid);
  await buy(uid, 'pantas_cs_weekly', 'pay_mrqp1');
  await buy(uid, 'pantas_cs_weekly', 'pay_mrqp2', {daysAgo: 1.9});
  const p1 = await grantOf(uid, 'pay_mrqp1');
  const p2 = await grantOf(uid, 'pay_mrqp2');
  await refundCommand({paymentId: 'pay_mrqp1', amount: 2450, label: 'queue_part_1'});
  const p1After = await grantOf(uid, 'pay_mrqp1');
  const p2After = await grantOf(uid, 'pay_mrqp2');
  assert.equal(p1After.state, 'active');
  assert.equal(p1After.endsAt, shortenedEnd(p1.startsAt, p1.endsAt, 2450, 4900));
  assert.ok(p1After.endsAt < p1.endsAt);
  assert.equal(p2After.startsAt, p1After.endsAt);
  assert.equal(p2.startsAt - p2After.startsAt, p1.endsAt - p1After.endsAt);
  assert.equal(lengthOf(p2After), lengthOf(p2));
});

test('5. already refunded in part by PayMongo, then a manual refund for the rest', async () => {
  const providerRefund = (id, paymentId, refundId, amount) => resourceEvent({id, type: 'payment.refunded', resource: 'payment',
    resourceId: paymentId, attributes: {status: 'paid', refunds: [{id: refundId, amount, status: 'succeeded'}]}});
  const providerDeps = () => {const at = Date.now(); return {db, auth: fakeAuth(), client: fakeClient({}), signingSecret: SECRET, livemode: false, now: () => at};};
  // Rest of the price: revoked, each refund id once, amounts add up.
  let uid = 'mr-split-rest';
  await reset(uid);
  await buy(uid, 'pantas_cs_monthly', 'pay_mrsplit');
  assert.equal(await send(providerRefund('evt_mrsplit_p', 'pay_mrsplit', 'ref_mrsplit1', 5000), providerDeps()), 200);
  assert.equal((await grantOf(uid, 'pay_mrsplit')).state, 'active');
  await refundCommand({paymentId: 'pay_mrsplit', amount: 9900, label: 'split_rest_1'});
  const g = await grantOf(uid, 'pay_mrsplit');
  assert.deepEqual(g.refunds, {ref_mrsplit1: 5000, manual_split_rest_1: 9900});
  assert.equal(Object.values(g.refunds).reduce((a, b) => a + b, 0), g.paidAmount);
  assert.equal(g.state, 'revoked');
  assert.equal((await entitlement(uid)).pro, false);
  // Less than the rest: shortened, still active.
  uid = 'mr-split-less';
  await reset(uid);
  await buy(uid, 'pantas_cs_monthly', 'pay_mrsplitless');
  const original = await grantOf(uid, 'pay_mrsplitless');
  assert.equal(await send(providerRefund('evt_mrsplitless_p', 'pay_mrsplitless', 'ref_mrsplitless1', 5000), providerDeps()), 200);
  const afterProvider = await grantOf(uid, 'pay_mrsplitless');
  await refundCommand({paymentId: 'pay_mrsplitless', amount: 4000, label: 'split_less_1'});
  const less = await grantOf(uid, 'pay_mrsplitless');
  assert.deepEqual(less.refunds, {ref_mrsplitless1: 5000, manual_split_less_1: 4000});
  assert.equal(less.state, 'active');
  assert.equal(less.fullEndsAt, original.endsAt);
  assert.equal(less.endsAt, shortenedEnd(original.startsAt, original.endsAt, 9000, 14900));
  assert.ok(less.endsAt < afterProvider.endsAt);
  assert.equal((await entitlement(uid)).pro, true);
});

test('6. card payment with an open dispute: the refund adds to the revoked grant and a won dispute restores nothing', async () => {
  const uid = 'mr-dispute';
  await reset(uid);
  await buy(uid, 'pantas_cs_monthly', 'pay_mrdispute');
  const at = Date.now();
  const deps = {db, auth: fakeAuth(), client: fakeClient({}), signingSecret: SECRET, livemode: false, now: () => at};
  const dispute = (type, status) => resourceEvent({id: `evt_mrd_${type}`, type, resource: 'dispute', resourceId: 'dp_mr1',
    attributes: {payment_id: 'pay_mrdispute', status}});
  assert.equal(await send(dispute('dispute.created', 'under_review'), deps), 200);
  const disputed = await grantOf(uid, 'pay_mrdispute');
  assert.equal(disputed.state, 'revoked');
  assert.equal(disputed.disputeId, 'dp_mr1');
  const versionBefore = (await entitlement(uid)).version;
  await refundCommand({paymentId: 'pay_mrdispute', amount: 14900, label: 'dispute_1'});
  const refunded = await grantOf(uid, 'pay_mrdispute');
  // Still revoked, still tied to the same open dispute, now with the refund recorded.
  assert.equal(refunded.state, 'revoked');
  assert.equal(refunded.revokedReason, 'dispute.created');
  assert.equal(refunded.disputeId, 'dp_mr1');
  assert.equal(refunded.disputeResolved, false);
  assert.deepEqual(refunded.refunds, {manual_dispute_1: 14900});
  assert.ok(refunded.revokedAt >= disputed.revokedAt); // the refund restamps the revocation time
  assert.equal((await entitlement(uid)).pro, false);
  assert.ok((await entitlement(uid)).version <= versionBefore + 1);
  // A later win closes the dispute but must not bring back access the refund ended.
  assert.equal(await send(dispute('dispute.resolved', 'won'), deps), 200);
  const won = await grantOf(uid, 'pay_mrdispute');
  assert.equal(won.state, 'revoked');
  assert.equal(won.disputeResolved, true);
  assert.deepEqual(won.refunds, {manual_dispute_1: 14900});
  assert.equal((await entitlement(uid)).pro, false);
});

test('7. the same label twice: the second run changes nothing', async () => {
  const uid = 'mr-twice';
  await reset(uid);
  await buy(uid, 'pantas_cs_monthly', 'pay_mrtwice');
  await refundCommand({paymentId: 'pay_mrtwice', amount: 5000, label: 'twice_1'});
  const grant = await grantOf(uid, 'pay_mrtwice');
  const record = await entitlement(uid);
  const second = await refundCommand({paymentId: 'pay_mrtwice', amount: 5000, label: 'twice_1'});
  assert.match(second.stdout, /HTTP 200 /);
  assert.deepEqual(await grantOf(uid, 'pay_mrtwice'), grant);
  assert.deepEqual(await entitlement(uid), record);
  assert.equal(record.version, 2);
});

async function paths(ref = db) {
  const out = [];
  for (const collection of await ref.listCollections()) {
    for (const doc of await collection.listDocuments()) {
      if ((await doc.get()).exists) out.push(doc.path);
      out.push(...await paths(doc));
    }
  }
  return out;
}

test('8. an account already deleted: the command creates no grant, no user, no Pro', async () => {
  const {deleteAccount} = await import('../lib/deleteAccount.js');
  const uid = 'mr-deleted';
  await getAuth().createUser({uid});
  await reset(uid);
  await buy(uid, 'pantas_cs_monthly', 'pay_mrdeleted');
  const caller = {uid, token: {email: 'mr-deleted@example.test', email_verified: true,
    firebase: {sign_in_provider: 'google.com', identities: {'google.com': ['mr-deleted-sub']}}}};
  await deleteAccount.run({data: {}, auth: {...caller, token: {...caller.token, auth_time: Math.floor(Date.now() / 1000)}}, app: {appId: 'demo-app'}});
  assert.equal((await db.doc(`accountDeletions/${uid}`).get()).exists, true);
  assert.equal((await db.doc('paymongoPayments/pay_mrdeleted').get()).exists, false);
  const before = new Set(await paths());
  const {stdout} = await refundCommand({paymentId: 'pay_mrdeleted', amount: 14900, label: 'deleted_1'});
  const written = (await paths()).filter(p => !before.has(p));
  assert.deepEqual(written.map(p => p.replace(/^audit_logs\/.+/, 'audit_logs/<id>')).sort(), ['audit_logs/<id>', 'paymongoRevocations/pay_mrdeleted']);
  assert.match(stdout, /HTTP 200 sent; confirm in step 5$/);
  assert.equal((await db.doc(`users/${uid}`).get()).exists, false);
  assert.equal((await db.collection(`users/${uid}/grants`).get()).size, 0);
  assert.equal((await db.doc(`users/${uid}/server/entitlement`).get()).exists, false);
  assert.equal((await db.doc(`accountDeletions/${uid}`).get()).exists, true);
  assert.equal(written.filter(p => p.startsWith(`users/${uid}`)).length, 0);
  assert.equal((await db.doc('paymongoRevocations/pay_mrdeleted').get()).get('refunds').manual_deleted_1, 14900);
});

test('the documented command keeps the shape this test relies on', () => {
  assert.match(block, /payment\.refunded/);
  assert.match(block, /manual_\$\{label\}/);
  assert.match(block, /Paymongo-Signature/);
});
