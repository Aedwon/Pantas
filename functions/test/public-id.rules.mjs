import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test, {before, after} from 'node:test';
import {initializeTestEnvironment, assertSucceeds, assertFails} from '@firebase/rules-unit-testing';
import {doc, getDoc, setDoc, updateDoc} from 'firebase/firestore';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
let env;
before(async () => {
  env = await initializeTestEnvironment({projectId:'demo-pantas-test', firestore:{
    rules:readFileSync(new URL('../../firestore.rules',import.meta.url),'utf8'),
  }});
  await env.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(),'users/public-id-rules'), {publicId:'123456782'});
    await setDoc(doc(context.firestore(),'publicIds/123456782'), {uid:'public-id-rules'});
    await setDoc(doc(context.firestore(),'retiredPublicIds/999999998'), {retiredAt:new Date()});
  });
});
after(async () => env.cleanup());
test('R-5 owner reads their ID without Pro; other and anonymous readers are denied', async () => {
  const owner = env.authenticatedContext('public-id-rules', {firebase:{sign_in_provider:'google.com'}}).firestore();
  assert.equal((await assertSucceeds(getDoc(doc(owner,'users/public-id-rules')))).get('publicId'),'123456782');
  for (const reader of [env.unauthenticatedContext(), env.authenticatedContext('other-public-id'),
    env.authenticatedContext('public-id-rules',{firebase:{sign_in_provider:'anonymous'}})]) {
    await assertFails(getDoc(doc(reader.firestore(),'users/public-id-rules')));
  }
});
test('R-5 ID and retirement fields cannot be written by a client', async () => {
  const db = env.authenticatedContext('public-id-rules',{firebase:{sign_in_provider:'google.com'}}).firestore();
  await assertFails(updateDoc(doc(db,'users/public-id-rules'), {publicId:'999999998'}));
  await assertFails(updateDoc(doc(db,'users/public-id-rules'), {publicIdRetired:false}));
  await assertFails(setDoc(doc(db,'users/public-id-rules-new'), {createdAt:new Date(),publicId:'999999998'}));
});
test('R-5 mapping and retired IDs are unreadable and unwritable, including client admin claims', async () => {
  for (const claims of [{firebase:{sign_in_provider:'google.com'}}, {admin:true, firebase:{sign_in_provider:'google.com'}}]) {
    const db = env.authenticatedContext('public-id-rules',claims).firestore();
    for (const path of ['publicIds/123456782','retiredPublicIds/999999998']) {
      await assertFails(getDoc(doc(db,path)));
      await assertFails(setDoc(doc(db,path), {uid:'public-id-rules'}));
    }
  }
});
