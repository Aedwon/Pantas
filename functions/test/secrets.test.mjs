import assert from 'node:assert/strict';
import {readdirSync, readFileSync} from 'node:fs';
import test from 'node:test';

import {APP_GROUP, PAYMENT_GROUP, TEST_GROUPS, TEST_SECRETS, paymentBindingViolations, setTestSecrets} from './_secrets-helper.mjs';
import * as store from '../lib/_secrets.js';

const src = new URL('../src/', import.meta.url);
const sources = readdirSync(src).filter(name => name.endsWith('.ts')).map(name => ({name, text: readFileSync(new URL(name, src), 'utf8')}));
const doc = readFileSync(new URL('../../docs/secrets-merge.md', import.meta.url), 'utf8');
const keysSection = doc.split('## Keys')[1].split('\n## ')[0];
const documentedGroups = Object.fromEntries(keysSection.split('### ').slice(1).map(part => {
  const [name] = part.split('\n');
  return [name.trim(), [...part.matchAll(/^- `([A-Z0-9_]+)`$/gm)].map(match => match[1]).sort()];
}));
const documented = Object.values(documentedGroups).flat().sort();

test('the keys the code reads equal the documented keys and the test value', () => {
  const read = new Set();
  for (const {name, text} of sources) {
    if (name === '_secrets.ts') continue;
    for (const match of text.matchAll(/\bsecret\('([A-Z0-9_]+)'/g)) read.add(match[1]);
  }
  assert.deepEqual([...read].sort(), [...store.SECRET_KEYS].sort());
  assert.deepEqual([...store.SECRET_KEYS].sort(), documented);
  assert.deepEqual(Object.keys(TEST_SECRETS).sort(), documented);
  for (const group of [PAYMENT_GROUP, APP_GROUP]) {
    assert.deepEqual(documentedGroups[group], Object.keys(TEST_GROUPS[group]).sort(), group);
    assert.deepEqual(documentedGroups[group], store.SECRET_GROUPS[group].slice().sort(), group);
  }
});

test('the two groups are the only secret params', () => {
  const defines = sources.flatMap(({name, text}) => [...text.matchAll(/defineSecret\('([A-Z0-9_]+)'\)/g)].map(m => `${name}:${m[1]}`));
  assert.deepEqual(defines.sort(), ['_secrets.ts:PANTAS_APP_SECRETS', '_secrets.ts:PANTAS_PAYMENT_SECRETS']);
});

const original = {[PAYMENT_GROUP]: process.env[PAYMENT_GROUP], [APP_GROUP]: process.env[APP_GROUP]};
test.afterEach(() => {
  for (const [name, value] of Object.entries(original)) if (value === undefined) delete process.env[name]; else process.env[name] = value;
});

test('each key returns its own value', () => {
  setTestSecrets();
  for (const [key, value] of Object.entries(TEST_SECRETS)) assert.equal(store.secret(key), value);
});

test('a missing key, an empty value and a non-string value fail closed for that key only', () => {
  setTestSecrets({GUARDIAN_HMAC_KEY: undefined, SIGN_IN_CODE_KEY: '', PAYMONGO_SECRET_KEY: 7});
  assert.throws(() => store.secret('GUARDIAN_HMAC_KEY'), /GUARDIAN_HMAC_KEY/);
  assert.throws(() => store.secret('SIGN_IN_CODE_KEY'), /SIGN_IN_CODE_KEY/);
  assert.throws(() => store.secret('PAYMONGO_SECRET_KEY'), /PAYMONGO_SECRET_KEY/);
  assert.equal(store.secret('TRIAL_IDENTITY_HMAC_KEY'), TEST_SECRETS.TRIAL_IDENTITY_HMAC_KEY);
});

test('invalid JSON, a non-object and an unset secret all fail closed without echoing any value', () => {
  for (const [group, key] of [[APP_GROUP, 'TRIAL_IDENTITY_HMAC_KEY'], [PAYMENT_GROUP, 'PAYMONGO_SECRET_KEY']])
  for (const raw of [`{"${key}": "leaky-value-123"`, 'not json leaky-value-123', '["leaky-value-123"]', 'null', '', undefined]) {
    if (raw === undefined) delete process.env[group]; else process.env[group] = raw;
    assert.throws(() => store.secret(key), error => {
      assert.ok(!String(error.message).includes('leaky-value-123'), `message leaks for ${raw}`);
      assert.equal(error.code, 'failed-precondition');
      return true;
    }, `raw ${raw}`);
  }
});

test('the error for a bad key never contains a stored value', () => {
  setTestSecrets({GUARDIAN_HMAC_KEY: ''});
  assert.throws(() => store.secret('GUARDIAN_HMAC_KEY'), error => {
    for (const value of Object.values(TEST_SECRETS)) assert.ok(!String(error.message).includes(value));
    return true;
  });
});

test('a broken group fails closed without touching the other group', () => {
  setTestSecrets();
  process.env[PAYMENT_GROUP] = '{bad';
  assert.throws(() => store.secret('PAYMONGO_SECRET_KEY'));
  assert.equal(store.secret('GUARDIAN_HMAC_KEY'), TEST_SECRETS.GUARDIAN_HMAC_KEY);
  setTestSecrets();
  process.env[APP_GROUP] = '{bad';
  assert.throws(() => store.secret('GUARDIAN_HMAC_KEY'));
  assert.equal(store.secret('PAYMONGO_SECRET_KEY'), TEST_SECRETS.PAYMONGO_SECRET_KEY);
});

test('a key stored in the wrong group is not read', () => {
  setTestSecrets();
  process.env[APP_GROUP] = JSON.stringify({...TEST_GROUPS[APP_GROUP], PAYMONGO_SECRET_KEY: 'wrong-place'});
  process.env[PAYMENT_GROUP] = JSON.stringify({});
  assert.throws(() => store.secret('PAYMONGO_SECRET_KEY'), /PAYMONGO_SECRET_KEY/);
});

test('only checkout, the PayMongo webhook and the RevenueCat webhook bind the payment secret', async () => {
  const index = await import('../lib/index.js');
  const endpoints = Object.fromEntries(Object.entries(index).filter(([, fn]) => fn?.__endpoint).map(([name, fn]) => [name, fn.__endpoint]));
  assert.ok(Object.keys(endpoints).length > 50, 'the real endpoint list is loaded');
  assert.deepEqual(paymentBindingViolations(endpoints), []);
});

test('the binding check catches a guardian callable that binds the payment secret', () => {
  const real = {
    createPaymongoCheckout: {secretEnvironmentVariables: [{key: PAYMENT_GROUP}]},
    paymongoWebhook: {secretEnvironmentVariables: [{key: PAYMENT_GROUP}]},
    revenuecatWebhook: {secretEnvironmentVariables: [{key: PAYMENT_GROUP}]},
  };
  assert.deepEqual(paymentBindingViolations(real), []);
  const bad = {...real, sendGuardianLink: {secretEnvironmentVariables: [{key: APP_GROUP}, {key: PAYMENT_GROUP}]}};
  assert.deepEqual(paymentBindingViolations(bad), [`sendGuardianLink binds ${PAYMENT_GROUP}`]);
  assert.match(paymentBindingViolations({...real, revenuecatWebhook: {secretEnvironmentVariables: []}}).join(), /revenuecatWebhook does not bind/);
  assert.match(paymentBindingViolations({...real, paymongoWebhook: {secretEnvironmentVariables: [{key: PAYMENT_GROUP}, {key: APP_GROUP}]}}).join(), /paymongoWebhook binds PANTAS_APP_SECRETS/);
});

test('a changed value is read again, not served from an old parse', () => {
  setTestSecrets();
  assert.equal(store.secret('SIGN_IN_CODE_KEY'), TEST_SECRETS.SIGN_IN_CODE_KEY);
  setTestSecrets({SIGN_IN_CODE_KEY: 'rotated'});
  assert.equal(store.secret('SIGN_IN_CODE_KEY'), 'rotated');
});

test('only the emulator may use a stand-in, and bad JSON still fails there', () => {
  const emulator = process.env.FUNCTIONS_EMULATOR;
  try {
    delete process.env[APP_GROUP];
    delete process.env.FUNCTIONS_EMULATOR;
    assert.throws(() => store.secret('GUARDIAN_HMAC_KEY', {emulatorStandIn: 'x'}));
    process.env.FUNCTIONS_EMULATOR = 'true';
    assert.equal(store.secret('GUARDIAN_HMAC_KEY', {emulatorStandIn: 'x'}), 'x');
    assert.throws(() => store.secret('GUARDIAN_HMAC_KEY'));
    process.env[APP_GROUP] = '{bad';
    assert.throws(() => store.secret('GUARDIAN_HMAC_KEY', {emulatorStandIn: 'x'}));
  } finally {
    if (emulator === undefined) delete process.env.FUNCTIONS_EMULATOR; else process.env.FUNCTIONS_EMULATOR = emulator;
  }
});
