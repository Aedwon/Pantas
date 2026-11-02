import assert from 'node:assert/strict';
import test from 'node:test';
import {createCeiling, DAILY_DELIVERED_CEILING, CEILING_SHARDS} from '../lib/_contentCeiling.js';

const DAY_MS = 86_400_000;
const T0 = Date.parse('2026-11-20T10:00:00+08:00');

function rig(overrides = {}) {
  const state = {now: T0, total: 0, reads: 0, writes: [], alerts: []};
  const store = {
    read: async () => { state.reads++; return state.total; },
    add: async (day, shard, amount) => { state.writes.push({day, shard, amount}); },
  };
  const ceiling = createCeiling({
    store, now: () => state.now, random: () => 0.5, alert: m => state.alerts.push(m), ...overrides,
  });
  return {state, ceiling};
}

test('the ceiling is 200,000 delivered ids a day, spread over many counters', () => {
  assert.equal(DAILY_DELIVERED_CEILING, 200_000);
  assert.ok(CEILING_SHARDS >= 20);
});

test('it is open below the ceiling and reads the total once while the cache is fresh', async () => {
  const {state, ceiling} = rig();
  state.total = 1000;
  assert.equal(await ceiling.isOpen(), true);
  assert.equal(await ceiling.isOpen(), true);
  assert.equal(state.reads, 1);
  state.now += 31_000;
  await ceiling.isOpen();
  assert.equal(state.reads, 2);
});

test('it closes at the ceiling and counts what this instance delivered since the last read', async () => {
  const {state, ceiling} = rig();
  state.total = DAILY_DELIVERED_CEILING - 10;
  assert.equal(await ceiling.isOpen(), true);
  await ceiling.record(10);
  assert.equal(await ceiling.isOpen(), false);
});

test('record makes exactly one write, to a counter picked at random, with the delivered amount', async () => {
  const {state, ceiling} = rig({random: () => 0.999});
  await ceiling.record(7);
  assert.equal(state.writes.length, 1);
  assert.deepEqual(state.writes[0], {day: '2026-11-20', shard: CEILING_SHARDS - 1, amount: 7});
  await ceiling.record(0);
  assert.equal(state.writes.length, 1);
});

test('a failed write never fails the caller', async () => {
  const {ceiling} = rig({store: {read: async () => 0, add: async () => { throw new Error('down'); }}});
  await ceiling.record(3);
});

test('near the ceiling the total is re-read every two seconds so instances do not overshoot far', async () => {
  const {state, ceiling} = rig();
  state.total = DAILY_DELIVERED_CEILING * 0.95;
  await ceiling.isOpen();
  state.now += 2_100;
  await ceiling.isOpen();
  assert.equal(state.reads, 2);
});

test('the total starts again on the next Philippine day', async () => {
  const {state, ceiling} = rig();
  state.total = DAILY_DELIVERED_CEILING + 5;
  assert.equal(await ceiling.isOpen(), false);
  state.now += DAY_MS;
  state.total = 0;
  assert.equal(await ceiling.isOpen(), true);
});

test('it logs one alertable line at 80% and one when the ceiling is reached', async () => {
  const {state, ceiling} = rig();
  state.total = DAILY_DELIVERED_CEILING * 0.8 + 1;
  await ceiling.isOpen();
  await ceiling.isOpen();
  assert.equal(state.alerts.length, 1);
  assert.match(state.alerts[0], /^Daily content ceiling reached 80%/);
  state.now += 31_000;
  state.total = DAILY_DELIVERED_CEILING;
  await ceiling.isOpen();
  await ceiling.isOpen();
  assert.equal(state.alerts.length, 2);
  assert.match(state.alerts[1], /^Daily content ceiling reached\./);
});
