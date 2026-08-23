import assert from 'node:assert/strict';
import test from 'node:test';

import {
  effectiveReviewStatus,
  filterReviewItems,
  queueNeighborKey,
  reviewProgress,
} from './public/illustration_review.mjs';

const items = [
  { key: 'a', digest: '1'.repeat(64), status: 'pending', stale: false },
  { key: 'b', digest: '2'.repeat(64), status: 'changes-requested', stale: false },
  { key: 'c', digest: '3'.repeat(64), status: 'approved', stale: false },
  { key: 'd', digest: null, status: 'approved', stale: false, missingReason: 'Founder PNG has not been supplied.' },
  { key: 'e', digest: '5'.repeat(64), status: 'approved', stale: true },
];

test('Pending filter includes pending and stale decisions in catalog order', () => {
  assert.deepEqual(filterReviewItems(items, 'pending').map((item) => item.key), ['a', 'e']);
});

test('Needs changes filter uses changes-requested status', () => {
  assert.deepEqual(filterReviewItems(items, 'changes-requested').map((item) => item.key), ['b']);
});

test('Approved filter excludes stale and missing decisions', () => {
  assert.deepEqual(filterReviewItems(items, 'approved').map((item) => item.key), ['c']);
});

test('Missing filter includes items without a current digest', () => {
  assert.deepEqual(filterReviewItems(items, 'missing').map((item) => item.key), ['d']);
});

test('missing status has precedence over stale or saved approval state', () => {
  assert.equal(effectiveReviewStatus({ digest: null, status: 'approved', stale: true }), 'missing');
  assert.equal(effectiveReviewStatus({ digest: null, status: 'changes-requested', stale: false }), 'missing');
});

test('stale approval becomes pending while a current approval stays approved', () => {
  assert.equal(effectiveReviewStatus({ digest: 'a'.repeat(64), status: 'approved', stale: true }), 'pending');
  assert.equal(effectiveReviewStatus({ digest: 'a'.repeat(64), status: 'approved', stale: false }), 'approved');
});

test('next queue navigation follows filtered queue order and stops at the end', () => {
  const queue = filterReviewItems(items, 'pending');
  assert.equal(queueNeighborKey(queue, 'a', 1), 'e');
  assert.equal(queueNeighborKey(queue, 'e', 1), null);
});

test('previous queue navigation follows filtered queue order and stops at the start', () => {
  const queue = filterReviewItems(items, 'pending');
  assert.equal(queueNeighborKey(queue, 'e', -1), 'a');
  assert.equal(queueNeighborKey(queue, 'a', -1), null);
});

test('progress counts use effective status and include stale approval as pending', () => {
  assert.deepEqual(reviewProgress(items), {
    total: 5,
    pending: 2,
    changesRequested: 1,
    approved: 1,
    missing: 1,
    reviewed: 2,
  });
});
