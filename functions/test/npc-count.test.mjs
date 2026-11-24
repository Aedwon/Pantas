import assert from 'node:assert/strict';
import test from 'node:test';

import {runNpcDataSubjectCount, NPC_ALERT_AT} from '../lib/npcDataSubjectCount.js';
import * as jobs from '../lib/scheduledJobs.js';

function fakeDb(result) {
  const seen = {};
  const db = {collectionGroup: (group) => { seen.group = group; return {where: (field, op, value) => {
    seen.where = [field, op, value];
    return {count: () => ({get: async () => { if (result instanceof Error) throw result; return {data: () => ({count: result})}; }})};
  }}; }};
  return {db, seen};
}
const run = async (result) => {
  const info = []; const error = [];
  const {db, seen} = fakeDb(result);
  const out = await runNpcDataSubjectCount({db, info: (t) => info.push(t), error: (t) => error.push(t)});
  return {out, info, error, seen};
};

test('below 800 it logs the count at INFO and nothing at ERROR', async () => {
  const {out, info, error, seen} = await run(799);
  assert.deepEqual(out, {count: 799});
  assert.deepEqual(info, ['npc data subjects 799']);
  assert.deepEqual(error, []);
  assert.equal(seen.group, 'server');
  assert.deepEqual(seen.where, ['ageGroup', 'in', ['minor', 'adult']]);
});

test('at 800 it also logs one ERROR line with the count only', async () => {
  assert.equal(NPC_ALERT_AT, 800);
  const {info, error} = await run(800);
  assert.deepEqual(info, ['npc data subjects 800']);
  assert.deepEqual(error, ['npc registration threshold near 800 of 1000']);
});

test('a query error does not stop the other tasks in the job', async () => {
  const ran = []; const lines = [];
  const registry = {};
  for (const name of jobs.TASK_NAMES) {
    registry[name] = {name, budgetMs: 1000, run: async () => {
      ran.push(name);
      if (name === 'npcDataSubjectCount') await runNpcDataSubjectCount({db: fakeDb(new Error('missing index')).db});
      return {};
    }};
  }
  const outcomes = await jobs.runJob(jobs.DAILY_EARLY_TASKS, registry, {log: (m, f) => lines.push({m, f})});
  assert.deepEqual(ran, jobs.DAILY_EARLY_TASKS);
  assert.equal(outcomes.filter((o) => !o.ok).length, 1);
  assert.equal(lines[0].m, 'Scheduled task failed: npcDataSubjectCount');
});
