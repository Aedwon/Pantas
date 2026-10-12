import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test, {before,after} from 'node:test';
import {initializeTestEnvironment,assertFails,assertSucceeds} from '@firebase/rules-unit-testing';
import {collection,doc,getDoc,getDocs,setDoc} from 'firebase/firestore';

assert.equal(process.env.GCLOUD_PROJECT,'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
let env;
before(async()=>{
  env=await initializeTestEnvironment({projectId:'demo-pantas-test',firestore:{rules:readFileSync(new URL('../../firestore.rules',import.meta.url),'utf8')}});
  await env.withSecurityRulesDisabled(async context=>{
    const db=context.firestore();
    await setDoc(doc(db,'users/server-content-pro'),{publicId:'100000009'});
    await setDoc(doc(db,'examTracks/content-rule-test/proContent/lesson'),{body:'protected'});
  });
});
after(async()=>env.cleanup());

test('AC-8 even a current Pro user cannot read or list untiered server content',async()=>{
  const db=env.authenticatedContext('server-content-pro',{
    firebase:{sign_in_provider:'google.com'},pro:true,proUntil:Date.now()+86400000,
  }).firestore();
  await assertSucceeds(getDoc(doc(db,'users/server-content-pro')));
  await assertFails(getDoc(doc(db,'examTracks/content-rule-test/proContent/lesson')));
  await assertFails(getDocs(collection(db,'examTracks/content-rule-test/proContent')));
});
