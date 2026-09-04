import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';

const webhookSource = () =>
  readFileSync(new URL('../src/revenuecatWebhook.ts', import.meta.url), 'utf8');
const claimsSource = () =>
  readFileSync(new URL('../src/revenuecatClaims.ts', import.meta.url), 'utf8');
const policySource = () =>
  readFileSync(new URL('../src/revenuecatPolicy.ts', import.meta.url), 'utf8');
const indexSource = () =>
  readFileSync(new URL('../src/index.ts', import.meta.url), 'utf8');

test('RevenueCat webhook routes signed requests through the behavior-tested policy', () => {
  const source = webhookSource();
  assert.match(source, /x-revenuecat-webhook-signature/i);
  assert.match(source, /requireExactRevenueCatRawBody/);
  assert.match(source, /verifyRevenueCatSignature/);
  assert.match(source, /res\.status\(401\)/);
});

test('RevenueCat webhook preserves existing event dedupe and rate-limit wiring', () => {
  const source = webhookSource();
  assert.match(source, /collection\('webhookEvents'\)/);
  assert.match(source, /collection\('webhookRateLimits'\)/);
  assert.match(source, /MAX_EVENTS_PER_MINUTE = 30/);
  assert.match(source, /res\.status\(429\)/);
});

test('RevenueCat claims adapter delegates merge-safe transitions to policy', () => {
  const source = claimsSource();
  assert.match(source, /executeRevenueCatClaimTransition/);
  assert.match(source, /customClaims/);
  assert.match(source, /setCustomUserClaims\(uid, claims\)/);
  assert.doesNotMatch(source, /setCustomUserClaims\(uid, \{ pro:/);
});

test('RevenueCat policy remains the single backend correctness helper', () => {
  const source = policySource();
  assert.match(source, /verifyRevenueCatSignature/);
  assert.match(source, /firebaseTransferTransitions/);
  assert.match(source, /mergeProClaim/);
});

test('RevenueCat webhook remains exported from index', () => {
  assert.match(indexSource(), /export \{ revenuecatWebhook \}/);
});
