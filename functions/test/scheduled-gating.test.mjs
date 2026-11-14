import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {readFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import test from 'node:test';

const functionsDir = fileURLToPath(new URL('..', import.meta.url));
const NEW_JOBS = ['jobsDailyEarly', 'jobsDailyLate', 'jobsFrequent'];
const LEGACY = ['checkRecentEntitlementClaims', 'cleanupOrphanAnons', 'cleanupSyncData', 'cleanupWrappedOrphans',
  'keepCallablesWarm', 'purgeInactiveAccounts', 'purgeOldAuditLogs', 'purgeOldGuardianRecords', 'repairEntitlementClaims'];

function parseEnvFile(name) {
  const env = {};
  for (const line of readFileSync(new URL(`../${name}`, import.meta.url), 'utf8').split('\n')) {
    const match = /^([A-Z0-9_]+)=(.*)$/.exec(line);
    if (match) env[match[1]] = match[2];
  }
  return env;
}

/** Loads lib/index.js the way firebase-tools does (firebase-functions' own loader), in a clean process. */
function discover(extraEnv) {
  const env = {PATH: process.env.PATH, HOME: process.env.HOME, GCLOUD_PROJECT: 'demo-pantas-test', ...extraEnv};
  const script = `
    const {createRequire} = require('node:module');
    const loader = require(${JSON.stringify(`${functionsDir}node_modules/firebase-functions/lib/runtime/loader.js`)});
    loader.loadStack(${JSON.stringify(functionsDir)}).then((stack) => {
      const out = Object.entries(stack.endpoints).map(([name, e]) => ({name, schedule: e.scheduleTrigger?.schedule ?? null,
        invoker: e.httpsTrigger?.invoker ?? null}));
      process.stdout.write(JSON.stringify(out));
    }).catch((error) => { console.error(error); process.exit(1); });`;
  const output = execFileSync(process.execPath, ['-e', script], {env, cwd: functionsDir, encoding: 'utf8'});
  const endpoints = JSON.parse(output);
  return {
    scheduled: endpoints.filter((e) => e.schedule).map((e) => e.name).sort(),
    runner: endpoints.find((e) => e.name === 'runScheduledTask'),
    all: endpoints,
  };
}

test('with no setting, three combined jobs and the nine legacy jobs are scheduled', () => {
  const {scheduled} = discover({});
  assert.deepEqual(scheduled, [...NEW_JOBS, ...LEGACY].sort());
});

test('the prod env file schedules exactly the three combined jobs plus the nine legacy ones', () => {
  const {scheduled} = discover(parseEnvFile('.env.pantas-prod'));
  assert.equal(scheduled.length, 12);
  assert.deepEqual(scheduled, [...NEW_JOBS, ...LEGACY].sort());
});

test('the staging env file schedules nothing, and the runner is still deployed', () => {
  const {scheduled, runner} = discover(parseEnvFile('.env.pantas-staging'));
  assert.deepEqual(scheduled, []);
  assert.ok(runner, 'runScheduledTask is exported on staging');
});

test('SCHEDULED_JOBS=off removes the combined and the legacy schedules, whatever LEGACY_SCHEDULES says', () => {
  for (const legacy of [undefined, 'on', 'off']) {
    const {scheduled} = discover({SCHEDULED_JOBS: 'off', ...(legacy ? {LEGACY_SCHEDULES: legacy} : {})});
    assert.deepEqual(scheduled, [], `legacy=${legacy}`);
  }
});

test('LEGACY_SCHEDULES=off leaves only the three combined jobs', () => {
  const {scheduled} = discover({LEGACY_SCHEDULES: 'off'});
  assert.deepEqual(scheduled, NEW_JOBS);
});

test('the runner exists under every setting and is private', () => {
  for (const env of [{}, {SCHEDULED_JOBS: 'off'}, {LEGACY_SCHEDULES: 'off'}, {SCHEDULED_JOBS: 'off', LEGACY_SCHEDULES: 'off'}]) {
    const {runner} = discover(env);
    assert.ok(runner, JSON.stringify(env));
    assert.equal(runner.schedule, null);
    assert.deepEqual(runner.invoker, ['private'], JSON.stringify(env));
  }
});

test('unknown values keep the schedules on, so a typo cannot silently stop cleanup', () => {
  const {scheduled} = discover({SCHEDULED_JOBS: 'maybe', LEGACY_SCHEDULES: 'yes'});
  assert.equal(scheduled.length, 12);
});
