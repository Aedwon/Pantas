import assert from 'node:assert/strict';
import { existsSync } from 'node:fs';
import test from 'node:test';

test('deployed entry initializes exactly one default Admin app', async () => {
  assert.ok(existsSync(new URL('../lib/index.js', import.meta.url)), 'compiled deploy entry must exist');
  await import('../lib/index.js');
  const { getApps } = await import('firebase-admin/app');
  assert.equal(getApps().length, 1);
  assert.equal(getApps()[0].name, '[DEFAULT]');
});
