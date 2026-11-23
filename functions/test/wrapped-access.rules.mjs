import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';
import {initializeTestEnvironment, assertFails, assertSucceeds} from '@firebase/rules-unit-testing';
import {doc, getDoc, setDoc, updateDoc} from 'firebase/firestore';
import {getBytes, ref, uploadBytes} from 'firebase/storage';
test('share paths bind the owner and share id; only revocation can change', async () => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
  const env = await initializeTestEnvironment({projectId: 'demo-pantas-test', firestore: {rules: readFileSync('../firestore.rules', 'utf8')}});
  try {
    const db = env.authenticatedContext('share-owner', {firebase: {sign_in_provider: 'google.com'}}).firestore();
    const id = 'a'.repeat(32), ref = doc(db, 'wrapped_shares', id);
    const record = {ownerUid: 'share-owner', revoked: false, storagePath: `wrapped/share-owner/${id}.png`,
      purgeAt: new Date(Date.now() + 80 * 86_400_000)};
    await assertFails(setDoc(ref, {...record, storagePath: `wrapped/victim/${id}.png`}));
    await assertFails(setDoc(ref, {...record, storagePath: `wrapped/share-owner/${'b'.repeat(32)}.png`}));
    await assertSucceeds(setDoc(ref, record));
    await assertFails(updateDoc(ref, {storagePath: 'private/secret.png'}));
    await assertSucceeds(updateDoc(ref, {revoked: true}));
  } finally {await env.cleanup();}
});

test('child claims cannot create or read Wrapped shares or images', async () => {
  const env = await initializeTestEnvironment({projectId: 'demo-pantas-test',
    firestore: {rules: readFileSync('../firestore.rules', 'utf8')},
    storage: {rules: readFileSync('../storage.rules', 'utf8')}});
  try {
    const uid = 'wrapped-rules-child', id = 'd'.repeat(32);
    const child = env.authenticatedContext(uid, {ageGroup: 'child', firebase: {sign_in_provider: 'custom'}});
    const path = `wrapped/${uid}/${id}.png`;
    const record = {ownerUid: uid, revoked: false, storagePath: path, purgeAt: new Date(Date.now() + 60_000)};
    const blob = new Uint8Array([1]);
    const share = doc(child.firestore(), 'wrapped_shares', id);
    const image = ref(child.storage(), path);
    await assertFails(setDoc(share, record));
    await assertFails(uploadBytes(image, blob, {contentType: 'image/png'}));
    await env.withSecurityRulesDisabled(async admin => {
      await setDoc(doc(admin.firestore(), 'wrapped_shares', id), record);
      await uploadBytes(ref(admin.storage(), path), blob, {contentType: 'image/png'});
    });
    await assertFails(getDoc(share));
    await assertFails(getBytes(image));
  } finally {await env.cleanup();}
});
