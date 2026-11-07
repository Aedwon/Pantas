import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test,{before,after} from 'node:test';
import {initializeTestEnvironment,assertFails,assertSucceeds} from '@firebase/rules-unit-testing';
import {doc,getDoc,setDoc,deleteDoc,collection,getDocs} from 'firebase/firestore';
import {ref,uploadBytes,getBytes,deleteObject,updateMetadata} from 'firebase/storage';
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
assert.ok(process.env.FIREBASE_STORAGE_EMULATOR_HOST);
let env;
const uid='feedback-rules-owner', id='A'.repeat(20), path=`betaFeedback/${uid}/${id}`;
const context=(owner=uid)=>env.authenticatedContext(owner,{firebase:{sign_in_provider:'google.com'}});
before(async()=>{
 env=await initializeTestEnvironment({projectId:'demo-pantas-test',
  firestore:{rules:readFileSync(new URL('../../firestore.rules',import.meta.url),'utf8')},
  storage:{rules:readFileSync(new URL('../../storage.rules',import.meta.url),'utf8')}});
 await env.withSecurityRulesDisabled(async c=>{
  for(const p of [`users/${uid}/betaFeedback/${id}`,`users/${uid}/betaReward/state`,`users/${uid}/betaReward/survey`])
   await setDoc(doc(c.firestore(),p),{test:true});
 });
});
after(async()=>env.cleanup());
test('feedback and reward records are owner-readable and never client-writable',async()=>{
 for(const group of ['betaFeedback','betaReward']) {
  const p=`users/${uid}/${group}/${group==='betaFeedback'?id:'state'}`;
  await assertSucceeds(getDoc(doc(context().firestore(),p)));
  await assertSucceeds(getDocs(collection(context().firestore(),`users/${uid}/${group}`)));
  for(const c of [context('other'),env.unauthenticatedContext(),
   env.authenticatedContext(uid,{firebase:{sign_in_provider:'anonymous'}})]) await assertFails(getDoc(doc(c.firestore(),p)));
  await assertFails(setDoc(doc(context().firestore(),p),{changed:true}));
  await assertFails(deleteDoc(doc(context().firestore(),p)));
  await assertFails(setDoc(doc(context().firestore(),`users/${uid}/${group}/new`),{test:true}));
 }
});
test('owner creates each supported image and reads it, but cannot replace or delete it',async()=>{
 for(const [i,type] of ['image/png','image/jpeg','image/webp'].entries()) {
  const target=ref(context().storage(),`${path}/${i}`);
  await assertSucceeds(uploadBytes(target,new Uint8Array(i===0?5*1024*1024:10),{contentType:type}));
  await assertSucceeds(getBytes(target));
  await assertFails(uploadBytes(target,new Uint8Array(10),{contentType:type}));
  await assertFails(deleteObject(target));
  await assertFails(updateMetadata(target,{contentType:'image/jpeg'}));
  for(const c of [context('other'),env.unauthenticatedContext()]) {
   await assertFails(getBytes(ref(c.storage(),`${path}/${i}`)));
   await assertFails(uploadBytes(ref(c.storage(),`${path}/${i}`),new Uint8Array(10),{contentType:type}));
   await assertFails(deleteObject(ref(c.storage(),`${path}/${i}`)));
  }
 }
});
test('image creates reject invalid path, MIME, oversize and missing ownership',async()=>{
 const storage=context().storage();
 for(const [suffix,type,size] of [
  ['3','image/png',10],['00','image/png',10],['0/extra','image/png',10],
  ['0','text/html',10],['0','image/gif',10],['0','image/png',5*1024*1024+1]]) {
  await assertFails(uploadBytes(ref(storage,`betaFeedback/${uid}/${'B'.repeat(20)}/${suffix}`),new Uint8Array(size),{contentType:type}));
 }
 await assertFails(uploadBytes(ref(storage,`betaFeedback/${uid}/bad/0`),new Uint8Array(10),{contentType:'image/png'}));
 for(const c of [context('other'),env.unauthenticatedContext()]) {
  await assertFails(uploadBytes(ref(c.storage(),`betaFeedback/${uid}/${'C'.repeat(20)}/0`),new Uint8Array(10),{contentType:'image/png'}));
 }
});
