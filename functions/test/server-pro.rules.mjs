import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test, {before, after} from 'node:test';
import {initializeTestEnvironment, assertFails} from '@firebase/rules-unit-testing';
import {collection, deleteDoc, doc, getDoc, getDocs, setDoc} from 'firebase/firestore';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
let env;
const paths = ['content/lessons/items/l1', 'content/questions/items/q1', 'content/catalog/items/index', 'content/catalog/items/exam_upcat', 'contentPro/q1',
  'users/sp-user/server/mocks/items/m1', 'users/sp-user/server/answers/items/s1',
  'content/mocks/items/exam_cse_pro', 'users/sp-user/server/roadmap', 'users/sp-user/server/settings', 'users/sp-user/server/answerTotals'];
before(async () => {
  env = await initializeTestEnvironment({projectId: 'demo-pantas-test', firestore: {rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8')}});
  await env.withSecurityRulesDisabled(async context => {
    for (const p of paths) await setDoc(doc(context.firestore(), p), {version: 'v'});
  });
});
// The suites share one emulator. These placeholder documents (for example a catalog index with no
// payload) must not outlive this suite, or the next suite's content loader reads them.
after(async () => {
  await env.withSecurityRulesDisabled(async context => {
    for (const p of paths) await deleteDoc(doc(context.firestore(), p));
  });
  await env.cleanup();
});

test('no client, including a current Pro owner, reads or writes content or the server records', async () => {
  const contexts = [
    env.authenticatedContext('sp-user', {firebase: {sign_in_provider: 'google.com'}, pro: true, proUntil: Date.now() + 86400000}),
    env.authenticatedContext('sp-user', {firebase: {sign_in_provider: 'anonymous'}}),
    env.unauthenticatedContext(),
  ];
  for (const context of contexts) {
    const db = context.firestore();
    for (const p of paths) {
      await assertFails(getDoc(doc(db, p)));
      await assertFails(setDoc(doc(db, p), {version: 'hacked'}));
    }
    await assertFails(getDocs(collection(db, 'content/lessons/items')));
    await assertFails(getDocs(collection(db, 'content/catalog/items')));
    await assertFails(getDocs(collection(db, 'contentPro')));
    await assertFails(getDocs(collection(db, 'users/sp-user/server/mocks/items')));
    await assertFails(getDocs(collection(db, 'users/sp-user/server/answers/items')));
  }
});
