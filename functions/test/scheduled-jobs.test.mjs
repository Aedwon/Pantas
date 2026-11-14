import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import test from 'node:test';

import * as jobs from '../lib/scheduledJobs.js';

const at = (iso) => iso;

function fakeRegistry(behaviour = {}) {
  const ran = [];
  const registry = {};
  for (const name of jobs.TASK_NAMES) {
    registry[name] = {
      name, budgetMs: behaviour[name]?.budgetMs ?? 1000,
      run: async () => {
        ran.push(name);
        if (behaviour[name]?.throws) throw new Error(behaviour[name].throws);
        if (behaviour[name]?.hangs) await new Promise(() => {});
        return {name};
      },
    };
  }
  return {registry, ran};
}

test('warm-up runs on every five-minute run', () => {
  for (const minute of ['00', '05', '10', '25', '55']) {
    assert.ok(jobs.frequentTaskNames(at(`2026-11-15T07:${minute}:00Z`)).includes('keepCallablesWarm'), minute);
  }
});

test('hourly tasks run on the first run of each hour only, judged from the scheduled time', () => {
  const hourly = ['repairEntitlementClaims', 'purgeOldGuardianRecords'];
  assert.deepEqual(jobs.frequentTaskNames(at('2026-11-15T07:00:00Z')), ['keepCallablesWarm', ...hourly]);
  // Delivered late: the scheduled time decides, not the clock when the run starts.
  const realNow = Date.now;
  Date.now = () => Date.parse('2026-11-15T07:03:30Z');
  try {
    assert.deepEqual(jobs.frequentTaskNames(at('2026-11-15T06:55:00Z')), ['keepCallablesWarm']);
    assert.deepEqual(jobs.frequentTaskNames(at('2026-11-15T07:00:00Z')), ['keepCallablesWarm', ...hourly]);
  } finally { Date.now = realNow; }
  for (const minute of ['05', '10', '30', '55']) {
    assert.deepEqual(jobs.frequentTaskNames(at(`2026-11-15T07:${minute}:00Z`)), ['keepCallablesWarm'], minute);
  }
  // Manila and Singapore are whole hours from UTC, so the first run of the hour is the same run.
  assert.deepEqual(jobs.frequentTaskNames(at('2026-11-15T16:00:00+08:00')), ['keepCallablesWarm', ...hourly]);
  // Every hour of a day has exactly one run with the hourly tasks.
  let withHourly = 0;
  for (let step = 0; step < 288; step += 1) {
    const time = new Date(Date.UTC(2026, 10, 15) + step * 300000).toISOString();
    if (jobs.frequentTaskNames(time).includes('repairEntitlementClaims')) withHourly += 1;
  }
  assert.equal(withHourly, 24);
});

test('a missing or unreadable scheduled time still runs the hourly tasks', () => {
  assert.ok(jobs.frequentTaskNames(undefined).includes('repairEntitlementClaims'));
  assert.ok(jobs.frequentTaskNames('not a date').includes('purgeOldGuardianRecords'));
});

test('the two daily jobs carry the agreed tasks in order', () => {
  assert.deepEqual(jobs.DAILY_EARLY_TASKS, ['cleanupOrphanAnons', 'purgeOldAuditLogs', 'checkRecentEntitlementClaims']);
  assert.deepEqual(jobs.DAILY_LATE_TASKS, ['cleanupSyncData', 'purgeInactiveAccounts', 'cleanupWrappedOrphans']);
});

test('the three jobs cover all nine tasks exactly once', () => {
  const all = [...jobs.frequentTaskNames('2026-11-15T07:00:00Z'), ...jobs.DAILY_EARLY_TASKS, ...jobs.DAILY_LATE_TASKS];
  assert.equal(all.length, 9);
  assert.deepEqual([...new Set(all)].sort(), [...jobs.TASK_NAMES].sort());
});

test('each job fits its function timeout with the sum of its task budgets', () => {
  const budget = (names) => names.reduce((sum, name) => sum + jobs.TASKS[name].budgetMs, 0) / 1000;
  assert.ok(budget(jobs.frequentTaskNames('2026-11-15T07:00:00Z')) < jobs.JOB_TIMEOUT_SECONDS.jobsFrequent);
  assert.ok(budget(jobs.DAILY_EARLY_TASKS) < jobs.JOB_TIMEOUT_SECONDS.jobsDailyEarly);
  assert.ok(budget(jobs.DAILY_LATE_TASKS) < jobs.JOB_TIMEOUT_SECONDS.jobsDailyLate);
  // The five-minute job must finish before the next trigger.
  assert.ok(jobs.JOB_TIMEOUT_SECONDS.jobsFrequent <= 300);
  for (const seconds of Object.values(jobs.JOB_TIMEOUT_SECONDS)) assert.ok(seconds <= 1800);
  // A task never gets less time than it had as its own function (540 s for the three long cleanups).
  for (const name of ['cleanupOrphanAnons', 'purgeInactiveAccounts', 'cleanupWrappedOrphans']) {
    assert.ok(jobs.TASKS[name].budgetMs >= 540000, name);
  }
});

test('combined jobs never overlap themselves and are exported with the agreed schedules', async () => {
  const index = await import('../lib/index.js');
  const expected = {
    jobsFrequent: 'every 5 minutes', jobsDailyEarly: 'every day 03:00', jobsDailyLate: 'every day 04:00',
  };
  for (const [name, schedule] of Object.entries(expected)) {
    const endpoint = index[name].__endpoint;
    assert.equal(endpoint.scheduleTrigger.schedule, schedule, name);
    assert.equal(endpoint.maxInstances, 1, name);
    assert.equal(endpoint.concurrency, 1, name);
    assert.equal(endpoint.timeoutSeconds, jobs.JOB_TIMEOUT_SECONDS[name], name);
    assert.deepEqual(endpoint.region, ['asia-southeast1']);
  }
  assert.equal(index.jobsDailyEarly.__endpoint.scheduleTrigger.timeZone, 'Asia/Singapore');
  assert.equal(index.jobsDailyLate.__endpoint.scheduleTrigger.timeZone, 'Asia/Singapore');
  // The late job sends inactivity emails and reads the trial identity key.
  assert.ok(index.jobsDailyLate.__endpoint.secretEnvironmentVariables.length >= 2);
});

test('one task throwing does not stop the others, logs one stable ERROR line, and the job resolves', async () => {
  const {registry, ran} = fakeRegistry({purgeOldAuditLogs: {throws: 'boom'}});
  const lines = [];
  const outcomes = await jobs.runJob(jobs.DAILY_EARLY_TASKS, registry, {log: (message, fields) => lines.push({message, fields})});
  assert.deepEqual(ran, jobs.DAILY_EARLY_TASKS);
  assert.deepEqual(outcomes.map((o) => [o.task, o.ok]),
    [['cleanupOrphanAnons', true], ['purgeOldAuditLogs', false], ['checkRecentEntitlementClaims', true]]);
  assert.equal(lines.length, 1);
  assert.equal(lines[0].message, 'Scheduled task failed: purgeOldAuditLogs');
  assert.equal(lines[0].fields.task, 'purgeOldAuditLogs');
  assert.equal(lines[0].fields.error, 'boom');
});

test('a task that hangs past its own budget is abandoned, logged, and the next task still runs', async () => {
  const {registry, ran} = fakeRegistry({purgeInactiveAccounts: {hangs: true, budgetMs: 30}});
  const lines = [];
  const started = Date.now();
  const outcomes = await jobs.runJob(jobs.DAILY_LATE_TASKS, registry, {log: (message, fields) => lines.push({message, fields})});
  assert.ok(Date.now() - started < 1000);
  assert.deepEqual(ran, jobs.DAILY_LATE_TASKS);
  assert.equal(outcomes[1].ok, false);
  assert.equal(lines.length, 1);
  assert.equal(lines[0].message, 'Scheduled task failed: purgeInactiveAccounts');
  assert.match(lines[0].fields.error, /timed out after 30 ms/);
});

test('every task failing still resolves, with one line per task', async () => {
  const behaviour = Object.fromEntries(jobs.TASK_NAMES.map((name) => [name, {throws: `e-${name}`}]));
  const {registry} = fakeRegistry(behaviour);
  const lines = [];
  await jobs.runJob(jobs.DAILY_LATE_TASKS, registry, {log: (message) => lines.push(message)});
  assert.deepEqual(lines, jobs.DAILY_LATE_TASKS.map((name) => `Scheduled task failed: ${name}`));
});

test('the failure line is a severity ERROR entry from the real logger, with the task as a field', async () => {
  const script = `
    const jobs = await import(${JSON.stringify(new URL('../lib/scheduledJobs.js', import.meta.url).href)});
    const registry = {cleanupSyncData: {name: 'cleanupSyncData', budgetMs: 1000, run: async () => { throw new Error('x'); }}};
    await jobs.runJob(['cleanupSyncData'], registry);`;
  const run = spawnSync(process.execPath, ['--input-type=module', '-e', script], {encoding: 'utf8', env: {PATH: process.env.PATH, GCLOUD_PROJECT: 'demo-pantas-test'}});
  assert.equal(run.status, 0, run.stderr);
  // The logger writes ERROR entries to stderr as one JSON line each.
  const entries = run.stderr.split('\n').filter(Boolean).map((line) => JSON.parse(line));
  assert.equal(entries.length, 1);
  assert.equal(entries[0].severity, 'ERROR');
  // The logger prefixes the message with a stack for Error Reporting; the stable text stays inside it.
  assert.ok(entries[0].message.includes('Scheduled task failed: cleanupSyncData'));
  assert.equal(entries[0].task, 'cleanupSyncData');
  assert.equal(entries[0].error, 'x');
});

test('the manual runner runs the named task and returns its result', async () => {
  const {registry, ran} = fakeRegistry();
  const reply = await jobs.handleRunnerRequest('POST', 'cleanupSyncData', registry);
  assert.equal(reply.status, 200);
  assert.deepEqual(ran, ['cleanupSyncData']);
  assert.equal(reply.body.task, 'cleanupSyncData');
  assert.equal(reply.body.ok, true);
  assert.deepEqual(reply.body.result, {name: 'cleanupSyncData'});
});

test('the manual runner rejects unknown or missing names and non-POST calls without running anything', async () => {
  const {registry, ran} = fakeRegistry();
  for (const name of ['nope', '', undefined, 'constructor', '__proto__']) {
    const reply = await jobs.handleRunnerRequest('POST', name, registry);
    assert.equal(reply.status, 400, String(name));
    assert.deepEqual(reply.body.tasks, jobs.TASK_NAMES);
  }
  assert.equal((await jobs.handleRunnerRequest('GET', 'cleanupSyncData', registry)).status, 405);
  assert.deepEqual(ran, []);
});

test('the manual runner reports a failing task as 500 and does not use the alert line', async () => {
  const {registry} = fakeRegistry({cleanupSyncData: {throws: 'bad'}});
  const lines = [];
  const reply = await jobs.handleRunnerRequest('POST', 'cleanupSyncData', registry, {log: (message) => lines.push(message)});
  assert.equal(reply.status, 500);
  assert.equal(reply.body.ok, false);
  assert.equal(reply.body.error, 'bad');
  assert.ok(lines.every((line) => !line.startsWith('Scheduled task failed:')));
});
