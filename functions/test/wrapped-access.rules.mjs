import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';
import {initializeTestEnvironment, assertFails, assertSucceeds} from '@firebase/rules-unit-testing';
import {doc, setDoc, updateDoc} from 'firebase/firestore';
test('share paths bind the owner and share id; only revocation can change', async () => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
  const env = await initializeTestEnvironment({projectId: 'demo-pantas-test', firestore: {rules: readFileSync('../firestore.rules', 'utf8')}});
  try {
    const db = env.authenticatedContext('share-owner').firestore();
    const id = 'a'.repeat(32), ref = doc(db, 'wrapped_shares', id);
    const record = {ownerUid: 'share-owner', revoked: false, storagePath: `wrapped/share-owner/${id}.png`};
    await assertFails(setDoc(ref, {...record, storagePath: `wrapped/victim/${id}.png`}));
    await assertFails(setDoc(ref, {...record, storagePath: `wrapped/share-owner/${'b'.repeat(32)}.png`}));
    await assertSucceeds(setDoc(ref, record));
    await assertFails(updateDoc(ref, {storagePath: 'private/secret.png'}));
    await assertSucceeds(updateDoc(ref, {revoked: true}));
  } finally {await env.cleanup();}
});
