import assert from 'node:assert/strict';
import {createHmac} from 'node:crypto';
import test from 'node:test';
import * as policy from '../lib/revenuecatPolicy.js';
import {assertNamedPro} from '../lib/syncGenerationPolicy.js';
const now = Date.now();
const source = {productId: 'pantas_pro_monthly', entitlementIds: ['pro'], appId: 'app-pantas-test', environment: 'production', endsAt: now + 86400000, active: true};
const options = {appId: 'app-pantas-test', firebaseProjectId: 'pantas-prod', sandboxTester: false, at: now};
const calculate = (...args) => {
  assert.equal(typeof policy.claimsForRevenueCatAnswer, 'function');
  return policy.claimsForRevenueCatAnswer(...args);
};
test('AC-3 canceled but active subscriptions retain coverage until expiry', () => {
  assert.deepEqual(calculate([source], options), {pro: true, proUntil: source.endsAt + 86400000});
});
test('AC-2 unknown products and other apps grant nothing', () => {
  for (const patch of [{productId: 'unknown'}, {appId: 'other'}, {entitlementIds: []}]) {
    assert.deepEqual(calculate([{...source, ...patch}], options), {pro: false, proUntil: 0});
  }
});
test('AC-2 sandbox is staging-only or requires the production tester allowlist', () => {
  const sandbox = {...source, environment: 'sandbox'};
  assert.equal(calculate([sandbox], options).pro, false);
  assert.equal(calculate([sandbox], {...options, firebaseProjectId: 'pantas-staging'}).pro, true);
  assert.equal(calculate([sandbox], {...options, sandboxTester: true}).pro, true);
});
test('AC-3 late events do not revive expired or revoked periods', () => {
  assert.equal(calculate([{...source, endsAt: now - 1}], options).pro, false);
  assert.equal(calculate([{...source, active: false}], options).pro, false);
});
test('AC-7 known promotional grants survive a subscription expiry', () => {
  const grant = {...source, productId: null, entitlementIds: ['promo_civil_service'], appId: null, store: 'promotional'};
  assert.equal(calculate([{...source, active: false}, grant], options).pro, true);
  assert.equal(calculate([{...grant, entitlementIds: ['pro']}], options).pro, false);
});
test('AC-3 signed delivery timestamps are fresh for each retry and stale signatures fail', () => {
  const body = Buffer.from('{}');
  const t = Math.floor(now / 1000) - 301;
  const digest = createHmac('sha256', 'test-secret').update(`${t}.`).update(body).digest('hex');
  assert.equal(policy.verifyRevenueCatSignature(body, `t=${t},v1=${digest}`, 'test-secret', now), false);
});
test('AC-10 missing or expired proUntil never authorizes the sync callable', () => {
  const auth = {uid: 'test-user', token: {firebase: {sign_in_provider: 'google.com'}, pro: true}};
  assert.throws(() => assertNamedPro(auth));
  assert.throws(() => assertNamedPro({...auth, token: {...auth.token, proUntil: now - 1000}}));
});
