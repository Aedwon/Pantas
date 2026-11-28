import assert from 'node:assert/strict';
import test from 'node:test';
import {repairQueuedPlans} from './repair_queued_plans.mjs';

const now = Date.parse('2027-03-14T12:00:00Z');
const row = (uid, id, startsAt, state = 'active') => ({ref: {path: `users/${uid}/grants/${id}`},
  data: () => ({startsAt, state})});

function harness(rows, counts = {}) {
  const calls = [], lines = [];
  const db = {collectionGroup: name => ({get: async () => {
    assert.equal(name, 'grants');
    return {docs: rows};
  }})};
  const repair = async (_db, uid, at, options) => {calls.push({uid, at, options}); return counts[uid] ?? 0;};
  const run = (args) => repairQueuedPlans({args, db, repair, now: () => now, log: (...a) => lines.push(a.join(' '))});
  return {calls, lines, run};
}

const rows = [row('uid_secret_1', 'a', now + 1000), row('uid_secret_1', 'b', now + 2000),
  row('uid_secret_2', 'c', now + 1000), row('uid_secret_3', 'd', now - 5), row('uid_secret_4', 'e', now + 9, 'revoked')];

test('the default run is a dry run: it counts accounts and plans and prints no uid', async () => {
  const {calls, lines, run} = harness(rows, {uid_secret_1: 2, uid_secret_2: 0});
  assert.deepEqual(await run(['pantas-staging']), {accounts: 1, plans: 2, applied: false});
  assert.deepEqual(calls.map(c => c.uid).sort(), ['uid_secret_1', 'uid_secret_2']);
  assert.equal(calls.every(c => c.options.dryRun === true), true);
  assert.match(lines.join('\n'), /2 plans in 1 account/);
  assert.match(lines.join('\n'), /dry run/i);
  assert.equal(lines.join('\n').includes('uid_secret'), false);
});

test('--apply repairs each account and prints no uid', async () => {
  const {calls, lines, run} = harness(rows, {uid_secret_1: 2, uid_secret_2: 1});
  assert.deepEqual(await run(['pantas-prod', '--apply']), {accounts: 2, plans: 3, applied: true});
  assert.equal(calls.every(c => c.options.dryRun === false), true);
  assert.equal(lines.join('\n').includes('uid_secret'), false);
});

test('the same argument checks as the redelivery tool', async () => {
  const {calls, run} = harness(rows);
  await assert.rejects(run([]), /arguments/);
  await assert.rejects(run(['pantas-dev']), /arguments/);
  await assert.rejects(run(['pantas-prod', '--aply']), /arguments/);
  await assert.rejects(run(['pantas-prod', '--apply', 'extra']), /arguments/);
  assert.equal(calls.length, 0);
});
