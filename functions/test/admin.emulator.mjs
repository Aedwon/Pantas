import assert from 'node:assert/strict';
import { existsSync } from 'node:fs';
import test from 'node:test';

async function adminCallable() {
  assert.ok(existsSync(new URL('../lib/_admin.js', import.meta.url)), 'compiled admin guard must exist');
  const { requireAdmin } = await import('../lib/_admin.js');
  const { onCall } = await import('firebase-functions/v2/https');
  return onCall({ enforceAppCheck: true }, (request) => requireAdmin(request));
}

for (const [name, request] of [
  ['unauthenticated caller', { data: {}, app: { appId: 'demo-app' } }],
  ['non-admin caller', { data: {}, auth: { uid: 'student', token: { admin: false } }, app: { appId: 'demo-app' } }],
  ['truthy non-boolean claim', { data: {}, auth: { uid: 'student', token: { admin: 'true' } }, app: { appId: 'demo-app' } }],
  ['admin without App Check', { data: {}, auth: { uid: 'admin', token: { admin: true } } }],
]) {
  test(`admin callable denies ${name}`, async () => {
    const callable = await adminCallable();
    await assert.rejects(callable.run(request), { code: 'permission-denied' });
  });
}
