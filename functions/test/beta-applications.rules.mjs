import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test, {before, after} from 'node:test';
import {initializeTestEnvironment, assertFails} from '@firebase/rules-unit-testing';
import {collection, collectionGroup, doc, getDoc, getDocs, setDoc, updateDoc, deleteDoc} from 'firebase/firestore';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
let env;
before(async () => {
  env = await initializeTestEnvironment({projectId: 'demo-pantas-test',
    firestore: {rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8')}});
  await env.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(), 'betaApplications/beta-owner'), {ownerUid: 'beta-owner', uid: 'beta-owner'});
    await setDoc(doc(context.firestore(), 'betaApplications/beta-owner/private/details'), {value: 'private'});
  });
});
after(async () => env?.cleanup());
for (const client of ['owner-like', 'other', 'anonymous', 'signed-out']) {
  test(`betaApplications denies all client access: ${client}`, async () => {
    const db = client === 'signed-out' ? env.unauthenticatedContext().firestore()
      : env.authenticatedContext(client === 'owner-like' ? 'beta-owner' : `beta-${client}`, {
        firebase: {sign_in_provider: client === 'anonymous' ? 'anonymous' : 'google.com'},
        pro: true, proUntil: Date.now() + 86400000,
      }).firestore();
    for (const path of ['betaApplications/beta-owner', 'betaApplications/beta-owner/private/details']) {
      const ref = doc(db, path);
      await assertFails(getDoc(ref));
      await assertFails(setDoc(ref, {ownerUid: 'beta-owner'}));
      await assertFails(updateDoc(ref, {value: 'changed'}));
      await assertFails(deleteDoc(ref));
    }
    await assertFails(setDoc(doc(db, `betaApplications/new-${client}`), {ownerUid: 'beta-owner'}));
    await assertFails(getDocs(collection(db, 'betaApplications')));
    await assertFails(getDocs(collection(db, 'betaApplications/beta-owner/private')));
    await assertFails(getDocs(collectionGroup(db, 'betaApplications')));
  });
}
