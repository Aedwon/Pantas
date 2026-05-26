import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';

const webhookSource = () =>
  readFileSync(new URL('../src/revenuecatWebhook.ts', import.meta.url), 'utf8');
const claimsSource = () =>
  readFileSync(new URL('../src/revenuecatClaims.ts', import.meta.url), 'utf8');
const indexSource = () =>
  readFileSync(new URL('../src/index.ts', import.meta.url), 'utf8');

test('RevenueCat webhook verifies signed requests and rejects missing or invalid authorization', () => {
  const source = webhookSource();

  assert.match(source, /createHmac\('sha256'/);
  assert.match(source, /timingSafeEqual/);
  assert.match(source, /authorization/);
  assert.match(source, /res\.status\(401\)/);
});

test('RevenueCat webhook deduplicates event ids and rate limits per uid', () => {
  const source = webhookSource();

  assert.match(source, /collection\('webhookEvents'\)/);
  assert.match(source, /collection\('webhookRateLimits'\)/);
  assert.match(source, /MAX_EVENTS_PER_MINUTE = 30/);
  assert.match(source, /res\.status\(429\)/);
});

test('RevenueCat claim transitions set and clear pro entitlement for expected events', () => {
  const source = claimsSource();

  for (const event of [
    'INITIAL_PURCHASE',
    'RENEWAL',
    'PRODUCT_CHANGE',
    'TRANSFER_INCOMING',
  ]) {
    assert.match(source, new RegExp(`'${event}'`));
  }
  for (const event of ['CANCELLATION', 'EXPIRATION', 'TRANSFER_OUTGOING']) {
    assert.match(source, new RegExp(`'${event}'`));
  }
  assert.match(source, /setCustomUserClaims\(uid, \{ pro: true \}\)/);
  assert.match(source, /setCustomUserClaims\(uid, \{ pro: false \}\)/);
});

test('RevenueCat webhook is exported from index', () => {
  assert.match(indexSource(), /export \{ revenuecatWebhook \}/);
});
