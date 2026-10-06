import assert from 'node:assert/strict';
import test from 'node:test';
import { exportData } from '../lib/index.js';

test('unfinished export returns the approved failed-precondition error', async () => {
  assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
  await assert.rejects(exportData.run({
    data: {}, auth: { uid: 'export-test', token: { firebase: { sign_in_provider: 'google.com' } } },
    app: { appId: 'demo-app' },
  }), {
    code: 'failed-precondition',
    message: "Data export isn't available in the app yet. Email our Data Protection Officer for a copy.",
  });
});
