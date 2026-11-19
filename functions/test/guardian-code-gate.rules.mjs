import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test, {before, after} from 'node:test';
import {initializeTestEnvironment, assertFails} from '@firebase/rules-unit-testing';
import {collection, doc, getDoc, getDocs, setDoc, updateDoc, deleteDoc} from 'firebase/firestore';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);

// Every path the guardian code gate and the holder-child link use. Clients may touch none of them.
const PATHS = [
  'guardianCodes/gc-holder',
  'guardianCodeProofs/00000000000000000000000000000001',
  'guardianCodeLimits/gc-holder-2026-11-19',
  'guardianLimits/global-2026-11-19',
  'users/gc-holder/server/children/items/gc-kid',
  'users/gc-kid/server/childLink',
];

let env;
before(async () => {
  env = await initializeTestEnvironment({projectId: 'demo-pantas-test',
    firestore: {rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8')}});
  await env.withSecurityRulesDisabled(async context => {
    const db = context.firestore();
    for (const path of PATHS) await setDoc(doc(db, path), {holderUid: 'gc-holder', childUid: 'gc-kid', count: 1});
  });
});
after(async () => env?.cleanup());

for (const client of ['holder', 'child', 'other', 'signed-out']) {
  test(`guardian code gate data denies all client access: ${client}`, async () => {
    const db = client === 'signed-out' ? env.unauthenticatedContext().firestore()
      : env.authenticatedContext({holder: 'gc-holder', child: 'gc-kid', other: 'gc-other'}[client],
        {firebase: {sign_in_provider: client === 'child' ? 'custom' : 'google.com'}}).firestore();
    for (const path of PATHS) {
      const ref = doc(db, path);
      await assertFails(getDoc(ref));
      await assertFails(setDoc(ref, {count: 0}));
      await assertFails(updateDoc(ref, {count: 0}));
      await assertFails(deleteDoc(ref));
    }
    for (const path of ['guardianCodes', 'guardianCodeProofs', 'guardianCodeLimits', 'users/gc-holder/server/children/items']) {
      await assertFails(getDocs(collection(db, path)));
    }
    await assertFails(setDoc(doc(db, `guardianCodes/new-${client}`), {action: 'delete'}));
    await assertFails(setDoc(doc(db, `guardianCodeProofs/new-${client}`), {action: 'delete'}));
  });
}
