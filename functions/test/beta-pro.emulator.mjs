import '../lib/index.js';
import test from 'node:test';
import assert from 'node:assert/strict';
import {getFirestore} from 'firebase-admin/firestore';
import {changeBetaPro} from '../lib/betaPro.js';
import {fakeAuth} from './_paymongo-helpers.mjs';
assert.equal(process.env.GCLOUD_PROJECT,'demo-pantas-test');
const db=getFirestore(), end=Date.parse('2026-11-16T00:00:00+08:00'), now=end-60000;
const caller=uid=>({uid,token:{firebase:{sign_in_provider:'google.com'}}});
const request=(uid,enabled=true,extra={})=>({auth:caller(uid),app:{appId:'test'},data:{enabled,examId:'exam_cse_pro',...extra}});
const deps=()=>({db,auth:fakeAuth(),allow:async()=>true,now:()=>now,until:()=>end});
test('beta on and off are idempotent and copy exact-cutoff claims',async()=>{
 const uid='beta-toggle'; await db.recursiveDelete(db.doc(`users/${uid}`)); const d=deps();
 for(const enabled of [true,true,false,false,true]) {
  const result=await changeBetaPro(request(uid,enabled),d);
  assert.equal(result.enabled,enabled);
  const grant=(await db.doc(`users/${uid}/grants/beta_exam_cse_pro`).get()).data();
  assert.equal(grant.endsAt,end); assert.equal(grant.source,'beta'); assert.equal(grant.examId,'exam_cse_pro');
  assert.equal(d.auth.current().pro,enabled); assert.equal(d.auth.current().proUntil,enabled?end:0);
 }
});
test('beta refuses expired, disabled config, other account, signed out, no App Check, invalid exam and rate limit',async()=>{
 const cases=[
  [request('beta-deny'),{now:()=>end},'failed-precondition'],
  [request('beta-deny'),{until:()=>null},'failed-precondition'],
  [request('beta-deny',true,{uid:'someone-else'}),{},'permission-denied'],
  [{...request('beta-deny'),auth:undefined},{},'unauthenticated'],
  [{...request('beta-deny'),app:undefined},{},'unauthenticated'],
  [{...request('beta-deny'),app:{alreadyConsumed:true}},{},'unauthenticated'],
  [request('beta-deny',true,{examId:'exam_upcat'}),{},'invalid-argument'],
  [request('beta-deny',true,{examId:'missing'}),{},'invalid-argument'],
  [request('beta-deny'),{allow:async()=>false},'resource-exhausted'],
 ];
 for(const [req,overrides,code] of cases) await assert.rejects(changeBetaPro(req,{...deps(),...overrides}),e=>e.code===code);
});
