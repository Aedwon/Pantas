import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test, {before, after} from 'node:test';
import {initializeTestEnvironment, assertFails, assertSucceeds} from '@firebase/rules-unit-testing';
import {doc, getDoc, getDocs, collection, setDoc, updateDoc, serverTimestamp, writeBatch} from 'firebase/firestore';
import {ref, uploadBytes, getBytes, deleteObject} from 'firebase/storage';

assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
assert.ok(process.env.FIREBASE_STORAGE_EMULATOR_HOST);
const fixtures = {
  absent: null, trimmed: {ageGroup: 'minor'}, confirmed: {status: 'confirmed'},
  withdrawn: {status: 'withdrawn'}, deleting: {status: 'confirmed'}, deletedConsent: null,
};
const blocked = new Set(['withdrawn', 'deleting', 'deletedConsent']);
const uidFor = state => `withdrawn-rules-${state}`;
const id = 'a'.repeat(32), feedbackId = 'A'.repeat(20), png = {contentType: 'image/png'};
const bytes = new Uint8Array([1, 2, 3]);
let env;
const context = (state, anonymous = false) => env.authenticatedContext(uidFor(state), {
  firebase: {sign_in_provider: anonymous ? 'anonymous' : 'google.com'}, pro: true, proUntil: Date.now() + 86400000,
});
before(async () => {
  env = await initializeTestEnvironment({projectId: 'demo-pantas-test',
    firestore: {rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8')},
    storage: {rules: readFileSync(new URL('../../storage.rules', import.meta.url), 'utf8')}});
  await env.withSecurityRulesDisabled(async c => {
    for (const [state, consent] of Object.entries(fixtures)) {
      const uid = uidFor(state), db = c.firestore();
      await setDoc(doc(db, `users/${uid}`), {createdAt: new Date()});
      if (consent) await setDoc(doc(db, `users/${uid}/server/guardianConsent`), consent);
      if (state === 'deleting' || state === 'deletedConsent') await setDoc(doc(db, `accountDeletions/${uid}`), {reason: 'guardian_withdrawal'});
      for (const path of ['passes/pass', 'grants/grant', 'betaFeedback/feedback', 'betaReward/state',
        'sync_state/current', 'sync_generations/active', 'sync_generations/active/lesson_progress/old']) {
        await setDoc(doc(db, `users/${uid}/${path}`), {activeGenerationId: 'active', status: 'active'});
      }
      await uploadBytes(ref(c.storage(), `betaFeedback/${uid}/${feedbackId}/0`), bytes, png);
      await uploadBytes(ref(c.storage(), `wrapped/${uid}/${id}.png`), bytes, png);
      await setDoc(doc(db, `wrapped_shares/${state.padEnd(32, 'b').slice(0, 32)}`), {ownerUid: uid, revoked: false});
    }
  });
});
after(async () => env.cleanup());

for (const state of Object.keys(fixtures)) {
  const check = blocked.has(state) ? assertFails : assertSucceeds;
  const label = blocked.has(state) ? 'denies' : 'allows';
  test(`${state}: Firestore ${label} own root read and update`, async () => {
    const db = context(state).firestore(), root = doc(db, `users/${uidFor(state)}`);
    await check(getDoc(root));
    await check(updateDoc(root, {displayName: 'Student'}));
  });
  test(`${state}: Firestore ${label} all own readable collections, including anonymous passes and grants`, async () => {
    const uid = uidFor(state), db = context(state).firestore();
    for (const path of ['passes/pass', 'grants/grant', 'betaFeedback/feedback', 'betaReward/state',
      'sync_state/current', 'sync_generations/active', 'sync_generations/active/lesson_progress/old']) {
      await check(getDoc(doc(db, `users/${uid}/${path}`)));
    }
    await check(getDocs(collection(db, `users/${uid}/passes`)));
    for (const path of ['passes/pass', 'grants/grant']) await check(getDoc(doc(context(state, true).firestore(), `users/${uid}/${path}`)));
  });
  test(`${state}: Firestore ${label} a multi-row sync batch`, async () => {
    const db = context(state).firestore(), batch = writeBatch(db);
    // Enough rows to expose uncached per-write access calls exceeding the 20-call batch budget.
    for (let i = 0; i < 10; i++) batch.set(doc(db, `users/${uidFor(state)}/sync_generations/active/lesson_progress/new-${i}`), {
      lessonId: `lesson-${i}`, readAt: new Date(), updatedAt: serverTimestamp(), originDeviceId: 'device',
      mutationId: `mutation-${i}`, schemaVersion: 1, deleted: false,
    });
    await check(batch.commit());
  });
  test(`${state}: Firestore ${label} wrapped share create and revoke for named and anonymous callers`, async () => {
    for (const anonymous of [false, true]) {
      const db = context(state, anonymous).firestore(), uid = uidFor(state);
      const shareId = `${anonymous ? 'c' : 'd'}${Object.keys(fixtures).indexOf(state)}`.padEnd(32, 'e');
      // Anonymous accounts can no longer publish a card, whatever their consent state.
      await (anonymous ? assertFails : check)(setDoc(doc(db, `wrapped_shares/${shareId}`), {ownerUid: uid, storagePath: `wrapped/${uid}/${shareId}.png`, revoked: false,
        purgeAt: new Date(Date.now() + 80 * 86_400_000)}));
      await check(updateDoc(doc(db, `wrapped_shares/${state.padEnd(32, 'b').slice(0, 32)}`), {revoked: true}));
    }
  });
  test(`${state}: Storage ${label} feedback read and create`, async () => {
    const s = context(state).storage(), path = `betaFeedback/${uidFor(state)}/${feedbackId}`;
    await check(getBytes(ref(s, `${path}/0`)));
    await check(uploadBytes(ref(s, `${path}/1`), bytes, png));
  });
  test(`${state}: Storage ${label} wrapped create, update and delete for named and anonymous callers`, async () => {
    for (const anonymous of [false, true]) {
      const s = context(state, anonymous).storage(), path = `wrapped/${uidFor(state)}`;
      const expected = anonymous ? assertFails : check;
      await expected(uploadBytes(ref(s, `${path}/${'f'.repeat(32)}.png`), bytes, png));
      await expected(uploadBytes(ref(s, `${path}/${id}.png`), bytes, png));
    }
    await check(deleteObject(ref(context(state).storage(), `wrapped/${uidFor(state)}/${id}.png`)));
  });
}
