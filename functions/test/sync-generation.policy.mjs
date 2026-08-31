import assert from 'node:assert/strict';
import test from 'node:test';
import {
  assertNamedPro,
  cutoffDate,
  decideActivation,
  generationCleanupEligible,
  TOMBSTONE_RETENTION_DAYS,
  STAGING_RETENTION_DAYS,
  RETIRED_RETENTION_DAYS,
} from './.compiled/syncGenerationPolicy.js';

test('retention constants are exact', () => {
  assert.equal(TOMBSTONE_RETENTION_DAYS, 90);
  assert.equal(STAGING_RETENTION_DAYS, 7);
  assert.equal(RETIRED_RETENTION_DAYS, 30);
});

test('anonymous and named Free identities are rejected', () => {
  assert.throws(() => assertNamedPro(undefined));
  assert.throws(() => assertNamedPro({
    uid: 'u1',
    token: {firebase: {sign_in_provider: 'anonymous'}, pro: true},
  }));
  assert.throws(() => assertNamedPro({
    uid: 'u1',
    token: {firebase: {sign_in_provider: 'google.com'}, pro: false},
  }));
});

test('named Pro identity returns its uid', () => {
  assert.equal(assertNamedPro({
    uid: 'u1',
    token: {firebase: {sign_in_provider: 'google.com'}, pro: true},
  }), 'u1');
});

test('matching expected generation activates staging target', () => {
  assert.deepEqual(
    decideActivation({
      currentGenerationId: 'old',
      expectedActiveGenerationId: 'old',
      requestedGenerationId: 'new',
      requestedGenerationStatus: 'staging',
    }),
    {kind: 'activate', previousGenerationId: 'old'},
  );
});

test('same active target is idempotent success', () => {
  assert.deepEqual(
    decideActivation({
      currentGenerationId: 'new',
      expectedActiveGenerationId: 'old',
      requestedGenerationId: 'new',
      requestedGenerationStatus: 'active',
    }),
    {kind: 'already-active'},
  );
});

test('different active generation produces conflict', () => {
  assert.deepEqual(
    decideActivation({
      currentGenerationId: 'other',
      expectedActiveGenerationId: 'old',
      requestedGenerationId: 'new',
      requestedGenerationStatus: 'staging',
    }),
    {kind: 'generation-conflict', activeGenerationId: 'other'},
  );
});

test('non-staging inactive target is invalid', () => {
  assert.deepEqual(
    decideActivation({
      currentGenerationId: 'old',
      expectedActiveGenerationId: 'old',
      requestedGenerationId: 'new',
      requestedGenerationStatus: 'retired',
    }),
    {kind: 'invalid-target'},
  );
});

test('active generation is never cleanup eligible', () => {
  assert.equal(generationCleanupEligible({
    generationId: 'g1',
    status: 'retired',
    retiredAt: new Date('2026-01-01T00:00:00Z'),
    activeGenerationId: 'g1',
    now: new Date('2026-08-28T00:00:00Z'),
  }), false);
});

test('staging generation becomes cleanup eligible at exactly seven days', () => {
  const now = new Date('2026-08-28T00:00:00Z');

  assert.equal(generationCleanupEligible({
    generationId: 'g1',
    status: 'staging',
    createdAt: new Date('2026-08-21T00:00:01Z'),
    activeGenerationId: null,
    now,
  }), false);

  assert.equal(generationCleanupEligible({
    generationId: 'g1',
    status: 'staging',
    createdAt: new Date('2026-08-21T00:00:00Z'),
    activeGenerationId: null,
    now,
  }), true);
});

test('retired generation becomes cleanup eligible at exactly thirty days', () => {
  const now = new Date('2026-08-28T00:00:00Z');

  assert.equal(generationCleanupEligible({
    generationId: 'g1',
    status: 'retired',
    retiredAt: new Date('2026-07-29T00:00:01Z'),
    activeGenerationId: null,
    now,
  }), false);

  assert.equal(generationCleanupEligible({
    generationId: 'g1',
    status: 'retired',
    retiredAt: new Date('2026-07-29T00:00:00Z'),
    activeGenerationId: null,
    now,
  }), true);
});

test('tombstone cutoff is exactly ninety days before now', () => {
  assert.equal(
    cutoffDate(new Date('2026-08-28T00:00:00Z'), TOMBSTONE_RETENTION_DAYS).toISOString(),
    '2026-05-30T00:00:00.000Z',
  );
});

console.log('SYNC_GENERATION_POLICY_TEST_COUNT=11');
