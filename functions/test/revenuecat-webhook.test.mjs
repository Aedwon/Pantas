import assert from 'node:assert/strict';
import test from 'node:test';
import {readFileSync} from 'node:fs';
import {reconcileWebhook} from '../lib/revenuecatWebhook.js';
test('AC-3 unsigned and altered requests are refused before any backend side effect', async () => {
  const unavailable = () => {throw Error('backend must not run');};
  const deps = {db:{doc:unavailable},auth:{getUser:unavailable},appId:'test-app', signingSecret:'test-secret',readCustomer:unavailable};
  assert.equal(await reconcileWebhook({},Buffer.from('{}'),'bad-signature',deps),401);
  assert.equal(await reconcileWebhook({},undefined,'',deps),401);
});
test('the HTTP and hourly repair functions remain exported', () => {
  const index = readFileSync(new URL('../src/index.ts',import.meta.url),'utf8');
  assert.match(index,/export \{ revenuecatWebhook \}/);
  assert.match(index,/export \{ repairEntitlementClaims \}/);
});
