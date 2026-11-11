import assert from 'node:assert/strict';
import test from 'node:test';
import * as functions from '../lib/index.js';

// The default every function gets, and the explicit limits that must not share it.
const DEFAULT_CAP = 10;
const EXPLICIT = {paymongoWebhook: 30, revenuecatWebhook: 30, deleteAccount: 20};

const endpoints = Object.entries(functions).filter(([, fn]) => typeof fn === 'function').map(([name, fn]) => [name, fn.__endpoint]);

test('every deployed function declares a maxInstances cap', () => {
  assert.ok(endpoints.length > 40, `found only ${endpoints.length} functions`);
  for (const [name, endpoint] of endpoints) {
    assert.ok(endpoint, `${name} has no endpoint`);
    assert.equal(typeof endpoint.maxInstances, 'number', `${name} has no maxInstances`);
  }
});

test('payment webhooks and account deletion have their own explicit limits; everything else gets the default', () => {
  for (const [name, endpoint] of endpoints) {
    assert.equal(endpoint.maxInstances, EXPLICIT[name] ?? DEFAULT_CAP, name);
  }
  for (const name of Object.keys(EXPLICIT)) assert.ok(functions[name], `${name} is exported`);
});

test('no function keeps instances warm', () => {
  for (const [name, endpoint] of endpoints) {
    assert.ok(typeof endpoint.minInstances !== 'number' || endpoint.minInstances === 0, name);
  }
});
