// Tests for the upload tool's read-budget check (process-improvement, "Upload runs read past the free tier
// again (Nov 28)"). Nothing here touches a hosted project: the usage source is always injected.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {test} from 'node:test';
import {BUDGETS, PROD_REAL_USER_RESERVE, budgetFor, decideBudget, guardLiveRun} from './upload_budget.mjs';

test('budgets: staging 40,000; prod 40,000 minus a 15,000 reserve for real users', () => {
  assert.equal(PROD_REAL_USER_RESERVE, 15000);
  assert.deepEqual(BUDGETS, {staging: 40000, prod: 25000});
  assert.equal(budgetFor('pantas-staging'), 40000);
  assert.equal(budgetFor('pantas-prod'), 25000);
  assert.equal(budgetFor('demo-pantas-test'), null);
});

test('the decision refuses when used plus expected passes the budget and allows it at or under', () => {
  assert.equal(decideBudget({used: 38000, expected: 2001, budget: 40000}).ok, false);
  assert.equal(decideBudget({used: 38000, expected: 2000, budget: 40000}).ok, true);
  const refused = decideBudget({used: 52370, expected: 1500, budget: 40000});
  assert.match(refused.line, /used 52370/);
  assert.match(refused.line, /expected 1500/);
  assert.match(refused.line, /budget 40000/);
});

const base = {live: true, emulator: false, outDir: undefined, project: 'pantas-staging', expected: 1500};

test('a live run refuses with exit 75 when the project is already over budget, before any read', async () => {
  const lines = [];
  const code = await guardLiveRun({...base, readUsage: async () => 52370, log: (line) => lines.push(line)});
  assert.equal(code, 75);
  assert.equal(lines.length, 1);
  assert.match(lines[0], /used 52370.*expected 1500.*budget 40000/);
});

test('a live run on prod refuses at the prod limit, which holds back the real-user reserve', async () => {
  const code = await guardLiveRun({...base, project: 'pantas-prod', readUsage: async () => 24000, log: () => {}});
  assert.equal(code, 75);
});

test('a live run with room left may start', async () => {
  assert.equal(await guardLiveRun({...base, readUsage: async () => 1000, log: () => {}}), 0);
});

test('unreadable usage refuses: unknown is not zero', async () => {
  const lines = [];
  const code = await guardLiveRun({...base, readUsage: async () => { throw new Error('no credentials'); }, log: (line) => lines.push(line)});
  assert.equal(code, 75);
  assert.match(lines[0], /could not read/i);
});

test('a project with no budget refuses', async () => {
  assert.equal(await guardLiveRun({...base, project: 'some-other-project', readUsage: async () => 0, log: () => {}}), 75);
});

test('the emulator and --out-dir are not checked, and the usage source is never called', async () => {
  const never = async () => { throw new Error('must not read usage'); };
  assert.equal(await guardLiveRun({...base, emulator: true, readUsage: never, log: () => {}}), 0);
  assert.equal(await guardLiveRun({...base, live: false, readUsage: never, log: () => {}}), 0);
  assert.equal(await guardLiveRun({...base, outDir: '/tmp/x', readUsage: never, log: () => {}}), 0);
});

test('the CLI runs the check before it creates a Firestore client, and has no override flag', () => {
  const text = readFileSync(new URL('./upload_content.mjs', import.meta.url), 'utf8');
  assert.ok(text.includes('guardLiveRun'));
  assert.ok(text.indexOf('guardLiveRun') < text.indexOf('initializeApp({'), 'the check must come first');
  assert.equal(/--(force|override|skip-budget|no-budget)/.test(text), false);
});
