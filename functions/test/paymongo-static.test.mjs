import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';
import * as endpoints from '../lib/index.js';

const source = name => readFileSync(new URL(`../src/${name}`, import.meta.url), 'utf8');

test('index exports the PayMongo checkout, webhook, trial and plan list functions', () => {
  for (const name of ['createPaymongoCheckout', 'paymongoWebhook', 'startWebTrial', 'listWebPlans']) {
    assert.equal(typeof endpoints[name], 'function', name);
    assert.match(source('index.ts'), new RegExp(`export \\{ ${name} \\}`));
  }
});

test('the plan list enforces App Check and takes its prices from products.json only', () => {
  assert.match(source('webPlans.ts'), /enforceAppCheck: enforceAppCheck/);
  assert.match(source('webPlans.ts'), /priceCentavos\(product\)/);
  assert.doesNotMatch(source('webPlans.ts'), /webPricePhp|\b(49|149|1199|499)\b/);
});

test('callables enforce App Check; secrets come only from Functions secrets', () => {
  for (const file of ['paymongoCheckout.ts', 'webTrial.ts']) {
    assert.match(source(file), /enforceAppCheck: enforceAppCheck/);
    assert.match(source(file), /consumeAppCheckToken: enforceAppCheck/);
    assert.match(source(file), /assertNamedUser\(auth\)/);
  }
  assert.match(source('paymongoCheckout.ts'), /defineSecret\('PAYMONGO_SECRET_KEY'\)/);
  assert.match(source('paymongoWebhook.ts'), /defineSecret\('PAYMONGO_WEBHOOK_SECRET'\)/);
  for (const file of ['paymongoCheckout.ts', 'paymongoWebhook.ts', 'paymongoClient.ts', 'paymongoPolicy.ts', 'webTrial.ts']) {
    assert.doesNotMatch(source(file), /sk_(test|live)_[A-Za-z0-9]{6,}/);
  }
});
