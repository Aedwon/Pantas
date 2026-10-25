import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {listPlans} from '../lib/webPlans.js';
import {startTrial} from '../lib/webTrial.js';
import {createCheckout} from '../lib/paymongoCheckout.js';
import {fakeAuth} from './_paymongo-helpers.mjs';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const NOW = Date.parse('2026-10-20T10:00:00+08:00');
const named = uid => ({uid, token: {firebase: {sign_in_provider: 'google.com'}}});
const anon = uid => ({uid, token: {firebase: {sign_in_provider: 'anonymous'}}});
const reset = uid => db.recursiveDelete(db.doc(`users/${uid}`));
const code = async promise => {try {await promise; return 'ok';} catch (e) {assert.equal(typeof e.code, 'string', String(e)); return e.code;}};
const deps = (auth = fakeAuth()) => ({db, auth, allow: async () => true, now: () => NOW});

test('trial grants 7 days at the Civil Service tier, writes the record, and copies claims', async () => {
  const uid = 'tr-ok';
  await reset(uid);
  const auth = fakeAuth();
  const result = await startTrial(named(uid), deps(auth));
  assert.equal(result.endsAt, NOW + 7 * 86400000);
  const grant = (await db.doc(`users/${uid}/grants/trial`).get()).data();
  assert.deepEqual({source: grant.source, tier: grant.tier, state: grant.state, startsAt: grant.startsAt, endsAt: grant.endsAt},
    {source: 'trial', tier: 'civilService', state: 'active', startsAt: NOW, endsAt: NOW + 7 * 86400000});
  const marker = (await db.doc(`users/${uid}/server/trial`).get()).data();
  assert.deepEqual(marker, {usedAt: NOW, grantId: 'trial'});
  const record = (await db.doc(`users/${uid}/server/entitlement`).get()).data();
  assert.equal(record.pro, true);
  assert.equal(record.proUntil, NOW + 8 * 86400000);
  assert.equal(record.claimsVersion, record.version);
  assert.equal(auth.current().pro, true);
});

test('trial is refused for anonymous and signed-out callers, and a second trial', async () => {
  const uid = 'tr-twice';
  await reset(uid);
  assert.equal(await code(startTrial(anon(uid), deps())), 'permission-denied');
  assert.equal(await code(startTrial(undefined, deps())), 'unauthenticated');
  assert.equal(await code(startTrial(named(uid), deps())), 'ok');
  assert.equal(await code(startTrial(named(uid), deps())), 'failed-precondition');
  // Even if the grant row is removed, the trial record still blocks a second trial.
  await db.doc(`users/${uid}/grants/trial`).delete();
  assert.equal(await code(startTrial(named(uid), deps())), 'failed-precondition');
});

test('trial is refused after a paid grant, a pass, a subscription or a recorded purchase', async () => {
  const cases = {
    'tr-paid': async uid => db.doc(`users/${uid}/grants/pay_old`).set({source: 'paymongo', product: 'pantas_cs_weekly', tier: 'civilService', startsAt: 1, endsAt: 2, state: 'revoked', createdAt: 1}),
    'tr-pass': async uid => db.doc(`users/${uid}/passes/p1`).set({product: 'pantas_pass_cse_pro', state: 'revoked'}),
    'tr-sub': async uid => db.doc(`users/${uid}/server/entitlement`).set({pro: false, proUntil: 0, version: 1, facts: {sources: [{productId: 'pantas_pro_monthly'}], purchases: []}}),
    'tr-purchase': async uid => db.doc(`users/${uid}/server/entitlement`).set({pro: false, proUntil: 0, version: 1, facts: {sources: [], purchases: [{productId: 'pantas_pass_cse_pro'}]}}),
    'tr-pro': async uid => db.doc(`users/${uid}/server/entitlement`).set({pro: true, proUntil: NOW + 1000, version: 1}),
  };
  for (const [uid, seed] of Object.entries(cases)) {
    await reset(uid);
    await seed(uid);
    assert.equal(await code(startTrial(named(uid), deps())), 'failed-precondition', uid);
    assert.equal((await db.doc(`users/${uid}/server/trial`).get()).exists, false, uid);
  }
});

test('an account with an entitlement record but no purchases may still start the trial', async () => {
  const uid = 'tr-empty-record';
  await reset(uid);
  await db.doc(`users/${uid}/server/entitlement`).set({pro: false, proUntil: 0, version: 3, claimsVersion: 3,
    facts: {sources: [], purchases: [], coverageContext: {appId: 'a', firebaseProjectId: 'p', sandboxTester: false}}});
  assert.equal(await code(startTrial(named(uid), deps())), 'ok');
  assert.equal((await db.doc(`users/${uid}/server/entitlement`).get()).get('version'), 4);
});

test('trial attempts are rate limited per account', async () => {
  assert.equal(await code(startTrial(named('tr-rate'), {...deps(), allow: async () => false})), 'resource-exhausted');
});

const client = (calls = []) => ({calls, createCheckoutSession: async input => {calls.push(input); return {id: 'cs_new', checkoutUrl: 'https://checkout.paymongo.com/abc'};}});
const checkoutDeps = (c, extra = {}) => ({client: c, db, origin: 'https://pantas.study', methods: ['card', 'gcash'], allow: async () => true,
  catalog: [{id: 'exam_cse_pro', publishedSittings: [{firstDay: '2027-03-14', lastDay: '2027-03-14', sourceUrl: 'https://x.test'}]}], now: () => NOW, ...extra});

test('checkout creates a session with uid and product metadata inputs and the web price', async () => {
  const calls = [];
  const out = await createCheckout(named('co-ok'), {product: 'pantas_cs_monthly'}, checkoutDeps(client(calls)));
  assert.deepEqual(out, {checkoutUrl: 'https://checkout.paymongo.com/abc', sessionId: 'cs_new', reference: calls[0].referenceNumber});
  assert.equal(calls[0].successUrl, `https://pantas.study/pro?checkout=success&ref=${out.reference}`);
  assert.equal(calls[0].cancelUrl, `https://pantas.study/pro?checkout=cancelled&ref=${out.reference}`);
  assert.equal(calls[0].uid, 'co-ok');
  assert.equal(calls[0].product, 'pantas_cs_monthly');
  assert.equal(calls[0].amountCentavos, 14900);
  assert.deepEqual(calls[0].paymentMethodTypes, ['card', 'gcash']);
  assert.match(calls[0].successUrl, /^https:\/\/pantas\.study\//);
});

test('checkout refuses anonymous and signed-out callers, unknown or non-web products, and floods', async () => {
  const calls = [];
  const d = checkoutDeps(client(calls));
  assert.equal(await code(createCheckout(anon('co-anon'), {product: 'pantas_cs_monthly'}, d)), 'permission-denied');
  assert.equal(await code(createCheckout(undefined, {product: 'pantas_cs_monthly'}, d)), 'unauthenticated');
  for (const product of ['pantas_made_up', 'pantas_pro_monthly', 'promo_student', undefined, 5, {}]) {
    assert.equal(await code(createCheckout(named('co-bad'), {product}, d)), 'invalid-argument');
  }
  assert.equal(await code(createCheckout(named('co-bad'), null, d)), 'invalid-argument');
  assert.equal(await code(createCheckout(named('co-rate'), {product: 'pantas_cs_monthly'}, {...d, allow: async () => false})), 'resource-exhausted');
  assert.deepEqual(calls, []);
});

test('checkout for a pass needs a published sitting and refuses a pass that is already active', async () => {
  const calls = [];
  assert.equal(await code(createCheckout(named('co-pass'), {product: 'pantas_pass_cse_pro'}, checkoutDeps(client(calls), {catalog: []}))), 'failed-precondition');
  const uid = 'co-pass-active';
  await reset(uid);
  await db.doc(`users/${uid}/grants/pay_p`).set({source: 'paymongo', product: 'pantas_pass_cse_pro', tier: 'civilService', startsAt: 1, endsAt: NOW + 1000, state: 'active', createdAt: 1});
  assert.equal(await code(createCheckout(named(uid), {product: 'pantas_pass_cse_pro'}, checkoutDeps(client(calls)))), 'already-exists');
  assert.equal(await code(createCheckout(named(uid), {product: 'pantas_pass_cse_sub'}, checkoutDeps(client(calls)))), 'failed-precondition');
  assert.deepEqual(calls, []);
});

test('the real rate limiter (users/{uid}/limits) allows 10 checkouts per window', async () => {
  const uid = 'co-limit';
  await reset(uid);
  const calls = [];
  const d = {...checkoutDeps(client(calls)), allow: undefined};
  for (let i = 0; i < 10; i++) await createCheckout(named(uid), {product: 'pantas_cs_weekly'}, d);
  assert.equal(await code(createCheckout(named(uid), {product: 'pantas_cs_weekly'}, d)), 'resource-exhausted');
  assert.equal(calls.length, 10);
});


test('listed trial eligibility matches trial enforcement for named and anonymous accounts and all past records', async () => {
  const cases = {
    fresh: [null, true],
    marker: [uid => db.doc(`users/${uid}/server/trial`).set({usedAt: 1}), false],
    paid: [uid => db.doc(`users/${uid}/grants/old`).set({source: 'paymongo', product: 'pantas_cs_weekly', state: 'revoked', endsAt: 2}), false],
    pass: [uid => db.doc(`users/${uid}/passes/old`).set({product: 'pantas_pass_cse_pro', state: 'revoked'}), false],
    subscription: [uid => db.doc(`users/${uid}/server/entitlement`).set({facts: {sources: [{productId: 'pantas_cs_monthly'}]}}), false],
    purchase: [uid => db.doc(`users/${uid}/server/entitlement`).set({facts: {purchases: [{productId: 'pantas_pass_cse_pro'}]}}), false],
    proUntil: [uid => db.doc(`users/${uid}/server/entitlement`).set({pro: false, proUntil: 1}), false],
    pro: [uid => db.doc(`users/${uid}/server/entitlement`).set({pro: true}), false],
    empty: [uid => db.doc(`users/${uid}/server/entitlement`).set({pro: false, proUntil: 0, facts: {sources: [], purchases: []}}), true],
  };
  for (const [key, [seed, eligible]] of Object.entries(cases)) {
    const uid = `plans-trial-${key}`;
    await reset(uid);
    if (seed) await seed(uid);
    const out = await listPlans(named(uid), {db, allow: async () => true, now: () => NOW});
    assert.equal(out.trialEligible, eligible, key);
    assert.equal((await db.doc(`users/${uid}/server/trial`).get()).exists, key === 'marker');
    assert.equal(await code(startTrial(named(uid), deps())), eligible ? 'ok' : 'failed-precondition', key);
  }
  const uid = 'plans-trial-anon';
  await reset(uid);
  assert.equal((await listPlans(anon(uid), {db, allow: async () => true})).trialEligible, false);
});


test('listed Play renewal requires explicit live production Play facts', async () => {
  const source = {productId: 'pantas_cs_monthly', entitlementIds: ['pro'], appId: 'app-test',
    environment: 'production', store: 'play_store', endsAt: NOW + 86400000, active: true, willRenew: true};
  for (const [key, patch, expected] of [
    ['renewing', {}, true], ['canceled', {willRenew: false}, false],
    ['expired', {endsAt: NOW}, false], ['inactive', {active: false}, false],
    ['apple', {store: 'app_store'}, false], ['sandbox', {environment: 'sandbox'}, false],
    ['unknown', {willRenew: null}, false], ['otherapp', {appId: 'other-app'}, false],
  ]) {
    const uid = `listed-renewal-${key}`;
    await reset(uid);
    await db.doc(`users/${uid}/server/entitlement`).set({facts: {sources: [{...source, ...patch}], coverageContext: {appId: 'app-test'}}});
    assert.equal((await listPlans(named(uid), {db, allow: async () => true, now: () => NOW})).googlePlayPlanRenews, expected, key);
  }
});
