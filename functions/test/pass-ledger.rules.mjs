import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test, {before,after} from 'node:test';
import {initializeTestEnvironment,assertSucceeds,assertFails} from '@firebase/rules-unit-testing';
import {doc,getDoc,setDoc} from 'firebase/firestore';
assert.equal(process.env.GCLOUD_PROJECT,'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
let env;
before(async()=>{
  env=await initializeTestEnvironment({projectId:'demo-pantas-test',firestore:{rules:readFileSync(new URL('../../firestore.rules',import.meta.url),'utf8')}});
  await env.withSecurityRulesDisabled(async context=>{
    await setDoc(doc(context.firestore(),'users/pass-rules/passes/GPA.test'),{examId:'exam_cse_pro',state:'active',endsAt:1900000000000});
  });
});
after(async()=>env.cleanup());
test('AC-4 named and anonymous owners read their passes without a Pro claim',async()=>{
  for(const provider of ['google.com','anonymous']) {
    const db=env.authenticatedContext('pass-rules',{firebase:{sign_in_provider:provider}}).firestore();
    assert.equal((await assertSucceeds(getDoc(doc(db,'users/pass-rules/passes/GPA.test')))).get('examId'),'exam_cse_pro');
  }
});
test('AC-4 clients cannot write pass records or read another account or ownership index',async()=>{
  const own=env.authenticatedContext('pass-rules',{firebase:{sign_in_provider:'google.com'},admin:true}).firestore();
  await assertFails(setDoc(doc(own,'users/pass-rules/passes/GPA.test'),{examId:'exam_let'}));
  await assertFails(getDoc(doc(own,'passOwners/GPA.test')));
  const other=env.authenticatedContext('pass-rules-other').firestore();
  await assertFails(getDoc(doc(other,'users/pass-rules/passes/GPA.test')));
});
