import assert from 'node:assert/strict';
import { createHmac } from 'node:crypto';
import test from 'node:test';

import * as revenuecatPolicyModule from '../lib/revenuecatPolicy.js';

const policy = revenuecatPolicyModule;

function requirePolicyFunction(name) {
  const value = policy[name];
  assert.equal(typeof value, 'function', `${name} must be implemented`);
  return value;
}

const verifyRevenueCatSignature = requirePolicyFunction('verifyRevenueCatSignature');

const rawBody = Buffer.from(
  '{"event":{"id":"evt_signature","type":"RENEWAL"}}',
);
const signingSecret = 'test_signing_secret';
const timestamp = String(Math.floor(Date.now() / 1000));

function signedHeader(
  secret = signingSecret,
  body = rawBody,
  signedAt = timestamp,
) {
  const digest = createHmac('sha256', secret)
    .update(Buffer.concat([Buffer.from(`${signedAt}.`), body]))
    .digest('hex');
  return `t=${signedAt},v1=${digest}`;
}

test('accepts RevenueCat signed-webhook HMAC over timestamp dot exact raw body', () => {
  assert.equal(
    verifyRevenueCatSignature(rawBody, signedHeader(), signingSecret),
    true,
  );
});

test('rejects signed webhook when secret is wrong', () => {
  assert.equal(
    verifyRevenueCatSignature(rawBody, signedHeader('other_secret'), signingSecret),
    false,
  );
});

test('rejects signed webhook when exact raw body bytes change', () => {
  const altered = Buffer.from(
    '{"event": {"id":"evt_signature","type":"RENEWAL"}}',
  );
  assert.equal(
    verifyRevenueCatSignature(altered, signedHeader(), signingSecret),
    false,
  );
});

test('rejects missing or malformed RevenueCat signature headers', () => {
  for (const header of [
    '',
    `v1=${'a'.repeat(64)}`,
    't=not-a-unix-time,v1=abc',
    `t=${timestamp}`,
    `t=${timestamp},v1=not-hex`,
  ]) {
    assert.equal(verifyRevenueCatSignature(rawBody, header, signingSecret), false);
  }
});

test('raw-body gate accepts only exact Buffer bytes and fails closed otherwise', () => {
  const requireRawBody = requirePolicyFunction(
    'requireExactRevenueCatRawBody',
  );
  const exact = Buffer.from('{"event":{"id":"evt_raw"}}');
  assert.equal(requireRawBody(exact), exact);
  assert.equal(requireRawBody(undefined), null);
  assert.equal(requireRawBody(null), null);
  assert.equal(requireRawBody('{"event":{}}'), null);
  assert.equal(requireRawBody({ event: {} }), null);
});

test('unresolved Firebase identity errors include missing and invalid uid only', () => {
  const isUnresolved = requirePolicyFunction(
    'isUnresolvedFirebaseIdentityError',
  );
  assert.equal(isUnresolved({ code: 'auth/user-not-found' }), true);
  assert.equal(isUnresolved({ code: 'auth/invalid-uid' }), true);
  assert.equal(isUnresolved({ code: 'auth/internal-error' }), false);
  assert.equal(isUnresolved(new Error('network')), false);
});
