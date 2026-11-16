import assert from 'node:assert/strict';
import {readdirSync, readFileSync} from 'node:fs';
import test from 'node:test';

import {TEST_SECRETS, setTestSecrets} from './_secrets-helper.mjs';
import * as store from '../lib/_secrets.js';

const src = new URL('../src/', import.meta.url);
const sources = readdirSync(src).filter(name => name.endsWith('.ts')).map(name => ({name, text: readFileSync(new URL(name, src), 'utf8')}));
const keysSection = readFileSync(new URL('../../docs/secrets-merge.md', import.meta.url), 'utf8')
  .split('## Keys')[1].split(/\n\n/)[1];
const documented = [...keysSection.matchAll(/^- `([A-Z0-9_]+)`$/gm)].map(match => match[1]).sort();

test('the keys the code reads equal the documented keys and the test value', () => {
  const read = new Set();
  for (const {name, text} of sources) {
    if (name === '_secrets.ts') continue;
    for (const match of text.matchAll(/\bsecret\('([A-Z0-9_]+)'/g)) read.add(match[1]);
  }
  assert.deepEqual([...read].sort(), [...store.SECRET_KEYS].sort());
  assert.deepEqual([...store.SECRET_KEYS].sort(), documented);
  assert.deepEqual(Object.keys(TEST_SECRETS).sort(), documented);
});

test('PANTAS_SECRETS is the only secret param, and only functions that read secrets declare it', () => {
  const defines = sources.flatMap(({name, text}) => [...text.matchAll(/defineSecret\('([A-Z0-9_]+)'\)/g)].map(m => `${name}:${m[1]}`));
  assert.deepEqual(defines, ['_secrets.ts:PANTAS_SECRETS']);
});

const original = process.env.PANTAS_SECRETS;
test.afterEach(() => {
  if (original === undefined) delete process.env.PANTAS_SECRETS; else process.env.PANTAS_SECRETS = original;
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
  for (const raw of ['{"TRIAL_IDENTITY_HMAC_KEY": "leaky-value-123"', 'not json leaky-value-123', '["leaky-value-123"]', 'null', '', undefined]) {
    if (raw === undefined) delete process.env.PANTAS_SECRETS; else process.env.PANTAS_SECRETS = raw;
    assert.throws(() => store.secret('TRIAL_IDENTITY_HMAC_KEY'), error => {
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

test('a changed value is read again, not served from an old parse', () => {
  setTestSecrets();
  assert.equal(store.secret('SIGN_IN_CODE_KEY'), TEST_SECRETS.SIGN_IN_CODE_KEY);
  setTestSecrets({SIGN_IN_CODE_KEY: 'rotated'});
  assert.equal(store.secret('SIGN_IN_CODE_KEY'), 'rotated');
});

test('only the emulator may use a stand-in, and bad JSON still fails there', () => {
  const emulator = process.env.FUNCTIONS_EMULATOR;
  try {
    delete process.env.PANTAS_SECRETS;
    delete process.env.FUNCTIONS_EMULATOR;
    assert.throws(() => store.secret('GUARDIAN_HMAC_KEY', {emulatorStandIn: 'x'}));
    process.env.FUNCTIONS_EMULATOR = 'true';
    assert.equal(store.secret('GUARDIAN_HMAC_KEY', {emulatorStandIn: 'x'}), 'x');
    assert.throws(() => store.secret('GUARDIAN_HMAC_KEY'));
    process.env.PANTAS_SECRETS = '{bad';
    assert.throws(() => store.secret('GUARDIAN_HMAC_KEY', {emulatorStandIn: 'x'}));
  } finally {
    if (emulator === undefined) delete process.env.FUNCTIONS_EMULATOR; else process.env.FUNCTIONS_EMULATOR = emulator;
  }
});
