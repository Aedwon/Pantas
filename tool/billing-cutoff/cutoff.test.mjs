// Run: node --test tool/billing-cutoff/
import assert from 'node:assert/strict';
import test from 'node:test';
import {decide, handle} from './cutoff.mjs';

const env = {PROJECT_ID: 'pantas-staging', BUDGET_ID: 'budget-1', ALERT_POLICY_PREFIX: 'billing-cutoff', DRY_RUN: 'false'};
const budget = (cost, amount = 5, budgetId = 'budget-1') => ({
  attributes: {budgetId, billingAccountId: 'acct'},
  data: Buffer.from(JSON.stringify({costAmount: cost, budgetAmount: amount, budgetDisplayName: 'cutoff'})).toString('base64'),
});
const alert = (state, policy = 'billing-cutoff: hosting bytes') => ({
  attributes: {},
  data: Buffer.from(JSON.stringify({incident: {state, policy_name: policy}})).toString('base64'),
});

test('budget under or at its amount does nothing', () => {
  assert.equal(decide(budget(4.99), env).act, false);
  assert.equal(decide(budget(5), env).act, false);
});

test('budget over its amount cuts billing', () => {
  assert.equal(decide(budget(5.01), env).act, true);
});

test('a message from another budget is ignored', () => {
  assert.equal(decide(budget(99, 5, 'other-budget'), env).act, false);
});

test('an open usage alarm from a cutoff policy cuts billing; a closed one or another policy does not', () => {
  assert.equal(decide(alert('open'), env).act, true);
  assert.equal(decide(alert('closed'), env).act, false);
  assert.equal(decide(alert('open', 'some other alert'), env).act, false);
});

test('a message it cannot read does nothing', () => {
  assert.equal(decide({data: Buffer.from('not json').toString('base64')}, env).act, false);
  assert.equal(decide({}, env).act, false);
});

const fakeBilling = (enabled = true) => {
  const calls = [];
  return {
    calls,
    getBillingInfo: async () => ({billingEnabled: enabled}),
    disableBilling: async project => { calls.push(project); },
  };
};

test('dry run logs but never disables billing', async () => {
  const billing = fakeBilling();
  const result = await handle(budget(50), {...env, DRY_RUN: 'true'}, billing, () => {});
  assert.equal(result, 'dry run: would disable billing');
  assert.deepEqual(billing.calls, []);
});

test('a real trigger disables billing on the configured project only', async () => {
  const billing = fakeBilling();
  const result = await handle(budget(50), env, billing, () => {});
  assert.equal(result, 'billing disabled');
  assert.deepEqual(billing.calls, ['pantas-staging']);
});

test('dry run is the default when the flag is missing or unclear', async () => {
  const billing = fakeBilling();
  const {DRY_RUN: _, ...noFlag} = env;
  assert.equal(await handle(budget(50), noFlag, billing, () => {}), 'dry run: would disable billing');
  assert.equal(await handle(budget(50), {...env, DRY_RUN: 'no'}, billing, () => {}), 'dry run: would disable billing');
  assert.deepEqual(billing.calls, []);
});

test('billing already off is left alone', async () => {
  const billing = fakeBilling(false);
  assert.equal(await handle(budget(50), env, billing, () => {}), 'billing already disabled');
  assert.deepEqual(billing.calls, []);
});

test('no trigger means no billing call at all', async () => {
  const billing = fakeBilling();
  assert.equal(await handle(budget(1), env, billing, () => {}), 'no action');
  assert.deepEqual(billing.calls, []);
});

test('if reading the billing state fails, it still cuts billing rather than doing nothing', async () => {
  const billing = fakeBilling();
  billing.getBillingInfo = async () => { throw new Error('Cloud Billing 403: denied'); };
  assert.equal(await handle(budget(50), env, billing, () => {}), 'billing disabled');
  assert.deepEqual(billing.calls, ['pantas-staging']);
});
