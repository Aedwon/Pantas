import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test, {before, after} from 'node:test';
import {initializeTestEnvironment, assertFails} from '@firebase/rules-unit-testing';
import {collection, doc, getDoc, getDocs, setDoc, updateDoc, deleteDoc} from 'firebase/firestore';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
let env;
before(async () => {
  env = await initializeTestEnvironment({projectId: 'demo-pantas-test',
    firestore: {rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8')}});
  await env.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(), 'accountDeletions/js-owner'), {reason: 'user_request', startedAt: 1, attempts: 1});
    await setDoc(doc(context.firestore(), 'jobState/evidencePurge'), {cursor: 'x'});
  });
});
after(async () => env?.cleanup());
for (const client of ['owner-named', 'owner-anonymous', 'other', 'signed-out']) {
  test(`pending deletions and job cursors deny all client access: ${client}`, async () => {
    const db = client === 'signed-out' ? env.unauthenticatedContext().firestore()
      : env.authenticatedContext(client.startsWith('owner') ? 'js-owner' : 'js-other', {
        firebase: {sign_in_provider: client === 'owner-anonymous' ? 'anonymous' : 'google.com'},
      }).firestore();
    for (const path of ['accountDeletions/js-owner', 'jobState/evidencePurge']) {
      const ref = doc(db, path);
      await assertFails(getDoc(ref));
      await assertFails(setDoc(ref, {attempts: 0}));
      await assertFails(updateDoc(ref, {attempts: 0}));
      await assertFails(deleteDoc(ref));
    }
    await assertFails(setDoc(doc(db, `accountDeletions/new-${client}`), {reason: 'user_request'}));
    await assertFails(getDocs(collection(db, 'accountDeletions')));
    await assertFails(getDocs(collection(db, 'jobState')));
  });
}
