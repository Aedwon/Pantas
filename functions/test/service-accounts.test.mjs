import assert from 'node:assert/strict';
import test from 'node:test';

process.env.GCLOUD_PROJECT ??= 'demo-pantas-test';
const index = await import('../lib/index.js');
const {DEFAULT_SERVICE_ACCOUNT, SERVICE_ACCOUNTS, serviceAccountFor} = await import('../lib/serviceAccounts.js');

const functions = Object.entries(index).filter(([, value]) => value?.__endpoint);

test('every mapped name is a real function export', () => {
  const names = new Set(functions.map(([name]) => name));
  const missing = Object.values(SERVICE_ACCOUNTS).flat().filter((name) => !names.has(name));
  assert.deepEqual(missing, []);
});

test('no function name is mapped to two accounts', () => {
  const all = Object.values(SERVICE_ACCOUNTS).flat();
  assert.equal(new Set(all).size, all.length);
});

test('every function runs as its mapped account, never the default compute account', () => {
  assert.ok(functions.length >= 60, `expected all functions, found ${functions.length}`);
  const wrong = [];
  for (const [name, fn] of functions) {
    const actual = fn.__endpoint.serviceAccountEmail;
    if (!actual) wrong.push(`${name}: no service account (default compute account)`);
    else if (actual !== serviceAccountFor(name)) wrong.push(`${name}: ${actual}, expected ${serviceAccountFor(name)}`);
  }
  assert.deepEqual(wrong, []);
});

test('functions not listed run as the default account', () => {
  const listed = new Set(Object.values(SERVICE_ACCOUNTS).flat());
  for (const [name, fn] of functions) {
    if (!listed.has(name)) assert.equal(fn.__endpoint.serviceAccountEmail, DEFAULT_SERVICE_ACCOUNT, name);
  }
});
