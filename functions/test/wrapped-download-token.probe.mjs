// Diagnostic for blocked Must 3. Expected to fail until uploads stop issuing
// bearer tokens. Run explicitly, outside the passing regression suite.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';
import {initializeTestEnvironment, assertFails, assertSucceeds} from '@firebase/rules-unit-testing';

assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
assert.ok(process.env.FIREBASE_STORAGE_EMULATOR_HOST);

// A bearer download URL skips both Storage rules and the renderer's owner check.
for (const operation of ['create', 'update']) {
  test(`Wrapped ${operation} refuses download-token metadata`, async () => {
    const {ref, uploadBytes, updateMetadata} = await import('firebase/storage');
    const env = await initializeTestEnvironment({projectId: 'demo-pantas-test',
      storage: {rules: readFileSync('../storage.rules', 'utf8')}});
    try {
      const card = ref(env.authenticatedContext('wrapped-token-owner').storage(),
        `wrapped/wrapped-token-owner/${(operation === 'create' ? 'd' : 'e').repeat(32)}.png`);
      const metadata = {contentType: 'image/png', customMetadata: {firebaseStorageDownloadTokens: 'saved-bearer-token'}};
      if (operation === 'update') {
        await assertSucceeds(uploadBytes(card, new Uint8Array([1]), {contentType: 'image/png'}));
        await assertFails(updateMetadata(card, metadata));
      } else {
        await assertFails(uploadBytes(card, new Uint8Array([1]), metadata));
      }
    } finally {await env.cleanup();}
  });
}
