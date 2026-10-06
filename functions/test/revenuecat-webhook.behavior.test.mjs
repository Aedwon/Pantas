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
const timestamp = '1788506400';

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

test('lifecycle policy keeps cancellation/billing/product-change neutral and expiry authoritative', () => {
  const transition = requirePolicyFunction(
    'proTransitionForEvent',
  );
  const apply = (current, eventType) =>
    transition(eventType) ?? current;

  let pro = false;
  pro = apply(pro, 'INITIAL_PURCHASE');
  assert.equal(pro, true);
  pro = apply(pro, 'CANCELLATION');
  assert.equal(pro, true);
  pro = apply(pro, 'BILLING_ISSUE');
  assert.equal(pro, true);
  pro = apply(pro, 'PRODUCT_CHANGE');
  assert.equal(pro, true);
  pro = apply(pro, 'EXPIRATION');
  assert.equal(pro, false);
  pro = apply(pro, 'RENEWAL');
  assert.equal(pro, true);

  assert.equal(transition('UNCANCELLATION'), null);
  assert.equal(transition('SOME_FUTURE_EVENT'), null);
});

test('transfer normalization deduplicates arrays and excludes RevenueCat anonymous IDs from Firebase transitions', () => {
  const normalize = requirePolicyFunction(
    'normalizeRevenueCatEvent',
  );
  const transitionsForTransfer = requirePolicyFunction(
    'firebaseTransferTransitions',
  );

  const event = normalize({
    event: {
      id: 'evt_transfer',
      type: 'TRANSFER',
      transferred_from: [
        'firebase_source',
        '$RCAnonymousID:source-anon',
        'firebase_source',
      ],
      transferred_to: [
        'firebase_destination',
        '$RCAnonymousID:destination-anon',
        'firebase_destination',
      ],
    },
  });

  assert.deepEqual(event.transferredFrom, [
    'firebase_source',
    '$RCAnonymousID:source-anon',
  ]);
  assert.deepEqual(event.transferredTo, [
    'firebase_destination',
    '$RCAnonymousID:destination-anon',
  ]);
  assert.deepEqual(transitionsForTransfer(event), [
    {
      eventId: 'evt_transfer',
      eventType: 'TRANSFER_OUTGOING',
      uid: 'firebase_source',
      unresolvedUserIsNoop: true,
    },
    {
      eventId: 'evt_transfer',
      eventType: 'TRANSFER_INCOMING',
      uid: 'firebase_destination',
      unresolvedUserIsNoop: true,
    },
  ]);
});

test('claim executor preserves unrelated custom claims on grant and revoke', async () => {
  const execute = requirePolicyFunction(
    'executeRevenueCatClaimTransition',
  );
  const writes = [];
  const dependencies = {
    getCustomClaims: async (uid) =>
      uid === 'grant_uid'
        ? { role: 'student', cohort: 7, pro: false }
        : { role: 'student', cohort: 7, pro: true },
    setCustomClaims: async (uid, claims) => {
      writes.push({ uid, claims });
    },
    markTransferLoser: async () => {
      throw new Error('unexpected transfer-loser side effect');
    },
  };

  await execute(
    { eventId: 'evt_grant', eventType: 'INITIAL_PURCHASE', uid: 'grant_uid' },
    dependencies,
  );
  await execute(
    { eventId: 'evt_revoke', eventType: 'EXPIRATION', uid: 'revoke_uid' },
    dependencies,
  );

  assert.deepEqual(writes, [
    {
      uid: 'grant_uid',
      claims: { role: 'student', cohort: 7, pro: true },
    },
    {
      uid: 'revoke_uid',
      claims: { role: 'student', cohort: 7, pro: false },
    },
  ]);
});

test('resolved outgoing transfer revokes then marks loser; unresolved outgoing is a safe no-op', async () => {
  const execute = requirePolicyFunction(
    'executeRevenueCatClaimTransition',
  );
  const writes = [];
  const losers = [];
  const dependencies = {
    getCustomClaims: async (uid) =>
      uid === 'resolved_source' ? { pro: true, locale: 'en' } : null,
    setCustomClaims: async (uid, claims) => {
      writes.push({ uid, claims });
    },
    markTransferLoser: async (uid, eventId) => {
      losers.push({ uid, eventId });
    },
  };

  assert.equal(
    await execute(
      {
        eventId: 'evt_transfer_resolved',
        eventType: 'TRANSFER_OUTGOING',
        uid: 'resolved_source',
        unresolvedUserIsNoop: true,
      },
      dependencies,
    ),
    true,
  );
  assert.equal(
    await execute(
      {
        eventId: 'evt_transfer_missing',
        eventType: 'TRANSFER_OUTGOING',
        uid: 'not_a_firebase_user',
        unresolvedUserIsNoop: true,
      },
      dependencies,
    ),
    false,
  );

  assert.deepEqual(writes, [
    {
      uid: 'resolved_source',
      claims: { pro: false, locale: 'en' },
    },
  ]);
  assert.deepEqual(losers, [
    { uid: 'resolved_source', eventId: 'evt_transfer_resolved' },
  ]);
});

test('resolved incoming transfer grants Pro and unresolved incoming is a safe no-op', async () => {
  const execute = requirePolicyFunction(
    'executeRevenueCatClaimTransition',
  );
  const writes = [];
  const dependencies = {
    getCustomClaims: async (uid) =>
      uid === 'resolved_destination' ? { beta: true } : null,
    setCustomClaims: async (uid, claims) => {
      writes.push({ uid, claims });
    },
    markTransferLoser: async () => {
      throw new Error('incoming transfer must not mark a loser');
    },
  };

  assert.equal(
    await execute(
      {
        eventId: 'evt_transfer_in',
        eventType: 'TRANSFER_INCOMING',
        uid: 'resolved_destination',
        unresolvedUserIsNoop: true,
      },
      dependencies,
    ),
    true,
  );
  assert.equal(
    await execute(
      {
        eventId: 'evt_transfer_in_missing',
        eventType: 'TRANSFER_INCOMING',
        uid: 'missing_destination',
        unresolvedUserIsNoop: true,
      },
      dependencies,
    ),
    false,
  );

  assert.deepEqual(writes, [
    { uid: 'resolved_destination', claims: { beta: true, pro: true } },
  ]);
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
