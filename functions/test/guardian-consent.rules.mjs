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
    await setDoc(doc(context.firestore(), 'users/gr-owner/server/guardianConsent'), {status: 'pending'});
    await setDoc(doc(context.firestore(), 'guardianTokens/abc'), {uid: 'gr-owner', state: 'open'});
    await setDoc(doc(context.firestore(), 'guardianLimits/abc'), {count: 1});
    await setDoc(doc(context.firestore(), 'guardianConsentEvidence/gr-owner/responses/abc'), {
      action: 'confirm', decidedAt: 1, documentVersions: {teens: '2026-11-09'},
      noticeWordingVersion: '2026-11-12',
    });
  });
});
after(async () => env?.cleanup());
for (const client of ['owner-named', 'owner-anonymous', 'other', 'signed-out']) {
  test(`guardian consent data denies all client access: ${client}`, async () => {
    const db = client === 'signed-out' ? env.unauthenticatedContext().firestore()
      : env.authenticatedContext(client.startsWith('owner') ? 'gr-owner' : 'gr-other', {
        firebase: {sign_in_provider: client === 'owner-anonymous' ? 'anonymous' : 'google.com'},
      }).firestore();
    for (const path of ['users/gr-owner/server/guardianConsent', 'guardianTokens/abc', 'guardianLimits/abc', 'guardianConsentEvidence/gr-owner/responses/abc']) {
      const ref = doc(db, path);
      await assertFails(getDoc(ref));
      await assertFails(setDoc(ref, {status: 'confirmed'}));
      await assertFails(updateDoc(ref, {status: 'confirmed'}));
      await assertFails(deleteDoc(ref));
    }
    await assertFails(setDoc(doc(db, 'users/gr-owner/server/guardianConsent'), {status: 'confirmed'}, {merge: true}));
    await assertFails(setDoc(doc(db, `guardianTokens/new-${client}`), {state: 'open'}));
    await assertFails(getDocs(collection(db, 'guardianTokens')));
    await assertFails(getDocs(collection(db, 'guardianConsentEvidence/gr-owner/responses')));
    await assertFails(getDocs(collection(db, 'users/gr-owner/server')));
  });
}
