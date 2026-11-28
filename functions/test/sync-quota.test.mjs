import assert from 'node:assert/strict';
import test from 'node:test';

process.env.GCLOUD_PROJECT ??= 'demo-pantas-test';
const index = await import('../lib/index.js');
const quota = await import('../lib/countSyncWrites.js');

test('countSyncWrites is a Firestore trigger on sync rows, in the jobs account, capped at 3 instances', () => {
  const endpoint = index.countSyncWrites.__endpoint;
  assert.equal(endpoint.region[0], 'asia-southeast1');
  assert.equal(endpoint.maxInstances, 3);
  assert.match(endpoint.serviceAccountEmail, /^pantas-jobs@/);
  const filters = endpoint.eventTrigger.eventFilterPathPatterns;
  assert.equal(filters.document, 'users/{uid}/sync_generations/{generationId}/{collection}/{rowId}');
  assert.match(endpoint.eventTrigger.eventType, /written/);
});

test('caps default to the spec values and read lower values from the environment', () => {
  const saved = {...process.env};
  try {
    delete process.env.SYNC_ROWS_PER_HOUR; delete process.env.SYNC_ROWS_PER_DAY; delete process.env.SYNC_BYTES_PER_DAY;
    assert.deepEqual(quota.syncCaps(), {rowsPerHour: 10_000, rowsPerDay: 30_000, bytesPerDay: 50_000_000});
    process.env.SYNC_ROWS_PER_HOUR = '5'; process.env.SYNC_ROWS_PER_DAY = '9'; process.env.SYNC_BYTES_PER_DAY = '1000';
    assert.deepEqual(quota.syncCaps(), {rowsPerHour: 5, rowsPerDay: 9, bytesPerDay: 1000});
    process.env.SYNC_ROWS_PER_HOUR = 'abc'; process.env.SYNC_ROWS_PER_DAY = '-4'; process.env.SYNC_BYTES_PER_DAY = '0';
    assert.deepEqual(quota.syncCaps(), {rowsPerHour: 10_000, rowsPerDay: 30_000, bytesPerDay: 50_000_000});
  } finally { process.env = saved; }
});

test('pause ends at the next UTC hour for the hourly cap and at UTC midnight for the daily caps', () => {
  const at = new Date('2026-11-22T13:45:10.000Z');
  assert.equal(quota.nextUtcHour(at).toISOString(), '2026-11-22T14:00:00.000Z');
  assert.equal(quota.nextUtcHour(new Date('2026-11-22T23:59:59.999Z')).toISOString(), '2026-11-23T00:00:00.000Z');
  assert.equal(quota.nextUtcMidnight(at).toISOString(), '2026-11-23T00:00:00.000Z');
  assert.equal(quota.dayKey(at), '20261122');
});

test('about 1 event in 20 is checked, chosen by a hash of the event id', () => {
  let hits = 0;
  for (let i = 0; i < 4000; i++) if (quota.shouldCheck(`event-${i}`, 20)) hits++;
  assert.ok(hits > 120 && hits < 300, `hits ${hits}`);
  assert.equal(quota.shouldCheck('same', 20), quota.shouldCheck('same', 20));
  assert.equal(quota.shouldCheck('anything', 1), true);
});
